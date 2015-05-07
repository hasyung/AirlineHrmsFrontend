



app = @nb.app

enums = {}
forEach = angular.forEach
find = _.find

class EnumService
    @.$inject = ['nbConstants', 'inflector', '$q']

    constructor: (CONSTANTS, inflector, $q) ->

        forEach CONSTANTS, (value, key) ->
            enums[key] = value

        @get= (type) ->
            throw "resource type #{type} not existed" if !type || !enums[type]
            return enums[type]

        @parseLabel= (id, type) ->
            return '无' if (id == null || angular.isUndefined(id))
            id = id.id if angular.isObject id
            typedEnums = @get(type)
            res = find(typedEnums, (e) -> e.id == id)
            label = if angular.isObject(res) then res.label else "无"





# class EnumService
#     @.$inject = ['$http', 'inflector']

#     constructor: (@http, @inflector) ->

#     loadEnum: () ->
#         http = @http
#         inflector = @inflector
#         self = @

#         return (key) ->
#             #BUG: md-select beta 0.8.1 的 bug , 数据加载后,第二次打开依然会弹出加载进度条
#             delete enums[key] if enums[key]

#             onSuccess = (res, status) ->
#                 enums[key] = _.map res.data.result, (item) ->
#                     _.reduce(item, (res, val, key) ->
#                         res[inflector.camelize(key)] = val
#                         return res
#                     , {})
#             promise  = http.get("/api/enum?key=#{key}").then onSuccess.bind(self)

#     get: ->
#         return enums


app.service '$enum', EnumService