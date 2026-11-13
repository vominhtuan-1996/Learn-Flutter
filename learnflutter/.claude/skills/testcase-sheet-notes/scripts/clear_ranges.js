// Clear Contents theo đoạn, tránh hàng header gộp. Sửa mảng ranges trước khi chạy.
// Toạ độ ribbon (zoom trình duyệt mặc định, cửa sổ 1920 rộng): Clear (1337,129), Clear Contents (1371,212).
async (page) => {
  const ranges = ['S8:S14', 'S16:S50', 'S52:S77', 'S79:S82', 'S84:S91'];
  const fr = page.frames().find(f => f.url().includes('xlviewerinternal'));
  const nb = fr.locator('#FormulaBar-NameBox-input, input[aria-label="Name Box"]').first();
  for (const r of ranges) {
    await nb.click({ clickCount: 3 });
    await page.keyboard.press('Meta+A');
    await page.keyboard.type(r);
    await page.keyboard.press('Enter');
    await page.waitForTimeout(1500);
    await page.mouse.click(1337, 129);
    await page.waitForTimeout(800);
    await page.mouse.click(1371, 212);
    await page.waitForTimeout(2500);
  }
  return ranges.join(',');
}
