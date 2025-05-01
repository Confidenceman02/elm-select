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
  it("has all tested examples", async () => {
    const page = await browser.newPage();

    await page.goto(BASE_URI);
    const singleSearchableVisible = await page.isVisible(
      "text=SingleSearchable.elm",
    );
    const nativeSingle = await page.isVisible("text=SingleNative.elm");
    const multiAsyncExampleVisible = await page.isVisible(
      "text=MultiAsync.elm",
    );
    const multiExampleVisible = await page.isVisible("text=Multi.elm");
    const multiFilterable = await page.isVisible("text=MultiFilterable.elm");
    const multiNativeVisible = await page.isVisible("text=MultiNative.elm");
    const singleVisible = await page.isVisible("text=Single.elm");
    const singleGroupVisible = await page.isVisible("text=SingleGrouped.elm");
    const formVisible = await page.isVisible("text=Form.elm");
    const customMenuItemsVisible = await page.isVisible(
      "text=CustomMenuItems.elm",
    );
    const singleMenuVisible = await page.isVisible("text=SingleMenu.elm");
    const singleMenuOpenVisible = await page.isVisible(
      "text=SingleMenuOpen.elm",
    );
    const singleVirtualVisible = await page.isVisible("text=SingleVirtual.elm");
    const singleMenuVirtualVisible = await page.isVisible(
      "text=SingleVirtual.elm",
    );
    const multiVirtualVisible = await page.isVisible("text=MultiVirtual.elm");
    const keepMenuOpenVisible = await page.isVisible("text=KeepMenuOpen.elm");

    expect(singleSearchableVisible).toBeTruthy();
    expect(nativeSingle).toBeTruthy();
    expect(multiAsyncExampleVisible).toBeTruthy();
    expect(multiFilterable).toBeTruthy();
    expect(multiExampleVisible).toBeTruthy();
    expect(multiNativeVisible).toBeTruthy();
    expect(singleVisible).toBeTruthy();
    expect(singleMenuVirtualVisible).toBeTruthy();
    expect(singleGroupVisible).toBeTruthy();
    expect(formVisible).toBeTruthy();
    expect(customMenuItemsVisible).toBeTruthy();
    expect(singleMenuVisible).toBeTruthy();
    expect(singleMenuOpenVisible).toBeTruthy();
    expect(singleVirtualVisible).toBeTruthy();
    expect(multiVirtualVisible).toBeTruthy();
    expect(keepMenuOpenVisible).toBeTruthy();
  });
});

describe("SingleMenuVirtual", () => {
  // has 1000 menu items
  it("Only renders the first 8 items", async () => {
    await browser.newContext();
    const page = await browser.newPage();

    await page.goto(`${BASE_URI}/SingleMenuVirtual.elm`);
    await page.click("[data-test-id=bold]");
    await page.waitForSelector("[data-test-id=listBox]");
    const options = page.getByRole("option");

    expect(options).toHaveCount(8);
  });

  it("Jumps to the end of the list", async () => {
    await browser.newContext();
    const page = await browser.newPage();

    await page.goto(`${BASE_URI}/SingleMenuVirtual.elm`);
    await page.click("[data-test-id=bold]");
    await page.waitForSelector("[data-test-id=listBox]");
    await page.keyboard.press("ArrowUp");
    const lastItem = page.getByRole("option", { name: "1000" });

    expect(lastItem).toBeVisible();
  });

  it("Jumps to start of the list", async () => {
    await browser.newContext();
    const page = await browser.newPage();

    await page.goto(`${BASE_URI}/SingleMenuVirtual.elm`);
    await page.click("[data-test-id=bold]");
    await page.waitForSelector("[data-test-id=listBox]");
    await page.keyboard.press("ArrowUp");
    const lastItem = page.getByRole("option", { name: "1000" });

    expect(lastItem).toBeVisible();

    await page.keyboard.press("ArrowDown");
    const firstItem = page.getByRole("option", { name: "0" });

    expect(firstItem).toBeVisible();
  });

  it("loads more options on scroll", async () => {
    await browser.newContext();
    const page = await browser.newPage();

    await page.goto(`${BASE_URI}/SingleMenuVirtual.elm`);
    await page.click("[data-test-id=bold]");
    await page.waitForSelector("[data-test-id=listBox]");
    const listbox = page.locator("[data-test-id=listBox]");
    const [x, y, width, height] = await listbox.evaluate((ele: HTMLElement) => {
      const boundingRect = ele.getBoundingClientRect();
      return [
        boundingRect.x,
        boundingRect.y,
        ele.clientWidth,
        ele.clientHeight,
      ];
    });

    // Position mouse in the middle of listbox
    await page.mouse.move((x + width) / 2, (y + height) / 2);
    await page.mouse.wheel(0, 230);
    await page.waitForTimeout(100);

    const item = page.getByRole("option", { name: "11" });

    expect(item).toBeVisible();
  });
});

