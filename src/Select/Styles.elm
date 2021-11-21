module Select.Styles exposing
    ( Config
    , default
    , getControlBackgroundColorHover
    , getControlBorderColor
    , getControlBorderColorFocused
    , getControlBorderColorHover
    , getControlClearIndicatorColor
    , getControlClearIndicatorColorHover
    , getControlDisabledOpacity
    , getControlDropdownIndicatorColor
    , getControlDropdownIndicatorColorHover
    , getControlLoadingIndicatorColor
    , getControlPlaceholderOpacity
    , getControlSeparatorColor
    )

import Css


type Config
    = Config Configuration


type ControlConfig
    = ControlConfig ControlConfiguration


type alias ControlConfiguration =
    { borderColor : Css.Color
    , borderColorFocused : Css.Color
    , borderColorHover : Css.Color
    , clearIndicatorColor : Css.Color
    , clearIndicatorColorHover : Css.Color
    , dropdownIndicatorColor : Css.Color
    , dropdownIndicatorColorHover : Css.Color
    , loadingIndicatorColor : Css.Color
    , backgroundColorHover : Css.Color
    , placeholderOpacity : Float
    , disabledOpacity : Float
    , separatorColor : Css.Color
    }


type alias Configuration =
    { controlStyles : ControlConfig }


defaultsControl : ControlConfiguration
defaultsControl =
    { borderColor = Css.hex "#898BA9"
    , borderColorFocused = Css.hex "#0168b3"
    , backgroundColorHover = Css.hex "#F0F1F4"
    , borderColorHover = Css.hex "#4B4D68"
    , clearIndicatorColor = Css.rgb 102 102 102
    , clearIndicatorColorHover = Css.rgb 51 51 51
    , dropdownIndicatorColor = Css.rgb 102 102 102
    , dropdownIndicatorColorHover = Css.rgb 51 51 51
    , loadingIndicatorColor = Css.rgb 102 102 102
    , placeholderOpacity = 0.5
    , disabledOpacity = 0.3
    , separatorColor = Css.rgb 204 204 204
    }


defaultControl : ControlConfig
defaultControl =
    ControlConfig defaultsControl


defaults : Configuration
defaults =
    { controlStyles = defaultControl
    }


default : Config
default =
    Config defaults



-- GETTERS CONTROL


getControlBorderColor : Config -> Css.Color
getControlBorderColor (Config config) =
    let
        (ControlConfig controlConfig) =
            config.controlStyles
    in
    controlConfig.borderColor


getControlBorderColorFocused : Config -> Css.Color
getControlBorderColorFocused (Config config) =
    let
        (ControlConfig controlConfig) =
            config.controlStyles
    in
    controlConfig.borderColorFocused


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
