# // depth 修改

treeData = {
    root: root
}


orgChartDirective = ->

    postLink = (scope, elem, attr) ->

        # onItemClick = ->
        #     scope.$apply -> scope.onItemClick()


        options = {
            container: elem
            rectBgColor: '#dfe5e7'  #树节点的正常状态的颜色
            hasChildColor: '#C9D4D7'  #还有为展开的子节点的节点的颜色
            rectWidth: 36  #节点宽度
            rectHeight: 180  #节点高度
            rectBorderRadius: 8  #节点方块的圆角半径
            borderWidth: 1  #节点方块的边框线宽
            rectVerticalSpacing: 50  #节点方块之间的垂直间距
            rectHorizontalSpacing: 50 #节点之间水平间距
            linkColor: '#c4cfd3'  #连接线的颜色
            linkWidth: '3'  #连接线的线宽
            selectColor: '#90d7ff'  #节点方块被选中状态的颜色
            duration: 750  #动画效果的时长
            # onItemClick: scope.onItemClick
        }

        destroyChart = -> d3.select(elem.find('svg')[0]).remove()

        scope.$watch 'treeData', (newVal) -> render(newVal, options)
        scope.$on '$destroy', () -> destroyChart()


    return {
        link: postLink
        scope: {
            treeData: '@'
            onItemClick: '&'
        }
    }


render = (root, options) ->
    container = options.container
    active_node = null
    # cleanup
    d3.select(container.find('svg')[0]).selectAll("*").remove()

    if root.depth == 1
        drawOrgChart(root, options)
    else
        drawTreeChart(root, options)

update = () ->
# nature.name 分类
# shengchanbumen
# jiguanbumen
# fengongsijidi
drawOrgChart = (root, options) ->
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

    computeLayerMaxLength = (root) ->
        length_group = _.countBy root.children, (org) -> return org.nature.name
        length_arr = _.keys(length_group)
        return length_arr.reduce (pre, value) -> return +value if !pre || +value > pre


    nodesDecorator = (root, tree) ->
        nodes = tree.nodes(root)
        nodes.forEach (d) ->
            branch = nature_type_order.indexOf(d.nature.name) + 1
            d.y = branch*(rectHeight + rectVerticalSpacing)
        grouped_org = _.groupBy root.children, (org) -> return org.nature.name
        grouped_org['root'] = [root]

        nature_type_order.forEach (name, idx) ->
            typed_orgs =  grouped_org[name]
            # 计算根节点、奇数列 正确位置
            fixed_odd_position = if typed_orgs.length%2 !=0 && name == 'root' then typed_orgs.length + 1 else typed_orgs.length
            typed_orgs.forEach (d, i) ->
                d.x = (width/2 - ((computeLen - 1)*rectHorizontalSpacing + computeLen*rectWidth)/2) + i*(rectHorizontalSpacing + rectWidth)

        return nodes

    draw = (svg, tree, nodes, layerMaxLength, root) ->

        drawPath = ->
            svg.selectAll("path.link")
                .data(nodes)
                .enter()
                .append("path")
                .attr "d", (d, i) ->
                    """
                     M#{root.x+ rectWidth/2} #{root.y+rectHeight}
                     L#{root.x + rectWidth/2} #{d.y - rectSpacing/2}
                     L#{d.x + rectWidth/2} #{d.y - rectSpacing/2}
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
                .style("cursor", "pointer")
                .on 'click', (d,i) ->   #To Do:
                    active_node
                        .classed('node',true)

                    d3.select(this)
                        .classed('node active',true)

                    active_node = d3.select(this)

            nodeEnter.append("rect")
                .attr("class", "chart-box")
                .attr("width", rectWidth)
                .attr("height", rectHeight)
                .attr("rx", rectBorderRadius)
                .attr("ry", rectBorderRadius)
                .attr("stroke", linkColor)
                .attr("stroke-width", borderWidth)
                .attr "x", (d) -> d.x
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

        svg.attr("width",rectWidth*layerMaxLength + rectSpacing*(layerMaxLength - 1) + 40)
            .attr("height",(rectHeight + rectSpacing)*4)
        tree.size([rectWidth*layerMaxLength + rectSpacing*(layerMaxLength - 1) + 40,(rectHeight + rectSpacing)*3+40])

        drawPath()
        drawRect()



    layerMaxLength = computeLayerMaxLength(root)
    tree = d3.layout.tree()
    svg = d3.select(container).append('svg')
    nodes = nodesDecorator(root, tree)
    draw(svg, tree, nodes, layerMaxLength, root)











drawTreeChart = (root, options) ->
    container             = options.container
    rectHeight            = options.rectHeight || 180
    rectWidth             = options.rectWidth || 36
    rectVerticalSpacing   = options.rectVerticalSpacing
    rectHorizontalSpacing = options.rectHorizontalSpacing
    linkColor             = options.linkColor
    linkWidth             = options.linkWidth
    rectBorderRadius      = options.rectBorderRadius
    borderWidth           = options.borderWidth
    # // compute leaf size 树的宽度与叶子节点个数线性相关
    computeLayerMaxLength = (source) ->
        leaf = 0
        countLeaf(source)
        countLeaf = (source) ->
            if source.children
                source.children.forEach(countLeaf)
            else if source._children
                source._children.forEach(countLeaf)
            else
                leaf++
        return leaf
    # // 篡改tree插件生成的Y坐标
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
                    """
                     M#{d.x} #{d.y}
                     L#{d.x} #{d.y - rectSpacing/2}
                     L#{d.parent.x} #{d.y - rectSpacing/2}
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
                .style("cursor","pointer")
                .on "click", () -> #ToDo

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
        svg.attr("width",rectWidth*layerMaxLength + rectSpacing*(layerMaxLength - 1) + 40)
            .attr("height",(rectHeight + rectSpacing)*3)
        tree.size([rectWidth*layerMaxLength + rectSpacing*(layerMaxLength - 1) + 40,(rectHeight + rectSpacing)*3+40])

        drawPath()
        drawRect()

    #方法调用
    layerMaxLength = computeLayerMaxLength(root)
    tree = d3.layout.tree()
    svg = d3.select(container).append('svg')
    nodes = nodesDecorator(root, tree)
    draw(svg, tree, nodes, layerMaxLength, root)

companyOrgnizationArchitectureLine = ->
computeCompanyOrgRect = ->

