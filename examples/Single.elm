module Single exposing (..)

import Browser
import Html.Styled as Styled exposing (Html)
import Select exposing (MenuItem, initState, selectIdentifier, update)


type Msg
    = SelectMsg (Select.Msg String)


type alias Model =
    { selectState : Select.State
    , items : List (MenuItem String)
    }


init : ( Model, Cmd Msg )
init =
    ( { selectState = initState, items = [ { item = "Something", label = "Something" } ] }, Cmd.none )


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
                ( _, updatedState, cmds ) =
                    Select.update sm model.selectState
            in
            ( { model | selectState = updatedState }, Cmd.map SelectMsg cmds )


view : Model -> Html Msg
view m =
    Styled.map SelectMsg <|
        Select.view
            (Select.single Nothing
                |> Select.state m.selectState
                |> Select.menuItems m.items
                |> Select.placeholder "placeholder"
            )
            (selectIdentifier "SingleSelectExample")
