nb = @.nb
app = nb.app


class Route
    @.$inject = ['$stateProvider', '$urlRouterProvider']

    constructor: (stateProvider, urlRouterProvider) ->
        stateProvider
            .state 'boss', {
                url: '/dashboard'
                views: {
                    boss_datas: {
                        templateUrl: '/partials/shared/boss_datas/labors/labors.html'
                        controller: BossLaborsController
                        controllerAs: 'ctrl'
                    }
                }
            }
            .state 'boss_labors', {
                url: '/dashboard/labors'
                views: {
                    boss_datas: {
                        templateUrl: '/partials/shared/boss_datas/labors/labors.html'
                        controller: BossLaborsController
                        controllerAs: 'ctrl'
                    }
                }
            }
            .state 'boss_human', {
                url: '/dashboard/human'
                views: {
                    boss_datas: {
                        templateUrl: '/partials/shared/boss_datas/human/human.html'
                        controller: BossHumanController
                        controllerAs: 'ctrl'
                    }
                }
            }
            .state 'boss_salary', {
                url: '/dashboard/salary'
                views: {
                    boss_datas: {
                        templateUrl: '/partials/shared/boss_datas/salary/salary.html'
                        controller: BossSalaryController
                        controllerAs: 'ctrl'
                    }
                }
            }
            .state 'boss_flyer', {
                url: '/dashboard/flyer'
                views: {
                    boss_datas: {
                        templateUrl: '/partials/shared/boss_datas/flyer/flyer.html'
                        controller: BossFlyerController
                        controllerAs: 'ctrl'
                    }
                }
            }
            .state 'boss_practice', {
                url: '/dashboard/practice'
                views: {
                    boss_datas: {
                        templateUrl: '/partials/shared/boss_datas/practice/practice.html'
                        controller: BossPracticeController
                        controllerAs: 'ctrl'
                    }
                }
            }
            .state 'boss_service', {
                url: '/dashboard/service'
                views: {
                    boss_datas: {
                        templateUrl: '/partials/shared/boss_datas/service/service.html'
                        controller: BossServiceController
                        controllerAs: 'ctrl'
                    }
                }
            }
            .state 'boss_welfare', {
                url: '/dashboard/welfare'
                views: {
                    boss_datas: {
                        templateUrl: '/partials/shared/boss_datas/welfare/welfare.html'
                        controller: BossWelfareController
                        controllerAs: 'ctrl'
                    }
                }
            }
            
            


class BossDashBoardController extends nb.Controller
    @.$inject = ['$scope', '$rootScope', 'Todo', '$state', '$timeout', 'USER_META', 'REPORT_CHECKER']

    constructor: (@scope, @rootScope, Todo, @state, @timeout, USER_META, REPORT_CHECKER) ->
        @isHrGeneralManager = false
        @isHrDeputyManager = false
        @isServiceDeputyManager = false

        @messagesType='交流分享'
        @user = USER_META
        @reportCheckers = REPORT_CHECKER

        @checkBossType()

        @todos = Todo.$collection().$fetch()

    redirectTo: (state) ->
        self = @

        # 切换状态
        @state.go(state)

        @timeout ()->
            self.rootScope.show_main = true
            self.rootScope.selectPendingAnother = true
        , 800 

    checkBossType: () ->
        self = @
        userPositionIds = []

        @user.positions.forEach (current)->
            userPositionIds.push current.position.id

        if userPositionIds.indexOf(@reportCheckers['人力资源部总经理']) > -1
            self.isHrGeneralManager = true
            self.state.go('boss')

        else if userPositionIds.indexOf(@reportCheckers['副总经理（人事、劳动关系、招飞）']) > -1
            self.isHrDeputyManager = true
            self.state.go('boss')

        else if userPositionIds.indexOf(@reportCheckers['副总经理（培训、员工服务）']) > -1
            self.isServiceDeputyManager = true
            self.timeout ()->
                self.state.go('boss_practice')
            ,100


class BossBaseController extends nb.Controller
    constructor: (@scope, @http, @ReportNeedToKnow, depName) ->
        @initialDataCompleted = false
        @datasType = '汇报'
        @showChart = true

        @chartConfig = {
            theme:''
            dataLoaded:true
        }


        @loadDateTime()
        @loadReports(depName)

    loadReports: (name) ->
        @reports = @ReportNeedToKnow.$collection().$fetch({department_name: name})

    isImgObj: (obj)->
        return /jpg|jpeg|png|gif/.test(obj.type)

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


