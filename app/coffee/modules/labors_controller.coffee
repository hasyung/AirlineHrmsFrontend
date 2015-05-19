
nb = @.nb
app = nb.app
extend = angular.extend
Modal = nb.Modal



class Route
    @.$inject = ['$stateProvider', '$urlRouterProvider']

    constructor: (stateProvider, urlRouterProvider) ->

        stateProvider
            .state 'contract_management', {
                url: '/contract-management'
                templateUrl: 'partials/labors/contract_management.html'
                controller: ContractCtrl
                controllerAs: 'ctrl'
            }

class LaborCtrl extends nb.Controller

    @.$inject = ['$scope', '$mdDialog', 'Flow::AdjustPosition']

    constructor: (@scope, @mdDialog, flow) ->
        @flows  = flow.$collection().$fetch()

    search: (tableState)->
        @flows.$refresh(tableState)

class ContractCtrl extends nb.Controller
    @.$inject = ['$scope', 'Contrack']
    constructor: (@scope, @Contrack) ->
        # ...
    






app.config(Route)
