angular.module 'nb.directives'
    .directive 'mutiEnumSearch', ['$enum', ($enum) ->
        #筛选器中支持选择多个属地
        multipleTemplate = '''
            <md-chips ng-model="ctrl.$enums" >
                <md-autocomplete md-item-text="enum.label"
                    md-items="enum in ctrl.queryMatched(ctrl.searchText)"
                    md-search-text="ctrl.searchText"
                    md-selected-item="ctrl.enum"
                    md-delay="200"
                    md-autoselect
                    >
                    <span md-highlight-text="ctrl.searchText">{{enum.label}}</span>
                </md-autocomplete>
                <md-chip-template>
                    <span ng-bind="$chip.label"></span>
                </md-chip-template>
            </md-chips>
        '''

        postLink = (scope, elem, attrs, ctrl)->
            ngModelCtrl = ctrl
            if ngModelCtrl
                attr =  attrs.ngModel
                initialValue = scope.$parent[attr]
                scope.ctrl.$enums = $enum.getEnumsByIds(initialValue, attrs['enumKey']) if initialValue
                scope.$watchCollection 'ctrl.$enums', (newValue, old) ->
                    if newValue
                        enum_ids = newValue.map (item) -> return item.id
                        ngModelCtrl.$setViewValue(enum_ids)
                ngModelCtrl.$render = ->
                    if ngModelCtrl.$viewValue && ngModelCtrl.$viewValue.name
                        scope.ctrl.searchText = ngModelCtrl.$viewValue.name

        return {
            scope: {
                enumKey: '@'
            }
            restrict: 'E'
            link: postLink
            require: '?ngModel'
            template: multipleTemplate
            controller: MutiEnumSearchCtrl
            controllerAs: 'ctrl'
        }
    ]


class MutiEnumSearchCtrl
    @.$inject = ['$scope', '$enum']

    constructor: (@scope, @enumService) ->
        @$enums = []

    queryMatched: (text) ->
        return new Error("enum-key attr is needed!") if !@scope.enumKey
        enums = @enumService.get @scope.enumKey
        enums = enums.filter (item) -> s.include(item.label, text)