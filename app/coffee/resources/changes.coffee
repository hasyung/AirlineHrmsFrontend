resources = angular.module('resources')


Change = (restmod, RMUtils, $Evt) ->

    Change = restmod.model('/employee_changes/check').mix 'nbRestApi', 'DirtyModel', {
        checkDate: {decode: 'date', param: 'yyyy年MM月dd日',mask: 'CU'}
        createdAt: {decode: 'date', param: 'yyyy年MM月dd日',mask: 'CU'}
        $hooks:
            'after-check': ->
                $Evt.$send('changes:check:success', "审核提交成功")

            'after-check-error': ->
                $Evt.$send('changes:check:success', "审核提交失败")
        $config:
            jsonRoot: 'audits'

        $extend:
            Collection:
                checkChanges: (parms)->
                    self = this
                    request = {
                        method: 'PUT',
                        url: "/api/employee_changes",
                        data: {audits:parms}
                    }
                    onSuccess = (res)->
                        angular.forEach parms, (item) ->
                            item = _.find self, {id: item.id}
                            self.$remove item
                        self.$dispatch 'after-check', res

                    onErorr = (res) ->
                        self.$dispatch 'after-check-error', res

                    this.$send(request, onSuccess, onErorr)

    }
Record = (restmod, RMUtils, $Evt) ->

    Record = restmod.model('/employee_changes/record').mix 'nbRestApi', 'DirtyModel', {
        $config:
            jsonRoot: 'audits'

    }


resources.factory 'Change',['restmod', 'RMUtils', '$nbEvent', Change]
resources.factory 'Record',['restmod', 'RMUtils', '$nbEvent', Record]