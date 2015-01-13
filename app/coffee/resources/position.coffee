














resources = angular.module('resources')



Position = (restmod) ->
    restmod.model('/positions').mix 'nbRestApi', {
        department_id: {mask: 'R', map: 'department.id'}
        department: {mask: 'CU'}



    }










resources.factory 'Position',['restmod', Position]
