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
    'ng-echarts'
    'ui.calendar'
]


resources = angular.module('resources', [])
nb.app = App = angular.module 'nb', deps


# 日期解析和格式化
moment.locale('zh-cn')


#初始化在<head> <script> 标签中, 如果不存在， 系统行为待定
App.constant 'PERMISSIONS', metadata.permissions || []
App.value 'USER_META', metadata.user || {}
App.value 'REPORT_CHECKER', metadata.report_checker || {}
App.constant 'VACATIONS', metadata.vacation_summary || {}
App.constant 'DEPARTMENTS', dep_info.departments || []
App.constant 'nbConstants', metadata.resources || []
App.constant 'ROUTE_INFO', metadata.route_info || {}

# 服务器必须提供推送配置信息
App.constant 'PUSH_SERVER_CONFIG', metadata.push_server

App.constant 'USER_MESSAGE', metadata.messages || {}
App.constant 'CURRENT_ROLES', metadata.roles || {}
App.constant 'ROLES_MENU_CONFIG', metadata.roles_menu_config || {}
App.value 'SALARY_SETTING', metadata.salary_setting || {}

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
    $urlRouterProvider.otherwise(metadata.route_info.default_route || "/dashboard")

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
                    data = response.data

                    if data.controller == "positions" && data.action == "index"
                        return

                    if data.controller == "specifications" && data.action == "show"
                        return

                    if data.controller == "employees" && data.action == "show"
                        return

                    sweet.error('操作失败', response.data.messages || JSON.stringify(response.data))

                if response.status == 400
                    data = response.data
                    toaster.pop('error', data.type || '参数错误', data.messages || JSON.stringify(data) || response)

                if /^5/.test(Number(response.status).toString()) # if server error
                    data = response.data
                    toaster.pop('error', '服务器错误', data.messages || JSON.stringify(data || response))

                return $q.reject(response)
        }
    ]

    $httpProvider.defaults.paramSerializer = '$httpParamSerializerJQLike'


secConf = ($sceDelegateProvider) ->
    $sceDelegateProvider.resourceUrlWhitelist(['self'])

# 检测是否ie浏览器 采取相应措施
ieKiller = () ->
    Sys = {}
    ua = navigator.userAgent.toLowerCase()

    if (s = ua.match(/rv:([\d.]+)\) like gecko/))
        Sys.ie = s[1]
    else if (s = ua.match(/msie ([\d.]+)/))
        Sys.ie = s[1]
    else
        Sys.ie = 0

    return Sys

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
        sys = ieKiller()

        $rootScope.isIE = sys.ie

        $rootScope.menu = menu

        i18nService.setCurrentLang('zh-cn')
        OrgStore.initialize() # 初始化OrgStore

        ################
        ###全局loading###
        ################
        # cancelLoading = ->
        #     $timeout(
        #         ()-> $rootScope.loading = false
        #         100
        #     )

        # startLoading = ->
        #     $rootScope.loading = true

        # $rootScope.$on '$stateChangeStart', (evt, _to , _toParam, _from, _fromParam) ->
        #     startLoading()

        # $rootScope.loading = true

        $rootScope.$on '$stateChangeSuccess', () ->
            # cancelLoading()

            #console.error $state.current.url

            $rootScope.hide_menu = $state.current.url.indexOf('/self/my_requests') >= 0  \
                || $state.current.url.indexOf('/profile') >= 0  \
                || $state.current.url.indexOf('/charts') >= 0  \
                || $state.current.url.indexOf('/members') >= 0  \
                || $state.current.url.indexOf('/education') >= 0  \
                || $state.current.url.indexOf('/experience') >= 0  \
                || $state.current.url.indexOf('/performance') >= 0  \
                || $state.current.url.indexOf('/leave') >= 0  \
                || $state.current.url.indexOf('/resignation') >= 0  \
                || $state.current.url.indexOf('/adjust-position') >= 0  \
                || $state.current.url.indexOf('/early_retirement') >= 0  \
                || $state.current.url.indexOf('/renew_contract') >= 0 \
                || $state.current.url.indexOf('/reward_punishment') >= 0 \
                || $state.current.url.indexOf('/attendance') >= 0 \
                || $state.current.url.indexOf('/annuity') >= 0 \
                || $state.current.url.indexOf('/leader_experience') >= 0

            if $state.current.url.indexOf('/performance_') >= 0 || $state.current.url.indexOf('labors_attendance') >= 0
                $rootScope.hide_menu = false

        # $rootScope.$on 'process', startLoading

        $rootScope.$on 'success', (code, info)->
            toaster.pop(code.name, "提示", info)
            # cancelLoading()

        $rootScope.$on 'error', (code, info)->
            # $rootScope.loading = false
            toaster.pop(code.name, "提示", info)

        $rootScope.$state = $state
        $rootScope.$enum  = $enum

        $rootScope.allOrgs = Org.$search()
    ]