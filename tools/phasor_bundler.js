#!/usr/bin/env node
// ============================================================================
// PHASORLANG UNIVERSAL HTML BUNDLER — CHRONOS IDE & KORADEVS ECOSYSTEM
// https://github.com/koradevsorg
//
// Empaquetador Autónomo Universal de Aplicaciones Multi-Dispositivo & Multi-Ventana
// Compila cualquier archivo (.ph, .fas, .wasm) a un ÚNICO archivo HTML autónomo:
// - Arquitectura Unificada: Escritorio (Workspace Padre <main> + Ventanas Hijas flotantes)
//   vs Móvil (Snap 100% al Viewport + Pestañas de Navegación)
// - Zero-GC a 90-120 FPS
// - Zero-CORS en file:/// (Doble clic directo sin servidor local)
// - PWA Ready (Service Worker embebido en Blob + Manifest Data URI)
// ============================================================================

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const C = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  dim: '\x1b[2m',
  cyan: '\x1b[36m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  red: '\x1b[31m'
};

function printBanner() {
  console.log(`
${C.cyan}${C.bright}===================================================================${C.reset}
${C.cyan}${C.bright}   PHASORLANG UNIVERSAL BUNDLER — KORADEVS ECOSYSTEM             ${C.reset}
${C.dim}   Arquitectura Unificada Multi-Dispositivo & Multi-Ventana (120 FPS)  ${C.reset}
${C.cyan}${C.bright}===================================================================${C.reset}
`);
}

function printHelp() {
  printBanner();
  console.log(`
${C.bright}USO:${C.reset}
  phasor bundle [archivo.ph | archivo.fas | archivo.wasm] [salida.html] [opciones]
  node tools/phasor_bundler.js [archivo] [salida.html] [opciones]

${C.bright}ARGUMENTOS:${C.reset}
  ${C.green}archivo${C.reset}        Código fuente (.ph, .fas) o binario WebAssembly (.wasm).
                 Si se omite, se busca en 'phasor.toml' o 'main.fas' / 'main.ph'.
  ${C.green}salida.html${C.reset}    Nombre del archivo HTML resultante (por defecto: dist/<nombre>.html).

${C.bright}OPCIONES:${C.reset}
  ${C.yellow}--title <nombre>${C.reset}    Título de la aplicación / workspace.
  ${C.yellow}--out, -o <ruta>${C.reset}    Ruta de salida específica.
  ${C.yellow}--pwa${C.reset}              Habilita registro de Service Worker PWA (activo por defecto).
  ${C.yellow}--no-pwa${C.reset}           Deshabilita Service Worker PWA.
  ${C.yellow}--hud${C.reset}              Muestra el HUD de telemetría de rendimiento al iniciar.
  ${C.yellow}--help, -h${C.reset}         Muestra esta pantalla de ayuda.

${C.bright}EJEMPLOS:${C.reset}
  phasor bundle samples/calculadora.fas dist/calculadora.html --title "Calculadora Fasorial"
  phasor bundle samples/demo_koradevs_master.fas dist/demo_koradevs_master.html
  phasor bundle samples/phasor_ide.ph dist/chronos_ide.html
`);
}

function parseArgs(args) {
  const options = {
    input: null,
    output: null,
    title: null,
    pwa: true,
    showHud: false,
    help: false
  };

  const positional = [];

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];

    if (arg === '--help' || arg === '-h') {
      options.help = true;
    } else if (arg === '--hud') {
      options.showHud = true;
    } else if (arg === '--pwa') {
      options.pwa = true;
    } else if (arg === '--no-pwa') {
      options.pwa = false;
    } else if (arg === '--title' && i + 1 < args.length) {
      options.title = args[++i];
    } else if ((arg === '--out' || arg === '-o') && i + 1 < args.length) {
      options.output = args[++i];
    } else if (!arg.startsWith('-')) {
      positional.push(arg);
    }
  }

  if (positional.length > 0) options.input = positional[0];
  if (positional.length > 1 && !options.output) options.output = positional[1];

  return options;
}

