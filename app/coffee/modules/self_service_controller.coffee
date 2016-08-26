nb = @.nb
app = nb.app


class Route
    @.$inject = ['$stateProvider', '$urlRouterProvider']

    constructor: (stateProvider, urlRouterProvider) ->
        stateProvider
            .state 'self', {
                url: '/self-service'
                templateUrl: 'partials/self/self_info.html'
                controller: ProfileCtrl
                controllerAs: 'ctrl'
            }
            .state 'self.profile', {
                url: '/profile'
                controller: ProfileCtrl
                controllerAs: 'ctrl'
                templateUrl: 'partials/self/self_info_basic/self_info_basic.html'
            }
            .state 'self.members', {
                url: '/members'
                controller: ProfileCtrl
                controllerAs: 'ctrl'
                templateUrl: 'partials/self/self_info_family/self_info_members.html'
            }
            .state 'self.education', {
                url: '/education'
                controller: ProfileCtrl
                controllerAs: 'ctrl'
                templateUrl: 'partials/self/education.html'
            }
            .state 'self.experience', {
                url: '/experience'
                controller: ProfileCtrl
                controllerAs: 'ctrl'
                templateUrl: 'partials/self/experience.html'
            }
            .state 'self.leader_experience', {
                url: '/leader_experience'
                controller: ProfileCtrl
                controllerAs: 'ctrl'
                templateUrl: 'partials/self/leader_exp.html'
            }
            .state 'self.attendance', {
                url: '/attendance'
                controller: ProfileCtrl
                controllerAs: 'ctrl'
                templateUrl: 'partials/self/attendance.html'
            }
            .state 'self.performance', {
                url: '/performance'
                controller: ProfileCtrl
                controllerAs: 'ctrl'
                templateUrl: 'partials/self/performance/performance.html'
            }
            .state 'self.technical', {
                url: '/technical'
                controller: ProfileCtrl
                controllerAs: 'ctrl'
                templateUrl: 'partials/self/technical/technical_records.html'
            }
            .state 'self.reward_punishment', {
                url: '/reward_punishment'
                controller: ProfileCtrl
                controllerAs: 'ctrl'
                templateUrl: 'partials/self/reward_punishment.html'
            }
            .state 'self.resume', {
                url: '/resume'
                controller: ProfileCtrl
                controllerAs: 'ctrl'
                templateUrl: 'partials/self/self_resume.html'
            }
            .state 'charts', {
                url: '/charts'
                templateUrl: 'partials/role/chart_index.html'
            }
            .state 'my_requests', {
                url: '/self/my_requests'
                templateUrl: 'partials/self/my_requests/index.html'
            }
            .state 'my_requests.leave', {
                url: '/leave'
                views: {
                    '@': {
                        templateUrl: 'partials/self/my_requests/leave/index.html'
                        controller: MyRequestCtrl
                        controllerAs: 'ctrl'
                    }
                }
            }
            .state 'my_requests.annuity', {
                url: '/annuity'
                views: {
                    '@': {
                        templateUrl: 'partials/self/my_requests/annuity/index.html'
                        controller: MyRequestCtrl
                        controllerAs: 'ctrl'
                    }
                }
            }
            .state 'my_requests.performance', {
                url: '/performance'
                views: {
                    '@': {
                        templateUrl: 'partials/self/my_requests/performance/index.html'
                        controller: MyRequestCtrl
                        controllerAs: 'ctrl'
                    }
                }
            }
            .state 'my_requests.resignation', {
                url: '/resignation'
                views: {
                    '@': {
                        templateUrl: 'partials/self/my_requests/resignation/index.html'
                        controller: 'SbFlowHandlerCtrl'
                        resolve: {
                            'FlowName': -> 'Flow::Resignation'
                            'ColumnDef': (GridHelper) ->
                                return GridHelper.buildDefault([
                                    {displayName: '通道', name: 'receptor.channel'}
                                    {displayName: '用工性质', name: 'receptor.laborRelation'}
                                    {displayName: '状态', name: 'workflowState'}
                                    {displayName: '离职发起', name: 'leaveJobFlowState', cellFilter: "date:'yyyy-MM-dd'"}
                                    {displayName: '发起时间', name: 'createdAt', cellFilter: "date:'yyyy-MM-dd'"}
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
                                ])
                        }
                    }
                }
            }
            .state 'my_requests.renew_contract', {
                url: '/renew_contract'
                views: {
                    '@': {
                        templateUrl: 'partials/self/my_requests/renew_contract/index.html'
                        controller: 'SbFlowHandlerCtrl'
                        resolve: {
                            'FlowName': -> 'Flow::RenewContract'
                            'ColumnDef': (GridHelper) ->
                                return GridHelper.buildDefault([
                                    {displayName: '状态', name: 'workflowState'}
                                    {displayName: '变更标志', name: 'signState'}
                                    {displayName: '开始时间', name: 'startDate', cellFilter: "date:'yyyy-MM-dd'"}
                                    {displayName: '结束时间', name: 'endDate', cellFilter: "date:'yyyy-MM-dd'"}
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
                                ])
                        }
                    }
                }
            }
            .state 'my_requests.early_retirement', {
                url: '/early_retirement'
                views: {
                    '@': {
                        templateUrl: 'partials/self/my_requests/early_retirement/index.html'
                        controller: 'SbFlowHandlerCtrl'
                        resolve: {
                            'FlowName': -> 'Flow::EarlyRetirement'
                            'ColumnDef': (GridHelper) ->
                                return GridHelper.buildDefault([
                                    {displayName: '性别', name: 'receptor.gender'}
                                    {displayName: '通道', name: 'receptor.channel'}
                                    {displayName: '状态', name: 'workflowState'}
                                    {displayName: '出生日期', name: 'receptor.birthday', cellFilter: "date:'yyyy-MM-dd'"}
                                    {displayName: '申请发起时间', name: 'createdAt', cellFilter: "date:'yyyy-MM-dd'"}
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
                                ])
                        }
                    }
                }
            }
            .state 'my_requests.adjust_position', {
                url: '/adjust-position'
                views: {
                    '@': {
                        templateUrl: 'partials/self/my_requests/adjust_position/index.html'
                        controller: 'SbFlowHandlerCtrl'
                        resolve: {
                            'FlowName': -> 'Flow::AdjustPosition'
                            'ColumnDef': (GridHelper) ->
                                return GridHelper.buildDefault([
                                    {displayName: '转入部门', name: 'toDepartmentName'}
                                    {displayName: '转入岗位', name: 'toPositionName'}
                                    {displayName: '状态', name: 'workflowState'}
                                    {displayName: '申请发起时间', name: 'createdAt', cellFilter: "date:'yyyy-MM-dd'"}
                                    {
                                        name: 'type'
                                        displayName: '详细'
                                        cellTemplate: '''
                                        <div class="ui-grid-cell-contents">
                                            <a flow-handler="row.entity" flow-view>
                                                查看
                                            </a>
                                        </div>
                                        '''
                                    }
                                ])
                        }
                    }
                }
            }


