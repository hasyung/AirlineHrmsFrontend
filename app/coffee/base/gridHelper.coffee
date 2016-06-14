# 表格的工具类， 将重复的表格列抽取出来

app = @nb.app


defaultFlowCol =    [
        {minWidth: 120, displayName: '员工编号', name: 'receptor.employeeNo'}
        {
            minWidth: 120
            displayName: '姓名'
            field: 'receptor.name'
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
            minWidth: 350
            displayName: '所属部门'
            name: 'receptor.departmentName'
            cellTooltip: (row) ->
                return row.entity.departmentName
        }
        {
            minWidth: 250
            displayName: '岗位'
            name: 'receptor.positionName'
            cellTooltip: (row) ->
                return row.entity.positionName
        }
    ]


defaultUserCol = [
    {minWidth: 120, displayName: '员工编号', name: 'employeeNo', enableCellEdit: false}
    {
        minWidth: 120
        displayName: '姓名'
        field: 'name'
        cellTemplate: '''
        <div class="ui-grid-cell-contents ng-binding ng-scope">
            <a nb-panel
                template-url="partials/personnel/info_basic.html"
                locals="{employee: row.entity}">
                {{grid.getCellValue(row, col)}}
            </a>
        </div>
        '''
        enableCellEdit: false
    }
    {
        minWidth: 350
        displayName: '所属部门'
        name: 'department.name'
        cellTooltip: (row) ->
            return row.entity.department.name
        enableCellEdit: false
    }
    {
        minWidth: 250
        displayName: '岗位'
        name: 'position.name'
        cellTooltip: (row) ->
            return row.entity.position.name
        enableCellEdit: false
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