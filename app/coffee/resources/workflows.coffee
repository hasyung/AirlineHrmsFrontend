resources = angular.module('resources')

#流程资源集合，用于批量生成流程资源

workflows = [
    "Flow::AccreditLeave"
    "Flow::AnnualLeave"
    "Flow::FuneralLeave"
    "Flow::HomeLeave"
    "Flow::MarriageLeave"
    "Flow::MaternityLeave"
    "Flow::MaternityLeaveBreastFeeding"
    "Flow::MaternityLeaveDystocia"
    "Flow::MaternityLeaveLateBirth"
    "Flow::MaternityLeaveMultipleBirth"
    "Flow::MiscarriageLeave"
    "Flow::PersonalLeave"
    "Flow::PrenatalCheckLeave"
    "Flow::RearNurseLeave"
    "Flow::SickLeave"
    "Flow::SickLeaveInjury"
    "Flow::SickLeaveNulliparous"
    "Flow::WomenLeave"
    "Flow::Retirement"
    "Flow::EarlyRetirement"
    "Flow::Resignation"
    "Flow::Punishment"
    "Flow::Dismiss"
    "Flow::RenewContract"
    "Flow::AdjustPosition"
]

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


    resource = (restmod, RMUtils, $Evt) ->
        resource = restmod.model("/workflows/#{item}").mix 'nbRestApi','Workflow', {

            flowNodes: {hasMany: "FlowReply"}


            $config:
                jsonRootMany: 'workflows'
                jsonRootSingle: 'workflow'

        }
    resources.factory item, ['restmod', 'RMUtils', resource]



resources.factory 'FlowReply', (restmod) ->
    restmod.model().mix 'nbRestApi', {
        $config:
            jsonRootSingle: 'flow_node'

    }




resources.factory 'Leave', (restmod, $injector) ->

    restmod.model("/workflows/leave").mix 'nbRestApi', 'Workflow', {
        $config:
            jsonRootMany: 'workflows'
            jsonRootSingle: 'workflow'

    }









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