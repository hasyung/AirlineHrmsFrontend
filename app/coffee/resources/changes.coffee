resources = angular.module('resources')


Change = (restmod, RMUtils, $Evt) ->
    Change = restmod.model('/employee_changes/check').mix 'nbRestApi', 'DirtyModel', {
        checkDate: {decode: 'date', param: 'yyyy-MM-dd', mask: 'CU'}
        createdAt: {decode: 'date', param: 'yyyy-MM-dd', mask: 'CU'}

        $hooks:
            'after-check': ->
                $Evt.$send('changes:check:success', "审核提交成功")

        $config:
            jsonRoot: 'audits'

        $extend:
            Collection:
                checkChanges: (parms)->
                    self = this

                    request = {
                        method: 'PUT',
                        url: "/api/employee_changes",
                        data: {audits: parms}
                    }

                    onSuccess = (res)->
                        angular.forEach parms, (item) ->
                            item = _.find self, {id: item.id}
                            self.$remove item

                        angular.forEach self, (item)->
                            console.error item.statusCd

                        self.$dispatch 'after-check', res

                    this.$send(request, onSuccess)
    }


Record = (restmod, RMUtils, $Evt) ->

    Record = restmod.model('/employee_changes/record').mix 'nbRestApi', 'DirtyModel', {
        checkDate: {decode: 'date', param: 'yyyy-MM-dd', mask: 'CU'}
        createdAt: {decode: 'date', param: 'yyyy-MM-dd', mask: 'CU'}

        $config:
            jsonRoot: 'audits'
    }


resources.factory 'Change',['restmod', 'RMUtils', '$nbEvent', Change]
resources.factory 'Record',['restmod', 'RMUtils', '$nbEvent', Record]