class ProfileCtrl extends nb.Controller
    @.$inject = ['$scope', 'sweet', 'Employee', '$rootScope', 'User', 'USER_META', 'UserPerformance', 'Performance', '$filter', 'UserReward', 'UserPunishment', 'UserTechnicalRecords', '$http', '$nbEvent']

    constructor: (@scope, @sweet, @Employee, @rootScope, @User, @USER_META, @UserPerformance, @Performance, @filter, @UserReward, @UserPunishment, @UserTechnicalRecords, @http, @Evt) ->
        @loadInitialData()
        @status = 'show'

        @nations = [ '汉族'  , '壮族' , '满族' , '回族' , '苗族'  , '维吾尔族'  , '土家族'
                , '彝族'  , '蒙古族'  ,' 藏族'  , '布依族'  ,' 侗族'  ,' 瑶族'  , '朝鲜族'
                ,' 白族'  , '哈尼族'  , '哈萨克族'  ,' 黎族'  ,' 傣族'  ,' 畲族'  , '傈僳族'
                , '仡佬族'  , '东乡族'  , '高山族'  , '拉祜族'  ,' 水族'  ,' 佤族'  , '纳西族'
                ,' 羌族'  ,' 土族'  , '仫佬族'  , '锡伯族'  , '柯尔克孜族'  , '达斡尔族'  , '景颇族'
                , '毛南族'  , '撒拉族'  , '布朗族'  , '塔吉克族'  , '阿昌族'  , '普米族'  , '鄂温克族'
                ,' 怒族'  ,' 京族'  , '基诺族'  , '德昂族'  , '保安族'  , '俄罗斯族'  , '裕固族'
                , '乌兹别克族'  , '门巴族'  , '鄂伦春族'  , '独龙族'  , '塔塔尔族'  , '赫哲族'  , '珞巴族']

    dayOnClick: ()->
        #

    loadInitialData: () ->
        @scope.currentUser = @User.$fetch()

    # 员工自助中员工编辑自己的信息
    updateInfo: ->
        @scope.currentUser.$update()

    updateEdu: (edu)->
        edu.$save()

    createEdu: (edu)->
        @scope.currentUser.educationExperiences.createEdu(edu)
        # @scope.currentUser.$update()

    updateFavicon: ()->
        self = @
        @scope.currentUser.$refresh().$then ()->
            angular.extend self.USER_META.favicon, self.scope.currentUser.favicon

    loadPerformance: ()->
        self = @
        @UserPerformance.$collection().$fetch().$then (performances)->
            self.performances = _.sortBy((_.groupBy performances, (item)-> item.assessYear)).reverse()

    loadRewards: ()->
        @rewards = @UserReward.$collection().$fetch()

    loadTechnicalRecords: ()->
        @technicalRecords = @UserTechnicalRecords.$collection().$fetch()

    loadPunishments: ()->
        @punishments = @UserPunishment.$collection().$fetch()

    allege: (performance, request)->
        performance.allege(request)

    loadAttendance: ()->
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
                monthNamesShort: ["一月", "二月", "三月", "四月", "五月", "六月", "七月","八月","九月","十月","十一月","十二月"]
                monthNames: ["一月", "二月", "三月", "四月", "五月", "六月", "七月","八月","九月","十月","十一月","十二月"]

                height: 450
                editable: false

                header: {
                  #left: 'month basicWeek basicDay agendaWeek agendaDay'
                  left: 'month basicWeek'
                  center: 'title'
                  right: 'today prev,next'
                }

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

        @http.get('/api/me/attendance_records/').success (data)->
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

    queryNations: (text) ->
        self = @
        nations = _.filter self.nations, (nation)->
            _.includes nation, text
        return nations

    clearLover: (lover) ->
        self = @

        lover.$destroy()


    isImgObj: (obj)->
        return /jpg|jpeg|png|gif/.test(obj.type)

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

    distinguishExp: (currentUser) ->
        self = @

        currentUser.workExperiences.$refresh().$then (works) ->
            workAfter = _.clone works, true
            _.remove workAfter, (work)->
                return work.category == 'before'

            workAfterEmployee = _.remove workAfter, (work)->
                return work.employeeCategory == '员工' || work.employeeCategory == null

            self.workBefore = _.filter works, _.matches({'category': 'before'})
            self.workAfterEmployee = workAfterEmployee
            self.workAfterLeader = workAfter


