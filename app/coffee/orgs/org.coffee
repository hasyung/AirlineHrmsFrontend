
nb = @.nb
app = nb.app
extend = angular.extend
resetForm = nb.resetForm
Dialog = nb.Dialog


orgChart = () ->
    link = (scope, $el, attrs) ->
        #
        #raphael paper
        paper = null
        active_rect = null


        click_handler = (evt, elem) ->
            # elem.setAttribute("class", 'active')
            rect = elem[0]
            if active_rect != null
                active_rect.classList.remove('active')
            rect.classList = _.uniq rect.classList.add 'active'
            active_rect = rect
            params = arguments
            scope.$apply ->
                scope.ctrl.onItemClick.apply(scope.ctrl,params)


        oc_options_2 = {
            data_id           : 90943,                    # identifies the ID of the "data" JSON object that is paired with these options
            container         : $el[0],     # name of the DIV where the chart will be drawn
            box_color         : '#dfe5e7',               # fill color of boxes
            box_color_hover   : '#cad4d7',               # fill color of boxes when mouse is over them
            box_border_color  : '#c4cfd3',               # stroke color of boxes
            box_html_template : null,                 # id of element with template; don't use if you are using the box_click_handler
            line_color        : '#c4cfd3',               # color of connectors
            title_color       : '#000',               # color of titles
            subtitle_color    : '#707',               # color of subtitles
            max_text_width    : 1,                   # max width (in chars) of each line of text ('0' for no limit)
            text_font         : 'Courier',            # font family to use (should be monospaced)
            use_images        : false,                # use images within boxes?
            box_click_handler : click_handler,        # handler (function) called on click on boxes (set to null if no handler)
            use_zoom_print    : false,                # wheter to use zoom and print or not (only one graph per web page can do so)
            debug             : false                 # set to true if you want to debug the library
        };

        scope.$watch attrs.orgChartData, (newval ,old) ->
            if typeof newval == 'undefined'
                return
            if paper?
                active_rect = null
                paper.remove()
            data = {id:90943, title: '', root: newval}
            paper =ggOrgChart.render(oc_options_2, data)
            active_rect = $el.find('rect').last()[0] #默认选择顶级节点
            active_rect.classList.add 'active'
            $el.trigger('resize') # 触发滚动居中
        return

    return {
        restrict: 'A'
        link: link
    }

orgTree = (Org, $parse) ->

    postLink = (scope, elem, attrs, $ctrl) ->

        $tree = null
        getData = (node) ->
            data = {}
            for k, v of node
                if (
                    k not in ['parent', 'children', 'element', 'tree'] and
                    Object.prototype.hasOwnProperty.call(node, k)
                )
                    data[k] = v
            return data

        orgs = Org.$search().$then (orgs) ->
            treeData = orgs.jqTreeful()
            $tree = elem.tree {data: treeData,autoOpen: 0}
            $tree.bind 'tree.select', (evt) ->
                if evt.node
                    node = evt.node
                    scope.selectedData = getData(node)
                else
            return
        scope.$on '$destroy', () ->
            $tree.tree('destroy')
            $tree = null

    return {
        scope: {
            selectedData: '='
            # treeData: '@'
        }
        link: postLink
    }


app.directive('orgChart',[orgChart])
app.directive('nbOrgTree',['Org', '$parse', orgTree])



