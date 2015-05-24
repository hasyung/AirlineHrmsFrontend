
nb = @.nb
app = nb.app
extend = angular.extend
Modal = nb.Modal



class Route
    @.$inject = ['$stateProvider', '$urlRouterProvider']

    constructor: (stateProvider, urlRouterProvider) ->

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


class AttendanceCtrl extends nb.Controller

    @.$inject = ['GridHelper', 'Leave']

    constructor: (helper, @Leave) ->

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
                name: 'type'
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
            }
            {
                name: 'type'
                displayName: '详细'
            }

        ]

        @columnDef = helper.buildFlowDefault(def)

        @leaveFlows = @Leave.$collection().$fetch()


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
            {displayName: '合同开始时间', name: 'startDate', cellFilter: "enum:'channels'"}
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



app.config(Route)
