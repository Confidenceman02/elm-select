## [12.2.2] - 2025-10-27

## Fixed

- Select native variant using Keyed for correct rendering during Elm diff
## [12.2.1] - 2025-09-11

## Fixed

- Title attribute on Tag when truncation config set for accessibility

## [12.2.0] - 2025-05-29

## Added

- SingleMenuVirtual variant

## [12.1.2] - 2025-01-19

## Fixed

- Unnecessary memory creation for virtualized menu items

## [12.1.1] - 2025-01-05

## Added

- RTL compatibility

## [12.1.0] - 2024-11-09

## Added

- Ability to configure indicator padding

## [12.0.1] - 2024-10-13

## Fixes

- MenuToggle action not being dispatched for unsearchable variants and some internal Msg's like InputEscape

## [12.0.0] - 2024-10-13

## Breaking

- Add MenuToggle Action

Will need to handle the MenuToggle action if you are exhaustively matching all actions in your update.

```elm
case action of
    -- ...  Other actions

    Just (Select.MenuToggle Select.MenuClose) ->
        -- Menu has been toggled and will close as a result

    Just (Select.MenuToggle Select.MenuOpen) ->
        -- Menu has been toggled and will open as a result
```

## [11.2.0] - 2024-09-14

## Added

- Support for 'required' attribute

## [11.1.0] - 2024-08-03

## Added

- Virtual scroll multi variant

## [11.0.0] - 2024-07-28

## Added

- Virtual scroll variant

## Breaking

- `Config` type now has extra param

This shouldn't cause any issues if you are not defining it anywhere in your
program.

Before

```elm
Config item
```

Current

```elm
Config item (MenuItems item)

-- OR for virtual scroll variants

Config item (VirtualItems item)
```

## [10.4.5] - 2024-07-13

## Fixed

- Tailwind box-shadow addition on search input

## [10.4.4] - 2024-06-22

## Fixed

- Off center multi select tags
- Wrapping multi select tags

## Added

- Default styles to match react-select

## [10.4.3] - 2024-06-21

## Fixed

- Native variant ugly border

## [10.4.2] - 2024-06-17

## Added

- Multi variant styles for boostrap4 theme

## [10.4.1] - 2024-05-08

## Added

- Hidden inputs for Multi variants for form submission compatibility

## [10.4.0] - 2024-03-17

## Added

- `staticSelectIdentifier` function for static id's

## [10.3.0] - 2024-03-17

## Added

- Bootstrap4 theme style pack
- mousedown and selected menu item color styles

## [10.2.0] - 2024-03-16

## Added

- Custom Single variant works in native forms (Requires `name` function)
- Ability to explicitly set a value attribute on a form submitted menu item

## [10.1.2] - 2023-08-26

## Added

- Illegal characters in identifier are replaced with "\_"

## [10.1.1] - 2023-08-18

## Fix

- Illegal characters in identifier

## [10.1.0] - 2023-08-11

## Added

- Conditionally dismissible tags

## Fix

- Illegal characters in css classes

## [10.0.1] - 2023-07-21

## Fix

- Illegal characters in css classes

## [10.0.0] - 2023-07-03

## Breaking changes

- `Focus` and `Blur` added to `Action` type.

## [9.0.3] - 2023-06-28

## Added

- Tailwind style border styles

## [9.0.2] - 2023-05-13

## Fixed

- Breaking styles from id string that contains forward slashes.

## [9.0.1] - 2023-05-13

## Fixed

- Breaking styles from id string that contains whitespace.

## [9.0.0] - 2023-05-13

## Added

- Auto publish for tagged releases.
- Added getMenuItemBackgroundColorHoverSelected & setMenuItemBackgroundColorHoverSelected to Styles config.

## Breaking changes

- Styles renamed to make more sense

```elm
    setMenuItemBackgroundColorClicked -> setMenuItemBackgroundColorMouseDown
    getMenuItemBackgroundColorClicked -> getMenuItemBackgroundColorMouseDown
    setMenuItemBackgroundColorNotSelected -> setMenuItemBackgroundColor
    getMenuItemBackgroundColorNotSelected -> getMenuItemBackgroundColor
    setMenuItemColorHoverNotSelected -> setMenuItemColorHover
    getMenuItemColorHoverNotSelected -> getMenuItemColorHover
```

