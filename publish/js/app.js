(function() {
  var App, appConf, datepickerConf, deps, mdThemingConf, nb, resources, restConf, routeConf;

  this.nb = nb = {};

  deps = ['ct.ui.router.extras', 'mgo-angular-wizard', 'mgcrea.ngStrap.datepicker', 'ngDialog', 'ui.select', 'ngAnimate', 'ngAria', 'ui.bootstrap', 'ngSanitize', 'ngMessages', 'ngMaterial', 'toaster', 'restmod', 'angular.filter', 'resources', 'nb.directives', 'toaster', 'ngCookies', 'nb.filters', 'nb.component'];

  resources = angular.module('resources', []);

  nb.app = App = angular.module('nb', deps);

  appConf = function($provide, ngDialogProvider) {
    $provide.decorator('$rootScope', [
      '$delegate', function($delegate) {
        Object.defineProperty($delegate.constructor.prototype, '$onRootScope', {
          value: function(name, listener) {
            var unsubscribe;
            unsubscribe = $delegate.$on(name, listener);
            this.$on('$destroy', unsubscribe);
            return unsubscribe;
          },
          enumerable: false
        });
        return $delegate;
      }
    ]);
    return ngDialogProvider.setDefaults({
      className: 'ngdialog-theme-flat',
      plain: false,
      showClose: false,
      appendTo: false
    });
  };

  restConf = function(restmodProvider) {
    return restmodProvider.rebase('AMSApi', {
      $config: {
        urlPrefix: 'api'
      }
    });
  };

  mdThemingConf = function($mdThemingProvider) {
    return $mdThemingProvider.theme('default').primaryPalette('indigo').accentPalette('amber').warnPalette('deep-orange');
  };

  routeConf = function($stateProvider, $urlRouterProvider, $locationProvider, $httpProvider) {
    $locationProvider.html5Mode(false);
    $urlRouterProvider.otherwise('/');
    $stateProvider.state('home', {
      url: '/',
      templateUrl: 'partials/home.html',
      ncyBreadcrumb: {
        skip: true
      }
    }).state('login', {
      url: '/login',
      templateUrl: 'partials/auth/login.html'
    }).state('sigup', {
      url: '/sigup',
      templateUrl: 'partials/auth/sigup.html'
    });
    return $httpProvider.interceptors.push([
      '$q', '$location', 'toaster', 'sweet', function($q, $location, toaster, sweet) {
        return {
          'responseError': function(response) {
            if (response.status === 401) {
              $location.path('/login');
            }
            if (response.status === 403) {
              sweet.error('操作失败', response.data.message || JSON.stringify(response.data));
            }
            if (/^5/.test(Number(response.status).toString())) {
              toaster.pop('error', '服务器错误', response.data.message || JSON.stringify(response.data));
            }
            return $q.reject(response);
          }
        };
      }
    ]);
  };

  datepickerConf = function($datepickerProvider) {
    return angular.extend($datepickerProvider.defaults, {
      dateFormat: 'yyyy-MM-dd',
      modelDateFormat: 'yyyy-MM-dd',
      dateType: 'string'
    });
  };

  App.config(['$provide', 'ngDialogProvider', appConf]).config(['$datepickerProvider', datepickerConf]).config(['restmodProvider', restConf]).config(['$mdThemingProvider', mdThemingConf]).config(['$stateProvider', '$urlRouterProvider', '$locationProvider', '$httpProvider', routeConf]).run([
    '$state', '$rootScope', 'toaster', '$http', 'Org', 'sweet', 'User', '$enum', '$timeout', '$cookies', function($state, $rootScope, toaster, $http, Org, sweet, User, $enum, $timeout, $cookies) {
      var cancelLoading, startLoading;
      cancelLoading = function() {
        return $rootScope.loading = false;
      };
      startLoading = function() {
        return $rootScope.loading = true;
      };
      $rootScope.$on('$stateChangeStart', function() {
        startLoading();
        return $timeout(cancelLoading, 1000);
      });
      $rootScope.$on('process', startLoading);
      $rootScope.$on('success', function(code, info) {
        toaster.pop(code.name, "提示", info);
        return cancelLoading();
      });
      $rootScope.$on('error', function(code, info) {
        $rootScope.loading = false;
        return toaster.pop(code.name, "提示", info);
      });
      $rootScope.currentUser = User.$fetch();
      $rootScope.$state = $state;
      $rootScope.allOrgs = Org.$search();
      $rootScope.logout = function() {
        return $http["delete"]('/api/sign_out').success(function() {
          return $rootScope.currentUser = null;
        });
      };
      $rootScope.enums = $enum.get();
      return $rootScope.loadEnum = $enum.loadEnum();
    }
  ]);

}).call(this);

(function() {


}).call(this);

(function() {
  var Base, Controller, EditableResourceCtrl, NewResourceCtrl, Service, app, nb,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  nb = this.nb;

  app = nb.app;

  Base = (function() {
    function Base() {}

    return Base;

  })();

  Service = (function(_super) {
    __extends(Service, _super);

    function Service() {
      return Service.__super__.constructor.apply(this, arguments);
    }

    return Service;

  })(Base);

  Controller = (function(_super) {
    __extends(Controller, _super);

    function Controller() {}

    Controller.prototype.onInitialDataError = function(xhr) {
      if (xhr) {
        if (xhr.status === 404) {
          this.location.path(this.navUrls.resolve("not-found"));
          this.location.replace();
        } else if (xhr.status === 403) {
          this.location.path(this.navUrls.resolve("permission-denied"));
          this.location.replace();
        }
      }
      return this.q.reject(xhr);
    };

    return Controller;

  })(Base);

  nb.Base = Base;

  nb.Service = Service;

  nb.Controller = Controller;

  EditableResourceCtrl = (function() {
    EditableResourceCtrl.$inject = ['$scope'];

    function EditableResourceCtrl(scope) {
      scope.editing = false;
      scope.edit = function(evt) {
        if (evt && evt.preventDefault) {
          evt.preventDefault();
        }
        return scope.editing = true;
      };
      scope.save = function(promise, form) {
        if (form && form.$invalid) {
          return;
        }
        if (promise) {
          if (promise.then) {
            return promise.then(function() {
              return scope.editing = false;
            });
          } else if (promise.$then) {
            return promise.$then(function() {
              return scope.editing = false;
            });
          } else {
            throw new Error('promise 参数错误');
          }
        } else {
          return scope.editing = false;
        }
      };
      scope.cancel = function(resource, evt, form) {
        if (evt) {
          evt.preventDefault();
        }
        if (resource && resource.$restore) {
          resource.$restore();
        }
        if (form && form.$setPristine) {
          form.$setPristine();
        }
        return scope.editing = false;
      };
    }

    return EditableResourceCtrl;

  })();

  NewResourceCtrl = (function() {
    NewResourceCtrl.$inject = ['$scope'];

    function NewResourceCtrl(scope) {
      scope.create = function(resource, form) {
        if (form && form.$invalid) {
          return;
        }
        if (resource.$save) {
          return resource.$save();
        }
      };
    }

    return NewResourceCtrl;

  })();

  app.controller('EditableResource', EditableResourceCtrl);

  app.controller('NewResource', NewResourceCtrl);

}).call(this);

(function() {
  var Api, App, ConfigService, nb,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  nb = this.nb;

  App = nb.app;

  Api = {
    urlPrefix: 'api'
  };

  ConfigService = (function(_super) {
    __extends(ConfigService, _super);

    ConfigService.$inject = ['$log', 'restmodProvider'];

    function ConfigService(log, provider) {
      this.log = log;
      this.provider = provider;
      this.initialize();
    }

    ConfigService.prototype.initialize = function() {};

    return ConfigService;

  })(nb.Service);

}).call(this);

(function() {
  angular.module('nb.directives', []);

  angular.module('nb.component', []);

}).call(this);

(function() {
  var mixOf, nb, resetForm,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  mixOf = function() {
    var Mixed, base, method, mixin, mixins, name, _i, _ref;
    base = arguments[0], mixins = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    Mixed = (function(_super) {
      __extends(Mixed, _super);

      function Mixed() {
        return Mixed.__super__.constructor.apply(this, arguments);
      }

      return Mixed;

    })(base);
    for (_i = mixins.length - 1; _i >= 0; _i += -1) {
      mixin = mixins[_i];
      _ref = mixin.prototype;
      for (name in _ref) {
        method = _ref[name];
        Mixed.prototype[name] = method;
      }
    }
    return Mixed;
  };

  resetForm = function() {
    var form, forms, _i, _len;
    forms = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    for (_i = 0, _len = forms.length; _i < _len; _i++) {
      form = forms[_i];
      form.$setPristine();
      form.$setUntouched();
    }
  };

  nb = this.nb;

  nb.mixOf = mixOf;

  nb.resetForm = resetForm;

}).call(this);

(function() {
  var App, DateRangeDirective, NumberRangeDirective, finderDirective, forEach, isDefined, nb;

  nb = this.nb;

  App = nb.app;

  forEach = angular.forEach;

  isDefined = angular.isDefined;

  finderDirective = function($log) {
    var Condition, FinderController, postLink;
    Condition = (function() {
      function Condition(_primary, name, filter) {
        this.filter = filter;
        this['key'] = _primary;
        this['name'] = name;
      }

      Condition.prototype.$get = function(key) {
        if (this[key] != null) {
          return this[key];
        }
      };

      Condition.prototype.$id = function() {
        return this.key;
      };

      Condition.prototype.$param = function() {
        return this.filter.$param();
      };

      return Condition;

    })();
    FinderController = (function() {
      FinderController.$inject = ['$scope', '$log', '$attrs'];

      function FinderController(scope, log, attr) {
        this.scope = scope;
        this.log = log;
        this.attr = attr;
        this.log.debug('finder initialized', arguments);
        this.filters = [];
        this.conditions = [];
        this.initialize();
      }

      FinderController.prototype.$$event = 'data:search';

      FinderController.prototype.initialize = function() {};

      FinderController.prototype.select = function(condition) {};

      FinderController.prototype.remove = function(condition) {};

      FinderController.prototype.addFilter = function(name, _primary, ctx) {
        var condition;
        condition = new Condition(name, _primary, ctx);
        return this.conditions.push(condition);
      };

      FinderController.prototype.$param = function() {
        var condition, param, _fn, _i, _len, _ref;
        param = {};
        _ref = this.conditions;
        _fn = function(condition) {
          var key;
          key = condition.$id();
          return param[key] = condition.$param();
        };
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          condition = _ref[_i];
          _fn(condition);
        }
        this.log.debug('finder: ', param);
        return param;
      };

      FinderController.prototype.$search = function() {
        var eventName, param;
        param = this.$param();
        eventName = this.attr.finderEvent ? "" + this.attr.finderEvent + ":search" : 'data:search';
        return this.scope.$emit('data:search', param);
      };

      return FinderController;

    })();
    postLink = function(scope, $el, attr, $finder) {
      return $log.debug(arguments);
    };
    return {
      templateUrl: 'partials/personnel/finder.html',
      transclude: true,
      replace: true,
      scope: true,
      controller: FinderController,
      controllerAs: 'ctrl',
      link: postLink
    };
  };

  App.directive('finder', ['$log', finderDirective]);

  NumberRangeDirective = function(log) {
    var postLink;
    postLink = function(scope, $el, attrs, $finder) {
      var $param, displayName, fromEl, inputs, key, options, toEl;
      log.debug(arguments);
      $param = function() {
        var param;
        param = {
          from: $(fromEl).val(),
          to: $(toEl).val()
        };
        log.debug('numberRange:', param);
        return param;
      };
      options = {};
      scope.$param = $param;
      forEach(['name', 'displayName'], function(key) {
        if (isDefined[attrs[key]]) {
          return options[key] = attrs[key];
        }
      });
      key = attrs['name'];
      displayName = attrs['displayName'];
      scope.displayName = displayName;
      scope.status = {
        isopen: false
      };
      $finder.addFilter(key, displayName, scope);
      inputs = $el.find('input');
      fromEl = inputs[0];
      toEl = inputs[1];
      return scope.$on('destory', function() {
        toEl = null;
        fromEl = null;
        return inputs = null;
      });
    };
    return {
      templateUrl: 'partials/personnel/numberRange.html',
      require: '^finder',
      link: postLink
    };
  };

  DateRangeDirective = function(log) {
    var link;
    link = function($scope, $el, $attrs, $model) {
      log.debug($attrs);
      return console.log(123);
    };
    return {
      link: link
    };
  };

  App.directive('numberRange', ['$log', NumberRangeDirective]);

}).call(this);

(function() {
  var EnumService, app, enums;

  app = this.nb.app;

  enums = {};

  EnumService = (function() {
    EnumService.$inject = ['$http', 'inflector'];

    function EnumService(http, inflector) {
      this.http = http;
      this.inflector = inflector;
    }

    EnumService.prototype.loadEnum = function() {
      var http, inflector, self;
      http = this.http;
      inflector = this.inflector;
      self = this;
      return function(key) {
        var onSuccess, promise;
        if (enums[key]) {
          delete enums[key];
        }
        onSuccess = function(res, status) {
          return enums[key] = _.map(res.data.result, function(item) {
            return _.reduce(item, function(res, val, key) {
              res[inflector.camelize(key)] = val;
              return res;
            }, {});
          });
        };
        return promise = http.get("/api/enum?key=" + key).then(onSuccess.bind(self));
      };
    };

    EnumService.prototype.get = function() {
      return enums;
    };

    return EnumService;

  })();

  app.service('$enum', EnumService);

}).call(this);

(function() {
  var EventsProvider, EventsService, app, nb,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  nb = this.nb;

  app = nb.app;

  EventsService = (function(_super) {
    var forEach;

    __extends(EventsService, _super);

    forEach = angular.forEach;

    function EventsService(rootScope, q) {
      this.rootScope = rootScope;
      this.q = q;
    }

    EventsService.prototype.$send = function(eventName, params, scope) {
      var events, message;
      if (scope == null) {
        scope = this.rootScope;
      }
      events = eventName.split(':');
      if (events.length === 3) {
        if (!params || angular.isString(params)) {
          message = params;
        } else {
          message = params.message;
        }
        this.rootScope.$emit(_.last(events), message);
      }
      return scope.$emit(eventName, params);
    };

    EventsService.prototype.$on = function(events, callback, scope) {
      events = [].concat(events);
      if (!scope && this.constructor.name === 'Scope') {
        scope = this;
      } else {
        throw new Error('conext scope is required');
      }
      return forEach(events, function(eventName) {
        return scope.$onRootScope(eventName, callback);
      });
    };

    return EventsService;

  })(nb.Service);

  EventsProvider = (function() {
    function EventsProvider() {}

    EventsProvider.prototype.$get = function($rootScope, $q) {
      var service;
      service = new EventsService($rootScope, $q);
      return service;
    };

    EventsProvider.prototype.$get.$inject = ['$rootScope', '$q'];

    return EventsProvider;

  })();

  app.provider("$nbEvent", EventsProvider);

}).call(this);

