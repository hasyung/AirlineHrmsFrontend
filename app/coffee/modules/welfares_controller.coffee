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


# 社保


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
                    name: 'department_name'
                    displayName: '机构'
                    type: 'org-search'
                }
                {
                    name: 'social_location'
                    type: 'string'
                    displayName: '社保属地'
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

    loadInitialData: ->
        @socialPersonSetups = @SocialPersonSetup.$collection().$fetch()

    search: (tableState) ->
        @socialPersonSetups.$refresh(tableState)

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

    loadEmployee: (params, newSetup)->
        self = @

        @Employee.$collection().$refresh(params).$then (employees)->
            matched = _.find employees, params

            if matched
                self.loadEmp = matched
                newSetup.owner = matched
            else
                self.loadEmp = params


class SocialComputeController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', 'SocialRecord']

    constructor: (@http, $scope, @Evt, @SocialRecord) ->
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

        @socialRecords = @SocialRecord.$collection().$fetch()

    search: (tableState)->
        @socialRecords.$refresh(tableState)

    currentCalcTime: ()->
        @currentYear + "-" + @currentMonth

    loadRecords: ()->
        @socialRecords.$refresh({month: @currentCalcTime()})

    # 强制计算
    exeCalc: ()->
        @calcing = true
        self = this

        @socialRecords = @SocialRecord.compute({month: @currentCalcTime()}).$asPromise().then (data)->
            self.calcing = false
            erorr_msg = data.$response.data.messages
            self.Evt.$send("social:calc:error", erorr_msg) if erorr_msg

    parseJSON: (data) ->
        angular.fromJson(data)

    upload_salary: ()->
        self = @
        calc_month = @currentCalcTime()
        params = {attachment_id: @upload_xls_id, month: calc_month}

        @http.post("/api/social_records/import", params).success (data, status) ->
            if data.error_count > 0
                self.Evt.$send 'upload:salary_import:error', '月度' + calc_month + '薪酬数据有' + data.error_count + '条导入失败'
            else
                self.Evt.$send 'upload:salary_import:success', '月度' + calc_month + '薪酬数据导入成功'


class SocialHistoryController
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
                    name: 'month'
                    displayName: '缴费月度'
                    type: 'date-range'
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

    loadInitialData: ->
        @socialRecords = @SocialRecord.$collection().$fetch()

    search: (tableState) ->
        @socialRecords.$refresh(tableState)

    getSelectsIds: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk


class SocialChangesController
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

    loadInitialData: ->
        @socialChanges = @SocialChange.$collection().$fetch()

    search: (tableState) ->
        @socialChanges.$refresh(tableState)


class SocialChangeProcessController extends nb.EditableResourceCtrl
    @.$inject = ['$http', '$scope', '$enum', '$nbEvent', 'SocialPersonSetup']

    constructor: ($http, $scope, $enum, $Evt, @SocialPersonSetup) ->
        super($scope, $enum, $Evt)

        @find_or_build_setup = (change)->
            return change.socialSetup.$fetch() if change.socialSetup
            change.socialSetup = @SocialPersonSetup.$build({
                employeeId: change.owner.$pk
                socialAccount: '000000'
            })


app.controller 'welfareCtrl', WelfareController
app.controller 'welfarePersonalCtrl', WelfarePersonalController
app.controller 'socialComputeCtrl', SocialComputeController
app.controller 'socialHistoryCtrl', SocialHistoryController
app.controller 'socialChangesCtrl', SocialChangesController
app.controller 'socialChangesProcessCtrl', SocialChangeProcessController


# 年金
class AnnuityPersonalController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', 'Annuity', '$q']

    constructor: (@http, @scope, @Evt, @Annuity, @q) ->
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
                    name: 'annuityStatus'
                    displayName: '缴费状态'
                    type: 'select'
                    params: {
                        type: 'annuity_status'
                    }
                }
            ]
        }

        @columnDef = [
            {displayName: '员工编号', name: 'employeeNo'}
            {
                displayName: '姓名'
                name: 'name'
                enableCellEdit: false
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
                enableCellEdit: false
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

            console.error rowEntity.annuityStatus

            @http({
                method: 'PUT'
                url: '/api/annuities/' + rowEntity.id
                data: {
                    id: rowEntity.id
                    annuity_status: rowEntity.annuityStatus
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

    loadInitialData: ->
        @annuities = @Annuity.$collection().$fetch()

    search: (tableState) ->
        @annuities.$refresh(tableState)

    getSelectsIds: () ->
        rows = @scope.$gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk

    getSelected: () ->
        rows = @scope.$gridApi.selection.getSelectedGridRows()
        @selected = if rows.length >= 1 then rows[0].entity else null

    loadBasicComputeRecords: (employee_id)->
        self = @
        console.error employee_id

        @http({
            method: 'GET'
            url: '/api/annuities/show_cardinality?employee_id=' +  employee_id
        })
        .success (data) ->
            json_data = angular.fromJson(data)
            self.basicComputeRecords = json_data.social_records
            self.averageCompute = json_data.meta.annuity_cardinality


class AnnuityComputeController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', 'AnnuityRecord']

    constructor: ($http, $scope, $Evt, @AnnuityRecord) ->
        @configurations = @loadInitialData()

        @columnDef = [
            {displayName: '员工编号', name: 'employeeNo'}
            {
                displayName: '姓名'
                name: 'employeeName'
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
            {displayName: '备注', name: 'note'}
        ]

        @constraints = [

        ]

    loadInitialData: ->
        # @upload_xls_id = 0
        # @upload_result = ""

        @year_list = @$getYears()
        @month_list = @$getMonths()

        @currentYear = _.last(@year_list)
        @currentMonth = _.last(@month_list)

        @annuityRecords = @AnnuityRecord.$collection().$fetch()

    search: (tableState) ->
        @annuityRecords.$refresh(tableState)

    currentCalcTime: ()->
        @currentYear + "-" + @currentMonth

    loadRecords: ()->
        @annuityRecords.$refresh({date: @currentCalcTime()})


class AnnuityHistoryController
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
                    type: 'date-range'
                }
            ]
        }

        @columnDef = [
            {displayName: '员工编号', name: 'employeeNo'}
            {
                displayName: '姓名'
                name: 'employeeName'
            }
            {
                displayName: '所属部门'
                name: 'departmentName'
                cellTooltip: (row) ->
                    return row.entity.department.name
            }
            {displayName: '身份证号', name: 'identityNo'}
            {displayName: '手机号', name: 'mobile'}
            {displayName: '本年基数', name: 'annuityCardinality'}
            {displayName: '个人缴费', name: 'personalPayment'}
            {displayName: '公司缴费', name: 'companyPayment'}
            {displayName: '备注', name: 'note'}
        ]

        @constraints = [

        ]

    loadInitialData: ->
        @annuityRecords = @AnnuityRecord.$collection().$fetch()

    search: (tableState) ->
        @annuityRecords.$refresh(tableState)


class AnnuityChangesController
    @.$inject = ['$http', '$scope', '$nbEvent', 'AnnuityChange']

    constructor: ($http, $scope, $Evt, @AnnuityChange) ->
        @configurations = @loadInitialData()

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
            {displayName: '员工编号', name: 'employeeNo'}
            {
                displayName: '姓名'
                name: 'name'
            }
            {
                displayName: '所属部门'
                name: 'department.name'
                cellTooltip: (row) ->
                    return row.entity.department.name
            }
            {displayName: '信息发生时间', name: 'identityNo'}
            {displayName: '信息种类', name: 'mobile'}
            {
                displayName: '处理'
                field: 'deal'
                cellTemplate: '''
                <div class="ui-grid-cell-contents ng-binding ng-scope">
                    md-radio-group(ng-model="row.entity.handleStatus")
                        md-radio-button.md-primary(value="true") 加入
                        md-radio-button.md-primary(value="false") 退出
                </div>
                '''
            }
        ]

        @constraints = [

        ]


    loadInitialData: ->
        @annuityChanges = @AnnuityChange.$collection().$fetch()

    search: (tableState) ->
        @annuityChanges.$refresh(tableState)


app.controller 'annuityPersonalCtrl', AnnuityPersonalController
app.controller 'annuityComputeCtrl', AnnuityComputeController
app.controller 'annuityHistoryCtrl', AnnuityHistoryController
app.controller 'annuityChangesCtrl', AnnuityChangesController