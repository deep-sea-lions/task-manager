Converts literate coffee into markdown that github will syntax highlight
correctly. Regex taken from [Journo Cakefile]. This code is not run in the
actual application. It's just something used to build the README.md

    console.log require('fs').
      readFileSync('/dev/stdin', 'utf8').
      replace /\n\n    ([\s\S]*?)\n\n(?!    )/mg, (match, code) ->
        "\n\n```coffeescript\n#{code.replace(/^    /mg, '')}\n```\n\n"

[Journo Cakefile]:https://github.com/jashkenas/journo/blob/master/Cakefile
