module Select.SelectInput exposing
    ( InputSizing(..)
    , activeDescendant
    , currentValue
    , default
    , defaultWidth
    , disabled
    , inputId
    , inputSizing
    , onBlurMsg
    , onFocusMsg
    , onInput
    , onMousedown
    , preventKeydownOn
    , setAriaControls
    , setAriaExpanded
    , setAriaLabelledBy
    , sizerId
    , view
    )

import Html.Styled exposing (Html, div, input, text)
import Html.Styled.Attributes exposing (attribute, id, size, style, type_, value)
import Html.Styled.Attributes.Aria exposing (ariaActiveDescendant, ariaControls, ariaExpanded, ariaHasPopup, ariaLabelledby, role)
import Html.Styled.Events exposing (on, onBlur, onFocus, preventDefaultOn)
import Json.Decode as Decode
import Json.Encode as Encode
import Select.Events as Events


type Config msg
    = Config (Configuration msg)


type alias Active =
    Bool


type InputSizing
    = Dynamic
    | DynamicJsOptimized Active


type alias Configuration msg =
    { onInput : Maybe (String -> msg)
    , onBlur : Maybe msg
    , onFocus : Maybe msg
    , onMousedown : Maybe msg
    , currentValue : Maybe String
    , disabled : Bool
    , minWidth : Int
    , preventKeydownOn : List (Decode.Decoder msg)
    , inputSizing : InputSizing
    , dataTestId : String
    , ariaActiveDescendant : Maybe String
    , ariaControls : Maybe String
    , ariaLabelledBy : Maybe String
    , ariaExpanded : Bool
    }



-- DEFAULTS


defaults : Configuration msg
defaults =
    { onInput = Nothing
    , onBlur = Nothing
    , onFocus = Nothing
    , onMousedown = Nothing
    , currentValue = Nothing
    , disabled = False
    , minWidth = defaultWidth
    , preventKeydownOn = []
    , inputSizing = Dynamic
    , dataTestId = "selectInput"
    , ariaActiveDescendant = Nothing
    , ariaLabelledBy = Nothing
    , ariaControls = Nothing
    , ariaExpanded = False
    }


default : Config msg
default =
    Config defaults


sizerId : String -> String
sizerId sid =
    "kaizen-select-input-sizer-target-" ++ sid


inputId : String -> String
inputId iid =
    "kaizen-select-input-target-" ++ iid



-- CONSTANTS


defaultWidth : Int
defaultWidth =
    2



-- MODIFIERS


setAriaExpanded : Bool -> Config msg -> Config msg
setAriaExpanded expanded (Config config) =
    Config { config | ariaExpanded = expanded }


setAriaControls : String -> Config msg -> Config msg
setAriaControls s (Config config) =
    Config { config | ariaControls = Just s }


setAriaLabelledBy : String -> Config msg -> Config msg
setAriaLabelledBy s (Config config) =
    Config { config | ariaLabelledBy = Just s }


activeDescendant : String -> Config msg -> Config msg
activeDescendant s (Config config) =
    Config { config | ariaActiveDescendant = Just s }


inputSizing : InputSizing -> Config msg -> Config msg
inputSizing width (Config config) =
    Config { config | inputSizing = width }


preventKeydownOn : List (Decode.Decoder msg) -> Config msg -> Config msg
preventKeydownOn decoders (Config config) =
    Config { config | preventKeydownOn = decoders }


onInput : (String -> msg) -> Config msg -> Config msg
onInput msg (Config config) =
    Config { config | onInput = Just msg }


onBlurMsg : msg -> Config msg -> Config msg
onBlurMsg msg (Config config) =
    Config { config | onBlur = Just msg }


onFocusMsg : msg -> Config msg -> Config msg
onFocusMsg msg (Config config) =
    Config { config | onFocus = Just msg }


onMousedown : msg -> Config msg -> Config msg
onMousedown msg (Config config) =
    Config { config | onMousedown = Just msg }


currentValue : String -> Config msg -> Config msg
currentValue value_ (Config config) =
    if String.isEmpty value_ then
        Config { config | currentValue = Nothing }

    else
        Config { config | currentValue = Just value_ }


disabled : Bool -> Config msg -> Config msg
disabled predicate (Config config) =
    Config { config | disabled = predicate }


