resources = angular.module('resources')

MyLeave = (restmod, RMUtils, $Evt) ->
    MyLeave = restmod.model('/me/leave').mix 'nbRestApi', {

        $hooks:
            'after-revert': ->
                $Evt.$send('leave:revert:success',"请假撤销成功")
            'after-charge': ->
                $Evt.$send('leave:charge:success',"请假抵扣成功")
        $config:
            jsonRoot: 'workflows'

        $extend:

            Record:
                revert: ()->
                    self = this
                    request = {
                        url: "/api/workflows/#{this.type}/#{this.id}/repeal"
                        method: "PUT"
                    }
                    onSuccess = (res) ->
                        self.$dispatch 'after-revert'
                        # $Evt.$send('leave:revert:success')

                    this.$send(request, onSuccess)

                charge: (parms)->
                    self = this
                    request = {
                        url: "/api/workflows/#{this.type}/#{this.id}/deduct"
                        method: "PUT"
                        data: parms
                    }
                    onSuccess = (res) ->
                        self.$dispatch 'after-charge'

                    this.$send(request, onSuccess)



    }





resources.factory 'MyLeave',['restmod', 'RMUtils', '$nbEvent', MyLeave]
