
nb = @.nb
app = nb.app

class LoginController extends nb.Controller


    @.$inject = ['$http','$stateParams', '$state', '$scope', '$rootScope']


    constructor: (@http, @params, @state, @scope, @rootScope)->
        @scope.currentUser = null #当前用户

    loadInitialData: () -> #初始化数据
        
    login: (user) ->
        self = @
        # user.employee_no = user.employee_no + ""
        self.http.post('/api/sign_in', {user: user})
            .success (data) ->
                self.rootScope.currentUser = user
                self.http.defaults.headers.common = {token: data.token}
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