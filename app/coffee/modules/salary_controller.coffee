# 薪资
nb = @.nb
app = nb.app

class Route
    @.$inject = ['$stateProvider']

    constructor: (stateProvider) ->
        stateProvider
            .state 'salary', {
                url: '/salary'
                templateUrl: 'partials/salary/settings.html'
            }

            .state 'salary_personal', {
                url: '/salary/personal'
                templateUrl: 'partials/salary/personal.html'
            }

            .state 'salary_calc', {
                url: '/salary/calc'
                templateUrl: 'partials/salary/calc.html'
            }


app.config(Route)


class SalaryController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', 'toaster', 'SALARY_SETTING']

    constructor: (@http, @scope, $Evt, @toaster, @SALARY_SETTING) ->
        self = @
        @initialize()

    $defaultCoefficient: ()->
        company: 0.1
        business_council: 0.1
        logistics: 0.1

    $checkCoefficientDefault: ()->
        month = @currentCalcTime()
        if !angular.isDefined(@global_setting.coefficient[month])
            @global_setting.coefficient[month] = @$defaultCoefficient()

    initialize: () ->
        self = @
        @CATEGORY_LIST = ["leader_base",                # 基础-干部
                          "manager15_base",             # 基础-管理15
                          "manager12_base",             # 基础-管理12
                          "flyer_legend_base",          # 基础-荣誉级飞行员
                          "flyer_leader_base",          # 基础-机长
                          "flyer_copilot_base",         # 基础-副驾
                          "flyer_teacher_A_base",       # 基础-教员A
                          "flyer_teacher_B_base",       # 基础-教员B
                          "flyer_teacher_C_base",       # 基础-教员C
                          "flyer_student_base",         # 基础-学员
                          "air_steward_base",           # 基础-空乘空保
                          "service_b_normal_cleaner_base",      # 基础-服务B-清洁工
                          "service_b_parking_cleaner_base",     # 基础-服务B-机坪清洁工
                          "service_b_hotel_service_base",       # 基础-服务B-宾馆服务员
                          "service_b_green_base",               # 基础-服务B-绿化
                          "service_b_front_desk_base",          # 基础-服务B-总台服务员
                          "service_b_security_guard_base",      # 基础-服务B-保安、空保装备保管员
                          "service_b_input_base",               # 基础-服务B-数据录入
                          "service_b_guard_leader1_base",       # 基础-服务B-保安队长（一类）
                          "service_b_device_keeper_base",       # 基础-服务B-保管（库房、培训设备、器械）
                          "service_b_unloading_base",           # 基础-服务B-外站装卸
                          "service_b_making_water_base",        # 基础-服务B-制水工
                          "service_b_add_water_base",           # 基础-服务B-加水工、排污工
                          "service_b_guard_leader2_base",       # 基础-服务B-保安队长（二类）
                          "service_b_water_light_base",         # 基础-服务B-水电维修
                          "service_b_car_repair_base",          # 基础-服务B-汽修工
                          "service_b_airline_keeper_base",      # 基础-服务B-机务工装设备/客舱供应库管
                          "service_c_base",                     # 基础-服务C
                          "air_observer_base",                  # 基础-空中观察员
                          "front_run_base",                     # 基础-前场运行
                          "information_perf",                   # 绩效-信息通道
                          "airline_business_perf",              # 绩效-航务航材
                          "manage_market_perf",                 # 绩效-管理营销
                          "service_c_1_perf",                   # 绩效-服务C-1
                          "service_c_2_perf",                   # 绩效-服务C-2
                          "service_c_3_perf",                   # 绩效-服务C-3
                          "service_c_driving_perf",             # 绩效-服务C-驾驶
                          "flyer_hour",                         # 小时费-飞行员
                          "fly_attendant_hour",                 # 小时费-空乘
                          "air_security_hour",                  # 小时费-空保
                          "unfly_allowance_hour",               # 小时费-未飞补贴
                          "allowance",                          # 津贴设置
                          "land_subsidy",                       # 地面驻站补贴
                          "airline_subsidy"                     # 空勤驻站补贴
                         ]

        @year_list = @$getYears()
        @month_list = @$getMonths()
        @currentYear = _.last @year_list
        @currentMonth = _.last @month_list

        @settings = {}
        @global_setting = {}

    loadConfigFromServer: (category)->
        self = @
        @http.get('/api/salaries').success (data)->
            # 全局设置单独处理
            self.global_setting = data.global.form_data
            self.$checkCoefficientDefault()
            self.basic_cardinality = parseInt(self.global_setting.basic_cardinality)
            self.settings['global_setting'] = self.global_setting

            angular.forEach self.CATEGORY_LIST, (item)->
                data[item] ||= {}
                self.settings[item + '_setting'] = data[item].form_data || {}

            self.loadDynamicConfig(category)

            # 更新薪酬设置
            self.SALARY_SETTING = angular.copy(self.settings)

    currentCalcTime: ()->
        @currentYear + "-" + @currentMonth

    loadGlobalCoefficient: ()->
        @$checkCoefficientDefault()

    loadDynamicConfig: (category)->
        @current_category = category
        @dynamic_config = @settings[category + '_setting']
        @backup_config = angular.copy(@dynamic_config)
        @editing = false

    resetDynamicConfig: ()->
        @dynamic_config = {}
        @dynamic_config = angular.copy(@backup_config)
        @editing = false

    saveConfig: (category, config)->
        self = @
        config = @settings[@current_category + '_setting'] if !config

        @http.put('/api/salaries/' + (category || @current_category), {form_data: config}).success (data)->
            error_msg = data.messages

            if error_msg
                self.toaster.pop('error', '提示', error_msg)
            else
                self.editing = false
                self.backup_config = angular.copy(self.dynamic_config)
                self.toaster.pop('success', '提示', '配置已更新')

    calcAmount: (rate)->
        parseInt(@basic_cardinality * parseFloat(rate))

    calcRate: (amount)->
        if !@basic_cardinality || @basic_cardinality == 0
            throw new Error('全局设置薪酬基数无效')
        Math.round(amount / @basic_cardinality)

    existCurrentRate: ()->
        @dynamic_config.flag_list.indexOf('rate') >= 0

    formatColumn: (input)->
        result = input

        if input && angular.isDefined(input['format_cell'])
            result = input['format_cell']
            result = result.replace('%{format_value}', input['format_value'])
            result = result.replace('%{work_value}', input['work_value'])
            result = result.replace('%{time_value}', input['time_value'])

        result

    exchangeExpr: (expr, reverse = false)->
        return if !expr && !angular.isDefined(expr)

        hash = {
            '调档时间':     '%{format_value}'
            '驾驶经历时间':  '%{work_value}'
            '飞行时间':     '%{time_value}'
            '员工职级':     '%{job_title_degree}'
            '员工学历':     '%{education_background}'
            '去年年度绩效':  '%{last_year_perf}'
        }

        result = expr

        angular.forEach hash, (value, key)->
            if reverse
                result = result.replace(value, key)
            else
                result = result.replace(key, value)

        result


