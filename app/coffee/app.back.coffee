

@nb = nb = {}



restConf = (restmodProvider) ->
    restmodProvider.rebase 'VXstoreApi',
        $config:
            PACKER: 'DefaultPacker'
            urlPrefix: 'api'
            style: 'AMS'
        # $hooks: {
        #     'before-request': (_req)->
        #         _req.url += '.json'
        # }



models = angular.module('models',[])


models.factory 'VXstoreApi',(restmod, RMUtils) ->

    Utils = RMUtils

    restmod.mixin {
        'Record.$store': (_patch) ->
            self = @
            self.$action () ->
                url = Utils.joinUrl(self.$url('update'),_patch)

                request =
                    method: 'PATCH'
                    url: url
                    data: self.$wrap (_name) -> _patch.indexOf(_name) == -1

                onSuccess = (_response) ->
                    self[_patch] = _response.data

                onErorr = (_response) ->
                    self.$dispatch 'after-store-error', [_response]

                @.$send request, onSuccess, onErorr



    }

models.factory 'User',(restmod) ->
    User = restmod.model('/users').mix('VXstoreApi', {
        # created_at: { serialize: 'RailsDate' } #todo 序列化器
        updated_at: { decode: 'date', param: 'yyyy年mm月dd日',mask: 'CUR' } #不 send CURD 操作时
        permissions: { belongsToMany: 'Permission', keys: 'permission_ids'}
        # permission_ids: { mask: 'CU' }
        organ: { mask: 'CU'}
        organs: { hasMany: 'Organ'}
        gender: { mask: 'U'}
        # orgName: { map: 'organ'}

        # decode: () ->
        #     console.debug 'decode debug :', arguments

        orgName: { ignore: true }

        $extend:
            Model:
                unpack: (resource,_raw) ->
                    console.debug 'resource,raw',resource,_raw
                    _raw.orgName = _.pluck(_raw.organ,'name').join(',')
                    _raw


        $hooks:
            'after-feed-many': (raw) ->
                console.debug 'after feed many this:' ,this
            'after-feed': (raw) ->
                org = raw.organ
                this.orgName = _.pluck(org,'name').join(',')



    })


models.factory 'Organ', (restmod) ->
    Org = restmod.model '/organs'

models.factory 'Permission',(restmod) ->
    Permission = restmod.model('/permissions')



routeConf = ($stateProvider,$urlRouterProvider,$locationProvider) ->
    $locationProvider.html5Mode(false)

    #default route
    $urlRouterProvider.otherwise('/')
    $stateProvider
        .state 'home', {template: 'home.html'}


deps = [
    'ui.router'
    'ui.select'
    'models'
    # 'ui.bootstrap'
    'ngSanitize'
    'ngMessages'
    'restmod'    #rest api
    # 'satellizer' #登陆验证
    # 'toaster' # 后台通知组件 Angular-toaster
]

App = angular.module 'nb',deps

App
    .config ['restmodProvider',restConf]
    .config ['$stateProvider','$urlRouterProvider','$locationProvider',routeConf]
    .run ['$state','$rootScope', ($state,$rootScope) ->
        # for $state.includes in view
        $rootScope.$state = $state

        console.log "state : #{JSON.stringify $state.current}"

    ]



App.controller 'Ctrl',(User) ->
    console.debug "User.$url() : #{User.$url()}"

    users = User.$search()

    users.$then (us) ->
        current = us[0]

        console.debug "current User: ",current

        # current.permissions.splice(0,3)·

        # permis =  current.permissions[0].$fetch()

        # permis.$save()


        current.$save(['name','permissions'])

        current.$store('gender')

        # permissions =  current.permissions.$fetch()
        # org = current.organs.$fetch()
        # permissions.$save()

        # console.debug permissions











nb.app = App
