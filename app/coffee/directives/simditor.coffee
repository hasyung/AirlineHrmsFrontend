angular.module 'nb.directives'
    .constant 'simditorConfig', {
        textarea: null
        upload: true
        toolbar: [
            'title'          # 标题文字
            'bold'           # 加粗文字
            'italic'         # 斜体文字
            'underline'      # 下划线文字
            'strikethrough'  # 删除线文字
            'ol'             # 有序列表
            'ul'             # 无序列表
            'blockquote'     # 引用
            'code'           # 代码
            'table'          # 表格
            'link'           # 插入链接
            'image'          # 插入图片
            'hr'             # 分割线
            'indent'         # 向右缩进
            'outdent'        # 向左缩进
        ]
        tabIndent: true
        toolbarFloat: true
        pasteImage: false
    }
    .directive 'simditor', ['$timeout','simditorConfig',($timeout,defaultConfig) ->
        return {
            restrict: 'A'
            replace: true
            require: 'ngModel'
            scope: {
                textVal: '=ngModel'
            }
            link: (scope,elem,attrs,ctrl) ->
                opts = angular.extend {},defaultConfig,{textarea:elem}
                editor = new Simditor opts
                editor.on 'valuechanged', () ->
                    fn = _.throttle(() ->
                        scope.$apply ()->
                            ctrl.$setViewValue editor.getValue()

                    ,2000)
                    fn()

                #当编辑文章时初始化文本
                ctrl.$render = () ->
                    editor.setValue(ctrl.$modelValue)
                # if attrs.editable == "false"
                #     editor.body.attr("contenteditable", false)
                scope.$watch 'editable',(newVal,old) ->
                    if newVal == false
                        editor.body.attr('contenteditable',false)

                scope.$on '$destroy', () ->
                    editor.destroy()
        }
    ]