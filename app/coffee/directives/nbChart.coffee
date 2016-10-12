# 依赖 ng－echarts 的 二次封装，
# 旨在 简化创建图表使用的代码

# 饼图的基础配置
pieOptionsBase = {
    title : {
        text: '',
        x:'center'
    },

    tooltip : {
        trigger: 'item',
        formatter: "{a} <br/>{b} : {c} ({d}%)"
    },

    legend: {
        orient: 'vertical',
        left: '5%',
        top: '5%',
        data: []
    },

    series : [
        {
            name: '',
            type: 'pie',
            radius : '55%',
            center: ['50%', '50%'],
            data:[],
            itemStyle: {
                emphasis: {
                    shadowBlur: 10,
                    shadowOffsetX: 0,
                    shadowColor: 'rgba(0, 0, 0, 0.5)'
                }
            }
        }
    ]
}

brokenLineOpitionBase = {
    tooltip: {
        trigger: 'axis'
    },
    legend: {
        data:[]
    },
    grid: {
        left: '3%',
        right: '4%',
        bottom: '3%',
        containLabel: true
    },
    xAxis: {
        type: 'category',
        splitLine: { show: false },
        boundaryGap: false,
        data: []
    },
    yAxis: {
        type: 'value',
    },
    series: []
}


angular.module 'nb.directives'
    .directive 'nbChart', [ () ->

        template = '''
            <ng-echarts class="echarts-bar"
                ec-config="config"
                ec-option="options"
            ></ng-echarts>
        '''

        preLink = (scope, elem, attrs) ->
            defaultConfig =  {
                theme:''
                dataLoaded:true
            }

            # 这里要根据情况确定渲染 选择渲染各种图
            switch attrs.category
                when 'pie' then baseOptions = pieOptionsBase
                when 'brokenLine' then baseOptions = brokenLineOpitionBase

            if angular.isDefined attrs.nbConfig
                scope.config = $.extend(true, {}, defaultConfig, attrs.nbConfig)
            else
                scope.config = defaultConfig

            scope.$watch 'customOptions',
                (newValue)->
                    if angular.isDefined newValue
                        scope.options = $.extend(true, {}, baseOptions, newValue)
                ,true

        return {
            restrict: 'EA'
            template: template
            link: {
                pre: preLink
            }
            scope: {
                customOptions: '=nbOptions'
            }
        }
    ]