describe("MultiVirtual", () => {
  // has 1000 menu items
  it("Only renders the first 8 items", async () => {
    await browser.newContext();
    const page = await browser.newPage();

    await page.goto(`${BASE_URI}/MultiVirtual.elm`);
    await page.click("[data-test-id=selectContainer]");
    await page.waitForSelector("[data-test-id=listBox]");
    const options = page.getByRole("option");

    expect(options).toHaveCount(8);
  });

  it("Jumps to the end of the list", async () => {
    await browser.newContext();
    const page = await browser.newPage();

    await page.goto(`${BASE_URI}/MultiVirtual.elm`);
    await page.click("[data-test-id=selectContainer]");
    await page.waitForSelector("[data-test-id=listBox]");
    await page.keyboard.press("ArrowUp");
    const lastItem = page.getByRole("option", { name: "1000" });

    expect(lastItem).toBeVisible();
  });

  it("Jumps to start of the list", async () => {
    await browser.newContext();
    const page = await browser.newPage();

    await page.goto(`${BASE_URI}/MultiVirtual.elm`);
    await page.click("[data-test-id=selectContainer]");
    await page.waitForSelector("[data-test-id=listBox]");
    await page.keyboard.press("ArrowUp");
    const lastItem = page.getByRole("option", { name: "1000" });

    expect(lastItem).toBeVisible();

    await page.keyboard.press("ArrowDown");
    const firstItem = page.getByRole("option", { name: "0" });

    expect(firstItem).toBeVisible();
  });

  it("loads more options on scroll", async () => {
    await browser.newContext();
    const page = await browser.newPage();

    await page.goto(`${BASE_URI}/MultiVirtual.elm`);
    await page.click("[data-test-id=selectContainer]");
    await page.waitForSelector("[data-test-id=listBox]");
    const listbox = page.locator("[data-test-id=listBox]");
    const [x, y, width, height] = await listbox.evaluate((ele: HTMLElement) => {
      const boundingRect = ele.getBoundingClientRect();
      return [
        boundingRect.x,
        boundingRect.y,
        ele.clientWidth,
        ele.clientHeight,
      ];
    });

    // Position mouse in the middle of listbox
    await page.mouse.move((x + width) / 2, (y + height) / 2);
    await page.mouse.wheel(0, 230);
    await page.waitForTimeout(100);

    const item = page.getByRole("option", { name: "11" });

    expect(item).toBeVisible();
  });
});

describe("SingleVirtual", () => {
  // has 1000 menu items
  it("Only renders the first 8 items", async () => {
    await browser.newContext();
    const page = await browser.newPage();

    await page.goto(`${BASE_URI}/SingleVirtual.elm`);
    await page.click("[data-test-id=selectContainer]");
    await page.waitForSelector("[data-test-id=listBox]");
    const options = page.getByRole("option");

    expect(options).toHaveCount(8);
  });

  it("Jumps to the end of the list", async () => {
    await browser.newContext();
    const page = await browser.newPage();

    await page.goto(`${BASE_URI}/SingleVirtual.elm`);
    await page.click("[data-test-id=selectContainer]");
    await page.waitForSelector("[data-test-id=listBox]");
    await page.keyboard.press("ArrowUp");
    const lastItem = page.getByRole("option", { name: "1000" });

    expect(lastItem).toBeVisible();
  });

  it("Jumps to start of the list", async () => {
    await browser.newContext();
    const page = await browser.newPage();

    await page.goto(`${BASE_URI}/SingleVirtual.elm`);
    await page.click("[data-test-id=selectContainer]");
    await page.waitForSelector("[data-test-id=listBox]");
    await page.keyboard.press("ArrowUp");
    const lastItem = page.getByRole("option", { name: "1000" });

    expect(lastItem).toBeVisible();

    await page.keyboard.press("ArrowDown");
    const firstItem = page.getByRole("option", { name: "0" });

    expect(firstItem).toBeVisible();
  });

  it("loads more options on scroll", async () => {
    await browser.newContext();
    const page = await browser.newPage();

    await page.goto(`${BASE_URI}/SingleVirtual.elm`);
    await page.click("[data-test-id=selectContainer]");
    await page.waitForSelector("[data-test-id=listBox]");
    const listbox = page.locator("[data-test-id=listBox]");
    const [x, y, width, height] = await listbox.evaluate((ele: HTMLElement) => {
      const boundingRect = ele.getBoundingClientRect();
      return [
        boundingRect.x,
        boundingRect.y,
        ele.clientWidth,
        ele.clientHeight,
      ];
    });

    // Position mouse in the middle of listbox
    await page.mouse.move((x + width) / 2, (y + height) / 2);
    await page.mouse.wheel(0, 230);
    await page.waitForTimeout(100);

    const item = page.getByRole("option", { name: "11" });

    expect(item).toBeVisible();
  });
});

