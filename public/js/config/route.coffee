module.exports = ['$stateProvider','$urlRouterProvider','$locationProvider',
($stateProvider,$urlRouterProvider,$locationProvider) ->

    $locationProvider.html5Mode(false)

    checkAuth = ['$q','$rootScope','$location','$timeout','$state',($q,$rootScope,$location,$timeout,$state) ->
        deferred = $q.defer()
        unless $rootScope.user
            if user = store.get('user')
                $rootScope.user = user
                $location.url('/knowledge')
                deferred.resolve()
            else
                $location.url('/login')
                $timeout () ->
                    deferred.reject()
        else
            $location.url('')
            deferred.resolve()
        deferred.promise
    ]

    #default route
    $urlRouterProvider.otherwise('/knowledge')
    # $urlRouterProvider.when('/', '/knowledge')


    $stateProvider
        .state 'home', {
            abstract: true
            url: ''
            template: require('../home.jade')()
            resolve: {
                # before route home page
                checkAuth: checkAuth
            }
        }
        .state 'auth', {
            abstract: true
            # auth page layout
            template: require('../auth.jade')()
        }
        .state 'knowledge', {
            parent: 'home'
            url: '/knowledge'
            abstract: true
            views: {
                "": {
                    template: require('../knowledge/index.jade')()
                }
            }
            # resolve: {
            #     checkAuth: checkAuth
            # }
        }

]