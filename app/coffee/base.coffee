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

    $getYears: ()->
        [2015..new Date().getFullYear()]

    $getMonths: ()->
        months = [1..new Date().getMonth() + 1]
        months = _.map months, (item) ->
            item = "0" + item if item < 10

    parseJSON: (data) ->
        angular.fromJson(data)


class FilterController extends Controller
    onConditionInValid: ($Evt, invalid) ->
        $Evt.$send('search:condition:error', {message: invalid.join(",")})


class EditableResourceCtrl
    @.$inject = ['$scope', '$enum', '$nbEvent']

    constructor: (scope, $enum, @Evt) ->
        scope.editing = false
        scope.$enum = $enum

        scope.edit = (evt) ->
            evt.preventDefault() if evt && evt.preventDefault
            scope.editing = true

        scope.save = (promise, form) ->
            return if form && form.$invalid
            self = @

            if promise
                if promise.then
                    promise.then (data) ->
                        scope.editing = false
                        self.response_data = data
                else if promise.$then
                    promise.$then (data) ->
                        scope.editing = false
                        self.response_data = data
                else
                    throw new Error('promise 参数错误')

                if self.response_data
                    msg = self.response_data.messages
                    @Evt.$send('model:save:success', msg || "保存成功")
            else
                scope.editing = false

        scope.cancel = (resource, evt, form, attach_models = []) ->
            evt.preventDefault() if evt
            resource.$restore() if resource && resource.$restore

            angular.forEach attach_models, (model) ->
                model.$restore() if model && model.$restore
            form.$setPristine() if form && form.$setPristine

            scope.editing = false


nb.Base = Base
nb.Service = Service
nb.Controller = Controller
nb.FilterController = FilterController
nb.EditableResourceCtrl = EditableResourceCtrl


class NewResourceCtrl
    @.$inject = ['$scope', '$enum', '$nbEvent', 'toaster']

    constructor: (scope, $enum, $Evt, @toaster) ->
        scope.$enum = $enum

        scope.create = (resource, form) ->
            return if form && form.$invalid

            if resource.$save
                resource.$save().$asPromise().then (data)->
                    msg = data.$response.data.messages

                    if data.$response.status == 200
                        $Evt.$send('model:save:success', msg || "创建成功")
                    else
                        $Evt.$send('model:save:error', msg || "创建失败")


class NewFlowCtrl
    @.$inject = ['$scope', '$http', '$state', 'USER_META', 'toaster']

    constructor: (scope, $http, @state, meta, @toaster) ->
        self = @

        Moment = moment().constructor

        scope.initialFlow = (type) ->
            self.flow_type = type

            return {}

        scope.createFlow = (request, receptor, list) ->
            data = _.cloneDeep(request)

            if data.start_time && typeof(data.start_time) == 'object'
                data.start_time = moment(data.start_time._d).format('YYYY-MM-DD HH:MM:ss')
            if data.end_time && typeof(data.end_time) == 'object'
                data.end_time = moment(data.end_time._d).format('YYYY-MM-DD HH:MM:ss')

            if data.position
                # 调岗数据处理，否则无法序列化错误
                data.position = undefined

            data.vacation_days = scope.vacation_days
            data.receptor_id = if receptor then receptor.id else meta.id

            #临时处理, moment() 默认的 toString 不符合前后端约定
            #暂时没有找到好的方法
            for own key, value of data
                if value instanceof Moment
                    data[key] = value.format()

            $http.post("/api/workflows/#{self.flow_type}", data).success () ->
                scope.panel.close() if scope.panel
                # 这个bug很奇葩，刷新了服务器的请假数据后，最新的1条id没有更新，其他的列有更新
                # 导致点击查看按钮，显示的是错位的流程信息
                list.$refresh() if list
                self.toaster.pop('success', '提示', '流程创建成功')
                self.state.go(self.state.current.name, {}, {reload: true})


class NewMyRequestCtrl extends NewFlowCtrl
    @.$inject = ['$scope', '$http', '$timeout', '$state', 'USER_META', 'toaster', '$nbEvent', 'Employee']

    constructor: (scope, $http, $timeout, $state, meta, toaster, @Evt, @Employee) ->
        super(scope, $http, $state, meta, toaster) # 手动注入父类实例化参数
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
        scope.calculateTotalDays = (data, vacation_type, sync_end_time) ->
            data.end_time = data.start_time if sync_end_time

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


app.controller('EditableResourceCtrl', EditableResourceCtrl)
app.controller('NewResourceCtrl', NewResourceCtrl)
app.controller('NewFlowCtrl', NewFlowCtrl)
app.controller('NewMyRequestCtrl', NewMyRequestCtrl)