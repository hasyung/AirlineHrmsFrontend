angular.module 'vx.services',[]

    # .factory 'restHelper',[ '$q',($q)->


    #     # (promise) ->
    #     #     deferred = $q.defer()
    #     #     promise.then()

    #     return {}

    # ]

    .factory 'userProfile',['$rootScope','Restangular','$q',($rootScope,Restangular,$q) ->

        User = Restangular.all('users')

        _group = undefined
        _user  = undefined

        current_user = () ->
            _user = User.one('me').get().$object if !_user
            _user
        #用户的参加的组
        joined_groups = () ->
            deferred = $q.defer()
            promise = deferred.promise
            $object = [] #默认为引用
            promise.$object = $object
            if _group
                _.extend($object,angular.copy(_group))
                deferred.resolve($object)
            else
                User.one('me','joined_groups').getList().then (groups) ->
                    _group = groups.plain()
                    _.extend($object,angular.copy(_group))
                    deferred.resolve($object)

            promise

        return {
            current_user: current_user
            joined_groups: joined_groups
        }


    ]