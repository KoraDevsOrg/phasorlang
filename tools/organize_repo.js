const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..');

console.log('=== KORADEVS REPOSITORY CLEANUP & ORGANIZATION ===');
console.log('Target Root:', rootDir);

// 1. Create target directories
const dirsToEnsure = ['bin', 'compiler', 'runtime', 'docs', 'dist'];
dirsToEnsure.forEach(d => {
  const full = path.join(rootDir, d);
  if (!fs.existsSync(full)) {
    fs.mkdirSync(full, { recursive: true });
    console.log('[+] Creado directorio:', d);
  }
});

// 2. Sync CLI scripts to bin/
const cliFiles = ['phasor', 'phasor.bat', 'phasor-bundle', 'phasor-bundle.bat'];
cliFiles.forEach(f => {
  const src = path.join(rootDir, f);
  const dest = path.join(rootDir, 'bin', f);
  if (fs.existsSync(src)) {
    fs.copyFileSync(src, dest);
    console.log('[+] Sincronizado a bin/:', f);
  }
});

// 3. Sync compiler and runtime
const jarSrc = path.join(rootDir, 'phasor.jar');
const jarDest = path.join(rootDir, 'compiler', 'phasor.jar');
if (fs.existsSync(jarSrc)) {
  fs.copyFileSync(jarSrc, jarDest);
  console.log('[+] Sincronizado a compiler/: phasor.jar');
}

const runtimeSrc = path.join(rootDir, 'phasor_runtime.js');
const runtimeDest = path.join(rootDir, 'runtime', 'phasor_runtime.js');
if (fs.existsSync(runtimeSrc)) {
  fs.copyFileSync(runtimeSrc, runtimeDest);
  console.log('[+] Sincronizado a runtime/: phasor_runtime.js');
}

// 4. Move root build artifacts to dist/
const rootArtifacts = [
  '03_test_ui_responsive.html',
  '03_test_ui_responsive.wasm',
  'calculadora.wasm',
  'demo_koradevs_master.wasm',
  'main.html',
  'main.wasm',
  'phasor_ide.html',
  'phasor_ide.wasm'
];

rootArtifacts.forEach(f => {
  const src = path.join(rootDir, f);
  const dest = path.join(rootDir, 'dist', f);
  if (fs.existsSync(src)) {
    try {
      fs.copyFileSync(src, dest);
      fs.unlinkSync(src);
      console.log('[>] Movido a dist/:', f);
    } catch (e) {
      console.warn('[-] Error moviendo:', f, e.message);
    }
  }
});

// 5. Remove legacy Sketchware Pro & Syncthing folders
const legacyDirs = [
  'collection',
  'mysc',
  'logcat',
  'backups',
  'bak',
  '.stfolder',
  '.stversions'
];

legacyDirs.forEach(d => {
  const full = path.join(rootDir, d);
  if (fs.existsSync(full)) {
    try {
      fs.rmSync(full, { recursive: true, force: true });
      console.log('[-] Eliminado directorio legacy:', d);
    } catch (e) {
      console.warn('[-] No se pudo eliminar:', d, e.message);
    }
  }
});

// Remove any .stfolder.removed*
fs.readdirSync(rootDir).forEach(item => {
  if (item.startsWith('.stfolder.removed') || item.startsWith('debug.sync-conflict')) {
    const full = path.join(rootDir, item);
    try {
      if (fs.statSync(full).isDirectory()) {
        fs.rmSync(full, { recursive: true, force: true });
      } else {
        fs.unlinkSync(full);
      }
      console.log('[-] Eliminado archivo/carpeta de sincronización:', item);
    } catch(e) {}
  }
  if (item === 'debug.txt' || item === 'dataset_phasor.jsonl') {
    const full = path.join(rootDir, item);
    try {
      fs.unlinkSync(full);
      console.log('[-] Eliminado temporal:', item);
    } catch(e) {}
  }
});

console.log('=== ORGANIZACIÓN COMPLETADA CON ÉXITO ===');
