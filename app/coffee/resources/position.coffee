resources = angular.module('resources')

# position.specifications.fetch()

Position = (restmod, RMUtils, $Evt, Specification) ->

    # restmod.model('/positions')
    Position = restmod.model('/positions').mix 'nbRestApi', 'DirtyModel', {
        department: {mask: 'C', belongsTo: 'Org'}
        isSelected: {mask: "CU"}
        createdAt: {decode: 'nbDate'}
        employees: { hasMany: 'Employee'}
        # 部门领导
        formerleaders: {hasMany: 'Formerleaders'}
        # 是否超编
        # isOverstaffed: {
        #     computed: (val) ->
        #         this.staffing > this.budgetedStaffing
        #     , mask: "CU"
        # }
        #超编人数，主要用这个，上面那个是否超编会逐渐取消，最后删除
        overstaffedNum: {
            computed: (val) ->
                num = this.staffing - this.budgetedStaffing
                if num > 0 then num else 0
            , mask: "CU"
        }
        specification: { hasOne: 'Specification', mask: "U"}

        $hooks:
            'after-create': ->
                $Evt.$send('position:create:success', "岗位创建成功")

            'after-update': ->
                $Evt.$send('position:update:success', "岗位更新成功")

            'after-destroy': ->
                $Evt.$send('position:destroy:success',"岗位删除成功")

            'after-adjust': ->
                $Evt.$send('position:adjust:success',"岗位调整成功")

        $extend:
            Collection:
                $adjust: (infoData)->
                    self = @
                    # url = this.$url()
                    request = {
                        method: 'POST',
                        url: "api/positions/adjust",
                        data: infoData
                    }

                    onSuccess = (res)->
                        angular.forEach infoData.position_ids, (id) ->
                            item = _.find self, {id: id}
                            self.$remove item
                        self.$dispatch 'after-adjust', res

                    this.$send(request, onSuccess)

                $batchRemove: (ids) ->
                    self = @
                    request = {
                        method: 'POST',
                        url: "api/positions/batch_destroy",
                        data: ids
                    }
                    onSuccess = (res)->
                        angular.forEach ids.ids, (id) ->
                            item = _.find self, {id: id}
                            self.$remove item

                        self.$dispatch 'after-destroy', res


                    this.$send(request, onSuccess)
            Record:
                $createSpe: (spe) ->
                    self = @
                    url = @.$url()
                    spe = Specification.$build(spe).$wrap()
                    request = {
                        method: 'POST',
                        url: "#{url}/specification",
                        data: spe
                    }
                    onSuccess = (res)->
                        self.$dispatch 'specification-create', res

                    this.$send(request, onSuccess)

    }




Specification = (restmod, RMUtils, $Evt) ->
    Specification = restmod.model().mix 'nbRestApi', 'DirtyModel', {
        $config:
            jsonRoot: 'specification'

        $hooks:
            'after-update': ->
                $Evt.$send('position:update:success', "岗位说明书更新成功")

    }

PositionChange = (restmod, RMUtils, $Evt) ->
    PositionChange = restmod.model('/position_changes').mix 'nbRestApi', {
        $config:
            jsonRoot: 'audits'

    }





resources.factory 'Position',['restmod', 'RMUtils', '$nbEvent','Specification', Position]
resources.factory 'Specification',['restmod', 'RMUtils', '$nbEvent', Specification]
resources.factory 'PositionChange',['restmod', 'RMUtils', '$nbEvent', PositionChange]
