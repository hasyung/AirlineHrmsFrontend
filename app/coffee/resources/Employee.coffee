resources = angular.module('resources')

# position.specifications.fetch()

Employee = (restmod, RMUtils, $Evt) ->

    Employee = restmod.model('/employees').mix 'nbRestApi', 'DirtyModel', {
        departmentId: {mask: 'R', map: 'department.id'}
        department: {mask: 'CU'}

        joinScalDate: {decode: 'date', param: 'yyyy年MM月dd日',mask: 'CU'}

        startDate: {decode: 'date', param: 'yyyy年MM月dd日',mask: 'CU'}

        isSelected: {mask: "CU"}

        $hooks: {
            'after-create': ->
                $Evt.$send('employee:create:success', "新员工创建成功")
            'after-create-error': ->
                $Evt.$send('employee:create:error', "新员工创建失败")
        }
        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)


    }
Formerleaders = (restmod, RMUtils, $Evt) ->
    Leader = restmod.model('/formerleaders').mix 'nbRestApi', {
        $config:
            jsonRoot: 'employees'

        startDate: {decode: 'date', param: 'yyyy年MM月dd日',mask: 'CU'}
        endDate: {decode: 'date', param: 'yyyy年MM月dd日',mask: 'CU'}


        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)

    }
User = (restmod, RMUtils, $Evt) ->
    User = restmod.model(null).mix 'nbRestApi', {
        $config:
            jsonRoot: 'employee'
        familymembers: {hasMany: 'FamilyMember'}
    }
    .single('/me')

FamilyMember = (restmod, RMUtils, $Evt) ->
    FamilyMember = restmod.model().mix 'nbRestApi', {
        $config:
            jsonRoot: 'family_members'
    }


resources.factory 'Employee',['restmod', 'RMUtils', '$nbEvent', Employee]
resources.factory 'User',['restmod', 'RMUtils', '$nbEvent', User]
resources.factory 'Formerleaders',['restmod', 'RMUtils', '$nbEvent', Formerleaders]
resources.factory 'FamilyMember',['restmod', 'RMUtils', '$nbEvent', FamilyMember]
