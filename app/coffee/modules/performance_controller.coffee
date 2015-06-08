
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
                controller: PerformanceAllege
                controllerAs: 'ctrl'

            }
            .state 'performance_setting', {
                url: '/performance_setting'
                templateUrl: 'partials/performance/setting/index.html'
                controller: PerformanceSetting
                controllerAs: 'ctrl'
            }

class PerformanceRecord extends nb.Controller
    @.$inject = ['$scope', 'Performance', '$http']

    constructor: (@scope, @Performance, @http)->
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
    uploadPerformance: (request)->
        request.assess_time = request.assessTime + '-1'
        @http.post("/api/performances/import_performances", request)

class PerformanceSetting extends nb.Controller
    @.$inject = ['$scope', 'PerformanceTemp']

    constructor: (@scope, @PerformanceTemp)->
        @filterOptions = getBaseFilterOptions('performance_setting')

        @columnDef = [
            {displayName: '员工编号', name: 'employeeNo'}
            {displayName: '姓名', name: 'name'}
            {
                displayName: '所属部门'
                name: 'department.name'
                cellTooltip: (row) ->
                    return row.entity.department.name
            }
            {
                displayName: '岗位'
                name: 'position.name'
                cellTooltip: (row) ->
                    return row.entity.position.name
            }
            {displayName: '通道', name: 'channelId', cellFilter: "enum: 'channels'"}
            {displayName: '职务职级', name: 'dutyRankId', cellFilter: "enum: 'duty_ranks'"}
            {displayName: '到岗时间', name: 'joinScalDate'}
            {displayName: '月度分配基数', name: 'monthDistributeBase'}
            {displayName: '考核人员分类', name: 'pcategory'}
        ]

        @performanceTemps = @PerformanceTemp.$collection().$fetch()

    search: (tableState)->
        @performanceTemps.$refresh(tableState)

    getSelected: () ->
        rows = @scope.$gridApi.selection.getSelectedGridRows()
        selected = if rows.length >= 1 then rows[0].entity else null

class PerformanceAllege extends nb.Controller
    @.$inject = ['$scope', 'Allege']

    constructor: (@scope, @Allege)->
        @filterOptions = getBaseFilterOptions('performance_allege')

        @columnDef = BASE_TABLE_DEFS.concat [
            {displayName: '考核时段', name: 'assessTime'}
            {displayName: '绩效', name: 'result'}
            {displayName: '申述时间', name: 'createdAt'}
            {displayName: '申述结果', name: 'outcome'}
            {
                displayName: '处理',
                field: '查看',
                cellTemplate: '''
                    <div class="ui-grid-cell-contents ng-binding ng-scope">
                        <a> 查看
                        </a>
                    </div>
                '''
            }
        ]

        @alleges = @Allege.$collection().$fetch()

    search: (tableState)->
        @alleges.$refresh(tableState)

    getSelected: () ->
        rows = @scope.$gridApi.selection.getSelectedGridRows()
        selected = if rows.length >= 1 then rows[0].entity else null



app.config(Route)
