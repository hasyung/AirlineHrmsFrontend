resources = angular.module('resources')

#流程资源集合，用于批量生成流程资源
workflows = ['Flow::EarlyRetirement','Flow::AdjustPosition', 'Flow::AnnualLeave']

CustomConfig = {
    'Flow::AdjustPosition': {
        'out_chief_review': '''
                <div class="form-group">
                    <label for="">入职日期</label>
                    <input type="text" name="probation" ng-model="req.probation" >
                </div>
                <div class="form-group">
                    <label for=""></label>
                    <input type="text" name="duty_date" container="body" ng-model="req.duty_date" bs-datepicker>
                </div>
            '''
    }
}



angular.forEach workflows, (item)->


    # resources = (restmod, RMUtils, $Evt) ->
    #     resource.call(this, restmod, RMUtils, item)


    resource = (restmod, RMUtils, $Evt) ->
        resource = restmod.model("/workflows/#{item}").mix 'nbRestApi','Workflow', {
            $config:
                jsonRootMany: 'workflows'
                jsonRootSingle: 'workflow'

        }
    resources.factory item, ['restmod', 'RMUtils', resource]



hasExtraForm = (workflow) ->
    return unless workflow
    has = _.has
    if workflow.type && workflow.workflow_state
        return has(CustomConfig, workflow.type) && has(CustomConfig[workflow.type], workflow.workflow_state)


resources.factory 'Workflow', ['restmod', (restmod) ->

    restmod.mixin ->
        this.on 'after-feed', (_raw) ->
            if hasExtraForm(_raw)
                this.$extraForm = CustomConfig[_raw.type][_raw.workflow_state]


]