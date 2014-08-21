angular.module 'vx.controllers.knowledge',[]

    .config ['$stateProvider', ($stateProvider) ->

        $stateProvider
            .state 'knowledge.articles', {
                views: {
                    'searchbar' : {
                        template: require( '../knowledge/searchbar.jade')()
                    }
                }
            }
            # .state 'knowledge.articles.home', {
            #     url: ''
            #     views: {
            #         '@knowledge': {
            #             template: require( '../knowledge/articles.jade')()
            #         }
            #     }
            # }
            .state 'knowledge.articles.public', {
                url: ''
                views: {
                    '@knowledge': {
                        template: require( '../knowledge/articles.jade')()
                    }
                }
            }
            .state 'knowledge.articles.my', {
                url: '/articles/my'
                views: {
                    '@knowledge': {
                        template: require('../knowledge/my.jade')()
                    }
                }
            }
            .state 'knowledge.articles.auditing', {
                url: '/articles'
                abstract: true
                views: {
                    '@knowledge': {
                        template: require( '../knowledge/auditing.jade')()
                    }
                }
            }
            .state 'knowledge.articles.auditing.auditing', {
                url: '/auditing'
                views: {
                    'auditItemView': {
                        template: require('../knowledge/audit/auditing.jade')()
                    }
                }
            }
            .state 'knowledge.articles.auditing.audited', {
                url: '/audited'
                views: {
                    'auditItemView': {
                        template: require('../knowledge/audit/audited.jade')()
                    }
                }
            }
            .state 'knowledge.articles.search', {
                url: '/articles/search/:keyword'
                views: {
                    '@home': {
                        template: require('../knowledge/search_result.jade')()
                        controller: 'KSearchCtrl'
                    }
                }
            }
            .state 'knowledge.articles.new', {
                url: '/articles/new'
                views: {
                    '@home': {
                        controller: 'KEditCtrl'
                        template: require('../knowledge/new.jade')()
                    }
                }
            }
            .state 'knowledge.articles.byId', {
                url: '/articles/:articleId',
                views: {
                    '@home': {
                        template: require('../knowledge/article_item.jade')()
                    },
                    'comment@knowledge.articles.byId' : {
                        controller: 'KArticleCtrl',
                        template: require('../knowledge/comments.jade')()
                    }
                }
            }
            .state 'knowledge.articles.auditById', {
                url: '/articles/:articleId/:audit',
                views: {
                    '@home': {
                        template: require('../knowledge/article_item.jade')()
                    },
                    'comment@knowledge.articles.auditById' : {
                        controller: 'KArticleCtrl',
                        template: require('../knowledge/comments.jade')()
                    }
                }
            }
            .state 'knowledge.articles.byId.edit', {
                url: 'articles/:articleId/edit/:audit'
                views: {
                    '@home': {
                        controller: 'KEditCtrl'
                        template: require('../knowledge/new.jade')()
                    }
                }
            }
    ]


    .factory 'knowledgeService', ['Restangular','$q',(Restangular,$q) ->

        Knowledge = Restangular.one('knowledge')

        Articles = Knowledge.all('articles')

        _types = undefined
        ###*
         * 加载文章
         * @param  {[string|object]} 路由
         * @param  {[object]} query参数
         * @return {[articles]}
        ###
        load = (route,query) ->
            if(typeof route == 'object')
                query = route
                if query.group_id == 'public'  #公共文档
                    Articles.all('public').getList(_.omit(query,'group_id'))
                else
                    Articles.getList(query)
            else
                Route =  Articles.all(route).getList(query)

        loadById = (articleId) ->
            Articles.one(articleId).get()

        del = (articleId) ->
            Articles.one(articleId).remove()

        allTypes = () ->
            deferred = $q.defer()
            promise = deferred.promise
            $object = []
            promise.$object = $object
            if _types
                $object = angular.copy(_types)
                deferred.resolve($object)
            else
                Knowledge.all('types').getList().then (types) ->
                    _types = types.plain()
                    _.extend($object,angular.copy(_types))
                    deferred.resolve($object)
            promise


        # Restangular.service('public',article)
        serve = (route) ->
            Articles.one(route)

        return {
            load: load
            del : del
            allTypes: allTypes
            serve: serve
        }


    ]

    .controller 'KIndexCtrl',['$scope','Restangular','$state','knowledgeService','userProfile','$controller',
    ($scope,Restangular,$state,knowledgeService,userProfile,$controller) ->
        public_group = {
            name: '公共文档'
            id :'public'
            active: true
        }
        # public  my  auditing  三个模块的数据路由
        if $state.includes('knowledge.articles')
            route =  $state.current.name.split('.').pop()
        else
            throw new Error('路由错误！')

        $scope.articles = knowledgeService.load(route).$object
        $scope.types    = knowledgeService.allTypes().$object
        # $scope.groups   = userProfile.joined_groups().call('unshift',public_group).$object
        $scope.groups   = userProfile.joined_groups().$object
        $scope.groups.unshift(public_group)

        queryMgr = ($scope,group) ->
            this.scope = $scope
            this.group = group
            this.type = undefined
        queryMgr.prototype.select_group = (group) ->
            this.group = group
            this.scope.$emit('$queryChanged',this.getQueryParam())
        queryMgr.prototype.select_type = (type) ->
            this.type = if this.type == type then undefined else type
            this.scope.$emit('$queryChanged',this.getQueryParam())
        queryMgr.prototype.getQueryParam = () ->
            param = {}
            param.group_id = this.group.id
            param.type_id  = this.type.id if this.type
            return param

        $scope.queryMgr = $controller(['$scope','group',queryMgr],{$scope: $scope.$new(),group: public_group})

        $scope.$on '$queryChanged',(evt,param) ->
            evt.preventDefault()
            $scope.articles = knowledgeService.load(param).$object


        #for test
        #$scope.current_user = userProfile.current_user
        $scope.current_user = {
            is_admin: true
        }
        Knowledge = Restangular.one('knowledge')

        loadArticles = (param) ->
            $scope.articles = knowledgeService.load(param).$object

        $scope.$on '$stateChangeSuccess',(evt,toState) ->
            evt.preventDefault()
            $scope.articles = switch toState.name
                when 'knowledge.articles.public' then loadArticles('public')
                when 'knowledge.articles.my'then loadArticles('my')
                when 'knowledge.articles.auditing' then loadArticles('auditing')
                when 'knowledge.articles.auditing.auditing' then loadArticles('auditing')
                when 'knowledge.articles.auditing.audited' then loadArticles('audited')
                else loadArticles('public')


        #对已通过审核的文档进行编辑，删除，屏蔽
        $scope.editArticle = (articleId) ->
            $state.go('knowledge.articles.byId.edit', {articleId:articleId, audit:true})

        $scope.deleteArticle = (articleId) ->
            if confirm("你确定删除这篇文章吗？")
                knowledgeService.del articleId
                $state.go('knowledge.articles.auditing.audited', {}, {reload: true})

        $scope.shieldArticle = (articleId) ->
           if confirm("你确定要屏蔽这篇文章吗？")
                Knowledge.one('articles', articleId).one("shield").put().then (data) ->
                    $state.go('knowledge.articles.auditing.audited', {}, {reload: true})

        $scope.canelShieldArticle = (articleId) ->
            if confirm("你确定要取消屏蔽这篇文章吗？")
                Knowledge.one('articles', articleId).one("canel_shield").put().then (data) ->
                    $state.go('knowledge.articles.auditing.audited', {}, {reload: true})

# queryMgr = $controller(queryMgr)

# queryMgr = ($scope) ->
#     current_group = undefined
#     type = undefined

#     this.select_group = (group) ->
#         if current_group == group
#             current_group = undefined
#         else
#             current_group = group
#     this.select_type = (type)->
#         if current_type == type
#             current_type = undefined
#         else
#             current_type = type




        # init = () ->
        #     $scope.articles = loadArticles('public')
        #     $scope.cols = [[],[],[]]

        #load  articles
        # loadArticles = (route,query = {}) ->
        #     if query.group_id == 'public'
        #         delete query.group_id
        #         route = 'public'

        #     unless route
        #         Articles.getList(query).$object
        #     else
        #         Articles.all(route).getList(query).$object

        # loadIndexEntrys = () ->
        #     $scope.cols = [[],[],[]]
        #     Articles.all('home').getList().then (types) ->
        #         $scope.cols = _.map $scope.cols,(col,colIndex) ->
        #             colTypes = _.filter types,(type,typeIndex)->
        #                 typeIndex % $scope.cols.length == colIndex
        #             col.concat colTypes



        # loadArticleById = (articleId, reff) ->
        #     Articles.one(articleId).get().$object

        # select_group = (group) ->
        #     $scope.current_group = group
        #     if group.active
        #         return
        #     query = _current_query()

        #     grp.active = false for grp in $scope.user_groups

        #     group.active = true
        #     #兼容公共文档
        #     if group.id == public_group.id
        #         $scope.current_group = undefined
        #         delete query.group_id
        #         $scope.articles = loadArticles('public',query)
        #     else
        #         query.group_id = group.id
        #         $scope.articles = loadArticles("",query)
        # toggle_type = (typ) ->
        #     $scope.current_type = typ

        #     query = _current_query()
        #     is_current_active = typ.active

        #     if is_current_active
        #         $scope.current_type = undefined

        #     type.active = false for type in $scope.types
        #     unless is_current_active
        #         typ.active = true
        #     if typ.active
        #         query.type_id = typ.id
        #     else
        #         delete query.type_id

        #     $scope.articles = loadArticles("",query)

        # _current_query =()->
        #     query = {}
        #     _get = (args) ->
        #         _.find args, (arg)->
        #             return arg.active
        #     group_id = _get($scope.user_groups).id
        #     type = _get($scope.types)
        #     query.group_id = group_id if group_id?
        #     query.type_id = type.id if type?

        #     return query



        # Knowledge = Restangular.one('knowledge')

        # Articles = Knowledge.all('articles')
        #绑定行为
        # $scope.loadArticleById = loadArticleById
        # $scope.select_group = select_group
        # $scope.toggle_type =toggle_type

        # $scope.current_user = Restangular.one('users','me').get().$object
        # Restangular.one('users','me').all('joined_groups').getList().then (groups) ->

        #     #默认不选中任何组
        #     _.each groups, (group)->
        #         group.active = false
        #     # 默认路由到公共文档
        #     groups.unshift public_group

        #     $scope.user_groups = groups

        # $scope.types = Knowledge.all('types').getList().$object


        # $scope.$on '$stateChangeSuccess',(evt,toState) ->
        #     evt.preventDefault()
        #     $scope.articles = switch toState.name
        #         when 'knowledge.articles.home' then loadIndexEntrys()
        #         when 'knowledge.articles.public' then loadArticles('public')
        #         when 'knowledge.articles.my'then loadArticles('my')
        #         when 'knowledge.articles.auditing' then loadArticles('auditing')
        #         else loadArticles('public')





        # auditInit = () ->
        #     Articles.all('audited').getList().then (data) ->
        #         $scope.publicedArticles = data


        #对已通过审核的文档进行编辑，删除，屏蔽
        # $scope.editAction = (articleId) ->
        #     $state.go('knowledge.articles.byId.edit', {articleId:articleId, audit:true})

        # $scope.deleteAction = (articleId) ->
        #     if confirm("你确定删除这篇文章吗？")
        #         Knowledge.one('articles', articleId).remove().then (data) ->
        #             if data
        #                 auditInit()

        # $scope.shieldArticle = (articleId) ->
        #    if confirm("你确定要屏蔽这篇文章吗？")
        #         Knowledge.one('articles', articleId).one("shield").put().then (data) ->
        #             if data
        #                 auditInit()
        #             else
        #                 console.log "屏蔽文章失败"

        # $scope.canelShieldArticle = (articleId) ->
        #     if confirm("你确定要取消屏蔽这篇文章吗？")
        #         Knowledge.one('articles', articleId).one("canel_shield").put().then (data) ->
        #             if data
        #                 auditInit()
        #             else
        #                 console.log "取消屏蔽失败"

        # $scope.waitDisplay = true

        # $scope.switchArticles = (display) ->
        #     $scope.waitDisplay = display
        #     #当display为false时加载审核通过的文章，否则加载待审核的文章
        #     if !display
        #         Articles.all('audited').getList().then (data) ->
        #             $scope.publicedArticles = data
        #     else
        #         $scope.articles = loadArticles('auditing')




    ]
    .controller 'KArticleCtrl', ['$scope','Restangular','$state','$stateParams','$sce'
    ($scope,Restangular,$state,$stateParams,$sce) ->

        articleId = $stateParams.articleId

        $scope.focusInput = false
        $scope.myReply = {}

        audit = $stateParams.audit
        #
        getTypeObjById = (types, typeId) ->
            temp = {}
            angular.forEach types, (item) ->
                if item.id == typeId
                    temp = item
            return temp;

        # 1、只有当当前用户就是作者本人时才会有编辑
        # 2、在已发布情况下任何人都没权限去编辑
        # 3、在审核过程中只有作者才能修改和删除
        Article = Restangular.one('knowledge').one('articles',articleId)
        Restangular.one('knowledge').one('articles',articleId).get().then (article) ->
            #文章权限管理
            Restangular.one('users','me').get().then (user) ->
                if article.author_name == user.name &&
                        (article.check_status == 1 || article.check_status == 3 || article.check_status == 4)
                    article.editable = true
                    article.deletable= true
                if article.check_status == 2
                    article.commentable = true
                if user.is_admin && article.check_status == 1 && audit == 'true'
                    article.reviewable = true
                    article.editable = false
                    article.deletable= false
                $scope.article = article

                Restangular.one('knowledge').all('types').getList().then (types) ->
                    $scope.currentType = getTypeObjById(types, $scope.article.type_id)


        Comments = Restangular.one('knowledge').one('articles', articleId).all('comments')
        Comments.getList().then (comments) ->
            $scope.comments = comments
        $scope.deleteArticle = () ->
            if confirm("你确定删除这篇文章吗？")
                Restangular.one('knowledge').one('articles', articleId).remove().then (date) ->
                    $state.go('^.my')


        $scope.replyAuthor = (comment) ->
            Comments.post({comment:comment}).then (servData) ->
                    $scope.comments.push servData
                $scope.myReply = {}



        $scope.publishArticle = () ->
            Restangular.one('knowledge').one('articles',articleId).one('publish').put()

        $scope.auditArticle = (result) ->
            Article.one('audit').put({passed:result}).then (data) ->
                $state.go("knowledge.articles.auditing")


    ]
    .controller 'KCommentRowCtrl', ['$scope','Restangular','$stateParams', ($scope,Restangular,$stateParams) ->

        articleId = $stateParams.articleId
        $scope.replying = false

        Comments = Restangular.one('knowledge').one('articles', articleId).all('comments')


        $scope.replyTo = (index) ->
            if $scope.replying == true
                $scope.cancel()
                return

            $scope.replying = true
            $scope.reply_to_id = $scope.comment.id
            $scope.content = "回复 #{$scope.comment.creator.name}："
        $scope.reply = () ->
            entry = {
                content: $scope.content
                reply_to_id: $scope.reply_to_id
            }
            Comments.post(entry).then (realComment) ->
                $scope.comment.replys.push(realComment)
            $scope.replying = false

        $scope.cancel = () ->
            $scope.replying = false

    ]
    .controller 'KSearchCtrl', ['$scope','Restangular','$state','$stateParams'
    ($scope,Restangular,$state,$stateParams) ->

        # rework
        $scope.search = (text) ->
            $state.go('^.search',{keyword: text})

        # end
        $scope.search_keyword = $stateParams.keyword


        articles = Restangular.one('knowledge','articles')
            .all('search').getList({keyword: $scope.search_keyword}).$object

        $scope.articles = articles

    ]



    .controller 'KEditCtrl', [
        '$scope'
        'knowledgeService'
        'userProfile'
        'Restangular'
        '$state'
        '$stateParams'
        '$timeout'
        ($scope,knowledgeService,userProfile,Restangular,$state,$stateParams,$timeout) ->


            # rework
            $scope.search = (text) ->
                $state.go('^.search',{keyword: text})

            # resume article if old article
            resumeArticle = (article,groupPromise,typePromise) ->
                $scope.article.title = article.title
                $scope.article.permissions = article.permissions
                $scope.article.tags = article.tags
                $scope.article.html_content = article.html_content

                _resumeGroup = (groups) ->
                    $scope.article.group = _.find groups,(group) ->
                        group.id = article.group_id
                    # $scope.group ||= newGroups[0]

                _resumeType = (types) ->
                    $scope.article.type = _.find types, (type) ->
                        type.id = article.type_id
                    # 默认类型
                    $scope.article.type ||= types[0]

                groupPromise.then _resumeGroup
                typePromise.then _resumeType

                # if $scope.groups.length == 0
                #     canceled = $scope.$watch 'groups',(newGroups,old) ->
                #         $scope.group = _.find newGroups,(group) ->
                #             group.id = article.group_id
                #         $scope.group ||= newGroups[0]
                # else
                #     $scope.group = _.find $scope.groups,(group) ->
                #         group.id = article.group_id





            # isNew = true

            # audit = $stateParams.audit
            # if audit == "true"
            #     $scope.editorDisabled = true

            # 解决model之间关联关系
            # $timeout(() ->
            #     $scope.article.type  = _.find $scope.types, (type) ->
            #         type.id == $scope.article.type_id
            #     if $scope.article.group_id?
            #         $scope.article.group  = _.find $scope.groups, (group) ->
            #             group.id == $scope.article.group_id

            #     $scope.article.type = $scope.types[0] unless $scope.article.type?
            #     $scope.article.group = $scope.groups[0] unless $scope.article.group?
            # ,600)
            # end

            # 下拉框数据
            $scope.article = {}
            $scope.groups = []
            $scope.types = []
            $scope.article.permissions = 'public'
            $scope.article.groupDisabled = true
            $scope.article.tags = []
            $scope.article.title = ""
            $scope.article.group = undefined
            $scope.article.type = undefined
            $scope.article.html_content = ""
            # 监控
            $scope.$watch 'permissions', (newVal,oldVal) ->
                if newVal == 'public'
                    $scope.groupDisabled = true
                else
                    $scope.groupDisabled = false



            init = () ->

                groupPromise = userProfile.joined_groups()
                typePromise = knowledgeService.allTypes()

                $scope.groups = groupPromise.$object
                $scope.types = typePromise.$object

                if $state.includes 'knowledge.articles.*.edit'
                    unless _.has $stateParams,'article'
                        throw new Error("KEditCtrl status Error, stateParams : #{JSON.parse $stateParams}")
                    resumeArticle($stateParams.article,groupPromise,typePromise)


            init()


            $scope.save = (article,form) ->
                # article.type_id = $scope.type.id if $scope.type?
                # article.group_id = $scope.type.id if article.group?
                # article.draft = true
                # return if form.$invalid

                article = article.plain() if article.plain?

                if article.group
                    article.group_id = article.group.id
                    delete article.group
                if article.type
                    article.type_id = article.type.id
                    delete article.type


                article.cover_cache = ''

                formData = new FormData()

                _.forEach article,(val,key) ->
                    if article.hasOwnProperty(key)
                        formData.append("article[#{key}]",val)

                service = Articles.withHttpConfig({transformRequest: angular.identity})

                if isNew # 上传图片
                    promise = service.customPOST(formData, undefined, undefined, {'Content-Type': undefined}).then () ->
                else
                    promise = service.customPUT(formData,article.id,undefined,{'Content-Type': undefined}).then () ->
                promise.then () ->
                    $state.go('knowledge.articles.my')




    ]
