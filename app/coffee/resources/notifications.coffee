resources = angular.module('resources')


Notification = (restmod, RMUtils, $Evt) ->
    Notification = restmod.model('/me/notifications').mix 'nbRestApi', {
        createdAt: {decode: 'date', param: 'yyyy-MM-dd'}
        updatedAt: {decode: 'date', param: 'yyyy-MM-dd'}

        $extend:
            Collection:
                markToReaded: () ->
                    firstItem = this[0]
                    return if angular.isUndefined(firstItem)

                    url = this.$url()
                    request = {
                        url: "#{url}"
                        method: 'PUT'
                        data:{
                            anchor_id: firstItem.id
                        }
                    }

                    this.$send request
                    return true

                loadMore: (anchor_id)->
                    url = this.$url()
                    self = this
                    if anchor_id == 'undefined'
                        console.log 'test'
                    request = {
                        url: "#{url}?anchor_id=#{anchor_id}"
                        method: 'GET'
                    }
                    onSuccess = (res)->
                        angular.forEach res.data.notifications, (item)->
                            self.$add self.$buildRaw(item)
                        return
                    this.$send request, onSuccess

    }



resources.factory 'Notification',['restmod', 'RMUtils', Notification]
