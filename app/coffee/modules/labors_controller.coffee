# 劳动关系
nb = @.nb
app = nb.app
filterBuildUtils = nb.filterBuildUtils

userListFilterOptions = filterBuildUtils('laborsRetirement')
    .col 'name',                 '姓名',     'string', '姓名'
    .col 'employee_no',          '员工编号', 'string'
    .col 'department_ids',       '机构',     'org-search'
    .col 'position_names',       '岗位名称', 'string_array'
    .col 'locations',            '属地',     'string_array'
    .col 'channel_ids',          '通道',     'muti-enum-search', '', {type: 'channels'}
    .col 'employment_status_id', '用工状态', 'select',           '', {type: 'employment_status'}
    .col 'gender_id',            '性别',     'select',           '', {type: 'genders'}
    .col 'birthday',             '出生日期', 'date-range'
    .col 'join_scal_date',       '入职时间', 'date-range'
    .end()


USER_LIST_TABLE_DEFS = [
    {displayName: '员工编号', name: 'employeeNo'}
    {
        displayName: '姓名'
        field: 'name'
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
            <a flow-handler="row.entity" flow-view="true" is-history="true">
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
        {
            name: 'employee_no'
            displayName: '员工编号'
            type: 'string'
        }
        {
            name: 'gender_id'
            displayName: '性别'
            type: 'select'
            params: {
                type: 'genders'
            }
        }
        {
            name: 'birthday'
            displayName: '出生日期'
            type: 'date-range'
        }
        {
            name: 'channel_ids'
            displayName: '通道'
            type: 'muti-enum-search'
            params: {
                type: 'channels'
            }
        }
        {
            name: 'department_ids'
            displayName: '机构'
            type: 'org-search'
        }
        {
            name: 'workflow_state'
            displayName: '状态'
            type: 'workflow_status_select'
        }
        {
            name: 'join_scal_date'
            displayName: '入职时间'
            type: 'date-range'
        }
        {
            name: 'created_at'
            displayName: '发起时间'
            type: 'date-range'
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
        displayName: '天数'
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
        name: 'formData.startTime'
        displayName: '开始时间'
        cellFilter: "date:'yyyy-MM-dd'"
    }
    {
        name: 'formData.endTime'
        displayName: '结束时间'
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
    {width:100, displayName: '公假', name: 'publicLeave'}
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

ATTENDANCE_SUMMERY_HIS_DEFS= [
    {width:150, displayName: '所属部门', name: 'departmentName'}
    {width:100, displayName: '员工编号', name: 'employeeNo'}
    {width:100, displayName: '姓名', name: 'employeeName'}
    {width:100, displayName: '用工性质', name: 'laborRelation'}
    {width:100, displayName: '月份', name: 'summaryDate'}
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
    {width:100, displayName: '公假', name: 'publicLeave'}
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


app.config(Route)


class AttendanceCtrl extends nb.Controller
    @.$inject = ['GridHelper', 'Leave', '$scope', '$injector', '$http', 'AttendanceSummary', 'CURRENT_ROLES', 'toaster', '$q', '$nbEvent', '$timeout']

    constructor: (helper, @Leave, scope, injector, @http, @AttendanceSummary, @CURRENT_ROLES, @toaster, @q, @Evt, @timeout) ->
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
                    name: 'summary_date'
                    displayName: '汇总时间'
                    type: 'month-list'
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
                    name: 'leave_date'
                    displayName: '起始时间'
                    type: 'date-range'
                }
                {
                    name: 'name'
                    displayName: '假别'
                    type: 'vacation_select'
                }
            ]
        }

        checkBaseDef = ATTENDANCE_BASE_TABLE_DEFS.concat [
            {
                name: 'type'
                displayName: '详细'
                cellTemplate: '''
                <div class="ui-grid-cell-contents" ng-init="realFlow = grid.appScope.$parent.realFlow(row.entity)">
                    <a ng-if="!realFlow.processed" flow-handler="realFlow" flows="grid.options.data">
                        查看
                    </a>
                    <span ng-if="realFlow.processed">已处理</span>
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

    exeSearch: (departmentId)->
        date = moment(new Date("#{this.year}-#{this.month}")).format()
        params = {summary_date: date}
        params.department_id = departmentId if departmentId

        self = @

        @search(params).$asPromise().then (data)->
            summary_record = _.find data.$response.data.meta.attendance_summary_status, (item)->
                item.department_id == departmentId

            self.departmentHrChecked = summary_record.department_hr_checked
            self.departmentLeaderChecked = summary_record.department_leader_checked
            self.hrDepartmentLeaderChecked = summary_record.hr_department_leader_checked

            angular.forEach self.tableData, (item)->
                item.departmentHrChecked = self.departmentHrChecked
                item.departmentLeaderChecked = self.departmentLeaderChecked
                item.hrDepartmentLeaderChecked = self.hrDepartmentLeaderChecked

    initDate: ()->
        @year_list = @$getYears()
        @month_list = @$getMonths()
        # @month_list.pop()
        @filter_month_list = @$getFilterMonths()

        @year = @year_list[@year_list.length - 1]
        @month = @month_list[@month_list.length - 1]

    loadCheckList: ()->
        @tableData = @Leave.$collection().$fetch()

    loadRecords: ()->
        @tableData = @Leave.records()

    loadSummaries: ()->
        @summaryCols = ATTENDANCE_SUMMERY_HIS_DEFS
        @tableData = @AttendanceSummary.$collection().$fetch({per_page: 60,summary_date: moment().subtract(1, 'months').format('YYYY-MM')})

    loadSummariesList: ()->
        self = @

        @initDate()

        if @isDepartmentHr()
            self.summaryListCol = ATTENDANCE_SUMMERY_DEFS.concat [
                {
                    width:100,
                    displayName: '编辑',
                    field: '编辑',
                    cellTemplate: '''
                        <div class="ui-grid-cell-contents">
                            <a nb-dialog
                                ng-hide="row.entity.departmentHrChecked"
                                template-url="partials/labors/attendance/summary_edit.html"
                                locals="{summary: row.entity, list_ref: row.entity.$scope}"> 编辑
                            </a>
                            <span ng-show="row.entity.departmentHrChecked">已确认</span>
                        </div>
                    '''
                }
            ]
        else
            self.summaryListCol = ATTENDANCE_SUMMERY_DEFS

        @tableData = @AttendanceSummary.records({summary_date: moment().format()})

        @AttendanceSummary.records({summary_date: moment().format()}).$asPromise().then (data)->
            summary_record = _.find data.$response.data.meta.attendance_summary_status, (item)->
                item.department_id == data.$response.data.meta.department_id

            self.departmentHrChecked = summary_record.department_hr_checked
            self.departmentLeaderChecked = summary_record.department_leader_checked
            self.hrDepartmentLeaderChecked = summary_record.hr_department_leader_checked

            angular.forEach self.tableData, (item)->
                item.departmentHrChecked = self.departmentHrChecked
                item.departmentLeaderChecked = self.departmentLeaderChecked
                item.hrDepartmentLeaderChecked = self.hrDepartmentLeaderChecked

    getDate: ()->
        date = moment(new Date("#{this.year}-#{this.month}")).format()

    departmentHrConfirm: (isConfirm)->
        self = @

        params = {summary_date: @getDate()}

        @http.put('/api/attendance_summaries/department_hr_confirm', params).then (data)->
            self.tableData.$refresh()
            erorr_msg = data.$response.data.messages
            toaster.pop('info', '提示', erorr_msg || "确认成功")
            self.departmentHrChecked = true

            angular.forEach self.tableData, (item)->
                item.departmentHrChecked = true

    departmentLeaderCheck: ()->
        self = @
        params = {summary_date: @getDate()}

        @http.put('/api/attendance_summaries/department_leader_check', params).then (data)->
            self.tableData.$refresh()
            erorr_msg = data.$response.data.messages
            toaster.pop('info', '提示', erorr_msg || "审核成功")
            self.departmentLeaderChecked = true

            angular.forEach self.tableData, (item)->
                item.departmentLeaderChecked = true

    hrLeaderCheck: ()->
        self = @
        params = {summary_date: @getDate()}

        @http.put('/api/attendance_summaries/hr_leader_check', params).then (data)->
            self.tableData.$refresh()
            erorr_msg = data.$response.data.messages
            toaster.pop('info', '提示', erorr_msg || "审核成功")
            self.hrDepartmentLeaderChecked = true

            angular.forEach self.tableData, (item)->
                item.hrDepartmentLeaderChecked = true

    search: (tableState)->
        tableState = tableState || {}
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        @tableData.$refresh(tableState)

    getSelected: ->
        if @gridApi.selection
            rows = @gridApi.selection.getSelectedGridRows()
            selected = if rows.length >= 1 then rows[0].entity else null

    getSelectedEntities: ->
        if @gridApi.selection
            rows = @gridApi.selection.getSelectedGridRows()
            rows.map (row) -> row.entity

    exportGridApi: (gridApi) ->
        @gridApi = gridApi

    transferToOccupationInjury: (record)->
        self = @
        url = "/api/workflows/#{record.type}/#{record.id}/transfer_to_occupation_injury"
        @http.put(url).then ()->
            self.tableData.$refresh()

    isDepartmentHr: ()->
        @CURRENT_ROLES.indexOf('department_hr') >= 0

    finishVacation: ()->
        # 销假的逻辑目前没有实际的数据影响


class AttendanceRecordCtrl extends nb.Controller
    @.$inject = ['$scope', 'Attendance', 'Employee', 'GridHelper', '$enum', 'CURRENT_ROLES']

    constructor: (@scope, @Attendance, @Employee, GridHelper, $enum, @CURRENT_ROLES) ->
        @loadInitialData()

        @scope.$enum = $enum
        @reviewers = @Employee.leaders()

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

    loadInitialData: ()->
        @employees = @Employee.$collection().$fetch()

    search: (tableState)->
        tableState = tableState || {}
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        @employees.$refresh(tableState)

    getSelected: () ->
        rows = @scope.$gridApi.selection.getSelectedGridRows()
        selected = if rows.length >= 1 then rows[0].entity else null

    isDepartmentHr: ()->
        @CURRENT_ROLES.indexOf('department_hr') >= 0


class AttendanceHisCtrl extends nb.Controller
    @.$inject = ['$scope', 'Attendance', 'CURRENT_ROLES']

    constructor: (@scope, @Attendance, @CURRENT_ROLES) ->
        @loadInitialData()

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

    loadInitialData: ()->
        @attendances = @Attendance.$collection().$fetch()

    search: (tableState)->
        tableState = tableState || {}
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        @attendances.$refresh(tableState)

    getSelected: () ->
        rows = @scope.$gridApi.selection.getSelectedGridRows()
        selected = if rows.length >= 1 then rows[0].entity else null

    markToDeleted: (attendance)->
        self = @
        attendance.$destroy().$then ()->
            self.attendances.$refresh()

    isDepartmentHr: ()->
        @CURRENT_ROLES.indexOf('department_hr') >= 0


class ContractCtrl extends nb.Controller
    @.$inject = ['$scope', 'Contract', '$http', 'Employee', '$nbEvent', 'toaster']

    constructor: (@scope, @Contract, @http, @Employee, @Evt, @toaster) ->
        @show_merged = true
        @loadInitialData()

        @filterOptions = filterBuildUtils('contract')
            .col 'employee_name',        '姓名',        'string',           '姓名'
            .col 'employee_no',          '员工编号',     'string'
            .col 'department_ids',       '机构',        'org-search'
            .col 'end_date',             '合同到期时间',  'date-range'
            .col 'apply_type',           '用工性质',     'apply_type_select'
            .col 'notes',                '是否有备注',   'boolean'
            .end()

        @columnDef = [
            {displayName: '员工编号', name: 'employeeNo'}
            {
                displayName: '姓名'
                field: 'employeeName'
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a nb-panel
                        ng-if="row.entity.owner!=null"
                        template-url="partials/personnel/info_basic.html"
                        locals="{employee: row.entity.owner}">
                        {{grid.getCellValue(row, col)}}
                    </a>
                    <span ng-if="row.entity.owner==null">
                        {{grid.getCellValue(row, col)}}
                    </span>
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
            {displayName: '合同结束时间', name: 'endDateStr'}
            {displayName: '备注', name: 'notes', cellTooltip: (row) -> return row.entity.note}
            {
                displayName: '详细',
                field: '详细',
                cellTemplate: '''
                    <div class="ui-grid-cell-contents" ng-init="outerScope=grid.appScope.$parent">
                        <a nb-panel
                            template-url="partials/labors/contract/detail.dialog.html"
                            locals="{contract: row.entity.$refresh(), ctrl: outerScope.ctrl}"> 详细
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


    loadInitialData: () ->
        self = @

        @contracts = @Contract.$collection().$fetch().$then () ->
            self.contracts.$refresh({'show_merged': self.show_merged})

    changeLoadRule: () ->
        @contracts.$refresh({'show_merged': @show_merged})

    search: (tableState) ->
        tableState = tableState || {}
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        tableState['show_merged'] = @show_merged
        @contracts.$refresh(tableState)

    getSelected: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        selected = if rows.length >= 1 then rows[0].entity else null

    renewContract: (request, contract)->
        self = @
        return if contract && contract.employeeId == 0

        @http.post("/api/workflows/Flow::RenewContract", request).then (data)->
            self.contracts.$refresh({'show_merged': self.show_merged})
            msg = data.data.messages
            self.Evt.$send("contract:renew:success", msg) if msg

    loadDueTime: (contract)->
        self = @
        s = contract.startDate
        e = contract.endDate

        unless contract.isUnfix
            if s && e && s <= e
                d = moment.range(s, e).diff('days')
                dueTimeStr = parseInt(d/365)+'年'+(d-parseInt(d/365)*365)+'天'
                contract.dueTime = dueTimeStr

            else
                self.toaster.pop('error', '提示', '开始时间、结束时间必填，且结束时间需大于开始时间')
                return

    showDueTime: (contract)->
        self = @
        s = contract.startDate
        e = contract.endDate

        if s && e && s <= e
            d = moment.range(s, e).diff('days')
            dueTimeStr = parseInt(d/365)+'年'+(d-parseInt(d/365)*365)+'天'
            return dueTimeStr
        else if !e
            return '无固定'

    newContract: (contract)->
        self = @

        unless contract.isUnfix
            if !contract.endDate
                self.toaster.pop('error', '提示', '非无固定合同结束时间必填')
                return

            if contract.endDate <= contract.startDate
                self.toaster.pop('error', '提示', '非无固定合同结束时间不能小于等于开始时间')
                return

        @contracts.$build(contract).$save().$then ()->
            self.contracts.$refresh({'show_merged': self.show_merged})

    clearData: (contract)->
        if contract.isUnfix
            contract.endDate = null
            contract.dueTime = null

    leaveJob: (contract, isConfirm, reason, flow_id)->
        return if !isConfirm

        self = @
        params = {}
        params.reason = reason
        params.receptor_id = contract.owner.$pk
        params.flow_id = flow_id

        params.relation_data = '<div class="flow-info-row" layout="layout"> <div class="flow-info-cell" flex="flex"> <div class="flow-cell-title">入职时间</div> <div class="flow-cell-content">{{join_scal_date}}</div> </div> <div class="flow-info-cell" flex="flex"> <div class="flow-cell-title">发起时间</div> <div class="flow-cell-content">{{created_at}}</div> </div> </div>'
        params.relation_data = params.relation_data.replace('{{join_scal_date}}', contract.owner.joinScalDate)
        params.relation_data = params.relation_data.replace('{{created_at}}', moment().format('YYYY-MM-DD'))

        @http.post("/api/workflows/Flow::EmployeeLeaveJob", params).success (data, status)->
            self.Evt.$send "employee_leavejob:create:success", "离职单发起成功"

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


class UserListCtrl extends nb.Controller
    @.$inject = ["$scope", "Employee"]

    constructor: (scope, @Employee)->
        scope.employees = @Employee.$collection().$fetch()

        scope.filterOptions = filterBuildUtils('laborsRetirement')
            .col 'name',                 '姓名',    'string',           '姓名'
            .col 'employee_no',          '员工编号', 'string'
            .col 'department_ids',       '机构',    'org-search'
            .col 'position_name',        '岗位名称', 'string'
            .col 'location',             '属地',    'string'
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
        tableState = tableState || {}
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        @retirements.$refresh(tableState)


class SbFlowHandlerCtrl
    @.$inject = ['GridHelper', 'FlowName', '$scope', 'Employee', '$injector', 'OrgStore', 'ColumnDef', '$http', '$nbEvent', 'CURRENT_ROLES', '$enum', 'USER_META']

    constructor: (@helper, @FlowName, @scope, @Employee, $injector, OrgStore, @userRequestsColDef, @http, @Evt, @CURRENT_ROLES, @enum, @meta) ->
        @scope.ctrl = @
        @Flow = $injector.get(@FlowName)

        @userListName = "#{@FlowName}_USER_LIST"
        @checkListName = "#{@FlowName}_CHECK_LIST"
        @historyListName = "#{@FlowName}_HISTORY_LIST"

        @columnDef = null
        @tableData = null
        @filterOptions = null

        @reviewers =  @Employee.leaders()

        relationName = @enum.parseLabel(@meta.labor_relation_id, 'labor_relations')
        @canCreateEarlyRetirement = (["合同", "合同制"].indexOf(relationName) >= 0)

    userList: ->
        filterOptions = _.cloneDeep(userListFilterOptions)
        filterOptions.name = @userListName
        @filterOptions = filterOptions
        @columnDef = _.cloneDeep(USER_LIST_TABLE_DEFS)
        @tableData = @Employee.$collection().$fetch({filter_types: [@FlowName]})

    checkList: ->
        @columnDef = @helper.buildFlowDefault(FLOW_HANDLE_TABLE_DEFS)

        if @FlowName == 'Flow::Retirement'
            @columnDef.splice 2, 0, {displayName: '出生日期', name: 'receptor.birthday'}
            @columnDef.splice 7, 0, {displayName: '申请发起时间', name: 'createdAt'}

        if @FlowName == 'Flow::EarlyRetirement'
            @columnDef.splice 2, 0, {displayName: '出生日期', name: 'receptor.birthday'}
            @columnDef.splice 2, 0, {displayName: '性别', name: 'receptor.genderId', cellFilter: "enum:'genders'"}

        if @FlowName == 'Flow::AdjustPosition'
            @columnDef.splice 4, 0, {displayName: '转入部门', name: 'toDepartmentName'}
            @columnDef.splice 5, 1, {displayName: '转入岗位', name: 'toPositionName'}

        if @FlowName == 'Flow::EmployeeLeaveJob'
            @columnDef.splice 6, 0, {displayName: '用工性质', name: 'receptor.laborRelationId', cellFilter: "enum:'labor_relations'"}
            @columnDef.splice 6, 0, {displayName: '申请发起时间', name: 'createdAt'}

        filterOptions = _.cloneDeep(HANDLER_AND_HISTORY_FILTER_OPTIONS)
        filterOptions.name = @checkListName
        @filterOptions = filterOptions

        @tableData = @Flow.$collection().$fetch()

    historyList: ->
        @columnDef = @helper.buildFlowDefault(FLOW_HISTORY_TABLE_DEFS)

        if @FlowName == 'Flow::Retirement'
            @columnDef.splice 2, 0, {displayName: '出生日期', name: 'receptor.birthday'}
            @columnDef.splice 7, 0, {displayName: '申请发起时间', name: 'createdAt'}

        if @FlowName == 'Flow::AdjustPosition'
            @columnDef.splice 4, 0, {displayName: '转入部门', name: 'toDepartmentName'}
            @columnDef.splice 5, 1, {displayName: '转入岗位', name: 'toPositionName'}

        if @FlowName == 'Flow::Resignation' || @FlowName == 'Flow::Retirement' || @FlowName == 'Flow::Dismiss'
            @columnDef.splice 6, 0, {displayName: '离职发起', name: 'leaveJobFlowState'}

        if @FlowName == 'Flow::Resignation'
            @columnDef.splice 6, 0, {displayName: '用工性质', name: 'receptor.laborRelationId', cellFilter: "enum:'labor_relations'"}

        filterOptions = _.cloneDeep(HANDLER_AND_HISTORY_FILTER_OPTIONS)

        if @FlowName == 'Flow::Resignation' || @FlowName == 'Flow::Retirement' || @FlowName == 'Flow::Dismiss'
            filterOptions.constraintDefs.splice 10, 0, {displayName: '离职发起', name: 'leave_job_state', type: 'leave_job_state_select'}

        filterOptions.name = @historyListName
        @filterOptions = filterOptions
        @tableData = @Flow.records()

    myRequests: ->
        @columnDef = @userRequestsColDef
        @tableData = @Flow.myRequests()

    getSelected: ->
        return null unless @gridApi.selection
        rows = @gridApi.selection.getSelectedGridRows()
        selected = if rows.length >= 1 then rows[0].entity else null

    getSelectedEntities: ->
        return [] unless @gridApi.selection
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> row.entity

    exportGridApi: (gridApi) ->
        @gridApi = gridApi

    search: (tableState)->
        tableState = tableState || {}
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        @tableData.$refresh(tableState)

    retirement: (users)->
        self = @

        params = users.map (user)->
            {id: user.id, relation_data: user.relation_data, retirement_date: user.retirementDate}

        @http.post("/api/workflows/Flow::Retirement/batch_create", {receptors: params}).success (data, status)->
            self.Evt.$send "retirement:create:success", "退休发起成功"
            self.tableData.$refresh()

    leaveJob: (employeeId, isConfirm, reason, flow_id, join_scal_date)->
        return if !isConfirm

        self = @

        params = {}
        params.reason = reason
        params.receptor_id = employeeId
        params.flow_id = flow_id

        params.relation_data = '<div class="flow-info-row" layout="layout"> <div class="flow-info-cell" flex="flex"> <div class="flow-cell-title">入职时间</div> <div class="flow-cell-content">{{join_scal_date}}</div> </div> <div class="flow-info-cell" flex="flex"> <div class="flow-cell-title">发起时间</div> <div class="flow-cell-content">{{created_at}}</div> </div> </div>'
        params.relation_data = params.relation_data.replace('{{join_scal_date}}', join_scal_date)
        params.relation_data = params.relation_data.replace('{{created_at}}', moment().format('YYYY-MM-DD'))

        @http.post("/api/workflows/Flow::EmployeeLeaveJob", params).success (data, status)->
            self.Evt.$send "employee_leavejob:create:success", "离职单发起成功"
            self.refreshTableData()

    refreshTableData: ()->
        @tableData.$refresh({filter_types: [@FlowName]})

    revert: (isConfirm, record)->
        self = @

        if isConfirm
            record.revert().$asPromise().then ()->
                self.tableData.$refresh()

    isDepartmentHr: ()->
        @CURRENT_ROLES.indexOf('department_hr') >= 0

    isHrLaborRelationMember: ()->
        @CURRENT_ROLES.indexOf('hr_labor_relation_member') >= 0

app.controller('AttendanceRecordCtrl', AttendanceRecordCtrl)
app.controller('AttendanceHisCtrl', AttendanceHisCtrl)
app.controller('UserListCtrl', UserListCtrl)
app.controller('ContractCtrl', ContractCtrl)
app.controller('RetirementCtrl', RetirementCtrl)
app.controller('SbFlowHandlerCtrl', SbFlowHandlerCtrl)

app.constant('ColumnDef', [])
