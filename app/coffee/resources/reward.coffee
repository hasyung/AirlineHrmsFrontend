resources = angular.module('resources')


Reward = (restmod, RMUtils, $Evt) ->
    restmod.model('/rewards').mix 'nbRestApi', 'DirtyModel', {
        createdAt: {decode: 'date', param: 'yyyy-MM-dd'}
        startDate: {decode: 'date', param: 'yyyy-MM-dd'}
        endDate: {decode: 'date', param: 'yyyy-MM-dd'}

        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $hooks:
            'after-create': ->
                #$Evt.$send('reward:create:success', "奖励记录创建成功")

            'after-update': ->
                #$Evt.$send('reward:update:success', "奖励记录更新成功")
    }


resources.factory 'Reward', ['restmod', 'RMUtils', '$nbEvent', Reward]