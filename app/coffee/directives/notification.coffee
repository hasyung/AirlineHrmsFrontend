angular.module 'nb.directives'
    .directive 'nbNotification', ['$document', ($doc)->
        postLink = (scope, elem, attr, ctrl)->
            closeNotePan = (e)->
                e.stopPropagation()
                scope.$apply ()->
                    ctrl.isShow = false
                return

            ctrl.connect()
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
    @.$inject = ['$scope', '$window']
    constructor: (@scope, @window) ->
        @isShow = false
        @pomelo = @window.pomelo
        @notifications = []
    toggleClick: ()->
        @isShow = !@isShow

    listen: ()->
        self = @
        @pomelo.on 'Message', (data)->
            self.notifications.push data
            console.log(data)

    connect: ()->
        @listen()
        parms = {
            host: "192.168.6.21"
            port: "9927"
            log: true
        }
        callBack = (data)->
            if data.code == 'failed'
                console.log "#FF0000   DUPLICATE_ERROR"
        sender = ()->
            cEvent = "connector.entryHandler.enter"
            data = {username: 'lxs', rid: 'com.avatar.airline_hrms#uniq_key_here'}
            pomelo.request(cEvent,data, callBack)
        pomelo.init parms, sender

    send: (data)->
        cEvent = "message.messageHandler.send"

        @pomelo.request cEvent, data, (data)->
            console.log data

            


