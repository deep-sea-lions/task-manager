A list of urls that the browser should serve straight from it's cache _before_
asking the server if updates are available. The browser will still request this
list (if the app is online) and if the contents have changed in any way it will
re-download every url in this list then trigger an event.

The "client fingerprint" comment is a string is guaranteed to change every
time one of the files used to build any url in this list changes.

    clientFingerprint = require './client-fingerprint'

    module.exports = clientManifest = (cb) ->
      clientFingerprint (err, fingerprint) ->
        if err then cb err ; return
        cb noErr, """
        CACHE MANIFEST
        CACHE:
        /
        /app.js
        /app.css
        NETWORK:
        *
        # client fingerprint: #{fingerprint}
        """

    noErr = null
