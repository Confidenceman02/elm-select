module SingleGrouped exposing (..)

import Browser
import Css
import Html.Styled as Styled exposing (Html, div, text)
import Html.Styled.Attributes as StyledAttribs
import Select exposing (MenuItem, initState, selectIdentifier, update)
import Select.Styles as Styles


type Msg
    = SelectMsg (Select.Msg String)


type alias Model =
    { selectState : Select.State
    , items : List (MenuItem String)
    , selectedItem : Maybe String
    }


customColorGroupStyles : Styles.GroupConfig
customColorGroupStyles =
    Styles.getGroupConfig Styles.default
        |> Styles.setGroupColor (Css.hex "#FF3C33")


colorGroup : Select.Group
colorGroup =
    Select.group "colours"
        |> Select.groupStyles customColorGroupStyles
        |> Select.groupView (text "The colours")


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

                        Just Select.ClearSingleSelectItem ->
                            Nothing

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
                    |> Select.searchable False
                    |> Select.clearable True
                )
        ]
