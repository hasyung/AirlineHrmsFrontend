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


class SalaryController

    @.$inject = ['$http', '$scope', '$nbEvent']

    constructor: ($http, $scope, $Evt) ->


class SalaryBasicController
    @.$inject = ['$http', '$scope', '$nbEvent']

    constructor: ($http, $scope, $Evt) ->


class SalaryPerformanceController
    @.$inject = ['$http', '$scope', '$nbEvent']

    constructor: ($http, $scope, $Evt) ->


class SalaryPersonalController
    @.$inject = ['$http', '$scope', '$nbEvent', 'Employee']

    constructor: ($http, $scope, $Evt, @Employee) ->

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
            {
                displayName: '分类'
                name: 'categorg'
            }
            {
                displayName: '通道'
                name: 'channel'
            }
            {
                displayName: '用工性质'
                name: 'laborRelation'
            }
            {
                displayName: '属地化'
                name: 'localPosition'
            }
            {
                displayName: '设置'
                field: 'setting'
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a nb-dialog
                        template-url="partials/salary/settings/personal_edit.html"
                        locals="{setups: row.entity}">
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

    newPersonalSetup: (newSetup)->
        self = @
        newSetup = @salaryPersonSetups.$build(newSetup)
        newSetup.$save().$then ()->
            self.salaryPersonSetups.$refresh()

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
app.controller 'salaryBasicCtrl', SalaryBasicController
app.controller 'salaryPerformanceCtrl', SalaryPerformanceController
app.controller 'salaryPersonalCtrl', SalaryPersonalController