import { DefoFunctionReturnValue, DynamicSelectInputProps } from "./types";

const noop = () => {};

let activeMutationObserver: MutationObserver | undefined;

const config: MutationObserverInit = { characterData: true, subtree: true };

const sizerCallback =
  (
    sizer: HTMLElement,
    input: HTMLElement,
    initialWidth: number,
    data: DynamicSelectInputProps
  ): MutationCallback =>
  () => {
    // Need to remove the initial width of the sizer to account for empty space.
    const currentSizerWidth: number =
      sizer.getBoundingClientRect().width - initialWidth;
    // We also need to add the default width of the input which accounts for the cursor
    const calculatedInputWidth =
      currentSizerWidth < data.defaultInputWidth
        ? data.defaultInputWidth
        : currentSizerWidth + data.defaultInputWidth;
    input.style.width = `${calculatedInputWidth.toString()}px`;
  };

const initObserver = (
  sizer: HTMLElement,
  input: HTMLElement,
  nodeData: DynamicSelectInputProps
): MutationObserver => {
  // The sizer does not start at 0px, we need to record the width and account for it in the calculation
  const initialSizerWidth: number = sizer.getBoundingClientRect().width;
  activeMutationObserver = new MutationObserver(
    sizerCallback(sizer, input, initialSizerWidth, nodeData)
  );
  return activeMutationObserver;
};

export function dynamicSelectInput(
  inputElement: HTMLElement,
  props: DynamicSelectInputProps
): DefoFunctionReturnValue {
  const sizerNode = document.getElementById(props.sizerId);
  if (sizerNode) {
    initObserver(sizerNode, inputElement, props).observe(sizerNode, config);
  }
  return {
    destroy: noop,
    update: noop,
  };
}
