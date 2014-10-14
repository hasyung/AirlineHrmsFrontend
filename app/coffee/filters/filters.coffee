module = angular.module 'vx.filters', []


module
    .filter 'highlight', () ->
        (input,opts = {}) ->

            opts = {text: opts} if typeof opts == 'string'

            return input unless opts.text?

            input.replace(new RegExp(opts.text, 'gi'), '<span class="highlightText">$&</span>')