jQuery ->
    timbre.utils.exports "random.choice"

    # Pad
    pad_dac = T("rlpf", T("pulse", timbre.utils.bpm2hz(120, 4), 400, 1200).kr(), 0.95, 0.6)
    pad_pattern = [
        "o4 l16 [a<a>a<a> a<a->a<a->]2", "o4 l16 [a<a>a<a> a<a->a<a->]2"
        "o5 l16 [d-ad-a d-a-d-a-]2"
    ]
    pad = T("mml", pad_pattern)
    pad.index = 0
    pad.tnum1 = 0
    pad.tnum2 = 0
    pad.synth = T("+").appendTo pad_dac
    pad.synthdef = (freq, opts)->
        synth = T("*", T("+", T("osc", "tri(80)", freq - 2, 0.5),
                              T("osc", "tri(20)", freq + 2, 0.4)),
                       T("perc", "24db", 500))
        synth.keyon = (opts)->
            synth.args[1].set(mul:opts.volume/16).bang()
        synth
    pad.onended = ->
        pad.set(selected:(Math.random() * pad_pattern.length)|0).bang()
    pad_dac = T("efx.delay", 125, 0.6, 0.5, pad_dac)


    # drum
    drum_dac = T("efx.dist", 2, -18, 3200).set(mul:0.8)

    # BD
    BD = T("mml", [
        "c4r2."
        "c4r2r8c8"
        "c4r4c4r4"
        "c4r4c4r8c8"
    ])
    BD.synth = T("clip").set(mul:2).appendTo drum_dac
    BD.synthdef = (freq, opts)->
        synth = T("*", T("rbpf", 80, 0.8, T("osc", "sin(@3)", 20)),
                       T("perc", "32db", 100))
        synth.keyon = (opts)-> synth.args[1].set(mul:opts.volume/16).bang()
        synth
    BD.onended = ->
        BD.set(selected:choice [0, 0, 1, 2, 3]).bang()

    # SD
    SD = T("mml", [
        "r4c4r4c4"
        "r8v2c8v8c4r4c4"
        "r4c4r4r8v6c8v8"
    ])
    SD.synth = T("efx.comp", 0.2, 1/60, 5).appendTo drum_dac
    SD.synthdef = (freq, opts)->
        synth = T("*", T("hpf", 3200, T("pink" , 0.15)),
                       T("perc", "48db", 400))
        synth.keyon = (opts)-> synth.args[1].set(mul:opts.volume/16).bang()
        synth
    SD.onended = ->
        SD.set(selected:choice [0, 0, 0, 1, 1, 2, 2]).bang()

    # SD2
    SD2 = T("mml", [
        "r8c8c8.c16r4c8c8"
        "r8v2c8v8c4r4c8c8"
        "r8c8c16c16r8r4r8v6c16c16v8"
    ])
    SD2.synth = T("efx.delay").appendTo drum_dac
    SD2.synthdef = (freq, opts)->
        synth = T("*", T("rlpf", 1200, 0.8, 0.9, T("fnoise", 350, 0.2)),
                       T("perc", "24db", 80))
        synth.keyon = (opts)-> synth.args[1].set(mul:opts.volume/16).bang()
        synth
    SD2.onended = ->
        SD2.set(selected:choice [0, 0, 1, 2]).bang()

    # HH
    HH = T("mml", [
        "l16 rccc rccc"
        "l16 rccc32v4c32v8 rccc32v4c32v8"
        "l8 cc cc"
    ])
    HH.synth = T("efx.comp", 0.1, 1/80, 3).appendTo drum_dac
    HH.synthdef = (freq, opts)->
        synth = T("*", T("hpf", 7200, T("noise", 0.15)),
                       T("perc", "24db", 60))
        synth.keyon = (opts)-> synth.args[1].set(mul:opts.volume/16).bang()
        synth
    HH.onended = ->
        HH.set(selected:choice [0, 1, 2]).bang()


    # master
    buddies = [pad, BD, SD, SD2, HH]
    master = T("+", pad_dac, T("efx.reverb", 400, 0.1, drum_dac))
    master.buddy "play" , buddies, "on"
    master.buddy "pause", buddies, "off"
    master.isPlaying = false


    # description
    desc = switch timbre.env
        when "webkit" then "timbre.js on Web Audio API"
        when "moz"    then "timbre.js on Audio Data API"
        else "Please open with Chrome or Firefox"
    $("#desc").text desc

    # UI
    $("#btn").on "click", ->
        if master.isPlaying
            master.pause()
            $("#btn-img-pause").hide()
            $("#btn-img-play" ).show()
            master.isPlaying = false
        else
            master.play()
            $("#btn-img-play" ).hide()
            $("#btn-img-pause").show()
            master.isPlaying = true
