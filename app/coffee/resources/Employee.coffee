resources = angular.module('resources')

# position.specifications.fetch()

Employee = (restmod, RMUtils, $Evt) ->

    # restmod.model('/positions')
    Employee = restmod.model('/employees').mix 'nbRestApi', {
        department_id: {mask: 'R', map: 'department.id'}
        department: {mask: 'CU'}
        # isSelected: {mask: "CU"}
        # 是否超编

        $hooks: {

        }
        $extend:
            Collection: {}


    }










resources.factory 'Employee',['restmod', 'RMUtils', '$nbEvent', Employee]
