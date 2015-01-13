














resources = angular.module('resources')



Position = (restmod) ->
    restmod.model('/positions')
    Position = restmod.model('/positions').mix 'nbRestApi', {

    	$extend:
            Resource:
                $adjust: (infoData)->
                    self = @
                    url = RMUtils.joinUrl(this.$url(), 'adjust')
                    request = {method: 'POST', url: url, data: infoData}
                    # $Evt.$send('positions:adjust:success')
                    onSuccess = (res)->
                        self.$dispatch 'after-active', res
                        # $Evt.$send('org:refresh')

                    onErorr = (res) ->
                        self.$dispatch 'after-active-error', res

                    this.$send(request, onSuccess, onErorr)

                


    }










resources.factory 'Position',['restmod', Position]
