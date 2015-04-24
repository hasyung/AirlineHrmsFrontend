
nb = @nb
app = nb.app

ISO_DATE_REGEXP = /\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d\.\d+([+-][0-2]\d:[0-5]\d|Z)/


class NbTableCtrl
    @.$inject = ['$scope', '$parse', '$filter', '$attrs']

    copyRefs = (src) ->
        return `src? [].concat(src) : []`

    constructor: (scope, $parse, $filter, $attrs) ->
        propertyName  = $attrs.nbTable
        displayGetter = $parse(propertyName)
        displaySetter = displayGetter.assign
        safeGetter = undefined
        orderBy = $filter('orderBy')
        filter  = $filter('filter')
        safeCopy = copyRefs(displayGetter(scope))

        pipeAfterSafaCopy = true
        lastSelected = null #最后选择的选项

        tableState = {
            sort: {}
            predicate: {}
            pagination: {
                page: 1
            }
        }

        updateSafeCopy = ->
            safeCopy = copyRefs(safeGetter(scope))
            @pipe() if pipeAfterSafaCopy == true

        if $attrs.nbSafeSrc
            safeGetter = $parse $attrs.nbSafeSrc
            scope.$watch(
                ->
                    safeSrc = safeGetter(scope)
                    return `safeSrc? safeSrc.length : 0`
                (newValue, oldValue) ->
                    updateSafeCopy() if newValue != safeCopy.length
                )
            scope.$watchCollection(
                () -> return safeGetter(scope)
                (newValue, oldValue) -> updateSafeCopy() if newValue != oldValue
                )



        @sortBy = (predicate, reverse) ->
            tableState.sort.predicate = predicate
            tableState.sort.reverse = reverse == true
            tableState.pagination.start = 0
            return @pipe()

        @search = () ->
            # predicateObject = @tableState.search.predicateObject || {}
            # prop = predicate || '$'

            # predicateObject[prop] = input
            # # to avoid to filter out null value
            # delete predicateObject[prop] if !input
            # tableState.search.predicateObject = predicateObject
            # tableState.pagination.start = 0
            tableState.pagination.page = 1
            return @pipe()

        @pipe = ->
            pagination = tableState.pagination
            filtered = if tableState.search.predicateObject then filter(safeCopy, tableState.search.predicateObject) else safeCopy

            filtered = orderBy(filtered, tableState.sort.predicate, tableState.sort.reverse) if tableState.sort.predicate

            displaySetter(scope, filtered)

        @select = (row, mode) -> #选择行
            rows = safeCopy
            index = rows.indexOf(row)

            if index != -1
                switch mode
                    when 'single'
                        row.isSelected = row.isSelected != true
                        if lastSelected
                            lastSelected.isSelected = false

                        lastSelected = if row.isSelected == true then row else undefined
                    when 'multiple'
                        rows[index].isSelected = !rows[index].isSelected

        @selectAll = (isSelected) ->
            rows = safeCopy
            rows.map((row) -> row.isSelected = isSelected)

        @slice = (page, number) ->
            tableState.pagination.page = page
            tableState.pagination.per_page = number
            return @pipe()

        @getTableState = () ->
            tableState

        @setFilter = (filterName) ->
            filter = $filter(filterName)

        @setSort = (sortFunctionName) ->
            orderBy = $filter(sortFunctionName)

        @preventPipeOnWatch = ->
            pipeAfterSafaCopy = false

nbTableDirective = () ->

    postLink = (scope, elem, attrs, ctrl) ->

        ctrl.setFilter(attrs.nbSetFilter) if attrs.nbSetFilter
        ctrl.setSort(attrs.nbSetSort) if attrs.nbSetSort


    return {
        restrict: 'A'
        controller: NbTableCtrl
        link: postLink
    }

nbPipeDirective = () ->

    preLink = (scope, elem, attrs, ctrl) ->
        if angular.isFunction(scope.nbPipe)
            ctrl.preventPipeOnWatch()
            ctrl.pipe = ->
                return scope.nbPipe({tableState: ctrl.getTableState(), tableCtrl: ctrl})

        elem.on 'click', ->
            ctrl.search()

        scope.$on '$destroy', ->
            elem.off 'click'

    return {
        require: '^nbTable'
        scope: {nbPipe: '&'} # @ ?
        link:{
            pre: preLink
        }

    }

