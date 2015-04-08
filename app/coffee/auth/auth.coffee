
nb = @.nb
app = nb.app



class AuthService extends nb.Service

    @.$inject = ['$http', '$rootScope', 'User']

    ARRAY_LIKE = /^\[[\W,\w]*\]$/ # test array like string

    login: false


    initialized: false # 是否初始化成功, 如果false 切 this.promise != null , 则在登录中

    constructor: (http, @rootScope, @User) ->
        self = @
        @permissions = []

        promise = @setupCurrentUser()
        promise.then (user) ->
            self.permissions = [].concat user.permissions
            self.initialized = true
            delete self.promise

    setupCurrentUser: () ->
        self = @
        # export current User to rootScope
        user =  @user = @rootScope.currentUser = @User.$fetch()
        @promise = user.$asPromise()


    getPermissions: () ->
        return @permissions


    setPermissions: (permissions) ->
        @permissions = permissions
    # string | array
    has: (permission) ->
        hasPermission = false

        permission = permission.trim()

        if  !ARRAY_LIKE.test(permission)
            hasPermission = @permissions.indexOf(permission) != -1
        else
            try
                permission_array = JSON.parse(permission)
            catch e
                # array格式错误
                throw new Error('permission format error')
            hasPermission = permission_array.every((perm)-> @permissions.indexOf(perm) != -1)

        return hasPermission

    isLogged: () ->
        return @initialized

    isLogging: () ->
        return !!@promise

    logout: () ->
        onSuccess = ->
            @rootScope.currentUser = null
            @cookies.token = null
        @http.delete('/api/sign_out').success onSuccess.bind(@)



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
