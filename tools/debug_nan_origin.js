const fs = require('fs');

global.window = global;
const runtimeCode = fs.readFileSync('phasor_runtime.js', 'utf8');
eval(runtimeCode);

const html = fs.readFileSync('dist/chronos_ide.html', 'utf8');
const codeMatch = html.match(/<phasorcode[^>]*>([\s\S]*?)<\/phasorcode>/);
const json = JSON.parse(codeMatch[1]);

const vm = new global.MicroPhasorVM(json.bytecode, json.const_pool, json.strings);

// Override run with stepping and NaN checking
const origRun = global.MicroPhasorVM.prototype.run;
global.MicroPhasorVM.prototype.run = function(startPc, vw, vh) {
    let pc = startPc || 0;
    this.rScalar[250] = vw; this.rScalar[251] = vh;
    let S = this.rScalar, CR = this.rCompReal, CI = this.rCompImag, IC = this.isComplex, VX = this.rVecX, VY = this.rVecY, VZ = this.rVecZ, IV = this.isVector3, H = this.heapVectors;
    let cyc = 0;
    
    while (pc < this.code.length && ++cyc < 1000000) {
        let curPc = pc;
        let ins = this.code[pc++], op = (ins >>> 24) & 0xFF, dst = (ins >>> 16) & 0xFF, s1 = (ins >>> 8) & 0xFF, s2 = ins & 0xFF;
        if (op === 0x00) continue;
        if (op === 0xFF) break;
        
        // Execute instruction
        if (op === 0x01) { S[dst] = this.consts[s1]; IC[dst] = IV[dst] = 0; }
        else if (op === 0x02) { S[dst] = S[s1]; CR[dst] = CR[s1]; CI[dst] = CI[s1]; IC[dst] = IC[s1]; VX[dst] = VX[s1]; VY[dst] = VY[s1]; VZ[dst] = VZ[s1]; IV[dst] = IV[s1]; }
        else if (op === 0x03 || op === 0x10) {
            S[dst] = S[s1] + S[s2]; IC[dst] = IV[dst] = 0;
        }
        else if (op === 0x04 || op === 0x11) {
            S[dst] = S[s1] - S[s2]; IC[dst] = IV[dst] = 0;
        }
        else if (op === 0x05 || op === 0x12) {
            S[dst] = S[s1] * S[s2]; IC[dst] = IV[dst] = 0;
        }
        else if (op === 0x06 || op === 0x13) {
            S[dst] = S[s2] !== 0 ? S[s1] / S[s2] : 0; IC[dst] = IV[dst] = 0;
        }
        else if (op === 0x14) S[dst] = Math.pow(S[s1], S[s2]);
        else if (op === 0x15) S[dst] = Math.sqrt(S[s1]);
        else if (op === 0x17) S[dst] = Math.sin(S[s1]);
        else if (op === 0x18) S[dst] = Math.cos(S[s1]);
        else if (op === 0x19) S[dst] = Math.tan(S[s1]);
        else if (op === 0x1C) S[dst] = Math.abs(S[s1]);
        else if (op === 0x07 || op === 0x40) pc = (ins & 0xFFFF);
        else if (op === 0x08 || op === 0x41) { if (S[dst] === 0) pc = (ins & 0xFFFF); }
        else if (op === 0x21) S[dst] = S[s1] === S[s2] ? 1 : 0;
        else if (op === 0x22) S[dst] = S[s1] !== S[s2] ? 1 : 0;
        else if (op === 0x23) S[dst] = S[s1] < S[s2] ? 1 : 0;
        else if (op === 0x24) S[dst] = S[s1] <= S[s2] ? 1 : 0;
        else if (op === 0x25) S[dst] = S[s1] > S[s2] ? 1 : 0;
        else if (op === 0x26) S[dst] = S[s1] >= S[s2] ? 1 : 0;
        else if (op === 0x51) {
            var rx = S[this.code[pc++]], ry = S[this.code[pc++]], rw = S[this.code[pc++]], rh = S[this.code[pc++]], rc = S[this.code[pc++]];
        }
        else if (op === 0x52) {
            var rcx = S[this.code[pc++]], rcy = S[this.code[pc++]], rr = S[this.code[pc++]], rc = S[this.code[pc++]];
        }
        else if (op === 0x53) {
            var rx1 = S[this.code[pc++]], ry1 = S[this.code[pc++]], rx2 = S[this.code[pc++]], ry2 = S[this.code[pc++]], lc = S[this.code[pc++]];
        }
        else if (op === 0x54) {
            var isStr = dst === 1;
            var sRef = this.code[pc++];
            var rx = this.code[pc++], ry = this.code[pc++], rSz = this.code[pc++], rCol = this.code[pc++];
        }
        
        if (Number.isNaN(S[dst])) {
            console.log(`FIRST NaN produced at pc=${curPc}: op=0x${op.toString(16)} dst=R${dst} s1=R${s1} (val=${S[s1]}) s2=R${s2} (val=${S[s2]})`);
            return;
        }
    }
};

vm.rScalar[250] = 1366;
vm.rScalar[251] = 607;
vm.rScalar[252] = 839;
vm.rScalar[253] = 223.5;
vm.rScalar[254] = 1.0;
vm.rScalar[255] = 0;
vm.rScalar[247] = 0;

let firstPc = json.first_screen_pc || 0;
vm.run(firstPc, 1366, 607);
