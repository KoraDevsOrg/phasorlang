const fs = require('fs');
const path = require('path');

const targets = [
  path.resolve(__dirname, '..', 'phasor_runtime.js'),
  path.resolve(__dirname, '..', 'runtime', 'phasor_runtime.js'),
  path.resolve(__dirname, '..', 'dist', 'phasor_runtime.js')
];

const trueOpcodes = `      else if (op === 0x50) this.pushUi(0x50, S[dst]);
      else if (op === 0x51) {
        var rx = S[this.code[pc++]], ry = S[this.code[pc++]], rw = S[this.code[pc++]], rh = S[this.code[pc++]], rc = S[this.code[pc++]];
        this.pushUi(0x51, rx, ry, rw, rh, rc);
      }
      else if (op === 0x52) {
        var rcx = S[this.code[pc++]], rcy = S[this.code[pc++]], rr = S[this.code[pc++]], rc = S[this.code[pc++]];
        this.pushUi(0x52, rcx, rcy, rr, rc, 0);
      }
      else if (op === 0x53) {
        var rx1 = S[this.code[pc++]], ry1 = S[this.code[pc++]], rx2 = S[this.code[pc++]], ry2 = S[this.code[pc++]], lc = S[this.code[pc++]];
        this.pushUi(0x53, rx1, ry1, rx2, ry2, lc);
      }
      else if (op === 0x54) {
        var isStr = dst === 1;
        var sRef = this.code[pc++];
        var rx = this.code[pc++], ry = this.code[pc++], rSz = this.code[pc++], rCol = this.code[pc++];
        var tx = S[rx], ty = S[ry], tSz = S[rSz];
        var tc = (rCol >= 0 && rCol < S.length && S[rCol] !== 0) ? S[rCol] : 0x58A6FF;
        var txt = isStr ? (this.strings[sRef] || "") : (Number.isInteger(S[sRef]) ? S[sRef].toString() : S[sRef].toFixed(2));
        this.pushUi(0x54, tx, ty, tc, tSz, 0);
        this.texts.push({ text: txt, x: tx, y: ty, color: tc, size: tSz });
      }
      else if (op === 0x56) {
        var strId = dst;
        var rBx = this.code[pc++], rBy = this.code[pc++], rBw = this.code[pc++], rBh = this.code[pc++];
        var act = this.code[pc++];
        var rCol = this.code[pc++];
        var bx = S[rBx], by = S[rBy], bw = S[rBw], bh = S[rBh];
        var bc = (rCol >= 0 && rCol < S.length && S[rCol] > 0) ? S[rCol] : 0x1f6feb;
        var lbl = this.strings[strId] || 'BOTÓN';
        this.pushUi(0x56, bx, by, bw, bh, bc);
        this.buttons.push({ x: bx, y: by, w: bw, h: bh, target: act, label: lbl, color: bc });
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
    code = before + trueOpcodes + after;
  }

  // Also make sure run(0) is executed automatically on boot
  // In init(wasm, canvasId, opts):
  // Ensure that self.vm.run(0) is executed to initialize all global registers before first screen run!
  if (!code.includes('self.vm.run(0, window.innerWidth, window.innerHeight);')) {
    code = code.replace(
      'self.currentScreenPc = opts.firstScreenPc || 0;',
      'self.currentScreenPc = opts.firstScreenPc || 0;\n        self.vm.run(0, window.innerWidth, window.innerHeight);'
    );
  }

  fs.writeFileSync(fp, code, 'utf8');
  console.log('Successfully updated with true opcodes:', fp);
});
