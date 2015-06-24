
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
            }

            preClose = attrs.preClose

            elem.on 'click', (e) ->
                e.preventDefault()
                opts = {}
                angular.isDefined(attrs.panelClosePrevious) && ngDialog.close(attrs.nbDialogClosePrevious)

                opts['locals'] = scope.$eval(attrs.locals) || {}
                angular.extend(opts, options)
                promise =  ngDialog.open(opts).closePromise
                promise.then () ->
                   scope.$eval(preClose) if angular.isDefined(preClose)

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
    # .directive 'todoList', [ () ->

    #     postLink = (scope, elem, attrs) ->
    #         console.log("111");
    #     return {
    #         restrict: "A"
    #         link: postLink
    #     }
    # ]
    .directive 'columnChart', [ () ->

        postLink = (scope, elem, attrs) ->
            data = [
                {
                    name: "带薪假",
                    count: 3
                },
                {
                    name: "探亲假",
                    count: 6
                },
                {
                    name: "事假",
                    count: 3,
                },
                {
                    name: "病假",
                    count: 4
                },
                {
                    name: "旷工",
                    count: 2
                },
                {
                    name: "迟到",
                    count: 7
                },
                {
                    name: "早退",
                    count: 4
                }
            ]

            options = {
                "width": 520,
                "height": 250,
                "bottom": 50
            }

            yScale = d3.scale.linear()
                .domain([0, 15])
                .range([0, options.height - options.bottom])

            svg = d3.select(elem[0])
                .append("svg")
                    .attr("class","c-chart")
                    .attr("width", options.width)
                    .attr("height", options.height)

            nodes = svg.selectAll("g.c-item").data(data)
            node = nodes.enter().append("g").attr("class","c-item")

            nodes.exit().remove()

            node.append("rect")
                .attr("class","c-column")
                .attr("width", 30)
                .attr("height", (d, i) ->
                        return yScale(d.count)
                    )
                .attr("x", (d,i) ->
                        return (i+1)*(520-210)/8 + 30*i
                    )
                .attr("y", (d,i) ->
                        return options.height - options.bottom - yScale(d.count)
                    )
                .attr("fill", (d,i) ->

                    )

            node.append("text")
                .attr("class","c-name")
                .attr("font-size","10px")
                .attr("text-anchor","middle")
                .attr("x", (d,i) ->
                        return (i+1)*(520-210)/8 + 30*(i + .5)
                    )
                .attr("y", (d,i) ->
                        return options.height - options.bottom + 20
                    )
                .text( (d,i)-> d.name)






        return {
            restrict: "EA"
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
    .directive 'bsDatepicker', ['$parse', ->


        postLink = (scope, elem, attrs, ngModelCtrl) ->

            elem.datepicker(
                autoclose: true
                format: 'yyyy-mm-dd'
                language: 'zh-cn'

            )
            # .on 'changeDate', (evt) ->
            #     ngModelCtrl.$setViewValue(evt.date)

            ngModelCtrl.$parsers.unshift (viewValue) ->
                #only allowed yyyy-mm-dd format
                if(!viewValue || !/^\d{4}-\d{2}-\d{2}$/.test(viewValue))
                    ngModelCtrl.$setValidity('date', true)
                    return

                return moment(viewValue).format()

            ngModelCtrl.$formatters.push (modelValue) ->
                return moment(modelValue).format('YYYY-MM-DD') if modelValue


            scope.$on '$destroy', ->
                elem.datepicker("remove")


        return {
            link: postLink
            require: 'ngModel'
        }
    ]
    .directive 'flowUserInfo', (USER_META) ->

        origin_tmpl = '''
            <div class="flow-info-head">
                <div class="name" ng-bind="receptor.name"></div>
                <div class="flow-info-plus">
                    <span class="serial-num" ng-bind="receptor.employeeNo"></span>
                    <span class="position">{{ receptor.department.name }} / {{ receptor.position.name }}</span>
                </div>
            </div>
        '''

        # template = _.template(origin_tmpl)(USER_META)

        return {
            scope: {
                receptor: "=?"
            }
            link: (scope, elem, attrs)->
                scope.$apply ()-> scope.receptor = USER_META if !scope.receptor
            replace: true
            template: origin_tmpl
        }


    .directive 'flowFileUpload', [()->
        template = '''
        <div>
            <div class="accessory-container">
                <div ng-repeat="file in files track by $index"  class="accessory-cell">
                    <div ng-if="ctrl.isImage(file)" nb-gallery img-obj="file">
                        <div class="accessory-name" ng-bind="file.name"></div>
                        <div class="accessory-size" ng-bind="file.size | byteFmt:2"></div>
                        <div class="accessory-switch">
                            <md-button type="button" class="md-icon-button" ng-click="ctrl.removeFile($index)">
                                <md-icon md-svg-src="/images/svg/close.svg" class="md-warn"></md-icon>
                            </md-button>
                        </div>
                    </div>
                    <div ng-if="!ctrl.isImage(file)">
                        <div class="accessory-name" ng-bind="file.name"></div>
                        <div class="accessory-size" ng-bind="file.size | byteFmt:2"></div>
                        <div class="accessory-switch">
                            <md-button type="button" class="md-icon-button" ng-click="ctrl.removeFile($index)">
                                <md-icon md-svg-src="/images/svg/close.svg" class="md-warn"></md-icon>
                            </md-button>
                        </div>
                    </div>
                </div>
            </div>
            <div class="accessory-btn-group"
                flow-init="{target: '/api/workflows/##FLOW_TYPE##/attachments', testChunks:false, uploadMethod:'POST', singleFile:false}"
                flow-files-submitted="$flow.upload()"
                flow-file-success="ctrl.addFile($message);">
                <md-button class="md-primary md-raised" flow-btn type="button">添加文件</md-button>
                <span class="tip"> {{tips}}</span>
            </div>
        </div>
        '''

        class FileUploadCtrl
            @.$inject = ['$scope']

            constructor: (@scope)->

            addFile: (fileObj)->
                fileObj = JSON.parse(fileObj)
                file = fileObj.attachment
                @scope.files = [] if !@scope.files
                @scope.files.push file

            removeFile: (index)->
                @scope.files.splice(index, 1)

            isImage: (file)->
                /^image\/jpg|jpeg|gif|png/.test(file.type)

        postLink = (scope, elem, attrs, ngModelCtrl) ->

            scope.$watch "files", (newVal)->
                fileIds = _.map newVal, 'id'
                ngModelCtrl.$setViewValue(fileIds)
            , true

            return

        return {
            scope: {
                type: '@flowType'
                tips: '@tips'
            }
            template: (elem, attrs)->
                new Error("flow type is needed in workflows") if attrs['flowType']
                template.replace /##FLOW_TYPE##/, attrs['flowType']
            replace: true
            link: postLink
            require: 'ngModel'
            controller: FileUploadCtrl
            controllerAs: 'ctrl'
        }
    ]

    .directive 'nbFileUpload', [()->
        template = '''
        <div>
            <div class="accessory-container">
                <div ng-repeat="file in files track by $index"  class="accessory-cell">
                    <div ng-if="ctrl.isImage(file)" nb-gallery img-obj="file">
                        <div class="accessory-name" ng-bind="file.name"></div>
                        <div class="accessory-size" ng-bind="file.size | byteFmt:2"></div>
                        <div class="accessory-switch">
                            <md-button type="button" class="md-icon-button" ng-click="ctrl.removeFile($flow, $index)">
                                <md-icon md-svg-src="/images/svg/close.svg" class="md-warn"></md-icon>
                            </md-button>
                        </div>
                    </div>
                    <div ng-if="!ctrl.isImage(file)">
                        <div class="accessory-name" ng-bind="file.file_name"></div>
                        <div class="accessory-size" ng-bind="file.file_size | byteFmt:2"></div>
                        <div class="accessory-switch">
                            <md-button type="button" class="md-icon-button" ng-click="ctrl.removeFile($flow, $index)">
                                <md-icon md-svg-src="/images/svg/close.svg" class="md-warn"></md-icon>
                            </md-button>
                        </div>
                    </div>
                </div>
            </div>
            <div class="accessory-btn-group"
                flow-init="{target: '/api/attachments/upload_xls', testChunks:false, uploadMethod:'POST', singleFile:true}"
                flow-files-submitted="$flow.upload()"
                flow-file-success="ctrl.addFile($message);">
                <md-button
                    ng-if="$flow.files.length < fileSize"
                    class="md-primary md-raised" flow-btn type="button">添加文件</md-button>
                <span class="tip"> {{tips}}</span>
            </div>

        </div>
        '''

        class FileUploadCtrl
            @.$inject = ['$scope']

            constructor: (@scope)->
                @scope.fileSize = Number.MAX_VALUE

            addFile: (fileObj)->
                file = JSON.parse(fileObj)
                @scope.files = [] if !@scope.files
                @scope.files.push file

            removeFile: (flow, index)->
                file = @scope.files.splice(index, 1)

            isImage: (file)->
                /^image\/jpg|jpeg|gif|png/.test(file.type)

        postLink = (scope, elem, attrs, ngModelCtrl) ->

            if attrs.singleFile
                scope.fileSize = 1

            scope.$watch "files", (newVal)->
                fileIds = _.map newVal, 'id'
                result = if fileIds.length == 1 then fileIds[0] else fileIds
                ngModelCtrl.$setViewValue(result)
            , true

            return

        return {
            scope: {
                tips: '@tips'
            }
            template: template
            replace: true
            link: postLink
            require: 'ngModel'
            controller: FileUploadCtrl
            controllerAs: 'ctrl'
        }
    ]