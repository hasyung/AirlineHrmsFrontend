# 福利
nb = @.nb
app = nb.app

class Route
    @.$inject = ['$stateProvider']

    constructor: (stateProvider) ->
        stateProvider
            .state 'welfares', {
                url: '/welfares'
                templateUrl: 'partials/welfares/settings.html'
            }

            .state 'welfares_socials', {
                url: '/welfares/socials'
                templateUrl: 'partials/welfares/socials.html'
            }

            .state 'welfares_annuities', {
                url: '/welfares/annuities'
                templateUrl: 'partials/welfares/annuities.html'
            }

            .state 'welfares_dinnerfee', {
                url: '/welfares/dinnerfee'
                templateUrl: 'partials/welfares/dinnerfee.html'
            }

            .state 'welfares_birth', {
                url: '/welfares/birth'
                templateUrl: 'partials/welfares/birth.html'
            }


app.config(Route)


class WelfareController
    @.$inject = ['$http', '$scope', '$nbEvent']

    constructor: ($http, $scope, $Evt) ->
        $scope.currentSettingLocation = null
        #当前配置项
        $scope.setting = null
        $scope.configurations = null
        $scope.locations = null

        $http.get('api/welfares/socials')
            .success (result) ->
                $scope.configurations = result.socials
                $scope.locations  = $scope.configurations.map (config) -> config.location
                $scope.currentSettingLocation = $scope.locations[0]

        $scope.$watch 'currentSettingLocation', (newValue) ->
            $scope.setting = _.find $scope.configurations, (config) -> config.location == newValue if newValue

        #保存社保配置信息
        $scope.saveConfig = (setting)->
            configs = $scope.configurations

            current_setting_index = _.findIndex configs, (config) ->
                config.location == $scope.currentSettingLocation

            angular.extend configs[current_setting_index], setting

            $http.put('/api/welfares/socials', {
                socials: configs
            }).success ()->
                $Evt.$send('wselfate:save:success', '社保配置保存成功')


