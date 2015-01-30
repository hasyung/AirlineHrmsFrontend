
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
                url: '/{empId:[0-9]+}'
                abstract:true
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
            .state 'personnel.detail.basic',{
                url: ''
                views: {
                    "detail@personnel.detail": {
                        controller: perInfoCtrl
                        controllerAs: 'ctrl'
                        templateUrl: 'partials/personnel/info_basic.html'
                    }
                }
                ncyBreadcrumb: {
                    label: "{{selectEmp.name}}的基本信息"
                }
            }
            .state 'personnel.detail.more',{
                url: '/more'
                views: {
                    "detail@personnel.detail": {
                        controller: perInfoCtrl
                        controllerAs: 'ctrl'
                        templateUrl: 'partials/personnel/info_detail.html'
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

    loadInitailData: ->
        @scope.selectEmp = @Employee.$find(@stateParams.empId)




class ResumeCtrl extends Modal
    @.$inject = ['$modalInstance', '$scope', '$nbEvent','memoName', '$injector']
    constructor: (@dialog, @scope, @Evt, @memoName, @injector) ->
        super(dialog, scope, memoName)
    






app.config(Route)
