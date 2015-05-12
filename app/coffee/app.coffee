

@nb = nb = {}

metadata = @metadata #用户元数据
dep_info = @dep_info #机构数据



deps = [
    # 'ui.router'
    'ct.ui.router.extras'
    'mgo-angular-wizard'
    'mgcrea.ngStrap.datepicker'
    'ngDialog'
    'ui.select'
    'ui.grid'
    'ui.grid.selection'
    'ui.grid.pinning'
    'ui.grid.pagination'
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
    'flow'
    'ngMaterialDropmenu'
    #'nb.controller.site'
]
resources = angular.module('resources',[])

nb.app = App = angular.module 'nb',deps
# nb.models = models = angular.module 'models', []

#初始化在<head> <script> 标签中, 如果不存在， 系统行为待定
App.constant 'PERMISSIONS', metadata.permissions || []
App.constant 'USER_META', metadata.user || {}
App.constant 'DEPARTMENTS', dep_info.departments || []
App.constant 'nbConstants', metadata.resources || []


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
        .primaryPalette('blue')
        .accentPalette('light-green')
        .warnPalette('red')

    $mdThemingProvider.theme 'hrms'
        .primaryPalette 'grey', {
            'default': 'A100'

        }
        .accentPalette 'grey'
        .warnPalette 'red', {
            'default' : '400'
        }
        .backgroundPalette 'grey', {
            'default': '100'
            'hue-1': 'A100'
        }




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


    #default route
    $urlRouterProvider.otherwise('/')
    $stateProvider
        .state 'home', {
            url: '/'
            templateUrl: 'partials/home.html'
        }

    $httpProvider.interceptors.push ['$q', 'toaster', 'sweet', 'AuthService', ($q, toaster, sweet, AuthServ) ->
        return {
            'responseError': (response) ->
                if response.status == 401
                    AuthServ.logout()
                if response.status == 403
                    sweet.error('操作失败',response.data.message || JSON.stringify(response.data))
                if response.status == 400
                    toaster.pop('error', '参数错误', response.data.message || JSON.stringify(response.data) || response)

                if /^5/.test(Number(response.status).toString()) # if server error
                    toaster.pop('error', '服务器错误', response.data.message || JSON.stringify(response.data || response))

                return $q.reject(response)
        }

    ]
    #FIX! angular 1.4 feature , datepicker not supported 1.4 now. cause ngAnimate has many break changes in 1.4
    # $httpProvider.defaults.paramSerializer = '$httpParamSerializerJQLike'

datepickerConf = ($datepickerProvider)->
    angular.extend($datepickerProvider.defaults, {
        dateFormat: 'yyyy-MM-dd'
        autoclose: true
        container: 'body'
        # dateType: 'string'
    })


App
    .config ['$provide', 'ngDialogProvider', appConf]
    .config ['$datepickerProvider', datepickerConf]
    .config ['restmodProvider', restConf]
    .config ['$mdThemingProvider', mdThemingConf]
    .config ['$stateProvider','$urlRouterProvider','$locationProvider', '$httpProvider', routeConf]
    .run [
        'menu'
        '$state'
        'i18nService'
        '$location'
        '$rootScope'
        'toaster'
        '$http'
        'Org'
        'OrgStore'
        'sweet'
        'User'
        '$enum'
        '$timeout'
        'AuthService'
    (menu, $state, i18nService, $location, $rootScope, toaster, $http, Org, OrgStore, sweet, User, $enum, $timeout, AuthServ) ->

        $rootScope.menu = menu
        i18nService.setCurrentLang('zh-cn')
        OrgStore.initialize() #初始化OrgStore
        cancelLoading = ->
            $timeout(
                ()-> $rootScope.loading = false
                100
            )
        startLoading = ->
            $rootScope.loading = true

        # for $state.includes in view

        $rootScope.$on '$stateChangeStart', (evt, _to , _toParam, _from, _fromParam) ->
            startLoading()

        $rootScope.$on '$stateChangeSuccess', () ->
            cancelLoading()

        $rootScope.$on 'process', startLoading

        $rootScope.$on 'success', (code, info)->
            toaster.pop(code.name, "提示", info)
            cancelLoading()

        $rootScope.$on 'error', (code, info)->
            $rootScope.loading = false
            toaster.pop(code.name, "提示", info)

        $rootScope.$state = $state
        $rootScope.$enum  = $enum

        $rootScope.allOrgs = Org.$search()


        $rootScope.createFlow = (data, flowname) ->
            $http.post("/api/workflows/#{flowname}", data)


    ]


