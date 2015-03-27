



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
        <div class="flow-contianenr">

            <div class="sponsor-info">
                <div class="box"><label for="">申请人</label><span ng-bind="::flow.sponsor.name"></span></div>
                <div class="box"><label for="">员工编码</label><span ng-bind="::flow.sponsor.employeeNo"></span></div>
                <div class="box"><label for="">当前部门</label><span ng-bind="::flow.sponsor.departmentName"></span></div>
                <div class="box"><label for="">当前岗位</label><span ng-bind="::flow.sponsor.positionName"></span></div>

            </div>

            <div class="flow-relations" ng-bind-html="::flow.relation_data">

            </div>
            <div class="flow-info">
                <div class="box" ng-repeat="item in ::flow.formData">
                    <label for="" ng-bind="::data.name"></label>
                    <span ng-bind="::item.value"></span>
                </div>
            </div>
            <div class="flow-steps">
                <flow-item-box>

                </flow-item-box>
            </div>
            <form name="flow_handle_form" ng-submit="submitFlow(req, flow)" >
                <div class="opinion">
                    <md-radio-group ng-model="req.opinion">
                        <md-radio-button ng-value="CHOICE.ACCEPT">通过</md-radio-button>
                        <md-radio-button ng-value="CHOICE.REJECT">驳回</md-radio-button>
                    </md-radio-group>
                </div>
                <div class="flow-feedback">
                    <textarea name="desc" ng-model="req.desc" cols="30" rows="10"></textarea>
                    <div class="extra-form" ng-if="flow.$extraForm && req.opinion == true ">
                        #extraFormLayout#
                    </div>
                </div>
                <flow-actions>
                    <button type="submit" class="accept">批准</button>
                    <button type="button" ng-click="clostThisDialog()">取消</button>
                </flow-actions>
            </form>
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











