angular.module 'nb.directives'
    .directive 'nbDropdown', ['$http', 'inflector', '$window', ($http, inflector, $window)->


        class DropdownCtrl
            @.$inject = ['$http','$attrs','$scope']
            constructor: (@http, @attrs, @scope) ->
                self = @
                @scope.isOpen = false
                @options = []
                @scope.additory = true

                onSuccess = (data, status) ->
                    self.options = _.map data.result, (item) ->
                        _.reduce(item, (res, val, key) ->
                            res[inflector.camelize(key)] = val
                            return res
                        , {})

                onError = ->
                    self.scope.$emit('dropdown:notfound')

                @http.get("/api/enum?key=#{@attrs.remoteKey}")
                    .success onSuccess
                    .error onError
            setSelected: ($index) ->
                # @selected = _.clone @options[$index]
                # @scope.selected = _.clone @options[$index]
                # @scope.$apply () ->
                @scope.selected = _.clone @options[$index]
                # @scope.$emit('select:change', selected)
                # @scope.$emit('options:change', @selected)
                @close()

                # @scope.$digest()
            addItem: (evt, form , newItem) ->
                evt.preventDefault()
                @options.push(newItem)
                @options = _.uniq(@options)
                @setSelected(@options.length - 1)
                @newItem = ""
                form.$setPristine()


            toggle: () ->
                @isOpen = !@isOpen

            close: () ->
                @isOpen = false

        postLink = (scope, elem, attr, $ctrl) ->
            $doc = angular.element $window.document
            scope.isOpen = false
            scope.additory = ((attr.additory || "true") is "true")
            dropdownCtrl = $ctrl[0]
            ngModelCtrl = $ctrl[1]
            elem.on 'click', (e)->
                e.stopPropagation()
                scope.$apply () ->
                    ngModelCtrl.$touched = true
            $doc.on 'click', (e)->
                e.stopPropagation()
                scope.$apply ()->
                    dropdownCtrl.close()
                    # dropdownCtrl.close() 返回false，将阻止submit按钮的提交事件的触发
                    return true
                    
            # view to model
            # ngModelCtrl.$parsers.unshift (inputVal) ->
            #     console.debug "inputVal:", arguments
            #     return inputVal
            # # model to view
            # ngModelCtrl.$formatters.unshift (inputVal) ->
            #     console.debug "formatters : ", inputVal
            #     return inputVal

            scope.$watch 'selected', (newVal) ->
                console.debug 'selected:change', newVal
                scope.selected = newVal
                ngModelCtrl.$render()

            scope.$on '$destroy', () ->
                elem.off 'click'
                $doc.off 'click'

        return {
            restrict: 'EA'
            templateUrl: 'partials/common/dropdown.tpl.html'
            replace: true
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