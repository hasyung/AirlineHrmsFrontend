nb = @.nb
app = nb.app

class Route
    @.$inject = ['$stateProvider']

    constructor: (stateProvider) ->
        stateProvider
            .state 'nationality', {
                url: '/nationality'
                templateUrl: 'partials/nationality/nationality.html'
                controller: NationalityController
                controllerAs: 'ctrl'
            }

app.config(Route)

class NationalityController extends nb.Controller
    @.$inject = ['$scope', '$rootScope', 'Nationality']

    constructor: (@scope, @rootScope, @Nationality) ->

        @filterOptions = {
            name: 'nationality'
            constraintDefs: [
                {
                    name: 'id'
                    displayName: '员工标识'
                    type: 'string'
                    placeholder: '员工标识'
                }
                {
                    name: 'nationality'
                    type: 'string'
                    displayName: '国籍'
                }
            ]
        }

        @columnDef = [
            {minWidth: 120, displayName: '员工编号', name: 'employeeNo'}
            {
                minWidth: 250
                displayName: '岗位'
                name: 'position.name'
                cellTooltip: (row) ->
                    return row.entity.position.name
            }
            {minWidth: 120, displayName: '分类', name: 'categoryId', cellFilter: "enum:'categories'"}
            {minWidth: 120, displayName: '通道', name: 'channelId', cellFilter: "enum:'channels'"}
            {minWidth: 120, displayName: '用工性质', name: 'laborRelationId', cellFilter: "enum:'labor_relations'"}
            {minWidth: 120, displayName: '到岗时间', name: 'joinScalDate'}
        ]

        @initialData()


    initialData: () ->
        @nationality = @Nationality.$collection().$fetch()




