# The "database"

Right now this is just lines in a flat file. The last line represents the
current state of the item. Lines above it represent previous states.

    fs = require 'fs'

    module.exports = db = {}

    db.saveData = (data, cb) ->
      fs.appendFile dataFile, data + "\n", 'utf8', cb

    db.loadData = (cb) ->
      fs.readFile dataFile, 'utf8', (err, data) ->
        return cb err if err?
        lines = data.trim().split "\n"
        cb noErr, lines

    dataFile = './item.txt'

    noErr = null
