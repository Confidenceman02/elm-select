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
    const nativeSingle = await page.isVisible("text=NativeSingle.elm");
    const truncationExampleVisible = await page.isVisible(
      "text=MultiTruncation.elm"
    );
    const multiAsyncExampleVisible = await page.isVisible(
      "text=MultiAsync.elm"
    );
    const multiExampleVisible = await page.isVisible("text=Multi.elm");
    const multiFilterable = await page.isVisible("text=MultiFilterable.elm");
    const singleMenuVisible = await page.isVisible("text=Single.elm");
    const formVisible = await page.isVisible("text=Form.elm");
    const customMenuItemsVisible = await page.isVisible(
      "text=CustomMenuItems.elm"
    );

    expect(singleExampleVisible).toBeTruthy();
    expect(nativeSingle).toBeTruthy();
    expect(truncationExampleVisible).toBeTruthy();
    expect(multiAsyncExampleVisible).toBeTruthy();
    expect(multiFilterable).toBeTruthy();
    expect(multiExampleVisible).toBeTruthy();
    expect(singleMenuVisible).toBeTruthy();
    expect(formVisible).toBeTruthy();
    expect(customMenuItemsVisible).toBeTruthy();
  });
});

describe("CustomMenuItems", () => {
  it("filters list on user input", async () => {
    await browser.newContext();
    const page = await browser.newPage();

    await page.goto(`${BASE_URI}/CustomMenuItems.elm`);
    await page.type("[data-test-id=selectInput]", "pot");
    await page.waitForSelector("[data-test-id=listBox]");
    const listItemCount = await page.$$eval(
      "li",
      (listItems) => listItems.length
    );

    expect(listItemCount).toEqual(1);
  });
});

describe("Multi", () => {
  it("removes menu items from list when selected", async () => {
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/Multi.elm`);
    await page.click("[data-test-id=selectContainer]");
    await page.waitForSelector("[data-test-id=listBox]");

    const initialItemCount = await page.$$eval(
      "li",
      (listItems) => listItems.length
    );
    await page.keyboard.press("Enter");
    await page.click("[data-test-id=selectContainer]");
    await page.waitForSelector("[data-test-id=listBox]");
    const currentItemCount = await page.$$eval(
      "li",
      (listItems) => listItems.length
    );

    expect(currentItemCount).toEqual(initialItemCount - 1);
  });

  it("does not filter menu items that are not filterable", async () => {
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/MultiFilterable.elm`);
    await page.click("[data-test-id=selectContainer]");
    await page.waitForSelector("[data-test-id=listBox]");

    await page.type("[data-test-id=selectInput]", "sdsdsdsdsdsd");
    await page.waitForSelector("[data-test-id=listBox]");
    const rows = page.locator("ul li");
    const texts = await rows.evaluateAll((list) =>
      list.map((element) => element.textContent)
    );

    const matches = texts.map((it) => {
      return new RegExp("New value").test(it as string);
    });

    expect(matches.includes(true)).toBeTruthy();
  });
});

