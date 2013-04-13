# Client (Browser) Code

We use the `domready` module for capturing the domready event and the `reqwest`
module for ajax.

    domready = require 'domready'
    reqwest  = require 'reqwest'

Load the data then render the UI

    domready ->
      loadData (err, appData) ->
        (console.error "failed to retreive app data", err ; return) if err

        itemEl = document.querySelector '[name=item]'
        itemEl.value = last appData
        itemEl.focus()

        historyEl = document.querySelector '.historical-contents'
        for item in (allButLast appData).reverse()
          historyItemEl = document.createElement 'li'
          historyItemEl.innerText = item
          historyEl.appendChild historyItemEl

Loads the app's data from the server

    loadData = (cb) ->
      reqwest
        url: '/data.json'
        error: (err) -> cb err
        success: (response) -> cb noErr, response


## Some helpers

Get the last item from a list

    last = (list) -> list.slice(-1)[0]

Get everything but the last item

    allButLast = (list) -> list.slice(0,-1)

Useful alias

    noErr = null