describe("SingleGrouped", () => {
  it("renders groups", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleGrouped.elm`);
    await page.click("[data-test-id=selectContainer]");
    await page.waitForTimeout(100);

    const groupsVisible = await page.locator("[data-test-id=group]").count();

    expect(groupsVisible).toEqual(2);
  });
});

describe("SingleMenuOpen", () => {
  it("renders the menu by default", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleMenuOpen.elm`);

    const menuListVisble = await page.isVisible("[data-test-id=listBox]");

    expect(menuListVisble).toBeTruthy();
  });

  it("keeps the menu open after selection", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleMenuOpen.elm`);
    await page.locator("#select-menu-item-1-somestate__elm-select").click();

    const menuListVisble = await page.isVisible("[data-test-id=listBox]");

    expect(menuListVisble).toBeTruthy();
  });

  it("keeps the menu open when escaping whilst focused", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleMenuOpen.elm`);

    await page.locator("[data-test-id=selectContainer]").click();
    await page.waitForTimeout(100);
    await page.keyboard.press("Escape");
    const menuListVisble = await page.isVisible("[data-test-id=listBox]");

    expect(menuListVisble).toBeTruthy();
  });

  it("focuses the input when clicking on the conatainer", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleMenuOpen.elm`);

    await page.locator("[data-test-id=selectContainer]").click();
    await page.waitForTimeout(100);
    const handle: HTMLElement = await page.evaluate(
      "document.activeElement.tagName",
    );

    expect(handle).toEqual("INPUT");
  });

  it("does not focus the input when seelcting a menu item", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleMenuOpen.elm`);

    await page.locator("#select-menu-item-4-somestate__elm-select").click();
    await page.waitForTimeout(100);
    const handle: HTMLElement = await page.evaluate(
      "document.activeElement.tagName",
    );

    expect(handle).not.toEqual("INPUT");
  });
});

