
resources = angular.module('resources')



nbRestApi = (restmod, RMUtils, $Evt) ->

    Utils = RMUtils

    restmod.mixin {

        created_at: { decode: 'date', param: 'yyyy年mm月dd日',mask: 'CU' }
        updated_at: { decode: 'date', param: 'yyyy年mm月dd日',mask: 'CU' } #不 send CURD 操作时

        $hooks:
            'before-request': (_options) ->
                return if !_options.params || !angular.isObject(_options.params)
                _params = _options.params
                params = {}
                angular.forEach _params, (value, key) ->
                    if angular.isArray(value)
                        params[key+"[]"] = value
                    else
                        params[key] = value
                _options.params = params


            'before-fetch-many': (req) ->
                this.$queryParams = req.params if req.params

            # 'after-request-error': (res)->
                # $Evt.$send('global:request:error',res)



        # 'Record.$store': (_patch) ->
        #     self = @
        #     self.$action () ->
        #         url = Utils.joinUrl(self.$url('update'),_patch)

        #         request =
        #             method: 'PATCH'
        #             url: url
        #             data: self.$wrap (_name) -> _patch.indexOf(_name) == -1

        #         onSuccess = (_response) ->
        #             self[_patch] = _response.data

        #         onErorr = (_response) ->
        #             self.$dispatch 'after-store-error', [_response]

        #         @.$send request, onSuccess, onErorr

        # 'Record.$copy': ->
        #     raw = this.$wrap()
        #     if angular.isUndefined(this.$scope.$buildRaw)
        #         copy = _.omit(@, (v, k) -> k[0] == '$' )
        #     # copy = this.$scope.$new(this.$type.inferKey(raw))
        #     # copy.$type.decode(copy, raw, RMUtils.READ_MASK)
        #     # copy.$pk = copy.$type.inferKey(raw)
        #         # copy = this.$new(this.$type.inferKey(raw));
        #     else
        #         copy = this.$scope.$buildRaw(raw)
        #     return copy
        'Model.encodeUrlName': (_name)->
            _name.replace(/[A-Z]/g, "_$&")

    }


resources.factory 'nbRestApi',['restmod','RMUtils', '$nbEvent', nbRestApi]
