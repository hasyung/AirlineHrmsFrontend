
nb = @.nb
app = nb.app
extend = angular.extend
resetForm = nb.resetForm
Modal = nb.Modal



class Route
    @.$inject = ['$stateProvider', '$urlRouterProvider']

    constructor: (stateProvider, urlRouterProvider) ->

        stateProvider
            .state 'attendance', {
                url: '/attendance'
                templateUrl: 'partials/attendance/attendance.html'
                controller: AttendanceCtrl
                controllerAs: 'ctrl'
            }

class AttendanceCtrl extends nb.Controller

    @.$inject = ['$scope', 'Flow::EarlyRetirement', '$mdDialog']

    constructor: (@scope, @Leave, @mdDialog) ->
        @loadInitailData()

        

    loadInitailData: ()->
        @flows = @Leave.$collection().$fetch()

    # searchLeaves: (tableState)->
    #     @flows.$refresh(tableState)

class AttendanceRecordCtrl extends nb.Controller
    @.$inject = ['$scope', 'Attendance']
    constructor: (@scope, @Attendance) ->
        @loadInitailData()
        @filterOptions = {
            name: 'attendanceRecord'
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
            {displayName: '分类', name: 'applyType'}
            {displayName: '通道', name: 'changeFlag'}
            {displayName: '用工性质', name: 'startDate', cellFilter: "enum:'channels'"}
            {displayName: '到岗时间', name: 'endDate'}
        ]


    loadInitailData: ()->
        @attendances = @Attendance.$collection().$fetch()

        

    




app.config(Route)
app.controller('AttendanceRecordCtrl', AttendanceRecordCtrl)