view : Config msg -> String -> Html msg
view (Config config) id_ =
    let
        resolveSizerId =
            sizerId id_

        resolveInputId =
            inputId id_

        buildDynamicSelectInputProps =
            Encode.encode 0 <|
                Encode.object
                    [ ( "sizerId", Encode.string resolveSizerId )
                    , ( "defaultInputWidth", Encode.int defaultWidth )
                    ]

        inputWidthStyle =
            case config.inputSizing of
                Dynamic ->
                    if String.isEmpty inputValue then
                        [ size 1 ]

                    else
                        [ size <| String.length inputValue + config.minWidth ]

                DynamicJsOptimized True ->
                    [ style "width" (String.fromInt config.minWidth ++ "px"), attribute "data-es-dynamic-select-input" buildDynamicSelectInputProps ]

                DynamicJsOptimized False ->
                    [ style "width" (String.fromInt config.minWidth ++ "px") ]

        input_ changeMsg =
            Events.onInputAt [ "target", "value" ] changeMsg

        blur blurMsg =
            onBlur blurMsg

        focus focusMsg =
            onFocus focusMsg

        mousedown mousedownMsg =
            on "mousedown" <| Decode.succeed mousedownMsg

        inputValue =
            Maybe.withDefault "" config.currentValue

        events =
            if config.disabled then
                []

            else
                List.filterMap identity
                    [ Maybe.map input_ config.onInput
                    , Maybe.map blur config.onBlur
                    , Maybe.map focus config.onFocus
                    , Maybe.map mousedown config.onMousedown
                    ]
                    ++ [ preventOn ]

        preventOn =
            preventDefaultOn "keydown" <|
                Decode.map
                    (\m -> ( m, True ))
                    (Decode.oneOf config.preventKeydownOn)

        withAriaActiveDescendant =
            case config.ariaActiveDescendant of
                Just s ->
                    [ ariaActiveDescendant s ]

                _ ->
                    []

        withAriaControls =
            case config.ariaControls of
                Just s ->
                    [ ariaControls s ]

                _ ->
                    []

        withAriaLabelledBy =
            case config.ariaLabelledBy of
                Just s ->
                    [ ariaLabelledby s ]

                _ ->
                    []

        inputStyles =
            [ style "box-sizing" "content-box"
            , style "background" "0px center"
            , style "border" "0px"
            , style "font-size" "inherit"
            , style "outline" "0px"
            , style "padding" "0px"
            , style "color" "inherit"
            ]
                ++ inputWidthStyle

        sizerStyles =
            [ style "position" "absolute"
            , style "top" "0px"
            , style "left" "0px"
            , style "visibility" "hidden"
            , style "height" "0px"
            , style "overflow" "scroll"
            , style "white-space" "pre"
            , style "font-size" "16px"
            , style "font-style" "normal"
            , style "font-family" "Arial"
            , style "letter-spacing" "normal"
            , style "text-transform" "none"
            ]

        autoSizeInputContainerStyles =
            [ style "padding-bottom" "2px"
            , style "padding-top" "2px"
            , style "box-sizing" "border-box"
            , style "margin" "2px"
            , style "display" "inline"
            , role "combobox"
            , ariaHasPopup "listbox"
            ]

        withAriaOwns =
            case config.ariaControls of
                Just al ->
                    [ attribute "aria-owns" al ]

                _ ->
                    []

        withAriaExpanded =
            if config.ariaExpanded then
                [ ariaExpanded "true" ]

            else
                [ ariaExpanded "false" ]
    in
    div (autoSizeInputContainerStyles ++ withAriaOwns ++ withAriaExpanded)
        [ input
            ([ id resolveInputId
             , value inputValue
             , type_ "text"
             , role "textbox"
             , attribute "aria-multiline" "false"
             , attribute "aria-autocomplete" "list"
             , attribute "autocomplete" "off"
             , attribute "data-test-id" config.dataTestId
             ]
                ++ events
                ++ inputStyles
                ++ withAriaActiveDescendant
                ++ withAriaControls
                ++ withAriaLabelledBy
            )
            []

        -- query the div width to set the input width
        , div (id (sizerId id_) :: sizerStyles) [ text inputValue ]
        ]
