
nb = @.nb
app = nb.app
extend = angular.extend
resetForm = nb.resetForm
Modal = nb.Modal



class Route
    @.$inject = ['$stateProvider']

    constructor: (stateProvider) ->
        stateProvider
            .state 'welfares', {
                url: '/welfares'
                templateUrl: 'partials/TODO/TODO.html'
            }

app.config(Route)
