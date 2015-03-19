resources = angular.module('resources')

#流程资源集合，用于批量生成流程资源
workflows = ['Leave']

angular.forEach workflows, (item)->
    resource = (restmod, RMUtils, $Evt) ->
        resource = restmod.model("/workflows/#{item.toLowerCase()}").mix 'nbRestApi', 'DirtyModel', {
            $config:
                jsonRoot: 'workflows'

        }
    resources.factory item, ['restmod', 'RMUtils', '$nbEvent', resource]


# Leave = (restmod, RMUtils, $Evt) ->
#     Leave = restmod.model('/workflows/leave').mix 'nbRestApi', 'DirtyModel', {
        
#         $config:
#             jsonRoot: 'workflows'

#     }



# resources.factory 'Leave',['restmod', 'RMUtils', '$nbEvent', Leave]
