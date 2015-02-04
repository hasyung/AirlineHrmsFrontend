
nb = @.nb
app = nb.app
extend = angular.extend
resetForm = nb.resetForm
Modal = nb.Modal


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
        }

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

        # getter = $parse('org')
        # setter = getter.assign

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

        setOrgRoute = (node) ->
            orgRoute = []
            orgRoute.push node

            while node.parent && node.parent.parent_id != 0
                node = node.parent
                orgRoute.push node

            orgRoute.reverse()
            nameArr = _.map orgRoute, 'name'

            return nameArr.join('-')

        # $ctrl.$formatters.push (value)->
        #     if value
        #         return setOrgRoute value


        treeData = scope.treeData.jqTreeful()
        $tree = elem.tree {data: treeData,autoOpen: 0}
        $tree.bind 'tree.select', (evt) ->
            node = evt.node
            node.custStr = setOrgRoute node
            # setter(scope, getData(node).id)
            $ctrl.$setViewValue(getData(node))


        scope.$on '$destroy', () ->
            $tree.tree('destroy') if $tree && $tree.tree #for nest router
            $tree = null

    return {
        scope: {
            org: "=ngModel"
            treeData: '='
        }
        require: 'ngModel'
        link: postLink
    }


app.directive('orgChart',[orgChart])
app.directive('nbOrgTree',['Org', '$parse', orgTree])



# workaround 写法很奇怪, 编译出的 js 很 OK
class Route
    @.$inject = ['$stateProvider']

    constructor: (stateProvider) ->


        stateProvider
            .state 'org', {
                url: '/orgs'
                templateUrl: 'partials/orgs/orgs.html'
                controller: 'OrgsCtrl'
                controllerAs: 'ctrl'
                ncyBreadcrumb: {
                    label: "机构"
                }
                resolve: {
                    eidtMode: ()->
                        return true
                }
            }
            # .state 'org.revert', Dialog.$build('revert', RevertChangesCtrl, 'partials/orgs/shared/revert_changes.html')
            # .state 'org.active', nb.$buildDialog('active', ActiveCtrl, 'partials/orgs/shared/effect_changes.html')
            # .state 'org.history', nb.$buildDialog('history', HistoryCtrl, 'partials/orgs/org_history.html', {size: 'sm'})
            # .state 'org.transfer', nb.$buildDialog('transfer', TransferOrgCtrl, 'partials/orgs/shared/org_transfer.html', {size: 'sm'})
            # .state 'org.position', nb.$buildPanel(':id/positions',PositionCtrl, 'partials/orgs/position.html')
            # .state nb.$buildDialog {
            #     name: 'org.active'
            #     url: '/active'
            #     controller: ActiveCtrl
            #     templateUrl: 'partials/orgs/shared/effect_changes.html'
            # }
            # .state nb.$buildDialog {
            #     name: 'org.history'
            #     url:' /history'
            #     controller: HistoryCtrl
            #     templateUrl: 'partials/orgs/org_history.html'
            #     size: 'sm'
            # }
            # .state nb.$buildDialog {
            #     name: 'org.transfer'
            #     url: '/transfer'
            #     controller: TransferOrgCtrl
            #     templateUrl: 'partials/orgs/shared/org_transfer.html'
            #     size: 'sm'
            # }
            .state {
                name: 'org.position'
                url: '/:id/positions'
                controller: PositionCtrl
                views: {
                    "@": {
                        controller: PositionCtrl
                        controllerAs: 'ctrl'
                        templateUrl: 'partials/orgs/position.html'
                    }
                }
                ncyBreadcrumb: {
                    label: "{{ ctrl.currentOrg.name || '岗位' }}"
                }
            }
            # .state {
            #     name: 'org.position.detail'
            #     url: '/{posId:[0-9]+}'
            #     views: {
            #         "@": {
            #             controller: PosCtrl
            #             controllerAs: 'ctrl'
            #             templateUrl: 'partials/orgs/position_detail.html'
            #         }
            #     }
            #     ncyBreadcrumb: {
            #         label: "{{currentPos.name}}"
            #     }
            # }
            # .state {
            #     name: 'org.position.detail.editing'
            #     url: '/editing/:template'
            #     views: {
            #         "@": {
            #             controller: PosCtrl
            #             controllerAs: 'ctrl'
            #             templateUrl: (params) ->
            #                 return "partials/orgs/position_edit_#{params.template}.html"
            #         }
            #     }
            #     ncyBreadcrumb: {
            #         label: "编辑"
            #     }
            # }
            # .state {
            #     name: 'org.position.new'
            #     url: '/new'
            #     views: {
            #         "@": {
            #             controller: PosCreateCtrl
            #             controllerAs: 'ctrl'
            #             templateUrl: 'partials/orgs/position_add.html'
            #         }
            #     }
            #     ncyBreadcrumb: {
            #         label: "新增"
            #     }
            # }



            # nb.$buildPanel {
            #     name: 'org.position'
            #     url: ':id/positions'
            #     controller: PositionCtrl
            #     templateUrl: 'partials/orgs/position.html'
            # }