function resolveInputFile(inputCandidate, rootDir) {
  if (inputCandidate) {
    const fullPath = path.isAbsolute(inputCandidate)
      ? inputCandidate
      : path.resolve(rootDir, inputCandidate);

    if (fs.existsSync(fullPath)) {
      const stat = fs.statSync(fullPath);
      if (stat.isFile()) return fullPath;
      if (stat.isDirectory()) return resolveInputFile(null, fullPath);
    }
    for (const ext of ['.ph', '.fas', '.wasm']) {
      const candidateWithExt = fullPath + ext;
      if (fs.existsSync(candidateWithExt)) return candidateWithExt;
    }
    throw new Error(`Archivo no encontrado: ${inputCandidate}`);
  }

  const tomlPath = path.resolve(rootDir, 'phasor.toml');
  if (fs.existsSync(tomlPath)) {
    try {
      const tomlContent = fs.readFileSync(tomlPath, 'utf8');
      const match = tomlContent.match(/entry\s*=\s*["']([^"']+)["']/);
      if (match && match[1]) {
        const entryPath = path.resolve(rootDir, match[1]);
        if (fs.existsSync(entryPath)) return entryPath;
      }
    } catch (e) {}
  }

  const defaults = ['main.fas', 'main.ph', 'samples/calculadora.fas', 'samples/demo_koradevs_master.fas'];
  for (const def of defaults) {
    const p = path.resolve(rootDir, def);
    if (fs.existsSync(p)) return p;
  }

  throw new Error('No se pudo encontrar un archivo de entrada válido (.ph, .fas, .wasm).');
}