(function() {
  var UrlsService, format, module, nb, urls,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  nb = this.nb;

  urls = {
    'home': '/',
    'login': '/login',
    'not-found': '/not-found',
    'permission-denied': '/permission-denied'
  };

  format = function(fmt, obj) {
    obj = _.clone(obj);
    return fmt.replace(/%s/g, function(match) {
      return String(obj.shift());
    });
  };

  UrlsService = (function(_super) {
    __extends(UrlsService, _super);

    UrlsService.$inject = ['$config'];

    function UrlsService(config) {
      this.config = config;
      this.urls = urls;
    }

    UrlsService.prototype.update = function(urls) {
      return this.urls = _.merge(this.urls, urls);
    };

    UrlsService.prototype.reslove = function() {
      var args, name, url;
      args = _.toArray(arguments);
      if (args.length === 0) {
        throw Error("wrong arguments to setUrls");
      }
      name = args.slice(0, 1)[0];
      url = format(this.urls[name], args.slice(1));
      return format("%s/%s", [_.str.rtrim(this.mainUrl, "/"), _.str.ltrim(url, "/")]);
    };

    return UrlsService;

  })(nb.Service);

  module = this.nb.app;

  module.service('$urls', UrlsService);

}).call(this);

(function() {
  angular.module('nb.directives').directive('navToggleActive', [
    function() {
      return {
        scope: {},
        restrict: 'A',
        link: function(scope, elem, attr) {
          return elem.on('click', '.auto', function(event) {
            event.preventDefault();
            return elem.toggleClass('active');
          });
        }
      };
    }
  ]).directive('dragOn', [
    '$window', function($window) {
      var postLink;
      postLink = function(scope, elem, attrs) {
        if (!jQuery.fn.dragOn) {
          return;
        }
        $window.dragOnElem = elem.dragOn();
        return scope.$on('destroy', function() {
          return elem.trigger('DragOn.remove');
        });
      };
      return {
        link: postLink
      };
    }
  ]).directive('loadingBtn', [
    '$timeout', function($timeout) {
      var postLink;
      postLink = function(scope, elem, attrs, $ctrl, $transcludeFn) {
        var disableDataLoading;
        scope.clz = attrs["class"];
        scope.loadingType = attrs.btnLoadingType || 'slide-up';
        scope.dataLoading = false;
        scope.content = attrs.btnText;
        disableDataLoading = function() {
          return scope.$apply(function() {
            return scope.dataLoading = false;
          });
        };
        elem.on('click', function() {
          return scope.$apply(function() {
            return scope.dataLoading = true;
          });
        });
        scope.$on('data:loaded', function() {
          return scope.$apply(function() {
            return scope.dataLoading = false;
          });
        });
        return scope.$on('$destroy', function() {
          return elem.off('click');
        });
      };
      return {
        templateUrl: 'partials/component/loading-btn/btn.html',
        scope: true,
        link: postLink
      };
    }
  ]).directive('nbLoading', [
    '$rootScope', function(rootScope) {
      var postLink;
      postLink = function(scope, elem, attrs) {};
      return {
        templateUrl: 'partials/component/loading.html',
        link: postLink
      };
    }
  ]).directive('nbButterbar', [
    '$rootScope', '$anchorScroll', function(rootScope, anchorScroll) {
      var postLink;
      postLink = function(scope, elem, attrs) {
        elem.addClass('butterbar hide');
        rootScope.$on('$stateChangeStart', function(evt) {
          anchorScroll();
          return elem.removeClass('hide').addClass('active');
        });
        return rootScope.$on('$stateChangeSuccess', function(evt) {
          return evt.targetScope.$watch('$viewContentLoaded', function() {
            return elem.addClass('hide').removeClass('active');
          });
        });
      };
      return {
        template: '<span class="bar"></span>',
        link: postLink
      };
    }
  ]).directive('nbResponsiveHeight', [
    '$window', function($window) {
      var postLink;
      postLink = function(scope, elem, attrs) {
        var height;
        height = $window.innerHeight - elem.position().top;
        return elem.css({
          'height': "" + height + "px"
        });
      };
      return {
        link: postLink
      };
    }
  ]).directive('nbDialog', [
    'ngDialog', function(ngDialog) {
      var postLink;
      postLink = function(scope, elem, attrs) {
        return elem.on('click', function(e) {
          var data, defaults, dialogScope;
          e.preventDefault();
          dialogScope = angular.isDefined(scope.nbDialogScope)? scope.nbDialogScope : scope.$parent;
          angular.isDefined(attrs.nbDialogClosePrevious) && ngDialog.close(attrs.nbDialogClosePrevious);
          defaults = ngDialog.getDefaults();
          data = scope.nbDialogData;
          if (attrs.prepareData) {
            data = scope.prepareData();
          }
          return ngDialog.open({
            template: attrs.nbDialog,
            className: attrs.nbDialogClass || defaults.className,
            controller: attrs.nbDialogController,
            scope: dialogScope,
            data: data
          });
        });
      };
      return {
        restrict: 'A',
        scope: {
          nbDialogScope: '=',
          prepareData: '&?',
          nbDialogData: '='
        },
        link: postLink
      };
    }
  ]).directive('scrollCenter', function() {
    var postLink;
    return postLink = function(scope, elem, attrs) {
      var scrollCenter;
      scrollCenter = function() {
        var svgWidth, width;
        width = elem.width();
        svgWidth = elem.find('svg').width();
        return elem.scrollLeft((svgWidth - width) / 2);
      };
      elem.on('resize', scrollCenter);
      return scope.$on('$destroy', function() {
        return elem.off('resize', scrollCenter);
      });
    };
  }).directive('radioBox', [
    function() {
      var postLink;
      postLink = function(scope, elem, attrs, ctrl) {
        scope.selected = null;
        scope.$watch('pass', function(newVal) {
          if (newVal) {
            scope.selected = "2";
            scope.fail = false;
          }
          if (!(scope.pass || scope.fail)) {
            return scope.selected = "1";
          }
        });
        return scope.$watch('fail', function(newVal) {
          if (newVal) {
            scope.selected = "3";
            scope.pass = false;
          }
          if (!(scope.pass || scope.fail)) {
            return scope.selected = "1";
          }
        });
      };
      return {
        restrict: 'A',
        link: postLink,
        template: '<div>\n    <input type="checkbox" ng-model="pass"/>\n    <label>通过</label>\n    <input type="checkbox" ng-model="fail"/>\n    <label>不通过</label>\n</div>',
        require: 'ngModel',
        scope: {
          selected: "=ngModel"
        },
        replace: true
      };
    }
  ]);

}).call(this);

(function() {
  var SimpleDropdownCtrl;

  angular.module('nb.directives').directive('nbDropdown', [
    '$http', 'inflector', '$document', function($http, inflector, $doc) {
      var DropdownCtrl, getMappedAttr, parseMappedAttr, postLink;
      parseMappedAttr = function(mapped) {
        var attr, prefixIndex, splited;
        prefixIndex = mapped.indexOf('$item.');
        if (prefixIndex !== 0) {
          throw Error("map属性格式不正确, '必须符合 $item.xx.xx 格式'");
        }
        attr = mapped.slice(6);
        return splited = attr.split('.');
      };
      getMappedAttr = function(mappedArr, selectedItem) {
        var attr;
        return attr = mappedArr.reduce(function(res, value) {
          return res[value];
        }, selectedItem);
      };
      DropdownCtrl = (function() {
        DropdownCtrl.$inject = ['$http', '$attrs', '$scope'];

        function DropdownCtrl(http, attrs, scope) {
          var mapped, onSuccess, self;
          this.http = http;
          this.attrs = attrs;
          this.scope = scope;
          self = this;
          this.scope.isOpen = false;
          this.options = [];
          if (this.attrs.map) {
            this.mapped = mapped = parseMappedAttr(this.attrs.map);
          }
          onSuccess = function(data, status) {
            this.options = _.map(data.result, function(item) {
              return _.reduce(item, function(res, val, key) {
                res[inflector.camelize(key)] = val;
                return res;
              }, {});
            });
            if (scope.selected && attrs['map']) {
              return scope.item = _.find(this.options, function(opt) {
                return getMappedAttr(mapped, opt) === scope.selected;
              });
            }
          };
          if (scope.options) {
            this.options = scope.options;
          } else if (attrs.remoteKey) {
            this.http.get("/api/enum?key=" + this.attrs.remoteKey).success(onSuccess.bind(this));
          } else {
            throw new Error('dropdown need options');
          }
        }

        DropdownCtrl.prototype.setSelected = function($index) {
          var selected;
          selected = this.attrs.preventClone ? this.options[$index] : _.clone(this.options[$index]);
          this.scope.item = selected;
          this.scope.selected = this.mapped ? getMappedAttr(this.mapped, selected) : selected;
          return this.close();
        };

        DropdownCtrl.prototype.toggle = function() {
          this.isOpen = !this.isOpen;
          if (this.ngModelCtrl.$pristine) {
            return this.ngModelCtrl.$setDirty();
          }
        };

        DropdownCtrl.prototype.close = function() {
          return this.isOpen = false;
        };

        return DropdownCtrl;

      })();
      postLink = function(scope, elem, attr, $ctrl) {
        var closeDropdown, dropdownCtrl, ngModelCtrl;
        scope.isOpen = false;
        dropdownCtrl = $ctrl[0];
        ngModelCtrl = $ctrl[1];
        dropdownCtrl.ngModelCtrl = ngModelCtrl;
        elem.on('click', function(e) {
          return e.stopPropagation();
        });
        closeDropdown = function(e) {
          e.stopPropagation();
          return scope.$apply(function() {
            dropdownCtrl.toggle();
          });
        };
        scope.$watch(function() {
          return dropdownCtrl.isOpen;
        }, function(newValue, oldValue) {
          if (newValue === true) {
            return $doc.on('click', closeDropdown);
          } else {
            return $doc.off('click', closeDropdown);
          }
        });
        return scope.$on('$destroy', function() {
          elem.off('click');
          return $doc.off('click', closeDropdown);
        });
      };
      return {
        restrict: 'EA',
        templateUrl: 'partials/common/dropdown.tpl.html',
        require: ["nbDropdown", "ngModel"],
        scope: {
          options: "=nbDropdown",
          selected: "=ngModel"
        },
        controller: DropdownCtrl,
        controllerAs: 'dropdown',
        link: postLink
      };
    }
  ]).directive('simpleDropdown', [
    '$document', function($doc) {
      var postLink;
      postLink = function(scope, elem, attr) {
        var closeDropdown;
        closeDropdown = function(e) {
          e.stopPropagation();
          scope.$apply(function() {
            return scope.isOpen = false;
          });
        };
        elem.on('click', function(e) {
          if (e.target.nodeName === "BUTTON") {
            return e.stopPropagation();
          }
        });
        $doc.on('click', closeDropdown);
        return scope.$on('$destroy', function() {
          $doc.off('click', closeDropdown);
          return elem.off('click');
        });
      };
      return {
        restrict: 'EA',
        replace: true,
        scope: {},
        transclude: true,
        template: '<div class="dropdown", ng-class="{\'open\': isOpen}">\n  <md-button ng-click="dropdown.toggle()" class="skyblue  md-raised dropdown-toggle" type="button" data-toggle="dropdown" aria-expanded="true">\n    {{btnText}}\n    <span class="caret"></span>\n  </md-button>\n  <ul class="dropdown-menu" ng-if="isOpen" role="menu" aria-labelledby="dropdownMenu1" ng-transclude>\n  </ul>\n</div>',
        controller: SimpleDropdownCtrl,
        controllerAs: 'dropdown',
        link: postLink
      };
    }
  ]);

  SimpleDropdownCtrl = (function() {
    SimpleDropdownCtrl.$inject = ['$scope', '$attrs'];

    function SimpleDropdownCtrl(scope, attrs) {
      this.scope = scope;
      this.attrs = attrs;
      this.scope.isOpen = false;
      if (this.attrs.btnText) {
        this.scope.btnText = this.attrs.btnText;
      } else {
        throw Error("btn-text attribute is required");
      }
    }

    SimpleDropdownCtrl.prototype.toggle = function() {
      return this.scope.isOpen = !this.scope.isOpen;
    };

    return SimpleDropdownCtrl;

  })();

}).call(this);

