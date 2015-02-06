# ui-boostrap tabs inspired



com = angular.module('nb.component')



class TabsetCtrl
    @.$inject = ['$scope']

    constructor: (scope) ->
        self = @
        @tabs = scope.tabs = []
        @destroyed = undefined

        scope.$on '$destroy', -> self.destroyed

    select: (selectedTab) ->
        angular.forEach @tabs, (tab) ->
            if tab.active && tab != selectedTab
                tab.active = false
                tab.onDeselect()
        selectedTab.active = true
        selectedTab.onSelect()
    addTab: (tab) ->
        @tabs.push(tab)

        if @tabs.length == 1
            tab.active = true
        else if tab.active
            @select(tab)

    removeTab: (tab) ->
        index = @tabs.indexOf(tab)

        if tab.active && @tabs.length > 1 && @destroyed
            newActiveIndex = index = if @tabs.length - 1 then index - 1 else index + 1
            @select(@tabs[newActiveIndex])
        tabs.splice(index, 1)


tabsetDirective = ->
    postLink = (scope, elem, attrs) ->
        scope.vertical = if angular.isDefined(attrs.vertical) then scope.$parent.$eval(attrs.vertical) else false
        scope.justified = if angular.isDefined(attrs.justified) then scope.$parent.$eval(attrs.justified) else false


    return {
        restrict: 'EA'
        transclude: true
        replace: true
        scope:
            type: '@'
        controller: 'TabsetCtrl'
        templateUrl: 'partials/component/tab/tabset.html'
    }


tabDirective = ($parse) ->

    return {
        require: '^tabset'
        restrict: 'EA'
        replace: true
        templateUrl: 'partials/component/tab/tab.html'
        transclude: true
        scope: {
            active: '=?'
            heading: '@'
            onSelect: '&select'
            onDeselect: '&deselect'
        }
        controller: ->
        compile: (elem, attrs, transclude) ->

            postlink = (scope, elem, attrs, tabsetCtrl) ->
                scope.$watch 'active', (active) ->
                    tabsetCtrl.select(scope) if active

                scope.disabled = false

                scope.$parent.$watch $parse(attrs.disabled), (value) ->
                    scope.disabled = !!value

                scope.select = ->
                    scope.active = true if !scope.disabled

                tabsetCtrl.addTab(scope)

                scope.$on '$destroy', ->
                    tabsetCtrl.removeTab(scope)

                scope.$transcludeFn = transclude

            return postlink


    }


tabHeadingTranscludeDirective = ->

    postlink = (scope, elem, attrs, tabCtrl) ->
        scope.$watch 'headingElement', (heading) ->
            elem.html('').append(heading) if heading

    return {
        restrict: 'A'
        require: '^tab'
        link: postlink
    }

tabContentTranscludeDirective = ->

    isTabHeading = (node) ->
        return node.tagName && (
            node.hasAttribute('tab-heading') ||
            node.hasAttribute('data-tab-heading') ||
            node.tagName.toLowerCase() == 'tab-heading' ||
            node.tagName.toLowerCase() == 'data-tab-heading'
            )

    postlink = (scope, elem, attrs) ->
        tab = scope.$eval(attrs.tabContentTransclude)

        tab.$transcludeFn tab.$parent, (contents) ->
            angular.forEach contents, (node) ->
                if isTabHeading(node)
                    tab.headingElement = node
                else
                    elem.append(node)


com.controller 'TabsetCtrl', TabsetCtrl
com.directive 'tabset', tabsetDirective
com.directive 'tab', ['$parse', tabDirective]
com.directive 'tabHeadingTransclude', tabHeadingTranscludeDirective
com.directive 'tabContentTransclude', tabContentTranscludeDirective








