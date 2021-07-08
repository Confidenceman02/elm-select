export type DefoViews = {
  [key: string]: DefoFunction;
};

export type DefoFunction = (
  el: HTMLElement,
  props: any
) => DefoFunctionReturnValue;

export type DefoFunctionReturnValue = {
  destroy?: () => void;
  update?: (props: any) => void;
};
