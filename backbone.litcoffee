Backbone expects a jQuery-like `$` function to wrap view elements and to
handle event delegation. It'd be nice not depend on jQuery or Zepto so this
is an experiment to see if that's possible.

    {extend} = require 'underscore'
    backbone = require 'backbone'
    bonzo    = require 'bonzo'
    bean     = require 'bean'
    qwery    = require 'qwery'

    module.exports = backbone

    backbone.$ = (args...) ->
      # probably fails when args[0] is window
      # probably fails if passed an array constructed with this fn
      extend (bonzo args...), @$extensions

    backbone.$extensions =
      find: (args...) -> backbone.$ (qwery args...), this[0]
      on:   (args...) -> bean.on  this[0], args...
      off:  (args...) -> bean.off this[0], args...

