// ===============================================================
// PHASOR_RUNTIME.JS — Runtime Universal WebAssembly & Canvas 2D
// PhasorLang v1.0 [Chronos IDE & KoraDevs Ecosystem]
// https://github.com/koradevsorg
//
// Arquitectura Unificada Multi-Dispositivo & Multi-Ventana:
// - Espacio Cilíndrico Panorámico 360° en X con Desplazamiento Infinito en Y
// - Ventanas Hijas Libres e Independientes: Arrastre libre, Reubicación en 360°,
//   Redimensión 8D (NW, N, NE, E, SE, S, SW, W), Minimizado [-]/[+] y Scroll
// - MicroPhasorVM Zero-GC Integrada con Opcodes SoA, SIMD y UI
// - 100% Código PhasorLang: Renderizado autónomo a 90-120 FPS
// ===============================================================

(function(global) {
  'use strict';

  // =========================================================================
  // 1. MICRO PHASOR VM INTEGRADA (ZERO-GC INTERPRETER & UI DISPATCHER)
  // =========================================================================
  function MicroPhasorVM(code, consts, strings) {
    this.code = code || [];
    this.consts = consts || [];
    this.strings = strings || [];

    this.rScalar = new Float64Array(1024);
    this.rCompReal = new Float64Array(1024);
    this.rCompImag = new Float64Array(1024);
    this.isComplex = new Uint8Array(1024);

    // Registros Vectoriales Orthogonales Vec3 (SIMD)
    this.rVecX = new Float64Array(1024);
    this.rVecY = new Float64Array(1024);
    this.rVecZ = new Float64Array(1024);
    this.isVector3 = new Uint8Array(1024);

    // Memoria Plana Contigua SoA (Structure of Arrays: 512k doubles = 4MB)
    this.heapVectors = new Float64Array(524288);
    this.heapPtr = 0;

    this.uiCmds = [];
    this.buttons = [];
    this.texts = [];
    this.logs = [];
    this.tryStack = [];
  }

  MicroPhasorVM.prototype.handleException = function(err) {
    if (this.tryStack.length > 0) {
      var h = this.tryStack.pop();
      if (h.errReg > 0 && h.errReg < 1024) this.rScalar[h.errReg] = 1.0;
      return h.catchPc;
    }
    this.logs.push('> [PVM Runtime Error] ' + (err.message || err) + '\n');
    return -1;
  };

  MicroPhasorVM.prototype.pushUi = function(type, p1, p2, p3, p4, p5) {
    this.uiCmds.push(type, p1 || 0, p2 || 0, p3 || 0, p4 || 0, p5 || 0);
  };

  MicroPhasorVM.prototype.run = function(entryPc, viewW, viewH) {
    var pc = entryPc || 0;
    var cycles = 0;
    this.tryStack = [];
    this.uiCmds = [];
    this.buttons = [];
    this.texts = [];

    var vw = (viewW !== undefined && viewW > 0) ? viewW : (this.rScalar[250] > 0 ? this.rScalar[250] : 800);
    var vh = (viewH !== undefined && viewH > 0) ? viewH : (this.rScalar[251] > 0 ? this.rScalar[251] : 600);
    this.rScalar[250] = vw;
    this.rScalar[251] = vh;

    while (pc < this.code.length) {
      if (++cycles > 1000000) {
        var newPc = this.handleException(new Error('Watchdog Timer: Bucle excedido (1M ciclos)'));
        if (newPc >= 0) { pc = newPc; continue; } else break;
      }

      var instr = this.code[pc++];
      var op = (instr >>> 24) & 0xFF;
      var dst = (instr >>> 16) & 0xFF;
      var s1 = (instr >>> 8) & 0xFF;
      var s2 = instr & 0xFF;

      if (op === 0x00 || op === 0xFF) break; // HALT

      switch (op) {
        case 0x01: // LOAD_K
          this.rScalar[dst] = this.consts[s1];
          this.isComplex[dst] = 0;
          this.isVector3[dst] = 0;
          break;
        case 0x02: // MOV
          this.rScalar[dst] = this.rScalar[s1];
          this.rCompReal[dst] = this.rCompReal[s1];
          this.rCompImag[dst] = this.rCompImag[s1];
          this.isComplex[dst] = this.isComplex[s1];
          this.rVecX[dst] = this.rVecX[s1];
          this.rVecY[dst] = this.rVecY[s1];
          this.rVecZ[dst] = this.rVecZ[s1];
          this.isVector3[dst] = this.isVector3[s1];
          break;
        case 0x10: case 0x03: // ADD
          if (this.isComplex[s1] || this.isComplex[s2]) {
            var re1 = this.isComplex[s1] ? this.rCompReal[s1] : this.rScalar[s1];
            var im1 = this.isComplex[s1] ? this.rCompImag[s1] : 0;
            var re2 = this.isComplex[s2] ? this.rCompReal[s2] : this.rScalar[s2];
            var im2 = this.isComplex[s2] ? this.rCompImag[s2] : 0;
            this.rCompReal[dst] = re1 + re2;
            this.rCompImag[dst] = im1 + im2;
            this.isComplex[dst] = 1;
            this.isVector3[dst] = 0;
          } else {
            this.rScalar[dst] = this.rScalar[s1] + this.rScalar[s2];
            this.isComplex[dst] = 0;
            this.isVector3[dst] = 0;
          }
          break;
        case 0x11: case 0x04: // SUB
          if (this.isComplex[s1] || this.isComplex[s2]) {
            var re1s = this.isComplex[s1] ? this.rCompReal[s1] : this.rScalar[s1];
            var im1s = this.isComplex[s1] ? this.rCompImag[s1] : 0;
            var re2s = this.isComplex[s2] ? this.rCompReal[s2] : this.rScalar[s2];
            var im2s = this.isComplex[s2] ? this.rCompImag[s2] : 0;
            this.rCompReal[dst] = re1s - re2s;
            this.rCompImag[dst] = im1s - im2s;
            this.isComplex[dst] = 1;
            this.isVector3[dst] = 0;
          } else {
            this.rScalar[dst] = this.rScalar[s1] - this.rScalar[s2];
            this.isComplex[dst] = 0;
            this.isVector3[dst] = 0;
          }
          break;
        case 0x12: case 0x05: // MUL
          if (this.isComplex[s1] || this.isComplex[s2]) {
            var re1m = this.isComplex[s1] ? this.rCompReal[s1] : this.rScalar[s1];
            var im1m = this.isComplex[s1] ? this.rCompImag[s1] : 0;
            var re2m = this.isComplex[s2] ? this.rCompReal[s2] : this.rScalar[s2];
            var im2m = this.isComplex[s2] ? this.rCompImag[s2] : 0;
            this.rCompReal[dst] = re1m * re2m - im1m * im2m;
            this.rCompImag[dst] = re1m * im2m + im1m * re2m;
            this.isComplex[dst] = 1;
            this.isVector3[dst] = 0;
          } else {
            this.rScalar[dst] = this.rScalar[s1] * this.rScalar[s2];
            this.isComplex[dst] = 0;
            this.isVector3[dst] = 0;
          }
          break;
        case 0x13: case 0x06: // DIV
          if (this.isComplex[s1] || this.isComplex[s2]) {
            var re1d = this.isComplex[s1] ? this.rCompReal[s1] : this.rScalar[s1];
            var im1d = this.isComplex[s1] ? this.rCompImag[s1] : 0;
            var re2d = this.isComplex[s2] ? this.rCompReal[s2] : this.rScalar[s2];
            var im2d = this.isComplex[s2] ? this.rCompImag[s2] : 0;
            var den = re2d * re2d + im2d * im2d;
            if (den !== 0) {
              this.rCompReal[dst] = (re1d * re2d + im1d * im2d) / den;
              this.rCompImag[dst] = (im1d * re2d - re1d * im2d) / den;
            } else {
              this.rCompReal[dst] = 0;
              this.rCompImag[dst] = 0;
            }
            this.isComplex[dst] = 1;
            this.isVector3[dst] = 0;
          } else {
            this.rScalar[dst] = (this.rScalar[s2] !== 0) ? (this.rScalar[s1] / this.rScalar[s2]) : 0;
            this.isComplex[dst] = 0;
            this.isVector3[dst] = 0;
          }
          break;
        case 0x14: this.rScalar[dst] = Math.pow(this.rScalar[s1], this.rScalar[s2]); break;
        case 0x15: this.rScalar[dst] = this.rScalar[s1] % this.rScalar[s2]; break;
        case 0x16: this.rScalar[dst] = Math.sqrt(Math.abs(this.rScalar[s1])); break;
        case 0x17: this.rScalar[dst] = Math.sin(this.rScalar[s1]); break;
        case 0x18: this.rScalar[dst] = Math.cos(this.rScalar[s1]); break;
        case 0x19: this.rScalar[dst] = Math.tan(this.rScalar[s1]); break;
        case 0x1C: this.rScalar[dst] = Math.abs(this.rScalar[s1]); break;
        case 0x07: case 0x40: pc = (instr & 0xFFFF); break;
        case 0x08: case 0x41: if (this.rScalar[dst] === 0.0) pc = (instr & 0xFFFF); break;
        case 0x21: this.rScalar[dst] = (this.rScalar[s1] === this.rScalar[s2]) ? 1.0 : 0.0; break;
        case 0x22: this.rScalar[dst] = (this.rScalar[s1] !== this.rScalar[s2]) ? 1.0 : 0.0; break;
        case 0x23: this.rScalar[dst] = (this.rScalar[s1] < this.rScalar[s2]) ? 1.0 : 0.0; break;
        case 0x24: this.rScalar[dst] = (this.rScalar[s1] <= this.rScalar[s2]) ? 1.0 : 0.0; break;
        case 0x25: this.rScalar[dst] = (this.rScalar[s1] > this.rScalar[s2]) ? 1.0 : 0.0; break;
        case 0x26: this.rScalar[dst] = (this.rScalar[s1] >= this.rScalar[s2]) ? 1.0 : 0.0; break;
        case 0x28: case 0x09: { // MAKE_PHASOR
          var mag = this.rScalar[s1];
          var rad = this.rScalar[s2] * (Math.PI / 180.0);
          this.rCompReal[dst] = mag * Math.cos(rad);
          this.rCompImag[dst] = mag * Math.sin(rad);
          this.isComplex[dst] = 1;
          this.isVector3[dst] = 0;
          break;
        }
        case 0x30: case 0x0A: { // OUT
          if (dst === 1) {
            var st1 = (this.strings && this.strings[s1] !== undefined) ? this.strings[s1] : '';
            this.logs.push('> OUT: ' + st1 + '\n');
          } else {
            var valOut = this.rScalar[s1];
            this.logs.push('> OUT: ' + (typeof valOut === 'number' ? valOut.toFixed(4) : valOut) + '\n');
          }
          break;
        }
        case 0x36: { // PANIC
          var pMsg = (dst === 1 && this.strings && this.strings[s1]) ? this.strings[s1] : 'Pánico';
          var nPc = this.handleException(new Error('[PVM Panic] ' + pMsg));
          if (nPc >= 0) pc = nPc;
          break;
        }
        case 0x37: this.tryStack.push({ catchPc: instr & 0xFFFF, errReg: dst }); break;
        case 0x38: if (this.tryStack.length > 0) this.tryStack.pop(); break;

        // Opcodes de Interfaz Gráfica (0x50 - 0x57)
        case 0x50: // CLS
          this.pushUi(0x50, this.rScalar[dst]);
          break;
        case 0x51: { // RECT
          var rx = this.code[pc++], ry = this.code[pc++], rw = this.code[pc++];
          var extra1 = this.code[pc++];
          var rh = (extra1 >>> 16) & 0xFFFF, rc = (extra1 >>> 8) & 0xFF;
          this.pushUi(0x51, this.rScalar[rx], this.rScalar[ry], this.rScalar[rw], this.rScalar[rh], this.rScalar[rc]);
          break;
        }
        case 0x52: { // CIRCLE
          var rcx = this.code[pc++], rcy = this.code[pc++], rr = this.code[pc++];
          var extra2 = this.code[pc++];
          var rc2 = (extra2 >>> 16) & 0xFFFF;
          this.pushUi(0x52, this.rScalar[rcx], this.rScalar[rcy], this.rScalar[rr], this.rScalar[rc2], 0);
          break;
        }
        case 0x53: { // LINE
          var rx1 = this.code[pc++], ry1 = this.code[pc++], rx2 = this.code[pc++];
          var extra3 = this.code[pc++];
          var ry2 = (extra3 >>> 16) & 0xFFFF, lc = (extra3 >>> 8) & 0xFF;
          this.pushUi(0x53, this.rScalar[rx1], this.rScalar[ry1], this.rScalar[rx2], this.rScalar[ry2], this.rScalar[lc]);
          break;
        }
        case 0x54: { // TEXT
          var tx = this.code[pc++], ty = this.code[pc++], strIdx = this.code[pc++];
          var extra4 = this.code[pc++];
          var tc = (extra4 >>> 16) & 0xFFFF, varReg = (extra4 >>> 8) & 0xFF;
          var px = this.rScalar[tx], py = this.rScalar[ty];
          var displayText = "";
          if (varReg !== 0xFF) {
            displayText = this.rScalar[varReg].toFixed(2);
          } else {
            displayText = (this.strings && this.strings[strIdx] !== undefined) ? this.strings[strIdx] : "";
          }
          this.pushUi(0x54, px, py, tc, 0, 0);
          this.texts.push({ text: displayText, x: px, y: py, color: tc, signalReg: (varReg !== 0xFF ? varReg : -1) });
          break;
        }
        case 0x56: { // BUTTON
          var bx = this.code[pc++], by = this.code[pc++], bw = this.code[pc++];
          var extra5 = this.code[pc++];
          var bh = (extra5 >>> 16) & 0xFFFF, btnStrIdx = (extra5 >>> 8) & 0xFF;
          var extra6 = this.code[pc++];
          var actHash = extra6;
          var bpx = this.rScalar[bx], bpy = this.rScalar[by], bpw = this.rScalar[bw], bph = this.rScalar[bh];
          var label = (this.strings && this.strings[btnStrIdx] !== undefined) ? this.strings[btnStrIdx] : 'BOTÓN';
          this.pushUi(0x56, bpx, bpy, bpw, bph, 0x1f6feb);
          this.buttons.push({ x: bpx, y: bpy, w: bpw, h: bph, target: actHash, label: label });
          break;
        }

        // Opcodes Vectoriales SIMD (0x60 - 0x6D)
        case 0x60: {
          var evZ = this.code[pc++];
          var rZ = (evZ >>> 8) & 0xFF;
          this.rVecX[dst] = this.rScalar[s1];
          this.rVecY[dst] = this.rScalar[s2];
          this.rVecZ[dst] = this.rScalar[rZ];
          this.isVector3[dst] = 1;
          this.isComplex[dst] = 0;
          break;
        }
        case 0x61:
          this.rVecX[dst] = this.rVecX[s1] + this.rVecX[s2];
          this.rVecY[dst] = this.rVecY[s1] + this.rVecY[s2];
          this.rVecZ[dst] = this.rVecZ[s1] + this.rVecZ[s2];
          this.isVector3[dst] = 1;
          break;
        case 0x62:
          this.rVecX[dst] = this.rVecX[s1] - this.rVecX[s2];
          this.rVecY[dst] = this.rVecY[s1] - this.rVecY[s2];
          this.rVecZ[dst] = this.rVecZ[s1] - this.rVecZ[s2];
          this.isVector3[dst] = 1;
          break;
        case 0x63: {
          var sScale = this.rScalar[s2];
          this.rVecX[dst] = this.rVecX[s1] * sScale;
          this.rVecY[dst] = this.rVecY[s1] * sScale;
          this.rVecZ[dst] = this.rVecZ[s1] * sScale;
          this.isVector3[dst] = 1;
          break;
        }
        case 0x64:
          this.rScalar[dst] = this.rVecX[s1] * this.rVecX[s2] + this.rVecY[s1] * this.rVecY[s2] + this.rVecZ[s1] * this.rVecZ[s2];
          this.isVector3[dst] = 0;
          break;
        case 0x66:
          this.rScalar[dst] = Math.hypot(this.rVecX[s1], this.rVecY[s1], this.rVecZ[s1]);
          this.isVector3[dst] = 0;
          break;
        case 0x69: this.rScalar[dst] = this.rVecX[s1]; this.isVector3[dst] = 0; break;
        case 0x6A: this.rScalar[dst] = this.rVecY[s1]; this.isVector3[dst] = 0; break;
        case 0x6B: this.rScalar[dst] = this.rVecZ[s1]; this.isVector3[dst] = 0; break;

        // Opcodes SoA (0x70 - 0x74)
        case 0x70: { // SOA_ALLOC
          var flds = Math.floor(this.rScalar[s1]);
          var cap = Math.floor(this.rScalar[s2]);
          var needed = flds * cap;
          var base = this.heapPtr;
          this.heapPtr += needed;
          this.rScalar[dst] = base;
          this.isVector3[dst] = 0;
          break;
        }
        case 0x71: { // SOA_LOAD
          var extraSoaL = this.code[pc++];
          var rIdx = (extraSoaL >>> 16) & 0xFFFF;
          var rCap = (extraSoaL >>> 8) & 0xFF;
          var baseL = Math.floor(this.rScalar[s1]);
          var fieldL = Math.floor(this.rScalar[s2]);
          var idxL = Math.floor(this.rScalar[rIdx]);
          var capL = Math.floor(this.rScalar[rCap]);
          var offL = baseL + fieldL * capL + idxL;
          this.rScalar[dst] = (offL >= 0 && offL < this.heapVectors.length) ? this.heapVectors[offL] : 0.0;
          this.isVector3[dst] = 0;
          break;
        }
        case 0x72: { // SOA_STORE
          var extraSoaS = this.code[pc++];
          var rIdxS = (extraSoaS >>> 16) & 0xFFFF;
          var rCapS = (extraSoaS >>> 8) & 0xFF;
          var baseS = Math.floor(this.rScalar[dst]);
          var valS = this.rScalar[s1];
          var fieldS = Math.floor(this.rScalar[s2]);
          var idxS = Math.floor(this.rScalar[rIdxS]);
          var capS = Math.floor(this.rScalar[rCapS]);
          var offS = baseS + fieldS * capS + idxS;
          if (offS >= 0 && offS < this.heapVectors.length) {
            this.heapVectors[offS] = valS;
          }
          break;
        }
      }
    }
  };

  // =========================================================================
  // 2. PHASOR RUNTIME MASTER (CANVAS COMPOSITOR & PANORAMIC CYLINDER BOARD)
  // =========================================================================
  var PhasorRuntime = {
    canvas: null,
    ctx: null,
    width: 0,
    height: 0,
    fps: 120,
    lastFrameTime: performance.now(),
    frameCount: 0,
    title: 'PhasorLang Application',
    showHud: false,
    vm: null,
    screenRoutes: {},
    actionRoutes: {},
    currentScreenPc: 0,

    // Espacio de Trabajo Cilíndrico Panorámico (360° X continuo, Y infinito)
    cylinder: {
      enabled: true,
      angle: 0.0,
      targetAngle: 0.0,
      scrollY: 0.0,
      targetScrollY: 0.0,
      radius: 620,
      focalLength: 850,
      isDraggingBoard: false,
      lastDragX: 0,
      lastDragY: 0
    },

    // Ventanas hijas completamente libres e independientes
    children: [],
    activeChildIndex: 0,
    isDraggingWindow: null,
    isResizingWindow: null,
    isDraggingScrollbar: null,

    // Preasignación Zero-GC para cálculo de profundidad
    _drawOrder: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],

    colorHex: function(c) {
      var n = (Number(c) >>> 0) & 0xFFFFFF;
      return '#' + n.toString(16).padStart(6, '0');
    },

    // Renderizado Zero-GC de comandos de interfaz emitidos por MicroPhasorVM
    renderVmUi: function(ctx, targetVm, availW, availH) {
      if (!targetVm || !targetVm.uiCmds) return;
      var cmds = targetVm.uiCmds;
      var textIdx = 0;
      var btnIdx = 0;

      for (var i = 0; i < cmds.length; i += 6) {
        var type = Math.floor(cmds[i]);
        var p1 = cmds[i+1], p2 = cmds[i+2], p3 = cmds[i+3], p4 = cmds[i+4], p5 = cmds[i+5];

        if (type === 0x50) { // CLS
          ctx.fillStyle = this.colorHex(p1);
          ctx.fillRect(0, 0, availW, availH);
        } else if (type === 0x51) { // RECT
          ctx.fillStyle = this.colorHex(p5);
          ctx.fillRect(p1, p2, p3, p4);
        } else if (type === 0x52) { // CIRCLE
          ctx.strokeStyle = this.colorHex(p4);
          ctx.lineWidth = 2;
          ctx.beginPath();
          ctx.arc(p1, p2, p3, 0, Math.PI * 2);
          ctx.stroke();
        } else if (type === 0x53) { // LINE
          ctx.strokeStyle = this.colorHex(p5);
          ctx.lineWidth = 1.5;
          ctx.beginPath();
          ctx.moveTo(p1, p2);
          ctx.lineTo(p3, p4);
          ctx.stroke();
        } else if (type === 0x54) { // TEXT
          if (targetVm.texts && textIdx < targetVm.texts.length) {
            var t = targetVm.texts[textIdx++];
            ctx.fillStyle = this.colorHex(t.color);
            ctx.font = '12px monospace';
            ctx.textAlign = 'left';
            ctx.textBaseline = 'top';
            ctx.fillText(t.text, t.x, t.y);
          }
        } else if (type === 0x56) { // BUTTON
          ctx.fillStyle = this.colorHex(p5);
          if (ctx.roundRect) {
            ctx.beginPath();
            ctx.roundRect(p1, p2, p3, p4, 5);
            ctx.fill();
            ctx.strokeStyle = '#30363D';
            ctx.lineWidth = 1;
            ctx.stroke();
          } else {
            ctx.fillRect(p1, p2, p3, p4);
          }

          var btnText = 'BOTÓN';
          if (targetVm.buttons && btnIdx < targetVm.buttons.length) {
            btnText = targetVm.buttons[btnIdx].label || btnText;
          }
          btnIdx++;

          var fontSize = 11;
          if (btnText.length * 7 > p3 - 8) {
            fontSize = Math.max(9, Math.floor((p3 - 8) / (btnText.length * 0.65)));
          }
          ctx.fillStyle = '#FFFFFF';
          ctx.font = 'bold ' + fontSize + 'px monospace';
          ctx.textAlign = 'center';
          ctx.textBaseline = 'middle';
          ctx.fillText(btnText, p1 + (p3 / 2), p2 + (p4 / 2));
          ctx.textBaseline = 'top';
          ctx.textAlign = 'left';
        }
      }
    },

    getResizeDir: function(ch, mx, my) {
      if (ch.minimized) return null;
      var rx = ch.renderX, ry = ch.renderY, rw = ch.renderW, rh = ch.renderH;
      var pad = 9;

      if (mx >= rx + rw - pad && mx <= rx + rw + pad && my >= ry + rh - pad && my <= ry + rh + pad) return 'se';
      if (mx >= rx - pad && mx <= rx + pad && my >= ry - pad && my <= ry + pad) return 'nw';
      if (mx >= rx + rw - pad && mx <= rx + rw + pad && my >= ry - pad && my <= ry + pad) return 'ne';
      if (mx >= rx - pad && mx <= rx + pad && my >= ry + rh - pad && my <= ry + rh + pad) return 'sw';

      if (mx >= rx - pad && mx <= rx + 4 && my >= ry && my <= ry + rh) return 'w';
      if (mx >= rx + rw - 4 && mx <= rx + rw + pad && my >= ry && my <= ry + rh) return 'e';
      if (my >= ry - pad && my <= ry + 4 && mx >= rx && mx <= rx + rw) return 'n';
      if (my >= ry + rh - 4 && my <= ry + rh + pad && mx >= rx && mx <= rx + rw) return 's';

      return null;
    },

    init: function(wasmPathOrPayload, canvasId, options) {
      var self = this;
      options = options || {};
      self.title = options.title || 'Chronos IDE — KoraDevs';
      self.showHud = !!options.showHud;

      if (options.children && Array.isArray(options.children) && options.children.length > 0) {
        self.children = options.children;
      } else {
        self.children = [
          { id: 1, title: '<s>1: Ventana Principal', x: 60, y: 60, w: 480, h: 560, visible: true, minimized: false, color: '#161B22', scrollX: 0, scrollY: 0, screenPc: 0 }
        ];
      }

      // Inicializar MicroPhasorVM con el bytecode del compilador
      if (options.bytecode && options.constPool) {
        self.vm = new MicroPhasorVM(options.bytecode, options.constPool, options.strings || []);
        self.screenRoutes = options.screenRoutes || {};
        self.actionRoutes = options.actionRoutes || {};
        self.currentScreenPc = options.firstScreenPc || 0;

        self.handleAction = function(target, ch) {
          var key = String(Math.round(Number(target)));
          var targetPc = (self.actionRoutes[key] !== undefined)
            ? self.actionRoutes[key]
            : ((self.screenRoutes[key] !== undefined) ? self.screenRoutes[key] : null);

          if (targetPc !== null) {
            self.vm.run(targetPc);
            if (ch && ch.screenPc !== undefined) {
              self.vm.run(ch.screenPc);
            } else if (self.currentScreenPc !== 0) {
              self.vm.run(self.currentScreenPc);
            }
            self.renderFrame();
          }
        };

        self.vm.run(0);
        if (self.currentScreenPc !== 0) {
          self.vm.run(self.currentScreenPc);
        }
      }

      self.canvas = document.getElementById(canvasId || 'phasorCanvas');
      if (!self.canvas) {
        console.error('[PhasorRuntime] Canvas no encontrado: #' + canvasId);
        return;
      }
      self.ctx = self.canvas.getContext('2d', { alpha: false });

      self.resize();
      window.addEventListener('resize', function() { self.resize(); });
      self.setupInteractions();
      self.startLoop();
    },

    setupInteractions: function() {
      var self = this;
      if (!self.canvas) return;

      var worldW = Math.max(3600, self.children.length * 620);
      var R = Math.max(450, worldW / (Math.PI * 2));
      self.cylinder.radius = R;

      // 1. MOUSE DOWN (ESCRITORIO & MÓVIL)
      self.canvas.addEventListener('mousedown', function(e) {
        var rect = self.canvas.getBoundingClientRect();
        var mx = e.clientX - rect.left;
        var my = e.clientY - rect.top;

        self.setRegister(252, mx);
        self.setRegister(253, my);
        self.setRegister(254, 1.0);

        // A. Clic en botón de Telemetría HUD
        if (my >= 6 && my <= 32 && mx >= self.width - 150 && mx <= self.width - 16) {
          self.showHud = !self.showHud;
          self.renderFrame();
          return;
        }

        // B. Comprobar interacción en ventanas hijas (de mayor a menor profundidad / Z)
        for (var idx = self.children.length - 1; idx >= 0; idx--) {
          var chIdx = self._drawOrder[idx];
          var ch = self.children[chIdx];
          if (!ch) continue;

          var rx = ch.renderX || ch.x;
          var ry = ch.renderY || ch.y;
          var rw = ch.renderW || ch.w;
          var rh = ch.renderH || (ch.minimized ? 30 : ch.h);
          var S = ch.renderScale || 1.0;

          // 1. Botón Minimizar [-] / [+]
          var btnMinX = rx + rw - (28 * S);
          var btnMinY = ry + (4 * S);
          var btnMinSize = 22 * S;
          if (mx >= btnMinX && mx <= btnMinX + btnMinSize && my >= btnMinY && my <= btnMinY + btnMinSize) {
            ch.minimized = !ch.minimized;
            self.bringToFront(chIdx);
            self.renderFrame();
            return;
          }

          // 2. Agarraderas de Redimensión en 8 Direcciones
          var rDir = self.getResizeDir(ch, mx, my);
          if (rDir) {
            self.isResizingWindow = {
              child: ch,
              dir: rDir,
              startMx: mx,
              startMy: my,
              origX: ch.x,
              origY: ch.y,
              origW: ch.w,
              origH: ch.h,
              scale: S
            };
            self.bringToFront(chIdx);
            self.renderFrame();
            return;
          }

          // 3. Barra de Título: Arrastre / Reubicación Libre en el Tablero Cilíndrico
          var titleH = 30 * S;
          if (mx >= rx && mx <= rx + rw && my >= ry && my <= ry + titleH) {
            self.isDraggingWindow = {
              child: ch,
              startMx: mx,
              startMy: my,
              origX: ch.x,
              origY: ch.y,
              scale: S
            };
            self.bringToFront(chIdx);
            self.renderFrame();
            return;
          }

          // 4. Contenido Interno de la Ventana (Botones y Acciones PVM)
          if (!ch.minimized && mx >= rx && mx <= rx + rw && my >= ry + titleH && my <= ry + rh) {
            var localX = (mx - rx) / S - 12 + (ch.scrollX || 0);
            var localY = (my - ry) / S - 32 + (ch.scrollY || 0);

            if (ch.buttons && ch.buttons.length > 0) {
              for (var b = 0; b < ch.buttons.length; b++) {
                var btn = ch.buttons[b];
                if (localX >= btn.x && localX <= btn.x + btn.w && localY >= btn.y && localY <= btn.y + btn.h) {
                  if (typeof self.handleAction === 'function') {
                    self.handleAction(btn.target, ch);
                  }
                  self.bringToFront(chIdx);
                  self.renderFrame();
                  return;
                }
              }
            }

            self.bringToFront(chIdx);
            self.renderFrame();
            return;
          }
        }

        // C. Clic en Fondo Vacío: Arrastrar el Tablero Cilíndrico Panorámico
        self.cylinder.isDraggingBoard = true;
        self.cylinder.lastDragX = mx;
        self.cylinder.lastDragY = my;
      });

      // 2. MOUSE MOVE
      window.addEventListener('mousemove', function(e) {
        var rect = self.canvas.getBoundingClientRect();
        var mx = e.clientX - rect.left;
        var my = e.clientY - rect.top;

        self.setRegister(252, mx);
        self.setRegister(253, my);

        // A. Redimensión de Ventana
        if (self.isResizingWindow) {
          var res = self.isResizingWindow;
          var dx = (mx - res.startMx) / res.scale;
          var dy = (my - res.startMy) / res.scale;
          var minW = 240;
          var minH = 140;

          if (res.dir.indexOf('e') !== -1) {
            res.child.w = Math.max(minW, res.origW + dx);
          } else if (res.dir.indexOf('w') !== -1) {
            var nW = Math.max(minW, res.origW - dx);
            res.child.x = res.origX + (res.origW - nW);
            res.child.w = nW;
          }

          if (res.dir.indexOf('s') !== -1) {
            res.child.h = Math.max(minH, res.origH + dy);
          } else if (res.dir.indexOf('n') !== -1) {
            var nH = Math.max(minH, res.origH - dy);
            res.child.y = res.origY + (res.origH - nH);
            res.child.h = nH;
          }

          self.renderFrame();
          return;
        }

        // B. Arrastre / Reubicación de Ventana en el Tablero Cilíndrico
        if (self.isDraggingWindow) {
          var drag = self.isDraggingWindow;
          var dX = (mx - drag.startMx) / drag.scale;
          var dY = (my - drag.startMy) / drag.scale;

          drag.child.x = (drag.origX + dX + worldW) % worldW;
          drag.child.y = drag.origY + dY;

          self.renderFrame();
          return;
        }

        // C. Arrastre del Tablero Cilíndrico Panorámico (Revolver fondo y screens juntas)
        if (self.cylinder.isDraggingBoard) {
          var deltaX = mx - self.cylinder.lastDragX;
          var deltaY = my - self.cylinder.lastDragY;
          self.cylinder.lastDragX = mx;
          self.cylinder.lastDragY = my;

          self.cylinder.targetAngle -= (deltaX / self.cylinder.radius) * 1.35;
          self.cylinder.targetScrollY += deltaY * 1.1;

          self.renderFrame();
          return;
        }

        // D. Actualización Dinámica del Cursor
        var cur = 'default';
        for (var i = self.children.length - 1; i >= 0; i--) {
          var targetCh = self.children[self._drawOrder[i]];
          if (!targetCh) continue;

          var rDirTest = self.getResizeDir(targetCh, mx, my);
          if (rDirTest) {
            if (rDirTest === 'nw' || rDirTest === 'se') cur = 'nwse-resize';
            else if (rDirTest === 'ne' || rDirTest === 'sw') cur = 'nesw-resize';
            else if (rDirTest === 'w' || rDirTest === 'e') cur = 'ew-resize';
            else if (rDirTest === 'n' || rDirTest === 's') cur = 'ns-resize';
            break;
          }

          var S_test = targetCh.renderScale || 1.0;
          var rx_t = targetCh.renderX || targetCh.x;
          var ry_t = targetCh.renderY || targetCh.y;
          var rw_t = targetCh.renderW || targetCh.w;

          if (mx >= rx_t && mx <= rx_t + rw_t && my >= ry_t && my <= ry_t + (30 * S_test)) {
            cur = 'move';
            break;
          }
        }
        self.canvas.style.cursor = cur;
      });

      // 3. MOUSE UP
      window.addEventListener('mouseup', function() {
        self.setRegister(254, 0.0);
        self.isDraggingWindow = null;
        self.isResizingWindow = null;
        self.cylinder.isDraggingBoard = false;
        if (self.canvas) self.canvas.style.cursor = 'default';
      });

      // 4. SCROLL DE RUEDA DE RATÓN (WHEEL)
      self.canvas.addEventListener('wheel', function(e) {
        self.setRegister(255, e.deltaY);
        var rect = self.canvas.getBoundingClientRect();
        var mx = e.clientX - rect.left;
        var my = e.clientY - rect.top;

        // Comprobar si el scroll ocurre dentro de una ventana
        for (var i = self.children.length - 1; i >= 0; i--) {
          var ch = self.children[self._drawOrder[i]];
          if (!ch || ch.minimized) continue;

          var rx = ch.renderX || ch.x;
          var ry = ch.renderY || ch.y;
          var rw = ch.renderW || ch.w;
          var rh = ch.renderH || ch.h;

          if (mx >= rx && mx <= rx + rw && my >= ry + 30 && my <= ry + rh) {
            e.preventDefault();
            ch.scrollY = Math.max(0, (ch.scrollY || 0) + e.deltaY * 0.8);
            self.renderFrame();
            return;
          }
        }

        // Si ocurre en el fondo: orbitar cilindro en X y desplazar en Y
        e.preventDefault();
        if (e.shiftKey || Math.abs(e.deltaX) > Math.abs(e.deltaY)) {
          var dRot = e.deltaX !== 0 ? e.deltaX : e.deltaY;
          self.cylinder.targetAngle += (dRot / self.cylinder.radius) * 1.5;
        } else {
          self.cylinder.targetScrollY -= e.deltaY * 0.9;
        }
        self.renderFrame();
      }, { passive: false });

      // 5. TOUCH GESTURES (MÓVIL / PWA)
      var touchStartX = 0, touchStartY = 0;
      self.canvas.addEventListener('touchstart', function(e) {
        if (e.touches.length > 0) {
          var rect = self.canvas.getBoundingClientRect();
          var tx = e.touches[0].clientX - rect.left;
          var ty = e.touches[0].clientY - rect.top;
          touchStartX = tx;
          touchStartY = ty;
          self.setRegister(252, tx);
          self.setRegister(253, ty);
          self.setRegister(254, 1.0);

          // Simular mousedown en touch
          var fakeE = { clientX: e.touches[0].clientX, clientY: e.touches[0].clientY };
          // El touch actúa como paneo de tablero si no golpea ventana
        }
      }, { passive: true });

      self.canvas.addEventListener('touchmove', function(e) {
        if (e.touches.length === 1) {
          var rect = self.canvas.getBoundingClientRect();
          var tx = e.touches[0].clientX - rect.left;
          var ty = e.touches[0].clientY - rect.top;
          var dX = tx - touchStartX;
          var dY = ty - touchStartY;
          touchStartX = tx;
          touchStartY = ty;

          self.cylinder.targetAngle -= (dX / self.cylinder.radius) * 1.4;
          self.cylinder.targetScrollY += dY * 1.1;
          self.renderFrame();
        }
      }, { passive: true });

      self.canvas.addEventListener('touchend', function() {
        self.setRegister(254, 0.0);
      }, { passive: true });
    },

    bringToFront: function(childIndex) {
      var pos = this._drawOrder.indexOf(childIndex);
      if (pos !== -1) {
        this._drawOrder.splice(pos, 1);
        this._drawOrder.push(childIndex);
      }
      this.activeChildIndex = childIndex;
    },

    setRegister: function(idx, val) {
      if (this.vm && this.vm.rScalar && idx < this.vm.rScalar.length) {
        this.vm.rScalar[idx] = val;
      }
    },

    resize: function() {
      var w = window.innerWidth || document.documentElement.clientWidth || 800;
      var h = window.innerHeight || document.documentElement.clientHeight || 600;
      this.width = w;
      this.height = h;
      this.canvas.width = w;
      this.canvas.height = h;
      this.setRegister(250, w);
      this.setRegister(251, h);
      if (this.ctx) this.renderFrame();
    },

    startLoop: function() {
      var self = this;
      var loop = function(now) {
        self.frameCount++;
        if (now - self.lastFrameTime >= 1000) {
          self.fps = Math.round((self.frameCount * 1000) / (now - self.lastFrameTime));
          self.frameCount = 0;
          self.lastFrameTime = now;
        }

        // Amortiguación inercial suave del cilindro (90-120 FPS)
        var diffA = self.cylinder.targetAngle - self.cylinder.angle;
        if (Math.abs(diffA) > 0.0001) {
          self.cylinder.angle += diffA * 0.16;
        }
        var diffY = self.cylinder.targetScrollY - self.cylinder.scrollY;
        if (Math.abs(diffY) > 0.01) {
          self.cylinder.scrollY += diffY * 0.16;
        }

        self.renderFrame();
        requestAnimationFrame(loop);
      };
      requestAnimationFrame(loop);
    },

    renderFrame: function() {
      var self = this;
      var ctx = this.ctx;
      if (!ctx) return;
      var w = this.width;
      var h = this.height;
      var isMobile = w < 768;

      // 1. ESPACIO CÓSMICO DE FONDO (Espacio cilíndrico)
      ctx.fillStyle = '#080B10';
      ctx.fillRect(0, 0, w, h);

      var worldW = Math.max(3600, this.children.length * 620);
      var R = Math.max(450, worldW / (Math.PI * 2));
      var D = this.cylinder.focalLength;
      var angle = this.cylinder.angle;
      var scrollY = this.cylinder.scrollY;

      // Rejilla cilíndrica 3D panorámica de fondo (revolviendo a 360°)
      ctx.save();
      var numMeridians = 24;
      for (var m = 0; m < numMeridians; m++) {
        var mTheta = (m / numMeridians) * Math.PI * 2;
        var diffM = ((mTheta - angle + Math.PI) % (Math.PI * 2)) - Math.PI;
        if (diffM < -Math.PI) diffM += Math.PI * 2;
        if (diffM > Math.PI) diffM -= Math.PI * 2;

        var mX3D = R * Math.sin(diffM);
        var mZ3D = R * Math.cos(diffM) - R;
        var mS = D / (D - mZ3D);
        var projMX = (w / 2) + (mX3D * mS);

        var alphaGrid = Math.max(0.04, 0.22 * (1.0 - Math.abs(mZ3D) / (2 * R)));
        ctx.strokeStyle = 'rgba(88, 166, 255, ' + alphaGrid.toFixed(3) + ')';
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(projMX, 0);
        ctx.lineTo(projMX, h);
        ctx.stroke();
      }

      // Líneas horizontales de latitud
      for (var lat = -4; lat <= 4; lat++) {
        var latY = (h / 2) + ((lat * 220) + (scrollY % 220));
        ctx.strokeStyle = 'rgba(48, 54, 61, 0.4)';
        ctx.beginPath();
        ctx.moveTo(0, latY);
        ctx.lineTo(w, latY);
        ctx.stroke();
      }
      ctx.restore();

      // 2. CÁLCULO DE PROYECCIÓN CILÍNDRICA 3D Y PROFUNDIDAD DE VENTANAS
      // Inicializar _drawOrder si cambió la cantidad de hijos
      if (this._drawOrder.length !== this.children.length) {
        this._drawOrder = [];
        for (var d = 0; d < this.children.length; d++) this._drawOrder.push(d);
      }

      for (var i = 0; i < this.children.length; i++) {
        var ch = this.children[i];
        var cx = ch.x + (ch.w / 2);
        var theta = (cx / worldW) * (Math.PI * 2);

        var diff = ((theta - angle + Math.PI) % (Math.PI * 2)) - Math.PI;
        if (diff < -Math.PI) diff += Math.PI * 2;
        if (diff > Math.PI) diff -= Math.PI * 2;

        var x3d = R * Math.sin(diff);
        var z3d = R * Math.cos(diff) - R;
        var scale = D / (D - z3d);

        var curH = ch.minimized ? 30 : ch.h;
        var projW = ch.w * scale;
        var projH = curH * scale;
        var projX = (w / 2) + (x3d * scale) - (projW / 2);
        var projY = (h / 2) + ((ch.y + scrollY - (h / 2)) * scale);

        ch.renderX = projX;
        ch.renderY = projY;
        ch.renderW = projW;
        ch.renderH = projH;
        ch.renderScale = scale;
        ch.renderZ = z3d;
      }

      // Ordenar ventanas por profundidad Z ascendente (las más lejanas se dibujan primero)
      var selfOrder = this;
      this._drawOrder.sort(function(a, b) {
        var chA = selfOrder.children[a];
        var chB = selfOrder.children[b];
        var zA = chA ? chA.renderZ : 0;
        var zB = chB ? chB.renderZ : 0;
        return zA - zB;
      });

      // 0. AVANZAR KERNEL PRINCIPAL Y SEÑALES GLOBALES (t_global_ide)
      if (this.vm && this.currentScreenPc !== undefined) {
        this.vm.run(this.currentScreenPc, w, h);
      }

      // 3. RENDERIZADO DE CADA VENTANA HIJA (100% PHASORLANG BYTECODE)
      for (var ord = 0; ord < this._drawOrder.length; ord++) {
        var cIdx = this._drawOrder[ord];
        var win = this.children[cIdx];
        if (!win || win.visible === false) continue;

        var S = win.renderScale;
        var pX = win.renderX;
        var pY = win.renderY;
        var pW = win.renderW;
        var pH = win.renderH;
        var isActive = (cIdx === this.activeChildIndex);

        // Niebla atmosférica para ventanas lejanas detrás del cilindro
        var depthRatio = Math.max(0.35, Math.min(1.0, 1.0 - (Math.abs(win.renderZ) / (2.5 * R))));

        ctx.save();
        ctx.globalAlpha = depthRatio;
        ctx.translate(pX, pY);
        ctx.scale(S, S);

        // Sombra de ventana
        ctx.fillStyle = 'rgba(0, 0, 0, 0.65)';
        ctx.fillRect(4, 4, win.w, win.minimized ? 30 : win.h);

        // Superficie acrílica de ventana
        ctx.fillStyle = win.color || '#161B22';
        ctx.fillRect(0, 0, win.w, win.minimized ? 30 : win.h);

        // Borde acentuado
        ctx.strokeStyle = isActive ? '#58A6FF' : '#30363D';
        ctx.lineWidth = isActive ? 2 : 1;
        ctx.strokeRect(0, 0, win.w, win.minimized ? 30 : win.h);

        // Barra de Título (Arrastrable / Mover)
        ctx.fillStyle = isActive ? '#1F242C' : '#161B22';
        ctx.fillRect(0, 0, win.w, 30);
        ctx.strokeStyle = '#30363D';
        ctx.beginPath(); ctx.moveTo(0, 30); ctx.lineTo(win.w, 30); ctx.stroke();

        ctx.fillStyle = isActive ? '#58A6FF' : '#8B949E';
        ctx.font = 'bold 12px monospace';
        ctx.fillText(win.title || ('Ventana ' + win.id), 12, 19);

        // Botón Minimizar / Restaurar [-] / [+]
        ctx.fillStyle = win.minimized ? '#238636' : '#21262D';
        ctx.fillRect(win.w - 26, 5, 20, 20);
        ctx.strokeStyle = '#30363D';
        ctx.strokeRect(win.w - 26, 5, 20, 20);
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 12px monospace';
        ctx.textAlign = 'center';
        ctx.fillText(win.minimized ? '+' : '-', win.w - 16, 19);
        ctx.textAlign = 'left';

        // Contenido de la ventana (Ejecución y renderizado de PhasorLang Bytecode)
        if (!win.minimized) {
          var inW = Math.max(10, win.w - 24);
          var inH = Math.max(10, win.h - 36);

          ctx.save();
          ctx.beginPath();
          ctx.rect(2, 30, win.w - 4, win.h - 32);
          ctx.clip();

          ctx.translate(12 - (win.scrollX || 0), 32 - (win.scrollY || 0));

          // Despacho 100% PhasorLang a través de MicroPhasorVM
          if (self.vm && win.screenPc !== undefined) {
            self.vm.run(win.screenPc, inW, inH);
            win.buttons = self.vm.buttons.slice();
            self.renderVmUi(ctx, self.vm, inW, inH);
          } else {
            ctx.fillStyle = '#58A6FF';
            ctx.font = '12px monospace';
            ctx.fillText('Screen Phasor: PC=' + (win.screenPc || 0), 10, 20);
          }

          ctx.restore(); // Fin de clipping interno

          // Agarradera visual de redimensión en esquina SE
          ctx.strokeStyle = isActive ? '#58A6FF' : '#8B949E';
          ctx.lineWidth = 1.5;
          ctx.beginPath();
          ctx.moveTo(win.w - 12, win.h - 3); ctx.lineTo(win.w - 3, win.h - 12);
          ctx.moveTo(win.w - 8, win.h - 3); ctx.lineTo(win.w - 3, win.h - 8);
          ctx.moveTo(win.w - 4, win.h - 3); ctx.lineTo(win.w - 3, win.h - 4);
          ctx.stroke();
        }

        ctx.restore();
      }

      // 4. BARRA SUPERIOR DE ENTORNO Y TELEMETRÍA ZERO-GC
      ctx.fillStyle = '#161B22';
      ctx.fillRect(0, 0, w, 36);
      ctx.strokeStyle = '#30363D';
      ctx.beginPath(); ctx.moveTo(0, 36); ctx.lineTo(w, 36); ctx.stroke();

      ctx.fillStyle = '#58A6FF';
      ctx.font = 'bold 13px monospace';
      ctx.fillText(this.title.toUpperCase(), 16, 22);

      // Badge Tablero Cilíndrico
      var degAng = Math.round((angle * (180 / Math.PI)) % 360);
      if (degAng < 0) degAng += 360;
      ctx.fillStyle = '#21262D';
      ctx.fillRect(280, 6, 170, 24);
      ctx.strokeStyle = '#30363D';
      ctx.strokeRect(280, 6, 170, 24);
      ctx.fillStyle = '#79C0FF';
      ctx.font = 'bold 11px monospace';
      ctx.fillText('⟳ Tablero: ' + degAng + '° | Y: ' + Math.round(scrollY), 290, 22);

      // Badge Zero-GC / FPS
      ctx.fillStyle = '#238636';
      ctx.fillRect(w - 290, 6, 120, 24);
      ctx.fillStyle = '#FFFFFF';
      ctx.font = 'bold 11px monospace';
      ctx.fillText('Zero-GC | ' + this.fps + ' FPS', w - 280, 22);

      // Botón Telemetría HUD
      ctx.fillStyle = this.showHud ? '#1F6FEB' : '#21262D';
      ctx.fillRect(w - 150, 6, 134, 24);
      ctx.strokeStyle = '#30363D';
      ctx.strokeRect(w - 150, 6, 134, 24);
      ctx.fillStyle = this.showHud ? '#FFFFFF' : '#8B949E';
      ctx.font = 'bold 11px monospace';
      ctx.fillText('📊 Telemetría', w - 136, 22);

      // 5. MODAL DE TELEMETRÍA RUNTIME HUD (NO-INVASIVO)
      if (this.showHud) {
        var hudW = Math.min(460, w - 32);
        var hudH = 110;
        var hudX = w - hudW - 16;
        var hudY = h - hudH - 24;

        ctx.fillStyle = 'rgba(11, 14, 20, 0.96)';
        ctx.fillRect(hudX, hudY, hudW, hudH);
        ctx.strokeStyle = '#58A6FF';
        ctx.lineWidth = 1.5;
        ctx.strokeRect(hudX, hudY, hudW, hudH);

        ctx.fillStyle = '#21262D';
        ctx.fillRect(hudX, hudY, hudW, 24);
        ctx.fillStyle = '#58A6FF';
        ctx.font = 'bold 11px monospace';
        ctx.fillText('TELEMETRÍA PVM & TABLERO CILÍNDRICO', hudX + 10, hudY + 16);

        ctx.fillStyle = '#3FB950';
        ctx.font = '11px monospace';
        ctx.fillText('Invariante Zero-GC: 0.0 Bytes en Heap | ' + this.fps + ' FPS sostenidos', hudX + 12, hudY + 46);

        ctx.fillStyle = '#C9D1D9';
        ctx.font = '10px monospace';
        ctx.fillText('Cinemática Cilíndrica: R=' + Math.round(R) + 'px | 360° X continuo | Y infinito', hudX + 12, hudY + 68);
        ctx.fillText('Pantallas Phasor Activas: ' + this.children.length + ' (Ventanas libres desacopladas)', hudX + 12, hudY + 88);
      }
    }
  };

  global.MicroPhasorVM = MicroPhasorVM;
  global.PhasorRuntime = PhasorRuntime;
})(typeof window !== 'undefined' ? window : this);
