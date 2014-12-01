angular.module 'nb.directives', []

    .provider 'nbTooltip', [()->
        defaultOptions = {
            template:""
            title: ""
            content: ''
            container: ""
            html: true
            animation: ""
            customClass: ""
            autoClose: true
            position: "left"

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

                if options.title
                    nbTooltip.$scope.title = options.title

                if options.content
                    nbTooltip.$scope.content = options.content
                # 加载模板
                nbTooltip.$promise = fetchTemplate options.template

                tipLinker = tipElement = tipContainer = tipTemplate =undefined
                nbTooltip.$promise.then (template)->
                    if angular.isObject template
                        template = template.data
                    if options.html
                        template = template.replace /ng-bind="/ig, 'ng-bind-html="'
                    template = trim.apply template
                    tipTemplate = template
                    tipLinker = $compile(template)
                    nbTooltip.init()


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
                    if !nbTooltip.$isShown
                        return
                    nbTooltip.$isShown  = scope.$isShown = false
                    tipElement.remove()
                    if options.autoClose && tipElement
                        $body.off 'click'
                        tipElement.off 'click'
                nbTooltip.show = ()->
                    parent = if options.container then tipContainer else null
                    after = if options.container then null else element
                    if tipElement 
                        tipElement.remove()
                        tipElement = undefined
                    tipElement = nbTooltip.$element = tipLinker scope

                    if options.animation
                        tipElement.addClass options.animation
                    if options.customClass
                        tipElement.addClass options.customClass

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
                if attr.toggleClass
                    toggleText = attr.toggleClass
                else
                    toggleText = 'active'
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
            priority: 10
            scope: {

            }
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
                        console.log scope.title

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

    # .directive 'nbDropdown', [()->
    #     return {
    #         restrict: 'AC'
    #         templateUrl: 'partials/common/_dropdown.tpl.html'
    #         replace: true
    #         link: (scope, elem, attr) ->

    #     }
    # ]

    .directive 'organTree', [() ->
        # canvasW = 600
        # canvasH = 500
        nodeWidth = 100
        nodeHeight = 50
        rowHeight = 50
        colWidth = 30
        getNodeData = () ->
            return [
                [
                    {id:'1', data: {text:"四川航空"}}
                ],
                [
                    {id:'1.1', data: {text:"人力资源部"}},
                    {id:'1.2', data: {text:"信息技术部"}},
                    {id:'1.3', data: {text:"地勤保障部"}},
                    {id:'1.4', data: {text:"空乘服务部"}}
                ],
                [
                    {id:'1.1.1', data: {text:"薪酬福利室"}},
                    {id:'1.1.2', data: {text:"培训室"}},
                    {id:'1.1.3', data: {text:"办公室"}},
                    {id:'1.1.4', data: {text:"人力资源管理室"}},
                    {id:'1.2.1', data: {text:"测试部"}},
                    {id:'1.2.2', data: {text:"研发部"}},
                    {id:'1.2.3', data: {text:"运维部"}},
                    {id:'1.3.1', data: {text:"安保部"}},
                    {id:'1.3.2', data: {text:"安检部"}},
                    {id:'1.3.3', data: {text:"机场部"}},
                ],
                [
                    {id:'1.1.1', data: {text:"人力资源部"}},
                    {id:'1.1.2', data: {text:"信息技术部"}},
                    {id:'1.1.3', data: {text:"地勤保障部"}},
                    {id:'1.1.4', data: {text:"空乘服务部"}},
                    {id:'1.2.1', data: {text:"人力资源部"}},
                    {id:'1.2.2', data: {text:"信息技术部"}},
                    {id:'1.2.3', data: {text:"地勤保障部"}},
                    {id:'1.3.1', data: {text:"空乘服务部"}},
                    {id:'1.3.2', data: {text:"空乘服务部"}},
                    {id:'1.3.3', data: {text:"空乘服务部"}},
                ],
            ]

        analysisNode = (data) ->
            angular.forEach data, (item)->
        createNode = (ctx, px, py, width, height)->
            ctx.fillRect(px, py, width, height)
        drawTree = (ctx)->       
            # draw root 
            px = (ctx.canvas.clientWidth - nodeWidth)/2
            createNode ctx, px, rowHeight/2, nodeWidth, nodeHeight
            # draw the first row

        return {
            scope: {}
            restrict: 'A'
            link: (scope,elem,attr) ->
                context = elem[0].getContext('2d')
                context.fillStyle = "#fff"
                console.log context
                # context.globalAlpha=0;
                # createNode(context, 0, 0, nodeWidth, nodeHeight)
                drawTree context

        }
    ]






    # the legacy code
    # .directive 'fileread', [() ->
    #     return:
    #         scope:
    #             fileread: '='
    #         link: (scope,elem,attr) ->
    #             elem.on 'change', (evt) ->
    #                 scope.$apply () ->
    #                     scope.fileread = evt.target.files[0]
    # ]
    # .directive 'focusMe', ['$timeout','$parse',($timeout,$parse) ->
    #     return {
    #         scope: {
    #             focusMe: '='
    #         }
    #         link: (scope,elem,attr) ->
    #             scope.$watch 'focusMe',(value)->
    #                 if value == true
    #                     $timeout(() ->
    #                         elem[0].focus()
    #                     ,10)
    #             elem.on 'blur', () ->
    #                 scope.focusMe = false
    #     }
    # ]
