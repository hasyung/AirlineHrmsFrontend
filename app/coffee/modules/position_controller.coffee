
nb = @.nb
app = nb.app
extend = angular.extend
resetForm = nb.resetForm
Modal = nb.Modal



class Route
    @.$inject = ['$stateProvider']

    constructor: (stateProvider) ->
        stateProvider
            .state 'org', {
                url: '/orgs'
                templateUrl: 'partials/positions/positions.html'
                controller: 'OrgsCtrl'
                controllerAs: 'ctrl'
                ncyBreadcrumb: {
                    label: "岗位"
                }
                resolve: {
                    eidtMode: ->
                        return true
                }
            }

class PositionCtrl extends nb.Controller


    constructor: (@Position) ->
        @loadInitialData()

    loadInitialData: ->
        @positions = @Position.$collection().$fetch()