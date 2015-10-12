(function() {
  var SideMenuController, app;

  app = this.nb.app;

  SideMenuController = (function() {
    SideMenuController.$inject = ['$scope', '$http', 'menu', 'CURRENT_ROLES', 'ROLES_MENU_CONFIG'];

    function SideMenuController($scope, $http, menu, CURRENT_ROLES, ROLES_MENU_CONFIG) {
      var keys, pages;
      keys = Object.keys(ROLES_MENU_CONFIG);
      pages = [];
      angular.forEach(ROLES_MENU_CONFIG, function(array, key) {
        return angular.forEach(array, function(page) {
          return pages.push(key + '@' + page);
        });
      });
      menu.sections = _.filter(menu.sections, function(item) {
        return keys.indexOf(item.name) >= 0;
      });
      menu.sections = angular.forEach(menu.sections, function(item) {
        return item.pages = _.filter(item.pages, function(page) {
          return pages.indexOf(item.name + '@' + page.name) >= 0;
        });
      });
    }

    return SideMenuController;

  })();

  app.controller('sideMenuCtrl', SideMenuController);

}).call(this);
