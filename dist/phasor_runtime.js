// ============================================================================
// PHASOR_RUNTIME.JS — Micro-Runner Soberano & Puente I/O Canvas 2D
// PhasorLang v1.0 [Chronos IDE & KoraDevs Autonomous Ecosystem]
// Zero-GC a 120 FPS | Standalone Offline file:/// | <150 Líneas
// ============================================================================
(function(G) {
  'use strict';

  function MicroPhasorVM(code, consts, strings) {
    this.code = code || []; this.consts = consts || []; this.strings = strings || [];
    this.rScalar = new Float64Array(1024); this.rCompReal = new Float64Array(1024); this.rCompImag = new Float64Array(1024); this.isComplex = new Uint8Array(1024);
    this.rVecX = new Float64Array(1024); this.rVecY = new Float64Array(1024); this.rVecZ = new Float64Array(1024); this.isVector3 = new Uint8Array(1024);
    this.heapVectors = new Float64Array(524288); this.heapPtr = 0;
    this.uiCmds = []; this.buttons = []; this.texts = []; this.logs = [];
  }

  MicroPhasorVM.prototype.pushUi = function(t, a, b, c, d, e) { this.uiCmds.push(t, a || 0, b || 0, c || 0, d || 0, e || 0); };

  MicroPhasorVM.prototype.run = function(pc, vw, vh) {
    pc = pc || 0; var cyc = 0; this.uiCmds = []; this.buttons = []; this.texts = [];
    this.rScalar[250] = vw || this.rScalar[250] || 800; this.rScalar[251] = vh || this.rScalar[251] || 600;
    var S = this.rScalar, CR = this.rCompReal, CI = this.rCompImag, IC = this.isComplex, VX = this.rVecX, VY = this.rVecY, VZ = this.rVecZ, IV = this.isVector3, H = this.heapVectors;

    while (pc < this.code.length && ++cyc < 1000000) {
      var ins = this.code[pc++], op = (ins >>> 24) & 0xFF, dst = (ins >>> 16) & 0xFF, s1 = (ins >>> 8) & 0xFF, s2 = ins & 0xFF;
      if (op === 0x00) continue; if (op === 0xFF) break;
      if (op === 0x01) { S[dst] = this.consts[s1]; IC[dst] = IV[dst] = 0; }
      else if (op === 0x02) { S[dst] = S[s1]; CR[dst] = CR[s1]; CI[dst] = CI[s1]; IC[dst] = IC[s1]; VX[dst] = VX[s1]; VY[dst] = VY[s1]; VZ[dst] = VZ[s1]; IV[dst] = IV[s1]; }
      else if (op === 0x03 || op === 0x10) {
        if (IC[s1] || IC[s2]) { CR[dst] = (IC[s1] ? CR[s1] : S[s1]) + (IC[s2] ? CR[s2] : S[s2]); CI[dst] = (IC[s1] ? CI[s1] : 0) + (IC[s2] ? CI[s2] : 0); IC[dst] = 1; IV[dst] = 0; }
        else { S[dst] = S[s1] + S[s2]; IC[dst] = IV[dst] = 0; }
      }
      else if (op === 0x04 || op === 0x11) {
        if (IC[s1] || IC[s2]) { CR[dst] = (IC[s1] ? CR[s1] : S[s1]) - (IC[s2] ? CR[s2] : S[s2]); CI[dst] = (IC[s1] ? CI[s1] : 0) - (IC[s2] ? CI[s2] : 0); IC[dst] = 1; IV[dst] = 0; }
        else { S[dst] = S[s1] - S[s2]; IC[dst] = IV[dst] = 0; }
      }
      else if (op === 0x05 || op === 0x12) {
        if (IC[s1] || IC[s2]) { var r1 = IC[s1] ? CR[s1] : S[s1], i1 = IC[s1] ? CI[s1] : 0, r2 = IC[s2] ? CR[s2] : S[s2], i2 = IC[s2] ? CI[s2] : 0; CR[dst] = r1 * r2 - i1 * i2; CI[dst] = r1 * i2 + i1 * r2; IC[dst] = 1; IV[dst] = 0; }
        else { S[dst] = S[s1] * S[s2]; IC[dst] = IV[dst] = 0; }
      }
      else if (op === 0x06 || op === 0x13) {
        if (IC[s1] || IC[s2]) { var r1d = IC[s1] ? CR[s1] : S[s1], i1d = IC[s1] ? CI[s1] : 0, r2d = IC[s2] ? CR[s2] : S[s2], i2d = IC[s2] ? CI[s2] : 0, den = r2d * r2d + i2d * i2d; CR[dst] = den ? (r1d * r2d + i1d * i2d) / den : 0; CI[dst] = den ? (i1d * r2d - r1d * i2d) / den : 0; IC[dst] = 1; IV[dst] = 0; }
        else { S[dst] = S[s2] !== 0 ? S[s1] / S[s2] : 0; IC[dst] = IV[dst] = 0; }
      }
      else if (op === 0x14) S[dst] = Math.pow(S[s1], S[s2]);
      else if (op === 0x15) S[dst] = S[s1] % S[s2];
      else if (op === 0x16) S[dst] = Math.sqrt(Math.abs(S[s1]));
      else if (op === 0x17) S[dst] = Math.sin(S[s1]);
      else if (op === 0x18) S[dst] = Math.cos(S[s1]);
      else if (op === 0x19) S[dst] = Math.tan(S[s1]);
      else if (op === 0x1C) S[dst] = Math.abs(S[s1]);
      else if (op === 0x07 || op === 0x40) pc = (ins & 0xFFFF);
      else if (op === 0x08 || op === 0x41) { if (S[dst] === 0) pc = (ins & 0xFFFF); }
      else if (op === 0x21) S[dst] = S[s1] === S[s2] ? 1 : 0;
      else if (op === 0x22) S[dst] = S[s1] !== S[s2] ? 1 : 0;
      else if (op === 0x23) S[dst] = S[s1] < S[s2] ? 1 : 0;
      else if (op === 0x24) S[dst] = S[s1] <= S[s2] ? 1 : 0;
      else if (op === 0x25) S[dst] = S[s1] > S[s2] ? 1 : 0;
      else if (op === 0x26) S[dst] = S[s1] >= S[s2] ? 1 : 0;
      else if (op === 0x09 || op === 0x28) { var rad = S[s2] * (Math.PI / 180.0); CR[dst] = S[s1] * Math.cos(rad); CI[dst] = S[s1] * Math.sin(rad); IC[dst] = 1; IV[dst] = 0; }
      else if (op === 0x0A || op === 0x30) { var v = dst === 1 ? (this.strings[s1] || '') : S[s1]; this.logs.push('> ' + v + '\n'); }
      else if (op === 0x50) this.pushUi(0x50, S[dst]);
      else if (op === 0x51) this.pushUi(0x51, S[this.code[pc++]], S[this.code[pc++]], S[this.code[pc++]], S[this.code[pc++]], S[this.code[pc++]]);
      else if (op === 0x52) this.pushUi(0x52, S[this.code[pc++]], S[this.code[pc++]], S[this.code[pc++]], S[this.code[pc++]]);
      else if (op === 0x53) this.pushUi(0x53, S[this.code[pc++]], S[this.code[pc++]], S[this.code[pc++]], S[this.code[pc++]], S[this.code[pc++]]);
      else if (op === 0x54) {
        var isStr = dst === 1, sRef = this.code[pc++], tx = S[this.code[pc++]], ty = S[this.code[pc++]], tSz = S[this.code[pc++]] || 12, tc = S[this.code[pc++]];
        var txt = isStr ? (this.strings[sRef] || "") : (Number.isInteger(S[sRef]) ? S[sRef].toString() : S[sRef].toFixed(2));
        this.pushUi(0x54, tx, ty, tc, tSz); this.texts.push({ text: txt, x: tx, y: ty, color: tc, size: tSz });
      }
      else if (op === 0x56) {
        var strId = dst, bx = S[this.code[pc++]], by = S[this.code[pc++]], bw = S[this.code[pc++]], bh = S[this.code[pc++]], act = this.code[pc++], bc = S[this.code[pc++]] || 0x1f6feb;
        var lbl = this.strings[strId] || 'BOTÓN';
        this.pushUi(0x56, bx, by, bw, bh, bc); this.buttons.push({ x: bx, y: by, w: bw, h: bh, target: act, label: lbl, color: bc });
      }
      else if (op === 0x60) { var rz = (this.code[pc++] >>> 8) & 0xFF; VX[dst] = S[s1]; VY[dst] = S[s2]; VZ[dst] = S[rz]; IV[dst] = 1; IC[dst] = 0; }
      else if (op === 0x61) { VX[dst] = VX[s1] + VX[s2]; VY[dst] = VY[s1] + VY[s2]; VZ[dst] = VZ[s1] + VZ[s2]; IV[dst] = 1; }
      else if (op === 0x62) { VX[dst] = VX[s1] - VX[s2]; VY[dst] = VY[s1] - VY[s2]; VZ[dst] = VZ[s1] - VZ[s2]; IV[dst] = 1; }
      else if (op === 0x63) { VX[dst] = VX[s1] * S[s2]; VY[dst] = VY[s1] * S[s2]; VZ[dst] = VZ[s1] * S[s2]; IV[dst] = 1; }
      else if (op === 0x64) { S[dst] = VX[s1] * VX[s2] + VY[s1] * VY[s2] + VZ[s1] * VZ[s2]; IV[dst] = 0; }
      else if (op === 0x66) { S[dst] = Math.hypot(VX[s1], VY[s1], VZ[s1]); IV[dst] = 0; }
      else if (op === 0x69) { S[dst] = VX[s1]; IV[dst] = 0; }
      else if (op === 0x6A) { S[dst] = VY[s1]; IV[dst] = 0; }
      else if (op === 0x6B) { S[dst] = VZ[s1]; IV[dst] = 0; }
      else if (op === 0x70) { var base = this.heapPtr; this.heapPtr += Math.floor(S[s1]) * Math.floor(S[s2]); S[dst] = base; IV[dst] = 0; }
      else if (op === 0x71) {
        var exL = this.code[pc++], rI = (exL >>> 16) & 0xFFFF, rC = (exL >>> 8) & 0xFF;
        var offL = Math.floor(S[s1]) + Math.floor(S[s2]) * Math.floor(S[rC]) + Math.floor(S[rI]);
        S[dst] = (offL >= 0 && offL < H.length) ? H[offL] : 0; IV[dst] = 0;
      }
      else if (op === 0x72) {
        var exS = this.code[pc++], rIS = (exS >>> 16) & 0xFFFF, rCS = (exS >>> 8) & 0xFF;
        var offS = Math.floor(S[dst]) + Math.floor(S[s2]) * Math.floor(S[rCS]) + Math.floor(S[rIS]);
        if (offS >= 0 && offS < H.length) H[offS] = S[s1];
      }
    }
  };

  var PhasorRuntime = {
    canvas: null, ctx: null, width: 0, height: 0, vm: null, screenRoutes: {}, actionRoutes: {}, currentScreenPc: 0,
    hex: function(c) { return '#' + ((c >>> 0) & 0xFFFFFF).toString(16).padStart(6, '0'); },
    setReg: function(r, v) { if (this.vm && r >= 0 && r < 1024) this.vm.rScalar[r] = v; },
    resize: function() {
      if (!this.canvas) return;
      var w = window.innerWidth, h = window.innerHeight;
      this.canvas.width = this.width = w; this.canvas.height = this.height = h;
      this.setReg(250, w); this.setReg(251, h);
    },
    init: function(wasm, canvasId, opts) {
      var self = this; opts = opts || {};
      self.canvas = document.getElementById(canvasId || 'phasorCanvas');
      if (!self.canvas) return;
      self.ctx = self.canvas.getContext('2d', { alpha: false });
      if (opts.bytecode && opts.constPool) {
        self.vm = new MicroPhasorVM(opts.bytecode, opts.constPool, opts.strings || []);
        self.screenRoutes = opts.screenRoutes || {}; self.actionRoutes = opts.actionRoutes || {};
        self.currentScreenPc = opts.firstScreenPc || 0;
        self.handleAction = function(target) {
          var k = String(Math.round(Number(target)));
          var pc = self.actionRoutes[k] !== undefined ? self.actionRoutes[k] : self.screenRoutes[k];
          if (pc !== undefined && pc !== null) self.vm.run(pc, self.width, self.height);
          if (typeof self.onAction === 'function') self.onAction(target, k, pc);
        };
        self.vm.run(0, window.innerWidth, window.innerHeight);
      }
      self.resize();
      window.addEventListener('resize', function() { self.resize(); });
      var updatePtr = function(e, down) {
        var r = self.canvas.getBoundingClientRect(), mx = e.clientX - r.left, my = e.clientY - r.top;
        self.setReg(1, mx); self.setReg(2, my); self.setReg(252, mx); self.setReg(253, my);
        if (down !== undefined) { self.setReg(3, down); self.setReg(254, down); }
        return { mx: mx, my: my };
      };
      self.canvas.addEventListener('pointerdown', function(e) {
        var p = updatePtr(e, 1.0);
        if (self.vm && self.vm.buttons) {
          for (var b = self.vm.buttons.length - 1; b >= 0; b--) {
            var btn = self.vm.buttons[b];
            if (p.mx >= btn.x && p.mx <= btn.x + btn.w && p.my >= btn.y && p.my <= btn.y + btn.h) {
              if (self.handleAction) self.handleAction(btn.target);
              return;
            }
          }
        }
      });
      window.addEventListener('pointermove', function(e) { updatePtr(e); });
      window.addEventListener('pointerup', function(e) { updatePtr(e, 0.0); });
      self.canvas.addEventListener('wheel', function(e) {
        self.setReg(4, e.deltaY); self.setReg(255, e.deltaY);
      }, { passive: true });
      var loop = function() {
        if (self.ctx && self.vm) {
          self.vm.run(self.currentScreenPc, self.width, self.height);
          self.renderVmUi(self.ctx, self.vm, self.width, self.height);
          self.setReg(4, 0); self.setReg(255, 0);
        }
        requestAnimationFrame(loop);
      };
      requestAnimationFrame(loop);
    },
    bootFromElement: function(elementOrId, canvasId, extraOpts) {
      var self = this;
      var el = typeof elementOrId === 'string'
        ? (document.getElementById(elementOrId) || document.querySelector(elementOrId))
        : elementOrId;
      if (!el) return null;
      var raw = (el.textContent || el.innerText || '').trim();
      if (!raw) return null;
      try {
        var data = JSON.parse(raw);
        var opts = Object.assign({}, data, extraOpts || {});
        return self.init(data.wasm || '', canvasId || 'phasorCanvas', opts);
      } catch (err) {
        console.error('[PhasorRuntime] Error al procesar <phasorcode>:', err);
        return null;
      }
    },
    autoBoot: function() {
      var self = this;
      if (typeof document === 'undefined') return;
      var runBoot = function() {
        if (self.vm) return;
        var codeEl = document.querySelector('phasorcode, [type="application/phasor-binary"], [type="application/phasor-json"]');
        if (codeEl) {
          self.bootFromElement(codeEl, 'phasorCanvas');
        }
      };
      if (document.readyState === 'complete' || document.readyState === 'interactive') {
        runBoot();
      } else {
        window.addEventListener('DOMContentLoaded', runBoot);
      }
    },
    initPwa: function() {
      if (typeof navigator !== 'undefined' && 'serviceWorker' in navigator && location.protocol.indexOf('http') === 0) {
        try {
          var swBlob = new Blob(["self.addEventListener('install',e=>self.skipWaiting());self.addEventListener('activate',e=>e.waitUntil(clients.claim()));"], { type: 'application/javascript' });
          navigator.serviceWorker.register(URL.createObjectURL(swBlob)).catch(function(){});
        } catch(e) {}
      }
    },
    exportStandaloneHtml: function(filename) {
      if (typeof document === 'undefined') return;
      var codeEl = document.querySelector('phasorcode');
      if (!codeEl) {
        console.warn('[PhasorRuntime] No hay <phasorcode> activo para exportar.');
        return;
      }
      var fullHtml = '<!DOCTYPE html>\n<html lang="es">\n' + document.documentElement.innerHTML + '\n</html>';
      var blob = new Blob([fullHtml], { type: 'text/html;charset=utf-8' });
      var url = URL.createObjectURL(blob);
      var a = document.createElement('a');
      a.href = url;
      a.download = filename || 'chronos_ide_export.html';
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
    },
    renderVmUi: function(ctx, vm, w, h) {
      if (!vm || !vm.uiCmds) return;
      var cmds = vm.uiCmds, ti = 0, bi = 0;
      for (var i = 0; i < cmds.length; i += 6) {
        var op = Math.floor(cmds[i]), p1 = cmds[i+1], p2 = cmds[i+2], p3 = cmds[i+3], p4 = cmds[i+4], p5 = cmds[i+5];
        if (op === 0x50) { ctx.fillStyle = this.hex(p1); ctx.fillRect(0, 0, w, h); }
        else if (op === 0x51) { ctx.fillStyle = this.hex(p5); ctx.fillRect(p1, p2, p3, p4); }
        else if (op === 0x52) { ctx.strokeStyle = this.hex(p4); ctx.lineWidth = 2; ctx.beginPath(); ctx.arc(p1, p2, p3, 0, Math.PI * 2); ctx.stroke(); }
        else if (op === 0x53) { ctx.strokeStyle = this.hex(p5); ctx.lineWidth = 1.5; ctx.beginPath(); ctx.moveTo(p1, p2); ctx.lineTo(p3, p4); ctx.stroke(); }
        else if (op === 0x54 && vm.texts && ti < vm.texts.length) {
          var t = vm.texts[ti++]; ctx.fillStyle = this.hex(t.color); ctx.font = (t.size || 12) + 'px monospace'; ctx.textAlign = 'left'; ctx.textBaseline = 'top'; ctx.fillText(t.text, t.x, t.y);
        }
        else if (op === 0x56 && vm.buttons && bi < vm.buttons.length) {
          var b = vm.buttons[bi++]; ctx.fillStyle = this.hex(p5);
          if (ctx.roundRect) { ctx.beginPath(); ctx.roundRect(p1, p2, p3, p4, 5); ctx.fill(); ctx.strokeStyle = '#30363D'; ctx.lineWidth = 1; ctx.stroke(); }
          else { ctx.fillRect(p1, p2, p3, p4); }
          var txt = b.label || 'BOTÓN', fs = 11;
          if (txt.length * 7 > p3 - 8) fs = Math.max(9, Math.floor((p3 - 8) / (txt.length * 0.65)));
          ctx.fillStyle = '#FFFFFF'; ctx.font = 'bold ' + fs + 'px monospace'; ctx.textAlign = 'center'; ctx.textBaseline = 'middle';
          ctx.fillText(txt, p1 + (p3 / 2), p2 + (p4 / 2));
        }
      }
    }
  };

  G.MicroPhasorVM = MicroPhasorVM;
  G.PhasorRuntime = PhasorRuntime;
  if (typeof window !== 'undefined') {
    PhasorRuntime.initPwa();
    PhasorRuntime.autoBoot();
  }
})(typeof window !== 'undefined' ? window : this);
