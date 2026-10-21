const fs = require('fs');
const path = require('path');

const newRuntime = `  // =========================================================================
  // 2. PHASOR RUNTIME UNIVERSAL (SOVEREIGN ZERO-GC BYTECODE RUNNER & I/O BRIDGE)
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
    vm: null,
    screenRoutes: {},
    actionRoutes: {},
    currentScreenPc: 0,

    colorHex: function(c) {
      var n = (Number(c) >>> 0) & 0xFFFFFF;
      return '#' + n.toString(16).padStart(6, '0');
    },

    setRegister: function(reg, val) {
      if (this.vm && this.vm.rScalar && reg >= 0 && reg < 1024) {
        this.vm.rScalar[reg] = val;
      }
    },

    resize: function() {
      if (!this.canvas) return;
      var w = window.innerWidth;
      var h = window.innerHeight;
      this.canvas.width = w;
      this.canvas.height = h;
      this.width = w;
      this.height = h;
      this.setRegister(250, w);
      this.setRegister(251, h);
    },

    init: function(wasmPathOrPayload, canvasId, options) {
      var self = this;
      options = options || {};
      self.title = options.title || 'PhasorLang Application';

      self.canvas = document.getElementById(canvasId || 'phasorCanvas');
      if (!self.canvas) {
        console.error('[PhasorRuntime] Canvas no encontrado: #' + canvasId);
        return;
      }
      self.ctx = self.canvas.getContext('2d', { alpha: false });

      // Inicializar MicroPhasorVM con el bytecode del compilador
      if (options.bytecode && options.constPool) {
        self.vm = new MicroPhasorVM(options.bytecode, options.constPool, options.strings || []);
        self.screenRoutes = options.screenRoutes || {};
        self.actionRoutes = options.actionRoutes || {};
        self.currentScreenPc = options.firstScreenPc || 0;

        self.handleAction = function(target) {
          var key = String(Math.round(Number(target)));
          var targetPc = (self.actionRoutes[key] !== undefined)
            ? self.actionRoutes[key]
            : ((self.screenRoutes[key] !== undefined) ? self.screenRoutes[key] : null);

          if (targetPc !== null) {
            self.vm.run(targetPc, self.width, self.height);
          }
        };

        // Ejecutar bloque inicial de inicialización (PC = 0)
        self.vm.run(0, window.innerWidth, window.innerHeight);
      }

      self.resize();
      window.addEventListener('resize', function() { self.resize(); });
      self.setupInteractions();
      self.startLoop();
    },

    setupInteractions: function() {
      var self = this;
      if (!self.canvas) return;

      // 1. POINTER DOWN (Botones y acciones declaradas en código Phasor)
      self.canvas.addEventListener('pointerdown', function(e) {
        var rect = self.canvas.getBoundingClientRect();
        var mx = e.clientX - rect.left;
        var my = e.clientY - rect.top;

        self.setRegister(252, mx);
        self.setRegister(253, my);
        self.setRegister(254, 1.0);

        // Despacho de botones registrados por la VM
        if (self.vm && self.vm.buttons && self.vm.buttons.length > 0) {
          for (var b = self.vm.buttons.length - 1; b >= 0; b--) {
            var btn = self.vm.buttons[b];
            if (mx >= btn.x && mx <= btn.x + btn.w && my >= btn.y && my <= btn.y + btn.h) {
              if (typeof self.handleAction === 'function') {
                self.handleAction(btn.target);
              }
              return;
            }
          }
        }
      });

      // 2. POINTER MOVE (Hover y coordenadas)
      window.addEventListener('pointermove', function(e) {
        var rect = self.canvas.getBoundingClientRect();
        var mx = e.clientX - rect.left;
        var my = e.clientY - rect.top;

        self.setRegister(252, mx);
        self.setRegister(253, my);

        var isHover = false;
        if (self.vm && self.vm.buttons) {
          for (var b = 0; b < self.vm.buttons.length; b++) {
            var btn = self.vm.buttons[b];
            if (mx >= btn.x && mx <= btn.x + btn.w && my >= btn.y && my <= btn.y + btn.h) {
              isHover = true;
              break;
            }
          }
        }
        self.canvas.style.cursor = isHover ? 'pointer' : 'default';
      });

      // 3. POINTER UP
      window.addEventListener('pointerup', function() {
        self.setRegister(254, 0.0);
      });

      // 4. WHEEL (Scroll R255)
      self.canvas.addEventListener('wheel', function(e) {
        self.setRegister(255, e.deltaY);
      }, { passive: true });
    },

    startLoop: function() {
      var self = this;
      var loop = function(now) {
        self.frameCount++;
        if (now - self.lastFrameTime >= 1000) {
          self.fps = self.frameCount;
          self.frameCount = 0;
          self.lastFrameTime = now;
        }

        self.renderFrame();
        requestAnimationFrame(loop);
      };
      requestAnimationFrame(loop);
    },

    renderFrame: function() {
      var ctx = this.ctx;
      if (!ctx || !this.vm) return;
      var w = this.width;
      var h = this.height;

      // 1. Ejecutar pantalla activa en PhasorVM (Zero-GC, 120 FPS)
      this.vm.run(this.currentScreenPc, w, h);

      // 2. Rasterizar comandos gráficos emitidos por el código Phasor
      this.renderVmUi(ctx, this.vm, w, h);
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
            ctx.font = (t.size || 12) + 'px monospace';
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
    }
  };

  global.MicroPhasorVM = MicroPhasorVM;
  global.PhasorRuntime = PhasorRuntime;
})(typeof window !== 'undefined' ? window : this);
`;

function processFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const splitMarker = '// =========================================================================\n  // 2. PHASOR RUNTIME MASTER';
  const altMarker = 'var PhasorRuntime = {';
  let idx = content.indexOf(splitMarker);
  if (idx === -1) {
    idx = content.indexOf(altMarker);
    // Find preceding line break
    idx = content.lastIndexOf('\n', idx);
  }
  if (idx === -1) {
    console.error('Marker not found in:', filePath);
    return;
  }
  const prefix = content.substring(0, idx + 1);
  const updated = prefix + newRuntime;
  fs.writeFileSync(filePath, updated, 'utf8');
  console.log('Successfully updated:', filePath, '->', fs.statSync(filePath).size, 'bytes');
}

processFile('phasor_runtime.js');
if (fs.existsSync('runtime/phasor_runtime.js')) {
  processFile('runtime/phasor_runtime.js');
}
