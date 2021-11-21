module Select.Styles exposing
    ( Config
    , default
    , getControlBackgroundColorHover
    , getControlBorderColor
    , getControlBorderColorFocus
    , getControlBorderColorHover
    , getControlClearIndicatorColor
    , getControlClearIndicatorColorHover
    , getControlDisabledOpacity
    , getControlDropdownIndicatorColor
    , getControlDropdownIndicatorColorHover
    , getControlLoadingIndicatorColor
    , getControlPlaceholderOpacity
    , getControlSeparatorColor
    , setControlBackgroundColorHover
    , setControlBorderColor
    , setControlBorderColorFocus
    , setControlBorderColorHover
    , setControlClearIndicatorColor
    , setControlClearIndicatorColorHover
    , setControlDisabledOpacity
    , setControlDropdownIndicatorColor
    , setControlDropdownIndicatorColorHover
    , setControlLoadingIndicatorColor
    , setControlPlaceholderOpacity
    , setControlSeparatorColor
    , setControlStyles
    )

import Css


type Config
    = Config Configuration


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
    { controlStyles : ControlConfig }


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


controlDefault : ControlConfig
controlDefault =
    ControlConfig defaultsControl


defaults : Configuration
defaults =
    { controlStyles = controlDefault
    }


default : Config
default =
    Config defaults



-- MODIFIERS CONTROL


setControlBackgroundColorHover : Css.Color -> ControlConfig -> ControlConfig
setControlBackgroundColorHover c (ControlConfig config) =
    ControlConfig { config | backgroundColorHover = c }


setControlBorderColor : Css.Color -> ControlConfig -> ControlConfig
setControlBorderColor c (ControlConfig config) =
    ControlConfig { config | borderColor = c }


setControlBorderColorFocus : Css.Color -> ControlConfig -> ControlConfig
setControlBorderColorFocus c (ControlConfig config) =
    ControlConfig { config | borderColorFocus = c }


setControlBorderColorHover : Css.Color -> ControlConfig -> ControlConfig
setControlBorderColorHover c (ControlConfig config) =
    ControlConfig { config | borderColorHover = c }


setControlClearIndicatorColor : Css.Color -> ControlConfig -> ControlConfig
setControlClearIndicatorColor c (ControlConfig config) =
    ControlConfig { config | clearIndicatorColor = c }


setControlClearIndicatorColorHover : Css.Color -> ControlConfig -> ControlConfig
setControlClearIndicatorColorHover c (ControlConfig config) =
    ControlConfig { config | clearIndicatorColorHover = c }


setControlDisabledOpacity : Float -> ControlConfig -> ControlConfig
setControlDisabledOpacity f (ControlConfig config) =
    ControlConfig { config | disabledOpacity = f }


setControlDropdownIndicatorColor : Css.Color -> ControlConfig -> ControlConfig
setControlDropdownIndicatorColor c (ControlConfig config) =
    ControlConfig { config | dropdownIndicatorColor = c }


setControlDropdownIndicatorColorHover : Css.Color -> ControlConfig -> ControlConfig
setControlDropdownIndicatorColorHover c (ControlConfig config) =
    ControlConfig { config | dropdownIndicatorColorHover = c }


setControlLoadingIndicatorColor : Css.Color -> ControlConfig -> ControlConfig
setControlLoadingIndicatorColor c (ControlConfig config) =
    ControlConfig { config | loadingIndicatorColor = c }


setControlPlaceholderOpacity : Float -> ControlConfig -> ControlConfig
setControlPlaceholderOpacity f (ControlConfig config) =
    ControlConfig { config | placeholderOpacity = f }


setControlSeparatorColor : Css.Color -> ControlConfig -> ControlConfig
setControlSeparatorColor c (ControlConfig config) =
    ControlConfig { config | separatorColor = c }



-- MODIFIERS


setControlStyles : Config -> ControlConfig -> Config
setControlStyles (Config config) controlConfig =
    Config { config | controlStyles = controlConfig }



-- GETTERS CONTROL


getControlBorderColor : Config -> Css.Color
getControlBorderColor (Config config) =
    let
        (ControlConfig controlConfig) =
            config.controlStyles
    in
    controlConfig.borderColor


getControlBorderColorFocus : Config -> Css.Color
getControlBorderColorFocus (Config config) =
    let
        (ControlConfig controlConfig) =
            config.controlStyles
    in
    controlConfig.borderColorFocus


getControlPlaceholderOpacity : Config -> Float
getControlPlaceholderOpacity (Config config) =
    let
        (ControlConfig controlConfig) =
            config.controlStyles
    in
    controlConfig.placeholderOpacity


getControlBackgroundColorHover : Config -> Css.Color
getControlBackgroundColorHover (Config config) =
    let
        (ControlConfig controlConfig) =
            config.controlStyles
    in
    controlConfig.backgroundColorHover


getControlBorderColorHover : Config -> Css.Color
getControlBorderColorHover (Config config) =
    let
        (ControlConfig controlConfig) =
            config.controlStyles
    in
    controlConfig.borderColorHover


getControlSeparatorColor : Config -> Css.Color
getControlSeparatorColor (Config config) =
    let
        (ControlConfig controlConfig) =
            config.controlStyles
    in
    controlConfig.separatorColor


getControlClearIndicatorColor : Config -> Css.Color
getControlClearIndicatorColor (Config config) =
    let
        (ControlConfig controlConfig) =
            config.controlStyles
    in
    controlConfig.clearIndicatorColor


getControlClearIndicatorColorHover : Config -> Css.Color
getControlClearIndicatorColorHover (Config config) =
    let
        (ControlConfig controlConfig) =
            config.controlStyles
    in
    controlConfig.clearIndicatorColorHover


getControlDropdownIndicatorColor : Config -> Css.Color
getControlDropdownIndicatorColor (Config config) =
    let
        (ControlConfig controlConfig) =
            config.controlStyles
    in
    controlConfig.dropdownIndicatorColor


getControlDropdownIndicatorColorHover : Config -> Css.Color
getControlDropdownIndicatorColorHover (Config config) =
    let
        (ControlConfig controlConfig) =
            config.controlStyles
    in
    controlConfig.dropdownIndicatorColorHover


getControlLoadingIndicatorColor : Config -> Css.Color
getControlLoadingIndicatorColor (Config config) =
    let
        (ControlConfig controlConfig) =
            config.controlStyles
    in
    controlConfig.loadingIndicatorColor


getControlDisabledOpacity : Config -> Float
getControlDisabledOpacity (Config config) =
    let
        (ControlConfig controlConfig) =
            config.controlStyles
    in
    controlConfig.disabledOpacity
