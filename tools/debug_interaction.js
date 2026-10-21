const fs = require('fs');
const html = fs.readFileSync('dist/test_interactive.html', 'utf8');

const match = html.match(/<phasorcode[^>]*>([\s\S]*?)<\/phasorcode>/);
const payload = JSON.parse(match[1]);

const runtimeCode = fs.readFileSync('phasor_runtime.js', 'utf8');
const runInGlobal = new Function('window', runtimeCode);
const fakeWindow = {};
runInGlobal(fakeWindow);

const vm = new fakeWindow.MicroPhasorVM(payload.bytecode, payload.constPool, payload.strings);
vm.run(0);

// Print signals / registers
console.log('Signals before run:');
// Let's run frame 1
vm.run(payload.firstScreenPc, 800, 600);
console.log('Frame 1 done. rScalar[0..10]:', vm.rScalar.slice(0, 10));

// Step A: Mouse down at (600, 400)
vm.rScalar[252] = 600; vm.rScalar[253] = 400; vm.rScalar[254] = 1;
vm.run(payload.firstScreenPc, 800, 600);
console.log('Step A done. rScalar[0..10]:', vm.rScalar.slice(0, 10));

// Step B: Drag to (650, 420)
vm.rScalar[252] = 650; vm.rScalar[253] = 420; vm.rScalar[254] = 1;
vm.run(payload.firstScreenPc, 800, 600);
console.log('Step B done. rScalar[0..10]:', vm.rScalar.slice(0, 10));
console.log('Texts:', vm.texts);
