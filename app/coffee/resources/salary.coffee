resources = angular.module('resources')


BasicSalary = (restmod, RMUtils, $Evt) ->
    restmod.model('/basic_salaries').mix 'nbRestApi', 'DirtyModel', {
        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $hooks:
            'after-create': ->
                $Evt.$send('basic_salary:create:success', "基础工资创建成功")

            'after-update': ->
                $Evt.$send('basic_salary:update:success', "基础工资更新成功")

        $config:
            jsonRootSingle: 'basic_salary'
            jsonRootMany: 'basic_salaries'

        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
            Scope:
                # 计算(根据年月)
                compute: (params)->
                    restmod.model('/basic_salaries/compute').mix(
                        $config:
                            jsonRoot: 'basic_salaries'
                    ).$search(params)
    }


PerformanceSalary = (restmod, RMUtils, $Evt) ->
    restmod.model('/performance_salaries').mix 'nbRestApi', 'DirtyModel', {
        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $hooks:
            'after-create': ->
                $Evt.$send('performance_salary:create:success', "绩效工资创建成功")

            'after-update': ->
                $Evt.$send('performance_salary:update:success', "绩效工资更新成功")

        $config:
            jsonRootSingle: 'performance_salary'
            jsonRootMany: 'performance_salaries'

        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
            Scope:
                # 计算(根据年月)
                compute: (params)->
                    restmod.model('/performance_salaries/compute').mix(
                        $config:
                            jsonRoot: 'performance_salaries'
                    ).$search(params)
    }


HoursFee = (restmod, RMUtils, $Evt) ->
    restmod.model('/hours_fees').mix 'nbRestApi', 'DirtyModel', {
        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $hooks:
            'after-create': ->
                $Evt.$send('hours_fee:create:success', "小时费创建成功")

            'after-update': ->
                $Evt.$send('hours_fee:update:success', "小时费更新成功")

        $config:
            jsonRootSingle: 'hours_fee'
            jsonRootMany: 'hours_fees'

        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
            Scope:
                # 计算(根据年月)
                compute: (params)->
                    restmod.model('/hours_fees/compute').mix(
                        $config:
                            jsonRoot: 'hours_fees'
                    ).$search(params)
    }


resources.factory 'BasicSalary', ['restmod', 'RMUtils', '$nbEvent', BasicSalary]
resources.factory 'PerformanceSalary', ['restmod', 'RMUtils', '$nbEvent', PerformanceSalary]
resources.factory 'HoursFee', ['restmod', 'RMUtils', '$nbEvent', HoursFee]