(function() {
  angular.module('nb.directives').directive('nbPopupTransclude', [
    function() {
      var postLink;
      postLink = function(scope, elem, attrs, $ctrl, $transcludeFn) {
        return $transcludeFn(function(clone) {
          var templateBlock;
          templateBlock = clone.filter('popup-template');
          return elem.parent().parent().after(templateBlock);
        });
      };
      return {
        restrict: 'AE',
        link: postLink
      };
    }
  ]).directive('nbPopupEmbedTransclude', [
    function() {
      var EmbedTransclude, postLink;
      EmbedTransclude = (function() {
        function EmbedTransclude() {}

        return EmbedTransclude;

      })();
      postLink = function(scope, elem, attrs, $ctrl, $transcludeFn) {
        return $transcludeFn(function(clone) {
          return elem.replaceWith(clone.not('popup-template'));
        });
      };
      return {
        restrict: 'EA',
        link: postLink
      };
    }
  ]).directive('nbPopupPlusEmbedTransclude', [
    function() {
      var EmbedTransclude, postLink;
      EmbedTransclude = (function() {
        function EmbedTransclude() {}

        return EmbedTransclude;

      })();
      postLink = function(scope, elem, attrs, $ctrl, $transcludeFn) {
        return $transcludeFn(function(clone) {
          return elem.replaceWith(clone.not('popup-template'));
        });
      };
      return {
        restrict: 'EA',
        link: postLink
      };
    }
  ]).directive('nbPopup', [
    '$window', function($window) {
      var PopupController, postLink;
      PopupController = (function() {
        PopupController.$inject = ['$scope', '$element', '$transclude'];

        function PopupController($scope, $elem, $transcludeFn) {
          this.$scope = $scope;
        }

        return PopupController;

      })();
      postLink = function(scope, elem, attrs, $ctrl, $transcludeFn) {
        var $doc, calcPosition, getPosition, hide, hideHandle, options, show, tipElement, toggle;
        $doc = angular.element($window.document);
        scope.isShown = false;
        tipElement = elem.next();
        tipElement.append('<span class="arrow"></span>');
        tipElement.css({
          'z-index': '1040',
          'background-color': '#fff',
          position: 'absolute'
        });
        options = {
          scope: scope
        };
        options.position = "left";
        options.space = 12;
        angular.forEach(['position', 'space'], function(key) {
          if (angular.isDefined(attrs[key])) {
            return options[key] = attrs[key];
          }
        });
        tipElement.addClass(options.position);
        toggle = function() {
          if (scope.isShown) {
            return hide();
          } else {
            return show();
          }
        };
        show = function() {
          var position;
          tipElement.show();
          position = calcPosition(elem);
          tipElement.css({
            top: position.top + 'px',
            left: position.left + 'px'
          });
          $doc.on('click', hideHandle);
          return scope.isShown = true;
        };
        hide = function() {
          tipElement.hide();
          scope.isShown = false;
          return $doc.off('click', hideHandle);
        };
        getPosition = function(element) {
          return {
            left: element.position().left,
            top: element.position().top
          };
        };
        calcPosition = function(element) {
          var elemHeight, elemPosition, elemWidth, tipHeight, tipWidth;
          elemWidth = element.outerWidth();
          elemHeight = element.outerHeight();
          elemPosition = {
            left: element[0].offsetLeft,
            top: element[0].offsetTop
          };
          tipWidth = tipElement.outerWidth();
          tipHeight = tipElement.outerHeight();
          if (options.position === "bottom") {
            return {
              top: elemPosition.top + elemHeight + options.space,
              left: elemPosition.left + elemWidth / 2 - tipWidth / 2
            };
          } else if (options.position === "top") {
            return {
              top: elemPosition.top - options.space - tipHeight,
              left: elemPosition.left + elemWidth / 2 - tipWidth / 2
            };
          } else if (options.position === "left") {
            return {
              top: elemPosition.top + elemHeight / 2 - tipHeight / 2,
              left: elemPosition.left - tipWidth - options.space
            };
          } else if (options.position === "right") {
            return {
              top: elemPosition.top + elemHeight / 2 - tipHeight / 2,
              left: elemPosition.left + elemWidth + options.space
            };
          } else {
            throw Error('position only support left, right, bottom, top!');
          }
        };
        hideHandle = function(e) {
          e.stopPropagation();
          hide();
        };
        hide();
        elem.on('click', function(e) {
          e.stopPropagation();
          return toggle();
        });
        return scope.$on('$destroy', function() {
          $doc.off('click', hideHandle);
          elem.off('click');
          return tipElement = null;
        });
      };
      return {
        transclude: true,
        controller: PopupController,
        templateUrl: 'partials/common/popup.html',
        link: postLink
      };
    }
  ]).directive('nbPopupPlus', [
    '$window', function($window) {
      var PopupPlusController, postLink;
      PopupPlusController = (function() {
        PopupPlusController.$inject = ['$scope', '$element', '$transclude'];

        function PopupPlusController(scope, $elem, $transcludeFn) {
          this.scope = scope;
        }

        PopupPlusController.prototype.hide = function() {
          return this.scope.isShown = false;
        };

        return PopupPlusController;

      })();
      postLink = function(scope, elem, attrs, $ctrl) {
        var $doc, arrow, calcPosition, closeEles, hide, hideHandle, options, show, tipElement, toggle;
        $doc = angular.element($window.document);
        scope.isShown = false;
        tipElement = elem.next();
        tipElement.append('<span class="arrow"></span>');
        arrow = tipElement.find(".arrow");
        tipElement.css({
          'z-index': '1040',
          'background-color': '#fff',
          position: 'absolute'
        });
        options = {
          scope: scope
        };
        options.offset = 0.5;
        options.space = 12;
        options.border = 1;
        options.arrowBorder = 11;
        angular.forEach(['position', 'space', 'offset'], function(key) {
          if (angular.isDefined(attrs[key])) {
            return options[key] = attrs[key];
          }
        });
        tipElement.addClass(options.position.split("-")[0]);
        toggle = function() {
          if (scope.isShown) {
            return hide();
          } else {
            return show();
          }
        };
        show = function() {
          var position;
          if ($ctrl) {
            $ctrl.showPopup(tipElement);
          }
          tipElement.show();
          position = calcPosition(elem);
          tipElement.css({
            top: position.pTip.top + 'px',
            left: position.pTip.left + 'px'
          });
          arrow.css({
            top: position.pArrow.top + 'px',
            left: position.pArrow.left + 'px'
          });
          scope.isShown = true;
          return $doc.on('click', hideHandle);
        };
        hide = function() {
          tipElement.hide();
          scope.isShown = false;
          return $doc.off('click', hideHandle);
        };
        calcPosition = function(element) {
          var elemHeight, elemPosition, elemWidth, pArrow, pTip, tipHeight, tipWidth;
          elemWidth = element.outerWidth();
          elemHeight = element.outerHeight();
          elemPosition = element.position();
          tipWidth = tipElement.outerWidth();
          tipHeight = tipElement.outerHeight();
          pTip = {};
          pArrow = {};
          switch (options.position) {
            case 'left-bottom':
              pTip = {
                top: elemPosition.top - tipHeight * options.offset + elemHeight / 2,
                left: elemPosition.left - options.space - tipWidth
              };
              pArrow = {
                top: tipHeight * options.offset,
                left: tipWidth - 2 * options.border
              };
              break;
            case 'right-bottom':
              pTip = {
                top: elemPosition.top - tipHeight * options.offset + elemHeight / 2,
                left: elemPosition.left + elemWidth + options.space
              };
              pArrow = {
                top: tipHeight * options.offset,
                left: -options.arrowBorder
              };
              break;
            case 'left-top':
              pTip = {
                top: elemPosition.top - tipHeight * (1 - options.offset) + elemHeight / 2,
                left: elemPosition.left - options.space - tipWidth
              };
              pArrow = {
                top: tipHeight * (1 - options.offset),
                left: tipWidth - 2 * options.border
              };
              break;
            case 'right-top':
              pTip = {
                top: elemPosition.top - tipHeight * (1 - options.offset) + elemHeight / 2,
                left: elemPosition.left + elemWidth + options.space
              };
              pArrow = {
                top: tipHeight * (1 - options.offset),
                left: -options.arrowBorder
              };
              break;
            case 'top-right':
              pTip = {
                top: elemPosition.top - tipHeight - options.space,
                left: elemPosition.left - tipWidth * options.offset + elemWidth / 2
              };
              pArrow = {
                top: tipHeight - 2 * options.border,
                left: tipWidth * options.offset
              };
              break;
            case 'top-left':
              pTip = {
                top: elemPosition.top - tipHeight - options.space,
                left: elemPosition.left - tipWidth * (1 - options.offset) + elemWidth / 2
              };
              pArrow = {
                top: tipHeight - 2 * options.border,
                left: tipWidth * (1 - options.offset)
              };
              break;
            case 'bottom-left':
              pTip = {
                top: elemPosition.top + elemHeight + options.space,
                left: elemPosition.left - tipWidth * (1 - options.offset) + elemWidth / 2
              };
              pArrow = {
                top: -options.arrowBorder + options.border,
                left: tipWidth * (1 - options.offset)
              };
              break;
            case 'bottom-right':
              pTip = {
                top: elemPosition.top + elemHeight + options.space,
                left: elemPosition.left - tipWidth * options.offset + elemWidth / 2
              };
              pArrow = {
                top: -options.arrowBorder + options.border,
                left: tipWidth * options.offset
              };
              break;
            default:
              throw Error("only left-top,left-bottom,right-bottom,right-top,top-left,top-right,bottom-left,bottom-right is accepted.");
          }
          return {
            pTip: pTip,
            pArrow: pArrow
          };
        };
        hideHandle = function(e) {
          e.stopPropagation();
          hide();
        };
        hide();
        elem.on('click', function(e) {
          e.stopPropagation();
          return toggle();
        });
        tipElement.on('click', function(e) {
          return e.stopPropagation();
        });
        closeEles = tipElement.find('[popup-close]');
        closeEles.on('click', function(e) {
          e.stopPropagation();
          hide();
        });
        scope.$watch('isShown', function(newVal) {
          if (!newVal) {
            return hide();
          }
        });
        return scope.$on('$destroy', function() {
          $doc.off('click', hideHandle);
          elem.off('click');
          closeEles.off('click');
          tipElement.off('click');
          return tipElement = null;
        });
      };
      return {
        transclude: true,
        controller: PopupPlusController,
        templateUrl: 'partials/common/popup.html',
        link: postLink,
        require: '^?nbPopupManagement'
      };
    }
  ]).directive('nbPopupManagement', [
    function() {
      var ManmageCtrl;
      ManmageCtrl = (function() {
        ManmageCtrl.$inject = ['$scope'];

        function ManmageCtrl(scope) {
          this.scope = scope;
          this.showEle = null;
        }

        ManmageCtrl.prototype.showPopup = function(popup) {
          if (this.showEle) {
            this.showEle.hide();
          }
          return this.showEle = popup;
        };

        return ManmageCtrl;

      })();
      return {
        restrict: 'AE',
        controller: ManmageCtrl
      };
    }
  ]);

}).call(this);

(function() {
  angular.module('nb.directives').constant('simditorConfig', {
    textarea: null,
    upload: true,
    toolbar: ['title', 'bold', 'italic', 'underline', 'strikethrough', 'ol', 'ul', 'blockquote', 'code', 'table', 'link', 'image', 'hr', 'indent', 'outdent'],
    tabIndent: true,
    toolbarFloat: true,
    pasteImage: false
  }).directive('simditor', [
    '$timeout', 'simditorConfig', function($timeout, defaultConfig) {
      return {
        restrict: 'A',
        replace: true,
        require: 'ngModel',
        scope: {
          textVal: '=ngModel',
          toolbar: '='
        },
        link: function(scope, elem, attrs, ctrl) {
          var customOpt, editor, onValueChanged, opts;
          customOpt = {};
          if (scope.toolbar) {
            customOpt.toolbar = scope.toolbar;
          }
          opts = angular.extend({}, defaultConfig, customOpt, {
            textarea: elem
          });
          onValueChanged = _.throttle(function() {
            return ctrl.$setViewValue(editor.getValue());
          }, 2000);
          editor = new Simditor(opts);
          editor.on('valuechanged', onValueChanged);
          ctrl.$render = function() {
            return editor.setValue(ctrl.$modelValue);
          };
          scope.$watch('editable', function(newVal, old) {
            if (newVal === false) {
              return editor.body.attr('contenteditable', false);
            }
          });
          return scope.$on('$destroy', function() {
            return editor.destroy();
          });
        }
      };
    }
  ]).directive('nbSimditor', [
    'simditorConfig', function(defaultConfig) {
      return {
        restrict: 'A',
        require: 'ngModel',
        replace: true,
        templateUrl: 'partials/common/nb_simditor.tpl.html',
        scope: {
          editing: '=?editing',
          modelVal: '=ngModel',
          toolbar: '='
        },
        link: function(scope, elem, attrs, ctrl) {
          var createEditor, customOpt, editor;
          customOpt = {};
          editor = null;
          createEditor = function() {
            var onValueChanged, opts, textarea;
            textarea = elem.find("textarea");
            if (scope.toolbar) {
              customOpt.toolbar = scope.toolbar;
            }
            opts = angular.extend({}, defaultConfig, customOpt, {
              textarea: textarea
            });
            onValueChanged = _.throttle(function() {
              return ctrl.$setViewValue(editor.getValue());
            }, 2000);
            editor = new Simditor(opts);
            editor.on('valuechanged', onValueChanged);
            editor.setValue(ctrl.$modelValue);
            return editor;
          };
          scope.$watch('editable', function(newVal, old) {
            if (newVal === false) {
              return editor.body.attr('contenteditable', false);
            }
          });
          if (angular.isUndefined(scope.editing)) {
            editor = createEditor();
          } else {
            scope.$watch('editing', function(newVal) {
              if (newVal) {
                return editor = createEditor();
              } else {
                if (editor) {
                  return editor.destroy();
                }
              }
            });
          }
          return scope.$on('$destroy', function() {
            if (editor) {
              return editor.destroy();
            }
          });
        }
      };
    }
  ]);

}).call(this);

(function() {
  angular.module('nb.directives').constant('slimscrollConfig', {
    allowPageScroll: true,
    size: '7px',
    color: '#bbb',
    railColor: '#eaeaea',
    position: 'right',
    height: '250px',
    alwaysVisible: false,
    railVisible: false,
    disableFadeOut: true
  }).directive('slimscroll', [
    'slimscrollConfig', function(slimscrollConfig) {
      return {
        restrict: 'A',
        replace: true,
        link: function(scope, elem, attr) {
          var opts;
          opts = {};
          angular.forEach(['height', 'wrapperClass', 'railColor', 'position'], function(key) {
            if (angular.isDefined(attr[key])) {
              return opts[key] = attr[key];
            }
          });
          opts = angular.extend({}, slimscrollConfig, opts);
          elem.slimScroll(opts);
          return scope.$on('$destroy', function() {
            return elem.slimscroll({
              destroy: true
            });
          });
        }
      };
    }
  ]);

}).call(this);

