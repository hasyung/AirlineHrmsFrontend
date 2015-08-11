module = angular.module 'nb.filters', []


module
    .filter 'highlight', () ->
        (input,opts = {}) ->
            opts = {text: opts} if typeof opts == 'string'
            return input unless opts.text?
            input.replace(new RegExp(opts.text, 'gi'), '<span class="highlightText">$&</span>')

module
    .filter 'dictmap', [()->
        #把map抽成一个service，各个模块的码表都放进去，统一在一个地方编辑。可好？
        map = {
            "personnel":{
                '0': '无需审核',
                '1': '待审核',
                '2': '通过',
                '3': '不通过',
            }
        }
        (input, module) ->
            return map[module][input.toString()]
    ]

    .filter 'nbDate', ->
        (input, opts) ->
            if input then new Date(input) else ""

    .filter 'fromNow', ->
        (input, opts = true) ->
            if input
                try
                    return moment(input).fromNow(opts)
                catch e
                    ""

    .filter 'mdate', ->
        (input, format = "YYYY-mm-DD") ->
            if input && input.format
                return input.format(format)


    .filter 'diffDate', ->
        (input, opts) ->
            if input
                try
                    return moment().diff(moment(input), opts)
                catch e
                    return ''


    .filter 'enum', ['$enum', ($enum) ->
        (input, opts) ->
            $enum.parseLabel(input, opts)
    ]

    .filter 'big2small', [()->
        (input) ->
            _.sortBy input, (item)->
                this.sin item.$key
            , Math
    ]

    .filter 'breakit', ['$sce', ($sce) ->
        (text) ->
            if text && angular.isDefined(text)
                text = text.replace(/\n/g, '<br />')
                return $sce.trustAsHtml(text)
            text
    ]

    .filter 'toArray', [()->
        (obj, key_name) ->
            result = []
            angular.forEach obj, (val, key) ->
                val[key_name] = key
                result.push val
            result
    ]
