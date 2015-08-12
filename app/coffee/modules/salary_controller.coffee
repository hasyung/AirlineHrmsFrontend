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

            .state 'salary_basic', {
                url: '/salary/basic'
                templateUrl: 'partials/salary/basic.html'
            }

            .state 'salary_performance', {
                url: '/salary/salary_performance'
                templateUrl: 'partials/salary/performance.html'
            }


app.config(Route)


class SalaryController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', 'toaster']

    constructor: (@http, @scope, $Evt, @toaster) ->
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
        @CATEGORY_LIST = ["leader_base",                # 干部
                          "manager15_base",             # 管理15
                          "manager12_base",             # 管理12
                          "flyer_legend_base",          # 荣誉级飞行员
                          "flyer_leader_base",          # 机长
                          "flyer_copilot_base",         # 副驾
                          "flyer_teacher_A_base",       # 教员A
                          "flyer_teacher_B_base",       # 教员B
                          "flyer_teacher_C_base",       # 教员C
                          "flyer_student_base",         # 学员
                          "air_steward_base",           # 空乘空保
                          "service_b_normal_cleaner_base",      # 服务B-清洁工
                          "service_b_parking_cleaner_base",     # 服务B-机坪清洁工
                          "service_b_hotel_service_base",       # 服务B-宾馆服务员
                          "service_b_green_base",               # 服务B-绿化
                          "service_b_front_desk_base",          # 服务B-总台服务员
                          "service_b_security_guard_base",      # 服务B-保安、空保装备保管员
                          "service_b_data_input_base",          # 服务B-数据录入
                          "service_b_guard_leader1_base",       # 服务B-保安队长（一类）
                          "service_b_device_keeper_base",       # 服务B-保管（库房、培训设备、器械）
                          "service_b_unloading_base",           # 服务B-外站装卸
                          "service_b_making_water_base",        # 服务B-制水工
                          "service_b_add_water_base",           # 服务B-加水工、排污工
                          "service_b_guard_leader2_base",       # 服务B-保安队长（二类）
                          "service_b_water_light_base",         # 服务B-水电维修
                          "service_b_car_repair_base",          # 服务B-汽修工
                          "service_b_airline_keeper_base",      # 服务B-机务工装设备/客舱供应库管
                          "service_c_base",                     # 服务C
                          "air_observer_base",                  # 空中观察员
                          "front_run_base",                     # 前场运行
                         ]

        @year_list = @$getYears()
        @month_list = @$getMonths()
        @currentYear = _.last @year_list
        @currentMonth = _.last @month_list

        # 所有的设置
        @settings = {}
        # 薪酬全局设置
        @global_setting = {}

        @http.get('/api/salaries').success (data)->
            # 全局设置单独处理
            self.global_setting = data.global.form_data
            self.$checkCoefficientDefault()
            self.basic_cardinality = parseInt(self.global_setting.basic_cardinality)

            angular.forEach self.CATEGORY_LIST, (item)->
                data[item] ||= {}
                self.settings[item + '_setting'] = data[item].form_data || {}

            self.loadDynamicConfig(self.CATEGORY_LIST[0])

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

    saveConfig: (config)->
        self = @
        config = @settings[@current_category + '_setting'] if !config

        @http.put('/api/salaries/' + @current_category, {form_data: config}).success (data)->
            error_msg = data.messages

            if error_msg
                self.toaster.pop('error', '提示', error_msg)
            else
                self.editing = false
                self.backup_config = angular.copy(self.dynamic_config)
                self.toaster.pop('success', '提示', '配置已更新')

    calcAmount: (rate)->
        parseInt(@basic_cardinality * parseFloat(rate))

    formatColumn: (input)->
        result = input

        if input && angular.isDefined(input['format_cell'])
            result = input['format_cell']
            result = result.replace('%{format_value}', input['format_value'])
            result = result.replace('%{work_value}', input['work_value'])
            result = result.replace('%{time_value}', input['time_value'])

        result


class SalaryPerformanceController
    @.$inject = ['$http', '$scope', '$nbEvent']

    constructor: ($http, $scope, $Evt) ->


class SalaryBasicController
    @.$inject = ['$http', '$scope', '$nbEvent']

    constructor: ($http, $scope, $Evt) ->

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


app.controller 'salaryCtrl', SalaryController
app.controller 'salaryPersonalCtrl', SalaryPersonalController
app.controller 'salaryBasicCtrl', SalaryBasicController
app.controller 'salaryPerformanceCtrl', SalaryPerformanceController