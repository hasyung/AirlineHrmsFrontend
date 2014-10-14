

restConf = (restmodProvider) ->
    restmodProvider.rebase
        PACKER: 'default'
        URL_PREFIX: '/web_api/v1'


routeConf = ($stateProvider,$urlRouterProvider,$locationProvider) ->
    $locationProvider.html5Mode(false)

    #default route
    $urlRouterProvider.otherwise('/')
    $stateProvider
        .state 'home', {template: 'home.html'}


deps = [
    'ui.router'
    'ui.select'
    'ui.bootstrap'
    'ngSanitize'
    'ngMessages'
    'restmod'    #rest api
    'satellizer' #登陆验证
    'toaster' # 后台通知组件 Angular-toaster
]

App = angular.module 'vxApp',deps

App
    .config ['restmodProvider',restConf]
    .config ['$stateProvider','$urlRouterProvider','$locationProvider',routeConf]
    .run ['$state','$rootScope', ($state,$rootScope) ->
        # for $state.includes in view
        $rootScope.$state = $state

        console.log "state : #{JSON.stringify $state.current}"

    ]
