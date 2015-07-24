nb = @.nb
app = nb.app

class Base

class Service extends Base

class Controller extends Base

    constructor: () ->
        # @initialize()

    # 在grid register api 时， 将 gridApi 共享到controller中
    exportGridApi: (gridApi) ->
        @gridApi = gridApi

    onInitialDataError: (xhr) ->
        if xhr
            if xhr.status == 404
                @location.path(@navUrls.resolve("not-found"))
                @location.replace()
            else if xhr.status == 403
                @location.path(@navUrls.resolve("permission-denied"))
                @location.replace()

        return @q.reject(xhr)

class FilterController extends Controller

    onConditionInValid: ($Evt, invalid) ->
        $Evt.$send('search:condition:error', {message: invalid.join(",")})


nb.Base = Base
nb.Service = Service
nb.Controller = Controller
nb.FilterController = FilterController


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

        scope.cancel = (resource, evt, form, attach_models = []) ->
            evt.preventDefault() if evt
            resource.$restore() if resource && resource.$restore
            angular.forEach attach_models, (model) ->
                model.$restore() if model && model.$restore
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
    @.$inject = ['$scope', '$http', 'USER_META']

    constructor: (scope, $http, meta) ->
        ctrl = @

        Moment = moment().constructor

        scope.initialFlow = (type) ->
            ctrl.flow_type = type

            return {}

        scope.createFlow = (data, receptor, list) ->
            data.vacation_days = scope.vacation_days
            data.receptor_id = if receptor then receptor.id else meta.id

            #临时处理， moment() 默认的tostring 不符合前后端约定
            #暂时没有找到好的方法
            for own key, value of data
                if value instanceof Moment
                    data[key] = value.format()

            $http.post("/api/workflows/#{ctrl.flow_type}", data).success () ->
                scope.panel.close() if scope.panel
                list.$refresh()
                if scope.panel
                    scope.panel.close()
                    if scope.panel.$$collection #WORKAROUND 临时代码， 因为流程与列表数据展现不一致
                        scope.panel.$$collection.$refresh()


class NewMyRequestCtrl extends NewFlowCtrl

    @.$inject = ['$scope', '$http', '$timeout', 'USER_META', '$nbEvent']

    constructor: (scope, $http, $timeout, meta, @Evt) ->
        super(scope, $http, meta) # 手动注入父类实例化参数
        self = @

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
            if data.start_time && data.end_time
                start = moment(data.start_time)
                end = moment(data.end_time)

                request_data = {
                    vacation_type: vacation_type
                    start_time: start.format()
                    end_time: end.format()
                }

                if start > end
                    self.Evt.$send("leave:calc_days:error", "开始时间不能大于结束时间")
                    return

                enableCalculating()

                $http.get('/api/vacations/calc_days', {params: request_data}).success (data, status)->
                    $timeout disableCalculating, 2000
                    scope.vacation_days = data.vacation_days


app.controller('EditableResource', EditableResourceCtrl)
app.controller('NewResource', NewResourceCtrl)
app.controller('NewFlowCtrl', NewFlowCtrl)
app.controller('NewMyRequestCtrl', NewMyRequestCtrl)
