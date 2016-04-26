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
        {
            name: 'notes'
            displayName: '是否有说明'
            type: 'boolean'
        }
    ]
}

SALARY_COLUMNDEF_DEFAULT = [
    {
        minWidth: 120
        displayName: '员工编号'
        name: 'employeeNo'
        enableCellEdit: false
        pinnedLeft: true
    }
    {
        minWidth: 120
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
        pinnedLeft: true
    }
    {
        minWidth: 350
        displayName: '所属部门'
        name: 'departmentName'
        enableCellEdit: false
        cellTooltip: (row) ->
            return row.entity.departmentName
    }
    {
        minWidth: 250
        displayName: '岗位'
        name: 'positionName'
        enableCellEdit: false
        cellTooltip: (row) ->
            return row.entity.positionName
    }
    {minWidth: 120, displayName: '通道', name: 'channelId', enableCellEdit: false, cellFilter: "enum:'channels'"}
]

CALC_STEP_COLUMN = [
    {
        minWidth: 150
        displayName: '计算过程'
        field: 'step'
        enableCellEdit: false
        cellTemplate: '''
        <div class="ui-grid-cell-contents">
            <a nb-dialog
                template-url="partials/salary/calc/step.html"
                locals="{employee_id: row.entity.owner.$pk, employee_name: row.entity.employee_name, month: row.entity.month, category: row.entity.category}">
                显示过程
            </a>
        </div>
        '''
    }
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
    @.$inject = ['$http', '$scope', '$nbEvent', 'toaster', 'SALARY_SETTING', 'PERMISSIONS']

    constructor: (@http, @scope, $Evt, @toaster, @SALARY_SETTING, @PERMISSIONS) ->
        self = @
        @initialize()

        @variables = ['调档年限','驾驶经历年限','教员经历年限','飞行时间','员工学历','员工职级','去年年度绩效','本企业经历年限','无人为飞行事故年限','无安全严重差错年限', '高原特殊机场飞行资格']

        @tempUpdatable = _.includes @PERMISSIONS, 'salaries_update_temp'
        @comunicateUpdatable = _.includes @PERMISSIONS, 'salaries_update_communicate_allowance'
        @coldSubsidyUpdatable = _.includes @PERMISSIONS, 'salaries_update_cold_subsidy'

    queryVariables: (text)->
        self = @
        variables = _.filter self.variables, (variable)->
            _.includes variable, text
        return variables

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

        # if !angular.isDefined(@global_setting.flight_bonus[year])
        #     @global_setting.flight_bonus[year] = 100000000

        # if !angular.isDefined(@global_setting.service_bonus[year])
        #     @global_setting.service_bonus[year] = 100000000

        # if !angular.isDefined(@global_setting.airline_security_bonus[year])
        #     @global_setting.airline_security_bonus[year] = 100000000

        # if !angular.isDefined(@global_setting.composite_bonus[year])
        #     @global_setting.composite_bonus[year] = 100000000

    initialize: () ->
        self = @
        @CATEGORY_LIST = ["leader_base",                # 基础-干部
                          "manager15_base",             # 基础-管理15
                          "manager12_base",             # 基础-管理12
                          "flyer_legend_base",          # 基础-荣誉级
                          "flyer_duty_leader_base",     # 基础-责任机长
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
                          "service_c_driving_base",             # 基础-服务C-驾驶
                          "air_observer_base",                  # 基础-空中观察员
                          "front_run_base",                     # 基础-前场运行监察
                          "information_perf",                   # 绩效-信息通道
                          "airline_business_perf",              # 绩效-航务航材
                          "manage_market_perf",                 # 绩效-管理营销
                          "service_normal_perf",                # 绩效-机务维修(普通员工)
                          "service_tech_perf",                  # 绩效-机务维修(技术骨干)
                          "service_c_1_perf",                   # 绩效-服务C-1
                          "service_c_2_perf",                   # 绩效-服务C-2
                          "service_c_3_perf",                   # 绩效-服务C-3
                          "service_c_driving_perf",             # 绩效-服务C-驾驶
                          "market_leader_perf",                 # 绩效-营销类Y/管理A类
                          "material_leader_perf",               # 绩效-航务/航材技术类H
                          "information_leader_perf",            # 绩效-信息技术类E
                          "service_leader_perf",                # 绩效-机务维修技术类W
                          "flyer_hour",                         # 小时费-飞行员
                          "fly_attendant_hour",                 # 小时费-空乘
                          "air_security_hour",                  # 小时费-空保
                          "unfly_allowance_hour",               # 小时费-未飞补贴
                          "flyer_science_subsidy",              # 小时费-飞行驾驶技术津贴
                          "allowance",                          # 津贴设置
                          "land_subsidy",                       # 地面驻站补贴
                          "airline_subsidy",                    # 空勤驻站补贴
                          "temp"                                # 高温补贴
                          "cold_subsidy"                        # 寒冷补贴
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

    loadMonthList: () ->
        if @currentYear == new Date().getFullYear()
            months = [1..new Date().getMonth() + 1]
        else
            months = [1..12]

        @month_list = _.map months, (item)->
            item = '0' + item if item < 10
            item + ''

    loadGlobalCoefficient: ()->
        @loadMonthList()
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

    formatColumn: (flags, grade, setting, column)->
        result = input = setting[column]

        if column == 'rate' || column == 'amount'
            return result

        if input && angular.isDefined(input)
            result = input['format_cell']

            if result && angular.isDefined(result)
                vars = ['transfer_years', 'drive_work_years', 'teacher_drive_years', 'fly_time_value', 'job_title_degree', 'education_background', 'last_year_perf', 'join_scal_years', 'no_subjective_accident', 'no_serious_security_error', 'can_fly_highland_special']
                angular.forEach vars, (item) ->
                    result = result.replace('%{' + item + '}', input[item])
            else if angular.isDefined(input['transfer_years'])
                if input['transfer_years'] == '99'
                    result = '封顶'
                if input['transfer_years'] == '999'
                    result = '荣誉'

        result

    exchangeExpr: (expr, reverse = false)->
        expr = "" if !expr

        hash = {
            '调档年限':             '%{transfer_years}'
            '驾驶经历年限':          '%{drive_work_years}'
            '教员经历年限':          '%{teacher_drive_years}'
            '飞行时间':              '%{fly_time_value}'
            '员工职级':              '%{job_title_degree}'
            '员工学历':              '%{education_background}'
            '去年年度绩效':          '%{last_year_perf}'
            '本企业经历年限':         '%{join_scal_years}'
            '无人为飞行事故年限':      '%{no_subjective_accident_years}'
            '无安全严重差错年限':      '%{no_serious_security_error_years}'
            '高原特殊机场飞行资格':  '%{can_fly_highland_special}'
        }

        result = expr

        angular.forEach hash, (value, key)->
            if reverse
                result = result.replace(value, key) if result
            else
                result = result.replace(key, value) if result

        result

    loadPositions: (selectDepIds, keywords)->
        self = @
        return unless selectDepIds

        @tempPositions = []

        @http.get('/api/salaries/temperature_amount?department_ids=' + selectDepIds + '&per_page=10000')
            .success (data)->
                self.tempPositions = data.temperature_amounts

                if !!keywords && keywords.length > 0
                    self.tempPositions = _.filter self.tempPositions, (item)->
                        item.full_position_name.indexOf(keywords) >= 0

    listTempPosition: (amount)->
        self = @

        @http.get('/api/salaries/temperature_amount?per_page=3000&temperature_amount=' + amount)
            .success (data)->
                self.currentTempPositions = data.temperature_amounts

    updateTempAmount: (position_id, amount)->
        self = @
        params = {position_id: position_id, temperature_amount: parseInt(amount)}

        @http.put('/api/salaries/update_temperature_amount', params)
            .success (data)->
                self.toaster.pop('success', '提示', '更新成功')
            .error (data)->
                self.toaster.pop('error', '提示', '更新失败')

    # 通讯补贴 TODO: 和高温补贴合并
    loadComPositions: (selectDepIds, keywords)->
        self = @
        return unless selectDepIds

        @comPositions = []

        @http.get('/api/salaries/communicate_allowance?department_ids=' + selectDepIds + '&per_page=10000')
            .success (data)->
                self.comPositions = data.communicate_allowances

                if !!keywords && keywords.length > 0
                    self.comPositions = _.filter self.comPositions, (item)->
                        item.full_position_name.indexOf(keywords) >= 0

    listComPosition: (allowance)->
        self = @

        @http.get('/api/salaries/communicate_allowance?per_page=3000&communicate_allowance=' + allowance)
            .success (data)->
                self.currentComPositions = data.communicate_allowances

    loadComDutyRank: () ->
        self = @

        @http.get('/api/salaries/communicate_of_duty_rank')
            .success (data)->
                console.log data
                self.dutyRankAllowance = data.duty_ranks


    updateComAmount: (position_id, amount)->
        self = @
        params = {position_id: position_id, communicate_allowance: parseInt(amount)}

        @http.put('/api/salaries/update_communicate_allowance', params)
            .success (data)->
                self.toaster.pop('success', '提示', '更新成功')
            .error (data)->
                self.toaster.pop('error', '提示', '更新失败')

    updateComRankAmount: (rank_id, amount)->
        self = @
        params = {id: rank_id, communicate_allowance: parseInt(amount)}

        @http.put('/api/salaries/set_communicate_of_duty_rank', params)
            .success (data)->
                self.toaster.pop('success', '提示', '更新成功')
            .error (data)->
                self.toaster.pop('error', '提示', '更新失败')

    # 寒冷补贴 TODO: 和高温补贴合并
    loadColdPositions: (selectDepIds, keywords)->
        self = @
        return unless selectDepIds

        @coldPositions = []

        @http.get('/api/salaries/position_cold_subsidy?department_ids=' + selectDepIds + '&per_page=10000')
            .success (data)->
                self.coldPositions = data.position_cold_subsidy

                if !!keywords && keywords.length > 0
                    self.coldPositions = _.filter self.coldPositions, (item)->
                        item.full_position_name.indexOf(keywords) >= 0

    listColdPosition: (type)->
        self = @

        @http.get('/api/salaries/position_cold_subsidy?cold_subsidy_type=' + type)
            .success (data)->
                self.currentColdPositions = data.position_cold_subsidy

    updateColdType: (position_id, type)->
        self = @
        params = {position_id: position_id, cold_subsidy_type: type}

        @http.put('/api/salaries/set_position_cold_subsidy', params)
            .success (data)->
                self.toaster.pop('success', '提示', '更新成功')
            .error (data)->
                self.toaster.pop('error', '提示', '更新失败')

    destroyCity: (cities, idx) ->
        cities.splice(idx, 1)

    addSkyCity: (cities, city) ->
        self = @

        if city.city
            cities.push(city)
            self.scope.cityForeign = {}
            self.scope.cityNation = {}
            self.toaster.pop('success', '提示', '添加成功，点击“保存”按钮保存设置')

        else
            self.toaster.pop('error', '提示', '请填写城市名称及缩写名')

    addColdCity: (cities, city) ->
        self = @

        if city.name
            cities.push(city)
            self.scope.newSubsidy = {}
            self.toaster.pop('success', '提示', '添加成功，点击“保存”按钮保存设置')

        else
            self.toaster.pop('error', '提示', '请填写城市名称')

class DepNumSettingController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', 'Org', 'toaster']

    constructor: (@http, $scope, $Evt, @Org, @toaster) ->
        @orgTree = {}

        @loadInitialData()

    loadInitialData: () ->
        self = @
        @Org.$search().$then (data)->
            self.orgTree = data.jqTreeful()[0]
            console.log self.orgTree

    saveDepNumber: (id, num) ->
        # @http请求保存接口
        # 保存部门编码
        self = @
        params = { id: id, set_book_no: num }

        @http.post('/api/departments/update_set_book_no', params)
            .success (data) ->
                self.toaster.pop 'success', '提示', data.messages
            .error (data) ->
                self.toaster.pop 'error', '提示', data.messages



class SalaryPersonalController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', '$enum', 'SalaryPersonSetup', 'toaster']

    constructor: (@http, $scope, $Evt, $enum, @SalaryPersonSetup, @toaster) ->
        @tableState = null
        @exportSalarySettingUrl = ''

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
                    name: 'department_ids'
                    displayName: '机构'
                    type: 'org-search'
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
            {
                minWidth: 120
                displayName: '员工编号'
                name: 'employeeNo'
            }
            {
                minWidth: 120
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
                minWidth: 350
                displayName: '所属部门'
                name: 'department.name'
                cellTooltip: (row) ->
                    return row.entity.departmentName
            }
            {
                minWidth: 250
                displayName: '岗位'
                name: 'positionName'
                cellTooltip: (row) ->
                    return row.entity.positionName
            }
            {
                minWidth: 120
                displayName: '分类'
                name: 'categoryId'
                cellFilter: "enum:'categories'"
            }
            {
                minWidth: 120
                displayName: '通道'
                name: 'channelId'
                cellFilter: "enum:'channels'"
            }
            {
                minWidth: 120
                displayName: '用工性质'
                name: 'laborRelationId'
                cellFilter: "enum:'labor_relations'"
            }
            {
                minWidth: 120
                displayName: '属地化'
                name: 'location'
            }
            {
                minWidth: 120
                displayName: '设置'
                field: 'setting'
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a
                        href="javascript:void(0);"
                        nb-dialog
                        template-url="partials/salary/settings/personal_edit/personal_edit.html"
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
        @tableState = tableState

    exportSalaryUrl: () ->
        paramStr = ''

        if @tableState
            _.map @tableState, (value, key) ->
                if angular.isString value
                    paramStr = paramStr + (key + '=' + value) + '&'
                if angular.isArray value
                    value.forEach (item) ->
                        paramStr = paramStr + (key + '%5B%5D' + '=' + item) + '&'

        @exportSSUrl = 'api/salary_person_setups/export_to_xls?' + paramStr

    getSelectsIds: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk

    getSelected: () ->
        rows = @gridApi.selection.getSelectedGridRows()

    currentCalcTime: ()->
        @currentYear + "-" + @currentMonth

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

    uploadSalarySetBook: (attachment_id)->
        self = @
        params = {attachment_id: attachment_id}

        @http.post("/api/salary_person_setups/upload_salary_set_book", params).success (data, status) ->
            self.toaster.pop('success', '提示', '导入成功')
            self.import_finish = true

    uploadShareFund: (attachment_id)->
        self = @
        params = {attachment_id: attachment_id}

        @http.post("/api/salary_person_setups/upload_share_fund", params).success (data, status) ->
            self.toaster.pop('success', '提示', '导入成功')
            self.import_finish = true


class SalaryChangeController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', '$enum', 'SalaryChange', 'SalaryPersonSetup']

    constructor: (@http, $scope, $Evt, $enum, @SalaryChange, @SalaryPersonSetup) ->
        @loadInitialData()

        @filterOptions = {
            name: 'salaryChange'
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
                    name: 'category'
                    displayName: '信息种类'
                    type: 'salary_change_category_select'
                }
            ]
        }

        @columnDef = [
            {
                minWidth: 120
                displayName: '员工编号'
                name: 'employeeNo'
            }
            {
                minWidth: 120
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
                minWidth: 350
                displayName: '所属部门'
                name: 'departmentName'
                cellTooltip: (row) ->
                    return row.entity.departmentName
            }
            {
                minWidth: 150
                displayName: '信息发生时间'
                name: 'changeDate'
            }
            {
                minWidth: 150
                displayName: '信息种类'
                name: 'category'
            }
            {
                minWidth: 120
                displayName: '查看'
                field: 'setting'
                cellTemplate: '''
                <div class="ui-grid-cell-contents" ng-init="outerScope=grid.appScope.$parent">
                    <a
                        href="javascript:void(0);"
                        nb-dialog
                        template-url="partials/salary/settings/changes/personal.html"
                        locals="{change: row.entity, outerScope: outerScope}">
                        查看
                    </a>
                </div>
                '''
            }
        ]

    loadInitialData: () ->
        @salaryChanges = @SalaryChange.$collection().$fetch()

    loadPersonSettings: (change) ->
        self = @
        return @SalaryPersonSetup.$collection().$fetch().$find(change.salaryPersonSetupId) || {}

        # return @SalaryPersonSetup.$collection().$fetch(change.salaryPersonSetupId)

    newPersonSettings: (change, settings, dialog) ->
        self = @

        settings.owner = change.owner
        settings.recordDate = change.changeDate
        @SalaryPersonSetup.$build(settings).$save().$then (data)->
            change.state = '已处理'
            change.$save().$then (data)->
                self.salaryChanges.$refresh()

    search: (tableState) ->
        tableState = tableState || {}
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        @salaryChanges.$refresh(tableState)


class SalaryGradeChangeController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', '$enum', 'SalaryGradeChange', 'SALARY_SETTING', 'toaster', '$rootScope']

    constructor: (@http, @scope, $Evt, $enum, @SalaryGradeChange, @SALARY_SETTING, @toaster, @rootScope) ->
        self = @

        @loadInitialData()

        @checking = false

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
                    name: 'department_ids'
                    displayName: '机构'
                    type: 'org-search'
                }
            ]
        }

        @columnDef = [
            {
                minWidth: 120
                displayName: '员工编号'
                name: 'employeeNo'
            }
            {
                minWidth: 120
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
                minWidth: 350
                displayName: '所属部门'
                name: 'department.name'
                cellTooltip: (row) ->
                    return row.entity.departmentName
            }
            {
                minWidth: 120
                displayName: '用工性质'
                name: 'laborRelationId'
                cellFilter: "enum:'labor_relations'"
            }
            {
                minWidth: 120
                displayName: '通道'
                name: 'channelId'
                cellFilter: "enum:'channels'"
            }
            {
                minWidth: 150
                displayName: '薪酬模块'
                name: 'changeModule'
            }
            {
                minWidth: 150
                displayName: '信息发生时间'
                name: 'recordDate'
            }
            {
                minWidth: 120
                displayName: '查看'
                field: 'setting'
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a
                        href="javascript:void(0);"
                        nb-dialog
                        template-url="partials/salary/settings/changes/grade.html"
                        locals="{gradeChange: row.entity, ctrl: grid.appScope.$parent.ctrl}">
                        查看
                    </a>
                </div>
                '''
            }
        ]

        # 检测后端推送的更新通知
        # 需要测试
        @rootScope.$watch 'reloadFlagStr', (oldValue, newValue)->
            try
                if angular.isDefined(self.salaryGradeChanges)
                    self.salaryGradeChanges.$refresh()
            catch ex
                console.error "检测reloadTableData数据发生异常", ex
            finally

    loadInitialData: () ->
        @salaryGradeChanges = @SalaryGradeChange.$collection().$fetch()

    search: (tableState) ->
        tableState = tableState || {}
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        @salaryGradeChanges.$refresh(tableState)

    checkUpdateChange: (type)->
        params = new Object()
        self = @
        params.type = type
        @checking = true

        @http.get('/api/salary_person_setups/check_person_upgrade.json?type='+type)
            .success (data)->
                self.toaster.pop('success', '提示', '薪酬档级变动数据已更新')
                self.salaryGradeChanges.$refresh()
                self.checking = false
            .error (data)->
                self.checking = false


class SalaryExchangeController
    @.$inject = ['$http', '$scope', '$nbEvent', 'SALARY_SETTING', '$timeout', 'toaster', '$q']

    constructor: (@http, $scope, $Evt, @SALARY_SETTING, $timeout, @toaster, @q) ->
        self = @

        @setBookData = null
        @alreadyHasSetBook = true

        @isLegalFlagArr = []
        @isLegalPerfFlagArr = []

        @normalChannelArr = []
        @normalPerfChannelArr = []

        if angular.isDefined $scope.$parent.$parent.current.formData
            $timeout(
                ()->
                    self.normal_channel_array($scope.$parent.$parent.current.formData.transferTo)
                    self.perf_channel_array($scope.$parent.$parent.current.formData.transferTo)
                , 500
                )
        else
            $timeout(
                ()->
                    self.normal_channel_array($scope.$parent.$parent.current)
                    self.perf_channel_array($scope.$parent.$parent.current)
                , 0
                )

    $channelSettingStr: (channel)->
        channel + '_setting'

    $settingHash: (channel)->
        @SALARY_SETTING[@$channelSettingStr(channel)]

    service_b: (current)->
        return unless current.baseWage
        setting = @$settingHash(current.baseWage)

        # 总工资
        current.basePerformanceMoney = setting.flags[current.baseFlag]['amount']
        # 基本工资
        current.baseMoney = @SALARY_SETTING['global_setting']['minimum_wage']
        # 除开基本工资，剩下的就是绩效工资(service_b)
        current.performanceMoney = current.basePerformanceMoney - current.baseMoney

    service_b_channel_array: (current)->
        return unless current.baseWage

        setting = @$settingHash(current.baseWage)

        channels = []

        angular.forEach setting.flag_list, (item)->
            if item != 'rate' && !_.startsWith(item, 'amount')
                channels.push(item)
                current.baseChannel = item
        _.uniq(channels)

    service_b_flag_array: (current)->
        return unless current.baseWage

        setting = @$settingHash(current.baseWage)
        Object.keys(setting.flags)

    normal: (current)->
        return unless current.baseWage
        return unless current.baseFlag

        setting = @$settingHash(current.baseWage)
        flag = setting.flags[current.baseFlag]

        return current.baseMoney = flag.amount if angular.isDefined(flag)
        return 0

    normal_channel_array: (current)->
        self = @

        return unless current.baseWage
        setting = @$settingHash(current.baseWage)
        channels = []

        angular.forEach setting.flag_list, (item)->
            channel = {}
            if item != 'rate' && !_.startsWith(item, 'amount')
                channel.grade = item
                channel.name = setting.flag_names[item]

                channels.push(channel)

        @normalChannelArr = _.uniq(channels)

    normal_flag_array: (current)->
        self = @
        @isLegalFlagArr = []

        return unless current.baseWage
        return unless current.baseChannel

        setting = @$settingHash(current.baseWage)
        flags = []

        angular.forEach setting.flags, (config, flag)->
            if Object.keys(config).indexOf(current.baseChannel) >= 0
                format_cell = config[current.baseChannel]['format_cell']

                if format_cell && format_cell.length > 0
                    self.isLegalFlagArr.push(flag)

            flags.push(flag)

        return flags

    perf: (current)->
        return unless current.performanceWage
        return unless current.performanceWage != 'service_tech_perf'
        setting = @$settingHash(current.performanceWage)

        flag = setting.flags[current.performanceFlag]

        return current.performanceMoney = flag.amount if angular.isDefined(flag)
        return 0

    # 机务维修通道 技术骨干 绩效个人设置数据读取
    techPerf: (current) ->
        return unless current.performanceWage
        return unless current.performanceChannel
        return unless current.technicalCategory
        return unless current.performancePosition

        setting = @$settingHash(current.performanceWage)

        if angular.isDefined setting[current.technicalCategory][current.performancePosition]
            current.performanceMoney = setting[current.technicalCategory][current.performancePosition][current.performanceChannel].amount
        else
            current.performanceMoney = 0

    changeBaseWage: (current) ->
        if current.baseWage=='leader_base'
            current.performanceWage = null
            current.performanceChannel = null
            current.performanceFlag = null
            current.performanceMoney = null

        current.baseChannel = null
        current.baseFlag = null
        current.baseMoney = null

    changeBaseChannel: (current) ->
        if current.baseWage=='leader_base'
            current.performanceFlag = null
            current.performanceMoney = null

        current.baseFlag = null
        current.baseMoney = null

    changePerWage: (current) ->
        current.performanceChannel = null if current.performanceChannel
        current.performanceFlag = null  if current.performanceFlag
        current.performanceMoney = null  if current.performanceMoney
        current.technicalCategory = null if current.technicalCategory

    perf_channel_array: (current)->
        return unless current.performanceWage
        return unless current.performanceWage != 'service_tech_perf'

        setting = @$settingHash(current.performanceWage)
        channels = []
        angular.forEach setting.flag_list, (item)->
            channel = {}
            if item != 'rate' && !_.startsWith(item, 'amount')
                channel.grade = item
                channel.name = setting.flag_names[item]
                channels.push(channel)
        @normalPerfChannelArr = _.uniq(channels)

    perf_flag_array: (current)->
        self = @
        @isLegalPerfFlagArr = []

        return unless current.performanceWage

        setting = @$settingHash(current.performanceWage)
        flags = []

        angular.forEach setting.flags, (config, flag)->
            if Object.keys(config).indexOf(current.performanceChannel) >= 0
                format_cell = config[current.performanceChannel]['format_cell']

                if format_cell && format_cell.length > 0
                    self.isLegalPerfFlagArr.push(flag)

            flags.push(flag)

        return flags

    leaderPerfFlagArray: (current) ->
        self = @
        @isLegalPerfFlagArr = []

        return unless current.performanceWage

        setting = @$settingHash(current.performanceWage)
        flags = []

        angular.forEach setting.flags, (config, flag) ->
            return if !angular.isDefined(config)
            return if !angular.isDefined(config["X"])

            if config["X"]["format_cell"]
                self.isLegalPerfFlagArr.push(flag)

            flags.push(flag)

        return flags

    fly: (current)->
        return unless current.baseWage
        return unless current.baseFlag

        setting = @$settingHash(current.baseWage)
        current.baseMoney = setting.flags[current.baseFlag]['amount']

    flyPerf: (current) ->
        return unless current.leaderGrade

        setting = @$settingHash('market_leader_perf')

        angular.forEach setting.flags, (config, flag) ->
            return if !angular.isDefined(config)
            return if !angular.isDefined(config["X"])

            if config["X"]["format_cell"] == current.leaderGrade
                current.performanceMoney = config['amount']
                return

    fly_channel_array: (current)->
        return unless current.baseWage

        setting = @$settingHash(current.baseWage)

        channels = []
        angular.forEach setting.flag_list, (item)->
            if item != 'rate' && !_.startsWith(item, 'amount')
                channels.push(item)
                # current.baseChannel = item
        _.uniq(channels)

    fly_flag_array: (current)->
        self = @
        @isLegalFlagArr = []

        return unless current.baseWage

        setting = @$settingHash(current.baseWage)
        Object.keys(setting.flags)

    fly_hour: (current)->
        return unless current.flyHourFee

        setting = @$settingHash('flyer_hour')
        current.flyHourMoney = setting[current.flyHourFee]

    flyer_science_subsidy: (current)->
        return unless current.flyerScienceSubsidy

        setting = @$settingHash('flyer_science_subsidy')
        current.flyerScienceMoney = setting[current.flyerScienceSubsidy]

    airline: (current)->
        return unless current.baseWage
        return unless current.baseFlag

        setting = @$settingHash(current.baseWage)
        current.baseMoney = setting.flags[current.baseFlag]['amount']

    air_channel_array: (current)->
        return unless current.baseWage

        setting = @$settingHash(current.baseWage)

        channels = []
        angular.forEach setting.flag_list, (item)->
            if item != 'rate' && !_.startsWith(item, 'amount')
                channels.push(item)

        _.uniq(channels)

    airline_flag_array: (current)->
        return unless current.baseWage

        setting = @$settingHash(current.baseWage)
        Object.keys(setting.flags)

    airline_hour: (current)->
        return current.airlineHourMoney = 0 unless current.airlineHourFee

        setting = @$settingHash('fly_attendant_hour')
        current.airlineHourMoney = setting[current.airlineHourFee]

    security_hour: (current)->
        return current.securityHourMoney = 0 unless current.securityHourFee

        setting = @$settingHash('air_security_hour')
        current.securityHourMoney = setting[current.securityHourFee]

    loadPersonalSetBook: (current) ->
        self = @

        employeeId = current.owner.$pk

        @http.get('/api/set_books/info?employee_id=' + employeeId)
            .success (data) ->
                if data.messages == '该员工套账信息为空'
                    self.alreadyHasSetBook = false
                else
                    self.setBookData = data.set_book_info
                    self.alreadyHasSetBook = true

    savePersonalSetBook: (setBookData, current) ->
        self = @

        params = setBookData
        params.employee_id = current.owner.$pk

        if @alreadyHasSetBook
            @http.put '/api/set_books/' + params.employee_id, params
                .success (msg) ->
                    self.toaster.pop 'success', '提示', '套账信息保存成功'
                .error (msg) ->
                    self.toaster.pop 'error', '提示', msg.messages

        else if !@alreadyHasSetBook
            @http.post '/api/set_books', params
                .success (data) ->
                    self.setBookData = data.set_book_info
                    self.toaster.pop 'success', '提示', '套账信息创建成功'
                    self.alreadyHasSetBook = true
                .error (msg) ->
                    self.toaster.pop 'error', '提示', msg.messages

    checkRegBankNo: (backNo, form) ->
        reg = /^\d{19}$/

        form.$invalid = !reg.test(backNo)


class SalaryBaseController extends nb.Controller
    constructor: (@Model, @scope, @q, @right_hand_mode, options = null, @rootScope) ->
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

    loadMonthList: () ->
        unless !@right_hand_mode
            if @currentYear == new Date().getFullYear()
                months = [1..new Date().getMonth() + 1]
            else
                months = [1..12]
        else
            if @currentYear == new Date().getFullYear()
                months = [1..new Date().getMonth()]
            else
                months = [1..12]

        @month_list = _.map months, (item)->
                item = '0' + item if item < 10
                item + ''

    loadDateTime: ()->
        date = new Date()

        @year_list = @$getYears()
        @month_list = @$getMonths()

        unless @right_hand_mode
            # 不是正扣倒发模式，看上个月的数据
            if date.getMonth() == 0
                @year_list.pop()
                # @year_list.unshift(date.getFullYear() - 1)
                @month_list = _.map [1..12], (item)->
                    item = '0' + item if item < 10
                    item + '' # to string

                @currentYear = _.last(@year_list)
                @currentMonth = _.last(@month_list)
            else
                @currentYear = _.last(@year_list)
                @month_list.pop()
                @currentMonth = _.last(@month_list)
        else
            # 正发倒扣模式
            @currentYear = _.last(@year_list)
            @currentMonth = _.last(@month_list)

    loadInitialData: (options) ->
        args = {month: @currentCalcTime()}
        angular.extend(args, options) if angular.isDefined(options)
        # 这种写法只有一次请求
        # 造成：先根据员工姓名搜索，再将下拉框改为员工编号搜索，
        #      两次搜索的条件会被合并起来，导致搜索请求错误
        # 原因：待查明，跟restmod相关
        # @records = @Model.$collection(args).$fetch()
        # 解决：换为下面的方法，得到更干净的集合records,但请求2次
        @records = @Model.$collection().$fetch()
        @records.$refresh(args)

    search: (tableState) ->
        tableState = tableState || {}
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
        @loadMonthList()
        args = {month: @currentCalcTime()}
        angular.extend(args, options) if angular.isDefined(options)
        @records.$refresh(args)

    cancelLoading: () ->
        @rootScope.loading = false

    startLoading: () ->
        @rootScope.loading = true

    # 强制计算
    exeCalc: (options = null) ->
        @startLoading()
        @calcing = true
        self = @

        args = {month: @currentCalcTime()}
        angular.extend(args, options) if angular.isDefined(options)

        @Model.compute(args).$asPromise().then (data)->
            self.cancelLoading()
            self.calcing = false
            erorr_msg = data.$response.data.messages
            # _.snakeCase('Foo Bar')
            # @Model => String???
            self.Evt.$send("salary_model:calc:error", erorr_msg) if erorr_msg
            self.loadRecords()
        , ()->
            self.cancelLoading()
            self.calcing = false


# 基础工资
class SalaryBasicController extends SalaryBaseController
    @.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'BasicSalary', 'toaster', '$rootScope']

    constructor: ($http, $scope, $q, @Evt, @Employee, @BasicSalary, @toaster, @rootScope) ->
        super(@BasicSalary, $scope, $q, true, null, @rootScope)

        @filterOptions = angular.copy(SALARY_FILTER_DEFAULT)

        @columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
            {minWidth: 150, displayName: '岗位薪酬', name: 'positionSalary', enableCellEdit: false}
            {minWidth: 150, displayName: '工龄工资', name: 'workingYearsSalary', enableCellEdit: false}
            {minWidth: 150, displayName: '补扣发', name: 'addGarnishee', headerCellClass: 'editable_cell_header'}
            {
                minWidth: 150
                name:"notes"
                displayName:"说明"
                enableCellEdit: false
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a href="javascript:;" nb-popup-plus="nb-popup-plus" position="left-bottom" offset="0.5" style="color: rgba(0,0,0,0.87);">
                        {{row.entity.notes || '无'}}
                        <popup-template
                            style="padding:8px;border:1px solid #ccc;"
                            class="nb-popup org-default-popup-template">
                            <div class="panel-body popup-body">
                                <div class="salary-explain">
                                    {{row.entity.notes || '无'}}
                                </div>
                            </div>
                        </popup-template>
                    </a>
                </div>
                '''
                cellTooltip: (row) ->
                    return row.entity.notes
            }
            {
                minWidth: 150
                name:"remark"
                displayName:"备注"
                headerCellClass: 'editable_cell_header'
                enableCellEdit: false
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a href="javascript:;" nb-popup-plus="nb-popup-plus" position="left-bottom" offset="0.5">
                        {{row.entity.remark || '请输入备注'}}
                        <popup-template
                            style="padding:8px;border:1px solid #ccc;"
                            class="nb-popup org-default-popup-template">
                            <div class="panel-body popup-body">
                                <md-input-container>
                                    <label>备注</label>
                                    <textarea
                                        ng-blur="row.entity.$save()"
                                        ng-model="row.entity.remark"
                                        style="resize:none;"
                                        class="reason-input"></textarea>
                                </md-input-container>
                            </div>
                        </popup-template>
                    </a>
                </div>
                '''
                cellTooltip: (row) ->
                    return row.entity.note
            }
        ]).concat(CALC_STEP_COLUMN)


# 保留工资
class SalaryKeepController extends SalaryBaseController
    @.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'KeepSalary', 'toaster', '$rootScope']

    constructor: ($http, $scope, $q, @Evt, @Employee, @KeepSalary, @toaster, @rootScope) ->
        super(@KeepSalary, $scope, $q, true, null, @rootScope)

        @filterOptions = angular.copy(SALARY_FILTER_DEFAULT)

        @columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
            {minWidth: 150, displayName: '岗位工资保留', name: 'position', enableCellEdit: false}
            {minWidth: 150, displayName: '业绩奖保留', name: 'performance', enableCellEdit: false}
            {minWidth: 150, displayName: '工龄工资保留', name: 'workingYears', enableCellEdit: false}
            {minWidth: 150, displayName: '保底增幅', name: 'minimumGrowth', enableCellEdit: false}
            {minWidth: 150, displayName: '地勤补贴保留', name: 'landAllowance', enableCellEdit: false}
            {minWidth: 150, displayName: '生活补贴保留1', name: 'life1', enableCellEdit: false}
            {minWidth: 150, displayName: '生活补贴保留2', name: 'life2', enableCellEdit: false}
            {minWidth: 150, displayName: '09调资增加保留', name: 'adjustment09', enableCellEdit: false}
            {minWidth: 150, displayName: '14公务用车保留', name: 'bus14', enableCellEdit: false}
            {minWidth: 150, displayName: '14通信补贴保留', name: 'communication14', enableCellEdit: false}
            {minWidth: 150, displayName: '补扣发', name: 'addGarnishee', headerCellClass: 'editable_cell_header'}
            {
                minWidth: 150,
                name:"notes"
                displayName:"说明"
                enableCellEdit: false
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a href="javascript:;" nb-popup-plus="nb-popup-plus" position="left-bottom" offset="0.5" style="color: rgba(0,0,0,0.87);">
                        {{row.entity.notes || '无'}}
                        <popup-template
                            style="padding:8px;border:1px solid #ccc;"
                            class="nb-popup org-default-popup-template">
                            <div class="panel-body popup-body">
                                <div class="salary-explain">
                                    {{row.entity.notes || '无'}}
                                </div>
                            </div>
                        </popup-template>
                    </a>
                </div>
                '''
                cellTooltip: (row) ->
                    return row.entity.notes
            }
            {
                minWidth: 150,
                name:"remark"
                displayName:"备注"
                headerCellClass: 'editable_cell_header'
                enableCellEdit: false
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a href="javascript:;" nb-popup-plus="nb-popup-plus" position="left-bottom" offset="0.5">
                        {{row.entity.remark || '请输入备注'}}
                        <popup-template
                            style="padding:8px;border:1px solid #ccc;"
                            class="nb-popup org-default-popup-template">
                            <div class="panel-body popup-body">
                                <md-input-container>
                                    <label>备注</label>
                                    <textarea
                                        ng-blur="row.entity.$save()"
                                        ng-model="row.entity.remark"
                                        style="resize:none;"
                                        class="reason-input"></textarea>
                                </md-input-container>
                            </div>
                        </popup-template>
                    </a>
                </div>
                '''
                cellTooltip: (row) ->
                    return row.entity.note
            }
        ]).concat(CALC_STEP_COLUMN)


# 绩效工资
class SalaryPerformanceController extends SalaryBaseController
    @.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'PerformanceSalary', 'toaster', '$rootScope']

    constructor: (@http, $scope, $q, @Evt, @Employee, @PerformanceSalary, @toaster, @rootScope) ->
        super(@PerformanceSalary, $scope, $q, false, null, @rootScope)

        @filterOptions = angular.copy(SALARY_FILTER_DEFAULT)

        @columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
            {minWidth: 150, displayName: '当月绩效基数', name: 'baseSalary', enableCellEdit: false}
            {minWidth: 150, displayName: '当月绩效薪酬', name: 'amount', enableCellEdit: false}
            {minWidth: 150, displayName: '补扣发', name: 'addGarnishee', headerCellClass: 'editable_cell_header'}
            {
                minWidth: 150,
                name:"notes"
                displayName:"说明"
                enableCellEdit: false
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a href="javascript:;" nb-popup-plus="nb-popup-plus" position="left-bottom" offset="0.5" style="color: rgba(0,0,0,0.87);">
                        {{row.entity.notes || '无'}}
                        <popup-template
                            style="padding:8px;border:1px solid #ccc;"
                            class="nb-popup org-default-popup-template">
                            <div class="panel-body popup-body">
                                <div class="salary-explain">
                                    {{row.entity.notes || '无'}}
                                </div>
                            </div>
                        </popup-template>
                    </a>
                </div>
                '''
                cellTooltip: (row) ->
                    return row.entity.notes
            }
            {
                minWidth: 150,
                name:"remark"
                displayName:"备注"
                headerCellClass: 'editable_cell_header'
                enableCellEdit: false
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a href="javascript:;" nb-popup-plus="nb-popup-plus" position="left-bottom" offset="0.5">
                        {{row.entity.remark || '请输入备注'}}
                        <popup-template
                            style="padding:8px;border:1px solid #ccc;"
                            class="nb-popup org-default-popup-template">
                            <div class="panel-body popup-body">
                                <md-input-container>
                                    <label>备注</label>
                                    <textarea
                                        ng-blur="row.entity.$save()"
                                        ng-model="row.entity.remark"
                                        style="resize:none;"
                                        class="reason-input"></textarea>
                                </md-input-container>
                            </div>
                        </popup-template>
                    </a>
                </div>
                '''
                cellTooltip: (row) ->
                    return row.entity.note
            }
        ]).concat(CALC_STEP_COLUMN)

    # 由confirm控制是否执行 强制计算
    exeConfirmCalc: (isConfirm, options = null) ->
        if isConfirm
            @startLoading()
            @calcing = true
            self = @

            args = {month: @currentCalcTime()}
            angular.extend(args, options) if angular.isDefined(options)

            @Model.compute(args).$asPromise().then (data)->
                self.cancelLoading()
                self.calcing = false
                erorr_msg = data.$response.data.messages
                # _.snakeCase('Foo Bar')
                # @Model => String???
                self.Evt.$send("salary_model:calc:error", erorr_msg) if erorr_msg
                self.loadRecords()
            , ()->
                self.cancelLoading()
                self.calcing = false


    upload_performance: (type, attachment_id)->
        self = @
        params = {type: type, attachment_id: attachment_id}

        @http.post("/api/performance_salaries/import", params).success (data, status) ->
            if data.error_count > 0
                self.toaster.pop('error', '提示', '有' + data.error_count + '个导入失败')
            else
                self.toaster.pop('success', '提示', '导入成功')

    getDateOptions: (type)->
        date = new Date()
        year = date.getFullYear()
        month = date.getMonth()

        return [year-1, year] if type == "year"

        formatOption = (year, month)->
            temp = []
            temp.push("#{year}-#{item}") for item in [1..month]
            return temp
        dateOptions = [].concat formatOption(year-1, 12), formatOption(year, month+1)

    uploadPerformance: (request, params)->
        self = @

        # 年度的时候 assessTime 是整数
        request.assess_time = moment(new Date(new String(request.assessTime))).format "YYYY-MM-DD"
        params.status = "uploading"

        @http.post("/api/performance_salaries/import", request)
            .success (response)->
                self.scope.resRecord = response.warnings
                params.status = "finish"
            .error (response)->
                self.scope.resRecord = response.messages
                params.status = "error"


# 小时费
class SalaryHoursFeeController extends SalaryBaseController
    @.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'HoursFee', 'toaster', '$rootScope']

    constructor: (@http, $scope, $q, @Evt, @Employee, @HoursFee, @toaster, @rootScope) ->
        @hours_fee_category = '飞行员'
        super(@HoursFee, $scope, $q, false, {hours_fee_category: @hours_fee_category}, @rootScope)

        @filterOptions = angular.copy(SALARY_FILTER_DEFAULT)

        @columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
            {minWidth: 150,displayName: '飞行时间', name: 'flyHours', enableCellEdit: false}
            {minWidth: 150,displayName: '小时费', name: 'flyFee', enableCellEdit: false}
            {minWidth: 150,displayName: '空勤灶', name: 'airlineFee', enableCellEdit: false}
            {minWidth: 150,displayName: '生育津贴', name: 'fertilityAllowance', enableCellEdit: false}
            # {minWidth: 150,displayName: '地面兼职补贴', name: 'groundSubsidy', enableCellEdit: false}
            {minWidth: 150,displayName: '补扣发', name: 'addGarnishee', headerCellClass: 'editable_cell_header'}
            {
                minWidth: 150,
                name:"notes"
                displayName:"说明"
                enableCellEdit: false
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a href="javascript:;" nb-popup-plus="nb-popup-plus" position="left-bottom" offset="0.5" style="color: rgba(0,0,0,0.87);">
                        {{row.entity.notes || '无'}}
                        <popup-template
                            style="padding:8px;border:1px solid #ccc;"
                            class="nb-popup org-default-popup-template">
                            <div class="panel-body popup-body">
                                <div class="salary-explain">
                                    {{row.entity.notes || '无'}}
                                </div>
                            </div>
                        </popup-template>
                    </a>
                </div>
                '''
                cellTooltip: (row) ->
                    return row.entity.notes
            }
            {
                minWidth: 150,
                name:"remark"
                displayName:"备注"
                headerCellClass: 'editable_cell_header'
                enableCellEdit: false
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a href="javascript:;" nb-popup-plus="nb-popup-plus" position="left-bottom" offset="0.5">
                        {{row.entity.remark || '请输入备注'}}
                        <popup-template
                            style="padding:8px;border:1px solid #ccc;"
                            class="nb-popup org-default-popup-template">
                            <div class="panel-body popup-body">
                                <md-input-container>
                                    <label>备注</label>
                                    <textarea
                                        ng-blur="row.entity.$save()"
                                        ng-model="row.entity.remark"
                                        style="resize:none;"
                                        class="reason-input"></textarea>
                                </md-input-container>
                            </div>
                        </popup-template>
                    </a>
                </div>
                '''
                cellTooltip: (row) ->
                    return row.entity.note
            }
        ]).concat(CALC_STEP_COLUMN)

    search: (tableState) ->
        tableState = tableState || {}
        tableState['hours_fee_category'] = @hours_fee_category
        tableState['month'] = @currentCalcTime()
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        @records.$refresh(tableState)

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

                self.toaster.pop('error', '提示', '有' + data.error_count + '个导入失败')
            else
                self.toaster.pop('success', '提示', '导入成功')


class SalaryAllowanceController extends SalaryBaseController
    @.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'Allowance', 'toaster', '$rootScope']

    constructor: (@http, $scope, $q, @Evt, @Employee, @Allowance, @toaster, @rootScope) ->
        super(@Allowance, $scope, $q, false, null, @rootScope)

        @filterOptions = angular.copy(SALARY_FILTER_DEFAULT)

        @columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
            {minWidth: 150, displayName: '安检津贴', name: 'securityCheck', enableCellEdit: false}
            {minWidth: 150,displayName: '安置津贴', name: 'resettlement', enableCellEdit: false}
            {minWidth: 150,displayName: '班组长津贴', name: 'groupLeader', enableCellEdit: false}
            {minWidth: 150,displayName: '航站管理津贴', name: 'airStationManage', enableCellEdit: false}
            {minWidth: 150,displayName: '车勤补贴', name: 'carPresent', enableCellEdit: false}
            {minWidth: 150,displayName: '地勤补贴', name: 'landPresent', enableCellEdit: false}
            {minWidth: 150,displayName: '机务放行补贴', name: 'permitEntry', enableCellEdit: false}
            {minWidth: 150,displayName: '试车津贴', name: 'tryDrive', enableCellEdit: false}
            {minWidth: 150,displayName: '飞行驾驶技术津贴', name: 'flyerScienceMoney', enableCellEdit: false}
            {minWidth: 150,displayName: '飞行安全荣誉津贴', name: 'flyHonor', enableCellEdit: false}
            {minWidth: 150,displayName: '航线实习补贴', name: 'airlinePractice', enableCellEdit: false}
            {minWidth: 150,displayName: '随机补贴', name: 'followPlane', enableCellEdit: false}
            {minWidth: 150,displayName: '签派放行补贴', name: 'permitSign', enableCellEdit: false}
            {minWidth: 150,displayName: '梭班补贴', name: 'workOvertime', enableCellEdit: false}
            {minWidth: 150,displayName: '高温补贴', name: 'temp', enableCellEdit: false}
            {minWidth: 150,displayName: '寒冷补贴', name: 'cold', enableCellEdit: false}
            {minWidth: 150,displayName: '通讯补贴', name: 'communication', enableCellEdit: false}
            {minWidth: 150,displayName: '后援补贴', name: 'backupSubsidy', enableCellEdit: false}
            {minWidth: 150,displayName: '年审补贴', name: 'annualAuditSubsidy', enableCellEdit: false}
            {minWidth: 150,displayName: '维修补贴', name: 'maintainSubsidy', enableCellEdit: false}
            {minWidth: 150,displayName: '后勤保障部补贴', name: 'logisticalSupportSubsidy', enableCellEdit: false}
            {minWidth: 150,displayName: '值班工资', name: 'watchSubsidy', enableCellEdit: false}
            {minWidth: 150,displayName: '重庆兼职车辆维修班补贴', name: 'cqPartTimeFixCarSubsidy', enableCellEdit: false}
            {minWidth: 150,displayName: '部件放行补贴', name: 'partPermitEntry', enableCellEdit: false}
            {minWidth: 150,displayName: '补扣发', name: 'addGarnishee', headerCellClass: 'editable_cell_header'}
            {
                minWidth: 150
                name:"notes"
                displayName:"说明"
                enableCellEdit: false
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a href="javascript:;" nb-popup-plus="nb-popup-plus" position="left-bottom" offset="0.5" style="color: rgba(0,0,0,0.87);">
                        {{row.entity.notes || '无'}}
                        <popup-template
                            style="padding:8px;border:1px solid #ccc;"
                            class="nb-popup org-default-popup-template">
                            <div class="panel-body popup-body">
                                <div class="salary-explain">
                                    {{row.entity.notes || '无'}}
                                </div>
                            </div>
                        </popup-template>
                    </a>
                </div>
                '''
                cellTooltip: (row) ->
                    return row.entity.notes
            }
            {
                minWidth: 150,
                name:"remark"
                displayName:"备注"
                headerCellClass: 'editable_cell_header'
                enableCellEdit: false
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a href="javascript:;" nb-popup-plus="nb-popup-plus" position="left-bottom" offset="0.5">
                        {{row.entity.remark || '请输入备注'}}
                        <popup-template
                            style="padding:8px;border:1px solid #ccc;"
                            class="nb-popup org-default-popup-template">
                            <div class="panel-body popup-body">
                                <md-input-container>
                                    <label>备注</label>
                                    <textarea
                                        ng-blur="row.entity.$save()"
                                        ng-model="row.entity.remark"
                                        style="resize:none;"
                                        class="reason-input"></textarea>
                                </md-input-container>
                            </div>
                        </popup-template>
                    </a>
                </div>
                '''
                cellTooltip: (row) ->
                    return row.entity.note
            }
        ]).concat(CALC_STEP_COLUMN)

    upload_allowance: (type, attachment_id)->
        self = @
        params = {type: type, attachment_id: attachment_id, month: @currentCalcTime()}

        @http.post("/api/allowances/import", params).success (data, status) ->
            if data.error_count > 0
                self.toaster.pop('error', '提示', '有' + data.error_count + '个导入失败')
            else
                self.toaster.pop('success', '提示', '导入成功')


class SalaryLandAllowanceController extends SalaryBaseController
    @.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'LandAllowance', 'toaster', '$rootScope']

    constructor: (@http, $scope, $q, @Evt, @Employee, @LandAllowance, @toaster, @rootScope) ->
        super(@LandAllowance, $scope, $q, false, null, @rootScope)

        @filterOptions = angular.copy(SALARY_FILTER_DEFAULT)

        @columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
            {minWidth: 150, displayName: '津贴', name: 'subsidy', enableCellEdit: false}
            {minWidth: 150, displayName: '补扣发', name: 'addGarnishee', headerCellClass: 'editable_cell_header'}
            {
                minWidth: 150,
                name:"notes"
                displayName:"说明"
                enableCellEdit: false
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a href="javascript:;" nb-popup-plus="nb-popup-plus" position="left-bottom" offset="0.5" style="color: rgba(0,0,0,0.87);">
                        {{row.entity.notes || '无'}}
                        <popup-template
                            style="padding:8px;border:1px solid #ccc;"
                            class="nb-popup org-default-popup-template">
                            <div class="panel-body popup-body">
                                <div class="salary-explain">
                                    {{row.entity.notes || '无'}}
                                </div>
                            </div>
                        </popup-template>
                    </a>
                </div>
                '''
                cellTooltip: (row) ->
                    return row.entity.notes
            }
            {
                minWidth: 150,
                name:"remark"
                displayName:"备注"
                headerCellClass: 'editable_cell_header'
                enableCellEdit: false
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a href="javascript:;" nb-popup-plus="nb-popup-plus" position="left-bottom" offset="0.5">
                        {{row.entity.remark || '请输入备注'}}
                        <popup-template
                            style="padding:8px;border:1px solid #ccc;"
                            class="nb-popup org-default-popup-template">
                            <div class="panel-body popup-body">
                                <md-input-container>
                                    <label>备注</label>
                                    <textarea
                                        ng-blur="row.entity.$save()"
                                        ng-model="row.entity.remark"
                                        style="resize:none;"
                                        class="reason-input"></textarea>
                                </md-input-container>
                            </div>
                        </popup-template>
                    </a>
                </div>
                '''
                cellTooltip: (row) ->
                    return row.entity.note
            }
        ]).concat(CALC_STEP_COLUMN)

    upload_land_allowance: (type, attachment_id)->
        self = @
        params = {type: type, attachment_id: attachment_id, month: @currentCalcTime()}

        @http.post("/api/land_allowances/import", params).success (data, status) ->
            if data.error_count > 0
                self.toaster.pop('error', '提示', '有' + data.error_count + '个导入失败')
            else
                self.toaster.pop('success', '提示', '导入成功')


class SalaryRewardController extends SalaryBaseController
    @.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'Reward', 'toaster', '$rootScope']

    constructor: (@http, $scope, $q, @Evt, @Employee, @Reward, @toaster, @rootScope) ->
        super(@Reward, $scope, $q, true, null, @rootScope)

        @filterOptions = angular.copy(SALARY_FILTER_DEFAULT)

        @columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
            {minWidth: 150,displayName: '航班正常奖', name: 'flightBonus', enableCellEdit: false}
            {minWidth: 150,displayName: '服务质量奖', name: 'serviceBonus', enableCellEdit: false}
            {minWidth: 150,displayName: '航空安全奖', name: 'airlineSecurityBonus', enableCellEdit: false}
            {minWidth: 150,displayName: '社会治安综合治理奖', name: 'compositeBonus', enableCellEdit: false}
            {minWidth: 150,displayName: '电子航意险代理提成奖', name: 'insuranceProxy', enableCellEdit: false}
            {minWidth: 150,displayName: '客舱升舱提成奖', name: 'cabinGrowUp', enableCellEdit: false}
            {minWidth: 150,displayName: '全员促销奖', name: 'fullSalePromotion', enableCellEdit: false}
            {minWidth: 150,displayName: '四川航空报稿费', name: 'articleFee', enableCellEdit: false}
            {minWidth: 150,displayName: '无差错飞行中队奖', name: 'allRightFly', enableCellEdit: false}
            {minWidth: 150,displayName: '年度综治奖', name: 'yearCompositeBonus', enableCellEdit: false}
            {minWidth: 150,displayName: '运兵先进奖', name: 'movePerfect', enableCellEdit: false}
            {minWidth: 150,displayName: '航空安全特殊贡献奖', name: 'securitySpecial', enableCellEdit: false}
            {minWidth: 150,displayName: '部门安全管理目标承包奖', name: 'depSecurityUndertake', enableCellEdit: false}
            {minWidth: 150,displayName: '飞行安全星级奖', name: 'flyStar', enableCellEdit: false}
            {minWidth: 150,displayName: '年度无差错机务维修中队奖', name: 'yearAllRightFly', enableCellEdit: false}
            {minWidth: 150,displayName: '网络联程奖', name: 'networkConnect', enableCellEdit: false}
            {minWidth: 150,displayName: '季度奖', name: 'quarterFee', enableCellEdit: false}
            {minWidth: 150,displayName: '收益奖励金', name: 'earningsFee', enableCellEdit: false}
            {minWidth: 150,displayName: '预算外奖励', name: 'offBudgetFee', enableCellEdit: false}
            {minWidth: 150,displayName: '节油奖', name: 'saveOilFee', enableCellEdit: false}
            {minWidth: 150,displayName: '补扣发', name: 'addGarnishee', headerCellClass: 'editable_cell_header'}
            {
                minWidth: 150
                name:"remark"
                displayName:"备注"
                headerCellClass: 'editable_cell_header'
                enableCellEdit: false
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a href="javascript:;" nb-popup-plus="nb-popup-plus" position="left-bottom" offset="0.5">
                        {{row.entity.remark || '请输入备注'}}
                        <popup-template
                            style="padding:8px;border:1px solid #ccc;"
                            class="nb-popup org-default-popup-template">
                            <div class="panel-body popup-body">
                                <md-input-container>
                                    <label>备注</label>
                                    <textarea
                                        ng-blur="row.entity.$save()"
                                        ng-model="row.entity.remark"
                                        style="resize:none;"
                                        class="reason-input"></textarea>
                                </md-input-container>
                            </div>
                        </popup-template>
                    </a>
                </div>
                '''
                cellTooltip: (row) ->
                    return row.entity.note
            }
        ]).concat(CALC_STEP_COLUMN)

    upload_reward: (type, attachment_id)->
        self = @
        params = {type: type, attachment_id: attachment_id, month: @currentCalcTime()}

        @http.post("/api/rewards/import", params).success (data, status) ->

            if data.error_count > 0
                self.toaster.pop('error', '提示', '有' + data.error_count + '个导入失败')
            else
                if data.messages.indexOf("但是") >= 0
                    self.toaster.pop('warning', '提示', data.messages || '导入成功')
                else
                    self.toaster.pop('success', '提示', data.messages || '导入成功')