## [8.2.1] - 2023-04-10

## Added

- Updated elm-css.
- Using `nodeLazy` for performance boost on huge lists.

## [8.2.0] - 2023-01-13

## Fixed

- Hard coded name attribute on native select.

## [8.1.0] - 2023-01-01

## Added

- More configurable styles for Multi tags

## [8.0.1] - 2022-12-31

## Fixed

- Missing documentation

## [8.0.0] - 2022-12-31

## Breaking changes

- The `Action` type has been simplified and has an additional action.

previous

```elm
type Action item
  = InputChange String
  | Select item
  | DeselectMulti (List item)
  | ClearSingleSelectItem
  | FocusSet
  | MenuInputCleared
```

current

```elm
type Action item
    = InputChange String
    | Select item
    | SelectBatch (List item)
    | Deselect (List item)
    | Clear
    | FocusSet
```

- All Custom variants should have a branch to handle the `Clear` `Action`.

```elm
case action of
    Just Clear ->
        -- The clear button has been pressed

    -- Other actions
```

- The multi native variant will solely use the `SelectBatch` action
  to determine the selected itmes. The multi select html node surfaces
  the selected items all together, so `SelectBatch` maps this behaviour.

It is not necessary to use the `Deselect` action for multi native variants.

## Added

- multi native variant

## [7.3.4] - 2022-12-30

## Fixed

- Broken README images.

## [7.3.3] - 2022-12-29

## Added

- Native clear action.

## [7.3.2] - 2022-12-27

## Added

- Native variant groups.

## [7.3.1] - 2022-12-25

## Fixed

- Documentation errors

## [7.3.0] - 2022-12-25

## Added

- Menu item groups.

## [7.2.0] - 2022-12-22

## Added

- Styling for individual menu items.

## [7.1.2] - 2022-12-04

## Fixed

- Disabled flag on native variant not working.

## [7.1.1] - 2022-11-27

## Added

- Loading spinner to Native variant.

## [7.1.0] - 2022-10-12

## Added

- Setter for setting the control `minHeight` property.

## [7.0.2] - 2022-10-12

## Fixed

- Dropdown icon not correctly centered on Native variant.

## [7.0.1] - 2022-10-04

## Fixed

- Loading menu opacity.

## [7.0.0] - 2022-10-03

## Added

- Clearable functionality for multi select variants.
- Keyed node on multi selected tags and input.

## Breaking changes

`DeselectMulti` `Action` now takes a `List` of multi items that have been deselected.

previous

```
case action of
    DeselectMulti item ->
        List.filter (\i -> item /= i) model.selectedItems
```

current

```
case action of
    DeselectMulti deselectedItems ->
        List.filter (\i -> not (List.member i deselectedItems))
```

## [6.3.2] - 2022-10-01

## Fixed

- Menu flickering open when dismissing multi select item on non-searchable variant.

## [6.3.1] - 2022-09-30

## Fixed

- Loading indicator not rendering when `searchable True` in config.

## [6.3.0] - 2022-09-19

## Added

- Configurable styles for menu border width.

## [6.2.2] - 2022-09-17

## Fixed

- Active target not resetting on input blur.
- `ContainerClicked` being dispatched on menu item elements.

## [6.2.1] - 2022-09-17

## Fixed

- Selected custom items not visually selected in menu variant list.

## [6.2.0] - 2022-09-16

## Added

- Configurable max height styles for menu.

## [6.1.0] - 2022-09-15

## Added

- Configurable position styles for menu.
- Hover style resolution for variants that show a menu without
  control focus.
- State modifier to keep menu open at all times.

## [6.0.2] - 2022-09-11

## Added

- Prevent default on unsearchable container clicks when input is focused.
  This avoids a blur event on the input.
- Conditionally focus input on unsearchable container click. Will only focus
  when the input is not currently focused. Reduces a DOM event.

## Fixed

