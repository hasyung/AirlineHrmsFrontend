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
        technicalRecords: {hasMany: 'TechnicalRecords', mask: 'CU'}

        $hooks: {
            'after-create': ->
                $Evt.$send('employee:create:success', "新员工创建成功")
            'after-update': ->
                $Evt.$send('employee:update:success', "员工信息更新成功")
            'after-leave': ->
                $Evt.$send('employee:leave:success', "员工已设置为离职状态")
            'after-retire': ->
                $Evt.$send('employee:retire:success', "员工已设置为退养状态")
            'after-change-education': ->
                $Evt.$send('employee:change_education:success', "员工学历已更新")
            'after-edit-technical': ->
                $Evt.$send('employee:edit_technical:success', "员工技术通道等级已更新")
            'after-change-employee-date': ->
                $Evt.$send('employee:change_employee_date:success', "员工工作年限已更新")
            'after-change-employee-tech-grade': ->
                $Evt.$send('employee:change_employee_tech_grade:success', "员工技术等级已更新")
        }

        $extend:
            Scope:
                leaders: () ->
                    restmod.model('/employees/simple_index').mix($config: jsonRoot: 'employees').$search()

                flow_leaders: (employeeId) ->
                    # 专门为流程发起的领导列表
                    restmod.model('/employees/flow_leader_index').mix($config: jsonRoot: 'employees').$search({employee_id: employeeId})

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

                edit_tech: (params, list, tableState)->
                    self = this

                    request = {
                        url: "/api/employees/#{this.id}/update_technical_grade"
                        method: "PUT"
                        data: params
                    }

                    onSuccess = (res) ->
                        self.$dispatch 'after-edit-technical'
                        list.$refresh(tableState)

                    this.$send(request, onSuccess)

                set_early_retire: (params, list, tableState)->
                    self = this

                    request = {
                        url: "/api/employees/#{this.id}/set_early_retire"
                        method: "POST"
                        data: params
                    }

                    onSuccess = (res) ->
                        self.$dispatch 'after-retire'
                        list.$refresh(tableState)

                    this.$send(request, onSuccess)

                # 设置员工工作年限相关
                set_employee_date: (params, list, tableState)->
                    self = this

                    request = {
                        url: "/api/employees/#{this.id}/set_employee_date"
                        method: "POST"
                        data: params
                    }

                    onSuccess = (res) ->
                        self.$dispatch 'after-change-employee-date'
                        list.$refresh(tableState)

                    this.$send(request, onSuccess)

                # 设置员工技术等级
                set_tech_grade: (params, list, tableState)->
                    self = this

                    request = {
                        url: "/api/employees/#{this.id}/change_technical"
                        method: "POST"
                        data: params
                    }

                    onSuccess = (res) ->
                        self.$dispatch 'after-change-employee-tech-grade'
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

EmployeesHasEarlyRetire = (restmod, RMUtils, $Evt) ->
    EmployeesHasEarlyRetires = restmod.model('/employees/search').mix 'nbRestApi', {
        department: {belongsTo: 'Org', mask: 'CU'}

        joinScalDate: {decode: 'date', param: 'yyyy-MM-dd'}
        startWorkDate: {decode: 'date', param: 'yyyy-MM-dd'}
        startDate: {decode: 'date', param: 'yyyy-MM-dd'}

        $config:
            jsonRootSingle: 'employee'
            jsonRootMany: 'employees'

        owner: {belongsTo: 'Employee', key: 'employee_id'}
    }

LeaveEmployees = (restmod, RMUtils, $Evt) ->
    LeaveEmployees = restmod.model('/leave_employees').mix 'nbRestApi', {
        joinScalDate: {decode: 'date', param: 'yyyy-MM-dd'}
        startWorkDate: {decode: 'date', param: 'yyyy-MM-dd'}
        startDate: {decode: 'date', param: 'yyyy-MM-dd'}

        owner: {belongsTo: 'Employee', key: 'employee_id'}
    }

EarlyRetireEmployees = (restmod, RMUtils, $Evt) ->
    EarlyRetireEmployees = restmod.model('/early_retire_employees').mix 'nbRestApi', {
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

AdjustPositionRecord = (restmod, RMUtils, $Evt) ->
    AdjustPositionEmployees = restmod.model('/position_records').mix 'nbRestApi', {
        $config:
            jsonRootSingle: 'position_record'
            jsonRootMany: 'position_records'

        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
    }

EducationExpRecord = (restmod, RMUtils, $Evt) ->
    EducationExpEmployees = restmod.model('/education_experience_records').mix 'nbRestApi', {
        $config:
            jsonRootSingle: 'education_experience_record'
            jsonRootMany: 'education_experience_records'

        owner: {belongsTo: 'Employee', key: 'employee_id'}

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

ClassSystem = (restmod, RMUtils, $Evt) ->
    ClassSystem = restmod.model('/work_shifts/index').mix 'nbRestApi', {
        # joinScalDate: {decode: 'date', param: 'yyyy-MM-dd'}
        $config:
            jsonRootSingle: 'work_shift'
            jsonRootMany: 'work_shifts'

        owner: {belongsTo: 'Employee', key: 'employee_id'}
    }


resources.factory 'Employee', ['restmod', 'RMUtils', '$nbEvent', Employee]
resources.factory 'EmployeesHasEarlyRetire', ['restmod', 'RMUtils', '$nbEvent', EmployeesHasEarlyRetire]
resources.factory 'Formerleaders', ['restmod', 'RMUtils', '$nbEvent', Formerleaders]
resources.factory 'LeaveEmployees', ['restmod', 'RMUtils', '$nbEvent', LeaveEmployees]
resources.factory 'EarlyRetireEmployees', ['restmod', 'RMUtils', '$nbEvent', EarlyRetireEmployees]
resources.factory 'AdjustPositionWaiting', ['restmod', 'RMUtils', '$nbEvent', AdjustPositionWaiting]
resources.factory 'AdjustPositionRecord', ['restmod', 'RMUtils', '$nbEvent', AdjustPositionRecord]
resources.factory 'EducationExpRecord', ['restmod', 'RMUtils', '$nbEvent', EducationExpRecord]
resources.factory 'MoveEmployees', ['restmod', 'RMUtils', '$nbEvent', MoveEmployees]
resources.factory 'ClassSystem', ['restmod', 'RMUtils', '$nbEvent', ClassSystem]

