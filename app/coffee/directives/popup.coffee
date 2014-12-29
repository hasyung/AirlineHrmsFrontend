angular.module 'nb.directives'
    .directive 'nbPopup', ['$window', ($window) ->

        class PopupController

            @.$inject = ['$scope', '$element', '$transclude']

            constructor: (@$scope, $elem, $transcludeFn) ->

        postLink = (scope, elem, attrs, $ctrl, $transcludeFn) ->

            $doc = angular.element $window.document
            scope.isShown = false
            tipElement = elem.next()
            tipElement.append '<span class="arrow"></span>'
            options = {scope: scope}
            options.position = "left"
            # popup提示框和按钮之间的距离
            options.space = 12
            angular.forEach ['position', 'space'], (key)->
                if angular.isDefined attrs[key]
                    options[key] = attrs[key]

            # css中向三角形添加样式需要知道模板的定位
            tipElement.addClass options.position
            toggle = (element)->
                if scope.isShown then hide(element) else show(element)
            show = (element)->
                element.show()
                # 重新定位，解决按钮位置被挤出后popover位置错乱的BUG
                position = calcPosition elem
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
                else if options.position == "right"
                    return {
                        top: elemPosition.top + elemHeight/2 - tipHeight/2,
                        left: elemPosition.left + elemWidth + options.space
                    }
                else
                    throw Error('position only support left, right, bottom, top!')

            # 加载时隐藏提示框
            hide tipElement

            elem.on 'click', (e)->
                e.stopPropagation()
                toggle elem.next()

            scope.$on '$destroy', ()->
                $doc.off 'click'
                elem.off 'click'
                tipElement = null

        return {
            transclude: true
            controller: PopupController
            templateUrl: 'partials/common/popup.html'
            link: postLink
        }

    ]