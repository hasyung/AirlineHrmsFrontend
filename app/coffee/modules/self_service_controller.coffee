
nb = @.nb
app = nb.app
extend = angular.extend
resetForm = nb.resetForm
Modal = nb.Modal



class Route
    @.$inject = ['$stateProvider', '$urlRouterProvider']

    constructor: (stateProvider, urlRouterProvider) ->

        urlRouterProvider.when('/self-service', '/self-service/profile')

        stateProvider
            .state 'my_requests', {
                url: '/self/my_requests'
                templateUrl: 'partials/self/my_requests/index.html'
                # controller: AttendanceCtrl
                controllerAs: 'ctrl'
            }

class AttendanceCtrl extends nb.Controller

    @.$inject = ['$scope', 'Flow::EarlyRetirement', '$mdDialog']

    constructor: (@scope, @Leave, @mdDialog) ->
        @loadInitailData()

    loadInitailData: ()->
        @flows = @Leave.$collection().$fetch()

    # searchLeaves: (tableState)->
    #     @flows.$refresh(tableState)

class AttendanceDialogCtrl extends nb.Controller
    @.$inject = ['$scope', 'data', '$mdDialog']
    constructor: (@scope, @data, @mdDialog) ->
        self = @
        @scope.data = @data

    pass: (leave)->
        self = @
        leave.audit.opinion = true
        leave.$update().$then ()->
            self.mdDialog.hide()
    reject: (leave)->
        self = @
        leave.audit.opinion = false
        leave.$update().$then ()->
            self.mdDialog.hide()




app.config(Route)
app.controller('AttendanceDialogCtrl', AttendanceDialogCtrl)
