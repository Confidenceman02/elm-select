module SingleNativeGrouped exposing (..)

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
    , selectedItem : Maybe String
    }


group : Select.Group
group =
    Select.group "Language"


init : ( Model, Cmd Msg )
init =
    ( { selectState = initState (selectIdentifier "SingleSelectExample")
      , items =
            [ Select.groupedMenuItem group (Select.basicMenuItem { item = "Elm", label = "Elm" })
            , Select.groupedMenuItem group (Select.basicMenuItem { item = "Is", label = "Is" })
            , Select.groupedMenuItem group (Select.basicMenuItem { item = "Really", label = "Really" })
            , Select.groupedMenuItem group (Select.basicMenuItem { item = "Great", label = "Great" })
            , Select.basicMenuItem { item = "And", label = "And" }
            , Select.basicMenuItem { item = "I", label = "I" }
            , Select.basicMenuItem { item = "Love", label = "Love" }
            , Select.basicMenuItem { item = "It", label = "It" }
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
                            Just i

                        Just Select.Clear ->
                            Nothing

                        _ ->
                            model.selectedItem
            in
            ( { model
                | selectState = selectState
                , selectedItem = updatedSelectedItem
              }
            , Cmd.map SelectMsg cmds
            )


view : Model -> Html Msg
view m =
    let
        selectedItem =
            case m.selectedItem of
                Just it ->
                    Just (Select.basicMenuItem { item = it, label = it })

                _ ->
                    Nothing
    in
    div
        [ StyledAttribs.css
            [ Css.margin (Css.px 20)
            ]
        ]
        [ Styled.map SelectMsg <|
            Select.view
                (Select.singleNative selectedItem
                    |> Select.state m.selectState
                    |> Select.menuItems m.items
                    |> Select.placeholder "Select something"
                    |> Select.clearable True
                )
        ]
