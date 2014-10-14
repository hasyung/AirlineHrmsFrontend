module.exports = ['$stateProvider','$urlRouterProvider','$locationProvider',
($stateProvider,$urlRouterProvider,$locationProvider) ->

    $locationProvider.html5Mode(false)

    # checkAuth = ['$q','$rootScope','$location','$timeout','$state',($q,$rootScope,$location,$timeout,$state) ->
    #     deferred = $q.defer()
    #     unless $rootScope.user
    #         if user = store.get('user')
    #             $rootScope.user = user
    #             $location.url('/knowledge')
    #             deferred.resolve()
    #         else
    #             $location.url('/login')
    #             $timeout () ->
    #                 deferred.reject()
    #     else
    #         $location.url('')
    #         deferred.resolve()
    #     deferred.promise
    # ]

    #default route
    $urlRouterProvider.otherwise('/knowledge')


    $stateProvider
        .state 'home', {
            url: ''
            template: require('../home.jade')()
        }
        # .state 'login', {
        #     url: '/login'
        #     # auth page layout
        # }
        # .state 'knowledge', {
        #     parent: 'home'
        #     url: '/knowledge'
        #     abstract: true
        #     views: {
        #         "": {
        #             template: require('../knowledge/index.jade')()
        #         }
        #     }
        # }

]