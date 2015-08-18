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
                          "service_c_1_3_perf",                 # 绩效-服务C1-3
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
        @flags = []

    $do_calc: (main_category, current)->
        if main_category == 'service_b'
            current.baseWage = @setting.flags[current.baseFlag]['amount']
            current.performanceWage = current.baseWage - @SALARY_SETTING['global_setting']['basic_cardinality']

    lookup: (main_category, current)->
        @setting = @SALARY_SETTING[current.baseChannel + '_setting']
        @flags = Object.keys(@setting.flags)
        @$do_calc(main_category, current)

    show_amount: (main_category, current)->
        @$do_calc(main_category, current)


class SalaryBasicController
    @.$inject = ['$http', '$scope', '$nbEvent']

    constructor: ($http, $scope, $Evt) ->


class SalaryPerformanceController
    @.$inject = ['$http', '$scope', '$nbEvent']

    constructor: ($http, $scope, $Evt) ->


class SalaryHoursFeeController
    @.$inject = ['$http', '$scope', '$nbEvent']

    constructor: ($http, $scope, $Evt) ->


class SalaryAllowanceController
    @.$inject = ['$http', '$scope', '$nbEvent']

    constructor: ($http, $scope, $Evt) ->


app.controller 'salaryCtrl', SalaryController
app.controller 'salaryPersonalCtrl', SalaryPersonalController
app.controller 'salaryExchangeCtrl', SalaryExchangeController
app.controller 'salaryBasicCtrl', SalaryBasicController
app.controller 'salaryPerformanceCtrl', SalaryPerformanceController
app.controller 'salaryHoursFeeCtrl', SalaryHoursFeeController
app.controller 'salaryAllowanceCtrl', SalaryAllowanceController