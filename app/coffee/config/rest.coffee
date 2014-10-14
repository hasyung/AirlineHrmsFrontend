# module.exports = ['RestangularProvider',(RestangularProvider) ->

#     RestangularProvider.setBaseUrl('/web_api/v1')
#     RestangularProvider.setRequestSuffix('.json')

# ]

restmodConf = (restmodProvider) ->


    restmodProvider.rebase
        PACKER: 'default'
        URL_PREFIX: '/web_api/v1'
        # '~before-request': (_req) ->
        #     #给所有请求加上.json 后缀
        #     _req += '.json'


module.exports = ['restmodProvider',restmodConf]