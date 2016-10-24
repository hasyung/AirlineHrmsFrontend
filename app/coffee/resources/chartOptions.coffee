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

resources.factory 'BarChartService', [BarChartOptions]
