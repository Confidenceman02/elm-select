module Styled exposing (..)

import Browser
import Css
import Html.Styled as Styled exposing (Html, div)
import Html.Styled.Attributes as StyledAttribs
import Process
import Select exposing (MenuItem, initState, selectIdentifier, update)
import Select.Styles as Styles
import Task


type Msg
    = SelectMsg (Select.Msg String)
    | FetchedItems


type Items
    = Loading
    | Loaded (List (MenuItem String))


type alias Model =
    { selectState : Select.State
    , items : Items
    , selectedItem : Maybe String
    , selectedItems : List (Select.MenuItem String)
    }


init : ( Model, Cmd Msg )
init =
    ( { selectState = initState (selectIdentifier "SingleSelectExample")
      , items =
            Loaded
                []
      , selectedItem = Nothing
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

                ( updatedModel, actionCmds ) =
                    case maybeAction of
                        Just (Select.Select i) ->
                            ( { model
                                | selectState = selectState
                                , selectedItem = Just i
                                , selectedItems = model.selectedItems ++ [ Select.basicMenuItem { label = i, item = i } ]
                              }
                            , Cmd.none
                            )

                        Just (Select.InputChange _) ->
                            ( { model | items = Loading, selectState = selectState }
                            , Task.perform (\_ -> FetchedItems)
                                (Process.sleep 1000)
                            )

                        _ ->
                            ( { model | selectState = selectState }, Cmd.none )
            in
            ( updatedModel, Cmd.batch [ Cmd.map SelectMsg cmds, actionCmds ] )

        FetchedItems ->
            ( { model
                | items =
                    Loaded
                        [ Select.basicMenuItem { item = "Elm", label = "Elm" }
                        , Select.basicMenuItem { item = "Really", label = "Really" }
                        , Select.basicMenuItem { item = "Inspires", label = "Inspires" }
                        , Select.basicMenuItem { item = "Learning", label = "Learning" }
                            |> Select.stylesMenuItem
                                (Styles.getMenuItemConfig Styles.dracula
                                    |> Styles.setMenuItemColorHover (Css.hex "#512DA8")
                                    |> Styles.setMenuItemBackgroundColor (Css.hex "#512DA8")
                                )
                        ]
              }
            , Cmd.none
            )


view : Model -> Html Msg
view m =
    let
        selectedItem =
            case m.selectedItem of
                Just i ->
                    Just (Select.basicMenuItem { item = i, label = i })

                _ ->
                    Nothing

        withLoading config =
            case m.items of
                Loading ->
                    Select.loading True config

                Loaded _ ->
                    Select.loading False config

        withItems config =
            case m.items of
                Loaded i ->
                    Select.menuItems i config

                Loading ->
                    Select.menuItems [] config
    in
    div
        [ StyledAttribs.css
            [ Css.position Css.absolute
            , Css.left (Css.px 0)
            , Css.right (Css.px 0)
            , Css.top (Css.px 0)
            , Css.bottom (Css.px 0)
            , Css.backgroundColor (Css.hex "#0D1117")
            ]
        ]
        [ div
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
                        |> Select.placeholder "Placeholder"
                        |> Select.searchable True
                        |> Select.setStyles Styles.dracula
                        |> Select.clearable True
                        |> withLoading
                        -- |> Select.menuItems allItems
                        |> withItems
                    )
            ]
        ]


allItems : List (Select.MenuItem String)
allItems =
    [ Select.basicMenuItem { item = "Elm", label = "Elm" }
    , Select.basicMenuItem { item = "Really", label = "Really" }
    , Select.basicMenuItem { item = "Inspires", label = "Inspires" }
    , Select.basicMenuItem { item = "Learning", label = "Learning" }
    ]
