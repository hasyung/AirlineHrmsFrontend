angular.module 'nb.directives'
    .directive 'nbDropdown', ['$http', 'inflector', '$document', ($http, inflector, $doc)->


        class DropdownCtrl
            @.$inject = ['$http','$attrs','$scope']
            constructor: (@http, @attrs, @scope) ->
                self = @
                @scope.isOpen = false
                @options = []

                onSuccess = (data, status) ->
                    @options = _.map data.result, (item) ->
                        _.reduce(item, (res, val, key) ->
                            res[inflector.camelize(key)] = val
                            return res
                        , {})
                onError = ->
                    scope.$emit('dropdown:notfound:error')


                if scope.options
                    @options = scope.options
                else if attrs.remoteKey
                    @http.get("/api/enum?key=#{@attrs.remoteKey}")
                        .success onSuccess.bind(@)
                        .error onError
                else
                    throw new Error('dropdown need options')
            setSelected: ($index) ->
                # @scope.selected = _.clone @options[$index] # why clone ?
                @scope.selected = if @attrs.preventClone then @options[$index] else _.clone @options[$index]
                @close()

            toggle: () ->
                @isOpen = !@isOpen

            close: () ->
                @isOpen = false

        postLink = (scope, elem, attr, $ctrl) ->
            scope.isOpen = false
            dropdownCtrl = $ctrl[0]
            ngModelCtrl = $ctrl[1]
            # 下面两行代码是为了防止点击元素后事件冒泡至body，然后影藏弹出框
            elem.on 'click', (e)->
                e.stopPropagation()
                scope.$apply () ->
                    ngModelCtrl.$setTouched()
                    # if !_.isEqual(initSelected, scope.selected)
                    #     ngModelCtrl.$setDirty()

            closeDropdown = (e) ->
                e.stopPropagation()
                scope.$apply ()->
                    dropdownCtrl.close()
                    # dropdownCtrl.close() 返回false，将阻止submit按钮的提交事件的触发
                    return
            $doc.on 'click', closeDropdown

            scope.$watch 'selected', (newVal) ->
                scope.selected = newVal

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
        
        class simDropdownCtrl
            @.$inject = ['$scope', '$attrs']
            constructor: (@scope, @attrs) ->
                @scope.isOpen = false
                if @attrs.btnText
                    @scope.btnText = @attrs.btnText
                else
                    throw Error("btn-text attribute is required")
            toggle: () ->
                @scope.isOpen = !@scope.isOpen

        postLink = (scope, elem, attr)->

            closeDropdown = (e)->
                e.stopPropagation()
                scope.$apply ()->
                    scope.isOpen = false
                return
            # 下面两行代码是为了防止点击元素后事件冒泡至body，然后影藏弹出框
            elem.on 'click', (e)->
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
            template: '<div class="dropdown", ng-class="{\'open\': isOpen}">' +
                        '  <button ng-click="dropdown.toggle()" class="btn btn-info dropdown-toggle" type="button" data-toggle="dropdown" aria-expanded="true">' +
                        '    {{btnText}}' +
                        '    <span class="caret"></span>' +
                        '  </button>' +
                        '  <ul class="dropdown-menu" role="menu" aria-labelledby="dropdownMenu1" ng-transclude>' +
                        '  </ul>' +
                        '</div>'
            controller: simDropdownCtrl
            controllerAs: 'dropdown'
            link: postLink

        }
    ]

