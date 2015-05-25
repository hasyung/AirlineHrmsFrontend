




mixOf = (base, mixins...) ->
    class Mixed extends base

    for mixin in mixins by -1 #earlier mixins override later ones
        for name, method of mixin::
            Mixed::[name] = method
    Mixed


resetForm = (forms...) ->
    for form in forms
        form.$setPristine()
        form.$setUntouched()
    return

filterBuildUtils = (filterName)->
    filtersObj = {}
    filtersObj.name = filterName
    filtersObj.constraintDefs = []

    this.col = (name, displayName, type, placeholder, params)->
        temp = {
            name: name
            type: type
            displayName: displayName
            placeholder: placeholder
            params: params
        }
        filtersObj.constraintDefs.push temp
        return this

    this.end = ()-> filtersObj

    return this








nb = @.nb

nb.mixOf = mixOf
nb.resetForm = resetForm
nb.filterBuildUtils = filterBuildUtils