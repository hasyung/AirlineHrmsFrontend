
nb = @.nb
app = nb.app
extend = angular.extend
resetForm = nb.resetForm
Modal = nb.Modal



class Route
    @.$inject = ['$stateProvider']

    constructor: (stateProvider) ->
        stateProvider
            .state 'management', {
                url: '/management'
                templateUrl: 'partials/management/self_info.html'
                controller: ManagementCtrl
                controllerAs: 'ctrl'
                abstract:true
                ncyBreadcrumb: {
                    label: "员工自助"
                }
                resolve: {
                }
            }
            .state 'management.personnel', {
                url: ''
                views: {
                    "detail@management": {
                        controller: perInfoCtrl
                        controllerAs: 'ctrl'
                        templateUrl: 'partials/management/self_info_basic.html'
                    }
                }
                ncyBreadcrumb: {
                    label: "员工自助"
                }
                
                resolve: {
                }
            }

class ManagementCtrl extends nb.Controller

    @.$inject = ['$scope', 'sweet', 'Employee']


    constructor: (@scope, @sweet, @Employee) ->
        @loadInitailData()

    loadInitailData: ->
        @employees = @Employee.$collection().$fetch()

    search: (tableState) ->
        @employees.$refresh(tableState)



class perInfoCtrl extends nb.Controller

    @.$inject = ['$scope', 'sweet', 'Employee', '$rootScope']


    constructor: (@scope, @sweet, @Employee, @rootScope) ->
        @loadInitailData()
        @status = 'show'

    loadInitailData: ->
        @scope.selectEmp = @rootScope.currentUser






app.config(Route)
