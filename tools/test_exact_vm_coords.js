const fs = require('fs');
global.window = global;
eval(fs.readFileSync('phasor_runtime.js', 'utf8'));
const html = fs.readFileSync('dist/chronos_ide.html', 'utf8');
const json = JSON.parse(html.match(/<phasorcode[^>]*>([\s\S]*?)<\/phasorcode>/)[1]);
const vm = new global.MicroPhasorVM(json.bytecode, json.constPool, json.strings);

vm.rScalar[250] = 1366;
vm.rScalar[251] = 607;
vm.rScalar[252] = 839;
vm.rScalar[253] = 223.5;
vm.rScalar[254] = 0.0; // let's first run 1 frame with pd=0 to initialize signals
vm.run(json.firstScreenPc, 1366, 607);

console.log('Frame 0 (init):');
console.log('s1_x (R15):', vm.rScalar[15]);
console.log('s1_y (R16):', vm.rScalar[16]);
console.log('s1_w (R17):', vm.rScalar[17]);
console.log('s1_h (R18):', vm.rScalar[18]);
console.log('spatial_pan_x (R1):', vm.rScalar[1]);
console.log('spatial_pan_y (R2):', vm.rScalar[2]);

// Now frame 1 with pd=1.0 at mx=839, my=223.5:
// But where is Screen 1 on screen?
let s1_x = vm.rScalar[15];
let s1_w = vm.rScalar[17];
let pan_x = vm.rScalar[1];
let hx = s1_x + pan_x + (1366 / 2);
console.log('hx should be:', hx, 'right edge (hx+w):', hx + s1_w);

// Let's test click at hx + s1_w - 4:
let test_mx = hx + s1_w - 4;
let test_my = vm.rScalar[16] + vm.rScalar[2] + (607 / 2) + 100;
console.log('Testing at mx=', test_mx, 'my=', test_my);

vm.rScalar[252] = test_mx;
vm.rScalar[253] = test_my;
vm.rScalar[254] = 1.0;
vm.run(json.firstScreenPc, 1366, 607);

console.log('After click:');
console.log('sb_win (R51):', vm.rScalar[51]);
console.log('sb_axis (R52):', vm.rScalar[52]);
console.log('sb_scan_hit (R56):', vm.rScalar[56]);
console.log('cursor (R229):', vm.rScalar[229]);
