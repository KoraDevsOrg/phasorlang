const fs = require('fs');
const html = fs.readFileSync('dist/chronos_ide.html', 'utf8');
const codeMatch = html.match(/<phasorcode[^>]*>([\s\S]*?)<\/phasorcode>/);
const json = JSON.parse(codeMatch[1]);

console.log('Bytecode 11520 to 11545:');
for (let i = 11520; i <= 11545; i++) {
  let ins = json.bytecode[i];
  let op = (ins >>> 24) & 0xFF;
  let dst = (ins >>> 16) & 0xFF;
  let s1 = (ins >>> 8) & 0xFF;
  let s2 = ins & 0xFF;
  console.log(i + ': op=0x' + op.toString(16).padStart(2, '0') + ' dst=' + dst + ' s1=' + s1 + ' s2=' + s2 + ' (raw=0x' + (ins>>>0).toString(16) + ')');
}
