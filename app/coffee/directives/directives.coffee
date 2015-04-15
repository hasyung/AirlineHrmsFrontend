
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
    .directive 'nbDialog',['ngDialog', (ngDialog) ->

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
