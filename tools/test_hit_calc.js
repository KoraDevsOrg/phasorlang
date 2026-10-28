function vp_client_w(w) { return w - 2.0; }
function vp_client_h(h, top) { return h - top - 1.0; }
function vp_show_v(cw, ch, clw, clh) {
    let val = 0.0;
    if (cw > clw) val = 1.0;
    let delta = clh - (7.0 * val);
    let res = 0.0;
    if (ch > delta) res = 1.0;
    return res;
}
function vp_show_h(cw, ch, clw, clh) {
    let val = vp_show_v(cw, ch, clw, clh);
    let delta = clw - (7.0 * val);
    let res = 0.0;
    if (cw > delta) res = 1.0;
    return res;
}
function vp_visible_h(cw, ch, clw, clh) {
    let val = vp_show_h(cw, ch, clw, clh);
    return clh - (7.0 * val);
}
function vp_max_y(cw, ch, clw, clh) {
    let res = vp_visible_h(cw, ch, clw, clh);
    let val = ch - res;
    if (val < 0.0) val = 0.0;
    return val;
}
function vp_track_v_x(hx, w) { return hx + w - 7.0; }
function vp_track_v_y(hy, top) { return hy + top + 1.0; }
function vp_track_v_len(cw, ch, clw, clh) {
    let res = vp_visible_h(cw, ch, clw, clh);
    return res - 1.0;
}
function vp_thumb_size(tl, val, ch) {
    let delta = 1.0;
    if (ch > 1.0) delta = val / ch;
    let sz = tl * delta;
    if (sz < 16.0) sz = 16.0;
    if (sz > tl) sz = tl;
    return sz;
}
function vp_thumb_offset(tl, sz, sc, max_sc) {
    let delta = tl - sz;
    let off = 0.0;
    if (max_sc >= 1.0) {
        if (delta > 0.0) {
            let val = sc;
            if (val < 0.0) val = 0.0;
            if (val > max_sc) val = max_sc;
            off = (val / max_sc) * delta;
        }
    }
    return off;
}

function vp_hit_v(hx, hy, w, h, top, cw, ch, sc, mx, my) {
    let clw = vp_client_w(w);
    let clh = vp_client_h(h, top);
    let val = vp_show_v(cw, ch, clw, clh);
    let hit = 0.0;
    console.log({ clw, clh, val });
    if (val === 1.0) {
        let tx = vp_track_v_x(hx, w);
        let ty = vp_track_v_y(hy, top);
        let tl = vp_track_v_len(cw, ch, clw, clh);
        console.log({ tx, ty, tl });
        if (tl >= 16.0) {
            console.log(`Checking mx [${tx - 3.0}, ${tx + 6.0}], mx=${mx}`);
            if (mx >= (tx - 3.0) && mx <= (tx + 6.0)) {
                console.log(`Checking my [${ty}, ${ty + tl}], my=${my}`);
                if (my >= ty && my <= (ty + tl)) {
                    let res = vp_visible_h(cw, ch, clw, clh);
                    let max_sc = vp_max_y(cw, ch, clw, clh);
                    let sz = vp_thumb_size(tl, res, ch);
                    let off = vp_thumb_offset(tl, sz, sc, max_sc);
                    let delta = ty + off;
                    hit = 2.0;
                    if (my >= delta && my <= (delta + sz)) hit = 1.0;
                    console.log({ res, max_sc, sz, off, delta, hit });
                }
            }
        }
    }
    return hit;
}

// Window 1: w=480, h=360, top=54, cw=680, ch=560, sc=0
// At center of screen sw=1366, sh=607:
// s1_x = -320 -> hx = -320 + 683 = 363. hy = -180 + 303.5 = 123.5.
let hx = 363, hy = 123.5, w = 480, h = 360, top = 54, cw = 680, ch = 560, sc = 0;
// Test click at track: mx = hx + w - 4 = 363 + 480 - 4 = 839. my = hy + 100 = 223.5
console.log('Result:', vp_hit_v(hx, hy, w, h, top, cw, ch, sc, 839, 223.5));
