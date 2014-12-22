
nb = @.nb
app = nb.app

class LoginController extends nb.Controller


    @.$inject = ['$http','$stateParams', '$state', '$scope', '$rootScope', '$cookies']


    constructor: (@http, @params, @state, @scope, @rootScope, @cookies)->
        @scope.currentUser = null #当前用户

    loadInitialData: () -> #初始化数据

    login: (user) ->
        self = @
        # user.employee_no = user.employee_no + ""
        self.http.post('/api/sign_in', {user: user})
            .success (data) ->
                self.cookies.token = data.token
                self.state.go "home"

            .error (data) ->
                self.$emit 'error', '#{data.message}'



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