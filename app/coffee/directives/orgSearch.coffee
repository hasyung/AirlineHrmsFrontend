
angular.module 'nb.directives'
    .directive 'orgSearch', ['OrgStore', (OrgStore) ->

        template = '''
            <md-autocomplete
                md-items="org in ctrl.queryMatched(ctrl.searchText)"
                md-item-text="org.fullName"
                md-selected-item="org"
                md-search-text="ctrl.searchText"
                md-min-length="0"
                placeholder="想查找啥机构呢？"
                md-selected-item-change="onSelectedItemChange({org: org})"
                md-delay="200"
                md-autoselect
                md-no-cache="true"
                ><span>{{org.fullName}}</span></md-autocomplete>

        '''

        postLink = (scope, elem, attr, ctrl) ->
            return if !ctrl

            onSelectedItemChange = (org) ->
                ctrl.$setViewValue(org)
                scope.selectedItemChange({org: org})

            scope.onSelectedItemChange = onSelectedItemChange


        return {
            require: '?ngModel'
            scope: {
                selectedItemChange: '&'
            }
            template: template
            # link: postLink
            controller: OrgSearchCtrl
            controllerAs: 'ctrl'
        }
    ]

class OrgSearchCtrl
    @.$inject = ['$scope', 'OrgStore']

    constructor: (scope, @OrgStore) ->

    queryMatched: (text) ->
        @OrgStore.queryMatchedOrgs(text)