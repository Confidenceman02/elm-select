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
