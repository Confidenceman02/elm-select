module Select.Styles exposing
    ( Config, ControlConfig, MenuConfig, MenuItemConfig, default
    , setControlStyles, setControlBackgroundColor, setControlBackgroundColorHover, setControlBorderColor, setControlBorderColorFocus, setControlBorderColorHover, setControlBorderRadius, setControlColor, setControlClearIndicatorColor
    , setControlClearIndicatorColorHover, setControlDisabledOpacity, setControlDropdownIndicatorColor, setControlDropdownIndicatorColorHover
    , setControlLoadingIndicatorColor, setControlSelectedColor, setControlPlaceholderOpacity, setControlSeparatorColor
    , setMenuStyles, setMenuBackgroundColor, setMenuBorderRadius, setMenuBoxShadowBlur, setMenuBoxShadowColor, setMenuBoxShadowHOffset, setMenuBoxShadowVOffset
    , setMenuItemStyles, setMenuItemBackgroundColorClicked, setMenuItemBackgroundColorSelected, setMenuItemBlockPadding, setMenuItemBorderRadius, setMenuItemColor, setMenuItemBackgroundColorNotSelected, setMenuItemColorHoverSelected, setMenuItemInlinePadding
    , setMenuItemColorHoverNotSelected
    , getControlConfig, getControlBackgroundColor, getControlBackgroundColorHover, getControlBorderColor, getControlColor, getControlBorderColorFocus, getControlBorderColorHover, getControlBorderRadius, getControlClearIndicatorColor
    , getControlClearIndicatorColorHover, getControlDisabledOpacity, getControlDropdownIndicatorColor, getControlDropdownIndicatorColorHover
    , getControlLoadingIndicatorColor, getControlPlaceholderOpacity, getControlSelectedColor, getControlSeparatorColor
    , getMenuConfig, getMenuBackgroundColor, getMenuBorderRadius, getMenuBoxShadowColor, getMenuBoxShadowHOffset, getMenuBoxShadowVOffset, getMenuBoxShadowBlur
    , getMenuItemConfig, getMenuItemBackgroundColorSelected, getMenuItemBackgroundColorClicked, getMenuItemBlockPadding, getMenuItemBorderRadius, getMenuItemColor, getMenuItemColorHoverSelected, getMenuItemColorHoverNotSelected, getMenuItemInlinePadding
    , getMenuItemBackgroundColorNotSelected
    , dracula
    )

