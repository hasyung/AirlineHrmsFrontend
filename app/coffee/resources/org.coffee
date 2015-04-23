

resources = angular.module('resources')
find = _.find


Org = (restmod, RMUtils, $Evt, DEPARTMENTS) ->

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

        if not _.isEmpty( children )
            if parent.id == undefined
                tree = children
            else
                parent['children'] = children

            _.each children, (child) -> unflatten(array, ttl, child, tree)

        return parent


    treeful = (treeData, DEPTH, parent) ->

        if not parent?
            parent = _.find treeData, (child) -> child.parent_id == undefined or child.parent_id == 0 #根节点
        else
            parent = _.find treeData, (child) -> parent.id == child.id
        return unflatten(treeData, DEPTH, parent)


    computeFullName = (ttl, initalArr = []) ->
        initalArr.unshift(this.name) && ttl--

        if ttl == 0
            initalArr.join(">")
        else
            if ( this.parentId || this.parent_id ) && this.depth > 2
                parentDep = find DEPARTMENTS, 'id', this.parentId || this.parent_id
                if !parentDep
                    throw new Error("机构数据结构错误 机构#{this.name}：#{this.id} 找不到parent #{this.parentId} 的机构")
                else
                    return computeFullName.call(parentDep, ttl, initalArr)
            else
                return initalArr.join(">")


    Org = restmod.model('/departments').mix 'nbRestApi', 'DirtyModel', {

        positions: { hasMany: 'Position'}

        fullName: {
            computed: (val) ->
                computeFullName.call(this, 3)
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
                treeful: (org, DEPTH = 4) ->
                    IneffectiveOrg = (org)-> #系统还有未生效的组织机构
                        return /inactive$/.test org.status

                    allOrgs =  @$wrap()
                    cachedIndexOrgs = cacheIndex(allOrgs)
                    rootSerialNumber = org.serialNumber
                    rootDepth = org.depth

                    isModified = false  #当前组织机构树是否被修改过

                    treeData = _.filter cachedIndexOrgs, (orgItem) ->
                        throw Error('serial number if required') if not orgItem.serial_number
                        #tree 数据深度不能超过 DEPTH
                        return false if orgItem.depth - rootDepth > DEPTH

                        isChild = _.str.startsWith(orgItem.serial_number,rootSerialNumber) #子机构的serialNumber number 前缀和父机构相同
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
                    treeData = treeful(treeData, Infinity)

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




resources.factory 'Org',['restmod', 'RMUtils', '$nbEvent', 'DEPARTMENTS', Org]
