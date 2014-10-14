angular.module 'vx.templates',[]
    .run ['$templateCache', ($templateCache) ->

        $templateCache.put 'validateMessages.html',require('../common/validate.jade')()







    ]