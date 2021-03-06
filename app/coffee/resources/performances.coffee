resources = angular.module('resources')


Performance = (restmod, RMUtils, $Evt) ->
    Performance = restmod.model('/performances').mix 'nbRestApi', 'DirtyModel', {
        attachments: {hasMany: 'Attachment'}

        owner: {belongsTo: 'Employee', key: 'employee_id'}
    }

PerformanceMix = (restmod, RMUtils, $Evt) ->
    Performance = restmod.model('/performances/index_all').mix 'nbRestApi', 'DirtyModel', {
        attachments: {hasMany: 'Attachment'}

        $config:
            jsonRootSingle: 'performance'
            jsonRootMany: 'performances'

        owner: {belongsTo: 'Employee', key: 'employee_id'}
    }


Attachment = (restmod, RMUtils, $Evt)->
    Attachment = restmod.model().mix 'nbRestApi', {
        $config:
            jsonRoot: 'attachments'
    }


Allege = (restmod, RMUtils, $Evt)->
    Allege = restmod.model('/alleges').mix 'nbRestApi', {
        attachments: {hasMany: 'Attachment'}

        owner: {belongsTo: 'Employee', key: 'employee_id'}
    }


PerformanceTemp = (restmod, RMUtils, $Evt)->
    PerformanceTemp = restmod.model('/performances/temp').mix 'nbRestApi', 'DirtyModel', {
    }


resources.factory 'Attachment', ['restmod', 'RMUtils', '$nbEvent', Attachment]
resources.factory 'Performance', ['restmod', 'RMUtils', '$nbEvent', Performance]
resources.factory 'PerformanceMix', ['restmod', 'RMUtils', '$nbEvent', PerformanceMix]
resources.factory 'Allege', ['restmod', 'RMUtils', '$nbEvent', Allege]
resources.factory 'PerformanceTemp', ['restmod', 'RMUtils', '$nbEvent', PerformanceTemp]