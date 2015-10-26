(function() {
  var EmployeeAttendanceCtrl, EmployeeMemberCtrl, EmployeePerformanceCtrl, EmployeeRewardPunishmentCtrl, LeaveEmployeesCtrl, MoveEmployeesCtrl, NewEmpsCtrl, PersonnelCtrl, PersonnelDataCtrl, PersonnelSort, ReviewCtrl, Route, app, filterBuildUtils, nb, orgMutiPos,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  nb = this.nb;

  app = nb.app;

  filterBuildUtils = nb.filterBuildUtils;

  Route = (function() {
    Route.$inject = ['$stateProvider'];

    function Route(stateProvider) {
      stateProvider.state('personnel_list', {
        url: '/personnel',
        templateUrl: 'partials/personnel/personnel.html',
        controller: PersonnelCtrl,
        controllerAs: 'ctrl'
      }).state('personnel_fresh', {
        url: '/personnel/fresh-list',
        controller: NewEmpsCtrl,
        controllerAs: 'ctrl',
        templateUrl: 'partials/personnel/personnel_new_list.html'
      }).state('personnel_review', {
        url: '/personnel/change-review',
        templateUrl: 'partials/personnel/change_review.html',
        controller: ReviewCtrl,
        controllerAs: 'ctrl'
      });
    }

    return Route;

  })();

  app.config(Route);

  PersonnelCtrl = (function(_super) {
    __extends(PersonnelCtrl, _super);

    PersonnelCtrl.$inject = ['$scope', 'sweet', 'Employee', 'CURRENT_ROLES'];

    function PersonnelCtrl(scope, sweet, Employee, CURRENT_ROLES) {
      this.scope = scope;
      this.sweet = sweet;
      this.Employee = Employee;
      this.CURRENT_ROLES = CURRENT_ROLES;
      this.loadInitialData();
      this.selectedIndex = 1;
      this.columnDef = [
        {
          displayName: '所属部门',
          name: 'department.name',
          cellTooltip: function(row) {
            return row.entity.department.name;
          }
        }, {
          displayName: '姓名',
          field: 'name',
          cellTemplate: '<div class="ui-grid-cell-contents ng-binding ng-scope">\n    <a nb-panel\n        template-url="partials/personnel/info_basic.html"\n        locals="{employee: row.entity}">\n        {{grid.getCellValue(row, col)}}\n    </a>\n</div>'
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
      this.constraints = [];
      this.filterOptions = filterBuildUtils('personnel').col('name', '姓名', 'string').col('employee_no', '员工编号', 'string').col('department_ids', '机构', 'org-search').col('position_name', '岗位名称', 'string').col('location', '属地', 'string').col('channel_ids', '通道', 'muti-enum-search', '', {
        type: 'channels'
      }).col('employment_status_id', '用工状态', 'select', '', {
        type: 'employment_status'
      }).col('birthday', '出生日期', 'date-range').col('join_scal_date', '入职日期', 'date-range').col('start_work_date', '参工日期', 'date-range').end();
    }

    PersonnelCtrl.prototype.loadInitialData = function() {
      return this.employees = this.Employee.$collection().$fetch();
    };

    PersonnelCtrl.prototype.search = function(tableState) {
      tableState = tableState || {};
      tableState['per_page'] = this.gridApi.grid.options.paginationPageSize;
      return this.employees.$refresh(tableState);
    };

    PersonnelCtrl.prototype.getSelected = function() {
      var rows;
      rows = this.gridApi.selection.getSelectedGridRows();
      return rows.map(function(row) {
        return row.entity;
      });
    };

    PersonnelCtrl.prototype.getSelectsIds = function() {
      var rows;
      rows = this.gridApi.selection.getSelectedGridRows();
      return rows.map(function(row) {
        return row.entity.$pk;
      });
    };

    PersonnelCtrl.prototype.exportGridApi = function(gridApi) {
      return this.gridApi = gridApi;
    };

    PersonnelCtrl.prototype.isDepartmentHr = function() {
      return this.CURRENT_ROLES.indexOf('department_hr') >= 0;
    };

    return PersonnelCtrl;

  })(nb.Controller);

  NewEmpsCtrl = (function(_super) {
    __extends(NewEmpsCtrl, _super);

    NewEmpsCtrl.$inject = ['$scope', 'Employee', 'Org', '$state', '$enum', '$http', 'toaster'];

    function NewEmpsCtrl(scope, Employee, Org, state, _enum, http, toaster) {
      this.scope = scope;
      this.Employee = Employee;
      this.Org = Org;
      this.state = state;
      this["enum"] = _enum;
      this.http = http;
      this.toaster = toaster;
      this.newEmp = {};
      this.loadInitialData();
      this.columnDef = [
        {
          displayName: '所属部门',
          name: 'department.name',
          cellTooltip: function(row) {
            return row.entity.department.name;
          }
        }, {
          displayName: '姓名',
          field: 'name',
          cellTemplate: '<div class="ui-grid-cell-contents ng-binding ng-scope">\n    <a nb-panel\n        template-url="partials/personnel/info_basic.html"\n        locals="{employee: row.entity}">\n        {{grid.getCellValue(row, col)}}\n    </a>\n</div>'
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
      this.filterOptions = {
        name: 'personnel_new',
        constraintDefs: [
          {
            name: 'name',
            displayName: '姓名',
            type: 'string',
            placeholder: '姓名'
          }, {
            name: 'employee_no',
            displayName: '员工编号',
            type: 'string',
            placeholder: '员工编号'
          }, {
            name: 'department_ids',
            displayName: '机构',
            type: 'org-search'
          }, {
            name: 'position_name',
            displayName: '岗位名称',
            type: 'string'
          }, {
            name: 'locations',
            type: 'string_array',
            displayName: '属地'
          }, {
            name: 'channel_ids',
            type: 'muti-enum-search',
            displayName: '通道',
            params: {
              type: 'channels'
            }
          }, {
            name: 'employment_status_id',
            type: 'select',
            displayName: '用工状态',
            params: {
              type: 'employment_status'
            }
          }, {
            name: 'birthday',
            type: 'date-range',
            displayName: '出生日期'
          }, {
            name: 'join_scal_date',
            type: 'date-range',
            displayName: '入职时间'
          }, {
            name: 'labor_relation_id',
            type: 'select',
            displayName: '用工性质',
            params: {
              type: 'labor_relations'
            }
          }
        ]
      };
    }

    NewEmpsCtrl.prototype.loadInitialData = function() {
      this.collection_param = {
        new_join_date: {
          from: moment().subtract(1, 'year').format('YYYY-MM-DD'),
          to: moment().format("YYYY-MM-DD")
        }
      };
      return this.employees = this.Employee.$collection().$fetch(this.collection_param);
    };

    NewEmpsCtrl.prototype.exportGridApi = function(gridApi) {
      return this.gridApi = gridApi;
    };

    NewEmpsCtrl.prototype.analysisIdentityNo = function(identityNo, object) {
      var genders, result;
      if (!angular.isDefined(identityNo)) {
        return;
      }
      if (!(identityNo.length === 15 || identityNo.length === 18)) {
        return;
      }
      genders = this["enum"].get('genders');
      if (identityNo.length === 15) {
        object.birthday = "19" + identityNo.slice(6, 8) + "-" + identityNo.slice(8, 10) + "-" + identityNo.slice(10, 12);
        if (parseInt(identityNo[14]) % 2 === 0) {
          result = _.find(genders, function(item) {
            return item.label === '女';
          });
          if (result) {
            object.genderId = result.id;
          }
        } else {
          result = _.find(genders, function(item) {
            return item.label === '男';
          });
          if (result) {
            object.genderId = result.id;
          }
        }
      }
      if (identityNo.length === 18) {
        object.birthday = identityNo.slice(6, 10) + "-" + identityNo.slice(10, 12) + "-" + identityNo.slice(12, 14);
        if (parseInt(identityNo[16]) % 2 === 0) {
          result = _.find(genders, function(item) {
            return item.label === '女';
          });
          if (result) {
            return object.genderId = result.id;
          }
        } else {
          result = _.find(genders, function(item) {
            return item.label === '男';
          });
          if (result) {
            return object.genderId = result.id;
          }
        }
      }
    };

    NewEmpsCtrl.prototype.regEmployee = function(employee) {
      var self;
      self = this;
      return this.employees.$build(employee).$save().$then(function() {
        self.loadInitialData();
        return self.state.go(self.state.current.name, {}, {
          reload: true
        });
      });
    };

    NewEmpsCtrl.prototype.checkExistEmployeeNo = function(employeeNo) {
      var self;
      self = this;
      return this.http({
        method: 'GET',
        url: '/api/employees/?employee_no=' + employeeNo
      }).success(function(data) {
        if (data.employees.length > 0) {
          return self.toaster.pop('error', '提示', '员工编号已经存在');
        }
      });
    };

    NewEmpsCtrl.prototype.getSelectsIds = function() {
      var rows;
      rows = this.gridApi.selection.getSelectedGridRows();
      return rows.map(function(row) {
        return row.entity.$pk;
      });
    };

    NewEmpsCtrl.prototype.search = function(tableState) {
      tableState = this.mergeParams(tableState);
      tableState['per_page'] = this.gridApi.grid.options.paginationPageSize;
      return this.employees.$refresh(tableState);
    };

    NewEmpsCtrl.prototype.mergeParams = function(tableState) {
      angular.forEach(this.collection_param, function(val, key) {
        return tableState[key] = val;
      });
      return tableState;
    };

    NewEmpsCtrl.prototype.uploadNewEmployees = function(type, attachment_id) {
      var params, self;
      self = this;
      params = {
        type: type,
        attachment_id: attachment_id
      };
      this.show_error_names = false;
      return this.http.post("/api/employees/import", params).success(function(data, status) {
        if (data.error_count > 0) {
          self.show_error_names = true;
          self.error_names = data.error_names;
          return self.toaster.pop('error', '提示', '有' + data.error_count + '个导入失败');
        } else {
          return self.toaster.pop('error', '提示', '导入成功');
        }
      });
    };

    return NewEmpsCtrl;

  })(nb.Controller);

  LeaveEmployeesCtrl = (function(_super) {
    __extends(LeaveEmployeesCtrl, _super);

    LeaveEmployeesCtrl.$inject = ['$scope', 'LeaveEmployees'];

    function LeaveEmployeesCtrl(scope, LeaveEmployees) {
      this.scope = scope;
      this.LeaveEmployees = LeaveEmployees;
      this.loadInitialData();
      this.columnDef = [
        {
          displayName: '所属部门',
          name: 'department',
          cellTooltip: function(row) {
            return row.entity.department;
          }
        }, {
          displayName: '姓名',
          field: 'name',
          cellTemplate: '<div class="ui-grid-cell-contents ng-binding ng-scope">\n    <a nb-panel\n        template-url="partials/personnel/info_basic.html"\n        locals="{employee: row.entity.owner}">\n        {{grid.getCellValue(row, col)}}\n    </a>\n</div>'
        }, {
          displayName: '员工编号',
          name: 'employeeNo'
        }, {
          displayName: '岗位',
          name: 'position',
          cellTooltip: function(row) {
            return row.entity.position;
          }
        }, {
          displayName: '性别',
          name: 'gender'
        }, {
          displayName: '通道',
          name: 'channel'
        }, {
          displayName: '用工性质',
          name: 'laborRelation'
        }, {
          displayName: '变动性质',
          name: 'employmentStatus'
        }, {
          displayName: '变动时间',
          name: 'changeDate'
        }
      ];
      this.filterOptions = {
        name: 'personnelLeave',
        constraintDefs: [
          {
            name: 'name',
            displayName: '姓名',
            type: 'string'
          }, {
            name: 'channel_ids',
            displayName: '通道',
            type: 'muti-enum-search',
            params: {
              type: 'channels'
            }
          }, {
            name: 'department',
            displayName: '机构',
            type: 'string'
          }, {
            name: 'position_name',
            displayName: '岗位名称',
            type: 'string'
          }, {
            name: 'employment_status',
            type: 'string',
            displayName: '变动性质'
          }, {
            name: 'change_date',
            type: 'date-range',
            displayName: '变动时间'
          }
        ]
      };
    }

    LeaveEmployeesCtrl.prototype.loadInitialData = function() {
      return this.leaveEmployees = this.LeaveEmployees.$collection().$fetch();
    };

    LeaveEmployeesCtrl.prototype.search = function(tableState) {
      tableState = tableState || {};
      tableState['per_page'] = this.gridApi.grid.options.paginationPageSize;
      return this.leaveEmployees.$refresh(tableState);
    };

    LeaveEmployeesCtrl.prototype.getSelected = function() {
      var rows;
      rows = this.gridApi.selection.getSelectedGridRows();
      return rows.map(function(row) {
        return row.entity;
      });
    };

    LeaveEmployeesCtrl.prototype.getSelectsIds = function() {
      var rows;
      rows = this.gridApi.selection.getSelectedGridRows();
      return rows.map(function(row) {
        return row.entity.$pk;
      });
    };

    LeaveEmployeesCtrl.prototype.exportGridApi = function(gridApi) {
      return this.gridApi = gridApi;
    };

    return LeaveEmployeesCtrl;

  })(nb.Controller);

  MoveEmployeesCtrl = (function(_super) {
    __extends(MoveEmployeesCtrl, _super);

    MoveEmployeesCtrl.$inject = ['$scope', 'MoveEmployees', 'Employee', '$nbEvent', '$http'];

    function MoveEmployeesCtrl(scope, MoveEmployees, Employee, Evt, http) {
      this.scope = scope;
      this.MoveEmployees = MoveEmployees;
      this.Employee = Employee;
      this.Evt = Evt;
      this.http = http;
      this.moveEmployees = this.loadInitialData();
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
          name: 'department.name',
          cellTooltip: function(row) {
            return row.entity.departmentName;
          }
        }, {
          displayName: '岗位',
          name: 'positionName',
          cellTooltip: function(row) {
            return row.entity.position;
          }
        }, {
          displayName: '异动性质',
          name: 'specialCategory',
          cellTooltip: function(row) {
            return row.entity.specialCategory;
          }
        }, {
          displayName: '异动时间',
          name: 'specialTime'
        }, {
          displayName: '异动地点',
          name: 'specialLocation'
        }, {
          displayName: '文件编号',
          name: 'fileNo',
          cellTooltip: function(row) {
            return row.entity.fileNo;
          }
        }, {
          displayName: '异动期限',
          name: 'limitTime',
          cellTooltip: function(row) {
            return row.entity.limitTime;
          }
        }
      ];
      this.filterOptions = {
        name: 'personnelLeave',
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
            name: 'department_ids',
            displayName: '机构',
            type: 'org-search'
          }, {
            name: 'special_category',
            type: 'string',
            displayName: '异动性质'
          }, {
            name: 'special_location',
            type: 'string',
            displayName: '异动地点'
          }
        ]
      };
    }

    MoveEmployeesCtrl.prototype.loadInitialData = function() {
      return this.moveEmployees = this.MoveEmployees.$collection().$fetch();
    };

    MoveEmployeesCtrl.prototype.newStopEmployee = function(moveEmployee) {
      var self;
      self = this;
      return this.http.post('/api/special_states/temporarily_stop_air_duty', moveEmployee).then(function(data) {
        var msg;
        self.moveEmployees.$refresh();
        msg = data.messages;
        if (data.status === 200) {
          return self.Evt.$send("special_state:save:success", msg || "创建成功");
        } else {
          return $Evt.$send('special_state:save:error', msg || "创建失败");
        }
      });
    };

    MoveEmployeesCtrl.prototype.newBorrowEmployee = function(moveEmployee) {
      var params, self;
      self = this;
      params = {};
      if (moveEmployee.department) {
        moveEmployee.department_id = moveEmployee.department.$pk;
      }
      params.department_id = moveEmployee.department_id;
      params.out_company = moveEmployee.out_company;
      params.employee_id = moveEmployee.employee_id;
      params.special_date_from = moveEmployee.special_date_from;
      params.special_date_to = moveEmployee.special_date_to;
      params.file_no = moveEmployee.file_no;
      return this.http.post('/api/special_states/temporarily_transfer', params).then(function(data) {
        var msg;
        self.moveEmployees.$refresh();
        msg = data.messages;
        if (data.status === 200) {
          return self.Evt.$send("special_state:save:success", msg || "创建成功");
        } else {
          return $Evt.$send('special_state:save:error', msg || "创建失败");
        }
      });
    };

    MoveEmployeesCtrl.prototype.newAccreditEmployee = function(moveEmployee) {
      var self;
      self = this;
      return this.http.post('/api/special_states/temporarily_defend', moveEmployee).then(function(data) {
        var msg;
        self.moveEmployees.$refresh();
        msg = data.messages;
        if (data.status === 200) {
          return self.Evt.$send("special_state:save:success", msg || "创建成功");
        } else {
          return $Evt.$send('special_state:save:error', msg || "创建失败");
        }
      });
    };

    MoveEmployeesCtrl.prototype.search = function(tableState) {
      tableState = tableState || {};
      return this.moveEmployees.$refresh(tableState);
    };

    MoveEmployeesCtrl.prototype.getSelected = function() {
      var rows, selected;
      rows = this.gridApi.selection.getSelectedGridRows();
      return selected = rows.length >= 1 ? rows[0].entity : null;
    };

    MoveEmployeesCtrl.prototype.loadEmployee = function(params, moveEmployee) {
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
          return moveEmployee.employee_id = matched.$pk;
        } else {
          return self.loadEmp = params;
        }
      });
    };

    return MoveEmployeesCtrl;

  })(nb.Controller);

  ReviewCtrl = (function(_super) {
    __extends(ReviewCtrl, _super);

    ReviewCtrl.$inject = ['$scope', 'Change', 'Record', '$mdDialog', 'toaster'];

    function ReviewCtrl(scope, Change, Record, mdDialog, toaster) {
      var self;
      this.scope = scope;
      this.Change = Change;
      this.Record = Record;
      this.mdDialog = mdDialog;
      this.toaster = toaster;
      this.loadInitialData();
      this.enable_check = false;
      self = this;
      this.changeColumnDef = [
        {
          name: "department.name",
          displayName: "所属部门"
        }, {
          name: "name",
          displayName: "姓名"
        }, {
          name: "employeeNo",
          displayName: "员工编号"
        }, {
          displayName: '信息变更模块',
          field: 'auditableType',
          cellTemplate: '<div class="ui-grid-cell-contents ng-binding ng-scope">\n    <a\n        href="javascript:void(0);"\n        nb-dialog\n        template-url="partials/common/{{row.entity.action == \'修改\'? \'update_change_review.tpl.html\': \'create_change_review.tpl.html\'}}"\n        locals="{\'change\': row.entity}"> {{row.entity.auditableType}}\n    </a>\n</div>'
        }, {
          name: "createdAt",
          displayName: "变更时间"
        }, {
          displayName: '操作',
          field: 'statusCd',
          cellTemplate: '<div class="ui-grid-cell-contents">\n    <div class="radio-group" radio-box ng-model="row.entity.statusCd"></div>\n</div>'
        }, {
          name: "reason",
          displayName: "理由",
          cellTemplate: '<div class="ui-grid-cell-contents">\n    <a href="javascript:;" nb-popup-plus="nb-popup-plus" position="left-bottom" offset="0.5">{{row.entity.reason || \'请输入\'}}\n        <popup-template style="padding:8px;border:1px solid #eee;" class="nb-popup org-default-popup-template">\n            <div class="panel-body popup-body">\n                <md-input-container>\n                    <label>请输入理由</label>\n                    <textarea ng-model="row.entity.reason" style="resize:none;" class="reason-input"></textarea>\n                </md-input-container>\n            </div>\n        </popup-template>\n    </a>\n</div>'
        }
      ];
      this.recordColumnDef = [
        {
          name: "department.name",
          displayName: "所属部门"
        }, {
          name: "name",
          displayName: "姓名"
        }, {
          name: "employeeNo",
          displayName: "员工编号"
        }, {
          displayName: '信息变更模块',
          field: 'auditableType',
          cellTemplate: '<div class="ui-grid-cell-contents ng-binding ng-scope">\n    <a\n        href="javascript:void(0);"\n        nb-dialog\n        template-url="partials/common/{{row.entity.action == \'修改\'? \'update_change_review.tpl.html\': \'create_change_review.tpl.html\'}}"\n        locals="{\'change\': row.entity}"> {{row.entity.auditableType}}\n    </a>\n</div>'
        }, {
          name: "createdAt",
          displayName: "变更时间"
        }, {
          name: "user.name",
          displayName: "操作者"
        }, {
          name: "statusCd",
          displayName: "状态",
          cellFilter: "dictmap:'personnel'"
        }, {
          name: "checkDate",
          displayName: "审核时间"
        }, {
          name: "reason",
          displayName: "理由"
        }
      ];
      this.filterOptions = {
        name: 'personnel_chage_record',
        constraintDefs: [
          {
            name: 'name',
            displayName: '姓名',
            type: 'string',
            placeholder: '员工姓名'
          }, {
            name: 'department_ids',
            displayName: '机构',
            type: 'org-search'
          }, {
            name: 'employee_no',
            displayName: '员工编号',
            type: 'string',
            placeholder: '员工编号'
          }, {
            name: 'created_at',
            type: 'date-range',
            displayName: '变更时间'
          }
        ]
      };
      this.scope.$watch('ctrl.changes', function(from, to) {
        var checked;
        checked = _.filter(self.changes, function(item) {
          if (item.statusCd !== "1") {
            return item;
          }
        });
        return self.enable_check = checked.length;
      }, true);
    }

    ReviewCtrl.prototype.loadInitialData = function() {
      return this.records = this.Record.$collection().$fetch();
    };

    ReviewCtrl.prototype.searchRecord = function(tableState) {
      return this.records.$refresh(tableState);
    };

    ReviewCtrl.prototype.checkChanges = function() {
      var checked, params, self;
      self = this;
      params = [];
      checked = _.filter(this.changes, function(item) {
        if (item.statusCd !== "1") {
          return item;
        }
      });
      _.forEach(checked, function(item) {
        var temp;
        temp = {};
        temp.id = item.id;
        temp.status_cd = item.statusCd;
        temp.reason = item.reason;
        return params.push(temp);
      });
      if (params.length > 0) {
        return this.changes.checkChanges(params).$asPromise().then(function(data) {
          self.changes.$clear();
          return self.changes.$refresh();
        });
      } else {
        return self.toaster.pop('error', '提示', '请勾选要处理的审核记录');
      }
    };

    return ReviewCtrl;

  })(nb.Controller);

  EmployeeMemberCtrl = (function(_super) {
    __extends(EmployeeMemberCtrl, _super);

    EmployeeMemberCtrl.$inject = ['$scope', 'Employee'];

    function EmployeeMemberCtrl(scope, Employee) {
      this.scope = scope;
      this.Employee = Employee;
    }

    EmployeeMemberCtrl.prototype.loadMembers = function(employee) {
      this.scope.lovers = employee.familyMembers.$search({
        relation: 'lover'
      });
      this.scope.children = employee.familyMembers.$search({
        relation: 'children'
      });
      return this.scope.others = employee.familyMembers.$search({
        relation: 'other'
      });
    };

    return EmployeeMemberCtrl;

  })(nb.Controller);

  EmployeePerformanceCtrl = (function(_super) {
    __extends(EmployeePerformanceCtrl, _super);

    EmployeePerformanceCtrl.$inject = ['$scope', 'Employee', 'Performance'];

    function EmployeePerformanceCtrl(scope, Employee, Performance) {
      this.scope = scope;
      this.Employee = Employee;
      this.Performance = Performance;
    }

    EmployeePerformanceCtrl.prototype.loadData = function(employee) {
      var self;
      self = this;
      return employee.performances.$refresh().$then(function(performances) {
        return self.performances = _.sortBy(_.groupBy(performances, function(item) {
          return item.assessYear;
        })).reverse();
      });
    };

    return EmployeePerformanceCtrl;

  })(nb.Controller);

  EmployeeRewardPunishmentCtrl = (function(_super) {
    __extends(EmployeeRewardPunishmentCtrl, _super);

    EmployeeRewardPunishmentCtrl.$inject = ['$scope', 'Employee', 'Reward', 'Punishment'];

    function EmployeeRewardPunishmentCtrl(scope, Employee, Reward, Punishment) {
      this.scope = scope;
      this.Employee = Employee;
      this.Reward = Reward;
      this.Punishment = Punishment;
    }

    EmployeeRewardPunishmentCtrl.prototype.loadRewards = function(employee) {
      return this.rewards = employee.rewards.$refresh({
        genre: '奖励'
      });
    };

    EmployeeRewardPunishmentCtrl.prototype.loadPunishments = function(employee) {
      return this.punishments = employee.punishments.$refresh({
        genre: '处分'
      });
    };

    return EmployeeRewardPunishmentCtrl;

  })(nb.Controller);

  EmployeeAttendanceCtrl = (function(_super) {
    __extends(EmployeeAttendanceCtrl, _super);

    EmployeeAttendanceCtrl.$inject = ['$scope', '$http', 'Employee', 'CURRENT_ROLES'];

    function EmployeeAttendanceCtrl(scope, http, Employee, CURRENT_ROLES) {
      this.scope = scope;
      this.http = http;
      this.Employee = Employee;
      this.CURRENT_ROLES = CURRENT_ROLES;
    }

    EmployeeAttendanceCtrl.prototype.isHrPaymentMember = function() {
      return this.CURRENT_ROLES.indexOf('hr_payment_member') >= 0;
    };

    EmployeeAttendanceCtrl.prototype.dayOnClick = function() {
      return alert('clicked');
    };

    EmployeeAttendanceCtrl.prototype.loadAttendance = function(employee) {
      var colors, keys, self;
      self = this;
      this.eventSources = [];
      keys = ["leaves", "late_or_early_leaves", "absences", "lands", "off_post_trains", "filigt_groundeds", "flight_ground_works"];
      colors = {
        "leaves": "#006600",
        "late_or_early_leaves": "#ffff66",
        "absences": "#ff0033",
        "lands": "#9933ff",
        "off_post_trains": "#0066ff",
        "filigt_groundeds": "#ff6633",
        "flight_ground_works": "#33ff00"
      };
      this.uiConfig = {
        calendar: {
          dayNames: ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"],
          dayNamesShort: ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"],
          monthNamesShort: ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"],
          monthNames: ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"],
          height: 450,
          editable: false,
          header: {
            left: 'month basicWeek',
            center: 'title',
            right: 'today prev,next'
          },
          dayClick: this.dayOnClick
        }
      };
      return this.http.get('/api/me/attendance_records/').success(function(data) {
        return angular.forEach(keys, function(key) {
          var events, source;
          events = data.attendance_records[key];
          events = angular.forEach(events, function(item) {
            if (item["start"]) {
              item["start"] = new Date(item["start"]);
            }
            if (item["end"]) {
              return item["end"] = new Date(item["end"]);
            }
          });
          source = {
            color: colors[key],
            textColor: '#000',
            events: events
          };
          return self.eventSources.push(source);
        });
      });
    };

    return EmployeeAttendanceCtrl;

  })(nb.Controller);

  PersonnelSort = (function(_super) {
    __extends(PersonnelSort, _super);

    PersonnelSort.$inject = ['$scope', 'Org', 'Position', 'Employee', '$http'];

    function PersonnelSort(scope, Org, Position, Employee, http) {
      this.scope = scope;
      this.Org = Org;
      this.Position = Position;
      this.Employee = Employee;
      this.http = http;
      this.orgLinks = [];
      this.loadInitialData();
    }

    PersonnelSort.prototype.loadInitialData = function() {
      var self;
      self = this;
      return this.currentOrgs = this.Org.$search().$then(function(data) {
        self.currentOrgs = data.jqTreeful()[0];
        return self.orgLinks.push(self.currentOrgs);
      });
    };

    PersonnelSort.prototype.orgSelectBack = function() {
      if (this.orgLinks.length > 1) {
        this.orgLinks.pop();
        return this.currentOrgs = this.orgLinks[this.orgLinks.length - 1];
      }
    };

    PersonnelSort.prototype.showChildsOrg = function(org) {
      this.orgLinks.push(org);
      return this.currentOrgs = org;
    };

    PersonnelSort.prototype.setHeigher = function(collection, index, category) {
      var params, promise;
      if (index === 0 || (!category)) {
        return;
      }
      params = {
        category: category,
        current_id: collection[index].id,
        target_id: collection[index - 1].id
      };
      promise = this.changeOrder(params);
      return promise.then(function() {
        var temp;
        temp = collection[index];
        collection[index] = collection[index - 1];
        return collection[index - 1] = temp;
      });
    };

    PersonnelSort.prototype.setLower = function(collection, index, category) {
      var params, promise;
      if (index >= collection.length - 1 || (!category)) {
        return;
      }
      params = {
        category: category,
        current_id: collection[index].id,
        target_id: collection[index + 1].id
      };
      promise = this.changeOrder(params);
      return promise.then(function() {
        var temp;
        temp = collection[index];
        collection[index] = collection[index + 1];
        return collection[index + 1] = temp;
      });
    };

    PersonnelSort.prototype.changeOrder = function(params) {
      var promise;
      return promise = this.http.get('/api/sort', {
        params: params
      });
    };

    return PersonnelSort;

  })(nb.Controller);

  orgMutiPos = function($rootScope) {
    var PersonnelPositions, postLink;
    PersonnelPositions = (function(_super) {
      __extends(PersonnelPositions, _super);

      PersonnelPositions.$inject = ['$scope', 'Position'];

      function PersonnelPositions(scope, Position) {
        this.scope = scope;
        this.Position = Position;
        this.scope.positions = [];
        this.scope.hasPrimary = false;
      }

      PersonnelPositions.prototype.addPositions = function() {
        return this.scope.positions.push({
          position_id: "",
          category: ""
        });
      };

      PersonnelPositions.prototype.removePosition = function(index) {
        return this.scope.positions.splice(index, 1);
      };

      PersonnelPositions.prototype.setHeigher = function(index) {
        var temp;
        if (index === 0) {
          return;
        }
        temp = this.scope.positions[index];
        this.scope.positions[index] = this.scope.positions[index - 1];
        return this.scope.positions[index - 1] = temp;
      };

      PersonnelPositions.prototype.queryPrimary = function(positions) {
        var self;
        self = this;
        self.scope.hasPrimary = false;
        return _.forEach(positions, function(position) {
          if (position.category === '主职') {
            return self.scope.hasPrimary = true;
          }
        });
      };

      return PersonnelPositions;

    })(nb.Controller);
    postLink = function(elem, attrs, ctrl) {};
    return {
      scope: {
        positions: "=ngModel",
        editStatus: "=editing"
      },
      replace: true,
      templateUrl: "partials/personnel/muti-positions.tpl.html",
      require: 'ngModel',
      link: postLink,
      controller: PersonnelPositions,
      controllerAs: "ctrl"
    };
  };

  app.directive('orgMutiPos', [orgMutiPos]);

  PersonnelDataCtrl = (function(_super) {
    __extends(PersonnelDataCtrl, _super);

    PersonnelDataCtrl.$inject = ['$scope', 'CURRENT_ROLES'];

    function PersonnelDataCtrl(scope, CURRENT_ROLES) {
      this.scope = scope;
      this.CURRENT_ROLES = CURRENT_ROLES;
      this.year_list = this.$getYears();
      this.month_list = this.$getMonths();
      this.currentYear = this.year_list[0];
      this.currentMonth = this.month_list[this.month_list.length - 1];
    }

    PersonnelDataCtrl.prototype.calcTime = function() {
      return this.currentYear + '-' + this.currentMonth;
    };

    PersonnelDataCtrl.prototype.isHrPaymentMember = function() {
      return this.CURRENT_ROLES.indexOf('hr_payment_member') >= 0;
    };

    PersonnelDataCtrl.prototype.loadSalary = function() {
      return console.error('载入' + this.calcTime() + '薪酬');
    };

    return PersonnelDataCtrl;

  })(nb.Controller);

  app.controller('PersonnelSort', PersonnelSort);

  app.controller('LeaveEmployeesCtrl', LeaveEmployeesCtrl);

  app.controller('MoveEmployeesCtrl', MoveEmployeesCtrl);

  app.controller('EmployeeMemberCtrl', EmployeeMemberCtrl);

  app.controller('EmployeePerformanceCtrl', EmployeePerformanceCtrl);

  app.controller('EmployeeAttendanceCtrl', EmployeeAttendanceCtrl);

  app.controller('EmployeeRewardPunishmentCtrl', EmployeeRewardPunishmentCtrl);

  app.controller('PersonnelDataCtrl', PersonnelDataCtrl);

}).call(this);
