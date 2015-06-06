
nb = @.nb
app = nb.app
extend = angular.extend
filterBuildUtils = nb.filterBuildUtils
Modal = nb.Modal


getBaseFilterOptions = (fliterName)->
    filterBuildUtils(fliterName)
        .col 'name',                 '姓名',    'string',           '姓名'
        .col 'employee_no',          '员工编号', 'string'
        .col 'department_ids',       '机构',    'org-search'
        .end()

BASE_TABLE_DEFS = [
    {displayName: '员工编号', name: 'employeeNo'}
    {
        displayName: '姓名'
        field: 'employeeName'
        cellTemplate: '''
        <div class="ui-grid-cell-contents ng-binding ng-scope">
            <a>
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
    {displayName: '通道', name: 'channel'}
]



class Route
    @.$inject = ['$stateProvider', '$urlRouterProvider', '$injector']

    constructor: (stateProvider, urlRouterProvider, injector) ->

        stateProvider
            .state 'performance_record', {
                url: '/performance_record'
                templateUrl: 'partials/performance/record/index.html'
                controller: PerformanceRecord
                controllerAs: 'ctrl'
                
            }
            .state 'performance_alleges', {
                url: '/performance_alleges'
                templateUrl: 'partials/performance/allege/index.html'
            }
            .state 'performance_setting', {
                url: '/performance_setting'
                templateUrl: 'partials/performance/setting/index.html'
            }

class PerformanceRecord extends nb.Controller
    @.$inject = ['$scope', 'Performance']

    constructor: (@scope, @Performance)->
        @filterOptions = getBaseFilterOptions('performance_record')

        @columnDef = BASE_TABLE_DEFS.concat [
            {displayName: '考核时段', name: 'assessTime'}
            {displayName: '绩效', name: 'result'}
            {displayName: '排序', name: 'sortNo'}
            {
                displayName: '附件',
                field: '查看',
                cellTemplate: '''
                    <div class="ui-grid-cell-contents ng-binding ng-scope">
                        <a> 查看
                        </a>
                    </div>
                '''
            }
        ]

        @performances = @Performance.$collection().$fetch()

    search: (tableState)->
        @performances.$refresh(tableState)

    getSelected: () ->
        rows = @scope.$gridApi.selection.getSelectedGridRows()
        selected = if rows.length >= 1 then rows[0].entity else null


app.config(Route)
