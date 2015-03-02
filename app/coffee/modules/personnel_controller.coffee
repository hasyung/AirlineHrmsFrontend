
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
            .state 'personnel.review', {
                url: '/change-review'
                templateUrl: 'partials/personnel/change_review.html'
                controller: ReviewCtrl
                controllerAs: 'ctrl'

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

        @employees = @Employee.$collection(collection_param).$fetch()
    regEmployee: (employee)->
        @Employee.$build(employee).$save()

    getExportParams: ->
        @employees
                .filter (emp) -> emp.isSelected
                .map (emp) -> emp.id
                .join(',')
    search: (tableState) ->
        @employees.$refresh(tableState)

class ReviewCtrl extends nb.Controller
    @.$inject = ['$scope', 'Change', 'Record']
    constructor: (@scope, @Change, @Record) ->
        @loadInitailData()

    loadInitailData: ->
        # @changes = @Change.$collection().$fetch()
        # @records = @Record.$collection().$fetch()
    searchRecord: (tableState)->
        @records.$refresh(tableState);
    checkChanges: ()->
        params = []
        # '无需审核': 0
        # '待审核': 1
        # '通过': 2
        # '不通过': 3
        checked = _.filter @changes, (item)->
            return item if item.statusCd != "1"
        _.forEach checked, (item)->
            temp = {}
            temp.id = item.id
            temp.status_cd = item.statusCd
            temp.reason = item.reason
            params.push temp
        @changes.checkChanges(params)

        

app.config(Route)
