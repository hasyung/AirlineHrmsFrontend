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
    {minWidth: 120, displayName: '员工编号', name: 'employeeNo'}
    {
        minWidth: 120
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
        minWidth: 350
        displayName: '所属部门'
        name: 'department.name'
        cellTooltip: (row) ->
            return row.entity.department.name
    }
    {
        minWidth: 250
        displayName: '岗位'
        name: 'position.name'
        cellTooltip: (row) ->
            return row.entity.position.name
    }
    {minWidth: 120, displayName: '分类', name: 'categoryId', cellFilter: "enum:'categories'"}
    {minWidth: 120, displayName: '通道', name: 'channelId', cellFilter: "enum:'channels'"}
    {minWidth: 120, displayName: '用工性质', name: 'laborRelationId', cellFilter: "enum:'labor_relations'"}
    {minWidth: 120, displayName: '到岗时间', name: 'joinScalDate'}
]


FLOW_HANDLE_TABLE_DEFS =  [
    {
        minWidth: 120
        name: 'receptor.channelId'
        displayName: '通道'
        cellFilter: "enum:'channels'"
    }
    {
        minWidth: 120
        name: 'workflowState'
        displayName: '状态'
    }
    {
        minWidth: 120
        name: 'createdAt'
        displayName: '申请发起时间'
        cellFilter: "date:'yyyy-MM-dd'"
    }
    {
        minWidth: 120
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
        minWidth: 120
        name: 'receptor.channelId'
        displayName: '通道'
        cellFilter: "enum:'channels'"
    }
    {
        minWidth: 120
        name: 'workflowState'
        displayName: '状态'
    }
    {
        minWidth: 120
        name: 'createdAt'
        displayName: '出生日期'
        cellFilter: "date:'yyyy-MM-dd'"
    }
    {
        minWidth: 120
        name: 'createdAt'
        displayName: '申请发起时间'
        cellFilter: "date:'yyyy-MM-dd'"
    }
    {
        minWidth: 120
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
        minWidth: 120
        name: 'name'
        displayName: '假别'
        cellTooltip: (row) ->
            return row.entity.name
    }
    {
        minWidth: 120
        name: 'vacationDays'
        displayName: '天数'
    }
    {
        minWidth: 120
        name: 'workflowState'
        displayName: '状态'
    }
    {
        minWidth: 120
        name: 'createdAt'
        displayName: '发起时间'
        cellFilter: "date:'yyyy-MM-dd'"
    }
    {
        minWidth: 120
        name: 'formData.startTime'
        displayName: '开始时间'
        cellFilter: "date:'yyyy-MM-dd'"
    }
    {
        minWidth: 120
        name: 'formData.endTime'
        displayName: '结束时间'
        cellFilter: "date:'yyyy-MM-dd'"
    }
]


