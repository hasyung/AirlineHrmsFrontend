app = @nb.app

class RootController extends nb.Controller
    @.$inject = ['$scope', '$rootScope', 'CURRENT_ROLES', '$timeout', '$state', 'ROUTE_INFO', 'REPORT_CHECKER', 'USER_META']

    constructor: (@scope, @rootScope, CURRENT_ROLES, $timeout, $state, ROUTE_INFO, REPORT_CHECKER, USER_META)->
        @isIE = false
        @show_main = false
        @downloadUrl = 'http://www.baidu.com'

        #用于定位当前用户的大领导身份
        @show_boss = false
        @isHrDeputyManager = false
        @isServiceDeputyManager = false
        @isHrGeneralManager = false

        @current_roles = CURRENT_ROLES
        @root_info = ROUTE_INFO
        @reportCheckers = REPORT_CHECKER
        @user = USER_META

        # @show_main = @root_info.single_point

        self = @

        @checkBossType()

        @rootScope.$watch 'hide_menu', (newVal, oldVal) ->
            self.hide_menu = newVal

        @rootScope.$watch 'show_main', (newVal, oldVal) ->
            self.show_main = newVal || self.show_main

        @rootScope.$watch 'downloadUrl', (newVal, oldVal) ->
            if angular.isDefined newVal
                self.downloadUrl = newVal
                document.getElementById('download-file').src = self.downloadUrl

    checkBossType: () ->
        self = @
        userPositionIds = []

        @user.positions.forEach (current)->
            userPositionIds.push current.position.id

        if userPositionIds.indexOf(@reportCheckers['副总经理（人事、劳动关系、招飞）']) > -1
            self.isHrDeputyManager = true
            self.show_boss = true

        if userPositionIds.indexOf(@reportCheckers['副总经理（培训、员工服务）']) > -1
            self.isServiceDeputyManager = true
            self.show_boss = true

        if userPositionIds.indexOf(@reportCheckers['人力资源部总经理']) > -1
            self.isHrGeneralManager = true
            self.show_boss = true

        if @user.employee_no == 'administrator'
            self.isHrGeneralManager = true
            self.isServiceDeputyManager = false
            self.isHrDeputyManager = false
            self.show_boss = true

    backToHome: () ->
      @show_main = false
      @rootScope.show_main = false

app.controller('RootCtrl', RootController)