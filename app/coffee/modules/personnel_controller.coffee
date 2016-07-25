nb = @.nb
app = nb.app
filterBuildUtils = nb.filterBuildUtils


class Route
    @.$inject = ['$stateProvider']

    constructor: (stateProvider) ->
        stateProvider
            .state 'personnel_list', {
                url: '/personnel'
                templateUrl: 'partials/personnel/personnel.html'
                controller: PersonnelCtrl
                controllerAs: 'ctrl'
            }
            .state 'personnel_fresh',{
                url: '/personnel/fresh-list'
                controller: NewEmpsCtrl
                controllerAs: 'ctrl'
                templateUrl: 'partials/personnel/personnel_new_list.html'
            }
            .state 'personnel_review', {
                url: '/personnel/change-review'
                templateUrl: 'partials/personnel/change_review.html'
                controller: ReviewCtrl
                controllerAs: 'ctrl'
            }

app.config(Route)


class PersonnelCtrl extends nb.Controller
    @.$inject = ['$scope', 'sweet', 'Employee', 'CURRENT_ROLES', 'toaster', '$http', '$rootScope']

    constructor: (@scope, @sweet, @Employee, @CURRENT_ROLES, @toaster, @http, @rootScope) ->
        @loadInitialData()
        @selectedIndex = 1

        @tableState = {}

        @importing = false

        @columnDef = [
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
                <div class="ui-grid-cell-contents ng-binding ng-scope">
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
                minWidth: 250
                displayName: '岗位'
                name: 'position.name'
                cellTooltip: (row) ->
                    return row.entity.position.name
            }
            {minWidth: 120, displayName: '通道', name: 'channelId', cellFilter: "enum:'channels'"}
            {minWidth: 120, displayName: '用工性质', name: 'laborRelationId', cellFilter: "enum:'labor_relations'"}
            {minWidth: 120, displayName: '出生日期', name: 'birthday', cellFilter: "date:'yyyy-MM-dd'"}
            {minWidth: 120, displayName: '到岗时间', name: 'joinScalDate', cellFilter: "date:'yyyy-MM-dd'"}
        ]

        @constraints = [

        ]

        @filterOptions = filterBuildUtils('personnel')
            .col 'name',                 '姓名',     'string'
            .col 'gender_id',            '性别',     'select', '', {type: 'genders'}
            .col 'employee_no',          '员工编号', 'string'
            .col 'identity_no',          '身份证', 'string'
            .col 'language_name',        '语种',     'language_select'
            .col 'language_grade',       '语言等级', 'string'
            .col 'department_ids',       '机构',     'org-search'
            .col 'grade_id',             '机构职级', 'select',           '',    {type: 'department_grades'}
            .col 'position_name',        '岗位名称', 'string'
            .col 'duty_rank_id',         '岗位职务职级', 'select',           '',    {type: 'duty_ranks'}
            .col 'location',             '属地',     'string'
            .col 'channel_ids',          '通道',     'muti-enum-search', '',    {type: 'channels'}
            .col 'employment_status_id', '用工状态', 'select',           '',    {type: 'employment_status'}
            .col 'labor_relation_id',    '用工性质', 'select',           '',    {type: 'labor_relations'}
            .col 'birthday',             '出生日期', 'date-range'
            .col 'join_scal_date',       '入职日期', 'date-range'
            .col 'start_work_date',      '参工日期', 'date-range'
            .col 'category_ids',          '分类',     'muti-enum-search', '',    {type: 'categories'}
            .end()

    loadInitialData: () ->
        @employees = @Employee.$collection().$fetch()

    search: (tableState) ->
        tableState = tableState || {}
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        @tableState = tableState
        @employees.$refresh(tableState)

    getSelected: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity

    getSelectsIds: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk

    exportGridApi: (gridApi) ->
        @gridApi = gridApi

    isDepartmentHr: ()->
        @CURRENT_ROLES.indexOf('department_hr') >= 0

    uploadPositives: (type, attachment_id)->
        self = @
        params = {type: type, attachment_id: attachment_id}
        @importing = true

        @http.post("/api/employees/transfer_to_regular_worker", params).success (data, status) ->
            self.toaster.pop('success', '提示', '导入成功')
            self.employees.$refresh()
            self.importing = false
        .error (data) ->
            self.importing = false

    uploadAttendance: (type, attachment_id)->
        self = @
        monthStr = ''

        now = moment()
        year = now.get('year')
        month = now.get('month') + 1
        date = now.get('date')

        if date > 15
            month = now.get('month') + 1
        else
            month =  now.get('month')

        if month < 10
            month = '0' + month

        monthStr = year + '-' + month

        params = {type: type, attachment_id: attachment_id, month: monthStr}
        @importing = true

        @http.post("/api/attendance_summaries/import", params).success (data, status) ->
            self.toaster.pop('success', '提示', '导入成功')
            self.importing = false
            self.rootScope.downloadUrl = data.path
        .error (data) ->
            self.toaster.pop('error', '提示', '导入失败')
            self.importing = false

    getCondition: ()->
        @tableState

    # 修改工作年限初始化params
    initialEmployeeDate: (current, params)->
        self = @

        current.$refresh().$asPromise().then (model) ->
            params.join_scal_date = model.joinScalDate
            params.start_work_date = model.startWorkDate
            params.leave_days = model.leaveDays
            params.actual_work_years = self.calcActualWorkYears(params)

    calcActualWorkYears: (params) ->
        s = params.start_work_date
        e = moment().format('YYYY-MM-DD')

        if s && e && s <= e
            d = moment.range(s, e).diff('days')
            actualWorkYears = Math.round((d - params.leave_days)*10/365)/10+'年'
            params.actual_work_years = actualWorkYears
        return actualWorkYears


