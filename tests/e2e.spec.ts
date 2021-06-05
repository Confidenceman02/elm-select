import { chromium, Browser } from "playwright";
import { expect } from "chai";
let browser: Browser;

before(async () => {
  browser = await chromium.launch();
});

after(async () => {
  await browser.close();
});

describe("examples", () => {
  it("has all examples", async () => {
    const page = await browser.newPage();

    await page.goto("http://localhost:8000");
    const singleExampleVisible = await page.isVisible("text=Single.elm");
    const truncationExampleVisible = await page.isVisible(
      "text=Truncation.elm"
    );
    const multiAsyncExampleVisible = await page.isVisible(
      "text=MultiAsync.elm"
    );
    const multiExampleVisible = await page.isVisible("text=Multi.elm");
    const disabledExampleVisible = await page.isVisible("text=Disabled.elm");
    const clearableExampleVisible = await page.isVisible("text=Clearable.elm");

    expect(singleExampleVisible).eq(true);
    expect(truncationExampleVisible).eq(true);
    expect(multiAsyncExampleVisible).eq(true);
    expect(multiExampleVisible).eq(true);
    expect(disabledExampleVisible).eq(true);
    expect(clearableExampleVisible).eq(true);
  });
});
