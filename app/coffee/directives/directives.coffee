
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

                dialogScope = `angular.isDefined(scope.nbDialogScope)? scope.nbDialogScope : 'noScope'`
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