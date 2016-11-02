# 绩效
nb = @.nb
app = nb.app
filterBuildUtils = nb.filterBuildUtils


getBaseFilterOptions = (fliterName)->
    filterBuildUtils(fliterName)
        .col 'name',                 '姓名',    'string',           '姓名'
        .col 'employee_no',          '员工编号', 'string'
        .col 'department_ids',       '机构',    'org-search'
        .end()


BASE_TABLE_DEFS = [
    {displayName: '员工编号', name: 'employeeNo', minWidth: 120}
    {
        minWidth: 120
        displayName: '姓名'
        field: 'employeeName'
        cellTemplate: '''
        <div class="ui-grid-cell-contents">
            <a nb-panel
                template-url="partials/personnel/info_basic.html"
                locals="{employee: row.entity.owner}">
                {{grid.getCellValue(row, col)}}
            </a>
        </div>
        '''
    }
    {
        minWidth: 350
        displayName: '所属部门'
        name: 'departmentName'
        cellTooltip: (row) ->
            return row.entity.departmentName
    }
    {
        minWidth: 250
        displayName: '岗位'
        name: 'positionName'
        cellTooltip: (row) ->
            return row.entity.positionName
    }
    {displayName: '通道', name: 'channel', minWidth: 120}
]


class Route
    @.$inject = ['$stateProvider', '$urlRouterProvider', '$injector']

    constructor: (stateProvider, urlRouterProvider, injector) ->
        stateProvider
            .state 'performance_list', {
                url: '/performance_list'
                templateUrl: 'partials/performance/record/index.html'

            }
            .state 'performance_alleges', {
                url: '/performance_alleges'
                templateUrl: 'partials/performance/allege/index.html'
                controller: PerformanceAllege
                controllerAs: 'ctrl'

            }
            .state 'performance_setting', {
                url: '/performance_setting'
                templateUrl: 'partials/performance/setting/index.html'
                controller: PerformanceSetting
                controllerAs: 'ctrl'
            }


