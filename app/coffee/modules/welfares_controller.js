(function() {
  var AnnuityChangesController, AnnuityComputeController, AnnuityHistoryController, AnnuityPersonalController, BirthAllowanceController, DinnerComputeController, DinnerPersonalController, Route, SocialChangeProcessController, SocialChangesController, SocialComputeController, SocialHistoryController, WelfareController, WelfarePersonalController, app, nb,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  nb = this.nb;

  app = nb.app;

  Route = (function() {
    Route.$inject = ['$stateProvider'];

    function Route(stateProvider) {
      stateProvider.state('welfares', {
        url: '/welfares',
        templateUrl: 'partials/welfares/settings.html'
      }).state('welfares_socials', {
        url: '/welfares/socials',
        templateUrl: 'partials/welfares/socials.html'
      }).state('welfares_annuities', {
        url: '/welfares/annuities',
        templateUrl: 'partials/welfares/annuities.html'
      }).state('welfares_dinnerfee', {
        url: '/welfares/dinnerfee',
        templateUrl: 'partials/welfares/dinnerfee.html'
      }).state('welfares_birth', {
        url: '/welfares/birth',
        templateUrl: 'partials/welfares/birth.html'
      });
    }

    return Route;

  })();

  app.config(Route);

  WelfareController = (function() {
    WelfareController.$inject = ['$http', '$scope', '$nbEvent'];

    function WelfareController($http, $scope, $Evt) {
      $scope.currentSettingLocation = null;
      $scope.setting = null;
      $scope.configurations = null;
      $scope.locations = null;
      $http.get('api/welfares/socials').success(function(result) {
        $scope.configurations = result.socials;
        $scope.locations = $scope.configurations.map(function(config) {
          return config.location;
        });
        return $scope.currentSettingLocation = $scope.locations[0];
      });
      $scope.$watch('currentSettingLocation', function(newValue) {
        return $scope.setting = _.find($scope.configurations, function(config) {
          if (newValue) {
            return config.location === newValue;
          }
        });
      });
      $scope.saveConfig = function(setting) {
        var configs, current_setting_index;
        configs = $scope.configurations;
        current_setting_index = _.findIndex(configs, function(config) {
          return config.location === $scope.currentSettingLocation;
        });
        angular.extend(configs[current_setting_index], setting);
        return $http.put('/api/welfares/socials', {
          socials: configs
        }).success(function() {
          return $Evt.$send('wselfate:save:success', '社保配置保存成功');
        });
      };
    }

    return WelfareController;

  })();

  WelfarePersonalController = (function(_super) {
    __extends(WelfarePersonalController, _super);

    WelfarePersonalController.$inject = ['$http', '$scope', '$nbEvent', 'Employee', 'SocialPersonSetup'];

    function WelfarePersonalController($http, $scope, $Evt, Employee, SocialPersonSetup) {
      this.Employee = Employee;
      this.SocialPersonSetup = SocialPersonSetup;
      this.configurations = this.loadInitialData();
      this.filterOptions = {
        name: 'welfarePersonal',
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
            name: 'department_ids',
            displayName: '机构',
            type: 'org-search'
          }, {
            name: 'social_location',
            type: 'string',
            displayName: '社保属地'
          }, {
            name: 'social_account',
            displayName: '社保编号',
            type: 'string'
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
          displayName: '社保属地',
          name: 'socialLocation'
        }, {
          displayName: '社保编号',
          name: 'socialAccount'
        }, {
          displayName: '年度养老基数',
          name: 'pensionCardinality'
        }, {
          displayName: '年度其他基数',
          name: 'otherCardinality'
        }, {
          displayName: '养老',
          name: 'pension',
          cellTemplate: '<boolean-table-cell></boolean-table-cell>'
        }, {
          displayName: '医疗',
          name: 'treatment',
          cellTemplate: '<boolean-table-cell></boolean-table-cell>'
        }, {
          displayName: '失业',
          name: 'unemploy',
          cellTemplate: '<boolean-table-cell></boolean-table-cell>'
        }, {
          displayName: '工伤',
          name: 'injury',
          cellTemplate: '<boolean-table-cell></boolean-table-cell>'
        }, {
          displayName: '大病',
          name: 'illness',
          cellTemplate: '<boolean-table-cell></boolean-table-cell>'
        }, {
          displayName: '生育',
          name: 'fertility',
          cellTemplate: '<boolean-table-cell></boolean-table-cell>'
        }, {
          displayName: '编辑',
          field: 'name',
          cellTemplate: '<div class="ui-grid-cell-contents">\n    <a nb-dialog\n        template-url="partials/welfares/settings/welfare_personal_edit.html"\n        locals="{setups: row.entity}">\n        编辑\n    </a>\n</div>'
        }
      ];
      this.constraints = [];
    }

    WelfarePersonalController.prototype.loadInitialData = function() {
      return this.socialPersonSetups = this.SocialPersonSetup.$collection().$fetch();
    };

    WelfarePersonalController.prototype.search = function(tableState) {
      var condition;
      condition = {};
      angular.forEach(tableState, function(value, key) {
        if (value && angular.isDefined(value)) {
          return condition[key] = value;
        }
      });
      condition['per_page'] = this.gridApi.grid.options.paginationPageSize;
      return this.socialPersonSetups.$refresh(condition);
    };

    WelfarePersonalController.prototype.getSelectsIds = function() {
      var rows;
      rows = this.gridApi.selection.getSelectedGridRows();
      return rows.map(function(row) {
        return row.entity.$pk;
      });
    };

    WelfarePersonalController.prototype.getSelected = function() {
      var rows;
      return rows = this.gridApi.selection.getSelectedGridRows();
    };

    WelfarePersonalController.prototype.newPersonalSetup = function(newSetup) {
      var self;
      self = this;
      newSetup = this.socialPersonSetups.$build(newSetup);
      return newSetup.$save().$then(function() {
        return self.socialPersonSetups.$refresh();
      });
    };

    WelfarePersonalController.prototype["delete"] = function(isConfirm) {
      if (isConfirm) {
        return this.getSelected().forEach(function(record) {
          return record.entity.$destroy();
        });
      }
    };

    WelfarePersonalController.prototype.loadEmployee = function(params, contract) {
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
          return contract.owner = matched;
        } else {
          return self.loadEmp = params;
        }
      });
    };

    return WelfarePersonalController;

  })(nb.Controller);

  SocialComputeController = (function(_super) {
    __extends(SocialComputeController, _super);

    SocialComputeController.$inject = ['$http', '$scope', '$nbEvent', 'SocialRecord', 'toaster'];

    function SocialComputeController(http, $scope, Evt, SocialRecord, toaster) {
      this.http = http;
      this.Evt = Evt;
      this.SocialRecord = SocialRecord;
      this.toaster = toaster;
      this.socialRecords = this.loadInitialData();
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
          displayName: '社保属地',
          name: 'socialLocation'
        }, {
          displayName: '社保编号',
          name: 'socialAccount'
        }, {
          displayName: '年度养老基数',
          name: 'pensionCardinality'
        }, {
          displayName: '年度其他基数',
          name: 'otherCardinality'
        }, {
          displayName: '个人合计',
          name: 'personageTotal'
        }, {
          displayName: '单位合计',
          name: 'companyTotal'
        }, {
          displayName: '总合计',
          name: 'total'
        }
      ];
      this.constraints = [];
    }

    SocialComputeController.prototype.loadInitialData = function() {
      this.upload_xls_id = 0;
      this.upload_result = "";
      this.year_list = this.$getYears();
      this.month_list = this.$getMonths();
      this.currentYear = _.last(this.year_list);
      this.currentMonth = _.last(this.month_list);
      return this.socialRecords = this.SocialRecord.$collection().$fetch({
        month: this.currentCalcTime()
      });
    };

    SocialComputeController.prototype.search = function(tableState) {
      return this.socialRecords.$refresh(tableState);
    };

    SocialComputeController.prototype.currentCalcTime = function() {
      return this.currentYear + "-" + this.currentMonth;
    };

    SocialComputeController.prototype.loadRecords = function() {
      return this.socialRecords.$refresh({
        month: this.currentCalcTime()
      });
    };

    SocialComputeController.prototype.exeCalc = function() {
      var self;
      this.calcing = true;
      self = this;
      return this.SocialRecord.compute({
        month: this.currentCalcTime()
      }).$asPromise().then(function(data) {
        var erorr_msg;
        self.calcing = false;
        erorr_msg = data.$response.data.messages;
        if (erorr_msg) {
          self.Evt.$send("social:calc:error", erorr_msg);
        }
        return self.loadRecords();
      });
    };

    SocialComputeController.prototype.upload_salary = function(param) {
      var calc_month, params, self;
      self = this;
      calc_month = param.year + '-' + param.month;
      params = {
        attachment_id: this.upload_xls_id,
        month: calc_month
      };
      return this.http.post("/api/social_records/import", params).success(function(data, status) {
        if (data.error_count > 0) {
          return self.Evt.$send('upload:salary_import:error', '月度' + calc_month + '薪酬数据有' + data.error_count + '条导入失败');
        } else {
          return self.Evt.$send('upload:salary_import:success', '月度' + calc_month + '薪酬数据导入成功');
        }
      });
    };

    return SocialComputeController;

  })(nb.Controller);

  SocialHistoryController = (function(_super) {
    __extends(SocialHistoryController, _super);

    SocialHistoryController.$inject = ['$http', '$scope', '$nbEvent', 'SocialRecord'];

    function SocialHistoryController($http, $scope, $Evt, SocialRecord) {
      this.SocialRecord = SocialRecord;
      this.configurations = this.loadInitialData();
      this.filterOptions = {
        name: 'welfarePersonal',
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
            name: 'calc_month',
            displayName: '缴费月度',
            type: 'month-range'
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
          displayName: '社保属地',
          name: 'socialLocation'
        }, {
          displayName: '缴费月度',
          name: 'month'
        }, {
          displayName: '社保编号',
          name: 'socialAccount'
        }, {
          displayName: '年度养老基数',
          name: 'pensionCardinality'
        }, {
          displayName: '年度其他基数',
          name: 'otherCardinality'
        }, {
          displayName: '个人合计',
          name: 'personageTotal'
        }, {
          displayName: '单位合计',
          name: 'companyTotal'
        }, {
          displayName: '总合计',
          name: 'total'
        }
      ];
    }

    SocialHistoryController.prototype.loadInitialData = function() {
      return this.socialRecords = this.SocialRecord.$collection().$fetch();
    };

    SocialHistoryController.prototype.search = function(tableState) {
      tableState = tableState || {};
      tableState['per_page'] = this.gridApi.grid.options.paginationPageSize;
      return this.socialRecords.$refresh(tableState);
    };

    SocialHistoryController.prototype.getSelectsIds = function() {
      var rows;
      rows = this.gridApi.selection.getSelectedGridRows();
      return rows.map(function(row) {
        return row.entity.$pk;
      });
    };

    return SocialHistoryController;

  })(nb.Controller);

  SocialChangesController = (function(_super) {
    __extends(SocialChangesController, _super);

    SocialChangesController.$inject = ['$http', '$scope', '$nbEvent', 'SocialChange'];

    function SocialChangesController($http, $scope, $Evt, SocialChange) {
      this.SocialChange = SocialChange;
      this.configurations = this.loadInitialData();
      this.filterOptions = {
        name: 'welfarePersonal',
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
      this.columnDef = [
        {
          displayName: '员工编号',
          name: 'employeeNo'
        }, {
          displayName: '姓名',
          field: 'employeeName',
          cellTemplate: '<div class="ui-grid-cell-contents ng-binding ng-scope">\n    <a nb-panel\n        template-url="partials/personnel/info_basic.html"\n        locals="{employee: row.entity.owner}">\n        {{grid.getCellValue(row, col)}}\n    </a>\n</div>'
        }, {
          displayName: '所属部门',
          name: 'departmentName'
        }, {
          displayName: '信息发生时间',
          name: 'changeDate'
        }, {
          displayName: '信息种类',
          name: 'category'
        }, {
          displayName: '处理',
          field: 'deal',
          cellTemplate: '<div class="ui-grid-cell-contents ng-binding ng-scope">\n    <a nb-dialog\n       ng-hide="row.entity.is_processed()"\n        template-url="partials/welfares/socials/change_info.html"\n        locals="{changeInfo: row.entity}">\n        查看\n    </a>\n    <span ng-show="row.entity.is_processed()">\n        已处理\n    </span>\n</div>'
        }
      ];
      this.constraints = [];
    }

    SocialChangesController.prototype.loadInitialData = function() {
      return this.socialChanges = this.SocialChange.$collection().$fetch();
    };

    SocialChangesController.prototype.search = function(tableState) {
      tableState = tableState || {};
      tableState['per_page'] = this.gridApi.grid.options.paginationPageSize;
      return this.socialChanges.$refresh(tableState);
    };

    return SocialChangesController;

  })(nb.Controller);

  SocialChangeProcessController = (function(_super) {
    __extends(SocialChangeProcessController, _super);

    SocialChangeProcessController.$inject = ['$http', '$scope', '$enum', '$nbEvent', 'SocialPersonSetup'];

    function SocialChangeProcessController($http, $scope, $enum, $Evt, SocialPersonSetup) {
      this.SocialPersonSetup = SocialPersonSetup;
      SocialChangeProcessController.__super__.constructor.call(this, $scope, $enum, $Evt);
      this.find_or_build_setup = function(change) {
        if (change.socialSetup) {
          change.socialSetup.$fetch();
          return change.socialSetup;
        }
        change.socialSetup = this.SocialPersonSetup.$build({
          socialAccount: '000000',
          socialLocation: '成都',
          owner: change.owner
        });
        return change.socialSetup;
      };
    }

    return SocialChangeProcessController;

  })(nb.EditableResourceCtrl);

  AnnuityPersonalController = (function(_super) {
    __extends(AnnuityPersonalController, _super);

    AnnuityPersonalController.$inject = ['$http', '$scope', '$nbEvent', 'AnnuitySetup', '$q', '$state'];

    function AnnuityPersonalController(http, scope, Evt, AnnuitySetup, q, state) {
      this.http = http;
      this.scope = scope;
      this.Evt = Evt;
      this.AnnuitySetup = AnnuitySetup;
      this.q = q;
      this.state = state;
      this.annuities = this.loadInitialData();
      this.filterOptions = {
        name: 'annuities',
        constraintDefs: [
          {
            name: 'name',
            displayName: '姓名',
            type: 'string'
          }, {
            name: 'employee_no',
            displayName: '员工编号',
            type: 'string'
          }, {
            name: 'annuity_status',
            displayName: '缴费状态',
            type: 'annuity_status_select',
            params: {
              type: 'annuity_status'
            }
          }
        ]
      };
      this.columnDef = [
        {
          displayName: '员工编号',
          name: 'employeeNo',
          enableCellEdit: false
        }, {
          displayName: '姓名',
          field: 'name',
          enableCellEdit: false,
          cellTemplate: '<div class="ui-grid-cell-contents ng-binding ng-scope">\n    <a nb-panel\n        template-url="partials/personnel/info_basic.html"\n        locals="{employee: row.entity.owner}">\n        {{grid.getCellValue(row, col)}}\n    </a>\n</div>'
        }, {
          displayName: '所属部门',
          name: 'department.name',
          enableCellEdit: false,
          cellTooltip: function(row) {
            return row.entity.department.name;
          }
        }, {
          displayName: '身份证号',
          name: 'identityNo',
          enableCellEdit: false
        }, {
          displayName: '手机号',
          name: 'mobile',
          enableCellEdit: false
        }, {
          displayName: '本年基数',
          name: 'annuityCardinality',
          headerCellClass: 'editable_cell_header',
          enableCellEdit: true,
          type: 'number'
        }, {
          displayName: '缴费状态',
          name: 'annuityStatus',
          editableCellTemplate: 'ui-grid/dropdownEditor',
          headerCellClass: 'editable_cell_header',
          editDropdownValueLabel: 'value',
          editDropdownIdLabel: 'key',
          editDropdownOptionsArray: [
            {
              key: '在缴',
              value: '在缴'
            }, {
              key: '退出',
              value: '退出'
            }
          ]
        }
      ];
      this.constraints = [];
    }

    AnnuityPersonalController.prototype.initialize = function(gridApi) {
      var saveRow, self;
      self = this;
      saveRow = function(rowEntity) {
        var dfd;
        dfd = this.q.defer();
        gridApi.rowEdit.setSavePromise(rowEntity, dfd.promise);
        return this.http({
          method: 'PUT',
          url: '/api/annuities/' + rowEntity.id,
          data: {
            id: rowEntity.id,
            annuity_status: rowEntity.annuityStatus,
            annuity_cardinality: rowEntity.annuityCardinality
          }
        }).success(function(data) {
          dfd.resolve();
          return self.Evt.$send('annuity_status:update:success', data.messages);
        }).error(function() {
          dfd.reject();
          return rowEntity.$restore();
        });
      };
      gridApi.rowEdit.on.saveRow(this.scope, saveRow.bind(this));
      return this.scope.$gridApi = gridApi;
    };

    AnnuityPersonalController.prototype.loadInitialData = function() {
      this.start_compute_basic = false;
      return this.annuities = this.AnnuitySetup.$collection().$fetch();
    };

    AnnuityPersonalController.prototype.search = function(tableState) {
      this.tableState = tableState;
      tableState = tableState || {};
      tableState['per_page'] = this.scope.$gridApi.grid.options.paginationPageSize;
      return this.annuities.$refresh(tableState);
    };

    AnnuityPersonalController.prototype.getSelectsIds = function() {
      var rows;
      rows = this.scope.$gridApi.selection.getSelectedGridRows();
      return rows.map(function(row) {
        return row.entity.$pk;
      });
    };

    AnnuityPersonalController.prototype.getSelected = function() {
      var rows;
      rows = this.scope.$gridApi.selection.getSelectedGridRows();
      return this.selected = rows.length >= 1 ? rows[0].entity : null;
    };

    AnnuityPersonalController.prototype.loadBasicComputeRecords = function(employee_id) {
      var self;
      self = this;
      return this.http({
        method: 'GET',
        url: '/api/annuities/show_cardinality?employee_id=' + employee_id
      }).success(function(data) {
        var json_data;
        json_data = angular.fromJson(data);
        self.basicComputeRecords = json_data.social_records;
        return self.averageCompute = json_data.meta.annuity_cardinality;
      });
    };

    AnnuityPersonalController.prototype.computeBasicRecords = function() {
      var self;
      this.start_compute_basic = true;
      self = this;
      return this.http({
        method: 'GET',
        url: '/api/annuities/cal_year_annuity_cardinality'
      }).success(function(data) {
        self.start_compute_basic = false;
        self.Evt.$send('year_annuity_cardinality:compute:success', data.messages || "计算结束");
        return self.loadRecords();
      }).error(function(data) {
        return self.loadRecords();
      });
    };

    AnnuityPersonalController.prototype.loadRecords = function() {
      return this.annuities.$refresh(this.tableState || {});
    };

    return AnnuityPersonalController;

  })(nb.Controller);

  AnnuityComputeController = (function(_super) {
    __extends(AnnuityComputeController, _super);

    AnnuityComputeController.$inject = ['$http', '$scope', '$nbEvent', 'AnnuityRecord', 'toaster'];

    function AnnuityComputeController($http, $scope, Evt, AnnuityRecord, toaster) {
      this.Evt = Evt;
      this.AnnuityRecord = AnnuityRecord;
      this.toaster = toaster;
      this.annuityRecords = this.loadInitialData();
      this.columnDef = [
        {
          displayName: '员工编号',
          name: 'employeeNo'
        }, {
          displayName: '姓名',
          field: 'employeeName',
          cellTemplate: '<div class="ui-grid-cell-contents ng-binding ng-scope">\n    <a nb-panel\n        template-url="partials/personnel/info_basic.html"\n        locals="{employee: row.entity.owner}">\n        {{grid.getCellValue(row, col)}}\n    </a>\n</div>'
        }, {
          displayName: '所属部门',
          name: 'departmentName',
          cellTooltip: function(row) {
            return row.entity.departmentName;
          }
        }, {
          displayName: '身份证号',
          name: 'identityNo'
        }, {
          displayName: '手机号',
          name: 'mobile'
        }, {
          displayName: '本年基数',
          name: 'annuityCardinality'
        }, {
          displayName: '个人缴费',
          name: 'personalPayment'
        }, {
          displayName: '公司缴费',
          name: 'companyPayment'
        }, {
          displayName: '备注',
          name: 'note',
          cellTooltip: function(row) {
            return row.entity.note;
          }
        }
      ];
      this.constraints = [];
    }

    AnnuityComputeController.prototype.loadInitialData = function() {
      this.year_list = this.$getYears();
      this.month_list = this.$getMonths();
      this.currentYear = _.last(this.year_list);
      this.currentMonth = _.last(this.month_list);
      return this.annuityRecords = this.AnnuityRecord.$collection().$fetch({
        date: this.currentCalcTime()
      });
    };

    AnnuityComputeController.prototype.search = function(tableState) {
      tableState = tableState || {};
      tableState['per_page'] = this.gridApi.grid.options.paginationPageSize;
      return this.annuityRecords.$refresh(tableState);
    };

    AnnuityComputeController.prototype.currentCalcTime = function() {
      return this.currentYear + "-" + this.currentMonth;
    };

    AnnuityComputeController.prototype.loadRecords = function() {
      return this.annuityRecords.$refresh({
        date: this.currentCalcTime()
      });
    };

    AnnuityComputeController.prototype.exeCalc = function() {
      var self;
      this.calcing = true;
      self = this;
      return this.AnnuityRecord.compute({
        date: this.currentCalcTime()
      }).$asPromise().then(function(data) {
        var erorr_msg;
        self.calcing = false;
        erorr_msg = data.$response.data.messages;
        if (erorr_msg) {
          self.Evt.$send("annuity:calc:error", erorr_msg);
        }
        return self.loadRecords();
      });
    };

    return AnnuityComputeController;

  })(nb.Controller);

  AnnuityHistoryController = (function(_super) {
    __extends(AnnuityHistoryController, _super);

    AnnuityHistoryController.$inject = ['$http', '$scope', '$nbEvent', 'AnnuityRecord'];

    function AnnuityHistoryController($http, $scope, $Evt, AnnuityRecord) {
      this.AnnuityRecord = AnnuityRecord;
      this.configurations = this.loadInitialData();
      this.filterOptions = {
        name: 'welfarePersonal',
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
            name: 'month',
            displayName: '缴费月度',
            type: 'month-range'
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
          cellTemplate: '<div class="ui-grid-cell-contents ng-binding ng-scope">\n    <a nb-panel\n        template-url="partials/personnel/info_basic.html"\n        locals="{employee: row.entity.owner}">\n        {{grid.getCellValue(row, col)}}\n    </a>\n</div>'
        }, {
          displayName: '所属部门',
          name: 'departmentName',
          cellTooltip: function(row) {
            return row.entity.departmentName;
          }
        }, {
          displayName: '缴费月度',
          name: 'calDate'
        }, {
          displayName: '当期基数',
          name: 'annuityCardinality'
        }, {
          displayName: '个人缴费',
          name: 'personalPayment'
        }, {
          displayName: '公司缴费',
          name: 'companyPayment'
        }, {
          displayName: '备注',
          name: 'note',
          cellTooltip: function(row) {
            return row.entity.note;
          }
        }
      ];
      this.constraints = [];
    }

    AnnuityHistoryController.prototype.loadInitialData = function() {
      return this.annuityRecords = this.AnnuityRecord.$collection().$fetch();
    };

    AnnuityHistoryController.prototype.search = function(tableState) {
      tableState = tableState || {};
      tableState['per_page'] = this.gridApi.grid.options.paginationPageSize;
      return this.annuityRecords.$refresh(tableState);
    };

    return AnnuityHistoryController;

  })(nb.Controller);

  AnnuityChangesController = (function() {
    AnnuityChangesController.$inject = ['$http', '$scope', '$nbEvent', 'AnnuityChange', '$q'];

    function AnnuityChangesController(http, scope, Evt, AnnuityChange, q) {
      this.http = http;
      this.scope = scope;
      this.Evt = Evt;
      this.AnnuityChange = AnnuityChange;
      this.q = q;
      this.annuityChanges = this.loadInitialData();
      this.filterOptions = {
        name: 'annuityChanges',
        constraintDefs: [
          {
            name: 'employee_name',
            displayName: '姓名',
            type: 'string'
          }, {
            name: 'employee_no',
            displayName: '员工编号',
            type: 'string'
          }
        ]
      };
      this.columnDef = [
        {
          displayName: '员工编号',
          name: 'employeeNo',
          enableCellEdit: false
        }, {
          displayName: '姓名',
          field: 'employeeName',
          enableCellEdit: false,
          cellTemplate: '<div class="ui-grid-cell-contents ng-binding ng-scope">\n    <a nb-panel\n        template-url="partials/personnel/info_basic.html"\n        locals="{employee: row.entity.owner}">\n        {{grid.getCellValue(row, col)}}\n    </a>\n</div>'
        }, {
          displayName: '所属部门',
          name: 'departmentName',
          enableCellEdit: false,
          cellTooltip: function(row) {
            return row.entity.departmentName;
          }
        }, {
          displayName: '信息发生时间',
          name: 'createdAt',
          enableCellEdit: false,
          cellFilter: "date: 'yyyy-MM-dd'"
        }, {
          displayName: '信息种类',
          name: 'applyCategory',
          enableCellEdit: false
        }, {
          displayName: '缴费状态',
          field: 'status',
          editableCellTemplate: 'ui-grid/dropdownEditor',
          headerCellClass: 'editable_cell_header',
          editDropdownValueLabel: 'value',
          editDropdownIdLabel: 'key',
          editDropdownOptionsArray: [
            {
              key: '未处理',
              value: '未处理'
            }, {
              key: '加入',
              value: '加入'
            }, {
              key: '退出',
              value: '退出'
            }
          ]
        }
      ];
      this.constraints = [];
    }

    AnnuityChangesController.prototype.initialize = function(gridApi) {
      var saveRow, self;
      self = this;
      saveRow = function(rowEntity) {
        var dfd;
        dfd = this.q.defer();
        gridApi.rowEdit.setSavePromise(rowEntity, dfd.promise);
        if (rowEntity.handleStatus !== "未处理") {
          return this.http({
            method: 'GET',
            url: '/api/annuity_apply/handle_apply?id=' + rowEntity.id + "&handle_status=" + rowEntity.status
          }).success(function(data) {
            dfd.resolve();
            return self.Evt.$send('annuity_change:update:success', data.messages || "处理成功");
          }).error(function() {
            dfd.reject();
            return rowEntity.$restore();
          });
        }
      };
      gridApi.rowEdit.on.saveRow(this.scope, saveRow.bind(this));
      return this.scope.gridApi = gridApi;
    };

    AnnuityChangesController.prototype.loadInitialData = function() {
      return this.annuityChanges = this.AnnuityChange.$collection().$fetch();
    };

    AnnuityChangesController.prototype.search = function(tableState) {
      tableState = tableState || {};
      tableState['per_page'] = this.scope.gridApi.grid.options.paginationPageSize;
      return this.annuityChanges.$refresh(tableState);
    };

    return AnnuityChangesController;

  })();

  DinnerPersonalController = (function(_super) {
    __extends(DinnerPersonalController, _super);

    DinnerPersonalController.$inject = ['$http', '$scope', '$nbEvent', 'DinnerPersonSetup', '$q', '$state'];

    function DinnerPersonalController(http, scope, Evt, DinnerPersonSetup, q, state) {
      this.http = http;
      this.scope = scope;
      this.Evt = Evt;
      this.DinnerPersonSetup = DinnerPersonSetup;
      this.q = q;
      this.state = state;
      this.filterOptions = {
        name: 'dinnerPersonal',
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
            name: 'department_ids',
            displayName: '机构',
            type: 'org-search'
          }, {
            name: 'social_location',
            type: 'string',
            displayName: '社保属地'
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
          displayName: '班制',
          name: 'shiftsType'
        }, {
          displayName: '驻地',
          name: 'landLocation'
        }, {
          displayName: '成都区域',
          name: 'chengduArea'
        }, {
          displayName: '卡金额',
          name: 'cardAmount'
        }, {
          displayName: '卡次数',
          name: 'cardNumber'
        }, {
          displayName: '工作餐',
          name: 'dinnerfee'
        }, {
          displayName: '设置',
          field: 'setting',
          cellTemplate: '<div class="ui-grid-cell-contents ng-binding ng-scope">\n    <a nb-dialog\n        template-url="partials/welfares/dinners/person.html"\n        locals="{}">\n        设置\n    </a>\n</div>'
        }
      ];
    }

    return DinnerPersonalController;

  })(nb.Controller);

  DinnerComputeController = (function(_super) {
    __extends(DinnerComputeController, _super);

    DinnerComputeController.$inject = ['$http', '$scope', '$nbEvent', 'DinnerRecord', 'toaster'];

    function DinnerComputeController($http, $scope, Evt, DinnerRecord, toaster) {
      this.Evt = Evt;
      this.DinnerRecord = DinnerRecord;
      this.toaster = toaster;
    }

    return DinnerComputeController;

  })(nb.Controller);

  BirthAllowanceController = (function(_super) {
    __extends(BirthAllowanceController, _super);

    BirthAllowanceController.$inject = ['$http', '$scope', '$nbEvent', 'BirthAllowance', 'Employee', 'toaster'];

    function BirthAllowanceController($http, $scope, Evt, BirthAllowance, Employee, toaster) {
      this.Evt = Evt;
      this.BirthAllowance = BirthAllowance;
      this.Employee = Employee;
      this.toaster = toaster;
      this.loadInitialData();
      this.filterOptions = {
        name: 'dinnerPersonal',
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
          displayName: '发放日期',
          name: 'sentDate'
        }, {
          displayName: '发放金额',
          name: 'sentAmount'
        }, {
          displayName: '抵扣金额',
          name: 'deductAmount'
        }
      ];
    }

    BirthAllowanceController.prototype.loadInitialData = function() {
      return this.birthAllowances = this.BirthAllowance.$collection().$fetch();
    };

    BirthAllowanceController.prototype.search = function(tableState) {
      tableState = tableState || {};
      tableState['per_page'] = this.gridApi.grid.options.paginationPageSize;
      return this.birthAllowances.$refresh(tableState);
    };

    BirthAllowanceController.prototype.loadEmployee = function(params, contract) {
      var self;
      self = this;
      return this.Employee.$collection().$refresh(params).$then(function(employees) {
        var args, matched;
        args = _.mapKeys(params, function(value, key) {
          return _.camelCase(key);
        });
        matched = _.find(employees, args);
        if (matched && matched.genderId === 27) {
          self.loadEmp = matched;
          self.isFemale = true;
          contract.employeeId = matched.id;
          contract.employeeNo = matched.employeeNo;
          contract.departmentName = matched.department.name;
          contract.positionName = matched.position.name;
          contract.employeeName = matched.name;
          return contract.owner = matched;
        } else if (matched && matched.genderId === 26) {
          self.loadEmp = matched;
          self.isFemale = false;
          return self.toaster.pop('error', '警告', '男性不能发放剩余津贴');
        } else {
          return self.loadEmp = params;
        }
      });
    };

    BirthAllowanceController.prototype.newBirthAllowance = function(birthAllowance) {
      var self;
      self = this;
      return this.birthAllowances.$build(birthAllowance).$save().$then(function() {
        return self.birthAllowances.$refresh();
      });
    };

    return BirthAllowanceController;

  })(nb.Controller);

  app.controller('welfareCtrl', WelfareController);

  app.controller('welfarePersonalCtrl', WelfarePersonalController);

  app.controller('socialComputeCtrl', SocialComputeController);

  app.controller('socialHistoryCtrl', SocialHistoryController);

  app.controller('socialChangesCtrl', SocialChangesController);

  app.controller('socialChangesProcessCtrl', SocialChangeProcessController);

  app.controller('annuityPersonalCtrl', AnnuityPersonalController);

  app.controller('annuityComputeCtrl', AnnuityComputeController);

  app.controller('annuityHistoryCtrl', AnnuityHistoryController);

  app.controller('annuityChangesCtrl', AnnuityChangesController);

  app.controller('dinnerPersonalCtrl', DinnerPersonalController);

  app.controller('dinnerComputeCtrl', DinnerComputeController);

  app.controller('birthAllowanceCtrl', BirthAllowanceController);

}).call(this);
