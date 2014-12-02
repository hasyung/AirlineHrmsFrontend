
# for  finder 2.0
# api =
#     name:
#         displayName: '姓名'
#         type: 'string'

#     create_at:
#         displayName: '入职时间'
#         range: true
#         type: 'date'
#     age:
#         displayName: '年龄'

#     sex:
#         displayName: '性别'
#         type: 'select'
#         resource: 'sex'
#         data: [
#             {displayName: '男', type: 0}
#             {displayName: '女', type: 1}
#         ]

#     org:
#         displayName: '部门'
#         type: 'dynamicSelect'
#         url: '/orgs'
#         map: 'org.name'
#         key: 'org.id'

#     abc:
#         type: 'select'
#         resource: 'org'
# to = {
#     name: 'ds'
#     create_at:
#         from: '43278743782'
#         to: '73485647386'
#     age: 38
#     org:
#         id: 23
# }



nb = @.nb
App = nb.app
forEach = angular.forEach
isDefined = angular.isDefined


finderDirective = ($log)->

    class Condition
        constructor: (_primary, name, @filter) ->

            this['key'] = _primary
            this['name'] = name

        $get: (key) ->
            return this[key] if this[key]?

        $id: ()->
            return @key

        $param: ->
            @filter.$param()


    class FinderController
        @.$inject = ['$scope', '$log', '$attrs']

        constructor: (@scope, @log, @attr) ->
            @log.debug 'finder initialized', arguments
            @.filters = []
            @.conditions = []
            @initialize()

        $$event: 'data:search'

        initialize: ->

        select: (condition) ->

        remove: (condition) ->

        addFilter: (name, _primary, ctx) ->
            condition = new Condition(name, _primary, ctx)
            @.conditions.push(condition)

        $param: ->
            param = {}
            for condition in @conditions
                do (condition) ->
                    key = condition.$id()
                    param[key] =  condition.$param()
            @log.debug 'finder: ', param
            return param

        $search: ()->
            param = @.$param()
            eventName = if @attr.finderEvent then "#{@attr.finderEvent}:search" else 'data:search'
            @scope.$emit('data:search',param)




    postLink = (scope, $el, attr, $finder)->
        $log.debug arguments

    return {
        templateUrl: 'partials/personnel/finder.html'
        transclude: true
        replace: true
        scope: true
        controller: FinderController
        controllerAs: 'ctrl'
        link: postLink
    }



App.directive('finder',['$log', finderDirective])


NumberRangeDirective = (log) ->

    postLink = (scope, $el, attrs, $finder) ->
        log.debug arguments

        $param = ->
            param =
                from: $(fromEl).val()
                to: $(toEl).val()
            log.debug 'numberRange:', param

            return param

        options = {}

        scope.$param = $param

        forEach ['name', 'displayName'], (key) ->
            options[key] = attrs[key]  if isDefined[attrs[key]]

        key = attrs['name']
        displayName = attrs['displayName']

        scope.displayName = displayName
        scope.status = isopen: false

        $finder.addFilter(key, displayName, scope)
        inputs = $el.find('input')
        fromEl = inputs[0]
        toEl   = inputs[1]

        scope.$on 'destory', () ->
            toEl   = null
            fromEl = null
            inputs = null




    return {
        templateUrl: 'partials/personnel/numberRange.html'
        require: '^finder'
        link: postLink
    }



DateRangeDirective= (log) ->
    link = ($scope, $el, $attrs, $model) ->
        log.debug $attrs
        console.log(123)


    return {
        link: link
    }



App.directive('numberRange', ['$log',NumberRangeDirective])


# class FinderProvider

#     FinderProvider::$get.$inject = ['$compile', '$templateCache', '$q']


#     fetchTemplate = (template) ->
#         promise =  $q.when($templateCache.get(template) or $http.get(template))
#         promise.then (res) ->
#             if angular.isObject(res)
#                 $templateCache.push(template), res.data
#                 return res.data
#             return res
#         return promise


#     $get: ($compile, $templateCache, $q) ->


#         finderFactory = (config) ->
#             $finder = {}

#             options = $finder.$options = angular.extend({}, default, config)

#             scope = $finder.$scope = options.scope && options.scope.$new() || $rootScope.$new()

#             append =  ->


