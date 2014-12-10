
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


    @.$inject = ['Org', '$http','$stateParams', '$state', '$scope']


    constructor: (@Org, @http, @params, @state, @scope, @toaster)->
        @scope.currentOrg = null #当前选中机构
        @orgs = null    #集合
        @editOrg = null # 当前正在修改的机构
        @loadInitialData()
        @scope.currentJobInfo = null #当前所选择的岗位信息
        @scope.jobRanks = null

        #for ui status
        @orgBarOpen = true
        @jobInfoDialog = false


        @scope.$on 'select:change', (ctx, location) ->
            scope.currentOrg.location = location
    deleteOrg: ->
        self = @
        onSuccess = ->
            self.scope.$emit('success',"机构：#{self.scope.currentOrg.name} ,删除成功")

        onError = (data, status)->
            self.scope.$emit 'error', "#{data.message}"

        self.scope.currentOrg.$destroy().$then onSuccess, onError
            

    loadInitialData: () ->
        self = @
        @Org.$search()
            .$then (orgs) ->
                self.orgs = orgs
                #默认选中总经理节点
                self.scope.currentOrg = _.find orgs, (org) ->
                    org.nodeType.name = 'manager'

                # self.currentOrg = _.find(orgs, {nodeType: 'manager'})
                console.log orgs[0]
                # self.currentOrg = orgs[0]
        @http.get("/api/enum?key=Department.node_types")
            .success (data) ->
                self.scope.jobRanks = data.result
            .error (data) ->
                self.scope.$emit 'error', "#{data.message}"

    setCurrentOrg: (org) ->
        state = @state
        id = org.id
        @scope.currentOrg = _.find(@orgs, {id: id})
        state.go('^.show')

    setCurrentJobInfo: (jobInfo) ->
        self = @
        self.scope.currentJobInfo = jobInfo
        self.jobInfoDialog = true
        console.log "test"

    newSubOrg: (org) ->
        self = @
        state = @state
        parentId = @params.parentId
        org.parentId = parentId
        org  = @orgs.$create(org)

        org.$then (org) ->
            self.scope.currentOrg = org
            state.go('^.show')


    # #切换到编辑页面
    # edit: (orgId) ->
    #     @state.go('^.edit',{parentId: orgId})

    update: (org) ->
        self = @
        onSuccess = ->
            self.state.go('^.show')

        onError = (data, status)->
            self.scope.$emit 'error'

        org.$save().$then onSuccess, onError

    revert: () ->
        self = @
        onSuccess = ->
            self.orgs = self.Org.$search()
            self.scope.$emit 'success', '撤销成功'

        onError = (data, status)->
            self.scope.$emit 'error', "#{data.message}"

        promise = @http.post '/api/departments/revert'
        promise.then onSuccess, onError


    active: (form, data) ->
        self = @
        onSuccess = ->
            self.orgs = self.Org.$search()
            self.scope.$emit 'success', '更改已生效'

        onError = (data, status)->
            self.scope.$emit 'error', "#{data.message}"

        promise = @http.post '/api/departments/active', data
        promise.then onSuccess, onError

    #控制view显示效果
    toggleOrgBar: ()->
        self = @
        self.orgBarOpen = ! self.orgBarOpen

    closeJobInfoDialog: () ->
        self = @
        self.jobInfoDialog = false





app.config(Route)
app.controller('OrgsController', OrgsController)
# app.controller('OrgController', OrgController)





