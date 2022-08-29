module MultiTruncation exposing (..)

import Browser
import Css
import Html.Styled as Styled exposing (Html, div)
import Html.Styled.Attributes as StyledAttribs
import Select exposing (MenuItem, initState, selectIdentifier, update)
import Select.Styles as Styles


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
            [ Select.basicMenuItem { item = "Elmmmmmmm", label = "Elmmmmmmm" }
            , Select.basicMenuItem { item = "Isssssss", label = "Isssssss" }
            , Select.basicMenuItem { item = "Reallyyyyyyy", label = "Reallyyyyyyy" }
            , Select.basicMenuItem { item = "Greattttttt", label = "Greattttttt" }
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
                        Just (Select.Select i) ->
                            model.selectedItems ++ [ i ]

                        Just (Select.DeselectMulti item) ->
                            List.filter (\i -> item /= i) model.selectedItems

                        _ ->
                            model.selectedItems
            in
            ( { model
                | selectState = selectState
                , selectedItems = updatedSelectedItems
              }
            , Cmd.map SelectMsg cmds
            )


view : Model -> Html Msg
view m =
    let
        selectedItems =
            List.map (\i -> Select.basicMenuItem { item = i, label = i }) m.selectedItems

        controlStyles =
            Styles.getControlConfig Styles.default
                |> Styles.setControlMultiTagTruncationWidth 40
                |> Styles.setControlMultiTagBackgroundColor (Css.hex "ddff33")
                |> Styles.setControlMultiTagDismissibleBackgroundColor (Css.hex "000000")
                |> Styles.setControlMultiTagBorderRadius 5

        customStyles =
            Styles.setControlStyles controlStyles Styles.default
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
                (Select.multi
                    selectedItems
                    |> Select.state m.selectState
                    |> Select.menuItems m.items
                    |> Select.placeholder "Placeholder"
                    |> Select.setStyles customStyles
                )
        ]
