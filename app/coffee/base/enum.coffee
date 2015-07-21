



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
            typedEnums = @get(type)
            res = find(typedEnums, (e) -> e.id == id)
            label = if angular.isObject(res) then res.label else "无"

        @getEnumsByIds = (ids, type)->
            self = @
            typeEnums = @get(type)
            reduceEnums = (res, id, $index) ->
                res.push _.find typeEnums, {id: id}
                return res
            ids.reduce(reduceEnums, [])


app.service '$enum', EnumService