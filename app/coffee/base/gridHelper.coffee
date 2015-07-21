

# 表格的工具类， 将重复的表格列抽取出来

app = @nb.app


defaultFlowCol =    [
        {displayName: '员工编号', name: 'receptor.employeeNo'}
        {
            displayName: '姓名'
            field: 'receptor.name'
            # pinnedLeft: true
            cellTemplate: '''
            <div class="ui-grid-cell-contents ng-binding ng-scope">
                <a nb-panel
                    template-url="partials/personnel/info_basic.html"
                    locals="{employee: row.entity.receptor}">
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

defaultUserCol = [
    {displayName: '员工编号', name: 'employeeNo'}
    {
        displayName: '姓名'
        field: 'name'
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
        name: 'department.name'
        cellTooltip: (row) ->
            return row.entity.department.name
    }

    {
        displayName: '岗位'
        name: 'position.name'
        cellTooltip: (row) ->
            return row.entity.position.name
    }
]


app.factory 'GridHelper', ->

    buildDefaultFlowGridOptions = (columnDef) ->
        defaultColClone = _.cloneDeep(defaultFlowCol)
        newCols = if columnDef then defaultColClone.concat columnDef else defaultColClone
        return newCols

    buildUserGridOptions = (columnDef)->
        defaultColClone = _.cloneDeep(defaultUserCol)
        newCols = if columnDef then defaultColClone.concat columnDef else defaultColClone
        return newCols


    return {
        buildDefault: buildDefaultFlowGridOptions
        buildFlowDefault: buildDefaultFlowGridOptions
        buildUserDefault: buildUserGridOptions
    }

