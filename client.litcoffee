# Client (Browser) Code

## Some helpers

Get the last item from a list

    last = (list) -> list.slice(-1)[0]

Get everything but the last item

    allButLast = (list) -> list.slice(0,-1)

## The App

Load the app data and render the UI

    appData = JSON.parse document.querySelector('[data-app-data]').innerText
    itemEl = document.querySelector '[name=item]'
    itemEl.value = last appData
    itemEl.focus()

    historyEl = document.querySelector '.historical-contents'
    for item in (allButLast appData).reverse()
      historyItemEl = document.createElement 'li'
      historyItemEl.innerText = item
      historyEl.appendChild historyItemEl
