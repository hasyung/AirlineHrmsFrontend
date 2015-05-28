



extend = angular.extend
app    = @nb.app
resetForm = nb.resetForm
# collection
# fetch
# search
# process
# add
# remove
# indexof
#
# /api/workflows/leave
#
#
#   new Flow('Leave').mix {
#
#       handle: ->
#           jiji
#
#
#   }
#
#   LeaveFlow
#
#   flows =  LeaveFlow.$search({})
#   flows.$then () - >
#   flows.$asList({type: 'undo'})
#
#   flow = flows[0]
#   flow.$scope === flows
#
#   flow.handle(message, accept) ? // return what?
#
#   flow.accept(msg)
#   flow.reject(msg)
#
#   flow :{
#       done: true
#       data:
#       steps: [
#       {}
#
#
#       ]
#
#
#
#       accept: {
#
#       }
#
#
#   }



# FLOW_API = {
#     LEAVE: {
#         name: 'leave::'

#     }
# }

# iterator = (api, key) ->
#     angular.factory key, ->
#         return new Flow(key)

# angular.forEach(FLOW_API, iterator)

# URL_BASE = "/api/workflows"





# app.factory ''

# Collection =  Util.buildArrayType()

# class FlowBuilder
#     xxflow =  Object.create(Flow::)
#     xxflow.$find = ->


# class CommonApi

#     $asPromise: () ->
#         self = @
#         $q = @q
#         if @.$promise
#             @.promise.then(
#                 -> return self
#                 ,
#                 -> return $q.reject(self)
#             )
#         else
#             return @q.when(self)





# class FlowModel

#     constructor: () ->




# class Flow

#     done: false

#     $params: null

#     constructor: (_prefix)->
#         @urlPrefix = _prefix

#     $asList: ->

#     $add: ->

#     $remove: ->

#     $collection: (_params)->
#         @params = _params

#     $fetch: (_params) ->
#         params = extend({} , @params, _params)
#         promise = @http.get(params)
#         promise.then (res) ->
#             data = res.data






#     $find: (_flowid) ->

#         promise = _flowid

#     $search: ->

#     $open: () ->



joinUrl = (_head) ->
    return null if(!_head)
    _tail = Array.prototype.slice.call(arguments, 1).join('/')
    return (_head+'').replace(/\/$/, '') + '/' + _tail.replace(/^\/+/g, '').replace(/\/{2,}/g, '/')



flowRelationDataDirective = ($timeout)->

    postLink = (scope, elem, attrs, ctrl) ->
        getRelationDataHTML = () ->
            ctrl.$setViewValue(elem.html())

        $timeout getRelationDataHTML, 3000

    return {
        require: 'ngModel'
        link: postLink
    }




