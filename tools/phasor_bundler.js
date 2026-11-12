const fs = require('fs');
const path = require('path');

function bundlePhasor(inputPath, outputPath) {
  if (!fs.existsSync(inputPath)) {
    console.error(`Error: Archivo de entrada no encontrado: ${inputPath}`);
    process.exit(1);
  }

  const phasorCode = fs.readFileSync(inputPath, 'utf8');
  const runtimePath = path.join(__dirname, '../runtime/phasor_runtime.js');
  
  let runtimeCode = '';
  if (fs.existsSync(runtimePath)) {
    runtimeCode = fs.readFileSync(runtimePath, 'utf8');
  } else {
    runtimeCode = `console.log("PhasorRuntime: inicializado en modo fallback");`;
  }

  const htmlContent = `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PhasorLang Runner</title>
  <style>
    body { margin: 0; background: #0f111a; color: #fff; font-family: sans-serif; display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100vh; }
    canvas { background: #000; border: 1px solid #333; box-shadow: 0 4px 20px rgba(0,0,0,0.6); }
    #log { margin-top: 10px; font-family: monospace; font-size: 13px; color: #88c0d0; }
  </style>
</head>
<body>
  <canvas id="phasorCanvas" width="640" height="480"></canvas>
  <div id="log">PhasorLang activo</div>
  <script>
${runtimeCode}
  </script>
  <script type="text/phasor" id="source">
${phasorCode}
  </script>
  <script>
    console.log("PhasorLang fuente cargado con éxito.");
  </script>
</body>
</html>`;

  const outputDir = path.dirname(outputPath);
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  fs.writeFileSync(outputPath, htmlContent, 'utf8');
  console.log(`✔ Generado con éxito: ${outputPath}`);
}

const args = process.argv.slice(2);
if (args.length < 2) {
  console.log("Uso: node tools/phasor_bundler.js <archivo.ph> <salida.html>");
  process.exit(1);
}

bundlePhasor(args[0], args[1]);