class NewEmpsCtrl extends nb.Controller
    @.$inject = ['$scope', 'Employee', 'Org', '$state', '$enum', '$http', 'toaster']

    constructor: (@scope, @Employee, @Org, @state, @enum, @http, @toaster) ->
        @newEmp = {}
        @loadInitialData()

        @columnDef = [
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
                <div class="ui-grid-cell-contents ng-binding ng-scope">
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

        @filterOptions = {
            name: 'personnel_new'
            constraintDefs: [
                {
                    name: 'name'
                    displayName: '姓名'
                    type: 'string'
                    placeholder: '姓名'
                }
                {
                    name: 'gender_id'
                    type: 'select'
                    displayName: '性别'
                    params: {
                        type: 'genders'
                    }
                }
                {
                    name: 'employee_no'
                    displayName: '员工编号'
                    type: 'string'
                    placeholder: '员工编号'
                }
                {
                    name: 'language_name'
                    displayName: '语种'
                    type: 'language_select'
                    placeholder: '语种'
                }
                {
                    name: 'language_grade'
                    displayName: '语言等级'
                    type: 'string'
                    placeholder: '语言等级'
                }
                {
                    name: 'department_ids'
                    displayName: '机构'
                    type: 'org-search'
                }
                {
                    name: 'grade_id'
                    type: 'select'
                    displayName: '机构职级'
                    params: {
                        type: 'department_grades'
                    }
                }
                {
                    name: 'position_name'
                    displayName: '岗位名称'
                    type: 'string'
                }
                {
                    name: 'duty_rank_id'
                    type: 'select'
                    displayName: '岗位职务职级'
                    params: {
                        type: 'duty_ranks'
                    }
                }
                {
                    name: 'locations'
                    type: 'string_array'
                    displayName: '属地'
                }
                {
                    name: 'channel_ids'
                    type: 'muti-enum-search'
                    displayName: '通道'
                    params: {
                        type: 'channels'
                    }
                }
                {
                    name: 'employment_status_id'
                    type: 'select'
                    displayName: '用工状态'
                    params: {
                        type: 'employment_status'
                    }
                }
                {
                    name: 'birthday'
                    type: 'date-range'
                    displayName: '出生日期'
                }
                {
                    name: 'join_scal_date'
                    type: 'date-range'
                    displayName: '入职时间'
                }
                {
                    name: 'labor_relation_id'
                    type: 'select'
                    displayName: '用工性质'
                    params: {
                        type: 'labor_relations'
                    }
                }
            ]
        }

    loadInitialData: () ->
        @collection_param = {
            new_join_date: {
                from: moment().subtract(1, 'year').format('YYYY-MM-DD')
                to: moment().format("YYYY-MM-DD")
            }
        }

        @employees = @Employee.$collection().$fetch(@collection_param)

    exportGridApi: (gridApi) ->
        @gridApi = gridApi

    analysisIdentityNo: (identityNo, object)->
        return unless angular.isDefined(identityNo)
        return unless identityNo.length == 15 || identityNo.length == 18

        genders = @enum.get('genders')

        if identityNo.length == 15
            object.birthday = "19" + identityNo.slice(6, 8) + "-" + identityNo.slice(8, 10)  + "-" + identityNo.slice(10, 12)

            if parseInt(identityNo[14]) % 2 == 0
                result = _.find genders, (item)-> item.label == '女'
                object.genderId = result.id if result
            else
                result = _.find genders, (item)-> item.label == '男'
                object.genderId = result.id if result

        if identityNo.length == 18
            object.birthday = identityNo.slice(6, 10) + "-" + identityNo.slice(10, 12) + "-" + identityNo.slice(12, 14)

            if parseInt(identityNo[16]) % 2 == 0
                result = _.find genders, (item)-> item.label == '女'
                object.genderId = result.id if result
            else
                result = _.find genders, (item)-> item.label == '男'
                object.genderId = result.id if result

    regEmployee: (employee)->
        self = @

        @employees.$build(employee).$save().$then ()->
            self.loadInitialData()
            #self.gridApi.core.refresh()
            #新增员工后页码刷新，表格控件内容不刷新，未找到确切原因
            #先使用ui-router的state刷新方法
            self.state.go(self.state.current.name, {}, {reload: true})

    checkExistEmployeeNo: (employeeNo)->
        self = @

        @http({
            method: 'GET'
            url: '/api/employees?employee_no=' + employeeNo
        })
            .success (data) ->
                if data.employees.length > 0
                    self.toaster.pop('error', '提示', '员工编号已经存在')

    setProbationMonths: (newEmp) ->
        if newEmp.channelId != 4
            newEmp.probationMonths = 6
        else
            newEmp.probationMonths = ''

    getSelectsIds: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk

    search: (tableState) ->
        tableState = @mergeParams(tableState)
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        @employees.$refresh(tableState)

    mergeParams: (tableState)->
        angular.forEach @collection_param, (val, key)->
            tableState[key] = val

        return tableState

    uploadNewEmployees: (type, attachment_id)->
        self = @
        params = {type: type, attachment_id: attachment_id}
        @show_error_names = false

        @http.post("/api/employees/import", params).success (data, status) ->
            self.toaster.pop('success', '提示', '导入成功')
            self.employees.$refresh(self.collection_param)

    removeLanguage: (employee, idx) ->
        if angular.isDefined(employee.languages)
            employee.languages.splice idx, 1

    addLanguage: (employee) ->
        if angular.isDefined(employee.languages)
            employee.languages.push new Object()


class LeaveEmployeesCtrl extends nb.Controller
    @.$inject = ['$scope', 'LeaveEmployees', 'toaster', 'PERMISSIONS']

    constructor: (@scope, @LeaveEmployees, @toaster, @permissions) ->
        @loadInitialData()

        @columnDef = [
            {
                minWidth: 350
                displayName: '所属部门'
                name: 'department'
                cellTooltip: (row) ->
                    return row.entity.department
            }
            {
                minWidth: 120
                displayName: '姓名'
                field: 'name'
                cellTemplate: '''
                <div class="ui-grid-cell-contents ng-binding ng-scope">
                    <a nb-panel
                        template-url="partials/personnel/info_basic.html"
                        locals="{employee: row.entity.owner}">
                        {{grid.getCellValue(row, col)}}
                    </a>
                </div>
                '''
            }
            {minWidth: 120, displayName: '员工编号', name: 'employeeNo'}
            {
                minWidth: 250
                displayName: '岗位'
                name: 'position'
                cellTooltip: (row) ->
                    return row.entity.position
            }
            {minWidth: 120, displayName: '性别', name: 'gender'}
            {minWidth: 120, displayName: '通道', name: 'channel'}
            {minWidth: 120, displayName: '用工性质', name: 'laborRelation'}
            {minWidth: 120, displayName: '变动性质', name: 'employmentStatus'}
            {minWidth: 120, displayName: '离职时间', name: 'changeDate', cellFilter: "date:'yyyy-MM-dd'"}
        ]

        # 根据权限 leave_employees_show 添加查看列
        @editable = _.includes @permissions,'leave_employees_update'

        if _.includes @permissions,'leave_employees_show'
            @columnDef = @columnDef.concat [
                {
                    minWidth: 120
                    displayName: '查看'
                    field: 'edit'
                    cellTemplate: '''
                    <div class="ui-grid-cell-contents">
                        <a nb-dialog
                            template-url="/partials/personnel/edit_leave.html"
                            locals="{leave: row.entity, ctrl:grid.appScope.$parent.ctrl}">
                            查看
                        </a>
                    </div>
                    '''
                }
            ]

        @filterOptions = {
            name: 'personnelLeave'
            constraintDefs: [
                {
                    name: 'name'
                    displayName: '姓名'
                    type: 'string'
                }
                {
                    name: 'channel'
                    displayName: '通道'
                    type: 'string'
                }
                {
                    name: 'department'
                    displayName: '机构'
                    type: 'string'
                }
                {
                    name: 'position_name'
                    displayName: '岗位名称'
                    type: 'string'
                }
                {
                    name: 'employment_status'
                    type: 'string'
                    displayName: '变动性质'
                }
                {
                    name: 'change_date'
                    type: 'date-range'
                    displayName: '离职时间'
                }
            ]
        }

    loadInitialData: () ->
        @leaveEmployees = @LeaveEmployees.$collection().$fetch()

    search: (tableState) ->
        tableState = tableState || {}
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        @leaveEmployees.$refresh(tableState)

    getSelected: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity

    getSelectsIds: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk

    exportGridApi: (gridApi) ->
        @gridApi = gridApi

    updateLeave: (model) ->
        self = @

        model.$save().$then (data) ->
            self.toaster.pop('success', '更新成功', data.$response.data.messages)
            self.leaveEmployees.$refresh()

class EarlyRetireEmployeesCtrl extends nb.Controller
    @.$inject = ['$scope', 'EarlyRetireEmployees', 'toaster', 'PERMISSIONS']

    constructor: (@scope, @EarlyRetireEmployees, @toaster, @permissions) ->
        @loadInitialData()

        @columnDef = [
            {
                minWidth: 350
                displayName: '所属部门'
                name: 'department'
                cellTooltip: (row) ->
                    return row.entity.department
            }
            {
                minWidth: 120
                displayName: '姓名'
                field: 'name'
                cellTemplate: '''
                <div class="ui-grid-cell-contents ng-binding ng-scope">
                    <a nb-panel
                        template-url="partials/personnel/info_basic.html"
                        locals="{employee: row.entity.owner}">
                        {{grid.getCellValue(row, col)}}
                    </a>
                </div>
                '''
            }
            {minWidth: 120, displayName: '员工编号', name: 'employeeNo'}
            {
                minWidth: 250
                displayName: '岗位'
                name: 'position'
                cellTooltip: (row) ->
                    return row.entity.position
            }
            {minWidth: 120, displayName: '性别', name: 'gender'}
            {minWidth: 120, displayName: '通道', name: 'channel'}
            {minWidth: 120, displayName: '用工性质', name: 'laborRelation'}
            {minWidth: 120, displayName: '退养时间', name: 'changeDate', cellFilter: "date:'yyyy-MM-dd'"}
        ]

        # 根据权限 early_retire_employees_show 添加查看列
        @editable = _.includes @permissions,'early_retire_employees_update'

        if _.includes @permissions,'early_retire_employees_show'
            @columnDef = @columnDef.concat [
                {
                    minWidth: 120
                    displayName: '查看'
                    field: 'edit'
                    cellTemplate: '''
                    <div class="ui-grid-cell-contents">
                        <a nb-dialog
                            template-url="/partials/personnel/edit_early_retire.html"
                            locals="{earlyRetire: row.entity, ctrl:grid.appScope.$parent.ctrl}">
                            查看
                        </a>
                    </div>
                    '''
                }
            ]

        @filterOptions = {
            name: 'personnelLeave'
            constraintDefs: [
                {
                    name: 'name'
                    displayName: '姓名'
                    type: 'string'
                }
                {
                    name: 'channel'
                    displayName: '通道'
                    type: 'string'
                }
                {
                    name: 'department'
                    displayName: '机构'
                    type: 'string'
                }
                {
                    name: 'position_name'
                    displayName: '岗位名称'
                    type: 'string'
                }
                {
                    name: 'change_date'
                    type: 'date-range'
                    displayName: '退养时间'
                }
            ]
        }

    loadInitialData: () ->
        @earlyRetireEmployees = @EarlyRetireEmployees.$collection().$fetch()

    search: (tableState) ->
        tableState = tableState || {}
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        @earlyRetireEmployees.$refresh(tableState)

    getSelected: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity

    getSelectsIds: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk

    exportGridApi: (gridApi) ->
        @gridApi = gridApi

    updateEarlyRetire: (model) ->
        self = @

        model.$save().$then (data) ->
            self.toaster.pop('success', '更新成功', data.$response.data.messages)
            self.earlyRetireEmployees.$refresh()


class MoveEmployeesCtrl extends nb.Controller
    @.$inject = ['$scope', 'MoveEmployees', 'Employee', '$nbEvent', '$http']

    constructor: (@scope, @MoveEmployees, @Employee, @Evt, @http) ->
        @moveEmployees = @loadInitialData()

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
                <div class="ui-grid-cell-contents ng-binding ng-scope">
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
                name: 'department.name'
                cellTooltip: (row) ->
                    return row.entity.departmentName
            }
            {
                minWidth: 250
                displayName: '岗位'
                name: 'positionName'
                cellTooltip: (row) ->
                    return row.entity.position
            }
            {
                minWidth: 120
                displayName: '异动性质'
                name: 'specialCategory'
                cellTooltip: (row) ->
                    return row.entity.specialCategory
            }
            {minWidth: 120, displayName: '异动时间', name: 'specialTime'}
            {
                minWidth: 200
                displayName: '异动地点'
                name: 'specialLocation'
                cellTooltip: (row) ->
                    return row.entity.specialLocation
            }
            {
                minWidth: 120
                displayName: '文件编号'
                name: 'fileNo'
                cellTooltip: (row) ->
                    return row.entity.fileNo
            }
            {
                minWidth: 200
                displayName: '异动期限'
                name: 'limitTime'
                cellTooltip: (row) ->
                    return row.entity.limitTime
            }
        ]

        @filterOptions = {
            name: 'personnelLeave'
            constraintDefs: [
                {
                    name: 'name'
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
                    name: 'special_category'
                    type: 'move_select'
                    displayName: '异动性质'
                }
                {
                    name: 'special_location'
                    type: 'string'
                    displayName: '异动地点'
                }
            ]
        }


    loadInitialData: () ->
        @moveEmployees = @MoveEmployees.$collection().$fetch()

    newStopEmployee: (moveEmployee)->
        self = @
        # moveEmployee.department_id = moveEmployee.department_id.$pk if moveEmployee.department_id

        @http.post('/api/special_states/temporarily_stop_air_duty', moveEmployee).then (data)->
            self.moveEmployees.$refresh()
            msg = data.messages

            if data.status == 200
                self.Evt.$send("special_state:save:success", msg || "创建成功")
            else
                $Evt.$send('special_state:save:error', msg || "创建失败")


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
            self.moveEmployees.$refresh()
            msg = data.messages

            if data.status == 200
                self.Evt.$send("special_state:save:success", msg || "创建成功")
            else
                $Evt.$send('special_state:save:error', msg || "创建失败")

    newAccreditEmployee: (moveEmployee)->
        self = @

        @http.post('/api/special_states/temporarily_defend', moveEmployee).then (data)->
            self.moveEmployees.$refresh()

            msg = data.messages

            if data.status == 200
                self.Evt.$send("special_state:save:success", msg || "创建成功")
            else
                $Evt.$send('special_state:save:error', msg || "创建失败")

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
            self.moveEmployees.$refresh()
            msg = data.messages

            if data.status == 200
                self.Evt.$send("special_state:save:success", msg || "创建成功")
            else
                self.Evt.$send('special_state:save:error', msg || "创建失败")    

    search: (tableState) ->
        tableState = tableState || {}
        # tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        @moveEmployees.$refresh(tableState)

    getSelected: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        selected = if rows.length >= 1 then rows[0].entity else null

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

