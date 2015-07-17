
nb = @.nb
app = nb.app
extend = angular.extend
resetForm = nb.resetForm
Modal = nb.Modal



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
            }).success ->
                $Evt.$send('wselfate:save:success', '社保配置保存成功')



class WelfarePersonalController
    @.$inject = ['$http', '$scope', '$nbEvent', 'socialPersonSetups']

    constructor: ($http, $scope, $Evt, @socialPersonSetups) ->

        @configurations = @loadInitailData()

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
                # pinnedLeft: true
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
            {displayName: '医疗', name: 'treatment'}
            {displayName: '失业', name: 'unemploy'}
            {displayName: '工伤', name: 'injury'}
            {displayName: '大病', name: 'illness'}
            {displayName: '生育', name: 'fertility'}
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

    loadInitailData: ->
        @socialPersonSetups = @socialPersonSetups.$collection().$fetch()

    search: (tableState) ->
        @socialPersonSetups.$refresh(tableState)

    getSelectsIds: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk


class SocialComputeController
    @.$inject = ['$http', '$scope', '$nbEvent', 'socialRecords']

    constructor: ($http, $scope, $Evt, @socialRecords) ->

        @configurations = @loadInitailData()

        @columnDef = [
            {displayName: '员工编号', name: 'employeeNo'}

        ]
        @constraints = [

        ]

    loadInitailData: ->
        @socialRecords = @socialRecords.$collection().$fetch()

    search: (tableState) ->
        @socialRecords.$refresh(tableState)

    getSelectsIds: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk


class SocialChangesController
    @.$inject = ['$http', '$scope', '$nbEvent', 'socialChanges']

    constructor: ($http, $scope, $Evt, @socialChanges) ->

        @configurations = @loadInitailData()

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
                # pinnedLeft: true
                cellTemplate: '''
                <div class="ui-grid-cell-contents ng-binding ng-scope">
                    <a nb-panel
                        template-url="partials/personnel/info_basic.html"
                        locals="{employee: row.entity}">
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
                # pinnedLeft: true
                cellTemplate: '''
                <div class="ui-grid-cell-contents ng-binding ng-scope">
                    <a nb-panel
                        template-url="partials/personnel/info_basic.html"
                        locals="{employee: row.entity}">
                        处理
                    </a>
                </div>
                '''
            }

        ]
        @constraints = [

        ]

    loadInitailData: ->
        @socialChanges = @socialChanges.$collection().$fetch()

    search: (tableState) ->
        @socialChanges.$refresh(tableState)

    getSelectsIds: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk



app.controller 'welfareCtrl', WelfareController
app.controller 'welfarePersonalCtrl', WelfarePersonalController

app.controller 'socialComputeCtrl', SocialComputeController
app.controller 'socialChangesCtrl', SocialChangesController