describe("SingleMenu", () => {
  it("renders the menu on input focus", async () => {
    await browser.newContext();
    const page = await browser.newPage();

    await page.goto(`${BASE_URI}/SingleMenu.elm`);
    await page.click("[data-test-id=dropdown]");
    await page.waitForSelector("[data-test-id=listBox]");
    const menuListVisble = await page.isVisible("[data-test-id=listBox]");

    expect(menuListVisble).toBeTruthy();
  });

  it("closes the menu when mouse clicking outside of menu", async () => {
    await browser.newContext();
    const page = await browser.newPage();

    await page.goto(`${BASE_URI}/SingleMenu.elm`);
    await page.click("[data-test-id=dropdown]");
    await page.waitForSelector("[data-test-id=selectInput]");
    await page.waitForTimeout(100);
    await page.mouse.click(10, 10);
    const menuListVisible = await page.isVisible("[data-test-id=listBox]");

    expect(menuListVisible).toBeFalsy();
  });

  it("closes the menu when double clicking on container then clicking outside menu", async () => {
    await browser.newContext();
    const page = await browser.newPage();

    await page.goto(`${BASE_URI}/SingleMenu.elm`);
    await page.click("[data-test-id=dropdown]");
    await page.waitForSelector("[data-test-id=selectInput]");
    await page.waitForTimeout(100);
    await page.locator("[data-test-id=selectContainer]").dblclick();
    await page.waitForTimeout(100);
    await page.mouse.click(10, 10);
    await page.waitForTimeout(100);
    const menuListVisible = await page.isVisible("[data-test-id=listBox]");

    expect(menuListVisible).toBeFalsy();
  });

  it("does not close the open menu when clicking on container", async () => {
    await browser.newContext();
    const page = await browser.newPage();

    await page.goto(`${BASE_URI}/SingleMenu.elm`);
    await page.click("[data-test-id=dropdown]");
    await page.waitForSelector("[data-test-id=selectInput]");
    await page.locator("[data-test-id=selectContainer]").click();
    await page.waitForTimeout(100);
    const menuListVisible = await page.isVisible("[data-test-id=listBox]");

    expect(menuListVisible).toBeTruthy();
  });

  it("does not clear the input value when clicking on container", async () => {
    await browser.newContext();
    const page = await browser.newPage();

    await page.goto(`${BASE_URI}/SingleMenu.elm`);
    await page.click("[data-test-id=dropdown]");
    const selectInput = page.locator("[data-test-id=selectInput]");
    await selectInput.type("pot");
    await page.waitForTimeout(100);
    await page.locator("[data-test-id=selectContainer]").click();
    await page.waitForTimeout(100);
    const inputValue = await selectInput.evaluate((ele: HTMLInputElement) => {
      return ele.value;
    });

    expect(inputValue).toEqual("pot");
  });

  it("closes the menu on Tab keydown", async () => {
    await browser.newContext();
    const page = await browser.newPage();

    await page.goto(`${BASE_URI}/SingleMenu.elm`);
    await page.click("[data-test-id=dropdown]");
    await page.waitForSelector("[data-test-id=selectInput]");
    await page.keyboard.down("Tab");
    await page.waitForTimeout(100);
    const menuListVisible = await page.isVisible("[data-test-id=listBox]");

    expect(menuListVisible).toBeFalsy();
  });

  it("does not close the menu when tab focusing to clear button", async () => {
    await browser.newContext();
    const page = await browser.newPage();

    await page.goto(`${BASE_URI}/SingleMenu.elm`);
    await page.click("[data-test-id=dropdown]");
    await page.waitForSelector("[data-test-id=selectInput]");
    await page.type("[data-test-id=selectInput]", "pot");
    await page.waitForTimeout(100);
    await page.keyboard.down("Tab");
    await page.waitForTimeout(100);
    const menuListVisible = await page.isVisible("[data-test-id=listBox]");

    expect(menuListVisible).toBeTruthy();
  });

  it("does not close the menu when tab focusing to clear button then back to input", async () => {
    await browser.newContext();
    const page = await browser.newPage();

    await page.goto(`${BASE_URI}/SingleMenu.elm`);
    await page.click("[data-test-id=dropdown]");
    await page.waitForSelector("[data-test-id=selectInput]");
    await page.type("[data-test-id=selectInput]", "pot");
    await page.waitForTimeout(100);
    await page.keyboard.down("Tab");
    await page.waitForTimeout(100);
    await page.keyboard.press("Shift+Tab");
    await page.waitForTimeout(100);
    const menuListVisible = await page.isVisible("[data-test-id=listBox]");

    expect(menuListVisible).toBeTruthy();
  });

  it("closes the menu when tabing past clear button", async () => {
    await browser.newContext();
    const page = await browser.newPage();

    await page.goto(`${BASE_URI}/SingleMenu.elm`);
    await page.click("[data-test-id=dropdown]");
    await page.waitForSelector("[data-test-id=selectInput]");
    await page.type("[data-test-id=selectInput]", "pot");
    await page.waitForTimeout(100);
    await page.keyboard.down("Tab");
    await page.waitForTimeout(100);
    await page.keyboard.down("Tab");
    await page.waitForTimeout(100);
    const menuListVisible = await page.isVisible("[data-test-id=listBox]");

    expect(menuListVisible).toBeFalsy();
  });

  it("clears the input when clear button is pressed", async () => {
    await browser.newContext();
    const page = await browser.newPage();

    await page.goto(`${BASE_URI}/SingleMenu.elm`);
    await page.click("[data-test-id=dropdown]");
    await page.waitForSelector("[data-test-id=selectInput]");
    await page.type("[data-test-id=selectInput]", "pot");
    await page.waitForTimeout(100);
    await page.click("[data-test-id=clear]");
    const inputValue = await page.$eval(
      "[data-test-id=selectInput]",
      (el: HTMLInputElement) => el.value,
    );

    expect(inputValue).toEqual("");
  });

  it("does not close the menu when clear button is clicked", async () => {
    await browser.newContext();
    const page = await browser.newPage();

    await page.goto(`${BASE_URI}/SingleMenu.elm`);
    await page.click("[data-test-id=dropdown]");
    await page.waitForSelector("[data-test-id=selectInput]");
    await page.type("[data-test-id=selectInput]", "pot");
    await page.waitForTimeout(100);
    await page.click("[data-test-id=clear]");
    const menuListVisible = await page.isVisible("[data-test-id=listBox]");

    expect(menuListVisible).toBeTruthy();
  });

  it("renders the clear button when there is input", async () => {
    await browser.newContext();
    const page = await browser.newPage();

    await page.goto(`${BASE_URI}/SingleMenu.elm`);
    await page.click("[data-test-id=dropdown]");
    await page.waitForSelector("[data-test-id=selectInput]");
    await page.type("[data-test-id=selectInput]", "pot");
    const clearButtonVisible = await page.isVisible("[data-test-id=clear]");

    expect(clearButtonVisible).toBeTruthy;
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
      (listItems) => listItems.length,
    );

    expect(listItemCount).toEqual(1);
  });
});

