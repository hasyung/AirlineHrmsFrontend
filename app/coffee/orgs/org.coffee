
nb = @.nb
app = nb.app



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

            scope.ctrl.onItemClick.apply(scope.ctrl,arguments)


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
        # require: 'ngModel'
        scope: {
            selectedData: '='
        }
        link: postLink

    }


app.directive('orgChart',[orgChart])
app.directive('nbOrgTree',['Org', '$parse', orgTree])



# workaround 写法很奇怪, 编译出的 js 很 OK
class Route
    @.$inject = ['$stateProvider']

    constructor: (stateProvider) ->


        # states  = []

        # states.push name: 'orgs', url: '/orgs', abstract: true, controller: 'OrgsCtrl', views: {}

        # sta



        stateProvider
            .state 'org', {
                url: '/orgs'
                # abstract: true
                templateUrl: 'partials/orgs/orgs.html'
                controller: 'OrgsCtrl'
                controllerAs: 'ctrl'
                resolve: {
                    eidtMode: ->
                        return true
                }
            }
            # .state 'org.show', {
            #     url: '/:orgId'
            #     views: {
            #         'sub': {
            #             templateUrl: 'partials/orgs/org.html'
            #         }
            #     }
            # }
            .state 'org_history', {
                url: '/orgs/history'
                abstract: true
                templateUrl: 'partials/orgs/org.html'
                controller: 'OrgsCtrl'
                controllerAs: 'orgsCtrl'
            }
            .state 'org_history.show', {
                url: '/:orgId'
                views: {
                    'sub': {
                        templateUrl: 'partials/orgs/org_detail.html'
                    }
                }
            }
            # .state 'org.newsub', {
            #     url: '/:parentId/newsub'
            #     views: {
            #         'sub': {
            #             templateUrl: 'partials/orgs/org_newsub.html'
            #         }
            #     }
            # }
            # .state 'org.edit', {
            #     url: '/:orgId/edit'
            #     views: {
            #         'sub': {
            #             templateUrl: 'partials/orgs/org_edit.html'
            #             controller: 'OrgController'
            #         }
            #     }
            # }




class OrgsCtrl extends nb.Controller


    @.$inject = ['Org', '$http','$stateParams', '$state', '$scope', '$modal', '$panel', '$rootScope', 'eidtMode']


    constructor: (@Org, @http, @params, @state, @scope, @modal, @panel, @rootScope, @eidtMode)->
        console.debug @

        self = @
        @treeRootOrg = null # 当前树的顶级节点
        @orgs = null    #集合
        #for ui status
        @isBarOpen = true

        @loadInitialData()
    # deleteOrg: (orgId)-> #删除机构
    #     self = @
    #     onSuccess = ->
    #         self.reset()
    #         self.scope.$emit('success',"机构：#{self.scope.currentOrg.name} ,删除成功")

    #     onError = (data, status)->
    #         self.scope.$emit 'error', "机构：#{self.scope.currentOrg.name} ,删除失败,请确保当前没有子机构，同时该机构岗位要为空"

    #     self.scope.currentOrg.$destroy().$then onSuccess, onError


    loadInitialData: () -> #初始化数据
        self = @
        rootScope = @rootScope
        @orgs = @Org.$search({'edit_mode': @eidtMode})
            .$then (orgs) ->
                treeRootOrg = _.find orgs, (org) -> org.depth == 1
                rootScope.$emit('orgs:link',treeRootOrg)
                self.buildTree(treeRootOrg)
                self.treeRootOrg = treeRootOrg

    buildTree: (org = @treeRootOrg, depth = 9)->
        depth = 1 if org.depth == 1 #如果是顶级节点 则只显示一级
        @treeRootOrg = org
        @tree = @orgs.treeful(org, depth)

    #force 是否修改当前机构
    reset: (force) ->
        self = @
        #数据入口不止一个，需要解决
        @orgs.$refresh({edit_mode: @eidtMode}).$then () ->
            self.buildTree()
            # self.rootScope.$emit('orgs:link', _.find(@orgs, {id: orgId}))

    onItemClick: (evt, elem) -> #机构树 点击事件处理 重构？
        orgId = elem.oc_id
        # @state.go('^.show',{orgId: orgId})
        @rootScope.$emit('orgs:link', _.find(@orgs, {id: orgId}))

    revert: () ->
        self = @
        onSuccess = ->
            self.reset(true)
            self.scope.$emit 'success', '撤销成功'

        onError = (data, status)->
            self.scope.$emit 'error', "#{data.message}"

        dialog = @modal.open {
            templateUrl: 'partials/orgs/shared/revert_changes.html'
            controller: RevertChangesCtrl
            controllerAs: 'rev'
            backdrop: true
            size: 'sm'
        }
        dialog.result.then () ->
            promise = self.http.post '/api/departments/revert'
            promise.then onSuccess, onError


    active: (form, data) ->
        self = @
        rootScope = @rootScope
        onSuccess = ->
            self.reset(true)
            rootScope.loading = false
            self.scope.$emit 'success', '更改已生效'

        onError = (data, status)->
            self.scope.$emit 'error', "#{data.message}"

        dialog = @modal.open {
            templateUrl: 'partials/orgs/shared/effect_changes.html'
            controller: EffectChangesCtrl
            controllerAs: 'eff'
        }
        dialog.result.then (formdata) ->
            #todo,以后需要讨论
            formdata.department_id = self.treeRootOrg.id
            rootScope.loading = true
            promise = self.http.post '/api/departments/active', formdata
            promise.then onSuccess, onError


    openPositionPanel: (orgId) ->

        self = @
        panel = @panel.open {
            templateUrl: 'partials/orgs/position.html'
            controller: PositionCtrl
            controllerAs: 'pos'
        }

    openHistoryDialog: () ->
        self = @
        dialog = @modal.open {
            templateUrl: 'partials/orgs/org_history.html'
            controller: HistoryCtrl
            controllerAs: 'his'
            backdrop: true
            size: 'sm'
            backdropClass: 'org-history-dialog-backdrop'
        }
        dialog.result.then (data) ->
            # self.isHistory = true
            self.orgs = data.historyOrgs
            self.buildTree()
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
            self.scope.currentOrg.transfer(dest_org.id).then ()->
                self.reset(true)
                self.scope.$emit("success", "划转机构成功")