class AdjustPositionWaitingController extends nb.Controller
    @.$inject = ['$scope', 'toaster', 'AdjustPositionWaiting']

    constructor: (@scope, @toaster, @AdjustPositionWaiting) ->
        @loadInitialData()

        @filterOptions = {
            name: 'positionChange'
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
                <div class="ui-grid-cell-contents ng-binding ng-scope">
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
            {
                minWidth: 120
                displayName: '操作人'
                name: 'operatorName'
                cellTooltip: (row) ->
                    return row.entity.operatorName
            }
            {
                minWidth: 120
                displayName: '操作时间'
                name: 'createdAt'
                cellFilter: "date:'yyyy-MM-dd'"
            }
            {
                minWidth: 200
                displayName: '生效时间'
                name: 'positionChangeDate'
                cellTooltip: (row) ->
                    return row.entity.positionChangeDate
            }
            {
                minWidth: 120
                displayName: '查看'
                field: 'edit'
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a nb-dialog
                        template-url="/partials/personnel/adjust_waiting_view.html"
                        locals="{adjust: row.entity, ctrl:grid.appScope.$parent.ctrl}">
                        查看
                    </a>
                </div>
                '''
            }

        ]

    loadInitialData: () ->
        self = @

        @adjustPositionEmployees = @AdjustPositionWaiting.$collection().$fetch()

    search: (tableState)->
        @adjustPositionEmployees.$refresh(tableState)

class PositionRecordController extends nb.Controller
    @.$inject = ['$scope', 'toaster', 'AdjustPositionRecord']

    constructor: (@scope, @toaster, @AdjustPositionRecord) ->
        @loadInitialData()

        @filterOptions = {
            name: 'positionRecord'
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
                    name: 'labor_relation_ids'
                    type: 'muti-enum-search'
                    displayName: '用工性质'
                    params: {
                        type: 'labor_relations'
                    }
                }
                {
                    name: 'change_date'
                    displayName: '变动时间'
                    type: 'date-range'
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
                <div class="ui-grid-cell-contents ng-binding ng-scope">
                    <a nb-panel
                        template-url="partials/personnel/info_basic.html"
                        locals="{employee: row.entity.owner}">
                        {{grid.getCellValue(row, col)}}
                    </a>
                </div>
                '''
            }
            {
                minWidth: 120
                displayName: '用工性质'
                name: 'laborRelationId'
                cellFilter: "enum:'labor_relations'"
            }
            {
                minWidth: 120
                displayName: '变动日期'
                name: 'changeDate'
                cellFilter: "date:'yyyy-MM-dd'"
            }
            {
                minWidth: 350
                displayName: '原部门'
                name: 'preDepartmentName'
                cellTooltip: (row) ->
                    return row.entity.preDepartmentName
            }
            {
                minWidth: 250
                displayName: '原岗位'
                name: 'prePositionName'
                cellTooltip: (row) ->
                    return row.entity.prePositionName
            }
            {
                minWidth: 120
                displayName: '原通道'
                name: 'preChannelName'
            }
            {
                minWidth: 120
                displayName: '原属地'
                name: 'preLocation'
            }
            {
                minWidth: 350
                displayName: '现部门'
                name: 'departmentName'
                cellTooltip: (row) ->
                    return row.entity.departmentName
            }
            {
                minWidth: 250
                displayName: '现岗位'
                name: 'positionName'
                cellTooltip: (row) ->
                    return row.entity.positionName
            }
            {
                minWidth: 120
                displayName: '现通道'
                name: 'channelName'
            }
            {
                minWidth: 120
                displayName: '现属地'
                name: 'location'
            }
            {
                minWidth: 150
                displayName: '文件号'
                name: 'oaFileNo'
                cellTooltip: (row) ->
                    return row.entity.fileNo
            }
            {
                minWidth: 150
                displayName: '备注'
                name: 'note'
            }
        ]

    loadInitialData: () ->
        self = @

        @adjustPositionRecords = @AdjustPositionRecord.$collection().$fetch()

    getSelectsIds: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk

    exportGridApi: (gridApi) ->
        @gridApi = gridApi

    search: (tableState)->
        @adjustPositionRecords.$refresh(tableState)



