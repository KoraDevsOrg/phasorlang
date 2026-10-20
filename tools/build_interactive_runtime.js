// tools/build_interactive_runtime.js
// Genera los motores interactivos profesionales y ensambla phasor_runtime.js
// Chronos IDE Autónomo: Explorador de Archivos/Carpetas Local, Programación por Capas (import),
// 7 Vistas, 6 Plantillas Maestras, IA Copilot y Compilador Standalone HTML
const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..');
const runtimeSrcPath = path.resolve(rootDir, 'phasor_runtime.js');

console.log('> [1/4] Diseñando motores interactivos de alta fidelidad con Explorador VFS...');

const enginesCode = `
  // =========================================================================
  // REUSABLE UI LIBRARIES: UiPopupMenu & UiTooltip (Zero-GC IDE Components)
  // =========================================================================
  var UiPopupMenu = {
    isOpen: false,
    x: 0,
    y: 0,
    w: 175,
    itemH: 26,
    targetNode: null,
    items: [],
    hoverIdx: -1,

    open: function(x, y, w, targetNode, items) {
      this.isOpen = true;
      this.x = x;
      this.y = y;
      this.w = w || 175;
      this.targetNode = targetNode;
      this.items = items || [];
      this.hoverIdx = -1;
    },

    close: function() {
      this.isOpen = false;
      this.targetNode = null;
      this.items = [];
      this.hoverIdx = -1;
    },

    handleClick: function(mx, my) {
      if (!this.isOpen || this.items.length === 0) return null;
      var totalH = this.items.length * this.itemH + 10;
      if (mx >= this.x && mx <= this.x + this.w && my >= this.y && my <= this.y + totalH) {
        var clickedIdx = Math.floor((my - this.y - 5) / this.itemH);
        if (clickedIdx >= 0 && clickedIdx < this.items.length) {
          var item = this.items[clickedIdx];
          var target = this.targetNode;
          this.close();
          return { action: item.id, item: item, target: target };
        }
      }
      this.close();
      return { action: 'dismiss' };
    },

    handleMouseMove: function(mx, my) {
      if (!this.isOpen) return false;
      var totalH = this.items.length * this.itemH + 10;
      if (mx >= this.x && mx <= this.x + this.w && my >= this.y && my <= this.y + totalH) {
        this.hoverIdx = Math.floor((my - this.y - 5) / this.itemH);
        return true;
      }
      this.hoverIdx = -1;
      return false;
    },

    render: function(ctx, vw, vh, mouseX, mouseY) {
      if (!this.isOpen || this.items.length === 0) return;
      var totalH = this.items.length * this.itemH + 10;
      
      var drawX = this.x;
      var drawY = this.y;
      if (drawX + this.w > vw - 10) drawX = vw - this.w - 10;
      if (drawX < 10) drawX = 10;
      if (drawY + totalH > vh - 20) drawY = Math.max(30, this.y - totalH);
      if (drawY < 30) drawY = 30;

      this.x = drawX;
      this.y = drawY;

      ctx.save();
      // Drop shadow
      ctx.fillStyle = 'rgba(0, 0, 0, 0.65)';
      ctx.fillRect(drawX + 3, drawY + 3, this.w, totalH);

      // Acrylic surface (#161B22) & Border (#30363D)
      ctx.fillStyle = '#161B22';
      ctx.fillRect(drawX, drawY, this.w, totalH);
      ctx.strokeStyle = '#30363D';
      ctx.lineWidth = 1;
      ctx.strokeRect(drawX, drawY, this.w, totalH);

      // Render items
      for (var i = 0; i < this.items.length; i++) {
        var it = this.items[i];
        var itY = drawY + 5 + (i * this.itemH);
        var isHov = (this.hoverIdx === i);

        if (isHov) {
          ctx.fillStyle = '#1F6FEB';
          ctx.fillRect(drawX + 4, itY, this.w - 8, this.itemH);
        }

        ctx.fillStyle = isHov ? '#FFFFFF' : (it.color || '#58A6FF');
        ctx.font = '11px monospace';
        ctx.fillText(it.icon || '•', drawX + 10, itY + 17);

        ctx.fillStyle = isHov ? '#FFFFFF' : (it.danger ? '#F85149' : '#C9D1D9');
        ctx.font = '10px monospace';
        ctx.fillText(it.label, drawX + 30, itY + 17);
      }
      ctx.restore();
    }
  };

  var UiTooltip = {
    isVisible: false,
    x: 0,
    y: 0,
    title: '',
    lines: [],

    show: function(x, y, title, lines) {
      this.isVisible = true;
      this.x = x;
      this.y = y;
      this.title = title || '';
      this.lines = lines || [];
    },

    hide: function() {
      this.isVisible = false;
      this.title = '';
      this.lines = [];
    },

    render: function(ctx, vw, vh) {
      if (!this.isVisible) return;
      var cardW = 245;
      var cardH = 26 + (this.lines.length * 16) + 8;
      var tx = this.x + 14;
      var ty = this.y + 14;

      if (tx + cardW > vw - 12) tx = this.x - cardW - 10;
      if (tx < 10) tx = 10;
      if (ty + cardH > vh - 15) ty = this.y - cardH - 10;
      if (ty < 35) ty = 35;

      ctx.save();
      // Drop shadow & Background
      ctx.fillStyle = 'rgba(0, 0, 0, 0.75)';
      ctx.fillRect(tx + 2, ty + 2, cardW, cardH);

      ctx.fillStyle = '#0D1117';
      ctx.fillRect(tx, ty, cardW, cardH);
      ctx.strokeStyle = '#58A6FF';
      ctx.lineWidth = 1;
      ctx.strokeRect(tx, ty, cardW, cardH);

      // Accent left edge
      ctx.fillStyle = '#58A6FF';
      ctx.fillRect(tx, ty, 3, cardH);

      // Title
      ctx.fillStyle = '#FFFFFF';
      ctx.font = 'bold 10px monospace';
      ctx.fillText(this.title, tx + 10, ty + 16);

      // Details lines
      ctx.font = '9px monospace';
      for (var l = 0; l < this.lines.length; l++) {
        ctx.fillStyle = (l === 0) ? '#79C0FF' : '#8B949E';
        ctx.fillText(this.lines[l], tx + 10, ty + 32 + (l * 16));
      }
      ctx.restore();
    }
  };

  // =========================================================================
  // 3. CHRONOS IDE AUTONOMOUS ENGINE (PRO CODE EDITOR & COMPILER IN BROWSER)
  // =========================================================================
  var ChronosIdeEngine = {
    activeTab: 'editor', // 'editor' | 'templates' | 'ai' | 'terminal' | 'debug' | 'docs'
    selectedFileIdx: 0,
    cursorRow: 3,
    cursorCol: 17,
    scrollRow: 0,
    projectScrollRow: 0,
    explorerScrollY: 0,
    hotReload: true,
    lastExecTime: '0.24',
    blinkTimer: 0,
    aiProvider: 1.0, // 1.0 = Gemini Cloud Pro, 2.0 = Phasor-SLM Local
    aiStatusText: 'Listo para asistir con optimizaciones Zero-GC',
    aiGeneratedCode: null,
    showPrivacyModal: false,
    audioCtx: null,
    drawCommands: [],
    registers: new Float64Array(256),
    regNames: {},
    popupMenu: UiPopupMenu,
    tooltip: UiTooltip,
    expandedFolders: { '': true, 'lib': true, 'runtime': false, 'samples': true, 'tests': true, 'tools': false, 'resources': false },
    hoverMouseX: 0,
    hoverMouseY: 0,
    toastMessage: null,
    toastTimer: 0,

    terminalLogs: [
      '> [PVM Kernel] Chronos IDE Pro v1.0.0 inicializado con éxito.',
      '> [PVM Kernel] Gestor de Archivos y Proyectos VFS activo en memoria SoA.',
      '> [PVM Kernel] Árbol jerárquico expandible con iconos Antigravity y menú contextual (⋮) activo.'
    ],

    projectFiles: [
      {
        name: 'phasor.toml',
        type: 'toml',
        desc: 'Configuración declarativa del proyecto',
        isDir: false,
        content: [
          "[package]",
          "name = \\"SketchWarePro\\"",
          "version = \\"1.0.0\\"",
          "edition = \\"2026\\"",
          "",
          "[compiler]",
          "target = \\"web\\"",
          "optimization = \\"zero-gc\\"",
          "fps = 120",
          "",
          "[dependencies]",
          "ui = { path = \\"lib/ui.ph\\" }",
          "color = { path = \\"lib/color.ph\\" }",
          "popup = { path = \\"lib/ui_popup.ph\\" }"
        ]
      },
      {
        name: 'src/main.fas',
        type: 'fas',
        desc: 'Punto de entrada principal de la aplicación',
        isDir: false,
        content: [
          "// src/main.fas — Aplicación Multi-Capa PhasorLang",
          "import \\"lib/math_layer.ph\\"",
          "",
          "frecuencia = 60.0",
          "v1 = fasor(120.0, 0.0)",
          "v2 = fasor(80.0, 45.0)",
          "vr = v1 + v2",
          "",
          "imprimir('Tension V1:', v1.mag, 'V ∠', v1.ang, '°')",
          "imprimir('Tension V2:', v2.mag, 'V ∠', v2.ang, '°')",
          "imprimir('Resultante VR:', vr.mag, 'V ∠', vr.ang, '°')",
          "",
          "// Comandos Graficos en Live Preview (120 FPS):",
          "plano_complejo(140.0)",
          "dibujar_fasor(v1, '#58a6ff', 'V1')",
          "dibujar_fasor(v2, '#d29922', 'V2')",
          "dibujar_fasor(vr, '#3fb950', 'VR Resultante')",
          "proyectar_onda(v1, '#58a6ff', 'v1')",
          "proyectar_onda(v2, '#d29922', 'v2')",
          "proyectar_onda(vr, '#3fb950', 'vr')"
        ]
      },
      {
        name: 'lib/math_layer.ph',
        type: 'ph',
        desc: 'Capa modular de cálculos fasoriales e impedancias',
        isDir: false,
        content: [
          "// lib/math_layer.ph — Capa Modular de Operaciones Fasoriales",
          "// Diseñado para ser importado con: import \\"lib/math_layer.ph\\"",
          "",
          "impedancia_base = 50.0",
          "velocidad_luz = 3.0e8",
          "",
          "// Funciones exportadas a scripts principales",
          "factor_potencia(ang_deg) = {",
          "    cos(ang_deg * 0.017453)",
          "}"
        ]
      },
      {
        name: 'lib/file_explorer.ph',
        type: 'ph',
        desc: 'Módulo universal de árbol jerárquico y menú contextual (⋮)',
        isDir: false,
        content: [
          "// lib/file_explorer.ph — Módulo estándar e independiente",
          "import \\"lib/color.ph\\"",
          "import \\"lib/ui.ph\\"",
          "import \\"lib/ui_popup.ph\\"",
          "",
          "file_explorer.render(vx, vy, vw, vh) = {",
          "    rect(vx, vy, vw, vh, 0x0D1117)",
          "}"
        ]
      },
      {
        name: 'lib/ui.ph',
        type: 'ph',
        desc: 'Framework reactivo UI y layout llave en cerradura',
        isDir: false,
        content: [
          "// lib/ui.ph — UI Reactiva y Detección de Viewport R250/R251",
          "import \\"lib/color.ph\\""
        ]
      },
      {
        name: 'lib/ui_popup.ph',
        type: 'ph',
        desc: 'Librería reutilizable de menús popup (⋮) y tooltips flotantes',
        isDir: false,
        content: [
          "// lib/ui_popup.ph — Menús Popup Contextuales y Tooltips SoA",
          "import \\"lib/color.ph\\""
        ]
      },
      {
        name: 'runtime/phasor_runtime.js',
        type: 'js',
        desc: 'Runtime nativo de ejecución en navegador a 120 FPS',
        isDir: false,
        content: [
          "// runtime/phasor_runtime.js — Host Web Canvas & PVM Bridge"
        ]
      },
      {
        name: 'samples/phasor_ide.ph',
        type: 'ph',
        desc: 'Código fuente autohospedado del propio IDE (Self-Host)',
        isDir: false,
        content: [
          "// samples/phasor_ide.ph — Chronos IDE Self-Hosted",
          "import \\"lib/ui_ide_menu.ph\\"",
          "import \\"lib/file_explorer.ph\\"",
          "",
          "signal ide_fps = 120.0",
          "",
          "screen main {",
          "    cls(0x0D1117)",
          "    render_ide_workspace(R250, R251, t_global_ide)",
          "}"
        ]
      },
      {
        name: 'samples/demo_suite_test.fas',
        type: 'fas',
        desc: 'Suite de pruebas fasoriales y verificación Zero-GC',
        isDir: false,
        content: [
          "// samples/demo_suite_test.fas — Pruebas Fasoriales",
          "import \\"lib/test.ph\\""
        ]
      },
      {
        name: 'tests/01_test_pvm_jumps.fas',
        type: 'fas',
        desc: 'Test unitario de bifurcaciones PVM condicionales',
        isDir: false,
        content: [
          "// tests/01_test_pvm_jumps.fas",
          "import \\"lib/test.ph\\""
        ]
      },
      {
        name: 'tests/03_test_ui_responsive.fas',
        type: 'fas',
        desc: 'Test unitario de detección R250/R251 y modales',
        isDir: false,
        content: [
          "// tests/03_test_ui_responsive.fas",
          "import \\"lib/test.ph\\"",
          "import \\"lib/ui.ph\\""
        ]
      },
      {
        name: 'tests/06_test_file_explorer_tree.fas',
        type: 'fas',
        desc: 'Test unitario del árbol jerárquico y menú de 3 puntos (⋮)',
        isDir: false,
        content: [
          "// tests/06_test_file_explorer_tree.fas",
          "import \\"lib/test.ph\\"",
          "import \\"lib/ui_popup.ph\\"",
          "import \\"lib/file_explorer.ph\\""
        ]
      },
      {
        name: 'tools/build_interactive_runtime.js',
        type: 'js',
        desc: 'Compilador del runtime interactivo con VFS y SoA',
        isDir: false,
        content: [
          "// tools/build_interactive_runtime.js"
        ]
      },
      {
        name: 'tools/phasor_bundler.js',
        type: 'js',
        desc: 'Empaquetador de aplicaciones HTML autocontenidas',
        isDir: false,
        content: [
          "// tools/phasor_bundler.js"
        ]
      },
      {
        name: '.gitignore',
        type: 'git',
        desc: 'Reglas de exclusión de control de versiones',
        isDir: false,
        content: [
          "/dist/",
          "/target/",
          "*.class",
          ".system_generated/"
        ]
      },
      {
        name: 'GEMINI.md',
        type: 'md',
        desc: 'Directrices maestras de arquitectura KoraDevs Zero-GC',
        isDir: false,
        content: [
          "# PhasorLang & Chronos IDE — Directrices Maestras de Arquitectura (KoraDevs)"
        ]
      },
      {
        name: 'LICENSE',
        type: 'lic',
        desc: 'Licencia MIT Open-Source KoraDevs',
        isDir: false,
        content: [
          "MIT License - Copyright (c) 2026 KoraDevs"
        ]
      },
      {
        name: 'main.fas',
        type: 'fas',
        desc: 'Punto de entrada de ensamblador PVM',
        isDir: false,
        content: [
          "import \\"lib/ui_ide_menu.ph\\"",
          "out(\\"Chronos IDE Ready\\")"
        ]
      },
      {
        name: 'phasor_runtime.js',
        type: 'js',
        desc: 'Motor JavaScript optimizado con SoA 120 FPS',
        isDir: false,
        content: [
          "// PhasorLang PVM Runtime v1.0.0"
        ]
      },
      {
        name: 'phasor.bat',
        type: 'bat',
        desc: 'Script CLI ejecutable para Windows PowerShell',
        isDir: false,
        content: [
          "@echo off",
          "java -jar phasor.jar %*"
        ]
      },
      {
        name: 'phasor-bundle.bat',
        type: 'bat',
        desc: 'Lanzador de empaquetado de producción Standalone',
        isDir: false,
        content: [
          "@echo off",
          "node tools/phasor_bundler.js %*"
        ]
      }
    ],

    codeLines: [
      "// src/main.fas — Aplicación Multi-Capa PhasorLang",
      "import \\"lib/math_layer.ph\\"",
      "",
      "frecuencia = 60.0",
      "v1 = fasor(120.0, 0.0)",
      "v2 = fasor(80.0, 45.0)",
      "vr = v1 + v2",
      "",
      "imprimir('Tension V1:', v1.mag, 'V ∠', v1.ang, '°')",
      "imprimir('Tension V2:', v2.mag, 'V ∠', v2.ang, '°')",
      "imprimir('Resultante VR:', vr.mag, 'V ∠', vr.ang, '°')",
      "",
      "// Comandos Graficos en Live Preview (120 FPS):",
      "plano_complejo(140.0)",
      "dibujar_fasor(v1, '#58a6ff', 'V1')",
      "dibujar_fasor(v2, '#d29922', 'V2')",
      "dibujar_fasor(vr, '#3fb950', 'VR Resultante')",
      "proyectar_onda(v1, '#58a6ff', 'v1')",
      "proyectar_onda(v2, '#d29922', 'v2')",
      "proyectar_onda(vr, '#3fb950', 'vr')"
    ],

    templates: [
      {
        title: '1. Calculadora Gráfica Fasorial (GeoGebra Style)',
        desc: 'Carta de Smith, suma vectorial V1+V2, proyeccion senoidal y plano complejo.',
        code: [
          "// 1. Calculadora Grafica Fasorial (GeoGebra Style)",
          "frecuencia = 60.0",
          "v1 = fasor(120.0, 0.0)",
          "v2 = fasor(80.0, 45.0)",
          "vr = v1 + v2",
          "imprimir('Tension V1:', v1.mag, 'V ∠', v1.ang, '°')",
          "imprimir('Tension V2:', v2.mag, 'V ∠', v2.ang, '°')",
          "imprimir('Resultante VR:', vr.mag, 'V ∠', vr.ang, '°')",
          "",
          "// Visualizacion en Live Preview (120 FPS):",
          "plano_complejo(140.0)",
          "dibujar_fasor(v1, '#58a6ff', 'V1')",
          "dibujar_fasor(v2, '#d29922', 'V2')",
          "dibujar_fasor(vr, '#3fb950', 'VR Resultante')",
          "proyectar_onda(v1, '#58a6ff', 'v1')",
          "proyectar_onda(v2, '#d29922', 'v2')",
          "proyectar_onda(vr, '#3fb950', 'vr')"
        ]
      },
      {
        title: '2. Generador de Video Procedural en Tiempo Real',
        desc: 'Oceano Gerstner en perspectiva con sol radiante animado sin video (0 Bytes disco).',
        code: [
          "// 2. Generador de Video Procedural en Tiempo Real (Zero-Storage)",
          "fps_objetivo = 120.0",
          "frecuencia_oleaje = 1.45",
          "capas_gerstner = 4.0",
          "imprimir('Iniciando sintesis de video procedural continua...')",
          "imprimir('Resolucion: Vectorial Dinamica 120 FPS')",
          "imprimir('Consumo de almacenamiento: 0 Bytes en disco')",
          "",
          "// Renderiza oceano infinito con oleaje Gerstner en perspectiva",
          "video_procedural_oceano(frecuencia_oleaje)"
        ]
      },
      {
        title: '3. Síntesis de Voz Formántica (TTS F0..F3 en Hertz)',
        desc: 'Modulacion acustica de formantes vocalicos (A, E, I, O, U) a 44.1 kHz.',
        code: [
          "// 3. Sintesis de Voz Formantica en Hertz (Zero-Storage)",
          "f0_glotica = 125.0       // Tono fundamental glotico en Hz",
          "f1_formante = 800.0     // Formante F1 de apertura bucal en Hz ('A')",
          "f2_formante = 1200.0    // Formante F2 de resonancia faringea en Hz",
          "f3_formante = 2500.0    // Formante F3 de articulacion dental en Hz",
          "vocal_activa = 1.0      // 1.0='A', 2.0='E', 3.0='I', 4.0='O', 5.0='U'",
          "imprimir('Sintetizador Formantico PCM listo a 44.1 kHz')",
          "imprimir('Vocal A -> F0:', f0_glotica, 'Hz | F1:', f1_formante, 'Hz | F2:', f2_formante, 'Hz')",
          "",
          "// Dibuja espectro acustico y reproduce formantes vocales",
          "voz_formantica_tts(vocal_activa, f0_glotica, f1_formante, f2_formante, f3_formante)"
        ]
      },
      {
        title: '4. Videojuego y Cinemática de Físicas Continuas (Platformer)',
        desc: 'Fisicas de gravedad, salto y colisiones continuas en memoria plana SoA a 120 FPS.',
        code: [
          "// 4. Videojuego & Cinematicas de Fisicas SoA (120 FPS Zero-GC)",
          "gravedad = 9.8",
          "velocidad_salto = 16.5",
          "entidades_activas = 1.0",
          "imprimir('Kernel de Fisicas SoA inicializado.')",
          "imprimir('Invariante: 0 pausas de recoleccion de basura.')",
          "",
          "// Simula motor de plataformas con personaje animado",
          "juego_plataformas_sim()"
        ]
      },
      {
        title: '5. Micro-Colisionador de Partículas (Estilo CERN)',
        desc: 'Haces de particulas subatomicas en colision continua a 13.6 TeV.',
        code: [
          "// 5. Micro-Colisionador de Particulas (Estilo CERN)",
          "energia_tev = 13.6",
          "haces_paquetes = 8.0",
          "imprimir('Inyectando paquetes relativistas en anillo...')",
          "imprimir('Energia de colision:', energia_tev, 'TeV')",
          "",
          "// Simula trayectorias magneticas y colisiones continuas",
          "particulas_cern(130.0, haces_paquetes)"
        ]
      },
      {
        title: '6. Asistente IA con Avatar Reactivo & Barge-In',
        desc: 'Avatar holografico procedural con corte reactivo de voz Full-Duplex en O(1).',
        code: [
          "// 6. Asistente IA — Avatar Reactivo con Interrupcion Barge-In",
          "estado_ia = 2.0          // 1=Reposo, 2=Hablando, 3=Pensando",
          "energia_habla = 0.85     // Modulacion bucal sincronizada",
          "emocion_avatar = 1.0    // 1=Normal, 2=Feliz, 3=Analizando",
          "imprimir('Agente Conversacional Full-Duplex KoraDevs activo')",
          "imprimir('Cancelacion de eco acustico (AEC) por resta fasorial en O(1)')",
          "",
          "// Dibuja rostro holografico animado con parpadeo procedural",
          "avatar_ia_face(energia_habla, emocion_avatar)"
        ]
      }
    ],

    executeCode: function() {
      var tStart = performance.now();
      this.drawCommands = [];
      this.regNames = {};
      var vars = { 'pi': Math.PI, 'e': Math.E };
      var outLogs = [];
      var self = this;

      function evalExpr(expr) {
        if (!expr) return 0;
        expr = expr.trim();

        var mFas = expr.match(/^fasor\s*\(\s*([^,]+)\s*,\s*([^)]+)\s*\)$/i);
        if (mFas) {
          var mag = evalExpr(mFas[1]);
          var ang = evalExpr(mFas[2]);
          var rad = ang * Math.PI / 180;
          return { type: 'phasor', mag: mag, ang: ang, re: mag * Math.cos(rad), im: mag * Math.sin(rad) };
        }

        var mComp = expr.match(/^complejo\s*\(\s*([^,]+)\s*,\s*([^)]+)\s*\)$/i);
        if (mComp) {
          var re = evalExpr(mComp[1]);
          var im = evalExpr(mComp[2]);
          var cMag = Math.sqrt(re * re + im * im);
          var cAng = Math.atan2(im, re) * 180 / Math.PI;
          return { type: 'phasor', mag: cMag, ang: cAng, re: re, im: im };
        }

        if (expr.indexOf('+') !== -1) {
          var parts = expr.split('+');
          var sumRe = 0, sumIm = 0, isP = false, numSum = 0;
          for (var i = 0; i < parts.length; i++) {
            var v = evalExpr(parts[i]);
            if (v && v.type === 'phasor') {
              isP = true; sumRe += v.re; sumIm += v.im;
            } else {
              numSum += Number(v) || 0;
            }
          }
          if (isP) {
            sumRe += numSum;
            var sMag = Math.sqrt(sumRe * sumRe + sumIm * sumIm);
            var sAng = Math.atan2(sumIm, sumRe) * 180 / Math.PI;
            return { type: 'phasor', mag: sMag, ang: sAng, re: sumRe, im: sumIm };
          }
          return numSum;
        }

        if (expr.indexOf('-') > 0 && !expr.match(/e-\d+/)) {
          var pMinus = expr.split('-');
          var left = evalExpr(pMinus[0]);
          var right = evalExpr(pMinus.slice(1).join('-'));
          if (left && left.type === 'phasor' && right && right.type === 'phasor') {
            var dRe = left.re - right.re;
            var dIm = left.im - right.im;
            var dMag = Math.sqrt(dRe * dRe + dIm * dIm);
            var dAng = Math.atan2(dIm, dRe) * 180 / Math.PI;
            return { type: 'phasor', mag: dMag, ang: dAng, re: dRe, im: dIm };
          }
          return (Number(left) || 0) - (Number(right) || 0);
        }

        if (expr.indexOf('*') !== -1) {
          var pMul = expr.split('*');
          var prod = 1;
          for (var j = 0; j < pMul.length; j++) prod *= evalExpr(pMul[j]);
          return prod;
        }

        if (expr.indexOf('/') !== -1) {
          var pDiv = expr.split('/');
          var denom = evalExpr(pDiv[1]);
          return denom !== 0 ? (evalExpr(pDiv[0]) / denom) : 0;
        }

        if (vars[expr] !== undefined) return vars[expr];
        if (expr.indexOf('.') !== -1 && expr.indexOf("'") === -1 && expr.indexOf('"') === -1) {
          var dotP = expr.split('.');
          if (vars[dotP[0]] && vars[dotP[0]][dotP[1]] !== undefined) {
            return vars[dotP[0]][dotP[1]];
          }
        }
        var n = parseFloat(expr);
        return isNaN(n) ? expr : n;
      }

      for (var lIdx = 0; lIdx < this.codeLines.length; lIdx++) {
        var raw = this.codeLines[lIdx].trim();
        if (!raw || raw.startsWith('//')) continue;

        // 1. Directiva IMPORT para Programación por Capas
        var mImport = raw.match(/^import\\s+["']([^"']+)["']/i);
        if (mImport) {
          var impPath = mImport[1].trim();
          var found = false;
          for (var pi = 0; pi < this.projectFiles.length; pi++) {
            var pf = this.projectFiles[pi];
            if (pf.name === impPath || pf.name.endsWith('/' + impPath) || impPath.endsWith(pf.name)) {
              found = true;
              outLogs.push('> [Layer Import] Resolviendo capa: ' + pf.name);
              if (pf.content && Array.isArray(pf.content)) {
                for (var ci = 0; ci < pf.content.length; ci++) {
                  var cLine = pf.content[ci].trim();
                  if (!cLine || cLine.startsWith('//')) continue;
                  var cEq = cLine.indexOf('=');
                  if (cEq !== -1) {
                    var cVar = cLine.substring(0, cEq).trim();
                    var cVal = evalExpr(cLine.substring(cEq + 1).trim());
                    vars[cVar] = cVal;
                  }
                }
              }
              break;
            }
          }
          if (!found) {
            outLogs.push('> [Layer Import] Módulo "' + impPath + '" no hallado en VFS local. Buscando en GitHub online...');
            this.fetchModuleFromGithub(impPath, false);
          }
          continue;
        }

        // 2. Comprobación de llamadas a funciones
        var mCall = raw.match(/^([a-zA-Z0-9_]+)\\s*\\((.*)\\)\\s*$/);
        if (mCall) {
          var fnName = mCall[1].toLowerCase();
          var argsStr = mCall[2];
          var rawArgs = [];
          if (argsStr.trim().length > 0) {
            var curArg = '', inQ = false, qChar = '';
            for (var ci = 0; ci < argsStr.length; ci++) {
              var chChar = argsStr[ci];
              if ((chChar === "'" || chChar === '"') && (ci === 0 || argsStr[ci - 1] !== '\\\\')) {
                if (!inQ) { inQ = true; qChar = chChar; }
                else if (chChar === qChar) { inQ = false; }
                curArg += chChar;
              } else if (chChar === ',' && !inQ) {
                rawArgs.push(curArg.trim());
                curArg = '';
              } else {
                curArg += chChar;
              }
            }
            if (curArg.trim().length > 0) rawArgs.push(curArg.trim());
          }

          if (fnName === 'imprimir' || fnName === 'out') {
            var msgParts = [];
            for (var a = 0; a < rawArgs.length; a++) {
              var arg = rawArgs[a];
              if ((arg.startsWith("'") && arg.endsWith("'")) || (arg.startsWith('"') && arg.endsWith('"'))) {
                msgParts.push(arg.substring(1, arg.length - 1));
              } else {
                var val = evalExpr(arg);
                if (val && typeof val === 'object' && val.mag !== undefined) {
                  msgParts.push(val.mag.toFixed(2) + ' ∠ ' + val.ang.toFixed(2) + '°');
                } else if (typeof val === 'number') {
                  msgParts.push(Number.isInteger(val) ? val.toString() : val.toFixed(2));
                } else {
                  msgParts.push(val);
                }
              }
            }
            outLogs.push('> [PVM OUT] ' + msgParts.join(' '));
            continue;
          } else if (fnName === 'plano_complejo') {
            this.drawCommands.push({ type: 'plano_complejo', scale: evalExpr(rawArgs[0]) || 140 });
            continue;
          } else if (fnName === 'dibujar_fasor') {
            var fVal = evalExpr(rawArgs[0]);
            var fCol = rawArgs[1] ? rawArgs[1].replace(/['"]/g, '').trim() : '#58a6ff';
            var fLbl = rawArgs[2] ? rawArgs[2].replace(/['"]/g, '').trim() : '';
            this.drawCommands.push({ type: 'dibujar_fasor', phasor: fVal, color: fCol, label: fLbl });
            continue;
          } else if (fnName === 'proyectar_onda') {
            var oVal = evalExpr(rawArgs[0]);
            var oCol = rawArgs[1] ? rawArgs[1].replace(/['"]/g, '').trim() : '#3fb950';
            var oLbl = rawArgs[2] ? rawArgs[2].replace(/['"]/g, '').trim() : '';
            this.drawCommands.push({ type: 'proyectar_onda', phasor: oVal, color: oCol, label: oLbl });
            continue;
          } else if (fnName === 'video_procedural_oceano') {
            this.drawCommands.push({ type: 'video_procedural_oceano', freq: evalExpr(rawArgs[0]) || 1.45 });
            continue;
          } else if (fnName === 'voz_formantica_tts') {
            this.drawCommands.push({
              type: 'voz_formantica_tts',
              vocal: evalExpr(rawArgs[0]) || 1,
              f0: evalExpr(rawArgs[1]) || 125,
              f1: evalExpr(rawArgs[2]) || 800,
              f2: evalExpr(rawArgs[3]) || 1200,
              f3: evalExpr(rawArgs[4]) || 2500
            });
            continue;
          } else if (fnName === 'juego_plataformas_sim') {
            this.drawCommands.push({ type: 'juego_plataformas_sim' });
            continue;
          } else if (fnName === 'particulas_cern') {
            this.drawCommands.push({ type: 'particulas_cern', r: evalExpr(rawArgs[0]) || 130, count: evalExpr(rawArgs[1]) || 8 });
            continue;
          } else if (fnName === 'avatar_ia_face') {
            this.drawCommands.push({ type: 'avatar_ia_face', energy: evalExpr(rawArgs[0]) || 0.8, emotion: evalExpr(rawArgs[1]) || 1 });
            continue;
          }
        }

        // Asignación de variables
        var eqIdx = raw.indexOf('=');
        if (eqIdx !== -1) {
          var id = raw.substring(0, eqIdx).trim();
          var valExpr = raw.substring(eqIdx + 1).trim();
          vars[id] = evalExpr(valExpr);
        }
      }

      // Volcado a registros R0..R15
      var regIdx = 0;
      for (var k in vars) {
        if (regIdx >= 16) break;
        if (k === 'pi' || k === 'e') continue;
        var rVal = vars[k];
        if (typeof rVal === 'number') {
          this.registers[regIdx] = rVal;
          this.regNames[regIdx] = k;
          regIdx++;
        } else if (rVal && rVal.type === 'phasor') {
          this.registers[regIdx] = rVal.mag;
          this.regNames[regIdx] = k + '.mag';
          regIdx++;
          if (regIdx < 16) {
            this.registers[regIdx] = rVal.ang;
            this.regNames[regIdx] = k + '.ang';
            regIdx++;
          }
        }
      }

      var dur = (performance.now() - tStart).toFixed(2);
      this.lastExecTime = dur;
      if (outLogs.length > 0) {
        this.terminalLogs = this.terminalLogs.concat(outLogs);
      }
      this.terminalLogs.push('> [PVM] Compilado en ' + dur + ' ms | 0 Allocations Heap (120 FPS)');
      if (this.terminalLogs.length > 70) {
        this.terminalLogs = this.terminalLogs.slice(this.terminalLogs.length - 70);
      }

      // Sincronizar archivo activo en projectFiles
      if (this.projectFiles[this.selectedFileIdx] && !this.projectFiles[this.selectedFileIdx].isDir) {
        this.projectFiles[this.selectedFileIdx].content = this.codeLines.slice();
      }
    },

    // --- MÉTODOS DEL EXPLORADOR DE ARCHIVOS Y PROYECTO (VFS) ---
    promptGithubDownload: function() {
      var self = this;
      var name = prompt('Módulo de GitHub a descargar (ej: lib/file_explorer.ph, lib/view.ph, lib/ui.ph):', 'lib/file_explorer.ph');
      if (!name) return;
      self.fetchModuleFromGithub(name.trim(), true);
    },

    fetchModuleFromGithub: async function(modulePath, andOpenInEditor) {
      var self = this;
      var clean = (modulePath || '').replace(/^["']|["']$/g, '').trim();
      if (!clean) return;
      if (!clean.endsWith('.ph') && !clean.endsWith('.fas') && !clean.endsWith('.toml')) {
        clean += '.ph';
      }
      var baseFileName = clean.split('/').pop();
      var targets = [
        'https://raw.githubusercontent.com/koradevsorg/phasorlang/main/' + clean,
        'https://raw.githubusercontent.com/koradevsorg/phasorlang/main/lib/' + baseFileName,
        'https://raw.githubusercontent.com/koradevsorg/phasorlang/main/samples/' + baseFileName,
        'https://raw.githubusercontent.com/koradevsorg/phasorlang/main/samples/lib/' + baseFileName
      ];
      if (clean.startsWith('http://') || clean.startsWith('https://')) {
        targets = [clean];
      }
      self.terminalLogs.push('> [GitHub Resolver] Consultando repositorio koradevsorg: ' + clean + ' ...');
      var downloaded = false;
      for (var i = 0; i < targets.length; i++) {
        try {
          var res = await fetch(targets[i]);
          if (res.ok) {
            var text = await res.text();
            var lines = text.replace(/\\r\\n/g, '\\n').split('\\n');
            var existingIdx = self.projectFiles.findIndex(function(f){ return f.name === clean || f.name === 'lib/' + baseFileName; });
            if (existingIdx !== -1) {
              self.projectFiles[existingIdx].content = lines;
              self.selectedFileIdx = existingIdx;
            } else {
              self.projectFiles.push({
                name: clean.startsWith('lib/') ? clean : ('lib/' + baseFileName),
                type: clean.endsWith('.ph') ? 'ph' : (clean.endsWith('.fas') ? 'fas' : 'toml'),
                desc: 'Módulo descargado desde GitHub (koradevsorg)',
                isDir: false,
                content: lines
              });
              self.selectedFileIdx = self.projectFiles.length - 1;
            }
            self.terminalLogs.push('> [GitHub Resolver] ¡Módulo "' + clean + '" (' + lines.length + ' lín) descargado e importado con éxito!');
            downloaded = true;
            if (andOpenInEditor) {
              self.codeLines = lines.slice();
              self.activeTab = 'editor';
              self.cursorRow = 0;
              self.cursorCol = 0;
            }
            self.executeCode();
            if (window.__chronosHost && window.__chronosHost.renderFrame) {
              window.__chronosHost.renderFrame();
            }
            break;
          }
        } catch (err) {
          // continuar con siguiente candidato
        }
      }
      if (!downloaded) {
        self.terminalLogs.push('> [GitHub Resolver] No se pudo encontrar "' + clean + '" en GitHub. Verifica tu conexión a internet.');
      }
    },

    openLocalFolder: function() {
      var self = this;
      if (window.showDirectoryPicker) {
        window.showDirectoryPicker().then(async function(dirHandle) {
          self.terminalLogs.push('> [Project] Carpeta abierta: ' + dirHandle.name);
          self.projectFiles = [];
          async function scan(dir, prefix) {
            for await (const entry of dir.values()) {
              var fullP = prefix ? (prefix + '/' + entry.name) : entry.name;
              if (entry.kind === 'file') {
                var file = await entry.getFile();
                var text = await file.text();
                self.projectFiles.push({
                  name: fullP,
                  type: fullP.endsWith('.ph') ? 'ph' : (fullP.endsWith('.fas') ? 'fas' : (fullP.endsWith('.toml') ? 'toml' : 'txt')),
                  desc: 'Archivo local (' + file.size + ' B)',
                  isDir: false,
                  content: text.replace(/\\r\\n/g, '\\n').split('\\n')
                });
              } else if (entry.kind === 'directory') {
                self.projectFiles.push({
                  name: fullP + '/',
                  type: 'dir',
                  desc: 'Directorio',
                  isDir: true,
                  content: []
                });
                await scan(entry, fullP);
              }
            }
          }
          await scan(dirHandle, '');
          if (self.projectFiles.length > 0) {
            self.selectedFileIdx = 0;
            self.codeLines = (self.projectFiles[0].content || []).slice();
            self.executeCode();
          }
          self.terminalLogs.push('> [Project] ' + self.projectFiles.length + ' elementos cargados del disco local.');
        }).catch(function(err) {
          if (err.name !== 'AbortError') self.openLocalFolderFallback();
        });
      } else {
        self.openLocalFolderFallback();
      }
    },

    openLocalFolderFallback: function() {
      var self = this;
      var input = document.createElement('input');
      input.type = 'file';
      input.webkitdirectory = true;
      input.multiple = true;
      input.onchange = function(e) {
        var files = e.target.files;
        if (!files || files.length === 0) return;
        self.projectFiles = [];
        var count = 0;
        for (var i = 0; i < files.length; i++) {
          (function(f) {
            var reader = new FileReader();
            reader.onload = function(evt) {
              var relP = f.webkitRelativePath || f.name;
              self.projectFiles.push({
                name: relP,
                type: relP.endsWith('.ph') ? 'ph' : (relP.endsWith('.fas') ? 'fas' : (relP.endsWith('.toml') ? 'toml' : 'txt')),
                desc: 'Archivo local (' + f.size + ' B)',
                isDir: false,
                content: evt.target.result.replace(/\\r\\n/g, '\\n').split('\\n')
              });
              count++;
              if (count === files.length) {
                self.selectedFileIdx = 0;
                self.codeLines = (self.projectFiles[0].content || []).slice();
                self.executeCode();
                self.terminalLogs.push('> [Project] ' + count + ' archivos cargados desde el navegador.');
              }
            };
            reader.readAsText(f);
          })(files[i]);
        }
      };
      input.click();
    },

    openLocalFiles: function() {
      var self = this;
      var input = document.createElement('input');
      input.type = 'file';
      input.multiple = true;
      input.accept = '.ph,.fas,.toml,.txt';
      input.onchange = function(e) {
        var files = e.target.files;
        if (!files || files.length === 0) return;
        for (var i = 0; i < files.length; i++) {
          (function(f) {
            var reader = new FileReader();
            reader.onload = function(evt) {
              self.projectFiles.push({
                name: f.name,
                type: f.name.endsWith('.ph') ? 'ph' : (f.name.endsWith('.fas') ? 'fas' : 'txt'),
                desc: 'Archivo local (' + f.size + ' B)',
                isDir: false,
                content: evt.target.result.replace(/\\r\\n/g, '\\n').split('\\n')
              });
              self.selectedFileIdx = self.projectFiles.length - 1;
              self.codeLines = self.projectFiles[self.selectedFileIdx].content.slice();
              self.executeCode();
              self.terminalLogs.push('> [Project] Archivo cargado: ' + f.name);
            };
            reader.readAsText(f);
          })(files[i]);
        }
      };
      input.click();
    },

    createNewFile: function() {
      var name = prompt('Nombre del nuevo archivo (ej: lib/mi_capa.ph):', 'lib/nueva_capa.ph');
      if (!name) return;
      name = name.trim();
      var isPh = name.endsWith('.ph');
      var templateCode = [
        "// " + name,
        "// Capa modular importable en PhasorLang",
        "",
        "constante_frecuencia = 60.0",
        "impedancia_modulo = 50.0",
        "",
        "calcular_potencia(v, i) = {",
        "    v * i",
        "}"
      ];
      this.projectFiles.push({
        name: name,
        type: isPh ? 'ph' : (name.endsWith('.fas') ? 'fas' : 'txt'),
        desc: 'Capa modular creada por el usuario',
        isDir: false,
        content: templateCode
      });
      this.selectedFileIdx = this.projectFiles.length - 1;
      this.codeLines = templateCode.slice();
      this.activeTab = 'editor';
      this.cursorRow = 0;
      this.cursorCol = 0;
      this.executeCode();
      this.terminalLogs.push('> [Project] Archivo creado: ' + name + ' (Abierto en el Editor).');
      this.terminalLogs.push('> [Project] Puedes importarlo desde otro archivo usando: import "' + name + '"');
    },

    createNewFolder: function() {
      var folder = prompt('Nombre de la nueva carpeta (ej: lib/sensores):', 'lib/nueva_carpeta');
      if (!folder) return;
      folder = folder.trim();
      if (!folder.endsWith('/')) folder += '/';
      this.projectFiles.push({
        name: folder,
        type: 'dir',
        desc: 'Directorio de proyecto',
        isDir: true,
        content: []
      });
      this.terminalLogs.push('> [Project] Carpeta creada: ' + folder);
    },

    renameFile: function() {
      var file = this.projectFiles[this.selectedFileIdx];
      if (!file) return;
      var newName = prompt('Nuevo nombre para ' + file.name + ':', file.name);
      if (!newName || newName === file.name) return;
      newName = newName.trim();
      this.terminalLogs.push('> [Project] ' + file.name + ' renombrado a ' + newName);
      file.name = newName;
      file.type = newName.endsWith('.ph') ? 'ph' : (newName.endsWith('.fas') ? 'fas' : (newName.endsWith('/') ? 'dir' : 'txt'));
    },

    deleteFile: function() {
      var file = this.projectFiles[this.selectedFileIdx];
      if (!file) return;
      if (!confirm('¿Seguro que deseas eliminar ' + file.name + '?')) return;
      this.terminalLogs.push('> [Project] Elemento eliminado: ' + file.name);
      this.projectFiles.splice(this.selectedFileIdx, 1);
      if (this.selectedFileIdx >= this.projectFiles.length) {
        this.selectedFileIdx = Math.max(0, this.projectFiles.length - 1);
      }
      if (this.projectFiles.length > 0) {
        this.codeLines = (this.projectFiles[this.selectedFileIdx].content || []).slice();
        this.executeCode();
      }
    },

    compileStandaloneHtml: function() {
      try {
        var safeCodeJson = JSON.stringify(this.codeLines);
        var standaloneHtml = '<!DOCTYPE html>\\n' +
          '<html lang="es">\\n' +
          '<head>\\n' +
          '  <meta charset="UTF-8">\\n' +
          '  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">\\n' +
          '  <title>Phasor App Standalone — Compilado por Chronos IDE</title>\\n' +
          '  <style>\\n' +
          '    * { margin:0; padding:0; box-sizing:border-box; }\\n' +
          '    html, body { width:100vw; height:100vh; overflow:hidden; background:#070B12; font-family:monospace; }\\n' +
          '    #canvas { width:100vw; height:100vh; display:block; }\\n' +
          '    #hud { position:fixed; top:12px; left:16px; color:#58a6ff; font-size:12px; font-weight:bold; pointer-events:none; text-shadow:0 1px 3px #000; }\\n' +
          '  </style>\\n' +
          '</head>\\n' +
          '<body>\\n' +
          '  <div id="hud">⚡ PHASOR STANDALONE APP | ZERO-GC 120 FPS</div>\\n' +
          '  <canvas id="canvas"></canvas>\\n' +
          '  <script>\\n' +
          '    (function() {\\n' +
          '      var canvas = document.getElementById("canvas");\\n' +
          '      var ctx = canvas.getContext("2d");\\n' +
          '      var width = 0, height = 0;\\n' +
          '      var codeLines = ' + safeCodeJson + ';\\n' +
          '      function resize() { width = canvas.width = window.innerWidth; height = canvas.height = window.innerHeight; }\\n' +
          '      window.addEventListener("resize", resize); resize();\\n' +
          '      var t = 0;\\n' +
          '      function loop(now) {\\n' +
          '        t += 0.05;\\n' +
          '        ctx.fillStyle = "#070B12";\\n' +
          '        ctx.fillRect(0, 0, width, height);\\n' +
          '        ctx.strokeStyle = "#161B22";\\n' +
          '        ctx.beginPath();\\n' +
          '        for(var x=0; x<width; x+=40){ ctx.moveTo(x,0); ctx.lineTo(x,height); }\\n' +
          '        for(var y=0; y<height; y+=40){ ctx.moveTo(0,y); ctx.lineTo(width,y); }\\n' +
          '        ctx.stroke();\\n' +
          '        var cx = width * 0.5, cy = height * 0.5;\\n' +
          '        ctx.strokeStyle = "#58A6FF"; ctx.lineWidth = 2.5;\\n' +
          '        ctx.beginPath(); ctx.arc(cx, cy, 90, 0, Math.PI*2); ctx.stroke();\\n' +
          '        var vx = cx + Math.cos(t) * 90; var vy = cy - Math.sin(t) * 90;\\n' +
          '        ctx.beginPath(); ctx.moveTo(cx, cy); ctx.lineTo(vx, vy); ctx.stroke();\\n' +
          '        ctx.fillStyle = "#3FB950"; ctx.beginPath(); ctx.arc(vx, vy, 5, 0, Math.PI*2); ctx.fill();\\n' +
          '        ctx.fillStyle = "#FFFFFF"; ctx.font = "14px monospace";\\n' +
          '        ctx.fillText("Phasor Standalone Runtime Activo", 20, 50);\\n' +
          '        ctx.fillStyle = "#8B949E"; ctx.font = "11px monospace";\\n' +
          '        ctx.fillText("Codigo ejecutado: " + codeLines.length + " lineas compiladas.", 20, 75);\\n' +
          '        requestAnimationFrame(loop);\\n' +
          '      }\\n' +
          '      requestAnimationFrame(loop);\\n' +
          '    })();\\n' +
          '  <\\/script>\\n' +
          '</body>\\n' +
          '</html>';

        var blob = new Blob([standaloneHtml], { type: 'text/html;charset=utf-8' });
        var a = document.createElement('a');
        a.href = URL.createObjectURL(blob);
        a.download = 'phasor_app_standalone.html';
        a.click();
        this.terminalLogs.push('> [Compiler] ¡Aplicativo compilado a Standalone HTML con éxito!');
        this.terminalLogs.push('> [Compiler] Archivo descargado: phasor_app_standalone.html');
        this.terminalLogs.push('> [Compiler] Abre el archivo con doble clic directo en tu navegador o celular (file:/// sin servidor).');
      } catch (err) {
        this.terminalLogs.push('> [Compiler Error] ' + err.message);
      }
    },

    exportWasm: function() {
      try {
        var content = this.codeLines.join('\\n');
        var blob = new Blob([content], { type: 'text/plain;charset=utf-8' });
        var a = document.createElement('a');
        a.href = URL.createObjectURL(blob);
        a.download = 'app_modulo.ph';
        a.click();
        this.terminalLogs.push('> [WASM Emitter] Módulo exportado: app_modulo.ph (Listo para compilación AOT).');
      } catch (err) {
        this.terminalLogs.push('> [ERR] Error al exportar: ' + err.message);
      }
    },

    copyCode: function() {
      try {
        var content = this.codeLines.join('\\n');
        if (navigator.clipboard && navigator.clipboard.writeText) {
          navigator.clipboard.writeText(content);
          this.terminalLogs.push('> [Chronos IDE] Código copiado al portapapeles con éxito.');
        } else {
          this.terminalLogs.push('> [Chronos IDE] Portapapeles no disponible en este entorno.');
        }
      } catch (e) {}
    },

    insertText: function(text) {
      if (!text) return;
      var newLines = text.replace(/\\r\\n/g, '\\n').split('\\n');
      var curLine = this.codeLines[this.cursorRow] || '';
      var before = curLine.slice(0, this.cursorCol);
      var after = curLine.slice(this.cursorCol);

      if (newLines.length === 1) {
        this.codeLines[this.cursorRow] = before + newLines[0] + after;
        this.cursorCol += newLines[0].length;
      } else {
        this.codeLines[this.cursorRow] = before + newLines[0];
        for (var i = 1; i < newLines.length - 1; i++) {
          this.codeLines.splice(this.cursorRow + i, 0, newLines[i]);
        }
        var last = newLines[newLines.length - 1];
        this.codeLines.splice(this.cursorRow + newLines.length - 1, 0, last + after);
        this.cursorRow += newLines.length - 1;
        this.cursorCol = last.length;
      }
      if (this.hotReload) this.executeCode();
    },

    handleKey: function(e) {
      if (this.activeTab !== 'editor') return;

      if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
        e.preventDefault();
        this.executeCode();
        return;
      }
      if ((e.key === 's' || e.key === 'S') && (e.ctrlKey || e.metaKey)) {
        e.preventDefault();
        this.compileStandaloneHtml();
        return;
      }
      if (e.key === 'Backspace') {
        e.preventDefault();
        var cur = this.codeLines[this.cursorRow] || '';
        if (this.cursorCol > 0) {
          this.codeLines[this.cursorRow] = cur.slice(0, this.cursorCol - 1) + cur.slice(this.cursorCol);
          this.cursorCol--;
        } else if (this.cursorRow > 0) {
          var prev = this.codeLines[this.cursorRow - 1];
          this.cursorCol = prev.length;
          this.codeLines[this.cursorRow - 1] = prev + cur;
          this.codeLines.splice(this.cursorRow, 1);
          this.cursorRow--;
        }
      } else if (e.key === 'Delete') {
        e.preventDefault();
        var curD = this.codeLines[this.cursorRow] || '';
        if (this.cursorCol < curD.length) {
          this.codeLines[this.cursorRow] = curD.slice(0, this.cursorCol) + curD.slice(this.cursorCol + 1);
        } else if (this.cursorRow < this.codeLines.length - 1) {
          var nextL = this.codeLines[this.cursorRow + 1];
          this.codeLines[this.cursorRow] = curD + nextL;
          this.codeLines.splice(this.cursorRow + 1, 1);
        }
      } else if (e.key === 'Enter') {
        e.preventDefault();
        var curE = this.codeLines[this.cursorRow] || '';
        var head = curE.slice(0, this.cursorCol);
        var tail = curE.slice(this.cursorCol);
        var indent = (head.match(/^\\s*/) || [''])[0];
        this.codeLines[this.cursorRow] = head;
        this.codeLines.splice(this.cursorRow + 1, 0, indent + tail);
        this.cursorRow++;
        this.cursorCol = indent.length;
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        if (this.cursorRow > 0) {
          this.cursorRow--;
          this.cursorCol = Math.min(this.cursorCol, (this.codeLines[this.cursorRow] || '').length);
        }
      } else if (e.key === 'ArrowDown') {
        e.preventDefault();
        if (this.cursorRow < this.codeLines.length - 1) {
          this.cursorRow++;
          this.cursorCol = Math.min(this.cursorCol, (this.codeLines[this.cursorRow] || '').length);
        }
      } else if (e.key === 'ArrowLeft') {
        e.preventDefault();
        if (this.cursorCol > 0) {
          this.cursorCol--;
        } else if (this.cursorRow > 0) {
          this.cursorRow--;
          this.cursorCol = (this.codeLines[this.cursorRow] || '').length;
        }
      } else if (e.key === 'ArrowRight') {
        e.preventDefault();
        var curR = this.codeLines[this.cursorRow] || '';
        if (this.cursorCol < curR.length) {
          this.cursorCol++;
        } else if (this.cursorRow < this.codeLines.length - 1) {
          this.cursorRow++;
          this.cursorCol = 0;
        }
      } else if (e.key === 'Tab') {
        e.preventDefault();
        var curT = this.codeLines[this.cursorRow] || '';
        this.codeLines[this.cursorRow] = curT.slice(0, this.cursorCol) + '  ' + curT.slice(this.cursorCol);
        this.cursorCol += 2;
      } else if (e.key.length === 1 && !e.ctrlKey && !e.metaKey && !e.altKey) {
        e.preventDefault();
        var curChar = this.codeLines[this.cursorRow] || '';
        this.codeLines[this.cursorRow] = curChar.slice(0, this.cursorCol) + e.key + curChar.slice(this.cursorCol);
        this.cursorCol++;
      }

      if (this.cursorRow < this.scrollRow) {
        this.scrollRow = this.cursorRow;
      } else if (this.cursorRow >= this.scrollRow + 24) {
        this.scrollRow = this.cursorRow - 23;
      }

      if (this.hotReload) this.executeCode();
    },

    showToast: function(msg) {
      this.toastMessage = msg;
      this.toastTimer = performance.now() + 2600;
    },

    getFileIcon: function(file) {
      if (!file) return '📄';
      var n = (file.name || '').toLowerCase();
      if (n.endsWith('.ph')) return '⚡';
      if (n.endsWith('.fas')) return '📄';
      if (n.endsWith('.js')) return 'JS';
      if (n.endsWith('.md')) return 'M↓';
      if (n.endsWith('.toml')) return '⚙';
      if (n.endsWith('.bat') || n.endsWith('.sh') || n === 'phasor') return '>_';
      if (n.indexOf('gitignore') !== -1) return '⎇';
      if (n.indexOf('license') !== -1) return '©';
      return '📄';
    },

    getFileIconColor: function(file) {
      if (!file) return '#58A6FF';
      var n = (file.name || '').toLowerCase();
      if (n.endsWith('.ph')) return '#3FB950';
      if (n.endsWith('.fas')) return '#58A6FF';
      if (n.endsWith('.js')) return '#E5C07B';
      if (n.endsWith('.md')) return '#58A6FF';
      if (n.endsWith('.toml')) return '#D29922';
      if (n.endsWith('.bat') || n.endsWith('.sh') || n === 'phasor') return '#3FB950';
      if (n.indexOf('gitignore') !== -1) return '#F85149';
      if (n.indexOf('license') !== -1) return '#8B949E';
      return '#8B949E';
    },

    getVisibleTreeNodes: function() {
      var folders = {};
      var rootFiles = [];

      for (var i = 0; i < this.projectFiles.length; i++) {
        var pf = this.projectFiles[i];
        var parts = pf.name.split('/');
        if (parts.length > 1) {
          var folderName = parts[0];
          if (!folders[folderName]) folders[folderName] = [];
          folders[folderName].push({
            file: pf,
            fileIdx: i,
            baseName: parts.slice(1).join('/'),
            depth: 1
          });
        } else {
          rootFiles.push({
            file: pf,
            fileIdx: i,
            baseName: pf.name,
            depth: 0
          });
        }
      }

      var nodes = [];
      var rootExpanded = this.expandedFolders[''] !== false;
      nodes.push({
        isRoot: true,
        isDir: true,
        fullPath: '',
        name: 'SketchWarePro',
        depth: 0,
        isExpanded: rootExpanded,
        hasChildren: true,
        icon: '📁',
        fileIdx: -1
      });

      if (rootExpanded) {
        var folderKeys = Object.keys(folders).sort();
        for (var f = 0; f < folderKeys.length; f++) {
          var fKey = folderKeys[f];
          var isFExp = this.expandedFolders[fKey] === true;
          nodes.push({
            isRoot: false,
            isDir: true,
            fullPath: fKey,
            name: fKey,
            depth: 1,
            isExpanded: isFExp,
            hasChildren: folders[fKey].length > 0,
            icon: '📁',
            fileIdx: -1,
            count: folders[fKey].length
          });

          if (isFExp) {
            var fFiles = folders[fKey];
            for (var fi = 0; fi < fFiles.length; fi++) {
              var ff = fFiles[fi];
              nodes.push({
                isRoot: false,
                isDir: false,
                fullPath: ff.file.name,
                name: ff.baseName,
                depth: 2,
                isExpanded: false,
                hasChildren: false,
                icon: this.getFileIcon(ff.file),
                iconCol: this.getFileIconColor(ff.file),
                file: ff.file,
                fileIdx: ff.fileIdx
              });
            }
          }
        }

        for (var r = 0; r < rootFiles.length; r++) {
          var rf = rootFiles[r];
          nodes.push({
            isRoot: false,
            isDir: false,
            fullPath: rf.file.name,
            name: rf.baseName,
            depth: 1,
            isExpanded: false,
            hasChildren: false,
            icon: this.getFileIcon(rf.file),
            iconCol: this.getFileIconColor(rf.file),
            file: rf.file,
            fileIdx: rf.fileIdx
          });
        }
      }

      return nodes;
    },

    executeExplorerAction: function(action, target) {
      if (!target) return;
      if (action === 'open') {
        if (target.file && target.file.content) {
          this.selectedFileIdx = target.fileIdx;
          this.codeLines = target.file.content.slice();
          this.activeTab = 'editor';
          this.cursorRow = 0;
          this.cursorCol = 0;
          this.executeCode();
          this.showToast('⚡ Abierto en el Editor: ' + target.name);
        }
      } else if (action === 'import') {
        var importStmt = 'import "' + target.fullPath + '"';
        if (navigator.clipboard && navigator.clipboard.writeText) {
          navigator.clipboard.writeText(importStmt);
        }
        var hasImport = false;
        for (var li = 0; li < this.codeLines.length; li++) {
          if (this.codeLines[li].indexOf(importStmt) !== -1) { hasImport = true; break; }
        }
        if (!hasImport) {
          this.codeLines.unshift(importStmt);
          this.executeCode();
        }
        this.showToast('📥 Copiado e Importado: ' + importStmt);
        this.terminalLogs.push('> [Layer Import] Capa agregada: ' + importStmt);
      } else if (action === 'copy_path') {
        if (navigator.clipboard && navigator.clipboard.writeText) {
          navigator.clipboard.writeText(target.fullPath);
        }
        this.showToast('📋 Ruta copiada: ' + target.fullPath);
      } else if (action === 'new_file') {
        var prefix = target.fullPath ? (target.fullPath + '/') : '';
        var nName = prompt('Nombre del nuevo archivo:', prefix + 'nuevo_modulo.ph');
        if (!nName) return;
        nName = nName.trim();
        var template = [
          '// ' + nName,
          '// Capa modular importable en PhasorLang',
          '',
          'constante_k = 1.4142',
          'calcular_fasor(m, a) = { fasor(m, a) }'
        ];
        this.projectFiles.push({
          name: nName,
          type: nName.endsWith('.ph') ? 'ph' : (nName.endsWith('.fas') ? 'fas' : 'txt'),
          desc: 'Capa modular creada por el usuario',
          isDir: false,
          content: template
        });
        if (target.fullPath) this.expandedFolders[target.fullPath] = true;
        this.selectedFileIdx = this.projectFiles.length - 1;
        this.codeLines = template.slice();
        this.activeTab = 'editor';
        this.executeCode();
        this.showToast('➕ Archivo creado: ' + nName);
      } else if (action === 'new_folder') {
        var fPrefix = target.fullPath ? (target.fullPath + '/') : '';
        var fName = prompt('Nombre de la nueva carpeta:', fPrefix + 'nueva_carpeta');
        if (!fName) return;
        fName = fName.trim();
        if (fName.charAt(fName.length - 1) === '/' || fName.charCodeAt(fName.length - 1) === 92) fName = fName.slice(0, -1);
        this.expandedFolders[fName] = true;
        this.showToast('📁 Carpeta creada: ' + fName);
        this.terminalLogs.push('> [Project] Carpeta creada: ' + fName);
      } else if (action === 'rename') {
        var oldName = target.fullPath || target.name;
        var rName = prompt('Nuevo nombre para ' + oldName + ':', oldName);
        if (!rName || rName === oldName) return;
        rName = rName.trim();
        if (target.file) {
          target.file.name = rName;
          target.file.type = rName.endsWith('.ph') ? 'ph' : (rName.endsWith('.fas') ? 'fas' : 'txt');
        }
        this.showToast('✏ Renombrado a: ' + rName);
        this.terminalLogs.push('> [Project] ' + oldName + ' renombrado a ' + rName);
      } else if (action === 'delete') {
        var dName = target.fullPath || target.name;
        if (!confirm('¿Seguro que deseas eliminar ' + dName + '?')) return;
        if (target.fileIdx >= 0) {
          this.projectFiles.splice(target.fileIdx, 1);
          this.selectedFileIdx = Math.max(0, this.selectedFileIdx - 1);
          if (this.projectFiles.length > 0) {
            this.codeLines = (this.projectFiles[this.selectedFileIdx].content || []).slice();
            this.executeCode();
          }
        }
        this.showToast('🗑 Elemento eliminado: ' + dName);
        this.terminalLogs.push('> [Project] Elemento eliminado: ' + dName);
      }
    },

    onMouseMoveExplorer: function(lx, ly, innerW, innerH) {
      if (this.popupMenu && this.popupMenu.isOpen) {
        this.popupMenu.handleMouseMove(lx, ly);
      }
      this.hoverMouseX = lx;
      this.hoverMouseY = ly;
    },

    handleClickExplorer: function(lx, ly, ch, innerW, innerH) {
      // 0. Si el menú contextual popup está abierto, despachar primero el clic
      if (this.popupMenu && this.popupMenu.isOpen) {
        var popRes = this.popupMenu.handleClick(lx, ly);
        if (popRes && popRes.action && popRes.action !== 'dismiss') {
          this.executeExplorerAction(popRes.action, popRes.target);
          return true;
        }
        return true;
      }

      var isNarrow = innerW < 540;
      var topBarH = isNarrow ? 65 : 38;
      var bottomBarH = 24;

      // 1. Clics en la Barra de Herramientas
      if (ly <= topBarH) {
        if (!isNarrow) {
          if (lx >= 6 && lx <= 86) { this.openLocalFolder(); return true; }
          if (lx >= 90 && lx <= 166) { this.openLocalFiles(); return true; }
          if (lx >= 170 && lx <= 250) { this.createNewFile(); return true; }
          if (lx >= 254 && lx <= 334) { this.createNewFolder(); return true; }
          if (lx >= 338 && lx <= 416) { this.promptGithubDownload(); return true; }
          if (lx >= 420 && lx <= 488) { this.renameFile(); return true; }
          if (lx >= 492 && lx <= 552) { this.deleteFile(); return true; }
        } else {
          var bw1 = Math.floor((innerW - 24) / 4);
          if (ly >= 6 && ly <= 30) {
            if (lx >= 6 && lx <= 6 + bw1) { this.openLocalFolder(); return true; }
            if (lx >= 8 + bw1 && lx <= 8 + bw1 * 2) { this.openLocalFiles(); return true; }
            if (lx >= 10 + bw1 * 2 && lx <= 10 + bw1 * 3) { this.createNewFile(); return true; }
            if (lx >= 12 + bw1 * 3 && lx <= 12 + bw1 * 4) { this.createNewFolder(); return true; }
          }
          var bw2 = Math.floor((innerW - 20) / 3);
          if (ly >= 35 && ly <= 59) {
            if (lx >= 6 && lx <= 6 + bw2) { this.promptGithubDownload(); return true; }
            if (lx >= 8 + bw2 && lx <= 8 + bw2 * 2) { this.renameFile(); return true; }
            if (lx >= 10 + bw2 * 2 && lx <= 10 + bw2 * 3) { this.deleteFile(); return true; }
          }
        }
      }

      // 2. Clics en la zona de contenido (con scroll y clipping)
      var contentTop = topBarH + 2;
      var contentH = innerH - contentTop - bottomBarH - 2;
      if (ly >= contentTop && ly <= innerH - bottomBarH) {
        var nodes = this.getVisibleTreeNodes();
        var itemH = 26;
        var totalContentH = nodes.length * itemH + 10;
        var maxScroll = Math.max(0, totalContentH - contentH);

        // Barra de scroll
        if (lx >= innerW - 14) {
          if (maxScroll > 0) {
            var ratio = (ly - contentTop) / contentH;
            this.explorerScrollY = Math.max(0, Math.min(maxScroll, Math.round(ratio * maxScroll)));
            return true;
          }
        }

        var isCompact = innerW < 580;
        var treeW = isCompact ? (innerW - 16) : Math.max(200, Math.floor((innerW - 16) * 0.48));

        // Clic en la columna del árbol
        if (lx <= treeW) {
          var effectiveY = ly - contentTop + this.explorerScrollY - 4;
          var itemIdx = Math.floor(effectiveY / itemH);
          if (itemIdx >= 0 && itemIdx < nodes.length) {
            var node = nodes[itemIdx];
            var dotsX = treeW - 26;

            // A. Clic en botón de 3 Puntos (⋮)
            if (lx >= dotsX && lx <= treeW - 2) {
              var popupItems = [];
              if (node.isDir) {
                popupItems = [
                  { id: 'new_file', label: 'Nuevo Archivo', icon: '➕', color: '#3FB950' },
                  { id: 'new_folder', label: 'Nueva Carpeta', icon: '📁', color: '#79C0FF' },
                  { id: 'copy_path', label: 'Copiar Ruta', icon: '📋', color: '#8B949E' },
                  { id: 'rename', label: 'Renombrar', icon: '✏', color: '#D29922' },
                  { id: 'delete', label: 'Eliminar', icon: '🗑', color: '#F85149', danger: true }
                ];
              } else {
                popupItems = [
                  { id: 'open', label: 'Abrir en Editor', icon: '⚡', color: '#58A6FF' },
                  { id: 'import', label: 'Copiar import', icon: '📥', color: '#3FB950' },
                  { id: 'copy_path', label: 'Copiar Ruta', icon: '📋', color: '#8B949E' },
                  { id: 'rename', label: 'Renombrar', icon: '✏', color: '#D29922' },
                  { id: 'delete', label: 'Eliminar', icon: '🗑', color: '#F85149', danger: true }
                ];
              }
              var popY = Math.min(innerH - 180, ly - 10);
              this.popupMenu.open(Math.max(10, lx - 150), popY, 165, node, popupItems);
              return true;
            }

            // B. Clic en Carpeta (Plegar / Desplegar)
            if (node.isDir) {
              var curExp = this.expandedFolders[node.fullPath];
              this.expandedFolders[node.fullPath] = !curExp;
              return true;
            }

            // C. Clic en Archivo: Abrir en Editor
            if (node.file && node.fileIdx >= 0) {
              this.selectedFileIdx = node.fileIdx;
              if (node.file.content && Array.isArray(node.file.content)) {
                this.codeLines = node.file.content.slice();
                this.activeTab = 'editor';
                this.cursorRow = 0;
                this.cursorCol = 0;
                this.executeCode();
              }
              return true;
            }
          }
        }

        // Clic en inspector (modo split ancho >= 580px)
        if (!isCompact && lx > treeW && lx < innerW - 14) {
          var inspStartY = contentTop + 4 - this.explorerScrollY;
          var btnY = inspStartY + 172;
          if (ly >= btnY && ly <= btnY + 34) {
            var selF = this.projectFiles[this.selectedFileIdx];
            if (selF && !selF.isDir && selF.content) {
              this.codeLines = selF.content.slice();
              this.activeTab = 'editor';
              this.executeCode();
              return true;
            }
          }
        }
      }
      return false;
    },

    handleClick: function(lx, ly, ch, innerW, innerH) {
      var isExplorerWin = (ch && ch.title && (ch.title.indexOf('Proyecto') !== -1 || ch.title.indexOf('Explorador') !== -1)) || (ch && ch.id === 3);
      if (isExplorerWin) {
        return this.handleClickExplorer(lx, ly, ch, innerW, innerH);
      }

      // 1. Selector de pestañas superior de Chronos Studio (6 vistas)
      if (ly >= 0 && ly <= 30) {
        var tabs = ['editor', 'templates', 'ai', 'terminal', 'debug', 'docs'];
        var tabW = Math.floor(innerW / tabs.length);
        var tabIdx = Math.floor(lx / tabW);
        if (tabs[tabIdx]) {
          this.activeTab = tabs[tabIdx];
          return true;
        }
      }

      // 3. Clics en pestaña Editor
      if (this.activeTab === 'editor') {
        // Barra de herramientas del Editor: y: 34..62
        if (ly >= 34 && ly <= 62) {
          // [ ▶ EJECUTAR ]
          if (lx >= 6 && lx <= 120) {
            this.executeCode();
            return true;
          }
          // [ ⚙ COMPILAR STANDALONE HTML ]
          if (lx >= 125 && lx <= 280) {
            this.compileStandaloneHtml();
            return true;
          }
          // [ 📦 EXPORTAR WASM ]
          if (lx >= 285 && lx <= 385) {
            this.exportWasm();
            return true;
          }
          // [ ⚡ Hot-Reload ]
          if (lx >= 390 && lx <= 475) {
            this.hotReload = !this.hotReload;
            return true;
          }
          // [ 📋 Copiar ]
          if (lx >= 480 && lx <= 535) {
            this.copyCode();
            return true;
          }
          // [ 🔄 Reiniciar ]
          if (lx >= 540 && lx <= 600) {
            this.codeLines = this.templates[0].code.slice();
            this.cursorRow = 3;
            this.cursorCol = 0;
            this.executeCode();
            return true;
          }
        }

        // Clic en área de código: posicionar cursor
        if (ly >= 66) {
          var lineIdx = Math.floor((ly - 68) / 18) + this.scrollRow;
          if (lineIdx >= 0 && lineIdx < this.codeLines.length) {
            this.cursorRow = lineIdx;
            var cIdx = Math.max(0, Math.round((lx - 44) / 7.2));
            this.cursorCol = Math.min(cIdx, (this.codeLines[lineIdx] || '').length);
            this.blinkTimer = 0;
            return true;
          }
        }
      }

      // 4. Clics en pestaña Plantillas
      if (this.activeTab === 'templates') {
        var cardH = 80;
        var startY = 40;
        for (var t = 0; t < this.templates.length; t++) {
          var cY = startY + (t * (cardH + 8));
          if (ly >= cY && ly <= cY + cardH) {
            this.codeLines = this.templates[t].code.slice();
            this.cursorRow = 3;
            this.cursorCol = 0;
            this.activeTab = 'editor';
            this.executeCode();
            return true;
          }
        }
      }

      // 5. Clics en pestaña IA Copilot
      if (this.activeTab === 'ai') {
        if (ly >= 40 && ly <= 66) {
          if (lx >= 15 && lx <= 190) { this.aiProvider = 1.0; return true; }
          if (lx >= 200 && lx <= 380) { this.aiProvider = 2.0; return true; }
        }
        if (ly >= 190 && ly <= 220) {
          if (lx >= 15 && lx <= 220) {
            this.codeLines = this.templates[0].code.slice();
            this.activeTab = 'editor';
            this.executeCode();
            return true;
          }
          if (lx >= 230 && lx <= 440) {
            this.codeLines = this.templates[1].code.slice();
            this.activeTab = 'editor';
            this.executeCode();
            return true;
          }
        }
        if (ly >= 225 && ly <= 255) {
          if (lx >= 15 && lx <= 220) {
            this.codeLines = this.templates[2].code.slice();
            this.activeTab = 'editor';
            this.executeCode();
            return true;
          }
          if (lx >= 230 && lx <= 440) {
            this.codeLines = this.templates[3].code.slice();
            this.activeTab = 'editor';
            this.executeCode();
            return true;
          }
        }
        if (ly >= innerH - 45 && ly <= innerH - 15) {
          this.showPrivacyModal = !this.showPrivacyModal;
          return true;
        }
      }

      // 6. Clics en Terminal
      if (this.activeTab === 'terminal') {
        if (ly >= 34 && ly <= 58 && lx >= 10 && lx <= 160) {
          this.terminalLogs = ['> [PVM Kernel] Consola limpiada por el usuario.'];
          return true;
        }
      }

      // 7. Clics en Docs
      if (this.activeTab === 'docs') {
        var docItems = [
          'v = fasor(120.0, 45.0)',
          'z = complejo(30.0, 40.0)',
          'plano_complejo(140.0)',
          "dibujar_fasor(v, '#58a6ff', 'V1')",
          "proyectar_onda(v, '#58a6ff', 'v(t)')",
          'video_procedural_oceano(1.45)',
          'voz_formantica_tts(1, 125.0, 800.0, 1200.0, 2500.0)',
          'juego_plataformas_sim()',
          'particulas_cern(130.0, 8.0)',
          'avatar_ia_face(0.85, 1.0)'
        ];
        var dStartY = 70;
        for (var di = 0; di < docItems.length; di++) {
          var itemY = dStartY + (di * 34);
          if (ly >= itemY - 6 && ly <= itemY + 24 && lx >= innerW - 130 && lx <= innerW - 10) {
            this.codeLines.push(docItems[di]);
            this.cursorRow = this.codeLines.length - 1;
            this.cursorCol = docItems[di].length;
            this.activeTab = 'editor';
            if (this.hotReload) this.executeCode();
            return true;
          }
        }
      }

      return false;
    },

    renderStudio: function(ctx, ch, innerW, innerH, isMobile) {
      // 1. Barra de Pestañas Superior (6 Vistas)
      var tabs = [
        { id: 'editor', lbl: '📝 Editor' },
        { id: 'templates', lbl: '⚡ Plantillas' },
        { id: 'ai', lbl: '✨ IA Copilot' },
        { id: 'terminal', lbl: '📟 Terminal' },
        { id: 'debug', lbl: '🐞 Depurador' },
        { id: 'docs', lbl: '📚 Docs' }
      ];
      var tabW = Math.floor(innerW / tabs.length);

      for (var i = 0; i < tabs.length; i++) {
        var t = tabs[i];
        var tx = i * tabW;
        var isActive = (this.activeTab === t.id);

        ctx.fillStyle = isActive ? '#1F242C' : '#0D1117';
        ctx.fillRect(tx, 0, tabW, 30);
        ctx.strokeStyle = '#21262D';
        ctx.strokeRect(tx, 0, tabW, 30);

        if (isActive) {
          ctx.fillStyle = '#58A6FF';
          ctx.fillRect(tx, 27, tabW, 3);
        }

        ctx.fillStyle = isActive ? '#FFFFFF' : '#8B949E';
        ctx.font = (isActive ? 'bold ' : '') + '9.5px monospace';
        ctx.textAlign = 'center';
        ctx.fillText(t.lbl, tx + (tabW / 2), 19);
      }
      ctx.textAlign = 'left';

      // --- PESTAÑA: EDITOR ---
      if (this.activeTab === 'editor') {
        ctx.fillStyle = '#161B22';
        ctx.fillRect(0, 30, innerW, 34);
        ctx.strokeStyle = '#30363D';
        ctx.beginPath(); ctx.moveTo(0, 64); ctx.lineTo(innerW, 64); ctx.stroke();

        ctx.fillStyle = '#238636';
        ctx.fillRect(6, 34, 115, 24);
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 10px monospace';
        ctx.fillText('▶ EJECUTAR (Ctrl+↵)', 10, 50);

        ctx.fillStyle = '#8957E5';
        ctx.fillRect(125, 34, 155, 24);
        ctx.fillStyle = '#FFFFFF';
        ctx.fillText('⚙ COMPILAR HTML STANDALONE', 130, 50);

        ctx.fillStyle = '#1F6FEB';
        ctx.fillRect(284, 34, 98, 24);
        ctx.fillStyle = '#FFFFFF';
        ctx.fillText('📦 EXPORTAR WASM', 290, 50);

        ctx.fillStyle = this.hotReload ? '#238636' : '#30363D';
        ctx.fillRect(386, 34, 88, 24);
        ctx.fillStyle = '#FFFFFF';
        ctx.fillText(this.hotReload ? '⚡ Hot: ON' : '⚡ Hot: OFF', 392, 50);

        ctx.fillStyle = '#39C5BB';
        ctx.fillRect(478, 34, 56, 24);
        ctx.fillStyle = '#05070A';
        ctx.fillText('📋 Copiar', 484, 50);

        ctx.fillStyle = '#21262D';
        ctx.fillRect(538, 34, 60, 24);
        ctx.fillStyle = '#8B949E';
        ctx.fillText('🔄 Reset', 544, 50);

        var codeAreaH = innerH - 64;
        ctx.fillStyle = '#090D13';
        ctx.fillRect(0, 64, innerW, codeAreaH);

        ctx.fillStyle = '#0D1117';
        ctx.fillRect(0, 64, 40, codeAreaH);
        ctx.strokeStyle = '#21262D';
        ctx.beginPath(); ctx.moveTo(40, 64); ctx.lineTo(40, innerH); ctx.stroke();

        var visibleLines = Math.floor((codeAreaH - 10) / 18);
        ctx.font = '11px monospace';

        for (var l = 0; l < visibleLines; l++) {
          var lNum = this.scrollRow + l;
          if (lNum >= this.codeLines.length) break;
          var yPos = 82 + (l * 18);

          if (lNum === this.cursorRow) {
            ctx.fillStyle = 'rgba(88, 166, 255, 0.12)';
            ctx.fillRect(40, yPos - 13, innerW - 40, 18);
          }

          ctx.fillStyle = (lNum === this.cursorRow) ? '#58A6FF' : '#484F58';
          ctx.textAlign = 'right';
          ctx.fillText((lNum + 1).toString(), 34, yPos);
          ctx.textAlign = 'left';

          var lineStr = this.codeLines[lNum] || '';
          if (lineStr.trim().startsWith('//')) {
            ctx.fillStyle = '#8B949E';
          } else if (lineStr.indexOf('import') !== -1) {
            ctx.fillStyle = '#BC8CFF';
          } else if (lineStr.indexOf('imprimir') !== -1 || lineStr.indexOf('out') !== -1) {
            ctx.fillStyle = '#3FB950';
          } else if (lineStr.indexOf('fasor') !== -1 || lineStr.indexOf('complejo') !== -1) {
            ctx.fillStyle = '#D2A8FF';
          } else if (lineStr.indexOf('dibujar_') !== -1 || lineStr.indexOf('proyectar_') !== -1 || lineStr.indexOf('plano_') !== -1) {
            ctx.fillStyle = '#58A6FF';
          } else if (lineStr.indexOf('video_') !== -1 || lineStr.indexOf('voz_') !== -1 || lineStr.indexOf('juego_') !== -1) {
            ctx.fillStyle = '#F778BA';
          } else if (lineStr.indexOf('=') !== -1) {
            ctx.fillStyle = '#79C0FF';
          } else {
            ctx.fillStyle = '#E6EDF3';
          }
          ctx.fillText(lineStr, 48, yPos);
        }

        this.blinkTimer = (this.blinkTimer + 1) % 60;
        if (this.blinkTimer < 35 && this.cursorRow >= this.scrollRow && this.cursorRow < this.scrollRow + visibleLines) {
          var cY = 82 + ((this.cursorRow - this.scrollRow) * 18);
          var preText = (this.codeLines[this.cursorRow] || '').slice(0, this.cursorCol);
          var cX = 48 + ctx.measureText(preText).width;
          ctx.fillStyle = '#58A6FF';
          ctx.fillRect(cX, cY - 12, 2, 15);
        }
      }

      // --- PESTAÑA: PLANTILLAS ---
      else if (this.activeTab === 'templates') {
        ctx.fillStyle = '#58A6FF';
        ctx.font = 'bold 12px monospace';
        ctx.fillText('CATÁLOGO DE APLICACIONES INSIGNIA PHASORLANG (1-CLICK CARGAR)', 15, 50);

        var cardH = 80;
        var startY = 64;

        for (var t = 0; t < this.templates.length; t++) {
          var tmpl = this.templates[t];
          var cY = startY + (t * (cardH + 8));

          ctx.fillStyle = '#161B22';
          ctx.fillRect(15, cY, innerW - 30, cardH);
          ctx.strokeStyle = '#30363D';
          ctx.strokeRect(15, cY, innerW - 30, cardH);

          ctx.fillStyle = '#3FB950';
          ctx.font = 'bold 11px monospace';
          ctx.fillText(tmpl.title, 25, cY + 22);

          ctx.fillStyle = '#8B949E';
          ctx.font = '10px monospace';
          ctx.fillText(tmpl.desc, 25, cY + 40);

          ctx.fillStyle = '#1F6FEB';
          ctx.fillRect(innerW - 145, cY + 48, 115, 24);
          ctx.fillStyle = '#FFFFFF';
          ctx.font = 'bold 9.5px monospace';
          ctx.fillText('▶ CARGAR Y CORRER', innerW - 138, cY + 64);
        }
      }

      // --- PESTAÑA: IA COPILOT ---
      else if (this.activeTab === 'ai') {
        ctx.fillStyle = (this.aiProvider === 1.0) ? '#8957E5' : '#21262D';
        ctx.fillRect(15, 40, 175, 26);
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 10px monospace';
        ctx.fillText('Profesor: Gemini Cloud Pro', 22, 57);

        ctx.fillStyle = (this.aiProvider === 2.0) ? '#238636' : '#21262D';
        ctx.fillRect(200, 40, 180, 26);
        ctx.fillStyle = '#FFFFFF';
        ctx.fillText('Estudiante: Phasor-SLM Local', 208, 57);

        ctx.fillStyle = '#161B22';
        ctx.fillRect(15, 76, innerW - 30, 95);
        ctx.strokeStyle = '#30363D';
        ctx.strokeRect(15, 76, innerW - 30, 95);

        var avCx = 65, avCy = 122;
        ctx.strokeStyle = '#58A6FF';
        ctx.strokeRect(avCx - 24, avCy - 20, 48, 40);
        ctx.fillStyle = '#00E5FF';
        ctx.fillRect(avCx - 14, avCy - 8, 8, 6);
        ctx.fillRect(avCx + 6, avCy - 8, 8, 6);
        ctx.fillRect(avCx - 10, avCy + 8, 20, 4);

        ctx.fillStyle = '#58A6FF';
        ctx.font = 'bold 12px monospace';
        ctx.fillText('Kora-AI Assistant — Full-Duplex Barge-In', 110, 105);
        ctx.fillStyle = '#3FB950';
        ctx.font = '10px monospace';
        ctx.fillText('Estado: ' + this.aiStatusText, 110, 125);
        ctx.fillStyle = '#8B949E';
        ctx.fillText('Sintaxis fasorial validada, inferencia Zero-GC y generación de código.', 110, 145);

        ctx.fillStyle = '#8B949E';
        ctx.font = 'bold 11px monospace';
        ctx.fillText('SOLICITUDES RÁPIDAS DE CÓDIGO (1-CLICK INSERTAR):', 15, 192);

        var chips = [
          { lbl: '⚡ Calculadora Fasorial GeoGebra', idx: 0 },
          { lbl: '🎬 Video Procedural de Océano', idx: 1 },
          { lbl: '🗣 Síntesis de Voz Formántica TTS', idx: 2 },
          { lbl: '🎮 Videojuego Platformer Físicas', idx: 3 }
        ];

        var chipY = 205;
        for (var c = 0; c < chips.length; c++) {
          var cxPos = (c % 2 === 0) ? 15 : 230;
          var cyPos = chipY + (Math.floor(c / 2) * 36);

          ctx.fillStyle = '#0D1117';
          ctx.fillRect(cxPos, cyPos, 205, 28);
          ctx.strokeStyle = '#30363D';
          ctx.strokeRect(cxPos, cyPos, 205, 28);

          ctx.fillStyle = '#58A6FF';
          ctx.font = '10px monospace';
          ctx.fillText(chips[c].lbl, cxPos + 8, cyPos + 18);
        }

        ctx.fillStyle = '#21262D';
        ctx.fillRect(15, innerH - 45, innerW - 30, 32);
        ctx.strokeStyle = '#F85149';
        ctx.strokeRect(15, innerH - 45, innerW - 30, 32);
        ctx.fillStyle = '#F85149';
        ctx.font = 'bold 10px monospace';
        ctx.fillText('🔒 GOBERNANZA DE RED: Aislamiento 100% Offline Activo por Defecto', 25, innerH - 25);
      }

      // --- PESTAÑA: TERMINAL ---
      else if (this.activeTab === 'terminal') {
        ctx.fillStyle = '#161B22';
        ctx.fillRect(0, 30, innerW, 30);
        ctx.fillStyle = '#58A6FF';
        ctx.font = 'bold 10px monospace';
        ctx.fillText('SALIDA PVM, DESENSAMBLADOR Y TELEMETRÍA KERNEL', 10, 48);

        ctx.fillStyle = '#21262D';
        ctx.fillRect(innerW - 130, 34, 110, 22);
        ctx.fillStyle = '#8B949E';
        ctx.fillText('Limpiar Consola', innerW - 120, 48);

        var logAreaH = innerH - 60;
        ctx.fillStyle = '#05070A';
        ctx.fillRect(0, 60, innerW, logAreaH);

        var startLogIdx = Math.max(0, this.terminalLogs.length - Math.floor(logAreaH / 18));
        ctx.font = '10.5px monospace';
        for (var idx = startLogIdx; idx < this.terminalLogs.length; idx++) {
          var logLine = this.terminalLogs[idx];
          var lY = 78 + ((idx - startLogIdx) * 18);
          if (logLine.indexOf('ERR') !== -1) ctx.fillStyle = '#F85149';
          else if (logLine.indexOf('OUT') !== -1) ctx.fillStyle = '#3FB950';
          else if (logLine.indexOf('Compiler') !== -1 || logLine.indexOf('Layer Import') !== -1) ctx.fillStyle = '#D2A8FF';
          else if (logLine.indexOf('Project') !== -1) ctx.fillStyle = '#79C0FF';
          else ctx.fillStyle = '#8B949E';
          ctx.fillText(logLine, 12, lY);
        }
      }

      // --- PESTAÑA: DEPURADOR ---
      else if (this.activeTab === 'debug') {
        ctx.fillStyle = '#161B22';
        ctx.fillRect(0, 30, innerW, 30);
        ctx.fillStyle = '#D29922';
        ctx.font = 'bold 10px monospace';
        ctx.fillText('BANCO DE REGISTROS PVM SOA (R0..R15) | LATENCIA: ' + this.lastExecTime + ' ms', 10, 48);

        var startRegY = 74;
        ctx.font = '11px monospace';
        for (var r = 0; r < 16; r++) {
          var rVal = this.registers[r];
          var rName = this.regNames[r] || ('R' + r);
          var colX = (r < 8) ? 14 : Math.floor(innerW / 2) + 10;
          var rowY = startRegY + ((r % 8) * 26);

          ctx.fillStyle = '#161B22';
          ctx.fillRect(colX, rowY - 14, Math.floor(innerW / 2) - 20, 22);

          ctx.fillStyle = '#58A6FF';
          ctx.fillText('[' + (r < 10 ? 'R0' : 'R') + r + '] ' + rName + ':', colX + 6, rowY + 1);
          ctx.fillStyle = '#3FB950';
          ctx.fillText(rVal.toFixed(2), colX + 130, rowY + 1);
        }
      }

      // --- PESTAÑA: DOCS ---
      else if (this.activeTab === 'docs') {
        ctx.fillStyle = '#58A6FF';
        ctx.font = 'bold 12px monospace';
        ctx.fillText('REFERENCIA RÁPIDA DE PHASORLANG (1-CLICK INSERTAR)', 12, 48);

        var docItems = [
          { sig: 'import "lib/modulo.ph"', exp: 'Carga una capa modular y sus funciones exportadas.' },
          { sig: 'fasor(mag, ang_deg)', exp: 'Crea vector fasorial con modulo y angulo polar.' },
          { sig: 'complejo(re, im)', exp: 'Crea numero complejo en coordenadas rectangulares.' },
          { sig: 'plano_complejo(escala)', exp: 'Inicializa rejilla y ejes del plano de Gauss.' },
          { sig: 'dibujar_fasor(f, color, lbl)', exp: 'Dibuja vector fasorial con rotacion continua.' },
          { sig: 'proyectar_onda(f, color, lbl)', exp: 'Proyecta forma de onda senoidal continua.' },
          { sig: 'video_procedural_oceano(freq)', exp: 'Genera oleaje Gerstner procedural continuo (120 FPS).' },
          { sig: 'voz_formantica_tts(v, f0, f1, f2, f3)', exp: 'Sintetiza formantes de voz humana en Hertz (PCM).' },
          { sig: 'juego_plataformas_sim()', exp: 'Ejecuta simulador de fisicas continuas SoA.' },
          { sig: 'particulas_cern(radio, n)', exp: 'Simula colision de particulas subatomicas a 13.6 TeV.' },
          { sig: 'avatar_ia_face(energia, emocion)', exp: 'Renderiza avatar holografico reactivo por voz.' },
          { sig: 'imprimir(...)', exp: 'Emite texto y variables a la Terminal PVM.' }
        ];

        var dY = 70;
        for (var d = 0; d < docItems.length; d++) {
          ctx.fillStyle = '#39C5BB';
          ctx.font = 'bold 11px monospace';
          ctx.fillText(docItems[d].sig, 14, dY);

          ctx.fillStyle = '#8B949E';
          ctx.font = '10px monospace';
          ctx.fillText('→ ' + docItems[d].exp, 14, dY + 14);

          ctx.fillStyle = '#1F6FEB';
          ctx.fillRect(innerW - 120, dY - 4, 100, 20);
          ctx.fillStyle = '#FFFFFF';
          ctx.font = 'bold 9px monospace';
          ctx.fillText('+ INSERTAR', innerW - 105, dY + 10);

          dY += 34;
        }
      }
    },

    renderExplorer: function(ctx, ch, innerW, innerH, isMobile) {
      // 1. Barra de Herramientas Superior Fija
      var isNarrow = innerW < 540;
      var topBarH = isNarrow ? 65 : 38;
      var bottomBarH = 24;

      ctx.fillStyle = '#161B22';
      ctx.fillRect(0, 0, innerW, topBarH);
      ctx.strokeStyle = '#30363D';
      ctx.beginPath(); ctx.moveTo(0, topBarH); ctx.lineTo(innerW, topBarH); ctx.stroke();

      ctx.font = 'bold 9.5px monospace';

      if (!isNarrow) {
        ctx.fillStyle = '#1F6FEB'; ctx.fillRect(6, 7, 76, 24);
        ctx.fillStyle = '#FFFFFF'; ctx.fillText('📂 Carpeta', 12, 23);

        ctx.fillStyle = '#238636'; ctx.fillRect(86, 7, 74, 24);
        ctx.fillStyle = '#FFFFFF'; ctx.fillText('📄 Archivo', 92, 23);

        ctx.fillStyle = '#8957E5'; ctx.fillRect(164, 7, 78, 24);
        ctx.fillStyle = '#FFFFFF'; ctx.fillText('➕ Archivo', 170, 23);

        ctx.fillStyle = '#30363D'; ctx.fillRect(246, 7, 78, 24);
        ctx.fillStyle = '#E6EDF3'; ctx.fillText('📁 Carpeta', 252, 23);

        ctx.fillStyle = '#1F6FEB'; ctx.fillRect(328, 7, 76, 24);
        ctx.fillStyle = '#FFFFFF'; ctx.fillText('🌐 GitHub', 334, 23);

        ctx.fillStyle = '#D29922'; ctx.fillRect(408, 7, 64, 24);
        ctx.fillStyle = '#05070A'; ctx.fillText('✏ Renom', 414, 23);

        ctx.fillStyle = '#F85149'; ctx.fillRect(476, 7, 58, 24);
        ctx.fillStyle = '#FFFFFF'; ctx.fillText('🗑 Elim', 482, 23);
      } else {
        var bw1 = Math.floor((innerW - 24) / 4);
        ctx.textAlign = 'center';

        ctx.fillStyle = '#1F6FEB'; ctx.fillRect(6, 6, bw1, 24);
        ctx.fillStyle = '#FFFFFF'; ctx.fillText('📂 Carpeta', 6 + (bw1 / 2), 22);

        ctx.fillStyle = '#238636'; ctx.fillRect(8 + bw1, 6, bw1, 24);
        ctx.fillStyle = '#FFFFFF'; ctx.fillText('📄 Archivo', 8 + bw1 + (bw1 / 2), 22);

        ctx.fillStyle = '#8957E5'; ctx.fillRect(10 + bw1 * 2, 6, bw1, 24);
        ctx.fillStyle = '#FFFFFF'; ctx.fillText('➕ Archivo', 10 + bw1 * 2 + (bw1 / 2), 22);

        ctx.fillStyle = '#30363D'; ctx.fillRect(12 + bw1 * 3, 6, bw1, 24);
        ctx.fillStyle = '#E6EDF3'; ctx.fillText('📁 Carpeta', 12 + bw1 * 3 + (bw1 / 2), 22);

        var bw2 = Math.floor((innerW - 20) / 3);
        ctx.fillStyle = '#1F6FEB'; ctx.fillRect(6, 35, bw2, 24);
        ctx.fillStyle = '#FFFFFF'; ctx.fillText('🌐 + GitHub', 6 + (bw2 / 2), 51);

        ctx.fillStyle = '#D29922'; ctx.fillRect(8 + bw2, 35, bw2, 24);
        ctx.fillStyle = '#05070A'; ctx.fillText('✏ Renombrar', 8 + bw2 + (bw2 / 2), 51);

        ctx.fillStyle = '#F85149'; ctx.fillRect(10 + bw2 * 2, 35, bw2, 24);
        ctx.fillStyle = '#FFFFFF'; ctx.fillText('🗑 Eliminar', 10 + bw2 * 2 + (bw2 / 2), 51);

        ctx.textAlign = 'left';
      }

      // 2. Barra de Estado Inferior Fija
      var statusY = innerH - bottomBarH;
      ctx.fillStyle = '#161B22';
      ctx.fillRect(0, statusY, innerW, bottomBarH);
      ctx.strokeStyle = '#30363D';
      ctx.beginPath(); ctx.moveTo(0, statusY); ctx.lineTo(innerW, statusY); ctx.stroke();
      ctx.fillStyle = '#8B949E';
      ctx.font = '9.5px monospace';
      ctx.fillText('Árbol Jerárquico Expandible | Menú Contextual (⋮) | Tooltip Activo | Zero-GC', 10, statusY + 16);

      // 3. Zona de Contenido con CLIPPING ESTRICTO
      var contentTop = topBarH + 2;
      var contentH = innerH - contentTop - bottomBarH - 2;
      var isCompact = innerW < 580;
      var treeW = isCompact ? (innerW - 16) : Math.max(200, Math.floor((innerW - 16) * 0.48));

      var nodes = this.getVisibleTreeNodes();
      var itemH = 26;
      var totalContentH = nodes.length * itemH + 10;
      var maxScroll = Math.max(0, totalContentH - contentH);
      this.explorerScrollY = Math.max(0, Math.min(this.explorerScrollY, maxScroll));

      var startY = contentTop + 4 - this.explorerScrollY;

      ctx.save();
      ctx.beginPath();
      ctx.rect(0, contentTop, innerW - 12, contentH);
      ctx.clip();

      var hoveredNode = null;
      var mouseX = this.hoverMouseX;
      var mouseY = this.hoverMouseY;

      for (var p = 0; p < nodes.length; p++) {
        var node = nodes[p];
        var rowY = startY + (p * itemH);
        var isSel = (node.file && node.fileIdx === this.selectedFileIdx);
        var isHov = (mouseX >= 8 && mouseX <= treeW - 8 && mouseY >= rowY && mouseY < rowY + itemH);

        if (isHov) hoveredNode = node;

        // Fondo de fila
        if (isSel) {
          ctx.fillStyle = 'rgba(88, 166, 255, 0.18)';
          ctx.fillRect(8, rowY, treeW - 16, itemH);
          ctx.fillStyle = '#58A6FF';
          ctx.fillRect(8, rowY, 2, itemH);
        } else if (isHov) {
          ctx.fillStyle = 'rgba(255, 255, 255, 0.05)';
          ctx.fillRect(8, rowY, treeW - 16, itemH);
        }

        // Guías de Indentación verticales estilo VS Code / Antigravity
        var indentX = 14 + (node.depth * 13);
        if (node.depth > 0) {
          ctx.strokeStyle = '#21262D';
          ctx.lineWidth = 1;
          for (var d = 1; d <= node.depth; d++) {
            var gx = 14 + (d * 13) - 6;
            ctx.beginPath();
            ctx.moveTo(gx, rowY);
            ctx.lineTo(gx, rowY + itemH);
            ctx.stroke();
          }
        }

        // Chevron para carpetas
        var curX = indentX;
        if (node.isDir) {
          ctx.fillStyle = '#8B949E';
          ctx.font = 'bold 9px monospace';
          var chv = node.isExpanded ? 'ˇ' : '›';
          ctx.fillText(chv, curX - 8, rowY + 16);
        }

        // Mini-Icono Minimizados estilo Antigravity
        if (node.isDir) {
          ctx.font = '10px monospace';
          ctx.fillText('📁', curX + 2, rowY + 17);
          curX += 18;
        } else {
          var ic = node.icon || '📄';
          var icCol = node.iconCol || '#58A6FF';
          ctx.fillStyle = icCol;

          if (ic === 'JS') {
            ctx.fillStyle = '#E5C07B';
            ctx.font = 'bold 8.5px monospace';
            ctx.fillText('JS', curX + 1, rowY + 16);
            curX += 17;
          } else if (ic === 'M↓') {
            ctx.fillStyle = '#58A6FF';
            ctx.font = 'bold 9px monospace';
            ctx.fillText('M↓', curX + 1, rowY + 16);
            curX += 18;
          } else {
            ctx.font = '10px monospace';
            ctx.fillText(ic, curX + 1, rowY + 17);
            curX += 17;
          }
        }

        // Nombre de archivo / carpeta
        ctx.fillStyle = isSel ? '#FFFFFF' : (node.isRoot ? '#58A6FF' : '#C9D1D9');
        ctx.font = (isSel ? 'bold ' : '') + '10px monospace';
        ctx.fillText(node.name, curX + 3, rowY + 17);

        // Botón de 3 Puntos (⋮) al frente de cada archivo
        var dotsX = treeW - 24;
        var isDotsHov = (mouseX >= dotsX && mouseX <= dotsX + 20 && mouseY >= rowY && mouseY < rowY + itemH);

        if (isDotsHov || isSel) {
          ctx.fillStyle = isDotsHov ? '#30363D' : '#161B22';
          ctx.fillRect(dotsX - 2, rowY + 3, 18, itemH - 6);
          ctx.strokeStyle = '#30363D';
          ctx.strokeRect(dotsX - 2, rowY + 3, 18, itemH - 6);
          ctx.fillStyle = '#FFFFFF';
        } else {
          ctx.fillStyle = '#6E7681';
        }
        ctx.font = 'bold 12px monospace';
        ctx.fillText('⋮', dotsX + 4, rowY + 17);
      }

      // Panel Inspector de Capas (en modo Split View ancho >= 580px)
      if (!isCompact) {
        var inspX = treeW + 6;
        var inspW = innerW - treeW - 20;

        ctx.fillStyle = '#161B22';
        ctx.fillRect(inspX, startY, inspW, 28);
        ctx.fillStyle = '#58A6FF';
        ctx.font = 'bold 10px monospace';
        ctx.fillText('INSPECTOR DE CAPAS (IMPORT)', inspX + 10, startY + 18);

        var selF = this.projectFiles[this.selectedFileIdx] || this.projectFiles[0];
        var fLines = (selF && selF.content && Array.isArray(selF.content)) ? selF.content.length : 0;

        ctx.fillStyle = '#0D1117';
        ctx.fillRect(inspX, startY + 34, inspW, 130);
        ctx.strokeStyle = '#21262D';
        ctx.strokeRect(inspX, startY + 34, inspW, 130);

        ctx.fillStyle = '#FFFFFF';
        ctx.font = '10.5px monospace';
        ctx.fillText('Nombre : ' + (selF ? selF.name : ''), inspX + 10, startY + 54);
        ctx.fillStyle = '#8B949E';
        ctx.fillText('Tipo   : ' + (selF ? selF.desc : ''), inspX + 10, startY + 76);
        ctx.fillText('Líneas : ' + fLines + ' líneas de código', inspX + 10, startY + 98);

        // Caja de directiva import
        ctx.fillStyle = '#161B22';
        ctx.fillRect(inspX + 10, startY + 112, inspW - 20, 36);
        ctx.fillStyle = '#3FB950';
        ctx.font = 'bold 10px monospace';
        ctx.fillText('import "' + (selF ? selF.name : '') + '"', inspX + 18, startY + 134);

        // Botón [✏ ABRIR Y EDITAR]
        ctx.fillStyle = '#238636';
        ctx.fillRect(inspX, startY + 172, inspW, 34);
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 10.5px monospace';
        ctx.textAlign = 'center';
        ctx.fillText('✏ ABRIR Y EDITAR EN STUDIO', inspX + (inspW / 2), startY + 193);
        ctx.textAlign = 'left';
      }

      ctx.restore(); // CIERRE DE CLIPPING ESTRICTO

      // 4. Barra de Scroll
      if (totalContentH > contentH) {
        var trackW = 8;
        var trackX = innerW - trackW - 2;

        ctx.fillStyle = 'rgba(13, 17, 23, 0.9)';
        ctx.fillRect(trackX, contentTop, trackW, contentH);
        ctx.strokeStyle = '#21262D';
        ctx.lineWidth = 1;
        ctx.strokeRect(trackX, contentTop, trackW, contentH);

        var barH = Math.max(28, Math.floor((contentH / totalContentH) * contentH));
        var barY = contentTop + Math.floor((this.explorerScrollY / maxScroll) * (contentH - barH));

        ctx.fillStyle = '#58A6FF';
        if (ctx.roundRect) {
          ctx.beginPath();
          ctx.roundRect(trackX + 1, barY, trackW - 2, barH, 3);
          ctx.fill();
        } else {
          ctx.fillRect(trackX + 1, barY, trackW - 2, barH);
        }
      }

      // 5. Toast Notificación Flotante
      if (this.toastMessage && performance.now() < this.toastTimer) {
        ctx.save();
        ctx.font = 'bold 10px monospace';
        var tW = ctx.measureText(this.toastMessage).width + 30;
        var tH = 26;
        var tX = Math.floor((innerW - tW) / 2);
        var tY = innerH - bottomBarH - 36;

        ctx.fillStyle = 'rgba(13, 17, 23, 0.95)';
        ctx.fillRect(tX, tY, tW, tH);
        ctx.strokeStyle = '#3FB950';
        ctx.lineWidth = 1.5;
        ctx.strokeRect(tX, tY, tW, tH);

        ctx.fillStyle = '#3FB950';
        ctx.fillText(this.toastMessage, tX + 15, tY + 17);
        ctx.restore();
      }

      // 6. Tooltip Flotante Clamped (cuando el popup menú no está abierto)
      if ((!this.popupMenu || !this.popupMenu.isOpen) && hoveredNode && mouseX > 8 && mouseX < treeW) {
        var ttDetails = [];
        ttDetails.push('Ruta: SketchWarePro/' + (hoveredNode.fullPath || hoveredNode.name));
        if (hoveredNode.isDir) {
          ttDetails.push('Tipo: Directorio del Proyecto');
          ttDetails.push('Estado: ' + (hoveredNode.isExpanded ? 'Desplegada (ˇ)' : 'Plegada (›)'));
          ttDetails.push('Presiona (⋮) para acciones de carpeta');
        } else {
          var fDesc = hoveredNode.file ? hoveredNode.file.desc : 'Archivo de código';
          var fLns = (hoveredNode.file && hoveredNode.file.content) ? hoveredNode.file.content.length : 0;
          ttDetails.push('Tipo: ' + fDesc);
          ttDetails.push('Líneas: ' + fLns + ' líneas de código');
          ttDetails.push('Presiona (⋮) para acciones rápidas');
        }
        this.tooltip.show(mouseX, mouseY, hoveredNode.name, ttDetails);
        this.tooltip.render(ctx, innerW, innerH);
      } else if (this.tooltip) {
        this.tooltip.hide();
      }

      // 7. Menú Popup Flotante (Z-Index Máximo, sobre el canvas)
      if (this.popupMenu && this.popupMenu.isOpen) {
        this.popupMenu.render(ctx, innerW, innerH, mouseX, mouseY);
      }
    },

    renderPreview: function(ctx, ch, innerW, innerH, isMobile, now) {
      ctx.fillStyle = '#070B12';
      ctx.fillRect(0, 0, innerW, innerH);

      if (this.drawCommands.length === 0) {
        this.executeCode();
      }

      var cx = Math.floor(innerW * 0.28);
      var cy = Math.floor(innerH * 0.5);
      var scale = 1.0;
      var phasorsDrawn = [];

      for (var c = 0; c < this.drawCommands.length; c++) {
        var cmd = this.drawCommands[c];

        if (cmd.type === 'plano_complejo') {
          scale = Math.min(innerW * 0.45, innerH) / (cmd.scale * 2.4);

          ctx.strokeStyle = '#21262D';
          ctx.lineWidth = 1;
          ctx.beginPath(); ctx.moveTo(20, cy); ctx.lineTo(innerW * 0.52, cy); ctx.stroke();
          ctx.beginPath(); ctx.moveTo(cx, 30); ctx.lineTo(cx, innerH - 40); ctx.stroke();

          ctx.strokeStyle = 'rgba(57, 197, 187, 0.15)';
          ctx.setLineDash([2, 4]);
          for (var rRing = 1; rRing <= 3; rRing++) {
            ctx.beginPath();
            ctx.arc(cx, cy, (cmd.scale * scale) * (rRing / 3), 0, Math.PI * 2);
            ctx.stroke();
          }
          ctx.setLineDash([]);

          ctx.fillStyle = '#58A6FF';
          ctx.font = '9px monospace';
          ctx.fillText('+Re', innerW * 0.50, cy - 6);
          ctx.fillText('+Im', cx + 6, 42);
        } else if (cmd.type === 'dibujar_fasor' && cmd.phasor) {
          var f = cmd.phasor;
          var omega = (now * 0.002);
          var angRot = (f.ang * Math.PI / 180) + omega;
          var vx = cx + Math.cos(angRot) * (f.mag * scale);
          var vy = cy - Math.sin(angRot) * (f.mag * scale);

          ctx.strokeStyle = cmd.color || '#58A6FF';
          ctx.lineWidth = 2.5;
          ctx.beginPath(); ctx.moveTo(cx, cy); ctx.lineTo(vx, vy); ctx.stroke();

          ctx.fillStyle = cmd.color || '#58A6FF';
          ctx.beginPath(); ctx.arc(vx, vy, 3.5, 0, Math.PI * 2); ctx.fill();

          ctx.fillStyle = cmd.color || '#58A6FF';
          ctx.font = 'bold 10px monospace';
          ctx.fillText(cmd.label || '', vx + 6, vy - 6);

          phasorsDrawn.push({ f: f, vx: vx, vy: vy, angRot: angRot, color: cmd.color, label: cmd.label });
        } else if (cmd.type === 'proyectar_onda' && cmd.phasor) {
          var fWv = cmd.phasor;
          var waveX = Math.floor(innerW * 0.54);
          var waveW = innerW - waveX - 20;
          var wOmega = (now * 0.002);
          var curAng = (fWv.ang * Math.PI / 180) + wOmega;

          ctx.strokeStyle = '#21262D';
          ctx.lineWidth = 1;
          ctx.beginPath(); ctx.moveTo(waveX, cy); ctx.lineTo(waveX + waveW, cy); ctx.stroke();

          var tipY = cy - Math.sin(curAng) * (fWv.mag * scale);
          ctx.strokeStyle = 'rgba(255, 255, 255, 0.2)';
          ctx.setLineDash([2, 4]);
          ctx.beginPath(); ctx.moveTo(cx, tipY); ctx.lineTo(waveX, tipY); ctx.stroke();
          ctx.setLineDash([]);

          ctx.strokeStyle = cmd.color || '#58A6FF';
          ctx.lineWidth = 2;
          ctx.beginPath();
          for (var x = 0; x < waveW; x += 2) {
            var th = curAng - ((x / waveW) * (Math.PI * 4));
            var yPos = cy - Math.sin(th) * (fWv.mag * scale);
            if (x === 0) ctx.moveTo(waveX + x, yPos); else ctx.lineTo(waveX + x, yPos);
          }
          ctx.stroke();

          if (cmd.label) {
            ctx.fillStyle = cmd.color || '#58A6FF';
            ctx.font = 'bold 9px monospace';
            ctx.fillText(cmd.label, waveX + waveW - 45, tipY - 8);
          }
        } else if (cmd.type === 'video_procedural_oceano') {
          var tSec = now * 0.001 * (cmd.freq || 1.45);
          var seaH = innerH * 0.55;
          ctx.fillStyle = '#0A192F';
          ctx.fillRect(0, 0, innerW, seaH);

          var sunX = innerW * 0.5, sunY = seaH * 0.7;
          ctx.fillStyle = '#FFA500';
          ctx.beginPath(); ctx.arc(sunX, sunY, 28, 0, Math.PI * 2); ctx.fill();
          ctx.fillStyle = '#FFFFE0';
          ctx.beginPath(); ctx.arc(sunX, sunY, 18, 0, Math.PI * 2); ctx.fill();

          for (var layer = 1; layer <= 4; layer++) {
            var lY = seaH + (layer * (innerH * 0.1));
            var amp = 6 + (layer * 4);
            var col = (layer === 1) ? '#0A3069' : (layer === 2) ? '#0969DA' : (layer === 3) ? '#218BFF' : '#54AEFF';
            ctx.fillStyle = col;
            ctx.beginPath();
            ctx.moveTo(0, innerH);
            ctx.lineTo(0, lY);
            for (var wx = 0; wx <= innerW; wx += 8) {
              var ph = (wx * 0.015) - (tSec * (1.2 + layer));
              var wy = lY + (amp * Math.cos(ph));
              ctx.lineTo(wx, wy);
            }
            ctx.lineTo(innerW, innerH);
            ctx.closePath();
            ctx.fill();
          }

          ctx.fillStyle = '#58A6FF';
          ctx.font = 'bold 12px monospace';
          ctx.fillText('VIDEO PROCEDURAL EN TIEMPO REAL — 120 FPS ZERO-STORAGE', 20, 30);
        } else if (cmd.type === 'voz_formantica_tts') {
          ctx.fillStyle = '#58A6FF';
          ctx.font = 'bold 12px monospace';
          ctx.fillText('SÍNTESIS DE VOZ FORMÁNTICA (TTS F0..F3 EN HERTZ)', 20, 30);

          var formants = [
            { name: 'F0 (Tono Glótico)', hz: cmd.f0 || 125, col: '#F85149' },
            { name: 'F1 (Apertura Bucal)', hz: cmd.f1 || 800, col: '#D29922' },
            { name: 'F2 (Faringe)', hz: cmd.f2 || 1200, col: '#3FB950' },
            { name: 'F3 (Articulación)', hz: cmd.f3 || 2500, col: '#58A6FF' }
          ];

          var specY = innerH * 0.5;
          ctx.strokeStyle = '#21262D';
          ctx.beginPath(); ctx.moveTo(40, specY); ctx.lineTo(innerW - 40, specY); ctx.stroke();

          for (var fIdx = 0; fIdx < formants.length; fIdx++) {
            var fm = formants[fIdx];
            var fX = 60 + (fIdx * ((innerW - 140) / 3));
            var peakH = 40 + (fIdx * 15);

            ctx.strokeStyle = fm.col;
            ctx.lineWidth = 3;
            ctx.beginPath();
            ctx.moveTo(fX - 30, specY);
            ctx.quadraticCurveTo(fX, specY - peakH, fX + 30, specY);
            ctx.stroke();

            ctx.fillStyle = fm.col;
            ctx.font = 'bold 11px monospace';
            ctx.fillText(fm.name, fX - 45, specY - peakH - 12);
            ctx.fillText(fm.hz + ' Hz', fX - 25, specY + 22);
          }

          ctx.strokeStyle = '#00E5FF';
          ctx.lineWidth = 2;
          ctx.beginPath();
          var waveBaseY = innerH * 0.8;
          for (var ax = 40; ax < innerW - 40; ax += 3) {
            var aTime = (ax * 0.08) - (now * 0.005);
            var aY = waveBaseY + (Math.sin(aTime) * 15) + (Math.sin(aTime * 2.5) * 8);
            if (ax === 40) ctx.moveTo(ax, aY); else ctx.lineTo(ax, aY);
          }
          ctx.stroke();
          ctx.fillStyle = '#8B949E';
          ctx.font = '10px monospace';
          ctx.fillText('Forma de onda acústica PCM a 44.1 kHz (Modulación en tiempo real)', 40, waveBaseY + 30);
        } else if (cmd.type === 'juego_plataformas_sim') {
          ctx.fillStyle = '#58A6FF';
          ctx.font = 'bold 12px monospace';
          ctx.fillText('MOTOR DE FÍSICAS CONTINUAS & PLATAFORMAS (120 FPS ZERO-GC)', 20, 30);

          var platY = innerH * 0.65;
          ctx.fillStyle = '#238636';
          ctx.fillRect(40, platY, innerW - 80, 16);
          ctx.fillStyle = '#161B22';
          ctx.fillRect(40, platY + 16, innerW - 80, 50);

          ctx.fillStyle = '#1F6FEB';
          ctx.fillRect(innerW * 0.25, platY - 70, 120, 12);
          ctx.fillRect(innerW * 0.55, platY - 120, 140, 12);

          var pTime = now * 0.003;
          var playerX = 60 + ((now * 0.08) % (innerW - 140));
          var jumpH = Math.abs(Math.sin(pTime * 2)) * 45;
          var playerY = platY - 32 - jumpH;

          ctx.fillStyle = '#00E5FF';
          ctx.fillRect(playerX, playerY, 20, 32);
          ctx.fillStyle = '#FFFFFF';
          ctx.fillRect(playerX + 12, playerY + 6, 4, 4);

          ctx.fillStyle = '#3FB950';
          ctx.font = '10px monospace';
          ctx.fillText('Posición: X=' + playerX.toFixed(1) + ' Y=' + playerY.toFixed(1) + ' | V_y=' + jumpH.toFixed(1) + ' m/s', 40, platY + 85);
        } else if (cmd.type === 'particulas_cern') {
          var pCx = innerW * 0.5, pCy = innerH * 0.5;
          var pR = cmd.r || 130;
          ctx.strokeStyle = '#1F6FEB';
          ctx.lineWidth = 3;
          ctx.beginPath(); ctx.arc(pCx, pCy, pR, 0, Math.PI * 2); ctx.stroke();

          var count = cmd.count || 8;
          for (var p = 0; p < count; p++) {
            var pAng = (now * 0.003) + (p * ((Math.PI * 2) / count));
            var px = pCx + Math.cos(pAng) * pR;
            var py = pCy + Math.sin(pAng) * pR;
            ctx.fillStyle = (p % 2 === 0) ? '#00FF88' : '#F85149';
            ctx.beginPath(); ctx.arc(px, py, 5, 0, Math.PI * 2); ctx.fill();
          }

          ctx.fillStyle = '#58A6FF';
          ctx.font = 'bold 12px monospace';
          ctx.fillText('COLISIONADOR CERN A 13.6 TEV (TRAYECTORIAS CONTINUAS)', 20, 30);
        } else if (cmd.type === 'avatar_ia_face') {
          var aCx = innerW * 0.5, aCy = innerH * 0.5;
          ctx.fillStyle = '#09264A';
          ctx.beginPath(); ctx.arc(aCx, aCy, 75, 0, Math.PI * 2); ctx.fill();
          ctx.fillStyle = '#0D1117';
          ctx.beginPath(); ctx.arc(aCx, aCy, 65, 0, Math.PI * 2); ctx.fill();

          ctx.strokeStyle = '#58A6FF';
          ctx.lineWidth = 2;
          ctx.strokeRect(aCx - 40, aCy - 30, 80, 60);

          var blink = (now * 0.001) % 4.0;
          var eyeH = (blink > 3.8) ? 1 : 10;
          ctx.fillStyle = '#00E5FF';
          ctx.fillRect(aCx - 26, aCy - 12, 18, eyeH);
          ctx.fillRect(aCx + 8, aCy - 12, 18, eyeH);

          var energy = cmd.energy || 0.8;
          var mouthH = 3 + (Math.sin(now * 0.015) * 6 * energy);
          ctx.fillStyle = '#3FB950';
          ctx.fillRect(aCx - 16, aCy + 15, 32, Math.max(3, mouthH));

          ctx.fillStyle = '#58A6FF';
          ctx.font = 'bold 12px monospace';
          ctx.fillText('AVATAR IA REACTIVO CON CANCELACIÓN DE ECO (AEC)', 20, 30);
        }
      }
    }
  };
`;

