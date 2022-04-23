module Native exposing (..)

import Css
import Html.Styled exposing (Html, option, select, text)
import Html.Styled.Attributes exposing (attribute, css, disabled, hidden, id, name, selected, value)
import Html.Styled.Attributes.Aria as Aria
import Select.Events as Events
import Select.Styles
    exposing
        ( ControlConfig
        , getControlBackgroundColor
        , getControlBackgroundColorHover
        , getControlBorderColor
        , getControlBorderColorFocus
        , getControlBorderColorHover
        , getControlBorderRadius
        , getControlColor
        )



-- CONSTANTS


idPrefix : String
idPrefix =
    "native-single-select-"


type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { variant : Variant
    , id : String
    , height : Float
    , controlStyles : ControlConfig
    , ariaLabelledBy : Maybe String
    , ariaDescribedBy : Maybe String
    , placeholder : String
    , options : List Option
    , onInput : Int -> msg
    }


type Variant
    = Single
    | Multi


type Option
    = Selected String
    | NotSelected String



-- MODIFIERS


view : Config msg -> Html msg
view (Config config) =
    let
        withLabelledBy =
            case config.ariaLabelledBy of
                Just s ->
                    [ Aria.ariaLabelledby s ]

                _ ->
                    []

        withAriaDescribedBy =
            case config.ariaDescribedBy of
                Just s ->
                    [ Aria.ariaDescribedby s ]

                _ ->
                    []

        withPlaceholder =
            if List.any isSelected config.options then
                text ""

            else
                option
                    [ hidden True
                    , selected True
                    , disabled True
                    ]
                    [ text ("(" ++ config.placeholder ++ ")") ]

        buildList opt =
            case opt of
                Selected label ->
                    option [ value label, attribute "selected" "" ] [ text label ]

                NotSelected label ->
                    option [ value label ] [ text label ]
    in
    select
        ([ id (idPrefix ++ config.id)
         , attribute "data-test-id" "nativeSingleSelect"
         , name "SomeSelect"
         , Events.onInputAtInt [ "target", "selectedIndex" ] config.onInput
         , css
            [ Css.width (Css.pct 100)
            , Css.height (Css.px config.height)
            , Css.borderRadius <| Css.px (getControlBorderRadius config.controlStyles)
            , Css.backgroundColor (getControlBackgroundColor config.controlStyles)
            , Css.border3 (Css.px 2) Css.solid (getControlBorderColor config.controlStyles)
            , Css.padding2 (Css.px 2) (Css.px 8)
            , Css.property "appearance" "none"
            , Css.property "-webkit-appearance" "none"
            , Css.color (getControlColor config.controlStyles)
            , Css.fontSize (Css.px 16)
            , Css.focus
                [ Css.borderColor (getControlBorderColorFocus config.controlStyles), Css.outline Css.none ]
            , Css.hover
                [ Css.backgroundColor (getControlBackgroundColorHover config.controlStyles)
                , Css.borderColor (getControlBorderColorHover config.controlStyles)
                ]
            ]
         ]
            ++ withLabelledBy
            ++ withAriaDescribedBy
        )
        (withPlaceholder :: List.map buildList config.options)


isSelected : Option -> Bool
isSelected opt =
    case opt of
        Selected _ ->
            True

        _ ->
            False
