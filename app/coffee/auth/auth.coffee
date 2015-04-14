
nb = @.nb
app = nb.app

class LoginController extends nb.Controller


    @.$inject = ['$http','$stateParams', '$state', '$scope', '$rootScope', '$cookies', 'User', '$timeout', 'Org', '$nbEvent']


    constructor: (@http, @params, @state, @scope, @rootScope, @cookies, @User, @timeout, @Org, @Evt)->
        @scope.currentUser = null #当前用户

    loadInitialData: () -> #初始化数据

    login: (user) ->
        self = @
        # user.employee_no = user.employee_no + ""
        self.http.post('/api/sign_in', {user: user})
            .success (data) ->
                self.cookies.token = data.token
                #后期做权限的时候此处一定要改
                #$cookies will attempt to refresh every 100ms
                self.timeout ()->
                    self.rootScope.currentUser = self.User.$fetch()
                    self.rootScope.allOrgs = self.Org.$search()
                    self.state.go "home"
                , 100
                
                # self.rootScope.currentUser = user
                #####end
                

            .error (data) ->
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

            .error (data) ->






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