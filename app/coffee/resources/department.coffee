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

ReportNeedToKnow = (restmod, RMUtils, $Evt) ->
	ReportNeedToKnow = restmod.model('/reports/need_to_know').mix 'nbRestApi', {
        # updateDate: {decode: 'date', param: 'yyyy-MM-dd HH:mm'}

        $config:
            jsonRootSingle: 'report'
            jsonRootMany: 'reports'

    }







resources.factory 'Reports', ['restmod', 'RMUtils', '$nbEvent', Report]
resources.factory 'ReportNeedToKnow', ['restmod', 'RMUtils', '$nbEvent', ReportNeedToKnow]