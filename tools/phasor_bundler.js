const fs = require('fs');
const path = require('path');

function resolveImports(entryFile, visited = new Set()) {
  const absPath = path.resolve(entryFile);
  if (visited.has(absPath)) return '';
  visited.add(absPath);

  if (!fs.existsSync(absPath)) {
    console.warn(`⚠️ Import no encontrado: ${entryFile}`);
    return `// Import no encontrado: ${entryFile}\n`;
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
      out.push(`// >>> BEGIN IMPORT: ${relImport}`);
      out.push(resolveImports(target, visited));
      out.push(`// <<< END IMPORT: ${relImport}`);
    } else {
      out.push(line);
    }
  }
  return out.join('\n');
}

function bundlePhasor(inputPath, outputPath) {
  if (!fs.existsSync(inputPath)) {
    console.error(`Error: Archivo de entrada no encontrado: ${inputPath}`);
    process.exit(1);
  }

  const combinedSource = resolveImports(inputPath);
  const runtimePath = path.join(__dirname, '../runtime/phasor_runtime.js');
  const runtimeCode = fs.existsSync(runtimePath)
    ? fs.readFileSync(runtimePath, 'utf8')
    : '';

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
  <script type="text/phasor" id="source">
${combinedSource}
  </script>
  <script>
${runtimeCode}
  </script>
  <script>
    (function bootPhasorStandalone() {
      var canvas = document.getElementById('phasorCanvas');
      var srcEl = document.getElementById('source');
      var src = srcEl ? srcEl.textContent : '';

      function syncSize() {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
      }
      syncSize();
      window.addEventListener('resize', syncSize);

      if (typeof PhasorRuntime === 'function') {
        var rt = new PhasorRuntime(canvas, src, []);
        if (typeof rt.start === 'function') rt.start();
      } else if (window.PhasorWebRuntime && typeof window.PhasorWebRuntime.boot === 'function') {
        window.PhasorWebRuntime.boot(canvas, src);
      }
    })();
  </script>
</body>
</html>`;

  const outDir = path.dirname(outputPath);
  if (outDir && !fs.existsSync(outDir)) {
    fs.mkdirSync(outDir, { recursive: true });
  }
  fs.writeFileSync(outputPath, htmlContent, 'utf8');
  console.log(`✔ Generado con éxito: ${outputPath} (${(Buffer.byteLength(htmlContent) / 1024).toFixed(1)} KB)`);
}

if (require.main === module) {
  const args = process.argv.slice(2);
  if (args.length < 2) {
    console.log('Uso: node tools/phasor_bundler.js <entrada.ph> <salida.html>');
    process.exit(1);
  }
  bundlePhasor(args[0], args[1]);
}

module.exports = { bundlePhasor, resolveImports };
