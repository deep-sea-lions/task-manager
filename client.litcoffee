# Client (Browser) Code

We use the `domready` module for capturing the domready event and the `reqwest`
module for ajax.

    domready = require 'domready'
    reqwest  = require 'reqwest'

And a slightly customized version of backbone

    backbone = require './backbone.litcoffee'

Start the app on when the domready event fires

    domready -> do init

The app's initialization process - load the data then render the UI

    init = ->
      loadData (err, appData) ->
        if err then initError err ; return

        itemValue   = last appData
        itemHistory = allButLast appData

        itemView = new ItemView
          el: document.querySelector '.item-editor'
        itemView.render itemValue

        itemHistoryView = new ItemHistoryView
          el: document.querySelector '.historical-contents'
        itemHistoryView.render itemHistory

        document.body.className = 'loaded'

The error handler for errors that occur during initialization. Needs UX love.

    initError = (err) ->
      document.body.className = 'error'

The UI is composed of two views: the item viewer/editor and the historical
contents list.

    class ItemView extends backbone.View

      events:
        'submit' : 'update'

      update: (event) ->
        event.preventDefault()
        newItemValue = @inputEl().val()
        reqwest
          url: '/'
          method: 'POST'
          data: item: newItemValue
          type: 'json'
          error: networkError
          success: (response) -> window.location.reload()

      inputEl: -> @$ '[name=item]'

      render: (itemValue) ->
        inputEl = @el.querySelector '[name=item]'
        inputEl.value = itemValue
        inputEl.focus()

    class ItemHistoryView extends backbone.View

      render: (itemHistory) ->
        @el.innerHTML = ''
        for item in itemHistory.reverse()
          historyItemEl = document.createElement 'li'
          historyItemEl.innerText = item
          @el.appendChild historyItemEl

Loads the app's data from the server

    loadData = (cb) ->
      reqwest
        url: '/data.json'
        error: (err) -> cb err
        success: (response) -> cb noErr, response

A handler called when an error occurs during a networking (ajax) call. Need
better UX here.

    networkError = (err) ->
      console.error 'Network Error:', err

## Some helpers

Get the last item from a list

    last = (list) -> list.slice(-1)[0]

Get everything but the last item

    allButLast = (list) -> list.slice(0,-1)

Useful alias

    noErr = null
