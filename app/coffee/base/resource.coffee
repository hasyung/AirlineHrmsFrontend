




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

    transform = (arr = []) ->

        arr = [] if not angular.isArray(arr)

        newarr = []
        arr.forEach (val) ->
            res = _.transform (result, val, key) ->
                if key == 'name'
                    key = 'label'
                result[key] = val
            newarr.push res
        return newarr

    cacheIndex = (arr = []) ->
        newarr = _.cloneDeep arr
        newarr.forEach (val, index) ->
            val['mapping'] = index
        return newarr

    unflatten = (array, parent = {}, tree = []) ->

        children = _.filter array, (child) ->
            if typeof parent.id == 'undefined'
                return child.parentId == undefined
            else
                child.parentId == parent.id

        if not _.isEmpty( children )
            if parent.id == undefined
                tree = children
            else
                parent['children'] = children

            _.each children, (child) -> unflatten(array, child, tree)

        return tree



    Org = restmod.model('/departments').mix {

        positions: { hasMany: 'Position'}

        $extend:
            Collection:
                abc: () ->
                    forEach =  angular.forEach
                    forEach this, (model) ->
                        console.debug model
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

