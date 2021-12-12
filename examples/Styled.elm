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
    ( { selectState = initState
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
                                , selectedItems = model.selectedItems ++ [ { label = i, item = i } ]
                              }
                            , Cmd.none
                            )

                        Just (Select.InputChange i) ->
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
                        [ { item = "Elm", label = "Elm" }
                        , { item = "Really", label = "Really" }
                        , { item = "Inspires", label = "Inspires" }
                        , { item = "Learning", label = "Learning" }
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
                    Just { item = i, label = i }

                _ ->
                    Nothing

        withLoading config =
            case m.items of
                Loading ->
                    Select.loading True config

                Loaded items ->
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
                    (selectIdentifier "SingleSelectExample")
            ]
        ]


allItems : List (Select.MenuItem String)
allItems =
    [ { item = "Elm", label = "Elm" }
    , { item = "Really", label = "Really" }
    , { item = "Inspires", label = "Inspires" }
    , { item = "Learning", label = "Learning" }
    ]
