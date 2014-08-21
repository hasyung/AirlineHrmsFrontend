// Karma configuration
// Generated on Sun Jun 22 2014 14:13:52 GMT+0800 (CST)

module.exports = function(config) {
  config.set({

    // base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: '',


    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['jasmine'],


    // list of files / patterns to load in the browser
    files: [
      // 'deps/js/angular/angular.js',
      '../dist/js/lib.js',
      '../dist/js/app_debug.js',
      '../deps/js/angular-mocks/angular-mocks.js',
      'unit/*.coffee'
    ],


    // list of files to exclude
    exclude: [
      // 'deps/js/angular-mocks/angular-mocks.js'
    ],


    // preprocess matching files before serving them to the browser
    // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors: {
      '**/*.coffee': ['coffee']
    },

    // coffeePreprocessor: {
    //   // options passed to the coffee compiler
    //   options: {
    //     bare: true,
    //     sourceMap: true
    //   },
    //   // transforming the filenames
    //   transformPath: function(path) {
    //     return path.replace(/\.coffee$/, '.js');
    //   }
    // },

// add webpack as preprocessor
// preprocessors: {
//     'test/*Test.js': ['webpack']
// },

    // webpack: {
    //     cache: true,
    //     // webpack configuration
    // },

    // webpackServer: {
    //     // webpack-dev-server configuration
    //     // webpack-dev-middleware configuration
    // },

    // // the port used by the webpack-dev-server
    // // defaults to "config.port" + 1
    // // webpackPort: 1234,

    // plugins: [
    //     require("karma-webpack")
    // }


    // test results reporter to use
    // possible values: 'dots', 'progress'
    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['progress'],


    // web server port
    port: 9876,


    // enable / disable colors in the output (reporters and logs)
    colors: true,


    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    // logLevel: config.LOG_INFO,
    logLevel: 'DEBUG',


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,


    // start these browsers
    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['PhantomJS'],

    // plugins: [require('karma-webpack')],


    // Continuous Integration mode
    // if true, Karma captures browsers, runs the tests and exits
    singleRun: false
  });
};
