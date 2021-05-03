module Single exposing (..)

import Browser
import Html.Styled as Styled exposing (Html)
import Select exposing (initState, selectIdentifier)


init : ( Select.State, Cmd msg )
init =
    ( initState, Cmd.none )


main : Program () Select.State msg
main =
    Browser.element
        { init = always init
        , view = view >> Styled.toUnstyled
        , update = \_ m -> ( m, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }


view : Select.State -> Html msg
view _ =
    Select.view (Select.single Nothing) (selectIdentifier "SingleSelectExample")