(function() {
  angular.module('nb.directives').provider('nbTooltip', [
    function() {
      var defaultOptions;
      defaultOptions = {
        template: "",
        title: "",
        content: "",
        container: "",
        html: true,
        animation: "",
        customClass: "",
        autoClose: true,
        position: "right"
      };
      this.$get = [
        '$window', '$rootScope', '$compile', '$q', '$templateCache', '$http', '$timeout', function($window, $rootScope, $compile, $q, $templateCache, $http, $timeout) {
          var $body, fetchTemplate, trim;
          trim = String.prototype.trim;
          $body = angular.element($window.document);
          fetchTemplate = function(templateUrl) {
            return $q.when($templateCache.get(templateUrl) || $http.get(templateUrl)).then(function(res) {
              if (angular.isObject(res)) {
                $templateCache.put(templateUrl, res.data);
                return res.data;
              }
              return res;
            });
          };
          return function(element, config) {
            var calcPosition, getPosition, nbTooltip, options, scope, tipContainer, tipElement, tipLinker, tipTemplate;
            nbTooltip = {};
            options = nbTooltip.$options = angular.extend({}, defaultOptions, config);
            scope = nbTooltip.$scope = options.scope && options.scope.$new() || $rootScope.$new();
            if (options.title) {
              nbTooltip.$scope.title = options.title;
            }
            if (options.content) {
              nbTooltip.$scope.content = options.content;
            }
            nbTooltip.$promise = fetchTemplate(options.template);
            tipLinker = tipElement = tipContainer = tipTemplate = void 0;
            nbTooltip.$promise.then(function(template) {
              if (angular.isObject(template)) {
                template = template.data;
              }
              if (options.html) {
                template = template.replace(/ng-bind="/ig, 'ng-bind-html="');
              }
              template = trim.apply(template);
              tipTemplate = template;
              return tipLinker = $compile(template);
            });
            nbTooltip.init = function() {
              if (options.container === 'self') {
                return tipContainer = element;
              } else if (angular.isElement(options.container)) {
                return tipContainer = options.container;
              } else if (options.container) {
                return tipContainer = findElement(options.container);
              }
            };
            nbTooltip.toggle = function() {
              if (nbTooltip.$isShown) {
                return nbTooltip.hide();
              } else {
                return nbTooltip.show();
              }
            };
            nbTooltip.hide = function() {
              if (!nbTooltip.$isShown) {
                return;
              }
              nbTooltip.$isShown = scope.$isShown = false;
              tipElement.remove();
              if (options.autoClose && tipElement) {
                $body.off('click');
                return tipElement.off('click');
              }
            };
            nbTooltip.show = function() {
              var after, parent, position;
              parent = options.container ? tipContainer : null;
              after = options.container ? null : element;
              if (tipElement) {
                tipElement.remove();
              }
              tipElement = nbTooltip.$element = tipLinker(scope);
              if (options.animation) {
                tipElement.addClass(options.animation);
              }
              if (options.customClass) {
                tipElement.addClass(options.customClass);
              }
              tipElement.css({
                top: -9999 + 'px',
                left: -99999 + 'px',
                position: 'absolute',
                display: 'block',
                visibility: 'hidden',
                'background-color': '#ff0',
                'z-index': '1000000'
              });
              element.after(tipElement);
              position = calcPosition(element);
              tipElement.css({
                top: position.top + 'px',
                left: position.left + 'px',
                visibility: 'visible'
              });
              nbTooltip.$isShown = scope.$isShown = true;
              if (options.autoClose) {
                return $timeout(function() {
                  tipElement.on('click', function(e) {
                    return event.stopPropagation();
                  });
                  return $body.on('click', function() {
                    if (nbTooltip.$isShown) {
                      return nbTooltip.hide();
                    }
                  });
                }, 0);
              }
            };
            getPosition = function(element) {
              return {
                left: element.position().left,
                top: element.position().top
              };
            };
            calcPosition = function(element) {
              var elemHeight, elemPosition, elemWidth, tipHeight, tipWidth;
              elemWidth = element.outerWidth();
              elemHeight = element.outerHeight();
              elemPosition = getPosition(element);
              tipWidth = tipElement.outerWidth();
              tipHeight = tipElement.outerHeight();
              if (options.position === "bottom") {
                return {
                  top: elemPosition.top + elemHeight + 5,
                  left: elemPosition.left + elemWidth / 2 - tipWidth / 2
                };
              } else if (options.position === "top") {
                return {
                  top: elemPosition.top - 5 - tipHeight,
                  left: elemPosition.left + elemWidth / 2 - tipWidth / 2
                };
              } else if (options.position === "left") {
                return {
                  top: elemPosition.top + elemHeight / 2 - tipHeight / 2,
                  left: elemPosition.left - tipWidth - 5
                };
              } else {
                return {
                  top: elemPosition.top + elemHeight / 2 - tipHeight / 2,
                  left: elemPosition.left + elemWidth + 5
                };
              }
            };
            return nbTooltip;
          };
        }
      ];
    }
  ]);

}).call(this);

(function() {
  var $build, Modal, app, defaultOption, extend, nb;

  nb = this.nb;

  app = nb.app;

  extend = angular.extend;

  Modal = (function() {
    function Modal(dialog, scope, memoName) {
      this.initialize(dialog, scope, memoName);
    }

    Modal.prototype.cancel = function(evt, form) {
      evt.preventDefault();
      if (form) {
        form.$setPristine();
      }
      return this.dialog.dismiss('cancel');
    };

    Modal.prototype.initialize = function(dialog, scope, memoName) {
      var handle, invokerName;
      if (!memoName) {
        throw new Error('memoName is required, cause memo current state');
      }
      scope.ctrl = this;
      invokerName = "" + memoName + "Invoker";
      handle = function($state, $previousState, $rootScope, invokerName, $modalInstance) {
        var isRefresh, unsubscribe;
        if ($state.is("" + memoName)) {
          isRefresh = true;
        }
        $previousState.memo(invokerName);
        $modalInstance.result["finally"](function() {
          if (isRefresh) {
            $previousState.forget(invokerName);
            $state.go('^');
          } else {
            $previousState.go(invokerName);
          }
          return unsubscribe();
        });
        return unsubscribe = $rootScope.$on('$stateChangeStart', function(evt, toState) {
          if (!toState.$$state().includes[memoName]) {
            return $modalInstance.dismiss('close');
          }
        });
      };
      return this.injector.invoke(['$state', '$previousState', '$rootScope', 'invokerName', '$modalInstance', handle], this, {
        invokerName: invokerName,
        $modalInstance: dialog
      });
    };

    return Modal;

  })();

  defaultOption = {
    backdrop: true,
    keyboard: true
  };

  $build = function(routerOptions, modalOptions) {
    var modalOpen;
    modalOptions = extend({}, defaultOption, modalOptions);
    modalOpen = [
      '$modal', function($modal) {
        return $modal.open(modalOptions);
      }
    ];
    routerOptions = extend({}, {
      onEnter: modalOpen
    }, routerOptions);
    return routerOptions;
  };

  nb.$buildDialog = function(options) {
    var memoResolved, modalOptions, routerOptionAttrs, routerOptions;
    routerOptionAttrs = ['name', 'url', 'ncyBreadcrumb'];
    routerOptions = _.pick(options, routerOptionAttrs);
    modalOptions = _.omit(options, routerOptionAttrs);
    memoResolved = {
      resolve: {
        memoName: function() {
          return routerOptions.name;
        }
      }
    };
    modalOptions = extend({}, memoResolved, modalOptions);
    return $build.apply(this, [routerOptions, modalOptions]);
  };

  nb.$buildPanel = function(options) {
    var memoResolved, modalOptions, routerOptionAttrs, routerOptions;
    routerOptionAttrs = ['name', 'url', 'ncyBreadcrumb'];
    routerOptions = _.pick(options, routerOptionAttrs);
    modalOptions = _.omit(options, routerOptionAttrs);
    memoResolved = {
      resolve: {
        memoName: function() {
          return routerOptions.name;
        }
      },
      windowTemplateUrl: 'partials/component/panel/window.html'
    };
    modalOptions = extend({}, memoResolved, modalOptions);
    return $build.apply(this, [routerOptions, modalOptions]);
  };

  nb.Modal = Modal;

}).call(this);

(function() {
  var app, nb;

  nb = this.nb;

  app = nb.app;

  app.provider('$panel', function() {
    var $panelProvider, Provider;
    Provider = function($injector, $rootScope, $q, $http, $templateCache, $controller, $modalStack) {
      var $panel, getResolvePromises, getTemplatePromise;
      $panel = {};
      getTemplatePromise = function(options) {
        var request;
        if (options.template) {
          return $q.when(options.template);
        } else {
          request = angular.isFunction(options.templateUrl) ? options.templateUrl() : options.templateUrl;
          return $http.get(request, {
            cache: $templateCache
          }).then(function(result) {
            if (angular.isString(result)) {
              return result;
            } else {
              return result.data;
            }
          });
        }
      };
      getResolvePromises = function(resolves) {
        var promisesArr;
        promisesArr = [];
        angular.forEach(resolves, function(value) {
          if (angular.isFunction(value) || angular.isArray(value)) {
            return promisesArr.push($q.when($injector.invoke(value)));
          }
        });
        return promisesArr;
      };
      $panel.open = function(panelOptions) {
        var panelInstance, panelOpenedDeferred, panelResultDeferred, templateAndResolvePromise;
        panelResultDeferred = $q.defer();
        panelOpenedDeferred = $q.defer();
        panelInstance = {
          result: panelResultDeferred.promise,
          opened: panelOpenedDeferred.promise,
          close: function(result) {
            return $modalStack.close(panelInstance, result);
          },
          dismiss: function(reason) {
            return $modalStack.dismiss(panelInstance, reason);
          }
        };
        panelOptions = angular.extend({}, $panelProvider.options, panelOptions);
        panelOptions.resolve = panelOptions.resolve || {};
        if (!panelOptions.template && !panelOptions.templateUrl) {
          throw new Error('One of temlate or templateUrl options is required.');
        }
        templateAndResolvePromise = $q.all([getTemplatePromise(panelOptions)].concat(getResolvePromises(panelOptions.resolve)));
        templateAndResolvePromise.then(function(tplAndVars) {
          var ctrlInstance, ctrlLocals, panelScope, resolveIter;
          panelScope = (panelOptions.scope || $rootScope).$new();
          panelScope.$close = panelInstance.close;
          panelScope.$dismiss = panelInstance.dismiss;
          ctrlLocals = {};
          resolveIter = 1;
          if (panelOptions.controller) {
            ctrlLocals.$scope = panelScope;
            ctrlLocals.$panelInstance = panelInstance;
            angular.forEach(panelOptions.resolve, function(value, key) {
              return ctrlLocals[key] = tplAndVars[resolveIter++];
            });
            ctrlInstance = $controller(panelOptions.controller, ctrlLocals);
            if (panelOptions.controllerAs) {
              panelScope[panelOptions.controllerAs] = ctrlInstance;
            }
          }
          $modalStack.open(panelInstance, {
            scope: panelScope,
            deferred: panelResultDeferred,
            content: tplAndVars[0],
            backdrop: panelOptions.backdrop,
            keyboard: panelOptions.keyboard,
            backdropClass: panelOptions.backdropClass,
            windowCalss: panelOptions.windowCalss,
            windowTemplateUrl: 'partials/component/panel/window.html',
            size: panelOptions.size
          });
          templateAndResolvePromise.then(null, function(reason) {
            return panelResultDeferred.reject(reason);
          });
          templateAndResolvePromise.then(function() {
            panelOpenedDeferred.resolve(true);
          }, function() {
            panelOpenedDeferred.reject(false);
          });
        });
        return panelInstance;
      };
      return $panel;
    };
    $panelProvider = {
      options: {
        backdrop: true,
        keyboard: true
      },
      $get: ['$injector', '$rootScope', '$q', '$http', '$templateCache', '$controller', '$modalStack', Provider]
    };
    return $panelProvider;
  });

}).call(this);

(function() {
  var Alert, al, app, extend, nb;

  nb = this.nb;

  app = nb.app;

  al = this.swal;

  extend = this.angular.extend;

  Alert = (function() {
    function Alert(q, timeout) {
      this.q = q;
      this.timeout = timeout;
    }

    Alert.prototype.success = function(title, message) {
      return this.timeout(function() {
        return al(title, message, 'success');
      }, 200);
    };

    Alert.prototype.error = function(title, message) {
      return this.timeout(function() {
        return al(title, message, 'error');
      }, 200);
    };

    Alert.prototype.warning = function(title, message) {
      return this.timeout(function() {
        return al(title, message, 'warning');
      }, 200);
    };

    Alert.prototype.info = function(title, message) {
      return this.timeout(function() {
        return al(title, message, 'info');
      }, 200);
    };

    Alert.prototype.confirm = function(title, message, confirmButtonText, cancelButtonText) {
      var deferred, options;
      if (confirmButtonText == null) {
        confirmButtonText = '确定';
      }
      if (cancelButtonText == null) {
        cancelButtonText = '取消';
      }
      deferred = this.q.defer();
      options = {
        title: title,
        text: message,
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#DD6B55',
        confirmButtonText: confirmButtonText,
        cancelButtonText: cancelButtonText,
        closeOnConfirm: true,
        closeOnCancel: true
      };
      swal(options, function(isConfirm) {
        if (isConfirm) {
          return deferred.resolve(true);
        } else {
          return deferred.reject(false);
        }
      });
      return deferred.promise;
    };

    return Alert;

  })();

  app.factory('sweet', [
    '$q', '$timeout', function($q, $timeout) {
      return new Alert($q, $timeout);
    }
  ]);

  app.directive('nbConfirm', [
    'sweet', function(sweet) {
      var postLink;
      postLink = function(scope, elem, attrs) {
        var callback, title, type;
        title = attrs.nbTitle;
        type = attrs.nbType || 'warning';
        attrs.$observe('nbTitle', function(newValue) {
          return scope.title = newValue;
        });
        attrs.$observe('nbText', function(newValue) {
          return scope.text = newValue;
        });
        callback = function(isConfirm) {
          return scope.callback({
            isConfirm: isConfirm
          });
        };
        elem.on('click', function(e) {
          var promise;
          promise = sweet.confirm(scope.title, scope.text);
          return promise.then(callback)["catch"](scope.onCancel || callback);
        });
        return scope.$on('$destroy', function() {
          return elem.off('click');
        });
      };
      return {
        scope: {
          callback: '&nbConfirm',
          onCancel: '&'
        },
        link: postLink
      };
    }
  ]);

}).call(this);

(function() {
  var TabsetCtrl, com, tabContentTranscludeDirective, tabDirective, tabHeadingTranscludeDirective, tabsetDirective;

  com = angular.module('nb.component');

  TabsetCtrl = (function() {
    TabsetCtrl.$inject = ['$scope'];

    function TabsetCtrl(scope) {
      var self;
      self = this;
      this.tabs = scope.tabs = [];
      this.destroyed = void 0;
      scope.$on('$destroy', function() {
        return self.destroyed;
      });
    }

    TabsetCtrl.prototype.select = function(selectedTab) {
      angular.forEach(this.tabs, function(tab) {
        if (tab.active && tab !== selectedTab) {
          tab.active = false;
          return tab.onDeselect();
        }
      });
      selectedTab.active = true;
      return selectedTab.onSelect();
    };

    TabsetCtrl.prototype.addTab = function(tab) {
      this.tabs.push(tab);
      if (this.tabs.length === 1) {
        return tab.active = true;
      } else if (tab.active) {
        return this.select(tab);
      }
    };

    TabsetCtrl.prototype.removeTab = function(tab) {
      var index, newActiveIndex;
      index = this.tabs.indexOf(tab);
      if (tab.active && this.tabs.length > 1 && this.destroyed) {
        newActiveIndex = index = this.tabs.length - 1 ? index - 1 : index + 1;
        this.select(this.tabs[newActiveIndex]);
      }
      return this.tabs.splice(index, 1);
    };

    return TabsetCtrl;

  })();

  tabsetDirective = function() {
    var postLink;
    postLink = function(scope, elem, attrs) {
      scope.vertical = angular.isDefined(attrs.vertical) ? scope.$parent.$eval(attrs.vertical) : false;
      return scope.justified = angular.isDefined(attrs.justified) ? scope.$parent.$eval(attrs.justified) : false;
    };
    return {
      restrict: 'EA',
      transclude: true,
      replace: true,
      scope: {
        type: '@'
      },
      controller: 'TabsetCtrl',
      templateUrl: 'partials/component/tab/tabset.html'
    };
  };

  tabDirective = function($parse) {
    return {
      require: '^tabset',
      restrict: 'EA',
      replace: true,
      templateUrl: 'partials/component/tab/tab.html',
      transclude: true,
      scope: {
        active: '=?',
        heading: '@',
        onSelect: '&select',
        onDeselect: '&deselect'
      },
      controller: function() {},
      compile: function(elem, attrs, transclude) {
        var postlink;
        postlink = function(scope, elem, attrs, tabsetCtrl) {
          scope.$watch('active', function(active) {
            if (active) {
              return tabsetCtrl.select(scope);
            }
          });
          scope.disabled = false;
          scope.$parent.$watch($parse(attrs.disabled), function(value) {
            return scope.disabled = !!value;
          });
          scope.select = function() {
            if (!scope.disabled) {
              return scope.active = true;
            }
          };
          tabsetCtrl.addTab(scope);
          scope.$on('$destroy', function() {
            return tabsetCtrl.removeTab(scope);
          });
          return scope.$transcludeFn = transclude;
        };
        return postlink;
      }
    };
  };

  tabHeadingTranscludeDirective = function() {
    var postlink;
    postlink = function(scope, elem, attrs, tabCtrl) {
      return scope.$watch('headingElement', function(heading) {
        if (heading) {
          return elem.html('').append(heading);
        }
      });
    };
    return {
      restrict: 'A',
      require: '^tab',
      link: postlink
    };
  };

  tabContentTranscludeDirective = function() {
    var isTabHeading, postlink;
    isTabHeading = function(node) {
      return node.tagName && (node.hasAttribute('tab-heading') || node.hasAttribute('data-tab-heading') || node.tagName.toLowerCase() === 'tab-heading' || node.tagName.toLowerCase() === 'data-tab-heading');
    };
    return postlink = function(scope, elem, attrs) {
      var tab;
      tab = scope.$eval(attrs.tabContentTransclude);
      return tab.$transcludeFn(tab.$parent, function(contents) {
        return angular.forEach(contents, function(node) {
          if (isTabHeading(node)) {
            return tab.headingElement = node;
          } else {
            return elem.append(node);
          }
        });
      });
    };
  };

  com.controller('TabsetCtrl', TabsetCtrl);

  com.directive('tabset', tabsetDirective);

  com.directive('tab', ['$parse', tabDirective]);

  com.directive('tabHeadingTransclude', tabHeadingTranscludeDirective);

  com.directive('tabContentTransclude', tabContentTranscludeDirective);

}).call(this);

(function() {
  var ISO_DATE_REGEXP, NbSearchCtrl, NbTableCtrl, app, filterSelectorDirective, nb, nbConditionContainerDirective, nbPaginationDirective, nbPipeDirective, nbPredicateDirective, nbSearchDirective, nbSelectRowDirective, nbSelectRowDirective2, nbTableDirective;

  nb = this.nb;

  app = nb.app;

  ISO_DATE_REGEXP = /\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d\.\d+([+-][0-2]\d:[0-5]\d|Z)/;

  NbTableCtrl = (function() {
    var copyRefs;

    NbTableCtrl.$inject = ['$scope', '$parse', '$filter', '$attrs'];

    copyRefs = function(src) {
      return src? [].concat(src) : [];
    };

    function NbTableCtrl(scope, $parse, $filter, $attrs) {
      var displayGetter, displaySetter, filter, lastSelected, orderBy, pipeAfterSafaCopy, propertyName, safeCopy, safeGetter, tableState, updateSafeCopy;
      propertyName = $attrs.nbTable;
      displayGetter = $parse(propertyName);
      displaySetter = displayGetter.assign;
      safeGetter = void 0;
      orderBy = $filter('orderBy');
      filter = $filter('filter');
      safeCopy = copyRefs(displayGetter(scope));
      pipeAfterSafaCopy = true;
      lastSelected = null;
      tableState = {
        sort: {},
        predicate: {},
        pagination: {
          page: 1
        }
      };
      updateSafeCopy = function() {
        safeCopy = copyRefs(safeGetter(scope));
        if (pipeAfterSafaCopy === true) {
          return this.pipe();
        }
      };
      if ($attrs.nbSafeSrc) {
        safeGetter = $parse($attrs.nbSafeSrc);
        scope.$watch(function() {
          var safeSrc;
          safeSrc = safeGetter(scope);
          return safeSrc? safeSrc.length : 0;
        }, function(newValue, oldValue) {
          if (newValue !== safeCopy.length) {
            return updateSafeCopy();
          }
        });
        scope.$watchCollection(function() {
          return safeGetter(scope);
        }, function(newValue, oldValue) {
          if (newValue !== oldValue) {
            return updateSafeCopy();
          }
        });
      }
      this.sortBy = function(predicate, reverse) {
        tableState.sort.predicate = predicate;
        tableState.sort.reverse = reverse === true;
        tableState.pagination.start = 0;
        return this.pipe();
      };
      this.search = function() {
        tableState.pagination.page = 1;
        return this.pipe();
      };
      this.pipe = function() {
        var filtered, pagination;
        pagination = tableState.pagination;
        filtered = tableState.search.predicateObject ? filter(safeCopy, tableState.search.predicateObject) : safeCopy;
        if (tableState.sort.predicate) {
          filtered = orderBy(filtered, tableState.sort.predicate, tableState.sort.reverse);
        }
        return displaySetter(scope, filtered);
      };
      this.select = function(row, mode) {
        var index, rows;
        rows = safeCopy;
        index = rows.indexOf(row);
        if (index !== -1) {
          switch (mode) {
            case 'single':
              row.isSelected = row.isSelected !== true;
              if (lastSelected) {
                lastSelected.isSelected = false;
              }
              return lastSelected = row.isSelected === true ? row : void 0;
            case 'multiple':
              return rows[index].isSelected = !rows[index].isSelected;
          }
        }
      };
      this.selectAll = function(isSelected) {
        var rows;
        rows = safeCopy;
        return rows.map(function(row) {
          return row.isSelected = isSelected;
        });
      };
      this.slice = function(page, number) {
        tableState.pagination.page = page;
        tableState.pagination.per_page = number;
        return this.pipe();
      };
      this.getTableState = function() {
        return tableState;
      };
      this.setFilter = function(filterName) {
        return filter = $filter(filterName);
      };
      this.setSort = function(sortFunctionName) {
        return orderBy = $filter(sortFunctionName);
      };
      this.preventPipeOnWatch = function() {
        return pipeAfterSafaCopy = false;
      };
    }

    return NbTableCtrl;

  })();

  nbTableDirective = function() {
    var postLink;
    postLink = function(scope, elem, attrs, ctrl) {
      if (attrs.nbSetFilter) {
        ctrl.setFilter(attrs.nbSetFilter);
      }
      if (attrs.nbSetSort) {
        return ctrl.setSort(attrs.nbSetSort);
      }
    };
    return {
      restrict: 'A',
      controller: NbTableCtrl,
      link: postLink
    };
  };

  nbPipeDirective = function() {
    var preLink;
    preLink = function(scope, elem, attrs, ctrl) {
      if (angular.isFunction(scope.nbPipe)) {
        ctrl.preventPipeOnWatch();
        ctrl.pipe = function() {
          return scope.nbPipe({
            tableState: ctrl.getTableState(),
            tableCtrl: ctrl
          });
        };
      }
      elem.on('click', function() {
        return ctrl.search();
      });
      return scope.$on('$destroy', function() {
        return elem.off('click');
      });
    };
    return {
      require: '^nbTable',
      scope: {
        nbPipe: '&'
      },
      link: {
        pre: preLink
      }
    };
  };

  NbSearchCtrl = (function() {
    NbSearchCtrl.$inject = ['$scope', 'SearchCondition', '$attrs', '$element'];

    function NbSearchCtrl(scope, Filter, attrs) {
      var activePredicates, inactivePredicates, self;
      this.scope = scope;
      this.Filter = Filter;
      this.attrs = attrs;
      self = this;
      this.conditionCode = attrs.nbSearch;
      scope.filters = Filter.$search({
        code: this.conditionCode
      });
      scope.predicateObject = {};
      inactivePredicates = [];
      activePredicates = [];
      this.scope.conditions = this.conditions = [];
      this.predicates = scope.predicates = Object.create({}, {
        asArray: {
          enumerable: false,
          get: function() {
            return _.values(this);
          }
        },
        activePredicates: {
          enumerable: false,
          get: function() {
            return activePredicates;
          }
        },
        inactivePredicates: {
          enumerable: false,
          get: function() {
            return inactivePredicates;
          },
          set: function(newValue) {
            return inactivePredicates.push(newValue);
          }
        },
        startupPredicate: {
          enumerable: false,
          value: function(key) {
            var predicate;
            predicate = key ? _.remove(inactivePredicates, function(pre) {
              return pre.key === key;
            })[0] : inactivePredicates.pop();
            activePredicates.push(predicate);
            return predicate;
          }
        },
        shutdownPredicate: {
          enumerable: false,
          value: function(predicate) {
            var index;
            inactivePredicates.push(predicate);
            index = activePredicates.indexOf(predicate);
            return activePredicates.splice(index, 1);
          }
        },
        switchActivePredicate: {
          enumerable: false,
          value: function(oldValue, newValue) {
            var newIndex, oldIndex;
            oldIndex = activePredicates.indexOf(oldValue);
            newIndex = inactivePredicates.indexOf(newValue);
            activePredicates.splice(oldIndex, 1, newValue);
            return inactivePredicates.splice(newIndex, 1, oldValue);
          }
        },
        addPredicate: {
          enumerable: false,
          value: function(key, displayName, paramGetter, $transcludeFn) {
            Object.defineProperty(this, key, {
              enumerable: true,
              configurable: false,
              value: {
                key: key,
                displayName: displayName,
                getter: paramGetter,
                $transcludeFn: $transcludeFn,
                transclude: function(element, initialData) {
                  var newScope, that;
                  that = this;
                  newScope = scope.$new();
                  if (initialData) {
                    angular.forEach(initialData, (function(v, k) {
                      return newScope[key] = v;
                    }));
                  }
                  return this.$transcludeFn(newScope, function(clone, newScope) {
                    that.block = {
                      element: clone,
                      scope: newScope
                    };
                    element.append(clone);
                    return newScope.$watch(key, function() {
                      return self.updatePredicateObject();
                    }, true);
                  });
                }
              }
            });
            this.inactivePredicates = this[key];
            if (activePredicates.length === 0) {
              return self.addNewCondition();
            }
          }
        },
        select: {
          enumerable: false,
          value: function(option) {}
        }
      });
    }

    NbSearchCtrl.prototype.updatePredicateObject = function() {
      return this.scope.predicateObject = this.conditions.reduce(function(res, cur) {
        var predicate, value;
        predicate = cur.selected;
        value = predicate.getter(predicate.block.scope);
        if (value && !_.str.isBlank(value)) {
          res[predicate.key] = value;
        }
        return res;
      }, {});
    };

    NbSearchCtrl.prototype.switchQueryPredicate = function(old, newValue, element) {
      if (old.block != null) {
        this.$$destroy(old);
      }
      newValue.transclude(element);
      return this.predicates.switchActivePredicate(old, newValue);
    };

    NbSearchCtrl.prototype.initialCondition = function(predicate, element, initialData) {
      return predicate.transclude(element, initialData);
    };

    NbSearchCtrl.prototype.selectFilter = function(filter) {
      var parsedQueryParams, pick, self;
      self = this;
      this.$$clear();
      pick = _.pick;
      parsedQueryParams = this.$$parseFilter(filter.condition);
      return angular.forEach(parsedQueryParams, function(v, key) {
        var initialData, predicate;
        initialData = {};
        initialData[key] = v;
        predicate = self.predicates.startupPredicate(key);
        return self.addCondition(predicate, initialData);
      });
    };

    NbSearchCtrl.prototype.remove = function($index, force) {
      var condition;
      if (force == null) {
        force = false;
      }
      if (!force && this.conditions.length <= 1) {
        return;
      }
      condition = this.conditions[$index];
      this.$$destroyCondition(condition);
      return this.conditions.splice($index, 1);
    };

    NbSearchCtrl.prototype.saveFilter = function(filterName) {
      var promise, request_data;
      request_data = {
        name: filterName,
        code: this.conditionCode,
        condition: JSON.stringify(this.scope.predicateObject)
      };
      return promise = this.scope.filters.$create(request_data);
    };

    NbSearchCtrl.prototype.addPredicate = function(key, displayName, paramGetter, $transcludeFn) {
      return this.predicates.addPredicate(key, displayName, paramGetter, $transcludeFn);
    };

    NbSearchCtrl.prototype.addCondition = function(predicate, initialData) {
      return this.conditions.push({
        selected: predicate,
        initialData: initialData
      });
    };

    NbSearchCtrl.prototype.addNewCondition = function() {
      var predicate;
      predicate = this.predicates.startupPredicate();
      return this.addCondition(predicate);
    };

    NbSearchCtrl.prototype.$$destroyCondition = function(condition) {
      var predicate;
      predicate = condition.selected;
      this.scope.predicateObject = _.omit(this.scope.predicateObject, predicate.key);
      this.$$destroy(predicate);
      return this.predicates.shutdownPredicate(predicate);
    };

    NbSearchCtrl.prototype.$$clear = function() {
      var destroyAll;
      destroyAll = function(v, idx, arr) {
        return this.$$destroyCondition(v);
      };
      this.conditions.forEach(destroyAll.bind(this));
      return this.conditions.splice(0, this.conditions.length);
    };

    NbSearchCtrl.prototype.$$destroy = function(predicate) {
      if (!predicate.block) {
        return;
      }
      predicate.block.element.remove();
      predicate.block.scope.$destroy();
      delete predicate.block;
    };

    NbSearchCtrl.prototype.$$parseFilter = function(filter) {
      var reviver;
      reviver = function(k, v) {
        if (k === '') {
          return v;
        }
        if (typeof v === 'string' && ISO_DATE_REGEXP.test(v)) {
          return new Date(v);
        }
        return v;
      };
      return JSON.parse(filter, reviver);
    };

    return NbSearchCtrl;

  })();

  nbConditionContainerDirective = function() {
    var postLink;
    postLink = function(scope, elem, attrs, ctrl) {
      var initialData, selectedPredicate;
      selectedPredicate = scope.condition.selected;
      initialData = scope.condition.initialData;
      ctrl.initialCondition(scope.condition.selected, elem, initialData);
      scope.$watch('condition.selected', function(newValue, old) {
        if (newValue === old) {
          return;
        }
        return ctrl.switchQueryPredicate(old, newValue, elem);
      });
      return scope.$on('$destroy', function() {
        var conditionNode;
        return conditionNode = null;
      });
    };
    return {
      require: '^nbSearch',
      link: postLink
    };
  };

  nbSearchDirective = function($timeout) {
    var postLink;
    postLink = function(scope, elem, attrs, ctrl, $transcludeFn) {
      var onSelectFilter, promise, searchCtrl, tableCtrl, throttle;
      searchCtrl = ctrl[0];
      tableCtrl = ctrl[1];
      promise = null;
      throttle = attrs.nbDelay || 400;
      scope.$watch('predicateObject', function(newValue, oldValue) {
        return tableCtrl.getTableState().predicate = newValue;
      });
      scope.$watch('ctrl.currentFilter', function(newValue) {
        if (newValue) {
          return searchCtrl.selectFilter(newValue);
        }
      });
      $transcludeFn(scope, function(clone, scope) {
        return elem.append(clone);
      });
      onSelectFilter = function(evt, filter) {
        var condition;
        return condition = JSON.parse(filter.condition);
      };
      return elem.on('select:filter');
    };
    return {
      require: ['nbSearch', '^nbTable'],
      templateUrl: 'partials/component/table/search.html',
      transclude: true,
      controller: 'nbSearchCtrl',
      controllerAs: 'ctrl',
      scope: true,
      priority: 110,
      link: postLink
    };
  };

  nbSelectRowDirective = function() {
    var postLink;
    postLink = function(scope, elem, attrs, tableCtrl) {
      var mode, onSelect;
      if (!attrs.nbSelectRow) {
        return;
      }
      onSelect = function(evt) {
        return scope.$apply(function() {
          return tableCtrl.select(scope.row, mode);
        });
      };
      mode = attrs.mode || 'single';
      elem.on('click', onSelect);
      scope.$watch('row.isSelected', function(newValue, oldValue) {
        if (newValue === true) {
          return elem.addClass('nb-selected');
        } else {
          return elem.removeClass('nb-selected');
        }
      });
      return scope.$on('$destroy', function() {
        return elem.off('click', onSelect);
      });
    };
    return {
      require: '^nbTable',
      link: postLink,
      scope: {
        row: "=nbSelectRow"
      }
    };
  };

  nbSelectRowDirective2 = function() {
    var postLink;
    postLink = function(scope, elem, attrs, ctrl) {
      var $input, mode;
      mode = attrs.mode || 'single';
      $input = elem.find('input')[0];
      if (mode === 'all') {
        elem.on('change', function(evt) {
          return scope.$apply(function() {
            return ctrl.selectAll($input.checked);
          });
        });
      } else {
        elem.on('change', function(evt) {
          var input;
          input = evt.target;
          return ctrl.select(scope.row, mode);
        });
        scope.$watch('row.isSelected', function(newValue) {
          $input.checked = newValue;
          if (newValue === true) {
            return elem.parent().addClass('nb-selected');
          } else {
            return elem.parent().removeClass('nb-selected');
          }
        });
      }
      return scope.$on('$destroy', function() {
        return elem.off('change');
      });
    };
    return {
      template: '<input ng-model="row.isSelected" type="checkbox"/>',
      link: postLink,
      require: '^nbTable',
      scope: {
        row: '=?selectRow'
      }
    };
  };

  nbPredicateDirective = function($parse) {
    var postLink;
    postLink = function(scope, elem, attrs, ctrl, $transcludeFn) {
      var displayName, key, modelGetter, searchCtrl;
      searchCtrl = ctrl[0];
      displayName = attrs.nbPredicate;
      if (!attrs.ngModel && !attrs.predicateAttr) {
        return;
      }
      key = attrs.ngModel || attrs.predicateAttr;
      modelGetter = $parse(key);
      return searchCtrl.addPredicate(key, displayName, modelGetter, $transcludeFn);
    };
    return {
      require: ['^nbSearch'],
      link: postLink,
      transclude: 'element',
      priority: 1
    };
  };

  nbPaginationDirective = function() {
    var postLink;
    postLink = function(scope, elem, attrs, ctrl) {
      var redraw;
      scope.perPage = scope.$eval(attrs.perPage) || 10;
      scope.nbDislpayedPages = scope.$eval(scope.nbDislpayedPages) || 10;
      scope.currentPage = 1;
      scope.pages = [];
      redraw = function() {
        var end, i, start, _i, _ref;
        start = 1;
        end;
        i;
        start = Math.max(start, scope.currentPage - Math.abs(Math.floor(scope.nbDislpayedPages / 2)));
        end = start + scope.nbDislpayedPages;
        if (end > scope.pagesCount) {
          end = scope.pagesCount;
          start = Math.max(1, end - scope.nbDislpayedPages);
        }
        scope.pages = [];
        for (i = _i = start, _ref = end + 1; start <= _ref ? _i < _ref : _i > _ref; i = start <= _ref ? ++_i : --_i) {
          scope.pages.push(i);
        }
      };
      scope.$watch('pageState', function(newValue) {
        if (angular.isUndefined(newValue)) {
          return;
        }
        scope.currentPage = newValue.page;
        scope.perPage = newValue.per_page;
        scope.pagesCount = newValue.pages_count;
        return redraw();
      });
      scope.selectPage = function(page) {
        if ((0 < page && page <= scope.pagesCount)) {
          return ctrl.slice(page, scope.perPage);
        }
      };
      return ctrl.slice(1, scope.nbItemsByPage);
    };
    return {
      restrict: 'EA',
      require: '^nbTable',
      templateUrl: 'partials/component/table/pagination.html',
      scope: {
        pageState: '=nbPagination'
      },
      link: postLink
    };
  };

  filterSelectorDirective = function() {
    var postLink;
    return postLink = function(scope, elem, attrs) {};
  };

  app.controller('nbSearchCtrl', NbSearchCtrl);

  app.directive('nbTable', ['$timeout', nbTableDirective]);

  app.directive('nbSearch', nbSearchDirective);

  app.directive('nbConditionContainer', nbConditionContainerDirective);

  app.directive('nbPredicate', ['$parse', nbPredicateDirective]);

  app.directive('nbPipe', nbPipeDirective);

  app.directive('nbSelectRow', nbSelectRowDirective);

  app.directive('selectRow', nbSelectRowDirective2);

  app.directive('nbPagination', nbPaginationDirective);

}).call(this);

(function() {
  var LoginController, SigupController, app, nb,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  nb = this.nb;

  app = nb.app;

  LoginController = (function(_super) {
    __extends(LoginController, _super);

    LoginController.$inject = ['$http', '$stateParams', '$state', '$scope', '$rootScope', '$cookies', 'User', '$timeout', 'Org'];

    function LoginController(http, params, state, scope, rootScope, cookies, User, timeout, Org) {
      this.http = http;
      this.params = params;
      this.state = state;
      this.scope = scope;
      this.rootScope = rootScope;
      this.cookies = cookies;
      this.User = User;
      this.timeout = timeout;
      this.Org = Org;
      this.scope.currentUser = null;
    }

    LoginController.prototype.loadInitialData = function() {};

    LoginController.prototype.login = function(user) {
      var self;
      self = this;
      return self.http.post('/api/sign_in', {
        user: user
      }).success(function(data) {
        self.cookies.token = data.token;
        return self.timeout(function() {
          self.rootScope.currentUser = self.User.$fetch();
          self.rootScope.allOrgs = self.Org.$search();
          return self.state.go("home");
        }, 100);
      }).error(function(data) {
        return self.$emit('error', '#{data.message}');
      });
    };

    return LoginController;

  })(nb.Controller);

  SigupController = (function(_super) {
    __extends(SigupController, _super);

    SigupController.$inject = ['$http', '$stateParams', '$state', '$scope'];

    function SigupController(http, params, state, scope) {
      this.http = http;
      this.params = params;
      this.state = state;
      this.scope = scope;
      this.scope.currentUser = null;
    }

    SigupController.prototype.loadInitialData = function() {};

    SigupController.prototype.sigup = function(user) {
      var self;
      self = this;
      return self.http.post('/api/sign_in', {
        user: user
      }).success(function(data) {
        return console.log(data);
      }).error(function(data) {
        return console.log(data);
      });
    };

    return SigupController;

  })(nb.Controller);

  app.controller('LoginController', LoginController);

  app.controller('SigupController', SigupController);

}).call(this);

(function() {
  var module;

  module = angular.module('nb.filters', []);

  module.filter('highlight', function() {
    return function(input, opts) {
      if (opts == null) {
        opts = {};
      }
      if (typeof opts === 'string') {
        opts = {
          text: opts
        };
      }
      if (opts.text == null) {
        return input;
      }
      return input.replace(new RegExp(opts.text, 'gi'), '<span class="highlightText">$&</span>');
    };
  });

  module.filter('dictmap', [
    function() {
      var map;
      map = {
        "personnel": {
          '0': '无需审核',
          '1': '待审核',
          '2': '通过',
          '3': '不通过'
        }
      };
      return function(input, module) {
        return map[module][input.toString()];
      };
    }
  ]).filter('nbDate', function() {
    return function(input, opts) {
      return new Date(input);
    };
  });

}).call(this);

(function() {
  var Modal, ProfileCtrl, Route, app, extend, nb, resetForm,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  nb = this.nb;

  app = nb.app;

  extend = angular.extend;

  resetForm = nb.resetForm;

  Modal = nb.Modal;

  Route = (function() {
    Route.$inject = ['$stateProvider', '$urlRouterProvider'];

    function Route(stateProvider, urlRouterProvider) {
      urlRouterProvider.when('/self-service', '/self-service/profile');
      stateProvider.state('self', {
        url: '/self-service',
        templateUrl: 'partials/self/self_info.html',
        ncyBreadcrumb: {
          label: "员工自助"
        }
      }).state('self.profile', {
        url: '/profile',
        controller: ProfileCtrl,
        controllerAs: 'ctrl',
        templateUrl: 'partials/self/self_info_basic/self_info_basic.html'
      }).state('self.members', {
        url: '/members',
        controller: ProfileCtrl,
        controllerAs: 'ctrl',
        templateUrl: 'partials/self/self_info_family/self_info_members.html'
      }).state('self.education', {
        url: '/education',
        controller: ProfileCtrl,
        controllerAs: 'ctrl',
        templateUrl: 'partials/self/education.html'
      }).state('self.experience', {
        url: '/experience',
        controller: ProfileCtrl,
        controllerAs: 'ctrl',
        templateUrl: 'partials/self/experience.html'
      }).state('self.resume', {
        url: '/resume',
        controller: ProfileCtrl,
        controllerAs: 'ctrl',
        templateUrl: 'partials/self/self_resume.html'
      });
    }

    return Route;

  })();

  ProfileCtrl = (function(_super) {
    __extends(ProfileCtrl, _super);

    ProfileCtrl.$inject = ['$scope', 'sweet', 'Employee', '$rootScope'];

    function ProfileCtrl(scope, sweet, Employee, rootScope) {
      this.scope = scope;
      this.sweet = sweet;
      this.Employee = Employee;
      this.rootScope = rootScope;
      this.loadInitailData();
      this.status = 'show';
    }

    ProfileCtrl.prototype.loadInitailData = function() {
      return this.scope.currentUser = this.rootScope.currentUser;
    };

    ProfileCtrl.prototype.updateInfo = function() {
      return this.scope.currentUser.$update();
    };

    ProfileCtrl.prototype.updateEdu = function(edu) {
      return edu.$save();
    };

    ProfileCtrl.prototype.createEdu = function(edu) {
      return this.scope.currentUser.educationExperiences.createEdu(edu);
    };

    return ProfileCtrl;

  })(nb.Controller);

  app.config(Route);

}).call(this);

(function() {
  var Modal, OrgCtrl, OrgsCtrl, PositionCtrl, Route, app, extend, nb, orgChart, orgTree, resetForm,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  nb = this.nb;

  app = nb.app;

  extend = angular.extend;

  resetForm = nb.resetForm;

  Modal = nb.Modal;

  orgChart = function() {
    var link;
    link = function(scope, $el, attrs) {
      var active_rect, click_handler, oc_options_2, paper;
      paper = null;
      active_rect = null;
      click_handler = function(evt, elem) {
        var params, rect;
        rect = elem[0];
        if (active_rect !== null) {
          active_rect.classList.remove('active');
        }
        rect.classList = _.uniq(rect.classList.add('active'));
        active_rect = rect;
        params = arguments;
        return scope.$apply(function() {
          return scope.ctrl.onItemClick.apply(scope.ctrl, params);
        });
      };
      oc_options_2 = {
        data_id: 90943,
        container: $el[0],
        box_color: '#dfe5e7',
        box_color_hover: '#cad4d7',
        box_border_color: '#c4cfd3',
        box_html_template: null,
        line_color: '#c4cfd3',
        title_color: '#000',
        subtitle_color: '#707',
        max_text_width: 1,
        text_font: 'Courier',
        use_images: false,
        box_click_handler: click_handler,
        use_zoom_print: false,
        debug: false
      };
      scope.$watch(attrs.orgChartData, function(newval, old) {
        var data;
        if (typeof newval === 'undefined') {
          return;
        }
        if (paper != null) {
          active_rect = null;
          paper.remove();
        }
        data = {
          id: 90943,
          title: '',
          root: newval
        };
        paper = ggOrgChart.render(oc_options_2, data);
        active_rect = $el.find('rect').last()[0];
        active_rect.classList.add('active');
        return $el.trigger('resize');
      });
    };
    return {
      restrict: 'A',
      link: link
    };
  };

  orgTree = function(Org, $parse) {
    var postLink;
    postLink = function(scope, elem, attrs, $ctrl) {
      var $tree, getData, treeData;
      $tree = null;
      getData = function(node) {
        var data, k, v;
        data = {};
        for (k in node) {
          v = node[k];
          if ((k !== 'parent' && k !== 'children' && k !== 'element' && k !== 'tree') && Object.prototype.hasOwnProperty.call(node, k)) {
            data[k] = v;
          }
        }
        return data;
      };
      treeData = scope.treeData.jqTreeful();
      $tree = elem.tree({
        data: treeData,
        autoOpen: 0
      });
      $tree.bind('tree.select', function(evt) {
        var node;
        node = evt.node;
        return $ctrl.$setViewValue(getData(node));
      });
      return scope.$on('$destroy', function() {
        if ($tree && $tree.tree) {
          $tree.tree('destroy');
        }
        return $tree = null;
      });
    };
    return {
      scope: {
        org: "=ngModel",
        treeData: '='
      },
      require: 'ngModel',
      link: postLink
    };
  };

  app.directive('orgChart', [orgChart]);

  app.directive('nbOrgTree', ['Org', '$parse', orgTree]);

  Route = (function() {
    Route.$inject = ['$stateProvider'];

    function Route(stateProvider) {
      var orgs;
      orgs = function(Org) {
        return Org.$collection().$fetch({
          edit_mode: true
        }).$asPromise();
      };
      stateProvider.state('org', {
        url: '/orgs',
        templateUrl: 'partials/orgs/orgs.html',
        controller: 'OrgsCtrl',
        controllerAs: 'ctrl',
        resolve: {
          orgs: orgs
        }
      });
    }

    return Route;

  })();

  OrgsCtrl = (function(_super) {
    __extends(OrgsCtrl, _super);

    OrgsCtrl.$inject = ['orgs', '$http', '$stateParams', '$state', '$scope', '$rootScope', '$nbEvent'];

    function OrgsCtrl(orgs, http, params, state, scope, rootScope, Evt) {
      this.orgs = orgs;
      this.http = http;
      this.params = params;
      this.state = state;
      this.scope = scope;
      this.rootScope = rootScope;
      this.Evt = Evt;
      this.treeRootOrg = _.find(orgs, function(org) {
        return org.depth === 1;
      });
      this.tree = null;
      this.currentOrg = null;
      this.isBarOpen = false;
      scope.$onRootScope('org:refresh', this.refreshTree.bind(this));
      scope.$onRootScope('org:resetData', this.resetData.bind(this));
      this.buildTree(this.treeRootOrg);
    }

    OrgsCtrl.prototype.buildTree = function(org, depth) {
      if (org == null) {
        org = this.treeRootOrg;
      }
      if (depth == null) {
        depth = 9;
      }
      if (org.depth === 1) {
        depth = 1;
      }
      this.treeRootOrg = org;
      this.tree = this.orgs.treeful(org, depth);
      return this.currentOrg = org;
    };

    OrgsCtrl.prototype.refreshTree = function() {
      var depth;
      if (!this.treeRootOrg) {
        return;
      }
      depth = 9;
      if (this.treeRootOrg.depth === 1) {
        depth = 1;
      }
      this.tree = this.orgs.treeful(this.treeRootOrg, depth);
      return this.currentOrg = this.treeRootOrg;
    };

    OrgsCtrl.prototype.reset = function(force) {
      var self;
      self = this;
      return this.orgs.$refresh({
        edit_mode: this.eidtMode
      }).$then(function() {
        return self.buildTree();
      });
    };

    OrgsCtrl.prototype.onItemClick = function(evt, elem) {
      var orgId;
      orgId = elem.oc_id;
      return this.currentOrg = _.find(this.orgs, {
        id: orgId
      });
    };

    OrgsCtrl.prototype.revert = function(isConfirm) {
      if (isConfirm) {
        this.orgs.revert();
        return this.resetData();
      }
    };

    OrgsCtrl.prototype.active = function(evt, data) {
      var self;
      self = this;
      data.department_id = this.treeRootOrg.id;
      this.orgs.active(data).$then(function() {
        return self.rootScope.allOrgs.$refresh();
      });
      return this.resetData();
    };

    OrgsCtrl.prototype.resetData = function() {
      this.isHistory = false;
      return this.orgs.$refresh({
        'edit_mode': true
      });
    };

    OrgsCtrl.prototype.rootTree = function() {
      var treeRootOrg;
      treeRootOrg = _.find(this.orgs, function(org) {
        return org.depth === 1;
      });
      return this.buildTree(treeRootOrg);
    };

    OrgsCtrl.prototype.initialHistoryData = function() {
      var onSuccess, promise;
      onSuccess = function(res) {
        var changeLogs, firstDate, groupedLogs, logs, logsArr, minDate;
        logs = res.data.change_logs;
        groupedLogs = _.groupBy(logs, function(log) {
          return moment(log.created_at).format('YYYY');
        });
        logsArr = [];
        angular.forEach(groupedLogs, function(yeardLog, key) {
          return logsArr.push({
            logs: yeardLog,
            changeYear: key
          });
        });
        changeLogs = _.sortBy(logsArr, 'changeYear').reverse();
        firstDate = _.last(logs).created_at;
        minDate = moment(firstDate).subtract(1, 'days').format('DD/MM/YYYY');
        return {
          changeLogs: changeLogs,
          minDate: minDate
        };
      };
      promise = this.http.get('/api/departments/change_logs');
      return promise.then(onSuccess);
    };

    OrgsCtrl.prototype.pickLog = function(date, changeLogs) {
      var log, selectedMoment, sortedLogs;
      sortedLogs = _.flatten(_.pluck(changeLogs, 'logs'));
      selectedMoment = moment(date);
      log = _.find(sortedLogs, function(log) {
        return selectedMoment.isAfter(log.created_at);
      });
      if (log) {
        return this.expandLog(log);
      }
    };

    OrgsCtrl.prototype.backToPast = function(version) {
      var self;
      self = this;
      if (this.currentLog) {
        return this.orgs.$refresh({
          version: this.currentLog.id
        }).$then(function() {
          self.isHistory = true;
          return self.currentOrg = self.treeRootOrg;
        });
      }
    };

    OrgsCtrl.prototype.expandLog = function(log) {
      if (this.currentLog) {
        this.currentLog.active = false;
      }
      log.active = true;
      return this.currentLog = log;
    };

    return OrgsCtrl;

  })(nb.Controller);

  OrgCtrl = (function(_super) {
    __extends(OrgCtrl, _super);

    OrgCtrl.$inject = ['Org', '$stateParams', '$scope', '$rootScope', '$nbEvent', 'Position', 'sweet'];

    function OrgCtrl(Org, params, scope, rootScope, Evt, Position, sweet) {
      var self;
      this.Org = Org;
      this.params = params;
      this.scope = scope;
      this.rootScope = rootScope;
      this.Evt = Evt;
      this.Position = Position;
      this.sweet = sweet;
      this.state = 'show';
      self = this;
      scope.$parent.$watch('ctrl.currentOrg', function(newval) {
        return self.orgLink(newval);
      });
    }

    OrgCtrl.prototype.orgLink = function(org) {
      var queryParam;
      this.scope.currentOrg = org;
      queryParam = this.scope.ctrl.isHistory ? {
        version: this.scope.ctrl.currentLog.id
      } : {};
      return this.scope.positions = this.scope.currentOrg.positions.$refresh(queryParam);
    };

    OrgCtrl.prototype.transfer = function(destOrg) {
      var self;
      self = this;
      return this.scope.currentOrg.transfer(destOrg.id).$then(function() {
        return self.Evt.$send('org:resetData');
      });
    };

    OrgCtrl.prototype.newsub = function(form, neworg) {
      var self;
      if (form.$invalid) {
        return;
      }
      self = this;
      return this.scope.currentOrg.newSub(neworg).$then(function() {
        return self.state = 'show';
      });
    };

    OrgCtrl.prototype.destroy = function(isConfirm) {
      var $Evt, orgName, sweet;
      sweet = this.sweet;
      $Evt = this.Evt;
      orgName = this.scope.currentOrg.name;
      if (isConfirm) {
        return this.scope.currentOrg.$destroy().$then(function() {
          $Evt.$send('org:resetData');
          return sweet.success('删除成功', "您已成功删除" + orgName);
        });
      } else {
        return sweet.error("您取消了删除" + this.scope.currentOrg.name);
      }
    };

    return OrgCtrl;

  })(nb.Controller);

  PositionCtrl = (function(_super) {
    __extends(PositionCtrl, _super);

    PositionCtrl.$inject = ['$scope', '$nbEvent', 'Position', '$stateParams', 'Org', 'Specification'];

    function PositionCtrl(scope, Evt, Position, stateParams, Org, Specification) {
      this.scope = scope;
      this.Evt = Evt;
      this.Position = Position;
      this.stateParams = stateParams;
      this.Org = Org;
      this.Specification = Specification;
      this.positions = scope.ngDialogData;
      scope.ctrl = this;
    }

    PositionCtrl.prototype.getSelectsIds = function() {
      return this.positions.filter(function(pos) {
        return pos.isSelected;
      }).map(function(pos) {
        return pos.id;
      });
    };

    PositionCtrl.prototype.posTransfer = function() {
      var selectedPosIds, self;
      self = this;
      selectedPosIds = this.getSelectsIds();
      if (selectedPosIds.length > 0 && this.selectOrg) {
        this.positions.$adjust({
          department_id: this.selectOrg.id,
          position_ids: selectedPosIds
        });
        return self.selectOrg = null;
      } else {
        return this.Evt.$send("position:transfer:error", "被划转岗位和目标机构必选");
      }
    };

    PositionCtrl.prototype.batchRemove = function() {
      if (this.getSelectsIds().length !== 0) {
        return this.positions.$batchRemove({
          ids: this.getSelectsIds()
        });
      } else {
        return this.Evt.$send("position:remove:error", "你还没选择所要删除的岗位");
      }
    };

    PositionCtrl.prototype.getExportParams = function(id) {
      var ids;
      ids = this.getSelectsIds();
      if (ids.length === 0) {
        return 'department_id=' + id;
      } else {
        return 'department_id=' + id + '&position_ids=' + ids.join(',');
      }
    };

    PositionCtrl.prototype.createPos = function(newPos, spe) {
      return newPos = this.positions.$create(newPos).$then(function(newpos) {
        return newpos.$createSpe(spe);
      });
    };

    PositionCtrl.prototype.search = function(tableState) {
      return this.positions.$refresh(tableState);
    };

    PositionCtrl.prototype.searchEmp = function(tableState) {};

    return PositionCtrl;

  })(nb.Controller);

  app.config(Route);

  app.controller('OrgsCtrl', OrgsCtrl);

  app.controller('OrgCtrl', OrgCtrl);

  app.controller('OrgPosCtrl', PositionCtrl);

}).call(this);

(function() {
  var DialogCtrl, Modal, NewEmpsCtrl, PersonnelCtrl, ReviewCtrl, Route, app, extend, nb, resetForm,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  nb = this.nb;

  app = nb.app;

  extend = angular.extend;

  resetForm = nb.resetForm;

  Modal = nb.Modal;

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

  PersonnelCtrl = (function(_super) {
    __extends(PersonnelCtrl, _super);

    PersonnelCtrl.$inject = ['$scope', 'sweet', 'Employee'];

    function PersonnelCtrl(scope, sweet, Employee) {
      this.scope = scope;
      this.sweet = sweet;
      this.Employee = Employee;
      this.loadInitailData();
      this.selectedIndex = 1;
    }

    PersonnelCtrl.prototype.loadInitailData = function() {
      return this.employees = this.Employee.$collection().$fetch();
    };

    PersonnelCtrl.prototype.search = function(tableState) {
      return this.employees.$refresh(tableState);
    };

    PersonnelCtrl.prototype.getExportParams = function() {
      return this.employees.filter(function(emp) {
        return emp.isSelected;
      }).map(function(emp) {
        return emp.id;
      }).join(',');
    };

    return PersonnelCtrl;

  })(nb.Controller);

  NewEmpsCtrl = (function(_super) {
    __extends(NewEmpsCtrl, _super);

    NewEmpsCtrl.$inject = ['$scope', 'Employee', 'Org'];

    function NewEmpsCtrl(scope, Employee, Org) {
      this.scope = scope;
      this.Employee = Employee;
      this.Org = Org;
      this.newEmp = {};
      this.loadInitailData();
    }

    NewEmpsCtrl.prototype.loadInitailData = function() {
      var collection_param;
      collection_param = {
        predicate: {
          join_scal_date: {
            from: moment().subtract(1, 'year').format('YYYY-MM-DD'),
            to: moment().format("YYYY-MM-DD")
          }
        },
        sort: {
          join_scal_date: 'desc'
        }
      };
      return this.employees = this.Employee.$collection(collection_param).$fetch();
    };

    NewEmpsCtrl.prototype.regEmployee = function(employee) {
      var self;
      self = this;
      return this.employees.$build(employee).$save().$then(function() {
        return self.loadInitailData();
      });
    };

    NewEmpsCtrl.prototype.getExportParams = function() {
      return this.employees.filter(function(emp) {
        return emp.isSelected;
      }).map(function(emp) {
        return emp.id;
      }).join(',');
    };

    NewEmpsCtrl.prototype.search = function(tableState) {
      tableState = this.mergeParams(tableState);
      return this.employees.$refresh(tableState);
    };

    NewEmpsCtrl.prototype.mergeParams = function(tableState) {
      var params;
      params = {
        predicate: {
          join_scal_date: {
            from: moment().subtract(1, 'year').format('YYYY-MM-DD'),
            to: moment().format("YYYY-MM-DD")
          }
        },
        sort: {
          join_scal_date: 'desc'
        }
      };
      angular.forEach(params, function(val, key) {
        if (angular.isObject(val)) {
          return angular.forEach(val, function(nestedVal, nestedKey) {
            return tableState[key][nestedKey] = nestedVal;
          });
        }
      });
      return tableState;
    };

    return NewEmpsCtrl;

  })(nb.Controller);

  ReviewCtrl = (function(_super) {
    __extends(ReviewCtrl, _super);

    ReviewCtrl.$inject = ['$scope', 'Change', 'Record', '$mdDialog'];

    function ReviewCtrl(scope, Change, Record, mdDialog) {
      this.scope = scope;
      this.Change = Change;
      this.Record = Record;
      this.mdDialog = mdDialog;
      this.loadInitailData();
    }

    ReviewCtrl.prototype.loadInitailData = function() {};

    ReviewCtrl.prototype.searchRecord = function(tableState) {
      return this.records.$refresh(tableState);
    };

    ReviewCtrl.prototype.checkChanges = function() {
      var checked, params;
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
      return this.changes.checkChanges(params);
    };

    return ReviewCtrl;

  })(nb.Controller);

  DialogCtrl = (function(_super) {
    __extends(DialogCtrl, _super);

    DialogCtrl.$inject = ['$scope', 'data', '$mdDialog'];

    function DialogCtrl(scope, data, mdDialog) {
      var self;
      this.scope = scope;
      this.data = data;
      this.mdDialog = mdDialog;
      self = this;
      this.scope.data = this.data;
    }

    return DialogCtrl;

  })(nb.Controller);

  app.config(Route);

  app.controller('DialogCtrl', DialogCtrl);

}).call(this);

(function() {
  var Modal, PositionChangesCtrl, PositionCtrl, Route, app, extend, nb, resetForm,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  nb = this.nb;

  app = nb.app;

  extend = angular.extend;

  resetForm = nb.resetForm;

  Modal = nb.Modal;

  Route = (function() {
    Route.$inject = ['$stateProvider'];

    function Route(stateProvider) {
      stateProvider.state('position_list', {
        url: '/positions',
        templateUrl: 'partials/position/position.html',
        controller: PositionCtrl,
        controllerAs: 'ctrl'
      }).state('position_changes', {
        url: '/positions/changes',
        controller: PositionChangesCtrl,
        controllerAs: 'ctrl',
        templateUrl: 'partials/position/position_changes.html'
      });
    }

    return Route;

  })();

  PositionCtrl = (function(_super) {
    __extends(PositionCtrl, _super);

    PositionCtrl.$inject = ['Position', '$scope', 'sweet'];

    function PositionCtrl(Position, scope, sweet) {
      this.Position = Position;
      this.scope = scope;
      this.sweet = sweet;
      this.loadInitialData();
    }

    PositionCtrl.prototype.loadInitialData = function() {
      var self;
      self = this;
      return this.positions = this.Position.$collection().$fetch();
    };

    PositionCtrl.prototype.search = function(tableState) {
      return this.positions.$refresh(tableState);
    };

    PositionCtrl.prototype.getExportParams = function() {
      return this.positions.filter(function(pos) {
        return pos.isSelected;
      }).map(function(pos) {
        return pos.id;
      }).join(',');
    };

    return PositionCtrl;

  })(nb.Controller);

  PositionChangesCtrl = (function(_super) {
    __extends(PositionChangesCtrl, _super);

    PositionChangesCtrl.$inject = ['PositionChange', '$mdDialog'];

    function PositionChangesCtrl(PositionChange, mdDialog) {
      this.PositionChange = PositionChange;
      this.mdDialog = mdDialog;
    }

    PositionChangesCtrl.prototype.searchChanges = function(tableState) {
      return this.changes.$refresh(tableState);
    };

    return PositionChangesCtrl;

  })(nb.Controller);

  app.config(Route);

}).call(this);

(function() {
  var Employee, Formerleaders, resources;

  resources = angular.module('resources');

  Employee = function(restmod, RMUtils, $Evt) {
    return Employee = restmod.model('/employees').mix('nbRestApi', 'DirtyModel', {
      department: {
        mask: 'CU',
        belongsTo: 'Org'
      },
      joinScalDate: {
        decode: 'date',
        param: 'yyyy-MM-dd',
        mask: 'CU'
      },
      startDate: {
        decode: 'date',
        param: 'yyyy-MM-dd',
        mask: 'CU'
      },
      isSelected: {
        mask: "CU"
      },
      resume: {
        hasOne: 'Resume',
        mask: 'CU'
      },
      $hooks: {
        'after-create': function() {
          return $Evt.$send('employee:create:success', "新员工创建成功");
        },
        'after-create-error': function() {
          return $Evt.$send('employee:create:error', "新员工创建失败");
        },
        'after-update': function() {
          return $Evt.$send('employee:update:success', "员工信息更新成功");
        },
        'after-update-error': function() {
          return $Evt.$send('employee:update:error', "员工信息跟新失败");
        }
      },
      $extend: {
        Collection: {
          search: function(tableState) {
            return this.$refresh(tableState);
          }
        }
      }
    });
  };

  Formerleaders = function(restmod, RMUtils, $Evt) {
    var Leader;
    return Leader = restmod.model('/formerleaders').mix('nbRestApi', {
      $config: {
        jsonRoot: 'employees'
      },
      startDate: {
        decode: 'date',
        param: 'yyyy-MM-dd',
        mask: 'CU'
      },
      endDate: {
        decode: 'date',
        param: 'yyyy-MM-dd',
        mask: 'CU'
      },
      $extend: {
        Collection: {
          search: function(tableState) {
            return this.$refresh(tableState);
          }
        }
      }
    });
  };

  resources.factory('Employee', ['restmod', 'RMUtils', '$nbEvent', Employee]);

  resources.factory('Formerleaders', ['restmod', 'RMUtils', '$nbEvent', Formerleaders]);

}).call(this);

(function() {
  var nbRestApi, resources;

  resources = angular.module('resources');

  nbRestApi = function(restmod, RMUtils, $rootScope, $Evt) {
    var Utils;
    Utils = RMUtils;
    return restmod.mixin({
      created_at: {
        decode: 'date',
        param: 'yyyy年mm月dd日',
        mask: 'CU'
      },
      updated_at: {
        decode: 'date',
        param: 'yyyy年mm月dd日',
        mask: 'CU'
      },
      hooks: {
        'after-request-error': function(res) {
          return $Evt.$send('global:request:error', res);
        }
      },
      'Record.$store': function(_patch) {
        var self;
        self = this;
        return self.$action(function() {
          var onErorr, onSuccess, request, url;
          url = Utils.joinUrl(self.$url('update'), _patch);
          request = {
            method: 'PATCH',
            url: url,
            data: self.$wrap(function(_name) {
              return _patch.indexOf(_name) === -1;
            })
          };
          onSuccess = function(_response) {
            return self[_patch] = _response.data;
          };
          onErorr = function(_response) {
            return self.$dispatch('after-store-error', [_response]);
          };
          return this.$send(request, onSuccess, onErorr);
        });
      },
      'Model.encodeUrlName': function(_name) {
        return _name.replace(/[A-Z]/g, "_$&").toLowerCase();
      }
    });
  };

  resources.factory('nbRestApi', ['restmod', 'RMUtils', '$nbEvent', nbRestApi]);

}).call(this);

(function() {
  var Change, Record, resources;

  resources = angular.module('resources');

  Change = function(restmod, RMUtils, $Evt) {
    return Change = restmod.model('/employee_changes/check').mix('nbRestApi', 'DirtyModel', {
      checkDate: {
        decode: 'date',
        param: 'yyyy年MM月dd日',
        mask: 'CU'
      },
      createdAt: {
        decode: 'date',
        param: 'yyyy年MM月dd日',
        mask: 'CU'
      },
      $hooks: {
        'after-check': function() {
          return $Evt.$send('changes:check:success', "审核提交成功");
        }
      },
      $config: {
        jsonRoot: 'audits'
      },
      $extend: {
        Collection: {
          checkChanges: function(parms) {
            var onSuccess, request, self;
            self = this;
            request = {
              method: 'PUT',
              url: "/api/employee_changes",
              data: {
                audits: parms
              }
            };
            onSuccess = function(res) {
              angular.forEach(parms, function(item) {
                item = _.find(self, {
                  id: item.id
                });
                return self.$remove(item);
              });
              return self.$dispatch('after-check', res);
            };
            return this.$send(request, onSuccess);
          }
        }
      }
    });
  };

  Record = function(restmod, RMUtils, $Evt) {
    return Record = restmod.model('/employee_changes/record').mix('nbRestApi', 'DirtyModel', {
      $config: {
        jsonRoot: 'audits'
      }
    });
  };

  resources.factory('Change', ['restmod', 'RMUtils', '$nbEvent', Change]);

  resources.factory('Record', ['restmod', 'RMUtils', '$nbEvent', Record]);

}).call(this);

(function() {
  var Org, resources;

  resources = angular.module('resources');

  Org = function(restmod, RMUtils, $Evt) {
    var Constants, cacheIndex, transform, treeful, unflatten;
    Constants = {
      NODE_INDEX: 3
    };
    transform = function(arr, keyPair) {
      var newarr;
      if (arr == null) {
        arr = [];
      }
      if (keyPair == null) {
        keyPair = {
          'name': 'title'
        };
      }
      if (!angular.isArray(arr)) {
        arr = [];
      }
      newarr = [];
      arr.forEach(function(val) {
        var res;
        val['type'] = 'subordinate';
        res = _.transform(val, function(result, val, key) {
          if (keyPair.hasOwnProperty(key)) {
            result[keyPair[key]] = val;
          } else {
            result[key] = val;
          }
        });
        return newarr.push(res);
      });
      return newarr;
    };
    cacheIndex = function(arr) {
      var newarr;
      if (arr == null) {
        arr = [];
      }
      newarr = _.cloneDeep(arr);
      newarr.forEach(function(val, index) {
        return val['mapping'] = index;
      });
      return newarr;
    };
    unflatten = function(array, ttl, parent, tree) {
      var children;
      if (ttl == null) {
        ttl = 9;
      }
      if (parent == null) {
        parent = {};
      }
      if (tree == null) {
        tree = [];
      }
      if (ttl === 0) {
        return;
      }
      ttl = ttl - 1;
      children = _.filter(array, function(child) {
        if (typeof parent.id === 'undefined') {
          return child.parent_id === void 0 || child.parent_id === 0;
        } else {
          return child.parent_id === parent.id;
        }
      });
      if (!_.isEmpty(children)) {
        if (parent.id === void 0) {
          tree = children;
        } else {
          parent['children'] = children;
        }
        _.each(children, function(child) {
          return unflatten(array, ttl, child, tree);
        });
      }
      return parent;
    };
    treeful = function(treeData, DEPTH, parent) {
      if (parent == null) {
        parent = _.find(treeData, function(child) {
          return child.parent_id === void 0 || child.parent_id === 0;
        });
      } else {
        parent = _.find(treeData, function(child) {
          return parent.id === child.id;
        });
      }
      return unflatten(treeData, DEPTH, parent);
    };
    return Org = restmod.model('/departments').mix('nbRestApi', 'DirtyModel', {
      positions: {
        hasMany: 'Position'
      },
      $hooks: {
        'after-fetch-many': function() {
          return $Evt.$send('org:refresh');
        },
        'after-destroy': function() {
          $Evt.$send('org:refresh');
          return $Evt.$send('org:destroy:success', "机构删除成功");
        },
        'after-active': function() {
          $Evt.$send('org:refresh');
          return $Evt.$send('org:active:success', "生效成功");
        },
        'after-active-error': function() {
          return $Evt.$send('org:active:error', arguments);
        },
        'after-revert': function() {
          $Evt.$send('org:refresh');
          return $Evt.$send('org:revert:success', "撤销成功");
        },
        'after-update': function() {
          $Evt.$send('org:refresh');
          return $Evt.$send('org:update:success', "修改成功");
        },
        'after-update-error': function() {
          return $Evt.$send('org:update:error');
        },
        'after-newsub': function() {
          $Evt.$send('org:refresh');
          return $Evt.$send('org:newsub:success', "机构创建成功");
        },
        'after-newsub-error': function() {
          return $Evt.$send('org:newsub:error');
        },
        'after-transfer': function() {
          return $Evt.$send('org:transfer:success', "划转机构成功");
        }
      },
      $extend: {
        Resource: {
          active: function(formdata) {
            var onErorr, onSuccess, request, self, url;
            self = this;
            url = RMUtils.joinUrl(this.$url(), 'active');
            request = {
              method: 'POST',
              url: url,
              data: formdata
            };
            $Evt.$send('org:active:process');
            onSuccess = function(res) {
              self.$dispatch('after-active', res);
              return $Evt.$send('org:refresh');
            };
            onErorr = function(res) {
              return self.$dispatch('after-active-error', res);
            };
            return this.$send(request, onSuccess, onErorr);
          },
          revert: function() {
            var onErorr, onSuccess, request, self, url;
            self = this;
            url = RMUtils.joinUrl(this.$url(), 'revert');
            request = {
              method: 'POST',
              url: url
            };
            onSuccess = function(res) {
              self.$dispatch('after-revert', res);
              return $Evt.$send('org:refresh');
            };
            onErorr = function(res) {
              return self.$dispatch('after-revert-error', res);
            };
            return this.$send(request, onSuccess, onErorr);
          }
        },
        Collection: {
          treeful: function(org, DEPTH) {
            var IneffectiveOrg, allOrgs, cachedIndexOrgs, isModified, rootDepth, rootSerialNumber, treeData;
            if (DEPTH == null) {
              DEPTH = 4;
            }
            IneffectiveOrg = function(org) {
              return /inactive$/.test(org.status);
            };
            allOrgs = this.$wrap();
            cachedIndexOrgs = cacheIndex(allOrgs);
            rootSerialNumber = org.serialNumber;
            rootDepth = org.depth;
            isModified = false;
            treeData = _.filter(cachedIndexOrgs, function(orgItem) {
              var isChild;
              if (!orgItem.serial_number) {
                throw Error('serial number if required');
              }
              if (orgItem.depth - rootDepth > DEPTH) {
                return false;
              }
              isChild = _.str.startsWith(orgItem.serial_number, rootSerialNumber);
              return isChild;
            });
            _.forEach(cachedIndexOrgs, function(orgItem) {
              if (IneffectiveOrg(orgItem)) {
                return isModified = true;
              }
            });
            treeData = transform(treeData, {
              'name': 'title'
            });
            treeData = treeful(treeData, DEPTH, org);
            return {
              data: treeData,
              isModified: isModified
            };
          },
          jqTreeful: function() {
            var allOrgs, treeData;
            allOrgs = this.$wrap();
            treeData = transform(allOrgs, {
              'name': 'label'
            });
            treeData = treeful(treeData, Infinity);
            return [treeData];
          }
        },
        Record: {
          newSub: function(org) {
            var onErorr, onSuccess;
            onSuccess = function() {
              return this.$dispatch('after-newsub');
            };
            onErorr = function() {
              return this.$dispatch('after-newsub-error', arguments);
            };
            org = this.$scope.$build(org);
            org.parentId = this.$pk;
            return org.$save().$then(onSuccess, onErorr);
          },
          transfer: function(to_dep_id) {
            var onErorr, onSuccess, request, self, url;
            self = this;
            onSuccess = function() {
              this.parentId = to_dep_id;
              return this.$dispatch('after-transfer');
            };
            onErorr = function() {
              return this.$dispatch('after-transfer-error', arguments);
            };
            url = this.$url();
            request = {
              url: "" + url + "/transfer",
              method: 'POST',
              data: {
                to_department_id: to_dep_id
              }
            };
            return this.$send(request, onSuccess, onErorr);
          }
        }
      }
    });
  };

  resources.factory('Org', ['restmod', 'RMUtils', '$nbEvent', Org]);

}).call(this);

(function() {
  var Position, PositionChange, Specification, resources;

  resources = angular.module('resources');

  Position = function(restmod, RMUtils, $Evt, Specification) {
    return Position = restmod.model('/positions').mix('nbRestApi', 'DirtyModel', {
      department: {
        mask: 'C',
        belongsTo: 'Org'
      },
      isSelected: {
        mask: "CU"
      },
      employees: {
        hasMany: 'Employee'
      },
      formerleaders: {
        hasMany: 'Formerleaders'
      },
      overstaffedNum: {
        computed: function(val) {
          var num;
          num = this.staffing - this.budgetedStaffing;
          if (num > 0) {
            return num;
          } else {
            return 0;
          }
        },
        mask: "CU"
      },
      specification: {
        hasOne: 'Specification',
        mask: "U"
      },
      $hooks: {
        'after-create': function() {
          return $Evt.$send('position:create:success', "岗位创建成功");
        },
        'after-update': function() {
          return $Evt.$send('position:update:success', "岗位更新成功");
        },
        'after-destroy': function() {
          return $Evt.$send('position:destroy:success', "岗位删除成功");
        },
        'after-destroy-error': function() {
          return $Evt.$send('position:destroy:success', arguments);
        },
        'after-adjust': function() {
          return $Evt.$send('position:adjust:success', "岗位调整成功");
        },
        'after-adjust-error': function() {
          return $Evt.$send('position:adjust:success', arguments);
        }
      },
      $extend: {
        Collection: {
          $adjust: function(infoData) {
            var onErorr, onSuccess, request, self;
            self = this;
            request = {
              method: 'POST',
              url: "api/positions/adjust",
              data: infoData
            };
            onSuccess = function(res) {
              angular.forEach(infoData.position_ids, function(id) {
                var item;
                item = _.find(self, {
                  id: id
                });
                return self.$remove(item);
              });
              return self.$dispatch('after-adjust', res);
            };
            onErorr = function(res) {
              return self.$dispatch('after-adjust-error', res);
            };
            return this.$send(request, onSuccess, onErorr);
          },
          $batchRemove: function(ids) {
            var onErorr, onSuccess, request, self;
            self = this;
            request = {
              method: 'POST',
              url: "api/positions/batch_destroy",
              data: ids
            };
            onSuccess = function(res) {
              angular.forEach(ids.ids, function(id) {
                var item;
                item = _.find(self, {
                  id: id
                });
                return self.$remove(item);
              });
              return self.$dispatch('after-destroy', res);
            };
            onErorr = function(res) {
              return self.$dispatch('after-destroy-error', res);
            };
            return this.$send(request, onSuccess, onErorr);
          }
        },
        Record: {
          $createSpe: function(spe) {
            var onErorr, onSuccess, request, self, url;
            self = this;
            url = this.$url();
            spe = Specification.$build(spe).$wrap();
            request = {
              method: 'POST',
              url: "" + url + "/specification",
              data: spe
            };
            onSuccess = function(res) {
              return self.$dispatch('specification-create', res);
            };
            onErorr = function(res) {
              return self.$dispatch('specification-create-error', res);
            };
            return this.$send(request, onSuccess, onErorr);
          }
        }
      }
    });
  };

  Specification = function(restmod, RMUtils, $Evt) {
    return Specification = restmod.model().mix('nbRestApi', 'DirtyModel', {
      $config: {
        jsonRoot: 'specification'
      },
      $hooks: {
        'after-update': function() {
          return $Evt.$send('position:update:success', "岗位说明书更新成功");
        }
      }
    });
  };

  PositionChange = function(restmod, RMUtils, $Evt) {
    return PositionChange = restmod.model('/position_changes').mix('nbRestApi', {
      $config: {
        jsonRoot: 'audits'
      }
    });
  };

  resources.factory('Position', ['restmod', 'RMUtils', '$nbEvent', 'Specification', Position]);

  resources.factory('Specification', ['restmod', 'RMUtils', '$nbEvent', Specification]);

  resources.factory('PositionChange', ['restmod', 'RMUtils', '$nbEvent', PositionChange]);

}).call(this);

(function() {
  var Condition, resources;

  resources = angular.module('resources');

  Condition = function(restmod, RMUtils, $Evt) {
    return Condition = restmod.model('/search_conditions').mix({});
  };

  resources.factory('SearchCondition', ['restmod', 'RMUtils', '$nbEvent', Condition]);

}).call(this);


/*
 * 与用户相关联的资源
 *
 *
 * File: user.coffee
 */

(function() {
  var Education, Experience, FamilyMember, Resume, User, resources;

  resources = angular.module('resources');

  User = function(restmod, RMUtils, $Evt) {
    return User = restmod.model(null).mix('nbRestApi', 'DirtyModel', {
      $hooks: {
        'after-update': function() {
          return $Evt.$send('user:update:success', "个人信息更新成功");
        }
      },
      educationExperiences: {
        hasMany: 'Education'
      },
      workExperiences: {
        hasMany: 'Experience'
      },
      resume: {
        hasOne: 'Resume',
        mask: 'CU'
      },
      $config: {
        jsonRoot: 'employee'
      },
      familymembers: {
        hasMany: 'FamilyMember'
      }
    }).single('/me');
  };

  Education = function(restmod, RMUtils, $Evt) {
    return Education = restmod.model().mix('nbRestApi', {
      admissionDate: {
        decode: 'nbDate'
      },
      graduationDate: {
        decode: 'nbDate'
      },
      $hooks: {
        'after-create': function() {
          return $Evt.$send('education:create:success', "教育经历创建成功");
        },
        'after-update': function() {
          return $Evt.$send('education:update:success', "教育经历更新成功");
        },
        'after-destroy': function() {
          return $Evt.$send('education:update:success', "教育经历删除成功");
        }
      },
      $config: {
        jsonRootSingle: 'education_experience',
        jsonRootMany: 'education_experiences'
      }
    });
  };

  Experience = function(restmod, RMUtils, $Evt) {
    return Experience = restmod.model().mix('nbRestApi', {
      startDate: {
        decode: 'nbDate'
      },
      endDate: {
        decode: 'nbDate'
      },
      $hooks: {
        'after-create': function() {
          return $Evt.$send('work:create:success', "工作经历创建成功");
        },
        'after-update': function() {
          return $Evt.$send('work:update:success', "工作经历更新成功");
        },
        'after-destroy': function() {
          return $Evt.$send('work:update:success', "工作经历删除成功");
        }
      },
      $config: {
        jsonRootSingle: 'work_experience',
        jsonRootMany: 'work_experiences'
      }
    });
  };

  FamilyMember = function(restmod, RMUtils, $Evt) {
    return FamilyMember = restmod.model().mix('nbRestApi', {
      birthday: {
        decode: 'nbDate'
      },
      $hooks: {
        'after-create': function() {
          return $Evt.$send('FamilyMember:create:success', "家庭成员创建成功");
        },
        'after-update': function() {
          return $Evt.$send('FamilyMember:update:success', "家庭成员更新成功");
        },
        'after-destroy': function() {
          return $Evt.$send('FamilyMember:update:success', "家庭成员删除成功");
        }
      },
      $config: {
        jsonRootSingle: 'family_member',
        jsonRootMany: 'family_members'
      }
    });
  };

  Resume = function(restmod, RMUtils, $Evt) {
    return Resume = restmod.model().mix('nbRestApi', {
      $config: {
        jsonRoot: 'employee'
      }
    });
  };

  resources.factory('User', ['restmod', 'RMUtils', '$nbEvent', User]);

  resources.factory('Education', ['restmod', 'RMUtils', '$nbEvent', Education]);

  resources.factory('Experience', ['restmod', 'RMUtils', '$nbEvent', Experience]);

  resources.factory('FamilyMember', ['restmod', 'RMUtils', '$nbEvent', FamilyMember]);

  resources.factory('Resume', ['restmod', 'RMUtils', '$nbEvent', Resume]);

}).call(this);
