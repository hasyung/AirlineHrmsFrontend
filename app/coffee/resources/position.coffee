resources = angular.module('resources')

# position.specifications.fetch()

Position = (restmod, RMUtils, $Evt) ->

    # restmod.model('/positions')
    Position = restmod.model('/positions').mix 'nbRestApi', {
        department_id: {mask: 'R', map: 'department.id'}
        department: {mask: 'CU'}
        isSelected: {init: false , mask: "CU"}
        specification: { hasOne: 'Specification', mask: "U"}

        $hooks:
            'after-create': ->
                $Evt.$send('position:create:success', "岗位创建成功")

            'after-update': ->
                $Evt.$send('position:update:success', "岗位更新成功")

            'after-destroy': ->
                $Evt.$send('position:destroy:success',"岗位删除成功")
            'after-destroy-error': ->
                $Evt.$send('position:destroy:success', arguments)
            'after-adjust': ->
                $Evt.$send('position:adjust:success',"岗位调整成功")
            'after-adjust': ->
                $Evt.$send('position:adjust:success', arguments)
    	$extend:
            Collection:
                $adjust: (infoData)->
                    self = @
                    # url = this.$url()
                    request = {
                        method: 'POST',
                        url: "api/positions/adjust",
                        data: infoData
                    }

                    onSuccess = (res)->
                        angular.forEach infoData.position_ids, (id) ->
                            item = _.find self, {id: id}
                            self.$remove item
                        self.$dispatch 'after-adjust', res

                    onErorr = (res) ->
                        self.$dispatch 'after-adjust-error', res

                    this.$send(request, onSuccess, onErorr)

                $batchRemove: (ids) ->
                    self = @
                    request = {
                        method: 'POST',
                        url: "api/positions/batch_destroy",
                        data: ids
                    }
                    onSuccess = (res)->
                        angular.forEach ids.ids, (id) ->
                            item = _.find self, {id: id}
                            self.$remove item
                            
                        self.$dispatch 'after-destroy', res

                    onErorr = (res) ->
                        self.$dispatch 'after-destroy-error', res

                    this.$send(request, onSuccess, onErorr)


    }




Specification = (restmod, RMUtils, $Evt) ->
    Specification = restmod.model().mix 'nbRestApi', {
        $config:
            jsonRoot: 'specification'

        $hooks:
            'after-update': ->
                $Evt.$send('position:update:success', "岗位说明书更新成功")

    }







resources.factory 'Position',['restmod', 'RMUtils', '$nbEvent', Position]
resources.factory 'Specification',['restmod', 'RMUtils', '$nbEvent', Specification]
