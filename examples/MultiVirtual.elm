module MultiVirtual exposing (..)

import Browser
import Css
import Html.Styled as Styled exposing (Html, div)
import Html.Styled.Attributes as StyledAttribs
import Select exposing (MenuItem, initState, selectIdentifier, update)


type Msg
    = SelectMsg (Select.Msg Int)


type alias Model =
    { selectState : Select.State
    , items : List (MenuItem Int)
    , selectedItems : List Int
    }


init : ( Model, Cmd Msg )
init =
    ( { selectState = initState (selectIdentifier "SingleSelectExample")
      , items =
            List.range 0 1000
                |> List.map
                    (\i ->
                        Select.basicMenuItem { item = i, label = String.fromInt i }
                    )
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
                        Just (Select.Select i) ->
                            model.selectedItems ++ [ i ]

                        Just (Select.Deselect deletedItems) ->
                            List.filter (\i -> not (List.member i deletedItems)) model.selectedItems

                        Just Select.Clear ->
                            []

                        _ ->
                            model.selectedItems
            in
            ( { model | selectState = selectState, selectedItems = updatedSelectedItems }, Cmd.map SelectMsg cmds )


view : Model -> Html Msg
view m =
    let
        toMenuItem item =
            Select.basicMenuItem { item = item, label = String.fromInt item }
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
            Select.viewVirtual
                (Select.multiVirtual (List.map toMenuItem m.selectedItems)
                    |> Select.state m.selectState
                    |> Select.menuItemsVirtual (Select.virtualFixedMenuItems 35 m.items)
                    |> Select.placeholder "Placeholder"
                    |> Select.searchable True
                    |> Select.clearable True
                )
        ]
