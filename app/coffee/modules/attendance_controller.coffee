
nb = @.nb
app = nb.app
extend = angular.extend
resetForm = nb.resetForm
Modal = nb.Modal



class Route
    @.$inject = ['$stateProvider', '$urlRouterProvider']

    constructor: (stateProvider, urlRouterProvider) ->

        urlRouterProvider.when('/self-service', '/self-service/profile')

        stateProvider
            .state 'attendance', {
                url: '/attendance'
                templateUrl: 'partials/attendance/attendance.html'
                controller: AttendanceCtrl
                controllerAs: 'ctrl'
            }

class AttendanceCtrl extends nb.Controller

    @.$inject = ['$scope', 'Leave']

    constructor: (@scope, @Leave) ->
        @loadInitailData()

    loadInitailData: ()->
        @leaves = @Leave.$collection().$fetch()
    searchLeaves: (tableState)->
        @leaves.$refresh(tableState)

    submitForm: (data)->
        @Leave.$create({day:3, desc:"因为某事需求请假三天"})

    

app.config(Route)
