require './simditor.coffee'
require './tagsinput.js'
require './slimscroll.coffee'


angular.module 'vx.directives', ['simditor','bootstrap-tagsinput','slimscroll']

    .directive 'fileread', [() ->
        return:
            scope:
                fileread: '='
            link: (scope,elem,attr) ->
                elem.on 'change', (evt) ->
                    scope.$apply () ->
                        scope.fileread = evt.target.files[0]
    ]
    .directive 'focusMe', ['$timeout','$parse',($timeout,$parse) ->
        return {
            scope: {
                focusMe: '='
            }
            link: (scope,elem,attr) ->
                scope.$watch 'focusMe',(value)->
                    if value == true
                        $timeout(() ->
                            elem[0].focus()
                        ,10)
                elem.on 'blur', () ->
                    scope.focusMe = false
        }
    ]



# var pos = (el && el.size() > 0) ? el.offset().top : 0;

#  if (el) {
#     if ($('body').hasClass('page-header-fixed')) {
#         pos = pos - $('.page-header').height();
#     }
#     pos = pos + (offeset ? offeset : -1 * el.height());
# }

# $('html,body').animate({
#     scrollTop: pos
# }, 'slow');

# app.directive('focusMe', function($timeout, $parse) {
#   return {
#     //scope: true,   // optionally create a child scope
#     link: function(scope, element, attrs) {
#       var model = $parse(attrs.focusMe);
#       scope.$watch(model, function(value) {
#         console.log('value=',value);
#         if(value === true) {
#           $timeout(function() {
#             element[0].focus();
#           });
#         }
#       });
#       // to address @blesh's comment, set attribute value to 'false'
#       // on blur event:
#       element.bind('blur', function() {
#          console.log('blur');
#          scope.$apply(model.assign(scope, false));
#       });
#     }
#   };
# })