
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

    @.$inject = ['$scope', 'sweet', 'Employee', '$rootScope']


    

app.config(Route)
