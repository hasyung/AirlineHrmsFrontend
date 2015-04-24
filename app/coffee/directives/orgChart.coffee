# // depth 修改

# treeData = {
#     root: root
# }


app = @nb.app



orgChartDirective = ->

    postLink = (scope, elem, attr) ->

        # onItemClick = ->
        #     scope.$apply -> scope.onItemClick()
        clickHandler = (evt) ->
            scope.$apply ->
                scope.onItemClick(evt:evt)


        options = {
            container: elem[0]
            rectBgColor: '#dfe5e7'  #树节点的正常状态的颜色
            hasChildColor: '#C9D4D7'  #还有为展开的子节点的节点的颜色
            rectWidth: 36  #节点宽度
            rectHeight: 160  #节点高度
            rectBorderRadius: 8  #节点方块的圆角半径
            borderWidth: 1  #节点方块的边框线宽
            rectVerticalSpacing: 50  #节点方块之间的垂直间距
            rectHorizontalSpacing: 30 #节点之间水平间距
            linkColor: '#c4cfd3'  #连接线的颜色
            linkWidth: '3'  #连接线的线宽
            selectColor: '#90d7ff'  #节点方块被选中状态的颜色
            duration: 750  #动画效果的时长
            clickHandler: clickHandler
        }

        destroyChart = -> d3.select(elem.find('svg')[0]).remove()

        scope.$watch 'orgChartData', (newVal) -> render(newVal, options) if newVal
        scope.$on '$destroy', () -> destroyChart()
        render(scope.orgChartData, options)

    return {
        link: postLink
        scope: {
            orgChartData: '='
            onItemClick: '&'
        }
    }


render = (root, options) ->
    container = options.container
    # cleanup
    d3.select(container.querySelector('svg')).remove()

    if root.xdepth == 1
        drawOrgChart(root, options)
    else
        drawTreeChart(root, options)

update = () ->
# nature.name 分类
# shengchanbumen
# jiguanbumen
# fengongsijidi
drawOrgChart = (root, options) ->
    active_node = null

    container             = options.container
    nature_type_order     = ['jiguanbumen', 'shengchanbumen', 'fengongsijidi']
    nature_type_order.unshift('root') # root not exist nature
    rectHeight            = options.rectHeight || 180
    rectWidth             = options.rectWidth || 36
    rectVerticalSpacing   = options.rectVerticalSpacing
    rectHorizontalSpacing = options.rectHorizontalSpacing
    linkColor             = options.linkColor
    linkWidth             = options.linkWidth
    rectBorderRadius      = options.rectBorderRadius
    borderWidth           = options.borderWidth
    rectBgColor           = options.rectBgColor
    selectColor           = options.selectColor
    rectClickHandler      = options.clickHandler

    computeLayerMaxLength = (root) ->
        length_group = _.countBy root.children, (org) -> return org.nature.name
        return _.max(_.values(length_group))


    nodesDecorator = (root, tree) ->
        nodes = tree.nodes(root)
        nodes.forEach (d) ->
            type = if d.nature then d.nature.name else 'root'
            branch = nature_type_order.indexOf(type)
            d.y = branch*(rectHeight + rectVerticalSpacing)
        grouped_org = _.groupBy root.children, (org) -> return org.nature.name
        grouped_org['root'] = [root]

        nature_type_order.forEach (name, idx) ->
            typed_orgs =  grouped_org[name]
            # 计算根节点、奇数列 正确位置
            fixed_odd_position = if typed_orgs.length%2 !=0 && name == 'root' then typed_orgs.length + 1 else typed_orgs.length
            typed_orgs.forEach (d, i) ->
                d.x = ((rectWidth*layerMaxLength + rectHorizontalSpacing*(layerMaxLength - 1) + 40)/2 -
                    ((fixed_odd_position - 1)*rectHorizontalSpacing +
                    fixed_odd_position*rectWidth)/2) + i*(rectHorizontalSpacing + rectWidth)

        return nodes

    draw = (svg, tree, nodes, layerMaxLength, root) ->

        drawPath = ->
            svg.selectAll("path.link")
                .data(nodes)
                .enter()
                .append("path")
                .attr("class","link")
                .attr "d", (d, i) ->
                    """
                     M#{root.x+ rectWidth/2} #{root.y+rectHeight}
                     L#{root.x + rectWidth/2} #{d.y - rectVerticalSpacing/2}
                     L#{d.x + rectWidth/2} #{d.y - rectVerticalSpacing/2}
                     L#{d.x + rectWidth/2} #{d.y}
                    """
                .attr("stroke", linkColor)
                .attr("stroke-width", linkWidth)
                .attr("fill", "transparent")

        drawRect = ->
            nodeEnter = svg.selectAll("g.node")
                .data(nodes)
                .enter()
                .append("g")
                .attr("class","node")
                .style("cursor", "pointer")
                .on 'click', (d,i) ->   #To Do:
                    active_node.classed("active",false)
                    d3.select(this).classed("active",true)
                    active_node = d3.select(this)
                    rectClickHandler(target: d.id)


            nodeEnter.append("rect")
                .attr("class", "chart-box")
                .attr("width", rectWidth)
                .attr("height", rectHeight)
                .attr("rx", rectBorderRadius)
                .attr("ry", rectBorderRadius)
                .attr("stroke", linkColor)
                .attr("stroke-width", borderWidth)
                .attr "x", (d,i) -> d.x
                .attr "y", (d) -> d.y
                .attr "class", (d) -> #TODO: 根据状态确定方块颜色class

            nodeEnter.append("text")
                .attr("class", "orgchart-text")
                .attr("text-anchor", "middle")
                .attr("glyph-orientation-vertical", 0)
                .attr("writing-mode", "tb")
                .style("font-size", "12px")
                .attr "x", (d) -> d.x + rectWidth/2
                .attr "y", (d) -> d.y + rectHeight/2
                .text (d) -> d.name

        svg.attr("width",rectWidth*layerMaxLength + rectHorizontalSpacing*(layerMaxLength - 1) + 40)
            .attr("height",(rectHeight + rectVerticalSpacing)*4)
        tree.size([rectWidth*layerMaxLength + rectHorizontalSpacing*(layerMaxLength - 1) + 40,(rectHeight + rectVerticalSpacing)*3+40])

        drawPath()
        drawRect()
        active_node = d3.select(".node")




    layerMaxLength = computeLayerMaxLength(root)
    tree = d3.layout.tree()
    svg = d3.select(container).append('svg')
    nodes = nodesDecorator(root, tree)
    draw(svg, tree, nodes, layerMaxLength, root)



