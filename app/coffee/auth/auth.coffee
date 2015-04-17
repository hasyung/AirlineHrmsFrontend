
nb = @.nb
app = nb.app



class AuthService extends nb.Service

    @.$inject = ['$cookies', '$rootScope', 'PERMISSIONS']

    ARRAY_LIKE = /^\[[\W,\w]*\]$/ # test array like string

    constructor: (@cookies, @rootScope, @permissions) ->
    #
    # DESC： 判断用户是否存在某权限
    #
    # string | array
    #
    has: (permission) ->
        permit = false
        permission = permission.trim()

        if  !ARRAY_LIKE.test(permission)
            permit = @permissions.indexOf(permission) != -1
        else
            try
                permission_array = JSON.parse(permission)
            catch e
                # array格式错误
                throw new Error('permission format error')
            permit = permission_array.every((perm)-> @permissions.indexOf(perm) != -1)

        return permit

    #TIPS: 目前无权限 系统行为和用户执行退出操作一致。可能会更改
    logout: () ->
        location = window.location
        delete @cookies.token # angular 1.4 break change @cookies.remove("token")
        location.replace("#{location.origin}/sessions/new/")


class AuthController extends nb.Controller

    @.$inject = ['$scope', 'AuthService']

    constructor: (scope, AuthService) ->
        scope.logout = -> AuthService.logout()


class LoginController extends nb.Controller


    @.$inject = ['$http', '$state', '$rootScope', 'User', 'Org', 'AuthService']


    constructor: (@http, @state, @rootScope, @User, @Org, @Auth)->

    login: (user) ->
        rootScope = @rootScope
        onSuccess = ->
            @Auth.setupCurrentUser()
            #TODO: consider initial enums resource to service
            @rootScope.allOrgs = @Org.$search()
            @state.go "home"

        # user.employee_no = user.employee_no + ""
        @http.post('/api/sign_in', {user: user})
            .success onSuccess.bind(@)

    changePwd: (user)->
        self = @
        if user.new_password != user.password_confirm
            self.Evt.$send 'password:confirm:error', "两次输入新密码不一致"
            return

        self.http.put('/api/me/update_password', user)
            .success (data) ->
                self.Evt.$send 'password:update:success', '密码修改成功，请重新登录'
                self.rootScope.logout()
                self.state.go "login"



class SigupController extends nb.Controller


    @.$inject = ['$http','$stateParams', '$state', '$scope']


    constructor: (@http, @params, @state, @scope)->
        @scope.currentUser = null #当前用户


    loadInitialData: () -> #初始化数据

    sigup: (user) ->
        self = @
        # user.employee_no = user.employee_no + ""
        self.http.post('/api/sign_in', {user: user})
            .success (data) ->
                console.log data
            .error (data) ->
                console.log data


app.controller('LoginController', LoginController)
app.controller('SigupController', SigupController)
app.service('AuthService', AuthService)
app.controller('AuthController', AuthController)
