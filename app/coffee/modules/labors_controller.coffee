
nb = @.nb
app = nb.app
extend = angular.extend
Modal = nb.Modal



class Route
    @.$inject = ['$stateProvider', '$urlRouterProvider']

    constructor: (stateProvider, urlRouterProvider) ->

        urlRouterProvider.when('/labor-relations', '/labor-relations')

        stateProvider
            .state 'labors_transfer', {
                url: '/labor-relations-transfer'
                templateUrl: 'partials/labors/labors_transfer.html'
                controller: LaborCtrl
                controllerAs: 'ctrl'
            }
            .state 'labors_early_retirement', {
                url: '/labor-eary-retirement'
                templateUrl: 'partials/labors/labors_early_retirement.html'
                controller: EarlyRetirementCtrl
                controllerAs: 'ctrl'
            }

class LaborCtrl extends nb.Controller

    @.$inject = ['$scope', '$mdDialog', 'Flow::AdjustPosition']

    constructor: (@scope, @mdDialog, @flow) ->
        @flows  = flow.$collection().$fetch()

    search: (tableState)->
        @flows.$refresh(tableState)


class EarlyRetirementCtrl extends nb.Controller

    @.$inject = ['$scope', 'Flow::EarlyRetirement', '$mdDialog']

    constructor: (@scope, @EarlyRetirement, @mdDialog) ->
        @loadInitailData()
        @columnDef = [
            {displayName: '所属部门', name: 'sponsor.departmentName'}
            {displayName: '姓名', field: 'sponsor.name'}
            {displayName: '状态', field: 'workflowState'}
            {displayName: '创建时间', field: 'createdAt'}
            {
                displayName: '审批'
                name: '审批'
                cellTemplate: '''
                <a class="ui-grid-cell-contents"
                    flow-handler="row.entity"
                    ">
                    审批
                </a>'
                '''
            }
        ]

    loadInitailData: ()->
        @flows = @EarlyRetirement.$collection().$fetch()




    







app.config(Route)

