resources = angular.module('resources')


Leave = (restmod, RMUtils, $Evt) ->
    Leave = restmod.model('/workflows/leave').mix 'nbRestApi', 'DirtyModel', {
        

    }



resources.factory 'Leave',['restmod', 'RMUtils', '$nbEvent', Leave]
