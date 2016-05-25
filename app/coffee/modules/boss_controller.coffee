nb = @.nb
app = nb.app


class Route
    @.$inject = ['$stateProvider', '$urlRouterProvider']

    constructor: (stateProvider, urlRouterProvider) ->
        stateProvider
            .state 'boss', {
                url: '/dashboard'
                views: {
                    boss_datas: {
                        template: '<h1> {{bCtrl.todos[0].id}} </h1>'
                        controller: BossDashBoardController
                        controllerAs: 'bCtrl'
                    }
                }
            }
            # .state 'boss.profile', {
            #     url: '/profile'
            #     controller: ProfileCtrl
            #     controllerAs: 'ctrl'
            #     templateUrl: 'partials/self/self_info_basic/self_info_basic.html'
            # }
            
            


class BossDashBoardController extends nb.Controller
    @.$inject = ['$scope', 'Todo', '$state']

    constructor: (@scope, Todo, @state) ->
        @todos = Todo.$collection().$fetch()

    


app.controller 'BossCtrl', BossDashBoardController


app.config(Route)