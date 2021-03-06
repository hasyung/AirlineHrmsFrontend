app = @nb.app


angular.module 'nb.directives'
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
    @.$inject = ['$scope', '$state', 'WebsocketClient', '$rootScope', 'Notification', 'toaster', 'USER_MESSAGE', '$timeout']

    constructor: (scope, @state, WebsocketClient, @rootScope, Notification, toaster, initializedMessage, @timeout) ->
        computeTotalUnreadCount = (res, value) ->
            return res + value.count || value.count || 0

        ctrl = @

        ctrl.msg_unread_count = initializedMessage.user_message.unread_count || 0
        initWorkflows = initializedMessage.workflows || []

        ctrl.workflows = workflows = initWorkflows.reduce(
            (res, value) ->
                res[value.type] = value
                return res
            {}
            )

        #计算流程总数
        ctrl.workflow_count = initWorkflows.reduce(computeTotalUnreadCount, 0)

        WebsocketClient.addListener 'user_message', (data) ->
            msg = data.latest_message
            msg_unread_count = data.unread_count
            toaster.pop('success', msg.category, msg.body)
            scope.$apply -> ctrl.msg_unread_count = msg_unread_count

        WebsocketClient.addListener 'workflow', (data) ->
            scope.$apply ->
                workflows[data.type] = data
                ctrl.workflow_count = _.reduce(workflows, computeTotalUnreadCount, 0)

        WebsocketClient.addListener 'system_config', (data) ->
            scope.$apply ->
                ctrl.rootScope.reloadFlagStr = data.reload_flag_str

        @notifications = Notification.$collection().$fetch()

    redirectTo: (state) ->
        self = @

        # 切换状态
        @state.go(state)

        @timeout ()->
            self.rootScope.show_main = true
            self.rootScope.selectPending = true
        , 800

    markToReaded: ->
        @notifications.markToReaded()
        @msg_unread_count = 0


app.controller "notificationCtrl", NotificationCtrl