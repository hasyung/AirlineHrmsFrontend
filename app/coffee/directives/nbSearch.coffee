nbSearchTemplate =  '''
		<md-autocomplete
			ng-disabled="!editStatus"
			md-items="item in ctrl.queryMatched(ctrl.searchText)"
			md-item-text="item"
			md-selected-item="ctrl.selectedItem"
			md-search-text="ctrl.searchText"
			md-selected-item-change="onSelectedItemChange(ctrl.selectedItem);"
			md-search-text-change="onSearchTextChange(ctrl.searchText);"
			md-delay="200"
			#placeholder#
			md-no-cache="true"
			required="required"
			><span md-highlight-text="ctrl.searchText">{{item}}</span></md-autocomplete>

	'''


angular.module 'nb.directives'
	.directive 'nbSearch', [() -> 
		template = (elem, attrs) ->
			placeholder = attrs.placeholder
			placeholder_str = if angular.isDefined(attrs.floatLabel) then "md-floating-label='#{placeholder}'" else "placeholder='#{placeholder}'"

			tmpl = nbSearchTemplate.replace("#placeholder#", placeholder_str)
			return tmpl

		postLink = (scope, elem, attrs, ctrl) ->
			ngModelCtrl = ctrl if ctrl

			scope.onSearchTextChange = (text) ->
				scope.searchTextChange()

			scope.onSelectedItemChange = (item) ->
				scope.selectedItemChange()
				ngModelCtrl.$setViewValue(item) if ngModelCtrl

			if ngModelCtrl
				ngModelCtrl.$render = ->
					if ngModelCtrl.$viewValue
						scope.ctrl.selectedItem = ngModelCtrl.$viewValue

		return {
			require: '?ngModel'

			scope: {
				selectedItemChange: '&'
				searchTextChange: '&'
				editStatus: '=editable'
			}

			template: template
			link: postLink
			controller: nbSearchCtrl
			controllerAs: 'ctrl'
		}
	]

class nbSearchCtrl
	@.$inject = ['$scope', '$attrs']

	constructor: (@scope, attrs) ->
		@searchText = null
		@selectedItem = null

		@states = @getStates(attrs.type)

	queryMatched: (text) ->
		_.filter @states, (state)->
			_.includes state, text

	getStates: (type)->
		switch type
			when 'nationality' then return NationalityDic
			when 'nation' then return nationsDic


