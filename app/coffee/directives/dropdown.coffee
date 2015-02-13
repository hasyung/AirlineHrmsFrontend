angular.module 'nb.directives'
    .directive 'nbDropdown', ['$http', 'inflector', '$document', ($http, inflector, $doc)->

        # return array
        # example:
        #   {list:{item: 123}
        # return ['list', 'item']
        #
        parseMappedAttr = (mapped)->
            prefixIndex = mapped.indexOf('$item.')
            throw Error("map属性格式不正确, '必须符合 $item.xx.xx 格式'") if prefixIndex != 0
            attr = mapped.slice(6) #prefix length
            splited = attr.split('.')

        getMappedAttr = (mappedArr, selectedItem) ->
            attr = mappedArr.reduce(
                (res, value) -> res[value]
                ,
                selectedItem)


        class DropdownCtrl
            @.$inject = ['$http','$attrs','$scope']
            constructor: (@http, @attrs, @scope) ->
                self = @
                @scope.isOpen = false
                @options = []
                @mapped = mapped = parseMappedAttr(@attrs.map) if @attrs.map



                onSuccess = (data, status) ->
                    @options = _.map data.result, (item) ->
                        _.reduce(item, (res, val, key) ->
                            res[inflector.camelize(key)] = val
                            return res
                        , {})
                    # 处理map 属性反向映射
                    if scope.selected && attrs['map']
                        scope.item = _.find @options, (opt) ->
                            return getMappedAttr(mapped, opt) == scope.selected

                if scope.options
                    @options = scope.options
                else if attrs.remoteKey
                    @http.get("/api/enum?key=#{@attrs.remoteKey}")
                        .success onSuccess.bind(@)
                else
                    throw new Error('dropdown need options')
            setSelected: ($index) ->
                # @scope.selected = _.clone @options[$index] # why clone ?
                selected = if @attrs.preventClone then @options[$index] else _.clone @options[$index]
                @scope.item = selected
                @scope.selected = if @mapped then getMappedAttr(@mapped, selected) else selected
                @close()

            toggle: () ->
                @isOpen = !@isOpen
                if @ngModelCtrl.$pristine
                    @ngModelCtrl.$setDirty()

            close: () ->
                @isOpen = false

        postLink = (scope, elem, attr, $ctrl) ->
            scope.isOpen = false
            dropdownCtrl = $ctrl[0]
            ngModelCtrl = $ctrl[1]
            dropdownCtrl.ngModelCtrl = ngModelCtrl





            # 下面两行代码是为了防止点击元素后事件冒泡至body，然后影藏弹出框
            elem.on 'click', (e)->
                e.stopPropagation()
            closeDropdown = (e) ->
                e.stopPropagation()
                scope.$apply ()->
                    dropdownCtrl.toggle()
                    # dropdownCtrl.close() 返回false，将阻止submit按钮的提交事件的触发
                    return

            scope.$watch(
                -> dropdownCtrl.isOpen
                ,
                (newValue, oldValue) ->
                    if newValue == true
                        $doc.on 'click', closeDropdown
                    else
                        $doc.off 'click', closeDropdown
                )

            scope.$on '$destroy', () ->
                elem.off 'click'
                $doc.off 'click', closeDropdown

        return {
            restrict: 'EA'
            templateUrl: 'partials/common/dropdown.tpl.html'
            # replace: true
            require: ["nbDropdown", "ngModel"]
            scope: {
                options: "=nbDropdown"
                selected: "=ngModel"
            }
            controller: DropdownCtrl
            controllerAs: 'dropdown'

            link: postLink

        }
    ]
    .directive 'simpleDropdown', ['$document', ($doc)->

        postLink = (scope, elem, attr)->

            closeDropdown = (e)->
                e.stopPropagation()
                scope.$apply ()->
                    scope.isOpen = false
                return
            # 下面两行代码是为了防止点击元素后事件冒泡至body，然后影藏弹出框
            elem.on 'click', (e)->
                if e.target.nodeName is "BUTTON"
                    e.stopPropagation()

            $doc.on 'click', closeDropdown

            scope.$on '$destroy', () ->
                $doc.off 'click', closeDropdown
                elem.off 'click'


        return {
            restrict: 'EA'
            replace: true
            scope:{}
            transclude: true
            template: '''
            <div class="dropdown", ng-class="{\'open\': isOpen}">
              <button ng-click="dropdown.toggle()" class="btn btn-info dropdown-toggle" type="button" data-toggle="dropdown" aria-expanded="true">
                {{btnText}}
                <span class="caret"></span>
              </button>
              <ul class="dropdown-menu" ng-if="isOpen" role="menu" aria-labelledby="dropdownMenu1" ng-transclude>
              </ul>
            </div>
            '''
            controller: SimpleDropdownCtrl
            controllerAs: 'dropdown'
            link: postLink

        }
    ]

class SimpleDropdownCtrl
    @.$inject = ['$scope', '$attrs']
    constructor: (@scope, @attrs) ->
        @scope.isOpen = false
        if @attrs.btnText
            @scope.btnText = @attrs.btnText
        else
            throw Error("btn-text attribute is required")
    toggle: () ->
        @scope.isOpen = !@scope.isOpen
