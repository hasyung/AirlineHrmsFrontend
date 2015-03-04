


##
#
# 基类文件
#
#
#
#
#
#
#

nb = @.nb
app = nb.app

class Base

class Service extends Base

class Controller extends Base

    constructor: () ->
        # @initialize()


    onInitialDataError: (xhr) ->
        if xhr
            if xhr.status == 404
                @location.path(@navUrls.resolve("not-found"))
                @location.replace()
            else if xhr.status == 403
                @location.path(@navUrls.resolve("permission-denied"))
                @location.replace()

        return @q.reject(xhr)

nb.Base = Base
nb.Service= Service
nb.Controller = Controller


class EditableResourceCtrl
    @.$inject = ['$scope']
    constructor: (scope) ->
        scope.editing = false

        scope.edit = (evt) ->
            evt.preventDefault() if evt && evt.preventDefault
            scope.editing = true

        scope.save = (resource, form) ->
            return if form && form.$invalid

            if promise
                if promise.then
                    promise.then () -> scope.editing = false
                else if promise.$save
                    promise.$save().$then () -> scope.editing =false

                else
                    throw new Error('promise 参数错误')

            else scope.editing =false



        scope.cancel = (resource, evt, form) ->
            evt.preventDefault() if evt
            resource.$restore() if resource && resource.$restore
            form.$setPristine() if form && form.$setPristine
            scope.editing = false
class NewResourceCtrl

    @.$inject = ['$scope']

    constructor: (scope) ->
        scope.create = (resource, form) ->
            return if form && form.$invalid
            resource.$save() if resource.$save




app.controller('EditableResource', EditableResourceCtrl)
app.controller('NewResource', NewResourceCtrl)