FlowHandlerDirective = (ngDialog)->

    template = '''
        <div class="approval-wapper">
            <md-toolbar md-theme="hrms" class="md-warn">
                <div class="md-toolbar-tools">
                    <span>请假申请单</span>
                </div>
            </md-toolbar>
            <div class="approval-container">
                <md-card>
                    <div class="approval-info">
                        <div class="approval-info-head">
                            <div class="name"> 姜文峰 </div>
                            <div class="approval-info-plus">
                                <span class="serial-num"> 008863 </span>
                                <span class="position"> 人力资源部 / 人事调配室副主任 </span>
                            </div>
                        </div>
                        <div class="ask-relations">
                            #flowRelationData#
                        </div>
                    </div>
                </md-card>
                <md-card>
                    <div class="approval-relation-info">
                        <div class="approval-subheader">申请信息</div>
                        <div class="approval-relations">
                            <div layout ng-repeat="entity in flow.formData">
                                <div flex="flex" class="approval-cell">
                                    <span class="cell-title">{{entity.name}}</span>
                                    <span class="cell-content">{{entity.value}}</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </md-card>
                <md-card ng-if="!flowView">
                    <div class="approval-msg">
                        <div class="approval-subheader">意见</div>
                        <div class="approval-cell-container">
                            <div class="approval-msg-cell" ng-repeat="msg in flow.flowNodes track by msg.id">
                                <div class="approval-msg-container">
                                    <div class="approval-msg-header">
                                        <span>{{msg.reviewerName}}</span>
                                        <span>{{msg.reviewerDepartment}}-{{msg.reviewerPosition}}</span>
                                    </div>
                                    <div class="approval-msg-content" >
                                        {{msg.body}}
                                    </div>
                                </div>
                                <div class="approval-msg-decider">
                                    <span class="approval-decider-date">{{msg.createdAt | date: 'yyyy-MM-dd' }}</span>
                                </div>
                            </div>
                        </div>
                        <div class="approval-opinions">
                            <form name="flowReplyForm" ng-submit="reply(userReply, flowReplyForm);">
                                <div layout>
                                    <md-input-container flex>
                                        <label>审批意见</label>
                                        <textarea ng-model="userReply" required columns="1" md-maxlength="150"></textarea>
                                    </md-input-container>
                                </div>
                                <md-button class="md-raised md-primary" type="submit">保存意见</md-button>
                            </form>
                        </div>
                    </div>
                </md-card>
                <div class="approval-buttons" ng-if="!flowView">
                    <md-button class="md-raised md-warn" ng-click="submitFlow({opinion: true}, flow, dialog)" type="button">通过</md-button>
                    <md-button class="md-raised md-warn" ng-click="submitFlow({opinion: false}, flow, dialog)" type="button">驳回</md-button>
                    <md-button class="md-raised md-primary"
                        nb-dialog
                        template-url="partials/component/workflow/hand_over.html"
                        locals="{flow:flow}"
                        >移交</md-button>
                </div>
                <div class="approval-buttons" ng-if="flowView">
                    <md-button class="md-raised md-warn" ng-click="dialog.close()" type="button">关闭</md-button>
                </div>
            </div>
        </div>
    '''



    postLink = (scope, elem, attrs, ctrl) ->

        defaults = ngDialog.getDefaults()
        options = angular.extend {}, defaults, scope.options

        scope.flowView = if attrs.flowView then scope.$eval(attrs.flowView) else false

        offeredExtra = (flow) ->
            return template
                    .replace(/#flowRelationData#/, `flow.relationData? flow.relationData : ''`)
                    .replace(/#extraFormLayout#/, `flow.$extraForm ? flow.$extraForm : ''`)




        openDialog = (evt)->
            scope.flow = scope.flow.$refresh()
            promise = scope.flow.$asPromise()
            promise.then(offeredExtra).then (template)->
                ngDialog.open {
                    template: template
                    plain: true
                    className: 'ngdialog-theme-panel'
                    controller: 'FlowController'
                    controllerAs: 'dialog'
                    scope: scope
                    locals: {flow: scope.flow}
                    # showClose: attrs.ngDialogShowClose === 'false' ? false : (attrs.ngDialogShowClose === 'true' ? true : defaults.showClose),
                    # closeByDocument: attrs.ngDialogCloseByDocument === 'false' ? false :
                    # (attrs.ngDialogCloseByDocument === 'true' ? true : defaults.closeByDocument),
                    # closeByEscape: attrs.ngDialogCloseByEscape === 'false' ? false
                    # : (attrs.ngDialogCloseByEscape === 'true' ? true : defaults.closeByEscape),
                    # preCloseCallback: attrs.ngDialogPreCloseCallback || defaults.preCloseCallback
                }
        elem.on 'click', openDialog
        scope.$on '$destroy', -> elem.off 'click', openDialog


    comiple = () ->


    return {
        scope: {
            flow: "=flowHandler"
            flowSet: "=flows"
            options: "=?"
        }
        link: postLink
    }


class FlowController

    @.$inject = ['$http','$scope', 'USER_META', 'OrgStore', 'Employee']

    constructor: (http, scope, meta, OrgStore, Employee) ->
        FLOW_HTTP_PREFIX = "/api/workflows"

        scope.selectedOrgs = []
        #加载分类为领导和干部的人员
        scope.reviewers = Employee.$search({category_ids: [1,2], department_ids: [OrgStore.getPrimaryOrgId()]})

        scope.reviewOrgs = OrgStore.getPrimaryOrgs()

        scope.userReply = ""


        scope.CHOICE = {
            ACCEPT: true
            REJECT: false
        }

        scope.req = {
            opinion: true
        }

        scope.reply = (userReply, form) ->
            try
                last_msg = _.last(scope.flow.flowNodes)
                if last_msg && last_msg.reviewerId == meta.id
                    last_msg.$update({body: userReply})
                else
                    scope.flow.flowNodes.$create({body: userReply})
            finally
                scope.userReply = ""
                resetForm(form)


        scope.submitFlow = (req, flow, dialog) ->
            url = joinUrl(FLOW_HTTP_PREFIX, flow.type, flow.id)
            promise = http.put(url, req)
            promise.then ()->
                scope.flowSet.$refresh()
                dialog.close()

        parseParams = (params)->
            if params.type == "departments"
                orgIds = _.map scope.selectedOrgs, 'id'
                params.department_ids = orgIds
                params.reviewer_id = undefined
            else if params.type == "reviewer"
                params.department_ids = undefined

            return params

        scope.transfer = (params, flow, dialog, parentDialog)->
            params = parseParams params
            url = joinUrl(FLOW_HTTP_PREFIX, flow.type, flow.id)
            promise = http.put(url, params)
            promise.then ()->
                scope.flowSet.$refresh()
                dialog.close()
                parentDialog.close()

        scope.toggleSelect = (org, list)->
            index = list.indexOf org
            if index > -1 then list.splice(index, 1) else list.push org 



        




app.controller 'FlowController', FlowController
app.directive 'flowHandler', ['ngDialog', FlowHandlerDirective]
app.directive 'flowRelationData', ['$timeout', flowRelationDataDirective]











