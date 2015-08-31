app = nb.app

class FormHelperController extends nb.Controller
  @.$inject = ['$scope', '$enum']

  constructor: (@scope, @enum)->
    #

  analysisIdentityNo: (identityNo, object)->
    return unless identityNo.length == 15 || identityNo.length == 18
    genders = @enum.get('genders')

    if identityNo.length == 15
      object.birthday = "19" + identityNo.slice(6, 8) + "-" + identityNo.slice(8, 10)  + "-" + identityNo.slice(10, 12)

      if parseInt(identityNo[14]) % 2 == 0
        result = _.find genders, (item)-> item.label == '女'
        object.genderId = result.id if result
      else
        result = _.find genders, (item)-> item.label == '男'
        object.genderId = result.id if result

    if identityNo.length == 18
      object.birthday = identityNo.slice(6, 10) + "-" + identityNo.slice(10, 12) + "-" + identityNo.slice(12, 14)

      if parseInt(identityNo[16]) % 2 == 0
        result = _.find genders, (item)-> item.label == '女'
        object.genderId = result.id if result
      else
        result = _.find genders, (item)-> item.label == '男'
        object.genderId = result.id if result

app.controller('formHelperCtrl', FormHelperController)