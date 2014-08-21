path = require 'path'
fs   = require 'fs'
# httpProxy = require('http-proxy')
url = require('url')
proxy = require('./compat/proxy-middleware')
webpack = require('webpack')



deps = [
  'deps/jquery/dist/jquery.min.js'
  'deps/socket.io-client/socket.io.js'
  # 'deps/engine.io/engine.io.js'
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
  'deps/restangular/dist/restangular.js'
  'deps/ngInfiniteScroll/build/ng-infinite-scroll.js'
]

plugin_deps = [
  'vendor/js/bootstrap-tagsinput.js' # 修复原生BUG
  'deps/jasny-bootstrap/dist/js/jasny-bootstrap.js'
  'deps/bootstrap-hover-dropdown/bootstrap-hover-dropdown.js'
  'deps/jquery-slimscroll/jquery.slimscroll.js'
  'deps/angular-ui-select/dist/select.js'
  'deps/jquery.uniform/jquery.uniform.js'
  'deps/AngularJS-Toaster/toaster.js'
]

deps = deps.concat plugin_deps


module.exports = (grunt) ->


  # grunt.loadNpmTasks 'grunt-recess'
  # grunt.loadNpmTasks 'grunt-webpack'
  # grunt.loadNpmTasks 'grunt-contrib-concat'
  # grunt.loadNpmTasks 'grunt-contrib-uglify'
  # grunt.loadNpmTasks 'grunt-contrib-watch'
  # grunt.loadNpmTasks 'grunt-contrib-copy'
  # grunt.loadNpmTasks 'grunt-contrib-sass'
  # grunt.loadNpmTasks 'grunt-bower-task'


  unless process.env.NODE_ENV == 'productiom'
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
      copy:
        files: 'public/**/*'
        tasks: 'sync:assets'

    copy:
      # options:
      distFonts:
        expand: true
        flatten: true
        filter: 'isFile'
        src: ['deps/font-awesome/fonts/**'
              'deps/dribbble-portfolio/simple-line-icons/fonts/**']
        dest: 'dist/fonts/'

      fonts:
        expand: true
        flatten: true
        filter: 'isFile'
        src: [
               'deps/font-awesome/fonts/**'
               'deps/dribbble-portfolio/simple-line-icons/fonts/**'
            ]
        dest: '.tmp/fonts/'
      assets:
        expand: true
        cwd: 'public/assets'
        src: ['**']
        dest: '.tmp/'
      js:
        expand: true
        cwd: 'public/js'
        src: ['**']
        dest: '.tmp/'
      tpl:
        expand: true
        cwd: 'public/jade'
        src: ['**']
        dest: '.tmp/'
      img:
        expand: true
        cwd: 'public/assets/img'
        src: '**'
        dest: 'dist/img'

    sync:
      assets:
        files: [
          {cwd:'public/assets', src: ['**'], dest: '.tmp'}
          {cwd:'public/js', src: ['**'], dest: '.tmp'}
          {cwd:'public/tpl', src: ['**'], dest: '.tmp'}
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
            # proxyOpts = {
            #   # target: 'http://192.168.3.18'
            #   forward: 'http://192.168.3.19:3000'
            #   ws: false
            #   xfwd: true
            # }
            # #create proxy server
            # proxy = httpProxy.createProxyServer(proxyOpts)
            middlewares.unshift (req,res,next) ->
                res.setHeader("Access-Control-Allow-Origin", "*");
                res.setHeader("Access-Control-Allow-Credentials", true);
                # res.setHeader("Access-Control-Allow-Credentials", true);
                # res.setHeader("Access-Control-Max-Age", "172000");
                res.setHeader("Access-Control-Allow-Headers", "Content-Type");
                res.setHeader("Access-Control-Allow-Methods", "PUT, GET, POST, DELETE, OPTIONS");
                # res.setHeader("Access-Control-Allow-Origin","http://192.168.1.110:3000")
                next()
            #
            # proxyOptions = url.parse('http://192.168.3.99:3000');
            # proxyOptions = url.parse('http://localhost');
            proxyOptions = url.parse(config.server)
            # proxyOptions = url.parse(config.remote_server);
            #proxyOptions = url.parse(config.server);

            proxyOptions.route = config.base_route
            middlewares.unshift proxy(proxyOptions)


            middlewares



    concat:
      deps:
        src: deps
        dest: 'dist/js/lib.js'
        separator: ';'
    clean:['dist','.tmp']

    # bower:
    #   install:
    #     options:
    #       targetDir: './deps'

    preprocess:
      debug:
        src: 'index.html'
        dest: 'dist/index.html'
        options:
          context:
            ENV: 'debug'
    compass:
      dist:
        options:
          specify: ['.tmp/scss/web.scss','.tmp/scss/lib.scss']
          sassDir: '.tmp/scss/'
          cssDir: 'dist/css'
          # fontsDir: 'dist/fonts'
          watch: false
          require: ['sass-css-importer']
          raw: 'Encoding.default_external = "utf-8"'
      dev:
        options:
          specify: ['.tmp/scss/web.scss','.tmp/scss/lib.scss']
          sassDir: '.tmp/scss/'
          cssDir: 'dist/css'
          raw: 'Encoding.default_external = "utf-8"'
          # fontsDir: 'dist/fonts'
          require: ['sass-css-importer']
          watch: true
    concurrent:
      styles: ['watch','compass:dev']
      dev: ['watch']

    # sass:
    #   dist:
    #     options:
    #       expand: true
    #       cwd: 'styles'
    #       src: ['*.scss']
    #       dest: '../public'
    #       ext: '.css'
    #     file:
    #       'web.css': 'web.scss'
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
        # jshint:
        #   "validthis": true
        #   "laxcomma" : true
        #   "laxbreak" : true
        #   "browser"  : true
        #   "eqnull"   : true
        #   "debug"    : true
        #   "devel"    : true
        #   "boss"     : true
        #   "expr"     : true
        #   "asi"      : true
        #   "sub"      : true
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


  grunt.registerTask 'default',['dist','connect:dev','concurrent:dev']
  grunt.registerTask 'styles',['dist','connect:dev','concurrent:styles']
  grunt.registerTask 'dist',['clean','concat:deps','copy','preprocess','webpack','compass:dist']
  grunt.registerTask 'test',['karma:unit:build']

pathToRegExp = (p) ->
  new RegExp "^" + escapeRegExpString p
escapeRegExpString = (str) ->
  str.replace /[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&"

