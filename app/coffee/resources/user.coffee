#与用户相关联的资源
resources = angular.module('resources')


User = (restmod, RMUtils, $Evt) ->
    User = restmod.model(null).mix 'nbRestApi', 'DirtyModel', 'NestedDirtyModel', {
        #$hooks:
        #    'after-update': ->
        #        $Evt.$send('user:update:success', "个人信息更新成功")

        educationExperiences: {hasMany: 'Education'}
        workExperiences: {hasMany: 'Experience'}
        resume: {hasOne: 'Resume', mask: 'CU'}
        rewards: {hasMany: 'UserReward'}
        punishments: {hasMany: 'UserPunishment'}

        $config:
            jsonRoot: 'employee'

        familymembers: {hasMany: 'FamilyMember'}
    }
    .single('/me')


Education = (restmod, RMUtils, $Evt) ->
    Education = restmod.model().mix 'nbRestApi', 'DirtyModel', {
        admissionDate: {decode: 'date', param: 'yyyy-MM-dd'}
        graduationDate: {decode: 'date', param: 'yyyy-MM-dd'}

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
    Experience = restmod.model().mix 'nbRestApi', 'DirtyModel', {
        startDate: {decode: 'date', param: 'yyyy-MM-dd'}
        endDate: {decode: 'date', param: 'yyyy-MM-dd'}

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
    FamilyMember = restmod.model().mix 'nbRestApi', 'DirtyModel', {
        birthday: {decode: 'date', param: 'yyyy-MM-dd'}

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
    Resume = restmod.model().mix 'nbRestApi', 'DirtyModel', {
        $config:
            jsonRoot: 'employee'
    }


Contact = (restmod, RMUtils, $Evt) ->
    Contact = restmod.model().mix 'nbRestApi', 'DirtyModel', {
        $config:
            jsonRoot: 'employee'
    }


UserPerformance = (restmod, RMUtils, $Evt)->
    UserPerformance = restmod.model('/me/performances').mix 'nbRestApi', {
        $hooks:
            'allege-create': ->
                $Evt.$send('allege:create:success',"绩效申述成功")

        $extend:
            Record:
                allege: (data)->
                    self = @

                    request = {
                        method: 'POST',
                        url: "/api/performances/#{this.id}/alleges",
                        data: data
                    }

                    onSuccess = (res)->
                        self.$dispatch 'allege-create', res

                    this.$send(request, onSuccess)
    }


UserReward = (restmod, RMUtils, $Evt)->
    restmod.model('/me/rewards').mix 'nbRestApi', {

    }


UserPunishment = (restmod, RMUtils, $Evt)->
    restmod.model('/me/punishments').mix 'nbRestApi', {

    }


resources.factory 'User', ['restmod', 'RMUtils', '$nbEvent', User]
resources.factory 'Education', ['restmod', 'RMUtils', '$nbEvent', Education]
resources.factory 'Experience', ['restmod', 'RMUtils', '$nbEvent', Experience]
resources.factory 'FamilyMember', ['restmod', 'RMUtils', '$nbEvent', FamilyMember]
resources.factory 'Resume', ['restmod', 'RMUtils', '$nbEvent', Resume]
resources.factory 'Contact', ['restmod', 'RMUtils', '$nbEvent', Contact]
resources.factory 'UserPerformance', ['restmod', 'RMUtils', '$nbEvent', UserPerformance]
resources.factory 'UserReward', ['restmod', 'RMUtils', '$nbEvent', UserReward]
resources.factory 'UserPunishment', ['restmod', 'RMUtils', '$nbEvent', UserPunishment]