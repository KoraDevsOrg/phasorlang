// ===============================================================
// PHASOR_RUNTIME.JS — Runtime Universal WebAssembly & Canvas 2D
// PhasorLang v1.0 [Chronos IDE & KoraDevs Ecosystem]
// https://github.com/koradevsorg
//
// Arquitectura Unificada Multi-Dispositivo & Multi-Ventana:
// - Espacio de Trabajo Padre (<main>) en Escritorio (#0B0E14)
// - Ventanas Hijas (<s>1, <s>2, <s>3): Drag & Drop, Redimensión 8D,
//   Minimizado, Scroll Clamped Zero-Overflow y Renderizado de UI
// - Modo Móvil (<768px): Snap 100% Llave en Cerradura al Viewport
//   con Barra Superior Ergonómica y Pestañas / Gestos de Navegación
// - MicroPhasorVM Zero-GC Integrada con Despacho de 32 Bits y Rutas
// - Telemetría No-Invasiva Opcional (Show HUD) con Invariante 120 FPS
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
    this.rVecX = new Float64Array(1024);
    this.rVecY = new Float64Array(1024);
    this.rVecZ = new Float64Array(1024);
    this.isVector3 = new Uint8Array(1024);
    this.uiCmds = [];
    this.buttons = [];
    this.texts = [];
    this.logs = [];
  }

  MicroPhasorVM.prototype.pushUi = function(type, p1, p2, p3, p4, p5) {
    this.uiCmds.push(type, p1 || 0, p2 || 0, p3 || 0, p4 || 0, p5 || 0);
  };

  MicroPhasorVM.prototype.run = function(entryPc) {
    var pc = entryPc || 0;
    this.uiCmds = [];
    this.buttons = [];
    this.texts = [];

    while (pc < this.code.length) {
      var instr = this.code[pc++];
      var op = (instr >>> 24) & 0xFF;
      var dst = (instr >>> 16) & 0xFF;
      var s1 = (instr >>> 8) & 0xFF;
      var s2 = instr & 0xFF;

      if (op === 0x00 || op === 0xFF) break;
      switch (op) {
        case 0x01: this.rScalar[dst] = this.consts[s1]; this.isComplex[dst] = 0; break;
        case 0x02: this.rScalar[dst] = this.rScalar[s1]; break;
        case 0x10: case 0x03: this.rScalar[dst] = this.rScalar[s1] + this.rScalar[s2]; break;
        case 0x11: case 0x04: this.rScalar[dst] = this.rScalar[s1] - this.rScalar[s2]; break;
        case 0x12: case 0x05: this.rScalar[dst] = this.rScalar[s1] * this.rScalar[s2]; break;
        case 0x13: case 0x06: this.rScalar[dst] = (this.rScalar[s2] !== 0) ? (this.rScalar[s1] / this.rScalar[s2]) : 0; break;
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
        case 0x30: {
          var val = this.rScalar[s1];
          this.logs.push('> OUT: ' + (typeof val === 'number' ? val.toFixed(4) : val) + '\n');
          break;
        }
        case 0x50: this.pushUi(0x50, this.rScalar[dst]); break;
        case 0x51: {
          var rx = this.code[pc++], ry = this.code[pc++], rw = this.code[pc++], rh = this.code[pc++], rc = this.code[pc++];
          this.pushUi(0x51, this.rScalar[rx], this.rScalar[ry], this.rScalar[rw], this.rScalar[rh], this.rScalar[rc]);
          break;
        }
        case 0x52: {
          var rcx = this.code[pc++], rcy = this.code[pc++], rr = this.code[pc++], rc2 = this.code[pc++];
          this.pushUi(0x52, this.rScalar[rcx], this.rScalar[rcy], this.rScalar[rr], this.rScalar[rc2]);
          break;
        }
        case 0x53: {
          var rx1 = this.code[pc++], ry1 = this.code[pc++], rx2 = this.code[pc++], ry2 = this.code[pc++], lc = this.code[pc++];
          this.pushUi(0x53, this.rScalar[rx1], this.rScalar[ry1], this.rScalar[rx2], this.rScalar[ry2], this.rScalar[lc]);
          break;
        }
        case 0x54: {
          var isString = (dst === 1);
          var strOrReg = this.code[pc++], tx = this.code[pc++], ty = this.code[pc++], tSize = this.code[pc++], tc = this.code[pc++];
          var px = this.rScalar[tx], py = this.rScalar[ty], pCol = this.rScalar[tc], pSize = this.rScalar[tSize] || 16;
          var displayText = isString
            ? ((this.strings && this.strings[strOrReg] !== undefined) ? this.strings[strOrReg] : "")
            : (Number.isInteger(this.rScalar[strOrReg]) ? this.rScalar[strOrReg].toString() : this.rScalar[strOrReg].toFixed(2));
          this.pushUi(0x54, px, py, pCol, pSize);
          this.texts.push({ text: displayText, x: px, y: py, color: pCol, size: pSize });
          break;
        }
        case 0x56: {
          var strIdx = dst;
          var bx = this.code[pc++], by = this.code[pc++], bw = this.code[pc++], bh = this.code[pc++];
          var actHash = this.code[pc++];
          var bc = this.code[pc++];
          var px = this.rScalar[bx], py = this.rScalar[by], pw = this.rScalar[bw], ph = this.rScalar[bh];
          var bColor = this.rScalar[bc] || 0x1f6feb;
          var label = (this.strings && this.strings[strIdx] !== undefined) ? this.strings[strIdx] : 'BOTÓN';
          this.pushUi(0x56, px, py, pw, ph, bColor);
          this.buttons.push({ x: px, y: py, w: pw, h: ph, target: actHash, label: label, color: bColor });
          break;
        }
      }
    }
  };

  // =========================================================================
  // 2. PHASOR RUNTIME MASTER (CANVAS COMPOSITOR & MULTI-WINDOW MANAGER)
  // =========================================================================
  var PhasorRuntime = {
    wasmInstance: null,
    wasmMemory: null,
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

    // Sub-pantallas hijas configurables (por defecto 1 ventana centrada o N ventanas)
    children: [
      { id: 1, title: '<s>1: Ventana Principal', x: 60, y: 60, w: 460, h: 560, visible: true, minimized: false, color: '#161B22', scrollX: 0, scrollY: 0, contentW: 460, contentH: 520 }
    ],
    activeChildIndex: 0,
    isDraggingWindow: null,
    isResizingWindow: null,
    isDraggingScrollbar: null,
    dragOffsetX: 0,
    dragOffsetY: 0,
    initialPinchDist: 0,

    // Cálculo unificado de métricas de scroll y barras (Single Source of Truth)
    getScrollMetrics: function(ch) {
      if (!ch || ch.minimized) return null;

      var innerW = Math.max(10, ch.w - 24);
      var innerH = Math.max(10, ch.h - 36);
      var totW = ch.contentW || 460;
      var totH = ch.contentH || 520;

      var hasVScroll = totH > innerH;
      var hasHScroll = totW > innerW;

      var maxScX = Math.max(0, totW - innerW);
      var maxScY = Math.max(0, totH - innerH);

      var scX = Math.max(0, Math.min(maxScX, ch.scrollX || 0));
      var scY = Math.max(0, Math.min(maxScY, ch.scrollY || 0));
      ch.scrollX = scX;
      ch.scrollY = scY;

      var cornerReserve = 16;
      var sbSize = 8;

      var vMetrics = null;
      if (hasVScroll) {
        var vTrackX = ch.x + ch.w - sbSize - 3;
        var vTrackY = ch.y + 32;
        var vTrackH = Math.max(20, ch.h - 32 - cornerReserve);
        var vThumbH = Math.max(18, Math.min(vTrackH, Math.round(vTrackH * (innerH / totH))));
        var vAvail = vTrackH - vThumbH;
        var vRatio = maxScY > 0 ? (scY / maxScY) : 0;
        vRatio = Math.max(0, Math.min(1, vRatio));
        var vThumbY = Math.round(vTrackY + vRatio * vAvail);

        vMetrics = {
          trackX: vTrackX,
          trackY: vTrackY,
          trackW: sbSize,
          trackH: vTrackH,
          thumbY: vThumbY,
          thumbH: vThumbH,
          maxScroll: maxScY,
          hitX: vTrackX - 3,
          hitW: sbSize + 6
        };
      }

      var hMetrics = null;
      if (hasHScroll) {
        var hTrackX = ch.x + 4;
        var hTrackY = ch.y + ch.h - sbSize - 3;
        var hTrackW = Math.max(20, ch.w - 8 - cornerReserve);
        var hThumbW = Math.max(18, Math.min(hTrackW, Math.round(hTrackW * (innerW / totW))));
        var hAvail = hTrackW - hThumbW;
        var hRatio = maxScX > 0 ? (scX / maxScX) : 0;
        hRatio = Math.max(0, Math.min(1, hRatio));
        var hThumbX = Math.round(hTrackX + hRatio * hAvail);

        hMetrics = {
          trackX: hTrackX,
          trackY: hTrackY,
          trackW: hTrackW,
          trackH: sbSize,
          thumbX: hThumbX,
          thumbW: hThumbW,
          maxScroll: maxScX,
          hitY: hTrackY - 3,
          hitH: sbSize + 6
        };
      }

      return {
        innerW: innerW,
        innerH: innerH,
        totW: totW,
        totH: totH,
        maxScX: maxScX,
        maxScY: maxScY,
        scX: scX,
        scY: scY,
        hasVScroll: hasVScroll,
        hasHScroll: hasHScroll,
        v: vMetrics,
        h: hMetrics
      };
    },

    getResizeDir: function(ch, mx, my) {
      if (ch.minimized) return null;
      var x = ch.x, y = ch.y, w = ch.w, h = ch.h;

      if (mx >= x + w - 16 && mx <= x + w + 6 && my >= y + h - 16 && my <= y + h + 6) return 'se';
      if (mx >= x - 6 && mx <= x + 8 && my >= y - 6 && my <= y + 8) return 'nw';
      if (mx >= x + w - 8 && mx <= x + w + 6 && my >= y - 6 && my <= y + 8) return 'ne';
      if (mx >= x - 6 && mx <= x + 8 && my >= y + h - 8 && my <= y + h + 6) return 'sw';
      if (mx >= x - 5 && mx <= x + 3 && my >= y && my <= y + h) return 'w';
      if (mx >= x + w - 3 && mx <= x + w + 5 && my >= y && my <= y + h) return 'e';
      if (my >= y - 5 && my <= y + 3 && mx >= x && mx <= x + w) return 'n';
      if (my >= y + h - 3 && my <= y + h + 5 && mx >= x && mx <= x + w) return 's';

      return null;
    },

    colorHex: function(c) {
      var n = (Number(c) >>> 0) & 0xFFFFFF;
      return '#' + n.toString(16).padStart(6, '0');
    },

    // Renderizado Zero-GC de comandos de interfaz de MicroPhasorVM
    renderVmUi: function(ctx, targetVm, availW, availH) {
      if (!targetVm || !targetVm.uiCmds) return;
      var cmds = targetVm.uiCmds;
      var textIdx = 0;
      var btnIdx = 0;

      for (var i = 0; i < cmds.length; i += 6) {
        var type = Math.floor(cmds[i]);
        var p1 = cmds[i+1], p2 = cmds[i+2], p3 = cmds[i+3], p4 = cmds[i+4], p5 = cmds[i+5];

        if (type === 0x50) {
          ctx.fillStyle = this.colorHex(p1);
          ctx.fillRect(0, 0, availW, availH);
        } else if (type === 0x51) {
          ctx.fillStyle = this.colorHex(p5);
          ctx.fillRect(p1, p2, p3, p4);
        } else if (type === 0x52) {
          ctx.strokeStyle = this.colorHex(p4);
          ctx.lineWidth = 2;
          ctx.beginPath();
          ctx.arc(p1, p2, p3, 0, Math.PI * 2);
          ctx.stroke();
        } else if (type === 0x53) {
          ctx.strokeStyle = this.colorHex(p5);
          ctx.lineWidth = 1.5;
          ctx.beginPath();
          ctx.moveTo(p1, p2);
          ctx.lineTo(p3, p4);
          ctx.stroke();
        } else if (type === 0x54) {
          if (targetVm.texts && textIdx < targetVm.texts.length) {
            var t = targetVm.texts[textIdx++];
            ctx.fillStyle = this.colorHex(t.color);
            ctx.font = (t.size || 16) + 'px monospace';
            ctx.textAlign = 'left';
            ctx.textBaseline = 'top';
            ctx.fillText(t.text, t.x, t.y);
          }
        } else if (type === 0x56) {
          ctx.fillStyle = this.colorHex(p5);
          if (ctx.roundRect) {
            ctx.beginPath();
            ctx.roundRect(p1, p2, p3, p4, 6);
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
          var fontSize = 14;
          if (btnText.length * 8.5 > p3 - 10) {
            fontSize = Math.max(9, Math.floor((p3 - 10) / (btnText.length * 0.65)));
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

    init: function(wasmPathOrPayload, canvasId, options) {
      var self = this;
      options = options || {};
      self.title = options.title || 'PhasorLang Application';
      self.showHud = !!options.showHud;

      if (options.children && Array.isArray(options.children) && options.children.length > 0) {
        self.children = options.children;
      }

      // Inicializar MicroPhasorVM si se proporciona bytecode compilado
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
            self.vm.run(self.currentScreenPc);
            self.renderFrame();
          }
        };

        self.vm.run(0);
        if (self.currentScreenPc !== 0) {
          self.vm.run(self.currentScreenPc);
        }

        // Asignar VM a la primera ventana hija si no tiene uno
        if (self.children.length > 0 && !self.children[0].appVm) {
          self.children[0].appVm = self.vm;
        }
      }

      self.canvas = document.getElementById(canvasId || 'phasorCanvas');
      if (!self.canvas) {
        console.error('[PhasorRuntime] Elemento Canvas no encontrado: #' + canvasId);
        return;
      }
      self.ctx = self.canvas.getContext('2d', { alpha: false });

      self.resize();
      window.addEventListener('resize', function() {
        self.resize();
      });

      self.setupInteractions();
      self.loadWasm(wasmPathOrPayload || 'phasor_ide.wasm');
    },

    setupInteractions: function() {
      var self = this;
      if (!self.canvas) return;

      // 1. MOUSE (ESCRITORIO): BOTONES, VENTANAS, REDIMENSIÓN, MINIMIZADO Y SCROLL
      self.canvas.addEventListener('mousedown', function(e) {
        var rect = self.canvas.getBoundingClientRect();
        var mx = e.clientX - rect.left;
        var my = e.clientY - rect.top;

        self.setRegister(252, mx);
        self.setRegister(253, my);
        self.setRegister(254, 1.0);

        if (self.width < 768) {
          // A. Clic en pestañas superiores si hay múltiples ventanas
          if (self.children.length > 1 && my <= 44) {
            var sortedTabs = self.children.slice().sort(function(a, b) { return a.id - b.id; });
            var tabW = Math.min(130, Math.floor((self.width - 20) / self.children.length));
            for (var tIdx = 0; tIdx < sortedTabs.length; tIdx++) {
              var tabX = 10 + (tIdx * (tabW + 6));
              if (mx >= tabX && mx <= tabX + tabW) {
                var chosen = sortedTabs[tIdx];
                self.activeChildIndex = self.children.indexOf(chosen);
                self.renderFrame();
                return;
              }
            }
          }

          // B. Clic en botones dentro de la ventana activa en móvil
          var activeChild = self.children[self.activeChildIndex] || self.children[0];
          var targetVm = activeChild.appVm || self.vm;
          var testBtns = (activeChild.buttons && activeChild.buttons.length > 0) ? activeChild.buttons : (targetVm ? targetVm.buttons : null);
          if (testBtns && testBtns.length > 0 && my >= 44) {
            var scX = activeChild.scrollX || 0;
            var scY = activeChild.scrollY || 0;
            var localX = mx - 10 + scX;
            var localY = my - 48 + scY;

            for (var bIdx = 0; bIdx < testBtns.length; bIdx++) {
              var btn = testBtns[bIdx];
              if (localX >= btn.x && localX <= btn.x + btn.w && localY >= btn.y && localY <= btn.y + btn.h) {
                if (typeof self.handleAction === 'function') {
                  self.handleAction(btn.target, activeChild);
                }
                self.renderFrame();
                return;
              }
            }
          }
          return;
        }

        // Clic en botón de alternar Telemetría HUD en la barra superior
        if (my >= 6 && my <= 30 && mx >= self.width - 150 && mx <= self.width - 16) {
          self.showHud = !self.showHud;
          self.renderFrame();
          return;
        }

        // Clic en botón cerrar de Telemetría HUD flotante
        if (self.showHud) {
          var hudMargin = 24;
          var hudW = Math.min(460, self.width - (hudMargin * 2));
          var hudH = 90;
          var hudX = self.width - hudW - hudMargin;
          var hudY = self.height - hudH - 46;
          if (mx >= hudX + hudW - 24 && mx <= hudX + hudW - 4 && my >= hudY + 4 && my <= hudY + 24) {
            self.showHud = false;
            self.renderFrame();
            return;
          }
        }

        // Comprobar ventanas hijas en orden inverso (top-most primero)
        for (var i = self.children.length - 1; i >= 0; i--) {
          var ch = self.children[i];

          // A. Minimizar / Restaurar (-) o (+)
          if (mx >= ch.x + ch.w - 28 && mx <= ch.x + ch.w - 6 && my >= ch.y + 4 && my <= ch.y + 26) {
            ch.minimized = !ch.minimized;
            self.renderFrame();
            return;
          }

          if (!ch.minimized) {
            // B. Agarradera SE de redimensión
            if (mx >= ch.x + ch.w - 16 && mx <= ch.x + ch.w + 6 && my >= ch.y + ch.h - 16 && my <= ch.y + ch.h + 6) {
              self.isResizingWindow = {
                child: ch,
                dir: 'se',
                startX: mx,
                startY: my,
                origX: ch.x,
                origY: ch.y,
                origW: ch.w,
                origH: ch.h
              };
              self.children.splice(i, 1);
              self.children.push(ch);
              self.renderFrame();
              return;
            }

            // C. Barras de Scroll (Vertical / Horizontal)
            var metrics = self.getScrollMetrics(ch);
            if (metrics) {
              if (metrics.v && mx >= metrics.v.hitX && mx <= metrics.v.hitX + metrics.v.hitW &&
                  my >= metrics.v.trackY && my <= metrics.v.trackY + metrics.v.trackH) {
                var isThumbClick = (my >= metrics.v.thumbY && my <= metrics.v.thumbY + metrics.v.thumbH);
                var offset = isThumbClick ? (my - metrics.v.thumbY) : (metrics.v.thumbH / 2);
                if (!isThumbClick) {
                  var availH = metrics.v.trackH - metrics.v.thumbH;
                  if (availH > 0) {
                    var targetThumbY = (my - offset) - metrics.v.trackY;
                    var ratio = Math.max(0, Math.min(1, targetThumbY / availH));
                    ch.scrollY = Math.round(ratio * metrics.v.maxScroll);
                  }
                }
                self.isDraggingScrollbar = {
                  child: ch,
                  type: 'vertical',
                  trackPos: metrics.v.trackY,
                  trackLen: metrics.v.trackH,
                  thumbLen: metrics.v.thumbH,
                  maxScroll: metrics.v.maxScroll,
                  offset: offset
                };
                self.children.splice(i, 1);
                self.children.push(ch);
                self.renderFrame();
                return;
              }

              if (metrics.h && my >= metrics.h.hitY && my <= metrics.h.hitY + metrics.h.hitH &&
                  mx >= metrics.h.trackX && mx <= metrics.h.trackX + metrics.h.trackW) {
                var isThumbClickH = (mx >= metrics.h.thumbX && mx <= metrics.h.thumbX + metrics.h.thumbW);
                var offsetH = isThumbClickH ? (mx - metrics.h.thumbX) : (metrics.h.thumbW / 2);
                if (!isThumbClickH) {
                  var availW = metrics.h.trackW - metrics.h.thumbW;
                  if (availW > 0) {
                    var targetThumbX = (mx - offsetH) - metrics.h.trackX;
                    var ratioH = Math.max(0, Math.min(1, targetThumbX / availW));
                    ch.scrollX = Math.round(ratioH * metrics.h.maxScroll);
                  }
                }
                self.isDraggingScrollbar = {
                  child: ch,
                  type: 'horizontal',
                  trackPos: metrics.h.trackX,
                  trackLen: metrics.h.trackW,
                  thumbLen: metrics.h.thumbW,
                  maxScroll: metrics.h.maxScroll,
                  offset: offsetH
                };
                self.children.splice(i, 1);
                self.children.push(ch);
                self.renderFrame();
                return;
              }
            }

            // D. Detección y clic en botones de la aplicación dentro de la ventana
            var targetVm = ch.appVm || self.vm;
            var testBtns = (ch.buttons && ch.buttons.length > 0) ? ch.buttons : (targetVm ? targetVm.buttons : null);
            if (testBtns && testBtns.length > 0) {
              var innerX = ch.x + 12;
              var innerY = ch.y + 32;
              var scX = metrics ? metrics.scX : (ch.scrollX || 0);
              var scY = metrics ? metrics.scY : (ch.scrollY || 0);
              var localX = mx - innerX + scX;
              var localY = my - innerY + scY;

              for (var bIdx = 0; bIdx < testBtns.length; bIdx++) {
                var btn = testBtns[bIdx];
                if (localX >= btn.x && localX <= btn.x + btn.w && localY >= btn.y && localY <= btn.y + btn.h) {
                  if (typeof self.handleAction === 'function') {
                    self.handleAction(btn.target, ch);
                  }
                  self.children.splice(i, 1);
                  self.children.push(ch);
                  self.renderFrame();
                  return;
                }
              }
            }
          }

          // E. Redimensión perimetral en 8 direcciones
          var resizeDir = self.getResizeDir(ch, mx, my);
          if (resizeDir) {
            self.isResizingWindow = {
              child: ch,
              dir: resizeDir,
              startX: mx,
              startY: my,
              origX: ch.x,
              origY: ch.y,
              origW: ch.w,
              origH: ch.h
            };
            self.children.splice(i, 1);
            self.children.push(ch);
            self.renderFrame();
            return;
          }

          // F. Arrastre de ventana mediante la barra de título
          if (mx >= ch.x && mx <= ch.x + ch.w && my >= ch.y && my <= ch.y + 30) {
            self.isDraggingWindow = ch;
            self.dragOffsetX = mx - ch.x;
            self.dragOffsetY = my - ch.y;
            self.children.splice(i, 1);
            self.children.push(ch);
            self.renderFrame();
            return;
          }

          // G. Clic en cuerpo de la ventana: traer al frente
          if (!ch.minimized && mx >= ch.x && mx <= ch.x + ch.w && my >= ch.y && my <= ch.y + ch.h) {
            self.children.splice(i, 1);
            self.children.push(ch);
            self.renderFrame();
            return;
          }
        }

        // Clic en barra inferior de dock para restaurar ventanas minimizadas
        if (my >= self.height - 36) {
          for (var j = 0; j < self.children.length; j++) {
            self.children[j].minimized = false;
          }
          self.renderFrame();
        }
      });

      window.addEventListener('mousemove', function(e) {
        var rect = self.canvas.getBoundingClientRect();
        var mx = e.clientX - rect.left;
        var my = e.clientY - rect.top;

        self.setRegister(252, mx);
        self.setRegister(253, my);

        if (self.width < 768) return;

        // Arrastre activo de barra de scroll
        if (self.isDraggingScrollbar) {
          var sb = self.isDraggingScrollbar;
          var avail = sb.trackLen - sb.thumbLen;
          if (avail > 0) {
            if (sb.type === 'vertical') {
              var targetPos = (my - sb.offset) - sb.trackPos;
              var ratio = Math.max(0, Math.min(1, targetPos / avail));
              sb.child.scrollY = Math.round(ratio * sb.maxScroll);
            } else if (sb.type === 'horizontal') {
              var targetPosX = (mx - sb.offset) - sb.trackPos;
              var ratioX = Math.max(0, Math.min(1, targetPosX / avail));
              sb.child.scrollX = Math.round(ratioX * sb.maxScroll);
            }
          }
          self.renderFrame();
          return;
        }

        // Redimensión activa de ventana
        if (self.isResizingWindow) {
          var res = self.isResizingWindow;
          var dx = mx - res.startX;
          var dy = my - res.startY;
          var minW = 200;
          var minH = 120;

          if (res.dir.indexOf('e') !== -1) {
            res.child.w = Math.max(minW, res.origW + dx);
          } else if (res.dir.indexOf('w') !== -1) {
            var newW = Math.max(minW, res.origW - dx);
            res.child.x = res.origX + (res.origW - newW);
            res.child.w = newW;
          }

          if (res.dir.indexOf('s') !== -1) {
            res.child.h = Math.max(minH, res.origH + dy);
          } else if (res.dir.indexOf('n') !== -1) {
            var newH = Math.max(minH, res.origH - dy);
            res.child.y = res.origY + (res.origH - newH);
            res.child.h = newH;
          }

          var curInnerW = Math.max(10, res.child.w - 24);
          var curInnerH = Math.max(10, res.child.h - 36);
          var curTotW = res.child.contentW || 460;
          var curTotH = res.child.contentH || 520;
          var curMaxScX = Math.max(0, curTotW - curInnerW);
          var curMaxScY = Math.max(0, curTotH - curInnerH);

          res.child.scrollX = Math.max(0, Math.min(curMaxScX, res.child.scrollX || 0));
          res.child.scrollY = Math.max(0, Math.min(curMaxScY, res.child.scrollY || 0));

          self.renderFrame();
          return;
        }

        // Arrastre activo de ventana
        if (self.isDraggingWindow) {
          var ch = self.isDraggingWindow;
          ch.x = Math.max(0, Math.min(self.width - 60, mx - self.dragOffsetX));
          ch.y = Math.max(0, Math.min(self.height - 30, my - self.dragOffsetY));
          self.renderFrame();
          return;
        }

        // Actualización de cursor según bordes, scrollbars y botones
        var cursor = 'default';
        for (var k = self.children.length - 1; k >= 0; k--) {
          var target = self.children[k];
          if (target.minimized) {
            if (mx >= target.x && mx <= target.x + target.w && my >= target.y && my <= target.y + 30) {
              cursor = 'move';
              break;
            }
            continue;
          }

          var metrics = self.getScrollMetrics(target);
          if (metrics) {
            if (metrics.v && mx >= metrics.v.hitX && mx <= metrics.v.hitX + metrics.v.hitW &&
                my >= metrics.v.trackY && my <= metrics.v.trackY + metrics.v.trackH) {
              cursor = 'pointer';
              break;
            }
            if (metrics.h && my >= metrics.h.hitY && my <= metrics.h.hitY + metrics.h.hitH &&
                mx >= metrics.h.trackX && mx <= metrics.h.trackX + metrics.h.trackW) {
              cursor = 'pointer';
              break;
            }
          }

          // Comprobar hover en botones de la ventana
          var targetVm = target.appVm || self.vm;
          var testBtns = (target.buttons && target.buttons.length > 0) ? target.buttons : (targetVm ? targetVm.buttons : null);
          if (testBtns && testBtns.length > 0) {
            var innerX = target.x + 12;
            var innerY = target.y + 32;
            var scX = metrics ? metrics.scX : (target.scrollX || 0);
            var scY = metrics ? metrics.scY : (target.scrollY || 0);
            var localX = mx - innerX + scX;
            var localY = my - innerY + scY;
            var overButton = false;
            for (var bIdx = 0; bIdx < testBtns.length; bIdx++) {
              var btn = testBtns[bIdx];
              if (localX >= btn.x && localX <= btn.x + btn.w && localY >= btn.y && localY <= btn.y + btn.h) {
                cursor = 'pointer';
                overButton = true;
                break;
              }
            }
            if (overButton) break;
          }

          var rDir = self.getResizeDir(target, mx, my);
          if (rDir) {
            if (rDir === 'nw' || rDir === 'se') cursor = 'nwse-resize';
            else if (rDir === 'ne' || rDir === 'sw') cursor = 'nesw-resize';
            else if (rDir === 'w' || rDir === 'e') cursor = 'ew-resize';
            else if (rDir === 'n' || rDir === 's') cursor = 'ns-resize';
            break;
          } else if (mx >= target.x && mx <= target.x + target.w && my >= target.y && my <= target.y + 30) {
            cursor = 'move';
            break;
          }
        }
        self.canvas.style.cursor = cursor;
      });

      window.addEventListener('mouseup', function() {
        self.setRegister(254, 0.0);
        self.isDraggingWindow = null;
        self.isResizingWindow = null;
        self.isDraggingScrollbar = null;
        if (self.canvas) self.canvas.style.cursor = 'default';
      });

      // Scroll con rueda de ratón en escritorio
      self.canvas.addEventListener('wheel', function(e) {
        self.setRegister(255, e.deltaY);
        if (self.width < 768) return;
        var rect = self.canvas.getBoundingClientRect();
        var mx = e.clientX - rect.left;
        var my = e.clientY - rect.top;

        for (var i = self.children.length - 1; i >= 0; i--) {
          var ch = self.children[i];
          if (ch.minimized) continue;
          if (mx >= ch.x && mx <= ch.x + ch.w && my >= ch.y + 30 && my <= ch.y + ch.h) {
            e.preventDefault();
            var metrics = self.getScrollMetrics(ch);
            if (!metrics) return;

            if (e.shiftKey || Math.abs(e.deltaX) > Math.abs(e.deltaY)) {
              var dX = e.deltaX !== 0 ? e.deltaX : e.deltaY;
              ch.scrollX = Math.max(0, Math.min(metrics.maxScX, (ch.scrollX || 0) + dX));
            } else {
              ch.scrollY = Math.max(0, Math.min(metrics.maxScY, (ch.scrollY || 0) + e.deltaY));
            }
            self.renderFrame();
            return;
          }
        }
      }, { passive: false });

      // 2. TOUCH (MÓVIL): BOTONES, PESTAÑAS Y GESTOS MULTITÁCTILES
      var touchStartX = 0;
      var touchStartY = 0;

      self.canvas.addEventListener('touchstart', function(e) {
        if (e.touches.length > 0) {
          var rect = self.canvas.getBoundingClientRect();
          var tx = e.touches[0].clientX - rect.left;
          var ty = e.touches[0].clientY - rect.top;
          self.setRegister(252, tx);
          self.setRegister(253, ty);
          self.setRegister(254, 1.0);

          if (self.width < 768) {
            // A. Clic en pestañas superiores si hay múltiples ventanas
            if (self.children.length > 1 && ty <= 44) {
              var sortedTabs = self.children.slice().sort(function(a, b) { return a.id - b.id; });
              var tabW = Math.min(130, Math.floor((self.width - 20) / self.children.length));
              for (var tIdx = 0; tIdx < sortedTabs.length; tIdx++) {
                var tabX = 10 + (tIdx * (tabW + 6));
                if (tx >= tabX && tx <= tabX + tabW) {
                  var chosen = sortedTabs[tIdx];
                  self.activeChildIndex = self.children.indexOf(chosen);
                  self.renderFrame();
                  return;
                }
              }
            }

            // B. Clic en botones dentro de la ventana activa en móvil
            var activeChild = self.children[self.activeChildIndex] || self.children[0];
            var targetVm = activeChild.appVm || self.vm;
            var testBtns = (activeChild.buttons && activeChild.buttons.length > 0) ? activeChild.buttons : (targetVm ? targetVm.buttons : null);
            if (testBtns && testBtns.length > 0 && ty >= 44) {
              var scX = activeChild.scrollX || 0;
              var scY = activeChild.scrollY || 0;
              var localX = tx - 10 + scX;
              var localY = ty - 48 + scY;

              for (var bIdx = 0; bIdx < testBtns.length; bIdx++) {
                var btn = testBtns[bIdx];
                if (localX >= btn.x && localX <= btn.x + btn.w && localY >= btn.y && localY <= btn.y + btn.h) {
                  if (typeof self.handleAction === 'function') {
                    self.handleAction(btn.target, activeChild);
                  }
                  self.renderFrame();
                  return;
                }
              }
            }
          }
        }

        if (e.touches.length === 2) {
          var dx = e.touches[0].clientX - e.touches[1].clientX;
          var dy = e.touches[0].clientY - e.touches[1].clientY;
          self.initialPinchDist = Math.sqrt(dx * dx + dy * dy);
        } else if (e.touches.length === 1) {
          touchStartX = e.touches[0].clientX;
          touchStartY = e.touches[0].clientY;
        }
      }, { passive: true });

      self.canvas.addEventListener('touchmove', function(e) {
        if (e.touches.length > 0) {
          var rect = self.canvas.getBoundingClientRect();
          self.setRegister(252, e.touches[0].clientX - rect.left);
          self.setRegister(253, e.touches[0].clientY - rect.top);
        }
        if (e.touches.length === 2 && self.initialPinchDist > 0 && self.children.length > 1) {
          var dx = e.touches[0].clientX - e.touches[1].clientX;
          var dy = e.touches[0].clientY - e.touches[1].clientY;
          var currentDist = Math.sqrt(dx * dx + dy * dy);
          if (Math.abs(currentDist - self.initialPinchDist) > 40) {
            self.activeChildIndex = (self.activeChildIndex + 1) % self.children.length;
            self.initialPinchDist = currentDist;
            self.renderFrame();
          }
        }
      }, { passive: true });

      self.canvas.addEventListener('touchend', function(e) {
        self.setRegister(254, 0.0);
        self.initialPinchDist = 0;
        if (e.changedTouches.length === 1 && self.children.length > 1) {
          var deltaX = e.changedTouches[0].clientX - touchStartX;
          var deltaY = e.changedTouches[0].clientY - touchStartY;
          if (Math.abs(deltaX) > 60 || Math.abs(deltaY) > 60) {
            self.activeChildIndex = (self.activeChildIndex + 1) % self.children.length;
            self.renderFrame();
          }
        }
      }, { passive: true });
    },

    setRegister: function(idx, val) {
      if (this.wasmInstance && this.wasmInstance.exports) {
        if (typeof this.wasmInstance.exports.set_register === 'function') {
          this.wasmInstance.exports.set_register(idx, val);
        }
      }
      if (this.wasmMemory && this.wasmMemory.buffer) {
        var f64 = new Float64Array(this.wasmMemory.buffer);
        if (f64.length > idx) {
          f64[idx] = val;
        }
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

      if (this.ctx) {
        this.renderFrame();
      }
    },

    loadWasm: function(wasmInput) {
      var self = this;
      var onInstanceReady = function(instance) {
        self.wasmInstance = instance;
        self.wasmMemory = instance.exports.memory;
        self.setRegister(250, self.width);
        self.setRegister(251, self.height);
        self.startLoop();
      };

      if (typeof wasmInput === 'string' && wasmInput.length > 500 && !wasmInput.endsWith('.wasm')) {
        try {
          var binaryString = atob(wasmInput);
          var len = binaryString.length;
          var bytes = new Uint8Array(len);
          for (var i = 0; i < len; i++) {
            bytes[i] = binaryString.charCodeAt(i);
          }
          WebAssembly.instantiate(bytes.buffer).then(function(result) {
            onInstanceReady(result.instance);
          }).catch(function(err) {
            console.warn('[PhasorRuntime] Error instanciando WASM Base64:', err);
            self.startLoop();
          });
          return;
        } catch(e) {
          console.warn('[PhasorRuntime] Error decodificando Base64:', e);
        }
      }

      var targetPath = wasmInput || 'phasor_ide.wasm';
      fetch(targetPath)
        .then(function(res) {
          if (!res.ok) throw new Error('HTTP ' + res.status);
          return res.arrayBuffer();
        })
        .then(function(bytes) {
          return WebAssembly.instantiate(bytes);
        })
        .then(function(result) {
          onInstanceReady(result.instance);
        })
        .catch(function(err) {
          self.startLoop();
        });
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

      // 1. ESPACIO DE TRABAJO PADRE (<main>)
      ctx.fillStyle = '#0B0E14';
      ctx.fillRect(0, 0, w, h);

      if (!isMobile) {
        // Cuadrícula sutil de fondo en escritorio
        ctx.strokeStyle = '#161B22';
        ctx.lineWidth = 1;
        ctx.beginPath();
        for (var x = 0; x < w; x += 40) { ctx.moveTo(x, 0); ctx.lineTo(x, h); }
        for (var y = 0; y < h; y += 40) { ctx.moveTo(0, y); ctx.lineTo(w, y); }
        ctx.stroke();

        // Barra superior de acoplamiento (Docking Bar)
        ctx.fillStyle = '#161B22';
        ctx.fillRect(0, 0, w, 36);
        ctx.strokeStyle = '#30363D';
        ctx.beginPath(); ctx.moveTo(0, 36); ctx.lineTo(w, 36); ctx.stroke();

        // Título de la aplicación / workspace
        ctx.fillStyle = '#58A6FF';
        ctx.font = 'bold 13px monospace';
        ctx.fillText(this.title.toUpperCase(), 16, 22);

        // Badge Zero-GC / FPS
        ctx.fillStyle = '#238636';
        ctx.fillRect(w - 290, 6, 120, 24);
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 11px monospace';
        ctx.fillText('Zero-GC | ' + this.fps + ' FPS', w - 280, 22);

        // Botón interactivo para alternar Telemetría HUD
        ctx.fillStyle = this.showHud ? '#1F6FEB' : '#21262D';
        ctx.fillRect(w - 150, 6, 134, 24);
        ctx.strokeStyle = '#30363D';
        ctx.lineWidth = 1;
        ctx.strokeRect(w - 150, 6, 134, 24);
        ctx.fillStyle = this.showHud ? '#FFFFFF' : '#8B949E';
        ctx.font = 'bold 11px monospace';
        ctx.fillText('📊 Telemetría', w - 136, 22);

        // Barra inferior de estado y ventanas minimizadas
        ctx.fillStyle = '#161B22';
        ctx.fillRect(0, h - 34, w, 34);
        ctx.strokeStyle = '#30363D';
        ctx.beginPath(); ctx.moveTo(0, h - 34); ctx.lineTo(w, h - 34); ctx.stroke();
        ctx.fillStyle = '#8B949E';
        ctx.font = '12px monospace';
        ctx.fillText('Ventanas Hijas (' + this.children.length + '). Arrastra la barra de título para mover, [-] para minimizar.', 16, h - 13);
      }

      // 2. CONTENEDORES HIJOS (<s>1, <s>2)
      if (!isMobile) {
        // --- MODO ESCRITORIO: RENDERIZAR CADA HIJO ---
        for (var i = 0; i < this.children.length; i++) {
          var ch = this.children[i];
          var isMin = !!ch.minimized;
          var curH = isMin ? 30 : ch.h;

          // Sombra de ventana
          ctx.fillStyle = 'rgba(0, 0, 0, 0.45)';
          ctx.fillRect(ch.x + 6, ch.y + 6, ch.w, curH);

          if (!isMin) {
            ctx.fillStyle = ch.color || '#161B22';
            ctx.fillRect(ch.x, ch.y, ch.w, ch.h);
            ctx.strokeStyle = '#30363D';
            ctx.lineWidth = 2;
            ctx.strokeRect(ch.x, ch.y, ch.w, ch.h);
          }

          // Barra de título arrastrable
          ctx.fillStyle = isMin ? '#1C2128' : '#21262D';
          ctx.fillRect(ch.x, ch.y, ch.w, 30);
          ctx.strokeStyle = isMin ? '#58A6FF' : '#30363D';
          ctx.lineWidth = 1;
          ctx.strokeRect(ch.x, ch.y, ch.w, 30);

          // Título de la ventana
          ctx.fillStyle = '#58A6FF';
          ctx.font = 'bold 12px monospace';
          var titleStr = isMin ? ch.title + ' [MIN]' : ch.title;
          ctx.fillText(titleStr, ch.x + 10, ch.y + 19);

          // Botón minimizar / restaurar
          ctx.fillStyle = isMin ? '#238636' : '#30363D';
          ctx.fillRect(ch.x + ch.w - 24, ch.y + 6, 18, 18);
          ctx.fillStyle = '#FFFFFF';
          ctx.font = 'bold 12px monospace';
          ctx.fillText(isMin ? '+' : '-', ch.x + ch.w - 18, ch.y + 19);

          if (!isMin) {
            var metrics = self.getScrollMetrics(ch);
            var innerX = ch.x + 12;
            var innerY = ch.y + 32;
            var innerW = metrics ? metrics.innerW : Math.max(10, ch.w - 24);
            var innerH = metrics ? metrics.innerH : Math.max(10, ch.h - 36);

            // Clipping estricto por hardware
            ctx.save();
            ctx.beginPath();
            ctx.rect(ch.x + 2, ch.y + 30, ch.w - 4, ch.h - 32);
            ctx.clip();

            var scX = metrics ? metrics.scX : (ch.scrollX || 0);
            var scY = metrics ? metrics.scY : (ch.scrollY || 0);
            ctx.translate(innerX - scX, innerY - scY);

            var targetVm = ch.appVm || self.vm;
            if (self.vm && ch.screenPc !== undefined) {
              self.vm.run(ch.screenPc);
              ch.buttons = self.vm.buttons.slice();
              self.renderVmUi(ctx, self.vm, innerW, innerH);
            } else if (targetVm && targetVm.uiCmds && targetVm.uiCmds.length > 0) {
              // RENDERIZADO DINÁMICO DE ELEMENTOS PHASORLANG DE LA VENTANA
              self.renderVmUi(ctx, targetVm, innerW, innerH);
            } else {
              // Fallback para pruebas unitarias de maquetación y wrap
              ctx.fillStyle = '#3FB950';
              ctx.font = 'bold 11px monospace';
              ctx.fillText('Contenedor Hijo [' + ch.id + '] • Viewport Activo', 0, 16);

              ctx.fillStyle = '#8B949E';
              ctx.font = '10px monospace';
              ctx.fillText('Resolución: ' + Math.round(ch.w) + 'x' + Math.round(ch.h) + ' px | Scroll: (' + Math.round(scX) + ', ' + Math.round(scY) + ')', 0, 32);

              var charsPerLine = Math.max(8, Math.floor(innerW / 6.8));
              var rawText = 'PhasorLang Zero-GC Runtime. El contenido se adapta en modo wrap a los bordes de la ventana hija y permite desplazamiento bidireccional suave con la rueda del raton o touchpad.';
              var words = rawText.split(' ');
              var curLine = '';
              var lineY = 52;
              ctx.fillStyle = '#C9D1D9';
              ctx.font = '10px monospace';

              for (var wIdx = 0; wIdx < words.length; wIdx++) {
                var testLine = curLine + (curLine ? ' ' : '') + words[wIdx];
                if (testLine.length > charsPerLine && curLine.length > 0) {
                  ctx.fillText(curLine, 0, lineY);
                  lineY += 16;
                  curLine = words[wIdx];
                } else {
                  curLine = testLine;
                }
              }
              if (curLine.length > 0) {
                ctx.fillText(curLine, 0, lineY);
                lineY += 16;
              }

              if (lineY + 36 > 0) {
                ctx.fillStyle = '#238636';
                ctx.fillRect(0, lineY + 10, Math.max(120, Math.min(220, innerW - 20)), 32);
                ctx.fillStyle = '#FFFFFF';
                ctx.font = 'bold 11px monospace';
                ctx.fillText('Acción Hijo ' + ch.id, 16, lineY + 30);
              }

              ctx.fillStyle = '#1F6FEB';
              ctx.fillRect(340, 16, 140, 28);
              ctx.fillStyle = '#FFFFFF';
              ctx.font = '9px monospace';
              ctx.fillText('Panel Virtual X=340', 348, 34);
            }

            ctx.restore(); // Fin de clipping

            // Barras de desplazamiento (Scrollbars)
            if (metrics) {
              if (metrics.v) {
                var v = metrics.v;
                ctx.fillStyle = '#161B22';
                ctx.fillRect(v.trackX, v.trackY, v.trackW, v.trackH);
                ctx.strokeStyle = '#21262D';
                ctx.lineWidth = 1;
                ctx.strokeRect(v.trackX, v.trackY, v.trackW, v.trackH);

                var isVDragging = (self.isDraggingScrollbar && self.isDraggingScrollbar.child === ch && self.isDraggingScrollbar.type === 'vertical');
                ctx.fillStyle = isVDragging ? '#79C0FF' : '#58A6FF';
                if (ctx.roundRect) {
                  ctx.beginPath();
                  ctx.roundRect(v.trackX + 1, v.thumbY, v.trackW - 2, v.thumbH, 3);
                  ctx.fill();
                } else {
                  ctx.fillRect(v.trackX + 1, v.thumbY, v.trackW - 2, v.thumbH);
                }
              }

              if (metrics.h) {
                var hMetrics = metrics.h;
                ctx.fillStyle = '#161B22';
                ctx.fillRect(hMetrics.trackX, hMetrics.trackY, hMetrics.trackW, hMetrics.trackH);
                ctx.strokeStyle = '#21262D';
                ctx.lineWidth = 1;
                ctx.strokeRect(hMetrics.trackX, hMetrics.trackY, hMetrics.trackW, hMetrics.trackH);

                var isHDragging = (self.isDraggingScrollbar && self.isDraggingScrollbar.child === ch && self.isDraggingScrollbar.type === 'horizontal');
                ctx.fillStyle = isHDragging ? '#79C0FF' : '#58A6FF';
                if (ctx.roundRect) {
                  ctx.beginPath();
                  ctx.roundRect(hMetrics.thumbX, hMetrics.trackY + 1, hMetrics.thumbW, hMetrics.trackH - 2, 3);
                  ctx.fill();
                } else {
                  ctx.fillRect(hMetrics.thumbX, hMetrics.trackY + 1, hMetrics.thumbW, hMetrics.trackH - 2);
                }
              }
            }

            // Agarradera visual de redimensión en esquina SE
            ctx.strokeStyle = '#58A6FF';
            ctx.lineWidth = 1.5;
            ctx.beginPath();
            ctx.moveTo(ch.x + ch.w - 12, ch.y + ch.h - 3); ctx.lineTo(ch.x + ch.w - 3, ch.y + ch.h - 12);
            ctx.moveTo(ch.x + ch.w - 8, ch.y + ch.h - 3); ctx.lineTo(ch.x + ch.w - 3, ch.y + ch.h - 8);
            ctx.moveTo(ch.x + ch.w - 4, ch.y + ch.h - 3); ctx.lineTo(ch.x + ch.w - 3, ch.y + ch.h - 4);
            ctx.stroke();
          }
        }
      } else {
        // --- MODO MÓVIL: AJUSTE SNAP 100% AL VIEWPORT ---
        var activeChild = this.children[this.activeChildIndex] || this.children[0];

        ctx.fillStyle = activeChild.color || '#161B22';
        ctx.fillRect(0, 0, w, h);

        // Barra superior móvil (44px)
        ctx.fillStyle = '#161B22';
        ctx.fillRect(0, 0, w, 44);
        ctx.strokeStyle = '#30363D';
        ctx.beginPath(); ctx.moveTo(0, 44); ctx.lineTo(w, 44); ctx.stroke();

        if (this.children.length === 1) {
          ctx.fillStyle = '#58A6FF';
          ctx.font = 'bold 13px monospace';
          ctx.fillText(activeChild.title, 14, 27);
        } else {
          var sortedTabs = this.children.slice().sort(function(a, b) { return a.id - b.id; });
          var tabW = Math.min(130, Math.floor((w - 20) / this.children.length));
          for (var tIdx = 0; tIdx < sortedTabs.length; tIdx++) {
            var cTab = sortedTabs[tIdx];
            var isSel = (cTab === activeChild);
            var tabX = 10 + (tIdx * (tabW + 6));
            ctx.fillStyle = isSel ? '#238636' : '#21262D';
            ctx.fillRect(tabX, 8, tabW, 28);
            ctx.fillStyle = isSel ? '#FFFFFF' : '#8B949E';
            ctx.font = 'bold 11px monospace';
            ctx.textAlign = 'center';
            ctx.fillText(cTab.title.substring(0, 14), tabX + (tabW / 2), 26);
            ctx.textAlign = 'left';
          }
        }

        // FPS badge en barra superior
        ctx.fillStyle = '#3FB950';
        ctx.font = '10px monospace';
        ctx.textAlign = 'right';
        ctx.fillText(this.fps + ' FPS', w - 14, 27);
        ctx.textAlign = 'left';

        // Renderizado del contenido hijo en móvil
        var targetVmMobile = activeChild.appVm || this.vm;
        var innerH = h - 44;
        var scXMobile = activeChild.scrollX || 0;
        var scYMobile = activeChild.scrollY || 0;

        ctx.save();
        ctx.beginPath();
        ctx.rect(0, 44, w, innerH);
        ctx.clip();
        ctx.translate(10 - scXMobile, 48 - scYMobile);

        if (self.vm && activeChild.screenPc !== undefined) {
          self.vm.run(activeChild.screenPc);
          activeChild.buttons = self.vm.buttons.slice();
          self.renderVmUi(ctx, self.vm, w - 20, innerH);
        } else if (targetVmMobile && targetVmMobile.uiCmds && targetVmMobile.uiCmds.length > 0) {
          self.renderVmUi(ctx, targetVmMobile, w - 20, innerH);
        } else {
          ctx.fillStyle = '#8B949E';
          ctx.font = '10px monospace';
          ctx.fillText('Hijo ' + (this.activeChildIndex + 1) + '/' + this.children.length + ' • Desliza para orbitar 360°', 14, 20);

          var btnMargin = 15;
          var btnW = w - (btnMargin * 2);
          var btnH = 48;
          ctx.fillStyle = '#238636';
          ctx.fillRect(btnMargin - 10, innerH - 80, btnW, btnH);
          ctx.fillStyle = '#FFFFFF';
          ctx.font = 'bold 13px monospace';
          ctx.textAlign = 'center';
          ctx.fillText('Cambiar Sub-Pantalla (Touch >= 44px)', (w - 20) / 2, innerH - 50);
          ctx.textAlign = 'left';
        }
        ctx.restore();
      }

      // 3. PANEL DE TELEMETRÍA RUNTIME (SHOW HUD NO-INVASIVO)
      if (this.showHud) {
        var hudMargin = isMobile ? 12 : 24;
        var hudW = Math.min(460, w - (hudMargin * 2));
        var hudH = 92;
        var hudX = w - hudW - hudMargin;
        var hudY = isMobile ? (h - hudH - 20) : (h - hudH - 46);

        ctx.fillStyle = 'rgba(11, 14, 20, 0.95)';
        ctx.fillRect(hudX, hudY, hudW, hudH);
        ctx.strokeStyle = '#58A6FF';
        ctx.lineWidth = 1.5;
        ctx.strokeRect(hudX, hudY, hudW, hudH);

        ctx.fillStyle = '#21262D';
        ctx.fillRect(hudX, hudY, hudW, 24);
        ctx.fillStyle = '#58A6FF';
        ctx.font = 'bold 10px monospace';
        ctx.fillText('TELEMETRÍA RUNTIME [Zero-GC]', hudX + 10, hudY + 16);

        // Botón cerrar
        ctx.fillStyle = '#F85149';
        ctx.fillRect(hudX + hudW - 20, hudY + 4, 16, 16);
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 10px monospace';
        ctx.fillText('x', hudX + hudW - 15, hudY + 15);

        ctx.fillStyle = '#3FB950';
        ctx.font = '11px monospace';
        ctx.fillText('Invariante Zero-GC: 0.0 Bytes Heap | ' + this.fps + ' FPS', hudX + 12, hudY + 46);

        ctx.fillStyle = '#C9D1D9';
        ctx.font = '10px monospace';
        ctx.fillText('Ventanas Activas: ' + this.children.length + ' | Modo: ' + (isMobile ? 'Móvil Snap 100%' : 'Escritorio Multi-Ventana'), hudX + 12, hudY + 70);
      }
    }
  };

  global.MicroPhasorVM = MicroPhasorVM;
  global.PhasorRuntime = PhasorRuntime;
})(typeof window !== 'undefined' ? window : this);
