
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
        @loadInitailData()
        @selectedIndex =  1


        @columnDef = [
            {
                displayName: '岗位名称'
                field: 'name'
                # pinnedLeft: true
                cellTemplate: '''
                <div class="ui-grid-cell-contents ng-binding ng-scope">
                    <a nb-panel
                        template-url="partials/position/position_detail.html"
                        locals="{position: row.entity}">
                        {{grid.getCellValue(row, col)}}
                    </a>
                </div>
                '''
            }
            {displayName: '所属部门', name: 'department.name'}
            {displayName: '通道', name: 'channelId', cellFilter: "enum:'channels'"}
            {
                displayName: '编制数', 
                name: 'budgetedStaffing'
                cellTemplate: '''
                <div class="ui-grid-cell-contents ng-binding ng-scope">
                    
                </div>
                '''                
            }
            {displayName: '工作时间', name: 'schedule.displayName'}
            {displayName: 'OA文件编号', name: 'oaFileNo'}
        ]
        @constraints = [


        ]
        @filterOptions = {
            name: 'personnel'
            constraintDefs: [
                {
                    name: 'name'
                    displayName: '岗位名称'
                    type: 'string'
                    placeholder: '岗位名称'
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

    @.$inject = ['PositionChange', '$mdDialog']

    constructor: (@PositionChange, @mdDialog) ->

    searchChanges: (tableState)->
        @changes.$refresh(tableState)




app.config(Route)
