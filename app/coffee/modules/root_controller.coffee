app = @nb.app

class RootController extends nb.Controller
    @.$inject = ['$scope', 'CURRENT_ROLES']

    constructor: ($scope, CURRENT_ROLES)->
        @current_roles = CURRENT_ROLES



app.controller('RootCtrl', RootController)