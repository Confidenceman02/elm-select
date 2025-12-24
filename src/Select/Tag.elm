module Select.Tag exposing
    ( dataTestId
    , default
    , onDismiss
    , onMousedown
    , onMouseleave
    , rightMargin
    , setControlStyles
    , view
    )

import Css
import Html.Styled exposing (Html, button, div, text)
import Html.Styled.Attributes as StyledAttribs exposing (attribute, type_)
import Html.Styled.Events exposing (on, onClick, stopPropagationOn)
import Json.Decode as Decode
import Select.ClearIcon as ClearIcon
import Select.Styles as Styles


type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { onDismiss : Maybe msg
    , onMousedown : Maybe msg
    , onMouseleave : Maybe msg
    , rightMargin : Bool
    , backgroundColor : Css.Color
    , dataTestId : String
    , borderRadius : Float
    , controlStyles : Styles.ControlConfig
    }



-- VARIANTS


defaults : Configuration msg
defaults =
    { onDismiss = Nothing
    , onMousedown = Nothing
    , onMouseleave = Nothing
    , rightMargin = False
    , backgroundColor = Css.hex "#E1E2EA"
    , dataTestId = "multiSelectTag"
    , borderRadius = 16
    , controlStyles = Styles.getControlConfig Styles.default
    }



-- MODIFIERS


rightMargin : Bool -> Config msg -> Config msg
rightMargin pred (Config config) =
    Config { config | rightMargin = pred }


default : Config msg
default =
    Config defaults


onDismiss : msg -> Config msg -> Config msg
onDismiss msg (Config config) =
    Config { config | onDismiss = Just msg }


onMousedown : msg -> Config msg -> Config msg
onMousedown msg (Config config) =
    Config { config | onMousedown = Just msg }


onMouseleave : msg -> Config msg -> Config msg
onMouseleave msg (Config config) =
    Config { config | onMouseleave = Just msg }


setControlStyles : Styles.ControlConfig -> Config msg -> Config msg
setControlStyles cfg (Config config) =
    Config { config | controlStyles = cfg }


dataTestId : String -> Config msg -> Config msg
dataTestId testId (Config config) =
    Config { config | dataTestId = testId }


view : Config msg -> String -> Html msg
view (Config config) value =
    let
        resolveTruncation =
            case Styles.getControlMultiTagTruncationWidth config.controlStyles of
                Just width ->
                    [ Css.textOverflow Css.ellipsis
                    , Css.overflowX Css.hidden
                    , Css.whiteSpace Css.noWrap
                    , Css.maxWidth (Css.px width)
                    ]

                Nothing ->
                    []

        resolveTitleAttribute =
            case Styles.getControlMultiTagTruncationWidth config.controlStyles of
                Just _ ->
                    [ attribute "title" value ]

                Nothing ->
                    []
    in
    div
        -- root
        [ StyledAttribs.css
            [ Css.displayFlex
            , Css.minWidth (Css.px 0)
            , Css.backgroundColor (Styles.getControlMultiTagBackgroundColor config.controlStyles)
            , Css.borderRadius (Css.px (Styles.getControlMultiTagBorderRadius config.controlStyles))
            , Css.property "margin-block" (Css.px 2).value
            , Css.property "margin-inline" (Css.px 2).value
            , Css.boxSizing Css.borderBox
            ]
        , attribute "data-test-id" config.dataTestId
        ]
        [ div
            (StyledAttribs.css
                ([ Css.overflow Css.hidden
                 , Css.whiteSpace Css.noWrap
                 , Css.borderRadius (Css.px 2)
                 , Css.fontSize (Css.pct 90)
                 , Css.fontWeight (Css.int 400)
                 , Css.padding4 (Css.px 5) (Css.px 8) (Css.px 5) (Css.px 8)
                 , Css.property "padding-block" (Css.px 3).value
                 , Css.property "padding-inline" (Css.px 8).value
                 , Css.boxSizing Css.borderBox
                 ]
                    ++ resolveTruncation
                )
                :: resolveTitleAttribute
            )
            [ text value
            ]
        , viewClear config
        ]


viewClear : Configuration msg -> Html msg
viewClear config =
    let
        dismiss onDismissMsg =
            onClick onDismissMsg

        mousedown onMousedownMsg =
            stopPropagationOn "mousedown"
                (Decode.map (\msg -> ( msg, True ))
                    (Decode.succeed onMousedownMsg)
                )

        mouseleave onMouseleaveMsg =
            on "mouseleave" <| Decode.succeed onMouseleaveMsg

        events =
            List.filterMap identity
                [ Maybe.map dismiss config.onDismiss
                , Maybe.map mousedown config.onMousedown
                , Maybe.map mouseleave config.onMouseleave
                ]

        dataAttrib =
            [ attribute "data-test-id" (config.dataTestId ++ "-dismiss") ]
    in
    case config.onDismiss of
        Just _ ->
            div
                -- dismissIcon
                (StyledAttribs.css
                    [ Css.property "-moz-box-align" "center"
                    , Css.alignItems Css.center
                    , Css.displayFlex
                    , Css.borderRadius (Css.px 2)
                    , Css.property "margin-inline" (Css.px 4).value
                    , Css.boxSizing Css.borderBox
                    , Css.color
                        (Styles.getControlMultiTagDismissibleBackgroundColor
                            config.controlStyles
                        )
                    , Css.hover
                        [ Css.color
                            (Styles.getControlMultiTagDismissibleBackgroundColorHover
                                config.controlStyles
                            )
                        ]
                    ]
                    :: (events ++ dataAttrib)
                )
                [ button
                    [ StyledAttribs.css
                        [ Css.height (Css.px 16)
                        , Css.width (Css.px 16)
                        , Css.zIndex (Css.int 1)
                        , Css.displayFlex
                        , Css.color Css.inherit
                        , Css.property "padding-inline" (Css.px 0).value
                        , Css.property "padding-block" (Css.px 0).value
                        , Css.backgroundColor Css.transparent
                        , Css.borderColor (Css.rgba 0 0 0 0)
                        , Css.borderWidth (Css.px 1)
                        , Css.justifyContent Css.center
                        , Css.cursor Css.pointer
                        , Css.alignItems Css.center
                        , Css.focus [ Css.borderColor Css.inherit ]
                        , Css.borderRadius (Css.px 999)
                        ]
                    , type_ "button"
                    ]
                    [ ClearIcon.view ]
                ]

        _ ->
            text ""
