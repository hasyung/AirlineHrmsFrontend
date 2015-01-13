angular.module 'nb.directives'
    .directive 'nbPopupTransclude', [ () ->

        postLink = (scope, elem, attrs, $ctrl, $transcludeFn) ->
            $transcludeFn (clone) ->
                templateBlock = clone.filter('popup-template')
                elem.parent().parent().after templateBlock

        return {
            # controller: PopupTransclude
            restrict: 'AE'
            # require: '^popupTemplate'
            link: postLink
        }

    ]

    .directive 'nbPopupEmbedTransclude', [ ()->

        class EmbedTransclude
            constructor: () ->
        postLink = (scope, elem, attrs, $ctrl, $transcludeFn) ->
            $transcludeFn (clone) ->
                elem.replaceWith( clone.not('popup-template'))


        return {
            restrict: 'EA'
            # require: '^nbPopup'
            link: postLink
        }

    ]
    .directive 'nbPopupPlusEmbedTransclude', [ ()->

        class EmbedTransclude
            constructor: () ->
        postLink = (scope, elem, attrs, $ctrl, $transcludeFn) ->
            $transcludeFn (clone) ->
                elem.replaceWith( clone.not('popup-template'))


        return {
            restrict: 'EA'
            # require: '^nbPopupPlus'
            link: postLink
        }

    ]
    .directive 'nbPopup', ['$window', ($window) ->

        class PopupController

            @.$inject = ['$scope', '$element', '$transclude']

            constructor: (@$scope, $elem, $transcludeFn) ->

        postLink = (scope, elem, attrs, $ctrl, $transcludeFn) ->

            $doc = angular.element $window.document
            scope.isShown = false
            tipElement = elem.next()
            tipElement.append '<span class="arrow"></span>'
            tipElement.css {
                'z-index': '1040',
                'background-color': '#fff',
                position: 'absolute';
            }
            options = {scope: scope}
            options.position = "left"
            # popup提示框和按钮之间的距离
            options.space = 12
            angular.forEach ['position', 'space'], (key)->
                if angular.isDefined attrs[key]
                    options[key] = attrs[key]

            # css中向三角形添加样式需要知道模板的定位
            tipElement.addClass options.position
            toggle = ()->
                if scope.isShown then hide() else show()
            show = ()->
                tipElement.show()
                # 重新定位，解决按钮位置被挤出后popover位置错乱的BUG
                position = calcPosition elem
                tipElement.css {
                    top: position.top + 'px',
                    left: position.left + 'px',
                }
                #end
                scope.isShown = true
            

            hide = ()->
                tipElement.hide()
                scope.isShown = false

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
                    # 没有正确的位置信息三角形将无法定位
                    throw Error('position only support left, right, bottom, top!')

            hideHandle = (e) ->
                e.stopPropagation()
                hide()
                # hide() 返回false，将阻止submit按钮的提交事件的触发
                return 


            # 加载时隐藏提示框
            hide()
            
            $doc.on 'click', hideHandle
                
            elem.on 'click', (e)->
                e.stopPropagation()
                toggle()

            scope.$on '$destroy', ()->
                $doc.off 'click', hideHandle
                elem.off 'click'
                tipElement = null

        return {
            transclude: true
            controller: PopupController
            templateUrl: 'partials/common/popup.html'
            link: postLink
        }

    ]

    .directive 'nbPopupPlus', ['$window', ($window) ->
        class PopupPlusController

            @.$inject = ['$scope', '$element', '$transclude']

            constructor: (@$scope, $elem, $transcludeFn) ->

        postLink = (scope, elem, attrs, $ctrl, $transcludeFn) ->

            $doc = angular.element $window.document
            scope.isShown = false
            tipElement = elem.next()
            tipElement.append '<span class="arrow"></span>'
            arrow = tipElement.find(".arrow")
            tipElement.css {
                'z-index': '1040',
                'background-color': '#fff',
                position: 'absolute';
            }
            options = {scope: scope}
            # options.position = "left-bottom"
            options.offset = 0.5
            # popup提示框和按钮之间的距离
            options.space = 12
            #popup的边框
            options.border = 1
            options.arrowBorder = 11
            angular.forEach ['position', 'space', 'offset'], (key)->
                if angular.isDefined attrs[key]
                    options[key] = attrs[key]

            tipElement.addClass options.position.split("-")[0]
            toggle = ()->
                if scope.isShown then hide() else show()
            show = ()->
                tipElement.show()
                # 重新定位，解决按钮位置被挤出后popover位置错乱的BUG
                position = calcPosition elem
                tipElement.css {
                    top: position.pTip.top + 'px',
                    left: position.pTip.left + 'px',
                }
                arrow.css {
                    top: position.pArrow.top + 'px',
                    left: position.pArrow.left + 'px'
                }
                #end
                scope.isShown = true
            

            hide = ()->
                tipElement.hide()
                scope.isShown = false

            calcPosition = (element) ->
                elemWidth = element.outerWidth()
                elemHeight = element.outerHeight()
                #合并代码之后offset()获取到的left值比实际值要大，后续检查，先用暴力方法
                elemPosition = {left: element[0].offsetLeft, top: element[0].offsetTop}
                tipWidth = tipElement.outerWidth()
                tipHeight = tipElement.outerHeight()

                pTip = {}
                pArrow = {}
                switch options.position
                    when 'left-bottom'
                        pTip = {
                            top: elemPosition.top - tipHeight * options.offset + elemHeight/2,
                            left: elemPosition.left - options.space - tipWidth
                        }
                        pArrow = {
                            top: tipHeight * options.offset,
                            left: tipWidth - 2 * options.border
                        }
                    when 'right-bottom'
                        pTip = {
                            top: elemPosition.top - tipHeight * options.offset + elemHeight/2,
                            left: elemPosition.left + elemWidth + options.space
                        }
                        pArrow = {
                            top: tipHeight * options.offset,
                            left: - options.arrowBorder 
                        }
                    when 'left-top'
                        pTip = {
                            top: elemPosition.top - tipHeight * (1 - options.offset) + elemHeight/2,
                            left: elemPosition.left - options.space - tipWidth
                        }
                        pArrow = {
                            top: tipHeight * (1 - options.offset),
                            left: tipWidth - 2 * options.border
                        }
                    when 'right-top'
                        pTip = {
                            top: elemPosition.top - tipHeight * (1 - options.offset) + elemHeight/2,
                            left: elemPosition.left + elemWidth + options.space
                        }
                        pArrow = {
                            top: tipHeight * (1 - options.offset),
                            left: - options.arrowBorder 
                        }
                    when 'top-right'
                        pTip = {
                            top: elemPosition.top - tipHeight - options.space,
                            left: elemPosition.left - tipWidth * options.offset + elemWidth/2
                        }
                        pArrow = {
                            top: tipHeight - 2 * options.border,
                            left: tipWidth * options.offset
                        }
                    when 'top-left'
                        pTip = {
                            top: elemPosition.top - tipHeight - options.space,
                            left: elemPosition.left - tipWidth * (1 - options.offset) + elemWidth/2
                        }
                        pArrow = {
                            top: tipHeight - 2 * options.border,
                            left: tipWidth * (1 - options.offset)
                        }
                    when 'bottom-left'
                        pTip = {
                            top: elemPosition.top + elemHeight + options.space,
                            left: elemPosition.left - tipWidth * (1 - options.offset) + elemWidth/2
                        }
                        pArrow = {
                            top: -options.arrowBorder + options.border,
                            left: tipWidth * (1 - options.offset)
                        }
                    when 'bottom-right'
                        pTip = {
                            top: elemPosition.top + elemHeight + options.space,
                            left: elemPosition.left - tipWidth * options.offset + elemWidth/2
                        }
                        pArrow = {
                            top: -options.arrowBorder + options.border,
                            left: tipWidth * options.offset
                        }
                    
                    else
                        throw Error "only left-top,left-bottom,right-bottom,right-top,top-left,top-right,bottom-left,bottom-right is accepted."
                return {pTip: pTip, pArrow: pArrow}

            hideHandle = (e) ->
                e.stopPropagation()
                hide()
                # hide() 返回false，将阻止submit按钮的提交事件的触发
                return 

            # 加载时隐藏提示框
            hide()
            
            $doc.on 'click', hideHandle
                
            elem.on 'click', (e)->
                e.stopPropagation()
                toggle()

            tipElement.on 'click', (e) ->
                e.stopPropagation()


            scope.$on '$destroy', ()->
                $doc.off 'click', hideHandle
                elem.off 'click'
                tipElement.off 'click'
                tipElement = null

        return {
            transclude: true
            controller: PopupPlusController
            templateUrl: 'partials/common/popup.html'
            link: postLink
        }

    ]