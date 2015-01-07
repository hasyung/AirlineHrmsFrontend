

resources = angular.module('resources')


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

resources.factory 'User',['restmod', User]
