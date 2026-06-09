const { test, expect } = require('@playwright/test');

// Timeout 15 phút cho 50 test case chạy chậm trong 1 luồng demo.
test.setTimeout(900000);

const testCases = [
  { id: 'TC-01', day: '29', month: '02', year: '2024', expected: 'Valid' },
  { id: 'TC-02', day: '29', month: '02', year: '2023', expected: 'Invalid' },

  { id: 'TC-03', day: '01', month: '01', year: '1920', expected: 'Valid' },
  { id: 'TC-04', day: '31', month: '04', year: '2024', expected: 'Invalid' },

  { id: 'TC-05', day: '31', month: '12', year: '3000', expected: 'Valid' },
  { id: 'TC-06', day: '10', month: '13', year: '2024', expected: 'Invalid' },

  { id: 'TC-07', day: '28', month: '02', year: '2023', expected: 'Valid' },
  { id: 'TC-08', day: '30', month: '02', year: '2024', expected: 'Invalid' },

  { id: 'TC-09', day: '15', month: '06', year: '2026', expected: 'Valid' },
  { id: 'TC-10', day: '29', month: '02', year: '2100', expected: 'Invalid' },

  { id: 'TC-11', day: '30', month: '04', year: '2028', expected: 'Valid' },
  { id: 'TC-12', day: '32', month: '01', year: '2025', expected: 'Invalid' },

  { id: 'TC-13', day: '31', month: '01', year: '2025', expected: 'Valid' },
  { id: 'TC-14', day: '00', month: '05', year: '2024', expected: 'Invalid' },

  { id: 'TC-15', day: '29', month: '02', year: '2000', expected: 'Valid' },
  { id: 'TC-16', day: '01', month: '01', year: '1919', expected: 'Invalid' },

  { id: 'TC-17', day: '25', month: '12', year: '2500', expected: 'Valid' },
  { id: 'TC-18', day: '31', month: '12', year: '3001', expected: 'Invalid' },

  { id: 'TC-19', day: '10', month: '10', year: '2040', expected: 'Valid' },
  { id: 'TC-20', day: '31', month: '06', year: '2027', expected: 'Invalid' },

  { id: 'TC-21', day: '12', month: '03', year: '1999', expected: 'Valid' },
  { id: 'TC-22', day: '31', month: '09', year: '2024', expected: 'Invalid' },

  { id: 'TC-23', day: '05', month: '07', year: '1984', expected: 'Valid' },
  { id: 'TC-24', day: '15', month: '00', year: '2024', expected: 'Invalid' },

  { id: 'TC-25', day: '30', month: '11', year: '2022', expected: 'Valid' },
  { id: 'TC-26', day: '31', month: '11', year: '2022', expected: 'Invalid' },

  { id: 'TC-27', day: '14', month: '02', year: '2400', expected: 'Valid' },
  { id: 'TC-28', day: '29', month: '02', year: '1900', expected: 'Invalid' },

  { id: 'TC-29', day: '22', month: '08', year: '2077', expected: 'Valid' },
  { id: 'TC-30', day: '33', month: '08', year: '2077', expected: 'Invalid' },

  { id: 'TC-31', day: '09', month: '09', year: '2029', expected: 'Valid' },
  { id: 'TC-32', day: '09', month: '14', year: '2029', expected: 'Invalid' },

  { id: 'TC-33', day: '18', month: '05', year: '2035', expected: 'Valid' },
  { id: 'TC-34', day: '18', month: '05', year: '3010', expected: 'Invalid' },

  { id: 'TC-35', day: '07', month: '04', year: '1960', expected: 'Valid' },
  { id: 'TC-36', day: '31', month: '02', year: '1960', expected: 'Invalid' },

  { id: 'TC-37', day: '11', month: '11', year: '2111', expected: 'Valid' },
  { id: 'TC-38', day: '11', month: '11', year: '1918', expected: 'Invalid' },

  { id: 'TC-39', day: '20', month: '10', year: '2222', expected: 'Valid' },
  { id: 'TC-40', day: '20', month: '15', year: '2222', expected: 'Invalid' },

  { id: 'TC-41', day: '02', month: '02', year: '2022', expected: 'Valid' },
  { id: 'TC-42', day: '02', month: '02', year: '3002', expected: 'Invalid' },

  { id: 'TC-43', day: '16', month: '06', year: '1996', expected: 'Valid' },
  { id: 'TC-44', day: '31', month: '06', year: '1996', expected: 'Invalid' },

  { id: 'TC-45', day: '23', month: '09', year: '2750', expected: 'Valid' },
  { id: 'TC-46', day: '31', month: '09', year: '2750', expected: 'Invalid' },

  { id: 'TC-47', day: '08', month: '12', year: '2999', expected: 'Valid' },
  { id: 'TC-48', day: '08', month: '12', year: '3011', expected: 'Invalid' },

  { id: 'TC-49', day: '27', month: '03', year: '2021', expected: 'Valid' },
  { id: 'TC-50', day: '27', month: '16', year: '2021', expected: 'Invalid' },
];

async function slowFill(page, selector, value) {
  const input = page.locator(selector);

  await input.click();
  await input.fill('');

  for (const char of value) {
    await page.keyboard.type(char);
    await page.waitForTimeout(280);
  }
}

test('Continuous E2E demo - 50 non-duplicate Date Time Checker test cases', async ({ page }) => {
  await page.goto('http://localhost:9998');

  for (const tc of testCases) {
    console.log(`${tc.id}: ${tc.day}/${tc.month}/${tc.year} => ${tc.expected}`);

    await slowFill(page, '#day', tc.day);
    await page.waitForTimeout(250);

    await slowFill(page, '#month', tc.month);
    await page.waitForTimeout(250);

    await slowFill(page, '#year', tc.year);
    await page.waitForTimeout(400);

    await page.locator('#checkBtn').click();

    await expect(page.locator('#result')).toHaveText(tc.expected, {
      timeout: 10000,
    });

    await page.waitForTimeout(1200);

    await page.locator('#clearBtn').click();

    await expect(page.locator('#result')).toHaveText('', {
      timeout: 10000,
    });

    await page.waitForTimeout(500);
  }
});