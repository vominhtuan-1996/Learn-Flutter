// Template cho mcp__plugin_playwright_playwright__browser_run_code_unsafe.
// __CELLS__ được build_run_code.py thay bằng [["S8","text"],...].
async (page) => {
  const fr = page.frames().find(f => f.url().includes('xlviewerinternal'));
  const nb = fr.locator('#FormulaBar-NameBox-input, input[aria-label="Name Box"]').first();
  const cells = __CELLS__;
  const done = [];
  for (const [addr, text] of cells) {
    await nb.click({ clickCount: 3 });
    await page.keyboard.press('Meta+A');
    await page.keyboard.type(addr);
    await page.keyboard.press('Enter');
    await page.waitForTimeout(500);
    // Escape trả focus về lưới; thiếu bước này chữ rơi vào Name Box.
    await page.keyboard.press('Escape');
    await page.waitForTimeout(200);
    await page.keyboard.type(text);
    await page.keyboard.press('Enter');
    await page.waitForTimeout(500);
    done.push(addr);
  }
  return done.join(' ');
}
