module Native exposing (..)

import Browser
import Css
import Html.Styled as Styled exposing (Html, div)
import Html.Styled.Attributes as StyledAttribs
import Select exposing (MenuItem, initState, selectIdentifier, update)


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
    in
    div
        [ StyledAttribs.css
            [ Css.marginTop (Css.px 20)
            , Css.width (Css.pct 50)
            , Css.marginLeft Css.auto
            , Css.marginRight Css.auto
            ]
        ]
        [ Styled.map SelectMsg <|
            Select.view
                (Select.native
                    |> Select.state m.selectState
                    |> Select.menuItems m.items
                    |> Select.placeholder "Placeholder"
                )
                (selectIdentifier "SingleSelectExample")
        ]
