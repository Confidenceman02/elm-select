module Styled exposing (..)

import Browser
import Css
import Html.Styled as Styled exposing (Html, div)
import Html.Styled.Attributes as StyledAttribs
import Select exposing (MenuItem, initState, selectIdentifier, update)
import Select.Styles as Styles


type Msg
    = SelectMsg (Select.Msg String)


type alias Model =
    { selectState : Select.State
    , items : List (MenuItem String)
    , selectedItem : Maybe String
    }


init : ( Model, Cmd Msg )
init =
    ( { selectState = initState
      , items =
            [ { item = "Elm", label = "Elm" }
            , { item = "Is", label = "Is" }
            , { item = "Really", label = "Really" }
            , { item = "Great", label = "Great" }
            ]
      , selectedItem = Nothing
      }
    , Cmd.none
    )


main : Program () Model Msg
main =
    Browser.element
        { init = always init
        , view = view >> Styled.toUnstyled
        , update = update
        , subscriptions = \_ -> Sub.none
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectMsg sm ->
            let
                ( maybeAction, selectState, cmds ) =
                    Select.update sm model.selectState

                updatedSelectedItem =
                    case maybeAction of
                        Just (Select.Select i) ->
                            Just i |> Debug.log "Selected"

                        _ ->
                            model.selectedItem
            in
            ( { model | selectState = selectState, selectedItem = updatedSelectedItem }, Cmd.map SelectMsg cmds )


view : Model -> Html Msg
view m =
    let
        selectedItem =
            case m.selectedItem of
                Just i ->
                    Just { item = i, label = i }

                _ ->
                    Nothing

        baseBranding : Styles.Config
        baseBranding =
            Styles.default
                |> Styles.setControlStyles controlBranding
                |> Styles.setMenuStyles menuBranding
                |> Styles.setMenuItemStyles menuItemBranding

        controlBranding : Styles.ControlConfig
        controlBranding =
            Styles.getControlConfig Styles.default
                |> Styles.setControlBorderColor (Css.hex "#ff79c6")
                |> Styles.setControlBorderColorHover (Css.hex "#ff79c6")
                |> Styles.setControlBorderColorFocus (Css.hex "#ff79c6")
                |> Styles.setControlBackgroundColorHover (Css.rgba 255 255 65 0.2)
                |> Styles.setControlSeparatorColor (Css.hex "#ff79c6")
                |> Styles.setControlDropdownIndicatorColor (Css.hex "#ff79c6")
                |> Styles.setControlDropdownIndicatorColorHover (Css.hex "#e66db2")
                |> Styles.setControlClearIndicatorColor (Css.hex "#ff79c6")
                |> Styles.setControlClearIndicatorColorHover (Css.hex "#e66db2")
                |> Styles.setControlBackgroundColor (Css.hex "#282a36")
                |> Styles.setControlBackgroundColorHover (Css.hex "#282a36")

        menuBranding : Styles.MenuConfig
        menuBranding =
            Styles.getMenuConfig Styles.default
                |> Styles.setMenuBoxShadowColor (Css.rgba 255 165 44 0.2)
                |> Styles.setMenuBackgroundColor (Css.hex "#282a36")

        menuItemBranding : Styles.MenuItemConfig
        menuItemBranding =
            Styles.getMenuItemConfig Styles.default
                |> Styles.setMenuItemBackgroundColorNotSelected (Css.hex "#44475a")
                |> Styles.setMenuItemBackgroundColorSelected (Css.hex "#ff79c6")
                |> Styles.setMenuItemBackgroundColorClicked (Css.hex "#44475a")
                |> Styles.setMenuItemColor (Css.hex "#aeaea9")
    in
    div
        [ StyledAttribs.css
            [ Css.position Css.absolute
            , Css.left (Css.px 0)
            , Css.right (Css.px 0)
            , Css.top (Css.px 0)
            , Css.bottom (Css.px 0)
            , Css.backgroundColor (Css.hex "#0D1117")
            ]
        ]
        [ div
            [ StyledAttribs.css
                [ Css.marginTop (Css.px 20)
                , Css.width (Css.pct 50)
                , Css.marginLeft Css.auto
                , Css.marginRight Css.auto
                ]
            ]
            [ Styled.map SelectMsg <|
                Select.view
                    (Select.single selectedItem
                        |> Select.state m.selectState
                        |> Select.menuItems m.items
                        |> Select.placeholder "Placeholder"
                        |> Select.searchable False
                        |> Select.setStyles baseBranding
                        |> Select.clearable True
                    )
                    (selectIdentifier "SingleSelectExample")
            ]
        ]
