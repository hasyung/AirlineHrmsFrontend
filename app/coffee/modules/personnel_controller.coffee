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
    @.$inject = ['$scope', 'sweet', 'Employee', 'CURRENT_ROLES']

    constructor: (@scope, @sweet, @Employee, @CURRENT_ROLES) ->
        @loadInitialData()
        @selectedIndex = 1

        @columnDef = [
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

        @constraints = [

        ]

        @filterOptions = filterBuildUtils('personnel')
            .col 'name',                 '姓名',     'string'
            .col 'employee_no',          '员工编号', 'string'
            .col 'department_ids',       '机构',     'org-search'
            .col 'position_name',        '岗位名称', 'string'
            .col 'location',             '属地',     'string'
            .col 'channel_ids',          '通道',     'muti-enum-search', '',    {type: 'channels'}
            .col 'employment_status_id', '用工状态', 'select',           '',    {type: 'employment_status'}
            .col 'birthday',             '出生日期', 'date-range'
            .col 'join_scal_date',       '入职时间', 'date-range'
            .end()

    loadInitialData: () ->
        @employees = @Employee.$collection().$fetch()

    search: (tableState) ->
        tableState = tableState || {}
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
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


class NewEmpsCtrl extends nb.Controller
    @.$inject = ['$scope', 'Employee', 'Org', '$state', '$enum', '$http', 'toaster']

    constructor: (@scope, @Employee, @Org, @state, @enum, @http, @toaster) ->
        @newEmp = {}
        @loadInitialData()

        @columnDef = [
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
                    name: 'position_name'
                    displayName: '岗位名称'
                    type: 'string'
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
            url: '/api/employees/?employee_no=' + employeeNo
        })
            .success (data) ->
                if data.employees.length > 0
                    self.toaster.pop('error', '提示', '员工编号已经存在')

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


