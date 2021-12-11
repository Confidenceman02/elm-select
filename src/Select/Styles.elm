module Select.Styles exposing
    ( Config, ControlConfig, MenuConfig, default, setControlStyles, setMenuStyles
    , setControlBackgroundColor, setControlBackgroundColorHover, setControlBorderColor, setControlBorderColorFocus, setControlBorderColorHover, setControlClearIndicatorColor
    , setControlClearIndicatorColorHover, setControlDisabledOpacity, setControlDropdownIndicatorColor, setControlDropdownIndicatorColorHover
    , setControlLoadingIndicatorColor, setControlPlaceholderOpacity, setControlSeparatorColor
    , setMenuBackgroundColor, setMenuBorderRadius, setMenuBoxShadowBlur, setMenuBoxShadowColor, setMenuBoxShadowHOffset, setMenuBoxShadowVOffset
    , setMenuItemStyles, setMenuItemBackgroundColorClicked, setMenuItemBackgroundColorSelected, setMenuItemColor, setMenuItemBackgroundColorNotSelected, setMenuItemColorHoverSelected
    , getControlConfig, getControlBackgroundColor, getControlBackgroundColorHover, getControlBorderColor, getControlBorderColorFocus, getControlBorderColorHover, getControlClearIndicatorColor
    , getControlClearIndicatorColorHover, getControlDisabledOpacity, getControlDropdownIndicatorColor, getControlDropdownIndicatorColorHover
    , getControlLoadingIndicatorColor, getControlPlaceholderOpacity, getControlSeparatorColor
    , getMenuConfig, getMenuBackgroundColor, getMenuBorderRadius, getMenuBoxShadowColor, getMenuBoxShadowHOffset, getMenuBoxShadowVOffset, getMenuBoxShadowBlur
    , getMenuItemConfig, getMenuItemBackgroundColorSelected, getMenuItemColor, getMenuItemColorHoverSelected, getMenuItemBackgroundColorClicked, getMenuItemColorHoverNotSelected
    , getMenuItemBackgroundColorNotSelected
    , MenuItemConfig, setMenuItemColorHoverNotSelected
    )

