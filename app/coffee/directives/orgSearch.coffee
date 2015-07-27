singleTemplate =  '''
        <md-autocomplete
            md-items="org in ctrl.queryMatched(ctrl.searchText)"
            md-item-text="org.fullName"
            md-selected-item="ctrl.org"
            md-search-text="ctrl.searchText"
            md-selected-item-change="onSelectedItemChange(org)"
            md-delay="200"
            #placeholder#
            md-no-cache="true"
            ><span md-highlight-text="ctrl.searchText">{{org.fullName}}</span></md-autocomplete>
    '''
            # md-min-length=""


multipleTemplate = '''
    <md-chips ng-model="ctrl.$orgs" >
        <md-autocomplete md-item-text="org.fullName"
            md-items="org in ctrl.queryMatched(ctrl.searchText)"
            placeholder="机构"
            md-search-text="ctrl.searchText"
            md-selected-item="ctrl.org"
            md-delay="200"
            md-autoselect
            >
            <span md-highlight-text="ctrl.searchText">{{org.fullName || org.name}}</span>
        </md-autocomplete>
        <md-chip-template>
            <span ng-bind="$chip.fullName"></span>
        </md-chip-template>
    </md-chips>
'''


angular.module 'nb.directives'
    .directive 'orgSearch', ['OrgStore', '$timeout', (OrgStore, $timeout) ->
        template = (elem, attrs) ->
            if angular.isDefined attrs.multiple
                return multipleTemplate
            else
                placeholder = attrs.placeholder || '机构'
                placeholder_str = if angular.isDefined(attrs.floatLabel) then "md-floating-label='#{placeholder}'" else "placeholder='#{placeholder}'"

                tmpl = singleTemplate.replace("#placeholder#", placeholder_str)
                return tmpl

        postLink = (scope, elem, attrs, ctrl) ->
            isMultiple = true if angular.isDefined(attrs.multiple)
            ngModelCtrl = ctrl if ctrl

            onSelectedItemChange = (org) ->
                return if !org
                ngModelCtrl.$setViewValue(org) if ngModelCtrl
                scope.selectedItemChange({org: org})

            scope.onSelectedItemChange = onSelectedItemChange

            if isMultiple && ngModelCtrl
                # fix 指令初始化时 ngmodel, viewValue 还未初始化
                if ngModelCtrl
                    attr =  attrs.ngModel
                    initialValue = scope.$parent[attr]
                    scope.ctrl.$orgs = OrgStore.getOrgsByIds(initialValue) if initialValue

                scope.$watchCollection 'ctrl.$orgs', (newValue, old) ->
                    if newValue
                        org_ids = newValue.map (org) -> return org.id
                        ngModelCtrl.$setViewValue(org_ids)

            if ngModelCtrl
                ngModelCtrl.$render = ->
                    if ngModelCtrl.$viewValue && ngModelCtrl.$viewValue.name
                        # scope.ctrl.org = ngModelCtrl.$viewValue
                        scope.ctrl.searchText = ngModelCtrl.$viewValue.name
                        # $timeout(->
                        #     elem.find('input').val(ngModelCtrl.$viewValue.name)
                        # , 200)
                    # scope.ctrl.org = if ngModelCtrl.$viewValue then ngModelCtrl.$viewValue

        return {
            require: '?ngModel'
            scope: {
                selectedItemChange: '&'
            }
            template: template
            link: postLink
            controller: OrgSearchCtrl
            controllerAs: 'ctrl'
        }
    ]


class OrgSearchCtrl
    @.$inject = ['$scope', 'OrgStore', '$attrs']

    constructor: (scope, @OrgStore, attrs) ->
        @$orgs = [] if angular.isDefined(attrs.multiple)

    queryMatched: (text) ->
        @OrgStore.queryMatchedOrgs(text)