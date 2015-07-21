
nb = @.nb
app = nb.app
extend = angular.extend
resetForm = nb.resetForm
Modal = nb.Modal


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


app.directive('nbOrgTree',['Org', '$parse', orgTree])



###*
 * workaround 写法很奇怪, 编译出的 js 很 OK
 * 在单页面应用中， 路由的过程很复杂， 总体来说最核心的是
 * 准备数据
 * 准备模板
 * 实例化控制器，link 模板
 * 切换URL状态， 将页面渲染交给框架
 *
 * 其中数据、模板准备必须在切换URL之前， 不然会引起页面频繁reflow， 凭白损失性能，用户体验也很差
 *
 * 但是数据和业务紧密相关， 天然不能简单的分离为 route 和 controller
 * so, 将它们放在一起是符合逻辑的， 是合理的
 *
 * 更进一步的， 将天然不能分离的东西，仿造后端架构 route controller ，框架提供这样的抽象
 * 那么框架设计本身就不合理， 因为前后端环境不一样， 应另行处理
 *
 * ##PS： 果不其然， angular2 中将概念进一步简化， 将路由放在业务中
 *
###
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

        @tree = null    # tree化的 orgs 数据
        @currentOrg = @treeRootOrg


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

    backToSCAL: () ->
        scal_org =  _.find @orgs, (org) -> org.xdepth == 1 # 四川航空
        @selectOrgChart(scal_org)

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
        self = @
        @isHistory = false
        @orgs.$refresh({'edit_mode': true}).$then ()->
            self.treeRootOrg = _.find self.orgs, (org) -> org.xdepth == 1
            self.currentOrg = self.treeRootOrg

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
                self.treeRootOrg = _.find self.orgs, (org) -> org.xdepth == 1
                self.currentOrg = self.treeRootOrg
    expandLog: (log)->
        # 防止UI中出现多个被选中的item
        @currentLog.active = false if @currentLog
        log.active = true
        @currentLog = log

    print: () ->
        console.log 111
        $svg = $('.svg-wrapper svg')
        sWidth = $svg.attr('width')
        sHeight = $svg.attr('height')
        A4Width = 1123
        A4Height = 670

        if sWidth > A4Width
            $svg.css("transform", "scale(" + A4Width/sWidth + ")")

        $('.svg-wrapper').printArea({
            popWd : 200
            popHt : 200
            mode : "popup"
            popTitle : "机构组织图"
            popClose : false
        })

        $svg.css("transform", "scale(1)")




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


        @columnDef = [
            {
                displayName: '岗位名称'
                field: 'name'
                # pinnedLeft: true
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    <a nb-panel
                        panel-controller="PositionDetailCtrl"
                        template-url="partials/position/position_detail.html"
                        locals="{position: row.entity}">
                        {{grid.getCellValue(row, col)}}
                    </a>
                </div>
                '''
            }
            {displayName: '通道', name: 'channelId', cellFilter: "enum:'channels'"}
            {
                displayName: '编制数'
                name: 'budgetedStaffing'
                cellTemplate: '''
                <div class="ui-grid-cell-contents">
                    {{row.entity.staffing}}/{{grid.getCellValue(row, col)}}
                </div>
                '''
            }
            {displayName: '工作时间', name: 'scheduleId', cellFilter: "enum:'position_schedules'"}
            {displayName: 'OA文件编号', name: 'oaFileNo'}
        ]


    getSelectsIds: () ->
        rows = @scope.$gridApi.selection.getSelectedGridRows()
        rows.map (row) -> return row.entity.$pk

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





