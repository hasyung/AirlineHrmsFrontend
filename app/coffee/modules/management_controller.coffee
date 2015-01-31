
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
                templateUrl: 'partials/management/personnel/self_info.html'
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
                        templateUrl: 'partials/management/personnel/self_info_basic.html'
                    }
                }
                ncyBreadcrumb: {
                    label: "员工自助"
                }
                
                resolve: {
                }
            }

class ManagementCtrl extends nb.Controller

    @.$inject = ['$scope', 'sweet', 'Employee', '$rootScope']


    constructor: (@scope, @sweet, @Employee, @rootScope) ->
        @scope.currentUser = @rootScope.currentUser
        @loadInitailData()

    loadInitailData: ->




class perInfoCtrl extends nb.Controller

    @.$inject = ['$scope', 'sweet', 'Employee', '$rootScope']


    constructor: (@scope, @sweet, @Employee, @rootScope) ->
        @loadInitailData()
        @status = 'show'

    loadInitailData: ->
        console.log @rootScope.currentUser
        @scope.selectEmp = @rootScope.currentUser






app.config(Route)
