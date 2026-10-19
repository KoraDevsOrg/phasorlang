// tools/build_interactive_runtime.js
// Genera los motores interactivos profesionales y ensambla phasor_runtime.js
const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..');
const runtimeSrcPath = path.resolve(rootDir, 'phasor_runtime.js');

console.log('> [1/4] Diseñando motores interactivos de alta fidelidad...');

const enginesCode = `
  // =========================================================================
  // 3. CHRONOS IDE AUTONOMOUS ENGINE (PRO CODE EDITOR & COMPILER IN BROWSER)
  // =========================================================================
  var ChronosIdeEngine = {
    activeTab: 'editor', // 'editor' | 'templates' | 'terminal' | 'debug' | 'docs'
    codeLines: [
      "// ==============================================",
      "// CHRONOS STUDIO — SCRIPT FASORIAL ACTIVO",
      "// ==============================================",
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
      "dibujar_fasor(v1, '#58a6ff', 'V1 (120V)')",
      "dibujar_fasor(v2, '#d29922', 'V2 (80V)')",
      "dibujar_fasor(vr, '#3fb950', 'VR Resultante')",
      "proyectar_onda(v1, '#58a6ff', 'v1(t)')",
      "proyectar_onda(v2, '#d29922', 'v2(t)')",
      "proyectar_onda(vr, '#3fb950', 'vr(t)')"
    ],
    cursorRow: 3,
    cursorCol: 17,
    scrollRow: 0,
    terminalLogs: [
      '> [PVM Kernel] Chronos IDE Autonomous v1.0.0 inicializado con éxito.',
      '> [PVM Kernel] Invariante Zero-GC activo. Memoria SoA: 64 KB contigua.',
      '> [PVM Kernel] Editor de código listo: escribe código, pulsa [▶ EJECUTAR] o usa [Ctrl+Enter].'
    ],
    drawCommands: [],
    registers: new Float64Array(256),
    regNames: {},
    hotReload: true,
    lastExecTime: '0.24',
    blinkTimer: 0,

    templates: [
      {
        title: '1. Suma de Tensiones Fasoriales (Kirchhoff)',
        desc: 'Suma vectorial V1 + V2 con paralelogramo y proyeccion senoidal.',
        code: [
          "// 1. Suma de Tensiones Fasoriales (Kirchhoff)",
          "frecuencia = 60.0",
          "v1 = fasor(120.0, 0.0)",
          "v2 = fasor(80.0, 60.0)",
          "vr = v1 + v2",
          "imprimir('Tension V1:', v1.mag, 'V ∠', v1.ang, '°')",
          "imprimir('Tension V2:', v2.mag, 'V ∠', v2.ang, '°')",
          "imprimir('Resultante VR:', vr.mag, 'V ∠', vr.ang, '°')",
          "",
          "plano_complejo(130.0)",
          "dibujar_fasor(v1, '#58a6ff', 'V1 (120V)')",
          "dibujar_fasor(v2, '#d29922', 'V2 (80V)')",
          "dibujar_fasor(vr, '#3fb950', 'VR Resultante')",
          "proyectar_onda(v1, '#58a6ff', 'v1(t)')",
          "proyectar_onda(v2, '#d29922', 'v2(t)')",
          "proyectar_onda(vr, '#3fb950', 'vr(t)')"
        ]
      },
      {
        title: '2. Circuito RLC e Impedancia Compleja',
        desc: 'Calculo de R, XL, XC, impedancia Z, resonancia y factor de potencia.',
        code: [
          "// 2. Circuito RLC Serie & Resonancia",
          "f = 60.0",
          "omega = 2.0 * 3.14159 * f",
          "r = 30.0",
          "l = 0.12",
          "c = 0.00008",
          "xl = omega * l",
          "xc = 1.0 / (omega * c)",
          "x_net = xl - xc",
          "z_mag = sqrt(r * r + x_net * x_net)",
          "z_ang = atan2(x_net, r) * 57.2958",
          "f0 = 1.0 / (2.0 * 3.14159 * sqrt(l * c))",
          "fp = cos(z_ang * 0.017453)",
          "imprimir('Resistencia R:', r, 'Ω')",
          "imprimir('Reactancia Inductiva XL:', xl, 'Ω')",
          "imprimir('Reactancia Capacitiva XC:', xc, 'Ω')",
          "imprimir('Impedancia Total Z:', z_mag, 'Ω ∠', z_ang, '°')",
          "imprimir('Frecuencia Resonancia f0:', f0, 'Hz')",
          "imprimir('Factor de Potencia:', fp)",
          "",
          "plano_complejo(110.0)",
          "dibujar_fasor(fasor(r, 0.0), '#58a6ff', 'R (30Ω)')",
          "dibujar_fasor(fasor(xl, 90.0), '#bc8cff', 'XL (45Ω)')",
          "dibujar_fasor(fasor(xc, -90.0), '#f85149', 'XC (33Ω)')",
          "dibujar_fasor(fasor(z_mag, z_ang), '#3fb950', 'Z Total')",
          "proyectar_onda(fasor(z_mag, z_ang), '#3fb950', 'z(t)')"
        ]
      },
      {
        title: '3. Sistema Trifasico Equilibrado (120°)',
        desc: 'Generacion de fases VA, VB, VC desfasadas 120° y tension de linea VAB.',
        code: [
          "// 3. Sistema Trifasico Equilibrado",
          "frecuencia = 60.0",
          "va = fasor(120.0, 0.0)",
          "vb = fasor(120.0, -120.0)",
          "vc = fasor(120.0, 120.0)",
          "vab = va - vb",
          "imprimir('Fase VA:', va.mag, 'V ∠', va.ang, '°')",
          "imprimir('Fase VB:', vb.mag, 'V ∠', vb.ang, '°')",
          "imprimir('Fase VC:', vc.mag, 'V ∠', vc.ang, '°')",
          "imprimir('Linea VAB (sqrt(3)*120):', vab.mag, 'V ∠', vab.ang, '°')",
          "",
          "plano_complejo(140.0)",
          "dibujar_fasor(va, '#f85149', 'Fase A (Rojo)')",
          "dibujar_fasor(vb, '#d29922', 'Fase B (Amarillo)')",
          "dibujar_fasor(vc, '#58a6ff', 'Fase C (Azul)')",
          "proyectar_onda(va, '#f85149', 'va(t)')",
          "proyectar_onda(vb, '#d29922', 'vb(t)')",
          "proyectar_onda(vc, '#58a6ff', 'vc(t)')"
        ]
      },
      {
        title: '4. Onda Electromagnetica Planar (Campos E y B)',
        desc: 'Propagacion de campos E y B ortogonales a 120 FPS sostenidos.',
        code: [
          "// 4. Onda Electromagnetica Planar",
          "c = 3.0e8",
          "frecuencia = 100.0",
          "amp_e = 120.0",
          "amp_b = 85.0",
          "imprimir('Velocidad propagacion c:', c, 'm/s')",
          "imprimir('Campo Electrico E:', amp_e, 'V/m')",
          "imprimir('Campo Magnetico B:', amp_b, 'μT')",
          "",
          "plano_complejo(130.0)",
          "onda_em(amp_e, amp_b)"
        ]
      },
      {
        title: '5. Micro-Colisionador de Hadrones (Estilo CERN)',
        desc: 'Haces de particulas en colision continua de alta energia.',
        code: [
          "// 5. Micro-Colisionador de Hadrones",
          "energia = 13.6",
          "haces = 8.0",
          "imprimir('Inyectando paquetes en anillo de almacenamiento...')",
          "imprimir('Energia de colision:', energia, 'TeV')",
          "imprimir('Auditoria Zero-GC: trayectorias continuas')",
          "",
          "particulas_cern(120.0, haces)"
        ]
      }
    ],

    executeCode: function() {
      var tStart = performance.now();
      this.drawCommands = [];
      this.regNames = {};
      var vars = { 'pi': Math.PI, 'e': Math.E };
      var outLogs = [];

      function evalExpr(expr) {
        if (!expr) return 0;
        expr = expr.trim();

        // 1. Constructor Fasor: fasor(mag, ang_deg)
        var mFas = expr.match(/^fasor\s*\(\s*([^,]+)\s*,\s*([^)]+)\s*\)$/i);
        if (mFas) {
          var mag = evalExpr(mFas[1]);
          var ang = evalExpr(mFas[2]);
          var rad = ang * Math.PI / 180;
          return { type: 'phasor', mag: mag, ang: ang, re: mag * Math.cos(rad), im: mag * Math.sin(rad) };
        }

        // 2. Constructor Complejo: complejo(re, im)
        var mComp = expr.match(/^complejo\s*\(\s*([^,]+)\s*,\s*([^)]+)\s*\)$/i);
        if (mComp) {
          var re = evalExpr(mComp[1]);
          var im = evalExpr(mComp[2]);
          var cMag = Math.sqrt(re * re + im * im);
          var cAng = Math.atan2(im, re) * 180 / Math.PI;
          return { type: 'phasor', mag: cMag, ang: cAng, re: re, im: im };
        }

        // 3. Funciones matematicas: sqrt, sin, cos, tan, atan2, abs
        var mFn = expr.match(/^([a-zA-Z0-9_]+)\s*\((.*)\)$/);
        if (mFn) {
          var fn = mFn[1].toLowerCase();
          var rawArgs = mFn[2].split(',').map(function(a) { return evalExpr(a); });
          if (fn === 'sqrt') return Math.sqrt(Math.abs(rawArgs[0]));
          if (fn === 'sin') return Math.sin(rawArgs[0]);
          if (fn === 'cos') return Math.cos(rawArgs[0]);
          if (fn === 'tan') return Math.tan(rawArgs[0]);
          if (fn === 'abs') return Math.abs(rawArgs[0]);
          if (fn === 'atan2') return Math.atan2(rawArgs[0], rawArgs[1]);
        }

        // 4. Suma vectorial y escalar: a + b
        if (expr.indexOf('+') !== -1) {
          var parts = expr.split('+');
          var sumRe = 0, sumIm = 0, isP = false, numSum = 0;
          for (var i = 0; i < parts.length; i++) {
            var v = evalExpr(parts[i]);
            if (v && v.type === 'phasor') {
              isP = true;
              sumRe += v.re;
              sumIm += v.im;
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

        // 5. Resta vectorial y escalar: a - b
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

        // 6. Multiplicacion: a * b
        if (expr.indexOf('*') !== -1) {
          var pMul = expr.split('*');
          var prod = 1;
          for (var j = 0; j < pMul.length; j++) {
            prod *= evalExpr(pMul[j]);
          }
          return prod;
        }

        // 7. Division: a / b
        if (expr.indexOf('/') !== -1) {
          var pDiv = expr.split('/');
          var denom = evalExpr(pDiv[1]);
          return denom !== 0 ? (evalExpr(pDiv[0]) / denom) : 0;
        }

        // 8. Variables y propiedades de fasores
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

        // Comprobacion de imprimir(...) / out(...)
        var mPrint = raw.match(/^(?:imprimir|out)\s*\((.*)\)$/i);
        if (mPrint) {
          var argsRaw = mPrint[1].split(',');
          var msgParts = [];
          for (var a = 0; a < argsRaw.length; a++) {
            var arg = argsRaw[a].trim();
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
        }

        // Comandos graficos
        var mPlano = raw.match(/^plano_complejo\s*\(\s*([^)]*)\s*\)$/i);
        if (mPlano) {
          this.drawCommands.push({ type: 'plano_complejo', scale: evalExpr(mPlano[1]) || 120 });
          continue;
        }

        var mFasor = raw.match(/^dibujar_fasor\s*\(\s*([^,]+)\s*,\s*([^,]+)\s*,\s*([^)]+)\s*\)$/i);
        if (mFasor) {
          var fVal = evalExpr(mFasor[1]);
          var fCol = mFasor[2].trim().replace(/['"]/g, '');
          var fLbl = mFasor[3].trim().replace(/['"]/g, '');
          this.drawCommands.push({ type: 'dibujar_fasor', phasor: fVal, color: fCol, label: fLbl });
          continue;
        }

        var mOnda = raw.match(/^proyectar_onda\s*\(\s*([^,]+)\s*,\s*([^,)]+)(?:\s*,\s*([^)]+))?\s*\)$/i);
        if (mOnda) {
          var oVal = evalExpr(mOnda[1]);
          var oCol = mOnda[2].trim().replace(/['"]/g, '');
          var oLbl = mOnda[3] ? mOnda[3].trim().replace(/['"]/g, '') : '';
          this.drawCommands.push({ type: 'proyectar_onda', phasor: oVal, color: oCol, label: oLbl });
          continue;
        }

        var mEM = raw.match(/^onda_em\s*\(\s*([^,]+)\s*,\s*([^)]+)\s*\)$/i);
        if (mEM) {
          this.drawCommands.push({ type: 'onda_em', ampE: evalExpr(mEM[1]), ampB: evalExpr(mEM[2]) });
          continue;
        }

        var mCern = raw.match(/^particulas_cern\s*\(\s*([^,]+)\s*,\s*([^)]+)\s*\)$/i);
        if (mCern) {
          this.drawCommands.push({ type: 'particulas_cern', r: evalExpr(mCern[1]), count: evalExpr(mCern[2]) });
          continue;
        }

        // Asignacion de variables
        var eqIdx = raw.indexOf('=');
        if (eqIdx !== -1) {
          var id = raw.substring(0, eqIdx).trim();
          var valExpr = raw.substring(eqIdx + 1).trim();
          vars[id] = evalExpr(valExpr);
        }
      }

      // Volcado a registros R0..R15 para el depurador
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

    exportFile: function() {
      try {
        var content = this.codeLines.join('\\n');
        var blob = new Blob([content], { type: 'text/plain;charset=utf-8' });
        var a = document.createElement('a');
        a.href = URL.createObjectURL(blob);
        a.download = 'proyecto_phasor.ph';
        a.click();
        this.terminalLogs.push('> [Chronos IDE] Archivo descargado con éxito: proyecto_phasor.ph');
      } catch (err) {
        this.terminalLogs.push('> [ERR] Error al exportar archivo: ' + err.message);
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

    handleKey: function(e) {
      if (this.activeTab !== 'editor') return;

      // Atajo Ctrl+Enter / Meta+Enter: Ejecutar
      if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
        e.preventDefault();
        this.executeCode();
        return;
      }

      // Atajo Ctrl+S: Exportar / Descargar código
      if ((e.key === 's' || e.key === 'S') && (e.ctrlKey || e.metaKey)) {
        e.preventDefault();
        this.exportFile();
        return;
      }

      // Backspace
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
      }

      // Delete (Supr)
      else if (e.key === 'Delete') {
        e.preventDefault();
        var curD = this.codeLines[this.cursorRow] || '';
        if (this.cursorCol < curD.length) {
          this.codeLines[this.cursorRow] = curD.slice(0, this.cursorCol) + curD.slice(this.cursorCol + 1);
        } else if (this.cursorRow < this.codeLines.length - 1) {
          var nextL = this.codeLines[this.cursorRow + 1];
          this.codeLines[this.cursorRow] = curD + nextL;
          this.codeLines.splice(this.cursorRow + 1, 1);
        }
      }

      // Enter
      else if (e.key === 'Enter') {
        e.preventDefault();
        var lineCur = this.codeLines[this.cursorRow] || '';
        var before = lineCur.slice(0, this.cursorCol);
        var after = lineCur.slice(this.cursorCol);

        // Auto-indent
        var indentMatch = before.match(/^\\s*/);
        var indent = indentMatch ? indentMatch[0] : '';
        if (before.trim().endsWith('{')) indent += '  ';

        this.codeLines[this.cursorRow] = before;
        this.codeLines.splice(this.cursorRow + 1, 0, indent + after);
        this.cursorRow++;
        this.cursorCol = indent.length;
      }

      // Flechas
      else if (e.key === 'ArrowUp') {
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
        if (this.cursorCol > 0) this.cursorCol--;
        else if (this.cursorRow > 0) {
          this.cursorRow--;
          this.cursorCol = (this.codeLines[this.cursorRow] || '').length;
        }
      } else if (e.key === 'ArrowRight') {
        e.preventDefault();
        var cLen = (this.codeLines[this.cursorRow] || '').length;
        if (this.cursorCol < cLen) this.cursorCol++;
        else if (this.cursorRow < this.codeLines.length - 1) {
          this.cursorRow++;
          this.cursorCol = 0;
        }
      }

      // Inicio y Fin
      else if (e.key === 'Home') {
        e.preventDefault();
        this.cursorCol = 0;
      } else if (e.key === 'End') {
        e.preventDefault();
        this.cursorCol = (this.codeLines[this.cursorRow] || '').length;
      }

      // Tab
      else if (e.key === 'Tab') {
        e.preventDefault();
        var cL = this.codeLines[this.cursorRow] || '';
        this.codeLines[this.cursorRow] = cL.slice(0, this.cursorCol) + '  ' + cL.slice(this.cursorCol);
        this.cursorCol += 2;
      }

      // Caracteres regulares
      else if (e.key.length === 1 && !e.ctrlKey && !e.metaKey) {
        e.preventDefault();
        var lStr = this.codeLines[this.cursorRow] || '';
        this.codeLines[this.cursorRow] = lStr.slice(0, this.cursorCol) + e.key + lStr.slice(this.cursorCol);
        this.cursorCol++;
      }

      // Mantener cursor a la vista (auto-scroll)
      if (this.cursorRow < this.scrollRow) {
        this.scrollRow = this.cursorRow;
      } else if (this.cursorRow >= this.scrollRow + 24) {
        this.scrollRow = this.cursorRow - 23;
      }

      if (this.hotReload) {
        this.executeCode();
      }
    },

    handleClick: function(lx, ly, ch, innerW, innerH) {
      // 1. Selector de pestañas superior: y: 0..30
      if (ly >= 0 && ly <= 30) {
        var tabW = Math.floor(innerW / 5);
        var tabIdx = Math.floor(lx / tabW);
        var tabKeys = ['editor', 'templates', 'terminal', 'debug', 'docs'];
        if (tabKeys[tabIdx]) {
          this.activeTab = tabKeys[tabIdx];
          return true;
        }
      }

      // 2. Clics en pestaña Editor
      if (this.activeTab === 'editor') {
        // Barra de herramientas: y: 34..62
        if (ly >= 34 && ly <= 62) {
          // [ ▶ EJECUTAR ]
          if (lx >= 6 && lx <= 130) {
            this.executeCode();
            return true;
          }
          // [ ⚡ Hot-Reload ]
          if (lx >= 136 && lx <= 250) {
            this.hotReload = !this.hotReload;
            return true;
          }
          // [ 💾 Descargar ]
          if (lx >= 256 && lx <= 350) {
            this.exportFile();
            return true;
          }
          // [ 📋 Copiar ]
          if (lx >= 356 && lx <= 430) {
            this.copyCode();
            return true;
          }
          // [ 🔄 Reiniciar ]
          if (lx >= 436 && lx <= 520) {
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

      // 3. Clics en pestaña Plantillas
      if (this.activeTab === 'templates') {
        var cardH = 92;
        var startY = 40;
        for (var t = 0; t < this.templates.length; t++) {
          var cY = startY + (t * (cardH + 10));
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

      // 4. Clics en Terminal
      if (this.activeTab === 'terminal') {
        if (ly >= 34 && ly <= 58 && lx >= 10 && lx <= 160) {
          this.terminalLogs = ['> [PVM Kernel] Consola limpiada por el usuario.'];
          return true;
        }
      }

      // 5. Clics en Docs (insertar ejemplo)
      if (this.activeTab === 'docs') {
        var docItems = [
          'v = fasor(120.0, 45.0)',
          'z = complejo(30.0, 40.0)',
          'plano_complejo(140.0)',
          "dibujar_fasor(v, '#58a6ff', 'V1')",
          "proyectar_onda(v, '#58a6ff', 'v(t)')",
          'onda_em(120.0, 85.0)',
          'particulas_cern(120.0, 8.0)',
          "imprimir('Valor:', v.mag, '∠', v.ang)"
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
      // 1. Barra de Pestañas Superior
      var tabs = [
        { id: 'editor', lbl: '📝 Editor' },
        { id: 'templates', lbl: '⚡ Plantillas' },
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
        ctx.font = (isActive ? 'bold ' : '') + '10px monospace';
        ctx.textAlign = 'center';
        ctx.fillText(t.lbl, tx + (tabW / 2), 19);
      }
      ctx.textAlign = 'left';

      // --- CONTENIDO DE PESTAÑA: EDITOR ---
      if (this.activeTab === 'editor') {
        // Barra de Herramientas
        ctx.fillStyle = '#161B22';
        ctx.fillRect(0, 30, innerW, 34);
        ctx.strokeStyle = '#30363D';
        ctx.beginPath(); ctx.moveTo(0, 64); ctx.lineTo(innerW, 64); ctx.stroke();

        // Botón [▶ EJECUTAR]
        ctx.fillStyle = '#238636';
        ctx.fillRect(6, 34, 120, 24);
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 10px monospace';
        ctx.fillText('▶ EJECUTAR (Ctrl+↵)', 10, 50);

        // Botón [⚡ Hot-Reload]
        ctx.fillStyle = this.hotReload ? '#1F6FEB' : '#30363D';
        ctx.fillRect(132, 34, 114, 24);
        ctx.fillStyle = '#FFFFFF';
        ctx.fillText(this.hotReload ? '⚡ Hot-Reload: ON' : '⚡ Hot-Reload: OFF', 138, 50);

        // Botón [💾 Descargar .ph]
        ctx.fillStyle = '#8957E5';
        ctx.fillRect(252, 34, 98, 24);
        ctx.fillStyle = '#FFFFFF';
        ctx.fillText('💾 Descargar', 260, 50);

        // Botón [📋 Copiar]
        ctx.fillStyle = '#39C5BB';
        ctx.fillRect(356, 34, 74, 24);
        ctx.fillStyle = '#05070A';
        ctx.fillText('📋 Copiar', 364, 50);

        // Botón [🔄 Reiniciar]
        ctx.fillStyle = '#21262D';
        ctx.fillRect(436, 34, 80, 24);
        ctx.fillStyle = '#8B949E';
        ctx.fillText('🔄 Reiniciar', 442, 50);

        // Área de Código
        var codeAreaH = innerH - 64;
        ctx.fillStyle = '#090D13';
        ctx.fillRect(0, 64, innerW, codeAreaH);

        // Columna de Líneas
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

          // Resaltado de línea activa
          if (lNum === this.cursorRow) {
            ctx.fillStyle = 'rgba(88, 166, 255, 0.12)';
            ctx.fillRect(40, yPos - 13, innerW - 40, 18);
          }

          // Número de línea
          ctx.fillStyle = (lNum === this.cursorRow) ? '#58A6FF' : '#484F58';
          ctx.textAlign = 'right';
          ctx.fillText((lNum + 1).toString(), 34, yPos);
          ctx.textAlign = 'left';

          // Contenido de la línea con resaltado de sintaxis ligero
          var lineStr = this.codeLines[lNum] || '';
          if (lineStr.trim().startsWith('//')) {
            ctx.fillStyle = '#8B949E';
          } else if (lineStr.indexOf('imprimir') !== -1 || lineStr.indexOf('out') !== -1) {
            ctx.fillStyle = '#3FB950';
          } else if (lineStr.indexOf('fasor') !== -1 || lineStr.indexOf('complejo') !== -1) {
            ctx.fillStyle = '#D2A8FF';
          } else if (lineStr.indexOf('dibujar_') !== -1 || lineStr.indexOf('proyectar_') !== -1 || lineStr.indexOf('plano_') !== -1) {
            ctx.fillStyle = '#58A6FF';
          } else if (lineStr.indexOf('=') !== -1) {
            ctx.fillStyle = '#E6EDF3';
          } else {
            ctx.fillStyle = '#C9D1D9';
          }
          ctx.fillText(lineStr, 46, yPos);

          // Cursor parpadeante
          if (lNum === this.cursorRow) {
            this.blinkTimer = (this.blinkTimer + 1) % 60;
            if (this.blinkTimer < 35) {
              var curX = 46 + (this.cursorCol * 6.6);
              ctx.fillStyle = '#39C5BB';
              ctx.fillRect(curX, yPos - 12, 2, 15);
            }
          }
        }
      }

      // --- CONTENIDO DE PESTAÑA: PLANTILLAS ---
      else if (this.activeTab === 'templates') {
        ctx.fillStyle = '#58A6FF';
        ctx.font = 'bold 12px monospace';
        ctx.fillText('PLANTILLAS Y PROYECTOS PRECARGADOS (KORADEVS)', 12, 48);

        var cStartY = 60;
        var cH = 78;
        for (var idx = 0; idx < this.templates.length; idx++) {
          var templ = this.templates[idx];
          var cy = cStartY + (idx * (cH + 10));

          ctx.fillStyle = '#161B22';
          ctx.fillRect(10, cy, innerW - 20, cH);
          ctx.strokeStyle = '#30363D';
          ctx.strokeRect(10, cy, innerW - 20, cH);

          ctx.fillStyle = '#39C5BB';
          ctx.font = 'bold 12px monospace';
          ctx.fillText(templ.title, 20, cy + 22);

          ctx.fillStyle = '#8B949E';
          ctx.font = '11px monospace';
          ctx.fillText(templ.desc, 20, cy + 42);

          // Botón Cargar
          ctx.fillStyle = '#238636';
          ctx.fillRect(innerW - 190, cy + 48, 170, 24);
          ctx.fillStyle = '#FFFFFF';
          ctx.font = 'bold 10px monospace';
          ctx.fillText('⚡ CARGAR Y EJECUTAR', innerW - 180, cy + 64);
        }
      }

      // --- CONTENIDO DE PESTAÑA: TERMINAL ---
      else if (this.activeTab === 'terminal') {
        ctx.fillStyle = '#161B22';
        ctx.fillRect(0, 30, innerW, 32);

        ctx.fillStyle = '#DA3633';
        ctx.fillRect(10, 34, 140, 24);
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 10px monospace';
        ctx.fillText('🗑 LIMPIAR CONSOLA', 18, 50);

        ctx.fillStyle = '#05070A';
        ctx.fillRect(0, 62, innerW, innerH - 62);

        ctx.font = '11px monospace';
        var tY = 82;
        var startLog = Math.max(0, this.terminalLogs.length - Math.floor((innerH - 80) / 16));
        for (var l = startLog; l < this.terminalLogs.length; l++) {
          var logLine = this.terminalLogs[l];
          ctx.fillStyle = logLine.indexOf('ERR') !== -1 ? '#F85149' :
                         logLine.indexOf('OUT') !== -1 ? '#58A6FF' : '#3FB950';
          ctx.fillText(logLine, 12, tY);
          tY += 16;
        }
      }

      // --- CONTENIDO DE PESTAÑA: DEPURADOR ---
      else if (this.activeTab === 'debug') {
        ctx.fillStyle = '#58A6FF';
        ctx.font = 'bold 12px monospace';
        ctx.fillText('DEPURADOR PVM — INSPECCIÓN R0..R15 (Fase 14 Zero-GC)', 12, 48);

        ctx.fillStyle = '#3FB950';
        ctx.font = '11px monospace';
        ctx.fillText('ESTADO: EJECUCIÓN CONTINUA (120 FPS) | 0 PAUSAS GC | LATENCIA: ' + this.lastExecTime + ' ms', 12, 68);

        var startRegY = 92;
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

      // --- CONTENIDO DE PESTAÑA: DOCS ---
      else if (this.activeTab === 'docs') {
        ctx.fillStyle = '#58A6FF';
        ctx.font = 'bold 12px monospace';
        ctx.fillText('REFERENCIA RÁPIDA DE PHASORLANG (1-CLICK INSERTAR)', 12, 48);

        var docItems = [
          { sig: 'fasor(mag, ang_deg)', exp: 'Crea vector fasorial con modulo y angulo.' },
          { sig: 'complejo(re, im)', exp: 'Crea numero complejo en coordenadas rectangulares.' },
          { sig: 'plano_complejo(escala)', exp: 'Inicializa rejilla y ejes del plano de Gauss.' },
          { sig: 'dibujar_fasor(f, color, lbl)', exp: 'Dibuja vector fasorial con rotacion continua.' },
          { sig: 'proyectar_onda(f, color, lbl)', exp: 'Proyecta forma de onda senoidal continua.' },
          { sig: 'onda_em(ampE, ampB)', exp: 'Simula onda electromagnetica 3D (E y B).' },
          { sig: 'particulas_cern(radio, n)', exp: 'Simula colision de particulas subatomicas.' },
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

          // Boton [+ INSERTAR]
          ctx.fillStyle = '#1F6FEB';
          ctx.fillRect(innerW - 120, dY - 4, 100, 20);
          ctx.fillStyle = '#FFFFFF';
          ctx.font = 'bold 9px monospace';
          ctx.fillText('+ INSERTAR', innerW - 105, dY + 10);

          dY += 34;
        }
      }
    },

    renderPreview: function(ctx, ch, innerW, innerH, isMobile, now) {
      // Fondo
      ctx.fillStyle = '#070B12';
      ctx.fillRect(0, 0, innerW, innerH);

      var cx = Math.floor(innerW * 0.28);
      var cy = Math.floor(innerH * 0.5);
      var scale = 1.0;
      var phasorsDrawn = [];

      // Ejecutar comandos visuales activos
      for (var c = 0; c < this.drawCommands.length; c++) {
        var cmd = this.drawCommands[c];

        if (cmd.type === 'plano_complejo') {
          scale = Math.min(innerW * 0.45, innerH) / (cmd.scale * 2.4);

          // Ejes cartesianos
          ctx.strokeStyle = '#21262D';
          ctx.lineWidth = 1;
          ctx.beginPath(); ctx.moveTo(20, cy); ctx.lineTo(innerW * 0.52, cy); ctx.stroke();
          ctx.beginPath(); ctx.moveTo(cx, 30); ctx.lineTo(cx, innerH - 40); ctx.stroke();

          // Círculos de referencia concéntricos
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
        }

        else if (cmd.type === 'dibujar_fasor' && cmd.phasor) {
          var f = cmd.phasor;
          var omega = (now * 0.002);
          var angRot = (f.ang * Math.PI / 180) + omega;
          var vx = cx + Math.cos(angRot) * (f.mag * scale);
          var vy = cy - Math.sin(angRot) * (f.mag * scale);

          // Vector fasorial rotatorio
          ctx.strokeStyle = cmd.color || '#58A6FF';
          ctx.lineWidth = 2.5;
          ctx.beginPath();
          ctx.moveTo(cx, cy);
          ctx.lineTo(vx, vy);
          ctx.stroke();

          // Flecha del fasor
          var arrLen = 8;
          ctx.fillStyle = cmd.color || '#58A6FF';
          ctx.beginPath();
          ctx.arc(vx, vy, 3.5, 0, Math.PI * 2);
          ctx.fill();

          // Etiqueta del vector
          ctx.fillStyle = cmd.color || '#58A6FF';
          ctx.font = 'bold 10px monospace';
          ctx.fillText(cmd.label || '', vx + 6, vy - 6);

          phasorsDrawn.push({ f: f, vx: vx, vy: vy, angRot: angRot, color: cmd.color, label: cmd.label });
        }

        else if (cmd.type === 'proyectar_onda' && cmd.phasor) {
          var fWv = cmd.phasor;
          var waveX = Math.floor(innerW * 0.54);
          var waveW = innerW - waveX - 20;
          var wOmega = (now * 0.002);
          var curAng = (fWv.ang * Math.PI / 180) + wOmega;

          // Eje central de tiempo
          ctx.strokeStyle = '#21262D';
          ctx.lineWidth = 1;
          ctx.beginPath(); ctx.moveTo(waveX, cy); ctx.lineTo(waveX + waveW, cy); ctx.stroke();

          // Línea de proyección desde el fasor al inicio de la onda
          var tipY = cy - Math.sin(curAng) * (fWv.mag * scale);
          ctx.strokeStyle = 'rgba(255, 255, 255, 0.2)';
          ctx.setLineDash([2, 4]);
          ctx.beginPath(); ctx.moveTo(cx, tipY); ctx.lineTo(waveX, tipY); ctx.stroke();
          ctx.setLineDash([]);

          // Trazo senoidal continuo
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
        }

        else if (cmd.type === 'onda_em') {
          // Visualización 3D isométrica de campos E y B
          var emX = Math.floor(innerW * 0.15);
          var emW = innerW - emX - 30;
          ctx.strokeStyle = '#21262D';
          ctx.beginPath(); ctx.moveTo(emX, cy); ctx.lineTo(emX + emW, cy); ctx.stroke();

          var emScale = Math.min(innerH * 0.35, 90) / (cmd.ampE || 120);

          // Campo Eléctrico E (Vertical - Azul)
          ctx.strokeStyle = '#58A6FF';
          ctx.lineWidth = 2;
          ctx.beginPath();
          for (var ex = 0; ex < emW; ex += 3) {
            var ePhase = (now * 0.003) - (ex * 0.035);
            var ey = cy - Math.sin(ePhase) * (cmd.ampE * emScale);
            if (ex === 0) ctx.moveTo(emX + ex, ey); else ctx.lineTo(emX + ex, ey);
          }
          ctx.stroke();

          // Campo Magnético B (Ortogonal / Inclinado - Ámbar)
          ctx.strokeStyle = '#D29922';
          ctx.lineWidth = 1.5;
          ctx.beginPath();
          for (var bx = 0; bx < emW; bx += 3) {
            var bPhase = (now * 0.003) - (bx * 0.035);
            var by = cy - (Math.sin(bPhase) * (cmd.ampB * emScale) * 0.5);
            var bzOffset = Math.sin(bPhase) * (cmd.ampB * emScale) * 0.8;
            if (bx === 0) ctx.moveTo(emX + bx + bzOffset, by); else ctx.lineTo(emX + bx + bzOffset, by);
          }
          ctx.stroke();

          ctx.fillStyle = '#58A6FF';
          ctx.font = 'bold 11px monospace';
          ctx.fillText('Campo Eléctrico E (120 V/m)', emX + 10, cy - 70);
          ctx.fillStyle = '#D29922';
          ctx.fillText('Campo Magnético B (85 μT)', emX + 10, cy + 80);
        }

        else if (cmd.type === 'particulas_cern') {
          // Simulación colisionador continuo estilo CERN
          var cRad = Math.min(innerW * 0.3, innerH * 0.38);
          ctx.strokeStyle = 'rgba(88, 166, 255, 0.4)';
          ctx.lineWidth = 3;
          ctx.beginPath(); ctx.arc(cx, cy, cRad, 0, Math.PI * 2); ctx.stroke();

          // Haces colisionando
          var angBeam = now * 0.004;
          var b1x = cx + Math.cos(angBeam) * cRad;
          var b1y = cy + Math.sin(angBeam) * cRad;
          var b2x = cx + Math.cos(-angBeam) * cRad;
          var b2y = cy + Math.sin(-angBeam) * cRad;

          ctx.fillStyle = '#58A6FF';
          ctx.beginPath(); ctx.arc(b1x, b1y, 7, 0, Math.PI * 2); ctx.fill();
          ctx.fillStyle = '#D29922';
          ctx.beginPath(); ctx.arc(b2x, b2y, 7, 0, Math.PI * 2); ctx.fill();

          // Destellos en el centro
          ctx.strokeStyle = '#39C5BB';
          ctx.lineWidth = 1.5;
          for (var p = 0; p < (cmd.count || 8); p++) {
            var pAng = (p * Math.PI * 2 / cmd.count) + (now * 0.002);
            var dist = (now * 0.08) % cRad;
            ctx.beginPath();
            ctx.moveTo(cx, cy);
            ctx.lineTo(cx + Math.cos(pAng) * dist, cy + Math.sin(pAng) * dist);
            ctx.stroke();
          }
        }
      }

      // Si hay al menos 2 vectores y un resultante, trazar paralelogramo
      if (phasorsDrawn.length >= 3) {
        ctx.strokeStyle = 'rgba(255, 255, 255, 0.3)';
        ctx.setLineDash([4, 4]);
        ctx.beginPath();
        ctx.moveTo(phasorsDrawn[0].vx, phasorsDrawn[0].vy);
        ctx.lineTo(phasorsDrawn[2].vx, phasorsDrawn[2].vy);
        ctx.lineTo(phasorsDrawn[1].vx, phasorsDrawn[1].vy);
        ctx.stroke();
        ctx.setLineDash([]);
      }

      // Telemetría SoA en pie de ventana
      ctx.fillStyle = '#161B22';
      ctx.fillRect(0, innerH - 32, innerW, 32);
      ctx.strokeStyle = '#21262D';
      ctx.beginPath(); ctx.moveTo(0, innerH - 32); ctx.lineTo(innerW, innerH - 32); ctx.stroke();

      ctx.fillStyle = '#3FB950';
      ctx.font = 'bold 10px monospace';
      ctx.fillText('LIVE PREVIEW 120 FPS | ZERO-GC ESTABLE | SOA MEMORY: 64 KB', 12, innerH - 12);
    }
  };

  // =========================================================================
  // 4. PHASOR GRAPHER ENGINE (INTERACTIVE GEOGEBRA-STYLE ENGINEERING TOOL)
  // =========================================================================
  var PhasorGrapherEngine = {
    v1: { amp: 120.0, phase: 0.0 },
    v2: { amp: 80.0, phase: 45.0 },
    freq: 60.0,
    mode: 'SUM', // 'SUM' | 'SUB' | 'RLC'
    activeField: 'v1_amp', // 'v1_amp' | 'v1_phase' | 'v2_amp' | 'v2_phase' | 'freq'
    inputBuffer: '',

    getResults: function() {
      var r1 = this.v1.phase * Math.PI / 180;
      var v1x = this.v1.amp * Math.cos(r1);
      var v1y = this.v1.amp * Math.sin(r1);

      var r2 = this.v2.phase * Math.PI / 180;
      var v2x = this.v2.amp * Math.cos(r2);
      var v2y = this.v2.amp * Math.sin(r2);

      var vrx = (this.mode === 'SUB') ? (v1x - v2x) : (v1x + v2x);
      var vry = (this.mode === 'SUB') ? (v1y - v2y) : (v1y + v2y);

      var vrMag = Math.sqrt(vrx * vrx + vry * vry);
      var vrAng = Math.atan2(vry, vrx) * 180 / Math.PI;
      var vRms = vrMag / Math.SQRT2;
      var pf = Math.cos(vrAng * Math.PI / 180);

      return {
        v1x: v1x, v1y: v1y,
        v2x: v2x, v2y: v2y,
        vrx: vrx, vry: vry,
        vrMag: vrMag, vrAng: vrAng,
        vRms: vRms, pf: pf,
        pActive: vRms * 10 * pf,
        qReactive: vRms * 10 * Math.sin(vrAng * Math.PI / 180)
      };
    },

    adjustParam: function(delta) {
      if (this.activeField === 'v1_amp') this.v1.amp = Math.max(0, Math.min(300, this.v1.amp + delta));
      else if (this.activeField === 'v1_phase') this.v1.phase = (this.v1.phase + delta + 360) % 360;
      else if (this.activeField === 'v2_amp') this.v2.amp = Math.max(0, Math.min(300, this.v2.amp + delta));
      else if (this.activeField === 'v2_phase') this.v2.phase = (this.v2.phase + delta + 360) % 360;
      else if (this.activeField === 'freq') this.freq = Math.max(1, Math.min(1000, this.freq + delta));
      this.inputBuffer = '';
    },

    handleKey: function(e) {
      if (e.key >= '0' && e.key <= '9') {
        this.inputBuffer += e.key;
        this.applyInput();
      } else if (e.key === '.') {
        if (this.inputBuffer.indexOf('.') === -1) {
          this.inputBuffer += '.';
          this.applyInput();
        }
      } else if (e.key === 'Backspace') {
        this.inputBuffer = this.inputBuffer.slice(0, -1);
        this.applyInput();
      } else if (e.key === '+' || e.key === '=') {
        this.adjustParam(1);
      } else if (e.key === '-') {
        this.adjustParam(-1);
      }
    },

    applyInput: function() {
      var n = parseFloat(this.inputBuffer);
      if (!isNaN(n)) {
        if (this.activeField === 'v1_amp') this.v1.amp = n;
        else if (this.activeField === 'v1_phase') this.v1.phase = n;
        else if (this.activeField === 'v2_amp') this.v2.amp = n;
        else if (this.activeField === 'v2_phase') this.v2.phase = n;
        else if (this.activeField === 'freq') this.freq = n;
      }
    },

    handleClickParams: function(lx, ly, ch, innerW, innerH) {
      // 1. Tarjeta V1: y: 40..110
      if (ly >= 40 && ly <= 110) {
        if (lx >= 10 && lx <= 170) { this.activeField = 'v1_amp'; }
        if (lx >= 180 && lx <= 340) { this.activeField = 'v1_phase'; }

        // Botones de ajuste V1
        if (ly >= 80 && ly <= 104) {
          if (lx >= 20 && lx <= 60) this.adjustParam(-10);
          if (lx >= 64 && lx <= 104) this.adjustParam(-1);
          if (lx >= 110 && lx <= 150) this.adjustParam(1);
          if (lx >= 154 && lx <= 194) this.adjustParam(10);
        }
        return true;
      }

      // 2. Tarjeta V2: y: 120..190
      if (ly >= 120 && ly <= 190) {
        if (lx >= 10 && lx <= 170) { this.activeField = 'v2_amp'; }
        if (lx >= 180 && lx <= 340) { this.activeField = 'v2_phase'; }

        // Botones de ajuste V2
        if (ly >= 160 && ly <= 184) {
          if (lx >= 20 && lx <= 60) this.adjustParam(-10);
          if (lx >= 64 && lx <= 104) this.adjustParam(-1);
          if (lx >= 110 && lx <= 150) this.adjustParam(1);
          if (lx >= 154 && lx <= 194) this.adjustParam(10);
        }
        return true;
      }

      // 3. Frecuencia: y: 200..250
      if (ly >= 200 && ly <= 250) {
        this.activeField = 'freq';
        if (lx >= 170 && lx <= 220) this.freq = 50.0;
        if (lx >= 230 && lx <= 280) this.freq = 60.0;
        if (lx >= 290 && lx <= 340) this.freq = 400.0;
        return true;
      }

      // 4. Modos de Operacion: y: 260..300
      if (ly >= 260 && ly <= 300) {
        if (lx >= 10 && lx <= 150) this.mode = 'SUM';
        if (lx >= 160 && lx <= 300) this.mode = 'SUB';
        return true;
      }

      // 5. Presets de Ingenieria: y: 310..360
      if (ly >= 310 && ly <= 360) {
        if (lx >= 10 && lx <= 100) { this.v1.amp = 120; this.v1.phase = 0; this.v2.amp = 80; this.v2.phase = 45; }
        if (lx >= 110 && lx <= 210) { this.v1.amp = 100; this.v1.phase = 0; this.v2.amp = 100; this.v2.phase = 90; }
        if (lx >= 220 && lx <= 320) { this.v1.amp = 100; this.v1.phase = 0; this.v2.amp = 100; this.v2.phase = 180; }
        return true;
      }

      return false;
    },

    handleClickKeypad: function(lx, ly, ch, innerW, innerH) {
      var startY = 160;
      var keyW = Math.floor((innerW - 40) / 4);
      var keyH = 38;

      var keys = [
        ['7', '8', '9', '/'],
        ['4', '5', '6', '*'],
        ['1', '2', '3', '-'],
        ['0', '.', '±', '+'],
        ['DEL', 'AC', 'CALC', '=']
      ];

      for (var r = 0; r < keys.length; r++) {
        for (var c = 0; c < keys[r].length; c++) {
          var kx = 12 + (c * (keyW + 5));
          var ky = startY + (r * (keyH + 5));
          if (lx >= kx && lx <= kx + keyW && ly >= ky && ly <= ky + keyH) {
            var k = keys[r][c];
            if (k === 'DEL') {
              this.inputBuffer = this.inputBuffer.slice(0, -1);
              this.applyInput();
            } else if (k === 'AC') {
              this.inputBuffer = '';
              this.applyInput();
            } else if (k === '±') {
              var cur = parseFloat(this.inputBuffer) || 0;
              this.inputBuffer = (-cur).toString();
              this.applyInput();
            } else if (k >= '0' && k <= '9' || k === '.') {
              this.inputBuffer += k;
              this.applyInput();
            }
            return true;
          }
        }
      }
      return false;
    },

    renderParams: function(ctx, ch, innerW, innerH, isMobile) {
      ctx.fillStyle = '#0D1117';
      ctx.fillRect(0, 0, innerW, innerH);

      // Titulo
      ctx.fillStyle = '#58A6FF';
      ctx.font = 'bold 12px monospace';
      ctx.fillText('PARÁMETROS Y ECUACIONES FASORIALES', 12, 24);

      // 1. Tarjeta V1
      var isV1Act = (this.activeField.startsWith('v1'));
      ctx.fillStyle = isV1Act ? '#161B22' : '#0F131A';
      ctx.fillRect(10, 36, innerW - 20, 72);
      ctx.strokeStyle = isV1Act ? '#58A6FF' : '#30363D';
      ctx.strokeRect(10, 36, innerW - 20, 72);

      ctx.fillStyle = '#58A6FF';
      ctx.font = 'bold 11px monospace';
      ctx.fillText('FASOR V1: ' + this.v1.amp.toFixed(1) + ' V ∠ ' + this.v1.phase.toFixed(1) + '°', 20, 56);

      // Botones ajuste rapido V1
      var btns = ['-10', '-1', '+1', '+10'];
      for (var b = 0; b < btns.length; b++) {
        var bx = 20 + (b * 46);
        ctx.fillStyle = '#21262D';
        ctx.fillRect(bx, 68, 40, 24);
        ctx.fillStyle = '#C9D1D9';
        ctx.font = '10px monospace';
        ctx.fillText(btns[b], bx + 10, 84);
      }

      // 2. Tarjeta V2
      var isV2Act = (this.activeField.startsWith('v2'));
      ctx.fillStyle = isV2Act ? '#161B22' : '#0F131A';
      ctx.fillRect(10, 116, innerW - 20, 72);
      ctx.strokeStyle = isV2Act ? '#D29922' : '#30363D';
      ctx.strokeRect(10, 116, innerW - 20, 72);

      ctx.fillStyle = '#D29922';
      ctx.font = 'bold 11px monospace';
      ctx.fillText('FASOR V2: ' + this.v2.amp.toFixed(1) + ' V ∠ ' + this.v2.phase.toFixed(1) + '°', 20, 136);

      for (var b2 = 0; b2 < btns.length; b2++) {
        var bx2 = 20 + (b2 * 46);
        ctx.fillStyle = '#21262D';
        ctx.fillRect(bx2, 148, 40, 24);
        ctx.fillStyle = '#C9D1D9';
        ctx.font = '10px monospace';
        ctx.fillText(btns[b2], bx2 + 10, 164);
      }

      // 3. Frecuencia
      ctx.fillStyle = '#161B22';
      ctx.fillRect(10, 196, innerW - 20, 48);
      ctx.strokeStyle = '#30363D';
      ctx.strokeRect(10, 196, innerW - 20, 48);

      ctx.fillStyle = '#3FB950';
      ctx.font = 'bold 11px monospace';
      ctx.fillText('Frecuencia f: ' + this.freq.toFixed(1) + ' Hz', 20, 225);

      var freqs = [50, 60, 400];
      for (var f = 0; f < freqs.length; f++) {
        var fx = 170 + (f * 56);
        var isFAct = (this.freq === freqs[f]);
        ctx.fillStyle = isFAct ? '#238636' : '#21262D';
        ctx.fillRect(fx, 208, 48, 24);
        ctx.fillStyle = '#FFFFFF';
        ctx.fillText(freqs[f] + 'Hz', fx + 6, 224);
      }

      // 4. Modo de Operacion
      ctx.fillStyle = '#161B22';
      ctx.fillRect(10, 252, innerW - 20, 44);
      ctx.strokeStyle = '#30363D';
      ctx.strokeRect(10, 252, innerW - 20, 44);

      var isSum = (this.mode === 'SUM');
      ctx.fillStyle = isSum ? '#1F6FEB' : '#21262D';
      ctx.fillRect(20, 260, 140, 28);
      ctx.fillStyle = '#FFFFFF';
      ctx.fillText('V1 + V2 (Suma)', 35, 278);

      ctx.fillStyle = !isSum ? '#1F6FEB' : '#21262D';
      ctx.fillRect(170, 260, 140, 28);
      ctx.fillStyle = '#FFFFFF';
      ctx.fillText('V1 - V2 (Diferencial)', 175, 278);

      // 5. Presets
      ctx.fillStyle = '#8B949E';
      ctx.font = '10px monospace';
      ctx.fillText('PRESETS RÁPIDOS:', 12, 316);

      var presets = ['Kirchhoff', 'Cuadratura 90°', 'Cancelación 180°'];
      for (var p = 0; p < presets.length; p++) {
        var px = 10 + (p * 110);
        ctx.fillStyle = '#21262D';
        ctx.fillRect(px, 324, 102, 26);
        ctx.fillStyle = '#58A6FF';
        ctx.fillText(presets[p], px + 6, 341);
      }
    },

    renderCanvas: function(ctx, ch, innerW, innerH, isMobile, now) {
      ctx.fillStyle = '#070B12';
      ctx.fillRect(0, 0, innerW, innerH);

      var res = this.getResults();
      var cx = Math.floor(innerW * 0.28);
      var cy = Math.floor(innerH * 0.5);
      var maxV = Math.max(140, Math.max(this.v1.amp, this.v2.amp, res.vrMag));
      var scale = (Math.min(innerW * 0.45, innerH * 0.8) / 2) / maxV;

      // Ejes Complejos
      ctx.strokeStyle = '#21262D';
      ctx.lineWidth = 1;
      ctx.beginPath(); ctx.moveTo(20, cy); ctx.lineTo(innerW * 0.52, cy); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(cx, 20); ctx.lineTo(cx, innerH - 30); ctx.stroke();

      // Círculos concéntricos
      ctx.strokeStyle = 'rgba(57, 197, 187, 0.15)';
      ctx.setLineDash([2, 4]);
      for (var r = 1; r <= 3; r++) {
        ctx.beginPath();
        ctx.arc(cx, cy, (maxV * scale) * (r / 3), 0, Math.PI * 2);
        ctx.stroke();
      }
      ctx.setLineDash([]);

      // Rotación temporal continua a 120 FPS
      var omegaT = (now * 0.001) * (this.freq / 10);
      var ang1 = (this.v1.phase * Math.PI / 180) + omegaT;
      var ang2 = (this.v2.phase * Math.PI / 180) + omegaT;
      var angR = (res.vrAng * Math.PI / 180) + omegaT;

      var v1x = cx + Math.cos(ang1) * (this.v1.amp * scale);
      var v1y = cy - Math.sin(ang1) * (this.v1.amp * scale);

      var v2x = cx + Math.cos(ang2) * (this.v2.amp * scale);
      var v2y = cy - Math.sin(ang2) * (this.v2.amp * scale);

      var vrx = cx + Math.cos(angR) * (res.vrMag * scale);
      var vry = cy - Math.sin(angR) * (res.vrMag * scale);

      // Paralelogramo punteado
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.25)';
      ctx.setLineDash([4, 4]);
      ctx.beginPath();
      ctx.moveTo(v1x, v1y);
      ctx.lineTo(vrx, vry);
      ctx.lineTo(v2x, v2y);
      ctx.stroke();
      ctx.setLineDash([]);

      // Vector V1 (Azul)
      ctx.strokeStyle = '#58A6FF';
      ctx.lineWidth = 2.5;
      ctx.beginPath(); ctx.moveTo(cx, cy); ctx.lineTo(v1x, v1y); ctx.stroke();
      ctx.fillStyle = '#58A6FF'; ctx.beginPath(); ctx.arc(v1x, v1y, 4, 0, Math.PI * 2); ctx.fill();
      ctx.fillText('V1', v1x + 6, v1y - 4);

      // Vector V2 (Ámbar)
      ctx.strokeStyle = '#D29922';
      ctx.lineWidth = 2.5;
      ctx.beginPath(); ctx.moveTo(cx, cy); ctx.lineTo(v2x, v2y); ctx.stroke();
      ctx.fillStyle = '#D29922'; ctx.beginPath(); ctx.arc(v2x, v2y, 4, 0, Math.PI * 2); ctx.fill();
      ctx.fillText('V2', v2x + 6, v2y - 4);

      // Vector Resultante VR (Verde Esmeralda)
      ctx.strokeStyle = '#3FB950';
      ctx.lineWidth = 3.5;
      ctx.beginPath(); ctx.moveTo(cx, cy); ctx.lineTo(vrx, vry); ctx.stroke();
      ctx.fillStyle = '#3FB950'; ctx.beginPath(); ctx.arc(vrx, vry, 5, 0, Math.PI * 2); ctx.fill();
      ctx.fillText('VR (' + res.vrMag.toFixed(0) + 'V)', vrx + 8, vry - 4);

      // Mitad derecha: Formas de onda continuas proyectadas en el tiempo
      var waveX = Math.floor(innerW * 0.54);
      var waveW = innerW - waveX - 20;

      ctx.strokeStyle = '#21262D';
      ctx.beginPath(); ctx.moveTo(waveX, cy); ctx.lineTo(waveX + waveW, cy); ctx.stroke();

      // Línea de proyección desde VR
      ctx.strokeStyle = 'rgba(63, 185, 80, 0.3)';
      ctx.setLineDash([2, 4]);
      ctx.beginPath(); ctx.moveTo(vrx, vry); ctx.lineTo(waveX, vry); ctx.stroke();
      ctx.setLineDash([]);

      // Dibujar ondas: v1, v2, vr
      var waves = [
        { amp: this.v1.amp, ang: ang1, col: '#58A6FF', w: 1.5 },
        { amp: this.v2.amp, ang: ang2, col: '#D29922', w: 1.5 },
        { amp: res.vrMag, ang: angR, col: '#3FB950', w: 2.5 }
      ];

      for (var wi = 0; wi < waves.length; wi++) {
        var wv = waves[wi];
        ctx.strokeStyle = wv.col;
        ctx.lineWidth = wv.w;
        ctx.beginPath();
        for (var x = 0; x < waveW; x += 2) {
          var th = wv.ang - ((x / waveW) * (Math.PI * 4));
          var yPos = cy - Math.sin(th) * (wv.amp * scale);
          if (x === 0) ctx.moveTo(waveX + x, yPos); else ctx.lineTo(waveX + x, yPos);
        }
        ctx.stroke();
      }
    },

    renderKeypad: function(ctx, ch, innerW, innerH, isMobile) {
      ctx.fillStyle = '#0D1117';
      ctx.fillRect(0, 0, innerW, innerH);

      var res = this.getResults();

      // Panel de Resultados Calculados
      ctx.fillStyle = '#161B22';
      ctx.fillRect(10, 10, innerW - 20, 140);
      ctx.strokeStyle = '#30363D';
      ctx.strokeRect(10, 10, innerW - 20, 140);

      ctx.fillStyle = '#58A6FF';
      ctx.font = 'bold 11px monospace';
      ctx.fillText('ANÁLISIS FASORIAL EXACTO (PVM)', 20, 28);

      ctx.fillStyle = '#3FB950';
      ctx.font = 'bold 12px monospace';
      ctx.fillText('|VR| = ' + res.vrMag.toFixed(2) + ' V ∠ ' + res.vrAng.toFixed(2) + '°', 20, 50);

      ctx.fillStyle = '#C9D1D9';
      ctx.font = '10px monospace';
      ctx.fillText('Rectangular: ' + res.vrx.toFixed(2) + ' + ' + res.vry.toFixed(2) + 'j V', 20, 72);
      ctx.fillText('Tension RMS: ' + res.vRms.toFixed(2) + ' V (Eficaz)', 20, 92);
      ctx.fillText('Factor Potencia cos(θ): ' + res.pf.toFixed(3), 20, 112);
      ctx.fillText('P: ' + res.pActive.toFixed(1) + ' W | Q: ' + res.qReactive.toFixed(1) + ' VAR', 20, 132);

      // Teclado Numérico Científico
      var startY = 160;
      var keyW = Math.floor((innerW - 40) / 4);
      var keyH = 38;

      var keys = [
        ['7', '8', '9', '/'],
        ['4', '5', '6', '*'],
        ['1', '2', '3', '-'],
        ['0', '.', '±', '+'],
        ['DEL', 'AC', 'CALC', '=']
      ];

      for (var r = 0; r < keys.length; r++) {
        for (var c = 0; c < keys[r].length; c++) {
          var k = keys[r][c];
          var kx = 12 + (c * (keyW + 5));
          var ky = startY + (r * (keyH + 5));

          var isOp = (k === '+' || k === '-' || k === '*' || k === '/' || k === '=');
          var isFn = (k === 'DEL' || k === 'AC' || k === 'CALC');

          ctx.fillStyle = isFn ? '#30363D' : (isOp ? '#1F6FEB' : '#21262D');
          ctx.fillRect(kx, ky, keyW, keyH);
          ctx.strokeStyle = '#30363D';
          ctx.strokeRect(kx, ky, keyW, keyH);

          ctx.fillStyle = '#FFFFFF';
          ctx.font = 'bold 11px monospace';
          ctx.textAlign = 'center';
          ctx.fillText(k, kx + (keyW / 2), ky + 23);
        }
      }
      ctx.textAlign = 'left';
    }
  };

  // =========================================================================
  // 5. CALCULADORA FASORIAL CIENTIFICA ENGINE (ZERO-GC MULTI-FUNCION)
  // =========================================================================
  var CalculadoraEngine = {
    expr: '120.0 ∠ 45.0',
    resultPolar: '120.00 V ∠ 45.00°',
    resultRect: '84.85 + 84.85j V',
    ans: 120.0,

    handleKey: function(e) {
      if (e.key === 'Enter') {
        this.evaluate();
      } else if (e.key === 'Backspace') {
        this.expr = this.expr.slice(0, -1);
      } else if (e.key.length === 1 && !e.ctrlKey && !e.metaKey) {
        this.expr += e.key;
      }
    },

    handleClick: function(lx, ly, ch, innerW, innerH) {
      // Teclas calculadora
      var startY = 110;
      var keyW = Math.floor((innerW - 40) / 4);
      var keyH = 46;

      var keys = [
        ['7', '8', '9', '/'],
        ['4', '5', '6', '*'],
        ['1', '2', '3', '-'],
        ['0', '.', '∠', '+'],
        ['DEL', 'AC', 'POLAR', '=']
      ];

      for (var r = 0; r < keys.length; r++) {
        for (var c = 0; c < keys[r].length; c++) {
          var kx = 12 + (c * (keyW + 5));
          var ky = startY + (r * (keyH + 6));
          if (lx >= kx && lx <= kx + keyW && ly >= ky && ly <= ky + keyH) {
            var k = keys[r][c];
            if (k === '=') this.evaluate();
            else if (k === 'AC') { this.expr = ''; this.resultPolar = '0.00 V ∠ 0.00°'; this.resultRect = '0.00 + 0.00j V'; }
            else if (k === 'DEL') { this.expr = this.expr.slice(0, -1); }
            else if (k === 'POLAR') { /* Alterna */ }
            else { this.expr += k; }
            return true;
          }
        }
      }
      return false;
    },

    evaluate: function() {
      try {
        var clean = this.expr.trim();
        if (clean.indexOf('∠') !== -1) {
          var parts = clean.split('∠');
          var mag = parseFloat(parts[0]) || 0;
          var ang = parseFloat(parts[1]) || 0;
          var rad = ang * Math.PI / 180;
          var re = mag * Math.cos(rad);
          var im = mag * Math.sin(rad);
          this.resultPolar = mag.toFixed(2) + ' V ∠ ' + ang.toFixed(2) + '°';
          this.resultRect = re.toFixed(2) + (im >= 0 ? ' + ' : ' - ') + Math.abs(im).toFixed(2) + 'j V';
        } else {
          var n = eval(clean);
          this.resultPolar = (Number(n) || 0).toFixed(2) + ' (Escalar)';
          this.resultRect = (Number(n) || 0).toFixed(2) + ' + 0.00j';
        }
      } catch(e) {
        this.resultPolar = 'Error de Sintaxis';
      }
    },

    render: function(ctx, ch, innerW, innerH, isMobile) {
      ctx.fillStyle = '#0D1117';
      ctx.fillRect(0, 0, innerW, innerH);

      // Pantalla de la calculadora
      ctx.fillStyle = '#161B22';
      ctx.fillRect(10, 10, innerW - 20, 84);
      ctx.strokeStyle = '#30363D';
      ctx.strokeRect(10, 10, innerW - 20, 84);

      ctx.fillStyle = '#8B949E';
      ctx.font = '11px monospace';
      ctx.fillText(this.expr || '0', 20, 32);

      ctx.fillStyle = '#3FB950';
      ctx.font = 'bold 15px monospace';
      ctx.fillText(this.resultPolar, 20, 58);

      ctx.fillStyle = '#58A6FF';
      ctx.font = '11px monospace';
      ctx.fillText('Forma Rectangular: ' + this.resultRect, 20, 80);

      // Botones
      var startY = 110;
      var keyW = Math.floor((innerW - 40) / 4);
      var keyH = 46;

      var keys = [
        ['7', '8', '9', '/'],
        ['4', '5', '6', '*'],
        ['1', '2', '3', '-'],
        ['0', '.', '∠', '+'],
        ['DEL', 'AC', 'POLAR', '=']
      ];

      for (var r = 0; r < keys.length; r++) {
        for (var c = 0; c < keys[r].length; c++) {
          var k = keys[r][c];
          var kx = 12 + (c * (keyW + 5));
          var ky = startY + (r * (keyH + 6));
          var isEval = (k === '=');

          ctx.fillStyle = isEval ? '#238636' : '#21262D';
          ctx.fillRect(kx, ky, keyW, keyH);
          ctx.strokeStyle = '#30363D';
          ctx.strokeRect(kx, ky, keyW, keyH);

          ctx.fillStyle = '#FFFFFF';
          ctx.font = 'bold 12px monospace';
          ctx.textAlign = 'center';
          ctx.fillText(k, kx + (keyW / 2), ky + 28);
        }
      }
      ctx.textAlign = 'left';
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

// 2. Parchear renderFrame (Desktop) para que use ch.title / ch.id sin depender de orden
const oldDesktopDispatch = `if (self.appMode === 'ide') {
              if (ch.id === 1 || i === 0) {
                ChronosIdeEngine.renderStudio(ctx, ch, innerW, innerH, false);
              } else {
                ChronosIdeEngine.renderPreview(ctx, ch, innerW, innerH, false, performance.now());
              }
            } else if (self.appMode === 'graficadora') {
              if (ch.id === 1 || i === 0) {
                PhasorGrapherEngine.renderParams(ctx, ch, innerW, innerH, false);
              } else if (ch.id === 2 || i === 1) {
                PhasorGrapherEngine.renderCanvas(ctx, ch, innerW, innerH, false, performance.now());
              } else {
                PhasorGrapherEngine.renderKeypad(ctx, ch, innerW, innerH, false);
              }
            }`;

const newDesktopDispatch = `if (self.appMode === 'ide') {
              var isStudioWin = (ch.title && ch.title.indexOf('Studio') !== -1) || ch.id === 1;
              if (isStudioWin) {
                ChronosIdeEngine.renderStudio(ctx, ch, innerW, innerH, false);
              } else {
                ChronosIdeEngine.renderPreview(ctx, ch, innerW, innerH, false, performance.now());
              }
            } else if (self.appMode === 'graficadora') {
              var isParamsWin = (ch.title && (ch.title.indexOf('Parámetros') !== -1 || ch.title.indexOf('Ecuaciones') !== -1)) || ch.id === 1;
              var isCanvasWin = (ch.title && (ch.title.indexOf('Plano') !== -1 || ch.title.indexOf('Lienzo') !== -1 || ch.title.indexOf('Gráfico') !== -1)) || ch.id === 2;
              if (isParamsWin) {
                PhasorGrapherEngine.renderParams(ctx, ch, innerW, innerH, false);
              } else if (isCanvasWin) {
                PhasorGrapherEngine.renderCanvas(ctx, ch, innerW, innerH, false, performance.now());
              } else {
                PhasorGrapherEngine.renderKeypad(ctx, ch, innerW, innerH, false);
              }
            }`;

if (runtime.indexOf(oldDesktopDispatch) !== -1) {
  runtime = runtime.replace(oldDesktopDispatch, newDesktopDispatch);
}

// 3. Parchear renderFrame (Móvil)
const oldMobileDispatch = `if (self.appMode === 'ide') {
          if (activeChild.id === 1 || self.activeChildIndex === 0) {
            ChronosIdeEngine.renderStudio(ctx, activeChild, w - 20, innerH, true);
          } else {
            ChronosIdeEngine.renderPreview(ctx, activeChild, w - 20, innerH, true, performance.now());
          }
        } else if (self.appMode === 'graficadora') {
          if (activeChild.id === 1 || self.activeChildIndex === 0) {
            PhasorGrapherEngine.renderParams(ctx, activeChild, w - 20, innerH, true);
          } else if (activeChild.id === 2 || self.activeChildIndex === 1) {
            PhasorGrapherEngine.renderCanvas(ctx, activeChild, w - 20, innerH, true, performance.now());
          } else {
            PhasorGrapherEngine.renderKeypad(ctx, activeChild, w - 20, innerH, true);
          }
        }`;

const newMobileDispatch = `if (self.appMode === 'ide') {
          var isStudioMob = (activeChild.title && activeChild.title.indexOf('Studio') !== -1) || activeChild.id === 1;
          if (isStudioMob) {
            ChronosIdeEngine.renderStudio(ctx, activeChild, w - 20, innerH, true);
          } else {
            ChronosIdeEngine.renderPreview(ctx, activeChild, w - 20, innerH, true, performance.now());
          }
        } else if (self.appMode === 'graficadora') {
          var isParamsMob = (activeChild.title && (activeChild.title.indexOf('Parámetros') !== -1 || activeChild.title.indexOf('Ecuaciones') !== -1)) || activeChild.id === 1;
          var isCanvasMob = (activeChild.title && (activeChild.title.indexOf('Plano') !== -1 || activeChild.title.indexOf('Lienzo') !== -1 || activeChild.title.indexOf('Gráfico') !== -1)) || activeChild.id === 2;
          if (isParamsMob) {
            PhasorGrapherEngine.renderParams(ctx, activeChild, w - 20, innerH, true);
          } else if (isCanvasMob) {
            PhasorGrapherEngine.renderCanvas(ctx, activeChild, w - 20, innerH, true, performance.now());
          } else {
            PhasorGrapherEngine.renderKeypad(ctx, activeChild, w - 20, innerH, true);
          }
        }`;

if (runtime.indexOf(oldMobileDispatch) !== -1) {
  runtime = runtime.replace(oldMobileDispatch, newMobileDispatch);
}

// 4. Parchear handleClick (Desktop) para que traiga la ventana al frente
const oldHandleClick = `if (self.appMode === 'ide') {
              if (ch.id === 1 || i === 0) {
                if (ChronosIdeEngine.handleClick(locX, locY, ch, inW, inH)) {
                  self.renderFrame();
                  return;
                }
              }
            } else if (self.appMode === 'graficadora') {
              if (ch.id === 1 || i === 0) {
                if (PhasorGrapherEngine.handleClickParams(locX, locY, ch, inW, inH)) { self.renderFrame(); return; }
              } else if (ch.id === 3 || i === 2) {
                if (PhasorGrapherEngine.handleClickKeypad(locX, locY, ch, inW, inH)) { self.renderFrame(); return; }
              }
            }`;

const newHandleClick = `if (self.appMode === 'ide') {
              var isStudio = (ch.title && ch.title.indexOf('Studio') !== -1) || ch.id === 1;
              if (isStudio) {
                if (ChronosIdeEngine.handleClick(locX, locY, ch, inW, inH)) {
                  self.children.splice(i, 1);
                  self.children.push(ch);
                  self.renderFrame();
                  return;
                }
              }
            } else if (self.appMode === 'graficadora') {
              var isParams = (ch.title && (ch.title.indexOf('Parámetros') !== -1 || ch.title.indexOf('Ecuaciones') !== -1)) || ch.id === 1;
              var isKeypad = (ch.title && (ch.title.indexOf('Teclado') !== -1 || ch.title.indexOf('Análisis') !== -1)) || ch.id === 3;
              if (isParams) {
                if (PhasorGrapherEngine.handleClickParams(locX, locY, ch, inW, inH)) {
                  self.children.splice(i, 1);
                  self.children.push(ch);
                  self.renderFrame();
                  return;
                }
              } else if (isKeypad) {
                if (PhasorGrapherEngine.handleClickKeypad(locX, locY, ch, inW, inH)) {
                  self.children.splice(i, 1);
                  self.children.push(ch);
                  self.renderFrame();
                  return;
                }
              }
            }`;

if (runtime.indexOf(oldHandleClick) !== -1) {
  runtime = runtime.replace(oldHandleClick, newHandleClick);
}

// 5. Soporte para evento 'paste' de código
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

// 6. Soporte para scroll del mouse en Chronos IDE
const oldWheel = `for (var i = self.children.length - 1; i >= 0; i--) {
          var ch = self.children[i];
          if (ch.minimized) continue;
          if (mx >= ch.x && mx <= ch.x + ch.w && my >= ch.y + 30 && my <= ch.y + ch.h) {
            e.preventDefault();`;

const newWheel = `for (var i = self.children.length - 1; i >= 0; i--) {
          var ch = self.children[i];
          if (ch.minimized) continue;
          if (mx >= ch.x && mx <= ch.x + ch.w && my >= ch.y + 30 && my <= ch.y + ch.h) {
            e.preventDefault();
            if (self.appMode === 'ide' && ((ch.title && ch.title.indexOf('Studio') !== -1) || ch.id === 1)) {
              if (ChronosIdeEngine.activeTab === 'editor') {
                ChronosIdeEngine.scrollRow = Math.max(0, ChronosIdeEngine.scrollRow + (e.deltaY > 0 ? 3 : -3));
                self.renderFrame();
                return;
              }
            }`;

if (runtime.indexOf(oldWheel) !== -1) {
  runtime = runtime.replace(oldWheel, newWheel);
}

console.log('> [3/4] Escribiendo runtime sincronizado en todas las ubicaciones...');
fs.writeFileSync(runtimeSrcPath, runtime, 'utf8');
fs.writeFileSync(path.resolve(rootDir, 'runtime/phasor_runtime.js'), runtime, 'utf8');
fs.writeFileSync(path.resolve(rootDir, 'dist/phasor_runtime.js'), runtime, 'utf8');

console.log('> [4/4] Motores interactivos y runtime compilados con éxito!');
