nb = @nb
app = nb.app

# 过滤器
class NbFilterCtrl extends nb.FilterController
    #@desc 预编译模板
    #@param constraint definition

    preCompileTemplate = (def)->
        type = def.type || 'string'

        if !filter_template_definition[type]
            throw "filter template type: #{type} is not implemented"
        else
            template = filter_template_definition[type]

        compiled = _.template(template)

        return compiled(def)

    filter_template_definition =
        'string': '''
            <md-input-container md-no-float>
                <input type="text" placeholder="${ displayName }" ng-model="${ name }">
            </md-input-container>
        '''
        'date-range': '''
            <div class="md-input-container-row">
                <md-input-container md-no-float>
                    <input type="text" placeholder="起始时间" bs-datepicker container="body" ng-model="${name}.from">
                </md-input-container>
                <div class="divide-text">到</div>
                <md-input-container md-no-float>
                    <input type="text" placeholder="结束时间" bs-datepicker container="body" ng-model="${name}.to">
                </md-input-container>
            </div>
        '''
        'month-range': '''
            <div class="md-input-container-row">
                <md-input-container md-no-float>
                    <md-select placeholder="${ displayName }" ng-model="${ name }.from">
                        <md-option ng-value="item" ng-repeat="item in $parent.month_list">{{item}}</md-option>
                    </md-select>
                </md-input-container>
                <div class="divide-text">到</div>
                <md-input-container md-no-float>
                    <md-select placeholder="${ displayName }" ng-model="${ name }.to">
                        <md-option ng-value="item" ng-repeat="item in $parent.month_list">{{item}}</md-option>
                    </md-select>
                </md-input-container>
            </div>
        '''
        'month-list': '''
                <md-input-container md-no-float>
                    <md-select placeholder="年份月份" ng-model="${ name }">
                        <md-option ng-value="item" ng-repeat="item in $parent.month_list">{{item}}</md-option>
                    </md-select>
                </md-input-container>
            </div>
        '''
        'year-list': '''
                <md-input-container md-no-float>
                    <md-select placeholder="年份" ng-model="${ name }">
                        <md-option ng-value="item" ng-repeat="item in $parent.year_list">{{item}}</md-option>
                    </md-select>
                </md-input-container>
            </div>
        '''
        'date': '''
            <md-input-container md-no-float>
                <input type="text" placeholder="${ displayName }" bs-datepicker container="body" ng-model="${name}">
            </md-input-container>
        '''
        'select': '''
            <md-select placeholder="${ displayName }" ng-model="${ name }">
                <md-option ng-value="item.id" ng-repeat="item in $parent.$enum.get('${ params.type }')">{{item.label}}</md-option>
            </md-select>
        '''
        'perf_category_select': '''
            <md-select placeholder="${ displayName }" ng-model="${ name }">
                <md-option value="员工" placeholder="人员分类">员工</md-option>
                <md-option value="基层干部" placeholder="人员分类">基层干部</md-option>
                <md-option value="中层干部" placeholder="人员分类">中层干部</md-option>
                <md-option value="主官" placeholder="人员分类">主官</md-option>
            </md-select>
        '''
        'performance_select': '''
            <md-select placeholder="${ displayName }" ng-model="${ name }">
                <md-option value="优秀" placeholder="绩效结果">优秀</md-option>
                <md-option value="良好" placeholder="绩效结果">良好</md-option>
                <md-option value="合格" placeholder="绩效结果">合格</md-option>
                <md-option value="待改进" placeholder="绩效结果">待改进</md-option>
                <md-option value="不合格" placeholder="绩效结果">不合格</md-option>
            </md-select>
        '''
        'salary_change_category_select': '''
            <md-select placeholder="${ displayName }" ng-model="${ name }">
                <md-option value="合同新签" placeholder="信息种类">合同新签</md-option>
                <md-option value="岗位变动" placeholder="信息种类">岗位变动</md-option>
                <md-option value="停薪调" placeholder="信息种类">停薪调</md-option>
                <md-option value="停薪调停止" placeholder="信息种类">停薪调停止</md-option>
            </md-select>
        '''
        'season-list': '''
                <md-input-container md-no-float>
                    <md-select placeholder="季度" ng-model="${ name }">
                        <md-option ng-value="item" ng-repeat="item in $parent.season_list">{{item}}</md-option>
                    </md-select>
                </md-input-container>
            </div>
        '''
        'annuity_status_select': '''
            <md-select placeholder="${ displayName }" ng-model="${ name }">
                <md-option ng-value="true" placeholder="缴费状态">在缴</md-option>
                <md-option ng-value="false" placeholder="缴费状态">退出</md-option>
            </md-select>
        '''
        'workflow_status_select': '''
            <md-select placeholder="${ displayName }" ng-model="${ name }">
                <md-option ng-value="'rejected'" placeholder="状态">已驳回</md-option>
                <md-option ng-value="'checking'" placeholder="状态">审批中</md-option>
                <md-option ng-value="'accepted'" placeholder="状态">已通过</md-option>
                <md-option ng-value="'actived'" placeholder="状态">已生效</md-option>
                <md-option ng-value="'repeal'" placeholder="状态">已撤销</md-option>
            </md-select>
        '''
        'apply_type_select':'''
            <md-select placeholder="${ displayName }" ng-model="${ name }">
                <md-option ng-value="'合同'" placeholder="用工性质">合同</md-option>
                <md-option ng-value="'合同制'" placeholder="用工性质">合同制</md-option>
            </md-select>
        '''
        'leave_job_state_select':'''
            <md-select placeholder="${ displayName }" ng-model="${ name }">
                <md-option ng-value="true" placeholder="离职发起">已发起</md-option>
                <md-option ng-value="false" placeholder="离职发起">未发起</md-option>
            </md-select>
        '''
        'allege_result_select':'''
            <md-select placeholder="${ displayName }" ng-model="${ name }">
                <md-option ng-value="true" placeholder="申诉结果">已处理</md-option>
                <md-option ng-value="false" placeholder="申诉结果">未处理</md-option>
            </md-select>
        '''
        'budget_staffing_select':'''
            <md-select placeholder="${ displayName }" ng-model="${ name }">
                <md-option value="1" placeholder="编制状态">超编</md-option>
                <md-option value="-1" placeholder="编制状态">缺编</md-option>
                <md-option value="0" placeholder="编制状态">正常</md-option>
            </md-select>
        '''
        'boolean': '''
            <md-select placeholder="${ displayName }" ng-model="${ name }">
                <md-option value="true" selected)">是</md-option>
                <md-option value="false")">否</md-option>
            </md-select>
        '''
        'org-search': '''
            <org-search multiple ng-model="${ name }"></org-search>
        '''
        'muti-enum-search': '''
            <muti-enum-search ng-model="${ name }" enum-key="${params.type}"></muti-enum-search>
        '''
        'string_array': '''
            <md-chips ng-init="${ name } = ${ name }? ${ name }: []" ng-model="${ name }">
                <md-chip-template>
                    <span ng-bind="$chip"></span>
                </md-chip-template>
            </md-chips>
        '''

    @.$inject = ['$scope', '$element', '$attrs', '$parse', '$compile', 'SerializedFilter', '$http','$nbEvent']

    constructor: (scope, elem, attrs, $parse, @compile, SerializedFilter, @http, @Evt) ->
        options = scope.nbFilter
        @conditionCode = options.name
        defs = options.constraintDefs

        @filters = SerializedFilter.$search({code: @conditionCode})

        constraints = defs.reduce((res, val, index) ->
            propertyGetter = $parse(val.name)
            template = preCompileTemplate(val)

            constraint = {
                propertyGetter: propertyGetter
                template: template
                displayName: val.displayName
                active: false
                name: val.name
            }

            Object.defineProperties constraint, {
                destroy: {
                    enumerable: false
                    value: () ->
                        if this.block
                            block = this.block
                            block.scope.$destroy()
                            block.element.remove()
                            block = null
                            delete this.block
                        this.active = false
                }
                startup: {
                    enumerable: false
                    value: () ->
                        this.active = true
                }
                exportData: {
                    enumerable: false
                    value: () ->
                        getter = this.propertyGetter
                        scope = this.block.scope
                        return getter(scope)
                }
            }

            res.push constraint
            return res
        ,[])

        @constraints = constraints
        @conditions = []

    initialize: ->
        first = @constraints[0]
        first.startup()
        @conditions.push({selectedConstraint: first})

    inertConstraints: ->
        @constraints.filter (cons) -> cons.active == false

    activeConstraints: ->
        @constraints.filter (cons) -> cons.active == true

    removeCondition: (condition) ->
        return if @conditions.length == 1
        #先销毁constraint, 因为缓存了element, scope
        constraint = condition.selectedConstraint
        constraint.destroy()

        conditionIndex = @conditions.indexOf(condition)
        @conditions.splice(conditionIndex, 1)

    addNewCondition: (constraint, initialValue) ->
        return if !constraint
        constraint.startup()

        condition = {
            selectedConstraint: constraint
        }

        condition.initialValue = initialValue if initialValue
        @conditions.push(condition)

    initialCondition: (currentConstraint, parentScope, parentElem, initialValue) ->
        scope = parentScope.$new()
        scope[currentConstraint.name] = initialValue if initialValue

        $el = @compile(currentConstraint.template) scope, (cloned, scope) ->
            parentElem.append(cloned)


        currentConstraint.block = {
            scope: scope
            element: $el
        }

    exportQueryParams: () ->
        @activeConstraints().reduce((res, single) ->
            res[single.name] = single.exportData()
            return res
        , {})

    switchCondition: (newValue, old, parentScope, parentElem) ->
        old.destroy()
        newValue.startup()
        @initialCondition(newValue, parentScope, parentElem)

    saveFilter: (filterName) ->
        request_data = {
            name: filterName
            code: @conditionCode
            condition: JSON.stringify(@exportQueryParams())
        }

        promise = @filters.$create(request_data)

    removeFilter: (filterId, $event) ->
        self = @
        $event.stopPropagation()

        @http.delete('/api/search_conditions/'+filterId)
                .success (result) ->
                    self.filters.$refresh()


    restoreFilter: (queryParams) ->
        @.$clearAllCondition()
        self = @
        @constraints.forEach (constraint) ->
            initialValue = queryParams[constraint.name]
            self.addNewCondition(constraint, initialValue) if initialValue

    $clearAllCondition: () ->
        @activeConstraints().forEach (cstris) -> cstris.destroy()
        @conditions.splice(0, @conditions.length)


