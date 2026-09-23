const { test, expect } = require('@playwright/test');

test('home page has correct title', async ({ page }) => {
  await page.goto('/');
  // Expect a title containing "Job Applier" or similar
  await expect(page).toHaveTitle(/Job Applier/);
});

test('can navigate to login page', async ({ page }) => {
  await page.goto('/');
  // Click a login link if exists
  const loginLink = page.locator('text=Login');
  if (await loginLink.count()) {
    await loginLink.click();
    await expect(page).toHaveURL(/\/login/);
  }
});
