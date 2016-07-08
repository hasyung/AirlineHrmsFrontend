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
    "Flow::RecuperateLeave"
    "Flow::PrenatalCheckLeave"
    "Flow::RearNurseLeave"
    "Flow::SickLeave"
    "Flow::SickLeaveInjury"
    "Flow::SickLeaveNulliparous"
    "Flow::OccupationInjury"
    "Flow::WomenLeave"
    "Flow::Retirement"
    "Flow::EarlyRetirement"
    "Flow::Resignation"
    "Flow::Punishment"
    "Flow::Dismiss"
    "Flow::RenewContract"
    "Flow::AdjustPosition"
    "Flow::EmployeeLeaveJob"
    "Flow::Resignation"
    "Flow::PublicLeave"
    "Flow::LactationLeave"
    "Flow::OffsetLeave"
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
        restmod.model("/workflows/#{item}").mix 'nbRestApi', 'Workflow', {
            receptor: {belongsTo: 'Employee', key: 'receptor_id'}
            sponsor: {belongsTo: 'Employee', key: 'sponsor_id'}
            flowNodes: {hasMany: "FlowReply"}

            $config:
                jsonRootMany: 'workflows'
                jsonRootSingle: 'workflow'

            $extend:
                Scope:
                    records: ->
                        restmod.model("/workflows/#{item}/record").mix(
                            receptor: {belongsTo: 'Employee', key: 'receptor_id'}
                            sponsor: {belongsTo: 'Employee', key: 'sponsor_id'}

                            $config:
                                jsonRootMany: 'workflows'
                                jsonRootSingle: 'workflow'

                            $extend:
                                Record:
                                    revert: ()->
                                        self = this

                                        request = {
                                            url: "/api/workflows/#{this.type}/#{this.id}/repeal"
                                            method: "PUT"
                                        }

                                        onSuccess = (res) ->
                                            self.$dispatch 'after-revert'

                                        this.$send(request, onSuccess)
                        ).$collection().$fetch()

                    myRequests: ->
                        restmod.model("/me/workflows/#{item}").mix(
                            $config:
                                jsonRootMany:'workflows'
                                jsonRootSingle: 'workflow'

                            $extend:
                                Record:
                                    revert: ()->
                                        self = this

                                        request = {
                                            url: "/api/workflows/#{this.type}/#{this.id}/repeal"
                                            method: "PUT"
                                        }

                                        onSuccess = (res) ->
                                            self.$dispatch 'after-revert'

                                        this.$send(request, onSuccess)
                            ).$collection().$fetch()
        }

    resources.factory item, ['restmod', 'RMUtils', resource]


resources.factory 'FlowReply', (restmod) ->
    restmod.model().mix 'nbRestApi', {
        $config:
            jsonRootSingle: 'flow_node'
    }


resources.factory 'Leave', (restmod, $injector) ->
    restmod.model("/workflows/leave").mix 'nbRestApi', 'Workflow', {
        receptor: {belongsTo: 'Employee', key: 'receptor_id'}
        sponsor: {belongsTo: 'Employee', key: 'sponsor_id'}

        $config:
            jsonRootMany: 'workflows'
            jsonRootSingle: 'workflow'

        $extend:
            Scope:
                records: ->
                    restmod.model("/workflows/leave/record").mix(
                        receptor: {belongsTo: 'Employee', key: 'receptor_id'}
                        sponsor: {belongsTo: 'Employee', key: 'sponsor_id'}

                        $config:
                            jsonRootMany:'workflows'
                            jsonRootSingle: 'workflow'
                    ).$collection().$fetch()
    }


resources.factory 'Todo', (restmod, $injector) ->
    restmod.model("/me/todos").mix 'nbRestApi', {
        flowNodes: {hasMany: "FlowReply"}

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

# 客舱服务部管理的 resource
VacationDistribute = (restmod, RMUtils, $Evt) ->
    restmod.model('/workflows/vacation/distribute/vacation_distribute_list').mix 'nbRestApi', 'DirtyModel', {
        $config:
            jsonRootSingle: 'workflow'
            jsonRootMany: 'workflows'

        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $hooks: {
            'after-destroy': ->
                $Evt.$send('workflows:destroy:success',"删除成功")
            'after-save': ->
                $Evt.$send('workflows:save:success',"保存成功")
        }

        $extend:
            Collection:
                search: (tableState) ->
                    this.$refresh(tableState)
    }

# 审批人常用意见的 resource
FavNote = (restmod, RMUtils, $Evt) ->
    restmod.model('/fav_notes').mix 'nbRestApi', 'DirtyModel', {
        $config:
            jsonRootSingle: 'fav_note'
            jsonRootMany: 'fav_notes'

        owner: {belongsTo: 'Employee', key: 'employee_id'}

        $extend:
            Record:
                createHabit: () ->

                destroyHabit: () ->


            
    }

resources.factory 'VacationDistribute', ['restmod', 'RMUtils', '$nbEvent', VacationDistribute]
resources.factory 'FavNote', ['restmod', 'RMUtils', '$nbEvent', FavNote]