class ReviewCtrl extends nb.Controller
    @.$inject = ['$scope', 'Change', 'Record', '$mdDialog', 'toaster']

    constructor: (@scope, @Change, @Record, @mdDialog, @toaster) ->
        @loadInitialData()

        @tableState = null
        @exportEduExpUrl = ''
        @enable_check = false
        self = @

        @changeColumnDef = [
            {minWidth: 350, name:"department.name", displayName:"所属部门"}
            {minWidth: 120, name:"name", displayName:"姓名"}
            {minWidth: 120, name:"employeeNo", displayName:"员工编号"}
            {
                minWidth: 150
                displayName: '信息变更模块'
                field: 'auditableType'
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a
                        ng-if="row.entity.action != '修改'"
                        href="javascript:void(0);"
                        nb-dialog
                        template-url="partials/common/create_change_review.tpl.html"
                        locals="{'change': row.entity}"> {{row.entity.auditableType}}
                    </a>
                    <a
                        ng-if="row.entity.action == '修改'"
                        href="javascript:void(0);"
                        nb-dialog
                        template-url="partials/common/update_change_review.tpl.html"
                        locals="{'change': row.entity}"> {{row.entity.auditableType}}
                    </a>
                </div>
                '''
            }
            {minWidth: 120, name:"createdAt", displayName:"变更时间"}
            {
                minWidth: 150
                displayName: '操作'
                field: 'statusCd'
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <div class="radio-group" radio-box ng-model="row.entity.statusCd"></div>
                </div>
                '''
            }
            {
                minWidth: 200
                name:"reason"
                displayName:"理由"
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a href="javascript:;" nb-popup-plus="nb-popup-plus" position="left-bottom" offset="0.5">{{row.entity.reason || '请输入'}}
                        <popup-template style="padding:8px;border:1px solid #eee;" class="nb-popup org-default-popup-template">
                            <div class="panel-body popup-body">
                                <md-input-container>
                                    <label>请输入理由</label>
                                    <textarea ng-model="row.entity.reason" style="resize:none;" class="reason-input"></textarea>
                                </md-input-container>
                            </div>
                        </popup-template>
                    </a>
                </div>
                '''
            }
        ]

        @recordColumnDef = [
            {minWidth: 350, name:"department.name", displayName:"所属部门"}
            {minWidth: 120, name:"name", displayName:"姓名"}
            {minWidth: 120, name:"employeeNo", displayName:"员工编号"}
            {
                minWidth: 150
                displayName: '信息变更模块'
                field: 'auditableType'
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a
                        ng-if="row.entity.action != '修改'"
                        href="javascript:void(0);"
                        nb-dialog
                        template-url="partials/common/create_change_review.tpl.html"
                        locals="{'change': row.entity}"> {{row.entity.auditableType}}
                    </a>
                    <a
                        ng-if="row.entity.action == '修改'"
                        href="javascript:void(0);"
                        nb-dialog
                        template-url="partials/common/update_change_review.tpl.html"
                        locals="{'change': row.entity}"> {{row.entity.auditableType}}
                    </a>
                </div>
                '''
            }
            {minWidth: 120, name:"createdAt", displayName:"变更时间"}
            {minWidth: 120, name:"user.name", displayName:"操作者"}
            {minWidth: 120, name:"statusCd", displayName:"状态", cellFilter: "dictmap:'personnel'"}
            {minWidth: 120, name:"checkDate", displayName:"审核时间"}
            {minWidth: 200, name:"reason", displayName:"理由"}
        ]

        @filterOptions = {
            name: 'personnel_chage_record'
            constraintDefs: [
                {
                    name: 'name'
                    displayName: '姓名'
                    type: 'string'
                    placeholder: '员工姓名'
                }
                {
                    name: 'department_ids'
                    displayName: '机构'
                    type: 'org-search'
                }
                {
                    name: 'employee_no'
                    displayName: '员工编号'
                    type: 'string'
                    placeholder: '员工编号'
                }
                {
                    name: 'created_at'
                    type: 'date-range'
                    displayName: '变更时间'
                }
                {
                    name: 'auditable_type'
                    type: 'review_category_select'
                    displayName: '信息变更模块'
                }
            ]
        }

        @scope.$watch 'ctrl.changes', (from, to)->
            checked = _.filter self.changes, (item)->
                return item if item.statusCd != "1"
            self.enable_check = checked.length
        , true

    loadInitialData: () ->
        @records = @Record.$collection().$fetch()

    searchRecord: (tableState)->
        @records.$refresh(tableState)
        @tableState = tableState

    checkChanges: ()->
        self = @

        params = []
        # '无需审核': 0
        # '待审核': 1
        # '通过': 2
        # '不通过': 3

        checked = _.filter @changes, (item)->
            return item if item.statusCd != "1"

        _.forEach checked, (item)->
            temp = {}
            temp.id = item.id
            temp.status_cd = item.statusCd
            temp.reason = item.reason
            params.push temp

        if params.length > 0
            @changes.checkChanges(params).$asPromise().then (data)->
                self.changes.$clear()
                self.changes.$refresh()
        else
            self.toaster.pop('error', '提示','请勾选要处理的审核记录')

