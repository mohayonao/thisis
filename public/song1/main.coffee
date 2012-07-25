jQuery ->

    timbre.utils.exports "random.choice", "atof"

    voice = []
    wav = T("wav", "biwako2012.wav")
    wav.onloadeddata = (e)->
        dt = 217.3913043478261 # bpm2msec(138, 8)
        muls = [1.5, 1.5, 1.5, 1.5, 2, 4, 2, 0]
        voice[i] = wav.slice(dt * i, dt * (i + 1)).set(mul:muls[i]) for i in [0...8]
    wav.load()


    # vocal
    vocal_dac = T("dac").set(pan:0.3)
    vocal = T("mml", "t138 o3 q4 l8 $ @1 eeer eeer @6 eeee eerr")
    vocal.synth = T("rhpf", T("tri", 2, 200, 1320).kr(), 0.7).appendTo vocal_dac
    vocal.index = 0
    vocal.random = false
    vocal.synthdef = (freq, opts)->
        synth = T("*", 0, T("sin", 660).kr())
        synth.keyon  = (opts)->
            i = if vocal.random then (Math.random() * 4)|0 else vocal.index
            synth.args[0] = voice[i].bang() if voice[i]
            vocal.index = (vocal.index + 1) % 3
        synth
    vocal.onexternal = (opts)->
        vocal.random = Math.random() < (opts.value / 12) if opts.cmd is "@"
    vocal_dac.buddy "play", vocal, "on"


    # fue
    fue_dac = T("dac").set(pan:T("+sin", 0.05))
    rndfreq = [ atof("G2"), atof("A2"), atof("A2"), atof("C3"), atof("D3") ]
    fue = T("mml", "t138 q6 o4 $ l4 a<cc>a <el8dedc>ag a4aga<cc4> a4aga<ee4>")
    fue.synth = T("efx.reverb").appendTo fue_dac
    fue.synthdef = (freq, opts)->
        synth = T("*", T("osc", "wavc(0080a0c0)", T("osc", "sin(5)", 4, 2, freq).kr(), 0.25),
                       T("adsr", "24db", 25, 1500, 0.8, 250))
        synth.keyon  = (opts)->
            r = Math.random()
            if      r < 0.15 then _freq = choice rndfreq
            else if r > 0.75 then _freq = freq
            else _freq = 0
            synth.args[0].freq.add = _freq if _freq > 0
            synth.args[1].bang()
        synth.keyoff = (opts)->
            synth.args[1].keyoff()
        synth
    fue_dac.buddy "play", fue, "on"


    # bass
    bass_dac = T("dac")
    bass = T("mml", "t138 o2 l8 $ [aarr | ggrr]4 gg<cc>")
    bass.synth = T("+").appendTo bass_dac
    bass.synthdef = (freq, opts)->
        synth = T("*", T("clip", T("osc", "sin(@1)", freq * 2, 4)).set(mul:0.5),
                       T("adsr", "24db", 25, 150, 0.8, 50))
        synth.keyon  = (opts)-> synth.args[1].bang()
        synth.keyoff = (opts)-> synth.args[1].keyoff()
        synth
    bass_dac.buddy "play", bass, "on"


    # drum
    drum_dac = T("dac")
    drum = T("mml", "t138 l8 $ g0c g+ g0c0e g+")
    drum.synth = T("efx.comp", 0.1, 1/40, 5).set(mul:0.75).appendTo drum_dac
    drum.synthdef = (freq, opts)->
        synth = switch opts.tnum
            when 60 then T("*", T("rbpf", 80, 0.8, T("osc", "sin(@3)", 20)), T("perc", "32db", 100))
            when 64 then T("*", T("bpf", 1600, T("pink" , 0.25)), T("perc", "24db", 150))
            when 67 then T("*", T("hpf", 6400, T("noise", 0.15)), T("perc", "24db", 50))
            when 68 then T("*", T("hpf", 8800, T("noise", 0.15)), T("perc", "24db", 200))
            else T("*", T("noise", 0.6), T("perc", "24db", 250))
        synth.keyon  = (opts)-> synth.args[1].bang()
        synth
    drum_dac.buddy "play", drum, "on"


    # taiko & suzu
    stuff_dac = T("dac").set(mul:0.75)
    stuff = T("mml", "t138 l8 $ g0crcr crre g0ccrc crer l16g0ccccccccl8cc g0rcec gcee")
    stuff.synth = T("efx.comp", 0.2, 1/40, 2).set(mul:0.75).appendTo stuff_dac
    stuff.synthdef = (freq, opts)->
        synth = switch opts.tnum
            when 60 then voice[4]
            when 64 then voice[5]
            when 67 then voice[6]
        synth.keyon = (opts)-> synth.bang()
        synth
    stuff_dac.buddy "play", stuff, "on"


    # master
    buddies = [ vocal_dac, fue_dac, bass_dac, drum_dac, stuff_dac ]
    master = T("+")
    master.buddy "play" , buddies
    master.buddy "pause", buddies
    master.isPlaying = false

    # description
    desc = switch timbre.env
        when "webkit" then "timbre.js on Web Audio API"
        when "moz"    then "timbre.js on Audio Data API"
        else "Please open with Chrome or Firefox"
    $("#desc").text desc

    # UI
    $("#play").on "click", ->
        if not master.isPlaying
            master.play()
            master.isPlaying = true

    $("#pause").on "click", ->
        if master.isPlaying
            master.pause()
            master.isPlaying = false