class SalaryTransportFeeController extends SalaryBaseController
    @.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'TransportFee', 'toaster', '$rootScope']

    constructor: (@http, $scope, $q, @Evt, @Employee, @TransportFee, @toaster, @rootScope) ->
        super(@TransportFee, $scope, $q, true, null, @rootScope)

        @filterOptions = angular.copy(SALARY_FILTER_DEFAULT)

        @columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
            {minWidth: 150, displayName: '交通费', name: 'amount', enableCellEdit: false}
            {minWidth: 150, displayName: '班车费扣除', name: 'busFee', enableCellEdit: false}
            {minWidth: 150, displayName: '补扣发', name: 'addGarnishee', headerCellClass: 'editable_cell_header'}
            {
                minWidth: 150
                name:"notes"
                displayName:"说明"
                enableCellEdit: false
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a href="javascript:;" nb-popup-plus="nb-popup-plus" position="left-bottom" offset="0.5" style="color: rgba(0,0,0,0.87);">
                        {{row.entity.notes || '无'}}
                        <popup-template
                            style="padding:8px;border:1px solid #ccc;"
                            class="nb-popup org-default-popup-template">
                            <div class="panel-body popup-body">
                                <div class="salary-explain">
                                    {{row.entity.notes || '无'}}
                                </div>
                            </div>
                        </popup-template>
                    </a>
                </div>
                '''
                cellTooltip: (row) ->
                    return row.entity.notes
            }
            {
                minWidth: 150
                name:"remark"
                displayName:"备注"
                headerCellClass: 'editable_cell_header'
                enableCellEdit: false
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a href="javascript:;" nb-popup-plus="nb-popup-plus" position="left-bottom" offset="0.5">
                        {{row.entity.remark || '请输入备注'}}
                        <popup-template
                            style="padding:8px;border:1px solid #ccc;"
                            class="nb-popup org-default-popup-template">
                            <div class="panel-body popup-body">
                                <md-input-container>
                                    <label>备注</label>
                                    <textarea
                                        ng-blur="row.entity.$save()"
                                        ng-model="row.entity.remark"
                                        style="resize:none;"
                                        class="reason-input"></textarea>
                                </md-input-container>
                            </div>
                        </popup-template>
                    </a>
                </div>
                '''
                cellTooltip: (row) ->
                    return row.entity.note
            }
        ]).concat(CALC_STEP_COLUMN)

    upload_bus_fee: (type, attachment_id)->
        self = @
        params = {type: type, attachment_id: attachment_id}

        @http.post("/api/transport_fees/import", params)
            .success (data, status) ->
                if data.error_count > 0
                    self.toaster.pop('error', '提示', '有' + data.error_count + '个导入失败。'+ '员工编号:' + data.error_names)
                else
                    self.toaster.pop('success', '提示', '导入成功')


