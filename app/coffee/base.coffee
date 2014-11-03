


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

vx = @.vx

class Base

class Service extends Base

class Controller extends Base
    onInitialDataError: (xhr) ->
        if xhr
            if xhr.status == 404
                @location.path(@navUrls.resolve("not-found"))
                @location.replace()
            else if xhr.status == 403
                @location.path(@navUrls.resolve("permission-denied"))
                @location.replace()

        return @q.reject(xhr)

vx.Base = Base
vx.Service= Service
vx.Controller = Controller