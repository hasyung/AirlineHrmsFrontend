
nb = @.nb
app = nb.app
extend = angular.extend
resetForm = nb.resetForm
Modal = nb.Modal

#机构组织架构图
# orgChart = () ->
#     link = (scope, $el, attrs) ->
#         #
#         #raphael paper
#         paper = null
#         active_rect = null

#         click_handler = (evt, elem) ->
#             # elem.setAttribute("class", 'active')
#             rect = elem[0]
#             if active_rect != null
#                 active_rect.classList.remove('active')
#             rect.classList = _.uniq rect.classList.add 'active'
#             active_rect = rect
#             params = arguments
#             scope.$apply ->
#                 scope.ctrl.onItemClick.apply(scope.ctrl,params)


#         oc_options_2 = {
#             data_id           : 90943,                    # identifies the ID of the "data" JSON object that is paired with these options
#             container         : $el[0],     # name of the DIV where the chart will be drawn
#             box_color         : '#dfe5e7',               # fill color of boxes
#             box_color_hover   : '#cad4d7',               # fill color of boxes when mouse is over them
#             box_border_color  : '#c4cfd3',               # stroke color of boxes
#             box_html_template : null,                 # id of element with template; don't use if you are using the box_click_handler
#             line_color        : '#c4cfd3',               # color of connectors
#             title_color       : '#000',               # color of titles
#             subtitle_color    : '#707',               # color of subtitles
#             max_text_width    : 1,                   # max width (in chars) of each line of text ('0' for no limit)
#             text_font         : 'Courier',            # font family to use (should be monospaced)
#             use_images        : false,                # use images within boxes?
#             box_click_handler : click_handler,        # handler (function) called on click on boxes (set to null if no handler)
#             use_zoom_print    : false,                # wheter to use zoom and print or not (only one graph per web page can do so)
#             debug             : false                 # set to true if you want to debug the library
#         }

#         scope.$watch attrs.orgChartData, (newval ,old) ->
#             if typeof newval == 'undefined'
#                 return
#             if paper?
#                 active_rect = null
#                 paper.remove()
#             data = {id:90943, title: '', root: newval}
#             paper =ggOrgChart.render(oc_options_2, data)
#             active_rect = $el.find('rect').last()[0] #默认选择顶级节点
#             active_rect.classList.add 'active'
#             $el.trigger('resize') # 触发滚动居中
#         return

#     return {
#         restrict: 'A'
#         link: link
#     }

#机构选择树
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

        treeData = scope.treeData.jqTreeful()
        $tree = elem.tree {data: treeData,autoOpen: 0}
        $tree.bind 'tree.select', (evt) ->
            node = evt.node
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


# app.directive('orgChart',[orgChart])
app.directive('nbOrgTree',['Org', '$parse', orgTree])



# workaround 写法很奇怪, 编译出的 js 很 OK
class Route
    @.$inject = ['$stateProvider']

    constructor: (stateProvider) ->

        orgs = (Org)-> Org.$collection().$fetch(edit_mode: true).$asPromise()



        stateProvider
            .state 'org', {
                url: '/orgs'
                templateUrl: 'partials/orgs/orgs.html'
                controller: 'OrgsCtrl'
                controllerAs: 'ctrl'
                resolve: {
                    orgs: orgs
                }
            }



