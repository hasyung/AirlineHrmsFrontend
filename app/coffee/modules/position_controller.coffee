
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
                @$parent.status = JSON.stringify(data.status)
                @$parent.headers = JSON.stringify(data.headers())
                @$parent.data = JSON.stringify(data.data)

            req = {
                method: 'GET'
                url: '/api/positions'
                data: tableState
            }

            http(req).then callback.bind(@)

    loadInitialData: ->
        # @positions = @Position.$collection().$fetch()





app.config(Route)
