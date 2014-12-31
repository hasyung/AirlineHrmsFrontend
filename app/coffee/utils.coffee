




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






nb = @.nb

nb.mixOf = mixOf
nb.resetForm = resetForm