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


class WelfarePersonalController
    @.$inject = ['$http', '$scope', '$nbEvent', 'SocialPersonSetups']

    constructor: ($http, $scope, $Evt, @socialPersonSetups) ->
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
        @socialPersonSetups = @socialPersonSetups.$collection().$fetch()

    search: (tableState) ->
        @socialPersonSetups.$refresh(tableState)

    getSelectsIds: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk

    getSelected: () ->
        rows = @gridApi.selection.getSelectedGridRows()

    delete: (isConfirm) ->
        if isConfirm
            @getSelected().forEach (record) -> record.entity.$destroy()


class SocialComputeController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', 'SocialRecords']

    constructor: (@http, $scope, @Evt, @socialRecords) ->
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

        @socialRecords = @socialRecords.$collection().$fetch()
        @exeCalc()

    search: (tableState)->
        @socialRecords.$refresh(tableState)

    currentCalcTime: ()->
        @currentYear + "-" + @currentMonth

    exeCalc: ()->
        calc_month = @currentCalcTime()
        @search({month: calc_month})

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
    @.$inject = ['$http', '$scope', '$nbEvent', 'SocialRecords']

    constructor: ($http, $scope, $Evt, @socialRecords) ->
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
        @socialRecords = @socialRecords.$collection().$fetch()

    search: (tableState) ->
        @socialRecords.$refresh(tableState)

    getSelectsIds: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk


class SocialChangesController
    @.$inject = ['$http', '$scope', '$nbEvent', 'SocialChanges']

    constructor: ($http, $scope, $Evt, @socialChanges) ->
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
                        template-url="partials/welfares/socials/change_info.html"
                        locals="{changeInfos: row.entity}">
                        查看
                    </a>
                </div>
                '''
            }
        ]

        @constraints = [

        ]

    loadInitialData: ->
        @socialChanges = @socialChanges.$collection().$fetch()

    search: (tableState) ->
        @socialChanges.$refresh(tableState)

    getSelectsIds: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk


app.controller 'welfareCtrl', WelfareController
app.controller 'welfarePersonalCtrl', WelfarePersonalController
app.controller 'socialComputeCtrl', SocialComputeController
app.controller 'socialHistoryCtrl', SocialHistoryController
app.controller 'socialChangesCtrl', SocialChangesController


# 年金
class AnnuityPersonalController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', 'Annuitity']

    constructor: ($http, $scope, $Evt, @Annuitity) ->

        @configurations = @loadInitialData()

        @filterOptions = {
            name: 'annuities'
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
                name: 'department.name'
                cellTooltip: (row) ->
                    return row.entity.department.name
            }
            {displayName: '身份证号', name: 'identityNo'}
            {displayName: '手机号', name: 'mobile'}
            {displayName: '本年基数', name: 'annuityCardinality'}
            {displayName: '缴费状态', name: 'annuityStatus'}
            # {
            #     displayName: '编辑'
            #     field: 'name'
            #     cellTemplate: '''
            #     <div class="ui-grid-cell-contents">
            #         <a nb-dialog
            #             template-url="partials/welfares/settings/welfare_personal_edit.html"
            #             locals="{setups: row.entity}">
            #             编辑
            #         </a>
            #     </div>
            #     '''
            # }
        ]

        @constraints = [

        ]

    loadInitialData: ->
        @Annuitity = @Annuitity.$collection().$fetch()

    search: (tableState) ->
        @Annuitity.$refresh(tableState)

    getSelectsIds: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk

    getSelected: () ->
        rows = @gridApi.selection.getSelectedGridRows()


class AnnuityComputeController
    @.$inject = ['$http', '$scope', '$nbEvent', 'SocialRecords']

    constructor: ($http, $scope, $Evt, @socialRecords) ->


class AnnuityHistoryController
    @.$inject = ['$http', '$scope', '$nbEvent']

    constructor: ($http, $scope, $Evt) ->


class AnnuityChangesController
    @.$inject = ['$http', '$scope', '$nbEvent']

    constructor: ($http, $scope, $Evt) ->


app.controller 'annuityPersonalCtrl', AnnuityPersonalController
app.controller 'annuityComputeCtrl', AnnuityComputeController
app.controller 'annuityHistoryCtrl', AnnuityHistoryController
app.controller 'annuityChangesCtrl', AnnuityChangesController