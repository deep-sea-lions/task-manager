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

Create the connect chain

    app = connect()

A GET on the root url renders the UI

    app.use (req, res, next) ->
      return next() unless req.url is '/' and req.method is 'GET'
      res.setHeader 'Content-Type', 'text/html'

      renderUI (err, html) ->
        return next err if err?
        res.end html

A POST parses out the updated value, save it then renders the UI

    app.use (req, res, next) ->
      return next() unless req.url is '/' and req.method is 'POST'
      res.setHeader 'Content-Type', 'text/html'

      body = ''
      req.on 'data', (data) -> body += data
      req.on 'end', ->
        {item} = querystring.parse body
        saveData item, (err) ->
          return next err if err?
          renderUI (err, html) ->
            return next err if err?
            res.end html

A GET to `/data.json` returns the historical contents of the item as a list
of strings encoded in JSON

    app.use (req, res, next) ->
      return next() unless req.url is '/data.json' and req.method is 'GET'
      res.setHeader 'Content-Type', 'text/json'

      loadData (err, data) ->
        return next err if err?
        res.end JSON.stringify data

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

The HTML UI is made up of the DOM template and some frontend code to load
the data into the template.

    renderUI = (cb) ->
      loadData (err, data) ->
        return cb err if err?
        cb noErr, [ template, appFrontend ].join "\n"

    template = fs.readFileSync 'template.html'

The frontend code is written in CoffeeScript then compiled to JS and wrapped
in a script tag

    reqwest = fs.readFileSync 'reqwest.js', 'utf8'
    appCS   = fs.readFileSync 'client.litcoffee', 'utf8'
    appJS   = cs.compile appCS, literate: yes
    appJS   = [ reqwest, appJS ].join ";\n"
    appFrontend = [ '<script>', appJS, '</script>' ].join "\n"

Create a web server, pass the connect chain to it and start listening on a port

    port = process.env.PORT ? 3000
    server = http.createServer app
    server.listen port, -> console.log "app running on port #{port}"

* * *

Alias to enhance readability

    noErr = null
