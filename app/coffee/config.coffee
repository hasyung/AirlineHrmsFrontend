


nb = @.nb

App = nb.app


Api = {

    urlPrefix: 'api'

}



class ConfigService extends nb.Service

    @.$inject = ['$log','restmodProvider','']

    constructor: (@log, @provider) ->
        @initialize()


    initialize: () ->






# nb.factory '$config'