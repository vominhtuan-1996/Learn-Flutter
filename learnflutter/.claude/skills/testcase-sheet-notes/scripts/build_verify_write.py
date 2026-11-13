#!/usr/bin/env python3
"""Sinh code browser_run_code_unsafe: mở sheet, dựng bản đồ TC->hàng từ cột A, kiểm tiêu đề từng ô đích, rồi (nếu WRITE=true) ghi note.

Dùng: build_verify_write.py <notes.json> <titles.json> <tiền_tố_TC vd TC_02> "<tên sheet>" [col S] [--write]
Kiểm tiêu đề: chép ô F{hàng} và so 30 ký tự đầu (không phân biệt hoa thường) với tiêu đề kỳ vọng. Sai tiêu đề ở bất kỳ ô nào thì
KHÔNG ghi ô nào và trả danh sách lệch. Ô Note đích phải trống (khác trống thì bỏ qua và báo).
"""
import json, sys
notes = json.load(open(sys.argv[1], encoding="utf-8")); titles = json.load(open(sys.argv[2], encoding="utf-8"))
prefix, sheet = sys.argv[3], sys.argv[4]
col = sys.argv[5] if len(sys.argv) > 5 and not sys.argv[5].startswith("--") else "S"
write = "--write" in sys.argv
items = [[tc, titles[tc][:30], n] for tc, n in notes.items() if tc.startswith(prefix + ".")]
print(f"// {len(items)} ô — sheet {sheet}, cột {col}, write={write}")
print("""async (page) => {
  const fr = page.frames().find(f => f.url().includes('xlviewerinternal'));
  const nb = fr.locator('#FormulaBar-NameBox-input, input[aria-label="Name Box"]').first();
  const items = %s;
  const WRITE = %s, COL = %s;
  await fr.getByText(%s, {exact:true}).first().click(); await page.waitForTimeout(2500);
  await page.context().grantPermissions(['clipboard-read','clipboard-write']);
  const goto = async (addr) => { await nb.click({clickCount:3}); await page.keyboard.press('Meta+A'); await page.keyboard.type(addr); await page.keyboard.press('Enter'); await page.waitForTimeout(700); await page.keyboard.press('Escape'); await page.waitForTimeout(200); };
  const copy = async (addr) => { await goto(addr);
    for (let k=0;k<6;k++){ await page.evaluate(()=>navigator.clipboard.writeText('x')); await page.keyboard.press('Meta+C'); await page.waitForTimeout(2500);
      const t = await page.evaluate(()=>navigator.clipboard.readText()); if (t && t!=='x' && !/Retrieving/.test(t) && t.trim()!==addr) return t; } return ''; };
  const A = (await copy('A7:A200')).split(/\\r?\\n/);
  const rows = {}; A.forEach((id,i)=>{ const m=id.trim(); if(/^TC_\\d+\\.\\d+$/.test(m)) rows[m]=7+i; });
  const bad = [], plan = [];
  for (const [tc, t30, note] of items) {
    const r = rows[tc]; if (!r) { bad.push(tc+': không có trong cột A'); continue; }
    const title = (await copy('F'+r)).trim().toLowerCase(); const want = t30.toLowerCase();
    if (!title.startsWith(want)) { bad.push(tc+' hàng '+r+': tiêu đề «'+title.slice(0,50)+'» ≠ «'+want+'»'); continue; }
    const cur = (await copy(COL+r)).trim(); if (cur) { bad.push(tc+' hàng '+r+': ô '+COL+r+' đã có nội dung'); continue; }
    plan.push([tc, COL+r, note]);
  }
  if (bad.length || !WRITE) return JSON.stringify({ok: !bad.length, wrote: 0, plan: plan.map(p=>p[0]+'@'+p[1]), bad});
  for (const [tc, addr, note] of plan) { await goto(addr); await page.keyboard.type(note); await page.keyboard.press('Enter'); await page.waitForTimeout(500); }
  return JSON.stringify({ok:true, wrote: plan.length, plan: plan.map(p=>p[0]+'@'+p[1])});
}""" % (json.dumps(items, ensure_ascii=False), "true" if write else "false", json.dumps(col), json.dumps(sheet, ensure_ascii=False)))
