

@nb = nb = {}



deps = [
    'ui.router'
    'ui.select'
    # 'ui.bootstrap'
    'ngSanitize'
    'ngMessages'
    'toaster'
    'restmod'    #rest api
    'angular.filter'
    'resources'
    'nb.directives'
    'toaster'
    #'nb.controller.site'
]
resources = angular.module('resources',[])

nb.app = App = angular.module 'nb',deps
# nb.models = models = angular.module 'models', []




restConf = (restmodProvider) ->
    restmodProvider.rebase 'AMSApi',
        $config:
            urlPrefix: 'api'
        # $hooks: {
        #     'before-request': (_req)->
        #         _req.url += '.json'
        # }




routeConf = ($stateProvider,$urlRouterProvider,$locationProvider) ->
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



App
    .config ['restmodProvider', restConf]
    .config ['$stateProvider','$urlRouterProvider','$locationProvider',routeConf]
    .run ['$state','$rootScope', ($state, $rootScope) ->
        # for $state.includes in view
        $rootScope.$on '$stateChangeSuccess', (evt, to) ->
            console.debug "stateChangeSuccess: to ", to


    ]


