
nb = @.nb
app = nb.app


class NotificationCtrl extends nb.Controller

    @.$inject = ['$scope', 'Notification']

    constructor: (@scope, @Notification) ->
        self = @
        @notifications = []
        # @loadInitailData()
        @scope.markToReaded = ()-> self.notifications.markToReaded()

    loadInitailData: ()->
        # @notifications = @Notification.$collection().$fetch()

    loadMoreRows: ()->
        self = @
        rLength = @notifications.length
        if rLength > 1
            lastRow = @notifications[rLength - 1 ]
            return if lastRow.id == 1
            # @Notification.$collection().$fetch({anchor_id: lastRow.id}).$then (data)->
            #     angular.forEach data, (item)->
            #         console.log item
            #         self.notifications.$add item
            @notifications.loadMore(lastRow.id)
        else
            @notifications = @Notification.$collection().$fetch()





app.controller('NotificationCtrl', NotificationCtrl)