# workaround 写法很奇怪, 编译出的 js 很 OK
class Route
    @.$inject = ['$stateProvider']

    constructor: (stateProvider, $dialog) ->


        # states  = []

        # states.push name: 'orgs', url: '/orgs', abstract: true, controller: 'OrgsCtrl', views: {}

        # sta

    # $dialog = (dialogName, controller, templateUrl, options = {}) ->
    #     memoName = "#{dialogName}Invoker"
    #     $previousState.memo(dialogName) #记住当前 url 状态

    #     controller = {controller: controller}
    #     templateUrl= {templateUrl: templateUrl}

    #     options = angular.extend {}, controller, templateUrl, options

    #     modalInstance = $modal.open options

    #     modalInstance.result.finally ->
    #         $previousState.go(memoName) #恢复之前 url 状态
    #         unsubscribe()

    #     # 当 URL 改变时自动关闭 dialog
    #     unsubscribe =  $rootScope.$on '$stateChangeStart', (evt, toState) ->
    #         if !toState.$$state().includes[dialogName]
    #             modalInstance.dismiss('close')


    # # return $dialog
    # return {$dialog: $dialog}




        stateProvider
            .state 'org', {
                url: '/orgs'
                templateUrl: 'partials/orgs/orgs.html'
                controller: 'OrgsCtrl'
                controllerAs: 'ctrl'
                resolve: {
                    eidtMode: ->
                        return true
                }
            }
            .state 'org.revert', Dialog.$build('revert', RevertChangesCtrl, 'partials/orgs/shared/revert_changes.html')
            .state 'org.active', Dialog.$build('active', ActiveCtrl, 'partials/orgs/shared/effect_changes.html')
            .state 'org.history', Dialog.$build('history', HistoryCtrl, 'partials/orgs/org_history.html', {size: 'sm'})
            .state 'org.transfer', Dialog.$build('transfer', TransferOrgCtrl, 'partials/orgs/shared/org_transfer.html', {size: 'sm'})








class OrgsCtrl extends nb.Controller


    @.$inject = ['Org', '$http','$stateParams', '$state', '$scope', '$modal', '$panel', '$rootScope', '$nbEvent', 'eidtMode']


    constructor: (@Org, @http, @params, @state, @scope, @modal, @panel, @rootScope, @Evt, @eidtMode)->
        @treeRootOrg = null # 当前树的顶级节点
        @orgs = null    #集合
        @tree = null    # tree化的 orgs 数据
        @scope.currentOrg = null
        #for ui status
        @isBarOpen = true

        @loadInitialData()


        scope.$onRootScope 'org:revert', @.revert.bind(@)
        scope.$onRootScope 'org:active', @.active.bind(@)
        scope.$onRootScope 'org:history', @.history.bind(@)
        scope.$onRootScope 'org:refresh', @.refreshTree.bind(@)

    loadInitialData: () -> #初始化数据
        self = @
        rootScope = @rootScope
        Evt = @Evt
        @orgs = @Org.$search({'edit_mode': @eidtMode})
            .$then (orgs) ->
                treeRootOrg = _.find orgs, (org) -> org.depth == 1
                Evt.$send('org:link', treeRootOrg)
                self.buildTree(treeRootOrg)
                self.treeRootOrg = treeRootOrg

    buildTree: (org = @treeRootOrg, depth = 9)->
        depth = 1 if org.depth == 1 #如果是顶级节点 则只显示一级
        @treeRootOrg = org
        @tree = @orgs.treeful(org, depth)
    refreshTree: () ->
        return unless @treeRootOrg
        depth = 9
        depth = 1 if @treeRootOrg.depth == 1 #如果是顶级节点 则只显示一级
        @tree = @orgs.treeful(@treeRootOrg, depth)

    #force 是否修改当前机构
    reset: (force) ->
        self = @
        #数据入口不止一个，需要解决
        @orgs.$refresh({edit_mode: @eidtMode}).$then () ->
            self.buildTree()
            # self.rootScope.$emit('orgs:link', _.find(@orgs, {id: orgId}))

    onItemClick: (evt, elem) -> #机构树 点击事件处理 重构？
        orgId = elem.oc_id
        currentOrg = _.find(@orgs, {id: orgId})
        @Evt.$send('org:link', currentOrg)

    revert: () ->
        @Org.$revert()

    active: (evt, data) ->
        #deparment_id 是否必要?
        data.department_id = @.treeRootOrg.id
        @orgs.active(data)


    history: (evt, history_param) ->
        @isHistory = true
        promise  = @orgs.$refresh(history_param).$asPromise()
        promise.then @buildTree.bind(@)
    recovery_now: () ->
        @isHistory = false
        @orgs.$refresh({'edit_mode': @eidtMode}).$then @buildTree.bind(@)

    # openPositionPanel: (orgId) ->
    #     self = @
    #     panel = @panel.open {
    #         templateUrl: 'partials/orgs/position.html'
    #         controller: PositionCtrl
    #         controllerAs: 'pos'
    #     }

    openOrgtreeDialog: () ->
        self = @
        dialog = @modal.open {
            templateUrl: 'partials/orgs/shared/org_transfer.html'
            controller: TransferOrgCtrl
            controllerAs: 'trs'
            backdrop: true
            size: 'sm'
        }
        dialog.result.then (dest_org) ->
            self.scope.currentOrg.transfer(dest_org.id).then () ->
                self.reset(true)
                self.scope.$emit("success", "划转机构成功")


