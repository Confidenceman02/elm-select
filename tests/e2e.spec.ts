import { chromium, Browser } from "playwright";
import { expect } from "chai";
let browser: Browser;
const BASE_URI = "http://localhost:8000";

before(async () => {
  browser = await chromium.launch();
});

after(async () => {
  // await browser.close();
});

describe("examples", () => {
  it("has all examples", async () => {
    const page = await browser.newPage();

    await page.goto(BASE_URI);
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

    expect(singleExampleVisible).to.be.true;
    expect(truncationExampleVisible).to.be.true;
    expect(multiAsyncExampleVisible).to.be.true;
    expect(multiExampleVisible).to.be.true;
    expect(disabledExampleVisible).to.be.true;
    expect(clearableExampleVisible).to.be.true;
  });
});

describe("List box behaviour", () => {
  it("list box visible when input text in item text", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/Single.elm`);

    const listBoxInitialVisible = await page.isVisible(
      "[data-test-id=listBox]"
    );
    const inputVisible = await page.isVisible("[data-test-id=selectInput]");

    expect(listBoxInitialVisible).to.be.false;
    expect(inputVisible).to.be.true;

    // we can assume that e will match at least something in the list box
    await page.fill("[data-test-id=selectInput]", "e");
    await page.waitForTimeout(100);
    const listBoxVisible = await page.isVisible("[data-test-id=listBox]");

    expect(listBoxVisible).to.be.true;
  });

  it("list box not visible when escape button pressed", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/Single.elm`);

    const inputVisible = await page.isVisible("[data-test-id=selectInput]");
    expect(inputVisible).to.be.true;

    // we can assume that e will match at least something in the list box
    await page.type("[data-test-id=selectInput]", "e");
    await page.waitForTimeout(100);
    const listBoxVisible = await page.isVisible("[data-test-id=listBox]");

    expect(listBoxVisible).to.be.true;

    await page.keyboard.press("Escape");
    const listBoxVisibleAfterEscape = await page.isVisible(
      "[data-test-id=listBox]"
    );

    expect(listBoxVisibleAfterEscape).to.be.false;
  });
});
