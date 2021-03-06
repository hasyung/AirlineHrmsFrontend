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


DinnerPersonSetup = (restmod, RMUtils, $Evt) ->
    restmod.model('/dinner_person_setups').mix 'nbRestApi', 'DirtyModel', {
        $config:
            jsonRootSingle: 'dinner_person_setup'
            jsonRootMany: 'dinner_person_setups'

        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $hooks: {
            'after-destroy': ->
                $Evt.$send('dinnerPersonSetups:destroy:success',"删除成功")
            'after-save': ->
                $Evt.$send('dinnerPersonSetups:save:success',"保存成功")
        }

        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
    }

DinnerRecord = (restmod, RMUtils, $Evt) ->
    restmod.model('/dinner_fees').mix 'nbRestApi', {
        $config:
            jsonRootSingle: 'dinner_fee'
            jsonRootMany: 'dinner_fees'

        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $extend:
            Scope:
                # 计算(根据年月)
                compute: (params)->
                    restmod.model('/dinner_fees/compute').mix(
                        $config:
                            jsonRoot: 'dinner_fees'
                    ).$search(params)

            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
    }

DinnerNightSnack = (restmod, RMUtils, $Evt) ->
    restmod.model('/night_fees').mix 'nbRestApi', 'DirtyModel', {
        $config:
            jsonRootSingle: 'night_fee'
            jsonRootMany: 'night_fees'

        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $extend:
            Scope:
                # 计算(根据年月)
                compute: (params)->
                    restmod.model('/night_fees/compute').mix(
                        $config:
                            jsonRoot: 'night_fees'
                    ).$search(params)

            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
    }

DinnerSettle = (restmod, RMUtils, $Evt) ->
    restmod.model('/dinner_settles').mix 'nbRestApi', {
        $config:
            jsonRootSingle: 'dinner_settle'
            jsonRootMany: 'dinner_settles'

        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $extend:
            Scope:
                # 计算(根据年月)
                compute: (params)->
                    restmod.model('/dinner_settles/compute').mix(
                        $config:
                            jsonRoot: 'dinner_settles'
                    ).$search(params)

            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
    }

DinnerChange = (restmod, RMUtils, $Evt) ->
    restmod.model('/dinner_changes').mix 'nbRestApi', {
        $config:
            jsonRootSingle: 'dinner_change'
            jsonRootMany: 'dinner_changes'

        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
    }

DinnerHistory = (restmod, RMUtils, $Evt) ->
    restmod.model('/dinner_settles/history_record').mix 'nbRestApi', {
        $config:
            jsonRootSingle: 'dinner_history'
            jsonRootMany: 'dinner_histories'

        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
    }

BirthAllowance = (restmod, RMUtils, $Evt) ->
    restmod.model('/birth_allowances').mix 'nbRestApi', 'DirtyModel', {
        $config:
            jsonRootSingle: 'birth_allowance'
            jsonRootMany: 'birth_allowances'

        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $hooks: {
            'after-destroy': ->
                $Evt.$send('dinnerPersonSetups:destroy:success',"删除成功")
            'after-save': ->
                $Evt.$send('dinnerPersonSetups:save:success',"保存成功")
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

AirlineRecord = (restmod, RMUtils, $Evt) ->
    restmod.model('/airline_fees').mix 'nbRestApi', 'DirtyModel', {
        $config:
            jsonRootSingle: 'airline_fee'
            jsonRootMany: 'airline_fees'

        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $hooks: {
            'after-save': ->
                $Evt.$send('airline_fee:save:success',"保存成功")
        }

        $extend:
            Scope:
                # 计算(根据年月)
                compute: (params)->
                    restmod.model('/airline_fees/compute_oversea_food_fee').mix(
                        $config:
                            jsonRoot: 'airline_fees'
                    ).$search(params)

            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
    }

#社保
resources.factory 'SocialPersonSetup', ['restmod', 'RMUtils', '$nbEvent', SocialPersonSetup]
resources.factory 'SocialRecord', ['restmod', 'RMUtils', '$nbEvent', SocialRecord]
resources.factory 'SocialChange', ['restmod', 'RMUtils', '$nbEvent', SocialChange]

#年金
resources.factory 'AnnuitySetup', ['restmod', 'RMUtils', '$nbEvent', AnnuitySetup]
resources.factory 'AnnuityRecord', ['restmod', 'RMUtils', '$nbEvent', AnnuityRecord]
resources.factory 'AnnuityChange', ['restmod', 'RMUtils', '$nbEvent', AnnuityChange]

#津贴
resources.factory 'DinnerPersonSetup', ['restmod', 'RMUtils', '$nbEvent', DinnerPersonSetup]
resources.factory 'DinnerRecord', ['restmod', 'RMUtils', '$nbEvent', DinnerRecord]
resources.factory 'DinnerNightSnack', ['restmod', 'RMUtils', '$nbEvent', DinnerNightSnack]
resources.factory 'DinnerSettle', ['restmod', 'RMUtils', '$nbEvent', DinnerSettle]
resources.factory 'DinnerChange', ['restmod', 'RMUtils', '$nbEvent', DinnerChange]
resources.factory 'DinnerHistory', ['restmod', 'RMUtils', '$nbEvent', DinnerHistory]
resources.factory 'AirlineRecord', ['restmod', 'RMUtils', '$nbEvent', AirlineRecord]
resources.factory 'BirthAllowance', ['restmod', 'RMUtils', '$nbEvent', BirthAllowance]