drawTreeChart = (root, options) ->
    active_node = null

    container             = options.container
    rectHeight            = options.rectHeight || 180
    rectWidth             = options.rectWidth || 36
    rectVerticalSpacing   = options.rectVerticalSpacing
    rectHorizontalSpacing = options.rectHorizontalSpacing
    linkColor             = options.linkColor
    linkWidth             = options.linkWidth
    rectBorderRadius      = options.rectBorderRadius
    borderWidth           = options.borderWidth
    duration              = options.duration || 750
    rectClickHandler      = options.clickHandler
    leaf                  = 0
    # compute leaf size 树的宽度与叶子节点个数线性相关
    computeLayerMaxLength = (source) ->
        if source.children
            source.children.forEach(computeLayerMaxLength)
        else if source._children
            source._children.forEach(computeLayerMaxLength)
        else
            leaf++

    # 篡改tree插件生成的Y坐标
    nodesDecorator = (root, tree) ->
        nodes = tree.nodes(root)
        nodes.forEach (d) ->
            d.y = d.depth*(rectHeight + rectVerticalSpacing)
        return nodes

    #  绘制子机构树
    draw =  (svg, tree, nodes,layerMaxLength, root) ->

        drawPath = ->
            svg.selectAll("path")
                .data(nodes)
                .enter()
                .append("path")
                .attr "d", (d, i) ->
                    if d.depth != 0
                        return    """
                             M#{d.x} #{d.y}
                             L#{d.x} #{d.y - rectVerticalSpacing/2}
                             L#{d.parent.x} #{d.y - rectVerticalSpacing/2}
                             L#{d.parent.x} #{d.parent.y+rectHeight}
                            """
                .attr("stroke", linkColor)
                .attr("stroke-width", linkWidth)
                .attr("fill", "transparent")

        drawRect = ->

            nodeEnter = svg.selectAll("g.node")
                .data(nodes)
                .enter()
                .append("g")
                .attr("class","node")
                .style("cursor","pointer")
                .on "click", (d) ->
                    active_node.classed("active",false)
                    d3.select(this).classed("active",true)
                    active_node = d3.select(this)
                    rectClickHandler(target: d.id)

            nodeEnter.append("rect")
                .attr("class","chart-box")
                .attr("width",rectWidth)
                .attr("height",rectHeight)
                .attr "x", (d) ->
                    return d.x - rectWidth/2
                .attr "y", (d) ->
                    return d.y
                .attr("rx",rectBorderRadius)
                .attr("ry",rectBorderRadius)
                .attr("stroke",linkColor)
                .attr("stroke-width",borderWidth)

            nodeEnter.append("text")
                .attr("class","orgchart-text")
                .attr("text-anchor", "middle")
                .attr("glyph-orientation-vertical", 0)
                .attr("writing-mode", "tb")
                .style("font-size", "12px")
                .attr "x", (d) -> d.x
                .attr "y", (d) -> d.y + rectHeight/2
                .text (d) -> d.name

        # // compute canvas h w
        drawPath()
        drawRect()
        active_node = d3.select(".node")

    #方法调用
    computeLayerMaxLength(root)
    layerMaxLength = leaf
    tree = d3.layout.tree()
    svg = d3.select(container).append('svg')

    svg.attr("width",rectWidth*layerMaxLength + rectHorizontalSpacing*(layerMaxLength - 1) + 40)
        .attr("height",(rectHeight + rectVerticalSpacing)*3)
    tree.size([rectWidth*layerMaxLength + rectHorizontalSpacing*(layerMaxLength - 1) + 40,(rectHeight + rectVerticalSpacing)*3+40])

    nodes = nodesDecorator(root, tree)
    draw(svg, tree, nodes, layerMaxLength, root)

app.directive('orgChart',[orgChartDirective])

