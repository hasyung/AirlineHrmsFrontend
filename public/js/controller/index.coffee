

require './login.coffee'
require './knowledge.coffee'

angular.module('vx.controllers',['vx.controllers.knowledge','vx.controllers.login'])
    .controller 'HeaderCtrl', ['$scope','$interval','toaster',($scope,$interval,toaster) ->

        $scope.notifications = [
            '1你妈妈喊你回家吃饭！！'
            '2你妈妈喊你回家吃饭！！'
        ]



        $scope.$on 'newNotifacation', (data) ->
            $scope.notifications.push data.data+Math.floor(Math.random()*100)
            toaster.pop('success','待办事项','回家吃饭！')





    ]
