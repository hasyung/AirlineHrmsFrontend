resources = angular.module('resources')


Contract = (restmod, RMUtils, $Evt) ->
    Change = restmod.model('/contracts').mix 'nbRestApi', 'DirtyModel', {
        startDate: {decode: 'date', param: 'yyyy-MM-dd'}
        endDate: {decode: 'date', param: 'yyyy-MM-dd'}
    }

resources.factory 'Contract',['restmod', 'RMUtils', '$nbEvent', Contract]