conditionInputContainer = ($enum) ->
    postLink = (scope, elem, attr, ctrl) ->
        scope.$enum = $enum
        date = new Date()

        year_list = [2015..date.getFullYear()]
        month_list = []
        season_list = []

        angular.forEach year_list, (year) ->
            months = [1..12]
            months = [1..date.getMonth() + 1] if year = date.getFullYear()

            angular.forEach months, (month)->
                month = "0" + month if month < 10
                month_list.push(year + "-" + month)

            angular.forEach [1,2,3,4], (quarter)->
                season_list.push(year + '-' + quarter)

        scope.year_list = year_list
        scope.month_list = month_list
        scope.season_list = season_list

        ctrl.initialCondition(scope.condition.selectedConstraint, scope, elem, scope.condition.initialValue)
        scope.$watch 'condition.selectedConstraint', (newValue, old) ->
            #FIX 因为material没有发布正式版本，不太清楚md-select的dom是否还会修改
            #暂时HACK了md-select内部的dom节点
            elem.prev().children().first().html(scope.condition.selectedConstraint.displayName)
            ctrl.switchCondition(newValue, old, scope, elem) if newValue != old && !newValue.block

    return {
        require: '^nbFilter'
        link: postLink
    }


NbFilterDirective = ["$nbEvent", "$enum", ($Evt, $enum)->
    template = '''
        <md-content class="search-container">
            <md-toolbar>
                <div class="md-toolbar-tools">
                    <h2>筛选条件</h2>
                    <div flex></div>
                    <md-button class="md-primary md-raised" nb-dialog template-url="partials/component/table/save_filter_dialog.html">保存</md-button>
                    <md-select ng-model="filter.serializedFilter"
                    ng-if="filter.filters.length"
                    ng-change="filter.restoreFilter(filter.serializedFilter.parse());search(filter.serializedFilter.parse())" placeholder="请选择筛选条件">
                        <md-option ng-value="f" ng-repeat="f in filter.filters">
                            {{f.name}}
                            <md-icon style="position: absolute; right: 10px;" ng-click="filter.removeFilter(f.id, $event)" md-svg-icon="../../images/svg/close.svg"></md-icon>
                        </md-option>
                    </md-select>
                </div>
            </md-toolbar>

            <form ng-submit="search(filter.exportQueryParams())">
                <div ng-form="conditionForm" class="search-row" ng-repeat="condition in filter.conditions">
                    <md-button type="button" class="md-icon-button" ng-click="filter.removeCondition(condition)" ng-disabled="filter.conditions.length <= 1">
                        <md-icon md-svg-icon="../../images/svg/close.svg"></md-icon>
                    </md-button>
                    <!-- Error: [ng:cpws] Can't copy! Making copies of Window or Scope instances is not supported. -->
                    <md-select ng-model="condition.selectedConstraint">
                        <md-option ng-value="inert_cons" ng-repeat="inert_cons in filter.inertConstraints() track by inert_cons.name">
                            {{inert_cons.displayName}}
                        </md-option>
                    </md-select>
                    <condition-input-container></condition-input-container>
                    <md-button type="button" class="md-icon-button"
                        ng-show="$last && filter.inertConstraints().length > 0"
                        ng-click="filter.addNewCondition(filter.inertConstraints()[0])">
                        <md-icon md-svg-icon="../../images/svg/plus.svg"></md-icon>
                    </md-button>
                </div>
                <div class="search-footer">
                    <md-button class="md-primary md-raised" type="submit">搜索</md-button>
                </div>
            </form>
        </md-content>
    '''

    postLink = (scope, elem, attr, ctrl) ->
        ctrl.initialize()

        scope.search = (queryParams)->
            invalid = []

            angular.forEach queryParams, (item, key) ->
                if item && item["from"] && item["to"]
                    if new Date(item["to"]) < new Date(item["from"])
                        condition_valid = false
                        condition = _.find scope.filter.conditions, (item) ->
                            item.selectedConstraint.name == key
                        invalid.push condition.selectedConstraint["displayName"] + "的结束时间必须大于开始时间"

            if invalid.length > 0
                scope.filter.onConditionInValid($Evt, invalid) if scope.filter.onConditionInValid
            else
                scope.onSearch({state: queryParams})

    return {
        scope: {
            nbFilter: '='
            onSearch: '&'
        }

        link: postLink
        template: template
        controller: NbFilterCtrl
        controllerAs: 'filter'
    }]


