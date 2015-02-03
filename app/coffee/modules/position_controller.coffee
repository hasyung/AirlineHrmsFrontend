
nb = @.nb
app = nb.app
extend = angular.extend
resetForm = nb.resetForm
Modal = nb.Modal



class Route
    @.$inject = ['$stateProvider']

    constructor: (stateProvider) ->
        stateProvider
            .state 'position', {
                url: '/positions'
                templateUrl: 'partials/position/position.html'
                controller: PositionCtrl
                controllerAs: 'ctrl'
                ncyBreadcrumb: {
                    label: "岗位"
                }
                resolve: {
                }
            }
            .state 'position.detail', {
                url: '/{posId:[0-9]+}'
                views: {
                    "@": {
                        controller: PosCtrl
                        controllerAs: 'ctrl'
                        templateUrl: 'partials/position/position_detail.html'
                    }
                }
                ncyBreadcrumb: {
                    label: "{{currentPos.name}}"
                }
            }
            .state {
                name: 'position.detail.editing'
                url: '/editing/:template'
                views: {
                    "@": {
                        controller: PosCtrl
                        controllerAs: 'ctrl'
                        templateUrl: (params) ->
                            return "partials/position/position_edit_#{params.template}.html"
                    }
                }
                ncyBreadcrumb: {
                    label: "编辑"
                }
            }
            .state {
                name: 'position.new'
                url: '/new'
                views: {
                    "@": {
                        controller: PosCreateCtrl
                        controllerAs: 'ctrl'
                        templateUrl: 'partials/position/position_add.html'
                    }
                }
                ncyBreadcrumb: {
                    label: "新增"
                }
            }


class PositionCtrl extends nb.Controller

    @.$inject = ['Position', '$scope', 'sweet']


    constructor: (@Position, @scope, @sweet) ->
        @loadInitialData()
        scope.tableState = null

    loadInitialData: ->
        @positions = @Position.$collection().$fetch()

    search: (tableState) ->
        @positions.$refresh(tableState)


class PosCtrl extends nb.Controller
    @.$inject = ['$stateParams', 'Position', '$scope', '$state', 'Org']

    constructor: (@params, @Position, @scope, @state, @Org) ->
        @loadInitialData()
    loadInitialData: () ->
        self = @
        posId = @params.posId
        @Position.$find(posId).$then (position) ->
            self.scope.currentPos = position

            spe = position.specification.$fetch()
            spe.$asPromise().then (spe) ->
                self.scope.currentSpe = spe

    updateDetail: (position) ->
        self = @
        position.$save().$then () -> self.state.go "^"
    updateAdvanced: (advance) ->
        self = @
        @scope.currentSpe.$update(advance).$then ()->
            self.state.go '^'


class PosCreateCtrl extends nb.Controller
    @.$inject = ['$stateParams', 'Position', '$scope', 'Org', '$state']

    constructor: (@params, @Position, @scope, @Org, @state) ->


    createPos: () ->
        self = @
        @position.specification = @specification
        #将页面跳转放在then里，防止当跳转过去时新创建的岗位未被添加到岗位列表
        newPos = @Position.$create(@position).$then ()->
            self.state.go '^'
    store: (attr, value) ->
        this[attr] = value




app.config(Route)