{-| Add custom styling to the select.


# Set up

@docs Config, ControlConfig, MenuConfig, default, setControlStyles, setMenuStyles


# Set styles for control

@docs setControlBackgroundColor, setControlBackgroundColorHover, setControlBorderColor, setControlBorderColorFocus, setControlBorderColorHover, setControlClearIndicatorColor
@docs setControlClearIndicatorColorHover, setControlDisabledOpacity, setControlDropdownIndicatorColor, setControlDropdownIndicatorColorHover
@docs setControlLoadingIndicatorColor, setControlPlaceholderOpacity, setControlSeparatorColor


# Set styles for menu

@docs setMenuBackgroundColor, setMenuBorderRadius, setMenuBoxShadowBlur, setMenuBoxShadowColor, setMenuBoxShadowHOffset, setMenuBoxShadowVOffset


# Set styles for menu item

@docs setMenuItemStyles, setMenuItemBackgroundColorClicked, setMenuItemBackgroundColorSelected, setMenuItemColor, setMenuItemBackgroundColorNotSelected, setMenuItemColorHoverSelected
@docs setMenItemColorHoverNotSelected


# Get styles for control

@docs getControlConfig, getControlBackgroundColor, getControlBackgroundColorHover, getControlBorderColor, getControlBorderColorFocus, getControlBorderColorHover, getControlClearIndicatorColor
@docs getControlClearIndicatorColorHover, getControlDisabledOpacity, getControlDropdownIndicatorColor, getControlDropdownIndicatorColorHover
@docs getControlLoadingIndicatorColor, getControlPlaceholderOpacity, getControlSeparatorColor


# Get styles for menu

@docs getMenuConfig, getMenuBackgroundColor, getMenuBorderRadius, getMenuBoxShadowColor, getMenuBoxShadowHOffset, getMenuBoxShadowVOffset, getMenuBoxShadowBlur


# Get styles for menu item

@docs getMenuItemConfig, getMenuItemBackgroundColorSelected, getMenuItemColor, getMenuItemColorHoverSelected, getMenuItemBackgroundColorClicked, getMenuItemColorHoverNotSelected

@docs getMenuItemBackgroundColorNotSelected

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
    , color : Css.Color
    , colorHoverSelected : Css.Color
    , colorHoverNotSelected : Css.Color
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
    , clearIndicatorColor : Css.Color
    , clearIndicatorColorHover : Css.Color
    , disabledOpacity : Float
    , dropdownIndicatorColor : Css.Color
    , dropdownIndicatorColorHover : Css.Color
    , loadingIndicatorColor : Css.Color
    , placeholderOpacity : Float
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
    , color = Css.hex "#000000"
    , colorHoverSelected = Css.hex "#0168B3"
    , colorHoverNotSelected = Css.hex "#0168B3"
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
    , clearIndicatorColor = Css.rgb 102 102 102
    , clearIndicatorColorHover = Css.rgb 51 51 51
    , disabledOpacity = 0.3
    , dropdownIndicatorColor = Css.rgb 102 102 102
    , dropdownIndicatorColorHover = Css.rgb 51 51 51
    , loadingIndicatorColor = Css.rgb 102 102 102
    , placeholderOpacity = 0.5
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
setControlClearIndicatorColor : Css.Color -> ControlConfig -> ControlConfig
setControlClearIndicatorColor c (ControlConfig config) =
    ControlConfig { config | clearIndicatorColor = c }


{-| -}
setControlClearIndicatorColorHover : Css.Color -> ControlConfig -> ControlConfig
setControlClearIndicatorColorHover c (ControlConfig config) =
    ControlConfig { config | clearIndicatorColorHover = c }


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
setControlSeparatorColor : Css.Color -> ControlConfig -> ControlConfig
setControlSeparatorColor c (ControlConfig config) =
    ControlConfig { config | separatorColor = c }



-- MODIFIERS


{-| Set styles for the select control

        import Select.Styles as Styles


        controlBranding : Styles.ControlConfig
        controlBranding =
            Styles.getControlConfig default
                |> setControlBorderColor (Css.hex "#FFFFFF")
                |> setControlBorderColorFocus (Css.hex "#0168B3")

        selectBranding : Styles.Config
        selectBranding
            Styles.default
                |> setControlStyles controlBranding

-}
setControlStyles : ControlConfig -> Config -> Config
setControlStyles controlConfig (Config config) =
    Config { config | controlConfig = controlConfig }


{-| Set styles for the select menu

        import Select.Styles as Styles


        menuBranding : MenuConfig
        menuBranding =
            Styles.getMenuConfig Styles.default
                |> setMenuBackgroundColor (Css.hex "#000000")
                |> setMenuBorderRadius 4


        selectBranding : Styles.Config
        selectBranding
                Styles.default
                    |> setMenuStyles menuBranding

-}
setMenuStyles : MenuConfig -> Config -> Config
setMenuStyles menuConfig (Config config) =
    Config { config | menuConfig = menuConfig }


{-| Set styles for select menu item

        import Select.Styles as Styles


        menuItemBranding : MenuItemConfig
        menuItemBranding =
            Styles.getMenuItemConfig Styles.default
                |> setMenuItemBackgroundColorNotSelected (Css.hex "#000000")


        selectBranding : Styles.Config
        selectBranding
                Styles.default
                    |> setMenuItemStyles menuItemBranding

-}
setMenuItemStyles : MenuItemConfig -> Config -> Config
setMenuItemStyles menuItemConfig (Config config) =
    Config { config | menuItemConfig = menuItemConfig }



-- GETTERS MENU ITEM


{-| Get the MenuItemConfig

    import Select.Styles as Styles

    baseStyles : Styles.Config
    baseStyles =
        Styles.default

    baseMenuStyles : Styles.MenuItemConfig
    baseMenuStyles =
        Styles.getMenuItemConfig baseStyles
            |> Styles.setMenuItemBackgroundColorSelected (Css.hex "#000000")

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



-- GETTERS MENU STYLES


{-| Get the MenuConfig

    import Select.Styles as Styles

    baseStyles : Styles.Config
    baseStyles =
        Styles.default

    baseMenuStyles : Styles.MenuConfig
    baseMenuStyles =
        Styles.getMenuConfig baseStyles
            |> Styles.setMenuBorderRadius 4

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


{-| Get the ControlConfig

    import Select.Styles as Styles

    baseStyles : Styles.Config
    baseStyles =
        Styles.default

    baseControlStyles : Styles.ControlConfig
    baseControlStyles =
        Styles.getControlConfig baseStyles
            |> Styles.setControlBorderColor (Css.hex "ffffff")

-}
getControlConfig : Config -> ControlConfig
getControlConfig (Config config) =
    config.controlConfig


getControlConfiguration : Configuration -> ControlConfiguration
getControlConfiguration config =
    let
        (ControlConfig controlConfig) =
            config.controlConfig
    in
    controlConfig


{-| -}
getControlBackgroundColor : Config -> Css.Color
getControlBackgroundColor (Config config) =
    getControlConfiguration config |> .backgroundColor


{-| -}
getControlBackgroundColorHover : Config -> Css.Color
getControlBackgroundColorHover (Config config) =
    getControlConfiguration config |> .backgroundColorHover


{-| -}
getControlBorderColor : Config -> Css.Color
getControlBorderColor (Config config) =
    getControlConfiguration config |> .borderColor


{-| -}
getControlBorderColorFocus : Config -> Css.Color
getControlBorderColorFocus (Config config) =
    getControlConfiguration config |> .borderColorFocus


{-| -}
getControlPlaceholderOpacity : Config -> Float
getControlPlaceholderOpacity (Config config) =
    getControlConfiguration config |> .placeholderOpacity


{-| -}
getControlBorderColorHover : Config -> Css.Color
getControlBorderColorHover (Config config) =
    getControlConfiguration config |> .borderColorHover


{-| -}
getControlSeparatorColor : Config -> Css.Color
getControlSeparatorColor (Config config) =
    getControlConfiguration config |> .separatorColor


{-| -}
getControlClearIndicatorColor : Config -> Css.Color
getControlClearIndicatorColor (Config config) =
    getControlConfiguration config |> .clearIndicatorColor


{-| -}
getControlClearIndicatorColorHover : Config -> Css.Color
getControlClearIndicatorColorHover (Config config) =
    getControlConfiguration config |> .clearIndicatorColorHover


{-| -}
getControlDropdownIndicatorColor : Config -> Css.Color
getControlDropdownIndicatorColor (Config config) =
    getControlConfiguration config |> .dropdownIndicatorColor


{-| -}
getControlDropdownIndicatorColorHover : Config -> Css.Color
getControlDropdownIndicatorColorHover (Config config) =
    getControlConfiguration config |> .dropdownIndicatorColorHover


{-| -}
getControlLoadingIndicatorColor : Config -> Css.Color
getControlLoadingIndicatorColor (Config config) =
    getControlConfiguration config |> .loadingIndicatorColor


{-| -}
getControlDisabledOpacity : Config -> Float
getControlDisabledOpacity (Config config) =
    getControlConfiguration config |> .disabledOpacity