class WelfarePersonalController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', 'Employee', 'SocialPersonSetup']

    constructor: ($http, $scope, $Evt, @Employee, @SocialPersonSetup) ->
        @configurations = @loadInitialData()

        @filterOptions = {
            name: 'welfarePersonal'
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
                    name: 'social_location'
                    type: 'string'
                    displayName: '社保属地'
                }
                {
                    name: 'social_account'
                    displayName: '社保编号'
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
            {displayName: '社保属地', name: 'socialLocation'}
            {displayName: '社保编号', name: 'socialAccount'}
            {displayName: '年度养老基数', name: 'pensionCardinality'}
            {displayName: '年度其他基数', name: 'otherCardinality'}
            {displayName: '养老', name: 'pension', cellTemplate: '<boolean-table-cell></boolean-table-cell>'}
            {displayName: '医疗', name: 'treatment', cellTemplate: '<boolean-table-cell></boolean-table-cell>'}
            {displayName: '失业', name: 'unemploy', cellTemplate: '<boolean-table-cell></boolean-table-cell>'}
            {displayName: '工伤', name: 'injury', cellTemplate: '<boolean-table-cell></boolean-table-cell>'}
            {displayName: '大病', name: 'illness', cellTemplate: '<boolean-table-cell></boolean-table-cell>'}
            {displayName: '生育', name: 'fertility', cellTemplate: '<boolean-table-cell></boolean-table-cell>'}
            {
                displayName: '编辑'
                field: 'name'
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a nb-dialog
                        template-url="partials/welfares/settings/welfare_personal_edit.html"
                        locals="{setups: row.entity}">
                        编辑
                    </a>
                </div>
                '''
            }
        ]

        @constraints = [

        ]

    loadInitialData: () ->
        @socialPersonSetups = @SocialPersonSetup.$collection().$fetch()

    search: (tableState) ->
        condition = {}

        angular.forEach tableState, (value, key)->
            condition[key] = value if value && angular.isDefined(value)
        condition['per_page'] = @gridApi.grid.options.paginationPageSize

        @socialPersonSetups.$refresh(condition)

    getSelectsIds: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk

    getSelected: () ->
        rows = @gridApi.selection.getSelectedGridRows()

    newPersonalSetup: (newSetup)->
        self = @
        newSetup = @socialPersonSetups.$build(newSetup)
        newSetup.$save().$then ()->
            self.socialPersonSetups.$refresh()

    delete: (isConfirm) ->
        if isConfirm
            @getSelected().forEach (record) -> record.entity.$destroy()

    loadEmployee: (params, contract)->
        self = @

        @Employee.$collection().$refresh(params).$then (employees)->
            args = _.mapKeys params, (value, key) ->
                _.camelCase key

            matched = _.find employees, args

            if matched
                self.loadEmp = matched
                contract.owner = matched
            else
                self.loadEmp = params


class SocialComputeController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', 'SocialRecord', 'toaster']

    constructor: (@http, $scope, @Evt, @SocialRecord, @toaster) ->
        @socialRecords = @loadInitialData()

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
            {displayName: '社保属地', name: 'socialLocation'}
            {displayName: '社保编号', name: 'socialAccount'}
            {displayName: '年度养老基数', name: 'pensionCardinality'}
            {displayName: '年度其他基数', name: 'otherCardinality'}
            {displayName: '个人合计', name: 'personageTotal'}
            {displayName: '单位合计', name: 'companyTotal'}
            {displayName: '总合计', name: 'total'}

        ]

        @constraints = [

        ]

    loadInitialData: ()->
        @upload_xls_id = 0
        @upload_result = ""

        @year_list = @$getYears()
        @month_list = @$getMonths()

        @currentYear = _.last(@year_list)
        @currentMonth = _.last(@month_list)

        @socialRecords = @SocialRecord.$collection().$fetch({month: @currentCalcTime()})

    search: (tableState)->
        @socialRecords.$refresh(tableState)

    currentCalcTime: ()->
        @currentYear + "-" + @currentMonth

    loadRecords: ()->
        @socialRecords.$refresh({month: @currentCalcTime()})

    # 强制计算
    exeCalc: ()->
        @calcing = true
        self = @

        @SocialRecord.compute({month: @currentCalcTime()}).$asPromise().then (data)->
            self.calcing = false
            erorr_msg = data.$response.data.messages
            self.Evt.$send("social:calc:error", erorr_msg) if erorr_msg
            self.loadRecords()

    upload_salary: (param)->
        self = @
        calc_month = param.year + '-' + param.month
        params = {attachment_id: @upload_xls_id, month: calc_month}

        @http.post("/api/social_records/import", params).success (data, status) ->
            if data.error_count > 0
                self.Evt.$send 'upload:salary_import:error', '月度' + calc_month + '薪酬数据有' + data.error_count + '条导入失败'
            else
                self.Evt.$send 'upload:salary_import:success', '月度' + calc_month + '薪酬数据导入成功'


class SocialHistoryController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', 'SocialRecord']

    constructor: ($http, $scope, $Evt, @SocialRecord) ->
        @configurations = @loadInitialData()

        @filterOptions = {
            name: 'welfarePersonal'
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
                    name: 'calc_month'
                    displayName: '缴费月度'
                    type: 'month-range'
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
            {displayName: '社保属地', name: 'socialLocation'}
            {displayName: '缴费月度', name: 'month'}
            {displayName: '社保编号', name: 'socialAccount'}
            {displayName: '年度养老基数', name: 'pensionCardinality'}
            {displayName: '年度其他基数', name: 'otherCardinality'}
            {displayName: '个人合计', name: 'personageTotal'}
            {displayName: '单位合计', name: 'companyTotal'}
            {displayName: '总合计', name: 'total'}

        ]

    loadInitialData: () ->
        @socialRecords = @SocialRecord.$collection().$fetch()

    search: (tableState) ->
        tableState = tableState || {}
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        @socialRecords.$refresh(tableState)

    getSelectsIds: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk


class SocialChangesController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', 'SocialChange']

    constructor: ($http, $scope, $Evt, @SocialChange) ->
        @configurations = @loadInitialData()

        @filterOptions = {
            name: 'welfarePersonal'
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
                <div class="ui-grid-cell-contents ng-binding ng-scope">
                    <a nb-panel
                        template-url="partials/personnel/info_basic.html"
                        locals="{employee: row.entity.owner}">
                        {{grid.getCellValue(row, col)}}
                    </a>
                </div>
                '''
            }
            {displayName: '所属部门', name: 'departmentName'}
            {displayName: '信息发生时间', name: 'changeDate'}
            {displayName: '信息种类', name: 'category'}
            {
                displayName: '处理'
                field: 'deal'
                cellTemplate: '''
                <div class="ui-grid-cell-contents ng-binding ng-scope">
                    <a nb-dialog
                       ng-hide="row.entity.is_processed()"
                        template-url="partials/welfares/socials/change_info.html"
                        locals="{changeInfo: row.entity}">
                        查看
                    </a>
                    <span ng-show="row.entity.is_processed()">
                        已处理
                    </span>
                </div>
                '''
            }
        ]

        @constraints = [

        ]

    loadInitialData: () ->
        @socialChanges = @SocialChange.$collection().$fetch()

    search: (tableState) ->
        tableState = tableState || {}
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        @socialChanges.$refresh(tableState)


