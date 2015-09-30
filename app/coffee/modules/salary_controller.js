(function() {
  var CALC_STEP_COLUMN, CalcStepsController, RewardsAllocationController, Route, SALARY_COLUMNDEF_DEFAULT, SALARY_FILTER_DEFAULT, SalaryAllowanceController, SalaryBaseController, SalaryBasicController, SalaryChangeController, SalaryController, SalaryExchangeController, SalaryGradeChangeController, SalaryHoursFeeController, SalaryKeepController, SalaryLandAllowanceController, SalaryOverviewController, SalaryPerformanceController, SalaryPersonalController, SalaryRewardController, SalaryTransportFeeController, app, nb,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  nb = this.nb;

  app = nb.app;

  SALARY_FILTER_DEFAULT = {
    name: 'salary',
    constraintDefs: [
      {
        name: 'employee_name',
        displayName: '员工姓名',
        type: 'string'
      }, {
        name: 'employee_no',
        displayName: '员工编号',
        type: 'string'
      }
    ]
  };

  SALARY_COLUMNDEF_DEFAULT = [
    {
      displayName: '员工编号',
      name: 'employeeNo',
      enableCellEdit: false
    }, {
      displayName: '姓名',
      field: 'employeeName',
      enableCellEdit: false,
      cellTemplate: '<div class="ui-grid-cell-contents">\n    <a nb-panel\n        template-url="partials/personnel/info_basic.html"\n        locals="{employee: row.entity.owner}">\n        {{grid.getCellValue(row, col)}}\n    </a>\n</div>'
    }, {
      displayName: '所属部门',
      name: 'departmentName',
      enableCellEdit: false,
      cellTooltip: function(row) {
        return row.entity.departmentName;
      }
    }, {
      displayName: '岗位',
      name: 'positionName',
      enableCellEdit: false,
      cellTooltip: function(row) {
        return row.entity.positionName;
      }
    }, {
      displayName: '通道',
      name: 'channelId',
      enableCellEdit: false,
      cellFilter: "enum:'channels'"
    }
  ];

  CALC_STEP_COLUMN = [
    {
      displayName: '计算过程',
      field: 'step',
      enableCellEdit: false,
      cellTemplate: '<div class="ui-grid-cell-contents">\n    <a nb-panel\n        template-url="partials/salary/calc/step.html"\n        locals="{employee_id: row.entity.employee_id, month: row.entity.month, category: row.entity.category}">\n        显示过程\n    </a>\n</div>'
    }
  ];

  Route = (function() {
    Route.$inject = ['$stateProvider'];

    function Route(stateProvider) {
      stateProvider.state('salary', {
        url: '/salary',
        templateUrl: 'partials/salary/settings.html'
      }).state('salary_personal', {
        url: '/salary/personal',
        templateUrl: 'partials/salary/personal.html'
      }).state('salary_calc', {
        url: '/salary/calc',
        templateUrl: 'partials/salary/calc.html'
      });
    }

    return Route;

  })();

  app.config(Route);

  SalaryController = (function(_super) {
    __extends(SalaryController, _super);

    SalaryController.$inject = ['$http', '$scope', '$nbEvent', 'toaster', 'SALARY_SETTING'];

    function SalaryController(http, scope, $Evt, toaster, SALARY_SETTING) {
      var self;
      this.http = http;
      this.scope = scope;
      this.toaster = toaster;
      this.SALARY_SETTING = SALARY_SETTING;
      self = this;
      this.initialize();
    }

    SalaryController.prototype.$defaultCoefficient = function() {
      return {
        company: 0.1,
        business_council: 0.1,
        logistics: 0.1
      };
    };

    SalaryController.prototype.$checkCoefficientDefault = function() {
      var month;
      month = this.currentCalcTime();
      if (!angular.isDefined(this.global_setting.coefficient[month])) {
        return this.global_setting.coefficient[month] = this.$defaultCoefficient();
      }
    };

    SalaryController.prototype.$checkRewardDefault = function() {
      var year;
      year = this.currentYear;
      if (!angular.isDefined(this.global_setting.flight_bonus[year])) {
        this.global_setting.flight_bonus[year] = 100000000;
      }
      if (!angular.isDefined(this.global_setting.service_bonus[year])) {
        this.global_setting.service_bonus[year] = 100000000;
      }
      if (!angular.isDefined(this.global_setting.airline_security_bonus[year])) {
        this.global_setting.airline_security_bonus[year] = 100000000;
      }
      if (!angular.isDefined(this.global_setting.composite_bonus[year])) {
        return this.global_setting.composite_bonus[year] = 100000000;
      }
    };

    SalaryController.prototype.initialize = function() {
      var self;
      self = this;
      this.CATEGORY_LIST = ["leader_base", "manager15_base", "manager12_base", "flyer_legend_base", "flyer_leader_base", "flyer_copilot_base", "flyer_teacher_A_base", "flyer_teacher_B_base", "flyer_teacher_C_base", "flyer_student_base", "air_steward_base", "service_b_normal_cleaner_base", "service_b_parking_cleaner_base", "service_b_hotel_service_base", "service_b_green_base", "service_b_front_desk_base", "service_b_security_guard_base", "service_b_input_base", "service_b_guard_leader1_base", "service_b_device_keeper_base", "service_b_unloading_base", "service_b_making_water_base", "service_b_add_water_base", "service_b_guard_leader2_base", "service_b_water_light_base", "service_b_car_repair_base", "service_b_airline_keeper_base", "service_c_base", "air_observer_base", "front_run_base", "information_perf", "airline_business_perf", "manage_market_perf", "service_c_1_perf", "service_c_2_perf", "service_c_3_perf", "service_c_driving_perf", "flyer_hour", "fly_attendant_hour", "air_security_hour", "unfly_allowance_hour", "allowance", "land_subsidy", "airline_subsidy", "temp"];
      this.year_list = this.$getYears();
      this.month_list = this.$getMonths();
      this.currentYear = _.last(this.year_list);
      this.currentMonth = _.last(this.month_list);
      this.currentCity = "成都";
      this.settings = {};
      return this.global_setting = {};
    };

    SalaryController.prototype.loadConfigFromServer = function(category) {
      var self;
      self = this;
      return this.http.get('/api/salaries').success(function(data) {
        self.global_setting = data.global.form_data;
        self.$checkCoefficientDefault();
        self.basic_cardinality = parseInt(self.global_setting.basic_cardinality);
        self.settings['global_setting'] = self.global_setting;
        angular.forEach(self.CATEGORY_LIST, function(item) {
          data[item] || (data[item] = {});
          return self.settings[item + '_setting'] = data[item].form_data || {};
        });
        self.loadDynamicConfig(category);
        return self.SALARY_SETTING = angular.copy(self.settings);
      });
    };

    SalaryController.prototype.currentCalcTime = function() {
      return this.currentYear + "-" + this.currentMonth;
    };

    SalaryController.prototype.loadGlobalCoefficient = function() {
      return this.$checkCoefficientDefault();
    };

    SalaryController.prototype.loadGlobalReward = function() {
      return this.$checkRewardDefault();
    };

    SalaryController.prototype.loadDynamicConfig = function(category) {
      this.current_category = category;
      this.dynamic_config = this.settings[category + '_setting'];
      this.backup_config = angular.copy(this.dynamic_config);
      return this.editing = false;
    };

    SalaryController.prototype.isComplexSetting = function(flags, grade, column, setting) {
      if (['information_perf', 'airline_business_perf', 'manage_market_perf'].indexOf(this.current_category) >= 0) {
        if (!angular.isDefined(flags[grade])) {
          flags[grade] = {};
        }
        if (!angular.isDefined(flags[grade][column])) {
          flags[grade][column] = {};
        }
        setting = flags[grade];
        setting[column]['edit_mode'] = 'dialog';
        setting[column]['add'] = true;
        setting[column]['format_cell'] = null;
        setting[column]['expr'] = null;
        return true;
      }
      return false;
    };

    SalaryController.prototype.resetDynamicConfig = function() {
      this.dynamic_config = {};
      this.dynamic_config = angular.copy(this.backup_config);
      return this.editing = false;
    };

    SalaryController.prototype.saveConfig = function(category, config) {
      var self;
      self = this;
      if (!config) {
        config = this.settings[this.current_category + '_setting'];
      }
      return this.http.put('/api/salaries/' + (category || this.current_category), {
        form_data: config
      }).success(function(data) {
        var error_msg;
        error_msg = data.messages;
        if (error_msg) {
          return self.toaster.pop('error', '提示', error_msg);
        } else {
          self.editing = false;
          self.backup_config = angular.copy(self.dynamic_config);
          return self.toaster.pop('success', '提示', '配置已更新');
        }
      });
    };

    SalaryController.prototype.calcAmount = function(rate) {
      return parseInt(this.basic_cardinality * parseFloat(rate));
    };

    SalaryController.prototype.calcRate = function(amount) {
      if (!this.basic_cardinality || this.basic_cardinality === 0) {
        throw new Error('全局设置薪酬基数无效');
      }
      return Math.round(amount / this.basic_cardinality);
    };

    SalaryController.prototype.existCurrentRate = function() {
      return this.dynamic_config.flag_list.indexOf('rate') >= 0;
    };

    SalaryController.prototype.formatColumn = function(flags, grade, setting, column) {
      var input, result;
      if (setting[column] && (setting[column]['expr'] || setting[column]['format_cell'])) {
        setting[column]['add'] = false;
        flags[grade][column]['add'] = false;
      }
      result = input = setting[column];
      if (input && angular.isDefined(input['format_cell'])) {
        result = input['format_cell'];
        if (result) {
          result = result.replace('%{format_value}', input['format_value']);
        }
        if (result) {
          result = result.replace('%{work_value}', input['work_value']);
        }
        if (result) {
          result = result.replace('%{time_value}', input['time_value']);
        }
      }
      return result;
    };

    SalaryController.prototype.exchangeExpr = function(expr, reverse) {
      var hash, result;
      if (reverse == null) {
        reverse = false;
      }
      if (!expr && !angular.isDefined(expr)) {
        return;
      }
      hash = {
        '调档时间': '%{format_value}',
        '驾驶经历时间': '%{work_value}',
        '飞行时间': '%{time_value}',
        '员工职级': '%{job_title_degree}',
        '员工学历': '%{education_background}',
        '去年年度绩效': '%{last_year_perf}'
      };
      result = expr;
      angular.forEach(hash, function(value, key) {
        if (reverse) {
          if (result) {
            return result = result.replace(value, key);
          }
        } else {
          if (result) {
            return result = result.replace(key, value);
          }
        }
      });
      return result;
    };

    SalaryController.prototype.loadPositions = function(selectDepIds, keywords) {
      var self;
      self = this;
      if (!selectDepIds) {
        return;
      }
      return this.http.get('/api/salaries/temperature_amount?department_ids=' + selectDepIds).success(function(data) {
        self.tempPositions = data.temperature_amounts;
        if (!!keywords && keywords.length > 0) {
          return self.tempPositions = _.filter(self.tempPositions, function(item) {
            return item.full_position_name.indexOf(keywords) >= 0;
          });
        }
      });
    };

    SalaryController.prototype.listTempPosition = function(amount) {
      var self;
      self = this;
      return this.http.get('/api/salaries/temperature_amount?per_page=3000&temperature_amount=' + amount).success(function(data) {
        return self.currentTempPositions = data.temperature_amounts;
      });
    };

    SalaryController.prototype.updateTempAmount = function(position_id, amount) {
      var params, self;
      self = this;
      params = {
        position_id: position_id,
        temperature_amount: parseInt(amount)
      };
      return this.http.put('/api/salaries/update_temperature_amount', params).success(function(data) {
        return self.toaster.pop('success', '提示', '更新成功');
      }).error(function(data) {
        return self.toaster.pop('success', '提示', '更新成功');
      });
    };

    SalaryController.prototype.destroyCity = function(cities, idx) {
      return cities.splice(idx, 1);
    };

    SalaryController.prototype.addSkyCity = function(cities, city) {
      var self;
      self = this;
      if (city.city && city.abbr) {
        cities.push(city);
        self.scope.cityForeign = {};
        return self.scope.cityNation = {};
      }
    };

    return SalaryController;

  })(nb.Controller);

  SalaryPersonalController = (function(_super) {
    __extends(SalaryPersonalController, _super);

    SalaryPersonalController.$inject = ['$http', '$scope', '$nbEvent', '$enum', 'SalaryPersonSetup'];

    function SalaryPersonalController($http, $scope, $Evt, $enum, SalaryPersonSetup) {
      this.SalaryPersonSetup = SalaryPersonSetup;
      this.loadInitialData();
      this.filterOptions = {
        name: 'salaryPersonal',
        constraintDefs: [
          {
            name: 'employee_name',
            displayName: '员工姓名',
            type: 'string'
          }, {
            name: 'employee_no',
            displayName: '员工编号',
            type: 'string'
          }, {
            name: 'channel_ids',
            displayName: '通道',
            type: 'muti-enum-search',
            params: {
              type: 'channels'
            }
          }, {
            name: 'is_salary_special',
            displayName: '薪酬特殊人员',
            type: 'boolean'
          }
        ]
      };
      this.columnDef = [
        {
          displayName: '员工编号',
          name: 'employeeNo'
        }, {
          displayName: '姓名',
          field: 'employeeName',
          cellTemplate: '<div class="ui-grid-cell-contents">\n    <a nb-panel\n        template-url="partials/personnel/info_basic.html"\n        locals="{employee: row.entity.owner}">\n        {{grid.getCellValue(row, col)}}\n    </a>\n</div>'
        }, {
          displayName: '所属部门',
          name: 'departmentName',
          cellTooltip: function(row) {
            return row.entity.departmentName;
          }
        }, {
          displayName: '岗位',
          name: 'positionName',
          cellTooltip: function(row) {
            return row.entity.positionName;
          }
        }, {
          displayName: '分类',
          name: 'categoryId',
          cellFilter: "enum:'categories'"
        }, {
          displayName: '通道',
          name: 'channelId',
          cellFilter: "enum:'channels'"
        }, {
          displayName: '用工性质',
          name: 'laborRelationId',
          cellFilter: "enum:'labor_relations'"
        }, {
          displayName: '属地化',
          name: 'location'
        }, {
          displayName: '设置',
          field: 'setting',
          cellTemplate: '<div class="ui-grid-cell-contents">\n    <a\n        href="javascript:void(0);"\n        nb-dialog\n        template-url="partials/salary/settings/personal_edit.html"\n        locals="{setup: row.entity}">\n        设置\n    </a>\n</div>'
        }
      ];
      this.constraints = [];
    }

    SalaryPersonalController.prototype.loadInitialData = function() {
      return this.salaryPersonSetups = this.SalaryPersonSetup.$collection().$fetch();
    };

    SalaryPersonalController.prototype.search = function(tableState) {
      tableState = tableState || {};
      tableState['per_page'] = this.gridApi.grid.options.paginationPageSize;
      return this.salaryPersonSetups.$refresh(tableState);
    };

    SalaryPersonalController.prototype.getSelectsIds = function() {
      var rows;
      rows = this.gridApi.selection.getSelectedGridRows();
      return rows.map(function(row) {
        return row.entity.$pk;
      });
    };

    SalaryPersonalController.prototype.getSelected = function() {
      var rows;
      return rows = this.gridApi.selection.getSelectedGridRows();
    };

    SalaryPersonalController.prototype["delete"] = function(isConfirm) {
      if (isConfirm) {
        return this.getSelected().forEach(function(record) {
          return record.entity.$destroy();
        });
      }
    };

    SalaryPersonalController.prototype.loadEmployee = function(params, salary) {
      var self;
      self = this;
      return this.Employee.$collection().$refresh(params).$then(function(employees) {
        var args, matched;
        args = _.mapKeys(params, function(value, key) {
          return _.camelCase(key);
        });
        matched = _.find(employees, args);
        if (matched) {
          self.loadEmp = matched;
          return salary.owner = matched;
        } else {
          return self.loadEmp = params;
        }
      });
    };

    return SalaryPersonalController;

  })(nb.Controller);

  SalaryChangeController = (function(_super) {
    __extends(SalaryChangeController, _super);

    SalaryChangeController.$inject = ['$http', '$scope', '$nbEvent', '$enum', 'SalaryChange', 'SalaryPersonSetup'];

    function SalaryChangeController(http, $scope, $Evt, $enum, SalaryChange, SalaryPersonSetup) {
      this.http = http;
      this.SalaryChange = SalaryChange;
      this.SalaryPersonSetup = SalaryPersonSetup;
      this.loadInitialData();
      this.filterOptions = {
        name: 'salaryChange',
        constraintDefs: [
          {
            name: 'employee_name',
            displayName: '员工姓名',
            type: 'string'
          }, {
            name: 'employee_no',
            displayName: '员工编号',
            type: 'string'
          }, {
            name: 'category',
            displayName: '信息种类',
            type: 'salary_change_category_select'
          }
        ]
      };
      this.columnDef = [
        {
          displayName: '员工编号',
          name: 'employeeNo'
        }, {
          displayName: '姓名',
          field: 'employeeName',
          cellTemplate: '<div class="ui-grid-cell-contents">\n    <a nb-panel\n        template-url="partials/personnel/info_basic.html"\n        locals="{employee: row.entity.owner}">\n        {{grid.getCellValue(row, col)}}\n    </a>\n</div>'
        }, {
          displayName: '所属部门',
          name: 'departmentName',
          cellTooltip: function(row) {
            return row.entity.departmentName;
          }
        }, {
          displayName: '信息发生时间',
          name: 'changeDate'
        }, {
          displayName: '信息种类',
          name: 'category'
        }, {
          displayName: '查看',
          field: 'setting',
          cellTemplate: '<div class="ui-grid-cell-contents" ng-init="outerScope=grid.appScope.$parent">\n    <a\n        href="javascript:void(0);"\n        nb-dialog\n        template-url="partials/salary/settings/changes/personal.html"\n        locals="{change: row.entity, outerScope: outerScope}">\n        查看\n    </a>\n</div>'
        }
      ];
    }

    SalaryChangeController.prototype.loadInitialData = function() {
      return this.salaryChanges = this.SalaryChange.$collection().$fetch();
    };

    SalaryChangeController.prototype.loadPersonSettings = function(change) {
      var self;
      self = this;
      return this.SalaryPersonSetup.$collection().$fetch().$find(change.salaryPersonSetupId);
    };

    SalaryChangeController.prototype.search = function(tableState) {
      tableState = tableState || {};
      tableState['per_page'] = this.gridApi.grid.options.paginationPageSize;
      return this.salaryChanges.$refresh(tableState);
    };

    return SalaryChangeController;

  })(nb.Controller);

  SalaryGradeChangeController = (function(_super) {
    __extends(SalaryGradeChangeController, _super);

    SalaryGradeChangeController.$inject = ['$http', '$scope', '$nbEvent', '$enum', 'SalaryGradeChange', 'SALARY_SETTING'];

    function SalaryGradeChangeController(http, $scope, $Evt, $enum, SalaryGradeChange, SALARY_SETTING) {
      this.http = http;
      this.SalaryGradeChange = SalaryGradeChange;
      this.SALARY_SETTING = SALARY_SETTING;
      this.loadInitialData();
      this.filterOptions = {
        name: 'salaryPersonal',
        constraintDefs: [
          {
            name: 'employee_name',
            displayName: '员工姓名',
            type: 'string'
          }, {
            name: 'employee_no',
            displayName: '员工编号',
            type: 'string'
          }, {
            name: 'channel_ids',
            displayName: '通道',
            type: 'muti-enum-search',
            params: {
              type: 'channels'
            }
          }, {
            name: 'department_ids',
            displayName: '机构',
            type: 'org-search'
          }
        ]
      };
      this.columnDef = [
        {
          displayName: '员工编号',
          name: 'employeeNo'
        }, {
          displayName: '姓名',
          field: 'employeeName',
          cellTemplate: '<div class="ui-grid-cell-contents">\n    <a nb-panel\n        template-url="partials/personnel/info_basic.html"\n        locals="{employee: row.entity.owner}">\n        {{grid.getCellValue(row, col)}}\n    </a>\n</div>'
        }, {
          displayName: '所属部门',
          name: 'departmentName',
          cellTooltip: function(row) {
            return row.entity.departmentName;
          }
        }, {
          displayName: '用工性质',
          name: 'laborRelationId',
          cellFilter: "enum:'labor_relations'"
        }, {
          displayName: '通道',
          name: 'channelId',
          cellFilter: "enum:'channels'"
        }, {
          displayName: '薪酬模块',
          name: 'changeModule'
        }, {
          displayName: '信息发生时间',
          name: 'recordDate'
        }, {
          displayName: '查看',
          field: 'setting',
          cellTemplate: '<div class="ui-grid-cell-contents">\n    <a\n        href="javascript:void(0);"\n        nb-dialog\n        template-url="partials/salary/settings/changes/grade.html"\n        locals="{change: row.entity}">\n        查看\n    </a>\n</div>'
        }
      ];
    }

    SalaryGradeChangeController.prototype.loadInitialData = function() {
      return this.salaryGradeChanges = this.SalaryGradeChange.$collection().$fetch();
    };

    SalaryGradeChangeController.prototype.search = function(tableState) {
      tableState = tableState || {};
      tableState['per_page'] = this.gridApi.grid.options.paginationPageSize;
      return this.salaryGradeChanges.$refresh(tableState);
    };

    SalaryGradeChangeController.prototype.loadSalarySetting = function(employee_id) {
      var self;
      self = this;
      return this.http.get('/api/salary_person_setups/lookup?employee_id=' + employee_id).success(function(data) {
        self.setting = data.salary_person_setup;
        return self.flags = [];
      });
    };

    return SalaryGradeChangeController;

  })(nb.Controller);

  SalaryExchangeController = (function() {
    SalaryExchangeController.$inject = ['$http', '$scope', '$nbEvent', 'SALARY_SETTING'];

    function SalaryExchangeController($http, $scope, $Evt, SALARY_SETTING) {
      this.SALARY_SETTING = SALARY_SETTING;
    }

    SalaryExchangeController.prototype.$channelSettingStr = function(channel) {
      return channel + '_setting';
    };

    SalaryExchangeController.prototype.$settingHash = function(channel) {
      return this.SALARY_SETTING[this.$channelSettingStr(channel)];
    };

    SalaryExchangeController.prototype.service_b = function(current) {
      var setting;
      if (!current.baseChannel) {
        return;
      }
      setting = this.$settingHash(current.baseChannel);
      current.baseMoney = setting.flags[current.baseFlag]['amount'];
      return current.performanceMoney = current.baseMoney - this.SALARY_SETTING['global_setting']['minimum_wage'];
    };

    SalaryExchangeController.prototype.service_b_flag_array = function(current) {
      var setting;
      if (!current.baseChannel) {
        return;
      }
      setting = this.$settingHash(current.baseChannel);
      return Object.keys(setting.flags);
    };

    SalaryExchangeController.prototype.normal = function(current) {
      var flag, setting;
      if (!current.baseWage) {
        return;
      }
      if (!current.baseFlag) {
        return;
      }
      setting = this.$settingHash(current.baseWage);
      flag = setting.flags[current.baseFlag];
      if (angular.isDefined(flag)) {
        return current.baseMoney = flag.amount;
      }
      return 0;
    };

    SalaryExchangeController.prototype.normal_channel_array = function(current) {
      var channels, setting;
      if (!current.baseWage) {
        return;
      }
      setting = this.$settingHash(current.baseWage);
      channels = [];
      angular.forEach(setting.flag_list, function(item) {
        if (item !== 'rate' && !item.startsWith('amount')) {
          return channels.push(setting.flag_names[item]);
        }
      });
      return _.uniq(channels);
    };

    SalaryExchangeController.prototype.normal_flag_array = function(current) {
      var setting;
      if (!current.baseWage) {
        return;
      }
      setting = this.$settingHash(current.baseWage);
      return Object.keys(setting.flags);
    };

    SalaryExchangeController.prototype.perf = function(current) {
      var flag, setting;
      if (!current.performanceWage) {
        return;
      }
      setting = this.$settingHash(current.performanceWage);
      flag = setting.flags[current.performanceFlag];
      if (angular.isDefined(flag)) {
        return current.performanceMoney = flag.amount;
      }
      return 0;
    };

    SalaryExchangeController.prototype.perf_flag_array = function(current) {
      var setting;
      if (!current.performanceWage) {
        return;
      }
      setting = this.$settingHash(current.performanceWage);
      return Object.keys(setting.flags);
    };

    SalaryExchangeController.prototype.fly = function(current) {
      var setting;
      if (!current.baseChannel) {
        return;
      }
      if (!current.baseFlag) {
        return;
      }
      setting = this.$settingHash(current.baseChannel);
      return current.baseMoney = setting.flags[current.baseFlag]['amount'];
    };

    SalaryExchangeController.prototype.fly_flag_array = function(current) {
      var setting;
      if (!current.baseChannel) {
        return;
      }
      setting = this.$settingHash(current.baseChannel);
      return Object.keys(setting.flags);
    };

    SalaryExchangeController.prototype.fly_hour = function(current) {
      var setting;
      if (!current.flyHourFee) {
        return;
      }
      setting = this.$settingHash('flyer_hour');
      return current.flyHourMoney = setting[current.flyHourFee];
    };

    SalaryExchangeController.prototype.airline = function(current) {
      var setting;
      if (!current.baseChannel) {
        return;
      }
      if (!current.baseFlag) {
        return;
      }
      setting = this.$settingHash(current.baseChannel);
      return current.baseMoney = setting.flags[current.baseFlag]['amount'];
    };

    SalaryExchangeController.prototype.airline_flag_array = function(current) {
      var setting;
      if (!current.baseChannel) {
        return;
      }
      setting = this.$settingHash(current.baseChannel);
      return Object.keys(setting.flags);
    };

    SalaryExchangeController.prototype.airline_hour = function(current) {
      var setting;
      if (!current.airlineHourFee) {
        return;
      }
      setting = this.$settingHash('fly_attendant_hour');
      return current.airlineHourMoney = setting[current.airlineHourFee];
    };

    SalaryExchangeController.prototype.security_hour = function(current) {
      var setting;
      if (!current.securityHourFee) {
        return;
      }
      setting = this.$settingHash('air_security_hour');
      return current.securityHourMoney = setting[current.securityHourFee];
    };

    return SalaryExchangeController;

  })();

  SalaryBaseController = (function(_super) {
    __extends(SalaryBaseController, _super);

    function SalaryBaseController(Model, scope, q, right_hand_mode, options) {
      this.Model = Model;
      this.scope = scope;
      this.q = q;
      this.right_hand_mode = right_hand_mode;
      if (options == null) {
        options = null;
      }
      this.loadDateTime();
      this.loadInitialData(options);
    }

    SalaryBaseController.prototype.initialize = function(gridApi) {
      var saveRow;
      saveRow = function(rowEntity) {
        var dfd;
        dfd = this.q.defer();
        gridApi.rowEdit.setSavePromise(rowEntity, dfd.promise);
        return rowEntity.$save().$asPromise().then(function() {
          return dfd.resolve();
        }, function() {
          dfd.reject();
          return rowEntity.$restore();
        });
      };
      gridApi.rowEdit.on.saveRow(this.scope, saveRow.bind(this));
      this.scope.$gridApi = gridApi;
      return this.gridApi = gridApi;
    };

    SalaryBaseController.prototype.loadDateTime = function() {
      var date;
      date = new Date();
      this.year_list = this.$getYears();
      this.month_list = this.$getMonths();
      if (!this.right_hand_mode) {
        if (date.getMonth() === 0) {
          this.year_list.pop();
          this.year_list.unshift(date.getFullYear() - 1);
          this.month_list = _.map([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], function(item) {
            if (item < 10) {
              item = '0' + item;
            }
            return item + '';
          });
          this.currentYear = _.last(this.year_list);
          return this.currentMonth = _.last(this.month_list);
        } else {
          this.currentYear = _.last(this.year_list);
          this.month_list.pop();
          return this.currentMonth = _.last(this.month_list);
        }
      } else {
        this.currentYear = _.last(this.year_list);
        return this.currentMonth = _.last(this.month_list);
      }
    };

    SalaryBaseController.prototype.loadInitialData = function(options) {
      var args;
      args = {
        month: this.currentCalcTime()
      };
      if (angular.isDefined(options)) {
        angular.extend(args, options);
      }
      return this.records = this.Model.$collection(args).$fetch();
    };

    SalaryBaseController.prototype.search = function(tableState) {
      if (!tableState) {
        tableState = {};
      }
      tableState['month'] = this.currentCalcTime();
      tableState['per_page'] = this.gridApi.grid.options.paginationPageSize;
      return this.records.$refresh(tableState);
    };

    SalaryBaseController.prototype.getSelectsIds = function() {
      var rows;
      rows = this.gridApi.selection.getSelectedGridRows();
      return rows.map(function(row) {
        return row.entity.$pk;
      });
    };

    SalaryBaseController.prototype.getSelected = function() {
      var rows;
      return rows = this.gridApi.selection.getSelectedGridRows();
    };

    SalaryBaseController.prototype.currentCalcTime = function() {
      return this.currentYear + "-" + this.currentMonth;
    };

    SalaryBaseController.prototype.loadRecords = function(options) {
      var args;
      if (options == null) {
        options = null;
      }
      args = {
        month: this.currentCalcTime()
      };
      if (angular.isDefined(options)) {
        angular.extend(args, options);
      }
      return this.records.$refresh(args);
    };

    SalaryBaseController.prototype.exeCalc = function(options) {
      var args, self;
      if (options == null) {
        options = null;
      }
      this.calcing = true;
      self = this;
      args = {
        month: this.currentCalcTime()
      };
      if (angular.isDefined(options)) {
        angular.extend(args, options);
      }
      return this.Model.compute(args).$asPromise().then(function(data) {
        var erorr_msg;
        self.calcing = false;
        erorr_msg = data.$response.data.messages;
        if (erorr_msg) {
          self.Evt.$send("salary_model:calc:error", erorr_msg);
        }
        return self.loadRecords();
      });
    };

    return SalaryBaseController;

  })(nb.Controller);

  SalaryBasicController = (function(_super) {
    __extends(SalaryBasicController, _super);

    SalaryBasicController.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'BasicSalary', 'toaster'];

    function SalaryBasicController($http, $scope, $q, Evt, Employee, BasicSalary, toaster) {
      this.Evt = Evt;
      this.Employee = Employee;
      this.BasicSalary = BasicSalary;
      this.toaster = toaster;
      SalaryBasicController.__super__.constructor.call(this, this.BasicSalary, $scope, $q, true);
      this.filterOptions = angular.copy(SALARY_FILTER_DEFAULT);
      this.columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
        {
          displayName: '岗位薪酬',
          name: 'positionSalary',
          enableCellEdit: false
        }, {
          displayName: '工龄工资',
          name: 'workingYearsSalary',
          enableCellEdit: false
        }, {
          displayName: '补扣发',
          name: 'addGarnishee',
          headerCellClass: 'editable_cell_header'
        }, {
          displayName: '备注',
          name: 'remark',
          headerCellClass: 'editable_cell_header',
          cellTooltip: function(row) {
            return row.entity.note;
          }
        }
      ]).concat(CALC_STEP_COLUMN);
    }

    return SalaryBasicController;

  })(SalaryBaseController);

  SalaryKeepController = (function(_super) {
    __extends(SalaryKeepController, _super);

    SalaryKeepController.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'KeepSalary', 'toaster'];

    function SalaryKeepController($http, $scope, $q, Evt, Employee, KeepSalary, toaster) {
      this.Evt = Evt;
      this.Employee = Employee;
      this.KeepSalary = KeepSalary;
      this.toaster = toaster;
      SalaryKeepController.__super__.constructor.call(this, this.KeepSalary, $scope, $q, true);
      this.filterOptions = angular.copy(SALARY_FILTER_DEFAULT);
      this.columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
        {
          displayName: '岗位工资保留',
          name: 'position',
          enableCellEdit: false
        }, {
          displayName: '业绩奖保留',
          name: 'performance',
          enableCellEdit: false
        }, {
          displayName: '工龄工资保留',
          name: 'workingYears',
          enableCellEdit: false
        }, {
          displayName: '保底增幅',
          name: 'minimumGrowth',
          enableCellEdit: false
        }, {
          displayName: '地勤补贴保留',
          name: 'landAllowance',
          enableCellEdit: false
        }, {
          displayName: '生活补贴保留',
          name: 'lifeAllowance',
          enableCellEdit: false
        }, {
          displayName: '09调资增加保留',
          name: 'adjustmen_09',
          enableCellEdit: false
        }, {
          displayName: '14公务用车保留',
          name: 'bus_14',
          enableCellEdit: false
        }, {
          displayName: '14通信补贴保留',
          name: 'communication_14',
          enableCellEdit: false
        }, {
          displayName: '补扣发',
          name: 'addGarnishee',
          headerCellClass: 'editable_cell_header'
        }, {
          displayName: '备注',
          name: 'remark',
          headerCellClass: 'editable_cell_header',
          cellTooltip: function(row) {
            return row.entity.note;
          }
        }
      ]).concat(CALC_STEP_COLUMN);
    }

    return SalaryKeepController;

  })(SalaryBaseController);

  SalaryPerformanceController = (function(_super) {
    __extends(SalaryPerformanceController, _super);

    SalaryPerformanceController.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'PerformanceSalary', 'toaster'];

    function SalaryPerformanceController($http, $scope, $q, Evt, Employee, PerformanceSalary, toaster) {
      this.Evt = Evt;
      this.Employee = Employee;
      this.PerformanceSalary = PerformanceSalary;
      this.toaster = toaster;
      SalaryPerformanceController.__super__.constructor.call(this, this.PerformanceSalary, $scope, $q, false);
      this.filterOptions = angular.copy(SALARY_FILTER_DEFAULT);
      this.columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
        {
          displayName: '当月绩效基数',
          name: 'baseSalary',
          enableCellEdit: false
        }, {
          displayName: '当月绩效薪酬',
          name: 'amount',
          enableCellEdit: false
        }, {
          displayName: '补扣发',
          name: 'addGarnishee',
          headerCellClass: 'editable_cell_header'
        }, {
          displayName: '备注',
          name: 'remark',
          headerCellClass: 'editable_cell_header',
          cellTooltip: function(row) {
            return row.entity.note;
          }
        }
      ]).concat(CALC_STEP_COLUMN);
    }

    SalaryPerformanceController.prototype.upload_performance = function(type, attachment_id) {
      var params, self;
      self = this;
      params = {
        type: type,
        attachment_id: attachment_id
      };
      return this.http.post("/api/performance_salaries/import", params).success(function(data, status) {
        if (data.error_count > 0) {
          return self.toaster.pop('error', '提示', '有' + data.error_count + '个导入失败');
        } else {
          return self.toaster.pop('error', '提示', '导入成功');
        }
      });
    };

    return SalaryPerformanceController;

  })(SalaryBaseController);

  SalaryHoursFeeController = (function(_super) {
    __extends(SalaryHoursFeeController, _super);

    SalaryHoursFeeController.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'HoursFee', 'toaster'];

    function SalaryHoursFeeController(http, $scope, $q, Evt, Employee, HoursFee, toaster) {
      this.http = http;
      this.Evt = Evt;
      this.Employee = Employee;
      this.HoursFee = HoursFee;
      this.toaster = toaster;
      this.hours_fee_category = '飞行员';
      SalaryHoursFeeController.__super__.constructor.call(this, this.HoursFee, $scope, $q, false, {
        hours_fee_category: this.hours_fee_category
      });
      this.filterOptions = angular.copy(SALARY_FILTER_DEFAULT);
      this.columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
        {
          displayName: '飞行时间',
          name: 'flyHours',
          enableCellEdit: false
        }, {
          displayName: '小时费',
          name: 'flyFee',
          enableCellEdit: false
        }, {
          displayName: '空勤灶',
          name: 'airlineFee',
          enableCellEdit: false
        }, {
          displayName: '补扣发',
          name: 'addGarnishee',
          headerCellClass: 'editable_cell_header'
        }, {
          displayName: '备注',
          name: 'remark',
          headerCellClass: 'editable_cell_header',
          cellTooltip: function(row) {
            return row.entity.note;
          }
        }
      ]).concat(CALC_STEP_COLUMN);
    }

    SalaryHoursFeeController.prototype.search = function() {
      return SalaryHoursFeeController.__super__.search.call(this, {
        hours_fee_category: this.hours_fee_category
      });
    };

    SalaryHoursFeeController.prototype.loadRecords = function() {
      return SalaryHoursFeeController.__super__.loadRecords.call(this, {
        hours_fee_category: this.hours_fee_category
      });
    };

    SalaryHoursFeeController.prototype.exeCalc = function() {
      return SalaryHoursFeeController.__super__.exeCalc.call(this, {
        hours_fee_category: this.hours_fee_category
      });
    };

    SalaryHoursFeeController.prototype.upload_hours_fee = function(type, attachment_id) {
      var params, self;
      self = this;
      params = {
        type: type,
        attachment_id: attachment_id,
        month: this.currentCalcTime()
      };
      this.show_error_names = false;
      return this.http.post("/api/hours_fees/import", params).success(function(data, status) {
        if (data.error_count > 0) {
          self.show_error_names = true;
          self.error_names = data.error_names;
          return self.toaster.pop('error', '提示', '有' + data.error_count + '个导入失败');
        } else {
          return self.toaster.pop('error', '提示', '导入成功');
        }
      });
    };

    return SalaryHoursFeeController;

  })(SalaryBaseController);

  SalaryAllowanceController = (function(_super) {
    __extends(SalaryAllowanceController, _super);

    SalaryAllowanceController.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'Allowance', 'toaster'];

    function SalaryAllowanceController($http, $scope, $q, Evt, Employee, Allowance, toaster) {
      this.Evt = Evt;
      this.Employee = Employee;
      this.Allowance = Allowance;
      this.toaster = toaster;
      SalaryAllowanceController.__super__.constructor.call(this, this.Allowance, $scope, $q, true);
      this.filterOptions = angular.copy(SALARY_FILTER_DEFAULT);
      this.columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
        {
          displayName: '安检津贴',
          name: 'securityCheck',
          enableCellEdit: false
        }, {
          displayName: '安置津贴',
          name: 'resettlement',
          enableCellEdit: false
        }, {
          displayName: '班组长津贴',
          name: 'groupLeader',
          enableCellEdit: false
        }, {
          displayName: '航站管理津贴',
          name: 'airStationManage',
          enableCellEdit: false
        }, {
          displayName: '车勤补贴',
          name: 'carPresent',
          enableCellEdit: false
        }, {
          displayName: '地勤补贴',
          name: 'landPresent',
          enableCellEdit: false
        }, {
          displayName: '机务放行补贴',
          name: 'permitEntry',
          enableCellEdit: false
        }, {
          displayName: '试车津贴',
          name: 'tryDrive',
          enableCellEdit: false
        }, {
          displayName: '飞行荣誉津贴',
          name: 'flyHonor',
          enableCellEdit: false
        }, {
          displayName: '航线实习补贴',
          name: 'airlinePractice',
          enableCellEdit: false
        }, {
          displayName: '随机补贴',
          name: 'followPlane',
          enableCellEdit: false
        }, {
          displayName: '签派放行补贴',
          name: 'permitSign',
          enableCellEdit: false
        }, {
          displayName: '梭班补贴',
          name: 'workOvertime',
          enableCellEdit: false
        }, {
          displayName: '高温补贴',
          name: 'temp',
          enableCellEdit: false
        }, {
          displayName: '补扣发',
          name: 'addGarnishee',
          headerCellClass: 'editable_cell_header'
        }, {
          displayName: '备注',
          name: 'remark',
          headerCellClass: 'editable_cell_header',
          cellTooltip: function(row) {
            return row.entity.note;
          }
        }
      ]).concat(CALC_STEP_COLUMN);
    }

    SalaryAllowanceController.prototype.upload_allowance = function(type, attachment_id) {
      var params, self;
      self = this;
      params = {
        type: type,
        attachment_id: attachment_id
      };
      return this.http.post("/api/allowances/import", params).success(function(data, status) {
        if (data.error_count > 0) {
          return self.toaster.pop('error', '提示', '有' + data.error_count + '个导入失败');
        } else {
          return self.toaster.pop('error', '提示', '导入成功');
        }
      });
    };

    return SalaryAllowanceController;

  })(SalaryBaseController);

  SalaryLandAllowanceController = (function(_super) {
    __extends(SalaryLandAllowanceController, _super);

    SalaryLandAllowanceController.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'LandAllowance', 'toaster'];

    function SalaryLandAllowanceController(http, $scope, $q, Evt, Employee, LandAllowance, toaster) {
      this.http = http;
      this.Evt = Evt;
      this.Employee = Employee;
      this.LandAllowance = LandAllowance;
      this.toaster = toaster;
      SalaryLandAllowanceController.__super__.constructor.call(this, this.LandAllowance, $scope, $q, false);
      this.filterOptions = angular.copy(SALARY_FILTER_DEFAULT);
      this.columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
        {
          displayName: '津贴',
          name: 'subsidy',
          enableCellEdit: false
        }, {
          displayName: '补扣发',
          name: 'addGarnishee',
          headerCellClass: 'editable_cell_header'
        }, {
          displayName: '备注',
          name: 'remark',
          headerCellClass: 'editable_cell_header',
          cellTooltip: function(row) {
            return row.entity.note;
          }
        }
      ]).concat(CALC_STEP_COLUMN);
    }

    SalaryLandAllowanceController.prototype.upload_land_allowance = function(type, attachment_id) {
      var params, self;
      self = this;
      params = {
        type: type,
        attachment_id: attachment_id
      };
      return this.http.post("/api/land_allowances/import", params).success(function(data, status) {
        if (data.error_count > 0) {
          return self.toaster.pop('error', '提示', '有' + data.error_count + '个导入失败');
        } else {
          return self.toaster.pop('error', '提示', '导入成功');
        }
      });
    };

    return SalaryLandAllowanceController;

  })(SalaryBaseController);

  SalaryRewardController = (function(_super) {
    __extends(SalaryRewardController, _super);

    SalaryRewardController.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'Reward', 'toaster'];

    function SalaryRewardController($http, $scope, $q, Evt, Employee, Reward, toaster) {
      this.Evt = Evt;
      this.Employee = Employee;
      this.Reward = Reward;
      this.toaster = toaster;
      SalaryRewardController.__super__.constructor.call(this, this.Reward, $scope, $q, true);
      this.filterOptions = angular.copy(SALARY_FILTER_DEFAULT);
      this.columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
        {
          displayName: '航班正常奖',
          name: 'flightBonus',
          enableCellEdit: false
        }, {
          displayName: '服务质量奖',
          name: 'serviceBonus',
          enableCellEdit: false
        }, {
          displayName: '航空安全奖',
          name: 'airlineSecurityBonus',
          enableCellEdit: false
        }, {
          displayName: '社会治安综合治理奖',
          name: 'compositeBonus',
          enableCellEdit: false
        }, {
          displayName: '电子航意险代理提成奖',
          name: 'insuranceProxy',
          enableCellEdit: false
        }, {
          displayName: '客舱升舱提成奖',
          name: 'cabinGrowUp',
          enableCellEdit: false
        }, {
          displayName: '全员促销奖',
          name: 'fullSalePromotion',
          enableCellEdit: false
        }, {
          displayName: '四川航空报稿费',
          name: 'articleFee',
          enableCellEdit: false
        }, {
          displayName: '无差错飞行中队奖',
          name: 'allRightFly',
          enableCellEdit: false
        }, {
          displayName: '年度综治奖',
          name: 'yearCompositeBonus',
          enableCellEdit: false
        }, {
          displayName: '运兵先进奖',
          name: 'movePerfect',
          enableCellEdit: false
        }, {
          displayName: '航空安全特殊贡献奖',
          name: 'securitySpecial',
          enableCellEdit: false
        }, {
          displayName: '部门安全管理目标承包奖',
          name: 'depSecurityUndertake',
          enableCellEdit: false
        }, {
          displayName: '飞行安全星级奖',
          name: 'flyStar',
          enableCellEdit: false
        }, {
          displayName: '年度无差错机务维修中队奖',
          name: 'yearAllRightFly',
          enableCellEdit: false
        }, {
          displayName: '网络联程奖',
          name: 'networkConnect',
          enableCellEdit: false
        }, {
          displayName: '季度奖',
          name: 'quarterFee',
          enableCellEdit: false
        }, {
          displayName: '收益奖励金',
          name: 'earningsFee',
          enableCellEdit: false
        }, {
          displayName: '补扣发',
          name: 'addGarnishee',
          headerCellClass: 'editable_cell_header'
        }, {
          displayName: '备注',
          name: 'remark',
          headerCellClass: 'editable_cell_header',
          cellTooltip: function(row) {
            return row.entity.note;
          }
        }
      ]).concat(CALC_STEP_COLUMN);
    }

    SalaryRewardController.prototype.upload_reward = function(type, attachment_id) {
      var params, self;
      self = this;
      params = {
        type: type,
        attachment_id: attachment_id
      };
      return this.http.post("/api/rewards/import", params).success(function(data, status) {
        if (data.error_count > 0) {
          return self.toaster.pop('error', '提示', '有' + data.error_count + '个导入失败');
        } else {
          return self.toaster.pop('error', '提示', '导入成功');
        }
      });
    };

    return SalaryRewardController;

  })(SalaryBaseController);

  SalaryTransportFeeController = (function(_super) {
    __extends(SalaryTransportFeeController, _super);

    SalaryTransportFeeController.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'TransportFee', 'toaster'];

    function SalaryTransportFeeController(http, $scope, $q, Evt, Employee, TransportFee, toaster) {
      this.http = http;
      this.Evt = Evt;
      this.Employee = Employee;
      this.TransportFee = TransportFee;
      this.toaster = toaster;
      SalaryTransportFeeController.__super__.constructor.call(this, this.TransportFee, $scope, $q, true);
      this.filterOptions = angular.copy(SALARY_FILTER_DEFAULT);
      this.columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
        {
          displayName: '交通费',
          name: 'amount',
          enableCellEdit: false
        }, {
          displayName: '班车费扣除',
          name: 'busFee',
          enableCellEdit: false
        }, {
          displayName: '补扣发',
          name: 'addGarnishee',
          headerCellClass: 'editable_cell_header'
        }, {
          displayName: '备注',
          name: 'remark',
          headerCellClass: 'editable_cell_header',
          cellTooltip: function(row) {
            return row.entity.note;
          }
        }
      ]).concat(CALC_STEP_COLUMN);
    }

    SalaryTransportFeeController.prototype.upload_bus_fee = function(type, attachment_id) {
      var params, self;
      self = this;
      params = {
        type: type,
        attachment_id: attachment_id
      };
      return this.http.post("/api/transport_fees/import", params).success(function(data, status) {
        if (data.error_count > 0) {
          return self.toaster.pop('error', '提示', '有' + data.error_count + '个导入失败');
        } else {
          return self.toaster.pop('error', '提示', '导入成功');
        }
      });
    };

    return SalaryTransportFeeController;

  })(SalaryBaseController);

  SalaryOverviewController = (function(_super) {
    __extends(SalaryOverviewController, _super);

    SalaryOverviewController.$inject = ['$http', '$scope', '$q', '$nbEvent', 'Employee', 'SalaryOverview', 'toaster'];

    function SalaryOverviewController($http, $scope, $q, Evt, Employee, SalaryOverview, toaster) {
      this.Evt = Evt;
      this.Employee = Employee;
      this.SalaryOverview = SalaryOverview;
      this.toaster = toaster;
      SalaryOverviewController.__super__.constructor.call(this, this.SalaryOverview, $scope, $http, true);
      this.filterOptions = angular.copy(SALARY_FILTER_DEFAULT);
      this.columnDef = angular.copy(SALARY_COLUMNDEF_DEFAULT).concat([
        {
          displayName: '基础工资',
          name: 'basic',
          enableCellEdit: false
        }, {
          displayName: '绩效工资',
          name: 'performance',
          enableCellEdit: false
        }, {
          displayName: '小时费',
          name: 'hoursFee',
          enableCellEdit: false
        }, {
          displayName: '津贴',
          name: 'subsidy',
          enableCellEdit: false
        }, {
          displayName: '驻站津贴',
          name: 'landSubsidy',
          enableCellEdit: false
        }, {
          displayName: '奖励',
          name: 'reward',
          enableCellEdit: false
        }, {
          displayName: '合计',
          name: 'total',
          enableCellEdit: false
        }, {
          displayName: '备注',
          name: 'remark',
          headerCellClass: 'editable_cell_header',
          cellTooltip: function(row) {
            return row.entity.note;
          }
        }
      ]).concat(CALC_STEP_COLUMN);
    }

    return SalaryOverviewController;

  })(SalaryBaseController);

  CalcStepsController = (function() {
    CalcStepsController.$inject = ['$http', '$scope', 'CalcStep'];

    function CalcStepsController(http, $scope, CalcStep) {
      this.http = http;
      this.CalcStep = CalcStep;
    }

    CalcStepsController.prototype.loadFromServer = function(category, month, employee_id) {
      var self;
      self = this;
      return this.http.get('/api/calc_steps/search?category=' + category + "&month=" + month + "&employee_id=" + employee_id).success(function(data) {
        self.step_notes = data.calc_step.step_notes;
        return self.amount = data.calc_step.amount;
      });
    };

    return CalcStepsController;

  })();

  RewardsAllocationController = (function() {
    RewardsAllocationController.$inject = ['$http', '$scope', 'toaster'];

    function RewardsAllocationController(http, scope, toaster) {
      this.http = http;
      this.scope = scope;
      this.toaster = toaster;
      this.rewards = {};
      this.rewardsCategory = 'flight_bonus';
    }

    RewardsAllocationController.prototype.currentCalcTime = function() {
      return this.currentYear + "-" + this.currentMonth;
    };

    RewardsAllocationController.prototype.loadRewardsAllocation = function() {
      var month, self;
      self = this;
      month = this.currentCalcTime();
      return this.http.get('/api/departments/rewards?month=' + month).success(function(data) {
        return self.rewards = data.rewards;
      });
    };

    RewardsAllocationController.prototype.saveReward = function(departmentId, bonus) {
      var month, param, self;
      self = this;
      param = {
        month: month = this.currentCalcTime(),
        department_id: departmentId
      };
      param[this.rewardsCategory] = bonus;
      return this.http.put('/api/departments/reward_update', param).success(function(data) {
        return self.toaster.pop('success', '提示', '修改成功');
      });
    };

    return RewardsAllocationController;

  })();

  app.controller('salaryCtrl', SalaryController);

  app.controller('salaryPersonalCtrl', SalaryPersonalController);

  app.controller('salaryChangeCtrl', SalaryChangeController);

  app.controller('salaryGradeChangeCtrl', SalaryGradeChangeController);

  app.controller('salaryExchangeCtrl', SalaryExchangeController);

  app.controller('salaryBasicCtrl', SalaryBasicController);

  app.controller('salaryKeepCtrl', SalaryKeepController);

  app.controller('salaryPerformanceCtrl', SalaryPerformanceController);

  app.controller('salaryHoursFeeCtrl', SalaryHoursFeeController);

  app.controller('salaryAllowanceCtrl', SalaryAllowanceController);

  app.controller('salaryLandAllowanceCtrl', SalaryLandAllowanceController);

  app.controller('salaryRewardCtrl', SalaryRewardController);

  app.controller('salaryTransportFeeCtrl', SalaryTransportFeeController);

  app.controller('salaryOverviewCtrl', SalaryOverviewController);

  app.controller('calcStepCtrl', CalcStepsController);

  app.controller('rewardsAllocationCtrl', RewardsAllocationController);

}).call(this);
