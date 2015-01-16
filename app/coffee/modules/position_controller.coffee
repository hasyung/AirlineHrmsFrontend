
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

    @.$inject = ['Position', '$scope']


    constructor: (@Position, @scope) ->
        @loadInitialData()
        scope.tableState = null

    loadInitialData: ->
        # @positions = @Position.$collection().$fetch()

    search: (tableState) ->
        console.debug "search success:", arguments
        @$parent.tableState = JSON.stringify(tableState)



app.config(Route)
