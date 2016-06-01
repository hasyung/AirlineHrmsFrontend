# 科室管理
resources = angular.module('resources')

Report = (restmod, RMUtils, $Evt) ->
    Report = restmod.model('/reports').mix 'nbRestApi', {
        # updateDate: {decode: 'date', param: 'yyyy-MM-dd HH:mm'}
        
        # owner: {belongsTo: 'Employee', key: 'employee_id'}

        $config:
            jsonRootSingle: 'report'
            jsonRootMany: 'reports'

    }















resources.factory 'Reports', ['restmod', 'RMUtils', '$nbEvent', Report]