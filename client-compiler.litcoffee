Resolves all the dependencies for `client.litcoffee` and compiles it into a
single string of JavaScript sourcecode with a sourcemap included at the end.

    browserify = require 'browserify'
    coffeeify  = require 'coffeeify'

    module.exports =
    clientCompiler = (cb) ->
      browserify('./client.litcoffee')  # the entry point
        .transform(coffeeify)           # compile coffee
        .bundle debug: yes, cb          # include a sourcemap
