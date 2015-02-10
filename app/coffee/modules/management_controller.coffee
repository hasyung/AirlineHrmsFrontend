
nb = @.nb
app = nb.app
extend = angular.extend
resetForm = nb.resetForm
Modal = nb.Modal



class Route
    @.$inject = ['$stateProvider', '$urlRouterProvider']

    constructor: (stateProvider, urlRouterProvider) ->

        urlRouterProvider.when('/self-service', '/self-service/profile')

        stateProvider
            .state 'self', {
                url: '/self-service'
                template: '<div ui-view="profile"></div>'
                ncyBreadcrumb: {
                    label: "员工自助"
                }
            }
            .state 'self.profile', {
                url: '/profile'
                views: {
                    "profile@self": {
                        controller: SelfCtrl
                        controllerAs: 'ctrl'
                        templateUrl: 'partials/self/self_info.html'
                    }
                }
                ncyBreadcrumb: {
                    label: "个人信息"
                }
            }
            .state 'self.profile.basic', {
                url: ''
                views: {
                    "detail@self.profile": {
                        controller: ProfileCtrl
                        controllerAs: 'ctrl'
                        templateUrl: 'partials/self/self_info_basic/self_info_basic.html'
                    }
                }
                ncyBreadcrumb: {
                    label: "我的基本信息"
                }

            }
            .state 'self.profile.members', {
                url: '/members'
                views: {
                    "detail@self.profile": {
                        controller: ProfileCtrl
                        controllerAs: 'ctrl'
                        templateUrl: 'partials/self/self_info_family/self_info_members.html'
                    }
                }
                ncyBreadcrumb: {
                    label: "家庭成员"
                }

            }
            .state 'self.profile.education', {
                url: '/education'
                views: {
                    "detail@self.profile": {
                        controller: ProfileCtrl
                        controllerAs: 'ctrl'
                        templateUrl: 'partials/self/education.html'
                    }
                }
                ncyBreadcrumb: {
                    label: "教育经历"
                }

            }
            .state 'self.profile.experience', {
                url: '/experience'
                views: {
                    "detail@self.profile": {
                        controller: ProfileCtrl
                        controllerAs: 'ctrl'
                        templateUrl: 'partials/self/experience.html'
                    }
                }
                ncyBreadcrumb: {
                    label: "工作经历"
                }

            }

class SelfCtrl extends nb.Controller

    @.$inject = ['$scope', 'sweet', 'Employee', '$rootScope']


    constructor: (@scope, @sweet, @Employee, @rootScope) ->
        @scope.currentUser = @rootScope.currentUser
        @loadInitailData()

    loadInitailData: ->




class ProfileCtrl extends nb.Controller

    @.$inject = ['$scope', 'sweet', 'Employee', '$rootScope']


    constructor: (@scope, @sweet, @Employee, @rootScope) ->
        @loadInitailData()
        @status = 'show'

    loadInitailData: ->
        @scope.currentUser = @rootScope.currentUser

    # 员工自助中员工编辑自己的信息
    updateInfo: ->
        @scope.currentUser.$update()






app.config(Route)
