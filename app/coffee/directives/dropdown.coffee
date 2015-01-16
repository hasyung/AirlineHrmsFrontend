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
            elem.on 'click', (e)->
                e.stopPropagation()
                scope.$apply () ->
                    ngModelCtrl.$touched = true

            closeDropdown = (e) ->
                e.stopPropagation()
                scope.$apply ()->
                    dropdownCtrl.close()
                    # dropdownCtrl.close() 返回false，将阻止submit按钮的提交事件的触发
                    return
            $doc.on 'click', closeDropdown

            scope.$watch 'selected', (newVal) ->
                scope.selected = newVal
                ngModelCtrl.$render()

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