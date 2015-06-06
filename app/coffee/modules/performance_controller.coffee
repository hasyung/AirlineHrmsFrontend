
nb = @.nb
app = nb.app
extend = angular.extend
filterBuildUtils = nb.filterBuildUtils
Modal = nb.Modal


userListFilterOptions = filterBuildUtils('laborsRetirement')
    .col 'name',                 '姓名',    'string',           '姓名'
    .col 'employee_no',          '员工编号', 'string'
    .col 'department_ids',       '机构',    'org-search'
    .col 'position_names',       '岗位名称', 'string_array'
    .col 'locations',            '属地',    'string_array'
    .col 'channel_ids',          '通道',    'muti-enum-search', '',    {type: 'channels'}
    .col 'employment_status_id', '用工状态', 'select',           '',    {type: 'employment_status'}
    .col 'birthday',             '出生日期', 'date-range'
    .col 'join_scal_date',       '入职时间', 'date-range'
    .end()

USER_LIST_TABLE_DEFS = [
    {displayName: '员工编号', name: 'employeeNo'}
    {
        displayName: '姓名'
        field: 'name'
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
    {displayName: '分类', name: 'categoryId', cellFilter: "enum:'categories'"}
    {displayName: '通道', name: 'channelId', cellFilter: "enum:'channels'"}
    {displayName: '用工性质', name: 'laborRelationId', cellFilter: "enum:'labor_relations'"}
    {displayName: '到岗时间', name: 'joinScalDate'}
]



class Route
    @.$inject = ['$stateProvider', '$urlRouterProvider', '$injector']

    constructor: (stateProvider, urlRouterProvider, injector) ->

        stateProvider
            .state 'performance_record', {
                url: '/performance_record'
                templateUrl: 'partials/performance/record/index.html'
                
            }
            .state 'performance_alleges', {
                url: '/performance_alleges'
                templateUrl: 'partials/performance/allege/index.html'
            }
            .state 'performance_setting', {
                url: '/performance_setting'
                templateUrl: 'partials/performance/setting/index.html'
            }


app.config(Route)
