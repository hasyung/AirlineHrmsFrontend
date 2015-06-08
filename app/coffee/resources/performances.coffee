resources = angular.module('resources')


Performance = (restmod, RMUtils, $Evt) ->

    Performance = restmod.model('/performances').mix 'nbRestApi', {

    }

Allege = (restmod, RMUtils, $Evt)->

    Allege = restmod.model('/alleges').mix 'nbRestApi', {

    }

PerformanceTemp = (restmod, RMUtils, $Evt)->

    PerformanceTemp = restmod.model('/performances/temp').mix 'nbRestApi', 'DirtyModel', {

    }


resources.factory 'Performance',['restmod', 'RMUtils', '$nbEvent', Performance]
resources.factory 'Allege',['restmod', 'RMUtils', '$nbEvent', Allege]
resources.factory 'PerformanceTemp',['restmod', 'RMUtils', '$nbEvent', PerformanceTemp]