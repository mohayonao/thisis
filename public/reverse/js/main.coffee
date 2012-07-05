"use strict"

jQuery ->
    synth = T("buffer").set(loop:true, reversed:true).play()

    ctx  = new webkitAudioContext()

    $body = $ document.body
    $body.on "dragover", (e)->
        e.preventDefault()
        e.stopPropagation()

    $body.on "drop", (e)->
        e.preventDefault()
        e.stopPropagation()

        file = e.originalEvent.dataTransfer.files[0]

        reader = new FileReader()
        reader.onload = (e)->
            try
                buffer = ctx.createBuffer(e.target.result, true).getChannelData 0
                synth.buffer = buffer
                $("#text").text "逆再生します."
            catch e
                $("#text").text "再生できないファイルです."
        reader.readAsArrayBuffer file

    if timbre.env is "webkit"
        $("#text").text "ドラッグ & ドロップで逆再生します."
    else
        $("#text").text "Chrome で開いてね!!"
