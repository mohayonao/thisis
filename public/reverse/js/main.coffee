"use strict"

if navigator.language is "ja"
    Message = {
        openWithChrome: "Chrome で開いてね!!"
        dragAndDropToPlay: "音楽ファイルをドラッグ & ドロップすると再生します."
        play: "再生を開始します."
        cannotPlay: "再生できないファイルです."
    }
else
    Message = {
        openWithChrome: "Please open with Chrome"
        dragAndDropToPlay: "Drag & drop an audio file to play"
        play: "Play"
        cannotPlay: "Cannot play"
    }

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
                $("#text").text Message.play
                setTimeout ->
                    $("#text").text Message.dragAndDropToPlay
                , 5000
            catch e
                $("#text").text Message.cannotPlay
        reader.readAsArrayBuffer e.originalEvent.dataTransfer.files[0]

    if timbre.env is "webkit"
        ctx = new webkitAudioContext()
        $("#text").text Message.dragAndDropToPlay
    else
        $("#text").text Message.openWithChrome
