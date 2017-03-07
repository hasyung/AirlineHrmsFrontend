resources = angular.module('resources')

BarChartOptions = () ->

	smallOptions = {
		title : {
			left: 20
			text: ''
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
			data: []
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
		series : []
	}

	bigOptions = {
		title : {
			left: 20
			text: ''
			textStyle: {
				fontSize: 18
			}
		},
		tooltip : {
			trigger: 'axis'
			axisPointer: {
				type: 'shadow'
			}
			textStyle: {
				fontSize: 16
			}
		},
		legend: {
			data: []
			textStyle: {
				fontSize: 16
			}
		},
		calculable : true
		xAxis : [
			{
				type: 'value'
				axisLabel: { 
					'interval': 0
					textStyle: {
						fontSize: 16
					}
				}
			}
		],
		yAxis : [
			{
				type: 'category'
				axisLabel: { 
					'interval': 0
					textStyle: {
						fontSize: 16
					}
				}
				splitLine: { show: false }
				data: []
			}
		],
		grid : {
			left: '20%'
			right: '5%'
		},
		series : []
	}

	initial = () ->
		this.small = _.cloneDeep smallOptions
		this.big = _.cloneDeep bigOptions
		return this

	setTitle = (nameStr) ->
		this.small.title.text = nameStr
		this.big.title.text = nameStr
		return this

	setLegend = (nameArr) ->
		self = this

		this.small.legend.data = nameArr
		this.big.legend.data = nameArr

		_.forEach nameArr, (item) ->
			self.small.series.push(
				{
					name: item
					type: 'bar'
					data:[]
					markPoint : {
						data : [
							{type : 'max', name: '最大值'}
						]
					}
				}
			)

			self.big.series.push(
				{
					name:item
					type:'bar'
					data:[]
					markPoint : {
						data : [
							{type : 'max', name: '最大值'}
						]
						label: {
							normal: {
								textStyle: {
									fontSize: 16
								}
							}
							emphasis: {
								textStyle: {
									fontSize: 16
								}
							}
						}
					}
				}
			)

		return this

	fetchSmallOptions = () ->
		return _.cloneDeep this.small

	fetchBigOptions = () ->
		return _.cloneDeep this.big

	return {
		initial: initial
		setTitle: setTitle
		setLegend: setLegend
		fetchSmallOptions: fetchSmallOptions
		fetchBigOptions: fetchBigOptions

	}


PieChartOptions = () ->

	smallOptions = {
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

	bigOptions = {
		title : {
			text: ''
			x:'center'
			textStyle: {
				fontSize: 18
			}
		},
		tooltip : {
			trigger: 'item',
			formatter: "{a} <br/>{b} : {c} ({d}%)"
			textStyle: {
				fontSize: 16
			}
		},
		legend: {
			orient: 'vertical',
			left: '5%',
			top: '5%',
			data: []
			textStyle: {
				fontSize: 16
			}
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
				label: {
					normal: {
						textStyle: {
							fontSize: 16
						}
					}
					emphasis: {
						textStyle: {
							fontSize: 16
						}
					}
				}
			}
		]
	}

	initial = () ->
		this.small = _.cloneDeep smallOptions
		this.big = _.cloneDeep bigOptions
		return this

	setTitle = (nameStr) ->
		this.small.title.text = nameStr
		this.big.title.text = nameStr
		return this

	setSeriesName = (nameStr) ->
		this.small.series[0].name = nameStr
		this.big.series[0].name = nameStr
		return this

	fetchSmallOptions = () ->
		return _.cloneDeep this.small

	fetchBigOptions = () ->
		return _.cloneDeep this.big

	return {
		initial: initial
		setTitle: setTitle
		setSeriesName: setSeriesName
		fetchSmallOptions: fetchSmallOptions
		fetchBigOptions: fetchBigOptions
	}


BrokenLineChartOptions = () ->
	smallOptions = {
		tooltip: {
			trigger: 'axis'
		},
		legend: {
			data: []
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

	bigOptions = {
        tooltip: {
            trigger: 'axis'
            textStyle: {
                fontSize: 16
            }
        },
        legend: {
            data:[]
            textStyle: {
                fontSize: 16
            }
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
            axisLabel: { 
                'interval': 0
                textStyle: {
                    fontSize: 16
                }
            }
        },
        yAxis: {
            type: 'value',
            axisLabel: { 
                'interval': 0
                textStyle: {
                    fontSize: 16
                }
            }
        },
        series: []
    }

	initial = () ->
		this.small = _.cloneDeep smallOptions
		this.big = _.cloneDeep bigOptions
		return this

	setLegend = (nameArr) ->
		this.small.legend.data = nameArr
		this.big.legend.data = nameArr
		return this

	fetchSmallOptions = () ->
		return _.cloneDeep this.small

	fetchBigOptions = () ->
		return _.cloneDeep this.big

	return {
		initial: initial
		setLegend: setLegend
		fetchSmallOptions: fetchSmallOptions
		fetchBigOptions: fetchBigOptions
	}

resources.factory 'BarChartService', [BarChartOptions]
resources.factory 'PieChartService', [PieChartOptions]
resources.factory 'BrokenLineChartService', [BrokenLineChartOptions]
