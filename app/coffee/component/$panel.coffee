

nb = @.nb
app = nb.app



app.provider '$panel', () ->

    Provider =($injector, $rootScope, $q, $http, $templateCache, $controller, $modalStack) ->
        $panel = {};

        getTemplatePromise = (options) ->
            if options.template
                $q.when(options.template)
            else
                request = if angular.isFunction(options.templateUrl) then options.templateUrl() else options.templateUrl
                $http.get(request, {cache: $templateCache})
                    .then (result) ->
                        return if angular.isString(result) then result else result.data

        getResolvePromises =  (resolves) ->
            promisesArr = []
            angular.forEach resolves, (value) ->
                if angular.isFunction(value) or angular.isArray(value)
                    promisesArr.push($q.when($injector.invoke(value)))

            return promisesArr

        $panel.open = (panelOptions) ->
            panelResultDeferred = $q.defer()
            panelOpenedDeferred = $q.defer()

            # prepare an instance of a panel to be injected into controllers and returned to a caller

            panelInstance = {
                result: panelResultDeferred.promise
                opened: panelOpenedDeferred.promise
                close: (result) ->
                    $modalStack.close(panelInstance, result)
                dismiss: (reason) ->
                    $modalStack.dismiss(panelInstance, reason)
            }

            panelOptions = angular.extend({}, $panelProvider.options, panelOptions)

            panelOptions.resolve = panelOptions.resolve or {}

            #verify options
            if !panelOptions.template and !panelOptions.templateUrl
                throw new Error('One of temlate or templateUrl options is required.')

            templateAndResolvePromise =
                $q.all([getTemplatePromise(panelOptions)].concat(getResolvePromises(panelOptions.resolve)))

            templateAndResolvePromise.then (tplAndVars)->
                panelScope = (panelOptions.scope or $rootScope).$new()

                panelScope.$close = panelInstance.close
                panelScope.$dismiss = panelInstance.dismiss

                ctrlLocals = {}
                resolveIter = 1

                #controllers

                if panelOptions.controller
                    ctrlLocals.$scope = panelScope
                    ctrlLocals.$panelInstance = panelInstance

                    angular.forEach panelOptions.resolve, (value, key) ->
                        ctrlLocals[key] = tplAndVars[resolveIter++]

                    # 参数直接传递已实例化的 controller 对象, 可行否?
                    ctrlInstance = $controller panelOptions.controller, ctrlLocals

                    if panelOptions.controllerAs
                        panelScope[panelOptions.controllerAs] = ctrlInstance

                $modalStack.open panelInstance, {
                    scope: panelScope
                    deferred: panelResultDeferred
                    content: tplAndVars[0]
                    backdrop: panelOptions.backdrop
                    keyboard: panelOptions.keyboard
                    backdropClass: panelOptions.backdropClass
                    windowCalss: panelOptions.windowCalss
                    windowTemplateUrl: 'partials/component/panel/window.html'
                    size: panelOptions.size
                }

                templateAndResolvePromise.then null, (reason) ->
                    panelResultDeferred.reject(reason)


                templateAndResolvePromise.then(() ->
                    panelOpenedDeferred.resolve(true)
                    return
                ,() ->
                    panelOpenedDeferred.reject(false)
                    return
                )
                return

            return panelInstance

        return $panel




    $panelProvider = {
        options: {
            backdrop: true # can be also false or 'static'
            keyboard: true
        }

        $get: ['$injector', '$rootScope', '$q', '$http', '$templateCache', '$controller', '$modalStack', Provider]
    }

    return $panelProvider


