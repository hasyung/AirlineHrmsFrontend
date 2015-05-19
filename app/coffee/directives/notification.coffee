
app = @nb.app

angular.module 'nb.directives'
    .directive 'nbNotification', ['$document', 'WebsocketClient', ($doc, WebsocketClient)->
        postLink = (scope, elem, attr, ctrl)->
            closeNotePan = (e)->
                e.stopPropagation()
                scope.$apply ()->
                    ctrl.isShow = false
                return


        return {
            restrict: 'A'
            templateUrl: 'partials/common/notification.tpl.html'
            replace: true
            controller: NotificationCtrl
            controllerAs: 'ctrl'
            link: postLink

        }
    ]

    .directive 'notification', ['$document', ($doc) ->
        return {
            restrict: 'A'
            link: (scope,elem,attr) ->
                scope.isOpen = false
                toggle = (e)->
                    e.stopPropagation()
                    if scope.isOpen then close() else open()

                open = ->
                    scope.$apply -> scope.isOpen = true
                    $doc.on 'click', close

                close = ->
                    scope.$apply -> scope.isOpen = false
                    $doc.off 'click', close

                elem.on 'click', toggle
                scope.$on 'destroy', ()->
                    elem.off 'click', toggle
                    $doc.off 'click', close


        }
    ]

class NotificationCtrl
    @.$inject = ['$scope', 'WebsocketClient', '$rootScope', 'Notification', 'toaster']
    constructor: (scope, WebsocketClient, @rootScope, @Notification, toaster) ->

        ctrl = @

        WebsocketClient.addListener 'user_message', (data) ->
            msg = data.latest_message
            msg_unread_count = data.total_unread_count
            toaster.pop('success', msg.category, msg.body)
            scope.$apply -> ctrl.msg_unread_count = msg_unread_count

        # WebsocketClient.addListener 'workflow_step_action', ->

        @notifications = []


    initialNotification: ->
        @Notification.$collection().$fetch()



app.controller "notificationCtrl", NotificationCtrl



