
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
    @.$inject = ['$scope', 'Attendance', 'Employee']
    constructor: (@scope, @Attendance, @Employee) ->
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

        

    




app.config(Route)
app.controller('AttendanceRecordCtrl', AttendanceRecordCtrl)
