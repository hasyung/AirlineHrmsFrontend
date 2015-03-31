
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
            height = 92
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
                    'des': '超级最终审批'
                }
                {
                    'status': 'unreachable'
                    'des': '超级最终审批'
                }
            ]
            radius = 6
            single_area_width = width / data.length
            single_area_height = 2 * radius + 40

            svg = d3.select(elem[0]).append('svg')
            .attr('class', 'lw-svg')
                .attr('width', width)
                .attr('height', height)
            #- .append("g")
            #- .attr("transform", "translate(" + margin.left + "," + margin.top + ")");  //使svg区域与上、左有一定距离
            #
            svg.selectAll('line').data(data).enter().append('line').style('stroke', (d, i) ->
              if d.status == 'done'
                '#2cc350'
              else if d.status == 'undo'
                '#24afff'
              else if d.status == 'reject'
                '#f34e4c'
              else
                '#eee'
            ).style('stroke-width', '3').attr('class', 'step-line').attr('x1', (d, i) ->
              single_area_width * (i + .5)
            ).attr('y1', single_area_height - radius).attr('x2', (d, i) ->
              if i != 0
                single_area_width * (i - .5)
              else
                single_area_width * (i + .5)
            ).attr 'y2', single_area_height - radius

            svg.selectAll('circle').data(data).enter().append('circle').attr('class', 'step-point').attr('fill', (d) ->
              if d.status == 'done'
                '#2cc350'
              else if d.status == 'undo'
                '#24afff'
              else if d.status == 'reject'
                '#f34e4c'
              else
                '#eee'
            ).attr('cx', (d, i) ->
              single_area_width * (i + .5)
            ).attr('cy', single_area_height - radius)
            .attr('r', (d,i) ->
                if d.status == 'undo'
                    2*radius
                else
                    radius
            )

            svg.selectAll('text').data(data).enter().append('text')
            .attr('class', 'step-title')
            .attr('x', (d, i) ->
              single_area_width * (i + .5)
            )
            .attr('y', (d, i) ->
                if i%2 == 0
                    single_area_height - radius - 20
                else
                    single_area_height + 20 +radius
            )
            .attr('fill',(d,i) ->
                if d.status == 'unreachable'
                    'rgba(0,0,0,.54)'
                else
                    'rgba(0,0,0,.87)'
            )
            .attr('text-anchor', 'middle')
            .attr('font-size', '12px').text (d, i) ->
              d.des

        return {
            link: postLink
        }

    ]



