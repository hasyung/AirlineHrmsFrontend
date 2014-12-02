


nb = @.nb
app = nb.app


mixOf = nb.mixOf

# for finder 2.0
# api =
#     name:
#         displayName: '姓名'
#         type: 'string'

#     create_at:
#         displayName: '入职时间'
#         range: true
#         type: 'date'
#     age:
#         displayName: '年龄'

#     sex:
#         displayName: '性别'
#         type: 'select'
#         resource: 'sex'
#         data: [
#             {displayName: '男', type: 0}
#             {displayName: '女', type: 1}
#         ]

#     org:
#         displayName: '部门'
#         type: 'dynamicSelect'
#         url: '/orgs'
#         map: 'org.name'
#         key: 'org.id'

#     abc:
#         type: 'select'
#         resource: 'org'
# testApi =
#     name:
#         displayName: '姓名'
#         type: 'string'

# filter









class Route
    @.$inject = ['$stateProvider']

    constructor: (@stateProvider) ->
        # @stateProvider.state '/dsko', ()->



class StaffController extends mixOf(nb.Controller)

    @.$inject = ['$scope','$rootScope', 'Organ']

    constructor: (@scope, @rootscope, Organ) ->
        super()

        orgs = Organ.$search()

        orgs.abc()

        orgs.$asPromise().then (organs) ->
            organs.abc()

    loadInitialData: () ->


    buildOrganTree: () ->




        # @scope.filters.push()




app.config(Route)
app.controller('StaffController', StaffController)