class SalaryPersonalController
    @.$inject = ['$http', '$scope', '$nbEvent', '$enum', 'SalaryPersonSetup']

    constructor: ($http, $scope, $Evt, $enum, @SalaryPersonSetup) ->
        @loadInitialData()

        @filterOptions = {
            name: 'salaryPersonal'
            constraintDefs: [
                {
                    name: 'employee_name'
                    displayName: '员工姓名'
                    type: 'string'
                }
                {
                    name: 'channel_ids'
                    displayName: '通道'
                    type: 'muti-enum-search'
                    params: {
                        type: 'channels'
                    }
                }
            ]
        }

        @columnDef = [
            {displayName: '员工编号', name: 'employeeNo'}
            {
                displayName: '姓名'
                field: 'employeeName'
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a nb-panel
                        template-url="partials/personnel/info_basic.html"
                        locals="{employee: row.entity.owner}">
                        {{grid.getCellValue(row, col)}}
                    </a>
                </div>
                '''
            }
            {
                displayName: '所属部门'
                name: 'departmentName'
                cellTooltip: (row) ->
                    return row.entity.departmentName
            }
            {
                displayName: '岗位'
                name: 'positionName'
                cellTooltip: (row) ->
                    return row.entity.positionName
            }
            {displayName: '分类', name: 'categoryId', cellFilter: "enum:'categories'"}
            {displayName: '通道', name: 'channelId', cellFilter: "enum:'channels'"}
            {displayName: '用工性质', name: 'laborRelationId', cellFilter: "enum:'labor_relations'"}
            {
                displayName: '属地化'
                name: 'location'
            }
            {
                displayName: '设置'
                field: 'setting'
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a
                        href="javascript:void(0);"
                        nb-dialog
                        template-url="partials/salary/settings/personal_edit.html"
                        locals="{setup: row.entity}">
                        设置
                    </a>
                </div>
                '''
            }
        ]

        @constraints = [

        ]

    loadInitialData: ->
        @salaryPersonSetups = @SalaryPersonSetup.$collection().$fetch()

    search: (tableState) ->
        @salaryPersonSetups.$refresh(tableState)

    getSelectsIds: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk

    getSelected: () ->
        rows = @gridApi.selection.getSelectedGridRows()

    delete: (isConfirm) ->
        if isConfirm
            @getSelected().forEach (record) -> record.entity.$destroy()

    loadEmployee: (params, salary)->
        self = @

        @Employee.$collection().$refresh(params).$then (employees)->
            args = _.mapKeys params, (value, key) ->
                _.camelCase key

            matched = _.find employees, args

            if matched
                self.loadEmp = matched
                salary.owner = matched
            else
                self.loadEmp = params