describe("Multi", () => {
  it("has input focus after clearing more than 1 multi tag", async () => {
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/Multi.elm`);
    const input = page.locator("[data-test-id=selectInput]");

    await input.focus();
    await page.keyboard.press("ArrowDown");
    await page.waitForSelector("[data-test-id=listBox]");
    await page.keyboard.press("Enter");
    await page.waitForSelector("[data-test-id=multi-select-tag-0]");
    await page.keyboard.press("ArrowDown");
    await page.waitForSelector("[data-test-id=listBox]");
    await page.keyboard.press("Enter");
    await page.waitForSelector("[data-test-id=multi-select-tag-1]");
    await page.locator("[data-test-id=clear]").click();
    await page.waitForTimeout(100);
    await page.keyboard.press("A");
    const inputValue = await input.evaluate((el: HTMLInputElement) => {
      return el.value;
    });

    expect(inputValue).toEqual("A");
  });

  it("renders multi select tag when selecting item", async () => {
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/Multi.elm`);
    await page.click("[data-test-id=selectContainer]");
    await page.waitForSelector("[data-test-id=listBox]");

    await page.keyboard.press("Enter");
    await page.waitForTimeout(100);
    const multiItemVisible = await page.isVisible(
      "[data-test-id=multi-select-tag-0]",
    );

    expect(multiItemVisible).toBeTruthy();
  });

  it("removes menu items from list when selected", async () => {
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/Multi.elm`);
    await page.click("[data-test-id=selectContainer]");
    await page.waitForSelector("[data-test-id=listBox]");

    const initialItemCount = await page.$$eval(
      "li",
      (listItems) => listItems.length,
    );
    await page.keyboard.press("Enter");
    await page.click("[data-test-id=selectContainer]");
    await page.waitForSelector("[data-test-id=listBox]");
    const currentItemCount = await page.$$eval(
      "li",
      (listItems) => listItems.length,
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
      list.map((element) => element.textContent),
    );

    const matches = texts.map((it) => {
      return new RegExp("New value").test(it as string);
    });

    expect(matches.includes(true)).toBeTruthy();
  });
});

describe("MultiNative", () => {
  it("Selects an item by input when there is no selection", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/MultiNative.elm`);
    const SUT = page.locator("[data-test-id=nativeMultiSelect]");

    // maps to "Is"
    await page.type("[data-test-id=nativeMultiSelect]", "i");
    await page.waitForTimeout(100);
    const selectedIndex: number = await SUT.evaluate(
      (el: HTMLSelectElement) => el.selectedIndex,
    );

    expect(selectedIndex).toBe(1);
  });

  it("Selects multiple items", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/MultiNative.elm`);
    const SUT = page.locator("[data-test-id=nativeMultiSelect]");

    // maps to "Is"
    await page.type("[data-test-id=nativeMultiSelect]", "i");
    await page.waitForTimeout(100);
    await page.keyboard.down("Shift");
    await page.keyboard.press("ArrowDown");
    await page.waitForTimeout(100);
    const selectedOptions: number = await SUT.evaluate(
      (el: HTMLSelectElement) => el.selectedOptions.length,
    );

    expect(selectedOptions).toBe(2);
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

describe("Single", () => {
  it("opens and closes then opens menu", async () => {
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/Single.elm`);

    await page.click("[data-test-id=selectContainer]");
    await page.waitForSelector("[data-test-id=listBox]");
    await page.click("[data-test-id=selectContainer]");
    await page.waitForTimeout(100);
    const listBoxVisible = await page.isVisible("[data-test-id=listBox]");

    expect(listBoxVisible).toBeFalsy();

    await page.click("[data-test-id=selectContainer]");
    await page.waitForTimeout(100);
    const listBoxVisibleAgain = await page.isVisible("[data-test-id=listBox]");

    expect(listBoxVisibleAgain).toBeTruthy();
  });
});

