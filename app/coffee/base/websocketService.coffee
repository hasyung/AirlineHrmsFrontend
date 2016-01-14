# webscocket 客户端
nb = @.nb
app = nb.app


RID = "com.cdavatar.sichuan_airline_hrms#public"
SUBSCRIBE_EVENT = "connector.entryHandler.enter"
SEND_MSG_EVENT = "message.messageHandler.send"


class WebsocketService extends nb.Service
    processMessage = (service, data) ->
        if data.message_key
            handler = service._events[data.message_key]

            if angular.isFunction(handler)
                handler(data.content)
            else if angular.isArray(handler)
                listeners = handler.slice()
                handle(data.content) for handle in listeners
        else
            # 捕获到错误socket.io 会自动中断websocket 链接 #need investigation
            # throw TypeError("数据结构 缺少 data message_key 标识")

    constructor: (@pomelo, @rootScope, @toaster, UNIQ_KEY, PUSH_SERVER_CONFIG) ->
        @._events = {}
        @setupConnection(UNIQ_KEY, PUSH_SERVER_CONFIG)

    setupConnection: (uniq_key, PUSH_SERVER_CONFIG)->
        self = @
        toaster = @toaster

        intial_params = {
            username: "web_#{uniq_key}"
            rid: RID
        }

        #绑定监听事件
        callBack = (data)->
            if data.code == 'failed'
                toaster.pop 'error', '错误', '推送服务初始化失败'
                console.debug '推送服务初始化失败', data

            self.pomelo.on 'Message', (data) ->
                # console.error data
                processMessage(self, data)

        initialize = () ->
            self.pomelo.request(SUBSCRIBE_EVENT, intial_params, callBack)

        @pomelo.init PUSH_SERVER_CONFIG, initialize

    send: (data, callback = angular.noop)->
        @pomelo.request SEND_MSG_EVENT, data, callback

    disconnect: ()->
        @pomelo.disconnect()

    addListener: (type, callback)->
        if !angular.isFunction(callback)
            throw new Error("addListener only takes instances of Function")

        if !@._events[type]
            @._events[type] = callback
        else if angular.isArray(@._events[type])
            @._events[type].push(callback)
        else
            this._events[type] = [@._events[type], callback]

    removeListener: (name)->
        #@pomelo.removeListener name


class WebsocketProvider
    $get: ($window, $rootScope, toaster, meta, PUSH_SERVER_CONFIG) ->
        UNIQ_KEY = meta.employee_no #用用户员工号标识唯一主键
        pomelo = $window.pomelo || throw 'pomelo not defined'
        service = new WebsocketService(pomelo, $rootScope, toaster, UNIQ_KEY, PUSH_SERVER_CONFIG)
        return service

    @.prototype.$get.$inject = ['$window', '$rootScope', 'toaster',  'USER_META', 'PUSH_SERVER_CONFIG']


app.provider("WebsocketClient", WebsocketProvider)
