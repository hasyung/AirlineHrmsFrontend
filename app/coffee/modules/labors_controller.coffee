
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


FLOW_HANDLE_TABLE_DEFS =  [
    {
        name: 'receptor.channelId'
        displayName: '通道'
        cellFilter: "enum:'channels'"
    }
    {
        name: 'workflowState'
        displayName: '状态'
    }
    {
        name: 'createdAt'
        displayName: '出生日期'
        cellFilter: "date:'yyyy-MM-dd'"
    }
    {
        name: 'createdAt'
        displayName: '申请发起时间'
        cellFilter: "date:'yyyy-MM-dd'"
    }
    {
        name: 'type'
        displayName: '详细'
        cellTemplate: '''
        <div class="ui-grid-cell-contents">
            <a flow-handler="row.entity" flows="grid.options.data">
                查看
            </a>
        </div>
        '''
    }

]

HANDLER_AND_HISTORY_FILTER_OPTIONS = {
    constraintDefs: [
        {
            name: 'employee_name'
            displayName: '姓名'
            type: 'string'
        }
    ]
}





class Route
    @.$inject = ['$stateProvider', '$urlRouterProvider', '$injector']

    constructor: (stateProvider, urlRouterProvider, injector) ->

        stateProvider
            .state 'contract_management', {
                url: '/contract-management'
                templateUrl: 'partials/labors/contract/index.html'
                controller: ContractCtrl
                controllerAs: 'ctrl'
            }
            .state 'labors_attendance', {
                url: '/labors_attendance'
                templateUrl: 'partials/labors/attendance/index.html'
                controller: AttendanceCtrl
                controllerAs: 'ctrl'
            }
            .state 'labors_ajust_position', {
                url: '/labors_ajust_position'
                templateUrl: 'partials/labors/adjust_position/index.html'
                controller: SbFlowHandlerCtrl
                resolve: {
                    'FlowName': -> 'Flow::AdjustPosition'
                }
            }
            .state 'labors_dismiss', {
                url: '/labors_dismiss'
                templateUrl: 'partials/labors/dismiss/index.html'
                controller: SbFlowHandlerCtrl
                resolve: {
                    'FlowName': -> 'Flow::Dismiss'
                }
            }
            .state 'labors_early_retirement', {
                url: '/labors_early_retirement'
                templateUrl: 'partials/labors/early_retirement/index.html'
                controller: SbFlowHandlerCtrl
                resolve: {
                    'FlowName': -> 'Flow::EarlyRetirement'
                }
            }
            .state 'labors_punishment', {
                url: '/labors_punishment'
                templateUrl: 'partials/labors/punishment/index.html'
                controller: SbFlowHandlerCtrl
                resolve: {
                    'FlowName': -> 'Flow::Punishment'
                }
            }
            .state 'labors_renew_contract', {
                url: '/labors_renew_contract'
                templateUrl: 'partials/labors/renew_contract/index.html'
                controller: SbFlowHandlerCtrl
                resolve: {
                    'FlowName': -> 'Flow::RenewContract'
                }
            }
            .state 'labors_retirement', {
                url: '/labors_retirement'
                templateUrl: 'partials/labors/retirement/index.html'
                controller: LaborsCtrl
                controllerAs: 'ctrl'
            }



class LaborsCtrl extends nb.Controller

    @.$inject = ['$scope', '$http', 'Flow::Retirement']

    constructor: (@scope, @http, @Retirement)->

    retirement: (users)->
        params = users.map (user)->
            {id: user.id, relation_data:user.relation_data}

        @http.post("/api/workflows/Flow::Retirement/batch_create", {receptors:params})



class AttendanceCtrl extends nb.Controller

    @.$inject = ['GridHelper', 'Leave', '$scope', '$injector']

    constructor: (helper, @Leave, scope, injector) ->

        scope.realFlow = (entity) ->
            t = entity.type
            m = injector.get(t)
            return m.$find(entity.$pk)




        @recordsFilterOptions = {
            name: 'attendance_records'
            constraintDefs: [
                {
                    name: 'employee_name'
                    displayName: '姓名'
                    type: 'string'
                }
            ]
        }


        def = [
            {
                name: 'typeCn'
                displayName: '假别'
            }
            {
                name: 'vacationDays'
                displayName: '时长'
            }
            {
                name: 'workflowState'
                displayName: '状态'
            }
            {
                name: 'createdAt'
                displayName: '发起时间'
                cellFilter: "date:'yyyy-MM-dd'"
            }
            {
                name: 'type'
                displayName: '详细'
                cellTemplate: '''
                <div class="ui-grid-cell-contents" ng-init="realFlow = grid.appScope.$parent.realFlow(row.entity)">
                    <a flow-handler="realFlow" flows="grid.options.data">
                        查看
                    </a>
                </div>
                '''
            }

        ]

        @recodsColumnDef = helper.buildFlowDefault(def)

        @leaveFlows = @Leave.$collection().$fetch()



