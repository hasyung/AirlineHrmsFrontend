
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

FLOW_HISTORY_TABLE_DEFS =  [
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
            <a flow-handler="row.entity" flow-view="true">
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

ATTENDANCE_BASE_TABLE_DEFS = [
    {
        name: 'name'
        displayName: '假别'
        cellTooltip: (row) ->
            return row.entity.name
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

]

ATTENDANCE_SUMMERY_DEFS= [
    {width:150, displayName: '所属部门', name: 'departmentName'}
    {width:100, displayName: '员工编号', name: 'employeeNo'}
    {width:100, displayName: '姓名', name: 'employeeName'}
    {width:100, displayName: '用工性质', name: 'laborRelation'}
    {width:100, displayName: '<带薪假>', name: 'paidLeave'}

    {width:100, displayName: '年假', name: 'annualLeave'}
    {width:100, displayName: '婚丧假', name: 'marriageFuneralLeave'}
    {width:100, displayName: '产前检查假', name: 'prenatalCheckLeave'}
    {width:100, displayName: '计生假', name: 'familyPlanningLeave'}
    {width:100, displayName: '哺乳假', name: 'lactationLeave'}
    {width:100, displayName: '女工假', name: 'womenLeave'}
    {width:100, displayName: '产假', name: 'maternityLeave'}
    {width:100, displayName: '生育护理假', name: 'rearNurseLeave'}
    {width:100, displayName: '工伤假', name: 'injuryLeave'}
    {width:100, displayName: '疗养假', name: 'recuperateLeave'}
    {width:100, displayName: '派驻休假', name: 'accreditLeave'}


    {width:100, displayName: '病假', name: 'sickLeave'}
    {width:100, displayName: '病假（工伤待定）', name: 'sickLeaveInjury'}
    {width:100, displayName: '病假（怀孕待产）', name: 'sickLeaveNulliparous'}
    {width:100, displayName: '事假', name: 'personalLeave'}
    {width:100, displayName: '探亲假', name: 'homeLeave'}
    {width:100, displayName: '培训', name: 'cultivate'}
    {width:100, displayName: '出差', name: 'evection'}
    {width:100, displayName: '旷工', name: 'absenteeism'}
    {width:100, displayName: '迟到早退', name: 'lateOrLeave'}
    {width:100, displayName: '空勤停飞', name: 'ground'}
    {width:100, displayName: '空勤地面工作', name: 'surfaceWork'}
    {width:100, displayName: '驻站天数', name: 'stationDays'}
    {width:100, displayName: '驻站地点', name: 'stationPlace'}
    {width:100, displayName: '备注', name: 'remark'}
]





class Route
    @.$inject = ['$stateProvider', '$urlRouterProvider', '$injector']

    constructor: (stateProvider, urlRouterProvider, injector) ->

        stateProvider
            .state 'contract_management', {
                url: '/contract-management'
                templateUrl: 'partials/labors/contract/index.html'
                controller: SbFlowHandlerCtrl
                resolve: {
                    'FlowName': -> 'Flow::RenewContract'
                }
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
                controller: SbFlowHandlerCtrl
                resolve: {
                    'FlowName': -> 'Flow::Retirement'
                }
            }
            .state 'labors_leave_job', {
                url: '/labors_leave_job'
                templateUrl: 'partials/labors/leave_job/index.html'
                controller: SbFlowHandlerCtrl
                resolve: {
                    'FlowName': -> 'Flow::EmployeeLeaveJob'
                }
            }
            .state 'labors_resignation', {
                url: '/labors_resignation'
                templateUrl: 'partials/labors/resignation/index.html'
                controller: SbFlowHandlerCtrl
                resolve: {
                    'FlowName': -> 'Flow::Resignation'
                }
            }


class AttendanceCtrl extends nb.Controller

    @.$inject = ['GridHelper', 'Leave', '$scope', '$injector', '$http', 'AttendanceSummary']

    constructor: (helper, @Leave, scope, injector, @http, @AttendanceSummary) ->

        @initDate()

        scope.realFlow = (entity) ->
            t = entity.type
            m = injector.get(t)
            return m.$find(entity.$pk)




        @checksFilterOptions = {
            name: 'attendance_check_list'
            constraintDefs: [
                {
                    name: 'employee_name'
                    displayName: '姓名'
                    type: 'string'
                }
            ]
        }
        @recordsFilterOptions = {
            name: 'attendance_records_list'
            constraintDefs: [
                {
                    name: 'employee_name'
                    displayName: '姓名'
                    type: 'string'
                }
            ]
        }
        checkBaseDef = ATTENDANCE_BASE_TABLE_DEFS.concat [
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

        recordsBaseDef = ATTENDANCE_BASE_TABLE_DEFS.concat [
            {
                name: 'type'
                displayName: '详细'
                cellTemplate: '''
                <div class="ui-grid-cell-contents" ng-init="realFlow = grid.appScope.$parent.realFlow(row.entity)">
                    <a flow-handler="realFlow" flow-view="true">
                        查看
                    </a>
                </div>
                '''
            }
        ]


        @checksColumnDef = helper.buildFlowDefault(checkBaseDef)
        @recodsColumnDef = helper.buildFlowDefault(recordsBaseDef)


    getYears: ()->
        [2015..new Date().getFullYear()]

    getMonths: ()->
        [1..12]

    exeSearch: (departmentId)->
        date = moment(new Date("#{this.year}-#{this.month}")).format()
        params = {summary_date: date}
        params.department_id = departmentId if departmentId
        @search(params)


    initDate: ()->
        date = new Date()
        @year = date.getFullYear()
        @month = date.getMonth() + 1
    loadCheckList: ()->
        @tableData = @Leave.$collection().$fetch()

    loadRecords: ()->
        @tableData = @Leave.records()

    loadSummaries: ()->
        @summaryCols = ATTENDANCE_SUMMERY_DEFS
        @tableData = @AttendanceSummary.$collection().$fetch()

    loadSummariesList: ()->
        @summaryListCol = ATTENDANCE_SUMMERY_DEFS

        @tableData = @AttendanceSummary.records({summary_date: moment().format()})

    getDate: ()->
        date = moment(new Date("#{this.year}-#{this.month}")).format()

    departmentHrConfirm: (isConfirm)->
        self = @
        if isConfirm
            params = {summary_date: @getDate()}
            @http.put('/api/attendance_summaries/department_hr_confirm', params).then ()->
                self.tableData.$refresh()

    departmentLeaderCheck: (isConfirm)->
        if isConfirm
            self = @
            params = {summary_date: @getDate()}
            @http.put('/api/attendance_summaries/department_leader_check', params).then ()->
                self.tableData.$refresh()

    hrLeaderCheck: (isConfirm)->
        if isConfirm
            self = @
            params = {summary_date: @getDate()}
            @http.put('/api/attendance_summaries/hr_leader_check', params).then ()->
                self.tableData.$refresh()


    search: (tableState)->
        @tableData.$refresh(tableState)

    getSelected: -> # selected entity || arr
        rows = @gridApi.selection.getSelectedGridRows()
        selected = if rows.length >= 1 then rows[0].entity else null

    getSelectedEntities: ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> row.entity

    exportGridApi: (gridApi) ->
        @gridApi = gridApi

    transferToOccupationInjury: (record)->
        self = @
        url = "/api/workflows/#{record.type}/#{record.id}/transfer_to_occupation_injury"
        @http.put(url).then ()->
            self.tableData.$refresh()




class AttendanceRecordCtrl extends nb.Controller

    @.$inject = ['$scope', 'Attendance', 'Employee', 'GridHelper']
    constructor: (@scope, @Attendance, @Employee, GridHelper) ->
        @loadInitailData()
        @filterOptions = filterBuildUtils('attendanceRecord')
            .col 'name',                 '姓名',    'string',           '姓名'
            .col 'employee_no',          '员工编号', 'string'
            .col 'department_ids',       '机构',    'org-search'
            .end()

        @columnDef = GridHelper.buildUserDefault [
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
        @filterOptions = filterBuildUtils('attendanceHis')
            .col 'employee_name',        '姓名',      'string',           '姓名'
            .col 'employee_no',          '员工编号',   'string'
            .col 'department_ids',       '机构',      'org-search'
            .col 'created_at',           '记录时间',   'date-range'
            .end()

        @columnDef = [
            {displayName: '员工编号', name: 'user.employeeNo'}
            {
                displayName: '姓名'
                field: 'user.name'
                # pinnedLeft: true
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
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
                name: 'user.department.name'
                cellTooltip: (row) ->
                    return row.entity.user.department.name
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
    @.$inject = ['$scope', 'Contract', '$http', 'Employee']
    constructor: (@scope, @Contract, @http, @Employee) ->
        @loadInitailData()
        @filterOptions = filterBuildUtils('contract')
            .col 'employee_name',        '姓名',        'string',           '姓名'
            .col 'employee_no',          '员工编号',     'string'
            .col 'department_name',       '机构',        'string'
            .col 'end_date',             '合同到期时间',  'date-range'
            .col 'apply_type',           '用工性质',     'string'
            .col 'notes',                '是否有备注',   'boolean'
            .end()

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
                    <div class="ui-grid-cell-contents">
                        <a nb-panel
                            template-url="partials/personnel/info_basic.html"
                            locals="{employee: row.entity.owner.$fetch()}"> 详细
                        </a>
                    </div>
                '''

            }
        ]

        @hisFilterOptions = filterBuildUtils('contractHis')
            .col 'name',                 '姓名',        'string',           '姓名'
            .col 'employee_no',          '员工编号',     'string'
            .col 'department_ids',       '机构',        'org-search'
            .end()


        @hisColumnDef = [
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
            {displayName: '开始时间', name: 'startDate', cellFilter: "enum:'channels'"}
            {displayName: '结束时间', name: 'endDate'}
            {
                displayName: '详细',
                field: '详细',
                cellTemplate: '''
                    <div class="ui-grid-cell-contents">
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

    getSelected: () ->
        rows = @scope.$gridApi.selection.getSelectedGridRows()
        selected = if rows.length >= 1 then rows[0].entity else null

    renewContract: (request, contract)->
        self = @
        return if contract && contract.employeeId == 0
        request.receptor_id = contract.employeeId
        request.reviewer_id = contract.employeeId

        @http.post("/api/workflows/Flow::RenewContract", request).then ()->
            self.contracts.$refresh()

    newContract: (contract)->
        self = @
        @contracts.$build(contract).$save().$then ()->
            self.contracts.$refresh()

    leaveJob: (contract, isConfirm, reason)->
        return if !isConfirm
        request = {}
        request.reason = reason
        request.receptor_id = contract.employeeId
        @http.post("/api/workflows/Flow::EmployeeLeaveJob", request)
        return

    loadEmployee: (params, contract)->
        self = @
        @Employee.$collection().$refresh(params).$then (employees)->
            matched = _.find employees, params
            if matched then self.loadEmp = matched;contract.employeeId = matched.id else self.loadEmp = params


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
                <div class="ui-grid-cell-contents">
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

        scope.getSelectedEntities = ()->
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

    @.$inject = ['GridHelper', 'FlowName', '$scope', 'Employee', '$injector', 'OrgStore', 'ColumnDef', '$http', '$nbEvent']

    constructor: (@helper, @FlowName, @scope, @Employee, $injector, OrgStore, @userRequestsColDef, @http, @Evt) ->

        @scope.ctrl = @
        @Flow = $injector.get(@FlowName)


        @userListName = "#{@FlowName}_USER_LIST"
        @checkListName = "#{@FlowName}_CHECK_LIST"
        @historyListName = "#{@FlowName}_HISTORY_LIST"

        @columnDef = null
        @tableData = null
        @filterOptions = null

        @reviewers =  @Employee.leaders()

    userList: ->
        filterOptions = _.cloneDeep(userListFilterOptions)
        filterOptions.name = @userListName
        @filterOptions = filterOptions
        @columnDef = _.cloneDeep(USER_LIST_TABLE_DEFS)
        @tableData = @Employee.$collection().$fetch({filter_types: [@FlowName]})

    checkList: ->
        @columnDef = @helper.buildFlowDefault(FLOW_HANDLE_TABLE_DEFS)
        filterOptions = _.cloneDeep(HANDLER_AND_HISTORY_FILTER_OPTIONS)
        filterOptions.name = @checkListName
        @filterOptions = filterOptions
        @tableData = @Flow.$collection().$fetch()

    historyList: ->
        @columnDef = @helper.buildFlowDefault(FLOW_HISTORY_TABLE_DEFS)
        filterOptions = _.cloneDeep(HANDLER_AND_HISTORY_FILTER_OPTIONS)
        filterOptions.name = @historyListName
        @filterOptions = filterOptions
        @tableData = @Flow.records()

    myRequests: ->
        @columnDef = @userRequestsColDef
        @tableData = @Flow.myRequests()


    getSelected: -> # selected entity || arr
        rows = @gridApi.selection.getSelectedGridRows()
        selected = if rows.length >= 1 then rows[0].entity else null

    getSelectedEntities: ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> row.entity

    exportGridApi: (gridApi) ->
        @gridApi = gridApi

    search: (tableState)->
        @tableData.$refresh(tableState)

    retirement: (users)->
        self = @
        params = users.map (user)->
            {id: user.id, relation_data:user.relation_data}

        @http.post("/api/workflows/Flow::Retirement/batch_create", {receptors:params}).then ()->
            self.Evt.$send "retirement:create:success", "退休发起成功"
            self.tableData.$refresh()

    leaveJob: (employeeId, isConfirm, reason)->
        return if !isConfirm
        request = {}
        request.reason = reason
        request.receptor_id = employeeId
        @http.post("/api/workflows/Flow::EmployeeLeaveJob", request)

        return

    refreshTableDate: ()->
        @tableData.$refresh({filter_types: [@FlowName]})




app.config(Route)
app.controller('AttendanceRecordCtrl', AttendanceRecordCtrl)
app.controller('AttendanceHisCtrl', AttendanceHisCtrl)
app.controller('UserListCtrl', UserListCtrl)
app.controller('ContractCtrl', ContractCtrl)
app.controller('RetirementCtrl', RetirementCtrl)
app.controller('SbFlowHandlerCtrl', SbFlowHandlerCtrl)
app.constant('ColumnDef', [])

