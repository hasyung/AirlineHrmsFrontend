resources = angular.module('resources')

# position.specifications.fetch()

Employee = (restmod, RMUtils, $Evt) ->

    Employee = restmod.model('/employees').mix 'nbRestApi', {
        departmentId: {mask: 'R', map: 'department.id'}
        department: {mask: 'CU'}
        joinScalDate: {decode: 'date', param: 'yyyy年mm月dd日',mask: 'CU'}
        isSelected: {mask: "CU"}
        # 是否超编

        $hooks: {

        }
        $extend:
            Collection: {}
        

    }

User = (restmod, RMUtils, $Evt) ->
    User = restmod.model(null).mix 'nbRestApi', {
        $config:
            jsonRoot: 'employee'
    }
    .single('/employees/current')


resources.factory 'Employee',['restmod', 'RMUtils', '$nbEvent', Employee]
resources.factory 'User',['restmod', 'RMUtils', '$nbEvent', User]
