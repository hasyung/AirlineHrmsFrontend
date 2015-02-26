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
