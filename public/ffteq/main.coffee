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

requestAnimationFrame = window.requestAnimationFrame or
        window.webkitRequestAnimationFrame or
        window.mozRequestAnimationFrame    or
        window.oRequestAnimationFrame      or
        window.msRequestAnimationFrame     or
        (f)->setTimeout(f, 1000/60)

jQuery ->
    EQ_SIZE = 64
    EQ_Params = new Float32Array(EQ_SIZE)

    AcmeFFT = (n)->
        @size   = 1024
        @source = T("audio").set(loop:true)
        @source.onloadedmetadata = (e)=> @onloadedmetadata e
        @source.onerror          = (e)=> @onerror e
        @fft    = new timbre.utils.FFT(@size)
        @buffer = new Float32Array(@size)
        @index  = 0
        @

    AcmeFFT.prototype.setFile = (file)->
        @source.set({src:file}).load()
        @

    AcmeFFT.prototype.seq = (seq_id)->
        _ = @_

        if _.seq_id != seq_id
            _.seq_id = seq_id

            fft = @fft
            res = @source.seq(seq_id)

            for i in [0...res.length]
                @buffer[@index + i] = res[i]

            res  = fft.buffer

            cell = @cell
            for i in [0...cell.length]
                cell[i] = res[@index + i]

            @index += timbre.cellsize
            if @index is @size
                @index = 0
                fft.forward @buffer

                real = fft.real
                imag = fft.imag

                # ここでスペクトルをいじる
                n  = real.length
                nn = n >> 1
                dx = timbre.samplerate / nn / 2
                di = EQ_SIZE / @size
                dd = nn / EQ_SIZE

                for i in [0...nn]
                    j = n - i - 1
                    x = i * dx
                    if x < 8000
                        x = x / 8000 * EQ_SIZE
                        index = x|0
                        delta = x - index
                        x0 = index
                        x1 = index + 1
                        x0 = EQ_Params[x0]
                        x1 = EQ_Params[x1]
                        x1 = x0 if x1 is undefined
                        x = (1.0 - delta) * x0 + delta * x1;
                    else
                        x = EQ_Params[EQ_SIZE-1]
                    real[i] *= x
                    imag[i] *= x
                    real[j] *= x
                    imag[j] *= x
                fft.inverse real, imag
        @cell
    timbre.fn.register("acme", AcmeFFT)

    synth = T("acme").play()
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
        synth.setFile file

    if timbre.env is "webkit"
        $("#text").text Message.dragAndDropToPlay
    else
        $("#text").text Message.openWithChrome


    $canvas = $("#canvas")
    animate = ->
        list = EQ_Params
        w = $canvas.width()
        h = $canvas.height()
        context = $canvas.get(0).getContext "2d"

        context.save()
        context.fillStyle = "rgba(255, 255, 255, 0.2)"
        context.fillRect 0, 0, w, h

        context.fillStyle = "rgba(  0, 128, 255, 0.8)"

        dx = w / list.length
        for i in [0...list.length]
            x = i * dx
            y = h * list[i]
            context.fillRect(x, h - y, dx, y)
        context.restore()

        requestAnimationFrame animate

    $canvas.get(0).width  = $canvas.width()
    $canvas.get(0).height = $canvas.height()

    mouseFunction = (e, change)->
        e.preventDefault()
        offset = $canvas.offset()
        x = (e.pageX - offset.left) / $canvas.width()
        y = (e.pageY - offset.top ) / $canvas.height()
        if x < 0 then x = 0
        else if x > 1 then x = 0.999
        if y < 0 then y = 0
        else if y > 1 then y = 1

        if change
            EQ_Params[(x * EQ_SIZE)|0] = 1 - y
        x = (x * 8000)|0
        y = 1 - y
        $("#status").text "#{x}Hz / #{y.toFixed(2)}"

    $("#control").on "mousedown", (e)->
        $canvas.isMousedown = true
        mouseFunction e, true
    $("#control").on "mousemove", (e)->
        mouseFunction e, $canvas.isMousedown
    $("#control").on "mouseup"  , (e)->
        mouseFunction e, true
        $canvas.isMousedown = false

    $("#1_0").on "click", (e)->
        do -> EQ_Params[i] = 1.0 for i in [0...EQ_SIZE]
        $canvas.draw EQ_Params
    $("#0_0").on "click", (e)->
        do -> EQ_Params[i] = 0.0 for i in [0...EQ_SIZE]
        $canvas.draw EQ_Params

    sparse = ->
        x = (Math.random() * EQ_SIZE)|0
        sparse.data.push x
        EQ_Params[x] = 1

        if sparse.data.length > sparse.size
            x = sparse.data.shift()
            EQ_Params[x] = 0
        for i in [0...sparse.size - 1]
            EQ_Params[sparse.data[i]] = i / (sparse.size - 1)

    sparse.size = 16
    sparse.data = []

    timer = T("interval", 50, sparse)
    $("#sparse-play").on "click", (e)->
        if timer.isOn
            timer.off()
            $(this).css("color", "black").text("sparse-play")
        else
            timer.on()
            $(this).css("color", "red").text("sparse-pause")

    r = Math.random()
    if r < 0.2
        do -> EQ_Params[i] = 1 for i in [0...EQ_SIZE]
    else if r < 0.4
        do -> EQ_Params[i] = i / EQ_SIZE for i in [0...EQ_SIZE]
    else if r < 0.6
        do -> EQ_Params[i] = 1 - (i / EQ_SIZE) for i in [0...EQ_SIZE]
    else if r < 0.8
        do -> EQ_Params[i] = (i % 3) / 2 for i in [0...EQ_SIZE]
    else
        do -> EQ_Params[i] = Math.random() for i in [0...EQ_SIZE]

    animate()
