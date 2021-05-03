module Single exposing (..)

import Browser
import Html.Styled as Styled exposing (Html)
import Select exposing (initState, selectIdentifier)


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
        , update = \_ m -> ( m, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }


view : Select.State -> Html Msg
view _ =
    Styled.map SelectMsg <| Select.view (Select.single Nothing) (selectIdentifier "SingleSelectExample")
