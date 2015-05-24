
angular.module 'nb.directives'
    # 左侧导航收起和展开
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
    .directive 'nbDownload', [() ->

        postLink = (scope, elem, attrs)->

            elem.on 'click', ()->
                selectedRows = scope.paramGetter()
                paramString = selectedRows.join(',')
                hrefString = attrs['urlPrefix'].replace(/#param#/, paramString)
                elem.attr('href', hrefString)

        return {
            scope: {
                paramGetter: "&"
            }
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
    .directive 'nbButterbar', ['$rootScope', '$anchorScroll', (rootScope, anchorScroll) ->

        postLink = (scope, elem, attrs) ->
            elem.addClass 'butterbar hide'
            rootScope.$on '$stateChangeStart', (evt) ->
                anchorScroll()
                elem.removeClass('hide').addClass('active')
            rootScope.$on '$stateChangeSuccess', (evt) ->
                evt.targetScope.$watch '$viewContentLoaded', ->
                    elem.addClass('hide').removeClass('active')

        return {
            template: '<span class="bar"></span>'
            link: postLink
        }

    ]
    .directive 'nbResponsiveHeight', ['$window', ($window)->
        postLink = (scope, elem, attrs) ->
            height =  $window.innerHeight - elem.position().top
            elem.css('height': "#{height}px")

        return {
            link: postLink
        }
    ]
    #facade ngDialog
    .directive 'nbPanel',['ngDialog', '$parse', (ngDialog, $parse) ->

        getCustomConfig = (attrs) ->
            configAttrs = _.pick(attrs, (val, key) -> return /^panel/.test(key))
            customConfig = _.transform configAttrs, (res, val, key) ->
                attr = key.slice(5) #remove prefix 'panel'
                cusKey = _.camelCase(attr)


        postLink = (scope, elem, attrs) ->
            options = {
                controller: attrs.panelController || angular.noop
                template: attrs.templateUrl || 'partials/404.html'
                scope: scope
                controllerAs: attrs.controllerAs || 'panel'
                bindToController: true
                className: 'ngdialog-theme-panel'
                preCloseCallback: attrs.preCloseCallback || angular.noop

            }

            elem.on 'click', (e) ->
                e.preventDefault()
                opts = {}
                angular.isDefined(attrs.panelClosePrevious) && ngDialog.close(attrs.nbDialogClosePrevious)

                opts['locals'] = scope.$eval(attrs.locals) || {}
                angular.extend(opts, options)
                ngDialog.open opts

            scope.$on '$destroy', -> elem.off('click')

        return {
            restrict: 'A'
            link: postLink
        }


    ]
    .directive 'nbDialog',['$mdDialog', ($mdDialog) ->

        postLink = (scope, elem, attrs) ->

            throw new Error('所有dialog都需要templateUrl') if !angular.isDefined(attrs.templateUrl)
            options = {
                clickOutsideToClose: true
            }

            openDialog = (evt) ->
                #scope evt 生命周期仅限于本次点击
                opts = angular.extend({scope: scope.$new(), targetEvent: evt}, options)

                opts = angular.extend(opts, {
                        controller: ->
                            @close = (res) -> $mdDialog.hide(res)
                            @cancel = (res) -> $mdDialog.cancel(res)
                            return
                        controllerAs: 'dialog'
                        bindToController: true
                    })

                angular.forEach ['locals','resolve'], (key) ->
                    opts[key] = scope.$eval(attrs[key]) if angular.isDefined(attrs[key])

                $mdDialog.show opts

            # 暂定所有 dialog 无独立 controller , 交给parent控制
            angular.forEach ['templateUrl', 'template'], (key) ->
                options[key] = attrs[key] if angular.isDefined(attrs[key])


            falseValueRegExp = /^(false|0|)$/
            angular.forEach ['clickOutsideToClose', 'focusOnOpen', 'bindToController'], (key) ->
                options[key] = !falseValueRegExp.test(attrs[key]) if angular.isDefined(attrs[key])

            elem.on 'click', openDialog

            scope.$on '$destroy', -> elem.off('click', openDialog)

        return {
            restrict: 'A'
            link: postLink
        }

    ]



    .directive 'nbConfirm', ['$mdDialog', ($mdDialog) ->

        postLink = (scope, elem, attrs) ->

            attrs.$observe 'nbTitle', (newValue) ->
                scope.title = newValue || '提示'

            attrs.$observe 'nbContent', (newValue) ->
                scope.content = newValue || '缺少内容'

            performConfirm = (evt) ->
                confirm = $mdDialog.confirm()
                    .title(scope.title)
                    .content(scope.content)
                    .ok(attrs['okText'] || '确定')
                    .cancel(attrs['cancleText'] || '取消')
                    .targetEvent(evt)

            callback = (isConfirm) ->
                return -> scope.onComplete(isConfirm: isConfirm)


            elem.on 'click', (evt) ->
                confirm = performConfirm(evt)
                promise = $mdDialog.show(confirm)

                promise.then(callback(true), callback(false)) if angular.isDefined(scope.onComplete)

            scope.$on 'destroy', -> elem.off 'click'


        return {
            link: postLink
            scope: {
                'onComplete': '&nbConfirm'
            }
        }



    ]
    .directive 'scrollCenter', ->
        postLink = (scope, elem, attrs) ->

            scrollCenter = ->
                width = elem.width()
                svgWidth = elem.find('svg').width()
                elem.scrollLeft( (svgWidth - width ) / 2 )

            elem.on 'resize',scrollCenter

            scope.$on '$destroy', ->
                elem.off 'resize', scrollCenter

    .directive 'radioBox', [()->
        postLink = (scope, elem, attrs, ctrl) ->
            scope.selected = null
            # '无需审核': 0
            # '待审核': 1
            # '通过': 2
            # '不通过': 3
            scope.$watch 'pass', (newVal)->
                if newVal
                    scope.selected = "2"
                    scope.fail = false
                if !(scope.pass || scope.fail)
                    scope.selected = "1"
            scope.$watch 'fail', (newVal)->
                if newVal
                    scope.selected = "3"
                    scope.pass = false
                if !(scope.pass || scope.fail)
                    scope.selected = "1"

        return {
            restrict: 'A'
            link: postLink
            template: '''
            <div>
                <input type="checkbox" ng-model="pass"/>
                <label>通过</label>
                <input type="checkbox" ng-model="fail"/>
                <label>不通过</label>
            </div>
            '''
            require: 'ngModel'
            scope: {
                selected: "=ngModel"
            }
            replace: true
        }
    ]
    .directive 'approval', [ () ->

        postLink = (scope, elem, attrs) ->
            padding =
                top: 20
                right: 20
                bottom: 20
                left: 20

            width = 900
            height = 120
                #树的高
            duration = 750
            data = [
                {
                    'status': 'done'
                    'des': '请假单'
                }
                {
                    'status': 'done'
                    'des': '领导审批'
                }
                {
                    'status': 'undo'
                    'des': '上级领导审批'
                }
                {
                    'status': 'unreachable'
                    'des': '最终审批'
                }
                {
                    'status': 'unreachable'
                    'des': '超级最终审批'
                }
                {
                    'status': 'unreachable'
                    'des': '超级最终审批'
                }
                {
                    'status': 'unreachable'
                    'des': '超级最终审批'
                }
                {
                    'status': 'unreachable'
                    'des': '超级最终审批'
                }
                {
                    'status': 'unreachable'
                    'des': '超级最终审批'
                }
                {
                    'status': 'unreachable'
                    'des': '生效'
                }
            ]
            radius = 9
            single_area_width = width / data.length
            single_area_height = 2 * radius + 40

            svg = d3.select(elem[0])
                .append('svg')
                .attr('class', 'lw-svg')
                .attr('width', width)
                .attr('height', height)
            # - .attr("transform", "translate(" + margin.left + "," + margin.top + ")");  //使svg区域与上、左有一定距离
            #
            svg.selectAll('line')
                .data(data).enter()
                .append('line')
                .style('stroke', (d, i) ->
                    if d.status == 'done'
                        '#8bc34a'
                    else if d.status == 'undo'
                        '#2196f3'
                    else if d.status == 'reject'
                        '#f34e4c'
                    else
                        '#dedede'
                )
                .style('stroke-width', '3')
                .attr('class', 'step-line')
                .attr('x1', (d, i) ->
                    single_area_width * (i + .5) - 20
                )
                .attr 'y1', single_area_height - radius + 10
                .attr('x2', (d, i) ->
                    if i != 0
                        single_area_width * (i - .5) - 20
                    else
                        single_area_width * (i + .5) - 20
                )
                .attr 'y2', single_area_height - radius + 10

            svg.selectAll('circle')
                .data(data).enter()
                .append('circle')
                .attr('class', 'step-point')
                .attr('fill', (d, i) ->
                    if d.status == 'done'
                        '#8bc34a'
                    else if d.status == 'undo'
                        svg.append('circle')
                            .attr 'cx',
                                single_area_width * (i + .5) - 20
                            .attr 'cy',
                                single_area_height - radius + 10
                            .attr 'r', 17+radius
                            .attr 'fill', 'transparent'
                            .attr 'stroke', 'rgba(0, 0, 0, .12)'
                            .attr 'stroke-width', '2px'
                        return '#2196f3'
                    else if d.status == 'reject'
                        '#f34e4c'
                    else
                        '#dedede'
                )
                .attr('cx', (d, i) ->
                    single_area_width * (i + .5) - 20
                )
                .attr('cy', single_area_height - radius + 10)
                .attr('r', (d,i) ->
                    if d.status == 'undo'
                        7+radius
                    else
                        radius
                )

            svg.selectAll('text').data(data)
                .enter()
                .append('text')
                .attr('class', 'step-title')
                .attr('x', (d, i) ->
                    single_area_width * (i + .5) - 30
                )
                .attr('y', (d, i) ->
                    if i%2 == 0
                        if d.status == 'undo'
                            single_area_height - radius - 40 + 10
                        else
                            single_area_height - radius - 20 + 10
                    else
                        if d.status == 'undo'
                            single_area_height + 32 + radius + 10
                        else
                            single_area_height + 12 + radius + 10
                )
                .attr 'stroke-width', (d,i) ->
                    if d.status == 'undo'
                        return '2px'
                    else
                        return '1px'
                .attr('fill',(d,i) ->
                    if d.status == 'unreachable'
                        'rgba(0,0,0,.26)'
                    else if d.status == 'done'
                        '#689f38'
                    else if d.status == 'reject'
                        '#e84e40'
                    else if d.status == 'undo'
                        '#1976d2'
                )
                .attr('text-anchor', 'start')
                .attr 'font-size', (d, i) ->
                    if d.status == 'undo'
                        return '16px'
                    else
                        return '14px'
                .text (d, i) ->
                    d.des

        return {
            link: postLink
        }

    ]


    #
    # permission 支持单一权限与组合权限
    #
    # 90%情况 单一权限能满足需求
    #
    # 基于性能考虑与实际业务， 不支持动态权限
    # 所有权限使用较高优先级指令优先check, 如果不满足需求
    #
    #  usage:
    #
    # <div has-permission="department_index"></div>
    # <div has-permission="['department_index','department_active']"></div>

    .directive 'hasPermission', ['AuthService', '$animate', (AuthService, $animate) ->

        postLink = (scope, elem, attrs, ctrl, $transclude) ->
            if AuthService.has(attrs.hasPermission)
                $transclude (clone, newScope) ->
                    clone[clone.length++] = document.createComment(" end hasPermission: #{attrs.hasPermission}")
                    $animate.enter(clone, elem.parent(), elem)

            # scope.$watch attrs.permission, (value) ->
            #     if value
            #         if !childScope
            #             $transclude (clone, newScope) ->
            #                 childScope = newScope
            #                 clone[clone.length++] = document.createComment("end permission #{attrs.permission}")
            #                 block = {clone: clone}

            #                 $animate.enter(clone, $element.parent, $element)

            #     else
            #         if previousElements
            #             previousElements.remove()
            #             previousElements = null
            #         if childScope
            #             childScope.$destroy()
            #             childScope = null
            #         if block
            #             previousElements = getBlockNodes(block.clone)
            #             $animate.leave(previousElements).then -> previousElements = null
            #             block = null

        return {
            multiElement: true
            transclude: 'element'
            priority: 601
            terminal: true
            restrict: 'A'
            $$tlb: true
            link: postLink
        }

    ]
    # MOCK angular-strap datepicker directive
    .directive 'bsDatepicker', ->


        postLink = (scope, elem, attrs, ngModelCtrl) ->

            elem.datepicker(
                autoclose: true
                format: 'yyyy-mm-dd'
                language: 'zh-cn'

            ).on 'changeDate', (evt) ->
                ngModelCtrl.$setViewValue(evt.date)


            scope.$on '$destroy', ->
                elem.datepicker("remove")


        return {
            link: postLink
            require: 'ngModel'
        }

    .directive 'nbFileUpload', ->
        template = '''

        '''

        postLink = (scope, elem, attrs, ngModelCtrl) ->

            


        return {
            scope: {
                files: '=ngModel'
            }
            link: postLink
        }
