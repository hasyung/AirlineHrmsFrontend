

_       = require 'lodash'
path    = require 'path'
wrench  = require 'wrench'
fs      = require 'fs'
url     = require('url')
proxy   = require('./compat/proxy-middleware')
webpack = require('webpack')



deps = [
  #http://harvesthq.github.io/chosen/
  'deps/jquery/dist/jquery.min.js'
  # 'deps/socket.io-client/socket.io.js'
  'deps/simditor/lib/simditor-all.js'
  'deps/lodash/dist/lodash.min.js'
  # 'deps/moment/min/moment.min.js'
  'deps/store.js/store.js'
  'deps/angular/angular.js'
  'deps/angular-cookies/angular-cookies.js'
  'deps/angular-messages/angular-messages.js'
  'deps/angular-animate/angular-animate.js'
  'deps/angular-sanitize/angular-sanitize.js'
  'deps/angular-locale_zh-cn.js'
  'deps/angular-ui-router/release/angular-ui-router.js'
  # 'deps/angular-ui-utils/ui-utils.js'
  'deps/ngInfiniteScroll/build/ng-infinite-scroll.js'
]

plugin_deps = [
  'vendor/js/bootstrap-tagsinput.js' # 修复原生BUG
  # 'deps/jasny-bootstrap/dist/js/jasny-bootstrap.js' jasny bootstrap 增强版，提供一些好用组件
  # 'deps/bootstrap-hover-dropdown/bootstrap-hover-dropdown.js'
  'deps/jquery-slimscroll/jquery.slimscroll.js'
  'deps/angular-ui-select/dist/select.js'
  'deps/AngularJS-Toaster/toaster.js'
]

deps = deps.concat plugin_deps


