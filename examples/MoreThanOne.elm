module MoreThanOne exposing (..)

import Browser
import Css
import Html.Styled as Styled exposing (Html, div)
import Html.Styled.Attributes as StyledAttribs
import Select exposing (MenuItem, initState, selectIdentifier, update)


type Msg
    = SelectInput1Msg (Select.Msg String)
    | SelectInput2Msg (Select.Msg String)


type alias Model =
    { input1 :
        { selectState : Select.State
        , items : List (MenuItem String)
        , selectedItem : Maybe String
        }
    , input2 :
        { selectState : Select.State
        , items : List (MenuItem String)
        , selectedItems : List String
        }
    }


init : ( Model, Cmd Msg )
init =
    ( { input1 =
            { selectState = initState (selectIdentifier "SingleSelectExample")
            , items =
                [ Select.basicMenuItem { item = "Elm", label = "Elm" }
                , Select.basicMenuItem { item = "Is", label = "Is" }
                , Select.basicMenuItem { item = "Really", label = "Really" }
                , Select.basicMenuItem { item = "Great", label = "Great" }
                ]
            , selectedItem = Nothing
            }
      , input2 =
            { selectState = initState (selectIdentifier "MultiSelectExample")
            , items =
                [ Select.basicMenuItem { item = "Can't", label = "Can't" }
                , Select.basicMenuItem { item = "Get", label = "Get" }
                , Select.basicMenuItem { item = "Enough", label = "Enough" }
                , Select.basicMenuItem { item = "Of", label = "Of" }
                , Select.basicMenuItem { item = "It!", label = "It!" }
                ]
            , selectedItems = []
            }
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
        SelectInput1Msg sm ->
            let
                ( maybeAction, selectState, cmds ) =
                    Select.update sm model.input1.selectState

                updatedSelectedItem =
                    case maybeAction of
                        Just (Select.Select i) ->
                            Just i |> Debug.log "Selected"

                        _ ->
                            model.input1.selectedItem

                modelInput1 =
                    model.input1

                input1 =
                    { modelInput1 | selectState = selectState, selectedItem = updatedSelectedItem }
            in
            ( { model | input1 = input1 }, Cmd.map SelectInput1Msg cmds )

        SelectInput2Msg sm ->
            let
                ( maybeAction, selectState, cmds ) =
                    Select.update sm model.input2.selectState

                updatedSelectedItems =
                    case maybeAction of
                        Just (Select.Select i) ->
                            model.input2.selectedItems ++ [ i ]

                        Just (Select.DeselectMulti deselectedItems) ->
                            List.filter (\i -> not (List.member i deselectedItems)) model.input2.selectedItems

                        _ ->
                            model.input2.selectedItems

                modelInput2 =
                    model.input2

                input2 =
                    { modelInput2 | selectState = selectState, selectedItems = updatedSelectedItems }
            in
            ( { model | input2 = input2 }, Cmd.map SelectInput1Msg cmds )


view : Model -> Html Msg
view m =
    let
        input1SelectedItem =
            case m.input1.selectedItem of
                Just i ->
                    Just (Select.basicMenuItem { item = i, label = i })

                _ ->
                    Nothing

        input2SelectedItems =
            List.map (\i -> Select.basicMenuItem { item = i, label = i }) m.input2.selectedItems
    in
    div
        [ StyledAttribs.css
            [ Css.marginTop (Css.px 20)
            , Css.width (Css.pct 50)
            , Css.marginLeft Css.auto
            , Css.marginRight Css.auto
            ]
        ]
        [ div [ StyledAttribs.css [ Css.marginBottom (Css.px 20) ] ]
            [ Styled.map SelectInput1Msg <|
                Select.view
                    (Select.single input1SelectedItem
                        |> Select.state m.input1.selectState
                        |> Select.menuItems m.input1.items
                        |> Select.placeholder "Placeholder"
                        |> Select.searchable False
                    )
            ]
        , Styled.map SelectInput2Msg <|
            Select.view
                (Select.multi input2SelectedItems
                    |> Select.state m.input2.selectState
                    |> Select.menuItems m.input2.items
                    |> Select.placeholder "Placeholder"
                )
        ]
