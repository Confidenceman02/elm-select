module HeadlessSingle exposing (..)

import Browser
import Css
import Html.Styled as Styled exposing (Html, button, div, text)
import Html.Styled.Attributes as StyledAttribs
import Html.Styled.Events exposing (onClick)
import Select exposing (MenuItem, initState, selectIdentifier, update)
import Svg.Styled as SvgStyled
import Svg.Styled.Attributes as SvgAttribs


type Msg
    = SelectMsg (Select.Msg DropdownAction)
    | FocusInput


type alias Model =
    { selectState : Select.State
    , items : List (MenuItem DropdownAction)
    }


type DropdownAction
    = HideSettings
    | Duplicate
    | InsertBefore
    | InsertAfter
    | EditAsHTML
    | AddToBlocks


init : ( Model, Cmd Msg )
init =
    ( { selectState = initState (selectIdentifier "SingleSelectExample")
      , items =
            [ Select.basicMenuItem { item = HideSettings, label = "Hide settings" }
            , Select.basicMenuItem { item = Duplicate, label = "Duplicate" }
            , Select.basicMenuItem { item = InsertBefore, label = "Insert Before" }
            , Select.basicMenuItem { item = InsertAfter, label = "Insert After" }
            , Select.basicMenuItem { item = EditAsHTML, label = "Edit as HTML" }
            , Select.basicMenuItem { item = AddToBlocks, label = "Add to Blocks" }
            ]
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
                            Debug.log "Selected"

                        _ ->
                            Debug.log "Something else happened"
            in
            ( { model | selectState = selectState }, Cmd.map SelectMsg cmds )

        FocusInput ->
            ( model, Cmd.map SelectMsg (Select.focus model.selectState) )


view : Model -> Html Msg
view m =
    div
        [ StyledAttribs.css
            [ Css.marginTop (Css.px 20)
            , Css.width (Css.pct 50)
            , Css.marginLeft Css.auto
            , Css.marginRight Css.auto
            , Css.position Css.relative
            ]
        ]
        [ div
            [ StyledAttribs.css
                [ Css.property "gap" (Css.px 2).value
                , Css.justifyContent Css.flexEnd
                , Css.displayFlex
                ]
            ]
            [ withButton [ bold ]
            , withButton [ italic ]
            , withButton [ attachment ]
            , withButton [ horizontalKebab ]
            ]
        , Styled.map SelectMsg <|
            Select.view
                (Select.singleMenu Nothing
                    |> Select.state m.selectState
                    |> Select.menuItems m.items
                    |> Select.placeholder "Placeholder"
                    |> Select.searchable False
                )
        ]



-- ICONS


withButton : List (Html Msg) -> Html Msg
withButton =
    button
        [ StyledAttribs.css
            [ Css.displayFlex
            , Css.border (Css.px 0)
            , Css.padding (Css.rem 0.5)
            , Css.color (Css.hsla 0 0 0.68 1)
            , Css.backgroundColor (Css.hex "#E4E4E4")
            , Css.hover [ Css.backgroundColor (Css.hex "#D3D3D3"), Css.color (Css.hex "#8D8D8D") ]
            ]
        , onClick FocusInput
        ]


bold : Html msg
bold =
    Styled.span
        [ StyledAttribs.css
            [ Css.width (Css.px 30)
            , Css.displayFlex
            ]
        ]
        [ SvgStyled.svg [ SvgAttribs.viewBox "0 0 30 30" ]
            [ SvgStyled.path
                [ SvgAttribs.fill "currentColor"
                , SvgAttribs.d "M19.5 13.4875C20.7125 12.65 21.5625 11.275 21.5625 10C21.5625 7.175 19.375 5 16.5625 5H8.75V22.5H17.55C20.1625 22.5 22.1875 20.375 22.1875 17.7625C22.1875 15.8625 21.1125 14.2375 19.5 13.4875ZM12.5 8.125H16.25C17.2875 8.125 18.125 8.9625 18.125 10C18.125 11.0375 17.2875 11.875 16.25 11.875H12.5V8.125ZM16.875 19.375H12.5V15.625H16.875C17.9125 15.625 18.75 16.4625 18.75 17.5C18.75 18.5375 17.9125 19.375 16.875 19.375Z"
                ]
                []
            ]
        ]


italic : Html msg
italic =
    Styled.span
        [ StyledAttribs.css
            [ Css.width (Css.px 30)
            , Css.displayFlex
            ]
        ]
        [ SvgStyled.svg [ SvgAttribs.viewBox "0 0 30 30" ]
            [ SvgStyled.path
                [ SvgAttribs.fill "currentColor"
                , SvgAttribs.d "M12.5 5V8.75H15.2625L10.9875 18.75H7.5V22.5H17.5V18.75H14.7375L19.0125 8.75H22.5V5H12.5Z"
                ]
                []
            ]
        ]


attachment : Html msg
attachment =
    Styled.span
        [ StyledAttribs.css
            [ Css.width (Css.px 30)
            , Css.displayFlex
            ]
        ]
        [ SvgStyled.svg [ SvgAttribs.viewBox "0 0 30 30" ]
            [ SvgStyled.path [ SvgAttribs.fill "currentColor", SvgAttribs.d "M2.5 15.625C2.5 11.825 5.575 8.75 9.375 8.75H22.5C25.2625 8.75 27.5 10.9875 27.5 13.75C27.5 16.5125 25.2625 18.75 22.5 18.75H11.875C10.15 18.75 8.75 17.35 8.75 15.625C8.75 13.9 10.15 12.5 11.875 12.5H21.25V15H11.7625C11.075 15 11.075 16.25 11.7625 16.25H22.5C23.875 16.25 25 15.125 25 13.75C25 12.375 23.875 11.25 22.5 11.25H9.375C6.9625 11.25 5 13.2125 5 15.625C5 18.0375 6.9625 20 9.375 20H21.25V22.5H9.375C5.575 22.5 2.5 19.425 2.5 15.625Z" ] []
            ]
        ]


horizontalKebab : Html msg
horizontalKebab =
    Styled.span
        [ StyledAttribs.css
            [ Css.width (Css.px 30)
            , Css.displayFlex
            ]
        ]
        [ SvgStyled.svg [ SvgAttribs.viewBox "0 0 30 30" ]
            [ SvgStyled.path
                [ SvgAttribs.fill "currentColor"
                , SvgAttribs.d "M7.5 12.5C6.125 12.5 5 13.625 5 15C5 16.375 6.125 17.5 7.5 17.5C8.875 17.5 10 16.375 10 15C10 13.625 8.875 12.5 7.5 12.5ZM22.5 12.5C21.125 12.5 20 13.625 20 15C20 16.375 21.125 17.5 22.5 17.5C23.875 17.5 25 16.375 25 15C25 13.625 23.875 12.5 22.5 12.5ZM15 12.5C13.625 12.5 12.5 13.625 12.5 15C12.5 16.375 13.625 17.5 15 17.5C16.375 17.5 17.5 16.375 17.5 15C17.5 13.625 16.375 12.5 15 12.5Z"
                ]
                []
            ]
        ]