class PerformanceRecord extends nb.Controller
    @.$inject = ['$scope', 'Performance', '$http', 'USER_META', '$nbEvent', 'toaster', '$rootScope']

    constructor: (@scope, @Performance, @http, @USER_META, @Evt, @toaster, @rootScope)->
        @importing = false
        @tableState = null
        @filter_month_list = @$getFilterMonths()

        @filterOptions = getBaseFilterOptions('performance_record')
        @filterOptions.constraintDefs = @filterOptions.constraintDefs.concat [
            {
                displayName: '绩效人员分类'
                name: 'employee_category'
                placeholder: '绩效人员分类'
                type: 'perf_category_select'
            }
        ]

        @columnDef = BASE_TABLE_DEFS.concat [
            {displayName: '1月', name: 'january', minWidth: 120}
            {displayName: '2月', name: 'february', minWidth: 120}
            {displayName: '3月', name: 'march', minWidth: 120}
            {displayName: '4月', name: 'april', minWidth: 120}
            {displayName: '5月', name: 'may', minWidth: 120}
            {displayName: '6月', name: 'june', minWidth: 120}
            {displayName: '7月', name: 'july', minWidth: 120}
            {displayName: '8月', name: 'august', minWidth: 120}
            {displayName: '9月', name: 'september', minWidth: 120}
            {displayName: '10月', name: 'october', minWidth: 120}
            {displayName: '11月', name: 'november', minWidth: 120}
            {displayName: '12月', name: 'december', minWidth: 120}
            {displayName: '季度绩效', name: 'season', minWidth: 120}
            {displayName: '年度绩效', name: 'year', minWidth: 120}
            {displayName: '排序', name: 'sortNo', minWidth: 120}
            {
                minWidth: 120
                displayName: '附件',
                field: '查看',
                cellTemplate: '''
                    <div class="ui-grid-cell-contents" ng-init="outerScope=grid.appScope.$parent">
                        <a ng-if="row.entity.attachmentStatus"
                            nb-dialog
                            locals="{performance: row.entity, can_upload: false, outerScope: outerScope, can_del: false}"
                            template-url="/partials/performance/record/add_attachment.html"
                        > 查看
                        </a>
                    </div>
                '''
            }
        ]

        @loadYearList()
        #PRD要求初始化表体为空
        @performances = @Performance.$collection().$fetch({employee_category: 'NULL'})

    loadYearList: () ->
        @year_list = @$getYears()
        @currentYear = _.last @year_list

    exportGridApi: (gridApi) ->
        @gridApi = gridApi

    search: (tableState)->
        tableState = tableState || @tableState || {}
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        tableState['year'] = @currentYear
        @performances.$refresh(tableState)
        @tableState = tableState

    isImgObj: (obj)->
        return /jpg|jpeg|png|gif/.test(obj.type)

    attachmentDestroy: (attachment) ->
        self = @

        attachment.$destroy().$asPromise().then (data)->
            self.performances.$refresh()

    getSelected: () ->
        if @gridApi && @gridApi.selection
            rows = @gridApi.selection.getSelectedGridRows()
            selected = if rows.length >= 1 then rows[0].entity else null

    getDateOptions: (type)->
        date = new Date()
        year = date.getFullYear()
        month = date.getMonth()

        return [year-1, year] if type == "year"

        formatOption = (year, month)->
            temp = []
            temp.push("#{year}-#{item}") for item in [1..month]
            return temp
        dateOptions = [].concat formatOption(year-1, 12), formatOption(year, month+1)

    uploadPerformance: (request, params)->
        self = @

        # 年度的时候 assessTime 是整数
        request.assess_time = moment(new Date(new String(request.assessTime))).format "YYYY-MM-DD"
        params.status = "uploading"

        @http.post("/api/performances/import_performances", request).success (response)->
            self.scope.resRecord = response.messages
            params.status = "finish"
        .error ()->

    uploadAttachments: (performance, collection, $messages)->
        self = @

        data = JSON.parse($messages)

        hash = {
            id: data.id
            name: data.file_name
            type: data.file_type
            size: data.file_size
            performance_id: performance.id
        }

        performance.attachmentStatus = true
        collection.$create(hash).$asPromise().then (data)->
            collection.$refresh()
            self.performances.$refresh()

    # 安排离岗培训
    newTrainEmployee: (moveEmployee, dialog)->
        self = @

        if moveEmployee.special_date_from && moveEmployee.special_date_to
            start = moment(moveEmployee.special_date_from)
            end = moment(moveEmployee.special_date_to)

            if start < end
                @http.post('/api/special_states/temporarily_train', moveEmployee).then (data)->
                    self.Evt.$send("moveEmployee:save:success", '离岗培训设置成功')
                    dialog.close()
            else
                self.toaster.pop('error', '提示', '日期填写不正确，开始日期不能大于结束日期')

    uploadPerformances: (type, attachment_id) ->
        self = @
        params = {type: type, attachment_id: attachment_id}
        @importing = true

        @http.post("/api/performances/import_performance_collect", params).success (data, status) ->
            self.toaster.pop('success', '提示', '导入成功')
            self.performances.$refresh()
            self.importing = false
            self.cancelLoading()
        .error (data) ->
            self.importing = false
            self.cancelLoading()


