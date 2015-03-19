resources = angular.module('resources')


Notification = (restmod, RMUtils, $Evt) ->
    Notification = restmod.model('/notifications').mix 'nbRestApi', 'DirtyModel', {

    }



resources.factory 'Notification',['restmod', 'RMUtils', '$nbEvent', Notification]
