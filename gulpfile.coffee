gulp            = require("gulp")
jade            = require("gulp-jade")
_               = require("lodash")
url             = require('url')

coffee          = require("gulp-coffee")
concat          = require("gulp-concat")
uglify          = require("gulp-uglify")
plumber         = require("gulp-plumber")
wrap            = require("gulp-wrap")
rename          = require("gulp-rename")
livereload      = require("gulp-livereload")
# gutil           = require("gulp-util")
minifyHTML      = require("gulp-minify-html")
sass            = require("gulp-sass")
csslint         = require("gulp-csslint")
minifyCSS       = require("gulp-minify-css")
watch           = require("gulp-watch")
scsslint        = require("gulp-scss-lint")
newer           = require("gulp-newer")
cache           = require("gulp-cached")
jadeInheritance = require('gulp-jade-inheritance')
fs = require("fs")


proxy   = require('./compat/proxy-middleware')

debugMode = true

paths =
    app: "app"
    dist: "dist"
    jade: ["app/partials/**/*.jade"]
    vendorStyles: [
        'deps/bootstrap/dist/css/bootstrap.css'
    ]
    scssStyles: "app/styles/**/*.scss"
    distStylesPath: "dist/styles"
    distStyles: []
    sassStylesLib: "app/styles/lib.scss"
    sassStylesMain: "app/styles/web.scss"
    images: "app/images/**/*"
    svg: "app/svg/**/*"
    coffee: ["app/coffee/app.coffee"
             "app/coffee/*.coffee"
             "app/coffee/base/*.coffee"
             "app/coffee/personnel/*.coffee"
             # "app/coffee/modules/controllerMixins.coffee"
             # "app/coffee/modules/*.coffee"
             # "app/coffee/modules/common/*.coffee"
             # "app/coffee/modules/backlog/*.coffee"
             # "app/coffee/modules/taskboard/*.coffee"
             # "app/coffee/modules/kanban/*.coffee"
             # "app/coffee/modules/issues/*.coffee"
             # "app/coffee/modules/userstories/*.coffee"
             # "app/coffee/modules/tasks/*.coffee"
             # "app/coffee/modules/wiki/*.coffee"
             # "app/coffee/modules/admin/*.coffee"
             # "app/coffee/modules/projects/*.coffee"
             # "app/coffee/modules/locales/*.coffee"
             # "app/coffee/modules/base/*.coffee"
             # "app/coffee/modules/resources/*.coffee"
             # "app/coffee/modules/user-settings/*.coffee"
             # "app/plugins/**/*.coffee"
    ]
    vendorJsLibs: [
        'deps/underscore.string/lib/underscore.string.js',
        'deps/store.js/store.js'
        'deps/lodash/dist/lodash.min.js'
        'deps/moment/min/moment.min.js'
        'deps/jquery/dist/jquery.min.js'
        'deps/angular/angular.js'
        #http://harvesthq.github.io/chosen/
        'deps/simditor/lib/simditor-all.js'
        'deps/angular-cookies/angular-cookies.js'
        'deps/angular-restmod/dist/angular-restmod-bundle.js'
        'deps/angular-messages/angular-messages.js'
        'deps/angular-animate/angular-animate.js'
        'deps/angular-sanitize/angular-sanitize.js'
        'deps/angular-ui-router/release/angular-ui-router.js'
        'deps/ngInfiniteScroll/build/ng-infinite-scroll.js'
        'deps/angular-locale_zh-cn.js'
        'deps/angular-ui-select/dist/select.js'
        'deps/jquery-slimscroll/jquery.slimscroll.js'
        # 'deps/angular-ui-utils/ui-utils.js'
        # 'deps/bootstrap-hover-dropdown/bootstrap-hover-dropdown.js'
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

gulp.task "template", ->
    gulp.src("#{paths.app}/index.jade")
        .pipe(plumber())
        .pipe(jade({pretty: true, locals:{debugMode: debugMode,v:(new Date()).getTime(),libs: generate_scripts()}}))
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
        .pipe(rename("lib.css"))
        .pipe(gulp.dest(paths.distStylesPath))


#编译 并压缩 scss 文件
gulp.task "sass-deploy", ->
    gulp.src(paths.sassStylesMain)
        .pipe(plumber())
        .pipe(sass({includePaths: require('node-bourbon').includePaths}))
        .pipe(rename("app.css"))
        .pipe(gulp.dest(paths.distStylesPath))

# 引入第三方 CSS
gulp.task "css-vendor", ->
    gulp.src(paths.vendorStyles)
        .pipe(concat("vendor.css"))
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

# 国际化
# gulp.task "locales", ->
#     gulp.src("app/locales/en/app.json")
#         .pipe(wrap("angular.module('taigaLocales').constant('localesEnglish', <%= contents %>);"))
#         .pipe(rename("localeEnglish.coffee"))
#         .pipe(gulp.dest("app/coffee/modules/locales"))

#     gulp.src("app/locales/es/app.json")
#         .pipe(wrap("angular.module('locales.es', []).constant('locales.es', <%= contents %>);"))
#         .pipe(rename("locale.es.coffee"))
#         .pipe(gulp.dest("app/coffee/"))

gulp.task "coffee-watch", ->
    gulp.src(paths.coffee)
        .pipe(plumber())
        .pipe(coffee())
        .pipe(concat("app.js"))
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
    gulp.src("#{paths.app}/fonts/*")
        .pipe(gulp.dest("#{paths.dist}/fonts/"))

    gulp.src(paths.vendorJsLibs)
        .pipe(gulp.dest("#{paths.dist}/vendor/"))
    gulp.src("#{paths.app}/api/*")
        .pipe(gulp.dest("#{paths.dist}/api/"))

    gulp.src("#{paths.app}/images/**/*")
        .pipe(gulp.dest("#{paths.dist}/images/"))


gulp.task "express", ->
    express = require("express")
    app = express()

    proxyOptions = url.parse('http://192.168.6.7:3000')
    proxyOptions.route = '/api'

    # 反向代理 webapi
    app.use(proxy(proxyOptions))
    app.use("/js", express.static("#{__dirname}/dist/js"))
    app.use("/api", express.static("#{__dirname}/dist/api"))
    app.use("/vendor", express.static("#{__dirname}/dist/vendor"))
    app.use("/styles", express.static("#{__dirname}/dist/styles"))
    app.use("/images", express.static("#{__dirname}/dist/images"))
    # app.use("/svg", express.static("#{__dirname}/dist/svg"))
    app.use("/partials", express.static("#{__dirname}/dist/partials"))
    app.use("/fonts", express.static("#{__dirname}/dist/fonts"))
    app.use("/plugins", express.static("#{__dirname}/dist/plugins"))

    app.all "/*", (req, res, next) ->
        # Just send the index.html for other files to support HTML5Mode
        res.sendFile("index.html", {root: "#{__dirname}/dist/"})

    app.listen(9001)

# Rerun the task when a file changes
gulp.task "watch", ->
    livereload.listen()
    gulp.watch(paths.jade, ["jade-watch"])
    gulp.watch("#{paths.app}/index.jade", ["template"])
    gulp.watch(paths.scssStyles, ["sass-watch"])
    gulp.watch(paths.coffee, ["coffee-watch"])
    gulp.watch(["dist/index.html","dist/js/app.js","dist/styles/web.css","dist/partials/**/*.html"])
        .on("change",livereload.changed)



gulp.task "deploy", [
    "jade-deploy",
    "template",
    "copy",
    "coffee-deploy",
    "jslibs-deploy",
    "styles-deploy"
]

# bugfix: copy 异步 template 同步 ,后者依赖前者
# 添加 lib 文件后，先执行 gulp copy
gulp.task "default", [
    "jade-deploy",
    "copy",
    "css-vendor",
    "template",
    "sass-watch",
    "sass-lib",
    "coffee-watch",
    "jslibs-watch",
    "express",
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







