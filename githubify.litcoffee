Converts literate coffee into markdown that github will syntax highlight
correctly. Regex taken from [Journo Cakefile]

    console.log require('fs').
      readFileSync('/dev/stdin', 'utf8').
      replace /\n\n    ([\s\S]*?)\n\n(?!    )/mg, (match, code) ->
        "\n\n```coffeescript\n#{code.replace(/^    /mg, '')}\n```\n\n"

[Journo Cakefile]:https://github.com/jashkenas/journo/blob/master/Cakefile
