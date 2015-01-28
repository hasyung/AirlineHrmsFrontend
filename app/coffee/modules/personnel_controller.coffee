
nb = @.nb
app = nb.app
extend = angular.extend
resetForm = nb.resetForm
Modal = nb.Modal



class Route
    @.$inject = ['$stateProvider']

    constructor: (stateProvider) ->
        stateProvider
            .state 'personnel', {
                url: '/personnels'
                templateUrl: 'partials/personnel/personnel.html'
                controller: PersonnelCtrl
                controllerAs: 'ctrl'
                ncyBreadcrumb: {
                    label: "人事信息"
                }
                resolve: {
                }
            }
            .state 'personnel.detail', {
                url: '/:id'
                # templateUrl: 'partials/personnel/info.html'
                # controller: perInfoCtrl
                controllerAs: 'ctrl'
                views: {
                    "@": {
                        controller: perInfoCtrl
                        controllerAs: 'ctrl'
                        templateUrl: 'partials/personnel/info.html'
                    }
                }
                resolve: {
                }
            }

class PersonnelCtrl extends nb.Controller

    @.$inject = ['$scope', 'sweet', 'Employee']


    constructor: (@scope, @sweet, @Employee) ->
        @loadInitailData()

    loadInitailData: ->
        @employees = @Employee.$collection().$fetch()

    search: (tableState) ->
        @employees.$refresh(tableState)



class perInfoCtrl extends nb.Controller

    @.$inject = ['$scope', 'sweet', 'Employee']


    constructor: (@scope, @sweet, @Employee) ->
        @loadInitailData()

    loadInitailData: ->
        # @employees = @Employee.$collection().$fetch()

    search: (tableState) ->
        # @employees.$refresh(tableState)







app.config(Route)
