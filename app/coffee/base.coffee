


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

        scope.edit = () ->
            scope.editing = true

        scope.save = () ->
            scope.editing = false

app.controller('EditableResource', EditableResourceCtrl)
