@nb = nb = {}

# 用户元数据
metadata = @metadata

# 组织机构数据
dep_info = @dep_info

deps = [
    'ui.router'
    'mgo-angular-wizard'
    'ngDialog'
    'ui.grid'
    'ui.grid.selection'
    'ui.grid.pinning'
    'ui.grid.pagination'
    'ui.grid.autoResize'
    'ui.grid.edit'
    'ui.grid.rowEdit'
    'ui.grid.cellNav'
    'ui.grid.pinning'
    'ngAnimate'
    'ngAria'
    'ngSanitize'
    'ngMessages'
    'ngMaterial'
    'toaster'
    'restmod'
    'angular.filter'
    'resources'
    'nb.directives'
    'ngCookies'
    'nb.filters'
    'nb.component'
    'flow'
    'infinite-scroll'
]


resources = angular.module('resources', [])
nb.app = App = angular.module 'nb', deps


# 日期解析和格式化
moment.locale('zh-cn')


#初始化在<head> <script> 标签中, 如果不存在， 系统行为待定
App.constant 'PERMISSIONS', metadata.permissions || []
App.value 'USER_META', metadata.user || {}
App.constant 'VACATIONS', metadata.vacation_summary || {}
App.constant 'DEPARTMENTS', dep_info.departments || []
App.constant 'nbConstants', metadata.resources || []
App.constant 'PUSH_SERVER_CONFIG', metadata.push_server || {host: "192.168.6.99", port: 9927}
App.constant 'USER_MESSAGE', metadata.messages || {}


appConf = ($provide, ngDialogProvider) ->
    # 事件广播始终锁定在 rootScope 上， 提高性能
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

    $provide.value('THROTTLE_MILLISECONDS', 1000) #infinit scroll throttle milliseconds


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
        .primaryPalette 'blue', {
            'default': '500'
        }
        .accentPalette 'grey'
        .warnPalette 'red', {
            'default' : '400'
        }
        .backgroundPalette 'grey', {
            'default': '100'
            'hue-1': 'A100'
        }


routeConf = ($stateProvider, $urlRouterProvider, $locationProvider, $httpProvider) ->
    $locationProvider.html5Mode(false)
    $urlRouterProvider.otherwise('/orgs')

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
                    sweet.error('操作失败', response.data.messages || JSON.stringify(response.data))

                if response.status == 400
                    toaster.pop('error', '参数错误', response.data.messages || JSON.stringify(response.data) || response)

                if /^5/.test(Number(response.status).toString()) # if server error
                    toaster.pop('error', '服务器错误', response.data.messages || JSON.stringify(response.data || response))

                return $q.reject(response)
        }
    ]

    $httpProvider.defaults.paramSerializer = '$httpParamSerializerJQLike'


secConf = ($sceDelegateProvider) ->
    $sceDelegateProvider.resourceUrlWhitelist(['self'])


App
    .config ['$provide', 'ngDialogProvider', appConf]
    .config ['restmodProvider', restConf]
    .config ['$mdThemingProvider', mdThemingConf]
    .config ['$stateProvider','$urlRouterProvider','$locationProvider', '$httpProvider', routeConf]
    .config ['$sceDelegateProvider', secConf]
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
        OrgStore.initialize() # 初始化OrgStore

        cancelLoading = ->
            $timeout(
                ()-> $rootScope.loading = false
                100
            )

        startLoading = ->
            $rootScope.loading = true

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
    ]