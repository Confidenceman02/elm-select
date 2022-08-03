module Select.Tag exposing
    ( backgroundColor
    , borderRadius
    , dataTestId
    , default
    , onDismiss
    , onMousedown
    , onMouseleave
    , rightMargin
    , truncateWidth
    , view
    )

import Css
import Html.Styled exposing (Html, div, span, text)
import Html.Styled.Attributes as StyledAttribs exposing (attribute)
import Html.Styled.Events exposing (on, onClick)
import Json.Decode as Decode
import Select.ClearIcon as ClearIcon


type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { onDismiss : Maybe msg
    , onMousedown : Maybe msg
    , onMouseleave : Maybe msg
    , truncationWidth : Maybe Float
    , rightMargin : Bool
    , backgroundColor : Css.Color
    , dataTestId : String
    , borderRadius : Float
    }



-- VARIANTS


defaults : Configuration msg
defaults =
    { onDismiss = Nothing
    , onMousedown = Nothing
    , onMouseleave = Nothing
    , truncationWidth = Nothing
    , rightMargin = False
    , backgroundColor = Css.hex "#E1E2EA"
    , dataTestId = "multiSelectTag"
    , borderRadius = 16
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


truncateWidth : Float -> Config msg -> Config msg
truncateWidth width (Config config) =
    Config { config | truncationWidth = Just width }


backgroundColor : Css.Color -> Config msg -> Config msg
backgroundColor c (Config config) =
    Config { config | backgroundColor = c }


borderRadius : Float -> Config msg -> Config msg
borderRadius rad (Config config) =
    Config { config | borderRadius = rad }


dataTestId : String -> Config msg -> Config msg
dataTestId testId (Config config) =
    Config { config | dataTestId = testId }


view : Config msg -> String -> Html msg
view (Config config) value =
    let
        resolveRightMargin =
            if config.rightMargin then
                Css.px 7

            else
                Css.px 0
    in
    div
        -- root
        [ StyledAttribs.css
            [ Css.fontSize (Css.rem 0.875)
            , Css.fontWeight (Css.int 400)
            , Css.marginRight resolveRightMargin
            , Css.color (Css.hex "#35374A")
            , Css.display Css.inlineBlock
            , Css.border3 (Css.px 2) Css.solid Css.transparent
            , Css.borderRadius (Css.px config.borderRadius)
            , Css.padding2 (Css.px 0) (Css.px 9.6)
            , Css.boxSizing Css.borderBox
            , Css.backgroundColor config.backgroundColor
            , Css.height (Css.px 30)
            ]
        , attribute "data-test-id" config.dataTestId
        ]
        [ div
            -- layoutContainer
            [ StyledAttribs.css
                [ Css.height (Css.pct 100), Css.displayFlex, Css.alignItems Css.center ]
            ]
            [ viewTextContent config value
            , viewClear config
            ]
        ]


viewTextContent : Configuration msg -> String -> Html msg
viewTextContent config value =
    let
        resolveTruncation =
            case config.truncationWidth of
                Just width ->
                    [ Css.textOverflow Css.ellipsis
                    , Css.overflowX Css.hidden
                    , Css.whiteSpace Css.noWrap
                    , Css.maxWidth (Css.px width)
                    ]

                Nothing ->
                    []
    in
    span
        -- truncate
        [ StyledAttribs.css resolveTruncation
        ]
        [ text value ]


viewClear : Configuration msg -> Html msg
viewClear config =
    let
        dismiss onDismissMsg =
            onClick onDismissMsg

        mousedown onMousedownMsg =
            on "mousedown" <| Decode.succeed onMousedownMsg

        mouseleave onMouseleaveMsg =
            on "mouseleave" <| Decode.succeed onMouseleaveMsg

        events =
            List.filterMap identity
                [ Maybe.map dismiss config.onDismiss
                , Maybe.map mousedown config.onMousedown
                , Maybe.map mouseleave config.onMouseleave
                ]
    in
    span
        -- dismissIcon
        (StyledAttribs.css
            [ Css.position Css.relative
            , Css.displayFlex
            , Css.height (Css.pct 100)
            , Css.alignItems Css.center
            , Css.padding2 (Css.px 0) (Css.rem 0.375)
            , Css.marginRight (Css.rem -0.6625)
            , Css.marginLeft (Css.rem -0.225)
            , Css.color (Css.hex "#6B6E94")
            , Css.cursor Css.pointer
            , Css.hover [ Css.color (Css.hex "#4B4D68") ]
            ]
            :: events
        )
        [ span
            [ -- background
              StyledAttribs.css
                [ Css.position Css.absolute
                , Css.display Css.inlineBlock
                , Css.width (Css.px 8)
                , Css.height (Css.px 8)
                , Css.backgroundColor (Css.hex "#FFFFFF")
                , Css.left (Css.px 10)
                , Css.top (Css.px 9)
                ]
            ]
            []
        , div
            [ StyledAttribs.css
                [ Css.height (Css.px 16)
                , Css.width (Css.px 16)
                , Css.zIndex (Css.int 1)
                , Css.displayFlex
                ]
            ]
            [ ClearIcon.view ]
        ]