GridPaginationTemplate = """
        <div ui-grid="gridOptions"></div>
    """

'''
    <div nb-grid column-def="columnsDefs">
    </div>
'''


nbGridDirective = ($parse)->
    postLink = (scope, elem, attrs) ->
        columnDefs = scope.columnDefs
        safeSrc = scope.safeSrc
        pageGetter = $parse('safeSrc.$metadata.page')
        itemCountGetter = $parse('safeSrc.$metadata.count')
        exportApi = angular.isDefined(attrs.exportApi) #gridApi export to appScope
        multiSelect = if attrs.multiSelect then scope.$eval(attrs.multiSelect) else true
        enableRowSelection = angular.isDefined(attrs.gridSelection)

        defaultOptions = {
            # flatEntityAccess: true
            enableSorting: false
            # useExternalSorting: false
            useExternalPagination: true
            enableRowSelection: enableRowSelection
            enableSelectAll: multiSelect
            selectionRowHeaderWidth: 35
            rowHeight: 50
            enableColumnMenus: false
            multiSelect: multiSelect
            paginationCurrentPage: 1
            paginationPageSizes: [2, 20, 40, 60, 80, 100]
            paginationPageSize: 60

            onRegisterApi: (gridApi) ->
                #WARN 必须保持 grid 生命周期与 controller 一致，暂不支持动态生成表格, 不然会内存泄露

                # DEPRECATED
                gridApi.grid.appScope.$parent.$gridApi = gridApi if exportApi

                #recommended alpha
                scope.onRegisterApi({gridApi: gridApi})

                gridApi.pagination.on.paginationChanged scope, (newPage, pageSize) ->
                    currentQueryParams = safeSrc.$queryParams || {}

                    queryParams = angular.extend {}, currentQueryParams, {
                        page: newPage
                        per_page: pageSize
                    }

                    safeSrc.$refresh(queryParams)

            excludeProperties: [
                '$$dsp'
                '$pk'
                '$cmStatus'
                '$position'
                '$resolved'
                '$super'
                '$$hashKey'
                '$scope'
                '$queryParams'
            ]
        }

        options = angular.extend {
            columnDefs: columnDefs
            data: safeSrc
        }, defaultOptions

        scope.gridOptions = options

        scope.$watch(
            -> itemCountGetter(scope),
            (newValue) -> options.totalItems = newValue if angular.isNumber(newValue)
        )

        scope.$watch(
            -> pageGetter(scope),
            (newValue) -> options.paginationCurrentPage = newValue if angular.isNumber(newValue)
        )

        # scope.$watch('gridOptions.paginationPageSize') #watch 每页数据

    #WORKAROUND, issue#27, 当ui-grid-selection 存在时, resize 会存在使 table 错位的BUG
    #暂时使用 ui-grid-auto-resize 插件每250ms定时resize, 修复改BUG, 如果有性能问题, 再修复
    nbGridTemplate =  '''
        <div ui-grid="gridOptions" #plugins# ui-grid-pagination ui-grid-auto-resize></div>
    '''

    return {
        link: {
            pre: postLink
        }

        template: (elem, attrs) ->
            PLUGIN_PREFIX = 'ui-'

            plugins = [
                'ui-grid-pinning'
                'ui-grid-selection'
                'ui-grid-edit'
                'ui-grid-row-edit'
                'ui-grid-cellNav'
            ]

            applied_plugins = plugins.reduce((res, val) ->
                removedPrefix = val.replace(PLUGIN_PREFIX, '')
                camelCased = _.camelCase(removedPrefix)
                res.push(val) if angular.isDefined(attrs[camelCased])
                return res
            ,[])

            nbGridTemplate.replace("#plugins#", applied_plugins.join(" "))

        scope: {
            columnDefs: '='
            safeSrc: '='
            onRegisterApi: '&'
        }
    }


BooleanTableCell = ->
    template = '''
        <div class="ui-grid-cell-contents">
            <span ng-class="{'valid-mark':grid.getCellValue(row, col), 'invalid-mark': !grid.getCellValue(row, col) }"></span>
        </div>
    '''

    return {
        template: template
        replace: true
    }


app.directive 'nbGrid', nbGridDirective
app.directive 'booleanTableCell', BooleanTableCell
app.directive 'nbFilter', NbFilterDirective
app.directive 'conditionInputContainer', conditionInputContainer