"use strict"

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
        @source = T("buffer").set(loop:true)
        @fft    = new FFT(@size)
        @buffer = new Float32Array(@size)
        @index  = 0
        @

    AcmeFFT.prototype.setBuffer = (buffer)->
        @source.set({buffer:buffer}).bang()
        @

    DEBUG = 0

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
                DEBUG += 1
        @cell
    timbre.fn.register("acme", AcmeFFT)


    synth = T("acme").play()

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
                synth.setBuffer buffer
                $("#text").text "再生を開始します."
                setTimeout ->
                    $("#text").text "音楽ファイルをドラッグ & ドロップすると再生します."
                , 5000
            catch e
                $("#text").text "再生できないファイルです."
        reader.readAsArrayBuffer file

    if timbre.env is "webkit"
        $("#text").text "音楽ファイルをドラッグ & ドロップすると再生します."
    else
        $("#text").text "Chrome で開いてね!!"


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

    do -> EQ_Params[i] = Math.random() for i in [0...EQ_SIZE]

    animate()
