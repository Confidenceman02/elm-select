module Single exposing (..)

import Browser
import Html.Styled as Styled exposing (Html)
import Select exposing (initState, selectIdentifier, update)


type Msg
    = SelectMsg (Select.Msg String)


init : ( Select.State, Cmd Msg )
init =
    ( initState, Cmd.none )


main : Program () Select.State Msg
main =
    Browser.element
        { init = always init
        , view = view >> Styled.toUnstyled
        , update = update
        , subscriptions = \_ -> Sub.none
        }


update : Msg -> Select.State -> ( Select.State, Cmd Msg )
update msg model =
    case msg of
        SelectMsg sm ->
            let
                ( _, updatedState, cmds ) =
                    Select.update sm model
            in
            ( updatedState, Cmd.map SelectMsg cmds )


view : Select.State -> Html Msg
view m =
    Styled.map SelectMsg <| Select.view (Select.single Nothing |> Select.state m) (selectIdentifier "SingleSelectExample")
