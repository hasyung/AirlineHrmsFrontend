###
# 与用户相关联的资源
#
#
# File: user.coffee
###

resources = angular.module('resources')


User = (restmod, RMUtils, $Evt) ->
    User = restmod.model(null).mix 'nbRestApi', 'DirtyModel', {
        $hooks:
            'after-update': ->
                $Evt.$send('user:update:success', "个人信息更新成功")

        educationExperiences: { hasMany: 'Education'}
        workExperiences: { hasMany: 'Experience'}
        resume: { hasOne: 'Resume', mask: 'CU'}
        $config:
            jsonRoot: 'employee'
        familymembers: {hasMany: 'FamilyMember'}
    }
    .single('/me')
Education = (restmod, RMUtils, $Evt) ->
    Education = restmod.model().mix 'nbRestApi', {
        admissionDate: {decode: 'date', param: 'yyyy-MM-dd',mask: 'CU'}
        graduationDate: {decode: 'date', param: 'yyyy-MM-dd',mask: 'CU'}
        $hooks: {
            'after-create': ->
                $Evt.$send('education:create:success', "教育经历创建成功")
            'after-update': ->
                $Evt.$send('education:update:success', "教育经历更新成功")
            'after-destroy': ->
                $Evt.$send('education:update:success', "教育经历删除成功")
        }
        $config:
            jsonRootSingle: 'education_experience'
            jsonRootMany: 'education_experiences'
    }
Experience = (restmod, RMUtils, $Evt) ->
    Experience = restmod.model().mix 'nbRestApi', {
        startDate: {decode: 'date', param: 'yyyy-MM-dd',mask: 'CU'}
        endDate: {decode: 'date', param: 'yyyy-MM-dd',mask: 'CU'}
        $hooks: {
            'after-create': ->
                $Evt.$send('work:create:success', "工作经历创建成功")
            'after-update': ->
                $Evt.$send('work:update:success', "工作经历更新成功")
            'after-destroy': ->
                $Evt.$send('work:update:success', "工作经历删除成功")

        }
        $config:
            jsonRootSingle: 'work_experience'
            jsonRootMany: 'work_experiences'
    }

FamilyMember = (restmod, RMUtils, $Evt) ->
    FamilyMember = restmod.model().mix 'nbRestApi', {
        birthday: {decode: 'date', param: 'yyyy-MM-dd',mask: 'CU'}
        $hooks:
            'after-create': ->
                $Evt.$send('FamilyMember:create:success', "家庭成员创建成功")
            'after-update': ->
                $Evt.$send('FamilyMember:update:success', "家庭成员更新成功")
            'after-destroy': ->
                $Evt.$send('FamilyMember:update:success', "家庭成员删除成功")

        $config:
            jsonRootSingle: 'family_member'
            jsonRootMany: 'family_members'
    }
Resume = (restmod, RMUtils, $Evt) ->
    Resume = restmod.model().mix 'nbRestApi', {
        $config:
            jsonRoot: 'employee'
    }

resources.factory 'User',['restmod', 'RMUtils', '$nbEvent', User]
resources.factory 'Education',['restmod', 'RMUtils', '$nbEvent', Education]
resources.factory 'Experience',['restmod', 'RMUtils', '$nbEvent', Experience]
resources.factory 'FamilyMember',['restmod', 'RMUtils', '$nbEvent', FamilyMember]
resources.factory 'Resume',['restmod', 'RMUtils', '$nbEvent', Resume]
