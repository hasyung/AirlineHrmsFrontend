# 组织机构
nb = @.nb
app = nb.app


#机构选择树
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

        treeData = scope.treeData.jqTreeful()
        $tree = elem.tree {data: treeData,autoOpen: 0}

        $tree.bind 'tree.select', (evt) ->
            node = evt.node
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


app.directive('nbOrgTree', ['Org', '$parse', orgTree])


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

app.config(Route)


class OrgsCtrl extends nb.Controller
    @.$inject = ['orgs', '$http','$stateParams', '$state', '$scope', '$rootScope', '$nbEvent', 'OrgStore']

    constructor: (@orgs, @http, @params, @state, @scope, @rootScope, @Evt, @OrgStore)->
        @treeRootOrg = _.find @orgs, (org) -> org.xdepth == 1 # 当前树的顶级节点

        @tree = null # tree 化的 orgs 数据
        @currentOrg = @treeRootOrg

        @scope.$onRootScope 'org:refresh', @.refreshTree.bind(@)
        @scope.$onRootScope 'org:resetData', @.resetData.bind(@)

        @buildTree(@treeRootOrg)

    buildTree: (org = @treeRootOrg, depth = 9)->
        depth = 1 if org.xdepth == 1 #如果是顶级节点则只显示一级
        @tree = @orgs.treeful(org, depth)

    refreshTree: () ->
        return unless @treeRootOrg
        depth = 9
        depth = 1 if @treeRootOrg.xdepth == 1 #如果是顶级节点 则只显示一级

        @tree = @orgs.treeful(@treeRootOrg, depth)
        @currentOrg = @treeRootOrg

    # 参数force是否修改当前机构
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

        # 放弃当前修改
        @currentOrg.$restore() if @currentOrg && @currentOrg.$restore
        @currentOrg = _.find(@orgs, {id: orgId})

    revert: (isConfirm) ->
        self = @

        if isConfirm
            @orgs.revert()

            # 是否可以将两步合成一步
            # 即撤销后，后端返回当前机构信息
            @resetData(self.currentOrg)

    active: (evt, data) ->
        self = @

        #deparment_id 是否必要?
        data.department_id = @.treeRootOrg.id

        @orgs.active(data).$then ()->
            self.rootScope.allOrgs.$refresh()

        @resetData()

    resetData: (org) ->
        self = @
        @isHistory = false

        @orgs.$refresh({'edit_mode': true}).$then ()->
            if org
                self.currentOrg = org
            else
                self.treeRootOrg = _.find self.orgs, (org) -> org.xdepth == 1
                self.currentOrg = self.treeRootOrg

            self.OrgStore.reload()

            # 反复划转后情况很复杂
            self.state.go(self.state.current.name, {}, {reload: true})

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

    initVisble: (changeLogs) ->
        _.flatten(_.pluck(changeLogs, 'logs')).forEach (log) ->
            log.visible = true

    pickLog: (date, referOrgName, changeLogs) ->
        sortedLogs = _.flatten(_.pluck(changeLogs, 'logs'))

        _.flatten(_.pluck(changeLogs, 'logs')).forEach (log) ->
                log.visible = false

        if !referOrgName || angular.isUndefined(referOrgName) || referOrgName.length == 0
            referOrgName = null

        if !date || angular.isUndefined(date) || date.length == 0
            date = null
        else
            selectedMoment = moment(date)

        log = _.find sortedLogs, (log) ->
            if date && !referOrgName
                return selectedMoment.isAfter(log.created_at) || selectedMoment.isSame(log.created_at, 'day')

            if !date && referOrgName
                return log.dep_name.indexOf(referOrgName) >= 0

            if referOrgName && referOrgName
                return (selectedMoment.isAfter(log.created_at) || selectedMoment.isSame(log.created_at, 'day')) && log.dep_name.indexOf(referOrgName) >= 0

            else
                return true

        visibleLogs = _.filter sortedLogs, (log) ->
            if date && !referOrgName
                return selectedMoment.isAfter(log.created_at) || selectedMoment.isSame(log.created_at, 'day')

            if !date && referOrgName
                return log.dep_name.indexOf(referOrgName) >= 0

            if referOrgName && referOrgName
                return (selectedMoment.isAfter(log.created_at)|| selectedMoment.isSame(log.created_at, 'day')) && log.dep_name.indexOf(referOrgName) >= 0

            else
                return true


        _.forEach visibleLogs, (log)->
            log.visible = true

        @expandLog(log) if log

    # 返回机构的指定版本
    backToPast: (version)->
        self = @

        if @currentLog
            @orgs.$refresh({version: @currentLog.id}).$then ()->
                self.isHistory = true
                self.treeRootOrg = _.find self.orgs, (org) -> org.xdepth == 1
                self.currentOrg = self.treeRootOrg
                self.buildTree(self.currentOrg)

    expandLog: (log)->
        # 防止UI中出现多个被选中的item
        @currentLog.active = false if @currentLog
        log.active = true
        @currentLog = log

    print: () ->
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
    @.$inject = ['Org', '$stateParams', '$scope', '$rootScope', '$nbEvent', 'Position', 'sweet', '$enum', 'DEPARTMENTS']

    constructor: (@Org, @params, @scope, @rootScope, @Evt, @Position , @sweet, @enum, @DEPARTMENTS) ->
        @state = 'show' # show editing newsub
        @dep_grade_array = @enum.get('department_grades')

        self = @

        @scope.$parent.$watch 'ctrl.currentOrg', (newval)->
            # 监控变化引起的，删除机构会触发
            return if !newval || newval.name == 'org:resetData'
            self.orgLink(newval)

            # 切换后取消编辑模式
            self.state = 'show'

            # 都是show状态，不会触发$watch
            self.$resetGradeList();

        @scope.$watch 'orgCtrl.state', (newval)->
            self.$resetGradeList()

    $resetGradeList: ()->
        self = @
        current_grade_id = @scope.currentOrg.gradeId

        if @state != 'newsub' && @scope.currentOrg.parentId > 0
            #不是新增子机构和父级比较
            parentOrg = _.find @DEPARTMENTS, 'id', @scope.currentOrg.parentId
            current_grade_id = parentOrg.grade.id

        # 过滤机构的职级
        # TODO 没有考虑编辑的事后节点的职级不能比子节点低的情况
        @dep_grade_array = _.filter @enum.get('department_grades'), (item)->
            item.id > current_grade_id


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

        @scope.currentOrg.newSub(neworg).$then ->
            self.state = 'show'

    destroy: (isConfirm) ->
        sweet = @sweet
        $Evt = @Evt
        orgName = @scope.currentOrg.name
        self = @

        if isConfirm
            @scope.currentOrg.$destroy().$then ->
                $Evt.$send 'org:resetData'
                sweet.success('删除成功', "您已成功删除#{orgName}")
        else
            sweet.error("您取消了删除#{@scope.currentOrg.name}")