class OrgCtrl extends nb.Controller

    @.$inject = ['Org', '$stateParams', '$scope', '$rootScope', '$nbEvent']

    constructor: (@Org, @params, @scope, @rootScope, @Evt) ->
        @state = 'show' # show editing newsub
        # @scope.org = @Org.$find(@params.orgId)
        scope.$onRootScope 'org:link', @.orgLink.bind(@)
        Evt.$on.call(scope,['org:update:success','org:update:error','org:newsub:success','org:newsub:error'], @.reset.bind(@))
        scope.$onRootScope 'org:transfer', @.transfer.bind(@)


    orgLink: (evt, org)->
        @scope.currentOrg = org
        @scope.copyOrg = org.$copy()

    cancel: ->
        @state = 'show'

    # destory: ->
    #     self = @
    #     Evt = @Evt
    #     onSuccess = ->

    #     @scope.org.$destroy().$then onSuccess
    transfer: (evt, destOrg) ->
        @scope.currentOrg.transfer(destOrg.id)

    newsub: (form, neworg) ->
        $Evt = @Evt
        @scope.currentOrg.newSub(neworg).$then ->
            $Evt.$send 'org:newsub', form



    update: (form, copyOrg) ->
        @scope.currentOrg.$update(copyOrg)

    reset: (evt)->
        scope = @scope
        scope.neworg = {}
        scope.copyOrg = @scope.currentOrg.$copy()
        resetForm(scope.newsubForm, scope.updateForm)
        @state = 'show'

    # newSub: (org) ->
    #     @scope.org.newSub(org)


class RevertChangesCtrl extends Dialog
    @.$inject = ['$modalInstance','$scope', '$nbEvent', 'memoName', '$rootScope', '$previousState', '$state']

    constructor: (@dialog, @scope, @Evt, @memoName, @rootScope, @previousState, @state) ->
        super(dialog,scope,memoName) #必须调用父类构造器, 传入 dialog 实例, 当前 scope, memoname

    close: (formdata)->
        @Evt.$send('org:revert')
        @dialog.close()


class ActiveCtrl extends Dialog
    @.$inject = ['$modalInstance', '$scope', '$nbEvent','memoName', '$rootScope', '$previousState', '$state']
    constructor: (@dialog, @scope, @Evt, @memoName, @rootScope, @previousState, @state) ->
        super(dialog, scope, memoName)
    active: (log, form) ->
        @Evt.$send('org:active',log)
        @dialog.close()

class HistoryCtrl extends Dialog
    @.$inject = ['$modalInstance', '$scope', '$nbEvent','memoName', '$rootScope', '$previousState', '$state', '$http']
    constructor: (@dialog, @scope, @Evt, @memoName, @rootScope, @previousState, @state, @http) ->
        @loadInitialData()
        super(dialog, scope, memoName)

    loadInitialData: ()->
        onError = (res)->
            @Evt.$send('org:history:error',res)
        onSuccess = (res)->
            logs = res.data.change_logs
            groupedLog = _.groupBy logs, (log) ->
                # 还是UNIX时间戳转js时间
                log.created_at = parseInt(log.created_at) * 1000
                # 后端返回的一些数据是以";"结尾, 那么split之后数组的最后一项将为undefined
                if /.*;$/.test(log.step_desc)
                    log.step_desc = log.step_desc.substring(0, log.step_desc.length - 1)
                log.step_desc = log.step_desc.split(';')
                #Unix 时间戳转普通时间要乘1000 ，Date内部处理是按毫秒
                return new Date(log.created_at).getFullYear()
            # 将对象转换为数组,待优化后期会整合为filter
            groupedLogs = []
            angular.forEach groupedLog, (item, key) ->
                groupedLogs.push {logs:item, changeYear: key}
            #转换结束

            @scope.changeLogs = groupedLogs.reverse()
        promise = @http.get('/api/departments/change_logs')
        promise.then onSuccess.bind(@), onError.bind(@)

    expandLog: (log)->
        # 防止UI中出现多个被选中的item
        @currentLog.active = false if @currentLog
        log.active = true
        @currentLog = log

    submit: ()->
        # self = @
        # onError = (res)->
        #     self.scope.emit 'error', res
        #     self.dialog.close()
        # onSuccess = (res)->
        #     res.$metadata.created_at = parseInt(res.$metadata.created_at) * 1000
        #     self.dialog.close({ historyOrgs: res})
        # promise = self.Org.$search {version: self.currentLog.id}
        # promise.$then onSuccess, onError
        @Evt.$send('org:history', {version: @currentLog.id}) if @currentLog
        @dialog.close()


