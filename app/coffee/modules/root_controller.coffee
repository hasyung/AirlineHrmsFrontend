app = @nb.app

class RootController extends nb.Controller
    @.$inject = ['$scope', '$rootScope', 'CURRENT_ROLES', '$timeout', '$state', 'ROUTE_INFO']

    constructor: (@scope, @rootScope, CURRENT_ROLES, $timeout, $state, ROUTE_INFO)->
        # @isIE = @rootScope.isIE
        @isIE = false
        @show_main = false
        @current_roles = CURRENT_ROLES
        @root_info = ROUTE_INFO

        @show_main = @root_info.single_point

        self = @

        @rootScope.$watch 'hide_menu', (newVal, oldVal) ->
            self.hide_menu = newVal

        @rootScope.$watch 'show_main', (newVal, oldVal) ->
            self.show_main = newVal || self.show_main

    backToHome: () ->
      @show_main = false
      @rootScope.show_main = false

app.controller('RootCtrl', RootController)