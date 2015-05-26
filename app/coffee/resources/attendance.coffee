resources = angular.module('resources')


Attendance = (restmod, RMUtils, $Evt) ->
    Attendance = restmod.model('/attendances').mix 'nbRestApi', 'DirtyModel', {
        recordDate: {decode: 'date', param: 'yyyy-MM-dd'}

        $hooks:
            'after-create': ->
                $Evt.$send('attendance:create:success', "考勤创建成功")

            'after-update': ->
                $Evt.$send('attendance:update:success', "考勤更新成功")

    }

resources.factory 'Attendance',['restmod', 'RMUtils', '$nbEvent', Attendance]