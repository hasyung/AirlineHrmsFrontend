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

    $default_coefficient: ()->
        company: 0.1
        business_council: 0.1
        logistics: 0.1

    $check_coefficient_default: ()->
        month = @currentCalcTime()
        if !angular.isDefined(@global_setting.coefficient[month])
            @global_setting.coefficient[month] = @$default_coefficient()

    initialize: () ->
        self = @
        @CATEGORY_LIST = ["leader_base",            # 干部
                          "manager15_base",         # 管理15
                          "manager12_base",         # 管理12
                          "flyer_base_leader",      # 机长
                          "flyer_base_copilot",     # 副驾
                          "flyer_base_teacher_A",   # 教员A
                          "flyer_base_teacher_B",   # 教员B
                          "flyer_base_teacher_C",   # 教员C
                          "flyer_base_student",     # 学员
                          "air_steward_base",       # 空乘空保
                          "service_b_base",         # 服务B
                          "air_observer_base",      # 空中观察员
                          "front_run_base",         # 前场运行
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
            self.$check_coefficient_default()

            angular.forEach self.CATEGORY_LIST, (item)->
                data[item] ||= {}
                self.settings[item + '_setting'] = data[item].form_data || {}

            self.selectedIndex = 0
            self.scope.$watch 'ctrl.selectedIndex', (to)->
                self.load_dynamic_config(self.CATEGORY_LIST[to])

    currentCalcTime: ()->
        @currentYear + "-" + @currentMonth

    load_global_coefficient: ()->
        @$check_coefficient_default()

    load_dynamic_config: (category)->
        @current_category = category
        @dynamic_config = @settings[category + '_setting']
        @editing = false

    save_config: (config)->
        self = @
        config = @settings[@current_category + '_setting'] if !config
        @editing = false

        @http.put('/api/salaries/' + @current_category, {form_data: config}).success (data)->
            error_msg = data.messages

            if error_msg
                self.toaster.pop('error', '提示', error_msg)
            else
                self.toaster.pop('success', '提示', '配置已更新')


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