class SalaryExchangeController
    @.$inject = ['$http', '$scope', '$nbEvent', 'SALARY_SETTING']

    constructor: ($http, $scope, $Evt, @SALARY_SETTING) ->
        #

    $channelSettingStr: (channel)->
        channel + '_setting'

    $settingHash: (channel)->
        @SALARY_SETTING[@$channelSettingStr(channel)]

    service_b: (current)->
        return unless current.baseChannel

        setting = @$settingHash(current.baseChannel)
        current.baseMoney = setting.flags[current.baseFlag]['amount']
        # 除开基本工资，剩下的就是绩效工资(service_b)
        current.performanceMoney = current.baseMoney - @SALARY_SETTING['global_setting']['minimum_wage']

    service_b_flag_array: (current)->
        return unless current.baseChannel

        setting = @$settingHash(current.baseChannel)
        Object.keys(setting.flags)

    normal: (current)->
        return unless current.baseWage
        return unless current.baseFlag

        setting = @$settingHash(current.baseWage)
        flag = setting.flags[current.baseFlag]

        return current.baseMoney = flag.amount if angular.isDefined(flag)
        return 0

    normal_channel_array: (current)->
        return unless current.baseWage

        setting = @$settingHash(current.baseWage)
        channels = []
        angular.forEach setting.flag_list, (item)->
            if item != 'rate' && !item.startsWith('amount')
                channels.push(setting.flag_names[item])
        _.uniq(channels)

    normal_flag_array: (current)->
        return unless current.baseWage

        setting = @$settingHash(current.baseWage)
        Object.keys(setting.flags)

    perf: (current)->
        return unless current.performanceWage
        setting = @$settingHash(current.performanceWage)

        flag = setting.flags[current.performanceFlag]
        return current.performanceMoney = flag.amount if angular.isDefined(flag)
        return 0

    perf_flag_array: (current)->
        return unless current.performanceWage
        setting = @$settingHash(current.performanceWage)
        Object.keys(setting.flags)

    fly: (current)->
        return unless current.baseChannel
        return unless current.baseFlag

        setting = @$settingHash(current.baseChannel)
        current.baseMoney = setting.flags[current.baseFlag]['amount']

    fly_flag_array: (current)->
        return unless current.baseChannel

        setting = @$settingHash(current.baseChannel)
        Object.keys(setting.flags)

    fly_hour: (current)->
        return unless current.flyHourFee

        setting = @$settingHash('flyer_hour')
        current.flyHourMoney = setting[current.flyHourFee]

    airline: (current)->
        return unless current.baseChannel
        return unless current.baseFlag

        setting = @$settingHash(current.baseChannel)
        current.baseMoney = setting.flags[current.baseFlag]['amount']

    airline_flag_array: (current)->
        return unless current.baseChannel

        setting = @$settingHash(current.baseChannel)
        Object.keys(setting.flags)

    airline_hour: (current)->
        return unless current.airlineHourFee

        setting = @$settingHash('fly_attendant_hour')
        current.airlineHourMoney = setting[current.airlineHourFee]

    security_hour: (current)->
        return unless current.securityHourFee

        setting = @$settingHash('air_security_hour')
        current.securityHourMoney = setting[current.securityHourFee]


