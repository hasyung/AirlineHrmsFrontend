














resources = angular.module('resources')

# position.specifications.fetch()

Position = (restmod, RMUtils, $Evt) ->

    # restmod.model('/positions')
    Position = restmod.model('/positions').mix 'nbRestApi', {
        department_id: {mask: 'R', map: 'department.id'}
        department: {mask: 'CU'}
        isSelected: {init: false , volatile: true}
        specifications: { hasOne: 'Specification'}

        $hooks:
            'after-create': ->
                $Evt.$send('position:create:success', "岗位创建成功")
    	$extend:
            Collection:
                $adjust: (infoData)->
                    self = @
                    url = this.$url()
                    request = {
                        method: 'POST',
                        url: "#{url}/adjust",
                        data: infoData
                    }

                    # $Evt.$send('positions:adjust:success')
                    onSuccess = (res)->
                        self.$dispatch 'after-active', res
                        # $Evt.$send('org:refresh')

                    onErorr = (res) ->
                        self.$dispatch 'after-active-error', res

                    this.$send(request, onSuccess, onErorr)

                $batchRemove: (ids) ->
                    self = @
                    url = this.$url()
                    request = {
                        method: 'POST',
                        url: "#{url}/batch_destroy",
                        data: ids
                    }

                    this.$send(request, onSuccess, onErorr)


    }




Specification = (restmod, RMUtils, $Evt) ->
    Specification = restmod.model('/specifications').mix 'nbRestApi', {


    }







resources.factory 'Position',['restmod', 'RMUtils', '$nbEvent', Position]
resources.factory 'Specification',['restmod', 'RMUtils', '$nbEvent', Specification]
