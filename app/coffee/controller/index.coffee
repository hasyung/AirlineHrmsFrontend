

require './login.coffee'


angular.module('vx.controllers',['vx.controllers.knowledge','vx.controllers.login'])
    .controller 'HeaderCtrl', ['$scope','$interval','toaster',($scope,$interval,toaster) ->

        $scope.notifications = []


    ]
