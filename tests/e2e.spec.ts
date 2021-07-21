import { chromium, Browser } from "playwright";
import { expect } from "@playwright/test";
let browser: Browser;
const BASE_URI = "http://localhost:8000";
const OPTIMIZED_BASE_URI = "http://localhost:1234";

before(async () => {
  browser = await chromium.launch();
});

after(async () => {
  await browser.close();
});

describe("examples", () => {
  it("has all examples", async () => {
    const page = await browser.newPage();

    await page.goto(BASE_URI);
    const singleExampleVisible = await page.isVisible(
      "text=SingleSearchable.elm"
    );
    const truncationExampleVisible = await page.isVisible(
      "text=MultiTruncation.elm"
    );
    const multiAsyncExampleVisible = await page.isVisible(
      "text=MultiAsync.elm"
    );
    const multiExampleVisible = await page.isVisible("text=Multi.elm");
    const disabledExampleVisible = await page.isVisible("text=Disabled.elm");
    const clearableExampleVisible = await page.isVisible(
      "text=SingleClearable.elm"
    );
    const longMenuVisible = await page.isVisible("text=LongMenu.elm");

    expect(singleExampleVisible).toBeTruthy();
    expect(truncationExampleVisible).toBeTruthy();
    expect(multiAsyncExampleVisible).toBeTruthy();
    expect(multiExampleVisible).toBeTruthy();
    expect(disabledExampleVisible).toBeTruthy();
    expect(clearableExampleVisible).toBeTruthy();
    expect(longMenuVisible).toBeTruthy();
  });
});

describe("SingleSearchable", () => {
  // LIST BOX
  it("list box visible after matching input", async () => {
    // @ts-ignore
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleSearchable.elm`);

    const listBoxInitiallyVisible = await page.isVisible(
      "[data-test-id=listBox]"
    );
    const inputVisible = await page.isVisible("[data-test-id=selectInput]");

    expect(listBoxInitiallyVisible).toBeFalsy();
    expect(inputVisible).toBeTruthy();

    // we can assume that e will match at least something in the list box
    await page.fill("[data-test-id=selectInput]", "e");
    await page.waitForTimeout(100);
    const listBoxVisible = await page.isVisible("[data-test-id=listBox]");

    expect(listBoxVisible).toBeTruthy();
  });

  it("list box not visible when input container clicked after matching input", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleSearchable.elm`);

    await page.type("[data-test-id=selectInput]", "e");
    await page.waitForTimeout(100);
    const listBoxVisible = await page.isVisible("[data-test-id=listBox]");

    expect(listBoxVisible).toBeTruthy();

    await page.click("[data-test-id=selectContainer]");
    const listBoxVisibleAfterClick = await page.isVisible(
      "[data-text-id=selectContainer]"
    );
    expect(listBoxVisibleAfterClick).toBeFalsy();
  });

  // INPUT
  it("input text cleared after container click", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleSearchable.elm`);
    await page.type("[data-test-id=selectInput]", "e");

    const inputValue = await page.$eval(
      "[data-test-id=selectInput]",
      (el: HTMLInputElement) => el.value
    );

    expect(inputValue).toBe("e");

    await page.click("[data-test-id=selectContainer]");
    await page.waitForTimeout(100);
    const updatedInputValue = await page.$eval(
      "[data-test-id=selectInput]",
      (el: HTMLInputElement) => el.value
    );

    expect(updatedInputValue).toBe("");
  });
});

describe("Keyboard ArrowDown", () => {
  it("displays list box", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleSearchable.elm`);
    await page.focus("[data-test-id=selectInput]");

    const listBoxInitiallyVisible = await page.isVisible(
      "[data-test-id=listBox]"
    );

    expect(listBoxInitiallyVisible).toBeFalsy();

    await page.keyboard.press("ArrowDown");
    await page.waitForTimeout(100);

    const listBoxVisibleAfterAction = await page.isVisible(
      "[data-test-id=listBox]"
    );
    expect(listBoxVisibleAfterAction).toBeTruthy();
  });
  // Target focusing refers to the menu item being visually highlighted as the item that will be selected on selection.
  it("target focuses the first menu item", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleSearchable.elm`);
    await page.focus("[data-test-id=selectInput]");
    await page.keyboard.press("ArrowDown");
    await page.waitForTimeout(100);

    const firstItemFocused = await page.isVisible(
      "[data-test-id=listBoxItemTargetFocus0]"
    );

    expect(firstItemFocused).toBeTruthy();
  });

  it("target focuses the first menu item when the last menu item is target focused", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleSearchable.elm`);
    await page.focus("[data-test-id=selectInput]");
    await page.keyboard.press("ArrowUp");
    await page.waitForTimeout(100);

    const lastItemFocused = await page.isVisible(
      "[data-test-id=listBoxItemTargetFocus3]"
    );

    expect(lastItemFocused).toBeTruthy();

    await page.keyboard.press("ArrowDown");
    await page.waitForTimeout(100);

    const firstItemFocused = await page.isVisible(
      "[data-test-id=listBoxItemTargetFocus0]"
    );

    expect(firstItemFocused).toBeTruthy();
  });
});

