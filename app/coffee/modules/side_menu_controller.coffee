app = @nb.app

class SideMenuController
  @.$inject = ['$scope', '$http', 'menu', 'CURRENT_ROLES', 'ROLES_MENU_CONFIG', 'PERMISSIONS', 'USER_META']

  constructor: ($scope, $http, menu, CURRENT_ROLES, ROLES_MENU_CONFIG, PERMISSIONS, USER_META) ->
    keys = Object.keys(ROLES_MENU_CONFIG)
    pages = []

    angular.forEach ROLES_MENU_CONFIG, (array, key)->
      angular.forEach array, (page)->
        pages.push key + '@' + page

    # nodes
    menu.sections = _.filter menu.sections, (item)->
      keys.indexOf(item.name) >= 0

    # pages
    menu.sections = angular.forEach menu.sections, (item)->
      item.pages = _.filter item.pages, (page)->
        str = item.name + '@' + page.name

        if USER_META.name == 'administrator'
          return true

        if str == "岗位管理@岗位异动记录" && PERMISSIONS.indexOf("position_changes_index") < 0
          return false

        if str == "人事信息@人事变更信息" && PERMISSIONS.indexOf("employee_changes_record") < 0
          return false

        pages.indexOf(str) >= 0


app.controller('sideMenuCtrl', SideMenuController)