class OrgsCtrl extends nb.Controller


    @.$inject = ['orgs', '$http','$stateParams', '$state', '$scope', '$rootScope', '$nbEvent']


    constructor: (@orgs, @http, @params, @state, @scope, @rootScope, @Evt)->
        @treeRootOrg = _.find @orgs, (org) -> org.xdepth == 1 # 当前树的顶级节点
        @primaryOrgs = orgs.$asList (orgs) -> orgs.filter (org) -> org.xdepth <= 2

        @tree = null    # tree化的 orgs 数据
        @currentOrg = null


        @scope.$onRootScope 'org:refresh', @.refreshTree.bind(@)
        @scope.$onRootScope 'org:resetData', @.resetData.bind(@)

        @buildTree(@treeRootOrg)

    # loadInitialData: () -> #初始化数据
    #     self = @
    #     rootScope = @rootScope
    #     @orgs = @Org.$collection().$fetch({'edit_mode': @eidtMode})
    #         .$then (orgs) ->
    #             treeRootOrg = _.find orgs, (org) -> org.xdepth == 1
    #             self.buildTree(treeRootOrg)
    #             self.treeRootOrg = treeRootOrg


    buildTree: (org = @treeRootOrg, depth = 9)->
        depth = 1 if org.xdepth == 1 #如果是顶级节点 则只显示一级
        # @treeRootOrg = org
        @tree = @orgs.treeful(org, depth)
        #在orgCtrl中会监听该值得变化，用于更新右侧信息
        @currentOrg = org

    refreshTree: () ->
        return unless @treeRootOrg
        depth = 9
        depth = 1 if @treeRootOrg.xdepth == 1 #如果是顶级节点 则只显示一级

        @tree = @orgs.treeful(@treeRootOrg, depth)
        @currentOrg = @treeRootOrg

    #force 是否修改当前机构
    reset: (force) ->
        self = @
        #数据入口不止一个，需要解决
        @orgs.$refresh({edit_mode: @eidtMode}).$then () ->
            self.buildTree()
    queryMatchedOrg: (text) ->
        @orgs.filter (org) -> s.include(org.fullName, text)

    selectOrgChart: (org) ->
        @currentOrg = _.find(@orgs, {id: org.id})
        @treeRootOrg = @orgs.queryPrimaryOrg(@currentOrg)
        @buildTree(@treeRootOrg)

    onItemClick: (evt) -> #机构树 点击事件处理 重构？
        orgId = evt.target
        @currentOrg = _.find(@orgs, {id: orgId})

    revert: (isConfirm) ->
        if isConfirm
            @orgs.revert()
            # 是否可以将两步合成一步
            # 即撤销后，后端返回当前机构信息
            @resetData()

    active: (evt, data) ->
        self = @
        #deparment_id 是否必要?
        data.department_id = @.treeRootOrg.id
        @orgs.active(data).$then ()->
            self.rootScope.allOrgs.$refresh()
        @resetData()

    resetData: () ->
        @isHistory = false
        @orgs.$refresh({'edit_mode': true})

    rootTree: () ->
        treeRootOrg = _.find @orgs, (org) -> org.xdepth == 1
        @buildTree(treeRootOrg)

    initialHistoryData: ->
        onSuccess = (res)->
            logs = res.data.change_logs
            return if logs.length == 0
            groupedLogs = _.groupBy logs, (log) ->
                moment(log.created_at).format('YYYY')
            logsArr = []
            angular.forEach groupedLogs, (yeardLog, key) ->
                logsArr.push {logs:yeardLog, changeYear: key}

            changeLogs = _.sortBy(logsArr, 'changeYear').reverse()

            firstDate = _.last(logs).created_at

            minDate = moment(firstDate).subtract(1,'days').format('DD/MM/YYYY')


            return {
                changeLogs: changeLogs
                minDate: minDate
            }


        promise = @http.get('/api/departments/change_logs')
        promise.then onSuccess

    pickLog: (date, changeLogs) ->

        sortedLogs = _.flatten(_.pluck(changeLogs, 'logs'))
        selectedMoment =  moment(date)
        log = _.find sortedLogs, (log) ->
            return selectedMoment.isAfter(log.created_at)
        @expandLog(log) if log


    # 返回机构的指定版本
    backToPast: (version)->
        self = @
        if @currentLog
            @orgs.$refresh({version: @currentLog.id}).$then ()->
                self.isHistory = true
                self.currentOrg = self.treeRootOrg
    expandLog: (log)->
        # 防止UI中出现多个被选中的item
        @currentLog.active = false if @currentLog
        log.active = true
        @currentLog = log

    # print: () ->
    #     options = {
    #         container: 'org_chart',
    #         pdf_canvas: 'org_chart_print_canvas'
    #         pdf_filename: '机构组织架构图.pdf'
    #         oc_zdp_width_internal: $('svg').width(),
    #         oc_zdp_height_internal: $('svg').height()
    #     }

    #     ggOrgChart.print(options)





class OrgCtrl extends nb.Controller

    @.$inject = ['Org', '$stateParams', '$scope', '$rootScope', '$nbEvent', 'Position', 'sweet']

    constructor: (@Org, @params, @scope, @rootScope, @Evt, @Position , @sweet) ->
        @state = 'show' # show editing newsub
        self = @
        @scope.$parent.$watch 'ctrl.currentOrg', (newval)->
            self.orgLink(newval)

    orgLink: (org)->
        @scope.currentOrg = org
        queryParam = if @scope.ctrl.isHistory then {version: @scope.ctrl.currentLog.id} else {}
        @scope.positions = @scope.currentOrg.positions.$refresh(queryParam)

    transfer: (destOrg) ->
        self = @
        @scope.currentOrg.transfer(destOrg.id).$then ()->
            self.Evt.$send 'org:resetData'

    newsub: (form, neworg) ->
        return if form.$invalid
        self = @
        @scope.currentOrg.newSub(neworg).$then -> self.state = 'show'

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
        # @positions = @scope.panel.data # from parent ctrl
        # @scope.ctrl = this
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

    posTransfer: (selectOrg, isConfirm) -> #将岗位批量划转到另外一个机构下
        return if !isConfirm
        self = @
        selectedPosIds = @getSelectsIds()
        if selectedPosIds.length > 0 && selectOrg
            @positions
                .$adjust({department_id: selectOrg.id, position_ids: selectedPosIds })
        else
            # 通知被划转岗位和目标机构必选
            @Evt.$send "position:transfer:error", "被划转岗位和目标机构必选"

    batchRemove: (isConfirm) ->
        if isConfirm
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
        newPos = @positions.$create(newPos).$then (newpos)->
            newpos.$createSpe(spe)

    search: (tableState) ->
        @positions.$refresh(tableState)
    searchEmp: (tableState) ->



app.config(Route)
app.controller('OrgsCtrl', OrgsCtrl)
app.controller('OrgCtrl', OrgCtrl)
app.controller('OrgPosCtrl', PositionCtrl)





