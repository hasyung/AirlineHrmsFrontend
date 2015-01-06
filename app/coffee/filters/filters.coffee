module = angular.module 'nb.filters', []


module
    .filter 'highlight', () ->
        (input,opts = {}) ->

            opts = {text: opts} if typeof opts == 'string'

            return input unless opts.text?

            input.replace(new RegExp(opts.text, 'gi'), '<span class="highlightText">$&</span>')


module
	.filter 'unixToDate', ['$filter', ($filter)->
		return (unixTime, format) ->
			date = moment.unix(unixTime)._i
			$filter('date')(date, format)
	]