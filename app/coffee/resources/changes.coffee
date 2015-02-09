resources = angular.module('resources')


Change = (restmod, RMUtils, $Evt) ->

    # restmod.model('/positions')
    Change = restmod.model('/changes').mix 'nbRestApi', 'DirtyModel', {
        

    }



resources.factory 'Change',['restmod', 'RMUtils', '$nbEvent', Change]
