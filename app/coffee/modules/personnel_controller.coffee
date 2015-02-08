
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
                template: '<div ui-view></div>'
                controller: PersonnelCtrl
                controllerAs: 'ctrl'
                abstract:true
                ncyBreadcrumb: {
                    label: "人事管理"
                }
            }
            .state 'personnel.list', {
                url: ''
                templateUrl: 'partials/personnel/personnel.html'
                controller: PersonnelCtrl
                controllerAs: 'ctrl'

            }
            .state 'personnel.fresh',{
                url: '/fresh-list'
                views: {
                    "@": {
                        controller: NewEmpsCtrl
                        controllerAs: 'ctrl'
                        templateUrl: 'partials/personnel/personnel_new_list.html'
                    }
                }
                ncyBreadcrumb: {
                    label: "新员工列表"
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

    getExportParams: ->
        @employees
                .filter (emp) -> emp.isSelected
                .map (emp) -> emp.id
                .join(',')

class NewEmpsCtrl extends nb.Controller
    @.$inject = ['$scope', 'Employee', 'Org']
    constructor: (@scope, @Employee, @Org) ->
        @newEmp = {}
        @loadInitailData()

    loadInitailData: ->

        collection_param = {
            predicate: {
                join_scal_date: {
                    from: moment().startOf('year').format("YYYY-MM-DD")
                    to: moment().format("YYYY-MM-DD")
                }
            }
            sort: {
                join_scal_date: 'desc'
            }
        }

        @scope.newEmps = @Employee.$collection(collection_param).$fetch()
    regEmployee: (employee)->
        @Employee.$build(employee).$save()

    getExportParams: ->
        @scope.newEmps
                .filter (emp) -> emp.isSelected
                .map (emp) -> emp.id
                .join(',')

app.config(Route)