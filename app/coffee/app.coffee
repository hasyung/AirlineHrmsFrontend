
# require './config/templateCache.coffee'
# require './filters/filters.coffee'
# require './directives/directives.coffee'
# require './services/services.coffee'
# #推送服务
# # require './services/socketio.coffee'
# #登陆
# require './services/devise.js'
# require './controller/index.coffee'


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

# angular.module('vx.controllers',['vx.controllers.knowledge','vx.controllers.login'])


deps = [
    'ui.router'
    'ui.select'
    'ui.bootstrap'
    'mgcrea.ngStrap'
    'ngSanitize'
    'ngMessages'
    'restmod'    #rest api
    'satellizer' #登陆验证
    'vx.services'
    'vx.controllers'
    'vx.filters'
    'vx.templates'
    'vx.directives'
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

        # $rootScope.$on '$stateChangeStart',() ->
        #     console.log "from state : #{arguments[3].name } to state : #{JSON.stringify arguments[1].name}"

        $rootScope.$on 'devise:unauthorized',() ->
            $state.go('auth.login')




    ]
