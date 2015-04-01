

@nb = nb = {}



deps = [
    # 'ui.router'
    'ct.ui.router.extras'
    # 'ncy-angular-breadcrumb'
    'mgo-angular-wizard'
    'mgcrea.ngStrap.datepicker'
    'ngDialog'
    'ui.select'
    'ngAnimate'
    'ngAria'
    'ui.bootstrap'
    'ngSanitize'
    'ngMessages'
    'ngMaterial'
    'toaster'
    'restmod'    #rest api
    'angular.filter'
    'resources'
    'nb.directives'
    'toaster'
    'ngCookies'
    'nb.filters'
    'nb.component'
    #'nb.controller.site'
]
resources = angular.module('resources',[])

nb.app = App = angular.module 'nb',deps
# nb.models = models = angular.module 'models', []


appConf = ($provide, ngDialogProvider) ->
    # 事件广播 始终锁定在 rootScope 上 ， 提高性能
    $provide.decorator '$rootScope', ['$delegate', ($delegate) ->

        Object.defineProperty $delegate.constructor.prototype, '$onRootScope', {
            value: (name, listener) ->
                unsubscribe = $delegate.$on(name, listener)
                this.$on('$destroy', unsubscribe)
                return unsubscribe
            enumerable: false
        }

        return $delegate
    ]

    ngDialogProvider.setDefaults {
        className: 'ngdialog-theme-flat'
        plain: false
        showClose: false
        appendTo: false
    }



restConf = (restmodProvider) ->
    restmodProvider.rebase 'AMSApi',
        $config:
            urlPrefix: 'api'

mdThemingConf = ($mdThemingProvider) ->
    $mdThemingProvider.theme('default')
        .primaryPalette('indigo')
        .accentPalette('amber')
        .warnPalette('deep-orange')


routeConf = ($stateProvider,$urlRouterProvider,$locationProvider, $httpProvider) ->
    $locationProvider.html5Mode(false)

    # $stateProvider.decorator 'views', (state, parent) ->
    #     result = {}
    #     views = parent(state)

    #     angular.forEach views, (config, name) ->
    #         autoName = "#{state.name}.#{name}".replace('.','/')
    #         config.templateUrl = config.templateUrl || "/partials/#{autoName}.html"
    #         result[name] = config

    #     return result


    # $breadcrumbProvider.setOptions {
    #     prefixStateName: 'home'
    #     template: 'bootstrap3'
    # }

    #default route
    $urlRouterProvider.otherwise('/')
    $stateProvider
        .state 'home', {
            url: '/'
            templateUrl: 'partials/home.html'
            ncyBreadcrumb: {
                skip: true
            }
        }
        .state 'login', {
            url: '/login'
            templateUrl: 'partials/auth/login.html'
        }
        .state 'sigup', {
            url: '/sigup'
            templateUrl: 'partials/auth/sigup.html'
        }
        .state 'changePwd', {
            url: '/change-possword'
            templateUrl: 'partials/auth/change_pwd.html'
        }

    $httpProvider.interceptors.push ['$q', '$location', 'toaster', 'sweet', ($q, $location, toaster, sweet) ->

        return {
            'responseError': (response) ->
                if response.status == 401
                    $location.path('/login')
                if response.status == 403
                    sweet.error('操作失败',response.data.message || JSON.stringify(response.data))
                if response.status == 400
                    toaster.pop('error', '参数错误', response.data.message || JSON.stringify(response.data) || response)

                if /^5/.test(Number(response.status).toString()) # if server error
                    toaster.pop('error', '服务器错误', response.data.message || JSON.stringify(response.data) || response)
                return $q.reject(response)
        }

    ]

datepickerConf = ($datepickerProvider)->
    angular.extend($datepickerProvider.defaults, {
        dateFormat: 'yyyy-MM-dd'
        modelDateFormat: 'yyyy-MM-dd'
        dateType: 'string'
    })


App
    .config ['$provide', 'ngDialogProvider', appConf]
    .config ['$datepickerProvider', datepickerConf]
    .config ['restmodProvider', restConf]
    .config ['$mdThemingProvider', mdThemingConf]
    .config ['$stateProvider','$urlRouterProvider','$locationProvider', '$httpProvider', routeConf]
    .run ['$state','$rootScope', 'toaster', '$http', 'Org', 'sweet', 'User', '$enum', '$timeout', '$cookies',
    ($state, $rootScope, toaster, $http, Org, sweet, User, $enum, $timeout, $cookies) ->

        cancelLoading = ->
            $rootScope.loading = false
        startLoading = ->
            $rootScope.loading = true

        # for $state.includes in view

        $rootScope.$on '$stateChangeStart', ->
            startLoading()
            $timeout cancelLoading, 1000


        $rootScope.$on 'process', startLoading

        $rootScope.$on 'success', (code, info)->
            toaster.pop(code.name, "提示", info)
            cancelLoading()

        $rootScope.$on 'error', (code, info)->
            $rootScope.loading = false
            toaster.pop(code.name, "提示", info)

        $rootScope.currentUser = User.$fetch()

        $rootScope.$state = $state

        $rootScope.allOrgs = Org.$search()

        $rootScope.logout = ()->
            $http.delete('/api/sign_out').success ()->
                $rootScope.currentUser = null


        $rootScope.enums = $enum.get()
        $rootScope.loadEnum = $enum.loadEnum()

    ]


