



nb = @.nb

app = nb.app

class WebsocketService extends nb.Service

    constructor: (@window, @rootScope) ->
        @pomelo = @window.pomelo
        @listeners = []


    startupConnection: ()->
        self = @
        parms = {
            host: "192.168.6.32"
            port: "9927"
            log: true
        }
        #绑定监听事件
        callBack = (data)->
            if data.code == 'failed'
                console.log "#FF0000   DUPLICATE_ERROR"
        sender = ()->
            cEvent = "connector.entryHandler.enter"
            data = {username: self.rootScope.currentUser.employeeNo, rid: 'com.avatar.airline_hrms#uniq_key_here'}
            console.log data
            console.log self.rootScope.currentUser
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

    $get: ($window, $rootScope) ->
        service = new WebsocketService($window, $rootScope)
        return service

    @.prototype.$get.$inject = ['$window', '$rootScope']

app.provider("WebsocketClient", WebsocketProvider)
