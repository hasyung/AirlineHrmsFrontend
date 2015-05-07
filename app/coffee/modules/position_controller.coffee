
nb = @.nb
app = nb.app
extend = angular.extend
resetForm = nb.resetForm
Modal = nb.Modal



class Route
    @.$inject = ['$stateProvider']

    constructor: (stateProvider) ->
        stateProvider
            .state 'position_list', {
                url: '/positions'
                templateUrl: 'partials/position/position.html'
                controller: PositionCtrl
                controllerAs: 'ctrl'
            }
            .state 'position_changes', {
                url: '/positions/changes'
                controller: PositionChangesCtrl
                controllerAs: 'ctrl'
                templateUrl: 'partials/position/position_changes.html'

            }

class PositionCtrl extends nb.Controller

    @.$inject = ['Position', '$scope', 'sweet']

    constructor: (@Position, @scope, @sweet) ->
        @loadInitialData()
        @selectedIndex =  1


        @columnDef = [
            {
                displayName: '岗位名称'
                field: 'name'
                # pinnedLeft: true
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a nb-panel
                        panel-controller="PositionDetailCtrl"
                        template-url="partials/position/position_detail.html"
                        locals="{position: row.entity}">
                        {{grid.getCellValue(row, col)}}
                    </a>
                </div>
                '''
            }
            {
                displayName: '所属部门'
                name: 'department.name'
                cellTooltip: (row) ->
                    return row.entity.department.name
            }
            {displayName: '通道', name: 'channelId', cellFilter: "enum:'channels'"}
            {
                displayName: '编制数'
                name: 'budgetedStaffing'
                cellTemplate: '''
                <div class="ui-grid-cell-contents" ng-class="{'overstaffed': row.entity.overstaffedNum > 0}">
                    {{row.entity.staffing}}/{{grid.getCellValue(row, col)}}
                </div>
                '''
            }
            {displayName: '工作时间', name: 'scheduleId', cellFilter: "enum:'position_schedules'"}
            {displayName: 'OA文件编号', name: 'oaFileNo'}
        ]
        @constraints = [


        ]
        @filterOptions = {
            name: 'position'
            constraintDefs: [
                {
                    name: 'name'
                    displayName: '岗位名称'
                    type: 'string'
                    placeholder: '岗位名称'
                }
                {
                    name: 'staffing_surpass'
                    displayName: '是否超编'
                    type: 'boolean'
                }
                {
                    name: 'channel_id'
                    type: 'select'
                    displayName: '岗位通道'
                    params: {
                        type: 'channels'
                    }
                }
                {
                    name: 'created_at'
                    type: 'date-range'
                    displayName: '创建时间'
                }
                {
                    name: 'department_ids'
                    displayName: '机构'
                    type: 'org-search'
                }
            ]
        }








    loadInitialData: ->
        self = @
        @positions = @Position.$collection().$fetch()

    search: (tableState) ->
        @positions.$refresh(tableState)

    getExportParams: () ->
        @positions
                .filter (pos) -> pos.isSelected
                .map (pos) -> pos.id
                .join(',')

class PositionChangesCtrl extends nb.Controller

    @.$inject = ['PositionChange']

    constructor: (@PositionChange) ->
        @changes = @PositionChange.$collection().$refresh()
        @columnDef = [
            {name:"name", displayName:"岗位名称"}
            {name:"department.name", displayName:"所属部门"}
            {name:"action", displayName:"操作"}
            {name:"auditableType", displayName:"信息变更模块"}
            {
                displayName: '信息变更模块'
                field: 'auditableType'
                # pinnedLeft: true
                cellTemplate: '''
                <div class="ui-grid-cell-contents ng-binding ng-scope">
                    <a
                        href="javascript:void(0);"
                        nb-dialog
                        template-url="partials/common/{{row.entity.action == '修改'? 'update_change_review.tpl.html': 'create_change_review.tpl.html'}}"
                        locals="{'change': row.entity}"> {{row.entity.auditableType}}
                    </a>
                </div>
                '''
            }
            {name:"createdAt", displayName:"变更时间"}

        ]
        @filterOptions = {
            name: 'position_changes'
            constraintDefs: [

                {
                    name: 'name'
                    displayName: '岗位名称'
                    type: 'string'
                }
                {
                    name: 'department_ids'
                    displayName: '机构'
                    type: 'org-search'
                }
                {
                    name: 'created_at'
                    type: 'date-range'
                    displayName: '创建时间'
                }
            ]
        }


    searchChanges: (tableState)->
        @changes.$refresh(tableState)

class PositionDetailCtrl

    @.$inject = ['$scope']

    constructor: (scope) ->

        @workingEmpColumnDef = [
            {displayName: '员工编号', name: 'employeeNo'}
            {displayName: '姓名', name: 'name'}
            {displayName: '到岗时间', name: 'startDate'}
        ]

        @formerleadersColumnDef = [
            {displayName: '员工编号', name: 'employeeNo'}
            {displayName: '姓名', name: 'name'}
            {displayName: '到岗时间', name: 'startDate'}
        ]

app.controller 'PositionDetailCtrl', PositionDetailCtrl

app.config(Route)