class SocialChangeProcessController extends nb.EditableResourceCtrl
    @.$inject = ['$http', '$scope', '$enum', '$nbEvent', 'SocialPersonSetup']

    constructor: ($http, $scope, $enum, $Evt, @SocialPersonSetup) ->
        super($scope, $enum, $Evt)

        @find_or_build_setup = (change)->
            if change.socialSetup
                change.socialSetup.$fetch()
                return change.socialSetup

            change.socialSetup = @SocialPersonSetup.$build({
                socialAccount: '000000'
                # 默认处理成成都
                socialLocation: '成都'
                owner: change.owner
                # 使用change.owner.$pk有值，但是赋值无效
                # employeeId: change.owner.$pk
            })

            change.socialSetup


class AnnuityPersonalController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', 'AnnuitySetup', '$q', '$state']

    constructor: (@http, @scope, @Evt, @AnnuitySetup, @q, @state) ->
        @annuities = @loadInitialData()

        @filterOptions = {
            name: 'annuities'
            constraintDefs: [
                {
                    name: 'name'
                    displayName: '姓名'
                    type: 'string'
                }
                {
                    name: 'employee_no'
                    displayName: '员工编号'
                    type: 'string'
                }
                {
                    name: 'annuity_status'
                    displayName: '缴费状态'
                    type: 'annuity_status_select'
                    params: {
                        type: 'annuity_status'
                    }
                }
            ]
        }

        @columnDef = [
            {
                displayName: '员工编号'
                name: 'employeeNo'
                enableCellEdit: false
            }
            {
                displayName: '姓名'
                field: 'name'
                enableCellEdit: false
                cellTemplate: '''
                <div class="ui-grid-cell-contents ng-binding ng-scope">
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
                name: 'department.name'
                enableCellEdit: false
                cellTooltip: (row) ->
                    return row.entity.department.name
            }
            {
                displayName: '身份证号'
                name: 'identityNo'
                enableCellEdit: false
            }
            {
                displayName: '手机号'
                name: 'mobile'
                enableCellEdit: false
            }
            {
                displayName: '本年基数'
                name: 'annuityCardinality'
                headerCellClass: 'editable_cell_header'
                enableCellEdit: true
                type: 'number'
            }
            {
                displayName: '缴费状态'
                name: 'annuityStatus'
                editableCellTemplate: 'ui-grid/dropdownEditor'
                headerCellClass: 'editable_cell_header'
                editDropdownValueLabel: 'value'
                editDropdownIdLabel: 'key'
                editDropdownOptionsArray: [
                    {key: '在缴', value: '在缴'}
                    {key: '退出', value: '退出'}
                ]
            }
        ]

        @constraints = [

        ]

    initialize: (gridApi) ->
        self = @

        saveRow = (rowEntity) ->
            dfd = @q.defer()

            gridApi.rowEdit.setSavePromise(rowEntity, dfd.promise)

            @http({
                method: 'PUT'
                url: '/api/annuities/' + rowEntity.id
                data: {
                    id: rowEntity.id
                    annuity_status: rowEntity.annuityStatus
                    annuity_cardinality: rowEntity.annuityCardinality
                }
            })
            .success (data) ->
                dfd.resolve()
                self.Evt.$send('annuity_status:update:success', data.messages)
            .error () ->
                dfd.reject()
                rowEntity.$restore()

        # edit.on.afterCellEdit($scope,function(rowEntity, colDef, newValue, oldValue)
        # gridApi.edit.on.afterCellEdit @scope, (rowEntity, colDef, newValue, oldValue) ->

        gridApi.rowEdit.on.saveRow(@scope, saveRow.bind(@))
        @scope.$gridApi = gridApi

    loadInitialData: () ->
        @start_compute_basic = false
        @annuities = @AnnuitySetup.$collection().$fetch()

    search: (tableState) ->
        @tableState = tableState
        tableState = tableState || {}
        tableState['per_page'] = @scope.$gridApi.grid.options.paginationPageSize
        @annuities.$refresh(tableState)

    getSelectsIds: () ->
        rows = @scope.$gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk

    getSelected: () ->
        rows = @scope.$gridApi.selection.getSelectedGridRows()
        @selected = if rows.length >= 1 then rows[0].entity else null

    loadBasicComputeRecords: (employee_id)->
        self = @

        @http({
            method: 'GET'
            url: '/api/annuities/show_cardinality?employee_id=' +  employee_id
        })
        .success (data) ->
            json_data = angular.fromJson(data)
            self.basicComputeRecords = json_data.social_records
            self.averageCompute = json_data.meta.annuity_cardinality

    computeBasicRecords: ()->
        @start_compute_basic = true
        self = @

        @http({
            method: 'GET'
            url: '/api/annuities/cal_year_annuity_cardinality'
        })
        .success (data) ->
            self.start_compute_basic = false
            self.Evt.$send('year_annuity_cardinality:compute:success', data.messages || "计算结束")
            self.loadRecords()
        .error (data)->
            self.loadRecords()

    loadRecords: ()->
        # 保存搜索状态
        @annuities.$refresh(@tableState || {})


class AnnuityComputeController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', 'AnnuityRecord', 'toaster']

    constructor: ($http, $scope, @Evt, @AnnuityRecord, @toaster) ->
        @annuityRecords = @loadInitialData()

        @columnDef = [
            {displayName: '员工编号', name: 'employeeNo'}
            {
                displayName: '姓名'
                field: 'employeeName'
                cellTemplate: '''
                <div class="ui-grid-cell-contents ng-binding ng-scope">
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
            {displayName: '身份证号', name: 'identityNo'}
            {displayName: '手机号', name: 'mobile'}
            {displayName: '本年基数', name: 'annuityCardinality'}
            {displayName: '个人缴费', name: 'personalPayment'}
            {displayName: '公司缴费', name: 'companyPayment'}
            {
                displayName: '备注'
                name: 'note'
                cellTooltip: (row) ->
                    return row.entity.note
            }
        ]

        @constraints = [

        ]

    loadInitialData: () ->
        @year_list = @$getYears()
        @month_list = @$getMonths()

        @currentYear = _.last(@year_list)
        @currentMonth = _.last(@month_list)

        @annuityRecords = @AnnuityRecord.$collection().$fetch({date: @currentCalcTime()})

    search: (tableState) ->
        tableState = tableState || {}
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        @annuityRecords.$refresh(tableState)

    currentCalcTime: ()->
        @currentYear + "-" + @currentMonth

    loadRecords: ()->
        @annuityRecords.$refresh({date: @currentCalcTime()})

    exeCalc: ()->
        @calcing = true
        self = @

        @AnnuityRecord.compute({date: @currentCalcTime()}).$asPromise().then (data)->
            self.calcing = false
            erorr_msg = data.$response.data.messages
            self.Evt.$send("annuity:calc:error", erorr_msg) if erorr_msg
            self.loadRecords()


class AnnuityHistoryController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', 'AnnuityRecord']

    constructor: ($http, $scope, $Evt, @AnnuityRecord) ->
        @configurations = @loadInitialData()

        @filterOptions = {
            name: 'welfarePersonal'
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
                    name: 'month'
                    displayName: '缴费月度'
                    type: 'month-range'
                }
            ]
        }

        @columnDef = [
            {displayName: '员工编号', name: 'employeeNo'}
            {
                displayName: '姓名'
                field: 'employeeName'
                cellTemplate: '''
                <div class="ui-grid-cell-contents ng-binding ng-scope">
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
            {displayName: '缴费月度', name: 'calDate'}
            {displayName: '当期基数', name: 'annuityCardinality'}
            {displayName: '个人缴费', name: 'personalPayment'}
            {displayName: '公司缴费', name: 'companyPayment'}
            {displayName: '备注', name: 'note', cellTooltip: (row) -> return row.entity.note}
        ]

        @constraints = [

        ]

    loadInitialData: () ->
        @annuityRecords = @AnnuityRecord.$collection().$fetch()

    search: (tableState) ->
        tableState = tableState || {}
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        @annuityRecords.$refresh(tableState)


class AnnuityChangesController
    @.$inject = ['$http', '$scope', '$nbEvent', 'AnnuityChange', '$q']

    constructor: (@http, @scope, @Evt, @AnnuityChange, @q) ->
        @annuityChanges = @loadInitialData()

        @filterOptions = {
            name: 'annuityChanges'
            constraintDefs: [
                {
                    name: 'employee_name'
                    displayName: '姓名'
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
            {
                displayName: '员工编号'
                name: 'employeeNo'
                enableCellEdit: false
            }
            {
                displayName: '姓名'
                field: 'employeeName'
                enableCellEdit: false
                cellTemplate: '''
                <div class="ui-grid-cell-contents ng-binding ng-scope">
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
                displayName: '信息发生时间',
                name: 'createdAt'
                enableCellEdit: false
                cellFilter: "date: 'yyyy-MM-dd'"
            }
            {
                displayName: '信息种类'
                name: 'applyCategory'
                enableCellEdit: false
            }
            {
                displayName: '缴费状态'
                field: 'status'
                editableCellTemplate: 'ui-grid/dropdownEditor'
                headerCellClass: 'editable_cell_header'
                editDropdownValueLabel: 'value'
                editDropdownIdLabel: 'key'
                editDropdownOptionsArray: [
                    {key: '未处理', value: '未处理'}
                    {key: '加入', value: '加入'}
                    {key: '退出', value: '退出'}
                ]
            }
        ]

        @constraints = [

        ]

    initialize: (gridApi) ->
        self = @

        saveRow = (rowEntity) ->
            dfd = @q.defer()

            gridApi.rowEdit.setSavePromise(rowEntity, dfd.promise)

            if rowEntity.handleStatus != "未处理"
                @http({
                    method: 'GET'
                    url: '/api/annuity_apply/handle_apply?id=' + rowEntity.id + "&handle_status=" + rowEntity.status
                })
                .success (data) ->
                    dfd.resolve()
                    self.Evt.$send('annuity_change:update:success', data.messages || "处理成功")
                .error () ->
                    dfd.reject()
                    rowEntity.$restore()

        # edit.on.afterCellEdit($scope,function(rowEntity, colDef, newValue, oldValue)
        # gridApi.edit.on.afterCellEdit @scope, (rowEntity, colDef, newValue, oldValue) ->

        gridApi.rowEdit.on.saveRow(@scope, saveRow.bind(@))
        @scope.gridApi = gridApi

    loadInitialData: () ->
        @annuityChanges = @AnnuityChange.$collection().$fetch()

    search: (tableState) ->
        tableState = tableState || {}
        tableState['per_page'] = @scope.gridApi.grid.options.paginationPageSize
        @annuityChanges.$refresh(tableState)

