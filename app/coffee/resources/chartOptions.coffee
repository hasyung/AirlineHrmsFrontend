resources = angular.module('resources')

BarChartOptions = () ->
	barChartOptions = () ->
		this._options = {
	        title : {
	            left: 20
	            text: '新进/离职人员分布'
	            textStyle: {
	                fontSize: 14
	            }
	        },
	        tooltip : {
	            trigger: 'axis'
	            axisPointer: {
	                type: 'shadow'
	            }
	        },
	        legend: {
	            data:['新进人员','离职人员']
	        },
	        calculable : true
	        xAxis : [
	            {
	                type: 'value'
	            }
	        ],
	        yAxis : [
	            {
	                type: 'category'
	                axisLabel: { 
	                    'interval': 0
	                }
	                splitLine: { show: false }
	                data: []
	            }
	        ],
	        grid : {
	            left: '20%'
	            right: '5%'
	        },
	        series : [
	            {
	                name:'新进人员'
	                type:'bar'
	                data:[]
	                markPoint : {
	                    data : [
	                        {type : 'max', name: '最大值'}
	                    ]
	                },
	            },
	            {
	                name:'离职人员'
	                type:'bar'
	                data:[]
	                markPoint : {
	                    data : [
	                        {type : 'max', name: '最大值'}
	                    ]
	                },
	            }
	        ]
	    }