class EducationExpRecordController extends nb.Controller
    @.$inject = ['$scope', 'toaster', 'EducationExpRecord']

    constructor: (@scope, @toaster, @EducationExpRecord) ->
        @tableState = null
        @exportEduExpUrl = ''

        @loadInitialData()

        @filterOptions = {
            name: 'positionRecord'
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
                    name: 'department_name'
                    type: 'string'
                    displayName: '机构'
                }
                {
                    name: 'change_date'
                    displayName: '变动时间'
                    type: 'date-range'
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
                <div class="ui-grid-cell-contents ng-binding ng-scope">
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
            {
                minWidth: 200
                displayName: '身份证号码'
                name: 'identityNo'
                cellTooltip: (row) ->
                    return row.entity.identityNo
            }
            {
                minWidth: 120
                displayName: '用工性质'
                name: 'laborRelation'
                cellTooltip: (row) ->
                    return row.entity.laborRelation
            }
            {
                minWidth: 120
                displayName: '用工性质'
                name: 'laborRelation'
                cellTooltip: (row) ->
                    return row.entity.laborRelation
            }
            {
                minWidth: 150
                displayName: '毕业院校'
                name: 'school'
                cellTooltip: (row) ->
                    return row.entity.school
            }
            {
                minWidth: 150
                displayName: '专业'
                name: 'major'
                cellTooltip: (row) ->
                    return row.entity.major
            }
            {
                minWidth: 120
                displayName: '学历'
                name: 'educationBackground'
                cellTooltip: (row) ->
                    return row.entity.educationBackground
            }
            {
                minWidth: 120
                displayName: '学位'
                name: 'degree'
                cellTooltip: (row) ->
                    return row.entity.degree
            }
            {
                minWidth: 120
                displayName: '变动日期'
                name: 'changeDate'
                cellFilter: "date:'yyyy-MM-dd'"
            }
        ]

    loadInitialData: () ->
        self = @

        @educationExpRecords = @EducationExpRecord.$collection().$fetch()

    getSelectsIds: () ->
        rows = @gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk

    exportGridApi: (gridApi) ->
        @gridApi = gridApi

    search: (tableState)->
        @educationExpRecords.$refresh(tableState)
        @tableState = tableState

    exportEducationExperiences: () ->
        paramStr = ''

        if @tableState
            _.map @tableState, (value, key) ->
                if angular.isString value
                    paramStr = paramStr + (key + '=' + value) + '&'
                if angular.isArray value
                    paramStr = paramStr + (key + '=' + _.flatten value) + '&'
                if angular.isObject value
                    paramStr = paramStr + key + '%5Bfrom%5D=' + value.from.replace(/\+/g, '%2B') + '&'
                    paramStr = paramStr + key + '%5Bto%5D=' + value.to.replace(/\+/g, '%2B') + '&'

        @exportEduExpUrl = '/api/education_experience_records/export_to_xls?' + paramStr

