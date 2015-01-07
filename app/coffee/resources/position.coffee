














resources = angular.module('resources')



Position = (restmod) ->
    restmod.model('/positions')










resources.factory 'Position',['restmod', Position]
