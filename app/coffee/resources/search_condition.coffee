resources = angular.module('resources')


SerializedFilter = (restmod, RMUtils, $Evt) ->
    ISO_DATE_REGEXP = /\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d\.\d+([+-][0-2]\d:[0-5]\d|Z)/

    SerializedFilter = restmod.model('/search_conditions').mix {
        $extend:
            Record:
                parse: () ->
                    filter = this.condition

                    reviver = (k , v) ->
                        return v if k == ''
                        return new Date(v) if typeof v == 'string' && ISO_DATE_REGEXP.test(v)
                        return v

                    return JSON.parse(filter, reviver)
    }


resources.factory 'SerializedFilter', ['restmod', 'RMUtils', '$nbEvent', SerializedFilter]