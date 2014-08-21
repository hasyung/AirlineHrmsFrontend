
io = window.io


angular.module 'socketio',[]
    .provider 'Socketio', ()->

        globalConfig = {}

        defaultOpts = {
            reconnection: false
        }

        @setBaseUrl = (newBaseUrl) ->
            if /\/$/.test(newBaseUrl)
                globalConfig.baseUrl = newBaseUrl.substring(0, newBaseUrl.length-1)
            else
                globalConfig.baseUrl = newBaseUrl

        @$get = ['$timeout','$rootScope',($timeout, $rootScope) ->
            # socket = eio(globalConfig.baseUrl,{forceJSONP:true,jsonp:true})
            # socket = io.connect(globalConfig.baseUrl)
            #与服务器建立连接
            socket = io(globalConfig.baseUrl,defaultOpts)
            defaultScope = $rootScope

            asyncAngularify = (socket,callback) ->
                unless callback?
                    angular.noop
                else
                    () ->
                        args = arguments
                        $timeout () ->
                            callback.apply socket, args


            addListener = (eventName,callback) ->
                socket.on(eventName,callback.__ng = asyncAngularify(socket, callback))

            addOnceListener = (eventName,callback) ->
                scoket.once(eventName,callback__ng = asyncAngularify(scoket,callback))

            socketWrapper = {
                on: addListener
                addListener: addListener
                emit: (eventName, data, callback) ->
                    lastIndex = arguments.length - 1
                    callback = arguments[lastIndex]
                    if typeof callback == 'function'
                        callback = asyncAngularify(socket, callback)
                        arguments[lastIndex] = callback
                    socket.emit.apply(socket, arguments)

                removeListener: (ev, fn) ->
                    if fn and fn.__ng
                        arguments[1] = fn.__ng
                    socket.removeListener.apply(socket, arguments)

                removeAllListeners: () ->
                    socket.removeAllListeners.apply(socket,arguments)

                disconnet: (close) ->
                    socket.disconnet(close)

                # when socket.on('someEvent', fn (data) { ... }),
                # call scope.$broadcast('someEvent', data)
                forward: (events, scope) ->
                    if events instanceof Array == false
                        events = [events]
                    unless scope
                        scope = defaultScope

                    events.forEach (eventName) ->
                        forwardBroadcast = asyncAngularify socket, (data) ->
                            scope.$broadcast(eventName,data)

                        scope.$on '$destroy', () ->
                            socket.removeListener(eventName,forwardBroadcast)

                        socket.on(eventName,forwardBroadcast)


            }

            return socketWrapper

        ]

        return

