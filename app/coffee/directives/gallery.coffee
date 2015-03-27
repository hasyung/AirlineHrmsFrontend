angular.module 'nb.directives'
    .directive 'nbGalleryBox', ['$q', '$compile', '$document', '$templateCache', '$http', ($q, $compile, $document, $templateCache, $http)->
        postLink = (scope, elem, attr, ctrl)->
            $doc = angular.element $document
            linker = gallery = template = undefined
            $body = angular.element("body")
            $clientWidth = $doc.width()
            $clientHeight = $doc.height()

            if !attr.templateUrl
                throw Error("gallery needs a template!")
            fetchTemplate = (templateUrl)->
                return $q.when($templateCache.get(templateUrl) || $http.get(templateUrl)).then (res)->
                    if angular.isObject res
                        $templateCache.put templateUrl, res.data
                        return res.data
                    return res
            
            promise = fetchTemplate attr.templateUrl

            bindBody = (template)->
                linker = $compile template
                gallery = linker scope
                imgBox = gallery.find(".main-img")
                imgBox.css "width", "#{$clientWidth - 210}px"
                imgBox.css "height", "#{$clientHeight - 150}px"
                $body.append(gallery)
                scope.modalShow = true
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
            destroyGallery = ()->
                gallery.remove() if gallery
                scope.modalShow = false
            addGalleryListener = (e)->
                targetEle = angular.element(e.target)
                if targetEle.closest(".nb-modal-touchable").length == 0
                    destroyGallery()
                e.stopPropagation()                    

            scope.$watch ()->
                scope.modalShow
            , (newVal)->
                if newVal
                    gallery.on 'click', addGalleryListener
                else 
                    gallery.off 'click' if gallery


            elem.on 'click', (e)->
                e.stopPropagation()
                showGallery()


            $doc.on 'keydown', setCurrentImg

            scope.$on 'destroy', ()->
                $doc.off 'keydown', setCurrentImg
                elem.off 'click'

        return {
            restrict: 'A'
            replace: true
            controller: ImgBoxsCtrl
            controllerAs: 'ctrl'
            templateUrl: 'partials/common/gallery_box.tpl.html'
            link: postLink
            scope:{
                imgs: "=galleryData"
            }

        }
    ]
class ImgBoxsCtrl
    @.$inject = ['$scope']
    constructor: (@scope)->
        # @scope.imgs = [{url:'images/test/test1.jpg'}, {url:'images/test/test2.jpg'},{url:'images/test/test1.jpg'}, {url:'images/test/test2.jpg'},{url:'images/test/test1.jpg'}, {url:'images/test/test2.jpg'},{url:'images/test/test1.jpg'}, {url:'images/test/test2.jpg'},{url:'images/test/test1.jpg'}, {url:'images/test/test2.jpg'},{url:'images/test/test1.jpg'}, {url:'images/test/test2.jpg'},{url:'images/test/test1.jpg'}, {url:'images/test/test2.jpg'},{url:'images/test/test1.jpg'}, {url:'images/test/test2.jpg'},{url:'images/test/test1.jpg'}, {url:'images/test/test2.jpg'},{url:'images/test/test1.jpg'}, {url:'images/test/test2.jpg'},{url:'images/test/test1.jpg'}, {url:'images/test/test2.jpg'},{url:'images/test/test1.jpg'}, {url:'images/test/test2.jpg'}]
        @selectedIndex = 0
        @currentImg = @scope.imgs[@selectedIndex]
        @scope.modalShow = false
    setSelectedImg: (index)->
        @selectedIndex = index
        @setCurrentImg()

    setCurrentImg: ()->
       @currentImg = @scope.imgs[@selectedIndex] 

    nextImg: ()->
        if @selectedIndex < (@scope.imgs.length - 1) then @selectedIndex +=1 else @selectedIndex
        @setCurrentImg()
    prevImg: ()->
        if @selectedIndex > 0 then @selectedIndex -= 1 else @selectedIndex
        @setCurrentImg()
    
