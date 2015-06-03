resources = angular.module('resources')


Notification = (restmod, RMUtils, $Evt) ->
    Notification = restmod.model('/me/notifications').mix 'nbRestApi', {
        createdAt: {decode: 'date', param: 'yyyy-MM-dd'}
        updatedAt: {decode: 'date', param: 'yyyy-MM-dd HH:mm'}

        $extend:
            Collection:
                markToReaded: () ->
                    firstItem = this[0]
                    return if angular.isUndefined(firstItem)

                    url = this.$url()
                    request = {
                        url: url
                        method: 'PUT'
                        data:{
                            anchor_id: firstItem.id
                        }
                    }
                    this.$send(request).$asPromise()

                loadMore: () ->
                    if this.length > 0
                        anchor_id = this[this.length - 1]['$pk']
                        this.$fetch({anchor_id: anchor_id})

    }



resources.factory 'Notification',['restmod', 'RMUtils', Notification]