{-| Add custom styling to the Select control, menu and menu item.

![elm-select](https://Confidenceman02.github.io/elm-select/StylesModules.png)


# Set up

Styles for the different sections of the Select all have their own configuration.
This means when you are setting styles to the [MenuConfig](#MenuConfig) you can only use the
[Setters](#setters) for the MenuConfig.

NOTE: The [native](/packages/Confidenceman02/elm-select/latest/Select#singleNative) Select variant
only respects some of the styles.

@docs Config, ControlConfig, MenuConfig, MenuItemConfig, default


# Setters

Set styles


## Control

@docs setControlStyles, setControlBackgroundColor, setControlBackgroundColorHover, setControlBorderColor, setControlBorderColorFocus, setControlBorderColorHover, setControlBorderRadius, setControlColor, setControlClearIndicatorColor
@docs setControlClearIndicatorColorHover, setControlDisabledOpacity, setControlDropdownIndicatorColor, setControlDropdownIndicatorColorHover
@docs setControlLoadingIndicatorColor, setControlSelectedColor, setControlPlaceholderOpacity, setControlSeparatorColor


# Menu

@docs setMenuStyles, setMenuBackgroundColor, setMenuBorderRadius, setMenuBoxShadowBlur, setMenuBoxShadowColor, setMenuBoxShadowHOffset, setMenuBoxShadowVOffset


# Menu item

@docs setMenuItemStyles, setMenuItemBackgroundColorClicked, setMenuItemBackgroundColorSelected, setMenuItemBlockPadding, setMenuItemBorderRadius, setMenuItemColor, setMenuItemBackgroundColorNotSelected, setMenuItemColorHoverSelected, setMenuItemInlinePadding
@docs setMenuItemColorHoverNotSelected


# Getters

Get styles


## Control

@docs getControlConfig, getControlBackgroundColor, getControlBackgroundColorHover, getControlBorderColor, getControlColor, getControlBorderColorFocus, getControlBorderColorHover, getControlBorderRadius, getControlClearIndicatorColor
@docs getControlClearIndicatorColorHover, getControlDisabledOpacity, getControlDropdownIndicatorColor, getControlDropdownIndicatorColorHover
@docs getControlLoadingIndicatorColor, getControlPlaceholderOpacity, getControlSelectedColor, getControlSeparatorColor


# Menu

@docs getMenuConfig, getMenuBackgroundColor, getMenuBorderRadius, getMenuBoxShadowColor, getMenuBoxShadowHOffset, getMenuBoxShadowVOffset, getMenuBoxShadowBlur


# Menu item

@docs getMenuItemConfig, getMenuItemBackgroundColorSelected, getMenuItemBackgroundColorClicked, getMenuItemBlockPadding, getMenuItemBorderRadius, getMenuItemColor, getMenuItemColorHoverSelected, getMenuItemColorHoverNotSelected, getMenuItemInlinePadding

@docs getMenuItemBackgroundColorNotSelected


# Theme

@docs dracula

-}

import Css


{-| -}
type Config
    = Config Configuration


{-| -}
type ControlConfig
    = ControlConfig ControlConfiguration


{-| -}
type MenuConfig
    = MenuConfig MenuConfiguration


{-| -}
type MenuItemConfig
    = MenuItemConfig MenuItemConfiguration


type alias MenuItemConfiguration =
    { backgroundColorClicked : Css.Color
    , backgroundColorSelected : Css.Color
    , backgroundColorNotSelected : Css.Color
    , blockPadding : Float
    , borderRadius : Float
    , color : Css.Color
    , colorHoverSelected : Css.Color
    , colorHoverNotSelected : Css.Color
    , inlinePadding : Float
    }


type alias MenuConfiguration =
    { backgroundColor : Css.Color
    , borderRadius : Float
    , boxShadowBlur : Float
    , boxShadowColor : Css.Color
    , boxShadowHOffset : Float
    , boxShadowVOffset : Float
    }


type alias ControlConfiguration =
    { backgroundColor : Css.Color
    , backgroundColorHover : Css.Color
    , borderColor : Css.Color
    , borderColorFocus : Css.Color
    , borderColorHover : Css.Color
    , borderRadius : Float
    , clearIndicatorColor : Css.Color
    , clearIndicatorColorHover : Css.Color
    , color : Css.Color
    , disabledOpacity : Float
    , dropdownIndicatorColor : Css.Color
    , dropdownIndicatorColorHover : Css.Color
    , loadingIndicatorColor : Css.Color
    , placeholderOpacity : Float
    , selectedColor : Css.Color
    , separatorColor : Css.Color
    }


type alias Configuration =
    { controlConfig : ControlConfig
    , menuConfig : MenuConfig
    , menuItemConfig : MenuItemConfig
    }


defaultsMenuItem : MenuItemConfiguration
defaultsMenuItem =
    { backgroundColorClicked = Css.hex "#E6F0F7"
    , backgroundColorSelected = Css.hex "#E6F0F7"
    , backgroundColorNotSelected = Css.hex "#E6F0F7"
    , blockPadding = 8
    , borderRadius = 4
    , color = Css.hex "#000000"
    , colorHoverSelected = Css.hex "#0168B3"
    , colorHoverNotSelected = Css.hex "#0168B3"
    , inlinePadding = 8
    }


defaultsMenu : MenuConfiguration
defaultsMenu =
    { backgroundColor = Css.hex "#FFFFFF"
    , borderRadius = 7
    , boxShadowBlur = 12
    , boxShadowColor = Css.rgba 0 0 0 0.19
    , boxShadowHOffset = 0
    , boxShadowVOffset = 0
    }


defaultsControl : ControlConfiguration
defaultsControl =
    { backgroundColor = Css.hex "#FFFFFF"
    , backgroundColorHover = Css.hex "#F0F1F4"
    , borderColor = Css.hex "#898BA9"
    , borderColorFocus = Css.hex "#0168b3"
    , borderColorHover = Css.hex "#4B4D68"
    , borderRadius = 7
    , clearIndicatorColor = Css.rgb 102 102 102
    , clearIndicatorColorHover = Css.rgb 51 51 51
    , color = Css.hex "#000000"
    , disabledOpacity = 0.3
    , dropdownIndicatorColor = Css.rgb 102 102 102
    , dropdownIndicatorColorHover = Css.rgb 51 51 51
    , loadingIndicatorColor = Css.rgb 102 102 102
    , placeholderOpacity = 0.5
    , selectedColor = Css.hex "#35374A"
    , separatorColor = Css.rgb 204 204 204
    }


menuItemDefault : MenuItemConfig
menuItemDefault =
    MenuItemConfig defaultsMenuItem


menuDefault : MenuConfig
menuDefault =
    MenuConfig defaultsMenu


controlDefault : ControlConfig
controlDefault =
    ControlConfig defaultsControl


defaults : Configuration
defaults =
    { controlConfig = controlDefault
    , menuConfig = menuDefault
    , menuItemConfig = menuItemDefault
    }


{-| The default styling for the select

This is the [Config](#Config) that all select variants use if no styles
have been configured.

-}
default : Config
default =
    Config defaults



-- SETTERS MENU ITEM


{-| -}
setMenuItemBackgroundColorClicked : Css.Color -> MenuItemConfig -> MenuItemConfig
setMenuItemBackgroundColorClicked c (MenuItemConfig config) =
    MenuItemConfig { config | backgroundColorClicked = c }


{-| -}
setMenuItemBackgroundColorSelected : Css.Color -> MenuItemConfig -> MenuItemConfig
setMenuItemBackgroundColorSelected c (MenuItemConfig config) =
    MenuItemConfig { config | backgroundColorSelected = c }


{-| -}
setMenuItemBackgroundColorNotSelected : Css.Color -> MenuItemConfig -> MenuItemConfig
setMenuItemBackgroundColorNotSelected c (MenuItemConfig config) =
    MenuItemConfig { config | backgroundColorNotSelected = c }


{-| -}
setMenuItemBlockPadding : Float -> MenuItemConfig -> MenuItemConfig
setMenuItemBlockPadding f (MenuItemConfig config) =
    MenuItemConfig { config | blockPadding = f }


{-| -}
setMenuItemBorderRadius : Float -> MenuItemConfig -> MenuItemConfig
setMenuItemBorderRadius f (MenuItemConfig config) =
    MenuItemConfig { config | borderRadius = f }


{-| -}
setMenuItemColor : Css.Color -> MenuItemConfig -> MenuItemConfig
setMenuItemColor c (MenuItemConfig config) =
    MenuItemConfig { config | color = c }


{-| -}
setMenuItemColorHoverSelected : Css.Color -> MenuItemConfig -> MenuItemConfig
setMenuItemColorHoverSelected c (MenuItemConfig config) =
    MenuItemConfig { config | colorHoverSelected = c }


{-| -}
setMenuItemColorHoverNotSelected : Css.Color -> MenuItemConfig -> MenuItemConfig
setMenuItemColorHoverNotSelected c (MenuItemConfig config) =
    MenuItemConfig { config | colorHoverNotSelected = c }


{-| -}
setMenuItemInlinePadding : Float -> MenuItemConfig -> MenuItemConfig
setMenuItemInlinePadding f (MenuItemConfig config) =
    MenuItemConfig { config | inlinePadding = f }



-- SETTERS MENU STYLES


{-| -}
setMenuBackgroundColor : Css.Color -> MenuConfig -> MenuConfig
setMenuBackgroundColor c (MenuConfig config) =
    MenuConfig { config | backgroundColor = c }


{-| -}
setMenuBorderRadius : Float -> MenuConfig -> MenuConfig
setMenuBorderRadius f (MenuConfig config) =
    MenuConfig { config | borderRadius = f }


{-| -}
setMenuBoxShadowBlur : Float -> MenuConfig -> MenuConfig
setMenuBoxShadowBlur f (MenuConfig config) =
    MenuConfig { config | boxShadowBlur = f }


{-| -}
setMenuBoxShadowColor : Css.Color -> MenuConfig -> MenuConfig
setMenuBoxShadowColor c (MenuConfig config) =
    MenuConfig { config | boxShadowColor = c }


{-| -}
setMenuBoxShadowHOffset : Float -> MenuConfig -> MenuConfig
setMenuBoxShadowHOffset f (MenuConfig config) =
    MenuConfig { config | boxShadowHOffset = f }


{-| -}
setMenuBoxShadowVOffset : Float -> MenuConfig -> MenuConfig
setMenuBoxShadowVOffset f (MenuConfig config) =
    MenuConfig { config | boxShadowVOffset = f }



-- SETTERS CONTROL STYLES


{-| -}
setControlBackgroundColor : Css.Color -> ControlConfig -> ControlConfig
setControlBackgroundColor c (ControlConfig config) =
    ControlConfig { config | backgroundColor = c }


{-| -}
setControlBackgroundColorHover : Css.Color -> ControlConfig -> ControlConfig
setControlBackgroundColorHover c (ControlConfig config) =
    ControlConfig { config | backgroundColorHover = c }


{-| -}
setControlBorderColor : Css.Color -> ControlConfig -> ControlConfig
setControlBorderColor c (ControlConfig config) =
    ControlConfig { config | borderColor = c }


{-| -}
setControlBorderColorFocus : Css.Color -> ControlConfig -> ControlConfig
setControlBorderColorFocus c (ControlConfig config) =
    ControlConfig { config | borderColorFocus = c }


{-| -}
setControlBorderColorHover : Css.Color -> ControlConfig -> ControlConfig
setControlBorderColorHover c (ControlConfig config) =
    ControlConfig { config | borderColorHover = c }


{-| -}
setControlBorderRadius : Float -> ControlConfig -> ControlConfig
setControlBorderRadius f (ControlConfig config) =
    ControlConfig { config | borderRadius = f }


{-| -}
setControlClearIndicatorColor : Css.Color -> ControlConfig -> ControlConfig
setControlClearIndicatorColor c (ControlConfig config) =
    ControlConfig { config | clearIndicatorColor = c }


{-| -}
setControlClearIndicatorColorHover : Css.Color -> ControlConfig -> ControlConfig
setControlClearIndicatorColorHover c (ControlConfig config) =
    ControlConfig { config | clearIndicatorColorHover = c }


{-| -}
setControlColor : Css.Color -> ControlConfig -> ControlConfig
setControlColor c (ControlConfig config) =
    ControlConfig { config | color = c }


{-| -}
setControlDisabledOpacity : Float -> ControlConfig -> ControlConfig
setControlDisabledOpacity f (ControlConfig config) =
    ControlConfig { config | disabledOpacity = f }


{-| -}
setControlDropdownIndicatorColor : Css.Color -> ControlConfig -> ControlConfig
setControlDropdownIndicatorColor c (ControlConfig config) =
    ControlConfig { config | dropdownIndicatorColor = c }


{-| -}
setControlDropdownIndicatorColorHover : Css.Color -> ControlConfig -> ControlConfig
setControlDropdownIndicatorColorHover c (ControlConfig config) =
    ControlConfig { config | dropdownIndicatorColorHover = c }


{-| -}
setControlLoadingIndicatorColor : Css.Color -> ControlConfig -> ControlConfig
setControlLoadingIndicatorColor c (ControlConfig config) =
    ControlConfig { config | loadingIndicatorColor = c }


{-| -}
setControlPlaceholderOpacity : Float -> ControlConfig -> ControlConfig
setControlPlaceholderOpacity f (ControlConfig config) =
    ControlConfig { config | placeholderOpacity = f }


{-| -}
setControlSelectedColor : Css.Color -> ControlConfig -> ControlConfig
setControlSelectedColor c (ControlConfig config) =
    ControlConfig { config | selectedColor = c }


{-| -}
setControlSeparatorColor : Css.Color -> ControlConfig -> ControlConfig
setControlSeparatorColor c (ControlConfig config) =
    ControlConfig { config | separatorColor = c }



-- MODIFIERS


{-| Set styles for the select control

        controlBranding : ControlConfig
        controlBranding =
            getControlConfig default
                |> setControlBorderColor (Css.hex "#FFFFFF")
                |> setControlBorderColorFocus (Css.hex "#0168B3")

        selectBranding : Config
        selectBranding
            default
                |> setControlStyles controlBranding

-}
setControlStyles : ControlConfig -> Config -> Config
setControlStyles controlConfig (Config config) =
    Config { config | controlConfig = controlConfig }


{-| Set styles for the Select menu

        menuBranding : MenuConfig
        menuBranding =
            getMenuConfig default
                |> setMenuBackgroundColor (Css.hex "#000000")
                |> setMenuBorderRadius 4


        selectBranding : Config
        selectBranding
            default
                |> setMenuStyles menuBranding

-}
setMenuStyles : MenuConfig -> Config -> Config
setMenuStyles menuConfig (Config config) =
    Config { config | menuConfig = menuConfig }


{-| Set styles for Select menu item

        menuItemBranding : MenuItemConfig
        menuItemBranding =
            getMenuItemConfig default
                |> setMenuItemBackgroundColorNotSelected (Css.hex "#000000")


        selectBranding : Config
        selectBranding
                default
                    |> setMenuItemStyles menuItemBranding

-}
setMenuItemStyles : MenuItemConfig -> Config -> Config
setMenuItemStyles menuItemConfig (Config config) =
    Config { config | menuItemConfig = menuItemConfig }



-- GETTERS MENU ITEM


{-| Get the MenuItemConfig

    baseStyles : Config
    baseStyles =
        default

    baseMenuStyles : MenuItemConfig
    baseMenuStyles =
        getMenuItemConfig baseStyles
            |> setMenuItemBackgroundColorSelected (Css.hex "#000000")

-}
getMenuItemConfig : Config -> MenuItemConfig
getMenuItemConfig (Config config) =
    config.menuItemConfig


{-| -}
getMenuItemBackgroundColorClicked : MenuItemConfig -> Css.Color
getMenuItemBackgroundColorClicked (MenuItemConfig config) =
    config.backgroundColorClicked


{-| -}
getMenuItemBackgroundColorSelected : MenuItemConfig -> Css.Color
getMenuItemBackgroundColorSelected (MenuItemConfig config) =
    config.backgroundColorSelected


{-| -}
getMenuItemBackgroundColorNotSelected : MenuItemConfig -> Css.Color
getMenuItemBackgroundColorNotSelected (MenuItemConfig config) =
    config.backgroundColorNotSelected


{-| -}
getMenuItemBlockPadding : MenuItemConfig -> Float
getMenuItemBlockPadding (MenuItemConfig config) =
    config.blockPadding


{-| -}
getMenuItemBorderRadius : MenuItemConfig -> Float
getMenuItemBorderRadius (MenuItemConfig config) =
    config.borderRadius


{-| -}
getMenuItemColor : MenuItemConfig -> Css.Color
getMenuItemColor (MenuItemConfig config) =
    config.color


{-| -}
getMenuItemColorHoverSelected : MenuItemConfig -> Css.Color
getMenuItemColorHoverSelected (MenuItemConfig config) =
    config.colorHoverSelected


{-| -}
getMenuItemColorHoverNotSelected : MenuItemConfig -> Css.Color
getMenuItemColorHoverNotSelected (MenuItemConfig config) =
    config.colorHoverNotSelected


{-| -}
getMenuItemInlinePadding : MenuItemConfig -> Float
getMenuItemInlinePadding (MenuItemConfig config) =
    config.inlinePadding



-- GETTERS MENU STYLES


{-| Get the [MenuConfig](#MenuConfig)

    baseStyles : Config
    baseStyles =
        default

    baseMenuStyles : MenuConfig
    baseMenuStyles =
        getMenuConfig baseStyles
            |> setMenuBorderRadius 4

-}
getMenuConfig : Config -> MenuConfig
getMenuConfig (Config config) =
    config.menuConfig


{-| -}
getMenuBackgroundColor : MenuConfig -> Css.Color
getMenuBackgroundColor (MenuConfig config) =
    config.backgroundColor


{-| -}
getMenuBorderRadius : MenuConfig -> Float
getMenuBorderRadius (MenuConfig config) =
    config.borderRadius


{-| -}
getMenuBoxShadowBlur : MenuConfig -> Float
getMenuBoxShadowBlur (MenuConfig config) =
    config.boxShadowBlur


{-| -}
getMenuBoxShadowColor : MenuConfig -> Css.Color
getMenuBoxShadowColor (MenuConfig config) =
    config.boxShadowColor


{-| -}
getMenuBoxShadowHOffset : MenuConfig -> Float
getMenuBoxShadowHOffset (MenuConfig config) =
    config.boxShadowHOffset


{-| -}
getMenuBoxShadowVOffset : MenuConfig -> Float
getMenuBoxShadowVOffset (MenuConfig config) =
    config.boxShadowVOffset



-- GETTERS CONTROL STYLES


{-| Get the [ControlConfig](#ControlConfig)

    baseStyles : Config
    baseStyles =
        default

    baseControlStyles : ControlConfig
    baseControlStyles =
        getControlConfig baseStyles
            |> setControlBorderColor (Css.hex "ffffff")

-}
getControlConfig : Config -> ControlConfig
getControlConfig (Config config) =
    config.controlConfig


{-| -}
getControlBackgroundColor : ControlConfig -> Css.Color
getControlBackgroundColor (ControlConfig config) =
    config.backgroundColor


{-| -}
getControlBackgroundColorHover : ControlConfig -> Css.Color
getControlBackgroundColorHover (ControlConfig config) =
    config.backgroundColorHover


{-| -}
getControlBorderColor : ControlConfig -> Css.Color
getControlBorderColor (ControlConfig config) =
    config.borderColor


{-| -}
getControlBorderColorFocus : ControlConfig -> Css.Color
getControlBorderColorFocus (ControlConfig config) =
    config.borderColorFocus


{-| -}
getControlBorderRadius : ControlConfig -> Float
getControlBorderRadius (ControlConfig config) =
    config.borderRadius


{-| -}
getControlPlaceholderOpacity : ControlConfig -> Float
getControlPlaceholderOpacity (ControlConfig config) =
    config.placeholderOpacity


{-| -}
getControlBorderColorHover : ControlConfig -> Css.Color
getControlBorderColorHover (ControlConfig config) =
    config.borderColorHover


{-| -}
getControlColor : ControlConfig -> Css.Color
getControlColor (ControlConfig config) =
    config.color


{-| -}
getControlSelectedColor : ControlConfig -> Css.Color
getControlSelectedColor (ControlConfig config) =
    config.selectedColor


{-| -}
getControlSeparatorColor : ControlConfig -> Css.Color
getControlSeparatorColor (ControlConfig config) =
    config.separatorColor


{-| -}
getControlClearIndicatorColor : ControlConfig -> Css.Color
getControlClearIndicatorColor (ControlConfig config) =
    config.clearIndicatorColor


{-| -}
getControlClearIndicatorColorHover : ControlConfig -> Css.Color
getControlClearIndicatorColorHover (ControlConfig config) =
    config.clearIndicatorColorHover


{-| -}
getControlDropdownIndicatorColor : ControlConfig -> Css.Color
getControlDropdownIndicatorColor (ControlConfig config) =
    config.dropdownIndicatorColor


{-| -}
getControlDropdownIndicatorColorHover : ControlConfig -> Css.Color
getControlDropdownIndicatorColorHover (ControlConfig config) =
    config.dropdownIndicatorColorHover


{-| -}
getControlLoadingIndicatorColor : ControlConfig -> Css.Color
getControlLoadingIndicatorColor (ControlConfig config) =
    config.loadingIndicatorColor


{-| -}
getControlDisabledOpacity : ControlConfig -> Float
getControlDisabledOpacity (ControlConfig config) =
    config.disabledOpacity


{-| A fun dark theme

![elm-select](https://Confidenceman02.github.io/elm-select/DraculaTheme.png)

-}
dracula : Config
dracula =
    default
        |> setControlStyles draculaControl
        |> setMenuStyles draculaMenu
        |> setMenuItemStyles draculaMenuItem


draculaControl : ControlConfig
draculaControl =
    getControlConfig default
        |> setControlBorderColor (Css.hex "#ff79c6")
        |> setControlBorderColorHover (Css.hex "#ff79c6")
        |> setControlBorderColorFocus (Css.hex "#ff79c6")
        |> setControlBackgroundColorHover (Css.rgba 255 255 65 0.2)
        |> setControlSeparatorColor (Css.hex "#ff79c6")
        |> setControlDropdownIndicatorColor (Css.hex "#ff79c6")
        |> setControlDropdownIndicatorColorHover (Css.hex "#e66db2")
        |> setControlClearIndicatorColor (Css.hex "#ff79c6")
        |> setControlClearIndicatorColorHover (Css.hex "#e66db2")
        |> setControlBackgroundColor (Css.hex "#282a36")
        |> setControlBackgroundColorHover (Css.hex "#282a36")
        |> setControlColor (Css.hex "#ff79c6")
        |> setControlSelectedColor (Css.hex "#ff79c6")
        |> setControlLoadingIndicatorColor (Css.hex "#ff79c6")


draculaMenu : MenuConfig
draculaMenu =
    getMenuConfig default
        |> setMenuBoxShadowColor (Css.rgba 255 165 44 0.2)
        |> setMenuBackgroundColor (Css.hex "#282a36")


draculaMenuItem : MenuItemConfig
draculaMenuItem =
    getMenuItemConfig default
        |> setMenuItemBackgroundColorNotSelected (Css.hex "#44475a")
        |> setMenuItemBackgroundColorSelected (Css.hex "#ff79c6")
        |> setMenuItemBackgroundColorClicked (Css.hex "#44475a")
        |> setMenuItemColor (Css.hex "#aeaea9")
