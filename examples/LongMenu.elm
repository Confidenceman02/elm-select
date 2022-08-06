module LongMenu exposing (..)

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
    ( { selectState = initState (selectIdentifier "SingleSelectExample")
      , items =
            [ Select.basicMenuItem { item = "Elm", label = "Elm" }
            , Select.basicMenuItem { item = "Is", label = "Is" }
            , Select.basicMenuItem { item = "Really", label = "Really" }
            , Select.basicMenuItem { item = "Great", label = "Great" }
            , Select.basicMenuItem { item = "And", label = "And" }
            , Select.basicMenuItem { item = "Fun", label = "Fun" }
            , Select.basicMenuItem { item = "To", label = "To" }
            , Select.basicMenuItem { item = "Use", label = "Use" }
            , Select.basicMenuItem { item = "All", label = "All" }
            , Select.basicMenuItem { item = "The", label = "The" }
            , Select.basicMenuItem { item = "Time", label = "Time" }
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
                    Just (Select.basicMenuItem { item = i, label = i })

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
                (Select.single selectedItem
                    |> Select.state m.selectState
                    |> Select.menuItems m.items
                    |> Select.placeholder "Placeholder"
                )
        ]