# 基础工资
class SalaryBasicController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', 'Employee', 'BasicSalary', 'toaster']

    constructor: ($http, $scope, @Evt, @Employee, @BasicSalary, @toaster) ->
        @basicSalaries = @loadInitialData()

        @filterOptions = {
            name: 'basicSalary'
            constraintDefs: [
                {
                    name: 'employee_name'
                    displayName: '员工姓名'
                    type: 'string'
                }
                {
                    name: 'employee_no'
                    displayName: '员工编号'
                    type: 'string'
                }
            ]
        }

        @columnDef = [
            {displayName: '员工编号', name: 'employeeNo'}
            {
                displayName: '姓名'
                field: 'employeeName'
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a nb-panel
                        template-url="partials/personnel/info_basic.html"
                        locals="{employee: row.entity.owner}">
                        {{grid.getCellValue(row, col)}}
                    </a>
                </div>
                '''
            }
            {
                displayName: '所属部门'
                name: 'departmentName'
                cellTooltip: (row) ->
                    return row.entity.departmentName
            }
            {
                displayName: '岗位'
                name: 'positionName'
                cellTooltip: (row) ->
                    return row.entity.positionName
            }
            {displayName: '通道', name: 'channelId', cellFilter: "enum:'channels'"}
            {displayName: '当月基础薪酬', name: 'salary'}
            {displayName: '补扣发', name: 'addGarnishee'}
            {displayName: '备注', name: 'note'}
        ]

    loadInitialData: ->
        @year_list = @$getYears()
        @month_list = @$getMonths()

        @currentYear = _.last(@year_list)
        @currentMonth = _.last(@month_list)

        @basicSalaries = @BasicSalary.$collection().$fetch({month: @currentCalcTime()})

    search: (tableState) ->
        tableState = {} unless tableState
        tableState['month'] = @currentCalcTime()
        @basicSalaries.$refresh(tableState)

    getSelectsIds: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk

    getSelected: () ->
        rows = @gridApi.selection.getSelectedGridRows()

    currentCalcTime: ()->
        @currentYear + "-" + @currentMonth

    loadRecords: () ->
        @basicSalaries.$refresh({month: @currentCalcTime()})

    # 强制计算
    exeCalc: () ->
        @calcing = true
        @toaster.pop('info', '提示', '开始计算')

        self = @

        @BasicSalary.compute({month: @currentCalcTime()}).$asPromise().then (data)->
            self.calcing = false
            erorr_msg = data.$response.data.messages
            self.Evt.$send("basic_salary:calc:error", erorr_msg) if erorr_msg
            self.loadRecords()


# 绩效工资
class SalaryPerformanceController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', 'Employee', 'PerformanceSalary', 'toaster']

    constructor: ($http, $scope, @Evt, @Employee, @PerformanceSalary, @toaster) ->
        @performanceSalaries = @loadInitialData()

        @filterOptions = {
            name: 'performanceSalary'
            constraintDefs: [
                {
                    name: 'employee_name'
                    displayName: '员工姓名'
                    type: 'string'
                }
                {
                    name: 'employee_no'
                    displayName: '员工编号'
                    type: 'string'
                }
            ]
        }

        @columnDef = [
            {displayName: '员工编号', name: 'employeeNo'}
            {
                displayName: '姓名'
                field: 'employeeName'
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a nb-panel
                        template-url="partials/personnel/info_basic.html"
                        locals="{employee: row.entity.owner}">
                        {{grid.getCellValue(row, col)}}
                    </a>
                </div>
                '''
            }
            {
                displayName: '所属部门'
                name: 'departmentName'
                cellTooltip: (row) ->
                    return row.entity.departmentName
            }
            {
                displayName: '岗位'
                name: 'positionName'
                cellTooltip: (row) ->
                    return row.entity.positionName
            }
            {displayName: '通道', name: 'channelId', cellFilter: "enum:'channels'"}
            {displayName: '当月绩效基数', name: 'baseSalary'}
            {displayName: '当月绩效薪酬', name: 'amount'}
            {displayName: '补扣发', name: 'addGarnishee'}
            {displayName: '备注', name: 'note'}
        ]

    loadInitialData: ->
        @year_list = @$getYears()
        @month_list = @$getMonths()

        @currentYear = _.last(@year_list)
        @currentMonth = _.last(@month_list)

        @performanceSalaries = @PerformanceSalary.$collection().$fetch({month: @currentCalcTime()})

    search: (tableState) ->
        tableState = {} unless tableState
        tableState['month'] = @currentCalcTime()
        @performanceSalaries.$refresh(tableState)

    getSelectsIds: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk

    getSelected: () ->
        rows = @gridApi.selection.getSelectedGridRows()

    currentCalcTime: ()->
        @currentYear + "-" + @currentMonth

    loadRecords: () ->
        @performanceSalaries.$refresh({month: @currentCalcTime()})

    # 强制计算(计算基数、计算绩效薪酬)
    exeCalc: (type) ->
        @calcing = true
        self = @

        @PerformanceSalary.compute({month: @currentCalcTime(), type: type}).$asPromise().then (data)->
            self.calcing = false
            erorr_msg = data.$response.data.messages
            self.Evt.$send("performance_salary:calc:error", erorr_msg) if erorr_msg
            self.loadRecords()


