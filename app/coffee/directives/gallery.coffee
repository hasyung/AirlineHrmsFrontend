angular.module 'nb.directives'
    .directive 'nbGalleryBox', ['$q', '$compile', '$document', '$templateCache', '$http', ($q, $compile, $document, $templateCache, $http)->

        class ImgBoxsCtrl
            @.$inject = ['$scope']
            constructor: (@scope)->
                @imgs = [{url:'images/test/test1.jpg'}, {url:'images/test/test2.jpg'}]
                @selectedIndex = 0
                @currentImg = @imgs[@selectedIndex]
            setSelectedImg: (index)->
                @selectedIndex = index
                @setCurrentImg()

            setCurrentImg: ()->
               @currentImg = @imgs[@selectedIndex] 

            nextImg: ()->
                if @selectedIndex < (@imgs.length - 1) then @selectedIndex +=1 else @selectedIndex
                @setCurrentImg()
            prevImg: ()->
                if @selectedIndex > 0 then @selectedIndex -= 1 else @selectedIndex
                @setCurrentImg()
            

        compile = (element, attr)->
            fetchTemplate = (templateUrl)->
                return $q.when($templateCache.get(templateUrl) || $http.get(templateUrl)).then (res)->
                    if angular.isObject res
                        $templateCache.put templateUrl, res.data
                        return res.data
                    return res
            if !attr.templateUrl
                throw Error("gallery needs a template!");
            promise = fetchTemplate attr.templateUrl
            promise.then (template)->
                template = template.data if template

            postLink = (scope, elem, attr, ctrl)->
                $doc = angular.element $document
                linker = gallery = template = undefined
                $body = angular.element("body")

                bindBody = (template)->
                    linker = $compile template
                    gallery = linker scope
                    $body.append(gallery)
                showGallery = ()->
                    if template
                        bindBody template
                    else
                        promise.then (template)-> bindBody template
                setCurrentImg = (e)->
                    #下一张
                    #向下和向右
                    if e.keyCode == 40 || e.keyCode == 39
                        scope.$apply ()->
                            ctrl.nextImg()
                    #上一张
                    else if e.keyCode == 38 || e.keyCode == 37
                        scope.$apply ()->
                            ctrl.prevImg()


                elem.on 'click', ()->
                    showGallery()

                $doc.on 'keydown', setCurrentImg


                scope.$on 'destroy', ()->
                    $doc.off 'keydown', setCurrentImg
                
            return {
                post: postLink
            }

        return {
            restrict: 'A'
            replace: true
            controller: ImgBoxsCtrl
            controllerAs: 'ctrl'
            templateUrl: 'partials/common/gallery_box.tpl.html'
            compile: compile

        }
    ]

    # .directive 'nbGallery', ['$mdDialog', '$document', ($mdDialog, $document)->
    #     class GalleryCtrl
    #         @.$inject = ['$scope']
    #         constructor: (@scope) ->
    #             @imgs = [{url:'images/test/test1.jpg'}, {url:'images/test/test2.jpg'}]
    #             @selectIndex = 0
    #             @currentImg = @imgs[@selectIndex]

    #         setSelectImg: (index)->
    #             @selectIndex = index
    #             @setCurrentImg()

    #         setCurrentImg: ()->
    #            @currentImg = @imgs[@selectIndex] 

    #         nextImg: ()->
    #             if @selectIndex < (@imgs.length - 1) then @selectIndex +=1 else @selectIndex
    #             @setCurrentImg()
    #         prevImg: ()->
    #             if @selectIndex > 0 then @selectIndex -= 1 else @selectIndex
    #             @setCurrentImg()
                    
        
    #     postLink = (scope, elem, attr, ctrl)->
    #         $doc = angular.element $document
    #         setCurrentImg = (e)->
    #             #下一张
    #             #向下和向右
    #             if e.keyCode == 40 || e.keyCode == 39
    #                 scope.$apply ()->
    #                     ctrl.nextImg()
    #             #上一张
    #             else if e.keyCode == 38 || e.keyCode == 37
    #                 scope.$apply ()->
    #                     ctrl.prevImg()


    #         $doc.on 'keydown', setCurrentImg
    #         scope.$on 'destroy', ()->
    #             $doc.off 'keydown', setCurrentImg

    #     return {
    #         restrict: 'A'
    #         # require: ['^?nbGalleryBox', 'nbGallery']
    #         replace: true
    #         templateUrl: 'partials/common/gallery.tpl.html'
    #         controller: GalleryCtrl
    #         controllerAs: 'ctrl'
    #         link: postLink

    #     }
    # ]
