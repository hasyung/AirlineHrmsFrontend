angular.module 'nb.directives'
    .directive 'nbGalleryBox', [()->
        class ImgBoxsCtrl
            @.$inject = ['$scope']
            constructor: (@scope)->
                @annexs = [{url:'images/test/test1.jpg'}, {url:'images/test/test2.jpg'}]
                @currentImg = @annexs[@selectIndex]

        postLink = (scope, elem, attr, ctrl)->


        return {
            restrict: 'A'
            link: postLink
            replace: true
            controller: ImgBoxsCtrl
            controllerAs: 'ctrl'
            templateUrl: 'partials/common/gallery_box.tpl.html'

        }
    ]

    .directive 'nbGallery', ['$mdDialog', '$document', ($mdDialog, $document)->
        class GalleryCtrl
            @.$inject = ['$scope']
            constructor: (@scope) ->
                @imgs = [{url:'images/test/test1.jpg'}, {url:'images/test/test2.jpg'}]
                @selectIndex = 0
                @currentImg = @imgs[@selectIndex]

            setSelectImg: (index)->
                @selectIndex = index
                @setCurrentImg()

            setCurrentImg: ()->
               @currentImg = @imgs[@selectIndex] 

            nextImg: ()->
                if @selectIndex < (@imgs.length - 1) then @selectIndex +=1 else @selectIndex
                @setCurrentImg()
            prevImg: ()->
                if @selectIndex > 0 then @selectIndex -= 1 else @selectIndex
                @setCurrentImg()
                    
        
        postLink = (scope, elem, attr, ctrl)->
            $doc = angular.element $document
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


            $doc.on 'keydown', setCurrentImg
            scope.$on 'destroy', ()->
                $doc.off 'keydown', setCurrentImg

        return {
            restrict: 'A'
            # require: ['^?nbGalleryBox', 'nbGallery']
            replace: true
            templateUrl: 'partials/common/gallery.tpl.html'
            controller: GalleryCtrl
            controllerAs: 'ctrl'
            link: postLink

        }
    ]
