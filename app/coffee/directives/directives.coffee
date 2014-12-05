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
    .directive 'npPopup', [ () ->
        postLink = (scope, elem, attrs) ->

        return {
            transclude: true
            template: '''
                <div class="parent">
                    <div nb-popup-transclude></div>
                </div>
            '''
            link: postLink
        }

    ]
    .directive 'nbPopupTransclude', [ ()->

        postLink = (scope, elem, attrs, $ctrl, $transcludeFn) ->

            $transcludeFn (clone) ->
                console.debug "transcludeFn args:", arguments



        return {
            require: '^npPopup'
            link: postLink
        }

    ]

    .directive 'nbDropdown', ['$http', ($http)->
        return {
            restrict: 'AC'
            templateUrl: 'partials/common/_dropdown.tpl.html'
            replace: true
            require: "ngModel"
            scope: {
                options: "=nbDropdown"
                selected: "=ngModel"
            }
            controller: ($scope) ->
                $scope.defaultText = $scope.options.defaultText
                $scope.items = $scope.options.data
                $scope.setSelected = (index) ->
                    $scope.selected = $scope.options.data[index]

            link: (scope, elem, attr, ctrl) ->
                scope.isOpen = false
                elem.on 'click', (e) ->
                    e.preventDefault()
                    if scope.isOpen then elem.removeClass 'open' else elem.addClass 'open'
                    scope.isOpen = ! scope.isOpen


                # attr.required && ctrl && ctrl.$validators.required
                if attr.key
                    $http.get('/api/enum?key=' + attr.key).success (data, status) ->
                        scope.items = data
                    .error (data, status) ->
                        scope.items = [
                            {
                                key: 'ORG.'
                                name: 'chengdu'
                                display_name: '成都'
                            }
                            {
                                key: 'ORG.'
                                name: 'shanghai'
                                display_name: '上海'
                            }
                        ]

                scope.$on '$destroy', ()->
                    elem.off 'click'

                return



        }
    ]





