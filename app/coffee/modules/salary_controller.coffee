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


class SalaryController extends nb.Controller
    @.$inject = ['$http', '$scope', '$nbEvent', 'toaster']

    constructor: (@http, $scope, $Evt, @toaster) ->
        @initialize()

    $default_coefficient: ()->
        company: 0.1
        business_council: 0.1
        logistics: 0.1

    $check_coefficient_default: ()->
        month = @currentCalcTime()
        if !angular.isDefined(@global_setting.coefficient[month])
            @global_setting.coefficient[month] = @$default_coefficient()

    initialize: () ->
        @year_list = @$getYears()
        @month_list = @$getMonths()

        @currentYear = _.last @year_list
        @currentMonth = _.last @month_list

        # 薪酬全局设置
        @global_setting = {}

        self = @
        @http.get('/api/salaries').success (data)->
            # 全局设置单独处理
            self.global_setting = data.global.form_data
            self.$check_coefficient_default()

            CATEGORY_LIST = ["leader_base",       # 干部
                             "manager15_base",    # 管理15
                             "manager12_base",    # 管理12
                             "flyer_base",        # 飞行员
                             "air_steward",       # 空乘空保
                             "service_b",         # 服务B
                             "air_observer",      # 空中观察员
                             "front_run",         # 前场运行
                            ]
            angular.forEach CATEGORY_LIST, (item)->
                data[item] ||= {}
                self[item + '_setting'] = data[item].form_data || {}

    currentCalcTime: ()->
        @currentYear + "-" + @currentMonth

    load_global_coefficient: ()->
        @$check_coefficient_default()

    save_config: (category, config)->
        self = @
        @http.put('/api/salaries/' + category, {form_data: config}).success (data)->
            error_msg = data.messages

            if error_msg
                self.toaster.pop('error', '提示', error_msg)
            else
                self.toaster.pop('success', '提示', '配置已更新')


class SalaryPersonalController
    @.$inject = ['$http', '$scope', '$nbEvent']

    constructor: ($http, $scope, $Evt) ->


class SalaryBasicController
    @.$inject = ['$http', '$scope', '$nbEvent']

    constructor: ($http, $scope, $Evt) ->


class SalaryPerformanceController
    @.$inject = ['$http', '$scope', '$nbEvent']

    constructor: ($http, $scope, $Evt) ->



app.controller 'salaryCtrl', SalaryController
app.controller 'salaryPersonalCtrl', SalaryPersonalController
app.controller 'salaryBasicCtrl', SalaryBasicController
app.controller 'salaryPerformanceCtrl', SalaryPerformanceController