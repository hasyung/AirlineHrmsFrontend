



extend = angular.extend
app    = @nb.app

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
            ctrl.$modelValue =  elem.html()

        $timeout getRelationDataHTML, 3000

    return {
        require: 'ngModel'
        link: postLink
    }




FlowHandlerDirective = (ngDialog)->

    relationSlips = '''
        <div layout="layout">
            <div flex="flex" class="approval-cell">
                <span class="cell-title">转入部门</span>
                <span class="cell-content">信息技术部-测试组</span>
            </div>
        </div>
        <div layout="layout">
            <div flex="flex" class="approval-cell">
                <span class="cell-title">转入岗位</span>
                <span class="cell-content">测试组组长</span>
            </div>
        </div>
        <div layout="layout">
            <div flex="flex" class="approval-cell">
                <span class="cell-title">申请理由</span>
                <span class="cell-content">
                    几年的工作经历，使我迫切的希望进一步拓宽知识面，
                    同时也希望有一个直接到一线去工作的机会，所以，
                    我希望能够对工作岗位进行适当的调整，调往生产部，
                    给自己一个锻炼的机会，也争取为本单位多做一份贡献。
                </span>
            </div>
        </div>
        <div layout="layout">
            <div flex="flex" class="approval-cell">
                <span class="cell-title">试岗时长</span>
                <span class="cell-content">3个月</span>
            </div>
        </div>
    '''

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
                <md-card>
                    <div class="approval-msg">
                        <div class="approval-subheader">意见</div>
                        <div class="approval-cell-container">
                            <div class="approval-msg-cell">
                                <div class="approval-msg-container">
                                    <div class="approval-msg-header">
                                        <span>李志林</span>
                                        <span>人力资源部-福利管理室主管</span>
                                    </div>
                                    <div class="approval-msg-result">同意执行</div>
                                    <div class="approval-msg-content">
                                        经党委会讨论，批准姜文峰同志转为中共正式党员，
                                        当年从1989年10月20日算起。经党委会讨论，批
                                        准姜文峰同志转为中共正式党员，当年从1989年
                                        10月20日算起。经党委会讨论，批准姜文峰同志转
                                        为中共正式党员，当年从1989年10月20日算起。经
                                        党委会讨论，批准姜文峰同志转为中共正式党员，当
                                        年从1989年10月20日算起。
                                    </div>
                                </div>
                                <div class="approval-msg-decider">
                                    <span class="approval-decider-date">2015-1-1</span>
                                </div>
                            </div>
                            <div class="approval-msg-cell">
                                <div class="approval-msg-container">
                                    <div class="approval-msg-header">
                                        <span>李志林</span>
                                        <span>人力资源部-福利管理室主管</span>
                                    </div>
                                    <div class="approval-msg-result">同意执行</div>
                                    <div class="approval-msg-content">
                                        经党委会讨论，批准姜文峰同志转为中共正式党员，
                                        当年从1989年10月20日算起。
                                    </div>
                                </div>
                                <div class="approval-msg-decider">
                                    <span class="approval-decider-date">2015-1-1</span>
                                </div>
                            </div>
                        </div>
                        <div class="approval-opinions">
                            <form>
                                <div layout>
                                    <md-input-container flex>
                                        <label>审批意见</label>
                                        <textarea ng-model="sdfs" columns="1" md-maxlength="150"></textarea>
                                    </md-input-container>
                                </div>
                                <md-button class="md-raised md-primary" type="submit">保存意见</md-button>
                            </form>
                        </div>
                    </div>
                </md-card>
                <div class="approval-buttons">
                    <md-button class="md-raised md-warn">通过</md-button>
                    <md-button class="md-raised md-warn" type="button">驳回</md-button>
                    <md-button class="md-raised md-primary" nb-dialog template-url="">移交</md-button>
                </div>
            </div>
        </div>
    '''



    postLink = (scope, elem, attrs, ctrl) ->

        defaults = ngDialog.getDefaults()
        options = angular.extend {}, defaults, scope.options

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

    @.$inject = ['$http','$scope']

    constructor: (http, scope) ->
        FLOW_HTTP_PREFIX = "/api/workflows"

        scope.CHOICE = {
            ACCEPT: true
            REJECT: false
        }

        scope.req = {
            opinion: true
        }

        scope.submitFlow = (req, flow, dialog) ->
            url = joinUrl(FLOW_HTTP_PREFIX, flow.type, flow.id)
            promise = http.put(url, req)
            promise.then ()->
                scope.flowSet.$refresh()
                dialog.close()



app.controller 'FlowController', FlowController
app.directive 'flowHandler', ['ngDialog', FlowHandlerDirective]
app.directive 'flowRelationData', ['$timeout', flowRelationDataDirective]











