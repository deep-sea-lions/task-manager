# Phase 4, Challenge 1

Install node.js (nodejs.org) then run `make serve` from the command line.

Node.js processes start quickly with the minimum of capabilities. By default
they can't talk to a web browser. In fact, unlike Ruby processes they can't even
talk to the filesystem.

For this challenge we need three modules from the standard library.

The `fs` module for reading and writing files

```coffeescript
fs = require 'fs'
```

The `http` module allows us to talk the HTTP protocol to other programs

```coffeescript
http = require 'http'
```

Programs that talk HTTP usually encode information in the querystring format
(e.g. `item=%22foo+bar%22`)

```coffeescript
querystring = require 'querystring'
```

We also load CoffeeScript (from npm, node's rubygems equivalent) so we can
write our front end code in CS then compile it to JS before sending it to the
client.

```coffeescript
cs = require 'coffee-script'
```

Start a web server that responds to two conditions

```coffeescript
server = http.createServer (req, res) ->
  res.setHeader 'Content-Type', 'text/html'
```

If the request is a post then parse out the updated value, save it then render
the UI

```coffeescript
  if req.method is 'POST'
    body = ''
    req.on 'data', (data) -> body += data
    req.on 'end', ->
      data = querystring.parse body
      saveData data, (err) ->
        throw err if err?
        renderUI (err, html) ->
          throw err if err?
          res.end html
```

Otherwise just render the UI

```coffeescript
  else
    renderUI (err, html) ->
      throw err if err?
      res.end html
```

The item's contents are stored in a text file, `saveData` takes a
`{ item: 'contents of item' }` data structure and `loadData` returns one.

```coffeescript
dataFile = './item.txt'

saveData = (data, cb) ->
  fs.writeFile dataFile, data.item, 'utf8', cb

loadData = (cb) ->
  fs.readFile dataFile, 'utf8', (err, itemData) ->
    return cb err if err?
    cb noErr, item: itemData.trim()
```

The HTML UI is made up of the DOM template, the `{ item: 'contents of item' }`
data structure (stashed in a script tag) and some frontend code to load the data
into the template.

```coffeescript
renderUI = (cb) ->
  loadData (err, data) ->
    return cb err if err?
    cb noErr, template + (renderAppData data) + appFrontend

template = """<form method="post"><input name="item"></form>"""

renderAppData = (data) ->
  '<script data-app-data type="text/json">' +
    (JSON.stringify data) +
  '</script>'
```

The frontend code is written in CoffeeScript then compiled to JS and wrapped
in a script tag

```coffeescript
appFrontend = cs.compile """
  appData = JSON.parse document.querySelector('[data-app-data]').innerHTML
  itemEl = document.querySelector '[name=item]'
  itemEl.value = appData.item
  itemEl.focus()
"""

appFrontend = '<script>' + appFrontend + '</script>'
```

Hook the server up to a port and start listening for requests

```coffeescript
port = process.env.PORT ? 3000
server.listen port, -> console.log "app running on port #{port}"
```

Alias to enhance readability

    noErr = null

