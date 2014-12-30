



nb = @.nb

app = nb.app

class EventsService extends nb.Service

    forEach  = angular.forEach


    constructor: (@rootScope, @q) ->

    # @params: {string} eventName 结构为 "org:new:success", 命名空间-操作-状态
    #                   或 "org:link" 不带状态为瞬时事件
    #                   状态有 success process error
    #          {any}    params 需要发送的参数
    #          {Scope}  scope 发送事件的 scope
    #
    #
    $send: (eventName, params, scope = @rootScope) ->

        # if not angular.isString(eventName) return

        event = eventName.split(':')
        # if event.length == 2
            # @scope.$emit(eventName, params)
        if event.length == 3
            if angular.isString(params) then message = params  else message = params.message
            # success process error
            @rootScope.$emit _.last(event), message

        @scope.$emit(eventName, params)

    # @params {string | array} 需要绑定的事件名称
    #
    #
    #
    $on: (events ,scope, callback) ->
        events = [].concat events

        forEach events, (eventName)->
            scope.$onRootScope eventName, callback



    onMessage: () ->



class EventsProvider

    $get: ($rootScope, $q) ->
        service = new EventsService($rootScope, $q)
        # service.initialize(@.sessionId)
        return service

    @.prototype.$get.$inject = ['$rootScope', '$q']

app.provider("$nbEvent", EventsProvider)
