



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


# joinUrl = (_head, _tail) ->
#     return null if(!_head || !_tail)
#     return (_head+'').replace(/\/$/, '') + '/' + (_tail+'').replace(/^\//, '')




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









FlowHandlerDirective = (ngDialog)->

    template = '''
        <div class="flow-contianenr">
            <div class="flow-info" ng-bind-html="flow.submitdata">


            </div>
            <div class="flow-steps">
                <flow-item-box ng-repeat="">

                </flow-item-box>
            </div>
            <div class="flow-feedback">
                <form action="">
                    <textarea name="feedback" id="" cols="30" rows="10"></textarea>
                </form>
            </div>
            <flow-actions>
                <button class="accept" ng-click="accept()">批准</button>
                <button class="reject" ng-click="reject()">驳回</button>
            </flow-actions>
        </div>
    '''



    postLink = (scope, elem, attrs, ctrl) ->

        defaults = ngDialog.getDefaults()

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



    return {
        scope: {
            flow: "=flowHandler"
        }
        link: postLink
    }


class FlowController

    @.$inject = ['$http']

    constructor: (@http) ->

    accept: (msg)->
        flowInstance.handle(msg, true)

    reject: (msg)->
        flowInstance.handle(msg, false)

    setFlow: (flowInstance) ->
        @flowInstance = flowInstance





app.controller 'FlowController', FlowController
app.directive 'FlowHandlerDirective', ['ngDialog', FlowHandlerDirective]