ATTENDANCE_SUMMERY_DEFS= [
    {width:120, displayName: '所属部门', name: 'departmentName'}
    {width:100, displayName: '员工编号', name: 'employeeNo'}
    {width:100, displayName: '姓名', name: 'employeeName'}
    {width:100, displayName: '用工性质', name: 'laborRelation'}
    {width:100, displayName: '<带薪假>', name: 'paidLeave'}
    {width:100, displayName: '年假', name: 'annualLeave'}
    {width:100, displayName: '补休假', name: 'offsetLeave'}
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
    {width:130, displayName: '病假（工伤待定）', name: 'sickLeaveInjury'}
    {width:130, displayName: '病假（怀孕待产）', name: 'sickLeaveNulliparous'}
    {width:100, displayName: '病假总计', name: 'sickDays'}
    {width:100, displayName: '病假工作日', name: 'sickWorkDays'}
    {width:100, displayName: '事假', name: 'personalLeave'}
    {width:100, displayName: '事假工作日', name: 'personalLeaveWorkDays'}
    {width:100, displayName: '公假', name: 'publicLeave'}
    {width:100, displayName: '探亲假', name: 'homeLeave'}
    {width:120, displayName: '探亲假工作日', name: 'homeLeaveWorkDays'}
    {width:100, displayName: '培训', name: 'cultivate'}
    {width:100, displayName: '培训工作日', name: 'cultivateWorkDays'}
    {width:100, displayName: '出差', name: 'evection'}
    {width:100, displayName: '出差工作日', name: 'evectionWorkDays'}
    {width:100, displayName: '旷工', name: 'absenteeism'}
    {width:100, displayName: '迟到早退', name: 'lateOrLeave'}
    {width:100, displayName: '空勤停飞', name: 'ground'}
    {width:120, displayName: '空勤停飞工作日', name: 'flightGroundedWorkDays'}
    {width:120, displayName: '空勤地面工作', name: 'surfaceWork'}
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
    {width:100, displayName: '补休假', name: 'offsetLeave'}
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
    {width:130, displayName: '病假（工伤待定）', name: 'sickLeaveInjury'}
    {width:130, displayName: '病假（怀孕待产）', name: 'sickLeaveNulliparous'}
    {width:100, displayName: '病假总计', name: 'sickDays'}
    {width:100, displayName: '病假工作日', name: 'sickWorkDays'}
    {width:100, displayName: '事假', name: 'personalLeave'}
    {width:100, displayName: '事假工作日', name: 'personalLeaveWorkDays'}
    {width:100, displayName: '公假', name: 'publicLeave'}
    {width:100, displayName: '探亲假', name: 'homeLeave'}
    {width:120, displayName: '探亲假工作日', name: 'homeLeaveWorkDays'}
    {width:100, displayName: '培训', name: 'cultivate'}
    {width:100, displayName: '培训工作日', name: 'cultivateWorkDays'}
    {width:100, displayName: '出差', name: 'evection'}
    {width:100, displayName: '出差工作日', name: 'evectionWorkDays'}
    {width:100, displayName: '旷工', name: 'absenteeism'}
    {width:100, displayName: '迟到早退', name: 'lateOrLeave'}
    {width:100, displayName: '空勤停飞', name: 'ground'}
    {width:120, displayName: '空勤停飞工作日', name: 'flightGroundedWorkDays'}
    {width:120, displayName: '空勤地面工作', name: 'surfaceWork'}
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
            .state 'protocol_management', {
                url: '/protocol-management'
                templateUrl: 'partials/labors/protocol/index.html'
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
            .state 'cabin_management', {
                url: '/cabin_management'
                templateUrl: 'partials/labors/cabin/index.html'
            }

app.config(Route)


class AttendanceCtrl extends nb.Controller
    @.$inject = ['GridHelper', 'Leave', '$scope', '$injector', '$http', 'AttendanceSummary', 'CURRENT_ROLES', 'toaster', '$q', '$nbEvent', '$timeout', 'USER_META']

    constructor: (helper, @Leave, scope, injector, @http, @AttendanceSummary, @CURRENT_ROLES, @toaster, @q, @Evt, @timeout, @User) ->
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
                {
                    name: 'state'
                    displayName: '状态'
                    type: 'muti-enum-search'
                    params: {
                        type: 'workflow_state'
                    }
                }
            ]
        }

        # mouseover进行hack数据刷新 很不科学 存在问题
        checkBaseDef = ATTENDANCE_BASE_TABLE_DEFS.concat [
            {
                minWidth: 120
                name: 'type'
                displayName: '详细'
                cellTemplate: '''
                <div class="ui-grid-cell-contents" ng-mouseover="realFlow = grid.appScope.$parent.realFlow(row.entity)">
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
                minWidth: 120
                name: 'type'
                displayName: '详细'
                cellTemplate: '''
                <div class="ui-grid-cell-contents" ng-mouseover="realFlow = grid.appScope.$parent.realFlow(row.entity)">
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
        params = {summary_date: date, employee_name: this.employee_name, employee_no: this.employee_no}
        params.department_id = departmentId if departmentId

        self = @

        #console.error params
        @search(params).$asPromise().then (data)->
            summary_record = _.find data.$response.data.meta.attendance_summary_status, (item)->
                item.department_id == departmentId

            if angular.isDefined(summary_record)
                self.departmentHrChecked = summary_record.department_hr_checked
                self.departmentLeaderChecked = summary_record.department_leader_checked
                self.hrLaborRelationMemberChecked = summary_record.hr_labor_relation_member_checked
                self.hrDepartmentLeaderChecked = summary_record.hr_department_leader_checked

            angular.forEach self.tableData, (item)->
                item.departmentHrChecked = self.departmentHrChecked
                item.departmentLeaderChecked = self.departmentLeaderChecked
                item.hrLaborRelationMemberChecked = self.hrLaborRelationMemberChecked
                item.hrDepartmentLeaderChecked = self.hrDepartmentLeaderChecked

    initDate: ()->
        @year_list = @$getYears()
        @month_list = @$getMonths()
        # @month_list.pop()
        @filter_month_list = @$getFilterMonths()

        @year = @year_list[@year_list.length - 1]
        @month = @month_list[@month_list.length - 1]

    loadMonthList: () ->
        if @year == new Date().getFullYear()
            months = [1..new Date().getMonth() + 1]
        else
            months = [1..12]

        @month_list = _.map months, (item)->
            item = '0' + item if item < 10
            item + ''

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
                    width:120,
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

            if angular.isDefined(summary_record)
                self.departmentHrChecked = summary_record.department_hr_checked
                self.departmentLeaderChecked = summary_record.department_leader_checked
                self.hrLaborRelationMemberChecked = summary_record.hr_labor_relation_member_checked
                self.hrDepartmentLeaderChecked = summary_record.hr_department_leader_checked

            angular.forEach self.tableData, (item)->
                item.departmentHrChecked = self.departmentHrChecked
                item.departmentLeaderChecked = self.departmentLeaderChecked
                item.hrLaborRelationMemberChecked = self.hrLaborRelationMemberChecked
                item.hrDepartmentLeaderChecked = self.hrDepartmentLeaderChecked

    getDate: ()->
        date = moment(new Date("#{this.year}-#{this.month}")).format()

    departmentHrConfirm: (isConfirm)->
        self = @

        params = {summary_date: @getDate()}

        if isConfirm
            @startLoading();
            @http.put('/api/attendance_summaries/department_hr_confirm', params).then (data)->
                self.cancelLoading()
                self.tableData.$refresh()
                self.departmentHrChecked = true

                angular.forEach self.tableData, (item)->
                    item.departmentHrChecked = true

                erorr_msg = data.$response.data.messages if angular.isDefined data.$response
                self.toaster.pop('info', '提示', erorr_msg || "确认成功")

    administratorConfirm: (isConfirm)->
        self = @

        params = {summary_date: @getDate()}

        if isConfirm
            @http.put('/api/attendance_summaries/administrator_check', params).then (data)->
                self.tableData.$refresh()
                self.hrDepartmentLeaderChecked = true

                angular.forEach self.tableData, (item)->
                    item.hrDepartmentLeaderChecked = true

                erorr_msg = data.$response.data.messages if angular.isDefined data.$response
                self.toaster.pop('info', '提示', erorr_msg || "确认成功")

    departmentLeaderCheck: (opinion)->
        self = @
        params = {summary_date: @getDate(), department_leader_opinion: opinion}

        @http.put('/api/attendance_summaries/department_leader_check', params).then (data)->
            self.tableData.$refresh()
            self.departmentLeaderChecked = true

            angular.forEach self.tableData, (item)->
                item.departmentLeaderChecked = true

            erorr_msg = data.$response.data.messages if angular.isDefined data.$response
            self.toaster.pop('info', '提示', erorr_msg || "审核成功")

    laborManagerCheck: (opinion)->
        self = @
        params = {summary_date: @getDate(), hr_labor_relation_member_opinion: opinion}

        @http.put('/api/attendance_summaries/hr_labor_relation_member_check', params).then (data)->
            self.tableData.$refresh()
            self.hrLaborRelationMemberChecked = true

            angular.forEach self.tableData, (item)->
                item.hrLaborRelationMemberChecked = true

            erorr_msg = data.$response.data.messages if angular.isDefined data.$response
            self.toaster.pop('info', '提示', erorr_msg || "审核成功")

    hrLeaderCheck: (opinion)->
        self = @
        params = {summary_date: @getDate(), hr_department_leader_opinion: opinion}

        @http.put('/api/attendance_summaries/hr_leader_check', params).then (data)->
            self.tableData.$refresh()
            self.hrDepartmentLeaderChecked = true

            angular.forEach self.tableData, (item)->
                item.hrDepartmentLeaderChecked = true

            erorr_msg = data.$response.data.messages if angular.isDefined data.$response
            self.toaster.pop('info', '提示', erorr_msg || "审核成功")

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

    getCheckInfo: (tableData) ->
        self = @

        currentDepId = tableData.$metadata.department_id

        _.map tableData.$metadata.attendance_summary_status, (dep) ->
            if dep.department_id == currentDepId
                self.depCheckInfo = dep
                return

    finishVacation: ()->
        # 销假的逻辑目前没有实际的数据影响

    revertLeave: (isConfirm, leave)->
        self = @

        if isConfirm
            leave.revert().$asPromise().then ()->
                self.tableData.$refresh()


class AttendanceRecordCtrl extends nb.Controller
    @.$inject = ['$scope', 'Attendance', 'AttendanceDepartment', 'Employee', 'GridHelper', '$enum', 'CURRENT_ROLES', '$q', '$http', 'toaster', '$nbEvent', '$rootScope']

    constructor: (@scope, @Attendance, @AttendanceDepartment, @Employee, GridHelper, $enum, @CURRENT_ROLES, @q, @http, @toaster, @Evt, @rootScope) ->
        @loadInitialData()

        @scope.$enum = $enum
        @reviewers = null

        @filterOptions = filterBuildUtils('attendanceRecord')
            .col 'name',                 '姓名',    'string',           '姓名'
            .col 'employee_no',          '员工编号', 'string'
            .col 'department_ids',       '机构',    'org-search'
            .end()

        @columnDef = GridHelper.buildUserDefault [
            {minWidth: 120, displayName: '分类', name: 'categoryId', cellFilter: "enum:'categories'", enableCellEdit: false}
            {minWidth: 120, displayName: '通道', name: 'channelId', cellFilter: "enum:'channels'", enableCellEdit: false}
            {minWidth: 120, displayName: '用工性质', name: 'laborRelationId', cellFilter: "enum:'labor_relations'", enableCellEdit: false}
            {minWidth: 120, displayName: '到岗时间', name: 'joinScalDate', enableCellEdit: false}
            {minWidth: 120, displayName: '补休假天数', name: 'offsetDays', headerCellClass: 'editable_cell_header', enableCellEdit: true, type: 'number'}
        ]

    initialize: (gridApi) ->
        self = @

        saveRow = (rowEntity) ->
            dfd = @q.defer()

            gridApi.rowEdit.setSavePromise(rowEntity, dfd.promise)

            @http({
                method: 'POST'
                url: '/api/employees/' + rowEntity.id + '/set_offset_days'
                data: {
                    id: rowEntity.id
                    days: rowEntity.offsetDays
                }
            })
            .success (data) ->
                dfd.resolve()
                self.toaster.pop('success', '提示', '修改补休假天数成功')
            .error () ->
                dfd.reject()
                rowEntity.$restore()

        gridApi.rowEdit.on.saveRow(@scope, saveRow.bind(@))
        @scope.$gridApi = gridApi

    getReviewers: (employee) ->
        self = @

        @Employee.flow_leaders(employee.id).$asPromise().then (data) ->
            self.reviewers = data

    # 假期录入 不需要审批 所有字段非必填
    attendanceEntry: (request, receptor, type, panel) ->
        self = @

        params = request
        params.type = type
        params.receptor_id = receptor.id

        @http.post('/api/workflows/instead_leave/instead_leave', params).success ()->
            self.toaster.pop('success', '提示', '假期录入成功')
            panel.close()
        .error ()->
            self.toaster.pop('error', '提示', '假期录入失败')

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

    # 员工异动创建的各方法 from 员工异动 此处的方法没有对异动员工信息列表刷新
    loadEmployee: (params, moveEmployee)->
        self = @

        @Employee.$collection().$refresh(params).$then (employees)->
            args = _.mapKeys params, (value, key) ->
                _.camelCase key

            matched = _.find employees, args

            if matched
                self.loadEmp = matched
                moveEmployee.employee_id = matched.$pk
            else
                self.loadEmp = params

    newStopEmployee: (moveEmployee)->
        self = @
        # moveEmployee.department_id = moveEmployee.department_id.$pk if moveEmployee.department_id

        @http.post('/api/special_states/temporarily_stop_air_duty', moveEmployee).then (data)->
            msg = data.messages

            if data.status == 200
                self.Evt.$send("special_state:save:success", msg || "创建成功")
            else
                self.Evt.$send('special_state:save:error', msg || "创建失败")


    newBorrowEmployee: (moveEmployee)->
        self = @

        params = {}
        moveEmployee.department_id = moveEmployee.department.$pk if moveEmployee.department
        params.department_id = moveEmployee.department_id
        params.out_company = moveEmployee.out_company
        params.employee_id = moveEmployee.employee_id
        params.special_date_from = moveEmployee.special_date_from
        params.special_date_to = moveEmployee.special_date_to
        params.file_no = moveEmployee.file_no

        @http.post('/api/special_states/temporarily_transfer', params).then (data)->
            msg = data.messages

            if data.status == 200
                self.Evt.$send("special_state:save:success", msg || "创建成功")
            else
                self.Evt.$send('special_state:save:error', msg || "创建失败")

    newAccreditEmployee: (moveEmployee)->
        self = @

        @http.post('/api/special_states/temporarily_defend', moveEmployee).then (data)->
            msg = data.messages

            if data.status == 200
                self.Evt.$send("special_state:save:success", msg || "创建成功")
            else
                self.Evt.$send('special_state:save:error', msg || "创建失败")

    newBusinessEmployee: (moveEmployee)->
        self = @

        params = {}
        moveEmployee.department_id = moveEmployee.department.$pk if moveEmployee.department
        params.department_id = moveEmployee.department_id
        params.out_company = moveEmployee.out_company
        params.employee_id = moveEmployee.employee_id
        params.special_date_from = moveEmployee.special_date_from
        params.special_date_to = moveEmployee.special_date_to
        params.file_no = moveEmployee.file_no

        @http.post('/api/special_states/temporarily_business_trip', params).then (data)->
            msg = data.messages

            if data.status == 200
                self.Evt.$send("special_state:save:success", msg || "创建成功")
            else
                self.Evt.$send('special_state:save:error', msg || "创建失败")

    # 安排离岗培训
    newTrainEmployee: (moveEmployee, dialog)->
        self = @

        if moveEmployee.special_date_from && moveEmployee.special_date_to
            start = moment(moveEmployee.special_date_from)
            end = moment(moveEmployee.special_date_to)

            if start < end
                @http.post('/api/special_states/temporarily_train', moveEmployee).then (data)->
                    self.Evt.$send("moveEmployee:save:success", '离岗培训设置成功')
                    dialog.close()
            else
                self.toaster.pop('error', '提示', '日期填写不正确，开始日期不能大于结束日期')

    uploadAnnualDays: (type, attachment_id)->
        self = @

        params = {type: type, attachment_id: attachment_id}
        @importing = true

        @http.post("/api/vacations/import_annual_days", params).success (data, status) ->
            self.toaster.pop('success', '提示', '导入成功')
            self.importing = false
        .error (data) ->
            self.toaster.pop('error', '提示', '导入失败')
            self.importing = false

    loadMonthList: () ->
        @$getFilterMonths()

    loadAttendanceDepartments: () ->
        @departments = @AttendanceDepartment.$collection().$refresh({summary_date: @attendanceImportMonth})

    uploadAttendance: (type, attachment_id, departmentId, month, dialog)->
        self = @

        params = {type: type, attachment_id: attachment_id, month: month, department_id: departmentId}
        @importing = true

        @http.post("/api/attendance_summaries/import", params).success (data, status) ->
            self.toaster.pop('success', '提示', '导入成功')
            self.importing = false
            self.rootScope.downloadUrl = data.path
            dialog.close()
        .error (data) ->
            self.toaster.pop('error', '提示', '导入失败')
            self.importing = false


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
            {minWidth: 120, displayName: '员工编号', name: 'user.employeeNo'}
            {
                minWidth: 120
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
                minWidth: 350
                displayName: '所属部门'
                name: 'user.department.name'
                cellTooltip: (row) ->
                    return row.entity.user.department.name
            }

            {
                minWidth: 250
                displayName: '岗位'
                name: 'user.position.name'
                cellTooltip: (row) ->
                    return row.entity.user.position.name
            }
            {minWidth: 120, displayName: '分类', name: 'user.categoryId', cellFilter: "enum:'categories'"}
            {minWidth: 120, displayName: '通道', name: 'user.channelId', cellFilter: "enum:'channels'"}
            {minWidth: 120, displayName: '考勤类别', name: 'recordType'}
            {minWidth: 120, displayName: '记录时间', name: 'recordDate'}
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
    @.$inject = ['$scope', 'Contract', '$http', 'EmployeesHasEarlyRetire', '$nbEvent', 'toaster', 'CURRENT_ROLES', 'PERMISSIONS']

    constructor: (@scope, @Contract, @http, @EmployeesHasEarlyRetire, @Evt, @toaster, @CURRENT_ROLES, @permissions) ->
        @show_merged = false
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
            {minWidth: 120, displayName: '员工编号', name: 'employeeNo'}
            {
                minWidth: 120
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
                minWidth: 350
                displayName: '所属部门'
                name: 'departmentName'
                cellTooltip: (row) ->
                    return row.entity.departmentName
            }
            {
                minWidth: 250
                displayName: '岗位'
                name: 'positionName'
                cellTooltip: (row) ->
                    return row.entity.positionName
            }
            {minWidth: 120, displayName: '用工性质', name: 'applyType'}
            {minWidth: 120, displayName: '变更标志', name: 'changeFlag'}
            {minWidth: 120, displayName: '合同开始时间', name: 'startDate', cellFilter: "date:'yyyy-MM-dd'"}
            {minWidth: 120, displayName: '合同结束时间', name: 'endDateStr', cellFilter: "date:'yyyy-MM-dd'"}
            {minWidth: 200, displayName: '备注', name: 'notes', cellTooltip: (row) -> return row.entity.note}
            {
                minWidth: 120
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
            {minWidth: 120, displayName: '员工编号', name: 'employeeNo'}
            {
                minWidth: 120
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
                minWidth: 350
                displayName: '所属部门'
                name: 'departmentName'
                cellTooltip: (row) ->
                    return row.entity.departmentName
            }

            {
                minWidth: 250
                displayName: '岗位'
                name: 'positionName'
                cellTooltip: (row) ->
                    return row.entity.positionName
            }
            {minWidth: 120, displayName: '用工性质', name: 'applyType'}
            {minWidth: 120, displayName: '变更标志', name: 'changeFlag'}
            {minWidth: 120, displayName: '开始时间', name: 'startDate', cellFilter: "date:'yyyy-MM-dd'"}
            {minWidth: 120, displayName: '结束时间', name: 'endDate', cellFilter: "date:'yyyy-MM-dd'"}
            {
                minWidth: 120
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

        #根据权限 contracts_update 控制是否可以编辑表单
        @editable = _.includes @permissions,'contracts_update'

    isHrLaborRelationMember: ()->
        @CURRENT_ROLES.indexOf('hr_labor_relation_member') >= 0

    loadInitialData: () ->
        self = @

        @contracts = @Contract.$collection().$fetch().$then () ->
            self.contracts.$refresh({'show_merged': self.show_merged})

    changeLoadRule: () ->
        if @show_merged
            @columnDef.splice -1, 1
        else
            @columnDef.splice 10, 0, {
                minWidth: 120
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

        tableState = @tableState || {}
        tableState['show_merged'] = @show_merged
        @contracts.$refresh(tableState)

    updateContract: (model)->
        tableState = @tableState || {}
        tableState['show_merged'] = @show_merged

        model.$save().$then (data) ->
            self.toaster.pop('success', '更新成功', data.messages)
            self.contracts.$refresh(tableState)

    search: (tableState) ->
        tableState = tableState || {}
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        tableState['show_merged'] = @show_merged
        @contracts.$refresh(tableState)
        @tableState = tableState

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

        @EmployeesHasEarlyRetire.$collection().$refresh(params).$then (employees)->
            args = _.mapKeys params, (value, key) ->
                _.camelCase key

            matched = _.find employees, args

            if matched
                self.loadEmp = matched
                contract.owner = matched
            else
                self.loadEmp = params

    uploadContract: (attachment_id)->
        self = @
        params = {attachment_id: attachment_id}
        tableState = @tableState || {}
        tableState['show_merged'] = @show_merged

        @http.post("/api/contracts/import", params).success (data, status) ->
            self.importing = false
            if data.error_count > 0
                self.toaster.pop('error', '提示', '有' + data.error_count + '个导入失败')
            else
                self.contracts.$refresh(tableState)
                self.toaster.pop('success', '提示', '导入成功')
        .error () ->
            self.importing = false


class ProtocolCtrl extends nb.Controller
    @.$inject = ['$scope', 'Protocol', '$http', 'Employee', '$nbEvent', 'toaster', 'CURRENT_ROLES', 'PERMISSIONS']

    constructor: (@scope, @Protocol, @http, @Employee, @Evt, @toaster, @CURRENT_ROLES, @permissions) ->
        @loadInitialData()

        @tableState = null

        @filterOptions = filterBuildUtils('contract')
            .col 'employee_name',        '姓名',        'string',           '姓名'
            .col 'employee_no',          '员工编号',     'string'
            .col 'department_ids',       '机构',        'org-search'
            .col 'end_date',             '协议到期时间',  'date-range'
            .end()

        @columnDef = [
            {minWidth: 120, displayName: '员工编号', name: 'employeeNo'}
            {
                minWidth: 120
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
                minWidth: 350
                displayName: '所属部门'
                name: 'departmentName'
                cellTooltip: (row) ->
                    return row.entity.departmentName
            }
            {
                minWidth: 250
                displayName: '岗位'
                name: 'positionName'
                cellTooltip: (row) ->
                    return row.entity.positionName
            }
            {minWidth: 120, displayName: '用工性质', name: 'applyType'}
            {minWidth: 120, displayName: '协议开始时间', name: 'startDate', cellFilter: "date:'yyyy-MM-dd'"}
            {minWidth: 120, displayName: '协议结束时间', name: 'endDate', cellFilter: "date:'yyyy-MM-dd'"}
            {minWidth: 200, displayName: '备注', name: 'note', cellTooltip: (row) -> return row.entity.note}
            {
                minWidth: 120
                displayName: '详细',
                field: '详细',
                cellTemplate: '''
                    <div class="ui-grid-cell-contents" ng-init="outerScope=grid.appScope.$parent">
                        <a nb-panel
                            template-url="partials/labors/protocol/detail.html"
                            locals="{protocol: row.entity.$refresh(), ctrl: outerScope.ctrl}"> 详细
                        </a>
                    </div>
                '''
            }
        ]

        #根据权限 agreements_update 控制是否可以编辑表单
        @editable = _.includes @permissions,'agreements_update'

    isHrLaborRelationMember: ()->
        @CURRENT_ROLES.indexOf('hr_labor_relation_member') >= 0

    loadInitialData: () ->
        self = @

        @protocols = @Protocol.$collection().$fetch().$then () ->
            self.protocols.$refresh()

    updateProtocol: (model)->
        self = @
        tableState = @tableState || {}

        model.$save().$then (data) ->
            self.protocols.$refresh(tableState)

    search: (tableState) ->
        @tableState = tableState || {}
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        @protocols.$refresh(@tableState)

    loadDueTime: (protocol)->
        self = @
        s = protocol.startDate
        e = protocol.endDate

        unless protocol.isUnfix
            if s && e && s <= e
                # d = moment.range(s, e).diff('days')
                # dueTimeStr = parseInt(d/365)+'年'+(d-parseInt(d/365)*365)+'天'
                # protocol.dueTime = dueTimeStr

            else
                self.toaster.pop('error', '提示', '开始时间、结束时间必填，且结束时间需大于开始时间')
                return

    showDueTime: (protocol)->
        self = @
        s = protocol.startDate
        e = protocol.endDate

        if s && e && s <= e
            d = moment.range(s, e).diff('days')
            dueTimeStr = parseInt(d/365)+'年'+(d-parseInt(d/365)*365)+'天'
            return dueTimeStr
        else if !e
            return '无固定'

    newProtocol: (protocol)->
        self = @

        if !protocol.endDate
            self.toaster.pop('error', '提示', '协议结束时间必填')
            return

        if protocol.endDate <= protocol.startDate
            self.toaster.pop('error', '提示', '协议结束时间不能小于等于开始时间')
            return

        @protocols.$build(protocol).$save().$then ()->
            self.protocols.$refresh()

    clearData: (protocol)->
        if protocol.isUnfix
            protocol.endDate = null
            protocol.dueTime = null

    loadEmployee: (params, protocol)->
        self = @

        @Employee.$collection().$refresh(params).$then (employees)->
            args = _.mapKeys params, (value, key) ->
                _.camelCase key

            matched = _.find employees, args

            if matched
                self.loadEmp = matched
                protocol.owner = matched
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
                minWidth: 350
                displayName: '所属部门'
                name: 'department.name'
                cellTooltip: (row) ->
                    return row.entity.department.name
            }
            {
                minWidth: 120
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
            {minWidth: 120, displayName: '员工编号', name: 'employeeNo'}
            {
                minWidth: 120
                displayName: '岗位'
                name: 'position.name'
                cellTooltip: (row) ->
                    return row.entity.position.name
            }
            {minWidth: 120, displayName: '分类', name: 'categoryId', cellFilter: "enum:'categories'"}
            {minWidth: 120, displayName: '通道', name: 'channelId', cellFilter: "enum:'channels'"}
            {minWidth: 120, displayName: '用工性质', name: 'laborRelationId', cellFilter: "enum:'labor_relations'"}
            {minWidth: 120, displayName: '到岗时间', name: 'joinScalDate'}
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
            @columnDef.splice 2, 0, {minWidth: 120, displayName: '出生日期', name: 'receptor.birthday'}
            @columnDef.splice 7, 0, {minWidth: 120, displayName: '申请发起时间', name: 'createdAt'}

        if @FlowName == 'Flow::EarlyRetirement'
            @columnDef.splice 2, 0, {minWidth: 120, displayName: '出生日期', name: 'receptor.birthday'}
            @columnDef.splice 2, 0, {minWidth: 120, displayName: '性别', name: 'receptor.genderId', cellFilter: "enum:'genders'"}

        if @FlowName == 'Flow::AdjustPosition'
            @columnDef.splice 4, 0, {minWidth: 250, displayName: '转入部门', name: 'toDepartmentName'}
            @columnDef.splice 5, 1, {minWidth: 200, displayName: '转入岗位', name: 'toPositionName'}

        if @FlowName == 'Flow::EmployeeLeaveJob'
            @columnDef.splice 6, 0, {minWidth: 120, displayName: '用工性质', name: 'receptor.laborRelationId', cellFilter: "enum:'labor_relations'"}
            @columnDef.splice 6, 0, {minWidth: 120, displayName: '申请发起时间', name: 'createdAt'}

        filterOptions = _.cloneDeep(HANDLER_AND_HISTORY_FILTER_OPTIONS)
        filterOptions.name = @checkListName
        @filterOptions = filterOptions

        @tableData = @Flow.$collection().$fetch()

    historyList: ->
        @columnDef = @helper.buildFlowDefault(FLOW_HISTORY_TABLE_DEFS)

        if @FlowName == 'Flow::Retirement'
            @columnDef.splice 2, 0, {minWidth: 120, displayName: '出生日期', name: 'receptor.birthday'}
            @columnDef.splice 7, 0, {minWidth: 120, displayName: '申请发起时间', name: 'createdAt'}

        if @FlowName == 'Flow::AdjustPosition'
            @columnDef.splice 4, 0, {minWidth: 250, displayName: '转入部门', name: 'toDepartmentName'}
            @columnDef.splice 5, 1, {minWidth: 200, displayName: '转入岗位', name: 'toPositionName'}

        if @FlowName == 'Flow::Resignation' || @FlowName == 'Flow::Retirement' || @FlowName == 'Flow::Dismiss'
            @columnDef.splice 6, 0, {minWidth: 120, displayName: '离职发起', name: 'leaveJobFlowState'}

        if @FlowName == 'Flow::Resignation'
            @columnDef.splice 6, 0, {minWidth: 120, displayName: '用工性质', name: 'receptor.laborRelationId', cellFilter: "enum:'labor_relations'"}

        filterOptions = _.cloneDeep(HANDLER_AND_HISTORY_FILTER_OPTIONS)

        if @FlowName == 'Flow::Resignation' || @FlowName == 'Flow::Retirement' || @FlowName == 'Flow::Dismiss'
            filterOptions.constraintDefs.splice 10, 0, {minWidth: 120, displayName: '离职发起', name: 'leave_job_state', type: 'leave_job_state_select'}

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

# 客舱服务部管理
class VacationManagementCtrl extends nb.Controller
    @.$inject = ['$http', '$scope', 'VacationDistribute', 'toaster']

    constructor: (@http, scope, @VacationDistribute, @toaster) ->
        @importing = false

        @loadDateTime()
        @loadInitialData()

        @filterOptions = {
            name: 'cabinManagement'
            constraintDefs: [
                {
                    name: 'employee_name'
                    displayName: '姓名'
                    type: 'string'
                }
                {
                    name: 'name'
                    displayName: '假别'
                    type: 'string'
                }
            ]
        }

        @columnDef = [
            {
                minWidth: 120
                displayName: '员工编号'
                name: 'employeeNo'
            }
            {
                minWidth: 120
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
                minWidth: 350
                displayName: '所属部门'
                name: 'departmentName'
                cellTooltip: (row) ->
                    return row.entity.departmentName
            }
            {
                minWidth: 250
                displayName: '岗位'
                name: 'positionName'
                cellTooltip: (row) ->
                    return row.entity.positionName
            }
            {minWidth: 150, displayName: '休假时间', name: 'vacationDates'}
            {minWidth: 120, displayName: '天数', name: 'vacationDays'}
            {minWidth: 120, displayName: '假别', name: 'name'}
            {minWidth: 120, displayName: '状态', name: 'state'}
        ]

    exportGridApi: (gridApi) ->
        @gridApi = gridApi

    loadMonthList: () ->
        if @currentYear == new Date().getFullYear()
            months = [1..new Date().getMonth() + 1]
        else
            months = [1..12]

        @month_list = _.map months, (item)->
            item = '0' + item if item < 10
            item + ''

    loadDateTime: ()->
        @year_list = @$getYears()
        @month_list = @$getMonths()

        @currentYear = _.last(@year_list)
        @currentMonth = _.last(@month_list)

    currentCalcTime: ()->
        @currentYear + "-" + @currentMonth

    loadInitialData: () ->
        args = {month: @currentCalcTime()}
        @records = @VacationDistribute.$collection().$fetch()
        @records.$refresh(args)

    loadRecords: (tableState) ->
        tableState = tableState || {}
        @loadMonthList()
        args = {month: @currentCalcTime()}
        angular.extend(args, tableState) if angular.isDefined(tableState)
        @records.$refresh(args)

    search: (tableState)->
        tableState = tableState || {}
        tableState['month'] = @currentCalcTime()
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        @records.$refresh(tableState)

    uploadCabinVacation: (type, attachment_id)->
        self = @
        month = @currentCalcTime()

        params = {type: type, attachment_id: attachment_id, month: month}
        @importing = true

        @http.post("/api/workflows/vacation/cabin_vacation_import", params).success (data, status) ->
            self.records.$refresh({month: month})
            self.toaster.pop('success', '提示', '导入成功')
            self.importing = false
        .error (data) ->
            self.importing = false

    approveVacations: () ->
        self = @
        params = {month: @currentCalcTime()}
        @importing = true

        @http.put("/api/workflows/approve_vacation_list", params).success (data) ->
            self.toaster.pop('success', '提示', '审批已完成')
            self.records.$refresh(params)
            self.importing = false
        .error (data) ->
            self.importing = false


app.controller('AttendanceRecordCtrl', AttendanceRecordCtrl)
app.controller('AttendanceHisCtrl', AttendanceHisCtrl)
app.controller('UserListCtrl', UserListCtrl)
app.controller('ContractCtrl', ContractCtrl)
app.controller('ProtocolCtrl', ProtocolCtrl)
app.controller('RetirementCtrl', RetirementCtrl)
app.controller('SbFlowHandlerCtrl', SbFlowHandlerCtrl)
app.controller('VacationManagementCtrl', VacationManagementCtrl)

app.constant('ColumnDef', [])
