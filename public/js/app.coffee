
require './config/templateCache.coffee'
require './filters/filters.coffee'
require './directives/directives.coffee'
require './services/services.coffee'
require './services/socketio.coffee'
require './services/devise.js'
# require './controller/login.coffee'
# require './controller/knowledge.coffee'

require './controller/index.coffee'


rootRoute = require './config/route.coffee'
restConf = require './config/rest.coffee'


# angular.module('vx.controllers',['vx.controllers.knowledge','vx.controllers.login'])


deps = [
    'ngSanitize'
    'ngMessages'
    'ui.router'
    'restangular'
    'vx.services'
    'vx.controllers'
    'vx.filters'
    'vx.templates'
    'vx.directives'
    'ngSanitize'
    'ui.select'
    'socketio'
    'toaster' # 后台通知组件 Angular-toaster
]

App = angular.module 'vxApp',deps


App
    .config restConf
    .config rootRoute
    .config ['SocketioProvider', (ioProvider) ->

        # ioProvider.setBaseUrl('http://192.168.3.99:5001')
        # ioProvider.setBaseUrl('http://192.168.1.110:3000')
        ioProvider.setBaseUrl('http://localhost:5001')
        # ioProvider.setBaseUrl('http://192.168.3.31:3000')
        # ioProvider.setBaseUrl('http://localhost:3000')

    ]
    .run ['$state','$rootScope','Socketio', ($state,$rootScope,socket) ->
        # for $state.includes in view
        $rootScope.$state = $state

        console.log "state : #{JSON.stringify $state.current}"

        # $rootScope.$on '$stateChangeStart',() ->
        #     console.log "from state : #{arguments[3].name } to state : #{JSON.stringify arguments[1].name}"

        $rootScope.$on 'devise:unauthorized',() ->
            $state.go('auth.login')

        socket.on 'connect', () ->
            console.log 'connect socketio success!!'

        socket.forward('newNotifacation')

        socket.on 'connect_error', (err) ->
            console.log "socket err : #{err}"
    ]
