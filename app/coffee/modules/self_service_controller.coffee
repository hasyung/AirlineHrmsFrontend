
nb = @.nb
app = nb.app
extend = angular.extend
resetForm = nb.resetForm
Modal = nb.Modal



class Route
    @.$inject = ['$stateProvider', '$urlRouterProvider']

    constructor: (stateProvider, urlRouterProvider) ->

        stateProvider
            .state 'self', {
                url: '/self-service'
                templateUrl: 'partials/self/self_info.html'
                controller: ProfileCtrl
                controllerAs: 'ctrl'
            }
            .state 'self.profile', {
                url: '/profile'
                controller: ProfileCtrl
                controllerAs: 'ctrl'
                templateUrl: 'partials/self/self_info_basic/self_info_basic.html'
            }
            .state 'self.members', {
                url: '/members'
                controller: ProfileCtrl
                controllerAs: 'ctrl'
                templateUrl: 'partials/self/self_info_family/self_info_members.html'
            }
            .state 'self.education', {
                url: '/education'
                controller: ProfileCtrl
                controllerAs: 'ctrl'
                templateUrl: 'partials/self/education.html'
            }
            .state 'self.experience', {
                url: '/experience'
                controller: ProfileCtrl
                controllerAs: 'ctrl'
                templateUrl: 'partials/self/experience.html'
            }
            .state 'self.resume', {
                url: '/resume'
                controller: ProfileCtrl
                controllerAs: 'ctrl'
                templateUrl: 'partials/self/self_resume.html'
            }
            .state 'my_requests', {
                url: '/self/my_requests'
                templateUrl: 'partials/self/my_requests/index.html'
                controller: MyRequestCtrl
                controllerAs: 'ctrl'
            }
            .state 'self_position', {
                url: '/self-service-position'
                templateUrl: 'partials/self/transfer_position.html'
            }

# class SelfCtrl extends nb.Controller

#     @.$inject = ['$scope', 'sweet', 'Employee', '$rootScope']


#     constructor: (@scope, @sweet, @Employee, @rootScope) ->
#         @scope.currentUser = @rootScope.currentUser
#         @loadInitailData()

#     loadInitailData: ->




class ProfileCtrl extends nb.Controller

    @.$inject = ['$scope', 'sweet', 'Employee', '$rootScope', 'User', 'USER_META']


    constructor: (@scope, @sweet, @Employee, @rootScope, @User, @USER_META) ->
        @loadInitailData()
        @status = 'show'

    loadInitailData: ->
        @scope.currentUser = @User.$fetch()
        # @scope.currentUser.educationExperiences.$refresh()
        # @scope.currentUser.workExperiences.$fetch()

    # 员工自助中员工编辑自己的信息
    updateInfo: ->
        @scope.currentUser.$update()
    updateEdu: (edu)->
        edu.$save()
    createEdu: (edu)->
        @scope.currentUser.educationExperiences.createEdu(edu)
        # @scope.currentUser.$update()
        #
    updateFavicon: ()->
        self = @
        @scope.currentUser.$refresh().$then ()->
            angular.extend self.USER_META.favicon, self.scope.currentUser.favicon



class MyRequestCtrl extends nb.Controller

    @.$inject = ['$scope', 'Employee', 'OrgStore']

    constructor: ($scope, @Employee, @OrgStore) ->

        @reviewers = @loadReviewer()

    loadReviewer: () ->
        @Employee.$search({category_ids: [1,2], department_ids: [@OrgStore.getPrimaryOrgId()]})



app.config(Route)