describe("Form", () => {
  it("it doesn't submit the form when clearing a selected item with Enter", async () => {
    const page = await browser.newPage();
    let hasSubmitted = false;
    await page.goto(`${BASE_URI}/Form.elm`);
    page.on("framenavigated", () => {
      hasSubmitted = true;
    });
    await page.click("[data-test-id=selectContainer]");
    await page.waitForSelector("[data-test-id=listBox]");
    await page.keyboard.press("Enter");
    await page.waitForSelector("[data-test-id=clear]");
    await page.focus("[data-test-id=clear]");
    await page.keyboard.press("Enter");
    await page.waitForTimeout(100);

    expect(hasSubmitted).toBeFalsy();
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

  it("filters list on user input", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleSearchable.elm`);
    await page.type("[data-test-id=selectInput]", "el");
    await page.waitForSelector("[data-test-id=listBox]");

    const listItemCount = await page.$$eval(
      "li",
      (listItems) => listItems.length
    );

    expect(listItemCount).toEqual(1);
  });
});

describe("NativeSingle", () => {
  it("Selects item by input when there is no selection", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/NativeSingle.elm`);
    await page.type("[data-test-id=nativeSingleSelect]", "e");
    await page.waitForTimeout(100);

    const selectedIndex: number = await page.$eval(
      "[data-test-id=nativeSingleSelect]",
      (el: HTMLSelectElement) => el.selectedIndex
    );

    expect(selectedIndex).toBe(0);
  });

  it("Selects item by input when there is already a selection", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/NativeSingle.elm`);

    await page.selectOption("select#native-single-select-SingleSelectExample", {
      label: "Great",
    });
    await page.type("[data-test-id=nativeSingleSelect]", "e");
    await page.waitForTimeout(200);
    const selectedIndex: number = await page.$eval(
      "[data-test-id=nativeSingleSelect]",
      (el: HTMLSelectElement) => el.selectedIndex
    );

    expect(selectedIndex).toBe(0);
  });

  it("selects item by dropdown select", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/NativeSingle.elm`);
    await page.selectOption("select#native-single-select-SingleSelectExample", {
      label: "Great",
    });

    await page.waitForTimeout(200);
    const selectedIndex: number = await page.$eval(
      "[data-test-id=nativeSingleSelect]",
      (el: HTMLSelectElement) => el.selectedIndex
    );

    expect(selectedIndex).toBe(3);
  });

  it("selected item has selected attribute", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/NativeSingle.elm`);
    await page.selectOption("select#native-single-select-SingleSelectExample", {
      label: "Great",
    });

    const isSelected: boolean = await page.$eval(
      "#native-single-select-SingleSelectExample",
      (el: HTMLSelectElement) => {
        const selectedIndex = el.selectedIndex;
        return el.options[selectedIndex].selected;
      }
    );

    expect(isSelected).toBeTruthy();
  });
});

describe("MultiAsync", () => {
  it("renders a loading message when no items match input", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/MultiAsync.elm`);
    await page.type("[data-test-id=selectInput]", "122333");

    const loadingTextVisible = await page.isVisible("text=Loading...");

    expect(loadingTextVisible).toBeTruthy;
  });
});

describe("Keyboard ArrowDown", () => {
  it("displays list box for searchable", async () => {
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

  it("displays list box for non searchable", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/Single.elm`);
    await page.focus("[data-test-id=dummyInputSelect]");
    await page.keyboard.press("ArrowDown");
    await page.waitForTimeout(100);

    const firstItemFocused = await page.isVisible(
      "[data-test-id=listBoxItemTargetFocus0]"
    );

    expect(firstItemFocused).toBeTruthy();
  });
  // Target focusing refers to the menu item being visually highlighted as the item that will be selected on selection.
  it("target focuses the first menu item for searchable", async () => {
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

  it("target focuses the first menu item for non searchable", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/Single.elm`);
    await page.focus("[data-test-id=dummyInputSelect]");
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
  it("target focuses the last menu item for searchable", async () => {
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

  it("target focuses the last menu item for non searchable", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/Single.elm`);
    await page.focus("[data-test-id=dummyInputSelect]");
    await page.keyboard.press("ArrowUp");
    await page.waitForTimeout(100);

    const lastItemFocused = await page.isVisible(
      "[data-test-id=listBoxItemTargetFocus3]"
    );

    expect(lastItemFocused).toBeTruthy();
  });
});

describe("Keyboard Enter", () => {
  it("automatically selects first target focused menu item for searchable", async () => {
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

  it("automatically selects first target focused menu item for non searchable", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/Single.elm`);
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
    await page.waitForTimeout(200);
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
    await page.waitForTimeout(300);
    const currentInputWidth = await page.$eval(
      "[data-test-id=selectInput]",
      (el: HTMLInputElement) => el.getBoundingClientRect().width
    );

    expect(currentInputWidth).toBeGreaterThan(defaultInputWidth);
  });
});
