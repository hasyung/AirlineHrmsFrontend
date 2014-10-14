angular.module 'slimscroll',[]
    .constant 'slimscrollConfig', {
        allowPageScroll: true, # allow page scroll when the element scroll is ended
        size: '7px',
        color: '#bbb'
        # wrapperClass: 'slimScrollDiv'
        railColor: '#eaeaea'
        position: 'right'
        height: '250px'
        alwaysVisible: false
        railVisible: false
        disableFadeOut: true
    }
    .directive 'slimscroll', ['slimscrollConfig',(slimscrollConfig) ->

        return {
            restrict: 'A'
            replace: true
            # require: 'ngModel'
            scope: true
            link: (scope,elem,attr) ->
                opts = {}

                angular.forEach ['height','wrapperClass','railColor','position'], (key) ->
                  opts[key] = attr[key]  if angular.isDefined attr[key]

                opts = angular.extend {},slimscrollConfig,opts

                elem.slimScroll(opts)

                scope.$on '$destory', () ->
                    elem.slimscroll {
                        destory: true
                    }
        }

    ]


# angular.module('ui.slimscroll', []).directive('slimscroll', function() {
#   return {
#     restrict: 'A',
#     link: function($scope, $elem, $attr) {
#       var option = {};
#       var refresh = function() {
#         if ($attr.slimscroll) {
#           option = $scope.$eval($attr.slimscroll);
#         } else if ($attr.slimscrollOption) {
#           option = $scope.$eval($attr.slimscrollOption);
#         }
#         $elem.slimScroll({ destroy: true });
#         $elem.slimScroll(option);
#       };

#       refresh();

#       if ($attr.slimscroll && !option.noWatch) {
#         $scope.$watchCollection($attr.slimscroll, refresh);
#       }

#       if ($attr.slimscrollWatch) {
#         $scope.$watchCollection($attr.slimscrollWatch, refresh);
#       }

#       if ($attr.slimscrollListenTo) {
#         $scope.on($attr.slimscrollListenTo, refresh);
#       }
#     }

