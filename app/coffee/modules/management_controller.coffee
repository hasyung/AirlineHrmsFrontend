
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
                resolve: {
                }
            }
            .state 'self.profile.basic', {
                url: ''
                views: {
                    "detail@self.profile": {
                        controller: PerInfoCtrl
                        controllerAs: 'ctrl'
                        templateUrl: 'partials/self/self_info_basic/self_info_basic.html'
                    }
                }
                ncyBreadcrumb: {
                    label: "我的基本信息"
                }

                resolve: {
                }
            }
            .state 'self.profile.members', {
                url: '/members'
                views: {
                    "detail@self.profile": {
                        controller: PerInfoCtrl
                        controllerAs: 'ctrl'
                        templateUrl: 'partials/self/members.html'
                    }
                }
                ncyBreadcrumb: {
                    label: "家庭成员"
                }

                resolve: {
                }
            }
            .state 'self.profile.education', {
                url: '/education'
                views: {
                    "detail@self.profile": {
                        controller: PerInfoCtrl
                        controllerAs: 'ctrl'
                        templateUrl: 'partials/self/education.html'
                    }
                }
                ncyBreadcrumb: {
                    label: "教育经历"
                }

                resolve: {
                }
            }
            .state 'self.profile.experience', {
                url: '/experience'
                views: {
                    "detail@self.profile": {
                        controller: PerInfoCtrl
                        controllerAs: 'ctrl'
                        templateUrl: 'partials/self/experience.html'
                    }
                }
                ncyBreadcrumb: {
                    label: "工作经历"
                }

                resolve: {
                }
            }

class SelfCtrl extends nb.Controller

    @.$inject = ['$scope', 'sweet', 'Employee', '$rootScope']


    constructor: (@scope, @sweet, @Employee, @rootScope) ->
        @scope.currentUser = @rootScope.currentUser
        @loadInitailData()

    loadInitailData: ->




class PerInfoCtrl extends nb.Controller

    @.$inject = ['$scope', 'sweet', 'Employee', '$rootScope']


    constructor: (@scope, @sweet, @Employee, @rootScope) ->
        @loadInitailData()
        @status = 'show'

    loadInitailData: ->
        console.log @rootScope.currentUser
        @scope.currentUser = @rootScope.currentUser






app.config(Route)
