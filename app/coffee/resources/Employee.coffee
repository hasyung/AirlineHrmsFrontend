resources = angular.module('resources')


Employee = (restmod, RMUtils, $Evt) ->
    Employee = restmod.model('/employees').mix 'nbRestApi', 'NestedDirtyModel', {
        department: {belongsTo: 'Org', mask: 'CU'}

        joinScalDate: {decode: 'date', param: 'yyyy-MM-dd'}
        startWorkDate: {decode: 'date', param: 'yyyy-MM-dd'}
        startDate: {decode: 'date', param: 'yyyy-MM-dd', mask: 'CU'}
        isSelected: {mask: "CU"}

        resume: {hasOne: 'Resume', mask: 'CU'}
        familyMembers: {hasMany: 'FamilyMember', mask: 'CU'}
        performances: {hasMany: 'Performance', mask: 'CU'}
        rewards: {hasMany: 'Reward', mask: 'CU'}
        punishments: {hasMany: 'Punishment', mask: 'CU'}

        $hooks: {
            'after-create': ->
                $Evt.$send('employee:create:success', "新员工创建成功")
            'after-update': ->
                $Evt.$send('employee:update:success', "员工信息更新成功")
        }

        $extend:
            Scope:
                leaders: () ->
                    restmod.model('/employees/simple_index').mix($config: jsonRoot: 'employees').$search()

            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
    }


LeaveEmployees = (restmod, RMUtils, $Evt) ->
    LeaveEmployees = restmod.model('/leave_employees').mix 'nbRestApi', {
        joinScalDate: {decode: 'date', param: 'yyyy-MM-dd'}
        startWorkDate: {decode: 'date', param: 'yyyy-MM-dd'}
        startDate: {decode: 'date', param: 'yyyy-MM-dd'}

        owner: {belongsTo: 'Employee', key: 'employee_id'}
    }

MoveEmployees = (restmod, RMUtils, $Evt) ->
    MoveEmployees = restmod.model('/special_states').mix 'nbRestApi', {
        $config:
            jsonRootSingle: 'special_state'
            jsonRootMany: 'special_states'

        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $hooks: {
            'after-update': ->
                $Evt.$send('MoveEmployees:update:success', "修改成功")
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

        startDate: {decode: 'date', param: 'yyyy-MM-dd', mask: 'CU'}
        endDate: {decode: 'date', param: 'yyyy-MM-dd', mask: 'CU'}

        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
    }


resources.factory 'Employee', ['restmod', 'RMUtils', '$nbEvent', Employee]
resources.factory 'Formerleaders', ['restmod', 'RMUtils', '$nbEvent', Formerleaders]
resources.factory 'LeaveEmployees', ['restmod', 'RMUtils', '$nbEvent', LeaveEmployees]
resources.factory 'MoveEmployees', ['restmod', 'RMUtils', '$nbEvent', MoveEmployees]

