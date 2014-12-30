

nb = @.nb
app = nb.app
# Dialog =  ($modal, $previousState, $rootScope) ->

#     $dialog = (dialogName, controller, templateUrl, options = {}) ->
#         memoName = "#{dialogName}Invoker"
#         $previousState.memo(dialogName) #记住当前 url 状态

#         controller = {controller: controller}
#         templateUrl= {templateUrl: templateUrl}

#         options = angular.extend {}, controller, templateUrl, options

#         modalInstance = $modal.open options

#         modalInstance.result.finally ->
#             $previousState.go(memoName) #恢复之前 url 状态
#             unsubscribe()

#         # 当 URL 改变时自动关闭 dialog
#         unsubscribe =  $rootScope.$on '$stateChangeStart', (evt, toState) ->
#             if !toState.$$state().includes[dialogName]
#                 modalInstance.dismiss('close')


#     # return $dialog
#     return {$dialog: $dialog}


# app.factory '$nbDialog', ['$modal', '$previousState', '$rootScope', Dialog]



#   require: $scope, $previousState, $rootScope, $modalInstance named dialog
#
class Dialog
    constructor: ->

    initialize: (stateName)->
        throw new Error('stateName is required, cause memo current state') unless stateName

        $previousState = @previousState
        $state = @state
        dialog = @dialog
        _.bindAll(@)
        extend(@scope, @)
        invokerName = "#{stateName}Invoker"
        isRefresh = true if @state.includes("*.#{stateName}")

        $previousState.memo(invokerName)

        dialog.result.finally ->
            #BUG? 当已进入父节点状态, 尚未进入子状态, 此时 MEMO 记录的是父状态, 但是状态名URL 为子状态
            #此 BUG 会导致 当 dialog 关闭是 URL 不会回到正确的 URL 上
            #经研究: 路由跳转是解析了
            # home org  org.revert 是从上至下三种状态
            # 路由跳转时依次渲染了3种状态, 但是 state 迁移只触发了 home 与 org.revert 状态, 所以导致此 BUG
            if isRefresh
                $previousState.forget(invokerName)
                $state.go('^')
            else
                $previousState.go(invokerName)
            unsubscribe()

        unsubscribe = @rootScope.$on '$stateChangeStart', (evt, toState) ->
            if !toState.$$state().includes[stateName]
                dialog.dismiss('close')

nb.Dialog = Dialog

