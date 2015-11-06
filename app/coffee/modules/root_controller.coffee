app = @nb.app

class RootController extends nb.Controller
    @.$inject = ['$scope', '$rootScope', 'CURRENT_ROLES']

    constructor: (@scope, @rootScope, CURRENT_ROLES)->
        @show_main = false
        @current_roles = CURRENT_ROLES

        self = @

        @rootScope.$watch 'show_main', (newVal, oldVal) ->
            self.show_main = newVal

    backToHome: () ->
        @show_main = false
        @rootScope.show_main = false

app.controller('RootCtrl', RootController)