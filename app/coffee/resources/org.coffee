resources = angular.module('resources')


Org = (restmod, RMUtils, $Evt, DEPARTMENTS, $http) ->
    Constants = {
        NODE_INDEX: 3 # serial_number 生成策略是parent_node.serial_number+node_index，node_index由3位构成，值为创建该node时，其parent_node.children_count
    }

    transform = (arr = [], keyPair={'name': 'title'}) ->
        arr = [] if not angular.isArray(arr)

        newarr = []
        arr.forEach (val) ->
            val['type'] = 'subordinate'
            res = _.transform val, (result, val, key) ->
                if keyPair.hasOwnProperty(key)
                    result[keyPair[key]] = val
                else
                    result[key] = val
                return
            newarr.push res
        return newarr

    cacheIndex = (arr = []) ->
        newarr = _.cloneDeep arr
        newarr.forEach (val, index) ->
            val['mapping'] = index
        return newarr

    # 将数组根据 parent_id 转为 tree 形式
    # 子机构顺序根据机构sort_no 排序
    #
    #  tree 结构为
    #  [{
    #    id: 2
    #    children: []
    #  }]
    #
    #  param: array 待转换的数组
    #         ttl   tree 的最大深度
    #
    unflatten = (array, ttl = 9,parent = {}, tree = []) ->

        if ttl == 0
            return
        ttl = ttl - 1

        children = _.filter array, (child) ->
            if typeof parent.id == 'undefined'
                return child.parent_id == undefined or child.parent_id == 0
            else
                child.parent_id == parent.id

        children.sort (a, b) -> a.sort_no - b.sort_no

        if not _.isEmpty( children )
            if parent.id == undefined
                tree = children
            else
                parent['children'] = children

            _.each children, (child) -> unflatten(array, ttl, child, tree)

        return parent

    #将数组类型的机构数据转换成树形数据
    treeful = (treeData, DEPTH, parent) ->

        if not parent?
            parent = _.find treeData, (child) ->
                child.parent_id == undefined or child.parent_id == 0 #根节点
        else
            parent = _.find treeData, (child) ->
                parent.id == child.id

        staff_org = _.remove treeData, (child) -> child.is_stick == true
        parent.staff = staff_org.sort (a, b) -> a.sort_no - b.sort_no

        committee_org = _.remove treeData, (child) -> child.committee == true
        parent.committee = committee_org.sort (a, b) -> a.sort_no - b.sort_no
        return unflatten(treeData, DEPTH, parent)


    computeFullName = (parent, ttl, initalArr = []) ->
        initalArr.unshift(parent.name) && ttl--

        if ttl == 0
            initalArr.join(">")
        else
            if ( parent.parentId || parent.parent_id ) && parent.xdepth > 2
                parentDep = _.find DEPARTMENTS, {'id': parent.parentId || parent.parent_id}

                # 未生效的机构当前在DEPARTMENTS无法找到
                # OrgStore依赖于Org，这里注入会出现循环依赖
                if !parentDep
                    $http.get('/api/departments?edit_mode=true').success (data) ->
                        parentDep = _.find data.departments, {'id': parent.parentId || parent.parent_id}

                        if !parentDep
                            throw new Error("机构 #{parent.name}:#{parent.id}，找不到父级 #{parent.parentId}")

                        return computeFullName(parentDep, ttl, initalArr)
                else
                    return computeFullName(parentDep, ttl, initalArr)
            else
                return initalArr.join(">")


    Org = restmod.model('/departments').mix 'nbRestApi', 'DirtyModel', {
        $config:
            jsonRootMany: 'departments'

        positions: { hasMany: 'Position'}

        fullName: {
            computed: (val) ->
                computeFullName(@, 3)
            mask: "CU"
        }

        $hooks:
            'after-fetch-many': -> $Evt.$send('org:refresh')

            # 有无必要自定义事件增加系统复杂度? 待观察
            'after-destroy': ->
                $Evt.$send('org:refresh')
                $Evt.$send('org:destroy:success',"机构删除成功")

            'after-active': ->
                $Evt.$send('org:refresh')
                $Evt.$send('org:active:success', "生效成功")

            'after-revert': ->
                $Evt.$send('org:refresh')
                $Evt.$send('org:revert:success', "撤销成功")

            'after-update': ->
                $Evt.$send('org:refresh')
                $Evt.$send('org:update:success', "修改成功")

            'after-newsub': ->
                $Evt.$send('org:refresh')
                $Evt.$send('org:newsub:success', "机构创建成功")

            'after-transfer': ->
                $Evt.$send('org:transfer:success', "划转机构成功")

        $extend:
            Resource:
                #生效所有已执行的机构操作
                active: (formdata)->
                    self = @
                    url = RMUtils.joinUrl(this.$url(), 'active')
                    request = {method: 'POST', url: url, data: formdata}
                    $Evt.$send('org:active:process')
                    onSuccess = (res)->
                        self.$dispatch 'after-active', res
                        $Evt.$send('org:refresh')

                    this.$send(request, onSuccess)
                #撤销所有已执行的操作
                revert: ->
                    self = @
                    url = RMUtils.joinUrl(this.$url(), 'revert')
                    request = {method: 'POST', url: url}

                    onSuccess = (res) ->
                        self.$dispatch 'after-revert', res
                        $Evt.$send('org:refresh')

                    this.$send(request, onSuccess)

            Collection:
                queryPrimaryOrg: (org) ->
                    self = @
                    PRIMARY_ORG_DEPTH = 2 #一正机构 深度
                    depth = org.xdepth
                    accumulator = org

                    parentOrg = (childOrgId) ->
                        _.find self, (item) -> item.id == childOrgId

                    if depth <= PRIMARY_ORG_DEPTH
                        return org
                    else
                        diff = depth - PRIMARY_ORG_DEPTH
                        accumulator = parentOrg(accumulator.parentId) while diff-- > 0
                    return accumulator

                treeful: (org, DEPTH = 4) ->
                    IneffectiveOrg = (org)-> #系统还有未生效的组织机构
                        return /inactive$/.test org.status

                    allOrgs =  @$wrap()
                    cachedIndexOrgs = cacheIndex(allOrgs)
                    rootSerialNumber = org.serialNumber
                    rootDepth = org.xdepth

                    isModified = false  #当前组织机构树是否被修改过

                    treeData = _.filter cachedIndexOrgs, (orgItem) ->
                        throw Error('serial number if required') if not orgItem.serial_number
                        #tree 数据深度不能超过 DEPTH
                        return false if orgItem.xdepth - rootDepth > DEPTH

                        isChild = _.startsWith(orgItem.serial_number, rootSerialNumber) #子机构的serialNumber number 前缀和父机构相同
                        # isModified = true if isChild and IneffectiveOrg(orgItem)

                        return isChild

                    #待优化
                    _.forEach cachedIndexOrgs, (orgItem) ->
                        isModified = true if IneffectiveOrg(orgItem)

                    treeData = treeful(treeData, DEPTH, org)

                    return {
                        data: treeData
                        isModified: isModified
                    }

                jqTreeful: () ->
                    allOrgs = @$wrap()
                    treeData = transform(allOrgs, {'name': 'label'}) # for jqTree
                    parent = _.find treeData, (child) -> child.parent_id == undefined or child.parent_id == 0 #根节点
                    treeData = unflatten(treeData, Infinity, parent)
                    return [treeData]
            Record:
                newSub: (org) ->
                    onSuccess = ->
                        @.$dispatch 'after-newsub'

                    org = this.$scope.$build(org)
                    org.parentId = this.$pk
                    org.$save().$then onSuccess

                transfer: (to_dep_id) -> #划转机构 {to_department_id: to_id}
                    self = @

                    onSuccess = -> # bug? 直接修改属性 collection 中数据可能不会改变, 会影响到机构树
                        @parentId = to_dep_id
                        @.$dispatch 'after-transfer'

                    url = this.$url()

                    request = {
                        url: "#{url}/transfer"
                        method: 'POST'
                        data:{
                            to_department_id: to_dep_id
                        }
                    }

                    @.$send request, onSuccess
    }


