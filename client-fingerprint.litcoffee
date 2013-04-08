# Client Fingerprint

The idea behind a "fingerprint" is to find some cheap way to check if something
has changed so you don't have to do a "full body scan".

The UI code that's sent to the browser is built from a number of source files.
There's the HTML template, the `client.litcoffee` and it's depdencies, and (for
now) the actual compilation process happens in `app.litcoffee`.

So we make the client fingerprint the output of concatenating the modification
times of all the relevant sources files and then passing that through a hash
function.

    module.exports = clientFingerprint = (cb) ->
      map relevantSourceFiles, stat, (err, stats) ->
        return cb err if err?
        mtimes = (s.mtime for s in stats)
        cb noErr, sha1 mtimes.join "\n"

The filename list to map over

    relevantSourceFiles = [
      'template.html'      # app's html
      'app.litcoffee'      # compilation process here
      'client.litcoffee'   # frontend code
      'reqwest.js'         # frontend dependency
    ]

A function for getting file "stats" - from node's fs module

    {stat} = require 'fs'

We also import node's crypto library to get at its hasing capabilities. While
hashing functions are frequently used outside of cryptography, node probably
includes them in this module because the node implementation wraps the lower
level OpenSSL C library which is generally referred to as a "crypto" library
because that's it's primary use.

    crypto = require 'crypto'

This library has an awkward api so we wrap these innards in a function that
returns the hex digest shasum for it's string argument

    sha1 = (str) -> crypto.createHash('sha1').update(str).digest 'hex'

An implementation of parallel map - from the `async` node module

    {map} = require 'async'

Convinent alias

    noErr = null

## Test

While this app is certainly not "test driven", this module is a perfect
candidate for an isolated test.

This line says "only run this code if this file is the first argument passed
to the `coffee` command" - i.e. this code won't run in the app, it'll only run
if you type `coffee client-fingerprint.litcoffee` from the command line.

    if __filename is process.argv[1]

Node's assertion library

      assert = require 'assert'

Node's shell command execution method

      {exec} = require 'child_process'

We make a fingerprint then change the mtime of `client.litcoffee` then make
another fingerprint and check that they aren't the same

      clientFingerprint (err, fp1) ->
        throw err if err?
        exec "touch client.litcoffee", (err) ->
          throw err if err?
          clientFingerprint (err, fp2) ->
            throw err if err?
            assert fp1 isnt fp2
