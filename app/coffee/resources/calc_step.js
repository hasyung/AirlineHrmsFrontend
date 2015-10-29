(function() {
  var CalcStep, resources;

  resources = angular.module('resources');

  CalcStep = function(restmod, RMUtils, $Evt) {
    return restmod.model('/calc_steps').mix('nbRestApi', 'DirtyModel', {
      createdAt: {
        decode: 'date',
        param: 'yyyy-MM-dd',
        mask: 'CU'
      },
      owner: {
        belongsTo: 'Employee',
        key: 'employee_id'
      }
    });
  };

  resources.factory('CalcStep', ['restmod', 'RMUtils', '$nbEvent', CalcStep]);

}).call(this);
