module MultiNativeGrouped exposing (..)

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


colorGroup : Select.Group
colorGroup =
    Select.group "colours"


flavourGroup : Select.Group
flavourGroup =
    Select.group "flavours"


init : ( Model, Cmd Msg )
init =
    ( { selectState = initState (selectIdentifier "SingleSelectExample")
      , items =
            [ Select.groupedMenuItem colorGroup
                (Select.basicMenuItem { item = "Ocean", label = "Ocean" })
            , Select.basicMenuItem { item = "Random", label = "Random" }
            , Select.groupedMenuItem colorGroup
                (Select.basicMenuItem { item = "Blue", label = "Blue" })
            , Select.groupedMenuItem colorGroup
                (Select.basicMenuItem { item = "Purple", label = "Purple" })
            , Select.groupedMenuItem colorGroup
                (Select.basicMenuItem { item = "Red", label = "Red" })
            , Select.groupedMenuItem colorGroup
                (Select.basicMenuItem { item = "Orange", label = "Orange" })
            , Select.groupedMenuItem colorGroup
                (Select.basicMenuItem { item = "Yellow", label = "Yellow" })
            , Select.groupedMenuItem colorGroup
                (Select.basicMenuItem { item = "Green", label = "Green" })
            , Select.groupedMenuItem colorGroup
                (Select.basicMenuItem { item = "Forest", label = "Forest" })
            , Select.groupedMenuItem colorGroup
                (Select.basicMenuItem { item = "Slate", label = "Slate" })
            , Select.groupedMenuItem colorGroup
                (Select.basicMenuItem { item = "Silver", label = "Silver" })
            , Select.groupedMenuItem flavourGroup
                (Select.basicMenuItem { item = "Vanilla", label = "Vanilla" })
            , Select.groupedMenuItem flavourGroup
                (Select.basicMenuItem { item = "Chocolate", label = "Chocolate" })
            , Select.groupedMenuItem flavourGroup
                (Select.basicMenuItem { item = "Strawberry", label = "Strawberry" })
            , Select.basicMenuItem { item = "Salted Caramel", label = "Salted Caramel" }
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
