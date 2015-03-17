angular.module 'nb.directives'
    .directive 'nbNotification', ['$document', 'WebsocketClient', ($doc, WebsocketClient)->
        postLink = (scope, elem, attr, ctrl)->
            closeNotePan = (e)->
                e.stopPropagation()
                scope.$apply ()->
                    ctrl.isShow = false
                return

            ctrl.connect()
            # listen = (pomelo)->
            #     pomelo.on 'Message', (data)->
            #         console.log(data)

            # WebsocketClient.startConnect(listen)


            elem.on 'click', (e)->
                e.stopPropagation()

            $doc.on 'click', closeNotePan

            scope.$on '$destroy', ()->
                $doc.off 'click', closeNotePan
                elem.off 'click'

        return {
            restrict: 'A'
            templateUrl: 'partials/common/notification.tpl.html'
            replace: true
            controller: NotificationCtrl
            controllerAs: 'ctrl'
            link: postLink

        }
    ]

class NotificationCtrl
    @.$inject = ['$scope', '$window', '$rootScope', 'Notification']
    constructor: (@scope, @window, @rootScope, @Notification) ->
        @isShow = false
        @pomelo = @window.pomelo
        @notifications = []
        @loadInitailData()

    loadInitailData: ()->
        @notifications = @Notification.$collection({status:'unread'}).$fetch()
    toggleClick: ()->
        @isShow = !@isShow

    listen: ()->
        self = @
        @pomelo.on 'Message', (data)->
            self.notifications.push data
            console.log(data)
        @pomelo.on 'RemoveMessage', (data)->
            #删除已经处理的通知

    connect: ()->
        self = @
        @listen()
        parms = {
            host: "192.168.6.32"
            port: "9927"
            log: true
        }
        callBack = (data)->
            if data.code == 'failed'
                console.log "#FF0000   DUPLICATE_ERROR"
        sender = ()->
            cEvent = "connector.entryHandler.enter"
            data = {username: self.rootScope.currentUser.employeeNo, rid: 'com.avatar.airline_hrms#uniq_key_here'}
            console.log data
            console.log self.rootScope.currentUser
            pomelo.request(cEvent,data, callBack)
        pomelo.init parms, sender

    send: (data)->
        cEvent = "message.messageHandler.send"

        @pomelo.request cEvent, data, (data)->
            console.log data

            


