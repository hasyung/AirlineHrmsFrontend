(function() {
  var CustomConfig, hasExtraForm, resources, workflows;

  resources = angular.module('resources');

  workflows = ["Flow::AccreditLeave", "Flow::AnnualLeave", "Flow::FuneralLeave", "Flow::HomeLeave", "Flow::MarriageLeave", "Flow::MaternityLeave", "Flow::MaternityLeaveBreastFeeding", "Flow::MaternityLeaveDystocia", "Flow::MaternityLeaveLateBirth", "Flow::MaternityLeaveMultipleBirth", "Flow::MiscarriageLeave", "Flow::PersonalLeave", "Flow::PrenatalCheckLeave", "Flow::RearNurseLeave", "Flow::SickLeave", "Flow::SickLeaveInjury", "Flow::SickLeaveNulliparous", "Flow::OccupationInjury", "Flow::WomenLeave", "Flow::Retirement", "Flow::EarlyRetirement", "Flow::Resignation", "Flow::Punishment", "Flow::Dismiss", "Flow::RenewContract", "Flow::AdjustPosition", "Flow::EmployeeLeaveJob", "Flow::Resignation", "Flow::PublicLeave"];

  CustomConfig = {
    'Flow::AdjustPosition': {
      'out_chief_review': '<div class="form-group">\n    <label for="">入职日期</label>\n    <input type="text" name="probation" ng-model="req.probation" >\n</div>\n<div class="form-group">\n    <label for=""></label>\n    <input type="text" name="duty_date" container="body" ng-model="req.duty_date" bs-datepicker>\n</div>'
    }
  };

  angular.forEach(workflows, function(item) {
    var resource;
    resource = function(restmod, RMUtils, $Evt) {
      return restmod.model("/workflows/" + item).mix('nbRestApi', 'Workflow', {
        receptor: {
          belongsTo: 'Employee',
          key: 'receptor_id'
        },
        sponsor: {
          belongsTo: 'Employee',
          key: 'sponsor_id'
        },
        flowNodes: {
          hasMany: "FlowReply"
        },
        $config: {
          jsonRootMany: 'workflows',
          jsonRootSingle: 'workflow'
        },
        $extend: {
          Scope: {
            records: function() {
              return restmod.model("/workflows/" + item + "/record").mix({
                receptor: {
                  belongsTo: 'Employee',
                  key: 'receptor_id'
                },
                sponsor: {
                  belongsTo: 'Employee',
                  key: 'sponsor_id'
                },
                $config: {
                  jsonRootMany: 'workflows',
                  jsonRootSingle: 'workflow'
                },
                $extend: {
                  Record: {
                    revert: function() {
                      var onSuccess, request, self;
                      self = this;
                      request = {
                        url: "/api/workflows/" + this.type + "/" + this.id + "/repeal",
                        method: "PUT"
                      };
                      onSuccess = function(res) {
                        return self.$dispatch('after-revert');
                      };
                      return this.$send(request, onSuccess);
                    }
                  }
                }
              }).$collection().$fetch();
            },
            myRequests: function() {
              return restmod.model("/me/workflows/" + item).mix({
                $config: {
                  jsonRootMany: 'workflows',
                  jsonRootSingle: 'workflow'
                },
                $extend: {
                  Record: {
                    revert: function() {
                      var onSuccess, request, self;
                      self = this;
                      request = {
                        url: "/api/workflows/" + this.type + "/" + this.id + "/repeal",
                        method: "PUT"
                      };
                      onSuccess = function(res) {
                        return self.$dispatch('after-revert');
                      };
                      return this.$send(request, onSuccess);
                    }
                  }
                }
              }).$collection().$fetch();
            }
          }
        }
      });
    };
    return resources.factory(item, ['restmod', 'RMUtils', resource]);
  });

  resources.factory('FlowReply', function(restmod) {
    return restmod.model().mix('nbRestApi', {
      $config: {
        jsonRootSingle: 'flow_node'
      }
    });
  });

  resources.factory('Leave', function(restmod, $injector) {
    return restmod.model("/workflows/leave").mix('nbRestApi', 'Workflow', {
      receptor: {
        belongsTo: 'Employee',
        key: 'receptor_id'
      },
      sponsor: {
        belongsTo: 'Employee',
        key: 'sponsor_id'
      },
      $config: {
        jsonRootMany: 'workflows',
        jsonRootSingle: 'workflow'
      },
      $extend: {
        Scope: {
          records: function() {
            return restmod.model("/workflows/leave/record").mix({
              receptor: {
                belongsTo: 'Employee',
                key: 'receptor_id'
              },
              sponsor: {
                belongsTo: 'Employee',
                key: 'sponsor_id'
              },
              $config: {
                jsonRootMany: 'workflows',
                jsonRootSingle: 'workflow'
              }
            }).$collection().$fetch();
          }
        }
      }
    });
  });

  resources.factory('Todo', function(restmod, $injector) {
    return restmod.model("/me/todos").mix('nbRestApi', {
      flowNodes: {
        hasMany: "FlowReply"
      },
      $config: {
        jsonRootMany: 'workflows',
        jsonRootSingle: 'workflow'
      }
    });
  });

  hasExtraForm = function(workflow) {
    var has;
    if (!workflow) {
      return;
    }
    has = _.has;
    if (workflow.type && workflow.workflow_state) {
      return has(CustomConfig, workflow.type) && has(CustomConfig[workflow.type], workflow.workflow_state);
    }
  };

  resources.factory('Workflow', [
    'restmod', function(restmod) {
      return restmod.mixin(function() {
        return this.on('after-feed', function(_raw) {
          if (hasExtraForm(_raw)) {
            return this.$extraForm = CustomConfig[_raw.type][_raw.workflow_state];
          }
        });
      });
    }
  ]);

}).call(this);
