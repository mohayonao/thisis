jQuery ->
    timbre.utils.exports "mtof"

    tarai = (x, y, z)->
        tarai.result.push([x, y, z])
        if x <= y then y
        else tarai tarai(x-1, y, z), tarai(y-1, z, x), tarai(z-1, x, y)
    tarai.result = []
    tarai.index  =  0

    tarai(10, 5, 0)


    dorian = [ 0, 2, 3, 5, 7, 9, 10 ]
    dorian.degreeToFreq = (degree, rootFreq, octave)->
        i = dorian[degree % dorian.length] + ((degree / dorian.length)|0) * 12
        rootFreq * Math.pow(2, i / 12)

    scale   = ( dorian.degreeToFreq(i, mtof(62+12), 1) for i in [0...20] )
    pattern = [ 0,0,1,1,2,2,1,1,0,0,1,1,2,2,1,1 ]
    car     = []
    synth   = T("rhpf").set({wet:0.6})

    timer = T("interval", 110, ->
        count = timer.count % 16

        if count is 0
            car = tarai.result[tarai.index++]
            car.sort (a, b)-> a - b

        i = car[pattern[count]]
        freq = scale[i+1]
        freq /= 2 if count % 2 is 1

        T("*", T("+", T("saw", freq * 0.996, 0.25),
                      T("saw", freq * 1.004, 0.25)),
               T("perc", "24db", 500).bang()).appendTo(synth)

        synth.args.shift() if synth.args.length > 4
        master.pause()     if count is 15 and tarai.result.length is tarai.index
    )

    master = T("efx.delay", 200, 0.75, synth)
    master.isPlaying = false
    master.onplay  = -> timer.on()
    master.onpause = -> timer.off()


    $(window).on "mousemove", (e)->
        x = e.pageX / window.innerWidth
        y = e.pageY / window.innerHeight
        synth.cutoff = (1 - (y * y)) * 8000 + 400
        synth.Q      = x * x

    $("#play").on "click", ->
        if not master.isPlaying
            tarai.index = 0
            master.play()
            master.isPlaying = true

    $("#pause").on "click", ->
        if master.isPlaying
            master.pause()
            master.isPlaying = false
