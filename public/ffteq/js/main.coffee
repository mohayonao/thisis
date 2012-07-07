"use strict"

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

                for i in [0...nn]
                    j = n - i - 1
                    x = i * dx
                    if x < 8000
                        x = EQ_Params[(x / 8000 * EQ_SIZE)|0]
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
    $canvas.draw = (list)->
        w = $canvas.width()
        h = $canvas.height()
        context = $canvas.get(0).getContext "2d"

        context.save()
        context.clearRect 0, 0, w, h
        context.fillStyle = "#6699ff"

        dx = w / list.length
        for i in [0...list.length]
            x = i * dx
            y = h * list[i]
            context.fillRect(x|0, h - y, dx+0.5, y)
        context.restore()
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
            $canvas.draw EQ_Params
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

    $("#reset").on "click", (e)->
        do -> EQ_Params[i] = 0.8 for i in [0...EQ_SIZE]
        $canvas.draw EQ_Params
    $("#clear").on "click", (e)->
        do -> EQ_Params[i] = 0 for i in [0...EQ_SIZE]
        $canvas.draw EQ_Params

    sparse = ->
        x = (Math.random() * EQ_SIZE)|0
        sparse.data.push x
        EQ_Params[x] = 1

        if sparse.data.length > 8
            x = sparse.data.shift()
            EQ_Params[x] = 0

        $canvas.draw EQ_Params
    sparse.data = []

    timerId = 0
    $("#sparse-play").on "click", (e)->
        if timerId != 0
            clearInterval timerId
            timerId = 0
            $(this).css "color", "black"
        else
            $("#clear").click()
            timerId = setInterval sparse, 250
            $(this).css "color", "red"

    do -> EQ_Params[i] = 0.8 for i in [0...EQ_SIZE]
    $canvas.draw EQ_Params