class SalaryOverviewController extends SalaryBaseController
    @.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'SalaryOverview', 'toaster', '$rootScope']

    constructor: ($http, $scope, $q, @Evt, @Employee, @SalaryOverview, @toaster, @rootScope) ->
        super(@SalaryOverview, $scope, $http, true, null, @rootScope)

        @filterOptions = angular.copy(SALARY_FILTER_DEFAULT)

        @filterOptions.constraintDefs.pop()

        @columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
            {minWidth: 100, displayName: '基础工资', name: 'basic', enableCellEdit: false}
            {minWidth: 100, displayName: '保留工资', name: 'keep', enableCellEdit: false}
            {minWidth: 100, displayName: '绩效工资', name: 'performance', enableCellEdit: false}
            {minWidth: 100, displayName: '小时费', name: 'hoursFee', enableCellEdit: false}
            {minWidth: 100, displayName: '津贴', name: 'subsidy', enableCellEdit: false}
            {minWidth: 100, displayName: '驻站津贴', name: 'landSubsidy', enableCellEdit: false}
            {minWidth: 100, displayName: '奖励', name: 'reward', enableCellEdit: false}
            {minWidth: 100, displayName: '交通费', name: 'transportFee', enableCellEdit: false}
            {minWidth: 150, displayName: '生育保险冲抵', name: 'birth', enableCellEdit: false}
            {minWidth: 100, displayName: '合计', name: 'total', enableCellEdit: false}
            {
                minWidth: 100
                name:"remark"
                displayName:"备注"
                headerCellClass: 'editable_cell_header'
                enableCellEdit: false
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a href="javascript:;" nb-popup-plus="nb-popup-plus" position="left-bottom" offset="0.5">
                        {{row.entity.remark || '请输入备注'}}
                        <popup-template
                            style="padding:8px;border:1px solid #ccc;"
                            class="nb-popup org-default-popup-template">
                            <div class="panel-body popup-body">
                                <md-input-container>
                                    <label>备注</label>
                                    <textarea
                                        ng-blur="row.entity.$save()"
                                        ng-model="row.entity.remark"
                                        style="resize:none;"
                                        class="reason-input"></textarea>
                                </md-input-container>
                            </div>
                        </popup-template>
                    </a>
                </div>
                '''
                cellTooltip: (row) ->
                    return row.entity.note
            }
        ]).concat(CALC_STEP_COLUMN)

class BirthSalaryController extends SalaryBaseController
    @.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'BirthSalary', 'toaster', '$rootScope']

    constructor: ($http, $scope, $q, @Evt, @Employee, @BirthSalary, @toaster, @rootScope) ->
        super(@BirthSalary, $scope, $q, true, null, @rootScope)

        @filterOptions = angular.copy(SALARY_FILTER_DEFAULT)

        @columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
            {minWidth: 100, displayName: '基本工资', name: 'basicSalary', enableCellEdit: false}
            {minWidth: 100, displayName: '川航工龄工资', name: 'workingYearsSalary', enableCellEdit: false}
            {minWidth: 100, displayName: '保留工资', name: 'keepSalary', enableCellEdit: false}
            {minWidth: 100, displayName: '绩效薪酬', name: 'performanceSalary', enableCellEdit: false}
            {minWidth: 100, displayName: '小时费', name: 'hoursFee', enableCellEdit: false}
            {minWidth: 120, displayName: '收支目标考核奖', name: 'budgetReward', enableCellEdit: false}
            {minWidth: 100, displayName: '交通费', name: 'transportFee', enableCellEdit: false}
            {minWidth: 100, displayName: '高温津贴', name: 'tempAllowance', enableCellEdit: false}
            {minWidth: 120, displayName: '剩余抵扣金额', name: 'residueMoney', enableCellEdit: false}
            {minWidth: 120, displayName: '生育保险冲抵', name: 'birthResidueMoney', enableCellEdit: false}
            {minWidth: 120, displayName: '当期抵扣后剩余', name: 'afterResidueMoney', enableCellEdit: false}
            {
                minWidth: 100
                name:"notes"
                displayName:"说明"
                enableCellEdit: false
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a href="javascript:;" nb-popup-plus="nb-popup-plus" position="left-bottom" offset="0.5" style="color: rgba(0,0,0,0.87);">
                        {{row.entity.notes || '无'}}
                        <popup-template
                            style="padding:8px;border:1px solid #ccc;"
                            class="nb-popup org-default-popup-template">
                            <div class="panel-body popup-body">
                                <div class="salary-explain">
                                    {{row.entity.notes || '无'}}
                                </div>
                            </div>
                        </popup-template>
                    </a>
                </div>
                '''
                cellTooltip: (row) ->
                    return row.entity.notes
            }
            {
                minWidth: 150
                name:"remark"
                displayName:"备注"
                headerCellClass: 'editable_cell_header'
                enableCellEdit: false
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a href="javascript:;" nb-popup-plus="nb-popup-plus" position="left-bottom" offset="0.5">
                        {{row.entity.remark || '请输入备注'}}
                        <popup-template
                            style="padding:8px;border:1px solid #ccc;"
                            class="nb-popup org-default-popup-template">
                            <div class="panel-body popup-body">
                                <md-input-container>
                                    <label>备注</label>
                                    <textarea
                                        ng-blur="row.entity.$save()"
                                        ng-model="row.entity.remark"
                                        style="resize:none;"
                                        class="reason-input"></textarea>
                                </md-input-container>
                            </div>
                        </popup-template>
                    </a>
                </div>
                '''
                cellTooltip: (row) ->
                    return row.entity.note
            }
        ]).concat(CALC_STEP_COLUMN)


class CalcStepsController
    @.$inject = ['$http', '$scope']

    constructor: (@http, $scope)->
        #

    loadFromServer: (category, month, employee_id)->
        self = @

        @http.get('/api/calc_steps/search?category=' + category + "&month=" + month + "&employee_id=" + employee_id).success (data)->
            self.error_msg = data.messages

            if (!self.error_msg)
                self.step_notes = data.calc_step.step_notes
                self.amount = data.calc_step.amount

class RewardsAllocationController
    @.$inject = ['$http', '$scope', 'toaster']

    constructor: (@http, @scope, @toaster)->
        @rewards = {}
        @rewardsCategory = 'flight_bonus'

    currentCalcTime: ()->
        @currentYear + "-" + @currentMonth

    loadRewardsAllocation: () ->
        self = @

        month = @currentCalcTime()
        @http.get('/api/departments/rewards?month=' + month).success (data)->
            self.rewards = data.rewards

    saveReward: (departmentId, bonus) ->
        self = @

        param = { month: month = @currentCalcTime(), department_id: departmentId}
        param[@rewardsCategory] = bonus

        @http.put('/api/departments/reward_update', param).success (data)->
            self.toaster.pop('success', '提示', '修改成功')


app.controller 'salaryCtrl', SalaryController
app.controller 'depNumSettingCtrl', DepNumSettingController
app.controller 'salaryPersonalCtrl', SalaryPersonalController
app.controller 'salaryChangeCtrl', SalaryChangeController
app.controller 'salaryGradeChangeCtrl', SalaryGradeChangeController
app.controller 'salaryExchangeCtrl', SalaryExchangeController
app.controller 'salaryBasicCtrl', SalaryBasicController
app.controller 'salaryKeepCtrl', SalaryKeepController
app.controller 'salaryPerformanceCtrl', SalaryPerformanceController
app.controller 'salaryHoursFeeCtrl', SalaryHoursFeeController
app.controller 'salaryAllowanceCtrl', SalaryAllowanceController
app.controller 'salaryLandAllowanceCtrl', SalaryLandAllowanceController
app.controller 'salaryRewardCtrl', SalaryRewardController
app.controller 'salaryTransportFeeCtrl', SalaryTransportFeeController
app.controller 'salaryOverviewCtrl', SalaryOverviewController
app.controller 'birthSalaryCtrl', BirthSalaryController
app.controller 'calcStepCtrl', CalcStepsController
app.controller 'rewardsAllocationCtrl', RewardsAllocationController
