




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



VXstoreApi = (restmod, RMUtils) ->

    Utils = RMUtils

    restmod.mixin {
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



    }

User = (restmod) ->
    User = restmod.model('/users').mix('VXstoreApi', {
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


Org = (restmod) ->

    Constants = {
        NODE_INDEX: 3 # serial_number 生成策略是parent_node.serial_number+node_index，node_index由3位构成，值为创建该node时，其parent_node.children_count
    }


    transform = (arr = []) ->

        arr = [] if not angular.isArray(arr)

        newarr = []
        arr.forEach (val) ->
            val['type'] = 'subordinate'
            res = _.transform val, (result, val, key) ->
                if key == 'name'
                    key = 'title'
                result[key] = val
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
        parent = _.find treeData, (child) ->
            parent.id == child.id
        return unflatten(treeData, DEPTH, parent)



    Org = restmod.model('/departments').mix {

        positions: { hasMany: 'Position'}

        $extend:
            Collection:
                treeful: (org, DEPTH = 4) ->
                    IneffectiveOrg = (org)-> #系统还有未生效的组织机构
                        return /inactive/.test org.status

                    allOrgs =  @$wrap()
                    cachedIndexOrgs = cacheIndex(allOrgs)
                    rootSerialNumber = org.serialNumber
                    rootDepth = org.depth

                    isModified = false  #当前组织机构树是否被修改过

                    treeData = _.filter cachedIndexOrgs, (orgItem) ->
                        throw Error('serial number if required') if not orgItem.serial_number
                        #tree 数据深度不能超过 DEPTH
                        return false if orgItem.depth - rootDepth > DEPTH

                        isModified = true if IneffectiveOrg(orgItem)
                        isChild = _.str.startsWith(orgItem.serial_number,rootSerialNumber) #子机构的serialNumber number 前缀和父机构相同

                        return isChild

                    treeData = transform(treeData)
                    treeData = treeful(treeData, DEPTH, org)

                    return {
                        data: treeData
                        isModified: isModified
                    }
    }

Position = (restmod) ->
    restmod.model('/positions')

Permission = (restmod) ->
    Permission = restmod.model('/permissions'). mix {

    }



resources.factory 'VXstoreApi',['restmod','RMUtils', VXstoreApi]
resources.factory 'Org',['restmod', Org]
resources.factory 'User',['restmod', User]
resources.factory 'Permission',['restmod', Permission]
resources.factory 'Position',['restmod', Position]