class NbSearchCtrl

    @.$inject = ['$scope', 'SearchCondition', '$attrs', '$element']

    constructor: (@scope, @Filter, @attrs) ->
        self = @
        @conditionCode = @attrs.nbSearch
        @scope.filters = @Filter.$search({code: @conditionCode})
        @scope.predicateObject = {}
        inactivePredicates = []
        activePredicates = []
        @scope.conditions = @conditions = []
        @predicates = @scope.predicates = Object.create {} ,{
            asArray: {
                enumerable: false
                get: ->
                    _.values(@)
            }
            activePredicates: {
                enumerable: false
                get: ->
                    activePredicates


            }
            inactivePredicates: {
                enumerable: false
                get: ->
                    return inactivePredicates
                set: (newValue) ->
                    inactivePredicates.push newValue

            }
            startupPredicate: {
                enumerable: false
                value: (key) ->
                    predicate = if key then _.remove(inactivePredicates, (pre) -> pre.key == key)[0] else inactivePredicates.pop()
                    activePredicates.push predicate
                    return predicate
            }
            shutdownPredicate: {
                enumerable: false
                value: (predicate) ->
                    inactivePredicates.push(predicate)
                    index = activePredicates.indexOf(predicate)
                    activePredicates.splice(index, 1)
            }
            # 选择条件时, 把新条件放去 active_predicate, 老条件放入 inactive_predicate 中
            switchActivePredicate: {
                enumerable: false
                value: (oldValue, newValue) ->
                    oldIndex = activePredicates.indexOf(oldValue)
                    newIndex = inactivePredicates.indexOf(newValue)
                    activePredicates.splice(oldIndex, 1, newValue)
                    inactivePredicates.splice(newIndex, 1, oldValue)
            }
            addPredicate: {
                enumerable: false
                value: (key, displayName, paramGetter, $transcludeFn) ->
                    Object.defineProperty @, key, {
                        enumerable: true
                        configurable: false
                        value: {
                            key: key
                            displayName: displayName
                            getter: paramGetter
                            $transcludeFn: $transcludeFn
                            transclude: (element, initialData) ->
                                that = @
                                newScope = self.scope.$new()
                                angular.forEach initialData, ((v, k ) -> newScope[key] = v ) if initialData

                                @.$transcludeFn newScope, (clone, newScope) ->
                                    that.block = {
                                        element: clone
                                        scope: newScope
                                    }
                                    element.append(clone) # rework?
                                    newScope.$watch(key
                                        () -> self.updatePredicateObject()
                                        true
                                        )
                        }
                    }
                    @inactivePredicates = this[key]

                    self.addNewCondition() if activePredicates.length == 0

            }
            select: {
                enumerable: false
                value: (option) ->
            }
        }

    updatePredicateObject: ->

        @scope.predicateObject = @conditions.reduce(
            (res, cur) ->
                predicate = cur.selected
                value = predicate.getter(predicate.block.scope)
                res[predicate.key] = value  if value && !s.isBlank(value)
                return res
            , {})

    switchQueryPredicate: (old, newValue, element) ->
        @$$destroy(old) if old.block?
        newValue.transclude(element)

        @predicates.switchActivePredicate(old, newValue)

    initialCondition: (predicate, element, initialData) ->
        predicate.transclude(element, initialData)

    selectFilter: (filter) ->
        self = @
        @.$$clear()
        pick = _.pick
        # $el = @el
        # $el.trigger('select:filter',filter)

        parsedQueryParams = @.$$parseFilter(filter.condition)
        angular.forEach parsedQueryParams, (v, key) ->
            initialData = {}
            initialData[key] = v
            predicate = self.predicates.startupPredicate(key)
            self.addCondition(predicate, initialData)



    remove: ($index, force = false) ->
        return if !force && @conditions.length <= 1 #保留最少一个条件
        condition = @conditions[$index] #待删除的条件
        @.$$destroyCondition(condition)
        #删除
        @conditions.splice($index, 1)


    saveFilter: (filterName) ->

        request_data = {
            name: filterName
            code: @conditionCode
            condition: JSON.stringify(@scope.predicateObject)
        }

        promise = @scope.filters.$create(request_data)


    addPredicate: (key, displayName, paramGetter, $transcludeFn) ->
        @predicates.addPredicate(key, displayName, paramGetter, $transcludeFn)

    addCondition: (predicate, initialData) ->
        @conditions.push {selected: predicate, initialData: initialData}

    addNewCondition: () ->
        predicate = @predicates.startupPredicate()
        @addCondition(predicate)

    $$destroyCondition: (condition) ->
        predicate = condition.selected #当前条件的查询规则
        #清理资源
        #remove predicate from searchObject object
        @scope.predicateObject = _.omit(@scope.predicateObject, predicate.key)
        @$$destroy(predicate)
        #重置待选的条件
        @predicates.shutdownPredicate(predicate)


    $$clear: () ->
        destroyAll = (v, idx, arr) ->
            @.$$destroyCondition(v)

        @conditions.forEach destroyAll.bind(@)
        @conditions.splice(0, @conditions.length)



    $$destroy: (predicate) ->
        return  if not predicate.block
        predicate.block.element.remove()
        predicate.block.scope.$destroy()
        delete predicate.block
        return

    $$parseFilter: (filter) ->

        reviver = (k , v) ->
            return v if k == ''
            return new Date(v) if typeof v == 'string' && ISO_DATE_REGEXP.test(v)
            return v

        return JSON.parse(filter, reviver)

    # predicate: () ->