class OrgsCtrl extends nb.Controller


    @.$inject = ['Org', '$http','$stateParams', '$state', '$scope', '$modal', '$panel', '$rootScope', '$nbEvent', 'eidtMode']


    constructor: (@Org, @http, @params, @state, @scope, @modal, @panel, @rootScope, @Evt, @eidtMode)->
        @treeRootOrg = null # 当前树的顶级节点
        @orgs = null    #集合
        @tree = null    # tree化的 orgs 数据
        #for ui status
        @isBarOpen = false

        @loadInitialData()


        scope.$onRootScope 'org:active', @.active.bind(@)
        scope.$onRootScope 'org:refresh', @.refreshTree.bind(@)
        scope.$onRootScope 'org:resetData', @.resetData.bind(@)

    loadInitialData: () -> #初始化数据
        self = @
        rootScope = @rootScope
        Evt = @Evt
        @orgs = @Org.$collection().$fetch({'edit_mode': @eidtMode})
            .$then (orgs) ->
                treeRootOrg = _.find orgs, (org) -> org.depth == 1
                self.buildTree(treeRootOrg)
                self.treeRootOrg = treeRootOrg

    buildTree: (org = @treeRootOrg, depth = 9)->
        depth = 1 if org.depth == 1 #如果是顶级节点 则只显示一级
        @treeRootOrg = org
        @tree = @orgs.treeful(org, depth)
        currentOrg = org
        @Evt.$send('org:link', currentOrg)

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
        @orgs.revert()
        # 是否可以将两步合成一步
        # 即撤销后，后端返回当前机构信息
        @resetData()

    active: (evt, data) ->
        #deparment_id 是否必要?
        data.department_id = @.treeRootOrg.id
        @orgs.active(data)
        @resetData()

    resetData: () ->
        self = @
        @isHistory = false
        @orgs.$refresh({'edit_mode': @eidtMode})

    rootTree: () ->
        self = @
        treeRootOrg = _.find self.orgs, (org) -> org.depth == 1
        self.buildTree(treeRootOrg)
    initialHistoryData: ->
        onSuccess = (res)->
            logs = res.data.change_logs
            groupedLogs = _.groupBy logs, (log) ->
                moment.unix(log.created_at).format('YYYY')
            logsArr = []
            angular.forEach groupedLogs, (item, key) ->
                logsArr.push {logs:item, changeYear: key}

            changeLogs = _.sortBy(logsArr, 'changeYear').reverse()

        promise = @http.get('/api/departments/change_logs')
        promise.then onSuccess
    # 返回机构的指定版本
    backToPast: (version)->
        self = @
        if @currentLog
            self.orgs.$refresh({version: @currentLog.id})
        @isHistory = true
    expandLog: (log)->
        # 防止UI中出现多个被选中的item
        @currentLog.active = false if @currentLog
        log.active = true
        @currentLog = log




class OrgCtrl extends nb.Controller

    @.$inject = ['Org', '$stateParams', '$scope', '$rootScope', '$nbEvent', 'Position', 'sweet']

    constructor: (@Org, @params, @scope, @rootScope, @Evt, @Position , @sweet) ->
        @state = 'show' # show editing newsub
        # @scope.org = @Org.$find(@params.orgId)
        scope.$onRootScope 'org:link', @.orgLink.bind(@)
        Evt.$on.call(scope,['org:update:success','org:update:error','org:newsub:success','org:newsub:error'], @.reset.bind(@))
        scope.$onRootScope 'org:transfer', @.transfer.bind(@)


    orgLink: (evt, org)->
        @scope.currentOrg = org
        @scope.copyOrg = org.$copy()
        @scope.positions = @scope.currentOrg.positions.$refresh()

    cancel: ->
        @state = 'show'


    transfer: (destOrg) ->
        self = @
        @scope.currentOrg.transfer(destOrg.id).$then ()->
            self.Evt.$send 'org:resetData'

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

    destroy: (isConfirm) ->
        sweet = @sweet
        $Evt = @Evt
        orgName = @scope.currentOrg.name

        if isConfirm
            @scope.currentOrg.$destroy().$then ->
                $Evt.$send 'org:resetData'
                sweet.success('删除成功', "您已成功删除#{orgName}" )
        else
            sweet.error("您取消了删除#{@scope.currentOrg.name}")


