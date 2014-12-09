

# nb = @.nb

# app = nb.app


# mixOf = nb.mixOf






# class AdminCtrl extends nb.Controller

#     @.$inject = ['$scope', 'toaster' ,'$rootScope']

#     constuctor: (@scope, @toaster, @rootScope) ->


#         @scope.$on('error', @onError)

#     onMessage: (type, data) ->

#         map = {
#             'error':
#                 'name' : '错误'
#                 'icon-class': 'toast-error'
#             'info' :
#                 'name': '提示'
#                 'icon-class': 'toast-info'
#             'wait' :
#                 'name': '等待'
#                 'icon-class': 'toast-wait'
#             'success':
#                 'name': '成功'
#                 'icon-class': 'toast-success'
#             'warning':
#                 'name': '警告'
#                 'icon-class': 'toast-warning'
#         }

#         @toaster.pop('error' , '错误', "#{data.message}")



