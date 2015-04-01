
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
    .directive 'nbPanel',['ngDialog', (ngDialog) ->

        postLink = (scope, elem, attrs) ->
            elem.on 'click', (e) ->
                e.preventDefault()

                dialogScope = `angular.isDefined(scope.nbDialogScope)? scope.nbDialogScope : scope.$parent`
                angular.isDefined(attrs.nbDialogClosePrevious) && ngDialog.close(attrs.nbDialogClosePrevious)

                defaults = ngDialog.getDefaults()

                data = scope.nbDialogData
                #link https://github.com/angular/angular.js/issues/6404
                data = scope.prepareData() if attrs.prepareData

                ngDialog.open {

                    template: attrs.nbDialog
                    className: attrs.nbDialogClass || defaults.className
                    controller: attrs.nbDialogController
                    scope: dialogScope
                    data: data
                    # showClose: attrs.ngDialogShowClose === 'false' ? false : (attrs.ngDialogShowClose === 'true' ? true : defaults.showClose),
                    # closeByDocument: attrs.ngDialogCloseByDocument === 'false' ? false :
                    # (attrs.ngDialogCloseByDocument === 'true' ? true : defaults.closeByDocument),
                    # closeByEscape: attrs.ngDialogCloseByEscape === 'false' ? false
                    # : (attrs.ngDialogCloseByEscape === 'true' ? true : defaults.closeByEscape),
                    # preCloseCallback: attrs.ngDialogPreCloseCallback || defaults.preCloseCallback

                }

            scope.$on '$destroy', -> elem.off('click')

        return {
            restrict: 'A'
            scope: {
                nbDialogScope : '='
                prepareData: '&?'
                nbDialogData: '='
            }
            link: postLink
        }


    ]
    .directive 'nbDialog',['$mdDialog', ($mdDialog) ->

        postLink = (scope, elem, attrs) ->

            throw new Error('所有dialog都需要templateUrl') if !angular.isDefined(attrs.templateUrl)
            options = {}

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
                promise.then(callback(true), callback(false)) if angular.isDefined(attrs.onComplete)

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

# var ngIfDirective = ['$animate', function($animate) {
#   return {
#     multiElement: true,
#     transclude: 'element',
#     priority: 600,
#     terminal: true,
#     restrict: 'A',
#     $$tlb: true,
#     link: function($scope, $element, $attr, ctrl, $transclude) {
#         var block, childScope, previousElements;
#         $scope.$watch($attr.ngIf, function ngIfWatchAction(value) {
#           if (value) {
#             if (!childScope) {
#               $transclude(function(clone, newScope) {
#                 childScope = newScope;
#                 clone[clone.length++] = document.createComment(' end ngIf: ' + $attr.ngIf + ' ');
#                 // Note: We only need the first/last node of the cloned nodes.
#                 // However, we need to keep the reference to the jqlite wrapper as it might be changed later
#                 // by a directive with templateUrl when its template arrives.
#                 block = {
#                   clone: clone
#                 };
#                 $animate.enter(clone, $element.parent(), $element);
#               });
#             }
#           } else {
#             if (previousElements) {
#               previousElements.remove();
#               previousElements = null;
#             }
#             if (childScope) {
#               childScope.$destroy();
#               childScope = null;
#             }
#             if (block) {
#               previousElements = getBlockNodes(block.clone);
#               $animate.leave(previousElements).then(function() {
#                 previousElements = null;
#               });
#               block = null;
#             }
#           }
#         });
#     }
#   };
# }];



    #
    # permission 支持单一权限与组合权限
    #
    # 90%情况 单一权限能满足需求
    #
    # 基于性能考虑与实际业务， 不支持动态权限
    # 所有权限使用较高优先级指令优先check, 如果不满足需求
    #
    #
    #  usage:
    #
    # <div has-permission="department_index"></div>
    # <div has-permission="['department_index','department_active']"></div>

    .directive 'has-permission', [(AuthService) ->

        postLink = (scope, elem, attrs, ctrl, $transclude) ->
            if AuthService.has(attrs.permission)
                $transclude (clone, newScope) ->
                    $animate.enter(clone, elem.parent, elem)

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
            transclude: 'element'
            priority: 600
            terminal: true
            restrict: 'A'
            $$tlb: true
            link: postLink
        }

    ]