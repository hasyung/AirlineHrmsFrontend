
nb = @.nb
app = nb.app
extend = angular.extend
resetForm = nb.resetForm
Modal = nb.Modal



class Route
    @.$inject = ['$stateProvider']

    constructor: (stateProvider) ->
        stateProvider
            .state 'position', {
                url: '/positions'
                templateUrl: 'partials/position/position.html'
                controller: PositionCtrl
                controllerAs: 'ctrl'
                ncyBreadcrumb: {
                    label: "岗位"
                }
                resolve: {
                }
            }

class PositionCtrl extends nb.Controller

    @.$inject = ['Position', '$scope', '$http']


    constructor: (@Position, @scope, @http) ->
        @loadInitialData()
        scope.tableState = null
    loadInitialData: ->
        @positions = @Position.$collection().$fetch()

    search: (tableState) ->
        @positions.$refresh(tableState)






app.config(Route)
