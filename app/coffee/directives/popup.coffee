angular.module 'nb.directives'
    .directive 'nbPopup', ['$window', ($window) ->

        class PopupController

            @.$inject = ['$scope', '$element', '$transclude']

            constructor: (@$scope, $elem, $transcludeFn) ->


        postLink = (scope, elem, attrs, $ctrl, $transcludeFn) ->

            $doc = angular.element $window.document
            scope.isShown = false
            tipElement = elem.next()
            tipElement.append '<span class="triangle-border"></span>'
            tipElement.append '<span class="triangle-content"></span>'
            triangleBorder = tipElement.find(".triangle-border")
            triangleContent = tipElement.find(".triangle-content")
            options = {scope: scope}
            options.position = "left"
            options.space = 16
            options.triangleHeight = 14
            angular.forEach ['position', 'space', 'triangleHeight'], (key)->
                if angular.isDefined attrs[key]
                    options[key] = attrs[key]
            toggle = (element)->
                if scope.isShown then hide(element) else show(element)
            show = (element)->
                element.show()
                # 重新定位，解决按钮位置被挤出后popover位置错乱的BUG
                position = calcPosition elem
                setTriangleClass(tipElement.outerWidth(), tipElement.outerHeight())
                tipElement.css {top: position.top + 'px', left: position.left + 'px'}
                #end
                scope.isShown = true
                $doc.on 'click', (e)->
                    e.stopPropagation()
                    hide element

            hide = (element)->
                element.hide()
                scope.isShown = false
                $doc.off "click"

            getPosition = (element) ->
                return {
                    left: element.position().left,
                    top: element.position().top
                }

            setTriangleClass = (tipWidth, tipHeight) ->
                triangleBorder.css {
                    position: 'absolute',
                    'border-style': 'solid',
                    'border-width': options.triangleHeight + 'px',
                    width:0,
                    height:0
                }
                triangleContent.css {
                    position: 'absolute',
                    'border-width': options.triangleHeight + 'px',
                    'border-style': 'solid',
                    width:0,
                    height:0
                }
                if options.position == "bottom"
                    triangleBorder.css {
                        left: (tipWidth/2 - options.triangleHeight) + 'px',
                        top: "-#{2*options.triangleHeight+1}px",
                        'border-color': 'transparent transparent #bbb transparent'
                    }
                    triangleContent.css {
                        left: (tipWidth/2 - options.triangleHeight) + 'px',
                        top: "-#{2*options.triangleHeight}px",
                        'border-color': 'transparent transparent #fff transparent'
                    }
                else if options.position == "top"
                    triangleBorder.css {
                        left: (tipWidth/2 - options.triangleHeight) + 'px',
                        top: tipHeight-1+'px',
                        'border-color': '#ccc transparent transparent transparent'
                    }
                    triangleContent.css {
                        left: (tipWidth/2 - options.triangleHeight) + 'px',
                        top: tipHeight-2+'px',
                        'border-color': '#fff transparent transparent transparent'
                    }
                else if options.position == "left"
                    triangleBorder.css {
                        left: tipWidth-1 + 'px',
                        top: (tipHeight/2 - options.triangleHeight-2) + "px",
                        'border-color': 'transparent transparent transparent #ccc'
                    }
                    triangleContent.css {
                        left: tipWidth-2 + 'px',
                        top: (tipHeight/2 - options.triangleHeight-2) + "px",
                        'border-color': 'transparent transparent transparent #fff'
                    }
                else
                    triangleBorder.css {
                        left: "-#{2*options.triangleHeight}px",
                        top: (tipHeight/2 - options.triangleHeight-2) + "px",
                        'border-color': 'transparent #ccc transparent transparent'
                    }
                    triangleContent.css {
                        left: "-#{2*options.triangleHeight-1}px",
                        top: (tipHeight/2 - options.triangleHeight-2) + "px",
                        'border-color': 'transparent #fff transparent transparent'
                    }

            calcPosition = (element) ->
                elemWidth = element.outerWidth()
                elemHeight = element.outerHeight()
                elemPosition = getPosition(element)
                tipWidth = tipElement.outerWidth()
                tipHeight = tipElement.outerHeight()

                if options.position == "bottom"
                    return {
                        top: elemPosition.top + elemHeight + options.space,
                        left: elemPosition.left + elemWidth/2 - tipWidth/2
                    }
                else if options.position == "top"
                    return {
                        top: elemPosition.top - options.space - tipHeight,
                        left: elemPosition.left + elemWidth/2 - tipWidth/2
                    }
                else if options.position == "left"
                    return {
                        top: elemPosition.top + elemHeight/2 - tipHeight/2,
                        left: elemPosition.left - tipWidth - options.space
                    }
                else
                    return {
                        top: elemPosition.top + elemHeight/2 - tipHeight/2,
                        left: elemPosition.left + elemWidth + options.space
                    }

            
            hide tipElement
            elem.on 'click', (e)->
                e.stopPropagation()
                toggle elem.next()

            scope.$on '$destroy', ()->
                $doc.off 'click'
                elem.off 'click'





        return {
            transclude: true
            controller: PopupController
            templateUrl: 'partials/common/popup.html'
            link: postLink
        }

    ]



