app = @nb.app

class RootController extends nb.Controller
    @.$inject = ['$scope', '$rootScope', 'CURRENT_ROLES', '$timeout', '$state', 'ROUTE_INFO', 'REPORT_CHECKER', 'USER_META']

    constructor: (@scope, @rootScope, CURRENT_ROLES, $timeout, $state, ROUTE_INFO, REPORT_CHECKER, USER_META)->
        @isIE = false
        @show_main = false

        #用于定位当前用户的大领导身份
        @isHrDeputyManager = false
        @isServiceDeputyManager = false
        @isHrGeneralManager = false

        @current_roles = CURRENT_ROLES
        @root_info = ROUTE_INFO
        @reportCheckers = REPORT_CHECKER
        @user = USER_META

        @show_main = @root_info.single_point

        self = @

        @checkBossType()

        @rootScope.$watch 'hide_menu', (newVal, oldVal) ->
            self.hide_menu = newVal

        @rootScope.$watch 'show_main', (newVal, oldVal) ->
            self.show_main = newVal || self.show_main

    checkBossType: () ->
        self = @
        userPositionIds = []

        @user.positions.forEach (current)->
            userPositionIds.push current.position.id

        if userPositionIds.indexOf(@reportCheckers['副总经理（人事、劳动关系、招飞）']) > -1
            self.isHrDeputyManager = true

        if userPositionIds.indexOf(@reportCheckers['副总经理（培训、员工服务）']) > -1
            self.isServiceDeputyManager = true

        if userPositionIds.indexOf(@reportCheckers['人力资源部总经理']) > -1
            self.isHrGeneralManager = true

    # isBoss: () ->
    #     self = @

    #     userPositionIds = []
    #     bossPositionIds = []

    #     @user.positions.forEach (current)->
    #         userPositionIds.push current.position.id

    #     _.forEach @reportCheckers, (val, key) ->
    #         bossPositionIds.push val

    #     userPositionIds.forEach (current)->
    #         if bossPositionIds.indexOf(current) > -1
    #             self.show_boss = true


    backToHome: () ->
      @show_main = false
      @rootScope.show_main = false

app.controller('RootCtrl', RootController)