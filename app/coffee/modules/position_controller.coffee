
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
            }

class PositionCtrl extends nb.Controller

    @.$inject = ['Position', '$scope', 'sweet']

    constructor: (@Position, @scope, @sweet) ->
        @loadInitialData()

    loadInitialData: ->
        self = @
        @positions = @Position.$collection().$fetch()

    search: (tableState) ->
        @positions.$refresh(tableState)

    getExportParams: () ->
        @positions
                .filter (pos) -> pos.isSelected
                .map (pos) -> pos.id
                .join(',')

app.config(Route)
