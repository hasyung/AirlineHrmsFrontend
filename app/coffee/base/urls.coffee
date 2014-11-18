

nb = @.nb


urls =
    'home': '/'
    'login': '/login'
    'not-found': '/not-found'
    'permission-denied': '/permission-denied'




format = (fmt, obj) ->
    obj = _.clone(obj)
    return fmt.replace /%s/g, (match) -> String(obj.shift())


class UrlsService extends nb.Service
    @.$inject = ['$config']

    constructor: (@config) ->
        @urls = urls

    update: (urls) ->
        @urls = _.merge(@urls, urls)

    reslove: () ->
        args = _.toArray(arguments)

        if args.length == 0
            throw Error("wrong arguments to setUrls")

        name = args.slice(0, 1)[0]
        url = format(@.urls[name], args.slice(1))

        return format("%s/%s", [
            _.str.rtrim(@.mainUrl, "/"),
            _.str.ltrim(url, "/")
        ])

module = @.nb.app
module.service('$urls', UrlsService)