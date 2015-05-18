resources = angular.module('resources')


Notification = (restmod, RMUtils, $Evt) ->
    Notification = restmod.model('/me/notifications').mix 'nbRestApi', {
        createdAt: {decode: 'date', param: 'yyyy-MM-dd'}
        updatedAt: {decode: 'date', param: 'yyyy-MM-dd'}

    }



resources.factory 'Notification',['restmod', 'RMUtils', '$nbEvent', Notification]
