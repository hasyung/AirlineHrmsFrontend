(function() {
  var Allowance, BasicSalary, HoursFee, KeepSalary, LandAllowance, PerformanceSalary, Reward, SalaryChange, SalaryGradeChange, SalaryOverview, TransportFee, resources;

  resources = angular.module('resources');

  BasicSalary = function(restmod, RMUtils, $Evt) {
    return restmod.model('/basic_salaries').mix('nbRestApi', 'DirtyModel', {
      owner: {
        belongsTo: 'Employee',
        key: 'employee_id'
      },
      $hooks: {
        'after-create': function() {
          return $Evt.$send('basic_salary:create:success', "基础工资创建成功");
        },
        'after-update': function() {
          return $Evt.$send('basic_salary:update:success', "基础工资更新成功");
        }
      },
      $config: {
        jsonRootSingle: 'basic_salary',
        jsonRootMany: 'basic_salaries'
      },
      $extend: {
        Collection: {
          search: function(tableState) {
            return this.$refresh(tableState);
          }
        },
        Scope: {
          compute: function(params) {
            return restmod.model('/basic_salaries/compute').mix({
              $config: {
                jsonRoot: 'basic_salaries'
              }
            }).$search(params);
          }
        }
      }
    });
  };

  KeepSalary = function(restmod, RMUtils, $Evt) {
    return restmod.model('/keep_salaries').mix('nbRestApi', 'DirtyModel', {
      owner: {
        belongsTo: 'Employee',
        key: 'employee_id'
      },
      $hooks: {
        'after-create': function() {
          return $Evt.$send('basic_salary:create:success', "保留工资创建成功");
        },
        'after-update': function() {
          return $Evt.$send('basic_salary:update:success', "保留工资更新成功");
        }
      },
      $config: {
        jsonRootSingle: 'keep_salary',
        jsonRootMany: 'keep_salaries'
      },
      $extend: {
        Collection: {
          search: function(tableState) {
            return this.$refresh(tableState);
          }
        },
        Scope: {
          compute: function(params) {
            return restmod.model('/keep_salaries/compute').mix({
              $config: {
                jsonRoot: 'keep_salaries'
              }
            }).$search(params);
          }
        }
      }
    });
  };

  PerformanceSalary = function(restmod, RMUtils, $Evt) {
    return restmod.model('/performance_salaries').mix('nbRestApi', 'DirtyModel', {
      owner: {
        belongsTo: 'Employee',
        key: 'employee_id'
      },
      $hooks: {
        'after-create': function() {
          return $Evt.$send('performance_salary:create:success', "绩效工资创建成功");
        },
        'after-update': function() {
          return $Evt.$send('performance_salary:update:success', "绩效工资更新成功");
        }
      },
      $config: {
        jsonRootSingle: 'performance_salary',
        jsonRootMany: 'performance_salaries'
      },
      $extend: {
        Collection: {
          search: function(tableState) {
            return this.$refresh(tableState);
          }
        },
        Scope: {
          compute: function(params) {
            return restmod.model('/performance_salaries/compute').mix({
              $config: {
                jsonRoot: 'performance_salaries'
              }
            }).$search(params);
          }
        }
      }
    });
  };

  HoursFee = function(restmod, RMUtils, $Evt) {
    return restmod.model('/hours_fees').mix('nbRestApi', 'DirtyModel', {
      owner: {
        belongsTo: 'Employee',
        key: 'employee_id'
      },
      $hooks: {
        'after-create': function() {
          return $Evt.$send('hours_fee:create:success', "小时费创建成功");
        },
        'after-update': function() {
          return $Evt.$send('hours_fee:update:success', "小时费更新成功");
        }
      },
      $config: {
        jsonRootSingle: 'hours_fee',
        jsonRootMany: 'hours_fees'
      },
      $extend: {
        Collection: {
          search: function(tableState) {
            return this.$refresh(tableState);
          }
        },
        Scope: {
          compute: function(params) {
            return restmod.model('/hours_fees/compute').mix({
              $config: {
                jsonRoot: 'hours_fees'
              }
            }).$search(params);
          }
        }
      }
    });
  };

  Allowance = function(restmod, RMUtils, $Evt) {
    return restmod.model('/allowances').mix('nbRestApi', 'DirtyModel', {
      owner: {
        belongsTo: 'Employee',
        key: 'employee_id'
      },
      $hooks: {
        'after-create': function() {
          return $Evt.$send('allowance:create:success', "津贴创建成功");
        },
        'after-update': function() {
          return $Evt.$send('allowance:update:success', "津贴更新成功");
        }
      },
      $config: {
        jsonRootSingle: 'allowance',
        jsonRootMany: 'allowances'
      },
      $extend: {
        Collection: {
          search: function(tableState) {
            return this.$refresh(tableState);
          }
        },
        Scope: {
          compute: function(params) {
            return restmod.model('/allowances/compute').mix({
              $config: {
                jsonRoot: 'allowances'
              }
            }).$search(params);
          }
        }
      }
    });
  };

  LandAllowance = function(restmod, RMUtils, $Evt) {
    return restmod.model('/land_allowances').mix('nbRestApi', 'DirtyModel', {
      owner: {
        belongsTo: 'Employee',
        key: 'employee_id'
      },
      $hooks: {
        'after-create': function() {
          return $Evt.$send('land_allowance:create:success', "驻站津贴创建成功");
        },
        'after-update': function() {
          return $Evt.$send('land_allowance:update:success', "驻站津贴更新成功");
        }
      },
      $config: {
        jsonRootSingle: 'land_allowance',
        jsonRootMany: 'land_allowances'
      },
      $extend: {
        Collection: {
          search: function(tableState) {
            return this.$refresh(tableState);
          }
        },
        Scope: {
          compute: function(params) {
            return restmod.model('/land_allowances/compute').mix({
              $config: {
                jsonRoot: 'land_allowances'
              }
            }).$search(params);
          }
        }
      }
    });
  };

  Reward = function(restmod, RMUtils, $Evt) {
    return restmod.model('/rewards').mix('nbRestApi', 'DirtyModel', {
      owner: {
        belongsTo: 'Employee',
        key: 'employee_id'
      },
      $hooks: {
        'after-create': function() {
          return $Evt.$send('reward:create:success', "奖励创建成功");
        },
        'after-update': function() {
          return $Evt.$send('reward:update:success', "奖励更新成功");
        }
      },
      $config: {
        jsonRootSingle: 'reward',
        jsonRootMany: 'rewards'
      },
      $extend: {
        Collection: {
          search: function(tableState) {
            return this.$refresh(tableState);
          }
        },
        Scope: {
          compute: function(params) {
            return restmod.model('/rewards/compute').mix({
              $config: {
                jsonRoot: 'land_allowances'
              }
            }).$search(params);
          }
        }
      }
    });
  };

  TransportFee = function(restmod, RMUtils, $Evt) {
    return restmod.model('/transport_fees').mix('nbRestApi', 'DirtyModel', {
      owner: {
        belongsTo: 'Employee',
        key: 'employee_id'
      },
      $hooks: {
        'after-create': function() {
          return $Evt.$send('transport_fee:create:success', "交通费创建成功");
        },
        'after-update': function() {
          return $Evt.$send('transport_fee:update:success', "交通费更新成功");
        }
      },
      $config: {
        jsonRootSingle: 'transport_fee',
        jsonRootMany: 'transport_fees'
      },
      $extend: {
        Collection: {
          search: function(tableState) {
            return this.$refresh(tableState);
          }
        },
        Scope: {
          compute: function(params) {
            return restmod.model('/transport_fees/compute').mix({
              $config: {
                jsonRoot: 'transport_fees'
              }
            }).$search(params);
          }
        }
      }
    });
  };

  SalaryChange = function(restmod, RMUtils, $Evt) {
    return restmod.model('/salary_changes').mix('nbRestApi', 'DirtyModel', {
      owner: {
        belongsTo: 'Employee',
        key: 'employee_id'
      },
      $hooks: {
        'after-create': function() {
          return $Evt.$send('salary_change:create:success', "薪酬变更创建成功");
        },
        'after-update': function() {
          return $Evt.$send('salary_change:update:success', "薪酬变更更新成功");
        }
      },
      $config: {
        jsonRootSingle: 'salary_change',
        jsonRootMany: 'salary_changes'
      }
    });
  };

  SalaryGradeChange = function(restmod, RMUtils, $Evt) {
    return restmod.model('/salary_grade_changes').mix('nbRestApi', 'DirtyModel', {
      owner: {
        belongsTo: 'Employee',
        key: 'employee_id'
      },
      $hooks: {
        'after-create': function() {
          return $Evt.$send('salary_grade_change:create:success', "薪酬档级变更创建成功");
        },
        'after-update': function() {
          return $Evt.$send('salary_grade_change:update:success', "薪酬档级变更更新成功");
        }
      },
      $config: {
        jsonRootSingle: 'salary_grade_change',
        jsonRootMany: 'salary_grade_changes'
      },
      $extend: {
        Record: {
          audit: function(params) {
            var request, self;
            self = this;
            request = {
              url: "/api/salary_grade_changes/" + this.id + "/audit",
              method: "PUT",
              params: params
            };
            return this.$send(request, onSuccess);
          }
        }
      }
    });
  };

  SalaryOverview = function(restmod, RMUtils, $Evt) {
    return restmod.model('/salary_overviews').mix('nbRestApi', 'DirtyModel', {
      owner: {
        belongsTo: 'Employee',
        key: 'employee_id'
      },
      $hooks: {
        'after-create': function() {
          return $Evt.$send('salary_counter:create:success', "薪酬合计创建成功");
        },
        'after-update': function() {
          return $Evt.$send('salary_counter:update:success', "薪酬合计更新成功");
        }
      },
      $config: {
        jsonRootSingle: 'salary_overview',
        jsonRootMany: 'salary_overviews'
      },
      $extend: {
        Collection: {
          search: function(tableState) {
            return this.$refresh(tableState);
          }
        },
        Scope: {
          compute: function(params) {
            return restmod.model('/salary_overviews/compute').mix({
              $config: {
                jsonRoot: 'salary_overviews'
              }
            }).$search(params);
          }
        }
      }
    });
  };

  resources.factory('BasicSalary', ['restmod', 'RMUtils', '$nbEvent', BasicSalary]);

  resources.factory('KeepSalary', ['restmod', 'RMUtils', '$nbEvent', KeepSalary]);

  resources.factory('PerformanceSalary', ['restmod', 'RMUtils', '$nbEvent', PerformanceSalary]);

  resources.factory('HoursFee', ['restmod', 'RMUtils', '$nbEvent', HoursFee]);

  resources.factory('Allowance', ['restmod', 'RMUtils', '$nbEvent', Allowance]);

  resources.factory('LandAllowance', ['restmod', 'RMUtils', '$nbEvent', LandAllowance]);

  resources.factory('Reward', ['restmod', 'RMUtils', '$nbEvent', Reward]);

  resources.factory('TransportFee', ['restmod', 'RMUtils', '$nbEvent', TransportFee]);

  resources.factory('SalaryChange', ['restmod', 'RMUtils', '$nbEvent', SalaryChange]);

  resources.factory('SalaryGradeChange', ['restmod', 'RMUtils', '$nbEvent', SalaryGradeChange]);

  resources.factory('SalaryOverview', ['restmod', 'RMUtils', '$nbEvent', SalaryOverview]);

}).call(this);