class OrgStore extends nb.Service
    @.$inject = ['Org', 'DEPARTMENTS', 'USER_META']

    constructor: (@Org, @DEPARTMENTS, @USER_META) ->

    initialize: () ->
        @orgs = @Org.$collection().$fetch(edit_mode: true)

    reload: ()->
        @orgs.$refresh({edit_mode: true})

    get: ->
        return @orgs

    getPrimaryOrgs: ->
        return @DEPARTMENTS.filter (o) -> o.xdepth == 2

    getOrgsByIds: (ids) ->
        self = @

        reduceOrgs = (res, id, $index) ->
            res.push _.find self.orgs, {id: id}
            return res

        ids.reduce(reduceOrgs, [])

    queryMatchedOrgs: (text) ->
        @orgs.filter (org) ->
            s.include(org.fullName, text)

    getPrimaryOrgId: (id) ->
        currentOrg = _.find(@DEPARTMENTS, {id: @USER_META.department.id})
        serialNumber = currentOrg.serial_number

        if serialNumber
            if serialNumber.length == 6
                return currentOrg.id
            else if serialNumber.length > 6
                primaryOrgSerialNumber = serialNumber.slice(0, 6)
                primaryOrg = _.find(@DEPARTMENTS, {serial_number: primaryOrgSerialNumber})
                return primaryOrg.id
            else
                throw "can not find org id : #{id} primary org "


resources.service 'OrgStore', OrgStore
resources.factory 'Org', ['restmod', 'RMUtils', '$nbEvent', 'DEPARTMENTS', '$http', Org]