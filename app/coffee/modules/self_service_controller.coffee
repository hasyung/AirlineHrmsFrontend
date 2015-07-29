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
            .state 'self.performance', {
                url: '/performance'
                controller: ProfileCtrl
                controllerAs: 'ctrl'
                templateUrl: 'partials/self/performance/performance.html'
            }
            .state 'self.resume', {
                url: '/resume'
                controller: ProfileCtrl
                controllerAs: 'ctrl'
                templateUrl: 'partials/self/self_resume.html'
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
    @.$inject = ['$scope', 'sweet', 'Employee', '$rootScope', 'User', 'USER_META', 'UserPerformance', 'Performance', '$filter']

    constructor: (@scope, @sweet, @Employee, @rootScope, @User, @USER_META, @UserPerformance, @Performance, @filter) ->
        @loadInitialData()
        @status = 'show'

    loadInitialData: ->
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

    allege: (performance, request)->
        performance.allege(request)


class MyRequestCtrl extends nb.Controller
    @.$inject = ['$scope', 'Employee', 'OrgStore', 'USER_META', 'VACATIONS', 'MyLeave', '$injector']

    constructor: (@scope, @Employee, @OrgStore, meta, vacations, @MyLeave, injector) ->
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


app.config(Route)