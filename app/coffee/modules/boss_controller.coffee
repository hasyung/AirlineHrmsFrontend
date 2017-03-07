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


class BossLaborsController extends BossBaseController
    @.$inject = ['$scope', '$http', 'Employee', 'LeaveEmployees', 'ReportNeedToKnow', 'REPORT_CHECKER', 'BarChartService']

    constructor: (@scope, @http, @Employee, @LeaveEmployees, @ReportNeedToKnow, @reportCheckers, BarChartService) ->
        super(@scope, @http, @ReportNeedToKnow, '劳动关系管理室')

        @datasType = '公司人员进出'
        @showChartInDialog = true
        @tableTypeInDialog = '新进员工'

        @barOptionInDialog = {}

        @barConfig = {
            theme:''
            dataLoaded:true
        }

        @barOption = BarChartService
            .initial()
            .setTitle('新进/离职人员分布')
            .setLegend(['新进人员','离职人员'])
            .fetchSmallOptions()

        @barOptionInDialog = BarChartService
            .initial()
            .setTitle('新进/离职人员分布')
            .setLegend(['新进人员','离职人员'])
            .fetchBigOptions()

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

        @loadDateTime()
        @loadInitialData()
        @loadChartData()

    loadInitialData: () ->
        month = @currentCalcTime()

        tableParam = {
            month: month
        }

        @newEmployees = @Employee.$collection().$fetch(tableParam)
        @LeaveEmployees = @LeaveEmployees.$collection().$fetch(tableParam)

    loadChartData: () ->
        self = @

        @loadMonthList()

        month = @currentCalcTime()

        tableParam = {
            month: month
        }

        @http.get('/api/statements/new_leave_employee_summary?month='+month)
            .success (data) ->
                barSrc = self.dataFormatForBar(data.new_leave_employee_summary)
                self.barOption.yAxis[0].data = barSrc['yAxisData']
                self.barOption.series[0].data = barSrc['seriesA']
                self.barOption.series[1].data = barSrc['seriesB']

                self.barOptionInDialog.yAxis[0].data = barSrc['yAxisData']
                self.barOptionInDialog.series[0].data = barSrc['seriesA']
                self.barOptionInDialog.series[1].data = barSrc['seriesB']

                self.initialDataCompleted = true
            .error (msg) ->

        @newEmployees.$refresh(tableParam)
        @LeaveEmployees.$refresh(tableParam)

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
    @.$inject = ['$scope', '$http', 'ReportNeedToKnow', 'AdjustPositionRecord', '$enum', '$q', 'PieChartService']

    constructor: (@scope, @http, @ReportNeedToKnow, @AdjustPositionRecord, @enum, @q, PieChartService) ->
        super(@scope, @http, @ReportNeedToKnow, '人事调配管理室')
        self = @
        @datasType = '调岗记录'
        @channels = []

        @positionChangePieOption = PieChartService
            .initial()
            .setTitle('员工调岗来源')
            .setSeriesName('调岗来源')
            .fetchSmallOptions()

        @positionChangePieOptionInDialog = PieChartService
            .initial()
            .setTitle('员工调岗来源')
            .setSeriesName('调岗来源')
            .fetchBigOptions()

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
        @loadPositionChangesData(true)

    getChannels: () ->
        self = @
        month = @currentCalcTime()
        
        deferred = @q.defer()

        @http.get('/api/statements/position_change_record_channel?month='+month)
            .success (data) ->
                self.channels = data.channels
                deferred.resolve()
            .error (msg) ->
                deferred.reject()

        return deferred.promise;


    loadInitialData: () ->
        month = @currentCalcTime()
        channel = @positionChangeTableType

        tableParam = {
            month: month
            channel_name: channel
        }

        @adjustPositionRecords = @AdjustPositionRecord.$collection().$fetch(tableParam)

    loadPositionChangesData: (needResetChannel) ->
        self = @

        @loadMonthList()

        @getChannels().then () ->
            if angular.isDefined(needResetChannel)
                self.positionChangeTableType = _.head self.channels
            
            month = self.currentCalcTime()
            channel = self.positionChangeTableType

            tableParam = {
                month: month
                channel_name: channel
            }

            self.http.get('api/statements/position_change_record_pie?month='+month+'&channel_name='+channel)
                .success (data) ->
                    pieSeries = []
                    pieLegend = []

                    positionChangeSrc = data.position_change_record_pie

                    _.map positionChangeSrc, (val, key) ->
                        pieSeries.push({ value: val, name: key })
                        pieLegend.push(key)

                    self.positionChangePieOption.legend.data = pieLegend
                    self.positionChangePieOption.series[0].data = pieSeries

                    self.positionChangePieOptionInDialog.legend.data = pieLegend
                    self.positionChangePieOptionInDialog.series[0].data = pieSeries

                    self.initialDataCompleted = true

                .error (msg) ->

            self.adjustPositionRecords.$refresh(tableParam)


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
    @.$inject = ['$scope', '$http', 'ReportNeedToKnow', 'BrokenLineChartService', 'PieChartService']

    constructor: (@scope, @http, @ReportNeedToKnow, BrokenLineChartService, PieChartService) ->
        super(@scope, @http, @ReportNeedToKnow, '福利管理室')

        @datasType = '福利费用'
        @welfareFeeType = '福利费'
        
        @importing = false

        @brokenLineConfig = {
            theme:''
            dataLoaded:true
        }

        @pieConfig = {
            theme:''
            dataLoaded:true
        }

        @brokenLineOpition = BrokenLineChartService
            .initial()
            .setLegend(['福利费','社会保险费','公积金','企业年金'])
            .fetchSmallOptions()

        @brokenLineOpitionInDialog = BrokenLineChartService
            .initial()
            .setLegend(['福利费','社会保险费','公积金','企业年金'])
            .fetchBigOptions()

        @welfareFeesPieOption = PieChartService
            .initial()
            .fetchSmallOptions()

        @welfareFeesPieOptionInDialog = PieChartService
            .initial()
            .fetchBigOptions()

        @loadDateTime()
        @loadWelfareFees(@currentYear)
        @loadWelfareFeesForPie()

    loadDateTime: () ->
        super()

        @currentYear1 = _.last(@year_list)
        @currentMonth1 = _.last(@month_list)

    loadMonthList1: () ->
        if @currentYear1 == new Date().getFullYear()
            months = [1..new Date().getMonth() + 1]
        else
            months = [1..12]

        @month_list = _.map months, (item)->
            item = '0' + item if item < 10
            item + ''

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
                    fee.symbolSize = 10

                    _.forEach outVal, (inVal, inKey)->
                        valArr.push inVal
                        xAxisArray.push(inKey+'月') if !_.includes xAxisArray, inKey

                    fee.data = valArr
                    welfareFees.push fee
                    
                self.brokenLineOpition.xAxis.data = xAxisArray
                self.brokenLineOpition.series = welfareFees

                self.brokenLineOpitionInDialog.xAxis.data = xAxisArray
                self.brokenLineOpitionInDialog.series = welfareFees

            .error (err)->
                console.log err

    loadWelfareFeesForPie: () ->
        self = @

        @loadMonthList1()

        category = @welfareFeeType
        year = @currentYear1
        month = @currentMonth1

        @http.get('/api/welfare_fees/getcategory_with_year?year='+year+'&category='+category)
            .success (data) ->
                pieSeries = []
                pieLegend = ['已使用', '剩余']

                total = 0
                leave = 0

                welfareFeesSrc = data.welfare_fees

                _.forEach welfareFeesSrc, (val, key) ->
                    if parseInt(key.split('-')[1], 10) <= parseInt(self.currentMonth1, 10) && key != '剩余'
                        total = total + parseInt(val, 10)
                    else
                        leave = leave + parseInt(val, 10)

                pieSeries.push({ value: total, name: '已使用' })
                pieSeries.push({ value: leave, name: '剩余' })

                self.welfareFeesPieOption.title.text = category
                self.welfareFeesPieOption.legend.data = pieLegend
                self.welfareFeesPieOption.series[0].name = category
                self.welfareFeesPieOption.series[0].data = pieSeries

                self.welfareFeesPieOptionInDialog.title.text = category
                self.welfareFeesPieOptionInDialog.legend.data = pieLegend
                self.welfareFeesPieOptionInDialog.series[0].name = category
                self.welfareFeesPieOptionInDialog.series[0].data = pieSeries

                self.initialDataCompleted = true

            .error (err) ->
                console.log err

        
class BossContactController extends BossBaseController
    @.$inject = ['$scope', '$http']

    constructor: (@scope, @http) ->

app.controller 'BossCtrl', BossDashBoardController


app.config(Route)
