

nb = @.nb
app = nb.app


extend = angular.extend



defaultOption = {
    backdrop: true
    keyboard: true
    # size: 'lg' | 'sm'
}

#   require: $scope, $previousState, $rootScope, $modalInstance named dialog
#
class Dialog
    constructor: (dialog, scope, memoName)->
        @initialize(dialog, scope, memoName)

    cancel: (evt, form) ->
        evt.preventDefault()
        form.$setPristine() if form
        @dialog.dismiss('cancel')

    initialize: (dialog, scope, memoName)->
        throw new Error('memoName is required, cause memo current state') unless memoName
        # error: injector 只能注入 provider
        # $injector = angular.injector()
        # $state = $injector.get('$state')
        # $previousState = $injector.get('$previousState')
        # $rootScope = $injector.get('$rootScope')

        $state = @state
        $previousState = @previousState
        $rootScope = @rootScope

        # _.bindAll(@)
        # extend(scope, @) #把controller 方法绑定到 scope 上
        scope.ctrl = @
        invokerName = "#{memoName}Invoker"
        isRefresh = true if $state.includes("*.#{memoName}")

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
            if !toState.$$state().includes[memoName]
                dialog.dismiss('close')


Dialog.$build = (childState, controller, templateUrl, customOptions)->

    options = {
            templateUrl: templateUrl
            controller: controller
            resolve: {
                memoName: ->
                    return childState
            }
        }
    options = extend {}, defaultOption, customOptions, options


    modalOpen = ['$modal', ($modal)->
        $modal.open options
    ]

    return {
        url: "/#{childState}"
        template: '<div ui-view></div>'
        onEnter: modalOpen
    }

nb.Dialog = Dialog

