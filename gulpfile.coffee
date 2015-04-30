gulp            = require("gulp")
jade            = require("gulp-jade")
_               = require("lodash")
url             = require('url')
argv            = require('minimist')(process.argv.slice(2))
coffee          = require("gulp-coffee")
concat          = require("gulp-concat")
uglify          = require("gulp-uglify")
plumber         = require("gulp-plumber")
wrap            = require("gulp-wrap")
rename          = require("gulp-rename")
livereload      = require("gulp-livereload")
# gutil         = require("gulp-util")
minifyHTML      = require("gulp-minify-html")
sass            = require("gulp-sass")
sourcemaps      = require('gulp-sourcemaps')
less            = require("gulp-less")
csslint         = require("gulp-csslint")
minifyCSS       = require("gulp-minify-css")
watch           = require("gulp-watch")
scsslint        = require("gulp-scss-lint")
newer           = require("gulp-newer")
cache           = require("gulp-cached")
jadeInheritance = require('gulp-jade-inheritance')

fs              = require("fs")
request         = require("request")


proxy           = require('./compat/proxy-middleware')

debugMode       = true

LOCAL_TEST_SERVER = "http://192.168.6.99:9001"
REMOTE_TEST_SERVER = "http://114.215.142.122:9002"
LOCAL_SERVER = "http://localhost:3000"


if argv.localhost
    PROXY_SERVER_ADDR = LOCAL_SERVER
else if argv.remote
    PROXY_SERVER_ADDR =  REMOTE_TEST_SERVER
else if argv.addr
    PROXY_SERVER_ADDR = "http://#{argv.addr}"
else
    PROXY_SERVER_ADDR = LOCAL_TEST_SERVER


paths =
    app: "app"
    dist: "dist"
    jade: ["app/partials/**/*.jade"]
    vendorStyles: "app/styles/lib/*.css"
    lessVendorStyles: "app/styles/less/app.less"
    scssStyles: "app/styles/**/*.scss"
    distStylesPath: "dist/styles"
    distStyles: []
    sassStylesLib: "app/styles/lib.scss"
    sassStylesMain: ["app/styles/web.scss"]
    images: "app/images/**/*"
    svg: "app/svg/**/*"
    coffee: ["app/coffee/app.coffee"
             "app/coffee/*.coffee"
             "app/coffee/base/*.coffee"
             "app/coffee/directives/*.coffee"
             "app/coffee/component/*.coffee"
             "app/coffee/auth/*.coffee"
             "app/coffee/filters/*.coffee"
             "app/coffee/modules/*.coffee"
             "app/coffee/resources/*.coffee"
             # "app/coffee/modules/controllerMixins.coffee"
             # "app/coffee/modules/*.coffee"
             # "app/coffee/modules/common/*.coffee"
             # "app/coffee/modules/tasks/*.coffee"
             # "app/coffee/modules/admin/*.coffee"
             # "app/coffee/modules/resources/*.coffee"
             # "app/coffee/modules/user-settings/*.coffee"
             # "app/plugins/**/*.coffee"
    ]
    vendorJsLibs: [
        'deps/lodash/lodash.js'
        'deps/underscore.string/dist/underscore.string.js'
        'deps/store.js/store.js'
        'deps/moment/min/moment.min.js'
        'deps/jquery/dist/jquery.min.js'
        'deps/jqtree/tree.jquery.js'
        'deps/d3/d3.js'
        #alert
        'deps/sweetalert/lib/sweet-alert.js'

        #end
        'deps/angular/angular.js'
        # 'deps/angular-i18n/angular-locale_zh-cn.js'
        #http://harvesthq.github.io/chosen/
        'deps/simple-module/lib/module.js'
        'deps/simple-uploader/lib/uploader.js'
        'deps/simple-hotkeys/lib/hotkeys.js'
        'deps/simditor/lib/simditor.js'
        'deps/angular-cookies/angular-cookies.js'
        'deps/angular-restmod/dist/angular-restmod-bundle.js'
        'deps/angular-restmod/dist/styles/ams.js'
        'deps/angular-restmod/dist/plugins/dirty.js'
        'deps/angular-restmod/dist/plugins/preload.js'
        'deps/angular-messages/angular-messages.js'
        'deps/angular-animate/angular-animate.js'
        'deps/angular-aria/angular-aria.js'
        'deps/angular-sanitize/angular-sanitize.js'
        'deps/angular-filter/dist/angular-filter.js'
        'deps/angular-strap/dist/angular-strap.js'
        'deps/angular-strap/dist/angular-strap.tpl.js'
        'deps/angular-ui-router/release/angular-ui-router.js'
        'deps/ui-router-extras/release/ct-ui-router-extras.js'
        'deps/ngDialog/js/ngDialog.js'
        # 'compat/vendor/breadcrumb.js'
        'compat/vendor/wizard.js'
        'compat/vendor/ui-bootstrap-custom-tpls-0.12.0.js'
        # 'deps/ngInfiniteScroll/build/ng-infinite-scroll.js'
        'deps/AngularJS-Toaster/toaster.js'
        'deps/angular-ui-select/dist/select.js'
        'deps/jquery-slimscroll/jquery.slimscroll.js'
        'deps/angularjs-toaster/toaster.js'
        'deps/angular-material/angular-material.js'
        'compat/socket.io.js'
        'compat/pomeloclient.js'
        'compat/communite.js'
        'deps/ng-flow/dist/ng-flow-standalone.js'
        # 'deps/angular-ui-utils/ui-utils.js'
        # 'deps/jasny-bootstrap/dist/js/jasny-bootstrap.js' jasny bootstrap 增强版，提供一些好用组件
    ]
