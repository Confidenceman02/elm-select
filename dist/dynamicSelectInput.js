"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.dynamicSelectInput = void 0;
const noop = () => { };
let activeMutationObserver;
const config = { characterData: true, subtree: true };
const sizerCallback = (sizer, input, initialWidth, data) => () => {
    // Need to remove the initial width of the sizer to account for empty space.
    const currentSizerWidth = sizer.getBoundingClientRect().width - initialWidth;
    // We also need to add the default width of the input which accounts for the cursor
    const calculatedInputWidth = currentSizerWidth < data.defaultInputWidth
        ? data.defaultInputWidth
        : currentSizerWidth + data.defaultInputWidth;
    input.style.width = `${calculatedInputWidth.toString()}px`;
};
const initObserver = (sizer, input, nodeData) => {
    // The sizer does not start at 0px, we need to record the width and account for it in the calculation
    const initialSizerWidth = sizer.getBoundingClientRect().width;
    activeMutationObserver = new MutationObserver(sizerCallback(sizer, input, initialSizerWidth, nodeData));
    return activeMutationObserver;
};
function dynamicSelectInput(inputElement, props) {
    const sizerNode = document.getElementById(props.sizerId);
    if (sizerNode) {
        initObserver(sizerNode, inputElement, props).observe(sizerNode, config);
    }
    return {
        destroy: noop,
        update: noop,
    };
}
exports.dynamicSelectInput = dynamicSelectInput;
