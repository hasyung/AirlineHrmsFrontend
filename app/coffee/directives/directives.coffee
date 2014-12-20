
angular.module 'nb.directives', []

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


    .directive 'navToggleActive', [() ->
        return {
            scope: {}
            restrict: 'A'
            link: (scope,elem,attr) ->
                elem.on 'click', '.auto', (event) ->
                    event.preventDefault()
                    elem.toggleClass 'active'
        }
    ]
    #存在缺陷，有待优化
    # .directive 'toggleClass', [() ->
    #     return {
    #         scope: {}
    #         restrict: 'A'
    #         link: (scope,elem,attr) ->
    #             toggleText = if attr.toggleClass then attr.toggleClass else 'active'
    #             actionElement = {}

    #             if attr.actionClass
    #                 actionElement = elem.find('.' + attr.actionClass)
    #             else
    #                 actionElement = elem
    #             if attr.toggleElement
    #                 elem.on 'click', '.' + attr.toggleElement, (event) ->
    #                     event.preventDefault()
    #                     elem.toggleClass 'in-active'
    #                     actionElement.toggleClass toggleText
    #             else
    #                 elem.on 'click', (event) ->
    #                     event.preventDefault()
    #                     elem.toggleClass 'in-active'
    #                     actionElement.toggleClass toggleText
    #     }
    # ]
    .directive 'nbCheck', [()->
        return {
            restrict: 'AC'
            priority: 1
            controller: ($scope, $http)->
                #todo
                this.check = ()->

            link: (scope, elem, attr) ->

                elem.on 'click', (e)->
                    console.log "click check"
                    e.preventDefault()

        }
    ]
    .directive 'nbConfirm', ['nbTooltip', '$sce' , (nbTooltip, $sce)->
        return {
            restrict: 'AC'
            require: '?nbCheck'
            transclude: true
            replace: true
            priority: 10
            scope: {

            }
            # controller: ($element, $transclude) ->
            #     $transclude (cloned, scope) ->

            link: (scope, elem, attrs, nbCheckCtrl) ->
                options = {scope: scope}
                angular.forEach ['template', 'contentTemplate', 'container', 'html', 'animation', 'customClass', 'position'], (key)->
                    if angular.isDefined attrs[key]
                        options[key] = attrs[key]

                nbConfirm = nbTooltip(elem, options)
                attrs.$observe 'title', (newValue)->
                    if angular.isDefined newValue || !scope.hasOwnProperty 'title'
                        oldValue = scope.title
                        scope.title = $sce.trustAsHtml(newValue)

                elem.on 'click', (e)->
                    e.preventDefault()
                    nbConfirm.toggle()
                    #if need check
                    if attrs.nbCheck
                        #check first
                        nbCheckCtrl.check()
                    #default confirm
                    else

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

            position = calcPosition elem
            setTriangleClass(tipElement.outerWidth(), tipElement.outerHeight())
            tipElement.css {top: position.top + 'px', left: position.left + 'px'}
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

    # .directive 'popupTemplate', [ ()->

    #     postLink = (scope, elem, attrs) ->
    #         console.debug arguments
    #         console.debug 'template'
    #         # $transcludeFn (clone) ->
    #         #     console.debug "transcludeFn args:", arguments

    #     return {
    #         transclude: true
    #         restrict: 'EA'
    #         require: '^?nbPopup'
    #         controller: ->
    #         template: '''<div nb-popup-transclude></div>'''
    #         link: postLink
    #     }
    # ]
    .directive 'nbPopupTransclude', [ () ->


        # class PopupTransclude

        #     @.$inject = ['$scope', '$element', '$transclude']

        #     constructor: (@scope, $elem, $transcludeFn) ->
        #         $transcludeFn (clone) ->
        #             console.debug arguments
        #             templateBlock = clone.filter('[popup-template]')
        #             $elem.append templateBlock.html()


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
            require: '^nbPopup'
            link: postLink
        }

    ]




    .directive 'nbDropdown', ['$http', 'inflector', ($http, inflector)->


        class DropdownCtrl
            @.$inject = ['$http','$attrs','$scope']
            constructor: (@http, @attrs, @scope) ->
                self = @
                @scope.isOpen = false
                @options = []
                @scope.additory = true

                onSuccess = (data, status) ->
                    self.options = _.map data.result, (item) ->
                        _.reduce(item, (res, val, key) ->
                            res[inflector.camelize(key)] = val
                            return res
                        , {})

                onError = ->
                    self.scope.$emit('dropdown:notfound')

                @http.get("/api/enum?key=#{@attrs.remoteKey}")
                    .success onSuccess
                    .error onError
            setSelected: ($index) ->
                # @selected = _.clone @options[$index]
                # @scope.selected = _.clone @options[$index]
                # @scope.$apply () ->
                @scope.selected = _.clone @options[$index]
                # @scope.$emit('select:change', selected)
                # @scope.$emit('options:change', @selected)
                @close()

                # @scope.$digest()
            addItem: (evt, form , newItem) ->
                evt.preventDefault()
                @options.push(newItem)
                @options = _.uniq(@options)
                @setSelected(@options.length - 1)
                @newItem = ""
                form.$setPristine()


            toggle: () ->
                @isOpen = !@isOpen

            close: () ->
                @isOpen = false

        postLink = (scope, elem, attr, $ctrl) ->
            scope.isOpen = false
            scope.additory = ((attr.additory || "true") is "true")
            dropdownCtrl = $ctrl[0]
            ngModelCtrl = $ctrl[1]
            elem.on 'click', ()->
                ngModelCtrl.$touched = true
            # view to model
            # ngModelCtrl.$parsers.unshift (inputVal) ->
            #     console.debug "inputVal:", arguments
            #     return inputVal
            # # model to view
            # ngModelCtrl.$formatters.unshift (inputVal) ->
            #     console.debug "formatters : ", inputVal
            #     return inputVal

            scope.$watch 'selected', (newVal) ->
                console.debug 'selected:change', newVal
                scope.selected = newVal
                ngModelCtrl.$render()

            scope.$on '$destroy', () ->
                elem.off 'click'

        return {
            restrict: 'EA'
            templateUrl: 'partials/common/dropdown.tpl.html'
            replace: true
            require: ["nbDropdown", "ngModel"]
            scope: {
                options: "=nbDropdown"
                selected: "=ngModel"
            }
            controller: DropdownCtrl
            controllerAs: 'dropdown'

            link: postLink

        }
    ]
    .directive 'dragOn', [ '$window', ($window) ->


        postLink = (scope, elem, attrs)->

            return if not jQuery.fn.dragOn
            $window.dragOnElem = elem.dragOn()
            scope.$on 'destroy', () ->
                elem.trigger 'DragOn.remove'

        return {
            link: postLink
        }


    ]
    .directive 'loadingBtn', ['$timeout', ($timeout) ->


        postLink = (scope, elem, attrs, $ctrl, $transcludeFn) ->

            scope.clz  = attrs.class
            scope.loadingType = attrs.btnLoadingType || 'slide-up'
            scope.dataLoading = false
            scope.content = attrs.btnText

            disableDataLoading = ->
                scope.$apply ()->
                    scope.dataLoading = false

            elem.on 'click', () ->
                scope.$apply ()->
                    scope.dataLoading = true

            scope.$on 'data:loaded', () ->
                scope.$apply ()->
                    scope.dataLoading = false

            scope.$on '$destroy', () ->
                elem.off 'click'



        return {
            templateUrl: 'partials/component/loading-btn/btn.html'
            scope: true
            link: postLink
            # transclude: true

        }

    ]
    .directive 'nbLoading', ['$rootScope', (rootScope) ->

        postLink = (scope, elem, attrs) ->


        return {
            templateUrl: 'partials/component/loading.html'
            link: postLink
        }

    ]




