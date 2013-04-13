# Client (Browser) Code

We use the `domready` module for capturing the domready event and the `reqwest`
module for ajax.

    domready = require 'domready'
    reqwest  = require 'reqwest'

Load the data then render the UI

    domready ->
      loadData (err, appData) ->
        (console.error "failed to retreive app data", err ; return) if err
        itemValue   = last appData
        itemHistory = allButLast appData

        renderItemView (document.querySelector '[name=item]'), itemValue
        renderHistoryView (document.querySelector '.historical-contents'),
          itemHistory

The UI is composed of two views: the item viewer/editor and the historical
contents list.

    renderItemView = (el, itemValue) ->
      el.value = itemValue
      el.focus()

    renderHistoryView = (el, itemHistory) ->
      for item in itemHistory.reverse()
        historyItemEl = document.createElement 'li'
        historyItemEl.innerText = item
        el.appendChild historyItemEl

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
