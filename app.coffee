http        = require 'http'
fs          = require 'fs'
querystring = require 'querystring'

cs = require 'coffee-script'

server = http.createServer (req, res) ->
  res.setHeader 'Content-Type', 'text/html'

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
  else
    renderUI (err, html) ->
      throw err if err?
      res.end html

dataFile = './item.txt'

saveData = (data, cb) ->
  fs.writeFile dataFile, data.item, 'utf8', cb

loadData = (cb) ->
  fs.readFile dataFile, 'utf8', (err, itemData) ->
    return cb err if err?
    cb noErr, item: itemData.trim()

renderUI = (cb) ->
  loadData (err, data) ->
    return cb err if err?
    cb noErr, template + (renderAppData data) + appFrontend

template = """<form method="post"><input name="item"></form>"""

renderAppData = (data) ->
  '<script data-app-data type="text/json">' +
    (JSON.stringify data) +
  '</script>'

appFrontend = cs.compile """
  appData = JSON.parse document.querySelector('[data-app-data]').innerHTML
  itemEl = document.querySelector '[name=item]'
  itemEl.value = appData.item
  itemEl.focus()
"""

appFrontend = '<script>' + appFrontend + '</script>'

port = 3000
server.listen 3000, -> console.log "app running on port #{port}"

noErr = null
