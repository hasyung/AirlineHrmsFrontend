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


KeepSalary = (restmod, RMUtils, $Evt) ->
    restmod.model('/keep_salaries').mix 'nbRestApi', 'DirtyModel', {
        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $hooks:
            'after-create': ->
                $Evt.$send('basic_salary:create:success', "保留工资创建成功")

            'after-update': ->
                $Evt.$send('basic_salary:update:success', "保留工资更新成功")

        $config:
            jsonRootSingle: 'keep_salary'
            jsonRootMany: 'keep_salaries'

        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
            Scope:
                # 计算(根据年月)
                compute: (params)->
                    restmod.model('/keep_salaries/compute').mix(
                        $config:
                            jsonRoot: 'keep_salaries'
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


Reward = (restmod, RMUtils, $Evt) ->
    restmod.model('/rewards').mix 'nbRestApi', 'DirtyModel', {
        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $hooks:
            'after-create': ->
                $Evt.$send('reward:create:success', "奖励创建成功")

            'after-update': ->
                $Evt.$send('reward:update:success', "奖励更新成功")

        $config:
            jsonRootSingle: 'reward'
            jsonRootMany: 'rewards'

        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
            Scope:
                # 计算(根据年月)
                compute: (params)->
                    restmod.model('/rewards/compute').mix(
                        $config:
                            jsonRoot: 'rewards'
                    ).$search(params)
    }


TransportFee = (restmod, RMUtils, $Evt) ->
    restmod.model('/transport_fees').mix 'nbRestApi', 'DirtyModel', {
        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $hooks:
            'after-create': ->
                $Evt.$send('transport_fee:create:success', "交通费创建成功")

            'after-update': ->
                $Evt.$send('transport_fee:update:success', "交通费更新成功")

        $config:
            jsonRootSingle: 'transport_fee'
            jsonRootMany: 'transport_fees'

        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
            Scope:
                # 计算(根据年月)
                compute: (params)->
                    restmod.model('/transport_fees/compute').mix(
                        $config:
                            jsonRoot: 'transport_fees'
                    ).$search(params)
    }

BusFee = (restmod, RMUtils, $Evt) ->
    restmod.model('/bus_fees').mix 'nbRestApi', 'DirtyModel', {
        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $hooks:
            'after-create': ->
                $Evt.$send('bus_fees:create:success', "班车费创建成功")

            'after-update': ->
                $Evt.$send('bus_fee:update:success', "班车费更新成功")

        $config:
            jsonRootSingle: 'bus_fee'
            jsonRootMany: 'bus_fees'

        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
            Scope:
                # 计算(根据年月)
                compute: (params)->
                    restmod.model('/bus_fees/compute').mix(
                        $config:
                            jsonRoot: 'transport_fees'
                    ).$search(params)
    }

BirthSalary = (restmod, RMUtils, $Evt) ->
    restmod.model('/birth_salaries').mix 'nbRestApi', 'DirtyModel', {
        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $hooks:
            'after-create': ->
                $Evt.$send('birth_salary:create:success', "生育保险创建成功")

            'after-update': ->
                $Evt.$send('birth_salary:update:success', "生育保险更新成功")

        $config:
            jsonRootSingle: 'birth_salary'
            jsonRootMany: 'birth_salaries'

        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
            Scope:
                # 计算(根据年月)
                compute: (params)->
                    restmod.model('/birth_salaries/compute').mix(
                        $config:
                            jsonRoot: 'birth_salaries'
                    ).$search(params)
    }


SalaryChange = (restmod, RMUtils, $Evt) ->
    restmod.model('/salary_changes').mix 'nbRestApi', 'DirtyModel', {
        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $hooks:
            'after-create': ->
                $Evt.$send('salary_change:create:success', "薪酬变更创建成功")

            'after-update': ->
                $Evt.$send('salary_change:update:success', "薪酬变更更新成功")

        $config:
            jsonRootSingle: 'salary_change'
            jsonRootMany: 'salary_changes'
    }


SalaryGradeChange = (restmod, RMUtils, $Evt) ->
    restmod.model('/salary_grade_changes').mix 'nbRestApi', 'DirtyModel', {
        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $hooks:
            'after-create': ->
                $Evt.$send('salary_grade_change:create:success', "薪酬档级变更创建成功")

            'after-update': ->
                $Evt.$send('salary_grade_change:update:success', "薪酬档级变更更新成功")

        $config:
            jsonRootSingle: 'salary_grade_change'
            jsonRootMany: 'salary_grade_changes'

        # $extend:
        #     Record:
        #         audit: (params)->
        #             self = this

        #             request = {
        #                 url: "/api/salary_grade_changes/#{this.id}/audit"
        #                 method: "PUT"
        #                 params: params
        #             }

        #             this.$send(request, onSuccess)
    }


SalaryOverview = (restmod, RMUtils, $Evt) ->
    restmod.model('/salary_overviews').mix 'nbRestApi', 'DirtyModel', {
        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $hooks:
            'after-create': ->
                $Evt.$send('salary_overview:create:success', "薪酬合计创建成功")

            'after-update': ->
                $Evt.$send('salary_overview:update:success', "薪酬合计更新成功")

        $config:
            jsonRootSingle: 'salary_overview'
            jsonRootMany: 'salary_overviews'

        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
            Scope:
                # 计算(根据年月)
                compute: (params)->
                    restmod.model('/salary_overviews/compute').mix(
                        $config:
                            jsonRoot: 'salary_overviews'
                    ).$search(params)
    }


resources.factory 'BasicSalary', ['restmod', 'RMUtils', '$nbEvent', BasicSalary]
resources.factory 'KeepSalary', ['restmod', 'RMUtils', '$nbEvent', KeepSalary]
resources.factory 'PerformanceSalary', ['restmod', 'RMUtils', '$nbEvent', PerformanceSalary]
resources.factory 'HoursFee', ['restmod', 'RMUtils', '$nbEvent', HoursFee]
resources.factory 'Allowance', ['restmod', 'RMUtils', '$nbEvent', Allowance]
resources.factory 'LandAllowance', ['restmod', 'RMUtils', '$nbEvent', LandAllowance]
resources.factory 'Reward', ['restmod', 'RMUtils', '$nbEvent', Reward]
resources.factory 'TransportFee', ['restmod', 'RMUtils', '$nbEvent', TransportFee]
resources.factory 'BusFee', ['restmod', 'RMUtils', '$nbEvent', BusFee]
resources.factory 'BirthSalary', ['restmod', 'RMUtils', '$nbEvent', BirthSalary]
resources.factory 'SalaryChange', ['restmod', 'RMUtils', '$nbEvent', SalaryChange]
resources.factory 'SalaryGradeChange', ['restmod', 'RMUtils', '$nbEvent', SalaryGradeChange]
resources.factory 'SalaryOverview', ['restmod', 'RMUtils', '$nbEvent', SalaryOverview]