module.exports = (grunt) ->



  unless process.env.NODE_ENV == 'production'
    require('time-grunt')(grunt)

  #load npm tasks
  require('load-grunt-tasks')(grunt)

  config =  grunt.file.readJSON 'config.json'


  grunt.initConfig {
    pkg: grunt.file.readJSON 'package.json'

    watch:
      livereload:
        files: ['dist/css/*.css']
        task: []
        options:
          livereload: 1337
      deps:
        files: deps
        tasks: ['concat:deps']
        options:
          livereload: true
      # styles:
      #   files: 'public/assets/scss/**/*.scss'
      #   tasks: ['compass']
      index:
        files: ['dist/*.html']
        options:
          livereload: true
      process:
        files: 'index.html'
        tasks: ['preprocess']
      pack:
        files: ['.tmp/**/*.js','.tmp/**/*.coffee','.tmp/**/*.html']
        tasks: ['webpack']
      js:
        files: 'dist/**'
        options:
          livereload: true

    # copy:
    #   # options:
    #   distFonts:
    #     expand: true
    #     flatten: true
    #     filter: 'isFile'
    #     src: ['deps/font-awesome/fonts/**'
    #           'deps/dribbble-portfolio/simple-line-icons/fonts/**']
    #     dest: 'dist/fonts/'

    #   fonts:
    #     expand: true
    #     flatten: true
    #     filter: 'isFile'
    #     src: [
    #            'deps/font-awesome/fonts/**'
    #            'deps/dribbble-portfolio/simple-line-icons/fonts/**'
    #         ]
    #     dest: '.tmp/fonts/'
    #   assets:
    #     expand: true
    #     cwd: 'public/assets'
    #     src: ['**']
    #     dest: '.tmp/'

    #   js:
    #     expand: true
    #     cwd: 'public/js'
    #     src: ['**']
    #     dest: '.tmp/'
    #   tpl:
    #     expand: true
    #     cwd: 'public/jade'
    #     src: ['**']
    #     dest: '.tmp/'
    #   img:
    #     expand: true
    #     cwd: 'public/assets/img'
    #     src: '**'
    #     dest: 'dist/img'
    #   deps:
    #     expand: true
    #     src: deps
    #     dest: 'dist/js'

    sync:  # 预处理文件到TMP目录
      assets:
        files: [
          {cwd: 'public/assets', src: ['**'], dest: '.tmp'}
          {cwd: 'public/js', src: ['**'], dest: '.tmp'}
          {cwd: 'public/jade', src: ['**'], dest: '.tmp'}
          {cwd: 'public/assets/img',src: ['**'], dest: 'dist/img'}
          {src: deps ,dest: 'dist/js'}
        ]
        verbose: true

    connect:
      options:
        port: 7656
        hostname: 'localhost'
        debug: true
        # livereload: true
      dev:
        options:
          open: true
          base: ['dist','vendor']
          middleware: (connect, options, middlewares) ->
            middlewares.unshift (req,res,next) ->
                res.setHeader("Access-Control-Allow-Origin", "*");
                res.setHeader("Access-Control-Allow-Credentials", true);
                # res.setHeader("Access-Control-Allow-Credentials", true);
                # res.setHeader("Access-Control-Max-Age", "172000");
                res.setHeader("Access-Control-Allow-Headers", "Content-Type");
                res.setHeader("Access-Control-Allow-Methods", "PUT, GET, POST, DELETE, OPTIONS");
                next()
            # 定义真实服务器的IP地址
            proxyOptions = url.parse(config.server)
            # 需要代理的路由
            proxyOptions.route = config.base_route
            middlewares.unshift proxy(proxyOptions)
            middlewares


    # concat:
    #   deps:
    #     src: deps
    #     dest: 'dist/js/lib.js'
    #     separator: ';'

    clean:['dist','.tmp']

    preprocess:
      debug:
        src: 'index.html'
        dest: 'dist/index.html'
        options:
          context:
            ENV: 'debug'
            SCRIPTS: generate_scripts() #加载


    sass:
      options:
        sourceMap: false
        # includePaths: require('node-bourbon').includePaths
      dev:
        files:
          'dist/css/web.css' : '.tmp/scss/web.scss'
          'dist/css/lib.css' : '.tmp/scss/lib.scss'

        outputStyle:  'nested' # 'compressed'

    concurrent:
      styles: ['watch','sass:dev']
      dev: ['watch']

    karma:
      options:
        configFile: 'test/karma.conf.js'
      unit:
        build:
          singleRun: true
          autoWatch: false
        debug:
          singleRun: false
          autoWatch: true
          logLevel: 'DEBUG'


    webpack:
      options:
        context: __dirname + "/.tmp/",
        module:
          preLoaders: [{
            test: '\.jade$'
            # include: pathToRegExp(path.join(__dirname, 'public', 'js')),
            include: pathToRegExp(path.join(__dirname, '.tmp'))
            loader: 'jade-loader'
            }]
        output:
          path: './dist/js'
        cache: true
        plugins: []
      desktop:
        entry: './app.coffee'
        module:
          loaders: [
            { test: /\.jade$/ , loader: 'jade-loader'}
            { test: /\.(png|gif|jpg)/, loader: 'file-loader', query: {prefix:'../img/'}}
            { test: /\.html$/, loader: "html-loader" }
            { test: /\.coffee$/, loader: "coffee-loader" }
            { test: /\.json$/ , loader: 'json-loader' }
          ]
        output:
          filename: "app_debug.js"
          publicPath: ""
        optimize:
          minimize: false
        debug: false
        cache: false
        # devtool: 'eval'
  }


  # grunt.registerTask 'default',['dist','connect:dev','concurrent:dev']
  # grunt.registerTask 'styles',['dist','connect:dev','concurrent:styles']
  # grunt.registerTask 'dist',['clean','concat:deps','copy','preprocess','webpack','sass:dev']
  # grunt.registerTask 'test',['karma:unit:build']



# build 顺序
#   1、清除环境
#   2、复制需要构建的资源到 TMP 目录 , 复制 lib 文件到 dist 目录
#   3、构建出 app.js 到 dist 目录
#   4、预编译index.html 到 dist 目录, 动态生成 script
#   5、预编译 scss 文件 (优化为 lib.css 和 app.css)

  grunt.registerTask 'default', ['sync','webpack','preprocess','sass:dev']


pathToRegExp = (p) ->
  new RegExp "^" + escapeRegExpString p
escapeRegExpString = (str) ->
  str.replace /[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&"
generate_scripts = () ->
  files = wrench.readdirSyncRecursive('dist/js') # work around
  _.filter files, (file) ->
      /.js$/.test(file)
    .map (script) ->
      "<script src=\"js/#{script}\"></script>"
    .join(" ")



