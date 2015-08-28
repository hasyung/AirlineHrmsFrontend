resources = angular.module('resources')


SocialPersonSetup = (restmod, RMUtils, $Evt) ->
    restmod.model('/social_person_setups').mix 'nbRestApi', 'DirtyModel', {
        $config:
            jsonRootSingle: 'social_person_setup'
            jsonRootMany: 'social_person_setups'

        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $hooks: {
            'after-destroy': ->
                $Evt.$send('socialPersonSetups:destroy:success',"删除成功")
            'after-save': ->
                $Evt.$send('socialPersonSetups:save:success',"保存成功")
        }

        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
    }


# 社保记录
SocialRecord = (restmod, RMUtils, $Evt) ->
    restmod.model('/social_records').mix 'nbRestApi', {
        $config:
            jsonRootSingle: 'social_record'
            jsonRootMany: 'social_records'

        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $extend:
            Scope:
                # 计算(根据年月)
                compute: (params)->
                    restmod.model('/social_records/compute').mix(
                        $config:
                            jsonRoot: 'social_records'
                    ).$search(params)

            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
    }


SocialChange = (restmod, RMUtils, $Evt) ->
    restmod.model('/social_change_infos').mix 'nbRestApi', {
        $config:
            jsonRootSingle: 'social_change_info'
            jsonRootMany: 'social_change_infos'

        owner: {belongsTo: 'Employee', key: 'employee_id'}

        socialSetup: {belongsTo: 'SocialPersonSetup', key: 'social_person_setup_id'}

        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)

            Record:
                is_processed: ()->
                    this.state != "未处理"
    }


#年金个人设置
AnnuitySetup = (restmod, RMUtils, $Evt) ->
    restmod.model('/annuities').mix 'nbRestApi', {
        $config:
            jsonRootSingle: 'annuity'
            jsonRootMany: 'annuities'

        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
    }


# 记录
AnnuityRecord = (restmod, RMUtils, $Evt) ->
    restmod.model('/annuities/list_annuity').mix 'nbRestApi',{
        $config:
            jsonRootSingle: 'annuity'
            jsonRootMany: 'annuities'

        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $extend:
            Scope:
                # 计算(根据年月)
                compute: (params)->
                    restmod.model('/annuities/cal_annuity').mix(
                        $config:
                            jsonRoot: 'annuities'
                    ).$search(params)

            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
    }


AnnuityChange = (restmod, RMUtils, $Evt) ->
    restmod.model('/annuity_apply').mix 'nbRestApi', {
        $config:
            jsonRootSingle: 'annuity_apply'
            jsonRootMany: 'annuity_applies'

        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)

            Record:
                is_processed: ()->
                    this.state != "未处理"
    }

#社保
resources.factory 'SocialPersonSetup', ['restmod', 'RMUtils', '$nbEvent', SocialPersonSetup]
resources.factory 'SocialRecord', ['restmod', 'RMUtils', '$nbEvent', SocialRecord]
resources.factory 'SocialChange', ['restmod', 'RMUtils', '$nbEvent', SocialChange]

#年金
resources.factory 'AnnuitySetup', ['restmod', 'RMUtils', '$nbEvent', AnnuitySetup]
resources.factory 'AnnuityRecord', ['restmod', 'RMUtils', '$nbEvent', AnnuityRecord]
resources.factory 'AnnuityChange', ['restmod', 'RMUtils', '$nbEvent', AnnuityChange]
