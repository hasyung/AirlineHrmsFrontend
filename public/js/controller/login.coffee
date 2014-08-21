

lg = angular.module 'vx.controllers.login',['Devise']

lg.config ['$stateProvider','AuthProvider',($stateProvider,AuthProvider) ->

    AuthProvider.loginPath('/web_api/v1/sessions.json')


    $stateProvider
        .state 'auth.login', {
            url: '/login'
            template: require('../login.jade')()
        }
        .state 'auth.register' , {
            url: '/register'
            template: '<h1>none!!</h1>'
        }

]

lg.controller 'LoginCtrl',['Auth','$scope','$rootScope','$state','$location',(Auth,$scope,$rootScope,$state,$location) ->
    console.log(Auth.isAuthenticated()) # => false

    # /web_api/v1/
    $scope.login = (creds) ->
        Auth.login(creds)
            .then (user) ->
                store.set('user',user)
                $rootScope.current_user = user
                $location.url("/")

    $scope.$on "devise:unauthorized", (evt,xhr,deferred) ->

        $scope.loginerror = xhr.data

    return

]