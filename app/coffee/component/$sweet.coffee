# angular warpper for sweetalert


nb = @nb
app = nb.app

al = @swal # sweet alert ref

extend = @angular.extend


class Alert

    constructor: (@q, @timeout) ->

    success: (title, message) ->
        @timeout(
            -> al(title, message, 'success')
            200)

    error: (title, message) ->
        @timeout(
            -> al(title, message, 'error')
            200)

    warning: (title, message) ->
        @timeout(
            -> al(title, message, 'warning')
            200)

    info: (title, message) ->
        @timeout(
            -> al(title, message, 'info')
            200)

    confirm: (title, message,  confirmButtonText = '确定', cancelButtonText = '取消') ->

        deferred = @q.defer()

        options = {
            title: title
            text: message
            type: 'warning'
            showCancelButton: true
            confirmButtonColor: '#DD6B55'
            confirmButtonText: confirmButtonText
            cancelButtonText: cancelButtonText
            closeOnConfirm: true
            closeOnCancel: true
        }

        swal options, (isConfirm) ->
            if isConfirm
                deferred.resolve(true)
            else
                deferred.reject(false)

        return deferred.promise




app.factory 'sweet',['$q', '$timeout', ($q, $timeout) ->

    return new Alert($q, $timeout)

]