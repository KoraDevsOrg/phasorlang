const fs = require('fs');
const html = fs.readFileSync('dist/test_hito1.html', 'utf8');

const match = html.match(/<phasorcode[^>]*>([\s\S]*?)<\/phasorcode>/);
if (!match) {
    console.error('No phasorcode tag found in test_hito1.html');
    process.exit(1);
}

const payload = JSON.parse(match[1]);
console.log('Bytecode length:', payload.bytecode.length);
console.log('Strings:', payload.strings);
console.log('Const pool length:', payload.constPool.length);

const runtimeCode = fs.readFileSync('phasor_runtime.js', 'utf8');
const runInGlobal = new Function('window', runtimeCode);
const fakeWindow = {};
runInGlobal(fakeWindow);
const vm = new fakeWindow.MicroPhasorVM(payload.bytecode, payload.constPool, payload.strings);

// Run boot pass
vm.run(0);

// Set viewport inputs
vm.rScalar[250] = 800.0;
vm.rScalar[251] = 600.0;
vm.rScalar[252] = 100.0;
vm.rScalar[253] = 100.0;
vm.rScalar[254] = 0.0;
vm.rScalar[255] = 0.0;

// Run 3 frames of main screen
for (let frame = 1; frame <= 3; frame++) {
    vm.run(payload.firstScreenPc, 800, 600);
    const cmds = vm.uiCmds;
    console.log(`Frame ${frame} commands generated: ${cmds.length / 6}`);
    if (frame === 1) {
        console.log('UI texts generated:', vm.texts.length);
        console.log('Sample texts:', vm.texts);
    }
}
console.log('SUCCESS! Zero crashes, zero PC overflow.');
