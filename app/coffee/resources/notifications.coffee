resources = angular.module('resources')


Notification = (restmod, RMUtils, $Evt) ->
    Notification = restmod.model('/me/notifications').mix 'nbRestApi', 'DirtyModel', {

    }



resources.factory 'Notification',['restmod', 'RMUtils', '$nbEvent', Notification]
