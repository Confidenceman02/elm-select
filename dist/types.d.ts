export declare type DefoViews = {
    [key: string]: DefoFunction;
};
export declare type DefoFunction = (el: HTMLElement, props: any) => DefoFunctionReturnValue;
export declare type DefoFunctionReturnValue = {
    destroy?: () => void;
    update?: (props: any) => void;
};
export declare type DynamicSelectInputProps = {
    sizerId: string;
    defaultInputWidth: number;
};
