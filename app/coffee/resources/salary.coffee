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


Allowance = (restmod, RMUtils, $Evt) ->
    restmod.model('/allowances').mix 'nbRestApi', 'DirtyModel', {
        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $hooks:
            'after-create': ->
                $Evt.$send('allowance:create:success', "津贴创建成功")

            'after-update': ->
                $Evt.$send('allowance:update:success', "津贴更新成功")

        $config:
            jsonRootSingle: 'allowance'
            jsonRootMany: 'allowances'

        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
            Scope:
                # 计算(根据年月)
                compute: (params)->
                    restmod.model('/allowances/compute').mix(
                        $config:
                            jsonRoot: 'allowances'
                    ).$search(params)
    }


LandAllowance = (restmod, RMUtils, $Evt) ->
    restmod.model('/land_allowances').mix 'nbRestApi', 'DirtyModel', {
        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $hooks:
            'after-create': ->
                $Evt.$send('land_allowance:create:success', "驻站津贴创建成功")

            'after-update': ->
                $Evt.$send('land_allowance:update:success', "驻站津贴更新成功")

        $config:
            jsonRootSingle: 'land_allowance'
            jsonRootMany: 'land_allowances'

        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
            Scope:
                # 计算(根据年月)
                compute: (params)->
                    restmod.model('/land_allowances/compute').mix(
                        $config:
                            jsonRoot: 'land_allowances'
                    ).$search(params)
    }


SalaryOverview = (restmod, RMUtils, $Evt) ->
    restmod.model('/salary_overviews').mix 'nbRestApi', 'DirtyModel', {
        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $hooks:
            'after-create': ->
                $Evt.$send('salary_counter:create:success', "驻站津贴创建成功")

            'after-update': ->
                $Evt.$send('salary_counter:update:success', "驻站津贴更新成功")

        $config:
            jsonRootSingle: 'salary_overview'
            jsonRootMany: 'salary_overviews'
    }


resources.factory 'BasicSalary', ['restmod', 'RMUtils', '$nbEvent', BasicSalary]
resources.factory 'PerformanceSalary', ['restmod', 'RMUtils', '$nbEvent', PerformanceSalary]
resources.factory 'HoursFee', ['restmod', 'RMUtils', '$nbEvent', HoursFee]
resources.factory 'Allowance', ['restmod', 'RMUtils', '$nbEvent', Allowance]
resources.factory 'LandAllowance', ['restmod', 'RMUtils', '$nbEvent', LandAllowance]
resources.factory 'SalaryOverview', ['restmod', 'RMUtils', '$nbEvent', SalaryOverview]