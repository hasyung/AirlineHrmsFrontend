angular.module 'nb.directives'
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
            link: (scope,elem,attr) ->
                opts = {}

                angular.forEach ['height','wrapperClass','railColor','position'], (key) ->
                  opts[key] = attr[key]  if angular.isDefined attr[key]

                opts = angular.extend {},slimscrollConfig,opts

                elem.slimScroll(opts)

                scope.$on '$destroy', () ->
                    elem.slimscroll {
                        destroy: true
                    }
        }

    ]