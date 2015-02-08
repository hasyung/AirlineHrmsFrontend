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
			# unixToDate 1422439743
			date = moment.unix(dateStr)._i
			return $filter('date')(date, format)

	]