class PositionCtrl extends nb.Controller
    @.$inject = ['$scope', '$nbEvent', 'Position', '$stateParams', 'Org', 'Specification']

    constructor: (@scope, @Evt, @Position, @stateParams, @Org, @Specification) ->
        @columnDef = [
            {
                displayName: '岗位名称'
                field: 'name'
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
                    {{grid.getCellValue(row, col)}}
                </div>
                '''
            }
            {displayName: '在编', name: 'staffing'}
            {
                displayName: '超/缺编'
                name: 'staffingStatus'
                cellTemplate: '''
                    <div class="ui-grid-cell-contents">
                        <span style="color:blue" ng-if="row.entity.budgetedStaffing > row.entity.staffing">{{row.entity.staffing - row.entity.budgetedStaffing}}</span>
                        <span style="color:red" ng-if="row.entity.budgetedStaffing < row.entity.staffing">{{row.entity.staffing - row.entity.budgetedStaffing}}</span>
                        <span style="color:black" ng-if="row.entity.budgetedStaffing == row.entity.staffing">0</span>
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
            @positions.$adjust({department_id: selectOrg.id, position_ids: selectedPosIds})
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
        newPos = @positions.$create(newPos).$then (newpos)->
            newpos.$createSpe(spe)

    search: (tableState) ->
        tableState = tableState || {}
        tableState['per_page'] = @gridApi.grid.options.paginationPageSize
        @positions.$refresh(tableState)

    searchEmp: (tableState) ->


app.controller('OrgsCtrl', OrgsCtrl)
app.controller('OrgCtrl', OrgCtrl)
app.controller('OrgPosCtrl', PositionCtrl)