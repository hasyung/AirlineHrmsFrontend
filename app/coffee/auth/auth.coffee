
nb = @.nb
app = nb.app



class AuthService extends nb.Service

    @.$inject = ['$http', '$rootScope']

    ARRAY_LIKE = /^\[[\W,\w]*\]$/ # test array like string

    constructor: (http, rootScope) ->
        @permissions = rootScope.currentUser.permissions || [] if rootScope.currentUser
    set: (permissions) ->
        @permissions = permissions
    # string | array
    has: (permission) ->
        hasPermission = false

        permission = permission.trim()

        if  ARRAY_LIKE.test(permission)
            hasPermission = @permissions.indexOf(permission) != -1
        else if angular.isArray(permission)
            try
                permission_array = JSON.parse(permission)
            catch e
                # array格式错误
                throw new Error('permission format error')
            hasPermission = permission_array.every((perm)-> perm.indexOf(@permissions) != -1)

        return hasPermission



class LoginController extends nb.Controller


    @.$inject = ['$http','$stateParams', '$state', '$scope', '$rootScope', '$cookies', 'User', '$timeout', 'Org']


    constructor: (@http, @params, @state, @scope, @rootScope, @cookies, @User, @timeout, @Org)->
        @scope.currentUser = null #当前用户

    loadInitialData: () -> #初始化数据

    login: (user) ->
        self = @
        # user.employee_no = user.employee_no + ""
        self.http.post('/api/sign_in', {user: user})
            .success (data) ->
                self.rootScope.currentUser = self.User.$fetch()
                self.rootScope.allOrgs = self.Org.$search()
                self.state.go "home"
                




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
app.controller('AuthService', AuthService)
