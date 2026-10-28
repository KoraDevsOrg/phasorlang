const fs = require('fs');

global.window = global;
const runtimeCode = fs.readFileSync('phasor_runtime.js', 'utf8');
eval(runtimeCode);

const html = fs.readFileSync('dist/chronos_ide.html', 'utf8');
const codeMatch = html.match(/<phasorcode[^>]*>([\s\S]*?)<\/phasorcode>/);
const json = JSON.parse(codeMatch[1]);

const vm = new global.MicroPhasorVM(json.bytecode, json.const_pool, json.strings);

vm.rScalar[250] = 1366; // sw
vm.rScalar[251] = 607;  // sh
vm.rScalar[252] = 839;  // mx
vm.rScalar[253] = 223.5;// my
vm.rScalar[254] = 1.0;  // pd
vm.rScalar[255] = 0;    // wh_y
vm.rScalar[247] = 0;    // wh_x

let firstPc = json.first_screen_pc || 0;
vm.run(firstPc, 1366, 607);

console.log('After frame 1:');
console.log('sb_win (R51):', vm.rScalar[51]);
console.log('sb_axis (R52):', vm.rScalar[52]);
console.log('sb_grab (R53):', vm.rScalar[53]);
console.log('sb_scan_hit (R56):', vm.rScalar[56]);
console.log('resize_target_win (R43):', vm.rScalar[43]);
console.log('drag_target_win (R40):', vm.rScalar[40]);
console.log('R229 (cursor):', vm.rScalar[229]);
