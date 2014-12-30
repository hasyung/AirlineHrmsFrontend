
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




