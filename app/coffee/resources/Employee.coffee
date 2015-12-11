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
            'after-leave': ->
                $Evt.$send('employee:leave:success', "员工已设置为离职状态")
            'after-change-education': ->
                $Evt.$send('employee:change_education:success', "员工学历已更新")
        }

        $extend:
            Scope:
                leaders: () ->
                    restmod.model('/employees/simple_index').mix($config: jsonRoot: 'employees').$search()

            Record:
                update_basic_info: ()->
                    this.editType = 'basic'
                    this.$save()

                update_position_info: ()->
                    this.editType = 'position'
                    this.$save()

                update_skill_info: ()->
                    this.editType = 'skill'
                    this.$save()

                set_leave: (params, list, tableState)->
                    self = this

                    request = {
                        url: "/api/employees/#{this.id}/set_leave"
                        method: "POST"
                        data: params
                    }

                    onSuccess = (res) ->
                        self.$dispatch 'after-leave'
                        list.$refresh(tableState)

                    this.$send(request, onSuccess)

                update_education: (params, list, tableState)->
                    self = this

                    request = {
                        url: "/api/employees/#{this.id}/change_education"
                        method: "POST"
                        data: params
                    }

                    onSuccess = (res) ->
                        self.$dispatch 'after-change-education'
                        list.$refresh(tableState)

                    this.$send(request, onSuccess)

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

        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
    }

AdjustPositionWaiting = (restmod, RMUtils, $Evt) ->
    MoveEmployees = restmod.model('/position_change_records').mix 'nbRestApi', {
        $config:
            jsonRootSingle: 'position_change_record'
            jsonRootMany: 'position_change_records'

        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $hooks: {
            'after-destroy': ->
                $Evt.$send('position_change_record:destroy:success', "撤销成功")
        }

        $extend:
            Record:
                repeal: () ->
                    this.$destroy()

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
resources.factory 'AdjustPositionWaiting', ['restmod', 'RMUtils', '$nbEvent', AdjustPositionWaiting]
resources.factory 'MoveEmployees', ['restmod', 'RMUtils', '$nbEvent', MoveEmployees]

