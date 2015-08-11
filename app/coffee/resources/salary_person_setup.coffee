resources = angular.module('resources')

SalaryPersonSetup = (restmod, RMUtils, $Evt) ->
    restmod.model('/salary_person_setups').mix 'nbRestApi', 'DirtyModel', {
        $hooks:
            'after-create': ->
                $Evt.$send('salary_person_setups:create:success', "个人设置创建成功")

            'after-update': ->
                $Evt.$send('salary_person_setups:update:success', "个人设置更新成功")

        $config:
            jsonRootSingle: 'salary_person_setup'
            jsonRootMany: 'salary_person_setups'

        owner: {belongsTo: 'Employee', key: 'employee_id'}
    }


resources.factory 'SalaryPersonSetup', ['restmod', 'RMUtils', '$nbEvent', SalaryPersonSetup]
