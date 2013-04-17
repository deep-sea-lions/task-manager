# Phase 4 Project

Install node.js (nodejs.org) then run `make serve` from the command line.

Node.js processes start quickly with the minimum of capabilities. By default
they can't talk to a web browser. In fact, unlike Ruby processes they can't even
talk to the filesystem.

The `http` module allows us to talk the HTTP protocol to other programs

    http = require 'http'

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

A GET to `/default.appcache` returns the list of paths that the browser should
cache and not request again unless the contents of _this_ route (the manifest)
change.

    app.use dispatch 'GET /default.appcache' : (req, res, next) ->
      clientManifest (err, manifest) ->
        if err then next err ; return
        res.end manifest

    clientManifest = require './cache-manifest'

A GET to `/app.js` renders the application's javascript

    app.use dispatch 'GET /app.js' : (req, res, next) ->
      clientCompiler (err, js) ->
        if err then next err ; return
        res.setHeader 'Content-Type', 'text/javascript'
        res.end js

    clientCompiler = require './client-compiler'

A GET to `/app.css` renders the application's css

    app.use dispatch 'GET /app.css' : (req, res, next) ->
      send(req, 'app.css').pipe res

We have two routes for dealing with data, a GET to `/data.json` returns the
historical contents of the item as a list of strings encoded in JSON. A POST
to `/` parses out the updated value, save it then renders the UI

    db = require './db'

    app.use dispatch 'POST /' : connect urlencodedBody, (req, res, next) ->
      {item} = req.body
      db.saveData item, (err) ->
        if err then next err ; return
        res.setHeader 'Content-Type', 'text/json'
        res.end JSON.stringify {item}

    app.use dispatch 'GET /data.json' : (req, res, next) ->
      db.loadData (err, data) ->
        if err then next err ; return
        res.setHeader 'Content-Type', 'text/json'
        res.end JSON.stringify data

Create a web server, pass the connect chain to it and start listening on a port

    port = process.env.PORT ? 3000
    server = http.createServer app
    server.listen port, -> console.log "app running on port #{port}"

* * *

Alias to enhance readability

    noErr = null
