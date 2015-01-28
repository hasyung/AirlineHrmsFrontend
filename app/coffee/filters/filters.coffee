module = angular.module 'nb.filters', []


module
    .filter 'highlight', () ->
        (input,opts = {}) ->

            opts = {text: opts} if typeof opts == 'string'

            return input unless opts.text?

            input.replace(new RegExp(opts.text, 'gi'), '<span class="highlightText">$&</span>')

module
	.filter 'nbDate', ['$filter', ($filter)->
		return (dateStr, format) ->
			return dateStr if !dateStr
			# dateStr = _.trim(dateStr)
			# unixToDate 1422439743
			if /^\d\d+\d$/.test dateStr
				date = moment.unix(dateStr)._i
				return $filter('date')(date, format)
			else
				# "Wed 01 Aug 2012"
				return $filter('date')(new Date(dateStr), format)

	]
# 拼接对象属性
module
	.filter 'spliceItem', [()->
		return (arr, format = '-', property = 'name') ->
			return arr if !angular.isArray arr
			tempStr = ""
			angular.forEach arr, (item)->
				tempStr = tempStr + format + item[property]
			tempStr.replace format, ''

	]

