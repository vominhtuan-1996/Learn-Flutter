// Copy cột A (TC ID) ra clipboard rồi đọc lại; dùng kết quả cho build_rowmap.py.
// Thay A7:A100 theo vùng dữ liệu. Nếu clipboard trả "Retrieving data", chạy lại sau vài giây.
async (page) => {
  const fr = page.frames().find(f => f.url().includes('xlviewerinternal'));
  const nb = fr.locator('#FormulaBar-NameBox-input, input[aria-label="Name Box"]').first();
  await nb.click({ clickCount: 3 });
  await page.keyboard.press('Meta+A');
  await page.keyboard.type('A7:A100');
  await page.keyboard.press('Enter');
  await page.waitForTimeout(800);
  await page.context().grantPermissions(['clipboard-read', 'clipboard-write']);
  await page.keyboard.press('Meta+C');
  await page.waitForTimeout(3000);
  return await page.evaluate(() => navigator.clipboard.readText());
}
