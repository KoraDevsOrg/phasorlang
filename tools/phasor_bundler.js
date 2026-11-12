const fs = require('fs');
const path = require('path');

// =============================================================================
// 1. RESOLUCIÓN RECURSIVA DE IMPORTS (.ph)
// =============================================================================
function resolveImports(entryFile, visited = new Set()) {
  const absPath = path.resolve(entryFile);
  if (visited.has(absPath)) return '';
  visited.add(absPath);

  if (!fs.existsSync(absPath)) {
    console.warn(`⚠️ Import no encontrado: ${entryFile}`);
    return '';
  }

  const baseDir = path.dirname(absPath);
  const raw = fs.readFileSync(absPath, 'utf8');
  const lines = raw.split(/\r?\n/);
  const out = [];

  for (const line of lines) {
    const trimmed = line.trim();
    const match = trimmed.match(/^import\s+["']([^"']+)["']/);
    if (match) {
      const relImport = match[1];
      const candidateA = path.resolve(baseDir, relImport);
      const candidateB = path.resolve(process.cwd(), relImport);
      const target = fs.existsSync(candidateA) ? candidateA : candidateB;
      out.push(resolveImports(target, visited));
    } else {
      out.push(line);
    }
  }
  return out.join('\n');
}

// =============================================================================
// 2. COMPILADOR PHASORLANG (.ph) -> BYTECODE PVM 3-OPERAND ISA (32-BIT)
// =============================================================================
function compilePhasorToBytecode(source) {
  let clean = source.replace(/\/\*[\s\S]*?\*\//g, '').replace(/\/\/.*$/gm, '');

  const tokens = [];
  let i = 0;
  while (i < clean.length) {
    const c = clean[i];
    if (/\s/.test(c)) { i++; continue; }
    if (c === '"' || c === "'") {
      const q = c; i++;
      let s = '';
      while (i < clean.length && clean[i] !== q) {
        if (clean[i] === '\\' && i + 1 < clean.length) { s += clean[i + 1]; i += 2; }
        else { s += clean[i++]; }
      }
      i++;
      tokens.push({ type: 'STR', val: s });
      continue;
    }
    if (c === '0' && (clean[i + 1] === 'x' || clean[i + 1] === 'X')) {
      let hex = '0x'; i += 2;
      while (i < clean.length && /[0-9a-fA-F]/.test(clean[i])) hex += clean[i++];
      tokens.push({ type: 'NUM', val: parseInt(hex, 16) });
      continue;
    }
    if (/[0-9]/.test(c) || (c === '.' && /[0-9]/.test(clean[i + 1]))) {
      let num = '';
      while (i < clean.length && /[0-9.eE+-]/.test(clean[i])) {
        if ((clean[i] === '+' || clean[i] === '-') && !/[eE]/.test(clean[i - 1])) break;
        num += clean[i++];
      }
      tokens.push({ type: 'NUM', val: parseFloat(num) });
      continue;
    }
    if (/[a-zA-Z_]/.test(c)) {
      let id = '';
      while (i < clean.length && /[a-zA-Z0-9_]/.test(clean[i])) id += clean[i++];
      tokens.push({ type: 'ID', val: id });
      continue;
    }
    const two = clean.slice(i, i + 2);
    if (['==', '!=', '<=', '>=', '&&', '||'].includes(two)) {
      tokens.push({ type: 'OP', val: two }); i += 2; continue;
    }
    tokens.push({ type: 'OP', val: c }); i++;
  }

  const code = [];
  const constPool = [];
  const strings = [];
  const constMap = new Map();
  const strMap = new Map();

  function addConst(v) {
    const num = Number(v) || 0;
    const key = String(num);
    if (constMap.has(key)) return constMap.get(key);
    const idx = constPool.length;
    constPool.push(num);
    constMap.set(key, idx);
    return idx;
  }

  function addStr(s) {
    const str = String(s || '');
    if (strMap.has(str)) return strMap.get(str);
    const idx = strings.length;
    strings.push(str);
    strMap.set(str, idx);
    return idx;
  }

  // Registros:
  // R0..R119: señales/variables globales
  // R120..R228: pila de temporales y marcos locales (sin colisiones entre llamadas)
  // R229..R255: registros hardware PVM (R250=sw, R251=sh, R252=mx, R253=my, R254=pd, R255=whY)
  const varRegs = new Map();
  let nextVarReg = 0;
  function getVarReg(name) {
    const m = name.match(/^R(\d+)$/);
    if (m) return parseInt(m[1], 10);
    if (varRegs.has(name)) return varRegs.get(name);
    const r = nextVarReg++;
    if (nextVarReg >= 120) nextVarReg = 0;
    varRegs.set(name, r);
    return r;
  }

  let tempPtr = 120;
  function allocTemp() {
    const r = tempPtr++;
    if (tempPtr > 228) tempPtr = 120;
    return r;
  }

  function emit(op, dst = 0, s1 = 0, s2 = 0) {
    code.push(((op & 0xFF) << 24) | ((dst & 0xFF) << 16) | ((s1 & 0xFF) << 8) | (s2 & 0xFF));
    return code.length - 1;
  }

  const functions = new Map();
  const screens = new Map();
  const topStatements = [];

  let pos = 0;
  const peek = (o = 0) => tokens[pos + o];
  const next = () => tokens[pos++];

  function isFuncDef(startIdx) {
    let k = startIdx + 1;
    if (!tokens[k] || tokens[k].val !== '(') return false;
    let d = 0;
    while (k < tokens.length) {
      if (tokens[k].val === '(') d++;
      else if (tokens[k].val === ')') {
        d--;
        if (d === 0) return tokens[k + 1] && tokens[k + 1].val === '=';
      }
      k++;
    }
    return false;
  }

  function readBlock() {
    if (peek() && peek().val === '{') next();
    const body = [];
    let depth = 1;
    while (pos < tokens.length && depth > 0) {
      const t = next();
      if (t.val === '{') depth++;
      else if (t.val === '}') {
        depth--;
        if (depth === 0) break;
      }
      body.push(t);
    }
    return body;
  }

  while (pos < tokens.length) {
    const t = peek();
    if (!t) break;
    if (t.val === ';') { next(); continue; }
    if (t.type === 'ID' && t.val === 'signal') {
      next();
      const name = next().val;
      if (peek() && peek().val === '=') {
        next();
        const exprTokens = [];
        while (pos < tokens.length && peek().val !== ';' && !(peek().type === 'ID' && ['signal', 'screen'].includes(peek().val)) && !(peek().type === 'ID' && peek(1) && peek(1).val === '(' && isFuncDef(pos))) {
          exprTokens.push(next());
        }
        topStatements.push({ kind: 'assign', name, expr: exprTokens });
      }
      continue;
    }
    if (t.type === 'ID' && t.val === 'screen') {
      next();
      const sName = next().val;
      const body = readBlock();
      screens.set(sName, body);
      continue;
    }
    if (t.type === 'ID' && peek(1) && peek(1).val === '(' && isFuncDef(pos)) {
      const fnName = next().val;
      next(); // '('
      const params = [];
      while (pos < tokens.length && peek().val !== ')') {
        const pt = next();
        if (pt.type === 'ID') params.push(pt.val);
      }
      if (peek() && peek().val === ')') next();
      if (peek() && peek().val === '=') next();
      const body = readBlock();
      functions.set(fnName, { params, body });
      continue;
    }
    if (t.type === 'ID' && peek(1) && peek(1).val === '=') {
      const name = next().val;
      next(); // '='
      const exprTokens = [];
      while (pos < tokens.length && peek().val !== ';' && !(peek().type === 'ID' && ['signal', 'screen'].includes(peek().val)) && !(peek().type === 'ID' && peek(1) && peek(1).val === '(' && isFuncDef(pos))) {
        exprTokens.push(next());
      }
      topStatements.push({ kind: 'assign', name, expr: exprTokens });
      continue;
    }
    next();
  }

  function compileStream(tokList, localScope = null, callDepth = 0) {
    if (!Array.isArray(tokList) || tokList.length === 0) return allocTemp();
    let p = 0;
    let lastReg = allocTemp();
    const pk = (o = 0) => (tokList && (p + o) < tokList.length) ? tokList[p + o] : null;
    const nx = () => (tokList && p < tokList.length) ? tokList[p++] : null;

    function resolveReg(name) {
      if (localScope && localScope.has(name)) return localScope.get(name);
      return getVarReg(name);
    }

    function parseArgs() {
      nx(); // '('
      const args = [];
      let cur = [];
      let d = 0;
      while (p < tokList.length) {
        const tk = nx();
        if (!tk) break;
        if (tk.val === '(') { d++; cur.push(tk); }
        else if (tk.val === ')') {
          if (d === 0) { if (cur.length) args.push(cur); break; }
          d--; cur.push(tk);
        } else if (tk.val === ',' && d === 0) {
          args.push(cur); cur = [];
        } else {
          cur.push(tk);
        }
      }
      return args;
    }

    function compileExprTokens(subToks) {
      if (!Array.isArray(subToks) || subToks.length === 0) {
        const z = allocTemp();
        emit(0x01, z, addConst(0));
        return z;
      }
      const savedP = p, savedList = tokList;
      p = 0; tokList = subToks;
      const r = parseOr();
      p = savedP; tokList = savedList;
      return r;
    }

    function parseOr() {
      let l = parseAnd();
      while (pk() && pk().val === '||') {
        nx();
        const r = parseAnd();
        const dst = allocTemp();
        emit(0x03, dst, l, r);
        const z = allocTemp(); emit(0x01, z, addConst(0));
        emit(0x22, dst, dst, z);
        l = dst;
      }
      return l;
    }

    function parseAnd() {
      let l = parseCmp();
      while (pk() && pk().val === '&&') {
        nx();
        const r = parseCmp();
        const dst = allocTemp();
        emit(0x05, dst, l, r);
        l = dst;
      }
      return l;
    }

    function parseCmp() {
      let l = parseAdd();
      const cmpOps = { '==': 0x21, '!=': 0x22, '<': 0x23, '<=': 0x24, '>': 0x25, '>=': 0x26 };
      while (pk() && cmpOps[pk().val]) {
        const op = cmpOps[nx().val];
        const r = parseAdd();
        const dst = allocTemp();
        emit(op, dst, l, r);
        l = dst;
      }
      return l;
    }

    function parseAdd() {
      let l = parseMul();
      while (pk() && (pk().val === '+' || pk().val === '-')) {
        const op = nx().val === '+' ? 0x03 : 0x04;
        const r = parseMul();
        const dst = allocTemp();
        emit(op, dst, l, r);
        l = dst;
      }
      return l;
    }

    function parseMul() {
      let l = parseUnary();
      while (pk() && (pk().val === '*' || pk().val === '/' || pk().val === '%')) {
        const sym = nx().val;
        const op = sym === '*' ? 0x05 : (sym === '/' ? 0x06 : 0x15);
        const r = parseUnary();
        const dst = allocTemp();
        emit(op, dst, l, r);
        l = dst;
      }
      return l;
    }

    function parseUnary() {
      const tk = pk();
      if (tk && tk.val === '-') {
        nx();
        const v = parsePrimary();
        const z = allocTemp(); emit(0x01, z, addConst(0));
        const dst = allocTemp(); emit(0x04, dst, z, v);
        return dst;
      }
      return parsePrimary();
    }

    function parsePrimary() {
      const tk = pk();
      if (!tk) return allocTemp();
      if (tk.val === '(') {
        nx();
        const r = parseOr();
        if (pk() && pk().val === ')') nx();
        return r;
      }
      if (tk.type === 'NUM') {
        nx();
        const dst = allocTemp();
        emit(0x01, dst, addConst(tk.val));
        return dst;
      }
      if (tk.type === 'STR') {
        nx();
        const dst = allocTemp();
        emit(0x01, dst, addConst(addStr(tk.val)));
        return dst;
      }
      if (tk.type === 'ID') {
        const name = nx().val;
        if (pk() && pk().val === '(') {
          const rawArgs = parseArgs();
          return emitCall(name, rawArgs);
        }
        return resolveReg(name);
      }
      nx();
      return allocTemp();
    }

    function emitCall(fnName, rawArgs) {
      if (fnName === 'cls') {
        const c = compileExprTokens(rawArgs[0]);
        emit(0x50, c, 0, 0);
        return c;
      }
      if (fnName === 'rect') {
        const r0 = compileExprTokens(rawArgs[0]);
        const r1 = compileExprTokens(rawArgs[1]);
        const r2 = compileExprTokens(rawArgs[2]);
        const r3 = compileExprTokens(rawArgs[3]);
        const r4 = compileExprTokens(rawArgs[4]);
        emit(0x51, 0, 0, 0);
        code.push(r0, r1, r2, r3, r4);
        return r0;
      }
      if (fnName === 'circle') {
        const r0 = compileExprTokens(rawArgs[0]);
        const r1 = compileExprTokens(rawArgs[1]);
        const r2 = compileExprTokens(rawArgs[2]);
        const r3 = compileExprTokens(rawArgs[3]);
        emit(0x52, 0, 0, 0);
        code.push(r0, r1, r2, r3);
        return r0;
      }
      if (fnName === 'line') {
        const r0 = compileExprTokens(rawArgs[0]);
        const r1 = compileExprTokens(rawArgs[1]);
        const r2 = compileExprTokens(rawArgs[2]);
        const r3 = compileExprTokens(rawArgs[3]);
        const r4 = compileExprTokens(rawArgs[4]);
        emit(0x53, 0, 0, 0);
        code.push(r0, r1, r2, r3, r4);
        return r0;
      }
      if (fnName === 'text') {
        const arg0 = rawArgs[0] || [];
        const isLiteralStr = arg0.length === 1 && arg0[0].type === 'STR';
        const sRef = isLiteralStr ? addStr(arg0[0].val) : compileExprTokens(arg0);
        const rx = compileExprTokens(rawArgs[1]);
        const ry = compileExprTokens(rawArgs[2]);
        const rSz = compileExprTokens(rawArgs[3]);
        const rCol = compileExprTokens(rawArgs[4]);
        emit(0x54, isLiteralStr ? 1 : 2, 0, 0);
        code.push(sRef, rx, ry, rSz, rCol);
        return rx;
      }
      if (fnName === 'clip') {
        const r0 = compileExprTokens(rawArgs[0]);
        const r1 = compileExprTokens(rawArgs[1]);
        const r2 = compileExprTokens(rawArgs[2]);
        const r3 = compileExprTokens(rawArgs[3]);
        emit(0x5A, 0, 0, 0);
        code.push(r0, r1, r2, r3);
        return r0;
      }
      if (fnName === 'unclip') {
        emit(0x5B, 0, 0, 0);
        return allocTemp();
      }
      if (fnName === 'sin' || fnName === 'cos' || fnName === 'tan' || fnName === 'sqrt' || fnName === 'abs') {
        const opMap = { sin: 0x17, cos: 0x18, tan: 0x19, sqrt: 0x16, abs: 0x1C };
        const a = compileExprTokens(rawArgs[0]);
        const dst = allocTemp();
        emit(opMap[fnName], dst, a, 0);
        return dst;
      }
      if (fnName === 'alloc_soa') {
        const f = compileExprTokens(rawArgs[0]);
        const n = compileExprTokens(rawArgs[1]);
        const dst = allocTemp();
        emit(0x70, dst, f, n);
        return dst;
      }
      if (fnName === 'set_soa') {
        const base = compileExprTokens(rawArgs[0]);
        const field = compileExprTokens(rawArgs[1]);
        const idx = compileExprTokens(rawArgs[2]);
        const stride = compileExprTokens(rawArgs[3]);
        const val = compileExprTokens(rawArgs[4]);
        emit(0x72, base, val, field);
        code.push(((idx & 0xFFFF) << 16) | ((stride & 0xFF) << 8));
        return val;
      }
      if (fnName === 'get_soa') {
        const base = compileExprTokens(rawArgs[0]);
        const field = compileExprTokens(rawArgs[1]);
        const idx = compileExprTokens(rawArgs[2]);
        const stride = compileExprTokens(rawArgs[3]);
        const dst = allocTemp();
        emit(0x71, dst, base, field);
        code.push(((idx & 0xFFFF) << 16) | ((stride & 0xFF) << 8));
        return dst;
      }

      if (functions.has(fnName) && callDepth < 12) {
        const fnDef = functions.get(fnName);
        const childScope = new Map();
        const savedTempPtr = tempPtr;
        for (let k = 0; k < fnDef.params.length; k++) {
          const argReg = compileExprTokens(rawArgs[k]);
          const pReg = allocTemp();
          emit(0x02, pReg, argReg, 0);
          childScope.set(fnDef.params[k], pReg);
        }
        const retReg = compileStream(fnDef.body, childScope, callDepth + 1);
        const outReg = savedTempPtr;
        if (retReg !== outReg) emit(0x02, outReg, retReg, 0);
        tempPtr = savedTempPtr + 1;
        if (tempPtr > 228) tempPtr = 120;
        return outReg;
      }

      return allocTemp();
    }

    function extractBlock() {
      if (pk() && pk().val === '{') nx();
      const blk = [];
      let d = 1;
      while (p < tokList.length && d > 0) {
        const tk = nx();
        if (!tk) break;
        if (tk.val === '{') d++;
        else if (tk.val === '}') { d--; if (d === 0) break; }
        blk.push(tk);
      }
      return blk;
    }

    while (p < tokList.length) {
      const tk = pk();
      if (!tk) break;
      if (tk.val === ';') { nx(); continue; }

      if (tk.type === 'ID' && tk.val === 'if') {
        nx();
        const condReg = parseOr();
        const jzPos = emit(0x08, condReg, 0, 0);
        const thenBlk = extractBlock();
        lastReg = compileStream(thenBlk, localScope, callDepth);
        if (pk() && pk().type === 'ID' && pk().val === 'else') {
          nx();
          const jmpEndPos = emit(0x07, 0, 0, 0);
          code[jzPos] = (code[jzPos] & 0xFFFF0000) | (code.length & 0xFFFF);
          const elseBlk = extractBlock();
          lastReg = compileStream(elseBlk, localScope, callDepth);
          code[jmpEndPos] = (code[jmpEndPos] & 0xFFFF0000) | (code.length & 0xFFFF);
        } else {
          code[jzPos] = (code[jzPos] & 0xFFFF0000) | (code.length & 0xFFFF);
        }
        continue;
      }

      if (tk.type === 'ID' && tk.val === 'while') {
        nx();
        const loopStart = code.length;
        const condReg = parseOr();
        const jzPos = emit(0x08, condReg, 0, 0);
        const loopBlk = extractBlock();
        compileStream(loopBlk, localScope, callDepth);
        emit(0x07, 0, 0, 0);
        code[code.length - 1] = (code[code.length - 1] & 0xFFFF0000) | (loopStart & 0xFFFF);
        code[jzPos] = (code[jzPos] & 0xFFFF0000) | (code.length & 0xFFFF);
        continue;
      }

      if (tk.type === 'ID' && pk(1) && pk(1).val === '=') {
        const varName = nx().val;
        nx(); // '='
        const valReg = parseOr();
        const dstReg = resolveReg(varName);
        if (dstReg !== valReg) emit(0x02, dstReg, valReg, 0);
        lastReg = dstReg;
        continue;
      }

      lastReg = parseOr();
    }
    return lastReg;
  }

  for (const st of topStatements) {
    compileStream([
      { type: 'ID', val: st.name },
      { type: 'OP', val: '=' },
      ...st.expr
    ]);
  }
  const initEndPc = code.length;
  emit(0xFF, 0, 0, 0);

  const firstScreenPc = code.length;
  const mainBody = screens.get('main') || [];
  compileStream(mainBody);
  emit(0xFF, 0, 0, 0);

  return {
    bytecode: code,
    constPool,
    strings,
    screenRoutes: { '0': firstScreenPc, main: firstScreenPc },
    actionRoutes: {},
    firstScreenPc,
    initEndPc
  };
}

// =============================================================================
// 3. EMPAQUETADOR STANDALONE HTML (CERO DEPENDENCIAS, 120 FPS ZERO-GC)
// =============================================================================
function bundlePhasor(inputPath, outputPath) {
  if (!fs.existsSync(inputPath)) {
    console.error(`Error: Archivo de entrada no encontrado: ${inputPath}`);
    process.exit(1);
  }

  const combinedSource = resolveImports(inputPath);
  const compiled = compilePhasorToBytecode(combinedSource);

  const runtimePath = path.join(__dirname, '../runtime/phasor_runtime.js');
  let runtimeCode = fs.existsSync(runtimePath)
    ? fs.readFileSync(runtimePath, 'utf8')
    : '';

  runtimeCode = runtimeCode.replace(
    "self.canvas.addEventListener('pointerdown', function (e) {",
    `self.canvas.addEventListener('pointerdown', function (e) {
        if (self.canvas.setPointerCapture && e.pointerId !== undefined) {
          try { self.canvas.setPointerCapture(e.pointerId); } catch (err) {}
        }`
  );

  const payloadJson = JSON.stringify(compiled);

  const htmlContent = `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>Chronos IDE — PhasorLang Standalone</title>
  <style>
    * { box-sizing: border-box; -webkit-tap-highlight-color: transparent; }
    html, body {
      margin: 0; padding: 0; width: 100%; height: 100%;
      overflow: hidden; background: #090D13; touch-action: none;
    }
    canvas {
      display: block; width: 100vw; height: 100vh; touch-action: none;
    }
  </style>
</head>
<body>
  <canvas id="phasorCanvas"></canvas>
  <phasorcode id="phasor-bytecode" style="display:none">${payloadJson}</phasorcode>
  <script>
${runtimeCode}
  </script>
</body>
</html>`;

  const outDir = path.dirname(outputPath);
  if (outDir && !fs.existsSync(outDir)) {
    fs.mkdirSync(outDir, { recursive: true });
  }
  fs.writeFileSync(outputPath, htmlContent, 'utf8');
  console.log(`✔ Compilado AOT + Empaquetado: ${outputPath} (${compiled.bytecode.length} instrucciones PVM, ${(Buffer.byteLength(htmlContent) / 1024).toFixed(1)} KB)`);
}

if (require.main === module) {
  const args = process.argv.slice(2);
  if (args.length < 2) {
    console.log('Uso: node tools/phasor_bundler.js <entrada.ph> <salida.html>');
    process.exit(1);
  }
  bundlePhasor(args[0], args[1]);
}

module.exports = { bundlePhasor, resolveImports, compilePhasorToBytecode };