class PerformanceMasterRecord extends nb.Controller
    @.$inject = ['$scope', 'Performance', '$http', 'USER_META', '$nbEvent', '$q', 'toaster']

    constructor: (@scope, @Performance, @http, @USER_META, @Evt, @q, @toaster)->
        @year_list = @$getYears()
        @filter_month_list = @$getFilterMonths()

        @filterOptions = getBaseFilterOptions('performance_record')
        @filterOptions.constraintDefs = @filterOptions.constraintDefs.concat [
            {
                displayName: '绩效'
                name: 'result'
                placeholder: '绩效'
                type: 'performance_select'
            }
        ]

        @columnDef = BASE_TABLE_DEFS.concat [
            {displayName: '绩效类型', name: 'categoryName'}
            {displayName: '考核时段', name: 'assessTime'}
            {
                displayName: '绩效'
                name: 'result'
            }
            {displayName: '排序', name: 'sortNo'}
            {
                displayName: '附件',
                field: '查看',
                cellTemplate: '''
                    <div class="ui-grid-cell-contents" ng-init="outerScope=grid.appScope.$parent">
                        <a ng-if="row.entity.attachmentStatus"
                            nb-dialog
                            locals="{performance: row.entity, can_upload: false, outerScope: outerScope, can_del: false}"
                            template-url="/partials/performance/record/add_attachment.html"
                        > 查看
                        </a>
                    </div>
                '''
            }
        ]


        angular.forEach @columnDef, (item)->
            if item['name'] == 'sortNo'
                item['headerCellClass'] = 'editable_cell_header'
                item['enableCellEdit'] = true
            else if item['name'] == 'result'
                item['enableCellEdit'] = true
                item['editableCellTemplate'] = 'ui-grid/dropdownEditor'
                item['headerCellClass'] = 'editable_cell_header'
                item['editDropdownValueLabel'] = 'value'
                item['editDropdownIdLabel'] = 'key'
                item['editDropdownOptionsArray'] = [
                    {key: '无', value: '无'}
                    {key: '优秀', value: '优秀'}
                    {key: '良好', value: '良好'}
                    {key: '合格', value: '合格'}
                    {key: '待改进', value: '待改进'}
                    {key: '不合格', value: '不合格'}
                ]
            else
                item['enableCellEdit'] = false

        @performances = @Performance.$collection({employee_category: '主官'}).$fetch()

    initialize: (gridApi) ->
        self = @

        saveRow = (rowEntity) ->
            dfd = @q.defer()

            gridApi.rowEdit.setSavePromise(rowEntity, dfd.promise)

            @http({
                method: 'PUT'
                url: '/api/performances/' + rowEntity.id
                data: {
                    sort_no: rowEntity.sortNo
                }
            })
            .success (data) ->
                dfd.resolve()
                self.toaster.pop('success', '提示', '修改成功')
            .error () ->
                dfd.reject()
                rowEntity.$restore()

        # edit.on.afterCellEdit($scope,function(rowEntity, colDef, newValue, oldValue)
        # gridApi.edit.on.afterCellEdit @scope, (rowEntity, colDef, newValue, oldValue) ->

        gridApi.rowEdit.on.saveRow(@scope, saveRow.bind(@))
        @scope.$gridApi = gridApi


    search: (tableState)->
        tableState = tableState || {}
        tableState['per_page'] = @scope.$gridApi.grid.options.paginationPageSize
        @performances.$refresh(tableState)

    isImgObj: (obj)->
        return /jpg|jpeg|png|gif/.test(obj.type)

    getSelected: () ->
        if @scope.$gridApi && @scope.$gridApi.selection
            rows = @scope.$gridApi.selection.getSelectedGridRows()
            selected = if rows.length >= 1 then rows[0].entity else null

    uploadAttachments: (performance, collection, $messages)->
        self = @

        data = JSON.parse($messages)

        hash = {
            id: data.id
            name: data.file_name
            type: data.file_type
            size: data.file_size
            performance_id: performance.id
        }

        performance.attachmentStatus = true
        collection.$create(hash).$asPromise().then (data)->
            collection.$refresh()
            self.performances.$refresh()

    attachmentDestroy: (attachment) ->
        self = @

        attachment.$destroy()
        @performances.$refresh()


