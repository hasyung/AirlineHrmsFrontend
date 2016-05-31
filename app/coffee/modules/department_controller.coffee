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
    @.$inject = ['$scope', '$http', 'Reports', 'toaster']

    constructor: (@scope, @http, @Reports, @toaster) ->
        @loadInitialData()

    loadInitialData: () ->
        @reports = @Reports.$collection().$fetch()

    isImgObj: (obj)->
        return /jpg|jpeg|png|gif/.test(obj.type)

    createReport: (report, collection) ->
        self = @

        params = {
            title: report.title
            content: report.content
            attachment_ids: report.attachment_ids
            checker: report.checker
        }

        collection.$create(params).$asPromise().then (data)->
            self.toaster.pop('success', '汇报创建成功')
            collection.$refresh()

    editReport: (report) ->
        self = @

        report.$save().$asPromise().then (data)->
            self.toaster.pop('success', '汇报修改成功')
            self.reports.$refresh()

    removeReport: (report) ->
        self = @

        report.$destroy({id: report.id}).$asPromise().then (data)->
            self.toaster.pop('success', '汇报删除成功')
            self.reports.$refresh()

    uploadInNewReport: (report ,collection, $messages) ->
        self = @

        fileObj = JSON.parse($messages)
        file = fileObj.attachment
        collection = [] if !collection
        collection.push file
        report.attachment_ids.push file.id

    attachmentDestroyInNewReport: (report, attachments, attachment) ->
        idx = attachments.indexOf attachment

        attachments.splice idx, 1
        report.attachment_ids.splice idx, 1

    attachmentDestroy: (report, attachments, attachment) ->
        report.attachment_ids = report.attachment_ids || []
        attachments.forEach (item)->
            report.attachment_ids.push item.id

        idx = attachments.indexOf attachment
        attachments.splice(idx, 1)
        report.attachment_ids.splice(idx, 1)

    uploadAttachments: (report, $messages)->
        self = @

        fileObj = JSON.parse($messages)
        file = fileObj.attachment
        report.attachments = [] if !report.attachments
        report.attachment_ids = report.attachment_ids || []
        report.attachments.push file

        report.attachments.forEach (item)->
            report.attachment_ids.push item.id



        

app.controller 'DepartmentChartCtrl', DepartmentChartController


app.config(Route)
