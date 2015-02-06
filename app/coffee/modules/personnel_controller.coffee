
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
                ncyBreadcrumb: {
                    label: "人事信息列表"
                }
            }
            .state 'personnel.detail', {
                url: '/{empId:[0-9]+}'
                abstract:true
                views: {
                    "@": {
                        controller: PerInfoCtrl
                        controllerAs: 'ctrl'
                        templateUrl: 'partials/personnel/info.html'
                    }
                }
            }
            .state 'personnel.detail.basic',{
                url: ''
                views: {
                    "detail@personnel.detail": {
                        templateUrl: "partials/personnel/info_basic.html"
                    }
                }
                ncyBreadcrumb: {
                    label: "{{selectEmp.name}}的基本信息"
                }
            }
            .state 'personnel.detail.editing',{
                url: '/editing/:template'
                views: {
                    "detail@personnel.detail": {
                        templateUrl: (params) ->
                            return "partials/personnel/info_#{params.template}_editing.html"
                    }
                }
                ncyBreadcrumb: {
                    label: "{{selectEmp.name}}的详情信息"
                }
            }
            .state nb.$buildDialog {
                name: 'personnel.resume'
                url: '/resume'
                controller: ResumeCtrl
                templateUrl: 'partials/personnel/personnel_resume.html'
                size: 'lg'
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
            .state 'personnel.check',{
                url: '/check-list'
                template: '<div ui-view></div>'
                abstract:true
                ncyBreadcrumb: {
                    label: "待审核列表"
                }
            }
            .state 'personnel.check.list',{
                url: ''
                templateUrl: 'partials/personnel/personnel_check_list.html'
                ncyBreadcrumb: {
                    label: "待审核列表"
                }
            }
            .state 'personnel.check.record',{
                url: '/record'
                templateUrl: 'partials/personnel/personnel_changes_record.html'
                ncyBreadcrumb: {
                    label: "待审核列表"
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

class PerInfoCtrl extends nb.Controller

    @.$inject = ['$scope', 'sweet', 'Employee', '$stateParams', 'Org']


    constructor: (@scope, @sweet, @Employee, @stateParams, @Org) ->
        @loadInitailData()
        @basicEdit = false
        @posEdit = false

    loadInitailData: ->
        # @scope.selectEmp = @Employee.$find(@stateParams.empId)

    createPerPos: (perPos) ->
        console.log perPos

    setSelectedOrg: (org) ->
        @scope.selectEmp.department = org
        @scope.selectEmp.position = null
        @loadOrgPos()
        # 返回true是为了能执行后面的closeDialog
        return true
    loadOrgPos: ->
        currentOrg = @Org.$new @scope.selectEmp.department.id
        @scope.orgPos = currentOrg.positions.$fetch()

class NewEmpsCtrl extends nb.Controller
    @.$inject = ['$scope', 'Employee']
    constructor: (@scope, @Employee) ->
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


class RegEmployeeCtrl extends nb.Controller

    @.$inject = ['$scope', 'Employee']

    constructor: (@scope, @Employee) ->
        @scope.test = "test"
    regEmployee: (employee)->
        console.log employee

        


class ResumeCtrl extends Modal
    @.$inject = ['$modalInstance', '$scope', '$nbEvent','memoName', '$injector']
    constructor: (@dialog, @scope, @Evt, @memoName, @injector) ->
        super(dialog, scope, memoName)







app.config(Route)
app.controller('PerInfoCtrl', PerInfoCtrl)
app.controller('RegEmployeeCtrl', RegEmployeeCtrl)