function getFaviconSvgDataUri() {
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
    <rect width="64" height="64" rx="14" fill="#0B0E14"/>
    <circle cx="32" cy="32" r="24" fill="none" stroke="#30363D" stroke-width="2"/>
    <circle cx="32" cy="32" r="16" fill="none" stroke="#238636" stroke-width="1.5" stroke-dasharray="3,3"/>
    <line x1="32" y1="32" x2="48" y2="20" stroke="#58A6FF" stroke-width="3" stroke-linecap="round"/>
    <circle cx="48" cy="20" r="4.5" fill="#58A6FF"/>
    <circle cx="32" cy="32" r="4" fill="#3FB950"/>
  </svg>`;
  return 'data:image/svg+xml;base64,' + Buffer.from(svg).toString('base64');
}

function compile(sourceFile, target, rootDir) {
  const jarPath = path.resolve(rootDir, 'phasor.jar');
  if (!fs.existsSync(jarPath)) {
    throw new Error(`Compilador no encontrado: ${jarPath}`);
  }
  const cmd = `java -jar "${jarPath}" build "${sourceFile}" --target=${target}`;
  try {
    const output = execSync(cmd, { cwd: rootDir, encoding: 'utf8', stdio: 'pipe' });
    return output;
  } catch (err) {
    if (err.stdout) console.log(err.stdout);
    if (err.stderr) console.error(err.stderr);
    throw new Error(`Error durante compilación (${target}): ${err.message}`);
  }
}

/**
 * Empaqueta cualquier código PhasorLang en la arquitectura universal multi-ventana
 */
function bundleUnified(inputFile, options, rootDir) {
  const baseName = path.basename(inputFile, path.extname(inputFile));
  console.log(`> [Compilador] Compilando ${baseName} con canalización unificada...`);

  const ext = path.extname(inputFile).toLowerCase();
  let wasmB64 = '';
  let bytecodeStr = '[]';
  let constPoolStr = '[]';
  let screenRoutesStr = '{}';
  let actionRoutesStr = '{}';
  let stringsStr = '[]';
  let firstScreenPc = '0';

  function extractJsValue(html, varName) {
    const marker = new RegExp('(?:const|let|var)\\s+' + varName + '\\s*=\\s*');
    const match = html.match(marker);
    if (!match) return null;
    const startIdx = match.index + match[0].length;
    const firstChar = html[startIdx];
    if (firstChar === '[' || firstChar === '{') {
      const closeChar = firstChar === '[' ? ']' : '}';
      let depth = 0;
      let inStr = false;
      let quote = '';
      for (let i = startIdx; i < html.length; i++) {
        const c = html[i];
        if (inStr) {
          if (c === '\\') { i++; continue; }
          if (c === quote) inStr = false;
        } else {
          if (c === '"' || c === "'") {
            inStr = true;
            quote = c;
          } else if (c === firstChar) {
            depth++;
          } else if (c === closeChar) {
            depth--;
            if (depth === 0) {
              return html.substring(startIdx, i + 1);
            }
          }
        }
      }
    }
    const semiIdx = html.indexOf(';', startIdx);
    if (semiIdx !== -1) {
      return html.substring(startIdx, semiIdx).trim();
    }
    return null;
  }

  if (ext === '.wasm') {
    const wasmBuffer = fs.readFileSync(inputFile);
    wasmB64 = wasmBuffer.toString('base64');
  } else {
    // 1. Compilar con --target=web para extraer bytecode y rutas UI
    try {
      compile(inputFile, 'web', rootDir);
      const rawHtmlPath = path.resolve(rootDir, `${baseName}.html`);
      if (fs.existsSync(rawHtmlPath)) {
        const rawHtml = fs.readFileSync(rawHtmlPath, 'utf8');
        const wasmMatch = rawHtml.match(/const WASM_B64\s*=\s*"([^"]+)";/);
        if (wasmMatch) wasmB64 = wasmMatch[1];

        const bc = extractJsValue(rawHtml, 'BYTECODE');
        if (bc) bytecodeStr = bc;

        const cp = extractJsValue(rawHtml, 'CONST_POOL');
        if (cp) constPoolStr = cp;

        const sr = extractJsValue(rawHtml, 'SCREEN_ROUTES');
        if (sr) screenRoutesStr = sr;

        const ar = extractJsValue(rawHtml, 'ACTION_ROUTES');
        if (ar) actionRoutesStr = ar;

        const st = extractJsValue(rawHtml, 'STRINGS');
        if (st) stringsStr = st;

        const fsPc = extractJsValue(rawHtml, 'FIRST_SCREEN_PC');
        if (fsPc) firstScreenPc = fsPc;

        // Limpiar archivo temporal de compilación
        if (rawHtmlPath !== options.output) {
          try { fs.unlinkSync(rawHtmlPath); } catch (e) {}
        }
      }
    } catch (err) {
      console.warn(`[Compilación Web]: ${err.message}. Intentando fallback WASM directo...`);
      compile(inputFile, 'wasm', rootDir);
      const wasmPath = path.resolve(rootDir, `${baseName}.wasm`);
      if (fs.existsSync(wasmPath)) {
        wasmB64 = fs.readFileSync(wasmPath).toString('base64');
      }
    }
  }

  // 2. Cargar runtime unificado
  let runtimePath = path.resolve(rootDir, 'phasor_runtime.js');
  if (!fs.existsSync(runtimePath)) {
    runtimePath = path.resolve(rootDir, 'dist', 'phasor_runtime.js');
  }
  const runtimeCode = fs.readFileSync(runtimePath, 'utf8');

  // 3. Determinar títulos y ventanas configuradas
  const appTitle = options.title || (
    baseName === 'calculadora' ? 'Calculadora Fasorial' :
    baseName === 'demo_koradevs_master' ? 'Demostrador Maestro KoraDevs' :
    baseName.includes('graficadora') ? 'Calculadora Gráfica Fasorial' :
    baseName.includes('ide') ? 'Chronos IDE & Phasor Workspace' :
    `PhasorLang — ${baseName.toUpperCase()}`
  );

  let childrenConfig = [];
  let screenPcs = [];
  try {
    const routesObj = JSON.parse(screenRoutesStr);
    screenPcs = Object.values(routesObj).sort((a, b) => a - b);
  } catch(e) {}

  if (baseName.includes('ide')) {
    let routesObj = {};
    try { routesObj = JSON.parse(screenRoutesStr); } catch(e) {}
    const pcExplorer = routesObj['1794020195'] !== undefined ? routesObj['1794020195'] : 13391;
    const pcEditor   = routesObj['1352261553'] !== undefined ? routesObj['1352261553'] : 16194;
    const pcPreview  = routesObj['1257924439'] !== undefined ? routesObj['1257924439'] : 13136;
    const pcDebugger = routesObj['131570255']  !== undefined ? routesObj['131570255']  : 17058;
    const pcTerminal = routesObj['1691167414'] !== undefined ? routesObj['1691167414'] : 17319;
    const pcAi       = routesObj['554250084']  !== undefined ? routesObj['554250084']  : 17523;

    childrenConfig = [
      { id: 1, title: '<s>1: Explorador de Archivos', type: 'explorer', x: 40, y: 60, w: 460, h: 620, contentW: 460, contentH: 588, color: '#090D13', screenPc: pcExplorer, visible: true, minimized: false },
      { id: 2, title: '<s>2: Editor & Docs PhasorLang', type: 'editor', x: 530, y: 60, w: 660, h: 620, contentW: 660, contentH: 588, color: '#0D1117', screenPc: pcEditor, visible: true, minimized: false },
      { id: 3, title: '<s>3: Live Preview & Canvas (120 FPS)', type: 'preview', x: 1220, y: 60, w: 560, h: 620, contentW: 560, contentH: 588, color: '#070B12', screenPc: pcPreview, visible: true, minimized: false },
      { id: 4, title: '<s>4: Depurador PVM & Memoria SoA', type: 'debug', x: 1810, y: 60, w: 540, h: 620, contentW: 540, contentH: 588, color: '#0B0E14', screenPc: pcDebugger, visible: true, minimized: false },
      { id: 5, title: '<s>5: Terminal Interactiva PVM CLI', type: 'terminal', x: 2380, y: 60, w: 540, h: 620, contentW: 540, contentH: 588, color: '#080B10', screenPc: pcTerminal, visible: true, minimized: false },
      { id: 6, title: '<s>6: Asistente IA KoraDevs Copilot', type: 'ai', x: 2950, y: 60, w: 540, h: 620, contentW: 540, contentH: 588, color: '#111620', screenPc: pcAi, visible: true, minimized: false }
    ];
  } else if (baseName.includes('graficadora') || (screenPcs.length >= 3 && !baseName.includes('ide'))) {
    childrenConfig = [
      { id: 1, title: '<s>1: Ecuaciones & Parámetros', x: 24, y: 50, w: 370, h: 560, contentW: 370, contentH: 520, color: '#161B22', screenPc: screenPcs[0] !== undefined ? screenPcs[0] : 0 },
      { id: 2, title: '<s>2: Lienzo Gráfico Cartesiano & Polar', x: 410, y: 50, w: 580, h: 560, contentW: 580, contentH: 520, color: '#070B12', screenPc: screenPcs[1] !== undefined ? screenPcs[1] : 0 },
      { id: 3, title: '<s>3: Teclado Científico & Presets', x: 1006, y: 50, w: 310, h: 560, contentW: 310, contentH: 520, color: '#161B22', screenPc: screenPcs[2] !== undefined ? screenPcs[2] : 0 }
    ];
  } else if (baseName === 'calculadora') {
    childrenConfig = [
      { id: 1, title: '<s>1: Calculadora Fasorial (Zero-GC)', x: 60, y: 50, w: 460, h: 560, contentW: 460, contentH: 520, color: '#161B22', screenPc: screenPcs[0] || 0 }
    ];
  } else if (baseName === 'demo_koradevs_master') {
    childrenConfig = [
      { id: 1, title: '<s>1: Demostrador Maestro KoraDevs', x: 50, y: 50, w: 480, h: 580, contentW: 480, contentH: 540, color: '#161B22', screenPc: screenPcs[0] || 0 }
    ];
  } else {
    childrenConfig = [
      { id: 1, title: '<s>1: ' + appTitle, x: 60, y: 50, w: 460, h: 560, contentW: 460, contentH: 520, color: '#161B22', screenPc: screenPcs[0] || 0 }
    ];
  }

  const childrenJson = JSON.stringify(childrenConfig);
  const faviconUri = getFaviconSvgDataUri();

  // 4. Construir HTML Standalone 100% Autocontenido
  return `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
  <meta name="theme-color" content="#0b0e14">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <title>${appTitle}</title>
  <link rel="icon" type="image/svg+xml" href="${faviconUri}">
  <link rel="manifest" href="data:application/manifest+json,${encodeURIComponent(JSON.stringify({
    name: appTitle,
    short_name: baseName,
    start_url: '.',
    display: 'standalone',
    background_color: '#0b0e14',
    theme_color: '#0b0e14'
  }))}">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; user-select: none; -webkit-tap-highlight-color: transparent; }
    html, body { width: 100vw; height: 100vh; overflow: hidden; background: #0b0e14; touch-action: none; font-family: monospace; }
    #phasorCanvas { width: 100vw; height: 100vh; display: block; outline: none; }
  </style>
</head>
<body>
  <canvas id="phasorCanvas" tabindex="1"></canvas>
  <script>
${runtimeCode}
  </script>
  <script>
    (function() {
      ${options.pwa ? `if ('serviceWorker' in navigator && location.protocol.indexOf('http') === 0) {
        try {
          var swBlob = new Blob(["self.addEventListener('install',e=>self.skipWaiting());self.addEventListener('activate',e=>e.waitUntil(clients.claim()));"], { type: 'application/javascript' });
          navigator.serviceWorker.register(URL.createObjectURL(swBlob)).catch(()=>{});
        } catch(e) {}
      }` : ''}

      var WASM_PAYLOAD = "${wasmB64}";
      var BYTECODE = ${bytecodeStr};
      var CONST_POOL = ${constPoolStr};
      var SCREEN_ROUTES = ${screenRoutesStr};
      var ACTION_ROUTES = ${actionRoutesStr};
      var STRINGS = ${stringsStr};
      var FIRST_SCREEN_PC = ${firstScreenPc};
      var CHILDREN = ${childrenJson};

      window.addEventListener('DOMContentLoaded', function() {
        if (typeof PhasorRuntime !== 'undefined' && typeof PhasorRuntime.init === 'function') {
          PhasorRuntime.init(WASM_PAYLOAD, 'phasorCanvas', {
            title: "${appTitle}",
            appName: "${baseName}",
            showHud: ${options.showHud ? 'true' : 'false'},
            bytecode: BYTECODE,
            constPool: CONST_POOL,
            screenRoutes: SCREEN_ROUTES,
            actionRoutes: ACTION_ROUTES,
            strings: STRINGS,
            firstScreenPc: FIRST_SCREEN_PC,
            children: CHILDREN
          });
        }
      });
    })();
  </script>
</body>
</html>`;
}

function bundle(cliArgs = process.argv.slice(2)) {
  const rootDir = path.resolve(__dirname, '..');
  const options = parseArgs(cliArgs);

  if (options.help) {
    printHelp();
    return;
  }

  printBanner();

  const inputFile = resolveInputFile(options.input, rootDir);
  const baseName = path.basename(inputFile, path.extname(inputFile));
  console.log(`> [1/3] Entrada detectada : ${C.green}${inputFile}${C.reset}`);

  // Salida
  let outputPath = options.output;
  if (!outputPath) {
    const distDir = path.resolve(rootDir, 'dist');
    if (!fs.existsSync(distDir)) fs.mkdirSync(distDir, { recursive: true });
    outputPath = path.resolve(distDir, `${baseName}.html`);
  } else if (!path.isAbsolute(outputPath)) {
    outputPath = path.resolve(rootDir, outputPath);
  }

  const targetDir = path.dirname(outputPath);
  if (!fs.existsSync(targetDir)) fs.mkdirSync(targetDir, { recursive: true });

  console.log(`> [2/3] Generando paquete autónomo multi-ventana...`);
  const htmlContent = bundleUnified(inputFile, options, rootDir);

  fs.writeFileSync(outputPath, htmlContent, 'utf8');
  const stat = fs.statSync(outputPath);

  console.log(`> [3/3] Aplicativo standalone generado con éxito:
  ${C.green}${C.bright}${outputPath}${C.reset}
  Tamaño Total     : ${C.yellow}${stat.size.toLocaleString()} bytes${C.reset} (~${(stat.size / 1024).toFixed(1)} KB)
  Arquitectura     : Unificada (Escritorio Docking + Móvil Snap 100%)
  Invariante       : Zero-GC a 90-120 FPS | Standalone file:/// sin servidor HTTP
`);

  console.log(`${C.cyan}Para abrir directamente en tu navegador:${C.reset}`);
  console.log(`  file:///${outputPath.replace(/\\/g, '/')}\n`);

  return outputPath;
}

if (require.main === module) {
  try {
    bundle();
  } catch (err) {
    console.error(`\n${C.red}${C.bright}[Error en Bundler]${C.reset} ${err.message}\n`);
    process.exit(1);
  }
}

module.exports = { bundle, parseArgs };
