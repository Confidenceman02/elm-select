module Select.Native exposing
    ( ariaDescribedBy
    , ariaLabelledBy
    , controlStyles
    , multi
    , onInput
    , options
    , single
    , toNotSelected
    , toSelected
    , view
    , withId
    , withName
    , withPlaceholder
    )

import Css
import Html.Styled exposing (Html, option, select, text)
import Html.Styled.Attributes as StyledAttribs exposing (attribute, css, id, multiple, name)
import Html.Styled.Attributes.Aria as Aria
import Select.Events as Events
import Select.Styles
    exposing
        ( ControlConfig
        , default
        , getControlBackgroundColor
        , getControlBackgroundColorHover
        , getControlBorderColor
        , getControlBorderColorFocus
        , getControlBorderColorHover
        , getControlBorderRadius
        , getControlColor
        , getControlConfig
        )



-- CONSTANTS


singleIdPrefix : String
singleIdPrefix =
    "native-single-select-"


multiIdPrefix : String
multiIdPrefix =
    "native-multi-select-"


type Config msg
    = Config (Configuration msg)


type alias Configuration msg =
    { variant : Variant
    , id : String
    , controlStyles : ControlConfig
    , ariaLabelledBy : Maybe String
    , ariaDescribedBy : Maybe String
    , placeholder : Maybe String
    , options : List Option
    , onInput : Maybe (Int -> msg)
    , name : String
    }


type Variant
    = Single
    | Multi


type Option
    = Selected String
    | NotSelected String



-- CONFIG


defaults : Configuration msg
defaults =
    { variant = Single
    , id = singleIdPrefix
    , controlStyles = getControlConfig default
    , ariaLabelledBy = Nothing
    , ariaDescribedBy = Nothing
    , placeholder = Nothing
    , options = []
    , onInput = Nothing
    , name = "singleSelect"
    }


single : Config msg
single =
    Config { defaults | variant = Single }


multi : Config msg
multi =
    Config { defaults | variant = Multi, id = multiIdPrefix }



-- MODIFIERS


withId : String -> Config msg -> Config msg
withId id_ (Config config) =
    Config { config | id = id_ }


controlStyles : ControlConfig -> Config msg -> Config msg
controlStyles styles (Config config) =
    Config { config | controlStyles = styles }


ariaLabelledBy : String -> Config msg -> Config msg
ariaLabelledBy s (Config config) =
    Config { config | ariaLabelledBy = Just s }


ariaDescribedBy : String -> Config msg -> Config msg
ariaDescribedBy s (Config config) =
    Config { config | ariaDescribedBy = Just s }


withPlaceholder : String -> Config msg -> Config msg
withPlaceholder s (Config config) =
    Config { config | placeholder = Just s }


options : List Option -> Config msg -> Config msg
options opts (Config config) =
    Config { config | options = opts }


onInput : (Int -> msg) -> Config msg -> Config msg
onInput msg (Config config) =
    Config { config | onInput = Just msg }


withName : String -> Config msg -> Config msg
withName s (Config config) =
    Config { config | name = s }



-- HELPERS


toSelected : String -> Option
toSelected label =
    Selected label


toNotSelected : String -> Option
toNotSelected label =
    NotSelected label



-- VIEW


view : Config msg -> Html msg
view (Config config) =
    let
        withPlaceholder_ =
            case config.placeholder of
                Just placeholder ->
                    option
                        [ StyledAttribs.hidden True
                        , StyledAttribs.selected True
                        , StyledAttribs.disabled True
                        ]
                        [ text ("(" ++ placeholder ++ ")") ]

                _ ->
                    text ""

        buildList item =
            case item of
                Selected label ->
                    option [ StyledAttribs.value label, StyledAttribs.attribute "selected" "" ] [ text label ]

                NotSelected label ->
                    option [ StyledAttribs.value label ] [ text label ]

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

        withOnInput =
            case config.onInput of
                Just msg ->
                    [ Events.onInputAtInt [ "target", "selectedIndex" ] msg ]

                _ ->
                    []

        withMultiple =
            case config.variant of
                Multi ->
                    [ multiple True ]

                _ ->
                    []

        resolveIdPrefix =
            case config.variant of
                Single ->
                    singleIdPrefix

                Multi ->
                    multiIdPrefix
    in
    select
        ([ id (resolveIdPrefix ++ config.id)
         , attribute "data-test-id" "nativeSingleSelect"
         , name config.name
         , css
            [ Css.width (Css.pct 100)
            , Css.height (Css.px 48)
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
            ++ withOnInput
            ++ withMultiple
        )
        (withPlaceholder_ :: List.map buildList config.options)