describe("SingleSearchable", () => {
  // LIST BOX
  it("list box visible after matching input", async () => {
    // @ts-ignore
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleSearchable.elm`);

    const listBoxInitiallyVisible = await page.isVisible(
      "[data-test-id=listBox]",
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
      "[data-text-id=selectContainer]",
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
      (el: HTMLInputElement) => el.value,
    );

    expect(inputValue).toBe("e");

    await page.click("[data-test-id=selectContainer]");
    await page.waitForTimeout(100);
    const updatedInputValue = await page.$eval(
      "[data-test-id=selectInput]",
      (el: HTMLInputElement) => el.value,
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
      (listItems) => listItems.length,
    );

    expect(listItemCount).toEqual(1);
  });
});

describe("SingleNativeGrouped", () => {
  it("Shows the optgroup node", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleNativeGrouped.elm`);

    const groupsVisible = await page.locator("optgroup").count();

    expect(groupsVisible).toEqual(1);
  });

  it("Does not show clear indicator when there is no selection", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleNativeGrouped.elm`);

    const clearVisible = await page.isVisible("[data-test-id=clear]");

    expect(clearVisible).toBeFalsy();
  });

  it("Shows clear indicator when there is a selection", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleNativeGrouped.elm`);

    await page.selectOption("select#SingleSelectExample__elm-select", {
      label: "Great",
    });
    await page.waitForSelector("[data-test-id=clear]");
    const clearVisible = await page.isVisible("[data-test-id=clear]");

    expect(clearVisible).toBeTruthy();
  });

  it("Selects the correct option when it is in a group", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleNativeGrouped.elm`);
    await page.type("[data-test-id=nativeSingleSelect]", "e");
    await page.waitForTimeout(100);

    const SUT = page.locator("[data-test-id=nativeSingleSelect]");
    const selectedIndex = await SUT.evaluate(
      (el: HTMLSelectElement) => el.selectedIndex,
    );
    const selectedText = await SUT.evaluate(
      (el: HTMLSelectElement) => el.selectedOptions[0].innerText,
    );

    expect([selectedIndex, selectedText]).toEqual([4, "Elm"]);
  });

  it("Clears a selected option", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleNativeGrouped.elm`);

    await page.selectOption("select#SingleSelectExample__elm-select", {
      label: "Great",
    });
    await page.waitForSelector("[data-test-id=clear]");
    await page.click("[data-test-id=clear]");
    await page.waitForTimeout(200);
    const selectedIndex: number = await page.$eval(
      "[data-test-id=nativeSingleSelect]",
      (el: HTMLSelectElement) => el.selectedIndex,
    );

    expect(selectedIndex).toBe(0);
  });
});