- Placeholder not fully visible in unsearchable single variants.
- Clicking multiple times on unsearchable single variant container not
  opening and closing menu correctly.

## [6.0.1] - 2022-08-30

## Fixed

- Line height on tags when wrapping

## [6.0.0] - 2022-08-29

## Added

- Make menu variants.
- Add helper function isFocused, isMenuOpen.
- Add `Action`'s `FocusSet` and `MenuInputCleared`.
- Add focus function to open and focus a select variant.
- Improve docs around jsOptimize

## Breaking changes

Setting the `SelectId` now happens on `initState` instead
of the `view` function. This makes the `focus` function possible.

previous

```
view (single Nothing) (selectIndentifier "1234")
```

current

```
initState (selectIdentifier "1234")
```

## [5.4.0] - 2022-08-10

## Added

- Make multi tag dismiss icon background color configurable

## [5.3.2] - 2022-08-04

## Added

- Calling InputChange action with empty string on InputEscape and OnInputBlurrred

## [5.3.1] - 2022-08-03

## Fixed

- Center alignment for icons when document has large line-height set.

## [5.3.0] - 2022-08-03

## Added

- Exposing `Config` type

## [5.2.1] - 2022-08-03

## Added

- Relaxed elm/core lib

## [5.2.0] - 2022-08-02

## Added

- Menu item can be non filterable when component is searchable.

## [5.1.0] - 2022-08-01

## Added

- Multi tag border radius configurable

## [5.0.0] - 2022-07-28

## Added

- Multi variant tag styles to Styles module

## Breaking changes

`initMultiConfig` no longer required when using the `multi` builder.

previous

```
multi initMultiConfig selectedItems
```

current

```
multi selectedItems
```

Setting the multi tag color and truncation properties can be done via the `Styles` setters.

previous

```
multi
  (initMultiConfig
      |> truncateMultiTag 40
      |> multiTagColor (Css.hex "#E1E2EA")
  )
  []
```

current

```
let
  controlStyles =
      getControlConfig default
          |> setControlMultiTagTruncationWidth 40
          |> setControlMultiTagBackgroundColor (Css.hex "ddff33")

  customStyles =
      setControlStyles controlStyles default
in
multi []
    |> setStyles customStyles
```

## [4.1.2] - 2022-07-18

## Fixed

- Doubled up arrow events on dummy input.
- Focus ring on multi select tag.
- Center alignment of multi select tag value and close button.

## Added

- Latest elm-css version

## [4.1.1] - 2022-06-05

## Fixed

