app = @nb.app

class AttendanceRecordCtrl extends nb.Controller
    @.$inject = ['$scope', 'Attendance', 'Employee']

    constructor: (@scope, @Attendance, @Employee) ->
        @loadInitialData()

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

    loadInitialData: ()->
        @employees = @Employee.$collection().$fetch()

    search: (tableState)->
        @employees.$refresh(tableState)

    getSelected: () ->
        rows = @scope.$gridApi.selection.getSelectedGridRows()
        selected = if rows.length >= 1 then rows[0].entity else null


class AttendanceHisCtrl extends nb.Controller
    @.$inject = ['$scope', 'Attendance']

    constructor: (@scope, @Attendance) ->
        @loadInitialData()

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

    loadInitialData: ()->
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


app.controller('AttendanceRecordCtrl', AttendanceRecordCtrl)
app.controller('AttendanceHisCtrl', AttendanceHisCtrl)
