(function() {
  var FlowController, FlowHandlerDirective, app, flowRelationDataDirective, joinUrl, resetForm;

  app = this.nb.app;

  resetForm = nb.resetForm;

  joinUrl = function(_head) {
    var _tail;
    if (!_head) {
      return null;
    }
    _tail = Array.prototype.slice.call(arguments, 1).join('/');
    return (_head + '').replace(/\/$/, '') + '/' + _tail.replace(/^\/+/g, '').replace(/\/{2,}/g, '/');
  };

  flowRelationDataDirective = function($timeout) {
    var postLink;
    postLink = function(scope, elem, attrs, ctrl) {
      var getRelationDataHTML;
      getRelationDataHTML = function() {
        return ctrl.$setViewValue(elem.html());
      };
      return $timeout(getRelationDataHTML, 300);
    };
    return {
      require: 'ngModel',
      link: postLink
    };
  };

  FlowHandlerDirective = function(ngDialog) {
    var comiple, postLink, template;
    template = '<div class="approval-wapper panel-bg-gray">\n    <md-toolbar md-theme="hrms" class="md-warn">\n        <div class="md-toolbar-tools">\n            <span>{{flow.name}}申请单</span>\n        </div>\n    </md-toolbar>\n    <div class="approval-container">\n        <md-card>\n            <div class="approval-info">\n                <div class="approval-info-head">\n                    <div class="name" ng-bind="flow.receptor.name"></div>\n                    <div class="approval-info-plus">\n                        <span class="serial-num" ng-bind="flow.receptor.employeeNo"> </span>\n                        <span class="position"> {{::flow.receptor.departmentName}} / {{::flow.receptor.positionName}} </span>\n                    </div>\n                </div>\n                <div class="flow-relations">\n                    #flowRelationData#\n                </div>\n            </div>\n        </md-card>\n        <md-card>\n            <div class="approval-relation-info">\n                <div class="approval-subheader">申请信息</div>\n                <div class="approval-relations">\n                    <div layout ng-repeat="entity in flow.formData">\n                        <div flex="flex" class="approval-cell">\n                            <span class="cell-title">{{entity.name}}</span>\n                            <span class="cell-content">{{entity.value}}</span>\n                        </div>\n                    </div>\n                    <div style="margin-top:30px;" nb-annexs-box annexs="flow.attachments" ng-if="flow.attachments && flow.attachments.length >=1"></div>\n                </div>\n            </div>\n        </md-card>\n        <md-card>\n            <div class="approval-msg">\n                <div class="approval-subheader">意见</div>\n                <div class="approval-cell-container">\n                    <div class="approval-msg-cell" ng-repeat="msg in flow.flowNodes track by msg.id">\n                        <div class="approval-msg-container">\n                            <div class="approval-msg-header">\n                                <span>{{msg.reviewerName}}</span>\n                                <span>{{msg.reviewerDepartment}}-{{msg.reviewerPosition}}</span>\n                            </div>\n                            <div class="approval-msg-content" >\n                                {{msg.body}}\n                            </div>\n                        </div>\n                        <div class="approval-msg-decider">\n                            <span class="approval-decider-date">{{msg.createdAt | date: \'yyyy-MM-dd HH:mm\' }}</span>\n                        </div>\n                    </div>\n                </div>\n                <div class="approval-opinions" ng-if="!flowView || (!isHistory && flow.name==\'合同续签\')">\n                    <form name="flowReplyForm" ng-submit="reply(userReply, flowReplyForm);">\n                        <div layout>\n                            <md-input-container flex>\n                                <label>审批意见</label>\n                                <textarea ng-model="userReply" required columns="1" md-maxlength="150"></textarea>\n                            </md-input-container>\n                        </div>\n                        <md-button class="md-raised md-primary" type="submit">保存意见</md-button>\n                    </form>\n                </div>\n            </div>\n        </md-card>\n        <div class="approval-buttons" ng-if="!flowView || (!isHistory && flow.name==\'合同续签\')">\n            <md-button class="md-raised md-warn" ng-click="submitFlow({opinion: true}, flow, dialog, state)" type="button">通过</md-button>\n            <md-button class="md-raised md-warn" ng-click="submitFlow({opinion: false}, flow, dialog, state)" type="button">驳回</md-button>\n            <md-button class="md-raised md-primary"\n                nb-dialog\n                template-url="partials/component/workflow/hand_over.html"\n                locals="{flow:flow}"\n                >移交</md-button>\n        </div>\n        <div class="approval-buttons" ng-if="flowView && (flow.name!=\'合同续签\' || isHistory)">\n            <md-button class="md-raised md-warn" ng-click="dialog.close()" type="button">关闭</md-button>\n        </div>\n    </div>\n</div>';
    postLink = function(scope, elem, attrs, ctrl) {
      var defaults, offeredExtra, openDialog, options;
      defaults = ngDialog.getDefaults();
      options = angular.extend({}, defaults, scope.options);
      scope.flowView = angular.isDefined(attrs.flowView);
      scope.isHistory = angular.isDefined(attrs.isHistory);
      offeredExtra = function(flow) {
        return template.replace(/#flowRelationData#/, flow.relationData ? flow.relationData : '').replace(/#extraFormLayout#/, flow.$extraForm ? flow.$extraForm : '');
      };
      openDialog = function(evt) {
        var promise;
        promise = scope.flow.$refresh().$asPromise();
        return promise.then(offeredExtra).then(function(template) {
          return ngDialog.open({
            template: template,
            plain: true,
            className: 'ngdialog-theme-panel',
            controller: 'FlowController',
            controllerAs: 'dialog',
            scope: scope,
            locals: {
              flow: scope.flow
            }
          });
        });
      };
      elem.on('click', openDialog);
      return scope.$on('$destroy', function() {
        return elem.off('click', openDialog);
      });
    };
    comiple = function() {};
    return {
      scope: {
        flow: "=flowHandler",
        flowSet: "=flows",
        options: "=?"
      },
      link: postLink
    };
  };

  FlowController = (function() {
    FlowController.$inject = ['$http', '$scope', 'USER_META', 'OrgStore', 'Employee', '$nbEvent', '$state'];

    function FlowController(http, scope, meta, OrgStore, Employee, Evt, state) {
      var FLOW_HTTP_PREFIX, parseParams;
      this.state = state;
      FLOW_HTTP_PREFIX = "/api/workflows";
      scope.selectedOrgs = [];
      scope.reviewers = [];
      scope.leaders = [];
      scope.reviewOrgs = OrgStore.getPrimaryOrgs();
      scope.userReply = "";
      scope.state = this.state;
      scope.CHOICE = {
        ACCEPT: true,
        REJECT: false
      };
      scope.req = {
        opinion: true
      };
      scope.reply = function(userReply, form) {
        var last_msg;
        try {
          last_msg = _.last(scope.flow.flowNodes);
          if (last_msg && last_msg.reviewerId === meta.id) {
            return last_msg.$update({
              body: userReply
            });
          } else {
            return scope.flow.flowNodes.$create({
              body: userReply
            });
          }
        } finally {
          scope.userReply = "";
          resetForm(form);
        }
      };
      scope.submitFlow = function(req, flow, dialog, state) {
        var promise, url;
        url = joinUrl(FLOW_HTTP_PREFIX, flow.type, flow.id);
        promise = http.put(url, req);
        return promise.then(function() {
          if (angular.isDefined(scope.flowSet)) {
            scope.flowSet.$refresh();
          }
          return dialog.close();
        });
      };
      parseParams = function(params) {
        var orgIds;
        if (params.type === "departments") {
          orgIds = _.map(scope.selectedOrgs, 'id');
          params.department_ids = orgIds;
          params.reviewer_id = void 0;
        } else if (params.type === "reviewer") {
          params.department_ids = void 0;
        }
        return params;
      };
      scope.transfer = function(params, flow, dialog, parentDialog) {
        var promise, url;
        params = parseParams(params);
        url = joinUrl(FLOW_HTTP_PREFIX, flow.type, flow.id);
        promise = http.put(url, params);
        return promise.then(function() {
          if (angular.isDefined(scope.flowSet)) {
            flow.processed = '已处理';
            scope.flowSet.$refresh();
          }
          dialog.close();
          return parentDialog.close();
        });
      };
      scope.toggleSelect = function(org, list) {
        var index;
        index = list.indexOf(org);
        if (index > -1) {
          return list.splice(index, 1);
        } else {
          return list.push(org);
        }
      };
      scope.getContact = function() {
        return http.get('/api/me/flow_contact_people').success(function(result) {
          return scope.reviewers = result.flow_contact_people;
        });
      };
      scope.addContact = function(param) {
        return http.post('/api/me/flow_contact_people', {
          employee_id: param
        }).success(function(result) {
          return Evt.$send('result:post:success', '添加常用联系人成功');
        });
      };
      scope.removeContact = function(param) {
        return http["delete"]('/api/me/flow_contact_people/' + param).success(function(result) {
          scope.getContact();
          return Evt.$send('result:delete:success', '删除常用联系人成功');
        });
      };
      scope.queryContact = function(param) {
        return http.get('/api/me/auditor_list?&name=' + param).success(function(result) {
          return scope.leaders = result.employees;
        });
      };
    }

    return FlowController;

  })();

  app.controller('FlowController', FlowController);

  app.directive('flowHandler', ['ngDialog', FlowHandlerDirective]);

  app.directive('flowRelationData', ['$timeout', flowRelationDataDirective]);

}).call(this);