class MyRequestCtrl extends nb.Controller
    @.$inject = ['$scope', 'Employee', 'OrgStore', 'USER_META', 'VACATIONS', 'MyLeave', '$injector', 'UserAnnuity', '$http', 'toaster', 'UserAllege', 'User']

    constructor: (@scope, @Employee, @OrgStore, meta, vacations, @MyLeave, injector, @UserAnnuity, @http, @toaster, @UserAllege, @User) ->
        @scope.realFlow = (entity) ->
            t = entity.type
            m = injector.get(t)
            return m.$find(entity.$pk)

        @scope.meta = meta
        @scope.vacations = vacations

        @reviewers = @loadReviewer()

        @leaveCol = [
            {name:"receptor.employeeNo", displayName:"员工编号"}
            {name:"receptor.name", displayName:"姓名"}
            {name:"receptor.departmentName", displayName:"所属部门"}
            {name:"receptor.positionName", displayName:"岗位"}

            {name:"name", displayName:"假别"}
            {name:"vacationDays", displayName:"时长"}
            {name:"workflowState", displayName:"状态"}
            {name:"createdAt", displayName:"发起时间", cellFilter: "date:'yyyy-MM-dd'"}
            {
                field: 'action'
                displayName:"查看",
                cellTemplate: '''
                <div class="ui-grid-cell-contents" ng-init="realFlow = grid.appScope.$parent.realFlow(row.entity);">
                    <a flow-handler="realFlow" flow-view="true">
                        查看
                    </a>
                </div>
                '''
            }
        ]

        @allegeCol = [
            {name:"employeeNo", displayName:"员工编号"}
            {name:"employeeName", displayName:"姓名"}
            {name:"departmentName", displayName:"所属部门"}
            {name:"positionName", displayName:"岗位"}
            {name:"createdAt", displayName:"申诉时间", cellFilter:"date:'yyyy-MM-dd'"}
            {name:"assessTime", displayName:"考核时间"}
            {name:"result", displayName:"绩效"}
            {name:"category", displayName:"排名"}
            {name:"outcome", displayName:"申诉结果"}
            {
                name: 'type'
                displayName: '详细'
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a nb-panel
                        template-url="/partials/self/my_requests/performance/allege.html"
                        locals="{allege: row.entity}"
                    >
                        查看
                    </a>
                </div>
                '''
            }
        ]

    getSelected: () ->
        return unless @scope.$gridApi && @scope.$gridApi.selection
        rows = @scope.$gridApi.selection.getSelectedGridRows()
        selected = if rows.length >= 1 then rows[0].entity else null

    revert: (isConfirm, leave)->
        if isConfirm
            leave.revert()

    charge: (leave, params, leaves)->
        leave.charge(params).$then ()->
            leaves.$refresh()

    loadReviewer: () ->
        @Employee.flow_leaders()

    myRequests: (FlowName) ->
        @loadAnnuities()

    hasVacation: (name)->
        @scope.vacations.enable_vacation.indexOf(name) >= 0

    loadAnnuities: ()->
        self = @

        @columnDef = [
            {name:"employeeNo", displayName:"员工编号"}
            {name:"employeeName", displayName:"姓名"}
            {name:"departmentName", displayName:"所属部门"}
            {name:"positionName", displayName:"岗位"}
            {name:"calDate", displayName:"月度"}
            {name:"annuityCardinality", displayName:"基数"}
            {name:"personalPayment", displayName:"个人部分"}
            {name:"companyPayment", displayName:"公司部分"}
        ]

        @tableData = @UserAnnuity.$collection().$fetch()

        @UserAnnuity.$collection().$fetch().$asPromise().then (data) ->
            self.annuity_status = data.$response.data.meta.annuity_status
            self.annuity_apply_status = data.$response.data.meta.annuity_apply_status
            self.can_join_annuity = data.$response.data.meta.can_join_annuity

    toggleAnnuity: (status)->
        self = @

        @http.get('/api/annuity_apply/apply_for_annuity?status=' + status)
            .success (data)->
                self.toaster.pop('success', '提示', data.messages || '申请成功')
            .error (data)->
                self.toaster.pop('error', '提示', data.messages || '申请失败')

        self.operated = true


#分角色图表页面控制器部分
#图标主控制器 通用方法在这里
class ChartsMainController extends nb.Controller
    @.$inject = ['$scope','$rootScope', 'CURRENT_ROLES']

    constructor: (@scope, @rootScope, CURRENT_ROLES) ->
        @current_roles = CURRENT_ROLES

    checkRole: (role) ->
        _.includes @current_roles, role



class CompanyLeaderChartsController extends nb.Controller
    @.$inject = ['$scope', '$http', 'Employee', 'LeaveEmployees']

    constructor: (@scope, @http, @Employee, @LeaveEmployees) ->
        @initialDataCompleted = false
        @showChart = true
        @tableType = '新进员工'

        @loadDateTime()
        @loadInitialData()
        @loadChartData()

        @barConfig = {
            theme:''
            dataLoaded:true
        }

        @barOption = {
            title : {
                left: 50
                text: '新进/离职人员分布'
            },
            tooltip : {
                trigger: 'axis'
                axisPointer: {
                    type: 'shadow'
                }
            },
            legend: {
                data:['新进人员','离职人员']
            },
            calculable : true
            xAxis : [
                {
                    type: 'value'
                }
            ],
            yAxis : [
                {
                    type: 'category'
                    axisLabel: { 'interval':0 }
                    splitLine: { show: false }
                    data: []
                }
            ],
            series : [
                {
                    name:'新进人员'
                    type:'bar'
                    data:[]
                    markPoint : {
                        data : [
                            {type : 'max', name: '最大值'}
                        ]
                    },
                },
                {
                    name:'离职人员'
                    type:'bar'
                    data:[]
                    markPoint : {
                        data : [
                            {type : 'max', name: '最大值'}
                        ]
                    },
                }
            ]
        }

        @columnDefNew = [
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
            {minWidth: 120, displayName: '性别', name: 'genderId', cellFilter: "enum:'genders'"}
            {minWidth: 120, displayName: '到岗时间', name: 'joinScalDate', cellFilter: "date:'yyyy-MM-dd'"}
            {minWidth: 120, displayName: '实习时间', name: 'startInternshipDate', cellFilter: "date:'yyyy-MM-dd'"}
            {minWidth: 120, displayName: '通道', name: 'channelId', cellFilter: "enum:'channels'"}
        ]

        @columnDefLeave = [
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
                name: 'position'
                cellTooltip: (row) ->
                    return row.entity.position
            }
            {minWidth: 120, displayName: '性别', name: 'gender'}
            {minWidth: 120, displayName: '离职时间', name: 'changeDate', cellFilter: "date:'yyyy-MM-dd'"}
            {minWidth: 120, displayName: '通道', name: 'channelId', cellFilter: "enum:'channels'"}
        ]

    loadInitialData: () ->
        month = @currentCalcTime()

        tableParam = {
            month: month
        }

        @newEmployees = @Employee.$collection().$fetch(tableParam)
        @LeaveEmployees = @LeaveEmployees.$collection().$fetch(tableParam)

    loadChartData: () ->
        self = @

        # @initialDataCompleted = false
        @loadMonthList()

        month = @currentCalcTime()

        tableParam = {
            month: month
        }

        @http.get('/api/statements/new_leave_employee_summary?month='+month)
            .success (data) ->
                self.barSrc = self.dataFormatForBar(data.new_leave_employee_summary)
                self.barOption.yAxis[0].data = self.barSrc['yAxisData']
                self.barOption.series[0].data = self.barSrc['seriesA']
                self.barOption.series[1].data = self.barSrc['seriesB']

                self.initialDataCompleted = true
            .error (msg) ->

        @newEmployees.$refresh(tableParam)
        @LeaveEmployees.$refresh(tableParam)

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

    dataFormatForBar: (data) ->
        config = {}
        config['yAxisData'] = []
        config['seriesA'] = []
        config['seriesB'] = []

        index = 0

        _.forEach data, (val, key) ->
            if index %2 != 0
                config['yAxisData'].push('\n' + key)
            else
                config['yAxisData'].push(key)

            config['seriesA'].push(val.new | 0)
            config['seriesB'].push(val.leave | 0)

            index++
        
        return config

class CountyLeaderChartsController extends nb.Controller
    @.$inject = ['$scope', '$http', 'Employee', 'LeaveEmployees']

    constructor: (@scope, @http, @Employee, @LeaveEmployees) ->
        @initialDataCompleted = false
        @showChart = true
        @tableType = '新进员工'

        @loadDateTime()
        @loadInitialData()
        @loadChartData()

        @barConfig = {
            theme:''
            dataLoaded:true
        }

        @barOption = {
            title : {
                left: 50
                text: '新进/离职人员分布'
            },
            tooltip : {
                trigger: 'axis'
                axisPointer: {
                    type: 'shadow'
                }
            },
            legend: {
                data:['新进人员','离职人员']
            },
            calculable : true
            xAxis : [
                {
                    type: 'value'
                }
            ],
            yAxis : [
                {
                    type: 'category'
                    axisLabel: { 'interval':0 }
                    splitLine: { show: false }
                    data: []
                }
            ],
            series : [
                {
                    name:'新进人员'
                    type:'bar'
                    data:[]
                    markPoint : {
                        data : [
                            {type : 'max', name: '最大值'}
                        ]
                    },
                },
                {
                    name:'离职人员'
                    type:'bar'
                    data:[]
                    markPoint : {
                        data : [
                            {type : 'max', name: '最大值'}
                        ]
                    },
                }
            ]
        }

        @columnDefNew = [
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
            {minWidth: 120, displayName: '性别', name: 'genderId', cellFilter: "enum:'genders'"}
            {minWidth: 120, displayName: '到岗时间', name: 'joinScalDate', cellFilter: "date:'yyyy-MM-dd'"}
            {minWidth: 120, displayName: '实习时间', name: 'startInternshipDate', cellFilter: "date:'yyyy-MM-dd'"}
            {minWidth: 120, displayName: '通道', name: 'channelId', cellFilter: "enum:'channels'"}
        ]

        @columnDefLeave = [
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
                name: 'position'
                cellTooltip: (row) ->
                    return row.entity.position
            }
            {minWidth: 120, displayName: '性别', name: 'gender'}
            {minWidth: 120, displayName: '离职时间', name: 'changeDate', cellFilter: "date:'yyyy-MM-dd'"}
            {minWidth: 120, displayName: '通道', name: 'channelId', cellFilter: "enum:'channels'"}
        ]

    loadInitialData: () ->
        month = @currentCalcTime()

        tableParam = {
            month: month
        }

        @newEmployees = @Employee.$collection().$fetch(tableParam)
        @LeaveEmployees = @LeaveEmployees.$collection().$fetch(tableParam)

    loadChartData: () ->
        self = @

        # @initialDataCompleted = false
        @loadMonthList()

        month = @currentCalcTime()

        tableParam = {
            month: month
        }

        @http.get('/api/statements/new_leave_employee_summary?month='+month)
            .success (data) ->
                self.barSrc = self.dataFormatForBar(data.new_leave_employee_summary)
                self.barOption.yAxis[0].data = self.barSrc['yAxisData']
                self.barOption.series[0].data = self.barSrc['seriesA']
                self.barOption.series[1].data = self.barSrc['seriesB']

                self.initialDataCompleted = true
            .error (msg) ->

        @newEmployees.$refresh(tableParam)
        @LeaveEmployees.$refresh(tableParam)

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

    dataFormatForBar: (data) ->
        config = {}
        config['yAxisData'] = []
        config['seriesA'] = []
        config['seriesB'] = []

        index = 0

        _.forEach data, (val, key) ->
            if index %2 != 0
                config['yAxisData'].push('\n' + key)
            else
                config['yAxisData'].push(key)

            config['seriesA'].push(val.new | 0)
            config['seriesB'].push(val.leave | 0)

            index++
        
        return config

class DepartmentHrChartsController extends nb.Controller
    @.$inject = ['$scope']

    constructor: (@scope) ->
        @barConfig1 = {
            theme:'red'
            dataLoaded:true
        }

        @barConfig2 = {
            theme:'blue'
            dataLoaded:true
        }

        @barOption1 = {
            title : {
                text: '部门长期休假人员(两个月以上)百分比'
            },
            tooltip : {
                trigger: 'axis'
            },
            legend: {
                data:['A','B']
            },
            calculable : true,
            xAxis : [
                {
                    type : 'category',
                    data : ['人力资源部','专家委员会','企业文化部','标准管理部','保卫部','计划财务部','飞行部','商旅公司','校修中心','党委','机务工程部','物流部']
                }
            ],
            yAxis : [
                {
                    type : 'value'
                }
            ],
            series : [
                {
                    name:'A',
                    type:'bar',
                    data:[2.0, 4.9, 7.0, 23.2, 25.6, 76.7, 135.6, 162.2, 32.6, 20.0, 6.4, 3.3],
                    markPoint : {
                        data : [
                            {type : 'max', name: '最大值'},
                            {type : 'min', name: '最小值'}
                        ]
                    },
                    markLine : {
                        data : [
                            {type : 'average', name: '平均值'}
                        ]
                    }
                },
                {
                    name:'B',
                    type:'bar',
                    data:[2.6, 5.9, 9.0, 26.4, 28.7, 70.7, 175.6, 182.2, 48.7, 18.8, 6.0, 2.3],
                    markPoint : {
                        data : [
                            {name : '年最高', value : 182.2, xAxis: 7, yAxis: 183, symbolSize:18},
                            {name : '年最低', value : 2.3, xAxis: 11, yAxis: 3}
                        ]
                    },
                    markLine : {
                        data : [
                            {type : 'average', name : '平均值'}
                        ]
                    }
                }
            ]
        }

        @barOption2 = {
            title : {
                text: '部门年假完成率'
            },
            tooltip : {
                trigger: 'axis'
            },
            legend: {
                data:['A','B']
            },
            calculable : true,
            xAxis : [
                {
                    type : 'category',
                    data : ['人力资源部','专家委员会','企业文化部','标准管理部','保卫部','计划财务部','飞行部','商旅公司','校修中心','党委','机务工程部','物流部']
                }
            ],
            yAxis : [
                {
                    type : 'value'
                }
            ],
            series : [
                {
                    name:'A',
                    type:'bar',
                    data:[2.0, 4.9, 7.0, 23.2, 25.6, 76.7, 135.6, 162.2, 32.6, 20.0, 6.4, 3.3],
                    markPoint : {
                        data : [
                            {type : 'max', name: '最大值'},
                            {type : 'min', name: '最小值'}
                        ]
                    },
                    markLine : {
                        data : [
                            {type : 'average', name: '平均值'}
                        ]
                    }
                },
                {
                    name:'B',
                    type:'bar',
                    data:[2.6, 5.9, 9.0, 26.4, 28.7, 70.7, 175.6, 182.2, 48.7, 18.8, 6.0, 2.3],
                    markPoint : {
                        data : [
                            {name : '年最高', value : 182.2, xAxis: 7, yAxis: 183, symbolSize:18},
                            {name : '年最低', value : 2.3, xAxis: 11, yAxis: 3}
                        ]
                    },
                    markLine : {
                        data : [
                            {type : 'average', name : '平均值'}
                        ]
                    }
                }
            ]
        }

class DepartmentLeaderChartsController extends nb.Controller
    @.$inject = ['$http','$scope']

    constructor: (@http, @scope) ->
        @barConfig = {
            theme:'red'
            dataLoaded:true
        }

        @barOption = {
            title : {
                text: '离职岗位分布'
            },
            tooltip : {
                trigger: 'axis'
            },
            legend: {
                data:['A','B']
            },
            calculable : true,
            xAxis : [
                {
                    type : 'category',
                    data : ['人力资源部','专家委员会','企业文化部','标准管理部','保卫部','计划财务部','飞行部','商旅公司','校修中心','党委','机务工程部','物流部']
                }
            ],
            yAxis : [
                {
                    type : 'value'
                }
            ],
            series : [
                {
                    name:'A',
                    type:'bar',
                    data:[2.0, 4.9, 7.0, 23.2, 25.6, 76.7, 135.6, 162.2, 32.6, 20.0, 6.4, 3.3],
                    markPoint : {
                        data : [
                            {type : 'max', name: '最大值'},
                            {type : 'min', name: '最小值'}
                        ]
                    },
                    markLine : {
                        data : [
                            {type : 'average', name: '平均值'}
                        ]
                    }
                },
                {
                    name:'B',
                    type:'bar',
                    data:[2.6, 5.9, 9.0, 26.4, 28.7, 70.7, 175.6, 182.2, 48.7, 18.8, 6.0, 2.3],
                    markPoint : {
                        data : [
                            {name : '年最高', value : 182.2, xAxis: 7, yAxis: 183, symbolSize:18},
                            {name : '年最低', value : 2.3, xAxis: 11, yAxis: 3}
                        ]
                    },
                    markLine : {
                        data : [
                            {type : 'average', name : '平均值'}
                        ]
                    }
                }
            ]
        }

    loadOptions: (params) ->
        @barOption.series[0].data = [2.0, 2.9, 2.0, 2.2, 2.6, 2.7, 2.6, 2.2, 2.6, 2.0, 2.4, 2.3]

class HrLeaderChartsController extends nb.Controller
    @.$inject = ['$scope', '$http']

    constructor: (@scope, @http) ->
        @initialDataCompleted = false
        @showChart = true
        @tableType = '新进员工'

        @loadDateTime()
        @loadInitialData()
        @loadChartData()

        @barConfig = {
            theme:''
            dataLoaded:true
        }

        @barOption = {
            title : {
                left: 50
                text: '新进/离职人员分布'
            },
            tooltip : {
                trigger: 'axis'
                axisPointer: {
                    type: 'shadow'
                }
            },
            legend: {
                data:['新进人员','离职人员']
            },
            calculable : true
            xAxis : [
                {
                    type: 'value'
                }
            ],
            yAxis : [
                {
                    type: 'category'
                    axisLabel: { 'interval':0 }
                    splitLine: { show: false }
                    data: []
                }
            ],
            series : [
                {
                    name:'新进人员'
                    type:'bar'
                    data:[]
                    markPoint : {
                        data : [
                            {type : 'max', name: '最大值'}
                        ]
                    },
                },
                {
                    name:'离职人员'
                    type:'bar'
                    data:[]
                    markPoint : {
                        data : [
                            {type : 'max', name: '最大值'}
                        ]
                    },
                }
            ]
        }

        @pieConfig1 = {
            # theme:'red'
            dataLoaded:true
        }

        @pieOption1 = {
            title : {
                text: '学历分布',
                x:'center'
            },
            tooltip : {
                trigger: 'item',
                formatter: "{a} <br/>{b} : {c} ({d}%)"
            },
            legend: {
                orient : 'vertical',
                x : 'left',
                data:['大专','全日制本科','非全日制本科','研究生']
            },
            calculable : true,
            series : [
                {
                    name:'人数',
                    type:'pie',
                    radius : '55%',
                    center: ['50%', '60%'],
                    data:[
                        {value:335, name:'非全日制本科'},
                        {value:310, name:'研究生'},
                        {value:234, name:'大专'},
                        {value:1548, name:'全日制本科'}
                    ]
                }
            ]
        }

        @pieConfig2 = {
            theme:'blue'
            dataLoaded:true
        }

        @pieOption2 = {
            title : {
                text: '用工性质分布',
                x:'center'
            },
            tooltip : {
                trigger: 'item',
                formatter: "{a} <br/>{b} : {c} ({d}%)"
            },
            legend: {
                orient : 'vertical',
                x : 'left',
                data:['合同制','合同工','骐骥劳务','骐骥劳务(协议)','骐骥劳务(实习)','蓝天劳务','蓝天劳务(协议)','蓝天劳务(实习)','公务员','集团借调']
            },
            calculable : true,
            series : [
                {
                    name:'访问来源',
                    type:'pie',
                    radius : '55%',
                    center: ['50%', '60%'],
                    data:[
                        {value:335, name:'集团借调'},
                        {value:310, name:'公务员'},
                        {value:234, name:'骐骥劳务(协议)'},
                        {value:135, name:'骐骥劳务(实习)'},
                        {value:1548, name:'骐骥劳务'},
                        {value:234, name:'蓝天劳务(协议)'},
                        {value:135, name:'蓝天劳务(实习)'},
                        {value:878, name:'蓝天劳务'},
                        {value:1530, name:'合同制'},
                        {value:648, name:'合同工'}
                    ]
                }
            ]
        }

        @columnDefNew = [
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
            {minWidth: 120, displayName: '性别', name: 'genderId', cellFilter: "enum:'genders'"}
            {minWidth: 120, displayName: '到岗时间', name: 'joinScalDate', cellFilter: "date:'yyyy-MM-dd'"}
            {minWidth: 120, displayName: '实习时间', name: 'startInternshipDate', cellFilter: "date:'yyyy-MM-dd'"}
            {minWidth: 120, displayName: '通道', name: 'channelId', cellFilter: "enum:'channels'"}
        ]

        @columnDefLeave = [
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
                name: 'position'
                cellTooltip: (row) ->
                    return row.entity.position
            }
            {minWidth: 120, displayName: '性别', name: 'gender'}
            {minWidth: 120, displayName: '离职时间', name: 'changeDate', cellFilter: "date:'yyyy-MM-dd'"}
            {minWidth: 120, displayName: '通道', name: 'channelId', cellFilter: "enum:'channels'"}
        ]

    loadInitialData: () ->
        month = @currentCalcTime()

        tableParam = {
            month: month
        }

        @newEmployees = @Employee.$collection().$fetch(tableParam)
        @LeaveEmployees = @LeaveEmployees.$collection().$fetch(tableParam)

    loadChartData: () ->
        self = @

        # @initialDataCompleted = false
        @loadMonthList()

        month = @currentCalcTime()

        tableParam = {
            month: month
        }

        @http.get('/api/statements/new_leave_employee_summary?month='+month)
            .success (data) ->
                self.barSrc = self.dataFormatForBar(data.new_leave_employee_summary)
                self.barOption.yAxis[0].data = self.barSrc['yAxisData']
                self.barOption.series[0].data = self.barSrc['seriesA']
                self.barOption.series[1].data = self.barSrc['seriesB']

                self.initialDataCompleted = true
            .error (msg) ->

        @newEmployees.$refresh(tableParam)
        @LeaveEmployees.$refresh(tableParam)

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

    dataFormatForBar: (data) ->
        config = {}
        config['yAxisData'] = []
        config['seriesA'] = []
        config['seriesB'] = []

        index = 0

        _.forEach data, (val, key) ->
            if index %2 != 0
                config['yAxisData'].push('\n' + key)
            else
                config['yAxisData'].push(key)

            config['seriesA'].push(val.new | 0)
            config['seriesB'].push(val.leave | 0)

            index++
        
        return config

class WelfareManageChartsController extends nb.Controller
    @.$inject = ['$scope', '$http', 'toaster']

    constructor: (@scope, @http, @toaster) ->
        @importing = false

        @brokenLineConfig = {
            theme:'default'
            dataLoaded:true
        }

        @brokenLineOpition = {
            tooltip: {
                trigger: 'axis'
            },
            legend: {
                data:['福利费','社会保险费','公积金','企业年金']
            },
            grid: {
                left: '3%',
                right: '4%',
                bottom: '3%',
                containLabel: true
            },
            xAxis: {
                type: 'category',
                boundaryGap: false,
                data: []
            },
            yAxis: {
                type: 'value'
            },
            series: []
        }

        @loadDateTime()
        @loadWelfareFees(@currentYear)

    loadWelfareFees: (year) ->
        self = @
        welfareFees = []
        xAxisArray = []

        @http.get('/api/welfare_fees?year=' + year)
            .success (data)->
                _.forEach data.welfare_fees, (outVal, outKey)->
                    fee = new Object()
                    valArr = []
                    fee.name = outKey
                    fee.type = 'line'

                    _.forEach outVal, (inVal, inKey)->
                        valArr.push inVal
                        xAxisArray.push(inKey+'月') if !_.includes xAxisArray, inKey

                    fee.data = valArr
                    welfareFees.push fee
                    
                self.brokenLineOpition.xAxis.data = xAxisArray
                self.brokenLineOpition.series = welfareFees

            .error (err)->
                console.log err

    loadDateTime: () ->
        @year_list = @$getYears()

        @currentYear = _.last(@year_list)

    uploadWelfareFees: (type, attachment_id) ->
        self = @

        params = {type: type, attachment_id: attachment_id}
        @importing = true

        @http.post("/api/welfare_fees/import", params).success (data, status) ->
            self.toaster.pop('success', '提示', '导入成功')
            self.importing = false
        .error (data) ->
            self.toaster.pop('error', '提示', '导入失败')
            self.importing = false




        

app.controller 'ChartsMainCtrl', ChartsMainController
app.controller 'CompanyLeaderChartsCtrl', CompanyLeaderChartsController
app.controller 'CountyLeaderChartsCtrl', CountyLeaderChartsController
app.controller 'DepartmentHrChartsCtrl', DepartmentHrChartsController
app.controller 'DepartmentLeaderChartsCtrl', DepartmentLeaderChartsController
app.controller 'HrLeaderChartsCtrl', HrLeaderChartsController
app.controller 'WelfareManageChartsCtrl', WelfareManageChartsController


app.config(Route)