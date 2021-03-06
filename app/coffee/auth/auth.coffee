nb = @.nb
app = nb.app

class AuthService extends nb.Service
    @.$inject = ['$cookies', '$rootScope', 'PERMISSIONS']

    ARRAY_LIKE = /^\[[\W,\w]*\]$/ # test array like string

    constructor: (@cookies, @rootScope, @permissions) ->

    has: (permission) ->
        permit = false
        permission = permission.trim()
        self = @

        if !ARRAY_LIKE.test(permission)
            if permission.indexOf("|") < 0
                permit = @permissions.indexOf(permission) != -1
            else
                permission_array = permission.split("|")
                # console.error permission_array
                permit = permission_array.some((perm)-> self.permissions.indexOf(perm) != -1)
        else
            try
                # console.error permission
                permission_array = JSON.parse(permission)
            catch e
                # array格式错误
                # console.erorr e
                throw new Error('permission format error')

            permit = permission_array.every((perm)-> self.permissions.indexOf(perm) != -1)

        return permit

    # 目前无权限，系统行为和用户执行退出操作一致
    logout: () ->
        location = window.location
        @cookies.remove("token")
        location.replace("#{location.origin}/sessions/new/")


class AuthController extends nb.Controller
    @.$inject = ["$scope", "AuthService", "$http", "$nbEvent"]

    constructor: (scope, AuthService, @http, @Evt) ->
        scope.logout = -> AuthService.logout()

    changePwd: (user)->
        self = @

        if user.new_password != user.password_confirm
            self.Evt.$send 'password:confirm:error', "两次输入新密码不一致"
            return

        self.http.put('/api/me/update_password', user)
            .success (data) ->
                self.Evt.$send 'password:update:success', '密码修改成功'
            .error (data) ->
                console.log "error"


class LoginController extends nb.Controller
    @.$inject = ['$http', '$state', '$rootScope', 'User', 'Org', 'AuthService']

    constructor: (@http, @state, @rootScope, @User, @Org, @Auth)->

    login: (user) ->
        rootScope = @rootScope

        onSuccess = ->
            @Auth.setupCurrentUser()
            @rootScope.allOrgs = @Org.$search()
            @state.go "home"

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

    logout: ()->
        @Auth.logout();


class SigupController extends nb.Controller
    @.$inject = ['$http','$stateParams', '$state', '$scope']

    constructor: (@http, @params, @state, @scope)->
        @scope.currentUser = null #当前用户

    loadInitialData: () -> #初始化数据

    sigup: (user) ->
        self = @

        self.http.post('/api/sign_in', {user: user})
            .success (data) ->
                console.log data
            .error (data) ->
                console.log data


app.controller('LoginController', LoginController)
app.controller('SigupController', SigupController)
app.service('AuthService', AuthService)
app.controller('AuthController', AuthController)