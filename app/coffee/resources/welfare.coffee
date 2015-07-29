resources = angular.module('resources')


SocialPersonSetup = (restmod, RMUtils, $Evt) ->
    socialPersonSetups = restmod.model('/social_person_setups').mix 'nbRestApi', {
        $config:
            jsonRootSingle: 'social_person_setup'
            jsonRootMany: 'social_person_setups'

        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $hooks: {
            'after-destroy': ->
                $Evt.$send('socialPersonSetups:destroy:success',"删除成功")
        }

        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
    }


# 社保记录
SocialRecord = (restmod, RMUtils, $Evt) ->
    socialRecords = restmod.model('/social_records').mix 'nbRestApi', {
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
                    ).$search(params);

            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
    }


SocialChange = (restmod, RMUtils, $Evt) ->
    socialChanges = restmod.model('/social_change_infos').mix 'nbRestApi', {
        $config:
            jsonRootSingle: 'social_change_info'
            jsonRootMany: 'social_change_infos'

        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
    }

#年金
Annuitity = (restmod, RMUtils, $Evt) ->
    annuities = restmod.model('/annuities').mix 'nbRestApi', {
        $config:
            jsonRootSingle: 'annuitie'
            jsonRootMany: 'annuities'

        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
    }


#社保
resources.factory 'SocialPersonSetup', ['restmod', 'RMUtils', '$nbEvent', SocialPersonSetup]
resources.factory 'SocialRecord', ['restmod', 'RMUtils', '$nbEvent', SocialRecord]
resources.factory 'SocialChange', ['restmod', 'RMUtils', '$nbEvent', SocialChange]

#年金
resources.factory 'Annuitity', ['restmod', 'RMUtils', '$nbEvent', Annuitity]