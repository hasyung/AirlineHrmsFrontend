class PopupController

    @.$inject = ['$scope', '$element', '$transclude']

    constructor: (@scope, $elem, $transcludeFn) ->
        # $transcludeFn (clone) ->
        #     console.debug clone

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

    .directive 'toggleClass', [() ->
        return {
            scope: {}
            restrict: 'A'
            link: (scope,elem,attr) ->
                toggleText = if attr.toggleClass then attr.toggleClass else 'active'

                # for nav list
                elem.on 'click', (event) ->
                    event.preventDefault()
                    elem.toggleClass toggleText
        }
    ]
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
    .directive 'nbPopup', [ () ->


                    # console.debug $elem.html()





        postLink = (scope, elem, attrs, $ctrl, $transcludeFn) ->
            console.debug arguments

            # $transcludeFn (clone) ->
            #     TemplateBody = clone.filter 'popup-template'
            #     elem.append(TemplateBody)


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
                console.debug elem.html()
                console.debug clone
                elem.replaceWith( clone.not('popup-template'))


        return {
            restrict: 'EA'
            require: '^nbPopup'
            link: postLink
        }

    ]




    .directive 'nbDropdown', ['$http', ($http)->


        class DropdownCtrl
            @.$inject = ['$http','$attrs','$scope', 'inflector']
            constructor: (@http, @attrs, @scope, @inflector) ->
                self = @
                @scope.isOpen = false

                onSuccess = (data, status) ->
                    self.options = data.result

                onError = ->
                    @scope.$emit('dropdown:notfound')


                @http.get("/api/enum?key=#{@attrs.remoteKey}")
                    .success onSuccess
                    .error onError
            setSelected: ($index) ->
                # @selected = _.clone @options[$index]
                # @scope.selected = _.clone @options[$index]
                # @scope.$apply () ->
                inflector = @inflector
                @selected = _.clone @options[$index]
                # @scope.$emit('select:change', selected)
                # @scope.$emit('options:change', @selected)
                @close()

                # @scope.$digest()
            addItem: (newItem) ->
                @options.push(newItem)
                @setSelected(_.findIndex(@options,newItem))

            toggle: () ->
                @isOpen = !@isOpen

            close: () ->
                @isOpen = false

        postLink = (scope, elem, attr, $ctrl) ->
            scope.isOpen = false
            dropdownCtrl = $ctrl[0]
            ngModelCtrl = $ctrl[1]

            # view to model
            # ngModelCtrl.$parsers.unshift (inputVal) ->
            #     console.debug "inputVal:", arguments
            #     return inputVal
            # # model to view
            # ngModelCtrl.$formatters.unshift (inputVal) ->
            #     console.debug "formatters : ", inputVal
            #     return inputVal

            scope.$watch 'dropdown.selected', (newVal) ->
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
    # .directive 'nbSelect', ['$http', ($http) ->


    #     postLink = (scope, elem, attrs, $ctrl) ->

    #         key = attrs['remoteKey']

    #         $http.get("api/enum?key=#{key}")
    #             .success (data, status) ->
    #                 $ctrl.






    #     return {
    #         required: 'ngModel'
    #         link: postLink
    #         scope: {

    #         }
    #     }




    # ]

