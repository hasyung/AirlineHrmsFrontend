


nb = @.nb
app = nb.app


mixOf = nb.mixOf





api =
    name:
        displayName: '姓名'
        type: 'string'

    create_at:
        displayName: '入职时间'
        range: true
        type: 'date'
    age:
        displayName: '年龄'

    sex:
        displayName: '性别'
        type: 'select'
        resource: 'sex'
        data: [
            {displayName: '男', type: 0}
            {displayName: '女', type: 1}
        ]

    org:
        displayName: '部门'
        type: 'dynamicSelect'
        url: '/orgs'
        map: 'org.name'
        key: 'org.id'

    abc:
        type: 'select'
        resource: 'org'


testApi =
    name:
        displayName: '姓名'
        type: 'string'

# filter

class StaffController extends mixOf(nb.Controller, nb.FiltersMixin)

    @.$inject = ['$scope','$rootScope']

    constructor: (@scope, @rootscope) ->
        super()
        @decodeFilter(testApi)

        # @scope.filters.push()









app.controller('StaffController', StaffController)