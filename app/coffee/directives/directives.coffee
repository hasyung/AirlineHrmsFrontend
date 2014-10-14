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