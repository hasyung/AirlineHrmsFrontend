
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
                url: '/:parentId/edit'
                views: {
                    'sub': {
                        templateUrl: 'partials/orgs/org_edit.html'
                    }
                }
            }



class OrgsController extends nb.Controller

    @.$inject = ['Org', '$stateParams', '$state', '$scope']

    constructor: (@Org, @params, @state, @scope)->
        @currentOrg = null #当前选中机构
        @orgs = null    #集合
        @editOrg = null # 当前正在修改的机构
        @loadInitialData()

    deleteOrg: ->
        self = @
        # onSuccess = ->

        # onError = ->
        #     self.scope.$emit('nb:error',"")

        self.currentOrg.$destroy().$then (data)->
            self.scope.$emit('success',"机构：#{self.currentOrg.name} ,删除成功")

    loadInitialData: () ->
        self = @
        @Org.$search()
            .$then (orgs) ->
                self.orgs = orgs
                # self.currentOrg = _.find(orgs, {nodeType: 'manager'})
                # console.log orgs[0]
                self.currentOrg = orgs[0]

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
        @orgs.$update(org)



# class OrgCtrl
#     @.$inject = ['$scope', 'Org']

#     constructor: () ->

#     newsub: () ->

#     update: () ->

#     remove: () ->





app.config(Route)
app.controller('OrgsController', OrgsController)
# app.controller('OrgController', OrgController)





