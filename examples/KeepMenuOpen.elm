module KeepMenuOpen exposing (..)

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

                ( updatedSelectedItems, st ) =
                    case maybeAction of
                        Just (Select.Select i) ->
                            ( model.selectedItems ++ [ i ], selectState |> Select.keepMenuOpen True )

                        Just (Select.Deselect deletedItems) ->
                            ( List.filter (\i -> not (List.member i deletedItems)) model.selectedItems, selectState )

                        Just Select.Clear ->
                            ( [], selectState )

                        Just Select.Focus ->
                            let
                                _ =
                                    Debug.log "FOCUS" ()
                            in
                            ( model.selectedItems, selectState )

                        Just Select.Blur ->
                            let
                                updatedState =
                                    if Select.isFocused selectState then
                                        selectState

                                    else
                                        selectState |> Select.keepMenuOpen False
                            in
                            ( model.selectedItems, updatedState )

                        Just (Select.MenuToggle Select.MenuClose) ->
                            let
                                _ =
                                    Debug.log "CLOSE" ()
                            in
                            ( model.selectedItems, selectState |> Select.keepMenuOpen False )

                        _ ->
                            ( model.selectedItems, selectState )
            in
            ( { model | selectState = st, selectedItems = updatedSelectedItems }, Cmd.map SelectMsg cmds )


view : Model -> Html Msg
view m =
    let
        selectedItems =
            List.map (\i -> Select.basicMenuItem { item = i, label = i }) m.selectedItems
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
                (Select.multi selectedItems
                    |> Select.state m.selectState
                    |> Select.menuItems m.items
                    |> Select.placeholder "Placeholder"
                    |> Select.searchable True
                    |> Select.clearable True
                )
        ]
