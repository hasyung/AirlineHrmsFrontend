angular.module 'nb.directives'
    .directive 'nbAnnexsBox', [()->
        template = '''
        <div class="annex-container">
            <div ng-repeat="annex in annexs"  class="pull-left annex-item">
                <div ng-if="ctrl.isImgObj(annex)" template-url="/partials/common/gallery.tpl.html" nb-gallery img-obj="annex" style="width:100px;height:60px;border:1px solid #000;"></div>
                <div ng-if="!ctrl.isImgObj(annex)" style="width:100px;height:60px;border:1px solid #000;"></div>

            </div>
        </div>
        '''

        class AnnexCtrl
            @.$inject = ['$scope']
            imgRex = /jpg|jpeg|png|gif/
            constructor: (@scope)->
                
            getImgs: ()->
                imgs = []
                angular.forEach @scope.annexs, (item)->
                    imgs.push(item) if imgRex.test(item.type)
                imgs

            isImgObj: (obj)->
                return imgRex.test(obj.type)




        return {
            restrict: 'A'
            replace: true
            template: template
            scope:{
                annexs: "="
            }
            controller: AnnexCtrl
            controllerAs: "ctrl"

        }
    ]

    .directive 'nbGallery', ['$q', '$compile', '$document', '$templateCache', '$http', ($q, $compile, $document, $templateCache, $http)->
        

        class GalleryCtrl
            @.$inject = ['$scope']
            constructor: (@scope)->
                @scope.modalShow = false
            setSelectedImg: (img)->
                @scope.currentImg = img

            nextImg: ()->
                index = _.findIndex @scope.imgs, @scope.currentImg
                @scope.currentImg = if @scope.imgs[index + 1] then @scope.imgs[index + 1] else @scope.currentImg
            prevImg: ()->
                index = _.findIndex @scope.imgs, @scope.currentImg
                @scope.currentImg = if @scope.imgs[index - 1] then @scope.imgs[index - 1] else @scope.currentImg

        postLink = (scope, elem, attr, ctrl)->
            $doc = angular.element $document
            $body = angular.element("body")

            template = '''
                <div class="modal-container">
                    <div>
                      <div class="main-img-container">
                        <img ng-src="{{currentImg.url}}" class="main-img"/>
                        <div ng-click="ctrl.nextImg()" class="next-img nb-modal-touchable"></div>
                        <div ng-click="ctrl.prevImg()" class="prev-img nb-modal-touchable"></div>
                      </div>
                      <div class="img-list nb-modal-touchable">
                        <div ng-repeat="img in imgs" ng-click="ctrl.setSelectedImg(img)" ng-class="{'active': currentImg == img}" class="img-list-item">
                            <a href="javascript:;">
                                <img ng-src="{{img.url}}"/>
                            </a>
                        </div>
                      </div>
                    </div>
                  <div class="img-info-bar nb-modal-touchable"><span ng-bind="currentImg.url.split('/').pop()" class="img-name"> </span>
                    <div class="gallery-control"><span class="download-file"><a ng-href="{{currentImg.url}}" target="_blank" download="{{currentImg.url.split('/').pop()}}" title="下载"><i class="fa fa-download"></i></a></span><span class="view-file"><a ng-href="{{currentImg.url}}" target="_blank" title="查看"><i class="fa fa-external-link"></i></a></span></div>
                  </div>
                </div>
            '''

            singleTemplate = '''
                <div class="modal-container">
                    <div>
                      <div class="main-img-container">
                        <img ng-src="{{currentImg.url}}" class="main-img"/>
                      </div>
                    </div>
                  <div class="img-info-bar nb-modal-touchable single"><span ng-bind="currentImg.url.split('/').pop()" class="img-name"> </span>
                    <div class="gallery-control"><span class="download-file"><a ng-href="{{currentImg.url}}" target="_blank" download="{{currentImg.url.split('/').pop()}}" title="下载"><i class="fa fa-download"></i></a></span><span class="view-file"><a ng-href="{{currentImg.url}}" target="_blank" title="查看"><i class="fa fa-external-link"></i></a></span></div>
                  </div>
                </div>
            '''

            annexCtrl = ctrl[0]
            galleryCtrl = ctrl[1]
            scope.imgs = []
            scope.imgs = annexCtrl.getImgs() if annexCtrl
            scope.isMuti = if scope.imgs.length > 1 then true else false


            getImgSize = (imgObj)->
                img = new Image()
                img.src = imgObj.url
                {
                    width: img.naturalWidth
                    height: img.naturalHeight
                }

            getImgBoxSize = ()->
                # 多图片预览，图片盒子的大小
                return {width: ($doc.width() - 210), height: ($doc.height() - 150)} if scope.isMuti
                # 单图片预览，图片盒子的尺寸
                return {width: ($doc.width() - 80), height: ($doc.height() - 150)}

            bindBody = ()->
                template = if scope.isMuti then template else singleTemplate
                linker = $compile template
                scope.gallery = linker scope
                imgBoxSize = getImgBoxSize()
                imgBox = scope.gallery.find(".main-img-container")
                imgBox.css "width", "#{imgBoxSize.width}px"
                imgBox.css "height", "#{imgBoxSize.height}px"
                $body.append(scope.gallery)

            setImgSize = (imgSize, boxSize)->
                imgW2H = imgSize.width/imgSize.height
                boxW2H = boxSize.width/boxSize.height
                imgDom = scope.gallery.find(".main-img")
                if boxW2H >= imgW2H
                    imgHeight = if boxSize.height > imgSize.height then imgSize.height else boxSize.height
                    imgDom.css 'height', "#{imgHeight}px"
                    imgDom.css 'width', ""
                else
                    imgWidth = if boxSize.width > imgSize.width then imgSize.width else boxSize.width
                    imgDom.css 'width', "#{boxSize.width}px"
                    imgDom.css 'height', ""

            showGallery = ()->
                bindBody template
                scope.$apply ()->
                    scope.modalShow = true
            setCurrentImg = (e)->
                #下一张
                #向下和向右
                if e.keyCode == 40 || e.keyCode == 39
                    scope.$apply ()->
                        galleryCtrl.nextImg()
                #上一张
                else if e.keyCode == 38 || e.keyCode == 37
                    scope.$apply ()->
                        galleryCtrl.prevImg()
            destroyGallery = ()->
                scope.gallery.remove() if scope.gallery
                scope.$apply ()->
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
                    scope.gallery.on 'click', addGalleryListener
                else 
                    scope.gallery.off 'click' if scope.gallery  

            scope.$watch ()->
                scope.currentImg
            , (newVal)->
                return if !scope.modalShow
                imgSize = getImgSize(newVal)
                boxSize = getImgBoxSize()
                setImgSize(imgSize, boxSize)
                

            elem.on 'click', (e)->
                e.stopPropagation()
                showGallery()

            if scope.imgs && scope.imgs.length > 1
                $doc.on 'keydown', setCurrentImg

            scope.$on 'destroy', ()->
                $doc.off 'keydown', setCurrentImg
                elem.off 'click'                 

        return {
            restrict: 'A'
            scope: {
                currentImg: '=imgObj'
            }
            require: ['^?nbAnnexsBox', 'nbGallery']
            link: postLink
            controller: GalleryCtrl
            controllerAs: "ctrl"

        }
    ]
