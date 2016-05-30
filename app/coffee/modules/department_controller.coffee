nb = @.nb
app = nb.app


class Route
    @.$inject = ['$stateProvider', '$urlRouterProvider']

    constructor: (stateProvider, urlRouterProvider) ->
        stateProvider
            .state 'department_chart', {
                url: '/department_chart'
                controller: DepartmentChartController
                controllerAs: 'ctrl'
                templateUrl: 'partials/department/department_chart.html'
            }
            
            
        
class DepartmentChartController extends nb.Controller
    @.$inject = ['$scope', '$http', 'Reports']

    constructor: (@scope, @http, @Reports) ->
        @loadInitialData()

    loadInitialData: () ->
        @reports = @Reports.$collection().$fetch()

    isImgObj: (obj)->
        return /jpg|jpeg|png|gif/.test(obj.type)

    attachmentDestroy: (attachment) ->
        attachment.$destroy()

    createReport: (report, collection) ->
        self = @

        params = {
            title: report.title
            content: report.content
            checker: report.checker
        }

        collection.$create(params).$asPromise().then (data)->
            collection.$refresh()

    uploadAttachments: (lord, collection, $messages)->
        self = @

        data = JSON.parse($messages)

        hash = {
            id: data.id
            name: data.file_name
            type: data.file_type
            size: data.file_size
            lord_id: lord.id
        }

        collection.$create(hash).$asPromise().then (data)->
            collection.$refresh()

app.controller 'DepartmentChartCtrl', DepartmentChartController


app.config(Route)
