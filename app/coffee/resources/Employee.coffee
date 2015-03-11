resources = angular.module('resources')

# position.specifications.fetch()

Employee = (restmod, RMUtils, $Evt) ->

    Employee = restmod.model('/employees').mix 'nbRestApi', 'DirtyModel', {
        # departmentId: {mask: 'R', map: 'department.id'}
        department: {mask: 'CU', belongsTo: 'Org'}
        # dept: {belongsTo: 'Org', key: 'department_id'}

        joinScalDate: {decode: 'date', param: 'yyyy-MM-dd',mask: 'CU'}

        startDate: {decode: 'date', param: 'yyyy-MM-dd',mask: 'CU'}

        isSelected: {mask: "CU"}
        resume: { hasOne: 'Resume', mask: 'CU'}

        $hooks: {
            'after-create': ->
                $Evt.$send('employee:create:success', "新员工创建成功")
            'after-create-error': ->
                $Evt.$send('employee:create:error', "新员工创建失败")
            'after-update': ->
                $Evt.$send('employee:update:success', "员工信息更新成功")
            'after-update-error': ->
                $Evt.$send('employee:update:error', "员工信息跟新失败")
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

        startDate: {decode: 'date', param: 'yyyy-MM-dd',mask: 'CU'}
        endDate: {decode: 'date', param: 'yyyy-MM-dd',mask: 'CU'}


        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)

    }

resources.factory 'Employee',['restmod', 'RMUtils', '$nbEvent', Employee]
resources.factory 'Formerleaders',['restmod', 'RMUtils', '$nbEvent', Formerleaders]
