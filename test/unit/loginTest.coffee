creds = {
    login: 'admin@abc.com'
    password: '12345678'
}
errUserCreds = {
    login: 'errAdmin'
    password: 'errPsw'
}
errPsdCreds = {
    login: 'admin@abc.com'
    password:'errPsw'
}


# res

user = {
    avatar_url: "http://192.168.3.19:3000/assets/defaults/user/avatar.png"
    id: "532ba8c9bf63b7f258000001"
    name: "管理员"
}

errPassRes = {
    message: "invalid password!"
}

errUserRes = {
    message: "no this user!"
}

#errPswResFun = ()



describe 'LoginCtrl', () ->
    # scope, $httpBackend ,createController,timeout #use these in tests
    scope = $httpBackend = createController = $timeout  = Auth= undefined


    beforeEach(angular.mock.module('vxApp'))

    beforeEach inject(($injector,$controller,$rootScope) ->
        $httpBackend = $injector.get '$httpBackend'
        $timeout = $injector.get '$timeout'
        Auth = $injector.get 'Auth'


        scope = $rootScope.$new()

        createController = () ->
            $controller('LoginCtrl',{$scope:scope})


        loginPost = (req) ->
            reqStr = JSON.stringify {user: req}
            (str) ->
                console.log "str :#{str} reqStr: #{reqStr}"
                str == reqStr


        $httpBackend.when('POST','/web_api/v1/sessions.json',loginPost(creds)).respond(user)
        $httpBackend.when('POST','/web_api/v1/sessions.json',loginPost(errUserCreds)).respond(401, errUserRes)
        $httpBackend.when('POST','/web_api/v1/sessions.json',loginPost(errPsdCreds)).respond(401, errPassRes)

    )


    afterEach () ->
        $httpBackend.verifyNoOutstandingExpectation()
        $httpBackend.verifyNoOutstandingRequest()


    it '未登录',() ->
        expect(Auth.isAuthenticated()).toBe(false)

    it '正常登陆', () ->
        createController()
        scope.login(creds)
        $httpBackend.flush()

        expect(Auth.isAuthenticated()).toBe(true)
        expect(Auth._currentUser).toEqual(user)

    it '错误密码', () ->
        #expect(0).toBe(0)
        createController()
        scope.login(errPsdCreds)
        $httpBackend.flush()
        expect(Auth.isAuthenticated()).toBe(false)

    it '用户名错误', () ->
        createController()
        scope.login(errUserCreds)
        $httpBackend.flush()
        expect(Auth.isAuthenticated()).toBe(false)





