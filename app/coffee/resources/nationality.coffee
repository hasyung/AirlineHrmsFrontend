resources = angular.module('resources')


Nationality = (restmod, RMUtils, $Evt) ->
    restmod.model('/nationality/index').mix 'nbRestApi', 'DirtyModel', {
        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $config:
            jsonRootSingle: 'nation'
            jsonRootMany: 'nations'

    }


resources.factory 'Nationality', ['restmod', 'RMUtils', '$nbEvent', Nationality]