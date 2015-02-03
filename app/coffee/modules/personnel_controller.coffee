
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
                        controller: perInfoCtrl
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
                url: 'fresh-list'
                views: {
                    "@": {
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



class perInfoCtrl extends nb.Controller

    @.$inject = ['$scope', 'sweet', 'Employee', '$stateParams']


    constructor: (@scope, @sweet, @Employee, @stateParams) ->
        @loadInitailData()
        @basicEdit = false
        @posEdit = false

    loadInitailData: ->
        @scope.selectEmp = @Employee.$find(@stateParams.empId)


class ResumeCtrl extends Modal
    @.$inject = ['$modalInstance', '$scope', '$nbEvent','memoName', '$injector']
    constructor: (@dialog, @scope, @Evt, @memoName, @injector) ->
        super(dialog, scope, memoName)
    






app.config(Route)
