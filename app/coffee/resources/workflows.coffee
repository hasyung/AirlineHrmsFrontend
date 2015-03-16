resources = angular.module('resources')


Leave = (restmod, RMUtils, $Evt) ->
    Leave = restmod.model('/workflows/Flow::Leave').mix 'nbRestApi', 'DirtyModel', {
        

    }



resources.factory 'Leave',['restmod', 'RMUtils', '$nbEvent', Leave]
