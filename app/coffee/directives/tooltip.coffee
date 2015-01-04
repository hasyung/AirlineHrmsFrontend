angular.module 'nb.directives'
    .provider 'nbTooltip', [()->
        defaultOptions = {
            template:""
            title: ""
            content: ""
            container: ""
            html: true
            animation: ""
            customClass: ""
            autoClose: true
            position: "right"

        }
        this.$get  = ['$window', '$rootScope', '$compile', '$q', '$templateCache', '$http', '$timeout', ($window, $rootScope, $compile, $q, $templateCache, $http, $timeout)->
            trim = String.prototype.trim
            $body = angular.element $window.document
            fetchTemplate = (templateUrl) ->
                return $q.when($templateCache.get(templateUrl) || $http.get(templateUrl)).then (res)->
                    if angular.isObject res
                        $templateCache.put templateUrl, res.data
                        return res.data
                    return res

            return (element, config)->

                nbTooltip = {}
                options = nbTooltip.$options = angular.extend {}, defaultOptions, config
                scope = nbTooltip.$scope = options.scope && options.scope.$new() || $rootScope.$new()

                nbTooltip.$scope.title = options.title if options.title

                nbTooltip.$scope.content = options.content if options.content
                # 加载模板
                nbTooltip.$promise = fetchTemplate options.template

                tipLinker = tipElement = tipContainer = tipTemplate = undefined
                nbTooltip.$promise.then (template)->

                    template = template.data if angular.isObject template

                    template = template.replace /ng-bind="/ig, 'ng-bind-html="' if options.html
                    template = trim.apply template
                    tipTemplate = template
                    tipLinker = $compile template
                    #nbTooltip.init()

                #todo
                nbTooltip.init = ()->
                    if options.container == 'self'
                        tipContainer = element
                    else if angular.isElement options.container
                        tipContainer = options.container
                    else if options.container
                        tipContainer = findElement options.container


                nbTooltip.toggle = ()->
                    if nbTooltip.$isShown then nbTooltip.hide() else nbTooltip.show()


                nbTooltip.hide = ()->
                    return if !nbTooltip.$isShown

                    nbTooltip.$isShown  = scope.$isShown = false
                    tipElement.remove()
                    if options.autoClose && tipElement
                        $body.off 'click'
                        tipElement.off 'click'
                nbTooltip.show = ()->
                    parent = if options.container then tipContainer else null
                    after = if options.container then null else element

                    tipElement.remove() if tipElement

                    tipElement = nbTooltip.$element = tipLinker scope

                    tipElement.addClass options.animation if options.animation

                    tipElement.addClass options.customClass if options.customClass

                    tipElement.css({top: -9999 + 'px', left: -99999 + 'px', position:'absolute', display: 'block', visibility: 'hidden', 'background-color':'#ff0','z-index':'1000000'})
                    element.after(tipElement)
                    position = calcPosition element

                    tipElement.css {top: position.top + 'px', left: position.left + 'px', visibility: 'visible'}
                    nbTooltip.$isShown = scope.$isShown = true


                    if options.autoClose
                        $timeout ()->
                            tipElement.on 'click', (e)->
                                event.stopPropagation()
                            $body.on 'click', ()->
                                if nbTooltip.$isShown
                                    nbTooltip.hide()
                        , 0


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
                            top: elemPosition.top + elemHeight + 5,
                            left: elemPosition.left + elemWidth/2 - tipWidth/2
                        }
                    else if options.position == "top"
                        return {
                            top: elemPosition.top - 5 - tipHeight,
                            left: elemPosition.left + elemWidth/2 - tipWidth/2
                        }
                    else if options.position == "left"
                        return {
                            top: elemPosition.top + elemHeight/2 - tipHeight/2,
                            left: elemPosition.left - tipWidth - 5
                        }
                    else
                        return {
                            top: elemPosition.top + elemHeight/2 - tipHeight/2,
                            left: elemPosition.left + elemWidth + 5
                        }



                return nbTooltip

        ]
        return

    ]

