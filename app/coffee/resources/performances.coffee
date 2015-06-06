resources = angular.module('resources')


Performance = (restmod, RMUtils, $Evt) ->

    Performance = restmod.model('/performances').mix 'nbRestApi', {
        
    }


resources.factory 'Performance',['restmod', 'RMUtils', '$nbEvent', Performance]