class TransferOrgCtrl extends Dialog
    @.$inject = ['$modalInstance', '$scope', '$nbEvent','memoName', '$rootScope', '$previousState', '$state', '$http']
    constructor: (@dialog, @scope, @Evt, @memoName, @rootScope, @previousState, @state, @http) ->
        super(dialog, scope, memoName)
        @selectedData = null

    ok: () ->
        @Evt.$send('org:transfer',@selectedData)
        @dialog.close()

# 机构历史记录

# # 机构历史记录
# class HistoryCtrl
#     @.$inject = ['$modalInstance', '$scope', '$http', 'Org']
#     constructor: (@dialog, @scope, @http, @Org) ->
#         self = @
#         @changeLogs = null
#         @currentLog = null
#         @historyOrgs = null
#         @loadInitialData()



#     loadInitialData: ()->
#         self = @
#         onError = (res)->
#             self.scope.emit 'error', res
#         onSuccess = (res)->
#             logs = res.data.change_logs
#             groupedLog = _.groupBy logs, (log) ->
#                 # 还是UNIX时间戳转js时间
#                 log.created_at = parseInt(log.created_at) * 1000
#                 # 后端返回的一些数据是以";"结尾, 那么split之后数组的最后一项将为undefined
#                 if /.*;$/.test(log.step_desc)
#                     log.step_desc = log.step_desc.substring(0, log.step_desc.length - 1)
#                 log.step_desc = log.step_desc.split(';')
#                 #Unix 时间戳转普通时间要乘1000 ，Date内部处理是按毫秒
#                 return new Date(log.created_at).getFullYear()
#             # 将对象转换为数组,待优化后期会整合为filter
#             groupedLogs = []
#             angular.forEach groupedLog, (item, key) ->
#                 groupedLogs.push {logs:item, changeYear: key}
#             #转换结束

#             self.changeLogs = groupedLogs.reverse()
#         promise = self.http.get('/api/departments/change_logs')
#         promise.then onSuccess, onError


#     setCurrentLog: (log)->
#         # 防止UI中出现多个被选中的item
#         if @currentLog
#             @currentLog.isActive = false
#         log.isActive = true
#         @currentLog = log
#     ok: ()->
#         self = @
#         onError = (res)->
#             self.scope.emit 'error', res
#             self.dialog.close()
#         onSuccess = (res)->
#             res.$metadata.created_at = parseInt(res.$metadata.created_at) * 1000
#             self.dialog.close({ historyOrgs: res})
#         promise = self.Org.$search {version: self.currentLog.id}
#         promise.$then onSuccess, onError

#     cancel: ()->
#         @dialog.dismiss('cancel')

# 撤销提示框



# class EffectChangesCtrl
#     @.$inject = ['$modalInstance', '$scope']

#     constructor: (@dialog, @scope) ->
#         @scope.log = {}

#     ok: (formdata)->
#         @dialog.close(@scope.log)

#     cancel: (evt,form)->
#         evt.preventDefault()
#         @scope.log = {}
#         form.$setPristine()
#         @dialog.dismiss('cancel')

class PositionCtrl extends nb.Controller



app.config(Route)
app.controller('OrgsCtrl', OrgsCtrl)
app.controller('OrgCtrl', OrgCtrl)





