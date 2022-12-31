module Form exposing (..)

import Browser
import Css
import Html.Styled as Styled exposing (Html, div, form)
import Html.Styled.Attributes as StyledAttribs
import Html.Styled.Events as Events
import Select exposing (MenuItem, initState, selectIdentifier, update)
import Select.Events as SelectEvents


type Msg
    = SelectMsg (Select.Msg String)
    | EnterSelect


type alias Model =
    { selectState : Select.State
    , items : List (MenuItem String)
    , selectedItem : Maybe String
    }


init : ( Model, Cmd Msg )
init =
    ( { selectState = initState (selectIdentifier "SingleSelectExample")
      , items =
            [ Select.basicMenuItem { item = "Elm", label = "Elm" }
            , Select.basicMenuItem { item = "Is", label = "Is" }
            , Select.basicMenuItem { item = "Really", label = "Really" }
            , Select.basicMenuItem { item = "Great", label = "Great" }
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

                        Just Select.Clear ->
                            Nothing

                        _ ->
                            model.selectedItem
            in
            ( { model | selectState = selectState, selectedItem = updatedSelectedItem }, Cmd.map SelectMsg cmds )

        EnterSelect ->
            ( model, Cmd.none ) |> Debug.log "Enter"


view : Model -> Html Msg
view m =
    let
        selectedItem =
            case m.selectedItem of
                Just i ->
                    Just (Select.basicMenuItem { item = i, label = i })

                _ ->
                    Nothing

        enterDecoder =
            Events.on "keydown" (SelectEvents.isEnter EnterSelect)
    in
    form [ enterDecoder, StyledAttribs.method "POST", StyledAttribs.action "/something" ]
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
                        |> Select.clearable True
                    )
            ]
        ]
