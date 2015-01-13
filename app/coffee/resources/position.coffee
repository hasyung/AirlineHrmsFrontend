














resources = angular.module('resources')



Position = (restmod, RMUtils, $Evt) ->
    # restmod.model('/positions')
    Position = restmod.model('/positions').mix 'nbRestApi', {
        department_id: {mask: 'R', map: 'department.id'}
        department: {mask: 'CU'}
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

    }










resources.factory 'Position',['restmod', Position]