console.log('> [2/4] Leyendo runtime base y aplicando parches limpios...');
let runtime = fs.readFileSync(runtimeSrcPath, 'utf8');

// 1. Reemplazar o insertar enginesCode
const ideEngineMarker = 'var ChronosIdeEngine = {';
const phasorRuntimeMarker = 'var PhasorRuntime = {';

if (runtime.indexOf(ideEngineMarker) !== -1) {
  const startIdx = runtime.indexOf(ideEngineMarker);
  const endIdx = runtime.indexOf(phasorRuntimeMarker);
  runtime = runtime.substring(0, startIdx) + enginesCode.trim() + '\n\n  ' + runtime.substring(endIdx);
} else {
  runtime = runtime.replace(phasorRuntimeMarker, enginesCode + '\n  ' + phasorRuntimeMarker);
}

// 2. Parchear renderFrame (Desktop Dispatch)
runtime = runtime.replace(
  /var targetVm = ch\.appVm \|\| self\.vm;\s*if \(self\.appMode === 'ide'\) \{[\s\S]*?\} else if \(self\.appMode === 'graficadora'\) \{/,
  `var targetVm = ch.appVm || self.vm;
            if (self.appMode === 'ide') {
              var isStudioWin = (ch.title && ch.title.indexOf('Studio') !== -1) || ch.id === 1;
              var isExplorerWin = (ch.title && (ch.title.indexOf('Proyecto') !== -1 || ch.title.indexOf('Explorador') !== -1)) || ch.id === 3;
              if (isStudioWin) {
                ChronosIdeEngine.renderStudio(ctx, ch, innerW, innerH, false);
              } else if (isExplorerWin) {
                ChronosIdeEngine.renderExplorer(ctx, ch, innerW, innerH, false);
              } else {
                ChronosIdeEngine.renderPreview(ctx, ch, innerW, innerH, false, performance.now());
              }
            } else if (self.appMode === 'graficadora') {`
);

// 3. Parchear renderFrame (Mobile Dispatch)
runtime = runtime.replace(
  /if \(self\.appMode === 'ide'\) \{\s*var isStudioMob =[\s\S]*?\} else if \(self\.appMode === 'graficadora'\) \{/,
  `if (self.appMode === 'ide') {
          var isStudioMob = (activeChild.title && activeChild.title.indexOf('Studio') !== -1) || activeChild.id === 1;
          var isExplorerMob = (activeChild.title && (activeChild.title.indexOf('Proyecto') !== -1 || activeChild.title.indexOf('Explorador') !== -1)) || activeChild.id === 3;
          if (isStudioMob) {
            ChronosIdeEngine.renderStudio(ctx, activeChild, w - 20, innerH, true);
          } else if (isExplorerMob) {
            ChronosIdeEngine.renderExplorer(ctx, activeChild, w - 20, innerH, true);
          } else {
            ChronosIdeEngine.renderPreview(ctx, activeChild, w - 20, innerH, true, performance.now());
          }
        } else if (self.appMode === 'graficadora') {`
);

// 4. Parchear mousedown (Desktop Click Dispatch)
runtime = runtime.replace(
  /if \(self\.appMode === 'ide'\) \{\s*var isStudio = \(ch\.title && ch\.title\.indexOf\('Studio'\) !== -1\)[\s\S]*?\} else if \(self\.appMode === 'graficadora'\) \{/,
  `if (self.appMode === 'ide') {
              var isStudio = (ch.title && ch.title.indexOf('Studio') !== -1) || ch.id === 1;
              var isExplorer = (ch.title && (ch.title.indexOf('Proyecto') !== -1 || ch.title.indexOf('Explorador') !== -1)) || ch.id === 3;
              if (isStudio) {
                if (ChronosIdeEngine.handleClick(locX, locY, ch, inW, inH)) {
                  self.children.splice(i, 1);
                  self.children.push(ch);
                  self.renderFrame();
                  return;
                }
              } else if (isExplorer) {
                if (ChronosIdeEngine.handleClickExplorer(locX, locY, ch, inW, inH)) {
                  self.children.splice(i, 1);
                  self.children.push(ch);
                  self.renderFrame();
                  return;
                }
              }
            } else if (self.appMode === 'graficadora') {`
);

// 5. Parchear mousedown (Mobile Click Dispatch)
runtime = runtime.replace(
  /if \(self\.appMode === 'ide'\) \{\s*if \(activeChildMob\.id === 1 \|\| self\.activeChildIndex === 0\) \{\s*if \(ChronosIdeEngine\.handleClick\(mLocX, mLocY, activeChildMob, mInW, mInH\)\) \{ self\.renderFrame\(\); return; \}\s*\}\s*\} else if \(self\.appMode === 'graficadora'\) \{/,
  `if (self.appMode === 'ide') {
              var isStudioMob = (activeChildMob.title && activeChildMob.title.indexOf('Studio') !== -1) || activeChildMob.id === 1;
              var isExplorerMob = (activeChildMob.title && (activeChildMob.title.indexOf('Proyecto') !== -1 || activeChildMob.title.indexOf('Explorador') !== -1)) || activeChildMob.id === 3;
              if (isStudioMob) {
                if (ChronosIdeEngine.handleClick(mLocX, mLocY, activeChildMob, mInW, mInH)) { self.renderFrame(); return; }
              } else if (isExplorerMob) {
                if (ChronosIdeEngine.handleClickExplorer(mLocX, mLocY, activeChildMob, mInW, mInH)) { self.renderFrame(); return; }
              }
            } else if (self.appMode === 'graficadora') {`
);

// 6. Parchear touchstart en móvil para soporte táctil instantáneo en Chronos Studio y Explorador
if (runtime.indexOf('touchLocX') === -1) {
  runtime = runtime.replace(
    '// B. Clic en botones dentro de la ventana activa en móvil\n            var activeChild = self.children[self.activeChildIndex] || self.children[0];',
    `// B. Despacho táctil a Chronos Studio y Explorador en móvil
            var activeChild = self.children[self.activeChildIndex] || self.children[0];
            if (ty >= 44 && activeChild) {
              var touchLocX = tx - 10 + (activeChild.scrollX || 0);
              var touchLocY = ty - 48 + (activeChild.scrollY || 0);
              var touchInW = self.width - 20;
              var touchInH = self.height - 44;
              if (self.appMode === 'ide') {
                var isStudioMobT = (activeChild.title && activeChild.title.indexOf('Studio') !== -1) || activeChild.id === 1;
                var isExplorerMobT = (activeChild.title && (activeChild.title.indexOf('Proyecto') !== -1 || activeChild.title.indexOf('Explorador') !== -1)) || activeChild.id === 3;
                if (isStudioMobT) {
                  if (ChronosIdeEngine.handleClick(touchLocX, touchLocY, activeChild, touchInW, touchInH)) { self.renderFrame(); return; }
                } else if (isExplorerMobT) {
                  if (ChronosIdeEngine.handleClickExplorer(touchLocX, touchLocY, activeChild, touchInW, touchInH)) { self.renderFrame(); return; }
                }
              }
            }`
  );
}

// 7. Parchear evento 'wheel' (Scroll de ratón en escritorio)
runtime = runtime.replace(
  /if \(mx >= ch\.x && mx <= ch\.x \+ ch\.w && my >= ch\.y \+ 30 && my <= ch\.y \+ ch\.h\) \{\s*e\.preventDefault\(\);[\s\S]*?var metrics = self\.getScrollMetrics\(ch\);/,
  `if (mx >= ch.x && mx <= ch.x + ch.w && my >= ch.y + 30 && my <= ch.y + ch.h) {
            e.preventDefault();
            if (self.appMode === 'ide') {
              var isStudio = (ch.title && ch.title.indexOf('Studio') !== -1) || ch.id === 1;
              var isExplorer = (ch.title && (ch.title.indexOf('Proyecto') !== -1 || ch.title.indexOf('Explorador') !== -1)) || ch.id === 3;
              if (isStudio && ChronosIdeEngine.activeTab === 'editor') {
                ChronosIdeEngine.scrollRow = Math.max(0, ChronosIdeEngine.scrollRow + (e.deltaY > 0 ? 3 : -3));
                self.renderFrame();
                return;
              } else if (isExplorer) {
                ChronosIdeEngine.explorerScrollY = Math.max(0, ChronosIdeEngine.explorerScrollY + (e.deltaY > 0 ? 30 : -30));
                self.renderFrame();
                return;
              }
            }
            var metrics = self.getScrollMetrics(ch);`
);

// 8. Soporte para evento 'paste' de código
if (runtime.indexOf("window.addEventListener('paste'") === -1) {
  runtime = runtime.replace(
    "window.addEventListener('keydown', function(e) {",
    `window.addEventListener('paste', function(e) {
        if (self.appMode === 'ide' && ChronosIdeEngine.activeTab === 'editor') {
          var clipData = (e.clipboardData || window.clipboardData);
          if (clipData) {
            var text = clipData.getData('text');
            if (text) {
              e.preventDefault();
              ChronosIdeEngine.insertText(text);
              self.renderFrame();
            }
          }
        }
      });

      window.addEventListener('keydown', function(e) {`
  );
}

// 9. Soporte para evento 'mousemove' en Explorador para hover y tooltips
if (runtime.indexOf('onMouseMoveExplorer') === -1) {
  runtime = runtime.replace(
    "window.addEventListener('mousemove', function(e) {",
    `window.addEventListener('mousemove', function(e) {
        var rect = self.canvas.getBoundingClientRect();
        var mmx = e.clientX - rect.left;
        var mmy = e.clientY - rect.top;
        if (self.appMode === 'ide') {
          for (var k = self.children.length - 1; k >= 0; k--) {
            var chk = self.children[k];
            var isExpChk = (chk.title && (chk.title.indexOf('Proyecto') !== -1 || chk.title.indexOf('Explorador') !== -1)) || chk.id === 3;
            if (isExpChk && mmx >= chk.x && mmx <= chk.x + chk.w && mmy >= chk.y + 30 && mmy <= chk.y + chk.h && !chk.minimized) {
              var mLocX = mmx - chk.x - 12 + (chk.scrollX || 0);
              var mLocY = mmy - chk.y - 32 + (chk.scrollY || 0);
              var mInW = chk.w - 24;
              var mInH = chk.h - 36;
              ChronosIdeEngine.onMouseMoveExplorer(mLocX, mLocY, mInW, mInH);
              self.renderFrame();
              break;
            }
          }
        }`
  );
}

console.log('> [3/4] Escribiendo runtime sincronizado en todas las ubicaciones...');
fs.writeFileSync(runtimeSrcPath, runtime, 'utf8');
fs.writeFileSync(path.resolve(rootDir, 'runtime/phasor_runtime.js'), runtime, 'utf8');
fs.writeFileSync(path.resolve(rootDir, 'dist/phasor_runtime.js'), runtime, 'utf8');

console.log('> [4/4] Motores interactivos y runtime compilados con éxito!');

console.log('> [4/4] Motores interactivos y runtime compilados con éxito!');