class OrgCtrl extends nb.Controller

    @.$inject = ['Org', '$stateParams', '$scope', '$rootScope']

    constructor: (@Org, @params, @scope, @rootScope) ->
        @state = 'show' # show editing newsub
        # @scope.org = @Org.$find(@params.orgId)
        @scope.org = null

        @scope.$onRootScope 'orgs:link', (evt, org) ->
            # org = org.$wrap()
            scope.org = org
            copy = Org.$buildRaw(org.$wrap())
            # org.$update(copy)
    cancel: ->
        @state = 'show'


    reload: (org) ->
        @scope.org = org
    destory: ->
        self = @
        onSuccess = ->
            self.scope.$emit('success',"机构：#{self.scope.currentOrg.name} ,删除成功")



        @scope.org.$destroy().$then
    update: (org) ->
        org.$save()
    newSub: (org) ->
        @scope.org.newSub(org)






class TransferOrgCtrl
    @.$inject = ['$modalInstance', '$scope', '$http', 'Org']

    constructor: (@dialog, @scope, @http, @Org) ->
        @selectedData = null

    ok: () ->
        @dialog.close(@selectedData)
    cancel: () ->
        @dialog.dismiss('close')


# 机构历史记录

# 机构历史记录
class HistoryCtrl
    @.$inject = ['$modalInstance', '$scope', '$http', 'Org']
    constructor: (@dialog, @scope, @http, @Org) ->
        self = @
        @changeLogs = null
        @currentLog = null
        @historyOrgs = null
        @loadInitialData()



    loadInitialData: ()->
        self = @
        onError = (res)->
            self.scope.emit 'error', res
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

            self.changeLogs = groupedLogs.reverse()
        promise = self.http.get('/api/departments/change_logs')
        promise.then onSuccess, onError


    setCurrentLog: (log)->
        # 防止UI中出现多个被选中的item
        if @currentLog
            @currentLog.isActive = false
        log.isActive = true
        @currentLog = log
    ok: ()->
        self = @
        onError = (res)->
            self.scope.emit 'error', res
            self.dialog.close()
        onSuccess = (res)->
            res.$metadata.created_at = parseInt(res.$metadata.created_at) * 1000
            self.dialog.close({ historyOrgs: res})
        promise = self.Org.$search {version: self.currentLog.id}
        promise.$then onSuccess, onError

    cancel: ()->
        @dialog.dismiss('cancel')

# 撤销提示框

class RevertChangesCtrl
    @.$inject = ['$modalInstance']
    constructor: (@dialog) ->

    ok: (formdata)->
        @dialog.close()

    cancel: (evt,form)->
        evt.preventDefault()
        @dialog.dismiss('cancel')



class EffectChangesCtrl
    @.$inject = ['$modalInstance', '$scope']

    constructor: (@dialog, @scope) ->
        @scope.log = {}

    ok: (formdata)->
        @dialog.close(@scope.log)

    cancel: (evt,form)->
        evt.preventDefault()
        @scope.log = {}
        form.$setPristine()
        @dialog.dismiss('cancel')

class PositionCtrl extends nb.Controller



class Event
    constructor: ->

    send: ->



app.config(Route)
app.controller('OrgsCtrl', OrgsCtrl)
app.controller('OrgCtrl', OrgCtrl)





