














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

                $removeMany: (ids) ->
                    self = @
                    url = this.$url()
                    request = {
                        method: 'POST', 
                        url: "#{url}/batch_destroy",
                        data: ids
                    }
                    # $Evt.$send('positions:adjust:success')
                    onSuccess = (res)->
                        self.$dispatch 'after-active', res
                        # $Evt.$send('org:refresh')

                    onErorr = (res) ->
                        self.$dispatch 'after-active-error', res

                    this.$send(request, onSuccess, onErorr)

            Record:

                $getJD: () ->
                    self = @
                    url = this.$url()
                    request = {
                        method: 'GET', 
                        url: "#{url}/specifications",
                    }
                    onSuccess = ->
                        @.$dispatch 'after-get'
                    onErorr = ->
                        @.$dispatch 'after-get-error', arguments
                    this.$send(request, onSuccess, onErorr)

    }




Specification = (restmod) ->
    restmod.model('/specifications')





resources.factory 'Position',['restmod', Position]
resources.factory 'Specification',['restmod', Specification]
