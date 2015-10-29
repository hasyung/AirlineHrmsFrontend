app = @nb.app

class SideMenuController
  @.$inject = ['$scope', '$http', 'menu', 'CURRENT_ROLES', 'ROLES_MENU_CONFIG']

  constructor: ($scope, $http, menu, CURRENT_ROLES, ROLES_MENU_CONFIG) ->
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
        pages.indexOf(item.name + '@' + page.name) >= 0


app.controller('sideMenuCtrl', SideMenuController)