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

        $timeout getRelationDataHTML, 300

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
                            <p ng-show="AllLeaveFlows.indexOf(flow.type) >= 0 && !flowView && flow.type != 'Flow::PersonalLeave' && flow.type != 'Flow::AccreditLeave' && leaveDays >= 2.5 && leaveDays < 5" class="approval-relation-tip">请假天数大于等于2.5天，需部门分管领导批准</p>
                            <p ng-show="AllLeaveFlows.indexOf(flow.type) >= 0 && !flowView && flow.type != 'Flow::PersonalLeave' && flow.type != 'Flow::AccreditLeave' && leaveDays >= 5" class="approval-relation-tip">请假天数大于等于5天，需部门分管领导及主官批准</p>
                            <p ng-show="AllLeaveFlows.indexOf(flow.type) >= 0 && !flowView && flow.type == 'Flow::PersonalLeave' && leaveDays <= 3" class="approval-relation-tip">请假天数小于等于3天，需部门主官批准</p>
                            <p ng-show="AllLeaveFlows.indexOf(flow.type) >= 0 && !flowView && flow.type == 'Flow::PersonalLeave' && leaveDays > 3" class="approval-relation-tip">请假天数大于3天，需部门主官及人力资源部总经理批准</p>
                            <p ng-show="AllLeaveFlows.indexOf(flow.type) >= 0 && !flowView && flow.type == 'Flow::AccreditLeave' && leaveDays >= 2" class="approval-relation-tip">请假天数大于等于2天，需部门领导及代管领导批准</p>
                            <div style="margin-top:30px;" nb-annexs-box annexs="flow.attachments" ng-if="flow.attachments && flow.attachments.length >=1"></div>
                            <div ng-show="flowView && (flow.name !='合同续签' || isHistory) && leaveFlowsNeedAttachment.indexOf(flow.type) >= 0" class="accessory-header mt20">附件补传</div>
                            <div ng-show="flowView && (flow.name !='合同续签' || isHistory) && leaveFlowsNeedAttachment.indexOf(flow.type) >= 0" flow-file-upload flow-type="#FlowType#" ng-model="supplementIds"></div>
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
                        <div class="approval-opinions" ng-if="!flowView || (!isHistory && flow.name=='合同续签')">
                            <form name="flowReplyForm" ng-init="replyForm = flowReplyForm">
                                <div layout>
                                    <md-input-container flex>
                                        <label>审批意见</label>
                                        <textarea ng-model="dialog.userReply" required columns="1" md-maxlength="150"></textarea>
                                    </md-input-container>
                                    <button type="button" class="add-habit" ng-click="createFavNote(dialog.userReply)" aria-label="添加常用意见">
                                        添加为常用意见
                                    </button>
                                    <button type="button" class="delete-habit" ng-click="dialog.deleting=!dialog.deleting" aria-label="删除常用意见">
                                        <span ng-hide="dialog.deleting">删除</span>
                                        <span ng-show="dialog.deleting">返回</span>
                                    </button>
                                </div>
                                <div class="habit-opinions" layout>
                                    <button ng-class="{'deleting': dialog.deleting}" ng-disabled="dialog.userReply || dialog.deleting" class="habit-opinion" ng-click="dialog.userReply = favNote.note;" ng-repeat="favNote in favNotes track by favNote.id">
                                        {{ favNote.note }}
                                        <md-icon class="del-habit" ng-click="destroyFavNote($event, favNote.id)" md-svg-src="/images/svg/close.svg" aria-label="删除"></md-icon>
                                    </button>
                                </div>

                            </form>
                        </div>
                    </div>
                </md-card>
                <div class="approval-buttons" ng-if="!flowView || (!isHistory && flow.name=='合同续签')">
                    <md-button ng-disabled="!dialog.userReply" class="md-raised md-warn" ng-click="reply(dialog.userReply, $$prevSibling.flowReplyForm); submitFlow({opinion: true}, flow, dialog, state)" type="button">通过</md-button>
                    <md-button ng-disabled="!dialog.userReply" class="md-raised md-warn" ng-click="reply(dialog.userReply, $$prevSibling.flowReplyForm); submitFlow({opinion: false}, flow, dialog, state)" type="button">驳回</md-button>
                    <md-button class="md-raised md-primary"
                        ng-disabled="!dialog.userReply"
                        nb-dialog
                        template-url="partials/component/workflow/hand_over.html"
                        locals="{flow:flow}"
                        >移交</md-button>
                </div>
                <div class="approval-buttons" ng-if="flowView && (flow.name!='合同续签' || isHistory)">
                    <md-button ng-show="supplementIds.length > 0" class="md-raised md-primary" ng-click="supplementFlowFile(flow, supplementIds, dialog)">提交</md-button>
                    <md-button class="md-raised md-warn" ng-click="dialog.close()" type="button">关闭</md-button>
                </div>
            </div>
        </div>
    '''

    postLink = (scope, elem, attrs, ctrl) ->
        defaults = ngDialog.getDefaults()
        options = angular.extend {}, defaults, scope.options

        scope.flowView = angular.isDefined(attrs.flowView)
        scope.isHistory = angular.isDefined(attrs.isHistory)

        offeredExtra = (flow) ->
            return template
                    .replace(/#flowRelationData#/, `flow.relationData ? flow.relationData : ''`)
                    .replace(/#extraFormLayout#/, `flow.$extraForm ? flow.$extraForm : ''`)
                    .replace(/#FlowType#/, `flow.type? flow.type : ''`)

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
    @.$inject = ['$http','$scope', 'USER_META', 'OrgStore', 'Employee', '$nbEvent', '$state', 'VACATIONS', 'FavNote', 'toaster']

    constructor: (http, scope, meta, OrgStore, Employee, Evt, @state, vacations, FavNote, toaster) ->
        scope.leaveFlowsNeedAttachment = [
            "Flow::AccreditLeave"
            "Flow::FuneralLeave"
            "Flow::HomeLeave"
            "Flow::MarriageLeave"
            "Flow::MaternityLeave"
            "Flow::MaternityLeaveBreastFeeding"
            "Flow::MaternityLeaveDystocia"
            "Flow::MaternityLeaveLateBirth"
            "Flow::MaternityLeaveMultipleBirth"
            "Flow::MiscarriageLeave"
            "Flow::PrenatalCheckLeave"
            "Flow::RearNurseLeave"
            "Flow::SickLeave"
            "Flow::SickLeaveInjury"
            "Flow::SickLeaveNulliparous"
            "Flow::LactationLeave"
        ]

        scope.AllLeaveFlows = [
            "Flow::AccreditLeave"
            "Flow::AnnualLeave"
            "Flow::FuneralLeave"
            "Flow::HomeLeave"
            "Flow::MarriageLeave"
            "Flow::MaternityLeave"
            "Flow::MaternityLeaveBreastFeeding"
            "Flow::MaternityLeaveDystocia"
            "Flow::MaternityLeaveLateBirth"
            "Flow::MaternityLeaveMultipleBirth"
            "Flow::MiscarriageLeave"
            "Flow::PersonalLeave"
            "Flow::RecuperateLeave"
            "Flow::PrenatalCheckLeave"
            "Flow::RearNurseLeave"
            "Flow::SickLeave"
            "Flow::SickLeaveInjury"
            "Flow::SickLeaveNulliparous"
            "Flow::OccupationInjury"
            "Flow::WomenLeave"
            "Flow::PublicLeave"
            "Flow::LactationLeave"
        ]

        FLOW_HTTP_PREFIX = "/api/workflows"
        scope.selectedOrgs = []

        @userReply = ""
        @deleting = false
        #加载分类为领导和干部的人员
        scope.reviewers = []
        scope.leaders = []
        scope.reviewOrgs = OrgStore.getPrimaryOrgs()
        scope.userReply = ""
        scope.state = @state
        scope.favNotes = FavNote.$collection().$fetch()

        scope.CHOICE = {
            ACCEPT: true
            REJECT: false
        }

        scope.req = {
            opinion: true
        }

        scope.supplementIds = []
        scope.leaveDays = 0

        @getFlowDays(scope)

        # console.error scope.vacations
        # 查看请假流程的时候不显示年假信息
        scope.vacations = vacations

        scope.reply = (userReply, form) ->
            if userReply != '' && userReply != null && angular.isDefined(userReply)
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
                    #flow.processed = '已处理'
                    scope.flowSet.$refresh() # 刷新TODO列表
                    # 表格数据刷新后id错位，因为查看这列的ng-init中的realFlow绑定关系没有更新
                    # state.go(state.current.name, {}, {reload: true})

                dialog.close()

        # 补传附件 － new feature
        scope.supplementFlowFile = (flow, attachments_ids, dialog) ->
            url = joinUrl(FLOW_HTTP_PREFIX, flow.type, flow.id) + '/supplement'

            params = { attachment_ids: attachments_ids }

            http.put url, params
                .success (data) ->
                    toaster.pop 'success', '提示', '补传附件成功'
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
                if angular.isDefined(scope.flowSet)
                    flow.processed = '已处理'
                    scope.flowSet.$refresh() # 刷新TODO列表
                    # 表格数据刷新后id错位，因为查看这列的ng-init中的realFlow绑定关系没有更新
                    # state.go(state.current.name, {}, {reload: true})

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

        scope.queryContact = (param) ->
            http.get('/api/me/auditor_list?&name='+param)
                .success (result) ->
                    scope.leaders = result.employees

        scope.createFavNote = (param) ->
            if param != '' && param != null
                http.post('/api/fav_notes', { note: param })
                    .success (result) ->
                        scope.favNotes.$refresh()

        scope.destroyFavNote = (e, noteId) ->
            e.stopPropagation()

            if angular.isDefined noteId
                http.delete('/api/fav_notes/' + noteId)
                    .success (result) ->
                        scope.favNotes.$refresh()

    #获取请假流程天数
    getFlowDays: (scope) ->
        _.map scope.flow.formData, (item) ->
            if item.name == '请假天数'
                scope.leaveDays = item.value
                return


app.controller 'FlowController', FlowController
app.directive 'flowHandler', ['ngDialog', FlowHandlerDirective]
app.directive 'flowRelationData', ['$timeout', flowRelationDataDirective]