nbConditionContainerDirective = ->
    postLink = (scope, elem, attrs, ctrl) ->

        selectedPredicate = scope.condition.selected
        initialData  =scope.condition.initialData

        ctrl.initialCondition(scope.condition.selected, elem, initialData)

        scope.$watch 'condition.selected', (newValue, old) ->
            return if newValue == old #predicate object
            ctrl.switchQueryPredicate(old, newValue, elem)

        scope.$on '$destroy', ->
            conditionNode = null

    return {
        require: '^nbSearch'
        link: postLink
    }


nbSearchDirective = ($timeout) ->

    postLink = (scope, elem, attrs, ctrl, $transcludeFn) ->
        searchCtrl = ctrl[0]
        tableCtrl =  ctrl[1]
        promise = null
        throttle = attrs.nbDelay || 400
        # tableCtrl.getTableState().predicate = scope.predicate
        scope.$watch('predicateObject', (newValue, oldValue) -> tableCtrl.getTableState().predicate = newValue)

        scope.$watch('ctrl.currentFilter',(newValue) -> searchCtrl.selectFilter(newValue) if newValue)



        $transcludeFn scope,(clone, scope) -> #for parser nb-condition
            elem.append clone


        onSelectFilter = (evt, filter) ->
            condition = JSON.parse(filter.condition)



        # view -> table state 无搜索按钮?
        # state -> table view 条件数据入口唯一?

        elem.on 'select:filter'




    return {
        require: ['nbSearch','^nbTable']
        templateUrl: 'partials/component/table/search.html'
        transclude: true
        controller: 'nbSearchCtrl'
        controllerAs: 'ctrl'
        scope: true
        priority: 110
        link: postLink
    }

# div(nb-search)
#     input(name="" nb-predicate="姓名" ng-model="name")
#     input(name="" nb-predicate="年龄" ng-model="name")
#     input(name="" nb-predicate ng-model="name")
#     input(name="" nb-predicate ng-model="name")



nbSelectRowDirective = ->


    postLink = (scope, elem, attrs, tableCtrl) ->
        return unless attrs.nbSelectRow
        onSelect = (evt) ->
            scope.$apply ->
                tableCtrl.select(scope.row, mode)
        mode = attrs.mode || 'single' #multiple
        elem.on 'click', onSelect

        scope.$watch 'row.isSelected' ,(newValue, oldValue) ->
            if newValue == true
                elem.addClass('nb-selected')
            else
                elem.removeClass('nb-selected')

        scope.$on '$destroy', () ->
            elem.off 'click', onSelect

    return {
        require: '^nbTable'
        link: postLink
        scope: {
            row: "=nbSelectRow"
        }
    }


