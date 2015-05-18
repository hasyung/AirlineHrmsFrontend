
nb = @.nb
app = nb.app


class NotificationCtrl extends nb.Controller

    @.$inject = ['$scope', 'Notification']

    constructor: (@scope, @Notification) ->
        @loadInitailData()

    loadInitailData: ()->
        @notifications = @Notification.$collection().$fetch()



app.controller('NotificationCtrl', NotificationCtrl)
