angular.module 'nb.directives'
    .directive 'nbNotification', ['$document', 'WebsocketClient', ($doc, WebsocketClient)->
        postLink = (scope, elem, attr, ctrl)->
            closeNotePan = (e)->
                e.stopPropagation()
                scope.$apply ()->
                    ctrl.isShow = false
                return


            WebsocketClient.startupConnection()
            
            WebsocketClient.addListener {
                name:"Message",
                hander:(data)->
                    scope.$apply ()->
                        ctrl.notifications.push data
                    console.log data
            }
            WebsocketClient.addListener {
                name:"RemoveMessage",
                hander:(data)->
                    console.log data
            }

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

            


