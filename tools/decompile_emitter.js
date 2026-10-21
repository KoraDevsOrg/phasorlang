const { execSync } = require('child_process');
const out = execSync('javap -c -p com.chronosIDE.BytecodeEmitter', { encoding: 'utf8', maxBuffer: 10 * 1024 * 1024 });
const lines = out.split('\n');
for (let i = 0; i < lines.length; i++) {
  if (lines[i].includes('putfield') && lines[i].includes('nextReg')) {
    let s = Math.max(0, i - 10);
    let e = Math.min(lines.length, i + 5);
    console.log(lines.slice(s, e).join('\n'));
    console.log('-----------------------------------');
  }
}
