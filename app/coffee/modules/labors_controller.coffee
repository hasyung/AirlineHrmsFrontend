
nb = @.nb
app = nb.app
extend = angular.extend
Modal = nb.Modal



class Route
    @.$inject = ['$stateProvider', '$urlRouterProvider']

    constructor: (stateProvider, urlRouterProvider) ->

        urlRouterProvider.when('/labor-relations', '/labor-relations')

        stateProvider
            .state 'labors_transfer', {
                url: '/labor-relations-transfer'
                templateUrl: 'partials/labors/labors_transfer.html'
                controller: LaborCtrl
                controllerAs: 'ctrl'
            }

class LaborCtrl extends nb.Controller

    @.$inject = ['$scope', '$mdDialog', 'Flow::AdjustPosition']

    constructor: (@scope, @mdDialog, flow) ->
        @flows  = flow.$collection().$fetch()

    search: (tableState)->
        @flows.$refresh(tableState)

class LaborDialogCtrl extends nb.Controller
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
app.controller('LaborDialogCtrl', LaborDialogCtrl)
