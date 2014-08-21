module.exports = ['RestangularProvider',(RestangularProvider) ->

    RestangularProvider.setBaseUrl('/web_api/v1')
    RestangularProvider.setRequestSuffix('.json')

]
