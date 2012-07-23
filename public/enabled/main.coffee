"use strict"

jQuery ->

    [pass, fail] = ["#090","#900"]

    elem = $("#webkit")
    if typeof window.webkitAudioContext != "undefined"
        ctx = new webkitAudioContext()
        elem.text("✔").parent().css("color", pass)
        $("#webkit-sr").text(ctx.sampleRate)
    else elem.text("✖").parent().css("color", fail)

    elem = $("#moz")
    if typeof Audio is "function" and typeof (new Audio).mozSetup is "function"
        elem.text("✔").parent().css("color", pass)
        $("#moz-sr").text("mozSetup")
    else elem.text("✖").parent().css("color", fail)

    $("#contents").animate({opacity:1}, 500)
