


##
#
# 基类文件
#
#
#
#
#
#
#

nb = @.nb
app = nb.app

class Base

class Service extends Base

class Controller extends Base

    constructor: () ->
        # @initialize()


    onInitialDataError: (xhr) ->
        if xhr
            if xhr.status == 404
                @location.path(@navUrls.resolve("not-found"))
                @location.replace()
            else if xhr.status == 403
                @location.path(@navUrls.resolve("permission-denied"))
                @location.replace()

        return @q.reject(xhr)

nb.Base = Base
nb.Service= Service
nb.Controller = Controller


class EditableResourceCtrl
    @.$inject = ['$scope', '$enum']
    constructor: (scope, $enum) ->
        scope.editing = false
        scope.$enum = $enum
        scope.edit = (evt) ->
            evt.preventDefault() if evt && evt.preventDefault
            scope.editing = true

        scope.save = (promise, form) ->
            return if form && form.$invalid

            if promise
                if promise.then
                    promise.then () -> scope.editing = false
                else if promise.$then
                    promise.$then () -> scope.editing =false

                else
                    throw new Error('promise 参数错误')

            else scope.editing =false



        scope.cancel = (resource, evt, form) ->
            evt.preventDefault() if evt
            resource.$restore() if resource && resource.$restore
            form.$setPristine() if form && form.$setPristine
            scope.editing = false
class NewResourceCtrl

    @.$inject = ['$scope', '$enum']

    constructor: (scope, $enum) ->
        scope.$enum = $enum

        scope.create = (resource, form) ->
            return if form && form.$invalid
            resource.$save() if resource.$save


class NewFlowCtrl
    @.$inject = ['$scope', '$http']

    constructor: (scope, $http) ->
        ctrl = @

        scope.initialFlow = (type) ->
            ctrl.flow_type = type

            return {}


        scope.createFlow = (data) ->
            data.vacation_days = 5
            data.employee_id = 11821
            $http.post("/api/workflows/#{ctrl.flow_type}", data)


class NewMyRequestCtrl extends NewFlowCtrl

    @.$inject = ['$scope', '$http', '$timeout']

    constructor: (scope, $http, $timeout) ->
        super(scope, $http) # 手动注入父类实例化参数
        ctrl = @

        scope.request = {}
        scope.calculating = false
        scope.start_times = []
        scope.end_times = []

        enableCalculating = ->
            scope.calculating = true
        disableCalculating = ->
            scope.calculating = false

        scope.loadStartTime = () ->
            startOfDay = moment(scope.request.start_time).startOf('day')

            scope.start_times = [
                startOfDay.clone().add(9, 'hours')
                startOfDay.clone().add(13, 'hours')
            ]
        scope.loadEndTime = () ->
            startOfDay = moment(scope.request.end_time).startOf('day')

            scope.end_times = [
                startOfDay.clone().add(13, 'hours')
                startOfDay.clone().add(17, 'hours')
            ]


        # 计算请假天数
        scope.calculateTotalDays = (data, vacation_type) ->
            #validation data
            if moment.isMoment(data.start_time) && moment.isMoment(data.end_time)
                request_data = {
                    vacation_type: vacation_type
                    start_time:  data.start_time.toString()
                    end_time: data.end_time.toString()
                }
                enableCalculating()

                $http.get(
                    '/api/vacations/calc_days'
                    {
                        params: request_data
                    }
                ).success (data) ->
                    $timeout disableCalculating, 2000
                    scope.vacation_days = data.vacation_days





app.controller('EditableResource', EditableResourceCtrl)
app.controller('NewResource', NewResourceCtrl)
app.controller('NewFlowCtrl', NewFlowCtrl)
app.controller('NewMyRequestCtrl', NewMyRequestCtrl)
