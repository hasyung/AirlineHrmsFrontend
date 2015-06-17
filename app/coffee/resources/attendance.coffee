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

AttendanceSummary = (restmod, RMUtils, $Evt) ->
    AttendanceSummary = restmod.model('/attendance_summaries').mix 'nbRestApi', {
        
    }

resources.factory 'Attendance',['restmod', 'RMUtils', '$nbEvent', Attendance]
resources.factory 'AttendanceSummary',['restmod', 'RMUtils', '$nbEvent', AttendanceSummary]