- [ Issue #67 ](https://github.com/Confidenceman02/elm-select/issues/67) [Kevin Lufkin ](https://github.com/klufkin)

## [4.1.0] - 2022-04-01

## Added

- customMenuItem builder
- All CI scripts added to Makefile
- Custom menu item example
- tests for CustomMenuItems.elm

## [4.0.0] - 2022-04-23

## Added

- MenuItem opaque types
- Builder function for MenuItem

## Breaking changes

The MenuItem type is now an opaque type that can be built with the `basicMenuItem` function.
The `basicMenuItem` function will take the previous `MenuItem` structure and wrap it.

previous

```
menuItem : MenuItem String
menuItem =
    { item: "SomeItem", label: "Some item" }
```

current

```
menuItem : MenuItem String
menuItem =
    basicMenuItem { item: "SomeItem", label: "Some item" }
```

## [3.2.2] - 2022-01-18

## Added

- Type attribute to clear indicator button set to "button".

## Fixed

- Issue #53
- Form submitting when interacting with clear button with 'Enter' key
  when select is in form element.

## [3.2.1] - 2022-01-10

- Added latest elm-css package

This fixes some weird DOM excetions that were
happening for SVG nodes.

https://github.com/rtfeldman/elm-css/issues/563
https://github.com/rtfeldman/elm-css/issues/543

## [3.2.0] - 2022-01-09

## Added

- Configurable styles for control and menu item border radius.

## [3.1.1] - 2021-12-30

## Added

- Placeholder option for native select variant.

## [3.1.0] - 2021-12-23

## Added

- loadingMessage modifier for setting loading message when there are no
  matching items.

## [3.0.2] - 2021-12-19

## Fixed

- CHANGELOG.md

## [3.0.1] - 2021-12-19

## Added

- CHANGELOG.md file

## [3.0.0] - 2021-12-13

## Added

- Configurable styles for menu item variant.
- Create dracula dark theme styles.

## Fixed

- Loading message styles.

## [2.0.2] - 2021-12-07

## Added

- Updated dependencies.

## [2.0.1] - 2021-12-07

## Fixed

- Broken/missing dependency `matken11235/html-styled-extra`.

## [2.0.0] - 2021-12-01

## Added

- Configurable styles for menu.

## Breaking changes

- Default style configs now must be extracted from a base config.
  Previously you could use a default config for the control, menu or menu items.

```
seectBranding =
    Styles.controlDefault
        |> Styles.setControlBorderColor (Css.hex "#C93B55")
        |> Styles.setControlStyles Styles.default
```

Now these configs can only be extracted from a default `Config`.

```
selectBranding =
    Styles.default
        |> Styles.setControlStyles controlBranding

controlBranding
    Styles.getControlConfig Styles.default
        |> Styles.setControlBorderColor (Css.hex "#C93B55")
```

## [1.5.1] - 2021-11-30

## Fixed

- Example error in README.md documentation.

## [1.5.0] - 2021-11-24

## Added

- Modifier for ariaDescribedBy for all variants.

## [1.4.0] - 2021-11-23

## Added

- Configurable background color for control styles.

## [1.3.0] - 2021-11-22

## Added

- Styles configuration for select variants to determine basic styles.
- Example for setting custom styles.

## Changed

- Internal modules to live in the `Select` directory.

## Fixed

- Flaky CI test. Bumped the wait time incase the palywritght runtime was too eager.
  It's not a solid fix but it fails much less.
- ClearIcon.elm color issues by adding a fill attribute and setting to currentColor.
- DotLoadingIcon.elm color issues by adding a fill attribute and setting to currentColor.
- DropDownIcon.elm color issues by adding a fill attribute and setting to currentColor.

## [1.2.0] - 2021-11-19

## Added

- Expose searcheable modifier to make menu items searchable.
- Add tests for non searchable variant.

## [1.1.0] - 2021-11-14

## Added

- Native select variant.
- Native select docs to `README.md`.

## [1.0.3] - 2021-08-08

## Added

- Confidenceman02/elm-select:1.0.2 to examples.
- README.md for examples.
- README.md for exmaples-optimized.
- Pics to README.md documentation.
- optimized examples to their own directory `examples-optimized`.

## Changed

- example mmodule names.

## Fixed

- Truncation example `Truncation.elm` which was using the wrong init function name.

## [1.0.2] - 2021-07-19

### Added

- ts declaration files to bundled package.
- Added tsc to build script.

## [1.0.1] - 2021-07-19

### Added

- Confidenceman02/elm-select npm package for javascript optimized example.

## [1.0.0] - 2021-07-19

### Added

- Project to elm packages [Confidenceman02/elm-select](https://package.elm-lang.org/packages/Confidenceman02/elm-select/1.0.0/)

[12.2.2]: https://github.com/Confidenceman02/elm-select/compare/12.2.1...12.2.2
[12.2.1]: https://github.com/Confidenceman02/elm-select/compare/12.2.0...12.2.1
[12.2.0]: https://github.com/Confidenceman02/elm-select/compare/12.1.2...12.2.0
[12.1.2]: https://github.com/Confidenceman02/elm-select/compare/12.1.1...12.1.2
[12.1.1]: https://github.com/Confidenceman02/elm-select/compare/12.1.0...12.1.1
[12.1.0]: https://github.com/Confidenceman02/elm-select/compare/12.0.1...12.1.0
[12.0.1]: https://github.com/Confidenceman02/elm-select/compare/11.2.0...12.0.1
[12.0.0]: https://github.com/Confidenceman02/elm-select/compare/11.2.0...12.0.0
[11.2.0]: https://github.com/Confidenceman02/elm-select/compare/11.1.0...11.2.0
[11.1.0]: https://github.com/Confidenceman02/elm-select/compare/11.0.0...11.1.0
[11.0.0]: https://github.com/Confidenceman02/elm-select/compare/10.4.5...11.0.0
[10.4.5]: https://github.com/Confidenceman02/elm-select/compare/10.4.4...10.4.5
[10.4.4]: https://github.com/Confidenceman02/elm-select/compare/10.4.3...10.4.4
[10.4.3]: https://github.com/Confidenceman02/elm-select/compare/10.4.2...10.4.3
[10.4.2]: https://github.com/Confidenceman02/elm-select/compare/10.4.1...10.4.2
[10.4.1]: https://github.com/Confidenceman02/elm-select/compare/10.4.0...10.4.1
[10.4.0]: https://github.com/Confidenceman02/elm-select/compare/10.3.0...10.4.0
[10.3.0]: https://github.com/Confidenceman02/elm-select/compare/10.2.0...10.3.0
[10.2.0]: https://github.com/Confidenceman02/elm-select/compare/10.1.1...10.2.0
[10.1.2]: https://github.com/Confidenceman02/elm-select/compare/10.1.1...10.1.2
[10.1.1]: https://github.com/Confidenceman02/elm-select/compare/10.1.0...10.1.1
[10.1.0]: https://github.com/Confidenceman02/elm-select/compare/10.0.1...10.1.0
[10.0.1]: https://github.com/Confidenceman02/elm-select/compare/10.0.0...10.0.1
[10.0.0]: https://github.com/Confidenceman02/elm-select/compare/9.0.2...10.0.0
[9.0.3]: https://github.com/Confidenceman02/elm-select/compare/9.0.2...9.0.3
[9.0.2]: https://github.com/Confidenceman02/elm-select/compare/9.0.1...9.0.2
[9.0.1]: https://github.com/Confidenceman02/elm-select/compare/9.0.0...9.0.1
[9.0.0]: https://github.com/Confidenceman02/elm-select/compare/8.2.1...9.0.0
[8.2.1]: https://github.com/Confidenceman02/elm-select/compare/8.2.0...8.2.1
[8.2.0]: https://github.com/Confidenceman02/elm-select/compare/8.1.0...8.2.0
[8.1.0]: https://github.com/Confidenceman02/elm-select/compare/8.0.1...8.1.0
[8.0.1]: https://github.com/Confidenceman02/elm-select/compare/8.0.0...8.0.1
[8.0.0]: https://github.com/Confidenceman02/elm-select/compare/7.3.4...8.0.0
[7.3.4]: https://github.com/Confidenceman02/elm-select/compare/7.3.3...7.3.4
[7.3.3]: https://github.com/Confidenceman02/elm-select/compare/7.3.2...7.3.3
[7.3.2]: https://github.com/Confidenceman02/elm-select/compare/7.3.1...7.3.2
[7.3.1]: https://github.com/Confidenceman02/elm-select/compare/7.3.0...7.3.1
[7.3.0]: https://github.com/Confidenceman02/elm-select/compare/7.2.0...7.3.0
[7.2.0]: https://github.com/Confidenceman02/elm-select/compare/7.1.2...7.2.0
[7.1.2]: https://github.com/Confidenceman02/elm-select/compare/7.1.1...7.1.2
[7.1.1]: https://github.com/Confidenceman02/elm-select/compare/7.1.0...7.1.1
[7.1.0]: https://github.com/Confidenceman02/elm-select/compare/7.0.2...7.1.0
[7.0.2]: https://github.com/Confidenceman02/elm-select/compare/7.0.1...7.0.2
[7.0.1]: https://github.com/Confidenceman02/elm-select/compare/7.0.0...7.0.1
[7.0.0]: https://github.com/Confidenceman02/elm-select/compare/6.3.2...7.0.0
[6.3.2]: https://github.com/Confidenceman02/elm-select/compare/6.3.1...6.3.2
[6.3.1]: https://github.com/Confidenceman02/elm-select/compare/6.3.0...6.3.1
[6.3.0]: https://github.com/Confidenceman02/elm-select/compare/6.2.2...6.3.0
[6.2.2]: https://github.com/Confidenceman02/elm-select/compare/6.2.1...6.2.2
[6.2.1]: https://github.com/Confidenceman02/elm-select/compare/6.2.0...6.2.1
[6.2.0]: https://github.com/Confidenceman02/elm-select/compare/6.1.0...6.2.0
[6.1.0]: https://github.com/Confidenceman02/elm-select/compare/6.0.2...6.1.0
[6.0.2]: https://github.com/Confidenceman02/elm-select/compare/6.0.1...6.0.2
[6.0.1]: https://github.com/Confidenceman02/elm-select/compare/6.0.0...6.0.1
[6.0.0]: https://github.com/Confidenceman02/elm-select/compare/5.4.0...6.0.0
[5.4.0]: https://github.com/Confidenceman02/elm-select/compare/5.3.2...5.4.0
[5.3.2]: https://github.com/Confidenceman02/elm-select/compare/5.3.1...5.3.2
[5.3.1]: https://github.com/Confidenceman02/elm-select/compare/5.3.0...5.3.1
[5.3.0]: https://github.com/Confidenceman02/elm-select/compare/5.2.1...5.3.0
[5.2.1]: https://github.com/Confidenceman02/elm-select/compare/5.2.0...5.2.1
[5.2.0]: https://github.com/Confidenceman02/elm-select/compare/5.1.0...5.2.0
[5.1.0]: https://github.com/Confidenceman02/elm-select/compare/5.0.0...5.1.0
[5.0.0]: https://github.com/Confidenceman02/elm-select/compare/4.1.2...5.0.0
[4.1.2]: https://github.com/Confidenceman02/elm-select/compare/4.1.1...4.1.2
[4.1.1]: https://github.com/Confidenceman02/elm-select/compare/4.1.0...4.1.1
[4.1.0]: https://github.com/Confidenceman02/elm-select/compare/4.0.0...4.1.0
[4.0.0]: https://github.com/Confidenceman02/elm-select/compare/3.2.2...4.0.0
[3.2.2]: https://github.com/Confidenceman02/elm-select/compare/3.2.1...3.2.2
[3.2.1]: https://github.com/Confidenceman02/elm-select/compare/3.2.0...3.2.1
[3.2.0]: https://github.com/Confidenceman02/elm-select/compare/3.1.1...3.2.0
[3.1.1]: https://github.com/Confidenceman02/elm-select/compare/3.1.0...3.1.1
[3.1.0]: https://github.com/Confidenceman02/elm-select/compare/3.0.2...3.1.0
[3.0.2]: https://github.com/Confidenceman02/elm-select/compare/3.0.1...3.0.2
[3.0.1]: https://github.com/Confidenceman02/elm-select/compare/3.0.0...3.0.1
[3.0.0]: https://github.com/Confidenceman02/elm-select/compare/2.0.2...3.0.0
[2.0.2]: https://github.com/Confidenceman02/elm-select/compare/2.0.1...2.0.2
[2.0.1]: https://github.com/Confidenceman02/elm-select/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/Confidenceman02/elm-select/compare/1.5.0...2.0.0
[1.5.0]: https://github.com/Confidenceman02/elm-select/compare/1.4.0...1.5.0
[1.4.0]: https://github.com/Confidenceman02/elm-select/compare/1.3.0...1.4.0
[1.3.0]: https://github.com/Confidenceman02/elm-select/compare/1.2.0...1.3.0
[1.2.0]: https://github.com/Confidenceman02/elm-select/compare/1.1.0...1.2.0
[1.1.0]: https://github.com/Confidenceman02/elm-select/compare/1.0.3...1.1.0
[1.0.3]: https://github.com/Confidenceman02/elm-select/compare/1.0.2...1.0.3
[1.0.2]: https://github.com/Confidenceman02/elm-select/compare/1.0.1...1.0.2
[1.0.1]: https://github.com/Confidenceman02/elm-select/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/Confidenceman02/elm-select/releases/1.0.0