class EmployeeMemberCtrl extends nb.Controller
    @.$inject = ['$scope', 'Employee']

    constructor: (@scope, @Employee)->

    loadMembers: (employee)->
        @scope.lovers = employee.familyMembers.$search({relation: 'lover'})
        @scope.children = employee.familyMembers.$search({relation: 'children'})
        @scope.others = employee.familyMembers.$search({relation: 'other'})

class EmployeePerformanceCtrl extends nb.Controller
    @.$inject = ['$scope', 'Employee', 'Performance']

    constructor: (@scope, @Employee, @Performance)->

    loadData: (employee)->
        self = @
        employee.performances.$refresh().$then (performances)->
            self.performances = _.sortBy(_.groupBy performances, (item)-> item.assessYear).reverse()

class EmployeeRewardPunishmentCtrl extends nb.Controller
    @.$inject = ['$scope', 'Employee', 'Reward', 'Punishment']

    constructor: (@scope, @Employee, @Reward, @Punishment)->

    loadRewards: (employee) ->
        @rewards = employee.rewards.$refresh({genre: '奖励'})

    loadPunishments: (employee)->
        @punishments = employee.punishments.$refresh({genre: '处分'})

class EmployeeAttendanceCtrl extends nb.Controller
    @.$inject = ['$scope', '$http', 'Employee', 'CURRENT_ROLES']

    constructor: (@scope, @http, @Employee, @CURRENT_ROLES)->

    isHrPaymentMember: ()->
        @CURRENT_ROLES.indexOf('hr_payment_member') >= 0

    dayOnClick: ()->
        #

    loadAttendance: (employee)->
        self = @

        @eventSources = []
        keys = ["leaves", "late_or_early_leaves", "absences", "lands", "off_post_trains", "filigt_groundeds", "flight_ground_works"]
        colors = {
            "leaves": "#006600"
            "late_or_early_leaves": "#ffff66"
            "absences": "#ff0033"
            "lands": "#9933ff"
            "off_post_trains": "#0066ff"
            "filigt_groundeds": "#ff6633"
            "flight_ground_works": "#33ff00"
        }

        @uiConfig = {
            calendar: {
                dayNames: ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"]
                dayNamesShort: ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"]
                monthNamesShort: ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"]
                monthNames: ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"]

                height: 450
                editable: false

                header: {
                    left: 'month basicWeek'
                    center: 'title'
                    right: 'today prev,next'
                }

                displayEventTime: false

                buttonText: {
                    today:    '今天',
                    month:    '月',
                    week:     '周',
                    day:      '天'
                }

                #viewRender: (view, element)->
                   #console.error("View Changed: ", view.visStart, view.visEnd, view.start, view.end)

                dayClick: @dayOnClick
                #eventDrop
                #eventResize
            }
        }

        @http.get('/api/employees/' + employee.id + '/attendance_records/').success (data)->
            angular.forEach keys, (key)->
                events = data.attendance_records[key]

                events = angular.forEach events, (item)->
                    item["start"] = new Date(item["start"]) if item["start"]
                    item["end"] = new Date(item["end"]) if item["end"]

                source = {
                    color: colors[key]
                    textColor: '#000'
                    events: events
                }

                self.eventSources.push(source)

            self.scope.vacations = data.attendance_records.vacations
            self.scope.hasVacation = Object.keys(self.scope.vacations.year).length > 0

