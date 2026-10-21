const fs = require('fs');
const path = require('path');

const targets = [
  path.resolve(__dirname, '..', 'phasor_runtime.js'),
  path.resolve(__dirname, '..', 'runtime', 'phasor_runtime.js'),
  path.resolve(__dirname, '..', 'dist', 'phasor_runtime.js')
];

const newOpcodes = `      else if (op === 0x50) this.pushUi(0x50, S[dst]);
      else if (op === 0x51) {
        var rx = this.code[pc++], ry = this.code[pc++], rw = this.code[pc++];
        var extra = this.code[pc++];
        var rh = (extra >>> 16) & 0xFFFF, rc = (extra >>> 8) & 0xFF;
        this.pushUi(0x51, S[rx], S[ry], S[rw], S[rh], S[rc]);
      }
      else if (op === 0x52) {
        var rcx = this.code[pc++], rcy = this.code[pc++], rr = this.code[pc++];
        var extra = this.code[pc++];
        var rc = (extra >>> 16) & 0xFFFF;
        this.pushUi(0x52, S[rcx], S[rcy], S[rr], S[rc], 0);
      }
      else if (op === 0x53) {
        var rx1 = this.code[pc++], ry1 = this.code[pc++], rx2 = this.code[pc++];
        var extra = this.code[pc++];
        var ry2 = (extra >>> 16) & 0xFFFF, lc = (extra >>> 8) & 0xFF;
        this.pushUi(0x53, S[rx1], S[ry1], S[rx2], S[ry2], S[lc]);
      }
      else if (op === 0x54) {
        var tx = this.code[pc++], ty = this.code[pc++], strIdx = this.code[pc++];
        var extra = this.code[pc++];
        var tc = (extra >>> 16) & 0xFFFF, varReg = (extra >>> 8) & 0xFF;
        var px = S[tx], py = S[ty];
        var displayText = "";
        if (varReg !== 0xFF) {
          displayText = S[varReg].toFixed(2);
        } else {
          displayText = (this.strings && this.strings[strIdx] !== undefined) ? this.strings[strIdx] : "";
        }
        this.pushUi(0x54, px, py, tc, 0, 0);
        this.texts.push({ text: displayText, x: px, y: py, color: tc, size: 12 });
      }
      else if (op === 0x56) {
        var bx = this.code[pc++], by = this.code[pc++], bw = this.code[pc++];
        var extra = this.code[pc++];
        var bh = (extra >>> 16) & 0xFFFF, strIdx = (extra >>> 8) & 0xFF;
        var extra2 = this.code[pc++];
        var actHash = extra2;
        var px = S[bx], py = S[by], pw = S[bw], ph = S[bh];
        var label = (this.strings && this.strings[strIdx] !== undefined) ? this.strings[strIdx] : 'BOTÓN';
        this.pushUi(0x56, px, py, pw, ph, 0x1f6feb);
        this.buttons.push({ x: px, y: py, w: pw, h: ph, target: actHash, label: label });
      }
      else if (op === 0x57) {
        var extra = this.code[pc++];
        if (typeof this.handleAction === 'function') this.handleAction(extra);
      }
`;

targets.forEach(fp => {
  if (!fs.existsSync(fp)) return;
  let code = fs.readFileSync(fp, 'utf8');

  const startMarker = 'else if (op === 0x50)';
  const endMarker = 'else if (op === 0x60)';

  const startIdx = code.indexOf(startMarker);
  const endIdx = code.indexOf(endMarker);

  if (startIdx !== -1 && endIdx !== -1) {
    const before = code.substring(0, startIdx);
    const after = code.substring(endIdx);
    code = before + newOpcodes + after;
  }

  // Also improve 0x72
  const old72 = 'if (offS >= 0 && offS < H.length) H[offS] = S[s1];';
  const new72 = 'var valS = Math.floor(S[s1]); if (offS >= 0 && offS < H.length) H[offS] = (valS >= 0 && valS < S.length && S[valS] !== undefined) ? S[valS] : S[s1];';
  if (code.includes(old72)) {
    code = code.replace(old72, new72);
  }

  fs.writeFileSync(fp, code, 'utf8');
  console.log('Successfully patched:', fp);
});
