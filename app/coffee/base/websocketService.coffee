



nb = @.nb

app = nb.app

class WebsocketService extends nb.Service

    constructor: (@window, @USER_META) ->
        @pomelo = @window.pomelo
        @listeners = []


    startupConnection: ()->
        self = @
        parms = {
            host: "192.168.6.40"
            port: "9927"
            log: true
        }
        rid = "com.cdavatar.sichuan_airline_hrms#public"
        #绑定监听事件
        callBack = (data)->
            if data.code == 'failed'
                console.log "#FF0000   DUPLICATE_ERROR"
        sender = ()->
            cEvent = "connector.entryHandler.enter"
            data = {username: "web_#{self.USER_META.employee_no}", rid: rid}
            console.log data
            self.pomelo.request(cEvent,data, callBack)
        @pomelo.init parms, sender



    sendMessage: (data)->
        cEvent = "message.messageHandler.send"

        @pomelo.request cEvent, data, (data)->
            console.log data


    stopCurrentConnect: ()->
        @pomelo.disconnect()

    addListener: (listener)->
        @pomelo.on listener.name, listener.hander

    removeListener: (listener)->
        @pomelo.removeListener listener.name, listener.hander
        


    

class WebsocketProvider

    $get: ($window, USER_META) ->
        service = new WebsocketService($window, USER_META)
        return service

    @.prototype.$get.$inject = ['$window', 'USER_META']

app.provider("WebsocketClient", WebsocketProvider)
