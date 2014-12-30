

@nb = nb = {}



deps = [
    # 'ui.router'
    'ct.ui.router.extras'
    # 'ui.select'
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
                this.$on('$destory', unsubscribe)

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




routeConf = ($stateProvider,$urlRouterProvider,$locationProvider, $httpProvider) ->
    $locationProvider.html5Mode(false)

    #default route
    $urlRouterProvider.otherwise('/')
    $stateProvider
        .state 'home', {
            url: '/'
            templateUrl: 'partials/home.html'
        }
        .state 'personnel', {
            url: '/personnel'
            templateUrl: 'partials/personnel/info.html'
        }
        .state 'login', {
            url: '/login'
            templateUrl: 'partials/auth/login.html'
        }
        .state 'sigup', {
            url: '/sigup'
            templateUrl: 'partials/auth/sigup.html'
        }

    $httpProvider.interceptors.push ['$q', '$location', 'toaster', ($q, $location, toaster) ->

        return {
            'responseError': (response) ->
                if response.status == 401
                    $location.path('/login')
                toaster.pop('error', '服务器错误', JSON.stringify(response.data))
                return $q.reject(response)
        }


    ]


App
    .config ['$provide', appConf]
    .config ['restmodProvider', restConf]
    .config ['$stateProvider','$urlRouterProvider','$locationProvider', '$httpProvider',routeConf]
    .run ['$state','$rootScope', 'toaster', '$http', ($state, $rootScope, toaster, $http) ->
        # for $state.includes in view
        $rootScope.$on '$stateChangeSuccess', (evt, to) ->
            console.debug "stateChangeSuccess: to ", to

        $rootScope.$on 'success', (code, info)->
            toaster.pop(code.name, "提示", info)
        $rootScope.$on 'error', (code, info)->
            console.log arguments
            toaster.pop(code.name, "提示", info)

        $rootScope.$state = $state

    ]


