
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
                template: '<div ui-view></div>'
                controller: PositionCtrl
                controllerAs: 'ctrl'
                abstract:true
            }
            .state 'position.list', {
                url: ''
                templateUrl: 'partials/position/position.html'
                controller: PositionCtrl
                controllerAs: 'ctrl'
            }
            .state 'position.changes', {
                url: '/changes'
                views: {
                    "@": {
                        controller: PositionChangesCtrl
                        controllerAs: 'ctrl'
                        templateUrl: 'partials/position/position_changes.html'
                    }
                }
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
class PositionChangesCtrl extends nb.Controller

    @.$inject = ['PositionChange']

    constructor: (@PositionChange) ->

    searchChanges: (tableState)->
        @changes.$refresh(tableState)


    

app.config(Route)