class PositionCtrl extends nb.Controller
    @.$inject = ['$scope', '$nbEvent', 'Position', '$stateParams', 'Org', 'Specification']
    constructor: (@scope, @Evt, @Position, @stateParams, @Org, @Specification) ->
        @positions = scope.ngDialogData # from parent ctrl
        scope.ctrl = this
        # orgId = @stateParams.id
        # @currentOrg = Org.$find(orgId)
        # @positions = @currentOrg.positions.$fetch()
        # @selectOrg = null # 划转所选择的机构 rework
        # @scope.allSelect = false
        # @scope.$onRootScope 'position:refresh', @.resetData.bind(@)

    getSelectsIds: ()->
        @positions
            .filter (pos) -> return pos.isSelected
            .map (pos) -> return pos.id

    posTransfer: () -> #将岗位批量划转到另外一个机构下
        self = @
        selectedPosIds = @getSelectsIds()
        if selectedPosIds.length > 0 && @selectOrg
            @positions
                .$adjust({department_id: @selectOrg.id, position_ids: selectedPosIds })
            self.selectOrg = null
        else
            # 通知被划转岗位和目标机构必选
            @Evt.$send "position:transfer:error", "被划转岗位和目标机构必选"

    batchRemove: () ->
        if @getSelectsIds().length != 0
            @positions.$batchRemove({ids:@getSelectsIds()})
        else
            @Evt.$send "position:remove:error", "你还没选择所要删除的岗位"

    getExportParams: (id) ->
        ids = @getSelectsIds()
        if ids.length == 0
            return 'department_id=' + id
        else
            return 'department_id=' + id  + '&position_ids=' + ids.join(',')
    createPos: (newPos, spe) ->
        # self = @
        # @position.departmentId = @orgId
        # @position.specification = @specification
        #将页面跳转放在then里，防止当跳转过去时新创建的岗位未被添加到岗位列表
        # newPos.specification = @Specification.$buildRaw(spe)
        # newPos.specification = spe
        #bug, 
        newPos = @positions.$create(newPos).$then (newpos)-> newpos.specification.$update(spe)

    search: (tableState) ->
        @positions.$refresh(tableState)



# class PosCtrl extends nb.Controller
#     @.$inject = ['$stateParams', 'Position', '$scope', '$state', 'Org']

#     constructor: (@params, @Position, @scope, @state, @Org) ->
#         @loadInitialData()
#     loadInitialData: () ->
#         self = @
#         orgId = @params.id
#         posId = @params.posId
#         @Position.$find(posId).$then (position) ->
#             self.scope.currentPos = position
#             # self.scope.copyPos = position.$copy()

#             spe = position.specification.$fetch()
#             spe.$asPromise().then (spe) ->
#                 self.scope.currentSpe = spe
#                 # self.scope.copySpe = spe.$copy()


#         @scope.currentOrg = @Org.$find orgId

#     updateDetail: (position) ->
#         position.$save()
#     updateAdvanced: (advance) ->
#         @scope.currentSpe.$update(advance)



# class PosCreateCtrl extends nb.Controller
#     @.$inject = ['$stateParams', 'Position', '$scope', 'Org']

#     constructor: (@params, @Position, @scope, @Org) ->
#         @orgId = @params.id
#         @loadInitialData()

#     loadInitialData: () ->
#         @scope.currentOrg = @Org.$find @orgId
#     createPos: () ->
#         self = @
#         @position.departmentId = @orgId
#         @position.specification = @specification
#         #将页面跳转放在then里，防止当跳转过去时新创建的岗位未被添加到岗位列表
#         newPos = @Position.$create(@position)
#     store: (attr, value) ->
#         this[attr] = value





app.config(Route)
app.controller('OrgsCtrl', OrgsCtrl)
app.controller('OrgCtrl', OrgCtrl)
app.controller('OrgPosCtrl', PositionCtrl)





