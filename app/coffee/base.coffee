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
            item + '' # to string

    $getFilterMonths: ()->
        self = @
        years = @$getYears()

        array = []
        angular.forEach years, (year)->
            if year == new Date().getFullYear()
                months = self.$getMonths()
            else
                months = [1..12]

                months = _.map months, (item)->
                    item = '0' + item if item < 10
                    item + ''

            angular.forEach months, (month)->
                array.push(year + '-' + month)

        array

    $getSeasons: ()->
        years = @$getYears()
        array = []

        angular.forEach years, (year)->
            angular.forEach [1,2,3,4], (quarter)->
                array.push(year + '-' + quarter)

        array

    parseJSON: (data) ->
        angular.fromJson(data)

    $multiply: (multiplier, multiplicand) ->
        m = 0
        s1 = multiplier.toString()
        s2 = multiplicand.toString()

        try
            m += s1.split(".")[1].length
        catch error
        
        try
            m += s2.split(".")[1].length
        catch error
        
        return Number(s1.replace(".", "")) * Number(s2.replace(".","")) / Math.pow(10,m)

    # 这两个函数依赖于 $rootScope 
    # 所以在使用时必须在子类controller中注入 $rootScope
    cancelLoading: () ->
        @rootScope.loading = false

    startLoading: () ->
        @rootScope.loading = true
        

class FilterController extends Controller
    onConditionInValid: ($Evt, invalid) ->
        $Evt.$send('search:condition:error', {message: invalid.join(",")})


class EditableResourceCtrl
    @.$inject = ['$scope', '$enum', '$nbEvent']

    constructor: (scope, $enum, @Evt) ->
        scope.editing = false
        scope.$enum = $enum
        self = @

        scope.edit = (evt) ->
            evt.preventDefault() if evt && evt.preventDefault
            scope.editing = true

        scope.save = (promise, form, collections) ->
            return if form && form.$invalid

            if promise
                if promise.then
                    promise.then (data) ->
                        scope.editing = false
                        self.response_data = data

                        if self.response_data
                            msg = self.response_data.messages
                            self.Evt.$send('model:save:success', msg || "保存成功")
                else if promise.$then && !collections
                    promise.$then (data) ->
                        scope.editing = false
                        self.response_data = data

                        if self.response_data
                            msg = self.response_data.$response.data.messages
                            self.Evt.$send('model:save:success', msg || "保存成功")
                else if promise.$then && collections
                    promise.$then (data) ->
                        scope.editing = false
                        self.response_data = data
                        collections.$refresh()

                        if self.response_data
                            msg = self.response_data.$response.data.messages
                            self.Evt.$send('model:save:success', msg || "保存成功")
                else
                    throw new Error('promise 参数错误')

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
    @.$inject = ['$scope', '$http', '$state', 'USER_META', 'toaster', 'VACATIONS']

    constructor: (scope, $http, @state, meta, @toaster, vacations) ->
        self = @

        Moment = moment().constructor

        scope.initialFlow = (type) ->
            self.flow_type = type

            return {}

        scope.createFlow = (request, receptor, list) ->
            if self.flow_type == "Flow::AnnualLeave"
                # 两年年假就有 2 个 ng-repeat
                # 指令 flowHandler 处理后再次会渲染 2 次
                rd = request.relation_data
                start = rd.indexOf("年假 (")
                # ng_code = "年假 (<span ng-repeat=\"(key, value) in vacations.year_days.year\">{{key}} 年年假剩余天数 {{value}} 天 </span>"
                # request.relation_data =  rd.substring(0, start) + ng_code + ")</span>" + "</div></div></div>"

                static_content = "<span>年假 ("

                if angular.isDefined(vacations)
                    angular.forEach vacations.year_days.year, (value, key)->
                        static_content += "<span>" + key + " 年年假剩余天数 " + value + " 天</span>"

                static_content += ")</span></div></div></div>"

                request.relation_data =  rd.substring(0, start) + static_content
                #console.error static_content
                #console.error request.relation_data

            data = _.cloneDeep(request)

            if data.start_time && typeof(data.start_time) == 'object'
                data.start_time = moment(data.start_time._d).format()
            if data.end_time && typeof(data.end_time) == 'object'
                data.end_time = moment(data.end_time._d).format()

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
    @.$inject = ['$scope', '$http', '$timeout', '$state', 'USER_META', 'toaster', '$nbEvent', 'Employee', 'VACATIONS']

    constructor: (scope, $http, $timeout, $state, meta, @toaster, @Evt, @Employee, vacations) ->
        super(scope, $http, $state, meta, @toaster, vacations) # 手动注入父类实例化参数
        self = @

        scope.request = {}
        scope.calculating = false
        scope.start_times = []
        scope.end_times = []

        scope.isRequestLegal = true

        enableCalculating = ->
            scope.calculating = true

        disableCalculating = ->
            scope.calculating = false

        scope.loadStartTime = () ->
            startOfDay = moment(scope.request.start_time).startOf('day')

            scope.start_times = [
                startOfDay.clone().add(9, 'hours')
                startOfDay.clone().add(13, 'hours').add('30', 'm')
            ]

        scope.loadEndTime = () ->
            startOfDay = moment(scope.request.end_time).startOf('day')

            scope.end_times = [
                startOfDay.clone().add(13, 'hours').add('30', 'm')
                startOfDay.clone().add(17, 'hours')
            ]

        # 计算请假天数
        scope.calculateTotalDays = (data, vacation_type, sync_end_time, receptor) ->
            data.end_time = data.start_time if sync_end_time
            # 女工假特殊处理
            if vacation_type == '女工假'
                scope.vacation_days = 1
                data.end_time = moment(data.start_time).format()

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
                    scope.vacation_days = data.general_days
                    scope.isRequestLegal = self.isVacationLegal(vacation_type, receptor.vacations, scope.vacation_days, receptor.workShifts)

    # 检测有限假期的规则
    isVacationLegal: (type, vacations, calcDays, classSystem) ->
        if type == '年假' && vacations.yearDays.total < calcDays
            @toaster.pop('error', '提示', '剩余年假不足')
            return false
        if type == '补休假' && vacations.offsetDays < calcDays
            @toaster.pop('error', '提示', '剩余补休假不足')
            return false
        if type == '年假' && classSystem == '三班倒' && calcDays%3 != 0
            @toaster.pop('error', '提示', '天数必须为3的倍数')
            return false

        return true



app.controller('EditableResourceCtrl', EditableResourceCtrl)
app.controller('NewResourceCtrl', NewResourceCtrl)
app.controller('NewFlowCtrl', NewFlowCtrl)
app.controller('NewMyRequestCtrl', NewMyRequestCtrl)