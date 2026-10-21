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

vm.rScalar[250] = 800; // width
vm.rScalar[251] = 600; // height

// Frame 1: Init at rest
vm.rScalar[252] = 0; vm.rScalar[253] = 0; vm.rScalar[254] = 0;
vm.run(payload.firstScreenPc, 800, 600);
console.log('Frame 1 initial rendered, cmds:', vm.uiCmds.length / 6);

// TEST 1: Click empty space (600, 400) and drag to (650, 420)
// Step A: Mouse down at (600, 400)
vm.rScalar[252] = 600; vm.rScalar[253] = 400; vm.rScalar[254] = 1;
vm.run(payload.firstScreenPc, 800, 600);
// Step B: Drag to (650, 420)
vm.rScalar[252] = 650; vm.rScalar[253] = 420; vm.rScalar[254] = 1;
vm.run(payload.firstScreenPc, 800, 600);

let texts = vm.texts;
console.log('After background pan, window text pos:', texts[0]);

// Step C: Mouse release
vm.rScalar[254] = 0;
vm.run(payload.firstScreenPc, 800, 600);

// TEST 2: Click on window title bar (at texts[0].x, texts[0].y) and drag
const titleX = texts[0].x;
const titleY = texts[0].y;
console.log(`Clicking window title bar at (${titleX}, ${titleY})...`);

vm.rScalar[252] = titleX; vm.rScalar[253] = titleY; vm.rScalar[254] = 1;
vm.run(payload.firstScreenPc, 800, 600);

// Drag by +100px X, +50px Y
vm.rScalar[252] = titleX + 100; vm.rScalar[253] = titleY + 50; vm.rScalar[254] = 1;
vm.run(payload.firstScreenPc, 800, 600);

console.log('After window drag, window text pos:', vm.texts[0]);

if (Math.abs(vm.texts[0].x - (titleX + 100)) < 2 && Math.abs(vm.texts[0].y - (titleY + 50)) < 2) {
    console.log('>>> TEST PASSED: Window moved exactly by +100, +50 with the mouse! <<<');
} else {
    console.error('>>> TEST FAILED: Window did not move expected amount! <<<');
}
