resources = angular.module('resources')

# position.specifications.fetch()

Employee = (restmod, RMUtils, $Evt) ->

    Employee = restmod.model('/employees').mix 'nbRestApi', 'DirtyModel', {
        departmentId: {mask: 'R', map: 'department.id'}
        department: {mask: 'CU'}

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

        startDate: {decode: 'date', param: 'yyyy年MM月dd日',mask: 'CU'}
        endDate: {decode: 'date', param: 'yyyy年MM月dd日',mask: 'CU'}


        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)

    }
User = (restmod, RMUtils, $Evt) ->
    User = restmod.model(null).mix 'nbRestApi', {
        educationExperiences: { hasMany: 'Education'}
        workExperiences: { hasMany: 'Experience'}
        $config:
            jsonRoot: 'employee'
        familymembers: {hasMany: 'FamilyMember'}
    }
    .single('/me')
Education = (restmod, RMUtils, $Evt) ->
    Education = restmod.model().mix 'nbRestApi', {
        admissionDate: {decode: 'date', param: 'yyyy-MM-dd'}
        graduationDate: {decode: 'date', param: 'yyyy-MM-dd'}
        $hooks: {
            'after-create': ->
                $Evt.$send('education:create:success', "教育经历创建成功")
            'after-create-error': ->
                $Evt.$send('education:create:error', "教育经历创建失败")
            'after-update': ->
                $Evt.$send('education:update:success', "教育经历更新成功")
            'after-update-error': ->
                $Evt.$send('education:update:error', "教育经历更新失败")
        }
        $config:
            jsonRootSingle: 'education_experience'
            jsonRootMany: 'education_experiences'
    }
Experience = (restmod, RMUtils, $Evt) ->
    Experience = restmod.model().mix 'nbRestApi', {
        startDate: {decode: 'date', param: 'yyyy-MM-dd'}
        endDate: {decode: 'date', param: 'yyyy-MM-dd'}
        $hooks: {
            'after-create': ->
                $Evt.$send('work:create:success', "工作经历创建成功")
            'after-create-error': ->
                $Evt.$send('work:create:error', "工作经历创建失败")
            'after-update': ->
                $Evt.$send('work:update:success', "工作经历更新成功")
            'after-update-error': ->
                $Evt.$send('work:update:error', "工作经历更新失败")
        }
        $config:
            jsonRootSingle: 'work_experience'
            jsonRootMany: 'work_experiences'
    }

FamilyMember = (restmod, RMUtils, $Evt) ->
    FamilyMember = restmod.model().mix 'nbRestApi', {
        $config:
            jsonRootSingle: 'family_member'
            jsonRootMany: 'family_members'
    }
Resume = (restmod, RMUtils, $Evt) ->
    Resume = restmod.model().mix 'nbRestApi', {
        $config:
            jsonRoot: 'employee'
    }

resources.factory 'Employee',['restmod', 'RMUtils', '$nbEvent', Employee]
resources.factory 'User',['restmod', 'RMUtils', '$nbEvent', User]
resources.factory 'Formerleaders',['restmod', 'RMUtils', '$nbEvent', Formerleaders]
resources.factory 'Education',['restmod', 'RMUtils', '$nbEvent', Education]
resources.factory 'Experience',['restmod', 'RMUtils', '$nbEvent', Experience]
resources.factory 'FamilyMember',['restmod', 'RMUtils', '$nbEvent', FamilyMember]
resources.factory 'Resume',['restmod', 'RMUtils', '$nbEvent', Resume]
