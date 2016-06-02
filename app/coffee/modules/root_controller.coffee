app = @nb.app

class RootController extends nb.Controller
    @.$inject = ['$scope', '$rootScope', 'CURRENT_ROLES', '$timeout', '$state', 'ROUTE_INFO', 'REPORT_CHECKER', 'USER_META']

    constructor: (@scope, @rootScope, CURRENT_ROLES, $timeout, $state, ROUTE_INFO, REPORT_CHECKER, USER_META)->
        @isIE = false
        @show_main = false
        @show_boss = false
        @current_roles = CURRENT_ROLES
        @root_info = ROUTE_INFO
        @reportCheckers = REPORT_CHECKER
        @user = USER_META

        @show_main = @root_info.single_point

        self = @

        @isBoss()

        @rootScope.$watch 'hide_menu', (newVal, oldVal) ->
            self.hide_menu = newVal

        @rootScope.$watch 'show_main', (newVal, oldVal) ->
            self.show_main = newVal || self.show_main

    isBoss: () ->
        self = @

        userPositionIds = []
        bossPositionIds = []

        @user.positions.forEach (current)->
            userPositionIds.push current.position.id

        _.forEach @reportCheckers, (val, key) ->
            bossPositionIds.push val

        userPositionIds.forEach (current)->
            if bossPositionIds.indexOf(current) > -1
                self.show_boss = true


    backToHome: () ->
      @show_main = false
      @rootScope.show_main = false

app.controller('RootCtrl', RootController)