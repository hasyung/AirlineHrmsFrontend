resources = angular.module('resources')


Contract = (restmod, RMUtils, $Evt) ->
    Contract = restmod.model('/contracts').mix 'nbRestApi', 'DirtyModel', {
        startDate: {decode: 'date', param: 'yyyy-MM-dd'}
        endDate: {decode: 'date', param: 'yyyy-MM-dd'}
        owner: {belongsTo: 'Employee', key: 'employee_id'}
        $hooks:
            'after-create': ->
                $Evt.$send('contract:create:success', "合同创建成功")

            'after-update': ->
                $Evt.$send('contract:update:success', "合同更新成功")

    }

resources.factory 'Contract',['restmod', 'RMUtils', '$nbEvent', Contract]