nbSelectRowDirective2 = ->

    postLink = (scope, elem, attrs, ctrl) ->
        mode = attrs.mode || 'single'

        $input = elem.find('input')[0]

        if mode == 'all'
            elem.on 'change', (evt) ->
                scope.$apply () ->
                    ctrl.selectAll($input.checked)
        else
            elem.on 'change', (evt)->
                input = evt.target
                ctrl.select(scope.row, mode)

            scope.$watch(
                'row.isSelected'
                (newValue) ->
                    $input.checked = newValue
                    if newValue == true
                        elem.parent().addClass('nb-selected')
                    else
                        elem.parent().removeClass('nb-selected')
                )

        scope.$on '$destroy', () ->
            elem.off 'change'

    return {
        template: '<input ng-model="row.isSelected" type="checkbox"/>'
        link: postLink
        require: '^nbTable'
        scope: {
            row: '=?selectRow'
        }
    }


nbPredicateDirective = ($parse) ->

    postLink = (scope, elem, attrs, ctrl, $transcludeFn) ->
        searchCtrl = ctrl[0]
        # ngModelCtrl = ctrl[1]
        displayName = attrs.nbPredicate

        return if !attrs.ngModel && !attrs.predicateAttr

        key = attrs.ngModel || attrs.predicateAttr

        modelGetter = $parse(key)
        searchCtrl.addPredicate(key, displayName, modelGetter, $transcludeFn)

    return {
        require: ['^nbSearch']
        link: postLink
        transclude: 'element'
        priority: 1
    }




nbPaginationDirective = ->

    postLink = (scope, elem, attrs, ctrl) ->
        # eval?
        scope.perPage = scope.$eval(attrs.perPage) || 10 #每页条数
        scope.nbDislpayedPages = scope.$eval(scope.nbDislpayedPages) || 10 #显示多少页

        scope.currentPage = 1
        scope.pages = []

        redraw = ->
            start = 1
            end
            i
            # scope.currentPage = Math.floor(paginationState.start / paginationState.number) + 1

            start = Math.max start, scope.currentPage - Math.abs(Math.floor(scope.nbDislpayedPages / 2))
            end =  start + scope.nbDislpayedPages

            if end > scope.pagesCount
                end = scope.pagesCount
                start = Math.max(1, end - scope.nbDislpayedPages)

            scope.pages = []

            for i in [start ... end + 1]
                scope.pages.push(i)

            return

        scope.$watch 'pageState', (newValue) ->
            return if angular.isUndefined(newValue)
            scope.currentPage = newValue.page
            scope.count = newValue.count
            scope.perPage = newValue.per_page
            scope.pagesCount = newValue.pages_count
            scope.count = newValue.count
            redraw()

        # TODO: 下拉框选择每张表个数
        # TODO: 下一页 上一页 首页 尾页?

        scope.selectPage = (page) ->
            if 0 < page <= scope.pagesCount
                ctrl.slice page , scope.perPage

        ctrl.slice(1, scope.nbItemsByPage)

    return {
        restrict: 'EA'
        require: '^nbTable'
        templateUrl: 'partials/component/table/pagination.html'
        scope: {
            pageState: '=nbPagination'
        }
        link: postLink
    }

filterSelectorDirective = ->

    postLink = (scope, elem, attrs) ->





app.controller 'nbSearchCtrl', NbSearchCtrl
app.directive 'nbTable', ['$timeout', nbTableDirective]
app.directive 'nbSearch', nbSearchDirective
app.directive 'nbConditionContainer', nbConditionContainerDirective
app.directive 'nbPredicate', ['$parse', nbPredicateDirective]
app.directive 'nbPipe', nbPipeDirective
app.directive 'nbSelectRow', nbSelectRowDirective
app.directive 'selectRow', nbSelectRowDirective2

app.directive 'nbPagination', nbPaginationDirective