class DinnerController
    @.$inject = ['$http', '$scope', '$nbEvent']

    constructor: ($http, $scope, $Evt) ->
        $scope.currentSettingLocation = null
        #当前配置项
        $scope.setting = null
        $scope.configurations = null
        $scope.locations = null

        $http.get('api/welfares/dinners')
            .success (result) ->
                $scope.configurations = result.dinners

        #保存社保配置信息
        $scope.saveConfig = (settings)->
            $http.put('/api/welfares/dinners', {
                dinners: settings
            }).success ()->
                $Evt.$send('dinners:update:success', '工作餐配置保存成功')

    destroyCity: (cities, idx) ->
        cities.splice(idx, 1)



class DinnerPersonalController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', 'DinnerPersonSetup', '$q', '$state', 'Employee']

    constructor: (@http, @scope, @Evt, @DinnerPersonSetup, @q, @state, @Employee) ->
        @areas = []

        @loadInitialData()

        @filterOptions = {
            name: 'dinnerPersonal'
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
            {displayName: '班制', name: 'shiftsType'}
            {displayName: '驻地', name: 'location'}
            {displayName: '餐费区域', name: 'area'}
            {displayName: '卡金额', name: 'cardAmount'}
            {displayName: '卡次数', name: 'cardNumber'}
            {displayName: '工作餐', name: 'workingFee'}
            {
                displayName: '设置'
                field: 'setting'
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a nb-dialog
                        template-url="partials/welfares/dinners/person.html"
                        locals="{dinner: row.entity, ctrl: grid.appScope.$parent.ctrl}">
                        设置
                    </a>
                </div>
                '''
            }
        ]

    loadInitialData: () ->
        self = @

        @configurations = @DinnerPersonSetup.$collection().$fetch().$then (response)->
            self.areas = response.$response.data.areas

    loadEmployee: (params, contract)->
        self = @

        @Employee.$collection().$refresh(params).$then (employees)->
            args = _.mapKeys params, (value, key) ->
                _.camelCase key

            matched = _.find employees, args

            if matched
                self.loadEmp = matched
                self.isFemale = true
                contract.employeeId = matched.id
                contract.employeeNo = matched.employeeNo
                contract.departmentName = matched.department.name
                contract.positionName = matched.position.name
                contract.employeeName = matched.name
                contract.owner = matched
            else
                self.loadEmp = params

    newDinner: (dinner) ->
        self = @

        @configurations.$build(dinner).$save().$then ()->
            self.configurations.$refresh()

    saveDinner: (dinner) ->
        self = @
        dinner.$save().$then () ->
            self.configurations.$refresh()


class DinnerComputeController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', 'DinnerRecord', 'toaster','$q']

    constructor: (@http, @scope, @Evt, @DinnerRecord, @toaster, @q) ->
        opitions = null

        @loadDateTime()
        @loadInitialData(opitions)

        @filterOptions = {
            name: 'dinnerCompute'
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
            # {displayName: '发放日期', name: 'sentDate'}
        ]

    initialize: (gridApi) ->
    #     saveRow = (rowEntity) ->
    #         dfd = @q.defer()

    #         gridApi.rowEdit.setSavePromise(rowEntity, dfd.promise)

    #         rowEntity.$save().$asPromise().then(
    #             () -> dfd.resolve(),
    #             () ->
    #                 dfd.reject()
    #                 rowEntity.$restore())

    #     gridApi.rowEdit.on.saveRow(@scope, saveRow.bind(@))
        @scope.$gridApi = gridApi
        @gridApi = gridApi

    loadDateTime: () ->
        date = new Date()

        @year_list = @$getYears()
        @month_list = @$getMonths()

        @currentYear = @year_list[@year_list.length - 1]
        @currentMonth = @month_list[@month_list.length - 1]

    loadInitialData: (opitions) ->
        args = {month: @currentCalcTime()}
        angular.extend(args, opitions) if angular.isDefined(opitions)
        @records = @DinnerRecord.$collection(args).$fetch()

    search: (tableState) ->
        tableState = {} unless tableState
        tableState['month'] = @currentCalcTime()
        tableState['per_page'] = @gridApi.grid.opitions.paginationPageSize
        @records.$refresh(tableState)

    currentCalcTime: ()->
        @currentYear + "-" + @currentMonth

    loadRecords: (opitions = null) ->
        args = {month: @currentCalcTime()}
        angular.extend(args, opitions) if angular.isDefined(opitions)
        @records.$refresh(args)



class BirthAllowanceController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', 'BirthAllowance', 'Employee', 'toaster']

    constructor: ($http, $scope, @Evt, @BirthAllowance, @Employee, @toaster) ->
        @loadInitialData()

        @filterOptions = {
            name: 'dinnerPersonal'
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
            {displayName: '发放日期', name: 'sentDate'}
            {displayName: '发放金额', name: 'sentAmount'}
            {displayName: '抵扣金额', name: 'deductAmount'}
        ]

    loadInitialData: () ->
        @birthAllowances = @BirthAllowance.$collection().$fetch()

    search: (tableState) ->
        tableState = tableState || {}
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        @birthAllowances.$refresh(tableState)

    loadEmployee: (params, contract)->
        self = @

        @Employee.$collection().$refresh(params).$then (employees)->
            args = _.mapKeys params, (value, key) ->
                _.camelCase key

            matched = _.find employees, args

            if matched && matched.genderId == 27
                self.loadEmp = matched
                self.isFemale = true
                contract.employeeId = matched.id
                contract.employeeNo = matched.employeeNo
                contract.departmentName = matched.department.name
                contract.positionName = matched.position.name
                contract.employeeName = matched.name
                contract.owner = matched
            else if matched && matched.genderId == 26
                self.loadEmp = matched
                self.isFemale = false
                self.toaster.pop('error', '警告', '男性不能发放剩余津贴')
            else
                self.loadEmp = params

    newBirthAllowance: (birthAllowance) ->
        self = @

        @birthAllowances.$build(birthAllowance).$save().$then ()->
            self.birthAllowances.$refresh()



app.controller 'welfareCtrl', WelfareController
app.controller 'welfarePersonalCtrl', WelfarePersonalController
app.controller 'socialComputeCtrl', SocialComputeController
app.controller 'socialHistoryCtrl', SocialHistoryController
app.controller 'socialChangesCtrl', SocialChangesController
app.controller 'socialChangesProcessCtrl', SocialChangeProcessController


app.controller 'annuityPersonalCtrl', AnnuityPersonalController
app.controller 'annuityComputeCtrl', AnnuityComputeController
app.controller 'annuityHistoryCtrl', AnnuityHistoryController
app.controller 'annuityChangesCtrl', AnnuityChangesController

app.controller 'dinnerCtrl', DinnerController
app.controller 'dinnerPersonalCtrl', DinnerPersonalController
app.controller 'dinnerComputeCtrl', DinnerComputeController

app.controller 'birthAllowanceCtrl', BirthAllowanceController
