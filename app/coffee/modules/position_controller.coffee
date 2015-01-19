
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

        @search = (tableState) ->
            console.debug "search success:", arguments
            @$parent.tableState = JSON.stringify(tableState)

            callback = (data, status, headers, config) ->
                @$parent.status = data.$status
                @$parent.data = JSON.stringify(data.$wrap())

            req = {
                method: 'POST'
                url: '/api/positions'
                data: tableState
            }

            Position.$search(tableState).$then callback.bind(@)

    loadInitialData: ->
        # @positions = @Position.$collection().$fetch()





app.config(Route)
