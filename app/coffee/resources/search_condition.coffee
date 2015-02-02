resources = angular.module('resources')

# position.specifications.fetch()

Condition = (restmod, RMUtils, $Evt) ->

    # restmod.model('/positions')
    Condition = restmod.model('/search_conditions').mix {}










resources.factory 'SearchCondition',['restmod', 'RMUtils', '$nbEvent', Condition]
