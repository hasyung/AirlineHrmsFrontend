

@nb = nb = {}



deps = [
    # 'ui.router'
    'ct.ui.router.extras'
    'ncy-angular-breadcrumb'
    'mgo-angular-wizard'
    'mgcrea.ngStrap.datepicker'
    'ui.select'
    'ngAnimate'
    'ui.bootstrap'
    'ngSanitize'
    'ngMessages'
    'toaster'
    'restmod'    #rest api
    'angular.filter'
    'resources'
    'nb.directives'
    'toaster'
    'ngCookies'
    'nb.filters'
    #'nb.controller.site'
]
resources = angular.module('resources',[])

nb.app = App = angular.module 'nb',deps
# nb.models = models = angular.module 'models', []


appConf = ($provide) ->
    # 事件广播 始终锁定在 rootscope 上 ， 提高性能
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



restConf = (restmodProvider) ->
    restmodProvider.rebase 'AMSApi',
        $config:
            urlPrefix: 'api'
        # $hooks: {
        #     'before-request': (_req)->
        #         _req.url += '.json'
        # }


routeConf = ($stateProvider,$urlRouterProvider,$locationProvider, $httpProvider, $breadcrumbProvider) ->
    $locationProvider.html5Mode(false)

    $breadcrumbProvider.setOptions {
        prefixStateName: 'home'
        template: 'bootstrap3'
    }

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
        # .state 'personnel', {
        #     url: '/personnel'
        #     templateUrl: 'partials/personnel/info.html'
        # }
        .state 'login', {
            url: '/login'
            templateUrl: 'partials/auth/login.html'
        }
        .state 'sigup', {
            url: '/sigup'
            templateUrl: 'partials/auth/sigup.html'
        }

    $httpProvider.interceptors.push ['$q', '$location', 'toaster', 'sweet', ($q, $location, toaster, sweet) ->

        return {
            'responseError': (response) ->
                if response.status == 401
                    $location.path('/login')
                if response.status == 403
                    sweet.error('操作失败',response.data.message || JSON.stringify(response.data))

                if /^5/.test(Number(response.status).toString()) # if server error
                    toaster.pop('error', '服务器错误', response.data.message || JSON.stringify(response.data))
                return $q.reject(response)
        }


    ]


App
    .config ['$provide', appConf]
    .config ['restmodProvider', restConf]
    .config ['$stateProvider','$urlRouterProvider','$locationProvider', '$httpProvider', '$breadcrumbProvider', routeConf]
    .run ['$state','$rootScope', 'toaster', '$http', 'Org', 'sweet', ($state, $rootScope, toaster, $http, Org, sweet) ->
        # for $state.includes in view
        $rootScope.$on '$stateChangeSuccess', (evt, to) ->
            console.debug "stateChangeSuccess: to ", to
            # $uiViewScroll()

        $rootScope.$on 'process', () ->
            $rootScope.loading = true

        $rootScope.$on 'success', (code, info)->
            toaster.pop(code.name, "提示", info)
            $rootScope.loading = false

        $rootScope.$on 'error', (code, info)->
            $rootScope.loading = false
            toaster.pop(code.name, "提示", info)

        $rootScope.$state = $state

        $rootScope.allOrgs = Org.$search()

    ]