############################################################################
# Layout/CSS Related tasks
##############################################################################

gulp.task "jade-deploy", ->
    gulp.src(paths.jade)
        .pipe(plumber())
        .pipe(cache("jade"))
        .pipe(jade({pretty: false}))
        .pipe(gulp.dest("#{paths.dist}/partials"))

gulp.task "jade-watch", ->
    gulp.src(paths.jade)
        .pipe(plumber())
        .pipe(cache("jade"))
        .pipe(jadeInheritance({basedir: './app'}))
        .pipe(jade({pretty: true}))
        .pipe(gulp.dest("#{paths.dist}"))

gulp.task "template",['copy'], ->
    gulp.src("#{paths.app}/index.jade")
        .pipe(plumber())
        .pipe(jade({pretty: true, locals:{debugMode: debugMode,v: (new Date()).getTime(),libs: generate_scripts()}}))
        .pipe(gulp.dest("#{paths.dist}"))

gulp.task "sass-lint", ->
    gulp.src([paths.scssStyles, '!app/styles/lib/**/*.scss'])
        .pipe(cache("sasslint"))
        .pipe(scsslint({config: "scsslint.yml"}))

gulp.task "sass-watch", ->
    gulp.src(paths.sassStylesMain)
        .pipe(plumber())
        .pipe(sass({includePaths: require('node-bourbon').includePaths}))
        .pipe(rename("web.css"))
        .pipe(gulp.dest(paths.distStylesPath))


#编译 并压缩 scss 文件
gulp.task "sass-lib", ->
    gulp.src(paths.sassStylesLib)
        .pipe(plumber())
        .pipe(sass())
        .pipe(sourcemaps.write())
        .pipe(rename("lib.css"))
        .pipe(gulp.dest(paths.distStylesPath))


#编译 并压缩 scss 文件
gulp.task "sass-deploy", ->
    gulp.src(paths.sassStylesMain)
        .pipe(plumber())
        .pipe(sass({includePaths: require('node-bourbon').includePaths}))
        .pipe(sourcemaps.write())
        .pipe(rename("app.css"))
        .pipe(gulp.dest(paths.distStylesPath))

# 引入第三方 CSS
gulp.task "css-vendor", ->
    gulp.src(paths.vendorStyles)
        .pipe(concat("vendor1.css"))
        .pipe(gulp.dest(paths.distStylesPath))

gulp.task "less-vendor", ->
    gulp.src(paths.lessVendorStyles)
        .pipe(less())
        .pipe(rename("angulr.css"))
        .pipe(gulp.dest(paths.distStylesPath))

gulp.task "css-lint-app", ["sass-watch"],  ->
    gulp.src(paths.distStylesPath + "/app.css")
        .pipe(csslint("csslintrc.json"))
        .pipe(csslint.reporter())

gulp.task "styles-watch", ["sass-watch", "css-vendor", "css-lint-app"], ->
    gulp.src(paths.distStyles)
        .pipe(concat("main.css"))
        .pipe(gulp.dest(paths.distStylesPath))

gulp.task "styles-deploy", ["sass-deploy", "css-vendor"], ->
    gulp.src(paths.distStyles)
        .pipe(concat("main.css"))
        .pipe(minifyCSS())
        .pipe(gulp.dest(paths.distStylesPath))

##############################################################################
# JS Related tasks
##############################################################################

gulp.task "coffee-watch", ->
    gulp.src(paths.coffee)
        .pipe(plumber())
        .pipe(coffee())
        .pipe(concat("app.js"))
        .pipe(gulp.dest("dist/js/"))

gulp.task "js-watch", ->
    gulp.src(paths.js)
        .pipe(plumber())
        .pipe(concat("appjs.js"))
        .pipe(gulp.dest("dist/js/"))





gulp.task "coffee-deploy", ->
    gulp.src(paths.coffee)
        .pipe(plumber())
        .pipe(coffee())
        .pipe(concat("app.js"))
        .pipe(uglify({mangle:false, preserveComments: false}))
        .pipe(gulp.dest("dist/js/"))

gulp.task "jslibs-watch", ->
    gulp.src(paths.vendorJsLibs)
        .pipe(plumber())
        .pipe(concat("libs.js"))
        .pipe(gulp.dest("dist/js/"))

gulp.task "jslibs-deploy", ->
    gulp.src(paths.vendorJsLibs)
        .pipe(plumber())
        .pipe(concat("libs.js"))
        .pipe(uglify({mangle:false, preserveComments: false}))
        .pipe(gulp.dest("dist/js/"))