class EmployeeTechnicalRecordsCtrl extends nb.Controller
    @.$inject = ['$scope', 'Employee']

    constructor: (@scope, @Employee)->

    loadRecords: (employee)->
        @records = employee.technicalRecords.$refresh()



class PersonnelSort extends nb.Controller
    @.$inject = ['$scope', 'Org', 'Position', 'Employee', '$http']

    constructor: (@scope, @Org, @Position, @Employee, @http) ->
        @orgLinks = []
        @loadInitialData()

    loadInitialData: () ->
        self = @
        @currentOrgs = @Org.$search().$then (data)->
            self.currentOrgs = data.jqTreeful()[0]
            self.orgLinks.push self.currentOrgs

    orgSelectBack: ->
        if @orgLinks.length > 1
            @orgLinks.pop()
            @currentOrgs = @orgLinks[@orgLinks.length-1]

    showChildsOrg: (org)->
        @orgLinks.push(org)
        @currentOrgs = org

    setHeigher: (collection, index, category)->
        return if index == 0 || (!category)

        params = {
            category:category
            current_id: collection[index].id
            target_id:collection[index-1].id
        }

        promise = @changeOrder params
        promise.then ()->
            temp = collection[index]
            collection[index] = collection[index-1]
            collection[index-1] = temp

    setLower: (collection, index, category)->
        return if index >= collection.length-1 || (!category)

        params = {
            category:category
            current_id: collection[index].id
            target_id:collection[index+1].id
        }

        promise = @changeOrder params
        promise.then ()->
            temp = collection[index]
            collection[index] = collection[index+1]
            collection[index+1] = temp

    changeOrder: (params)->
        promise = @http.get '/api/sort', {params: params}
        # promise.then onSuccess

