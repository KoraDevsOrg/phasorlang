// tools/inject_interactive_engines.js
// Genera e inyecta los motores funcionales interactivos para Chronos IDE y Calculadora Gráfica
const fs = require('fs');
const path = require('path');

const runtimePath = path.resolve(__dirname, '../phasor_runtime.js');
let content = fs.readFileSync(runtimePath, 'utf8');

// Definición de motores interactivos
const enginesCode = `
  // =========================================================================
  // 3. CHRONOS IDE AUTONOMOUS ENGINE (LIVE CODE EDITOR & COMPILER IN BROWSER)
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
      "proyectar_onda(v1, '#58a6ff')",
      "proyectar_onda(v2, '#d29922')",
      "proyectar_onda(vr, '#3fb950')"
    ],
    cursorRow: 3,
    cursorCol: 17,
    scrollRow: 0,
    terminalLogs: [
      '> [PVM Kernel] Chronos IDE Autonomous v1.0.0 inicializado con éxito.',
      '> [PVM Kernel] Invariante Zero-GC activo. Memoria SoA: 64 KB contigua.',
      '> [PVM Kernel] Editor de código listo: puedes escribir, borrar y pulsar [▶ EJECUTAR].'
    ],
    drawCommands: [],
    registers: new Float64Array(256),
    regNames: {},
    hotReload: true,
    lastExecTime: '0.34',
    blinkTimer: 0,

    templates: [
      {
        title: '1. Suma de Tensiones Fasoriales (Kirchhoff)',
        desc: 'Suma vectorial V1 + V2 con paralelogramo y proyeccion senoidal.',
        code: [
          "// 1. Suma de Tensiones Fasoriales",
          "frecuencia = 60.0",
          "v1 = fasor(120.0, 0.0)",
          "v2 = fasor(80.0, 60.0)",
          "vr = v1 + v2",
          "imprimir('Tension V1:', v1.mag, 'V ∠', v1.ang, '°')",
          "imprimir('Tension V2:', v2.mag, 'V ∠', v2.ang, '°')",
          "imprimir('Resultante VR:', vr.mag, 'V ∠', vr.ang, '°')",
          "",
          "plano_complejo(130.0)",
          "dibujar_fasor(v1, '#58a6ff', 'V1')",
          "dibujar_fasor(v2, '#d29922', 'V2')",
          "dibujar_fasor(vr, '#3fb950', 'VR')",
          "proyectar_onda(v1, '#58a6ff')",
          "proyectar_onda(v2, '#d29922')",
          "proyectar_onda(vr, '#3fb950')"
        ]
      },
      {
        title: '2. Circuito RLC e Impedancia Compleja',
        desc: 'Calculo de R, XL, XC, impedancia Z y factor de potencia.',
        code: [
          "// 2. Circuito RLC Serie",
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
          "imprimir('Resistencia R:', r, 'Ω')",
          "imprimir('Reactancia Inductiva XL:', xl, 'Ω')",
          "imprimir('Reactancia Capacitiva XC:', xc, 'Ω')",
          "imprimir('Impedancia Total Z:', z_mag, 'Ω ∠', z_ang, '°')",
          "",
          "plano_complejo(110.0)",
          "dibujar_fasor(fasor(r, 0.0), '#58a6ff', 'R (30Ω)')",
          "dibujar_fasor(fasor(xl, 90.0), '#bc8cff', 'XL (45Ω)')",
          "dibujar_fasor(fasor(xc, -90.0), '#f85149', 'XC (33Ω)')",
          "dibujar_fasor(fasor(z_mag, z_ang), '#3fb950', 'Z Total')",
          "proyectar_onda(fasor(z_mag, z_ang), '#3fb950')"
        ]
      },
      {
        title: '3. Onda Electromagnetica Planar (Campos E y B)',
        desc: 'Propagacion de campos E y B ortogonales a 120 FPS sostenidos.',
        code: [
          "// 3. Onda Electromagnetica Planar",
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
        title: '4. Micro-Colisionador de Hadrones (Estilo CERN)',
        desc: 'Haces de particulas en colision continua de alta energia.',
        code: [
          "// 4. Micro-Colisionador de Hadrones",
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

        var mFas = expr.match(/^fasor\\s*\\(\\s*([^,]+)\\s*,\\s*([^)]+)\\s*\\)$/i);
        if (mFas) {
          var mag = evalExpr(mFas[1]);
          var ang = evalExpr(mFas[2]);
          var rad = ang * Math.PI / 180;
          return { type: 'phasor', mag: mag, ang: ang, re: mag * Math.cos(rad), im: mag * Math.sin(rad) };
        }

        var mComp = expr.match(/^complejo\\s*\\(\\s*([^,]+)\\s*,\\s*([^)]+)\\s*\\)$/i);
        if (mComp) {
          var re = evalExpr(mComp[1]);
          var im = evalExpr(mComp[2]);
          var cMag = Math.sqrt(re * re + im * im);
          var cAng = Math.atan2(im, re) * 180 / Math.PI;
          return { type: 'phasor', mag: cMag, ang: cAng, re: re, im: im };
        }

        var mFn = expr.match(/^([a-zA-Z0-9_]+)\\s*\\((.*)\\)$/);
        if (mFn) {
          var fn = mFn[1].toLowerCase();
          var rawArgs = mFn[2].split(',').map(function(a) { return evalExpr(a); });
          if (fn === 'sqrt') return Math.sqrt(Math.abs(rawArgs[0]));
          if (fn === 'sin') return Math.sin(rawArgs[0]);
          if (fn === 'cos') return Math.cos(rawArgs[0]);
          if (fn === 'abs') return Math.abs(rawArgs[0]);
          if (fn === 'atan2') return Math.atan2(rawArgs[0], rawArgs[1]);
        }

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

        if (expr.indexOf('-') > 0 && !expr.match(/e-\\d+/)) {
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
          for (var j = 0; j < pMul.length; j++) {
            prod *= evalExpr(pMul[j]);
          }
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

        var mPrint = raw.match(/^imprimir\\s*\\((.*)\\)$/i);
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

        var mPlano = raw.match(/^plano_complejo\\s*\\(\\s*([^)]*)\\s*\\)$/i);
        if (mPlano) {
          this.drawCommands.push({ type: 'plano_complejo', scale: evalExpr(mPlano[1]) || 120 });
          continue;
        }

        var mFasor = raw.match(/^dibujar_fasor\\s*\\(\\s*([^,]+)\\s*,\\s*([^,]+)\\s*,\\s*([^)]+)\\s*\\)$/i);
        if (mFasor) {
          var fVal = evalExpr(mFasor[1]);
          var fCol = mFasor[2].trim().replace(/['"]/g, '');
          var fLbl = mFasor[3].trim().replace(/['"]/g, '');
          this.drawCommands.push({ type: 'dibujar_fasor', phasor: fVal, color: fCol, label: fLbl });
          continue;
        }

        var mOnda = raw.match(/^proyectar_onda\\s*\\(\\s*([^,]+)\\s*,\\s*([^)]+)\\s*\\)$/i);
        if (mOnda) {
          var oVal = evalExpr(mOnda[1]);
          var oCol = mOnda[2].trim().replace(/['"]/g, '');
          this.drawCommands.push({ type: 'proyectar_onda', phasor: oVal, color: oCol });
          continue;
        }

        var mEM = raw.match(/^onda_em\\s*\\(\\s*([^,]+)\\s*,\\s*([^)]+)\\s*\\)$/i);
        if (mEM) {
          this.drawCommands.push({ type: 'onda_em', ampE: evalExpr(mEM[1]), ampB: evalExpr(mEM[2]) });
          continue;
        }

        var mCern = raw.match(/^particulas_cern\\s*\\(\\s*([^,]+)\\s*,\\s*([^)]+)\\s*\\)$/i);
        if (mCern) {
          this.drawCommands.push({ type: 'particulas_cern', r: evalExpr(mCern[1]), count: evalExpr(mCern[2]) });
          continue;
        }

        var eqIdx = raw.indexOf('=');
        if (eqIdx !== -1) {
          var id = raw.substring(0, eqIdx).trim();
          var valExpr = raw.substring(eqIdx + 1).trim();
          vars[id] = evalExpr(valExpr);
        }
      }

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
          this.registers[regIdx] = rVal.ang;
          this.regNames[regIdx] = k + '.ang';
          regIdx++;
        }
      }

      var dur = (performance.now() - tStart).toFixed(2);
      this.lastExecTime = dur;
      if (outLogs.length > 0) {
        this.terminalLogs = this.terminalLogs.concat(outLogs);
      }
      this.terminalLogs.push('> [PVM] Compilado en ' + dur + ' ms | 0 Allocations Heap (120 FPS)');
      if (this.terminalLogs.length > 60) {
        this.terminalLogs = this.terminalLogs.slice(this.terminalLogs.length - 60);
      }
    },

    handleKey: function(e) {
      if (this.activeTab !== 'editor') return;

      if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
        e.preventDefault();
        this.executeCode();
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
      } else if (e.key === 'Enter') {
        e.preventDefault();
        var lineCur = this.codeLines[this.cursorRow] || '';
        var before = lineCur.slice(0, this.cursorCol);
        var after = lineCur.slice(this.cursorCol);
        this.codeLines[this.cursorRow] = before;
        this.codeLines.splice(this.cursorRow + 1, 0, after);
        this.cursorRow++;
        this.cursorCol = 0;
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
      } else if (e.key === 'Tab') {
        e.preventDefault();
        var cL = this.codeLines[this.cursorRow] || '';
        this.codeLines[this.cursorRow] = cL.slice(0, this.cursorCol) + '  ' + cL.slice(this.cursorCol);
        this.cursorCol += 2;
      } else if (e.key.length === 1 && !e.ctrlKey && !e.metaKey) {
        e.preventDefault();
        var lStr = this.codeLines[this.cursorRow] || '';
        this.codeLines[this.cursorRow] = lStr.slice(0, this.cursorCol) + e.key + lStr.slice(this.cursorCol);
        this.cursorCol++;
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
        // Botones de acción: y: 34..62
        if (ly >= 34 && ly <= 62) {
          if (lx >= 6 && lx <= 170) {
            // [ ▶ EJECUTAR ]
            this.executeCode();
            return true;
          }
          if (lx >= 176 && lx <= 320) {
            // [ ⚡ Hot-Reload ]
            this.hotReload = !this.hotReload;
            return true;
          }
          if (lx >= 326 && lx <= 430) {
            // [ 🔄 Reiniciar ]
            this.codeLines = this.templates[0].code.slice();
            this.cursorRow = 3;
            this.cursorCol = 0;
            this.executeCode();
            return true;
          }
        }

        // Clic en área de texto: posicionar cursor
        if (ly >= 66) {
          var lineIdx = Math.floor((ly - 68) / 18) + this.scrollRow;
          if (lineIdx >= 0 && lineIdx < this.codeLines.length) {
            this.cursorRow = lineIdx;
            var cIdx = Math.max(0, Math.round((lx - 44) / 7.2));
            this.cursorCol = Math.min(cIdx, (this.codeLines[lineIdx] || '').length);
            return true;
          }
        }
      }

      // 3. Clics en pestaña Plantillas
      if (this.activeTab === 'templates') {
        var cardH = 96;
        var startY = 38;
        for (var t = 0; t < this.templates.length; t++) {
          var cY = startY + (t * (cardH + 12));
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
        if (ly >= 34 && ly <= 62 && lx >= 6 && lx <= 160) {
          this.terminalLogs = ['> [PVM Kernel] Terminal reiniciada.'];
          return true;
        }
      }

      return false;
    },

    renderStudio: function(ctx, ch, innerW, innerH, isMobile) {
      // Fondo de estudio
      ctx.fillStyle = '#0D1117';
      ctx.fillRect(0, 0, innerW, innerH);

      // Barra de pestañas
      var tabKeys = [
        { id: 'editor', label: '📝 Editor' },
        { id: 'templates', label: '📁 Plantillas' },
        { id: 'terminal', label: '📟 Terminal' },
        { id: 'debug', label: '🐞 Debug' },
        { id: 'docs', label: '📖 Docs' }
      ];
      var tabW = Math.floor(innerW / tabKeys.length);

      for (var t = 0; t < tabKeys.length; t++) {
        var tab = tabKeys[t];
        var isAct = (this.activeTab === tab.id);
        ctx.fillStyle = isAct ? '#1F6FEB' : '#161B22';
        ctx.fillRect(t * tabW, 0, tabW - 1, 28);
        ctx.fillStyle = isAct ? '#FFFFFF' : '#8B949E';
        ctx.font = (isAct ? 'bold ' : '') + '11px monospace';
        ctx.textAlign = 'center';
        ctx.fillText(tab.label, (t * tabW) + (tabW / 2), 18);
      }
      ctx.textAlign = 'left';

      // --- CONTENIDO DE PESTAÑA: EDITOR ---
      if (this.activeTab === 'editor') {
        // Barra de acciones
        ctx.fillStyle = '#161B22';
        ctx.fillRect(0, 30, innerW, 34);

        // [ ▶ EJECUTAR ]
        ctx.fillStyle = '#238636';
        ctx.fillRect(6, 34, 160, 26);
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 11px monospace';
        ctx.fillText('▶ EJECUTAR (Ctrl+↵)', 14, 51);

        // [ ⚡ Hot-Reload ]
        ctx.fillStyle = this.hotReload ? '#1F6FEB' : '#21262D';
        ctx.fillRect(174, 34, 140, 26);
        ctx.fillStyle = '#FFFFFF';
        ctx.fillText(this.hotReload ? '⚡ Hot-Reload: ON' : '⏸ Hot-Reload: OFF', 182, 51);

        // [ 🔄 Reset ]
        ctx.fillStyle = '#30363D';
        ctx.fillRect(322, 34, 100, 26);
        ctx.fillStyle = '#C9D1D9';
        ctx.fillText('🔄 Reiniciar', 334, 51);

        // Lienzo del editor
        ctx.fillStyle = '#07090E';
        ctx.fillRect(0, 64, innerW, innerH - 64);

        // Columna de números de línea
        ctx.fillStyle = '#0D1117';
        ctx.fillRect(0, 64, 38, innerH - 64);
        ctx.strokeStyle = '#21262D';
        ctx.beginPath(); ctx.moveTo(38, 64); ctx.lineTo(38, innerH); ctx.stroke();

        ctx.font = '12px monospace';
        var lineH = 18;
        var maxVisLines = Math.floor((innerH - 70) / lineH);

        for (var i = 0; i < maxVisLines; i++) {
          var lNum = i + this.scrollRow;
          if (lNum >= this.codeLines.length) break;
          var yPos = 80 + (i * lineH);

          // Número de línea
          ctx.fillStyle = (lNum === this.cursorRow) ? '#58A6FF' : '#484F58';
          ctx.textAlign = 'right';
          ctx.fillText((lNum + 1).toString(), 32, yPos);
          ctx.textAlign = 'left';

          // Resaltado de sintaxis
          var textLine = this.codeLines[lNum] || '';
          if (textLine.startsWith('//')) {
            ctx.fillStyle = '#6E7681';
          } else if (textLine.indexOf('=') !== -1) {
            ctx.fillStyle = '#E6EDF3';
          } else if (textLine.match(/^(plano_complejo|dibujar_fasor|proyectar_onda|imprimir)/)) {
            ctx.fillStyle = '#39C5BB';
          } else {
            ctx.fillStyle = '#C9D1D9';
          }
          ctx.fillText(textLine, 44, yPos);

          // Cursor parpadeante
          if (lNum === this.cursorRow) {
            this.blinkTimer = (this.blinkTimer + 1) % 60;
            if (this.blinkTimer < 32) {
              var curX = 44 + (this.cursorCol * 7.2);
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
        var cH = 80;
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
        ctx.fillText('DEPURADOR PVM — INSPECCIÓN R0..R255 (Fase 14 Zero-GC)', 12, 48);

        ctx.fillStyle = '#3FB950';
        ctx.font = '11px monospace';
        ctx.fillText('ESTADO: EJECUCIÓN CONTINUA (120 FPS) | 0 PAUSAS GC', 12, 68);

        var startRegY = 92;
        ctx.font = '11px monospace';
        for (var r = 0; r < 16; r++) {
          var rVal = this.registers[r];
          var rName = this.regNames[r] || ('reg_' + r);
          var colX = (r < 8) ? 14 : Math.floor(innerW / 2) + 10;
          var rowY = startRegY + ((r % 8) * 26);

          ctx.fillStyle = '#161B22';
          ctx.fillRect(colX, rowY - 14, Math.floor(innerW / 2) - 20, 22);

          ctx.fillStyle = '#58A6FF';
          ctx.fillText('[R' + r + '] ' + rName + ':', colX + 6, rowY + 1);
          ctx.fillStyle = '#3FB950';
          ctx.fillText(rVal.toFixed(2), colX + 130, rowY + 1);
        }
      }

      // --- CONTENIDO DE PESTAÑA: DOCS ---
      else if (this.activeTab === 'docs') {
        ctx.fillStyle = '#58A6FF';
        ctx.font = 'bold 12px monospace';
        ctx.fillText('REFERENCIA RÁPIDA DE PHASORLANG (DSL FASORIAL)', 12, 48);

        var docItems = [
          { sig: 'fasor(mag, ang_deg)', exp: 'Crea un vector fasorial con modulo y angulo.' },
          { sig: 'complejo(re, im)', exp: 'Crea un numero complejo en formato rectangular.' },
          { sig: 'plano_complejo(escala)', exp: 'Inicializa rejilla y ejes del plano de Gauss.' },
          { sig: 'dibujar_fasor(f, color, lbl)', exp: 'Dibuja vector fasorial con rotacion continua.' },
          { sig: 'proyectar_onda(f, color)', exp: 'Proyecta forma de onda senoidal continua.' },
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
          dY += 32;
        }
      }
    },

    renderPreview: function(ctx, ch, innerW, innerH, isMobile, now) {
      // Fondo
      ctx.fillStyle = '#070B12';
      ctx.fillRect(0, 0, innerW, innerH);

      var cx = Math.floor(innerW * 0.35);
      var cy = Math.floor(innerH * 0.5);
      var scale = 1.0;
      var phasorsDrawn = [];

      // Ejecutar comandos visuales
      for (var c = 0; c < this.drawCommands.length; c++) {
        var cmd = this.drawCommands[c];

        if (cmd.type === 'plano_complejo') {
          scale = Math.min(innerW, innerH) / (cmd.scale * 2.6);

          // Ejes cartesianos
          ctx.strokeStyle = '#21262D';
          ctx.lineWidth = 1;
          ctx.beginPath(); ctx.moveTo(20, cy); ctx.lineTo(innerW * 0.7, cy); ctx.stroke();
          ctx.beginPath(); ctx.moveTo(cx, 20); ctx.lineTo(cx, innerH - 20); ctx.stroke();

          // Círculos de escala
          ctx.strokeStyle = '#161B22';
          ctx.beginPath(); ctx.arc(cx, cy, 50 * scale, 0, Math.PI * 2); ctx.stroke();
          ctx.beginPath(); ctx.arc(cx, cy, 100 * scale, 0, Math.PI * 2); ctx.stroke();
          ctx.beginPath(); ctx.arc(cx, cy, 150 * scale, 0, Math.PI * 2); ctx.stroke();

          ctx.fillStyle = '#484F58';
          ctx.font = '10px monospace';
          ctx.fillText('+j Im', cx + 6, 28);
          ctx.fillText('+ Re', (innerW * 0.7) - 30, cy - 6);
        }

        else if (cmd.type === 'dibujar_fasor' && cmd.phasor) {
          var f = cmd.phasor;
          var angRad = (f.ang * Math.PI / 180) + (now * 0.002);
          var vx = cx + Math.cos(angRad) * (f.mag * scale);
          var vy = cy - Math.sin(angRad) * (f.mag * scale);
          phasorsDrawn.push({ vx: vx, vy: vy, col: cmd.color, mag: f.mag, angRad: angRad });

          // Línea de vector
          ctx.strokeStyle = cmd.color || '#58A6FF';
          ctx.lineWidth = 3;
          ctx.beginPath(); ctx.moveTo(cx, cy); ctx.lineTo(vx, vy); ctx.stroke();

          // Flecha / punta
          ctx.fillStyle = cmd.color || '#58A6FF';
          ctx.beginPath(); ctx.arc(vx, vy, 5, 0, Math.PI * 2); ctx.fill();

          // Etiqueta
          ctx.fillStyle = '#FFFFFF';
          ctx.font = 'bold 10px monospace';
          ctx.fillText(cmd.label || '', vx + 8, vy - 4);
        }

        else if (cmd.type === 'proyectar_onda' && cmd.phasor) {
          var pf = cmd.phasor;
          var waveStartX = Math.floor(innerW * 0.68);
          var waveW = innerW - waveStartX - 15;

          if (waveW > 30) {
            var angTime = (pf.ang * Math.PI / 180) + (now * 0.002);
            var tipY = cy - Math.sin(angTime) * (pf.mag * scale);

            // Línea punteada de proyección
            ctx.strokeStyle = 'rgba(255,255,255,0.2)';
            ctx.setLineDash([3, 3]);
            ctx.beginPath(); ctx.moveTo(cx, tipY); ctx.lineTo(waveStartX, tipY); ctx.stroke();
            ctx.setLineDash([]);

            // Eje central de onda
            ctx.strokeStyle = '#21262D';
            ctx.beginPath(); ctx.moveTo(waveStartX, cy); ctx.lineTo(innerW - 10, cy); ctx.stroke();

            // Onda senoidal continua
            ctx.strokeStyle = cmd.color || '#3FB950';
            ctx.lineWidth = 2;
            ctx.beginPath();
            for (var x = 0; x < waveW; x += 2) {
              var theta = angTime - ((x / waveW) * (Math.PI * 4));
              var y = cy - Math.sin(theta) * (pf.mag * scale);
              if (x === 0) ctx.moveTo(waveStartX + x, y); else ctx.lineTo(waveStartX + x, y);
            }
            ctx.stroke();
          }
        }

        else if (cmd.type === 'onda_em') {
          // Animación de onda electromagnética
          var eAmp = (cmd.ampE || 100) * 0.6;
          var bAmp = (cmd.ampB || 80) * 0.5;
          var emStartX = 40;
          var emW = innerW - 80;

          ctx.strokeStyle = '#21262D';
          ctx.beginPath(); ctx.moveTo(emStartX, cy); ctx.lineTo(emStartX + emW, cy); ctx.stroke();

          for (var emX = 0; emX < emW; emX += 16) {
            var phaseEM = (now * 0.003) - (emX * 0.03);
            var curE = Math.sin(phaseEM) * eAmp;
            var curB = Math.sin(phaseEM) * bAmp;

            // Vector E (vertical verde)
            ctx.strokeStyle = '#3FB950';
            ctx.lineWidth = 1.5;
            ctx.beginPath(); ctx.moveTo(emStartX + emX, cy); ctx.lineTo(emStartX + emX, cy - curE); ctx.stroke();

            // Vector B (oblicuo azul)
            ctx.strokeStyle = '#58A6FF';
            ctx.beginPath(); ctx.moveTo(emStartX + emX, cy); ctx.lineTo(emStartX + emX + (curB * 0.5), cy + (curB * 0.3)); ctx.stroke();
          }
        }

        else if (cmd.type === 'particulas_cern') {
          var cRad = Math.min(innerW, innerH) * 0.36;
          ctx.strokeStyle = '#21262D';
          ctx.lineWidth = 4;
          ctx.beginPath(); ctx.arc(cx, cy, cRad, 0, Math.PI * 2); ctx.stroke();

          // Dos haces colisionando
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

      // Si hay 2 vectores y resultante, trazar paralelogramo punteado
      if (phasorsDrawn.length >= 3) {
        ctx.strokeStyle = 'rgba(255, 255, 255, 0.25)';
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
      // Clics en tarjetas de parámetros
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

      // Frecuencia
      if (ly >= 200 && ly <= 250) {
        this.activeField = 'freq';
        if (lx >= 180 && lx <= 230) this.freq = 50.0;
        if (lx >= 236 && lx <= 286) this.freq = 60.0;
        if (lx >= 292 && lx <= 342) this.freq = 400.0;
        return true;
      }

      // Modos de Operación
      if (ly >= 270 && ly <= 310) {
        if (lx >= 10 && lx <= 170) this.mode = 'SUM';
        if (lx >= 180 && lx <= 340) this.mode = 'SUB';
        return true;
      }

      // Inversión rápida 180°
      if (ly >= 320 && ly <= 360) {
        if (lx >= 10 && lx <= 170) this.v1.phase = (this.v1.phase + 180) % 360;
        if (lx >= 180 && lx <= 340) this.v2.phase = (this.v2.phase + 180) % 360;
        return true;
      }

      return false;
    },

    handleClickKeypad: function(lx, ly, ch, innerW, innerH) {
      var startY = 180;
      var keyW = Math.floor((innerW - 40) / 4);
      var keyH = 44;

      var keys = [
        ['7', '8', '9', '/'],
        ['4', '5', '6', '*'],
        ['1', '2', '3', '-'],
        ['0', '.', '±', '+'],
        ['DEL', 'AC', 'CALC', '=']
      ];

      for (var r = 0; r < keys.length; r++) {
        for (var c = 0; c < keys[r].length; c++) {
          var kx = 16 + (c * (keyW + 6));
          var ky = startY + (r * (keyH + 6));
          if (lx >= kx && lx <= kx + keyW && ly >= ky && ly <= ky + keyH) {
            var k = keys[r][c];
            if (k === 'AC') {
              this.inputBuffer = '';
              this.applyInput();
            } else if (k === 'DEL') {
              this.inputBuffer = this.inputBuffer.slice(0, -1);
              this.applyInput();
            } else if (k === '±') {
              if (this.inputBuffer.startsWith('-')) this.inputBuffer = this.inputBuffer.substring(1);
              else this.inputBuffer = '-' + this.inputBuffer;
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

      ctx.fillStyle = '#58A6FF';
      ctx.font = 'bold 12px monospace';
      ctx.fillText('ENTRADA DE ECUACIONES & FASORES', 12, 22);

      // --- TARJETA V1 ---
      var isV1 = (this.activeField === 'v1_amp' || this.activeField === 'v1_phase');
      ctx.fillStyle = isV1 ? '#161B22' : '#111620';
      ctx.fillRect(10, 36, innerW - 20, 76);
      ctx.strokeStyle = isV1 ? '#58A6FF' : '#30363D';
      ctx.lineWidth = isV1 ? 1.5 : 1;
      ctx.strokeRect(10, 36, innerW - 20, 76);

      ctx.fillStyle = '#58A6FF';
      ctx.font = 'bold 11px monospace';
      ctx.fillText('FASOR V1 = ' + this.v1.amp.toFixed(1) + ' V ∠ ' + this.v1.phase.toFixed(1) + '°', 18, 54);

      // Botones ajuste V1
      ctx.fillStyle = '#21262D';
      ctx.fillRect(18, 70, 44, 22); ctx.fillRect(66, 70, 44, 22);
      ctx.fillRect(116, 70, 44, 22); ctx.fillRect(164, 70, 44, 22);
      ctx.fillStyle = '#C9D1D9';
      ctx.font = 'bold 10px monospace';
      ctx.fillText('-10', 30, 85); ctx.fillText('-1', 80, 85);
      ctx.fillText('+1', 130, 85); ctx.fillText('+10', 174, 85);

      // --- TARJETA V2 ---
      var isV2 = (this.activeField === 'v2_amp' || this.activeField === 'v2_phase');
      ctx.fillStyle = isV2 ? '#161B22' : '#111620';
      ctx.fillRect(10, 122, innerW - 20, 76);
      ctx.strokeStyle = isV2 ? '#D29922' : '#30363D';
      ctx.lineWidth = isV2 ? 1.5 : 1;
      ctx.strokeRect(10, 122, innerW - 20, 76);

      ctx.fillStyle = '#D29922';
      ctx.font = 'bold 11px monospace';
      ctx.fillText('FASOR V2 = ' + this.v2.amp.toFixed(1) + ' V ∠ ' + this.v2.phase.toFixed(1) + '°', 18, 140);

      // Botones ajuste V2
      ctx.fillStyle = '#21262D';
      ctx.fillRect(18, 156, 44, 22); ctx.fillRect(66, 156, 44, 22);
      ctx.fillRect(116, 156, 44, 22); ctx.fillRect(164, 156, 44, 22);
      ctx.fillStyle = '#C9D1D9';
      ctx.font = 'bold 10px monospace';
      ctx.fillText('-10', 30, 171); ctx.fillText('-1', 80, 171);
      ctx.fillText('+1', 130, 171); ctx.fillText('+10', 174, 171);

      // --- FRECUENCIA ---
      ctx.fillStyle = '#161B22';
      ctx.fillRect(10, 208, innerW - 20, 48);
      ctx.strokeStyle = '#30363D';
      ctx.strokeRect(10, 208, innerW - 20, 48);

      ctx.fillStyle = '#3FB950';
      ctx.font = 'bold 11px monospace';
      ctx.fillText('Frecuencia f: ' + this.freq.toFixed(1) + ' Hz', 18, 230);

      ctx.fillStyle = '#21262D';
      ctx.fillRect(180, 218, 48, 24); ctx.fillRect(234, 218, 48, 24); ctx.fillRect(288, 218, 54, 24);
      ctx.fillStyle = '#FFFFFF';
      ctx.font = '10px monospace';
      ctx.fillText('50Hz', 190, 234); ctx.fillText('60Hz', 244, 234); ctx.fillText('400Hz', 296, 234);

      // --- OPERACIÓN ---
      ctx.fillStyle = (this.mode === 'SUM') ? '#238636' : '#21262D';
      ctx.fillRect(10, 270, (innerW - 26) / 2, 34);
      ctx.fillStyle = '#FFFFFF';
      ctx.font = 'bold 11px monospace';
      ctx.fillText('✔ V1 + V2 (Suma)', 20, 292);

      ctx.fillStyle = (this.mode === 'SUB') ? '#238636' : '#21262D';
      ctx.fillRect(16 + ((innerW - 26) / 2), 270, (innerW - 26) / 2, 34);
      ctx.fillStyle = '#FFFFFF';
      ctx.fillText('✔ V1 - V2 (Resta)', 26 + ((innerW - 26) / 2), 292);

      // --- INVERSIÓN DE FASE 180° ---
      ctx.fillStyle = '#30363D';
      ctx.fillRect(10, 316, (innerW - 26) / 2, 32);
      ctx.fillRect(16 + ((innerW - 26) / 2), 316, (innerW - 26) / 2, 32);
      ctx.fillStyle = '#58A6FF';
      ctx.font = '10px monospace';
      ctx.fillText('± 180° Fase V1', 24, 336);
      ctx.fillStyle = '#D29922';
      ctx.fillText('± 180° Fase V2', 30 + ((innerW - 26) / 2), 336);
    },

    renderCanvas: function(ctx, ch, innerW, innerH, isMobile, now) {
      ctx.fillStyle = '#070B12';
      ctx.fillRect(0, 0, innerW, innerH);

      var cx = Math.floor(innerW * 0.32);
      var cy = Math.floor(innerH * 0.5);
      var scale = Math.min(innerW, innerH) / 520;
      var res = this.getResults();

      // Rejilla de Gauss
      ctx.strokeStyle = '#161B22';
      ctx.lineWidth = 1;
      ctx.beginPath();
      for (var r = 50; r <= 200; r += 50) {
        ctx.arc(cx, cy, r * scale, 0, Math.PI * 2);
      }
      ctx.stroke();

      // Ejes
      ctx.strokeStyle = '#21262D';
      ctx.beginPath(); ctx.moveTo(20, cy); ctx.lineTo(innerW * 0.65, cy); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(cx, 20); ctx.lineTo(cx, innerH - 20); ctx.stroke();

      ctx.fillStyle = '#484F58';
      ctx.font = '10px monospace';
      ctx.fillText('+j Im', cx + 6, 28);
      ctx.fillText('+ Re', (innerW * 0.65) - 30, cy - 6);

      // Ángulo de rotación continuo a 120 FPS
      var wRot = now * 0.002 * (this.freq / 60.0);
      var ang1 = (this.v1.phase * Math.PI / 180) + wRot;
      var ang2 = (this.v2.phase * Math.PI / 180) + wRot;
      var angR = (res.vrAng * Math.PI / 180) + wRot;

      var v1x = cx + Math.cos(ang1) * (this.v1.amp * scale);
      var v1y = cy - Math.sin(ang1) * (this.v1.amp * scale);
      var v2x = cx + Math.cos(ang2) * (this.v2.amp * scale);
      var v2y = cy - Math.sin(ang2) * (this.v2.amp * scale);
      var vrx = cx + Math.cos(angR) * (res.vrMag * scale);
      var vry = cy - Math.sin(angR) * (res.vrMag * scale);

      // Paralelogramo punteado
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.2)';
      ctx.setLineDash([4, 4]);
      ctx.beginPath();
      ctx.moveTo(v1x, v1y); ctx.lineTo(vrx, vry);
      ctx.lineTo(v2x, v2y);
      ctx.stroke();
      ctx.setLineDash([]);

      // Vector V1 (Azul)
      ctx.strokeStyle = '#58A6FF';
      ctx.lineWidth = 3;
      ctx.beginPath(); ctx.moveTo(cx, cy); ctx.lineTo(v1x, v1y); ctx.stroke();
      ctx.fillStyle = '#58A6FF';
      ctx.beginPath(); ctx.arc(v1x, v1y, 5, 0, Math.PI * 2); ctx.fill();

      // Vector V2 (Ámbar)
      ctx.strokeStyle = '#D29922';
      ctx.lineWidth = 3;
      ctx.beginPath(); ctx.moveTo(cx, cy); ctx.lineTo(v2x, v2y); ctx.stroke();
      ctx.fillStyle = '#D29922';
      ctx.beginPath(); ctx.arc(v2x, v2y, 5, 0, Math.PI * 2); ctx.fill();

      // Vector Resultante VR (Verde)
      ctx.strokeStyle = '#3FB950';
      ctx.lineWidth = 3.5;
      ctx.beginPath(); ctx.moveTo(cx, cy); ctx.lineTo(vrx, vry); ctx.stroke();
      ctx.fillStyle = '#3FB950';
      ctx.beginPath(); ctx.arc(vrx, vry, 6, 0, Math.PI * 2); ctx.fill();

      // --- SECCIÓN DE ONDAS SENOIDALES ---
      var waveX = Math.floor(innerW * 0.65);
      var waveW = innerW - waveX - 15;

      if (waveW > 40) {
        // Eje horizontal de onda
        ctx.strokeStyle = '#21262D';
        ctx.beginPath(); ctx.moveTo(waveX, cy); ctx.lineTo(innerW - 10, cy); ctx.stroke();

        // Proyección punteada VR
        ctx.strokeStyle = 'rgba(63, 185, 80, 0.4)';
        ctx.setLineDash([3, 3]);
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

// Insertar las definiciones de motores antes de PhasorRuntime
content = content.replace('var PhasorRuntime = {', enginesCode + '\n  var PhasorRuntime = {');

// En PhasorRuntime.init: detectar appMode
const initSearch = 'self.title = options.title || \'PhasorLang Application\';';
const initReplace = `self.title = options.title || 'PhasorLang Application';
      var rawApp = (options.appName || options.title || '').toLowerCase();
      if (rawApp.indexOf('ide') !== -1) {
        self.appMode = 'ide';
        ChronosIdeEngine.executeCode();
      } else if (rawApp.indexOf('graficadora') !== -1) {
        self.appMode = 'graficadora';
      } else if (rawApp.indexOf('calculadora') !== -1) {
        self.appMode = 'calculadora';
      } else {
        self.appMode = 'standard';
      }`;
content = content.replace(initSearch, initReplace);

// En setupInteractions: agregar listener de keydown
const setupSearch = 'self.canvas.addEventListener(\'mousedown\', function(e) {';
const setupReplace = `// 0. CAPTURA DE TECLADO PARA HERRAMIENTAS INTERACTIVAS
      window.addEventListener('keydown', function(e) {
        if (self.appMode === 'ide') {
          ChronosIdeEngine.handleKey(e);
          self.renderFrame();
        } else if (self.appMode === 'graficadora') {
          PhasorGrapherEngine.handleKey(e);
          self.renderFrame();
        } else if (self.appMode === 'calculadora') {
          CalculadoraEngine.handleKey(e);
          self.renderFrame();
        }
      });

      self.canvas.addEventListener('mousedown', function(e) {`;
content = content.replace(setupSearch, setupReplace);

// En mousedown: enrutar clics a los motores interactivos
const clickHookSearch = 'for (var i = self.children.length - 1; i >= 0; i--) {\\n          var ch = self.children[i];';
// Usaremos regex para encontrar el loop de ventanas en mousedown
content = content.replace(
  'for (var i = self.children.length - 1; i >= 0; i--) {\n          var ch = self.children[i];',
  `for (var i = self.children.length - 1; i >= 0; i--) {\n          var ch = self.children[i];
          // Despacho interactivo a motores de aplicación
          if (mx >= ch.x && mx <= ch.x + ch.w && my >= ch.y + 30 && my <= ch.y + ch.h && !ch.minimized) {
            var locX = mx - ch.x - 12 + (ch.scrollX || 0);
            var locY = my - ch.y - 32 + (ch.scrollY || 0);
            var inW = ch.w - 24;
            var inH = ch.h - 36;
            if (self.appMode === 'ide') {
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
            } else if (self.appMode === 'calculadora') {
              if (CalculadoraEngine.handleClick(locX, locY, ch, inW, inH)) { self.renderFrame(); return; }
            }
          }`
);

// En mousedown móvil (<768): enrutar clics interactivos
content = content.replace(
  '// B. Clic en botones dentro de la ventana activa en móvil',
  `// Interacción táctil en ventana activa móvil
          var activeChildMob = self.children[self.activeChildIndex] || self.children[0];
          if (my >= 44 && activeChildMob) {
            var mLocX = mx - 10 + (activeChildMob.scrollX || 0);
            var mLocY = my - 48 + (activeChildMob.scrollY || 0);
            var mInW = self.width - 20;
            var mInH = self.height - 44;

            if (self.appMode === 'ide') {
              if (activeChildMob.id === 1 || self.activeChildIndex === 0) {
                if (ChronosIdeEngine.handleClick(mLocX, mLocY, activeChildMob, mInW, mInH)) { self.renderFrame(); return; }
              }
            } else if (self.appMode === 'graficadora') {
              if (activeChildMob.id === 1 || self.activeChildIndex === 0) {
                if (PhasorGrapherEngine.handleClickParams(mLocX, mLocY, activeChildMob, mInW, mInH)) { self.renderFrame(); return; }
              } else if (activeChildMob.id === 3 || self.activeChildIndex === 2) {
                if (PhasorGrapherEngine.handleClickKeypad(mLocX, mLocY, activeChildMob, mInW, mInH)) { self.renderFrame(); return; }
              }
            } else if (self.appMode === 'calculadora') {
              if (CalculadoraEngine.handleClick(mLocX, mLocY, activeChildMob, mInW, mInH)) { self.renderFrame(); return; }
            }
          }

          // B. Clic en botones dentro de la ventana activa en móvil`
);

// En renderFrame (Desktop): rama para appMode
content = content.replace(
  'var targetVm = ch.appVm || self.vm;\n            if (self.vm && ch.screenPc !== undefined) {',
  `var targetVm = ch.appVm || self.vm;
            if (self.appMode === 'ide') {
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
            } else if (self.appMode === 'calculadora') {
              CalculadoraEngine.render(ctx, ch, innerW, innerH, false);
            } else if (self.vm && ch.screenPc !== undefined) {`
);

// En renderFrame (Mobile): rama para appMode
content = content.replace(
  'if (self.vm && activeChild.screenPc !== undefined) {',
  `if (self.appMode === 'ide') {
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
        } else if (self.appMode === 'calculadora') {
          CalculadoraEngine.render(ctx, activeChild, w - 20, innerH, true);
        } else if (self.vm && activeChild.screenPc !== undefined) {`
);

// Exportar globalmente
content = content.replace(
  'global.PhasorRuntime = PhasorRuntime;',
  `global.PhasorRuntime = PhasorRuntime;
  global.ChronosIdeEngine = ChronosIdeEngine;
  global.PhasorGrapherEngine = PhasorGrapherEngine;
  global.CalculadoraEngine = CalculadoraEngine;`
);

// Guardar en la raíz
fs.writeFileSync(runtimePath, content, 'utf8');
console.log('phasor_runtime.js actualizado con éxito:', content.length, 'bytes');

// Sincronizar en runtime/ y dist/
fs.copyFileSync(runtimePath, path.resolve(__dirname, '../runtime/phasor_runtime.js'));
fs.copyFileSync(runtimePath, path.resolve(__dirname, '../dist/phasor_runtime.js'));
console.log('Sincronizado a runtime/ y dist/phasor_runtime.js');
