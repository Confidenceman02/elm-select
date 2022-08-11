module MultiFilterable exposing (..)

import Browser
import Css
import Html.Styled as Styled exposing (Html, div, text)
import Html.Styled.Attributes as StyledAttribs
import List.Extra as LE
import Select exposing (MenuItem, initState, selectIdentifier, update)
import Select.Styles as Styles


type Msg
    = SelectMsg (Select.Msg Item)


type Item
    = Item String
    | NewItem String
    | ItemBuilder String


type alias Model =

    { selectState : Select.State
    , items : List Item
    , selectedItems : List Item
    }


init : ( Model, Cmd Msg )
init =
    ( { selectState = initState (selectIdentifier "SingleSelectExample")
      , items =
            [ Item "Elm"
            , Item "Is"
            , Item "Really"
            , Item "Great"
            , ItemBuilder ""
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

                updatedModel =
                    case maybeAction of
                        Just (Select.InputChange query) ->
                            { model | items = LE.updateIf isItemBuilder (\_ -> ItemBuilder query) model.items }

                        Just (Select.Select i) ->
                            case i of
                                ItemBuilder val ->
                                    let
                                        newItem =
                                            NewItem val
                                    in
                                    { model
                                        | selectedItems = model.selectedItems ++ [ newItem ]
                                        , items = LE.updateIf isItemBuilder (\_ -> newItem) model.items ++ [ ItemBuilder "" ]
                                    }

                                _ ->
                                    { model | selectedItems = model.selectedItems ++ [ i ] }

                        Just (Select.DeselectMulti item) ->
                            { model | selectedItems = List.filter (\i -> item /= i) model.selectedItems }

                        _ ->
                            model
            in
            ( { updatedModel | selectState = selectState }, Cmd.map SelectMsg cmds )


isItemBuilder : Item -> Bool
isItemBuilder i =
    case i of
        ItemBuilder _ ->
            True

        _ ->
            False


itemMap : (Item -> Item) -> Item -> Item
itemMap f =
    f


getItemValue : Item -> String
getItemValue i =
    case i of
        Item val ->
            val

        NewItem val ->
            val

        ItemBuilder val ->
            val


itemToMenuItem : Item -> MenuItem Item
itemToMenuItem i =
    case i of
        Item val ->
            Select.basicMenuItem { item = i, label = val }

        NewItem val ->
            Select.basicMenuItem { item = i, label = val }

        ItemBuilder val ->
            Select.customMenuItem
                { item = i
                , label = val
                , view =
                    let
                        resolveValue =
                            if String.isEmpty val then
                                "Type text to add new value"

                            else
                                val
                    in
                    div
                        [ StyledAttribs.css
                            [ Css.displayFlex
                            , Css.position Css.relative
                            ]
                        ]
                        [ div
                            [ StyledAttribs.css
                                [ Css.position Css.absolute
                                , Css.height (Css.pct 100)
                                , Css.border3 (Css.px 1) Css.solid (Css.hex "#000000")
                                ]
                            ]
                            []
                        , div
                            [ StyledAttribs.css [ Css.marginLeft (Css.rem 1) ]
                            ]
                            [ div
                                [ StyledAttribs.css
                                    [ Css.fontSize (Css.px 16)
                                    , Css.color (Css.hex "#1576CF")
                                    ]
                                ]
                                [ text "New value" ]
                            , div [ StyledAttribs.css [ Css.fontSize (Css.px 14) ] ] [ text resolveValue ]
                            ]
                        ]
                }
                |> Select.filterableMenuItem False


view : Model -> Html Msg
view m =
    let
        selectedItemToMenuItem : Item -> MenuItem Item
        selectedItemToMenuItem item =
            case item of
                Item val ->
                    Select.basicMenuItem { item = item, label = val }

                NewItem val ->
                    Select.basicMenuItem { item = item, label = val }

                ItemBuilder val ->
                    Select.basicMenuItem { item = item, label = val }

        controlStyles =
            Styles.getControlConfig Styles.default
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
                (Select.multi (List.map selectedItemToMenuItem m.selectedItems)
                    |> Select.state m.selectState
                    |> Select.menuItems (List.map itemToMenuItem m.items)
                    |> Select.placeholder "Placeholder"
                    |> Select.setStyles customStyles
                )
        ]
