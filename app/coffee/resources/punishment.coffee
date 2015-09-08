resources = angular.module('resources')


Punishment = (restmod, RMUtils, $Evt) ->
    restmod.model('/punishments').mix 'nbRestApi', 'DirtyModel', {
        startDate: {decode: 'date', param: 'yyyy-MM-dd'}
        endDate: {decode: 'date', param: 'yyyy-MM-dd'}

        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $hooks:
            'after-create': ->
                $Evt.$send('punishment:create:success', "处分记录创建成功")

            'after-update': ->
                $Evt.$send('punishment:update:success', "处分记录更新成功")
    }


resources.factory 'Punishment', ['restmod', 'RMUtils', '$nbEvent', Punishment]