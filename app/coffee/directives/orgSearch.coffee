


singleTemplate =  '''
        <md-autocomplete
            md-items="org in ctrl.queryMatched(ctrl.searchText)"
            md-item-text="org.fullName"
            md-selected-item="org"
            md-search-text="ctrl.searchText"
            placeholder="想查找啥机构呢？"
            md-selected-item-change="onSelectedItemChange(org)"
            md-delay="200"
            md-autoselect
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
            md-selected-item="org"
            md-delay="200"
            md-autoselect
            >
            <span md-highlight-text="ctrl.searchText">{{org.fullName}}</span>
        </md-autocomplete>
        <md-chip-template>
            <span ng-bind="$chip.fullName"></span>
        </md-chip-template>
    </md-chips>
'''


angular.module 'nb.directives'
    .directive 'orgSearch', ['OrgStore', (OrgStore) ->

        template = (elem, attrs) ->
            tmpl =  if angular.isDefined(attrs.multiple) then multipleTemplate else singleTemplate
            return tmpl

        postLink = (scope, elem, attrs, ctrl) ->
            isMultiple = true if angular.isDefined(attrs.multiple)
            ngModelCtrl = ctrl if ctrl

            onSelectedItemChange = (org) ->
                ngModelCtrl.$setViewValue(org) if ngModelCtrl
                scope.selectedItemChange({org: org})

            scope.onSelectedItemChange = onSelectedItemChange

            if isMultiple && ngModelCtrl
                scope.$watchCollection 'ctrl.$orgs', (newValue, old) ->
                    if newValue
                        org_ids = newValue.map (org) -> return org.id
                        ngModelCtrl.$setViewValue(org_ids)


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