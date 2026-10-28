const fs = require('fs');

const html = fs.readFileSync('dist/chronos_ide.html', 'utf8');
const codeMatch = html.match(/<phasorcode[^>]*>([\s\S]*?)<\/phasorcode>/);
const json = JSON.parse(codeMatch[1]);

console.log('Strings count:', json.strings.length);
console.log('Bytecode length:', json.bytecode.length);
console.log('Const pool length:', json.const_pool.length);
