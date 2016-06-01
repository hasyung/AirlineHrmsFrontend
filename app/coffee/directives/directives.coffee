angular.module 'nb.directives'
    # 下载
    .directive 'nbDownload', [() ->
        postLink = (scope, elem, attrs)->
            elem.on 'click', ()->
                selectedRows = scope.paramGetter()

                if angular.isArray(selectedRows)
                    paramString = selectedRows.join(',')
                else
                    paramString = angular.element.param(selectedRows)

                hrefString = attrs['urlPrefix'].replace(/#param#/, paramString)
                #console.error hrefString
                elem.attr('href', hrefString)

        return {
            scope: {
                paramGetter: "&"
            }
            link: postLink
        }
    ]

    # 页面切换的 loading 动画
    .directive 'nbLoading', ['$rootScope', (rootScope) ->
        return {
            templateUrl: 'partials/component/loading.html'
        }
    ]

    # 右侧滑出栏
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

    # 独立模态对话框
    .directive 'nbDialog',['$mdDialog', '$enum', ($mdDialog, $enum) ->
        postLink = (scope, elem, attrs) ->
            throw new Error('所有dialog都需要templateUrl') if !angular.isDefined(attrs.templateUrl)
            options = {
                clickOutsideToClose: true
            }

            openDialog = (evt) ->
                newScope = scope.$new()
                newScope.$enum = $enum
                #scope evt 生命周期仅限于本次点击
                opts = angular.extend({scope: newScope, targetEvent: evt}, options)

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

    # confirm
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

    # 在变更记录中使用
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

    # 流程分支节点图，现在已废弃，花了较多精力，暂时保留
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
                .domain([0, 10])
                .range([0, options.height - options.bottom])

            svg = d3.select(elem[0])
                .append("svg")
                    .attr("class","c-chart")
                    .attr("width", options.width)
                    .attr("height", options.height)

            nodes = svg.selectAll("g.c-item").data(data)
            node = nodes.enter().append("g").attr("class","c-item")

            node.append("rect").attr("class","c-column")
            node.append("text").attr("class","c-name")
            node.append("g").attr("class","c-desc")
            node.select("g.c-desc").append("rect")
            node.select("g.c-desc").append("text")

            nodes.exit().remove()

            node.on 'mouseover', (d, i)->
                    d3.select(this).select("g.c-desc")
                        .transition()
                        .duration(300)
                        .attr("fill-opacity", 1)

                    d3.select(this).select("rect.c-column")
                        .transition()
                        .duration(300)
                        .attr("fill-opacity", .7)

            node.on 'mouseout', (d, i)->
                    d3.select(this).select("g.c-desc")
                        .transition()
                        .duration(300)
                        .attr("fill-opacity", 0)

                    d3.select(this).select("rect.c-column")
                        .transition()
                        .duration(300)
                        .attr("fill-opacity", 1)

            nodes.select("rect.c-column")
                .attr("width", 30)
                .attr("height", (d, i) ->
                        return yScale(d.count)
                    )
                .attr("x", (d,i) ->
                        return (i+1)*(options.width-210)/8 + 30*i
                    )
                .attr("y", (d,i) ->
                        return options.height - options.bottom - yScale(d.count)
                    )
                .attr("fill", (d,i) ->
                        switch d.name
                            when "带薪假" then "#77a340"
                            when "探亲假" then  "#77a340"
                            when "事假" then "#2d8ddb"
                            when "病假" then "#2d8ddb"
                            when "旷工" then "#dd5140"
                            when "迟到" then "#ddb509"
                            when "早退" then "#ddb509"
                    )

            nodes.select("text.c-name")
                .attr("font-size","10px")
                .attr("text-anchor","middle")
                .attr("x", (d,i) ->
                        return (i+1)*(options.width-210)/8 + 30*(i + .5)
                    )
                .attr("y", (d,i) ->
                        return options.height - options.bottom + 20
                    )
                .text( (d,i)-> d.name)

            nodes.select("g.c-desc")
                .attr("fill-opacity", 0)

            nodes.select("g.c-desc").select("rect")
                .attr("width", 40)
                .attr("height", 30)
                .attr("x", (d,i) ->
                        return (i+1)*(options.width-210)/8 + 30*i
                    )
                .attr("y", (d,i) ->
                        return options.height - options.bottom - yScale(d.count) - 40
                    )
                .attr("fill", "rgba(255, 255, 255, .4)")

            node.select("g.c-desc").select("text")
                .attr("font-size","14px")
                .attr("text-anchor","middle")
                .attr("fill","#fff")
                .attr("x", (d,i) ->
                            return (i+1)*(options.width-210)/8 + 30*i + 20
                        )
                    .attr("y", (d,i) ->
                            return options.height - options.bottom - yScale(d.count) - 40 + 20
                        )
                .text( (d,i)-> d.count + "天")

        return {
            restrict: "EA"
            link: postLink
        }
    ]

    # permission 支持单一权限与组合权限
    # 90%情况 单一权限能满足需求
    # 基于性能考虑与实际业务，不支持动态权限
    # 所有权限使用较高优先级指令优先check, 如果不满足需求
    # <div has-permission="department_index"></div>
    # <div has-permission="['department_index','department_active']"></div>

    .directive 'hasPermission', ['AuthService', '$animate', (AuthService, $animate) ->
        postLink = (scope, elem, attrs, ctrl, $transclude) ->
            if AuthService.has(attrs.hasPermission)
                $transclude (clone, newScope) ->
                    clone[clone.length++] = document.createComment(" end hasPermission: #{attrs.hasPermission}")
                    $animate.enter(clone, elem.parent(), elem)

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
            config = autoclose: true, format: 'yyyy-mm-dd', language: 'zh-cn', todayHignlight: true

            if attrs.endDate == 'today'
                config['endDate'] = moment().endOf('day').toDate()

            elem.datepicker(config).on 'changeDate', (evt) ->
                #ngModelCtrl.$setViewValue(evt.date)

            if attrs.defaultToday
                elem.datepicker('update', moment().startOf('day').format('YYYY-MM-DD'))
                ngModelCtrl.$setViewValue(moment().startOf('day').format())

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
                    <span class="serial-num" ng-bind="receptor.employeeNo || receptor.employee_no"></span>
                    <span class="position">{{ receptor.department.name }} / {{ receptor.position.name }}</span>
                </div>
            </div>
        '''

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
                    </div>
                    <div ng-if="!ctrl.isImage(file)">
                        <a ng-href="{{file.default}}" download style="display:block;color:rgba(0,0,0,0.87);">
                            <div class="accessory-name" ng-bind="file.name"></div>
                            <div class="accessory-size" ng-bind="file.size | byteFmt:2"></div>
                        </a>
                    </div>
                    <div class="accessory-switch">
                        <md-button type="button" class="md-icon-button" ng-click="ctrl.removeFile($index)">
                            <md-icon md-svg-src="/images/svg/close.svg" class="md-warn"></md-icon>
                        </md-button>
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

    # 在变更记录中使用
    .directive 'addCity', [()->
        postLink = (scope, elem, attrs) ->

        class AddCityCtrl
            @.$inject = ['$scope']

            constructor: (@scope)->

            addItem: (item)->
                if angular.isDefined(item) && item.length > 0
                    @scope.cities.push(item)

        return {
            restrict: 'E'
            link: postLink
            template: '''
            <span>
                <input ng-show="adding" type="text" ng-model="city" ng-blur="ctrl.addItem(city); city=''; adding=false;" />
                <span ng-click="adding=true" ng-hide="adding" class="add-chip">
                    <md-icon md-svg-src="/images/svg/plus.svg" class="md-primary"></md-icon>
                </span>
            </span>
            '''
            scope: {
                city: "=?"
                adding: "=?"
                cities: "=ngModel"
            }
            require: 'ngModel'
            replace: true
            controller: AddCityCtrl
            controllerAs: 'ctrl'
        }
    ]

    #自动提示输入框
    .directive 'nbAutocomplete', [()->
        postLink = (scope, elem, attrs) ->

        return {
            restrict: 'E'
            link: postLink
            template: '''
            <md-autocomplete
                ng-disabled="ctrl.isDisabled"
                md-selected-item="selectedItem"
                md-search-text-change="value=searchText"
                md-search-text="searchText"
                md-selected-item-change="value=selectedItem"
                md-items="item in ctrl.queryMatchedValues(searchText)"
                md-floating-label="please replace me!"
                <md-item-template>
                    <span md-highlight-text="searchText">{{item}}</span>
                </md-item-template>
                <md-not-found>
                    未找到 "{{searchText}}"
                </md-not-found>
            </md-autocomplete>
            '''
            scope: {
                value: "=ngModel"
                searchText: "=?"
                selectedItem: "=?"
            }
            require: 'ngModel'
            replace: true
            controller: NbAutocompleteCtrl
            controllerAs: 'ctrl'
        }
    ]

    #下拉菜单 两部分合并的string
    .directive 'selectTwoParts', [()->
        postLink = (scope, elem, attrs) ->

        return {
            restrict: 'E'
            link: postLink
            template: '''
            <div class="select-group">
                <md-input-container md-no-float>
                    <md-select placeholder="请选择" ng-model="ctrl.firstPart" ng-change="ctrl.concatVal()">
                        <md-option ng-selected="$last" ng-value="item" ng-repeat="item in year_list track by $index">{{item}}</md-option>
                    </md-select>
                </md-input-container>
                <div class="divide-text">—</div>
                <md-input-container md-no-float>
                    <md-select placeholder="请选择" ng-model="ctrl.secondPart" ng-change="ctrl.concatVal()">
                        <md-option ng-selected="$last" ng-value="item" ng-repeat="item in month_list track by $index">{{item}}</md-option>
                    </md-select>
                </md-input-container>
            </div>
            '''
            scope: {
                value: "=ngModel"
            }
            require: 'ngModel'
            replace: true
            controller: SelectTwoPartsCtrl
            controllerAs: 'ctrl'
        }
    ]

    # 复选框容器 内部配合md-checkbox data-val表示选中值
    # ng-model绑定值 返回被复选中的数组 
    .directive 'checkboxGroup', [ () ->
        postLink = (scope, elem, attrs) ->
            scope.existed = (item)->
                return scope.list.indexOf(item) > -1

            scope.toggled = (item)->
                idx = scope.list.indexOf(item);

                if idx > -1
                    scope.list.splice(idx, 1);
                else
                    scope.list.push(item);
                    

        return {
            template: '<md-checkbox ng-checked="existed(val)" ng-click="toggled(val)" class="md-primary" ng-repeat="(key, val) in checkboxes" data-val="{{val}}">{{key}}</md-checkbox>'
            scope: {
                list: "=ngModel"
                checkboxes: "=checkboxes"
            }
            restrict: "EA"
            link: postLink
        }
    ]

    # BOSS页面的待办事项（不考虑重用）
    .directive 'bossTodo', [ () ->
        postLink = (scope, elem, attrs) ->
            $boards = elem.find '.todos__board'

            $boards.on 'click', () ->
                if(!$(this).hasClass('active'))
                    $(this).removeClass('outlier')
                    
                    prev = elem.find '.active'
                    outlier = elem.find '.outlier'

                    prev.removeClass('active')
                    $(this).addClass('active')

                    $(this).animate({
                        top: 0
                        }, 500, false)

                    outlier.animate({
                        top: '501px'
                        }, 500, false)

                    prev.animate({
                        top: '591px'
                        }, 500, ()->
                            prev.addClass('outlier')
                            )
                    

        return {
            restrict: "EA"
            link: postLink
        }
    ]

    # BOSS页面的待办事项（不考虑重用）
    .directive 'bossTodo', [ () ->
        postLink = (scope, elem, attrs) ->
            $boards = elem.find '.todos__board'

            $boards.on 'click', () ->
                if(!$(this).hasClass('active'))
                    $(this).removeClass('outlier')
                    
                    prev = elem.find '.active'
                    outlier = elem.find '.outlier'

                    prev.removeClass('active')
                    $(this).addClass('active')

                    $(this).animate({
                        top: 0
                        }, 500, false)

                    outlier.animate({
                        top: '501px'
                        }, 500, false)

                    prev.animate({
                        top: '591px'
                        }, 500, ()->
                            prev.addClass('outlier')
                            )
                    

        return {
            restrict: "EA"
            link: postLink
        }
    ]

    # BOSS页面的数据块 tab滑动菜单（不考虑重用）
    .directive 'bossDataSlider', [ () ->
        postLink = (scope, elem, attrs) ->
            $tabs = elem.find '.datas__tab'

            $slider = elem.find '.datas__slider'

            $tabs.on 'click', () ->
                activeIndex = $tabs.index($(this))

                disdance = if activeIndex > 0 then 95+84*(activeIndex - 1) else 0

                $slider.stop(true, false)

                if activeIndex == 6
                    $slider.animate({
                        width: '115px'
                        borderBottomLeftRadius: '50px'
                        borderTopRightRadius: '50px'
                        borderTopLeftRadius: '0'
                        borderBottomRightRadius: '0'
                        }, 500, false)

                else if activeIndex == 0
                    $slider.animate({
                        width: '115px'
                        borderBottomLeftRadius: '0'
                        borderTopRightRadius: '0'
                        borderTopLeftRadius: '50px'
                        borderBottomRightRadius: '50px'
                        }, 500, false)

                else
                    $slider.animate({
                        width: '105px'
                        }, 500, false)

                $slider.css({
                    left: disdance + 'px'
                    })
                    
        return {
            restrict: "EA"
            link: postLink
        }
    ]

    # BOSS页面的数据块 datas_picker（不考虑重用）
    .directive 'bossDataPicker', [ () ->
        postLink = (scope, elem, attrs) ->
            listWidth = 0
            startIndex = 0
            $listObj = elem.find '.picker__list'
            $items = elem.find '.picker__items'
            $prev = elem.find '.picker__prev'
            $next = elem.find '.picker__next'
            animating = false
            dueTime = 300

            $items.each () ->
                listWidth += $(this).width()

            $listObj.css('width', listWidth)

            $prev.on 'click', () ->
                d = $items.eq(startIndex - 1).width()
                s = parseInt($listObj.css('transform').toString().split(',')[4])
                f = s + d

                if startIndex > 0 && !animating
                    animating = true

                    $listObj.css {
                        transform: 'translate3d('+ f + 'px, 0, 0)'
                    }

                    startIndex--

                    setTimeout(()-> animating = false
                    dueTime
                    )
                
            $next.on 'click', () ->
                d = $items.eq(startIndex).width()
                s = parseInt($listObj.css('transform').toString().split(',')[4])
                f = s - d

                if startIndex < $items.length - 1 && !animating
                    animating = true

                    $listObj.css {
                        transform: 'translate3d('+ f + 'px, 0, 0)'
                    }

                    startIndex++
                    setTimeout(()-> animating = false
                    dueTime
                    )


        return {
            restrict: 'EA'
            link: postLink
        }

    ]

class NbAutocompleteCtrl
    @.$inject = ['$scope', '$attrs']

    constructor: (scope, attrs) ->
        @values = attrs.values if angular.isDefined(attrs.values)
        @isDisabled = attrs.isDisabled if angular.isDefined(attrs.isDisabled)

    queryMatchedValues = (text) ->
        self = @
        matched = _.filter self.values, (value)->
            _.includes value, text
        return matched

class SelectTwoPartsCtrl
    @.$inject = ['$scope', '$attrs']

    constructor: (@scope, attrs) ->
        @scope.year_list = [2015..new Date().getFullYear()]
        @scope.month_list = _.map [1..12], (item) ->
            item = "0" + item if item < 10
            item + '' # to string

    concatVal: () ->
        @scope.value = @firstPart+'-'+@secondPart










