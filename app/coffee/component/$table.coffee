
nb = @nb
app = nb.app


# [{
#     displayName: '姓名'
#     name: 'name'
#     placeholder: '姓名'
#     type: 'string'
# }]

# preCompile = ->



# string_template =

# type: ['date-range', 'string', 'number', 'date']


# createFilter(defs) ->
#     active_constraint = []
#     inert_constraint = []

#     getter = $parse(opt.name)

#     Elem = $compile(template)(scope.$new())

#     destroyBefore = ->
#         scope.$destroy()
#         elem.remove()
#         elem = null


#     defs.forEach (def, idx) ->
#         constraint = {}
#         propertyGetter = $parse(val.name)
#         template = preCompileTemplate(def)




class NbFilterCtrl

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
        'date': '''
            <md-input-container md-no-float>
                <input type="text" placeholder="${ displayName }" bs-datepicker container="body" ng-model="${name}">
            </md-input-container>
        '''
        'select': '''
            <md-select placeholder="${ displayName }" ng-model="${ name }">
                <md-select-label>{{ ${ name } ? $parent.$enum.parseLabel(${name}, '${params.type}') : '无' }}</md-select-label>
                <md-option ng-value="item.id" ng-repeat="item in $parent.$enum.get('${ params.type }')">{{item.label}}</md-option>
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


    @.$inject = ['$scope', '$element', '$attrs', '$parse', '$compile', 'SerializedFilter']
    constructor: (scope, elem, attrs, $parse, @compile, SerializedFilter) ->
        options = scope.nbFilter
        @conditionCode = options.name
        defs    = options.constraintDefs

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
        #先销毁constraint, 因为缓存了element , scope
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

        ctrl.initialCondition(scope.condition.selectedConstraint, scope, elem, scope.condition.initialValue)
        scope.$watch 'condition.selectedConstraint', (newValue, old) ->
            ctrl.switchCondition(newValue, old, scope, elem) if newValue != old && !newValue.block

    return {
        require: '^nbFilter'
        link: postLink
    }



NbFilterDirective = ()->

    template = '''
        <md-content class="search-container">
            <md-toolbar>
                <div class="md-toolbar-tools">
                    <h2>筛选条件</h2>
                    <div flex></div>
                    <md-button class="md-primary md-raised" nb-dialog template-url="partials/component/table/save_filter_dialog.html">保存</md-button>
                    <md-select ng-model="filter.serializedFilter"
                    ng-change="filter.restoreFilter(filter.serializedFilter.parse());search(filter.serializedFilter.parse())" placeholder="请选择筛选条件">
                        <md-option ng-value="f" ng-repeat="f in filter.filters">{{f.name}}</md-option>
                    </md-select>
                </div>
            </md-toolbar>

            <form ng-submit="search(filter.exportQueryParams())">
                <div ng-form="conditionForm" class="search-row" ng-repeat="condition in filter.conditions">
                    <md-button type="button" class="md-icon-button" ng-click="filter.removeCondition(condition)">
                        <md-icon md-svg-icon="../../images/svg/close.svg"></md-icon>
                    </md-button>
                    <md-select ng-model="condition.selectedConstraint">
                        <md-select-label>{{ condition.selectedConstraint.displayName }}</md-select-label>
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
    }


GridPaginationTemplate = """


        <div ui-grid="gridOptions"></div>


    """


'''

    <div nb-grid column-def="columnsDefs">

    </div>

'''





nbGridDirective = ($parse)->

    # defaultOptions = {
    #     enableSorting: false
    #     columnDefs: [
    #         {
    #             field: 'name'
    #             minWidth: 200
    #             width: 150 || '30%'
    #             enableColumnResizing: false
    #             cellFilter: 'mapGender '
    #             cellTooltip: (row, col) ->
    #                 return "Name: #{row.entity.name} Company: #{row.entity.company}"
    #                 return "FullOrgName:#{row.entity.fullName}" # 可行否？

    #         }
    #     ]
    #     data: data
    #     useExternalPagination: true
    #     useExternalSorting: false
    #     # paginationTemplate: ''' ''' #分页组件模板， 需要集成 ui-grid-paper
    #     # totalItems: xxx
    #     # paginationCurrentPage: xxx
    #     # paginationPageSizes: [25, 50, 75]
    #     # paginationPageSize: 25

    #     onRegisterApi: (gridApi) ->

    #         gridApi.core.on.paginationChanged $scope, (newPage, pageSize) ->

    #         gridApi.core.on.filterChanged $scope, () ->
    #             grid = this.grid
    #             if grid.columns[1].filters[0].term == 'maile'
    #                 $http.get('/xxx/data').then -> scope.gridOptions.data = data
    # }



    postLink = (scope, elem, attrs) ->
        columnDefs = scope.columnDefs
        safeSrc = scope.safeSrc
        pageGetter = $parse('safeSrc.$metadata.page')
        itemCountGetter = $parse('safeSrc.$metadata.count')
        exportApi = angular.isDefined(attrs.exportApi) #gridApi export to appScope

        defaultOptions = {
            # flatEntityAccess: true
            enableSorting: false
            # useExternalSorting: false
            useExternalPagination: true
            enableRowSelection: true
            enableSelectAll: true
            selectionRowHeaderWidth: 35
            rowHeight: 50
            enableColumnMenus: false

            # paginationTemplate: ''' ''' #分页组件模板， 需要集成 ui-grid-paper
            # totalItems: xxx
            paginationCurrentPage: 1
            paginationPageSizes: [20, 40, 60, 80]
            paginationPageSize: 60

            onRegisterApi: (gridApi) ->

                #WARN 必须保持grid 生命周期与controller 一致， 暂不支持动态生成表格, 不然会内存泄露
                gridApi.grid.appScope.$parent.$gridApi = gridApi if exportApi

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
            -> itemCountGetter(scope)
            ,
            (newValue) -> options.totalItems =  newValue if newValue
            )
        scope.$watch(
            -> pageGetter(scope)
            ,
            (newValue) -> options.paginationCurrentPage =  newValue if newValue
            )
        # scope.$watch('gridOptions.paginationPageSize') #watch 每页数据

    #WORKAROUND, issue#27, 当ui-grid-selection 存在时， resize 会存在使table错位的BUG
    #暂时使用 ui-grid-auto-resize 插件 每250ms定时resize，修复改BUG
    #如果有性能问题， 再修复
    nbGridTemplate =  '''
        <div ui-grid="gridOptions" #plugins# ui-grid-pagination ui-grid-auto-resize></div>
    '''

    return {
        link: {
            pre: postLink
        }
        template: (elem, attrs) ->
            PLUGIN_PREFIX = 'ui-'
            plugins = ['ui-grid-pinning','ui-grid-selection']
            applied_plugins = plugins.reduce((res, val) ->
                removedPrefix = val.replace(PLUGIN_PREFIX, '')
                camelCased = _.camelCase(removedPrefix)
                res.push(val) if angular.isDefined(attrs[camelCased])
                return res
            ,[])
            nbGridTemplate.replace("#plugins#",applied_plugins.join(" "))
        scope: {
            columnDefs: '='
            safeSrc: '='
        }
    }


app.directive 'nbGrid', nbGridDirective
app.directive 'nbFilter', NbFilterDirective
app.directive 'conditionInputContainer', conditionInputContainer