describe("Keyboard ArrowUp", () => {
  it("target focuses the last menu item", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleSearchable.elm`);
    await page.focus("[data-test-id=selectInput]");
    await page.keyboard.press("ArrowUp");
    await page.waitForTimeout(100);

    const lastItemFocused = await page.isVisible(
      "[data-test-id=listBoxItemTargetFocus3]"
    );

    expect(lastItemFocused).toBeTruthy();
  });
});

describe("Keyboard Enter", () => {
  it("automatically selects first target focused menu item", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleSearchable.elm`);
    await page.click("[data-test-id=selectContainer]");
    await page.waitForSelector("[data-test-id=listBox]");
    await page.keyboard.press("Enter");
    await page.waitForTimeout(100);

    const firstListItemSelected = await page.isVisible(
      "[data-test-id=selectedItem]"
    );

    expect(firstListItemSelected).toBeTruthy();

    const selectedItemInnerText = await page.innerText(
      "data-test-id=selectedItem"
    );
    // Assuming menu items are Elm, Is, Really, Great
    expect(selectedItemInnerText).toBe("Elm");
  });
});

describe("Keyboard Escape", () => {
  it("input text cleared", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleSearchable.elm`);
    await page.type("[data-test-id=selectInput]", "e");

    const inputValue = await page.$eval(
      "[data-test-id=selectInput]",
      (el: HTMLInputElement) => el.value
    );

    expect(inputValue).toBe("e");

    await page.keyboard.press("Escape");
    await page.waitForTimeout(100);
    const updatedInputValue = await page.$eval(
      "[data-test-id=selectInput]",
      (el: HTMLInputElement) => el.value
    );

    expect(updatedInputValue).toBe("");
  });

  it("list box not visible if open", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleSearchable.elm`);

    // we can assume that e will match at least something in the list box
    await page.type("[data-test-id=selectInput]", "e");
    await page.waitForTimeout(100);
    const listBoxVisible = await page.isVisible("[data-test-id=listBox]");

    expect(listBoxVisible).toBeTruthy();

    await page.keyboard.press("Escape");
    const listBoxVisibleAfterEscape = await page.isVisible(
      "[data-test-id=listBox]"
    );

    expect(listBoxVisibleAfterEscape).toBeFalsy();
  });
});

describe("JsOptimized", () => {
  it("renders dynamic input data attributes when focused", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${OPTIMIZED_BASE_URI}`);

    const dynamicAttribsVisibleBeforeFocus = await page.isVisible(
      `[data-es-dynamic-select-input]`
    );

    expect(dynamicAttribsVisibleBeforeFocus).toBeFalsy();

    await page.focus("[data-test-id=selectInput]");
    const dynamicAttribsVisibleAfterFocus = await page.isVisible(
      `[data-es-dynamic-select-input]`
    );

    expect(dynamicAttribsVisibleAfterFocus).toBeTruthy();
  });

  it("dynamically increases the input width when typing", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${OPTIMIZED_BASE_URI}`);

    const defaultInputWidth = await page.$eval(
      "[data-test-id=selectInput]",
      (el: HTMLInputElement) => el.getBoundingClientRect().width
    );

    await page.type("[data-test-id=selectInput]", "JAIME");
    await page.waitForTimeout(90);
    const currentInputWidth = await page.$eval(
      "[data-test-id=selectInput]",
      (el: HTMLInputElement) => el.getBoundingClientRect().width
    );

    expect(currentInputWidth).toBeGreaterThan(defaultInputWidth);
  });
});
