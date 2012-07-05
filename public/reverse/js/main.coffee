"use strict"

jQuery ->
    synth = T("buffer").set(loop:true, reversed:true).play()

    ctx = null

    $body = $ document.body
    $body.on "dragover", (e)->
        e.preventDefault()
        e.stopPropagation()

    $body.on "drop", (e)->
        e.preventDefault()
        e.stopPropagation()

        return if ctx is null

        reader = new FileReader()
        reader.onload = (e)->
            try
                buffer = ctx.createBuffer(e.target.result, true).getChannelData 0
                synth.buffer = buffer
                $("#text").text "逆再生を開始します."
                setTimeout ->
                    $("#text").text "音楽ファイルをドラッグ & ドロップすると逆再生します."
                , 5000
            catch e
                $("#text").text "再生できないファイルです."
        reader.readAsArrayBuffer e.originalEvent.dataTransfer.files[0]

    if timbre.env is "webkit"
        ctx = new webkitAudioContext()
        $("#text").text "音楽ファイルをドラッグ & ドロップすると逆再生します."
    else
        $("#text").text "Chrome で開いてね!!"
