# 薪资
nb = @.nb
app = nb.app

class Route
    @.$inject = ['$stateProvider']

    constructor: (stateProvider) ->
        stateProvider
            .state 'salary', {
                url: '/salary'
                templateUrl: 'partials/salary/settings.html'
            }

            .state 'salary_basic', {
                url: '/salary/basic'
                templateUrl: 'partials/salary/basic.html'
            }


app.config(Route)


class SalaryController

    @.$inject = ['$http', '$scope', '$nbEvent', '$sce']

    constructor: ($http, $scope, $Evt, $sce) ->
        $scope.trustSrc = (url) ->
            $sce.trustAsResourceUrl("http://192.168.6.99:9001" + url)


class SalaryBasicController
    @.$inject = ['$http', '$scope', '$nbEvent', '$sce']

    constructor: ($http, $scope, $Evt, $sce) ->


app.controller 'salaryCtrl', SalaryController
app.controller 'salaryBasicCtrl', SalaryBasicController