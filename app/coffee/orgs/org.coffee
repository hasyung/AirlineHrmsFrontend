
nb = @.nb
app = nb.app






click_handler = () ->






organChart = () ->
    link = (scope, $el, attrs) ->

        oc_options_2 = {
            data_id           : 1,                    # identifies the ID of the "data" JSON object that is paired with these options
            container         : 'organ_chart',     # name of the DIV where the chart will be drawn
            box_color         : '#aaf',               # fill color of boxes
            box_color_hover   : '#faa',               # fill color of boxes when mouse is over them
            box_border_color  : '#008',               # stroke color of boxes
            box_html_template : null,                 # id of element with template; don't use if you are using the box_click_handler
            line_color        : '#f44',               # color of connectors
            title_color       : '#000',               # color of titles
            subtitle_color    : '#707',               # color of subtitles
            max_text_width    : 20,                   # max width (in chars) of each line of text ('0' for no limit)
            text_font         : 'Courier',            # font family to use (should be monospaced)
            use_images        : false,                # use images within boxes?
            box_click_handler : click_handler,        # handler (function) called on click on boxes (set to null if no handler)
            use_zoom_print    : false,                # wheter to use zoom and print or not (only one graph per web page can do so)
            debug             : false                 # set to true if you want to debug the library
        };

        orgs = {
            id: 1
            root: {
                id: 2
                title: '总经办'
                children: [
                    {
                        id: 3
                        title: '人力资源部'
                        type: 'staff' # staff
                    }

                ]
            }
            title: '董事会'

        }

        ggOrgChart.render(oc_options_2,orgs)

        return



    return {
        # scope: {
        #     organChartOptions: '@options'
        # }
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




# app.directive('organChart',[organChart])



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
        self = @
        @scope.currentOrg = null #当前选中机构
        @orgs = null    #集合
        @editOrg = null # 当前正在修改的机构
        @loadInitialData()
        @scope.currentJobInfo = null #当前所选择的岗位信息
        @scope.jobRanks = null

        #for ui status
        @orgBarOpen = true
        @org_modified = false


        @scope.$on 'select:change', (ctx, location) ->
            scope.currentOrg.location = location

    deleteOrg: ()-> #删除机构
        self = @
        onSuccess = ->
            self.scope.$emit('success',"机构：#{self.scope.currentOrg.name} ,删除成功")
            self.org_modified = true

        onError = (data, status)->
            console.log arguments
            self.scope.$emit 'error', "机构：#{self.scope.currentOrg.name} ,删除失败,请确保当前没有子机构，同时该机构岗位要为空"

        self.scope.currentOrg.$destroy().$then onSuccess, onError


    loadInitialData: () -> #初始化数据
        self = @
        @Org.$search()
            .$then (orgs) ->
                self.orgs = orgs
                #默认选中总经理节点
                console.log orgs[0]
                self.scope.currentOrg = _.find orgs, (org) ->
                    if org.depth
                        org.depth = 1

                self.org_modified = !! _.find self.orgs, (org) ->
                    /inactive/.test org.status


        @http.get("/api/enum?key=Department.department_grades")
            .success (data) ->
                self.scope.jobRanks = data.result
            .error (data) ->
                self.scope.$emit 'error', "#{data.message}"

    setCurrentOrg: (org) -> #修改当前机构
        console.log org.status
        id = org.id
        @scope.currentOrg = _.find(@orgs, {id: id})
        @state.go('^.show')

    setCurrentJobInfo: (jobInfo) ->
        self = @
        self.scope.currentJobInfo = jobInfo
        self.jobInfoDialog = true

    newSubOrg: (org) -> #新增子机构
        self = @
        state = @state
        parentId = @params.parentId
        org.parentId = parentId
        org  = @orgs.$create(org)

        org.$then (org) ->
            self.scope.currentOrg = org
            self.org_modified = true
            state.go('^.show')


    # #切换到编辑页面
    # edit: (orgId) ->
    #     @state.go('^.edit',{parentId: orgId})

    update: (org) -> #修改机构信息
        self = @
        onSuccess = ->
            self.org_modified = true
            self.state.go('^.show')

        onError = (data, status)->
            self.scope.$emit 'error'

        org.$save().$then onSuccess, onError

    revert: () ->
        self = @
        onSuccess = ->
            self.orgs = self.Org.$search()
            self.org_modified = false
            self.scope.$emit 'success', '撤销成功'

        onError = (data, status)->
            self.org_modified = true
            self.scope.$emit 'error', "#{data.message}"

        promise = @http.post '/api/departments/revert'
        promise.then onSuccess, onError


    active: (form, data) ->
        self = @
        onSuccess = ->
            self.orgs = self.Org.$search()
            self.org_modified = false
            self.scope.$emit 'success', '更改已生效'

        onError = (data, status)->
            self.org_modified = true
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


    openHistoryPanel: () ->
        self = @
        panel = @modal.open {
            templateUrl: 'partials/orgs/org_history.html'
            controller: HistoryCtrl
            controllerAs: 'his'
        } 

class HistoryCtrl
    @.$inject = ['$modalInstance', '$scope']
    constructor: (@dialog, @scope) ->

    ok: (formdata)->
        @dialog.close()


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





