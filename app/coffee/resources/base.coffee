
resources = angular.module('resources')



nbRestApi = (restmod, RMUtils, $Evt) ->

    Utils = RMUtils

    restmod.mixin {

        created_at: { decode: 'date', param: 'yyyy年mm月dd日',mask: 'CU' }
        updated_at: { decode: 'date', param: 'yyyy年mm月dd日',mask: 'CU' } #不 send CURD 操作时

        $hooks:


            'before-fetch-many': (req) ->
                this.$queryParams = req.params if req.params

        'Model.encodeUrlName': (_name)->
            _name.replace(/[A-Z]/g, "_$&").toLowerCase()

    }


resources.factory 'nbRestApi',['restmod','RMUtils', '$nbEvent', nbRestApi]
