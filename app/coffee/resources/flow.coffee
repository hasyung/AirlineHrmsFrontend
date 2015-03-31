



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

    postLink = (scope, elem, attrs) ->
        getRelationDataHTML = () ->
            scope.html = elem.html()

        $timeout getRelationDataHTML, 2000

    return {
        require: 'ngModel'
        scope: {
            html: '=ngModel'
        }
        link: postLink
    }




FlowHandlerDirective = (ngDialog)->

    template = '''
        <div class="approval-wapper">
            <md-toolbar>
                <div class="md-toolbar-tools">
                    <span>调岗申请单</span>
                </div>
            </md-toolbar>
            <div class="approval-container">
                <div class="approval-info">
                    <div class="approval-subheader">申请人信息</div>
                    <div class="approval-info-head">
                        <span class="name">姜文峰</span>
                        <span class="serial-number">008863</span>
                    </div>
                    <div class="approval-position">人力资源部-人事调配室 / 人事调配室副主任</div>
                    <div layout="layout">
                        <div flex="flex" class="approval-cell">
                            <span class="cell-title">学历</span>
                            <span class="cell-content">大学本科</span>
                        </div>
                        <div flex="flex" class="approval-cell">
                            <span class="cell-title">英语等级</span>
                            <span class="cell-content">大学英语四级</span>
                        </div>
                    </div>
                    <div layout="layout">
                        <div flex="flex" class="approval-cell">
                            <span class="cell-title">学位</span>
                            <span class="cell-content">学士</span>
                        </div>
                        <div flex="flex" class="approval-cell">
                            <span class="cell-title">当前岗位年限</span>
                            <span class="cell-content">3年</span>
                        </div>
                    </div>
                    <div layout="layout">
                        <div flex="flex" class="approval-cell">
                            <span class="cell-title">通道</span>
                            <span class="cell-content">管理</span>
                        </div>
                        <div flex="flex" class="approval-cell">
                            <span class="cell-title">近6个月绩效</span>
                            <span class="cell-content">优秀 2/良好 2/合格 2/待改进 2/不合格 2</span>
                        </div>
                  </div>
                </div>
                <div class="approval-info">
                    <div class="approval-subheader">调岗信息</div>
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
                </div>
                <div class="approval-msg">
                    <div class="approval-subheader">审批信息</div>
                    <div approval="approval" class="approval-progress-container"></div>
                    <div class="approval-msg-cell">
                        <div class="approval-msg-header">
                            <i class="circle"></i>
                            <span class="approval-header-title">合规性检查意见</span>
                            <span class="approval-header-name">李枝林</span>
                            <span class="approval-header-time">2015-04-01</span>
                        </div>
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
                </div>
                <div class="approval-opinions">
                    <div class="approval-subheader">审批意见</div>
                    <form>
                        <div class="approval-opinions-check">
                            <md-radio-group ng-model="data.group1">
                                <md-radio-button value="通过" class="skyblue">通过</md-radio-button>
                                <md-radio-button value="驳回" class="skyblue">驳回</md-radio-button>
                            </md-radio-group>
                        </div>
                        <md-input-container>
                            <textarea placeholder="请输入审批意见" columns="1"></textarea>
                        </md-input-container>
                        <div class="approval-buttons">
                            <md-button class="md-raised white">取消</md-button>
                            <md-button class="md-raised skyblue">提交</md-button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    '''



    postLink = (scope, elem, attrs, ctrl) ->

        defaults = ngDialog.getDefaults()

        offeredExtraForm = (flow) ->
            return template.replace(/#extraFormLayout#/, `flow.$extraForm ? flow.$extraForm : ''`)

        openDialog = ->
            scope.flow = scope.flow.$refresh()
            promise = scope.flow.$asPromise()
            promise.then(offeredExtraForm).then (template)->
                ngDialog.open {
                    template: template
                    plain: true
                    className: defaults.className
                    controller: 'FlowController'
                    scope: scope
                    data: scope.flow
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

        scope.submitFlow = (req, flow) ->
            url = joinUrl(FLOW_HTTP_PREFIX, flow.type, flow.id)
            promise = http.put(url, req)
            promise.then(scope.closeThisDialog)



app.controller 'FlowController', FlowController
app.directive 'flowHandler', ['ngDialog', FlowHandlerDirective]
app.directive 'flowRelationData', ['$timeout', flowRelationDataDirective]