class AttendanceRecordCtrl extends nb.Controller

    @.$inject = ['$scope', 'Attendance', 'Employee']
    constructor: (@scope, @Attendance, @Employee) ->
        @loadInitailData()
        @filterOptions = filterBuildUtils('attendanceRecord')
            .col 'name',                 '姓名',    'string',           '姓名'
            .col 'employee_no',          '员工编号', 'string'
            .col 'department_ids',       '机构',    'org-search'
            .end()

        @columnDef = [
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


    loadInitailData: ()->
        @employees = @Employee.$collection().$fetch()

    search: (tableState)->
        @employees.$refresh(tableState)

    getSelected: () ->
        rows = @scope.$gridApi.selection.getSelectedGridRows()
        selected = if rows.length >= 1 then rows[0].entity else null

class AttendanceHisCtrl extends nb.Controller
    @.$inject = ['$scope', 'Attendance']
    constructor: (@scope, @Attendance) ->
        @loadInitailData()
        @filterOptions = {
            name: 'attendanceHis'
            constraintDefs: [
                {
                    name: 'employee_name'
                    displayName: '姓名'
                    type: 'string'
                    placeholder: '姓名'
                }
                {
                    name: 'employee_no'
                    displayName: '员工编号'
                    type: 'string'
                    placeholder: '员工编号'
                }
                {
                    name: 'department_ids'
                    displayName: '机构'
                    type: 'org-search'
                }
                {
                    name: 'created_at'
                    displayName: '记录时间'
                    type: 'date-range'
                }

            ]
        }

        @columnDef = [
            {displayName: '员工编号', name: 'user.employeeNo'}
            {
                displayName: '姓名'
                field: 'user.name'
                # pinnedLeft: true
                cellTemplate: '''
                <div class="ui-grid-cell-contents ng-binding ng-scope">
                    <a nb-panel
                        template-url="partials/personnel/info_basic.html"
                        locals="{employee: row.entity.user}">
                        {{row.entity.user.name}}
                    </a>
                </div>
                '''
            }
            {
                displayName: '所属部门'
                name: 'user.departmentName'
                cellTooltip: (row) ->
                    return row.entity.user.departmentName
            }

            {
                displayName: '岗位'
                name: 'user.position.name'
                cellTooltip: (row) ->
                    return row.entity.user.position.name
            }
            {displayName: '分类', name: 'user.categoryId', cellFilter: "enum:'categories'"}
            {displayName: '通道', name: 'user.channelId', cellFilter: "enum:'channels'"}
            {displayName: '考勤类别', name: 'recordType'}
            {displayName: '记录时间', name: 'recordDate'}
        ]

    loadInitailData: ()->
        @attendances = @Attendance.$collection().$fetch()

    search: (tableState)->
        @attendances.$refresh(tableState)
    getSelected: () ->
        rows = @scope.$gridApi.selection.getSelectedGridRows()
        selected = if rows.length >= 1 then rows[0].entity else null

    markToDeleted: (attendance)->
        self = @
        attendance.$destroy().$then ()->
            self.attendances.$refresh()






class ContractCtrl extends nb.Controller
    @.$inject = ['$scope', 'Contract']
    constructor: (@scope, @Contract) ->
        @loadInitailData()
        @filterOptions = {
            name: 'contract'
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
                    placeholder: '员工编号'
                }
                {
                    name: 'department_ids'
                    displayName: '机构'
                    type: 'org-search'
                }
                {
                    name: 'end_date'
                    displayName: '合同到期时间'
                    type: 'date-range'
                }
                {
                    name: 'apply_type'
                    displayName: '用工性质'
                    type: 'string'
                }
                {
                    name: 'notes'
                    displayName: '是否有备注'
                    type: 'boolean'
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
                        locals="{employee: row.entity}">
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
            {displayName: '用工性质', name: 'applyType'}
            {displayName: '变更标志', name: 'changeFlag'}
            {displayName: '合同开始时间', name: 'startDate'}
            {displayName: '合同结束时间', name: 'endDate'}
            {displayName: '备注', name: 'notes'}
            {
                displayName: '详细',
                field: '详细',
                cellTemplate: '''
                    <div class="ui-grid-cell-contents ng-binding ng-scope">
                        <a nb-panel
                            template-url="partials/personnel/info_basic.html"
                            locals="{employee: row.entity}"> 详细
                        </a>
                    </div>
                '''

            }
        ]

        @hisFilterOptions = {
            name: 'contractHis'
            constraintDefs: [
                {
                    name: 'name'
                    displayName: '姓名'
                    type: 'string'
                    placeholder: '姓名'
                }
                {
                    name: 'employee_no'
                    displayName: '员工编号'
                    type: 'string'
                    placeholder: '员工编号'
                }
                {
                    name: 'department_ids'
                    displayName: '机构'
                    type: 'org-search'
                }

            ]
        }

        @hisColumnDef = [
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
            {displayName: '用工性质', name: 'applyType'}
            {displayName: '变更标志', name: 'changeFlag'}
            {displayName: '开始时间', name: 'startDate', cellFilter: "enum:'channels'"}
            {displayName: '结束时间', name: 'endDate'}
            {
                displayName: '详细',
                field: '详细',
                cellTemplate: '''
                    <div class="ui-grid-cell-contents ng-binding ng-scope">
                        <a nb-panel
                            template-url="partials/personnel/info_basic.html"
                            locals="{employee: row.entity}"> 详细
                        </a>
                    </div>
                '''

            }
        ]



    loadInitailData: ->
        @contracts = @Contract.$collection().$fetch()

    search: (tableState) ->
        @contracts.$refresh(tableState)


class UserListCtrl extends nb.Controller
    @.$inject = ["$scope", "Employee"]

    constructor: (scope, @Employee)->
        scope.employees = @Employee.$collection().$fetch()

        scope.filterOptions = filterBuildUtils('laborsRetirement')
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

        scope.columnDef = [
            {
                displayName: '所属部门'
                name: 'department.name'
                cellTooltip: (row) ->
                    return row.entity.department.name
            }
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

            {displayName: '员工编号', name: 'employeeNo'}
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

        scope.getSelected = () ->
            rows = scope.$gridApi.selection.getSelectedGridRows()
            selected = if rows.length >= 1 then rows[0].entity else null

        scope.getSelecteds = ()->
            rows = scope.$gridApi.selection.getSelectedGridRows()
            rows = rows.map (row)-> row.entity

        scope.search = (tableState)->
            scope.employees.$refresh(tableState)

class RetirementCtrl extends nb.Controller
    @.$inject = ['GridHelper', 'Flow::Retirement', '$scope', '$injector']

    constructor: (helper, @Retirement, scope, injector) ->

        @filterOptions = {
            name: 'retirementCheck'
            constraintDefs: [
                {
                    name: 'employee_name'
                    displayName: '姓名'
                    type: 'string'
                }
            ]
        }

        def = _.cloneDeep(flow_handle_table_defs)

        @columnDef = helper.buildFlowDefault(def)

        @retirements = @Retirement.$collection().$fetch()

    search: (tableState)->
        @retirements.$refresh(tableState)




class SbFlowHandlerCtrl

    @.$inject = ['GridHelper', 'FlowName', '$scope', 'Employee', '$injector', 'OrgStore']

    constructor: (@helper, FlowName, @scope, @Employee, $injector, OrgStore) ->

        @scope.ctrl = @
        @Flow = $injector.get(FlowName)


        @userListName = "#{FlowName}_USER_LIST"
        @checkListName = "#{FlowName}_CHECK_LIST"
        @historyListName = "#{FlowName}_HISTORY_LIST"

        @columnDef = null
        @tableData = null
        @filterOptions = null

        @reviewers =  @Employee.$search({category_ids: [1,2], department_ids: [OrgStore.getPrimaryOrgId()]})

    userList: ->
        filterOptions = _.cloneDeep(userListFilterOptions)
        filterOptions.name = @userListName
        @filterOptions = filterOptions
        @columnDef = _.cloneDeep(USER_LIST_TABLE_DEFS)
        @tableData = @Employee.$collection().$fetch()

    checkList: ->
        @columnDef = @helper.buildFlowDefault(FLOW_HANDLE_TABLE_DEFS)
        filterOptions = _.cloneDeep(HANDLER_AND_HISTORY_FILTER_OPTIONS)
        filterOptions.name = @checkListName
        @filterOptions = filterOptions
        @tableData = @Flow.$collection().$fetch()

    historyList: ->
        @columnDef = @helper.buildFlowDefault(FLOW_HANDLE_TABLE_DEFS)
        filterOptions = _.cloneDeep(HANDLER_AND_HISTORY_FILTER_OPTIONS)
        filterOptions.name = @historyListName
        @filterOptions = filterOptions
        @tableData = @Flow.records()

    getSelected: ->
        rows = @scope.$gridApi.selection.getSelectedGridRows()
        selected = if rows.length >= 1 then rows[0].entity else null

    search: (tableState)->
        @tableData.$refresh(tableState)

class EarlyRetirementCtrl extends SbFlowHandlerCtrl

    @.$inject = ['GridHelper', 'Flow::EarlyRetirement', '$scope', 'Employee']

    constructor: (helper, Flow, scope, Employee) ->
        @userListName = 'EarlyRetirementUserList'
        @checkListName = 'EarlyRetirementCheckList'
        @historyListName = 'EarlyRetirementHistoryList'
        super(helper, Flow, scope, Employee)




app.config(Route)
app.controller('AttendanceRecordCtrl', AttendanceRecordCtrl)
app.controller('AttendanceHisCtrl', AttendanceHisCtrl)
app.controller('UserListCtrl', UserListCtrl)
app.controller('RetirementCtrl', RetirementCtrl)
app.controller('SbFlowHandlerCtrl', SbFlowHandlerCtrl)

