# 薪资
nb = @.nb
app = nb.app

SALARY_FILTER_DEFAULT = {
    name: 'salary'
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

SALARY_COLUMNDEF_DEFAULT = [
    {displayName: '员工编号', name: 'employeeNo', enableCellEdit: false}
        {
            displayName: '姓名'
            field: 'employeeName'
            enableCellEdit: false
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
            enableCellEdit: false
            cellTooltip: (row) ->
                return row.entity.departmentName
        }
        {
            displayName: '岗位'
            name: 'positionName'
            enableCellEdit: false
            cellTooltip: (row) ->
                return row.entity.positionName
        }
        {displayName: '通道', name: 'channelId', enableCellEdit: false, cellFilter: "enum:'channels'"}
    ]

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

    $checkRewardDefault: ()->
        year = @currentYear

        if !angular.isDefined(@global_setting.flight_bonus[year])
            @global_setting.flight_bonus[year] = 100000000

        if !angular.isDefined(@global_setting.service_bonus[year])
            @global_setting.service_bonus[year] = 100000000

        if !angular.isDefined(@global_setting.airline_security_bonus[year])
            @global_setting.airline_security_bonus[year] = 100000000

        if !angular.isDefined(@global_setting.composite_bonus[year])
            @global_setting.composite_bonus[year] = 100000000

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

        @currentCity = "成都"

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

    loadGlobalReward: ()->
        @$checkRewardDefault()

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


class SalaryPersonalController extends nb.Controller
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
                    name: 'employee_no'
                    displayName: '员工编号'
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
                {
                    name: 'is_salary_special'
                    displayName: '薪酬特殊人员'
                    type: 'boolean'
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

    loadInitialData: () ->
        @salaryPersonSetups = @SalaryPersonSetup.$collection().$fetch()

    search: (tableState) ->
        tableState = tableState || {}
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        @salaryPersonSetups.$refresh(tableState)

    getSelectsIds: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk

    getSelected: () ->
        rows = @gridApi.selection.getSelectedGridRows()

    delete: (isConfirm) ->
        if isConfirm
            @getSelected().forEach (record) ->
                record.entity.$destroy()

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


class SalaryChangeController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', '$enum', 'SalaryChange']

    constructor: ($http, $scope, $Evt, $enum, @SalaryChange) ->
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
                    name: 'employee_no'
                    displayName: '员工编号'
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
            {displayName: '信息发生时间', name: 'createdAt'}
            {displayName: '信息种类', name: 'applyCategory'}
            {
                displayName: '查看'
                field: 'setting'
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a
                        href="javascript:void(0);"
                        nb-dialog
                        template-url="partials/salary/settings/changes/index.html"
                        locals="{change: row.entity}">
                        查看
                    </a>
                </div>
                '''
            }
        ]

    loadInitialData: () ->
        @salaryChanges = @SalaryChange.$collection().$fetch()

    search: (tableState) ->
        tableState = tableState || {}
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        @salaryChanges.$refresh(tableState)


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


class SalaryBaseController extends nb.Controller
    constructor: (@Model, @scope, @q, options = null) ->
        @loadDateTime()
        @loadInitialData(options)

    initialize: (gridApi) ->
        saveRow = (rowEntity) ->
            dfd = @q.defer()

            gridApi.rowEdit.setSavePromise(rowEntity, dfd.promise)

            rowEntity.$save().$asPromise().then(
                () -> dfd.resolve(),
                () ->
                    dfd.reject()
                    rowEntity.$restore())

        # edit.on.afterCellEdit($scope,function(rowEntity, colDef, newValue, oldValue)
        # gridApi.edit.on.afterCellEdit @scope, (rowEntity, colDef, newValue, oldValue) ->

        gridApi.rowEdit.on.saveRow(@scope, saveRow.bind(@))
        @scope.$gridApi = gridApi
        @gridApi = gridApi

    loadDateTime: ()->
        @year_list = @$getYears()
        @month_list = @$getMonths()

        @currentYear = _.last(@year_list)
        @currentMonth = _.last(@month_list)

    loadInitialData: (options) ->
        args = {month: @currentCalcTime()}
        angular.extend(args, options) if angular.isDefined(options)
        @records = @Model.$collection(args).$fetch()

    search: (tableState) ->
        tableState = {} unless tableState
        tableState['month'] = @currentCalcTime()
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        @records.$refresh(tableState)

    getSelectsIds: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk

    getSelected: () ->
        rows = @gridApi.selection.getSelectedGridRows()

    currentCalcTime: ()->
        @currentYear + "-" + @currentMonth

    loadRecords: (options = null) ->
        args = {month: @currentCalcTime()}
        angular.extend(args, options) if angular.isDefined(options)
        @records.$refresh(args)

    # 强制计算
    exeCalc: (options = null) ->
        @calcing = true
        self = @

        args = {month: @currentCalcTime()}
        angular.extend(args, options) if angular.isDefined(options)

        @Model.compute(args).$asPromise().then (data)->
            self.calcing = false
            erorr_msg = data.$response.data.messages
            # _.snakeCase('Foo Bar')
            # @Model => String???
            self.Evt.$send("salary_model:calc:error", erorr_msg) if erorr_msg
            self.loadRecords()


# 基础工资
class SalaryBasicController extends SalaryBaseController
    @.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'BasicSalary', 'toaster']

    constructor: ($http, $scope, $q, @Evt, @Employee, @BasicSalary, @toaster) ->
        super(@BasicSalary, $scope, $q)

        @filterOptions = angular.copy(SALARY_FILTER_DEFAULT)

        @columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
            {displayName: '岗位薪酬', name: 'positionSalary', enableCellEdit: false}
            {displayName: '工龄工资', name: 'workingYearsSalary', enableCellEdit: false}
            {displayName: '保留工资', name: 'reserveSalary', enableCellEdit: false}
            {displayName: '补扣发', name: 'addGarnishee'}
            {displayName: '备注', name: 'remark'}
        ])


# 绩效工资
class SalaryPerformanceController extends SalaryBaseController
    @.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'PerformanceSalary', 'toaster']

    constructor: ($http, $scope, $q, @Evt, @Employee, @PerformanceSalary, @toaster) ->
        super(@PerformanceSalary, $scope, $q)

        @filterOptions = angular.copy(SALARY_FILTER_DEFAULT)

        @columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
            {displayName: '当月绩效基数', name: 'baseSalary', enableCellEdit: false},
            {displayName: '当月绩效薪酬', name: 'amount', enableCellEdit: false},
            {displayName: '补扣发', name: 'addGarnishee'},
            {displayName: '备注', name: 'remark'}
        ])

    upload_performance: (type, attachment_id)->
        self = @
        params = {type: type, attachment_id: attachment_id}

        @http.post("/api/performance_salaries/import", params).success (data, status) ->
            if data.error_count > 0
                self.toaster.pop('error', '提示', '导入失败')
            else
                self.toaster.pop('error', '提示', '导入成功')


# 小时费
class SalaryHoursFeeController extends SalaryBaseController
    @.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'HoursFee', 'toaster']

    constructor: (@http, $scope, $q, @Evt, @Employee, @HoursFee, @toaster) ->
        @hours_fee_category = '飞行员'
        super(@HoursFee, $scope, $q, {hours_fee_category: @hours_fee_category})

        @filterOptions = angular.copy(SALARY_FILTER_DEFAULT)

        @columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
            {displayName: '飞行时间', name: 'flyHours', enableCellEdit: false}
            {displayName: '小时费', name: 'flyFee', enableCellEdit: false}
            {displayName: '空勤灶', name: 'airlineFee', enableCellEdit: false}
            {displayName: '补扣发', name: 'addGarnishee'}
            {displayName: '备注', name: 'remark'}
        ])

    search: () ->
        super({hours_fee_category: @hours_fee_category})

    loadRecords: () ->
        super({hours_fee_category: @hours_fee_category})

    exeCalc: ()->
        super({hours_fee_category: @hours_fee_category})

    upload_hours_fee: (type, attachment_id)->
        self = @
        params = {type: type, attachment_id: attachment_id, month: @currentCalcTime()}
        @show_error_names = false

        @http.post("/api/hours_fees/import", params).success (data, status) ->
            if data.error_count > 0
                self.show_error_names = true
                self.error_names = data.error_names

                self.toaster.pop('error', '提示', '导入失败')
            else
                self.toaster.pop('error', '提示', '导入成功')


class SalaryAllowanceController extends SalaryBaseController
    @.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'Allowance', 'toaster']

    constructor: ($http, $scope, $q, @Evt, @Employee, @Allowance, @toaster) ->
        super(@Allowance, $scope, $q)

        @filterOptions = angular.copy(SALARY_FILTER_DEFAULT)

        @columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
            {displayName: '安检津贴', name: 'security_check', enableCellEdit: false}
            {displayName: '安置津贴', name: 'resettlement', enableCellEdit: false}
            {displayName: '班组长津贴', name: 'group_leader', enableCellEdit: false}
            {displayName: '航站管理津贴', name: 'air_station_manage', enableCellEdit: false}
            {displayName: '车勤补贴', name: 'car_present', enableCellEdit: false}
            {displayName: '地勤补贴', name: 'land_present', enableCellEdit: false}
            {displayName: '放行补贴', name: 'permit_entry', enableCellEdit: false}
            {displayName: '试车津贴', name: 'try_drive', enableCellEdit: false}
            {displayName: '飞行荣誉津贴', name: 'fly_honor', enableCellEdit: false}
            {displayName: '航线实习补贴', name: 'airline_practice', enableCellEdit: false}
            {displayName: '随机补贴', name: 'follow_plane', enableCellEdit: false}
            {displayName: '签派放行补贴', name: 'permit_sign', enableCellEdit: false}
            {displayName: '梭班补贴', name: 'work_overtime', enableCellEdit: false}
            {displayName: '高温补贴', name: 'temp', enableCellEdit: false}
            {displayName: '补扣发', name: 'addGarnishee'}
            {displayName: '备注', name: 'remark'}
        ])

    upload_allowance: (type, attachment_id)->
        self = @
        params = {type: type, attachment_id: attachment_id}

        @http.post("/api/allowances/import", params).success (data, status) ->
            if data.error_count > 0
                self.toaster.pop('error', '提示', '导入失败')
            else
                self.toaster.pop('error', '提示', '导入成功')


class SalaryLandAllowanceController extends SalaryBaseController
    @.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'LandAllowance', 'toaster']

    constructor: ($http, $scope, $q, @Evt, @Employee, @LandAllowance, @toaster) ->
        super(@LandAllowance, $scope, $q)

        @filterOptions = angular.copy(SALARY_FILTER_DEFAULT)

        @columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
            {displayName: '津贴', name: 'subsidy', enableCellEdit: false}
            {displayName: '补扣发', name: 'addGarnishee'}
            {displayName: '备注', name: 'remark'}
        ])


class SalaryRewardController extends SalaryBaseController
    @.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'Reward', 'toaster']

    constructor: ($http, $scope, $q, @Evt, @Employee, @Reward, @toaster) ->
        super(@Reward, $scope, $q)

        @filterOptions = angular.copy(SALARY_FILTER_DEFAULT)

        @columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
            {displayName: '航班正常奖', name: 'flight_bonus', enableCellEdit: false}
            {displayName: '服务质量奖', name: 'service_bonus', enableCellEdit: false}
            {displayName: '航空安全奖', name: 'airline_security_bonus', enableCellEdit: false}
            {displayName: '综治奖', name: 'composite_bonus', enableCellEdit: false}
            {displayName: '收支目标考核奖', name: 'in_out_bonus', enableCellEdit: false}
            {displayName: '奖1', name: 'bonus_1', enableCellEdit: false}
            {displayName: '奖2', name: 'bonus_2', enableCellEdit: false}
        ])

    upload_reward: (type, attachment_id)->
        self = @
        params = {type: type, attachment_id: attachment_id}

        @http.post("/api/rewards/import", params).success (data, status) ->
            if data.error_count > 0
                self.toaster.pop('error', '提示', '导入失败')
            else
                self.toaster.pop('error', '提示', '导入成功')


class SalaryOverviewController extends SalaryBaseController
    @.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'SalaryOverview', 'toaster']

    constructor: ($http, $scope, $q, @Evt, @Employee, @SalaryOverview, @toaster) ->
        super(@SalaryOverview, $scope, $http)

        @filterOptions = angular.copy(SALARY_FILTER_DEFAULT)

        @columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
            {displayName: '基础工资', name: 'basic', enableCellEdit: false}
            {displayName: '绩效工资', name: 'performance', enableCellEdit: false}
            {displayName: '小时费', name: 'hours_fee', enableCellEdit: false}
            {displayName: '津贴', name: 'subsidy', enableCellEdit: false}
            {displayName: '驻站津贴', name: 'land_subsidy', enableCellEdit: false}
            {displayName: '奖励', name: 'reward', enableCellEdit: false}
            {displayName: '合计', name: 'total', enableCellEdit: false}
            {displayName: '备注', name: 'remark'}
        ])


app.controller 'salaryCtrl', SalaryController
app.controller 'salaryPersonalCtrl', SalaryPersonalController
app.controller 'salaryChangeCtrl', SalaryChangeController
app.controller 'salaryExchangeCtrl', SalaryExchangeController
app.controller 'salaryBasicCtrl', SalaryBasicController
app.controller 'salaryPerformanceCtrl', SalaryPerformanceController
app.controller 'salaryHoursFeeCtrl', SalaryHoursFeeController
app.controller 'salaryAllowanceCtrl', SalaryAllowanceController
app.controller 'salaryLandAllowanceCtrl', SalaryLandAllowanceController
app.controller 'salaryRewardCtrl', SalaryRewardController
app.controller 'salaryOverviewCtrl', SalaryOverviewController