// Generated by CoffeeScript 1.3.3
(function() {

  jQuery(function() {
    "use strict";

    var $scale, $tuning, KV, baseRoot, baseScale, bass, bpm, buddies, calcFrequency, changeRootFreq, changeScale, changeTuning, desc, index, master, melo0, melo1, scales, sheet, tunings;
    master = T("efx.delay", 100, 0.4, 0.25);
    bpm = 104;
    baseScale = SC.Scale.major();
    baseRoot = 60;
    changeTuning = SC.Tuning.et12();
    changeScale = SC.Scale.minor();
    changeRootFreq = baseRoot.midicps() * 0.5;
    calcFrequency = function(tnum) {
      var degree, key;
      key = tnum - baseRoot;
      degree = baseScale.performKeyToDegree(key);
      return changeScale.degreeToFreq2(degree, changeRootFreq, 0);
    };
    melo0 = T("mml", ["o6l16q4" + "eere rcer gr8. > gr8.", "o6l16q4" + "cr8>gr8er rarb rb-ar" + "l12g<eg l16arfg rerc d>br8", "o6l16q4" + "r8gg-fd#re r>g#a<c r>a<cd" + "r8gg-fd#re < rcrc cr8.>" + "r8gg-fd#re r>g#a<c r>a<cd" + "r8e-r8dr8cr8.r4", "o6l16q4" + "ccrc rcdr ecr>a gr8.<" + "ccrc rcde r2" + "ccrc rcdr ecr>a gr8.", "o6l16q4" + "ecr>g r8g#r a<frf> ar8." + "l12b<aa agf l16ecr>a gr8.<" + "ecr>g r8g#r a<frf> ar8." + "l12b<ff fed l16c>grg cr8."]);
    melo0.synth = T("+").appendTo(master);
    melo0.synthdef = function(freq, opts) {
      var synth;
      synth = T("*", T("osc", "pulse", 0, 0.25), T("adsr", 0, 500, 0.8, 150));
      synth.keyon = function(opts) {
        synth.args[0].freq.value = calcFrequency(opts.tnum);
        return synth.args[1].bang();
      };
      synth.keyoff = function(opts) {
        return synth.args[1].keyoff();
      };
      return synth;
    };
    melo0.bpm = bpm;
    melo1 = T("mml", ["o5l16q4" + "f#f#rf# rf#f#r gr8. >gr8.", "o5l16q4" + "er8cr8>gr <rcrd rd-cr" + "l12cg<c l16cr>ab rgre fdr8", "o6l16q4" + "r8ee-d>b<rc r>efa rfab<" + "r8ee-d>b<rc rgrg gr8." + "r8ee-d>b<rc r>efa rfab<" + "r8cr8>fr8er8.r4", "o5l16q4" + "a-a-ra- ra-b-r <c>grf er8." + "a-a-ra- ra-b-g r2" + "a-a-ra- ra-b-r <c>grf er8.", "o6l16q4" + "c>gre r8er  f<drd> fr8." + "l12g<ff fed l16c>grf er8.<" + "c>gre r8er  f<drd> fr8." + "l12g<dd dc>b l16er8.r4"]);
    melo1.synth = T("+").appendTo(master);
    melo1.synthdef = function(freq, opts) {
      var synth;
      synth = T("*", T("osc", "pulse", 0, 0.25), T("adsr", 0, 500, 0.8, 150));
      synth.keyon = function(opts) {
        synth.args[0].freq.value = calcFrequency(opts.tnum);
        return synth.args[1].bang();
      };
      synth.keyoff = function(opts) {
        return synth.args[1].keyoff();
      };
      return synth;
    };
    melo1.bpm = bpm;
    bass = T("mml", ["o4l16q4" + "ddrd rddr <br8.>gr8.", "o4l16q4" + "gr8er8cr rfrg rg-fr" + "l12e<ce l16frde rcr>a bgr8", "o4l16q4" + "cr8gr8<cr >fr8<ccr>fr" + "cr8er8g<c < rfrf fr >>gr" + "cr8gr8<cr >fr8<ccr>fr>" + "a-r<a-r> b-<b-r8> l16cr8>g grcr", "o3l16q4" + "[a-r8<e-r8a-r gr8cr8>gr]3", "o4l16q4 crre gr<cr> fr<cr cc>fr" + "drrf grbr gr<cr cc>gr" + "crre gr<cr> fr<cr cc>fr" + "grrg l12gab l16 <cr>gr cr8."]);
    bass.synth = T("+").appendTo(master);
    bass.synthdef = function(freq, opts) {
      var synth;
      synth = T("*", T("osc", "fami", 0, 0.8), T("adsr", 0, 500, 0.8, 150));
      synth.keyon = function(opts) {
        synth.args[0].freq.value = calcFrequency(opts.tnum);
        return synth.args[1].bang();
      };
      synth.keyoff = function(opts) {
        return synth.args[1].keyoff();
      };
      return synth;
    };
    bass.bpm = bpm;
    sheet = [0, 1, 1, 2, 2, 3, 0, 1, 1, 4, 4, 3];
    index = 0;
    melo0.onended = function() {
      index = (index + 1) % sheet.length;
      melo0.selected = melo1.selected = bass.selected = sheet[index];
      melo0.bang();
      melo1.bang();
      return bass.bang();
    };
    buddies = [melo0, melo1, bass];
    master.buddy("play", buddies, "on");
    master.buddy("pause", buddies, "off");
    desc = (function() {
      switch (timbre.env) {
        case "webkit":
          return "timbre.js on Web Audio API / subcollider.js";
        case "moz":
          return "timbre.js on Audio Data API / subcollider.js";
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
    $("#pause").on("click", function() {
      if (master.isPlaying) {
        master.pause();
        return master.isPlaying = false;
      }
    });
    $scale = $("#scale");
    scales = (function() {
      scales = {};
      Object.keys(SC.ScaleInfo.scales).forEach(function(key) {
        var scale;
        scale = SC.ScaleInfo.at(key);
        if (scale.pitchesPerOctave() !== 12) {
          return;
        }
        scales[key] = scale;
        return $scale.append($("<option>").attr({
          value: key
        }).text(scale.name));
      });
      return scales;
    })();
    $scale.on("change", function() {
      changeScale = scales[$(this).val()];
      return changeScale.tuning(changeTuning);
    });
    $scale.val("major").change();
    $("#random-scale").on("click", function() {
      return $scale.val(Object.keys(scales).choose()).change();
    });
    $tuning = $("#tuning");
    tunings = (function() {
      tunings = {};
      Object.keys(SC.TuningInfo.tunings).forEach(function(key) {
        var tuning;
        tuning = SC.TuningInfo.at(key);
        if (tuning.size() !== 12) {
          return;
        }
        tunings[key] = tuning;
        return $tuning.append($("<option>").attr({
          value: key
        }).text(tuning.name));
      });
      return tunings;
    })();
    $tuning.on("change", function() {
      changeTuning = tunings[$(this).val()];
      return changeScale.tuning(changeTuning);
    });
    $tuning.val("et12");
    $("#random-tuning").on("click", function() {
      return $tuning.val(Object.keys(tunings).choose()).change();
    });
    SC.Scale.prototype.degreeToFreq2 = function(degree, rootFreq, octave) {
      return this.degreeToRatio2(degree, octave) * rootFreq;
    };
    SC.Scale.prototype.degreeToRatio2 = function(degree, octave) {
      var _index;
      octave += (degree / this._degrees.length) | 0;
      _index = degree % this._degrees.length;
      return this.ratios().blendAt(_index) * Math.pow(this.octaveRatio(), octave);
    };
    if (location.search !== "") {
      KV = (function() {
        KV = {};
        location.search.substr(1).split("&").forEach(function(x) {
          var items;
          items = x.split("=", 2);
          if (items.length === 1) {
            return KV[items[0]] = true;
          } else {
            return KV[items[0]] = items[1];
          }
        });
        return KV;
      })();
      if (KV.scale !== "") {
        $scale.val(KV.scale).change();
      }
      if (KV.tuning !== "") {
        $tuning.val(KV.tuning).change();
      }
      if (KV.autostart) {
        $("#play").click();
      }
    }
    return $("#tweet").on("click", function() {
      var baseurl, h, lis, scale_val, search, text, tuning_val, url, w, x, y;
      scale_val = $("#scale").val();
      tuning_val = $("#tuning").val();
      w = 550;
      h = 250;
      x = Math.round(screen.width * 0.5 - w * 0.5);
      y = Math.round(screen.height * 0.5 - h * 0.5);
      baseurl = location.protocol + "//" + location.host + location.pathname;
      text = "マリオの曲できた";
      search = "scale=" + scale_val + "&tuning=" + tuning_val;
      console.log(baseurl);
      lis = ["http://twitter.com/share?lang=ja", "text=" + text, "url=" + encodeURIComponent("" + baseurl + "?" + search)];
      url = lis.join("&");
      return window.open(url, "intent", "width=" + w + ",height=" + h + ",left=" + x + ",top=" + y);
    });
  });

}).call(this);
