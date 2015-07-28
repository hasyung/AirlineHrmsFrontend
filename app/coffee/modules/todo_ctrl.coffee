nb = @.nb
app = nb.app

class Route
    @.$inject = ['$stateProvider']

    constructor: (stateProvider) ->
        stateProvider
            .state 'TODO', {
                url: '/todo'
                templateUrl: 'partials/TODO/TODO.html'
                controller: TodoCtrl
                controllerAs: 'todoCtrl'
            }


class TodoCtrl
    @.$inject = ['Todo']

    constructor: (Todo) ->
        @todos = Todo.$collection().$fetch()


app.config(Route)