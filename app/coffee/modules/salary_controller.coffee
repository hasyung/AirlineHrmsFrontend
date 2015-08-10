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

            .state 'salary_personal', {
                url: '/salary/personal'
                templateUrl: 'partials/salary/personal.html'
            }

            .state 'salary_basic', {
                url: '/salary/basic'
                templateUrl: 'partials/salary/basic.html'
            }

            .state 'salary_performance', {
                url: '/salary/salary_performance'
                templateUrl: 'partials/salary/performance.html'
            }


app.config(Route)


class SalaryController

    @.$inject = ['$http', '$scope', '$nbEvent']

    constructor: ($http, $scope, $Evt) ->


class SalaryBasicController
    @.$inject = ['$http', '$scope', '$nbEvent']

    constructor: ($http, $scope, $Evt) ->


class SalaryPerformanceController
    @.$inject = ['$http', '$scope', '$nbEvent']

    constructor: ($http, $scope, $Evt) ->


class SalaryPersonalController
    @.$inject = ['$http', '$scope', '$nbEvent']

    constructor: ($http, $scope, $Evt) ->


app.controller 'salaryCtrl', SalaryController
app.controller 'salaryBasicCtrl', SalaryBasicController
app.controller 'salaryPerformanceCtrl', SalaryPerformanceController
app.controller 'salaryPersonalCtrl', SalaryPersonalController