NationalityDic= [   
	"安哥拉",   
	"阿富汗",   
	"阿尔巴尼亚",   
	"阿尔及利亚",   
	"安道尔共和国",   
	"安圭拉岛",   
	"安提瓜和巴布达",   
	"阿根廷",   
	"亚美尼亚",   
	"澳大利亚",   
	"奥地利",   
	"阿塞拜疆",   
	"巴哈马",   
	"巴林",   
	"孟加拉国",   
	"巴巴多斯",   
	"白俄罗斯",   
	"比利时",   
	"伯利兹",   
	"贝宁",   
	"百慕大群岛",   
	"玻利维亚",   
	"博茨瓦纳",   
	"巴西",   
	"文莱",   
	"保加利亚",   
	"布基纳法索",   
	"缅甸",   
	"布隆迪",   
	"喀麦隆",   
	"加拿大",   
	"中非共和国",   
	"乍得",   
	"智利",   
	"中国",   
	"哥伦比亚",   
	"刚果",   
	"库克群岛",   
	"哥斯达黎加",   
	"古巴",   
	"塞浦路斯",   
	"捷克",   
	"丹麦",   
	"吉布提",   
	"多米尼加共和国",   
	"厄瓜多尔",   
	"埃及",   
	"萨尔瓦多",   
	"爱沙尼亚",   
	"埃塞俄比亚",   
	"斐济",   
	"芬兰",   
	"法国",   
	"法属圭亚那",   
	"加蓬",   
	"冈比亚",   
	"格鲁吉亚",   
	"德国",   
	"加纳",   
	"直布罗陀",   
	"希腊",   
	"格林纳达",   
	"关岛",   
	"危地马拉",   
	"几内亚",   
	"圭亚那",   
	"海地",   
	"洪都拉斯",   
	"香港",   
	"匈牙利",   
	"冰岛",   
	"印度",   
	"印度尼西亚",   
	"伊朗",   
	"伊拉克",   
	"爱尔兰",   
	"以色列",   
	"意大利",   
	"牙买加",   
	"日本",   
	"约旦",   
	"柬埔寨",   
	"哈萨克斯坦",   
	"肯尼亚",   
	"韩国",   
	"科威特",   
	"吉尔吉斯坦",   
	"老挝",   
	"拉脱维亚",   
	"黎巴嫩",   
	"莱索托",   
	"利比里亚",   
	"利比亚",   
	"列支敦士登",   
	"立陶宛",   
	"卢森堡",   
	"澳门",   
	"马达加斯加",   
	"马拉维",   
	"马来西亚",   
	"马尔代夫",   
	"马里",   
	"马耳他",   
	"毛里求斯",   
	"墨西哥",   
	"摩尔多瓦",   
	"摩纳哥",   
	"蒙古",   
	"蒙特塞拉特岛",   
	"摩洛哥",   
	"莫桑比克",   
	"纳米比亚",   
	"瑙鲁",   
	"尼泊尔",   
	"荷兰",   
	"新西兰",   
	"尼加拉瓜",   
	"尼日尔",   
	"尼日利亚",   
	"朝鲜",   
	"挪威",   
	"阿曼",   
	"巴基斯坦",   
	"巴拿马",   
	"巴布亚新几内亚",   
	"巴拉圭",   
	"秘鲁",   
	"菲律宾",   
	"波兰",   
	"法属玻利尼西亚",   
	"葡萄牙",   
	"波多黎各",   
	"卡塔尔",   
	"罗马尼亚",   
	"俄罗斯",   
	"圣卢西亚",   
	"圣文森特岛",   
	"圣马力诺",   
	"圣多美和普林西比",   
	"沙特阿拉伯",   
	"塞内加尔",   
	"塞舌尔",   
	"塞拉利昂",   
	"新加坡",   
	"斯洛伐克",   
	"斯洛文尼亚",   
	"所罗门群岛",   
	"索马里",   
	"南非",   
	"西班牙",   
	"斯里兰卡",   
	"苏丹",   
	"苏里南",   
	"斯威士兰",   
	"瑞典",   
	"瑞士",   
	"叙利亚",   
	"台湾省",   
	"塔吉克斯坦",   
	"坦桑尼亚",   
	"泰国",   
	"多哥",   
	"汤加",   
	"特立尼达和多巴哥",   
	"突尼斯",   
	"土耳其",   
	"土库曼斯坦",   
	"乌干达",   
	"乌克兰",   
	"阿拉伯联合酋长国",   
	"英国",   
	"美国",   
	"乌拉圭",   
	"乌兹别克斯坦",   
	"委内瑞拉",   
	"越南",   
	"也门",   
	"南斯拉夫",   
	"津巴布韦",   
	"扎伊尔",   
	"赞比亚"   
]

@nationsDic = [
	'汉族',
	'壮族',
	'满族',
	'回族',
	'苗族',
	'维吾尔族',
	'土家族',
	'彝族',
	'蒙古族',
	'藏族',
	'布依族',
	'侗族',
	'瑶族',
	'朝鲜族',
	'白族',
	'哈尼族',
	'哈萨克族',
	'黎族',
	'傣族',
	'畲族',
	'傈僳族',
	'仡佬族',
	'东乡族',
	'高山族',
	'拉祜族',
	'水族',
	'佤族',
	'纳西族',
	'羌族',
	'土族',
	'仫佬族',
	'锡伯族',
	'柯尔克孜族',
	'达斡尔族',
	'景颇族',
	'毛南族',
	'撒拉族',
	'布朗族',
	'塔吉克族',
	'阿昌族',
	'普米族',
	'鄂温克族',
	'怒族',
	'京族',
	'基诺族',
	'德昂族',
	'保安族',
	'俄罗斯族',
	'裕固族',
	'乌兹别克族',
	'门巴族',
	'鄂伦春族',
	'独龙族',
	'塔塔尔族',
	'赫哲族',
	'珞巴族'
]