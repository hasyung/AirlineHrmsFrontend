




# {id:1, name: '董事会'}
# {id:3, parentId: 1 , name:'总经办'}


# {
#     id:1
#     name: '董事会'
#     children: [
#         {
#             id: 2
#             name: '总经办'
#         }
#     ]
# }

# to
# {
#     label: '董事会'
#     class: 'highlight'
#     id: 1
#     children: [
#         {
#             label: '总经办'
#             id: 2
#         }

#     ]
# }


# class ResourceService

#     constructor: ->


#     get: (key) ->
#         return ''


resources = angular.module('resources')



nbRestApi = (restmod, RMUtils, $rootScope, $Evt) ->

    Utils = RMUtils

    restmod.mixin {

        hooks:
            'after-request-error': (res)->
                $Evt.$send('global:request:error',res)



        'Record.$store': (_patch) ->
            self = @
            self.$action () ->
                url = Utils.joinUrl(self.$url('update'),_patch)

                request =
                    method: 'PATCH'
                    url: url
                    data: self.$wrap (_name) -> _patch.indexOf(_name) == -1

                onSuccess = (_response) ->
                    self[_patch] = _response.data

                onErorr = (_response) ->
                    self.$dispatch 'after-store-error', [_response]

                @.$send request, onSuccess, onErorr

        'Record.$copy': ->
            raw = this.$wrap()
            copy = this.$scope.$buildRaw(raw)
            return copy


    }

User = (restmod) ->
    User = restmod.model('/users').mix('nbRestApi', {
        # created_at: { serialize: 'RailsDate' } #todo 序列化器
        updated_at: { decode: 'date', param: 'yyyy年mm月dd日',mask: 'CUR' } #不 send CURD 操作时
        permissions: { belongsToMany: 'Permission', keys: 'permission_ids'}
        # permission_ids: { mask: 'CU' }
        organ: { mask: 'CU'}
        organs: { hasMany: 'Organ'}
        gender: { mask: 'U'}
        # orgName: { map: 'organ'}

        # decode: () ->
        #     console.debug 'decode debug :', arguments

        orgName: { ignore: true }

        $extend:
            Model:
                unpack: (resource,_raw) ->
                    console.debug 'resource,raw',resource,_raw
                    _raw.orgName = _.pluck(_raw.organ,'name').join(',')
                    _raw

        $hooks:
            'after-feed-many': (raw) ->
                console.debug 'after feed many this:' ,this
            'after-feed': (raw) ->
                org = raw.organ
                this.orgName = _.pluck(org,'name').join(',')



    })


Org = (restmod, RMUtils, $Evt) ->

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


    Org = restmod.model('/departments').mix 'nbRestApi', {

        positions: { hasMany: 'Position'}


        $hooks:
            # 有无必要自定义事件增加系统复杂度? 待观察
            'after-destroy': ->
                $Evt.$send('org:destroy:success',"机构：#{self.scope.currentOrg.name} ,删除成功")

            'after-active': ->
                $Evt.$send('org:active:success', "生效成功")

            'after-active-error': ->
                $Evt.$send('org:active:error', arguments)

            'after-revert': ->
                $Evt.$send('org:revert:success', "撤销成功")

        $extend:
            Scope:
                active: (formdata)->
                    self = @
                    url = RMUtils.joinUrl(this.$url(), 'active')
                    request = {method: 'POST', url: url, data: formdata}

                    onSuccess = (res)->
                        self.$dispatch 'after-active', res

                    onErorr = (res) ->
                        self.$dispatch 'after-active-error', res

                    this.$send(request, onSuccess, onErorr)

                revert: ->
                    self = @
                    url = RMUtils.joinUrl(this.$url(), 'revert')
                    request = {method: 'POST', url: url}

                    onSuccess = (res) ->
                        self.$dispatch 'after-revert', res

                    onErorr = (res) ->
                        self.$dispatch 'after-revert-error', res

                    this.$send(request, onSuccess, onErorr)



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
                        isModified = true if isChild and IneffectiveOrg(orgItem)

                        return isChild

                    treeData = transform(treeData, {'name': 'title'})
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
                    org = this.$build(org)
                    org.parentId = this.$primay
                    org.$save()


                transfer: (to_dep_id) -> #划转机构 {to_department_id: to_id}
                    self = @

                    onSuccess = -> # bug? 直接修改属性 collection 中数据可能不会改变, 会影响到机构树
                        self.parentId = to_dep_id

                    url = this.$url()
                    request = {to_department_id: to_dep_id}
                    promise =  $http.post "#{url}/transfer", request
                    promise.then onSuccess


    }

Position = (restmod) ->
    restmod.model('/positions')

Permission = (restmod) ->
    Permission = restmod.model('/permissions'). mix {

    }



resources.factory 'nbRestApi',['restmod','RMUtils', '$nbEvent', nbRestApi]
resources.factory 'Org',['restmod', 'RMUtils', '$nbEvent', Org]
resources.factory 'User',['restmod', User]
resources.factory 'Permission',['restmod', Permission]
resources.factory 'Position',['restmod', Position]