class LeaveEmployeesCtrl extends nb.Controller
    @.$inject = ['$scope', 'LeaveEmployees']

    constructor: (@scope, @LeaveEmployees) ->
        @loadInitialData()

        @columnDef = [
            {
                displayName: '所属部门'
                name: 'department'
                cellTooltip: (row) ->
                    return row.entity.department
            }
            {
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
            {displayName: '员工编号', name: 'employeeNo'}
            {
                displayName: '岗位'
                name: 'position'
                cellTooltip: (row) ->
                    return row.entity.position
            }
            {displayName: '性别', name: 'gender'}
            {displayName: '通道', name: 'channel'}
            {displayName: '用工性质', name: 'laborRelation'}
            {displayName: '变动性质', name: 'employmentStatus'}
            {displayName: '变动时间', name: 'changeDate'}
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
                    displayName: '变动时间'
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


class MoveEmployeesCtrl extends nb.Controller
    @.$inject = ['$scope', 'MoveEmployees', 'Employee', '$nbEvent', '$http']

    constructor: (@scope, @MoveEmployees, @Employee, @Evt, @http) ->
        @moveEmployees = @loadInitialData()

        @columnDef = [
            {
                displayName: '员工编号'
                name: 'employeeNo'
            }
            {
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
                displayName: '所属部门'
                name: 'departmentName'
                cellTooltip: (row) ->
                    return row.entity.departmentName
            }
            {
                displayName: '岗位'
                name: 'positionName'
                cellTooltip: (row) ->
                    return row.entity.position
            }
            {
                displayName: '异动性质'
                name: 'specialCategory'
                cellTooltip: (row) ->
                    return row.entity.specialCategory
            }
            {displayName: '异动时间', name: 'specialTime'}
            {displayName: '异动地点', name: 'specialLocation'}
            {
                displayName: '文件编号'
                name: 'fileNo'
                cellTooltip: (row) ->
                    return row.entity.fileNo
            }
            {
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
                    name: 'employeeName'
                    displayName: '姓名'
                    type: 'string'
                }
                {
                    name: 'employeeNo'
                    displayName: '员工编号'
                    type: 'string'
                }
                {
                    name: 'department'
                    displayName: '机构'
                    type: 'string'
                }
                {
                    name: 'special_category'
                    type: 'string'
                    displayName: '异动性质'
                }
                {
                    name: 'special_location'
                    type: 'date-range'
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
        moveEmployee.department_id = moveEmployee.department_id.$pk if moveEmployee.department_id

        @http.post('/api/special_states/temporarily_transfer', moveEmployee).then (data)->
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
            msg = data.$response.data.messages

            if data.$response.status == 200
                self.Evt.$send("special_state:save:success", msg || "创建成功")
            else
                $Evt.$send('special_state:save:error', msg || "创建失败")

    search: (tableState) ->
        tableState = tableState || {}
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
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


class ReviewCtrl extends nb.Controller
    @.$inject = ['$scope', 'Change', 'Record', '$mdDialog', 'toaster']

    constructor: (@scope, @Change, @Record, @mdDialog, @toaster) ->
        @loadInitialData()

        @enable_check = false
        self = @

        @changeColumnDef = [
            {name:"department.name", displayName:"所属部门"}
            {name:"name", displayName:"姓名"}
            {name:"employeeNo", displayName:"员工编号"}
            {
                displayName: '信息变更模块'
                field: 'auditableType'
                cellTemplate: '''
                <div class="ui-grid-cell-contents ng-binding ng-scope">
                    <a
                        href="javascript:void(0);"
                        nb-dialog
                        template-url="partials/common/{{row.entity.action == '修改'? 'update_change_review.tpl.html': 'create_change_review.tpl.html'}}"
                        locals="{'change': row.entity}"> {{row.entity.auditableType}}
                    </a>
                </div>
                '''
            }
            {name:"createdAt", displayName:"变更时间"}
            {
                displayName: '操作'
                field: 'statusCd'
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <div class="radio-group" radio-box ng-model="row.entity.statusCd"></div>
                </div>
                '''
            }
            {
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
            {name:"department.name", displayName:"所属部门"}
            {name:"name", displayName:"姓名"}
            {name:"employeeNo", displayName:"员工编号"}
            {
                displayName: '信息变更模块'
                field: 'auditableType'
                cellTemplate: '''
                <div class="ui-grid-cell-contents ng-binding ng-scope">
                    <a
                        href="javascript:void(0);"
                        nb-dialog
                        template-url="partials/common/{{row.entity.action == '修改'? 'update_change_review.tpl.html': 'create_change_review.tpl.html'}}"
                        locals="{'change': row.entity}"> {{row.entity.auditableType}}
                    </a>
                </div>
                '''
            }
            {name:"createdAt", displayName:"变更时间"}
            {name:"statusCd", displayName:"状态", cellFilter: "dictmap:'personnel'"}
            {name:"checkDate", displayName:"审核时间"}
            {name:"reason", displayName:"理由"}
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


class EmployeePerformanceCtrl extends nb.Controller
    @.$inject = ['$scope', 'Employee', 'Performance']

    constructor: (@scope, @Employee, @Performance)->

    loadData: (employee)->
        self = @
        employee.performances.$refresh().$then (performances)->
            self.performances = _.groupBy performances, (item)-> item.assessYear

class EmployeeRewardPunishmentCtrl extends nb.Controller
    @.$inject = ['$scope', 'Employee', 'Reward', 'Punishment']

    constructor: (@scope, @Employee, @Reward, @Punishment)->

    loadData: (employee)->
        #@rewards = employee.rewards.$refresh()
        @punishments = employee.punishments.$refresh()


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

    postLink = (elem, attrs, ctrl)->

    return {
        scope: {
            positions: "=ngModel"
            editStatus: "=editing"
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
    @.$inject = ['$scope', 'CURRENT_ROLES']

    constructor: (@scope, @CURRENT_ROLES) ->
        @year_list = @$getYears()
        @month_list = @$getMonths()

        @currentYear = @year_list[0]
        @currentMonth = @month_list[@month_list.length - 1]

    calcTime: ()->
        @currentYear + '-' + @currentMonth

    isHrPaymentMember: ()->
        @CURRENT_ROLES.indexOf('hr_payment_member') >= 0

    loadSalary: ()->
        console.error '载入' + @calcTime() + '薪酬'


app.controller('PersonnelSort', PersonnelSort)
app.controller('LeaveEmployeesCtrl', LeaveEmployeesCtrl)
app.controller('MoveEmployeesCtrl', MoveEmployeesCtrl)
app.controller('EmployeePerformanceCtrl', EmployeePerformanceCtrl)
app.controller('EmployeeRewardPunishmentCtrl', EmployeeRewardPunishmentCtrl)
app.controller('PersonnelDataCtrl', PersonnelDataCtrl)
