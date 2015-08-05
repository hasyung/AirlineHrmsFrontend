app = @nb.app


orgChartDirective = ->
    postLink = (scope, elem, attr) ->
        clickHandler = (evt) ->
            scope.$apply ->
                scope.onItemClick(evt: evt)

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

        scope.$watch 'orgChartData', (newVal) -> render(newVal, options, scope.initSelectOrgId) if newVal
        scope.$on '$destroy', () -> destroyChart()

    return {
        link: postLink
        scope: {
            orgChartData: '='
            onItemClick: '&'
            initSelectOrgId: '='
        }
    }


render = (root, options, select_org_id) ->
    container = options.container
    d3.select(container.querySelector('svg')).remove()

    if root.xdepth == 1
        drawOrgChart(root, options, select_org_id)
    else
        drawTreeChart(root, options, select_org_id)


drawOrgChart = (root, options, select_org_id) ->
    active_node = null
    staff_nodes = null

    container             = options.container
    nature_type_order     = [2,1,3] #workaround use nature id
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
        length_group = _.countBy root.children, (org) -> return org.nature_id
        return _.max(_.values(length_group))

    nodesDecorator = (root, tree) ->
        nodes = tree.nodes(root)
        staffLength = root.staff.length

        nodes.forEach (d) ->
            type = if d.nature_id then d.nature_id else 'root'
            branch = nature_type_order.indexOf(type)
            if branch == 0
                d.y = branch*(rectHeight + rectVerticalSpacing)
            else
                d.y = branch*(rectHeight + rectVerticalSpacing) + staffLength*(rectWidth + rectHorizontalSpacing) - rectHorizontalSpacing

        grouped_org = _.groupBy root.children, (org) -> return org.nature_id
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

    staffNodesDecorator = (root, tree) ->
        nodes = root.staff
        nodes.forEach (d, i) ->
            d.x = (rectWidth*layerMaxLength + rectHorizontalSpacing*(layerMaxLength - 1) + 40)/2 +100
            d.y = rectHeight + (rectVerticalSpacing/2 - rectWidth/2) + i*(rectWidth + rectHorizontalSpacing)
        return nodes

    draw = (svg, tree, nodes, layerMaxLength, root, staff_nodes) ->

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

        drawStaffPath = ->
            svg.selectAll("path.link-staff")
                .data(staff_nodes)
                .enter()
                .append("path")
                .attr("class","link")
                .attr "d", (d, i) ->
                    """
                     M#{root.x + rectWidth/2} #{d.y + rectWidth/2}
                     L#{d.x} #{d.y + rectWidth/2}
                    """
                .attr("stroke", linkColor)
                .attr("stroke-width", linkWidth)
                .attr("fill", "transparent")

        drawRect = ->
            nodeEnter = svg.selectAll("g.node")
                .data(nodes)
                .enter()
                .append("g")
                .attr "class", (d) ->
                    if d.status == 'create_inactive'
                        return "node chart-box-create_inactive"
                    else if d.status == 'update_inactive'
                        return "node chart-box-update_inactive"
                    else if d.status == 'destroy_inactive'
                        return "node chart-box-destroy_inactive"
                    else if d.status == 'transfer_inactive'
                        return "node chart-box-transfer_inactive"
                    else
                        return "node"
                .style("cursor", "pointer")
                .attr 'id', (d) -> "org_#{d.id}"
                .on 'click', (d,i) ->   #To Do:
                    active_node.classed("active",false)
                    d3.select(this).classed("active",true)
                    active_node = d3.select(this)
                    rectClickHandler(target: d.id)


            nodeEnter.append("rect")
                .attr("width", rectWidth)
                .attr("height", rectHeight)
                .attr("rx", rectBorderRadius)
                .attr("ry", rectBorderRadius)
                .attr("stroke", linkColor)
                .attr("stroke-width", borderWidth)
                .attr "x", (d,i) -> d.x
                .attr "y", (d) -> d.y

            nodeEnter.append("text")
                .attr("class", "orgchart-text")
                .attr("text-anchor", "middle")
                .attr("glyph-orientation-vertical", 0)
                .attr("writing-mode", "tb")
                .style("font-size", "12px")
                .attr "x", (d) -> d.x + rectWidth/2
                .attr "y", (d) -> d.y + rectHeight/2
                .text (d) -> d.name.replace(/（/gm, '︵').replace(/）/gm, '︶')

        drawStaffRect = ->
            nodeEnter = svg.selectAll("g.node-staff")
                .data(staff_nodes)
                .enter()
                .append("g")
                .attr "class", (d) ->
                    if d.status == 'create_inactive'
                        return "node chart-box-create_inactive"
                    else if d.status == 'update_inactive'
                        return "node chart-box-update_inactive"
                    else if d.status == 'destroy_inactive'
                        return "node chart-box-destroy_inactive"
                    else if d.status == 'transfer_inactive'
                        return "node chart-box-transfer_inactive"
                    else
                        return "node"
                .style("cursor", "pointer")
                .attr 'id', (d) -> "org_#{d.id}"
                .on 'click', (d,i) ->   #To Do:
                    active_node.classed("active",false)
                    d3.select(this).classed("active",true)
                    active_node = d3.select(this)
                    rectClickHandler(target: d.id)


            nodeEnter.append("rect")
                .attr("width", rectHeight)
                .attr("height", rectWidth)
                .attr("rx", rectBorderRadius)
                .attr("ry", rectBorderRadius)
                .attr("stroke", linkColor)
                .attr("stroke-width", borderWidth)
                .attr "x", (d,i) -> d.x
                .attr "y", (d) -> d.y

            nodeEnter.append("text")
                .attr("class", "orgchart-text")
                .attr("text-anchor", "middle")
                .style("font-size", "12px")
                .attr "x", (d) -> d.x + rectHeight/2 - 2
                .attr "y", (d) -> d.y + rectWidth/2 + 4
                .text (d) -> d.name.replace(/（/gm, '︵').replace(/）/gm, '︶')

        svg.attr("width",rectWidth*layerMaxLength + rectHorizontalSpacing*(layerMaxLength - 1) + 40)
            .attr("height",(rectHeight + rectVerticalSpacing)*4 + staff_nodes.length*(rectWidth + rectHorizontalSpacing))
        tree.size([rectWidth*layerMaxLength + rectHorizontalSpacing*(layerMaxLength - 1) + staff_nodes.length*(rectWidth + rectHorizontalSpacing) + 40,(rectHeight + rectVerticalSpacing)*3+40])

        drawPath()
        drawStaffPath()
        drawRect()
        drawStaffRect()
        active_node = svg.select("#org_#{select_org_id}")
        active_node.classed 'active',true

    layerMaxLength = computeLayerMaxLength(root)
    tree = d3.layout.tree()
    svg = d3.select(container).append('svg')
    nodes = nodesDecorator(root, tree)
    staff_nodes = staffNodesDecorator(root, tree)
    draw(svg, tree, nodes, layerMaxLength, root, staff_nodes)


drawTreeChart = (root, options, select_org_id) ->
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
                .attr "class", (d) ->
                    if d.status == 'create_inactive'
                        return "node chart-box-create_inactive"
                    else if d.status == 'update_inactive'
                        return "node chart-box-update_inactive"
                    else if d.status == 'delete_inactive'
                        return "node chart-box-destroy_inactive"
                    else if d.status == 'transfer_inactive'
                        return "node chart-box-transfer_inactive"
                    else
                        return "node"
                .style("cursor","pointer")
                .attr 'id', (d) -> "org_#{d.id}"
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
                .text (d) -> d.name.replace(/（/gm, '︵').replace(/）/gm, '︶')

        # // compute canvas h w
        drawPath()
        drawRect()
        active_node = svg.select("#org_#{select_org_id}")
        active_node.classed 'active',true

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


app.directive('orgChart', [orgChartDirective])