# 小时费
class SalaryHoursFeeController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', 'Employee', 'HoursFee', 'toaster']

    constructor: ($http, $scope, @Evt, @Employee, @HoursFee, @toaster) ->
        #


class SalaryAllowanceController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', 'Employee', 'Allowance', 'toaster']

    constructor: ($http, $scope, @Evt, @Employee, @Allowance, @toaster) ->
        @allowances = @loadInitialData()

        @filterOptions = {
            name: 'allowance'
            constraintDefs: [
                {
                    name: 'employee_name'
                    displayName: '员工姓名'
                    type: 'string'
                }
                {
                    name: 'employee_no'
                    displayName: '员工编号'
                    type: 'string'
                }
            ]
        }

        @columnDef = [
            {displayName: '员工编号', name: 'employeeNo'}
            {
                displayName: '姓名'
                field: 'employeeName'
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a nb-panel
                        template-url="partials/personnel/info_basic.html"
                        locals="{employee: row.entity.owner}">
                        {{grid.getCellValue(row, col)}}
                    </a>
                </div>
                '''
            }
            {
                displayName: '所属部门'
                name: 'departmentName'
                cellTooltip: (row) ->
                    return row.entity.departmentName
            }
            {
                displayName: '岗位'
                name: 'positionName'
                cellTooltip: (row) ->
                    return row.entity.positionName
            }
            {displayName: '通道', name: 'channelId', cellFilter: "enum:'channels'"}
            {displayName: '津贴', name: 'salary'}
            {displayName: '补扣发', name: 'addGarnishee'}
            {displayName: '备注', name: 'note'}
        ]

    loadInitialData: ->
        @year_list = @$getYears()
        @month_list = @$getMonths()

        @currentYear = _.last(@year_list)
        @currentMonth = _.last(@month_list)

        @allowances = @Allowance.$collection().$fetch({month: @currentCalcTime()})

    search: (tableState) ->
        tableState = {} unless tableState
        tableState['month'] = @currentCalcTime()
        @allowances.$refresh(tableState)

    getSelectsIds: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk

    getSelected: () ->
        rows = @gridApi.selection.getSelectedGridRows()

    currentCalcTime: ()->
        @currentYear + "-" + @currentMonth

    loadRecords: () ->
        @allowances.$refresh({month: @currentCalcTime()})

    # 强制计算
    exeCalc: () ->
        @calcing = true
        @toaster.pop('info', '提示', '开始计算')

        self = @

        @Allowances.compute({month: @currentCalcTime()}).$asPromise().then (data)->
            self.calcing = false
            erorr_msg = data.$response.data.messages
            self.Evt.$send("basic_salary:calc:error", erorr_msg) if erorr_msg
            self.loadRecords()


class SalaryLandAllowanceController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', 'Employee', 'LandAllowance', 'toaster']

    constructor: ($http, $scope, @Evt, @Employee, @LandAllowance, @toaster) ->
        #


class SalaryOverviewController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', 'Employee', 'SalaryOverview', 'toaster']

    constructor: ($http, $scope, @Evt, @Employee, @SalaryOverview, @toaster) ->
        #


app.controller 'salaryCtrl', SalaryController
app.controller 'salaryPersonalCtrl', SalaryPersonalController
app.controller 'salaryExchangeCtrl', SalaryExchangeController
app.controller 'salaryBasicCtrl', SalaryBasicController
app.controller 'salaryPerformanceCtrl', SalaryPerformanceController
app.controller 'salaryHoursFeeCtrl', SalaryHoursFeeController
app.controller 'salaryAllowanceCtrl', SalaryAllowanceController
app.controller 'salaryLandAllowanceCtrl', SalaryLandAllowanceController
app.controller 'salaryOverviewCtrl', SalaryOverviewController