orgMutiPos = ($rootScope)->
    class PersonnelPositions extends nb.Controller
        @.$inject = ['$scope', 'Position']

        constructor: (@scope, @Position) ->
            @scope.positions = []
            @scope.hasPrimary = false

        addPositions: ->
            @scope.positions.push {
                position_id: ""
                category: ""
            }

        removePosition: (index)->
            @scope.positions.splice index, 1

        setHeigher: (index)->
            return if index == 0
            temp = @scope.positions[index]
            @scope.positions[index] = @scope.positions[index-1]
            @scope.positions[index-1] = temp

        queryPrimary: (positions)->
            # 业务变更: 可以拥有多个主职了
            self = @

            self.scope.hasPrimary = false
            _.forEach positions, (position)->
                if position.category == '主职'
                    return self.scope.hasPrimary = true


    postLink = (scope, elem, attrs, ctrl)->

        scope.$watch 'positions', (newVal, oldVal) ->
            newVal.map (position) ->
                if !position.category || !position.position.id
                    scope.isValid = false
                else
                    scope.isValid = true
        , true

    return {
        scope: {
            positions: "=ngModel"
            editStatus: "=editing"
            isValid: "=isValid"
        }

        replace: true
        templateUrl: "partials/personnel/muti-positions.tpl.html"
        require: 'ngModel'
        link: postLink
        controller: PersonnelPositions
        controllerAs: "ctrl"
    }


app.directive('orgMutiPos',[orgMutiPos])


class PersonnelDataCtrl extends nb.Controller
    @.$inject = ['$scope', 'CURRENT_ROLES', 'USER_META']

    constructor: (@scope, @CURRENT_ROLES, @USER_META) ->
        @year_list = @$getYears()
        @month_list = @$getMonths()

        @currentYear = @year_list[0]
        @currentMonth = @month_list[@month_list.length - 1]

    calcTime: ()->
        @currentYear + '-' + @currentMonth

    isHrPaymentMember: ()->
        @CURRENT_ROLES.indexOf('hr_payment_member') >= 0

    isAdministrator: () ->
        return @USER_META.name == 'administrator'

    loadSalary: ()->
        console.error '载入' + @calcTime() + '薪酬'

    distinguish: (resume) ->
        self = @

        resume.$refresh().$then (resume) ->
            workAfter = _.clone resume.workExperiences, true

            _.remove workAfter, (work)->
                return work.category == 'before'

            workAfterEmployee = _.remove workAfter, (work)->
                return work.employeeCategory == '员工' || work.employeeCategory == null

            self.workBefore = _.filter resume.workExperiences, _.matches({'category': 'before'})
            self.eduBefore = _.filter resume.educationExperiences, _.matches({'category': 'before'})
            self.eduAfter = _.filter resume.educationExperiences, _.matches({'category': 'after'})

            self.workAfterEmployee = workAfterEmployee
            self.workAfterLeader = workAfter

    removeLanguage: (employee, idx) ->
        if angular.isDefined(employee.languages)
            employee.languages.splice idx, 1

    addLanguage: (employee) ->
        if angular.isDefined(employee.languages)
            employee.languages.push new Object()


app.controller('PersonnelSort', PersonnelSort)
app.controller('LeaveEmployeesCtrl', LeaveEmployeesCtrl)
app.controller('EarlyRetireEmployeesCtrl', EarlyRetireEmployeesCtrl)
app.controller('MoveEmployeesCtrl', MoveEmployeesCtrl)
app.controller('adjustPositionWaitingCtrl', AdjustPositionWaitingController)
app.controller('PositionRecordCtrl', PositionRecordController)
app.controller('EducationExpRecordCtrl', EducationExpRecordController)
app.controller('EmployeeMemberCtrl', EmployeeMemberCtrl)
app.controller('EmployeeTechnicalRecordsCtrl', EmployeeTechnicalRecordsCtrl)
app.controller('EmployeePerformanceCtrl', EmployeePerformanceCtrl)
app.controller('EmployeeAttendanceCtrl', EmployeeAttendanceCtrl)
app.controller('EmployeeRewardPunishmentCtrl', EmployeeRewardPunishmentCtrl)
app.controller('PersonnelDataCtrl', PersonnelDataCtrl)