##############################################################################
# Common tasks
##############################################################################

# SVG
gulp.task "svg",  ->
    gulp.src("#{paths.app}/svg/**/*")
        .pipe(gulp.dest("#{paths.dist}/svg/"))

# Copy Files
gulp.task "copy",  ->
    gulp.src("#{paths.app}/styles/fonts/*")
        .pipe(gulp.dest("#{paths.dist}/fonts/"))

    gulp.src("#{paths.app}/api/*")
        .pipe(gulp.dest("#{paths.dist}/api/"))

    gulp.src("#{paths.app}/images/**/*")
        .pipe(gulp.dest("#{paths.dist}/images/"))

    gulp.src(paths.vendorJsLibs)
        .pipe(gulp.dest("#{paths.dist}/vendor/"))


gulp.task "express", ['copy'],  ->
    express = require("express")
    bodyParser = require('body-parser')
    app = express()


    proxyOptions = url.parse(PROXY_SERVER_ADDR)
    proxyOptions.route = '/api'
    app.set('views', __dirname + '/app/')
    app.set('view engine', 'jade')

    # 反向代理 webapi
    app.use(proxy(proxyOptions))
    app.use(bodyParser.json())
    app.use(bodyParser.urlencoded())
    app.use("/js", express.static("#{__dirname}/dist/js"))
    app.use("/api", express.static("#{__dirname}/dist/api"))
    app.use("/vendor", express.static("#{__dirname}/dist/vendor"))
    app.use("/styles", express.static("#{__dirname}/dist/styles"))
    app.use("/images", express.static("#{__dirname}/dist/images"))
    # app.use("/svg", express.static("#{__dirname}/dist/svg"))
    app.use("/partials", express.static("#{__dirname}/dist/partials"))
    app.use("/fonts", express.static("#{__dirname}/dist/fonts"))
    app.use("/plugins", express.static("#{__dirname}/dist/plugins"))

    jar = request.jar()
    app.get "/sessions/new/", (req, res, next) ->
        res.render("partials/cust_login")

        # request.post {
        #     url: "#{PROXY_SERVER_ADDR}/sessions"
        #     formData: {
        #         'user[employee_no]': '003740'
        #         'user[password]': '123456'
        #     }
        #     jar: jar
        # }, (err, response, body) ->
        #     cooks = jar.getCookies(response.request.href)
        #     tokenCookie =  _.find cooks, (cook) -> cook.key == 'token'
        #     res.cookie('token', tokenCookie.value)
        #     res.redirect('/')
    app.post "/sessions", (req, res) ->
        user = req.body.user
        request.post {
            url: "#{PROXY_SERVER_ADDR}/sessions"
            formData: {
                'user[employee_no]': user.employee_no
                'user[password]': user.password
            }
            jar: jar
        }, (err, response, body) ->
            cooks = jar.getCookies(response.request.href)
            tokenCookie =  _.find cooks, (cook) -> cook.key == 'token'
            if tokenCookie && tokenCookie.value
                res.cookie('token', tokenCookie.value)
                res.redirect('/')
            else
                res.redirect('/sessions/new/')


    app.get "/", (req, res, next) ->
        request {
            url: "#{PROXY_SERVER_ADDR}/metadata"
            jar: jar
        }, (err, response, body) ->

            metadata = if !err && response.statusCode == 200 then body else "alert('meta data initial failed');console.log(#{body});"
            res.render('index', {meta: metadata, libs: libs, debugMode: debugMode})
        # Just send the index.html for other files to support HTML5Mode
    app.listen(9001)

    libs = generate_scripts()

# Rerun the task when a file changes
gulp.task "watch", ['jade-deploy'],  ->
    livereload.listen()
    gulp.watch(paths.jade, ["jade-watch"])
    gulp.watch(paths.scssStyles, ["sass-watch"])
    gulp.watch(paths.coffee, ["coffee-watch"])

    gulp.watch(["dist/js/app.js","dist/styles/web.css","dist/partials/**/*.html"])
        .on("change",livereload.changed)



gulp.task "deploy", [
    "jade-deploy"
    "less-vendor"
    "css-vendor"
    "template"
    "sass-watch"
    "sass-lib"
    "coffee-watch"
    # "coffee-deploy"
    "jslibs-watch"
    # "styles-deploy"
]

# bugfix: copy 异步 template 同步 ,后者依赖前者
# 添加 lib 文件后，先执行 gulp copy
gulp.task "default", [
    "jade-deploy"
    "less-vendor"
    "css-vendor"
    "template"
    "sass-watch"
    "sass-lib"
    "coffee-watch"
    "jslibs-watch"
    "express"
    "watch"
]

# utils

pathToRegExp = (p) ->
    new RegExp "^" + escapeRegExpString p
escapeRegExpString = (str) ->
    str.replace /[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&"
generate_scripts = () ->
    files = fs.readdirSync("#{__dirname}/dist/vendor") # work around
    _.sortBy files,(fileName) ->
        _.findIndex paths.vendorJsLibs,(path) ->
            path.indexOf(fileName) != -1







