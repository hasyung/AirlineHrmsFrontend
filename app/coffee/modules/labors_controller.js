(function() {
  var ATTENDANCE_BASE_TABLE_DEFS, ATTENDANCE_SUMMERY_DEFS, ATTENDANCE_SUMMERY_HIS_DEFS, AttendanceCtrl, AttendanceHisCtrl, AttendanceRecordCtrl, ContractCtrl, FLOW_HANDLE_TABLE_DEFS, FLOW_HISTORY_TABLE_DEFS, HANDLER_AND_HISTORY_FILTER_OPTIONS, RetirementCtrl, Route, SbFlowHandlerCtrl, USER_LIST_TABLE_DEFS, UserListCtrl, app, filterBuildUtils, nb, userListFilterOptions,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  nb = this.nb;

  app = nb.app;

  filterBuildUtils = nb.filterBuildUtils;

  userListFilterOptions = filterBuildUtils('laborsRetirement').col('name', '姓名', 'string', '姓名').col('employee_no', '员工编号', 'string').col('department_ids', '机构', 'org-search').col('position_names', '岗位名称', 'string_array').col('locations', '属地', 'string_array').col('channel_ids', '通道', 'muti-enum-search', '', {
    type: 'channels'
  }).col('employment_status_id', '用工状态', 'select', '', {
    type: 'employment_status'
  }).col('gender_id', '性别', 'select', '', {
    type: 'genders'
  }).col('birthday', '出生日期', 'date-range').col('join_scal_date', '入职时间', 'date-range').end();

  USER_LIST_TABLE_DEFS = [
    {
      displayName: '员工编号',
      name: 'employeeNo'
    }, {
      displayName: '姓名',
      field: 'name',
      cellTemplate: '<div class="ui-grid-cell-contents">\n    <a nb-panel\n        template-url="partials/personnel/info_basic.html"\n        locals="{employee: row.entity}">\n        {{grid.getCellValue(row, col)}}\n    </a>\n</div>'
    }, {
      displayName: '所属部门',
      name: 'department.name',
      cellTooltip: function(row) {
        return row.entity.department.name;
      }
    }, {
      displayName: '岗位',
      name: 'position.name',
      cellTooltip: function(row) {
        return row.entity.position.name;
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
      displayName: '到岗时间',
      name: 'joinScalDate'
    }
  ];

  FLOW_HANDLE_TABLE_DEFS = [
    {
      name: 'receptor.channelId',
      displayName: '通道',
      cellFilter: "enum:'channels'"
    }, {
      name: 'workflowState',
      displayName: '状态'
    }, {
      name: 'createdAt',
      displayName: '申请发起时间',
      cellFilter: "date:'yyyy-MM-dd'"
    }, {
      name: 'type',
      displayName: '详细',
      cellTemplate: '<div class="ui-grid-cell-contents">\n    <a flow-handler="row.entity" flows="grid.options.data">\n        查看\n    </a>\n</div>'
    }
  ];

  FLOW_HISTORY_TABLE_DEFS = [
    {
      name: 'receptor.channelId',
      displayName: '通道',
      cellFilter: "enum:'channels'"
    }, {
      name: 'workflowState',
      displayName: '状态'
    }, {
      name: 'createdAt',
      displayName: '出生日期',
      cellFilter: "date:'yyyy-MM-dd'"
    }, {
      name: 'createdAt',
      displayName: '申请发起时间',
      cellFilter: "date:'yyyy-MM-dd'"
    }, {
      name: 'type',
      displayName: '详细',
      cellTemplate: '<div class="ui-grid-cell-contents">\n    <a flow-handler="row.entity" flow-view="true" is-history="true">\n        查看\n    </a>\n</div>'
    }
  ];

  HANDLER_AND_HISTORY_FILTER_OPTIONS = {
    constraintDefs: [
      {
        name: 'employee_name',
        displayName: '姓名',
        type: 'string'
      }, {
        name: 'employee_no',
        displayName: '员工编号',
        type: 'string'
      }, {
        name: 'gender_id',
        displayName: '性别',
        type: 'select',
        params: {
          type: 'genders'
        }
      }, {
        name: 'birthday',
        displayName: '出生日期',
        type: 'date-range'
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
      }, {
        name: 'workflow_state',
        displayName: '状态',
        type: 'workflow_status_select'
      }, {
        name: 'join_scal_date',
        displayName: '入职时间',
        type: 'date-range'
      }, {
        name: 'created_at',
        displayName: '发起时间',
        type: 'date-range'
      }
    ]
  };

  ATTENDANCE_BASE_TABLE_DEFS = [
    {
      name: 'name',
      displayName: '假别',
      cellTooltip: function(row) {
        return row.entity.name;
      }
    }, {
      name: 'vacationDays',
      displayName: '天数'
    }, {
      name: 'workflowState',
      displayName: '状态'
    }, {
      name: 'createdAt',
      displayName: '发起时间',
      cellFilter: "date:'yyyy-MM-dd'"
    }, {
      name: 'formData.startTime',
      displayName: '开始时间',
      cellFilter: "date:'yyyy-MM-dd'"
    }, {
      name: 'formData.endTime',
      displayName: '结束时间',
      cellFilter: "date:'yyyy-MM-dd'"
    }
  ];

  ATTENDANCE_SUMMERY_DEFS = [
    {
      width: 150,
      displayName: '所属部门',
      name: 'departmentName'
    }, {
      width: 100,
      displayName: '员工编号',
      name: 'employeeNo'
    }, {
      width: 100,
      displayName: '姓名',
      name: 'employeeName'
    }, {
      width: 100,
      displayName: '用工性质',
      name: 'laborRelation'
    }, {
      width: 100,
      displayName: '<带薪假>',
      name: 'paidLeave'
    }, {
      width: 100,
      displayName: '年假',
      name: 'annualLeave'
    }, {
      width: 100,
      displayName: '婚丧假',
      name: 'marriageFuneralLeave'
    }, {
      width: 100,
      displayName: '产前检查假',
      name: 'prenatalCheckLeave'
    }, {
      width: 100,
      displayName: '计生假',
      name: 'familyPlanningLeave'
    }, {
      width: 100,
      displayName: '哺乳假',
      name: 'lactationLeave'
    }, {
      width: 100,
      displayName: '女工假',
      name: 'womenLeave'
    }, {
      width: 100,
      displayName: '产假',
      name: 'maternityLeave'
    }, {
      width: 100,
      displayName: '生育护理假',
      name: 'rearNurseLeave'
    }, {
      width: 100,
      displayName: '工伤假',
      name: 'injuryLeave'
    }, {
      width: 100,
      displayName: '疗养假',
      name: 'recuperateLeave'
    }, {
      width: 100,
      displayName: '派驻休假',
      name: 'accreditLeave'
    }, {
      width: 100,
      displayName: '病假',
      name: 'sickLeave'
    }, {
      width: 100,
      displayName: '病假（工伤待定）',
      name: 'sickLeaveInjury'
    }, {
      width: 100,
      displayName: '病假（怀孕待产）',
      name: 'sickLeaveNulliparous'
    }, {
      width: 100,
      displayName: '事假',
      name: 'personalLeave'
    }, {
      width: 100,
      displayName: '公假',
      name: 'publicLeave'
    }, {
      width: 100,
      displayName: '探亲假',
      name: 'homeLeave'
    }, {
      width: 100,
      displayName: '培训',
      name: 'cultivate'
    }, {
      width: 100,
      displayName: '出差',
      name: 'evection'
    }, {
      width: 100,
      displayName: '旷工',
      name: 'absenteeism'
    }, {
      width: 100,
      displayName: '迟到早退',
      name: 'lateOrLeave'
    }, {
      width: 100,
      displayName: '空勤停飞',
      name: 'ground'
    }, {
      width: 100,
      displayName: '空勤地面工作',
      name: 'surfaceWork'
    }, {
      width: 100,
      displayName: '驻站天数',
      name: 'stationDays'
    }, {
      width: 100,
      displayName: '驻站地点',
      name: 'stationPlace'
    }, {
      width: 100,
      displayName: '备注',
      name: 'remark'
    }
  ];

  ATTENDANCE_SUMMERY_HIS_DEFS = [
    {
      width: 150,
      displayName: '所属部门',
      name: 'departmentName'
    }, {
      width: 100,
      displayName: '员工编号',
      name: 'employeeNo'
    }, {
      width: 100,
      displayName: '姓名',
      name: 'employeeName'
    }, {
      width: 100,
      displayName: '用工性质',
      name: 'laborRelation'
    }, {
      width: 100,
      displayName: '月份',
      name: 'summaryDate'
    }, {
      width: 100,
      displayName: '<带薪假>',
      name: 'paidLeave'
    }, {
      width: 100,
      displayName: '年假',
      name: 'annualLeave'
    }, {
      width: 100,
      displayName: '婚丧假',
      name: 'marriageFuneralLeave'
    }, {
      width: 100,
      displayName: '产前检查假',
      name: 'prenatalCheckLeave'
    }, {
      width: 100,
      displayName: '计生假',
      name: 'familyPlanningLeave'
    }, {
      width: 100,
      displayName: '哺乳假',
      name: 'lactationLeave'
    }, {
      width: 100,
      displayName: '女工假',
      name: 'womenLeave'
    }, {
      width: 100,
      displayName: '产假',
      name: 'maternityLeave'
    }, {
      width: 100,
      displayName: '生育护理假',
      name: 'rearNurseLeave'
    }, {
      width: 100,
      displayName: '工伤假',
      name: 'injuryLeave'
    }, {
      width: 100,
      displayName: '疗养假',
      name: 'recuperateLeave'
    }, {
      width: 100,
      displayName: '派驻休假',
      name: 'accreditLeave'
    }, {
      width: 100,
      displayName: '病假',
      name: 'sickLeave'
    }, {
      width: 100,
      displayName: '病假（工伤待定）',
      name: 'sickLeaveInjury'
    }, {
      width: 100,
      displayName: '病假（怀孕待产）',
      name: 'sickLeaveNulliparous'
    }, {
      width: 100,
      displayName: '事假',
      name: 'personalLeave'
    }, {
      width: 100,
      displayName: '公假',
      name: 'publicLeave'
    }, {
      width: 100,
      displayName: '探亲假',
      name: 'homeLeave'
    }, {
      width: 100,
      displayName: '培训',
      name: 'cultivate'
    }, {
      width: 100,
      displayName: '出差',
      name: 'evection'
    }, {
      width: 100,
      displayName: '旷工',
      name: 'absenteeism'
    }, {
      width: 100,
      displayName: '迟到早退',
      name: 'lateOrLeave'
    }, {
      width: 100,
      displayName: '空勤停飞',
      name: 'ground'
    }, {
      width: 100,
      displayName: '空勤地面工作',
      name: 'surfaceWork'
    }, {
      width: 100,
      displayName: '驻站天数',
      name: 'stationDays'
    }, {
      width: 100,
      displayName: '驻站地点',
      name: 'stationPlace'
    }, {
      width: 100,
      displayName: '备注',
      name: 'remark'
    }
  ];

  Route = (function() {
    Route.$inject = ['$stateProvider', '$urlRouterProvider', '$injector'];

    function Route(stateProvider, urlRouterProvider, injector) {
      stateProvider.state('contract_management', {
        url: '/contract-management',
        templateUrl: 'partials/labors/contract/index.html',
        controller: SbFlowHandlerCtrl,
        resolve: {
          'FlowName': function() {
            return 'Flow::RenewContract';
          }
        }
      }).state('labors_attendance', {
        url: '/labors_attendance',
        templateUrl: 'partials/labors/attendance/index.html',
        controller: AttendanceCtrl,
        controllerAs: 'ctrl'
      }).state('labors_ajust_position', {
        url: '/labors_ajust_position',
        templateUrl: 'partials/labors/adjust_position/index.html',
        controller: SbFlowHandlerCtrl,
        resolve: {
          'FlowName': function() {
            return 'Flow::AdjustPosition';
          }
        }
      }).state('labors_dismiss', {
        url: '/labors_dismiss',
        templateUrl: 'partials/labors/dismiss/index.html',
        controller: SbFlowHandlerCtrl,
        resolve: {
          'FlowName': function() {
            return 'Flow::Dismiss';
          }
        }
      }).state('labors_early_retirement', {
        url: '/labors_early_retirement',
        templateUrl: 'partials/labors/early_retirement/index.html',
        controller: SbFlowHandlerCtrl,
        resolve: {
          'FlowName': function() {
            return 'Flow::EarlyRetirement';
          }
        }
      }).state('labors_punishment', {
        url: '/labors_punishment',
        templateUrl: 'partials/labors/punishment/index.html',
        controller: SbFlowHandlerCtrl,
        resolve: {
          'FlowName': function() {
            return 'Flow::Punishment';
          }
        }
      }).state('labors_renew_contract', {
        url: '/labors_renew_contract',
        templateUrl: 'partials/labors/renew_contract/index.html',
        controller: SbFlowHandlerCtrl,
        resolve: {
          'FlowName': function() {
            return 'Flow::RenewContract';
          }
        }
      }).state('labors_retirement', {
        url: '/labors_retirement',
        templateUrl: 'partials/labors/retirement/index.html',
        controller: SbFlowHandlerCtrl,
        resolve: {
          'FlowName': function() {
            return 'Flow::Retirement';
          }
        }
      }).state('labors_leave_job', {
        url: '/labors_leave_job',
        templateUrl: 'partials/labors/leave_job/index.html',
        controller: SbFlowHandlerCtrl,
        resolve: {
          'FlowName': function() {
            return 'Flow::EmployeeLeaveJob';
          }
        }
      }).state('labors_resignation', {
        url: '/labors_resignation',
        templateUrl: 'partials/labors/resignation/index.html',
        controller: SbFlowHandlerCtrl,
        resolve: {
          'FlowName': function() {
            return 'Flow::Resignation';
          }
        }
      });
    }

    return Route;

  })();

  app.config(Route);

  AttendanceCtrl = (function(_super) {
    __extends(AttendanceCtrl, _super);

    AttendanceCtrl.$inject = ['GridHelper', 'Leave', '$scope', '$injector', '$http', 'AttendanceSummary', 'CURRENT_ROLES', 'toaster', '$q', '$nbEvent', '$timeout'];

    function AttendanceCtrl(helper, Leave, scope, injector, http, AttendanceSummary, CURRENT_ROLES, toaster, q, Evt, timeout) {
      var checkBaseDef, recordsBaseDef;
      this.Leave = Leave;
      this.http = http;
      this.AttendanceSummary = AttendanceSummary;
      this.CURRENT_ROLES = CURRENT_ROLES;
      this.toaster = toaster;
      this.q = q;
      this.Evt = Evt;
      this.timeout = timeout;
      this.initDate();
      scope.realFlow = function(entity) {
        var m, t;
        t = entity.type;
        m = injector.get(t);
        return m.$find(entity.$pk);
      };
      this.checksFilterOptions = {
        name: 'attendance_check_list',
        constraintDefs: [
          {
            name: 'employee_name',
            displayName: '姓名',
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
            name: 'summary_date',
            displayName: '汇总时间',
            type: 'month-list'
          }
        ]
      };
      this.recordsFilterOptions = {
        name: 'attendance_records_list',
        constraintDefs: [
          {
            name: 'employee_name',
            displayName: '姓名',
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
            name: 'leave_date',
            displayName: '起始时间',
            type: 'date-range'
          }, {
            name: 'name',
            displayName: '假别',
            type: 'vacation_select'
          }
        ]
      };
      checkBaseDef = ATTENDANCE_BASE_TABLE_DEFS.concat([
        {
          name: 'type',
          displayName: '详细',
          cellTemplate: '<div class="ui-grid-cell-contents" ng-init="realFlow = grid.appScope.$parent.realFlow(row.entity)">\n    <a ng-if="!realFlow.processed" flow-handler="realFlow" flows="grid.options.data">\n        查看\n    </a>\n    <span ng-if="realFlow.processed">已处理</span>\n</div>'
        }
      ]);
      recordsBaseDef = ATTENDANCE_BASE_TABLE_DEFS.concat([
        {
          name: 'type',
          displayName: '详细',
          cellTemplate: '<div class="ui-grid-cell-contents" ng-init="realFlow = grid.appScope.$parent.realFlow(row.entity)">\n    <a flow-handler="realFlow" flow-view="true">\n        查看\n    </a>\n</div>'
        }
      ]);
      this.checksColumnDef = helper.buildFlowDefault(checkBaseDef);
      this.recodsColumnDef = helper.buildFlowDefault(recordsBaseDef);
    }

    AttendanceCtrl.prototype.exeSearch = function(departmentId) {
      var date, params, self;
      date = moment(new Date("" + this.year + "-" + this.month)).format();
      params = {
        summary_date: date
      };
      if (departmentId) {
        params.department_id = departmentId;
      }
      self = this;
      return this.search(params).$asPromise().then(function(data) {
        var summary_record;
        summary_record = _.find(data.$response.data.meta.attendance_summary_status, function(item) {
          return item.department_id === departmentId;
        });
        self.departmentHrChecked = summary_record.department_hr_checked;
        self.departmentLeaderChecked = summary_record.department_leader_checked;
        self.hrDepartmentLeaderChecked = summary_record.hr_department_leader_checked;
        return angular.forEach(self.tableData, function(item) {
          item.departmentHrChecked = self.departmentHrChecked;
          item.departmentLeaderChecked = self.departmentLeaderChecked;
          return item.hrDepartmentLeaderChecked = self.hrDepartmentLeaderChecked;
        });
      });
    };

    AttendanceCtrl.prototype.initDate = function() {
      this.year_list = this.$getYears();
      this.month_list = this.$getMonths();
      this.filter_month_list = this.$getFilterMonths();
      this.year = this.year_list[this.year_list.length - 1];
      return this.month = this.month_list[this.month_list.length - 1];
    };

    AttendanceCtrl.prototype.loadCheckList = function() {
      return this.tableData = this.Leave.$collection().$fetch();
    };

    AttendanceCtrl.prototype.loadRecords = function() {
      return this.tableData = this.Leave.records();
    };

    AttendanceCtrl.prototype.loadSummaries = function() {
      this.summaryCols = ATTENDANCE_SUMMERY_HIS_DEFS;
      return this.tableData = this.AttendanceSummary.$collection().$fetch({
        per_page: 60,
        summary_date: moment().subtract(1, 'months').format('YYYY-MM')
      });
    };

    AttendanceCtrl.prototype.loadSummariesList = function() {
      var self;
      self = this;
      this.initDate();
      if (this.isDepartmentHr()) {
        self.summaryListCol = ATTENDANCE_SUMMERY_DEFS.concat([
          {
            width: 100,
            displayName: '编辑',
            field: '编辑',
            cellTemplate: '<div class="ui-grid-cell-contents">\n    <a nb-dialog\n        ng-hide="row.entity.departmentHrChecked"\n        template-url="partials/labors/attendance/summary_edit.html"\n        locals="{summary: row.entity, list_ref: row.entity.$scope}"> 编辑\n    </a>\n    <span ng-show="row.entity.departmentHrChecked">已确认</span>\n</div>'
          }
        ]);
      } else {
        self.summaryListCol = ATTENDANCE_SUMMERY_DEFS;
      }
      this.tableData = this.AttendanceSummary.records({
        summary_date: moment().format()
      });
      return this.AttendanceSummary.records({
        summary_date: moment().format()
      }).$asPromise().then(function(data) {
        var summary_record;
        summary_record = _.find(data.$response.data.meta.attendance_summary_status, function(item) {
          return item.department_id === data.$response.data.meta.department_id;
        });
        self.departmentHrChecked = summary_record.department_hr_checked;
        self.departmentLeaderChecked = summary_record.department_leader_checked;
        self.hrDepartmentLeaderChecked = summary_record.hr_department_leader_checked;
        return angular.forEach(self.tableData, function(item) {
          item.departmentHrChecked = self.departmentHrChecked;
          item.departmentLeaderChecked = self.departmentLeaderChecked;
          return item.hrDepartmentLeaderChecked = self.hrDepartmentLeaderChecked;
        });
      });
    };

    AttendanceCtrl.prototype.getDate = function() {
      var date;
      return date = moment(new Date("" + this.year + "-" + this.month)).format();
    };

    AttendanceCtrl.prototype.departmentHrConfirm = function() {
      var params, self;
      self = this;
      params = {
        summary_date: this.getDate()
      };
      return this.http.put('/api/attendance_summaries/department_hr_confirm', params).then(function(data) {
        var erorr_msg;
        self.tableData.$refresh();
        erorr_msg = data.$response.data.messages;
        toaster.pop('info', '提示', erorr_msg || "确认成功");
        self.departmentHrChecked = true;
        return angular.forEach(self.tableData, function(item) {
          return item.departmentHrChecked = true;
        });
      });
    };

    AttendanceCtrl.prototype.departmentLeaderCheck = function() {
      var params, self;
      self = this;
      params = {
        summary_date: this.getDate()
      };
      return this.http.put('/api/attendance_summaries/department_leader_check', params).then(function(data) {
        var erorr_msg;
        self.tableData.$refresh();
        erorr_msg = data.$response.data.messages;
        toaster.pop('info', '提示', erorr_msg || "审核成功");
        self.departmentLeaderChecked = true;
        return angular.forEach(self.tableData, function(item) {
          return item.departmentLeaderChecked = true;
        });
      });
    };

    AttendanceCtrl.prototype.hrLeaderCheck = function() {
      var params, self;
      self = this;
      params = {
        summary_date: this.getDate()
      };
      return this.http.put('/api/attendance_summaries/hr_leader_check', params).then(function(data) {
        var erorr_msg;
        self.tableData.$refresh();
        erorr_msg = data.$response.data.messages;
        toaster.pop('info', '提示', erorr_msg || "审核成功");
        self.hrDepartmentLeaderChecked = true;
        return angular.forEach(self.tableData, function(item) {
          return item.hrDepartmentLeaderChecked = true;
        });
      });
    };

    AttendanceCtrl.prototype.search = function(tableState) {
      tableState = tableState || {};
      tableState['per_page'] = this.gridApi.grid.options.paginationPageSize;
      return this.tableData.$refresh(tableState);
    };

    AttendanceCtrl.prototype.getSelected = function() {
      var rows, selected;
      if (this.gridApi.selection) {
        rows = this.gridApi.selection.getSelectedGridRows();
        return selected = rows.length >= 1 ? rows[0].entity : null;
      }
    };

    AttendanceCtrl.prototype.getSelectedEntities = function() {
      var rows;
      if (this.gridApi.selection) {
        rows = this.gridApi.selection.getSelectedGridRows();
        return rows.map(function(row) {
          return row.entity;
        });
      }
    };

    AttendanceCtrl.prototype.exportGridApi = function(gridApi) {
      return this.gridApi = gridApi;
    };

    AttendanceCtrl.prototype.transferToOccupationInjury = function(record) {
      var self, url;
      self = this;
      url = "/api/workflows/" + record.type + "/" + record.id + "/transfer_to_occupation_injury";
      return this.http.put(url).then(function() {
        return self.tableData.$refresh();
      });
    };

    AttendanceCtrl.prototype.isDepartmentHr = function() {
      return this.CURRENT_ROLES.indexOf('department_hr') >= 0;
    };

    AttendanceCtrl.prototype.finishVacation = function() {};

    return AttendanceCtrl;

  })(nb.Controller);

  AttendanceRecordCtrl = (function(_super) {
    __extends(AttendanceRecordCtrl, _super);

    AttendanceRecordCtrl.$inject = ['$scope', 'Attendance', 'Employee', 'GridHelper', '$enum', 'CURRENT_ROLES'];

    function AttendanceRecordCtrl(scope, Attendance, Employee, GridHelper, $enum, CURRENT_ROLES) {
      this.scope = scope;
      this.Attendance = Attendance;
      this.Employee = Employee;
      this.CURRENT_ROLES = CURRENT_ROLES;
      this.loadInitialData();
      this.scope.$enum = $enum;
      this.reviewers = this.Employee.leaders();
      this.filterOptions = filterBuildUtils('attendanceRecord').col('name', '姓名', 'string', '姓名').col('employee_no', '员工编号', 'string').col('department_ids', '机构', 'org-search').end();
      this.columnDef = GridHelper.buildUserDefault([
        {
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
          displayName: '到岗时间',
          name: 'joinScalDate'
        }
      ]);
    }

    AttendanceRecordCtrl.prototype.loadInitialData = function() {
      return this.employees = this.Employee.$collection().$fetch();
    };

    AttendanceRecordCtrl.prototype.search = function(tableState) {
      tableState = tableState || {};
      tableState['per_page'] = this.gridApi.grid.options.paginationPageSize;
      return this.employees.$refresh(tableState);
    };

    AttendanceRecordCtrl.prototype.getSelected = function() {
      var rows, selected;
      rows = this.scope.$gridApi.selection.getSelectedGridRows();
      return selected = rows.length >= 1 ? rows[0].entity : null;
    };

    AttendanceRecordCtrl.prototype.isDepartmentHr = function() {
      return this.CURRENT_ROLES.indexOf('department_hr') >= 0;
    };

    return AttendanceRecordCtrl;

  })(nb.Controller);

  AttendanceHisCtrl = (function(_super) {
    __extends(AttendanceHisCtrl, _super);

    AttendanceHisCtrl.$inject = ['$scope', 'Attendance', 'CURRENT_ROLES'];

    function AttendanceHisCtrl(scope, Attendance, CURRENT_ROLES) {
      this.scope = scope;
      this.Attendance = Attendance;
      this.CURRENT_ROLES = CURRENT_ROLES;
      this.loadInitialData();
      this.filterOptions = filterBuildUtils('attendanceHis').col('employee_name', '姓名', 'string', '姓名').col('employee_no', '员工编号', 'string').col('department_ids', '机构', 'org-search').col('created_at', '记录时间', 'date-range').end();
      this.columnDef = [
        {
          displayName: '员工编号',
          name: 'user.employeeNo'
        }, {
          displayName: '姓名',
          field: 'user.name',
          cellTemplate: '<div class="ui-grid-cell-contents">\n    <a nb-panel\n        template-url="partials/personnel/info_basic.html"\n        locals="{employee: row.entity.user}">\n        {{row.entity.user.name}}\n    </a>\n</div>'
        }, {
          displayName: '所属部门',
          name: 'user.department.name',
          cellTooltip: function(row) {
            return row.entity.user.department.name;
          }
        }, {
          displayName: '岗位',
          name: 'user.position.name',
          cellTooltip: function(row) {
            return row.entity.user.position.name;
          }
        }, {
          displayName: '分类',
          name: 'user.categoryId',
          cellFilter: "enum:'categories'"
        }, {
          displayName: '通道',
          name: 'user.channelId',
          cellFilter: "enum:'channels'"
        }, {
          displayName: '考勤类别',
          name: 'recordType'
        }, {
          displayName: '记录时间',
          name: 'recordDate'
        }
      ];
    }

    AttendanceHisCtrl.prototype.loadInitialData = function() {
      return this.attendances = this.Attendance.$collection().$fetch();
    };

    AttendanceHisCtrl.prototype.search = function(tableState) {
      tableState = tableState || {};
      tableState['per_page'] = this.gridApi.grid.options.paginationPageSize;
      return this.attendances.$refresh(tableState);
    };

    AttendanceHisCtrl.prototype.getSelected = function() {
      var rows, selected;
      rows = this.scope.$gridApi.selection.getSelectedGridRows();
      return selected = rows.length >= 1 ? rows[0].entity : null;
    };

    AttendanceHisCtrl.prototype.markToDeleted = function(attendance) {
      var self;
      self = this;
      return attendance.$destroy().$then(function() {
        return self.attendances.$refresh();
      });
    };

    AttendanceHisCtrl.prototype.isDepartmentHr = function() {
      return this.CURRENT_ROLES.indexOf('department_hr') >= 0;
    };

    return AttendanceHisCtrl;

  })(nb.Controller);

  ContractCtrl = (function(_super) {
    __extends(ContractCtrl, _super);

    ContractCtrl.$inject = ['$scope', 'Contract', '$http', 'Employee', '$nbEvent', 'toaster'];

    function ContractCtrl(scope, Contract, http, Employee, Evt, toaster) {
      this.scope = scope;
      this.Contract = Contract;
      this.http = http;
      this.Employee = Employee;
      this.Evt = Evt;
      this.toaster = toaster;
      this.show_merged = true;
      this.loadInitialData();
      this.filterOptions = filterBuildUtils('contract').col('employee_name', '姓名', 'string', '姓名').col('employee_no', '员工编号', 'string').col('department_ids', '机构', 'org-search').col('end_date', '合同到期时间', 'date-range').col('apply_type', '用工性质', 'apply_type_select').col('notes', '是否有备注', 'boolean').end();
      this.columnDef = [
        {
          displayName: '员工编号',
          name: 'employeeNo'
        }, {
          displayName: '姓名',
          field: 'employeeName',
          cellTemplate: '<div class="ui-grid-cell-contents">\n    <a nb-panel\n        ng-if="row.entity.owner!=null"\n        template-url="partials/personnel/info_basic.html"\n        locals="{employee: row.entity.owner}">\n        {{grid.getCellValue(row, col)}}\n    </a>\n    <span ng-if="row.entity.owner==null">\n        {{grid.getCellValue(row, col)}}\n    </span>\n</div>'
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
          displayName: '用工性质',
          name: 'applyType'
        }, {
          displayName: '变更标志',
          name: 'changeFlag'
        }, {
          displayName: '合同开始时间',
          name: 'startDate'
        }, {
          displayName: '合同结束时间',
          name: 'endDateStr'
        }, {
          displayName: '备注',
          name: 'notes',
          cellTooltip: function(row) {
            return row.entity.note;
          }
        }, {
          displayName: '详细',
          field: '详细',
          cellTemplate: '<div class="ui-grid-cell-contents">\n    <a nb-panel\n        template-url="partials/labors/contract/detail.dialog.html"\n        locals="{contract: row.entity.$refresh()}"> 详细\n    </a>\n</div>'
        }
      ];
      this.hisFilterOptions = filterBuildUtils('contractHis').col('name', '姓名', 'string', '姓名').col('employee_no', '员工编号', 'string').col('department_ids', '机构', 'org-search').end();
      this.hisColumnDef = [
        {
          displayName: '员工编号',
          name: 'employeeNo'
        }, {
          displayName: '姓名',
          field: 'employeeName',
          cellTemplate: '<div class="ui-grid-cell-contents">\n    <a nb-panel\n        template-url="partials/personnel/info_basic.html"\n        locals="{employee: row.entity}">\n        {{grid.getCellValue(row, col)}}\n    </a>\n</div>'
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
          displayName: '用工性质',
          name: 'applyType'
        }, {
          displayName: '变更标志',
          name: 'changeFlag'
        }, {
          displayName: '开始时间',
          name: 'startDate',
          cellFilter: "enum:'channels'"
        }, {
          displayName: '结束时间',
          name: 'endDate'
        }, {
          displayName: '详细',
          field: '详细',
          cellTemplate: '<div class="ui-grid-cell-contents">\n    <a nb-panel\n        template-url="partials/personnel/info_basic.html"\n        locals="{employee: row.entity}"> 详细\n    </a>\n</div>'
        }
      ];
    }

    ContractCtrl.prototype.loadInitialData = function() {
      var self;
      self = this;
      return this.contracts = this.Contract.$collection().$fetch({
        'show_merged': self.show_merged
      });
    };

    ContractCtrl.prototype.search = function(tableState) {
      tableState = tableState || {};
      tableState['per_page'] = this.gridApi.grid.options.paginationPageSize;
      tableState['show_merged'] = this.show_merged;
      return this.contracts.$refresh(tableState);
    };

    ContractCtrl.prototype.getSelected = function() {
      var rows, selected;
      rows = this.gridApi.selection.getSelectedGridRows();
      return selected = rows.length >= 1 ? rows[0].entity : null;
    };

    ContractCtrl.prototype.renewContract = function(request, contract) {
      var self;
      self = this;
      if (contract && contract.employeeId === 0) {
        return;
      }
      return this.http.post("/api/workflows/Flow::RenewContract", request).then(function(data) {
        var msg;
        self.contracts.$refresh();
        msg = data.data.messages;
        if (msg) {
          return self.Evt.$send("contract:renew:success", msg);
        }
      });
    };

    ContractCtrl.prototype.loadDueTime = function(contract) {
      var d, dueTimeStr, e, s, self;
      self = this;
      s = contract.startDate;
      e = contract.endDate;
      if (!contract.isUnfix) {
        if (s && e && s <= e) {
          d = moment.range(s, e).diff('days');
          dueTimeStr = parseInt(d / 365) + '年' + (d - parseInt(d / 365) * 365) + '天';
          return contract.dueTime = dueTimeStr;
        } else {
          self.toaster.pop('error', '提示', '开始时间、结束时间必填，且结束时间需大于开始时间');
        }
      }
    };

    ContractCtrl.prototype.newContract = function(contract) {
      var self;
      self = this;
      if (!contract.isUnfix) {
        if (!contract.endDate) {
          self.toaster.pop('error', '提示', '非无固定合同结束时间必填');
          return;
        }
        if (contract.endDate <= contract.startDate) {
          self.toaster.pop('error', '提示', '非无固定合同结束时间不能小于等于开始时间');
          return;
        }
      }
      return this.contracts.$build(contract).$save().$then(function() {
        return self.contracts.$refresh();
      });
    };

    ContractCtrl.prototype.clearData = function(contract) {
      if (contract.isUnfix) {
        contract.endDate = null;
        return contract.dueTime = null;
      }
    };

    ContractCtrl.prototype.leaveJob = function(contract, isConfirm, reason, flow_id) {
      var params, self;
      if (!isConfirm) {
        return;
      }
      self = this;
      params = {};
      params.reason = reason;
      params.receptor_id = contract.owner.$pk;
      params.flow_id = flow_id;
      params.relation_data = '<div class="flow-info-row" layout="layout"> <div class="flow-info-cell" flex="flex"> <div class="flow-cell-title">入职时间</div> <div class="flow-cell-content">{{join_scal_date}}</div> </div> <div class="flow-info-cell" flex="flex"> <div class="flow-cell-title">发起时间</div> <div class="flow-cell-content">{{created_at}}</div> </div> </div>';
      params.relation_data = params.relation_data.replace('{{join_scal_date}}', contract.owner.joinScalDate);
      params.relation_data = params.relation_data.replace('{{created_at}}', moment().format('YYYY-MM-DD'));
      return this.http.post("/api/workflows/Flow::EmployeeLeaveJob", params).success(function(data, status) {
        return self.Evt.$send("employee_leavejob:create:success", "离职单发起成功");
      });
    };

    ContractCtrl.prototype.loadEmployee = function(params, contract) {
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

    return ContractCtrl;

  })(nb.Controller);

  UserListCtrl = (function(_super) {
    __extends(UserListCtrl, _super);

    UserListCtrl.$inject = ["$scope", "Employee"];

    function UserListCtrl(scope, Employee) {
      this.Employee = Employee;
      scope.employees = this.Employee.$collection().$fetch();
      scope.filterOptions = filterBuildUtils('laborsRetirement').col('name', '姓名', 'string', '姓名').col('employee_no', '员工编号', 'string').col('department_ids', '机构', 'org-search').col('position_name', '岗位名称', 'string').col('location', '属地', 'string').col('channel_ids', '通道', 'muti-enum-search', '', {
        type: 'channels'
      }).col('employment_status_id', '用工状态', 'select', '', {
        type: 'employment_status'
      }).col('birthday', '出生日期', 'date-range').col('join_scal_date', '入职时间', 'date-range').end();
      scope.columnDef = [
        {
          displayName: '所属部门',
          name: 'department.name',
          cellTooltip: function(row) {
            return row.entity.department.name;
          }
        }, {
          displayName: '姓名',
          field: 'name',
          cellTemplate: '<div class="ui-grid-cell-contents">\n    <a nb-panel\n        template-url="partials/personnel/info_basic.html"\n        locals="{employee: row.entity}">\n        {{grid.getCellValue(row, col)}}\n    </a>\n</div>'
        }, {
          displayName: '员工编号',
          name: 'employeeNo'
        }, {
          displayName: '岗位',
          name: 'position.name',
          cellTooltip: function(row) {
            return row.entity.position.name;
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
          displayName: '到岗时间',
          name: 'joinScalDate'
        }
      ];
      scope.getSelected = function() {
        var rows, selected;
        rows = scope.$gridApi.selection.getSelectedGridRows();
        return selected = rows.length >= 1 ? rows[0].entity : null;
      };
      scope.getSelectedEntities = function() {
        var rows;
        rows = scope.$gridApi.selection.getSelectedGridRows();
        return rows = rows.map(function(row) {
          return row.entity;
        });
      };
      scope.search = function(tableState) {
        return scope.employees.$refresh(tableState);
      };
    }

    return UserListCtrl;

  })(nb.Controller);

  RetirementCtrl = (function(_super) {
    __extends(RetirementCtrl, _super);

    RetirementCtrl.$inject = ['GridHelper', 'Flow::Retirement', '$scope', '$injector'];

    function RetirementCtrl(helper, Retirement, scope, injector) {
      var def;
      this.Retirement = Retirement;
      this.filterOptions = {
        name: 'retirementCheck',
        constraintDefs: [
          {
            name: 'employee_name',
            displayName: '姓名',
            type: 'string'
          }
        ]
      };
      def = _.cloneDeep(flow_handle_table_defs);
      this.columnDef = helper.buildFlowDefault(def);
      this.retirements = this.Retirement.$collection().$fetch();
    }

    RetirementCtrl.prototype.search = function(tableState) {
      tableState = tableState || {};
      tableState['per_page'] = this.gridApi.grid.options.paginationPageSize;
      return this.retirements.$refresh(tableState);
    };

    return RetirementCtrl;

  })(nb.Controller);

  SbFlowHandlerCtrl = (function() {
    SbFlowHandlerCtrl.$inject = ['GridHelper', 'FlowName', '$scope', 'Employee', '$injector', 'OrgStore', 'ColumnDef', '$http', '$nbEvent', 'CURRENT_ROLES', '$enum', 'USER_META'];

    function SbFlowHandlerCtrl(helper, FlowName, scope, Employee, $injector, OrgStore, userRequestsColDef, http, Evt, CURRENT_ROLES, _enum, meta) {
      var relationName;
      this.helper = helper;
      this.FlowName = FlowName;
      this.scope = scope;
      this.Employee = Employee;
      this.userRequestsColDef = userRequestsColDef;
      this.http = http;
      this.Evt = Evt;
      this.CURRENT_ROLES = CURRENT_ROLES;
      this["enum"] = _enum;
      this.meta = meta;
      this.scope.ctrl = this;
      this.Flow = $injector.get(this.FlowName);
      this.userListName = "" + this.FlowName + "_USER_LIST";
      this.checkListName = "" + this.FlowName + "_CHECK_LIST";
      this.historyListName = "" + this.FlowName + "_HISTORY_LIST";
      this.columnDef = null;
      this.tableData = null;
      this.filterOptions = null;
      this.reviewers = this.Employee.leaders();
      relationName = this["enum"].parseLabel(this.meta.labor_relation_id, 'labor_relations');
      this.canCreateEarlyRetirement = ["合同", "合同制"].indexOf(relationName) >= 0;
    }

    SbFlowHandlerCtrl.prototype.userList = function() {
      var filterOptions;
      filterOptions = _.cloneDeep(userListFilterOptions);
      filterOptions.name = this.userListName;
      this.filterOptions = filterOptions;
      this.columnDef = _.cloneDeep(USER_LIST_TABLE_DEFS);
      return this.tableData = this.Employee.$collection().$fetch({
        filter_types: [this.FlowName]
      });
    };

    SbFlowHandlerCtrl.prototype.checkList = function() {
      var filterOptions;
      this.columnDef = this.helper.buildFlowDefault(FLOW_HANDLE_TABLE_DEFS);
      if (this.FlowName === 'Flow::Retirement') {
        this.columnDef.splice(2, 0, {
          displayName: '出生日期',
          name: 'receptor.birthday'
        });
        this.columnDef.splice(7, 0, {
          displayName: '申请发起时间',
          name: 'createdAt'
        });
      }
      if (this.FlowName === 'Flow::EarlyRetirement') {
        this.columnDef.splice(2, 0, {
          displayName: '出生日期',
          name: 'receptor.birthday'
        });
        this.columnDef.splice(2, 0, {
          displayName: '性别',
          name: 'receptor.genderId',
          cellFilter: "enum:'genders'"
        });
      }
      if (this.FlowName === 'Flow::AdjustPosition') {
        this.columnDef.splice(4, 0, {
          displayName: '转入部门',
          name: 'toDepartmentName'
        });
        this.columnDef.splice(5, 1, {
          displayName: '转入岗位',
          name: 'toPositionName'
        });
      }
      if (this.FlowName === 'Flow::EmployeeLeaveJob') {
        this.columnDef.splice(6, 0, {
          displayName: '用工性质',
          name: 'receptor.laborRelationId',
          cellFilter: "enum:'labor_relations'"
        });
        this.columnDef.splice(6, 0, {
          displayName: '申请发起时间',
          name: 'createdAt'
        });
      }
      filterOptions = _.cloneDeep(HANDLER_AND_HISTORY_FILTER_OPTIONS);
      filterOptions.name = this.checkListName;
      this.filterOptions = filterOptions;
      return this.tableData = this.Flow.$collection().$fetch();
    };

    SbFlowHandlerCtrl.prototype.historyList = function() {
      var filterOptions;
      this.columnDef = this.helper.buildFlowDefault(FLOW_HISTORY_TABLE_DEFS);
      if (this.FlowName === 'Flow::Retirement') {
        this.columnDef.splice(2, 0, {
          displayName: '出生日期',
          name: 'receptor.birthday'
        });
        this.columnDef.splice(7, 0, {
          displayName: '申请发起时间',
          name: 'createdAt'
        });
      }
      if (this.FlowName === 'Flow::AdjustPosition') {
        this.columnDef.splice(4, 0, {
          displayName: '转入部门',
          name: 'toDepartmentName'
        });
        this.columnDef.splice(5, 1, {
          displayName: '转入岗位',
          name: 'toPositionName'
        });
      }
      if (this.FlowName === 'Flow::Resignation' || this.FlowName === 'Flow::Retirement' || this.FlowName === 'Flow::Dismiss') {
        this.columnDef.splice(6, 0, {
          displayName: '离职发起',
          name: 'leaveJobFlowState'
        });
      }
      if (this.FlowName === 'Flow::Resignation') {
        this.columnDef.splice(6, 0, {
          displayName: '用工性质',
          name: 'receptor.laborRelationId',
          cellFilter: "enum:'labor_relations'"
        });
      }
      filterOptions = _.cloneDeep(HANDLER_AND_HISTORY_FILTER_OPTIONS);
      if (this.FlowName === 'Flow::Resignation' || this.FlowName === 'Flow::Retirement' || this.FlowName === 'Flow::Dismiss') {
        filterOptions.constraintDefs.splice(10, 0, {
          displayName: '离职发起',
          name: 'leave_job_state',
          type: 'leave_job_state_select'
        });
      }
      filterOptions.name = this.historyListName;
      this.filterOptions = filterOptions;
      return this.tableData = this.Flow.records();
    };

    SbFlowHandlerCtrl.prototype.myRequests = function() {
      this.columnDef = this.userRequestsColDef;
      return this.tableData = this.Flow.myRequests();
    };

    SbFlowHandlerCtrl.prototype.getSelected = function() {
      var rows, selected;
      if (!this.gridApi.selection) {
        return null;
      }
      rows = this.gridApi.selection.getSelectedGridRows();
      return selected = rows.length >= 1 ? rows[0].entity : null;
    };

    SbFlowHandlerCtrl.prototype.getSelectedEntities = function() {
      var rows;
      if (!this.gridApi.selection) {
        return [];
      }
      rows = this.gridApi.selection.getSelectedGridRows();
      return rows.map(function(row) {
        return row.entity;
      });
    };

    SbFlowHandlerCtrl.prototype.exportGridApi = function(gridApi) {
      return this.gridApi = gridApi;
    };

    SbFlowHandlerCtrl.prototype.search = function(tableState) {
      tableState = tableState || {};
      tableState['per_page'] = this.gridApi.grid.options.paginationPageSize;
      return this.tableData.$refresh(tableState);
    };

    SbFlowHandlerCtrl.prototype.retirement = function(users) {
      var params, self;
      self = this;
      params = users.map(function(user) {
        return {
          id: user.id,
          relation_data: user.relation_data,
          retirement_date: user.retirementDate
        };
      });
      return this.http.post("/api/workflows/Flow::Retirement/batch_create", {
        receptors: params
      }).success(function(data, status) {
        self.Evt.$send("retirement:create:success", "退休发起成功");
        return self.tableData.$refresh();
      });
    };

    SbFlowHandlerCtrl.prototype.leaveJob = function(employeeId, isConfirm, reason, flow_id, join_scal_date) {
      var params, self;
      if (!isConfirm) {
        return;
      }
      self = this;
      params = {};
      params.reason = reason;
      params.receptor_id = employeeId;
      params.flow_id = flow_id;
      params.relation_data = '<div class="flow-info-row" layout="layout"> <div class="flow-info-cell" flex="flex"> <div class="flow-cell-title">入职时间</div> <div class="flow-cell-content">{{join_scal_date}}</div> </div> <div class="flow-info-cell" flex="flex"> <div class="flow-cell-title">发起时间</div> <div class="flow-cell-content">{{created_at}}</div> </div> </div>';
      params.relation_data = params.relation_data.replace('{{join_scal_date}}', join_scal_date);
      params.relation_data = params.relation_data.replace('{{created_at}}', moment().format('YYYY-MM-DD'));
      return this.http.post("/api/workflows/Flow::EmployeeLeaveJob", params).success(function(data, status) {
        self.Evt.$send("employee_leavejob:create:success", "离职单发起成功");
        return self.refreshTableData();
      });
    };

    SbFlowHandlerCtrl.prototype.refreshTableData = function() {
      return this.tableData.$refresh({
        filter_types: [this.FlowName]
      });
    };

    SbFlowHandlerCtrl.prototype.revert = function(isConfirm, record) {
      var self;
      self = this;
      if (isConfirm) {
        return record.revert().$asPromise().then(function() {
          return self.tableData.$refresh();
        });
      }
    };

    SbFlowHandlerCtrl.prototype.isDepartmentHr = function() {
      return this.CURRENT_ROLES.indexOf('department_hr') >= 0;
    };

    SbFlowHandlerCtrl.prototype.isHrLaborRelationMember = function() {
      return this.CURRENT_ROLES.indexOf('hr_labor_relation_member') >= 0;
    };

    return SbFlowHandlerCtrl;

  })();

  app.controller('AttendanceRecordCtrl', AttendanceRecordCtrl);

  app.controller('AttendanceHisCtrl', AttendanceHisCtrl);

  app.controller('UserListCtrl', UserListCtrl);

  app.controller('ContractCtrl', ContractCtrl);

  app.controller('RetirementCtrl', RetirementCtrl);

  app.controller('SbFlowHandlerCtrl', SbFlowHandlerCtrl);

  app.constant('ColumnDef', []);

}).call(this);
