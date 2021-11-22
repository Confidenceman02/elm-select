module Select.Styles exposing
    ( Config, ControlConfig, controlDefault, default, setControlStyles
    , setControlBackgroundColorHover, setControlBorderColor, setControlBorderColorFocus, setControlBorderColorHover, setControlClearIndicatorColor
    , setControlClearIndicatorColorHover, setControlDisabledOpacity, setControlDropdownIndicatorColor, setControlDropdownIndicatorColorHover
    , setControlLoadingIndicatorColor, setControlPlaceholderOpacity, setControlSeparatorColor
    , getControlBackgroundColorHover, getControlBorderColor, getControlBorderColorFocus, getControlBorderColorHover, getControlClearIndicatorColor
    , getControlClearIndicatorColorHover, getControlDisabledOpacity, getControlDropdownIndicatorColor, getControlDropdownIndicatorColorHover
    , getControlLoadingIndicatorColor, getControlPlaceholderOpacity, getControlSeparatorColor
    )

{-| Add custom styling to the select.


# Set up

@docs Config, ControlConfig, controlDefault, default, setControlStyles


# Set styles for control

@docs setControlBackgroundColorHover, setControlBorderColor, setControlBorderColorFocus, setControlBorderColorHover, setControlClearIndicatorColor
@docs setControlClearIndicatorColorHover, setControlDisabledOpacity, setControlDropdownIndicatorColor, setControlDropdownIndicatorColorHover
@docs setControlLoadingIndicatorColor, setControlPlaceholderOpacity, setControlSeparatorColor


# Get styles for control

@docs getControlBackgroundColorHover, getControlBorderColor, getControlBorderColorFocus, getControlBorderColorHover, getControlClearIndicatorColor
@docs getControlClearIndicatorColorHover, getControlDisabledOpacity, getControlDropdownIndicatorColor, getControlDropdownIndicatorColorHover
@docs getControlLoadingIndicatorColor, getControlPlaceholderOpacity, getControlSeparatorColor

-}

import Css


{-| -}
type Config
    = Config Configuration


{-| -}
type ControlConfig
    = ControlConfig ControlConfiguration


type alias ControlConfiguration =
    { backgroundColorHover : Css.Color
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
    ControlConfig


defaultsControl : ControlConfiguration
defaultsControl =
    { borderColor = Css.hex "#898BA9"
    , borderColorFocus = Css.hex "#0168b3"
    , borderColorHover = Css.hex "#4B4D68"
    , backgroundColorHover = Css.hex "#F0F1F4"
    , clearIndicatorColor = Css.rgb 102 102 102
    , clearIndicatorColorHover = Css.rgb 51 51 51
    , disabledOpacity = 0.3
    , dropdownIndicatorColor = Css.rgb 102 102 102
    , dropdownIndicatorColorHover = Css.rgb 51 51 51
    , loadingIndicatorColor = Css.rgb 102 102 102
    , placeholderOpacity = 0.5
    , separatorColor = Css.rgb 204 204 204
    }


{-| The default styling for the select control
-}
controlDefault : ControlConfig
controlDefault =
    ControlConfig defaultsControl


defaults : Configuration
defaults =
    controlDefault


{-| The default styling for the select
-}
default : Config
default =
    Config defaults



-- MODIFIERS CONTROL


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

        controlBranding : ControlConfig
        controlBranding =
            Styles.controlDefault
                |> setControlBorderColor (Css.hex "#FFFFFF")
                |> setControlBorderColorFocus (Css.hex "#0168B3")

        selectBranding : Config
        selectBranding
                setControlStyles Styles.default controlBranding

-}
setControlStyles : Config -> ControlConfig -> Config
setControlStyles _ controlConfig =
    Config controlConfig



-- GETTERS CONTROL


{-| -}
getControlBorderColor : Config -> Css.Color
getControlBorderColor (Config (ControlConfig controlConfig)) =
    controlConfig.borderColor


{-| -}
getControlBorderColorFocus : Config -> Css.Color
getControlBorderColorFocus (Config (ControlConfig controlConfig)) =
    controlConfig.borderColorFocus


{-| -}
getControlPlaceholderOpacity : Config -> Float
getControlPlaceholderOpacity (Config (ControlConfig controlConfig)) =
    controlConfig.placeholderOpacity


{-| -}
getControlBackgroundColorHover : Config -> Css.Color
getControlBackgroundColorHover (Config (ControlConfig controlConfig)) =
    controlConfig.backgroundColorHover


{-| -}
getControlBorderColorHover : Config -> Css.Color
getControlBorderColorHover (Config (ControlConfig controlConfig)) =
    controlConfig.borderColorHover


{-| -}
getControlSeparatorColor : Config -> Css.Color
getControlSeparatorColor (Config (ControlConfig controlConfig)) =
    controlConfig.separatorColor


{-| -}
getControlClearIndicatorColor : Config -> Css.Color
getControlClearIndicatorColor (Config (ControlConfig controlConfig)) =
    controlConfig.clearIndicatorColor


{-| -}
getControlClearIndicatorColorHover : Config -> Css.Color
getControlClearIndicatorColorHover (Config (ControlConfig controlConfig)) =
    controlConfig.clearIndicatorColorHover


{-| -}
getControlDropdownIndicatorColor : Config -> Css.Color
getControlDropdownIndicatorColor (Config (ControlConfig controlConfig)) =
    controlConfig.dropdownIndicatorColor


{-| -}
getControlDropdownIndicatorColorHover : Config -> Css.Color
getControlDropdownIndicatorColorHover (Config (ControlConfig controlConfig)) =
    controlConfig.dropdownIndicatorColorHover


{-| -}
getControlLoadingIndicatorColor : Config -> Css.Color
getControlLoadingIndicatorColor (Config (ControlConfig controlConfig)) =
    controlConfig.loadingIndicatorColor


{-| -}
getControlDisabledOpacity : Config -> Float
getControlDisabledOpacity (Config (ControlConfig controlConfig)) =
    controlConfig.disabledOpacity
