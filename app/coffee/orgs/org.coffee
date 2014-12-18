
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
            box_color         : '#fff',               # fill color of boxes
            box_color_hover   : '#faa',               # fill color of boxes when mouse is over them
            box_border_color  : '#008',               # stroke color of boxes
            box_html_template : null,                 # id of element with template; don't use if you are using the box_click_handler
            line_color        : '#f44',               # color of connectors
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
            active_rect = null
        return

    return {
        restrict: 'A'
        link: link
    }


# {
#     label: '公司机构'
#     children: [
#         label: ''

#     ]
# }
# {
#     label: '一正级机构'
#     children: [
#         {
#             label: '人力资源部'
#         }
#     ]
# }




app.directive('orgChart',[orgChart])



# workaround 写法很奇怪, 编译出的 js 很 OK
class Route
    @.$inject = ['$stateProvider']

    constructor: (stateProvider) ->
        stateProvider
            .state 'org', {
                url: '/orgs'
                abstract: true
                templateUrl: 'partials/orgs/org.html'
                # views: {
                #     '@main': 'partials/orgs/org.html'
                #     '': 'partials/orgs/org_detail.html'
                # }
            }
            .state 'org.show', {
                url: ''
                views: {
                    'sub': {
                        templateUrl: 'partials/orgs/org_detail.html'
                    }
                }
            }
            .state 'org.newsub', {
                url: '/:parentId/newsub'
                views: {
                    'sub': {
                        templateUrl: 'partials/orgs/org_newsub.html'
                    }
                }

            }
            .state 'org.edit', {
                url: '/:Id/edit'
                views: {
                    'sub': {
                        templateUrl: 'partials/orgs/org_edit.html'
                    }
                }
            }




class OrgsController extends nb.Controller


    @.$inject = ['Org', '$http','$stateParams', '$state', '$scope', '$modal', '$panel']


    constructor: (@Org, @http, @params, @state, @scope, @modal, @panel)->
        @ORG_TREE_DEEPTH = 1
        self = @
        @treeRootOrg = null # 当前树的顶级节点
        @scope.currentOrg = null #当前选中机构
        @orgs = null    #集合
        @editOrg = null # 当前正在修改的机构
        @loadInitialData()
        @scope.currentJobInfo = null #当前所选择的岗位信息

        #for ui status
        @orgBarOpen = true


        @scope.$on 'select:change', (ctx, location) ->
            scope.currentOrg.location = location

    deleteOrg: ()-> #删除机构
        self = @
        onSuccess = ->
            self.reset()
            self.scope.$emit('success',"机构：#{self.scope.currentOrg.name} ,删除成功")

        onError = (data, status)->
            console.log arguments
            self.scope.$emit 'error', "机构：#{self.scope.currentOrg.name} ,删除失败,请确保当前没有子机构，同时该机构岗位要为空"

        self.scope.currentOrg.$destroy().$then onSuccess, onError


    loadInitialData: () -> #初始化数据
        self = @
        @Org.$search()
            .$then (orgs) ->
                self.orgs = orgs
                self.rootTree()
    rootTree: () ->
        @currentOrg = _.find @orgs, (org) -> org.depth == 1
        @buildTree(@currentOrg)

    setCurrentOrg: (org) -> #修改当前机构
        id = org.id
        @scope.currentOrg = _.find(@orgs, {id: id})
        @scope.positions = @scope.currentOrg.positions.$fetch()
        @state.go('^.show')


    newSubOrg: (org) -> #新增子机构
        self = @
        state = @state
        parentId = @params.parentId
        org.parentId = parentId
        org  = @orgs.$create(org)

        org.$then (org) ->
            self.scope.currentOrg = org
            self.reset()
            state.go('^.show')

    buildTree: (org = @treeRootOrg)->

        depth = 5
        depth = @ORG_TREE_DEEPTH if org.depth == 1

        @treeRootOrg = org
        @setCurrentOrg(org)
        @tree = @orgs.treeful(org, depth)
    #force 是否修改当前机构
    reset: (force) ->
        self = @
        @Org.$search()
            .$then (orgs) ->
                self.orgs = orgs
                self.scope.currentOrg = _.find orgs,{id: self.treeRootOrg.id} if force
                self.buildTree()

    onItemClick: (evt, element) ->
        orgId = element.oc_id
        org = _.find @orgs, {id: orgId}
        @setCurrentOrg(org)

    # #切换到编辑页面
    # edit: (orgId) ->
    #     @state.go('^.edit',{parentId: orgId})

    update: (org) -> #修改机构信息
        self = @
        onSuccess = ->
            self.reset()
            self.state.go('^.show')

        onError = (data, status)->
            self.scope.$emit 'error'

        org.$save().$then onSuccess, onError

    revert: () ->
        self = @
        onSuccess = ->
            self.reset(true)
            self.scope.$emit 'success', '撤销成功'

        onError = (data, status)->
            self.scope.$emit 'error', "#{data.message}"

        promise = @http.post '/api/departments/revert'
        promise.then onSuccess, onError


    active: (form, data) ->
        self = @
        onSuccess = ->
            self.reset(true)
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
            formdata.department_id = 1
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
            backdrop: false
            size: 'sm'
        } 
        dialog.result.then (data) ->
            console.log data.historyOrgs
            self.orgs = data.historyOrgs

# 机构历史记录

# 机构历史记录
class HistoryCtrl
    @.$inject = ['$modalInstance', '$scope', '$http', 'Org']
    constructor: (@dialog, @scope, @http, @Org) ->
        self = @
        @changeLogs = null
        @currentHisVersion = null
        @historyOrgs = null
        @loadInitialData()



    loadInitialData: ()->
        self = @
        onError = (res)->
            self.scope.emit 'error', res
        onSuccess = (res)->
            logs = res.data.change_logs
            groupedLog = _.groupBy logs, (log) ->
                # 后端返回的一些数据是以";"结尾, 那么split之后数组的最后一项将为undefined
                if /.*;$/.test(log.step_desc)
                    log.step_desc = log.step_desc.substring(0, log.step_desc.length - 1)
                log.step_desc = log.step_desc.split(';') 

                #Unix 时间戳转普通时间要乘1000 ，Date内部处理是按毫秒
                return new Date(parseInt(log.created_at)*1000).getFullYear()
            # 将对象转换为数组,待优化后期会整合为filter
            groupedLogs = []
            angular.forEach groupedLog, (item, key) ->
                groupedLogs.push {logs:item, changeYear: key}
            #转换结束
            
            self.changeLogs = groupedLogs.reverse()
        promise = self.http.get('/api/departments/change_logs')
        promise.then onSuccess, onError


    setHistoryVersion: (version)->
        @currentHisVersion = version
    ok: ()->
        self = @
        onError = (res)->
            self.scope.emit 'error', res
            self.dialog.close()
        onSuccess = (res)->
            self.dialog.close({ historyOrgs: res })
        promise = self.Org.$search {version: self.currentHisVersion}
        promise.$then onSuccess, onError

    cancel: ()->
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








app.config(Route)
app.controller('OrgsController', OrgsController)
# app.controller('OrgController', OrgController)





