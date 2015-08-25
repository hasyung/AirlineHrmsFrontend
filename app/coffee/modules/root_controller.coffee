app = @nb.app

class RootController extends nb.Controller
    @.$inject = ['$scope', '$rootScope', 'CURRENT_ROLES']

    constructor: ($scope, $rootScope, CURRENT_ROLES)->
      @show_main = false
      @current_roles = CURRENT_ROLES


app.controller('RootCtrl', RootController)