
nb = @.nb
app = nb.app
extend = angular.extend
resetForm = nb.resetForm
Modal = nb.Modal



class Route
    @.$inject = ['$stateProvider', '$urlRouterProvider']

    constructor: (stateProvider, urlRouterProvider) ->

        stateProvider
            .state 'attendance', {
                url: '/attendance'
                templateUrl: 'partials/attendance/attendance.html'
                controller: AttendanceCtrl
                controllerAs: 'ctrl'
            }

class AttendanceCtrl extends nb.Controller

    @.$inject = ['$scope', 'Flow::EarlyRetirement', '$mdDialog']

    constructor: (@scope, @Leave, @mdDialog) ->
        @loadInitailData()

        @recordFilterOptions = {
            name: 'attendanceRecord'
            constraintDefs: [
                {
                    name: 'name'
                    displayName: '姓名'
                    type: 'string'
                    placeholder: '姓名'
                }
                {
                    name: 'employee_no'
                    displayName: '员工编号'
                    type: 'string'
                    placeholder: '员工编号'
                }
                {
                    name: 'department_ids'
                    displayName: '机构'
                    type: 'org-search'
                }
                
            ]
        }

    loadInitailData: ()->
        @flows = @Leave.$collection().$fetch()

    # searchLeaves: (tableState)->
    #     @flows.$refresh(tableState)

class AttendanceDialogCtrl extends nb.Controller
    @.$inject = ['$scope', 'data', '$mdDialog']
    constructor: (@scope, @data, @mdDialog) ->
        self = @
        @scope.data = @data

    pass: (leave)->
        self = @
        leave.audit.opinion = true
        leave.$update().$then ()->
            self.mdDialog.hide()
    reject: (leave)->
        self = @
        leave.audit.opinion = false
        leave.$update().$then ()->
            self.mdDialog.hide()




app.config(Route)
app.controller('AttendanceDialogCtrl', AttendanceDialogCtrl)
