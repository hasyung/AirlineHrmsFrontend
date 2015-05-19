resources = angular.module('resources')


Contrack = (restmod, RMUtils, $Evt) ->
    Change = restmod.model('/contracks').mix 'nbRestApi', 'DirtyModel', {
        startDate: {decode: 'date', param: 'yyyy-MM-dd'}
        endDate: {decode: 'date', param: 'yyyy-MM-dd'}
    }

resources.factory 'Contrack',['restmod', 'RMUtils', '$nbEvent', Contrack]
