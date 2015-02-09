resources = angular.module('resources')


Change = (restmod, RMUtils, $Evt) ->

    Change = restmod.model('/changes/check').mix 'nbRestApi', 'DirtyModel', {
        checkDate: {decode: 'date', param: 'yyyy年MM月dd日',mask: 'CU'}
        createdAt: {decode: 'date', param: 'yyyy年MM月dd日',mask: 'CU'}
        $config:
            jsonRoot: 'change_actions'

    }
Record = (restmod, RMUtils, $Evt) ->

    Record = restmod.model('/changes/record').mix 'nbRestApi', 'DirtyModel', {
        $config:
            jsonRoot: 'change_actions'

    }


resources.factory 'Change',['restmod', 'RMUtils', '$nbEvent', Change]
resources.factory 'Record',['restmod', 'RMUtils', '$nbEvent', Record]
