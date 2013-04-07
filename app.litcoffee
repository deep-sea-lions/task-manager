# Phase 4, Challenge 1

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

Start a web server that responds to two conditions

    server = http.createServer (req, res) ->
      res.setHeader 'Content-Type', 'text/html'

If the request is a post then parse out the updated value, save it then render
the UI

      if req.method is 'POST'
        body = ''
        req.on 'data', (data) -> body += data
        req.on 'end', ->
          {item} = querystring.parse body
          saveData item, (err) ->
            throw err if err?
            renderUI (err, html) ->
              throw err if err?
              res.end html

Otherwise just render the UI

      else
        renderUI (err, html) ->
          throw err if err?
          res.end html

The item's contents are stored in a text file, `saveData` takes a
`{ item: 'contents of item' }` data structure and `loadData` returns one.

    dataFile = './item.txt'

    saveData = (data, cb) ->
      fs.appendFile dataFile, data + "\n", 'utf8', cb

    loadData = (cb) ->
      fs.readFile dataFile, 'utf8', (err, data) ->
        return cb err if err?
        lines = data.trim().split "\n"
        cb noErr, lines

The HTML UI is made up of the DOM template, the `{ item: 'contents of item' }`
data structure (stashed in a script tag) and some frontend code to load the data
into the template.

    renderUI = (cb) ->
      loadData (err, data) ->
        return cb err if err?
        cb noErr, template + (renderAppData data) + appFrontend

    template = fs.readFileSync 'template.html'

    renderAppData = (data) ->
      '<script data-app-data type="text/json">' +
        (JSON.stringify data) +
      '</script>'

The frontend code is written in CoffeeScript then compiled to JS and wrapped
in a script tag

    appFrontend = cs.compile fs.readFileSync 'client.coffee'
    appFrontend = '<script>' + appFrontend + '</script>'

Hook the server up to a port and start listening for requests

    port = process.env.PORT ? 3000
    server.listen port, -> console.log "app running on port #{port}"

* * *

Alias to enhance readability

    noErr = null