class BossLaborsController extends nb.Controller
    @.$inject = ['$scope', '$http', 'Employee', 'LeaveEmployees', 'ReportNeedToKnow', 'REPORT_CHECKER']

    constructor: (@scope, @http, @Employee, @LeaveEmployees, @ReportNeedToKnow, @reportCheckers) ->
        @initialDataCompleted = false
        @datasType = '汇报'
        @showChartInDialog = true
        @tableTypeInDialog = '新进员工'

        @loadDateTime()
        @loadInitialData()
        @loadChartData()

        @barOptionInDialog = {}

        @barConfig = {
            theme:''
            dataLoaded:true
        }

        @barOption = {
            title : {
                left: 20
                text: '新进/离职人员分布'
                textStyle: {
                    fontSize: 14
                }
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
                    axisLabel: { 
                        'interval': 0
                    }
                    splitLine: { show: false }
                    data: []
                }
            ],
            grid : {
                left: '20%'
                right: '5%'
            },
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

        @barOptionInDialog = {
            title : {
                left: 20
                text: '新进/离职人员分布'
                textStyle: {
                    fontSize: 18
                }
            },
            tooltip : {
                trigger: 'axis'
                axisPointer: {
                    type: 'shadow'
                }
                textStyle: {
                    fontSize: 16
                }
            },
            legend: {
                data:['新进人员','离职人员']
                textStyle: {
                    fontSize: 16
                }
            },
            calculable : true
            xAxis : [
                {
                    type: 'value'
                    axisLabel: { 
                        'interval': 0
                        textStyle: {
                            fontSize: 16
                        }
                    }
                }
            ],
            yAxis : [
                {
                    type: 'category'
                    axisLabel: { 
                        'interval': 0
                        textStyle: {
                            fontSize: 16
                        }
                    }
                    splitLine: { show: false }
                    data: []
                }
            ],
            grid : {
                left: '20%'
                right: '5%'
            },
            series : [
                {
                    name:'新进人员'
                    type:'bar'
                    data:[]
                    markPoint : {
                        data : [
                            {type : 'max', name: '最大值'}
                        ]
                        label: {
                            normal: {
                                textStyle: {
                                    fontSize: 16
                                }
                            }
                            emphasis: {
                                textStyle: {
                                    fontSize: 16
                                }
                            }
                        }
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
                        label: {
                            normal: {
                                textStyle: {
                                    fontSize: 16
                                }
                            }
                            emphasis: {
                                textStyle: {
                                    fontSize: 16
                                }
                            }
                        }
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
                name: 'name'
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
                name: 'name'
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
        @reports = @ReportNeedToKnow.$collection().$fetch({department_name: '劳动关系管理室'})

    loadChartData: () ->
        self = @

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

                self.barOptionInDialog.yAxis[0].data = self.barSrc['yAxisData']
                self.barOptionInDialog.series[0].data = self.barSrc['seriesA']
                self.barOptionInDialog.series[1].data = self.barSrc['seriesB']

                self.initialDataCompleted = true
            .error (msg) ->

        @newEmployees.$refresh(tableParam)
        @LeaveEmployees.$refresh(tableParam)

    isImgObj: (obj)->
        return /jpg|jpeg|png|gif/.test(obj.type)

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
            config['yAxisData'].push(key)

            config['seriesA'].push(val.new | 0)
            config['seriesB'].push(val.leave | 0)

            index++
        
        return config

class BossHumanController extends BossBaseController
    @.$inject = ['$scope', '$http', 'ReportNeedToKnow', 'AdjustPositionRecord', '$enum']

    constructor: (@scope, @http, @ReportNeedToKnow, @AdjustPositionRecord, @enum) ->
        super(@scope, @http, @ReportNeedToKnow, '人事调配管理室')
        @channels = []

        @getChannels()
        @positionChangeTableType = _.last(@channels)

        @positionChangePieOption = {
            title : {
                text: '员工调岗来源',
                x:'center'
            },
            tooltip : {
                trigger: 'item',
                formatter: "{a} <br/>{b} : {c} ({d}%)"
            },
            legend: {
                orient: 'vertical',
                left: '5%',
                top: '5%',
                data: []
            },
            series : [
                {
                    name: '调岗来源',
                    type: 'pie',
                    radius : '55%',
                    center: ['50%', '50%'],
                    data:[],
                    itemStyle: {
                        emphasis: {
                            shadowBlur: 10,
                            shadowOffsetX: 0,
                            shadowColor: 'rgba(0, 0, 0, 0.5)'
                        }
                    }
                }
            ]
        }

        @positionChangePieOptionInDialog = {
            title : {
                text: '员工调岗来源'
                x:'center'
                textStyle: {
                    fontSize: 18
                }
            },
            tooltip : {
                trigger: 'item',
                formatter: "{a} <br/>{b} : {c} ({d}%)"
                textStyle: {
                    fontSize: 16
                }
            },
            legend: {
                orient: 'vertical',
                left: '5%',
                top: '5%',
                data: []
                textStyle: {
                    fontSize: 16
                }
            },
            series : [
                {
                    name: '调岗来源',
                    type: 'pie',
                    radius : '55%',
                    center: ['50%', '50%'],
                    data:[],
                    itemStyle: {
                        emphasis: {
                            shadowBlur: 10,
                            shadowOffsetX: 0,
                            shadowColor: 'rgba(0, 0, 0, 0.5)'
                        }
                    }
                    label: {
                        normal: {
                            textStyle: {
                                fontSize: 16
                            }
                        }
                        emphasis: {
                            textStyle: {
                                fontSize: 16
                            }
                        }
                    }
                }
            ]
        }

        @adjustPositionDef = [
            {
                minWidth: 120
                displayName: '员工编号'
                name: 'employeeNo'
            }
            {
                minWidth: 120
                displayName: '姓名'
                name: 'employeeName'
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
                minWidth: 500
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

        @loadInitialData()
        @loadPositionChangesData()

    getChannels: () ->
        self = @
        month = @currentCalcTime()

        @http.get('/api/statements/position_change_record_channel?month='+month)
            .success (data) ->
                self.channels = []
                self.channels = data.channels


    loadInitialData: () ->
        month = @currentCalcTime()
        channel = @positionChangeTableType

        tableParam = {
            month: month
            channel_name: channel
        }

        @adjustPositionRecords = @AdjustPositionRecord.$collection().$fetch(tableParam)

    loadPositionChangesData: () ->
        self = @

        @loadMonthList()

        month = @currentCalcTime()
        channel = @positionChangeTableType

        tableParam = {
            month: month
            channel_name: channel
        }

        @http.get('api/statements/position_change_record_pie?month='+month+'&channel_name='+channel)
            .success (data) ->
                pieSeries = []
                pieLegend = []

                self.positionChangeSrc = data.position_change_record_pie

                _.map self.positionChangeSrc, (val, key) ->
                    pieSeries.push({ value: val, name: key })
                    pieLegend.push(key)

                self.positionChangePieOption.legend.data = pieLegend
                self.positionChangePieOption.series[0].data = pieSeries

                self.positionChangePieOptionInDialog.legend.data = pieLegend
                self.positionChangePieOptionInDialog.series[0].data = pieSeries

                self.initialDataCompleted = true

            .error (msg) ->

        @adjustPositionRecords.$refresh(tableParam)


class BossSalaryController extends BossBaseController
    @.$inject = ['$scope', '$http', 'ReportNeedToKnow']

    constructor: (@scope, @http, @ReportNeedToKnow) ->
        super(@scope, @http, @ReportNeedToKnow, '薪酬管理室')

class BossFlyerController extends BossBaseController
    @.$inject = ['$scope', '$http', 'ReportNeedToKnow']

    constructor: (@scope, @http, @ReportNeedToKnow) ->
        super(@scope, @http, @ReportNeedToKnow, '飞行员招聘管理室')

class BossPracticeController extends BossBaseController
    @.$inject = ['$scope', '$http', 'ReportNeedToKnow']

    constructor: (@scope, @http, @ReportNeedToKnow) ->
        super(@scope, @http, @ReportNeedToKnow, '培训管理室')

class BossServiceController extends BossBaseController
    @.$inject = ['$scope', '$http', 'ReportNeedToKnow']

    constructor: (@scope, @http, @ReportNeedToKnow) ->
        super(@scope, @http, @ReportNeedToKnow, '员工服务室')


class BossWelfareController extends BossBaseController
    @.$inject = ['$scope', '$http', 'ReportNeedToKnow']

    constructor: (@scope, @http, @ReportNeedToKnow) ->
        super(@scope, @http, @ReportNeedToKnow, '福利管理室')

        
class BossContactController extends BossBaseController
    @.$inject = ['$scope', '$http']

    constructor: (@scope, @http) ->

app.controller 'BossCtrl', BossDashBoardController


app.config(Route)