class PerformanceSetting extends nb.Controller
    @.$inject = ['$scope', 'PerformanceTemp', '$http', '$q']

    constructor: (@scope, @PerformanceTemp, @http, @q)->
        @filterOptions = getBaseFilterOptions('performance_setting')

        @filterOptions.constraintDefs = @filterOptions.constraintDefs.concat [
            {
                displayName: '绩效人员分类'
                name: 'employee_category'
                type: 'perf_category_select'
            }
        ]


        @columnDef = [
            {displayName: '员工编号', name: 'employeeNo', enableCellEdit: false}
            {displayName: '姓名', name: 'name', enableCellEdit: false}
            {
                displayName: '所属部门'
                name: 'department.name'
                enableCellEdit: false
                cellTooltip: (row) ->
                    return row.entity.department.name
            }
            {
                displayName: '岗位'
                name: 'position.name'
                enableCellEdit: false
                cellTooltip: (row) ->
                    return row.entity.position.name
            }
            {displayName: '通道', name: 'channelId', cellFilter: "enum: 'channels'" , enableCellEdit: false}
            {displayName: '职务职级', name: 'dutyRankId', cellFilter: "enum: 'duty_ranks'", enableCellEdit: false}
            {displayName: '到岗时间', name: 'joinScalDate', enableCellEdit: false}
            {
                displayName: '月度分配基数'
                name: 'monthDistributeBase'
                headerCellClass: 'editable_cell_header'
                type: 'number'
            }
            {
                displayName: '考核人员分类'
                name: 'pcategory'
                headerCellClass: 'editable_cell_header'
                editableCellTemplate: 'ui-grid/dropdownEditor'
                editDropdownValueLabel: 'value'
                editDropdownIdLabel: 'key'
                editDropdownOptionsArray: [
                    {key: '员工', value: '员工'}
                    {key: '基层干部', value: '基层干部'}
                    {key: '中层干部', value: '中层干部'}
                    {key: '高层干部', value: '高层干部'}
                    {key: '主官', value: '主官'}
                ]
            }
        ]

        @performanceTemps = @PerformanceTemp.$collection().$fetch()

    initialize: (gridApi) ->
        self = @

        saveRow = (rowEntity) ->
            dfd = @q.defer()

            gridApi.rowEdit.setSavePromise(rowEntity, dfd.promise)

            @http({
                method: 'POST'
                url: '/api/performances/update_temp'
                data: {
                    id: rowEntity.id
                    month_distribute_base: rowEntity.monthDistributeBase
                    pcategory: rowEntity.pcategory
                }
            })
            .success () ->
                dfd.resolve()
                self.toaster.pop('success', '提示', '修改成功')
            .error () ->
                dfd.reject()
                rowEntity.$restore()

        # edit.on.afterCellEdit($scope,function(rowEntity, colDef, newValue, oldValue)
        # gridApi.edit.on.afterCellEdit @scope, (rowEntity, colDef, newValue, oldValue) ->

        gridApi.rowEdit.on.saveRow(@scope, saveRow.bind(@))
        @scope.$gridApi = gridApi

    search: (tableState)->
        tableState = tableState || {}
        tableState['per_page'] = @scope.$gridApi.grid.options.paginationPageSize
        @performanceTemps.$refresh(tableState)

    getSelected: () ->
        rows = @scope.$gridApi.selection.getSelectedGridRows()
        selected = if rows.length >= 1 then rows[0].entity else null

    isImgObj: (obj)->
        return /jpg|jpeg|png|gif/.test(obj.type)

class PerformanceAllege extends nb.Controller
    @.$inject = ['$scope', 'Allege', 'Performance', 'Employee']

    constructor: (@scope, @Allege, @Performance, @Employee)->
        @filterOptions = getBaseFilterOptions('performance_allege')

        @filterOptions.constraintDefs = @filterOptions.constraintDefs.concat [
            {
                displayName: '绩效'
                name: 'result'
                placeholder: '绩效'
                type: 'performance_select'
            }
            {
                displayName: '申诉时间'
                name: 'created_at'
                placeholder: '申诉时间'
                type: 'date-range'
            }
            {
                displayName: '申诉结果'
                name: 'is_managed'
                placeholder: '申诉结果'
                type: 'allege_result_select'
            }
        ]

        @columnDef = BASE_TABLE_DEFS.concat [
            {displayName: '绩效类型', name: 'categoryName'}
            {displayName: '考核时段', name: 'assessTime'}
            {displayName: '绩效', name: 'result'}
            {displayName: '申诉时间', name: 'createdAt',cellFilter: "date:'yyyy-MM-dd'"}
            {displayName: '申诉结果', name: 'outcome'}
            {
                displayName: '处理',
                field: '查看',
                cellTemplate: '''
                    <div class="ui-grid-cell-contents ng-binding ng-scope" ng-init="outerScope = grid.appScope.$parent">
                        <a
                            nb-panel
                            template-url="/partials/performance/allege/allege.html"
                            locals="{allege: row.entity, Performance: outerScope.ctrl.Performance, employee:row.entity.owner, outerScope: outerScope}"
                        > 查看
                        </a>
                    </div>
                '''
            }
        ]

        @alleges = @Allege.$collection().$fetch()

    isImgObj: (obj)->
        return /jpg|jpeg|png|gif/.test(obj.type)

    search: (tableState)->
        tableState = tableState || {}
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        @alleges.$refresh(tableState)

    getSelected: () ->
        rows = @scope.$gridApi.selection.getSelectedGridRows()
        selected = if rows.length >= 1 then rows[0].entity else null


app.config(Route)


app.controller 'PerformanceRecord', PerformanceRecord
app.controller 'PerformanceMasterRecord', PerformanceMasterRecord