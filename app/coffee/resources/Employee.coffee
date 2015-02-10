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

        startDate: {decode: 'date', param: 'yyyy年MM月dd日',mask: 'CU'}
        endDate: {decode: 'date', param: 'yyyy年MM月dd日',mask: 'CU'}


        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)

    }
User = (restmod, RMUtils, $Evt) ->
    User = restmod.model(null).mix 'nbRestApi', {
        educationExperiences: { hasOne: 'Education'}
        workExperiences: { hasOne: 'Experience'}
        $config:
            jsonRoot: 'employee'
    }
    .single('/me')
Education = (restmod, RMUtils, $Evt) ->
    Education = restmod.model('/education_experiences').mix 'nbRestApi', {
        
    }
Experience = (restmod, RMUtils, $Evt) ->
    Experience = restmod.model('/work_experiences').mix 'nbRestApi', {
        
    }

resources.factory 'Employee',['restmod', 'RMUtils', '$nbEvent', Employee]
resources.factory 'User',['restmod', 'RMUtils', '$nbEvent', User]
resources.factory 'Formerleaders',['restmod', 'RMUtils', '$nbEvent', Formerleaders]
resources.factory 'Education',['restmod', 'RMUtils', '$nbEvent', Education]
resources.factory 'Experience',['restmod', 'RMUtils', '$nbEvent', Experience]
