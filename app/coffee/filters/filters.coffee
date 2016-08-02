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
                Math.sin item.$key
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

            _.sortBy result, (item) ->
                -item[key_name]
    ]

    .filter 'salaryChannelMapId2Name', [()->
        (input) ->
            switch input
                when "service_b_normal_cleaner_base" then out = '服务B－清洁工'
                when "service_b_parking_cleaner_base" then out = '服务B－机坪清洁工'
                when "service_b_hotel_service_base" then out = '服务B－宾馆服务员'
                when "service_b_green_base" then out = '服务B－绿化'
                when "service_b_front_desk_base" then out = '服务B－总台服务员'
                when "service_b_security_guard_base" then out = '服务B－保安、空保装备保管员'
                when "service_b_input_base" then out = '服务B－数据录入'
                when "service_b_guard_leader1_base" then out = '服务B－保安队长(一类)'
                when "service_b_device_keeper_base" then out = '服务B－保管(库房、培训设备、器械)'
                when "service_b_unloading_base" then out = '服务B－外站装卸'
                when "service_b_making_water_base" then out = '服务B－制水工'
                when "service_b_add_water_base" then out = '服务B－加水工、排污工'
                when "service_b_guard_leader2_base" then out = '服务B－保安队长(二类)'
                when "service_b_water_light_base" then out = '服务B－水电维修'
                when "service_b_car_repair_base" then out = '服务B－汽修工'
                when "service_b_airline_keeper_base" then out = '服务B－机务工装设备/客舱供应库管'

            return out
    ]
