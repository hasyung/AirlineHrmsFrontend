module = angular.module 'vx.filters', []


module
    .filter 'highlight', () ->
        (input,opts = {}) ->

            opts = {text: opts} if typeof opts == 'string'

            return input unless opts.text?

            input.replace(new RegExp(opts.text, 'gi'), '<span class="highlightText">$&</span>')
    .filter 'nullback', () ->
        (input, back = "空") ->
            unless input?
                return back



 # return function (text, search, caseSensitive) {
 #    if (search || angular.isNumber(search)) {
 #      text = text.toString();
 #      search = search.toString();
 #      if (caseSensitive) {
 #        return text.split(search).join('<span class="ui-match">' + search + '</span>');
 #      } else {
 #        return text.replace(new RegExp(search, 'gi'), '<span class="ui-match">$&</span>');
 #      }
 #    } else {
 #      return text;
 #    }
 #  };