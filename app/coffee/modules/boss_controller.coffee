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
                        templateUrl: '/partials/shared/boss_datas/labors.html'
                        controller: BossLaborsController
                        controllerAs: 'ctrl'
                    }
                }
            }
            # .state 'boss.profile', {
            #     url: '/profile'
            #     controller: ProfileCtrl
            #     controllerAs: 'ctrl'
            #     templateUrl: 'partials/self/self_info_basic/self_info_basic.html'
            # }
            
            


class BossDashBoardController extends nb.Controller
    @.$inject = ['$scope', 'Todo', '$state']

    constructor: (@scope, Todo, @state) ->
        @state.go 'boss'

        @todos = Todo.$collection().$fetch()

class BossLaborsController extends nb.Controller
    @.$inject = ['$scope', '$http', 'Employee', 'LeaveEmployees']

    constructor: (@scope, @http, @Employee, @LeaveEmployees) ->
        @initialDataCompleted = false
        @datasType = '公司人员进出'
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
        



app.controller 'BossCtrl', BossDashBoardController


app.config(Route)