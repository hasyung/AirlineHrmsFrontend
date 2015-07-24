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

        events = eventName.split(':')
        # if event.length == 2
            # @scope.$emit(eventName, params)
        if events.length == 3
            if  !params || angular.isString(params) then message = params  else message = params.message
            # success process error
            @rootScope.$emit _.last(events), message

        scope.$emit(eventName, params)

    #   暂时非必须
    #    events scope callback
    #   $Evt.$on.call(scope,event, params)
    # @params  events {string | array} 需要绑定的事件名称
    # @params  scope 当前scope, 必选参数, 事件会在 scope 销毁时解除绑定
    # @params  callback 回调
    #
    $on: (events, callback, scope) ->
        events = [].concat events

        if !scope and this.constructor.name == 'Scope'
            scope = this
        else
            throw new Error('conext scope is required')

        forEach events, (eventName)->
            scope.$onRootScope eventName, callback



class EventsProvider

    $get: ($rootScope, $q) ->
        service = new EventsService($rootScope, $q)
        # service.initialize(@.sessionId)
        return service

    @.prototype.$get.$inject = ['$rootScope', '$q']

app.provider("$nbEvent", EventsProvider)
