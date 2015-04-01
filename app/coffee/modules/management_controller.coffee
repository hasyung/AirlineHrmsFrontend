
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
            .state 'self', {
                url: '/self-service'
                templateUrl: 'partials/self/self_info.html'
                controller: ProfileCtrl
                controllerAs: 'ctrl'
                ncyBreadcrumb: {
                    label: "员工自助"
                }
            }
            .state 'self.profile', {
                url: '/profile'
                controller: ProfileCtrl
                controllerAs: 'ctrl'
                templateUrl: 'partials/self/self_info_basic/self_info_basic.html'
            }
            # .state 'self.profile.basic', {
            #     url: ''
            #     views: {
            #         "detail@self.profile": {
            #             controller: ProfileCtrl
            #             controllerAs: 'ctrl'
            #             templateUrl: 'partials/self/self_info_basic/self_info_basic.html'
            #         }
            #     }
            #     ncyBreadcrumb: {
            #         label: "我的基本信息"
            #     }

            # }
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

# class SelfCtrl extends nb.Controller

#     @.$inject = ['$scope', 'sweet', 'Employee', '$rootScope']


#     constructor: (@scope, @sweet, @Employee, @rootScope) ->
#         @scope.currentUser = @rootScope.currentUser
#         @loadInitailData()

#     loadInitailData: ->




class ProfileCtrl extends nb.Controller

    @.$inject = ['$scope', 'sweet', 'Employee', '$rootScope', 'FileUploader']


    constructor: (@scope, @sweet, @Employee, @rootScope, @FileUploader) ->
        @loadInitailData()
        @status = 'show'
        uploader = @scope.uploader = new FileUploader {
            url: '/api/me/upload_favicon'
            method: 'PUT'
        }
        uploader.onAfterAddingFile = (fileItem)->
            console.log fileItem
            fileItem.upload()

    loadInitailData: ->
        @scope.currentUser = @rootScope.currentUser
        # @scope.currentUser.educationExperiences.$refresh()
        # @scope.currentUser.workExperiences.$fetch()


    # 员工自助中员工编辑自己的信息
    updateInfo: ->
        @scope.currentUser.$update()
    updateEdu: (edu)->
        edu.$save()
    createEdu: (edu)->
        @scope.currentUser.educationExperiences.createEdu(edu);
        # @scope.currentUser.$update()






app.config(Route)
