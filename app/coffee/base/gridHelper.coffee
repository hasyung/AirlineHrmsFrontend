

app = @nb.app


defaultCol =    [
        {displayName: '员工编号', name: 'receptor.employeeNo'}
        {
            displayName: '姓名'
            field: 'receptor.name'
            # pinnedLeft: true
            cellTemplate: '''
            <div class="ui-grid-cell-contents ng-binding ng-scope">
                <a nb-panel
                    template-url="partials/personnel/info_basic.html"
                    locals="{employee: row.entity}">
                    {{grid.getCellValue(row, col)}}
                </a>
            </div>
            '''
        }
        {
            displayName: '所属部门'
            name: 'receptor.departmentName'
            cellTooltip: (row) ->
                return row.entity.departmentName
        }

        {
            displayName: '岗位'
            name: 'receptor.positionName'
            cellTooltip: (row) ->
                return row.entity.positionName
        }
    ]


app.factory 'GridHelper', ->

    buildDefaultGridOptions = (columnDef) ->
        defaultColClone = _.cloneDeep(defaultCol)
        defaultColClone.concat columnDef

    return {
        buildFlowDefault: buildDefaultGridOptions
    }

