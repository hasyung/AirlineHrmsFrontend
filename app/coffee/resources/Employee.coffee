resources = angular.module('resources')

# position.specifications.fetch()

Employee = (restmod, RMUtils, $Evt) ->

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

User = (restmod, RMUtils, $Evt) ->

    cached = null

    User = restmod.model('/employees').mix 'nbRestApi', {
        department_id: {mask: 'R', map: 'department.id'}
        department: {mask: 'CU'}

        $hooks: {

        }
        $extend:
            Collection: {}
            Scope:
                getCurrentUser: () ->
                    if !cached
                        cached = true
                        this.$find('current')

    }








resources.factory 'Employee',['restmod', 'RMUtils', '$nbEvent', Employee]
resources.factory 'User',['restmod', 'RMUtils', '$nbEvent', User]
