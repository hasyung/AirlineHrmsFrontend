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
            .state 'my_requests.erarly_retirement', {
                url: '/erarly_retirement'
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
    @.$inject = ['$scope', 'sweet', 'Employee', '$rootScope', 'User', 'USER_META', 'UserPerformance', 'Performance', '$filter', 'UserReward', 'UserPunishment', '$http']

    constructor: (@scope, @sweet, @Employee, @rootScope, @User, @USER_META, @UserPerformance, @Performance, @filter, @UserReward, @UserPunishment, @http) ->
        @loadInitialData()
        @status = 'show'

        date = new Date()
        d = date.getDate()
        m = date.getMonth()
        y = date.getFullYear()

        @events1 = {
            color: '#f00',
            textColor: 'yellow',
            events: [
                {title: 'All Day Event', start: new Date(y, m, 1)}
                {title: 'Long Event', start: new Date(y, m, d - 5), end: new Date(y, m, d - 2)}
                {id: 999,title: 'Repeating Event', start: new Date(y, m, d - 3, 16, 0), allDay: false}
            ]
        }

        @events2 = {
            color: '#f0f',
            textColor: 'blue',
            events: [
                {id: 999,title: 'Repeating Event', start: new Date(y, m, d + 4, 16, 0), allDay: false}
                {title: 'Birthday Party', start: new Date(y, m, d + 1, 19, 0), end: new Date(y, m, d + 1, 22, 30), allDay: false}
                {title: 'Click for Google', start: new Date(y, m, 28), end: new Date(y, m, 29), url: 'http://google.com/'}
            ]
        }

        @eventSources = [@events1, @events2]

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

            #viewRender: (view, element)->
               #console.error("View Changed: ", view.visStart, view.visEnd, view.start, view.end)

            dayClick: @dayOnClick
            #eventDrop
            #eventResize
          }
        }

    dayOnClick: ()->
        alert('clicked')

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
            self.performances = _.groupBy performances, (item)-> item.assessYear

    loadRewards: ()->
        @rewards = @UserReward.$collection().$fetch()

    loadPunishments: ()->
        @punishments = @UserPunishment.$collection().$fetch()

    allege: (performance, request)->
        performance.allege(request)


class MyRequestCtrl extends nb.Controller
    @.$inject = ['$scope', 'Employee', 'OrgStore', 'USER_META', 'VACATIONS', 'MyLeave', '$injector', 'UserAnnuity', '$http', 'toaster']

    constructor: (@scope, @Employee, @OrgStore, meta, vacations, @MyLeave, injector, @UserAnnuity, @http, @toaster) ->
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
                <div class="ui-grid-cell-contents" ng-init="realFlow = grid.appScope.$parent.realFlow(row.entity)">
                    <a flow-handler="realFlow" flow-view="true">
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
        @Employee.leaders()

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

class CompanyLeaderChartsController extends nb.Controller
    @.$inject = ['$scope']

    constructor: (@scope) ->
        @areaConfig = {
            theme:'red'
            dataLoaded:true
        }

        @areaOption = {
            title : {
                text: '绩效系数变动'
            },
            tooltip : {
                trigger: 'axis'
            },
            legend: {
                data:['A','B','C']
            },
            calculable : true,
            xAxis : [
                {
                    type : 'category',
                    boundaryGap : false,
                    data : ['一月','二月','三月','四月','五月','六月','七月']
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
                    type:'line',
                    smooth:true,
                    itemStyle: {normal: {areaStyle: {type: 'default'}}},
                    data:[10, 12, 21, 54, 260, 830, 710]
                },
                {
                    name:'B',
                    type:'line',
                    smooth:true,
                    itemStyle: {normal: {areaStyle: {type: 'default'}}},
                    data:[30, 182, 434, 791, 390, 30, 10]
                },
                {
                    name:'C',
                    type:'line',
                    smooth:true,
                    itemStyle: {normal: {areaStyle: {type: 'default'}}},
                    data:[1320, 1132, 601, 234, 120, 90, 20]
                }
            ]
        }


        @barConfig = {
            theme:'red'
            dataLoaded:true
        }

        @barOption = {
            title : {
                text: '各部门人力成本分布'
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
    @.$inject = ['$scope']

    constructor: (@scope) ->
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

class HrLeaderChartsController extends nb.Controller
    @.$inject = ['$scope']

    constructor: (@scope) ->
        @barConfig = {
            theme:'red'
            dataLoaded:true
        }

        @barOption = {
            title : {
                text: '部门分布情况'
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

app.controller 'ChartsMainCtrl', ChartsMainController
app.controller 'CompanyLeaderChartsCtrl', CompanyLeaderChartsController
app.controller 'DepartmentHrChartsCtrl', DepartmentHrChartsController
app.controller 'DepartmentLeaderChartsCtrl', DepartmentLeaderChartsController
app.controller 'HrLeaderChartsCtrl', HrLeaderChartsController


app.config(Route)