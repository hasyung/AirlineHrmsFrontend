app = nb.app

class FormHelperController extends nb.Controller
  @.$inject = ['$scope']

  constructor: ($scope)->
    #

app.controller('formHelperCtrl', FormHelperController)