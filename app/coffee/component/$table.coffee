
nb = @nb
app = nb.app


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
                    ,
                    (newValue, oldValue) ->
                        updateSafeCopy() if newValue != safeCopy.length
                )
            scope.$watchCollection(
                    () -> return safeGetter(scope)
                    ,
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

            if pagination.number != undefined
                pagination.numberofPages = if filtered.length > 0 then Math.ceil(filtered.length / pagination.number) else 1
                pagination.start = if pagination.start >= filtered.length then (pagination.numberOfPages - 1) * pagination.number else pagination.start
                filtered = filtered.slice(pagination.start, pagination.start + pagination.number)

            displaySetter(scope, filtered)

        @select = (row, mode) -> #选择行
            rows = safeCopy
            index = rows.indexOf(row)

            if index != -1
                if mode == 'single'
                    row.isSelected = row.isSelected != true
                    if lastSelected
                        lastSelected.isSelected = false

                    lastSelected = if row.isSelected == true then row else undefined
                else
                    rows[index].isSelected = !rows[index].isSelected

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

class nbSearchCtrl

    @.$inject = ['$scope']

    constructor: (@scope) ->
        self = @
        scope.predicateObject = {}
        inactivePredicates = []
        activePredicates = []
        @scope.conditions = @conditions = []
        @predicates = scope.predicates = Object.create {} ,{
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
                            transclude: (element) ->
                                that = @
                                @.$transcludeFn (clone, newScope) ->
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

                    self.addCondition() if activePredicates.length == 0

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
                res[predicate.key] = value  if value && !_.str.isBlank(value)
                return res
            , {})

    splice: (old, newValue, element) ->
        @$$destroy(old) if old.block?
        newValue.transclude(element)

        oldIndex = _.findIndex @predicates.activePredicates, old
        newIndex = _.findIndex @predicates.inactivePredicates, newValue
        @predicates.activePredicates.splice(oldIndex, 1, newValue)
        @predicates.inactivePredicates.splice(newIndex, 1, old)

    initialCondition: (predicate, element) ->
        predicate.transclude(element)

    select: (option) ->
        @predicates.select(option)

    remove: ($index) ->
        return if @conditions.length <= 1
        condition = @conditions[$index]
        predicate = condition.selected
        #remove predicate from searchObject object
        @scope.predicateObject = _.omit(@scope.predicateObject, predicate.key)


        @$$destroy(predicate)

        @predicates.inactivePredicates.push(predicate)
        predicate_index = _.findIndex @predicates.activePredicates, predicate
        @predicates.activePredicates.splice(predicate_index, 1)
        @conditions.splice($index, 1)

    addPredicate: (key, displayName, paramGetter, $transcludeFn) ->
        @predicates.addPredicate(key, displayName, paramGetter, $transcludeFn)

    addCondition: ->
        predicate = @predicates.inactivePredicates.pop()
        @conditions.push {selected: predicate}
        @predicates.activePredicates.push predicate

    $$destroy: (predicate) ->
        return  if not predicate.block
        predicate.block.element.remove()
        predicate.block.scope.$destroy()
        delete predicate.block
        return

    # predicate: () ->


nbWatchSelectDirective = ->
    postLink = (scope, elem, attrs, ctrl) ->

        ctrl.initialCondition(scope.condition.selected, elem)

        scope.$watch 'condition.selected', (newValue, old) ->
            return if newValue == old
            ctrl.splice(old, newValue, elem)

        scope.$on '$destroy', ->
            conditionNode = null

    return {
        require: '^nbSearch'
        link: postLink
    }


nbSearchDirective = ($timeout) ->

    postLink = (scope, elem, attrs, ctrl, $transcludeFn) ->

        tableCtrl =  ctrl
        promise = null
        throttle = attrs.nbDelay || 400
        # tableCtrl.getTableState().predicate = scope.predicate
        scope.$watch('predicateObject', (newValue, oldValue) -> tableCtrl.getTableState().predicate = newValue)

        $transcludeFn (clone, scope) -> #for parser nb-condition
            elem.append clone

        # view -> table state 无搜索按钮?
        # state -> table view 条件数据入口唯一?



    return {
        require: '^nbTable'
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


nbPredicateDirective = ($parse) ->

    postLink = (scope, elem, attrs, ctrl, $transcludeFn) ->
        searchCtrl = ctrl[0]
        # ngModelCtrl = ctrl[1]

        return if !attrs.ngModel && !attrs.predicateAttr

        key = attrs.ngModel || attrs.predicateAttr

        modelGetter = $parse(key)
        searchCtrl.addPredicate(key, scope.displayName, modelGetter, $transcludeFn)

    return {
        require: ['^nbSearch']
        link: postLink
        transclude: 'element'
        priority: 1
        scope: {
            displayName: "@nbPredicate"
        }
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
            scope.perPage = newValue.per_page
            scope.pagesCount = newValue.pages_count
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


app.controller 'nbSearchCtrl', nbSearchCtrl
app.directive 'nbTable', ['$timeout', nbTableDirective]
app.directive 'nbSearch', nbSearchDirective
app.directive 'nbWatchSelect', nbWatchSelectDirective
app.directive 'nbPredicate', ['$parse', nbPredicateDirective]
app.directive 'nbPipe', nbPipeDirective
app.directive 'nbSelectRow', nbSelectRowDirective
app.directive 'nbPagination', nbPaginationDirective




