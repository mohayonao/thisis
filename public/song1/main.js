// Generated by CoffeeScript 1.3.1
(function() {

  jQuery(function() {
    var bass, bass_dac, buddies, desc, drum, drum_dac, fue, fue_dac, master, rndfreq, stuff, stuff_dac, vocal, vocal_dac, voice, wav;
    timbre.utils.exports("random.choice", "atof");
    voice = [];
    wav = T("wav", "biwako2012.wav");
    wav.onloadeddata = function(e) {
      var dt, i, muls, _i, _results;
      dt = 217.3913043478261;
      muls = [1.5, 1.5, 1.5, 1.5, 2, 4, 2, 0];
      _results = [];
      for (i = _i = 0; _i < 8; i = ++_i) {
        _results.push(voice[i] = wav.slice(dt * i, dt * (i + 1)).set({
          mul: muls[i]
        }));
      }
      return _results;
    };
    wav.load();
    vocal_dac = T("dac").set({
      pan: 0.3
    });
    vocal = T("mml", "t138 q4 l8 $ @1 eeer eeer @6 eeee eerr");
    vocal.synth = T("rhpf", T("tri", 2, 200, 1320).kr(), 0.7).appendTo(vocal_dac);
    vocal.index = 0;
    vocal.random = false;
    vocal.synthdef = function(freq, opts) {
      var synth;
      synth = T("*", 0, T("sin", 660).kr());
      synth.keyon = function(opts) {
        var i;
        i = vocal.random ? (Math.random() * 4) | 0 : vocal.index;
        if (voice[i]) {
          synth.args[0] = voice[i].bang();
        }
        return vocal.index = (vocal.index + 1) % 3;
      };
      return synth;
    };
    vocal.onexternal = function(opts) {
      if (opts.cmd === "@") {
        return vocal.random = Math.random() < (opts.value / 12);
      }
    };
    vocal_dac.buddy("play", vocal, "on");
    fue_dac = T("dac").set({
      pan: T("+sin", 0.05)
    });
    rndfreq = [atof("G2"), atof("A2"), atof("A2"), atof("C3"), atof("D3")];
    fue = T("mml", "t138 q6 o3 $ l4 a<cc>a <el8dedc>ag a4aga<cc4> a4aga<ee4>");
    fue.synth = T("efx.reverb").appendTo(fue_dac);
    fue.synthdef = function(freq, opts) {
      var synth;
      synth = T("*", T("osc", "wavc(0080a0c0)", T("osc", "sin(5)", 4, 2, freq).kr(), 0.25), T("adsr", "24db", 25, 1500, 0.8, 250));
      synth.keyon = function(opts) {
        var r, _freq;
        r = Math.random();
        if (r < 0.15) {
          _freq = choice(rndfreq);
        } else if (r > 0.75) {
          _freq = freq;
        } else {
          _freq = 0;
        }
        if (_freq > 0) {
          synth.args[0].freq.add = _freq;
        }
        return synth.args[1].bang();
      };
      synth.keyoff = function(opts) {
        return synth.args[1].keyoff();
      };
      return synth;
    };
    fue_dac.buddy("play", fue, "on");
    bass_dac = T("dac");
    bass = T("mml", "t138 o1 l8 $ [aarr | ggrr]4 gg<cc>");
    bass.synth = T("+").appendTo(bass_dac);
    bass.synthdef = function(freq, opts) {
      var synth;
      synth = T("*", T("clip", T("osc", "sin(@1)", freq * 2, 4)).set({
        mul: 0.5
      }), T("adsr", "24db", 25, 150, 0.8, 50));
      synth.keyon = function(opts) {
        return synth.args[1].bang();
      };
      synth.keyoff = function(opts) {
        return synth.args[1].keyoff();
      };
      return synth;
    };
    bass_dac.buddy("play", bass, "on");
    drum_dac = T("dac");
    drum = T("mml", "t138 l8 $ g0c g+ g0c0e g+");
    drum.synth = T("efx.comp", 0.1, 1 / 40, 5).set({
      mul: 0.75
    }).appendTo(drum_dac);
    drum.synthdef = function(freq, opts) {
      var synth;
      synth = (function() {
        switch (opts.tnum) {
          case 60:
            return T("*", T("rbpf", 80, 0.8, T("osc", "sin(@3)", 20)), T("perc", "32db", 100));
          case 64:
            return T("*", T("bpf", 1600, T("pink", 0.25)), T("perc", "24db", 150));
          case 67:
            return T("*", T("hpf", 6400, T("noise", 0.15)), T("perc", "24db", 50));
          case 68:
            return T("*", T("hpf", 8800, T("noise", 0.15)), T("perc", "24db", 200));
          default:
            return T("*", T("noise", 0.6), T("perc", "24db", 250));
        }
      })();
      synth.keyon = function(opts) {
        return synth.args[1].bang();
      };
      return synth;
    };
    drum_dac.buddy("play", drum, "on");
    stuff_dac = T("dac").set({
      mul: 0.75
    });
    stuff = T("mml", "t138 l8 $ g0crcr crre g0ccrc crer l16g0ccccccccl8cc g0rcec gcee");
    stuff.synth = T("efx.comp", 0.2, 1 / 40, 2).set({
      mul: 0.75
    }).appendTo(stuff_dac);
    stuff.synthdef = function(freq, opts) {
      var synth;
      synth = (function() {
        switch (opts.tnum) {
          case 60:
            return voice[4];
          case 64:
            return voice[5];
          case 67:
            return voice[6];
        }
      })();
      synth.keyon = function(opts) {
        return synth.bang();
      };
      return synth;
    };
    stuff_dac.buddy("play", stuff, "on");
    buddies = [vocal_dac, fue_dac, bass_dac, drum_dac, stuff_dac];
    master = T("+");
    master.buddy("play", buddies);
    master.buddy("pause", buddies);
    master.isPlaying = false;
    desc = (function() {
      switch (timbre.env) {
        case "webkit":
          return "timbre.js on Web Audio API";
        case "moz":
          return "timbre.js on Audio Data API";
        default:
          return "Please open with Chrome or Firefox";
      }
    })();
    $("#desc").text(desc);
    $("#play").on("click", function() {
      if (!master.isPlaying) {
        master.play();
        return master.isPlaying = true;
      }
    });
    return $("#pause").on("click", function() {
      if (master.isPlaying) {
        master.pause();
        return master.isPlaying = false;
      }
    });
  });

}).call(this);
