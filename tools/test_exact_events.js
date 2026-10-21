const fs = require('fs');
const html = fs.readFileSync('dist/chronos_ide.html', 'utf8');
const match = html.match(/<phasorcode[^>]*>([\s\S]*?)<\/phasorcode>/);
const payload = JSON.parse(match[1]);

const runtimeCode = fs.readFileSync('phasor_runtime.js', 'utf8');
const runInGlobal = new Function('window', runtimeCode);
const fakeWindow = {};
runInGlobal(fakeWindow);

const vm = new fakeWindow.MicroPhasorVM(payload.bytecode, payload.constPool, payload.strings);
vm.run(0);

// Setup viewport
vm.rScalar[250] = 1280;
vm.rScalar[251] = 720;
vm.rScalar[252] = 0;
vm.rScalar[253] = 0;
vm.rScalar[254] = 0;
vm.rScalar[255] = 0;

// Frame 1: Initial state
vm.run(payload.firstScreenPc, 1280, 720);
const initialTexts = JSON.parse(JSON.stringify(vm.texts));
const s1_init_x = vm.rScalar[19]; // s1_x signal
const s1_init_y = vm.rScalar[20]; // s1_y signal
const pan_init_x = vm.rScalar[1];  // spatial_pan_x signal
const pan_init_y = vm.rScalar[2];  // spatial_pan_y signal

console.log(`Initial: s1=(${s1_init_x}, ${s1_init_y}), pan=(${pan_init_x}, ${pan_init_y})`);

// -------------------------------------------------------------------------------
// TEST 1: Moving mouse WITHOUT clicking (pd = 0.0) from (100, 100) to (500, 400)
// -------------------------------------------------------------------------------
console.log('\n--- TEST 1: Mouse movement without click (Hover) ---');
vm.rScalar[252] = 100; vm.rScalar[253] = 100; vm.rScalar[254] = 0;
vm.run(payload.firstScreenPc, 1280, 720);

vm.rScalar[252] = 300; vm.rScalar[253] = 250; vm.rScalar[254] = 0;
vm.run(payload.firstScreenPc, 1280, 720);

vm.rScalar[252] = 500; vm.rScalar[253] = 400; vm.rScalar[254] = 0;
vm.run(payload.firstScreenPc, 1280, 720);

const pan_hover_x = vm.rScalar[1];
const pan_hover_y = vm.rScalar[2];
console.log(`After Hover: pan=(${pan_hover_x}, ${pan_hover_y})`);

if (pan_hover_x === 0.0 && pan_hover_y === 0.0) {
    console.log('✔ PASS TEST 1: Background did NOT move during hover without click.');
} else {
    console.error('❌ FAIL TEST 1: Background moved during hover! pan_x=' + pan_hover_x);
}

// -------------------------------------------------------------------------------
// TEST 2: Dragging empty background with click held (pd = 1.0)
// -------------------------------------------------------------------------------
console.log('\n--- TEST 2: Dragging empty background with click held ---');
// Click down at empty area (700, 500)
vm.rScalar[252] = 700; vm.rScalar[253] = 500; vm.rScalar[254] = 1;
vm.run(payload.firstScreenPc, 1280, 720);

// Drag to (760, 530) (delta = +60, +30)
vm.rScalar[252] = 760; vm.rScalar[253] = 530; vm.rScalar[254] = 1;
vm.run(payload.firstScreenPc, 1280, 720);

const pan_drag_x = vm.rScalar[1];
const pan_drag_y = vm.rScalar[2];
console.log(`After Background Pan: pan=(${pan_drag_x}, ${pan_drag_y})`);

if (Math.abs(pan_drag_x - 60.0) < 1 && Math.abs(pan_drag_y - 30.0) < 1) {
    console.log('✔ PASS TEST 2: Background panned exactly by (+60, +30) when click is held.');
} else {
    console.error(`❌ FAIL TEST 2: Expected (+60, +30), got (${pan_drag_x}, ${pan_drag_y})`);
}

// Release click
vm.rScalar[254] = 0;
vm.run(payload.firstScreenPc, 1280, 720);

// -------------------------------------------------------------------------------
// TEST 3: Dragging window title bar
// -------------------------------------------------------------------------------
console.log('\n--- TEST 3: Dragging Window 1 title bar ---');
// Screen 1 in screen coordinates is at s1_world + pan
const s1_screen_x = vm.rScalar[19] + vm.rScalar[1];
const s1_screen_y = vm.rScalar[20] + vm.rScalar[2];
console.log(`Screen 1 current screen pos: (${s1_screen_x}, ${s1_screen_y})`);

// Click title bar (s1_screen_x + 50, s1_screen_y + 14)
const click_title_x = s1_screen_x + 50;
const click_title_y = s1_screen_y + 14;

vm.rScalar[252] = click_title_x; vm.rScalar[253] = click_title_y; vm.rScalar[254] = 1;
vm.run(payload.firstScreenPc, 1280, 720);

// Drag by +80, +50
vm.rScalar[252] = click_title_x + 80; vm.rScalar[253] = click_title_y + 50; vm.rScalar[254] = 1;
vm.run(payload.firstScreenPc, 1280, 720);

const s1_drag_screen_x = vm.rScalar[19] + vm.rScalar[1];
const s1_drag_screen_y = vm.rScalar[20] + vm.rScalar[2];
console.log(`Screen 1 after drag: (${s1_drag_screen_x}, ${s1_drag_screen_y})`);

if (Math.abs(s1_drag_screen_x - (s1_screen_x + 80)) < 2 && Math.abs(s1_drag_screen_y - (s1_screen_y + 50)) < 2) {
    console.log('✔ PASS TEST 3: Window moved exactly by (+80, +50) following mouse drag.');
} else {
    console.error(`❌ FAIL TEST 3: Window did not follow drag! Expected (${s1_screen_x + 80}, ${s1_screen_y + 50}), got (${s1_drag_screen_x}, ${s1_drag_screen_y})`);
}

// Release click
vm.rScalar[254] = 0;
vm.run(payload.firstScreenPc, 1280, 720);

// -------------------------------------------------------------------------------
// TEST 4: Clicking inside window body should NOT move window nor background
// -------------------------------------------------------------------------------
console.log('\n--- TEST 4: Clicking inside window body ---');
const body_click_x = s1_drag_screen_x + 100;
const body_click_y = s1_drag_screen_y + 100;
const pan_before_body = vm.rScalar[1];
const s1_before_body = vm.rScalar[19];

vm.rScalar[252] = body_click_x; vm.rScalar[253] = body_click_y; vm.rScalar[254] = 1;
vm.run(payload.firstScreenPc, 1280, 720);

vm.rScalar[252] = body_click_x + 40; vm.rScalar[253] = body_click_y + 40; vm.rScalar[254] = 1;
vm.run(payload.firstScreenPc, 1280, 720);

if (vm.rScalar[1] === pan_before_body && vm.rScalar[19] === s1_before_body) {
    console.log('✔ PASS TEST 4: Clicking inside window body did NOT move window or background.');
} else {
    console.error('❌ FAIL TEST 4: Body click erroneously moved something!');
}

console.log('\nALL 4 INTERACTION TESTS COMPLETE.');