describe("SingleNative", () => {
  it("Selects item by input when there is no selection", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleNative.elm`);
    await page.type("[data-test-id=nativeSingleSelect]", "e");
    await page.waitForTimeout(100);

    const selectedIndex: number = await page.$eval(
      "[data-test-id=nativeSingleSelect]",
      (el: HTMLSelectElement) => el.selectedIndex,
    );

    expect(selectedIndex).toBe(0);
  });

  it("Selects item by input when there is already a selection", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleNative.elm`);

    await page.selectOption("select#SingleSelectExample__elm-select", {
      label: "Great",
    });
    await page.type("[data-test-id=nativeSingleSelect]", "e");
    await page.waitForTimeout(200);
    const selectedIndex: number = await page.$eval(
      "[data-test-id=nativeSingleSelect]",
      (el: HTMLSelectElement) => el.selectedIndex,
    );

    expect(selectedIndex).toBe(0);
  });

  it("selects item by dropdown select", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleNative.elm`);
    await page.selectOption("select#SingleSelectExample__elm-select", {
      label: "Great",
    });

    await page.waitForTimeout(200);
    const selectedIndex: number = await page.$eval(
      "[data-test-id=nativeSingleSelect]",
      (el: HTMLSelectElement) => el.selectedIndex,
    );

    expect(selectedIndex).toBe(3);
  });

  it("selected item has selected attribute", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${BASE_URI}/SingleNative.elm`);
    await page.selectOption("select#SingleSelectExample__elm-select", {
      label: "Great",
    });

    const isSelected: boolean = await page.$eval(
      "#SingleSelectExample__elm-select",
      (el: HTMLSelectElement) => {
        const selectedIndex = el.selectedIndex;
        return el.options[selectedIndex].selected;
      },
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
      "[data-test-id=listBox]",
    );

    expect(listBoxInitiallyVisible).toBeFalsy();

    await page.keyboard.press("ArrowDown");
    await page.waitForTimeout(100);

    const listBoxVisibleAfterAction = await page.isVisible(
      "[data-test-id=listBox]",
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
      "[data-test-id=listBoxItemTargetFocus0]",
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
      "[data-test-id=listBoxItemTargetFocus0]",
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
      "[data-test-id=listBoxItemTargetFocus0]",
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
      "[data-test-id=listBoxItemTargetFocus3]",
    );

    expect(lastItemFocused).toBeTruthy();

    await page.keyboard.press("ArrowDown");
    await page.waitForTimeout(100);

    const firstItemFocused = await page.isVisible(
      "[data-test-id=listBoxItemTargetFocus0]",
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
      "[data-test-id=listBoxItemTargetFocus3]",
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
      "[data-test-id=listBoxItemTargetFocus3]",
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
      "[data-test-id=selectedItem]",
    );

    expect(firstListItemSelected).toBeTruthy();

    const selectedItemInnerText = await page.innerText(
      "data-test-id=selectedItem",
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
      "[data-test-id=selectedItem]",
    );

    expect(firstListItemSelected).toBeTruthy();

    const selectedItemInnerText = await page.innerText(
      "data-test-id=selectedItem",
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
      (el: HTMLInputElement) => el.value,
    );

    expect(inputValue).toBe("e");

    await page.keyboard.press("Escape");
    await page.waitForTimeout(100);
    const updatedInputValue = await page.$eval(
      "[data-test-id=selectInput]",
      (el: HTMLInputElement) => el.value,
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
      "[data-test-id=listBox]",
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
      `[data-es-dynamic-select-input]`,
    );

    expect(dynamicAttribsVisibleBeforeFocus).toBeFalsy();

    await page.focus("[data-test-id=selectInput]");
    await page.waitForTimeout(15);
    const dynamicAttribsVisibleAfterFocus = await page.isVisible(
      `[data-es-dynamic-select-input]`,
    );

    expect(dynamicAttribsVisibleAfterFocus).toBeTruthy();
  });

  it("dynamically increases the input width when typing", async () => {
    await browser.newContext();
    const page = await browser.newPage();
    await page.goto(`${OPTIMIZED_BASE_URI}`);

    const defaultInputWidth = await page.$eval(
      "[data-test-id=selectInput]",
      (el: HTMLInputElement) => el.getBoundingClientRect().width,
    );

    await page.type("[data-test-id=selectInput]", "JAIME");
    await page.waitForTimeout(300);
    const currentInputWidth = await page.$eval(
      "[data-test-id=selectInput]",
      (el: HTMLInputElement) => el.getBoundingClientRect().width,
    );

    expect(currentInputWidth).toBeGreaterThan(defaultInputWidth);
  });
});
