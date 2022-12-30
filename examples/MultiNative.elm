module MultiNative exposing (..)

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
    , selectedItems : List String
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
            , Select.basicMenuItem { item = "I", label = "I" }
            , Select.basicMenuItem { item = "Love", label = "Love" }
            , Select.basicMenuItem { item = "It", label = "It" }
            , Select.basicMenuItem { item = "A", label = "A" }
            , Select.basicMenuItem { item = "Lot", label = "Lot" }
            ]
      , selectedItems = []
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

                updatedSelectedItems =
                    case maybeAction of
                        Just (Select.SelectBatch items) ->
                            items

                        _ ->
                            model.selectedItems
            in
            ( { model | selectState = selectState, selectedItems = updatedSelectedItems }, Cmd.map SelectMsg cmds )


view : Model -> Html Msg
view m =
    let
        selectedItems it =
            Select.basicMenuItem { item = it, label = it }
    in
    div
        [ StyledAttribs.css
            [ Css.margin (Css.px 20)
            ]
        ]
        [ Styled.map SelectMsg <|
            Select.view
                (Select.multiNative (List.map selectedItems m.selectedItems)
                    |> Select.state m.selectState
                    |> Select.menuItems m.items
                    |> Select.placeholder "Select something"
                )
        ]
