# Phase 4 Project

Install node.js (nodejs.org) then run `make serve` from the command line.

Node.js processes start quickly with the minimum of capabilities. By default
they can't talk to a web browser. In fact, unlike Ruby processes they can't even
talk to the filesystem.

For this challenge we need three modules from the standard library.

The `fs` module for reading and writing files

    fs = require 'fs'

The `http` module allows us to talk the HTTP protocol to other programs

    http = require 'http'

Programs that talk HTTP usually encode information in the querystring format
(e.g. `item=%22foo+bar%22`)

    querystring = require 'querystring'

The `send` module for serving static files

    send = require 'send'

We also load CoffeeScript (from npm, node's rubygems equivalent) so we can
write our front end code in CS then compile it to JS before sending it to the
client.

    cs = require 'coffee-script'

Connect is a library for passing http request and response objects through a
chain of "middleware" handlers. One handler might do something like parse the
cookie string into a data structure then call the next handler in the
chain. Another might match against a condition in the request (commonly the
method and path), create a response and decide there's no need to call the
next method in the chain.

Connect is higher up the abstraction ladder than node's http module or Ruby's
rack library but lower down than something like Sinatra.

    connect = require 'connect'

Dispatch produces returns a handler that only matches a specific method and
path.

    dispatch = require 'dispatch'

A hanlder that parses the querystring POST body into a map

    urlencodedBody = connect.urlencoded()

Create the connect chain

    app = connect()

A GET on the root url renders the UI. The UI is just some template html with a
script tag down the bottom that loads in all the behavior.

    app.use dispatch 'GET /' : (req, res, next) ->
      send(req, 'template.html').pipe res

A POST parses out the updated value, save it then renders the UI

    app.use dispatch 'POST /' : connect urlencodedBody, (req, res, next) ->
      {item} = req.body
      saveData item, (err) ->
        if err then next err ; return
        res.setHeader 'Content-Type', 'text/json'
        res.end JSON.stringify {item}

A GET to `/data.json` returns the historical contents of the item as a list
of strings encoded in JSON

    app.use dispatch 'GET /data.json' : (req, res, next) ->
      loadData (err, data) ->
        if err then next err ; return
        res.setHeader 'Content-Type', 'text/json'
        res.end JSON.stringify data

A GET to `/default.appcache` returns the list of paths that the browser should
cache and not request again unless the contents of _this_ route (the manifest)
change.

    app.use dispatch 'GET /default.appcache' : (req, res, next) ->
      clientManifest (err, manifest) ->
        if err then next err ; return
        res.end manifest

    clientManifest = require './cache-manifest'

A GET to `/app.js` renders the application's javascript (with browserify)

    browserify = require 'browserify'
    coffeeify  = require 'coffeeify'

    app.use dispatch 'GET /app.js' : (req, res, next) ->
      browserify('./client.litcoffee').transform(coffeeify).bundle
        debug: yes
      , (err, js) ->
        if err then next err ; return
        res.setHeader 'Content-Type', 'text/javascript'
        res.end js

A GET to `/app.css` renders the application's css

    app.use dispatch 'GET /app.css' : (req, res, next) ->
      send(req, 'app.css').pipe res

Data is stored in a flat file; `saveData` takes a new value and appends it to
the end of the file; `loadData` returns all historical values in chronlogical
order.

    dataFile = './item.txt'

    saveData = (data, cb) ->
      fs.appendFile dataFile, data + "\n", 'utf8', cb

    loadData = (cb) ->
      fs.readFile dataFile, 'utf8', (err, data) ->
        return cb err if err?
        lines = data.trim().split "\n"
        cb noErr, lines

Create a web server, pass the connect chain to it and start listening on a port

    port = process.env.PORT ? 3000
    server = http.createServer app
    server.listen port, -> console.log "app running on port #{port}"

* * *

Alias to enhance readability

    noErr = null
