app = @nb.app
resetForm = nb.resetForm


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
        <div class="approval-wapper panel-bg-gray">
            <md-toolbar md-theme="hrms" class="md-warn">
                <div class="md-toolbar-tools">
                    <span>{{flow.name}}申请单</span>
                </div>
            </md-toolbar>
            <div class="approval-container">
                <md-card>
                    <div class="approval-info">
                        <div class="approval-info-head">
                            <div class="name" ng-bind="flow.receptor.name"></div>
                            <div class="approval-info-plus">
                                <span class="serial-num" ng-bind="flow.receptor.employeeNo"> </span>
                                <span class="position"> {{::flow.receptor.departmentName}} / {{::flow.receptor.positionName}} </span>
                            </div>
                        </div>
                        <div class="flow-relations">
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
                            <div style="margin-top:30px;" nb-annexs-box annexs="flow.attachments" ng-if="flow.attachments && flow.attachments.length >=1"></div>
                        </div>
                    </div>
                </md-card>
                <md-card>
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
                                    <span class="approval-decider-date">{{msg.createdAt | date: 'yyyy-MM-dd HH:mm' }}</span>
                                </div>
                            </div>
                        </div>
                        <div class="approval-opinions" ng-if="!flowView || flow.name == '合同续签'">
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
                <div class="approval-buttons" ng-if="!flowView || flow.name == '合同续签'">
                    <md-button class="md-raised md-warn" ng-click="submitFlow({opinion: true}, flow, dialog, state)" type="button">通过</md-button>
                    <md-button class="md-raised md-warn" ng-click="submitFlow({opinion: false}, flow, dialog, state)" type="button">驳回</md-button>
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

        scope.flowView = angular.isDefined(attrs.flowView)

        offeredExtra = (flow) ->
            return template
                    .replace(/#flowRelationData#/, `flow.relationData? flow.relationData : ''`)
                    .replace(/#extraFormLayout#/, `flow.$extraForm ? flow.$extraForm : ''`)

        openDialog = (evt)->
            promise = scope.flow.$refresh().$asPromise()
            promise.then(offeredExtra).then (template)->
                ngDialog.open {
                    template: template
                    plain: true
                    className: 'ngdialog-theme-panel'
                    controller: 'FlowController'
                    controllerAs: 'dialog'
                    scope: scope
                    locals: {flow: scope.flow}
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
    @.$inject = ['$http','$scope', 'USER_META', 'OrgStore', 'Employee', '$nbEvent', '$state']

    constructor: (http, scope, meta, OrgStore, Employee, Evt, @state) ->
        FLOW_HTTP_PREFIX = "/api/workflows"
        scope.selectedOrgs = []

        #加载分类为领导和干部的人员
        scope.reviewers = []
        scope.leaders = Employee.leaders()
        scope.reviewOrgs = OrgStore.getPrimaryOrgs()
        scope.userReply = ""
        scope.state = @state

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

        scope.submitFlow = (req, flow, dialog, state) ->
            url = joinUrl(FLOW_HTTP_PREFIX, flow.type, flow.id)
            promise = http.put(url, req)

            promise.then ()->
                if angular.isDefined(scope.flowSet)
                    scope.flowSet.$refresh()
                    # 奇葩bug，表格数据刷新后id错位
                    # state.go(state.current.name, {}, {reload: true})

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
                scope.flowSet.$refresh() if angular.isDefined(scope.flowSet)
                dialog.close()
                parentDialog.close()

        scope.toggleSelect = (org, list)->
            index = list.indexOf org
            if index > -1 then list.splice(index, 1) else list.push org

        scope.getContact = () ->
            http.get('/api/me/flow_contact_people')
                .success (result) ->
                    scope.reviewers = result.flow_contact_people

        scope.addContact = (param) ->
            http.post('/api/me/flow_contact_people', {employee_id: param})
                .success (result) ->
                    Evt.$send 'result:post:success', '添加常用联系人成功'

        scope.removeContact = (param) ->
            http.delete('/api/me/flow_contact_people/'+param)
                .success (result) ->
                    scope.getContact()
                    Evt.$send 'result:delete:success', '删除常用联系人成功'

        scope.foggy = (param) ->





app.controller 'FlowController', FlowController
app.directive 'flowHandler', ['ngDialog', FlowHandlerDirective]
app.directive 'flowRelationData', ['$timeout', flowRelationDataDirective]