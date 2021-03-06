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
    synth = T("audio").set(loop:true, reversed:true).play()
    synth.onloadedmetadata = ->
        $("#text").text Message.play
        setTimeout ->
            $("#text").text Message.dragAndDropToPlay
        , 5000
    synth.onerror = (e)->
        $("#text").text Message.cannotPlay

    $body = $ document.body
    $body.on "dragover", (e)->
        e.preventDefault()
        e.stopPropagation()

    $body.on "drop", (e)->
        e.preventDefault()
        e.stopPropagation()

        file = e.originalEvent.dataTransfer.files[0]
        synth.set(src:file).load()

    if timbre.env is "webkit"
        $("#text").text Message.dragAndDropToPlay
    else
        $("#text").text Message.openWithChrome
