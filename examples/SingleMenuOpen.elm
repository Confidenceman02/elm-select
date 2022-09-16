module SingleMenuOpen exposing (..)

import Browser
import Css
import Html.Styled as Styled exposing (Html, div, text)
import Html.Styled.Attributes as StyledAttribs
import Select exposing (MenuItem, update)
import Svg.Styled as SvgStyled
import Svg.Styled.Attributes as SvgAttribs


type Msg
    = SelectMsg (Select.Msg DropdownAction)


type alias Model =
    { items : List (MenuItem DropdownAction)
    , state : Select.State
    , selected : Maybe DropdownAction
    }


type Action
    = Bold
    | Italic
    | Attachment
    | Dropdown


type DropdownAction
    = HideSettings
    | Duplicate
    | InsertBefore
    | InsertAfter
    | EditAsHTML
    | AddToBlocks


actionToString : DropdownAction -> String
actionToString act =
    case act of
        HideSettings ->
            "Hide settings"

        Duplicate ->
            "Duplicate"

        InsertBefore ->
            "Insert Before"

        InsertAfter ->
            "Insert After"

        EditAsHTML ->
            "Edit as HHTML"

        AddToBlocks ->
            "Add to Blocks"


init : ( Model, Cmd Msg )
init =
    ( { items =
            [ customMenuItem HideSettings "Hide settings"
            , customMenuItem Duplicate "Duplicate"
            , customMenuItem InsertBefore "Insert Before"
            , customMenuItem InsertAfter "Insert After"
            , customMenuItem EditAsHTML "Edit as HTML"
            , customMenuItem AddToBlocks "Add to Blocks"
            ]
      , state =
            Select.initState (Select.selectIdentifier "somestate")
                |> Select.keepMenuOpen True
      , selected = Nothing
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
                    Select.update sm model.state

                updatedSelected =
                    case maybeAction of
                        Just (Select.Select item) ->
                            Just item

                        _ ->
                            model.selected
            in
            ( { model | state = selectState, selected = updatedSelected }, Cmd.map SelectMsg cmds )


view : Model -> Html Msg
view m =
    Styled.map SelectMsg <|
        Select.view
            (Select.singleMenu
                (Maybe.map
                    (\act ->
                        Select.basicMenuItem
                            { item = act, label = actionToString act }
                    )
                    m.selected
                )
                |> Select.state m.state
                |> Select.menuItems m.items
                |> Select.placeholder "Placeholder"
                |> Select.searchable True
                |> Select.clearable True
            )


customMenuItem : DropdownAction -> String -> MenuItem DropdownAction
customMenuItem act label =
    let
        resolveIcon =
            case act of
                HideSettings ->
                    hideSettings

                Duplicate ->
                    duplicate

                InsertBefore ->
                    insertBefore

                InsertAfter ->
                    insertAfter

                EditAsHTML ->
                    code

                AddToBlocks ->
                    addToBlocks
    in
    Select.customMenuItem
        { item = act
        , label = label
        , view =
            div
                [ StyledAttribs.css
                    [ Css.displayFlex
                    , Css.property "gap" (Css.rem 1).value
                    ]
                ]
                [ resolveIcon, text label ]
        }


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


hideSettings : Html msg
hideSettings =
    Styled.span
        [ StyledAttribs.css
            [ Css.width (Css.px 20)
            , Css.displayFlex
            ]
        ]
        [ SvgStyled.svg [ SvgAttribs.viewBox "0 0 20 20" ]
            [ SvgStyled.path
                [ SvgAttribs.fill "currentColor"
                , SvgAttribs.d "M9.16669 5.83333L8.00002 7L10.1667 9.16667H1.66669V10.8333H10.1667L8.00002 13L9.16669 14.1667L13.3334 10L9.16669 5.83333ZM16.6667 15.8333H10V17.5H16.6667C17.5834 17.5 18.3334 16.75 18.3334 15.8333V4.16667C18.3334 3.25 17.5834 2.5 16.6667 2.5H10V4.16667H16.6667V15.8333Z"
                ]
                []
            ]
        ]


duplicate : Html msg
duplicate =
    Styled.span
        [ StyledAttribs.css
            [ Css.width (Css.px 20)
            , Css.displayFlex
            ]
        ]
        [ SvgStyled.svg [ SvgAttribs.viewBox "0 0 20 20" ]
            [ SvgStyled.path
                [ SvgAttribs.fill "currentColor"
                , SvgAttribs.d "M13.3333 0.833374H3.33334C2.41667 0.833374 1.66667 1.58337 1.66667 2.50004V14.1667H3.33334V2.50004H13.3333V0.833374ZM15.8333 4.16671H6.66667C5.75 4.16671 5.00001 4.91671 5.00001 5.83337V17.5C5.00001 18.4167 5.75 19.1667 6.66667 19.1667H15.8333C16.75 19.1667 17.5 18.4167 17.5 17.5V5.83337C17.5 4.91671 16.75 4.16671 15.8333 4.16671ZM15.8333 17.5H6.66667V5.83337H15.8333V17.5Z"
                ]
                []
            ]
        ]


insertBefore : Html msg
insertBefore =
    Styled.span
        [ StyledAttribs.css
            [ Css.width (Css.px 20)
            , Css.displayFlex
            ]
        ]
        [ SvgStyled.svg [ SvgAttribs.viewBox "0 0 20 20" ]
            [ SvgStyled.path
                [ SvgAttribs.fill "currentColor"
                , SvgAttribs.d "M6.66666 9.16667H9.16666V17.5H10.8333V9.16667H13.3333L9.99999 5.83333L6.66666 9.16667ZM3.33333 2.5V4.16667H16.6667V2.5H3.33333Z"
                ]
                []
            ]
        ]


insertAfter : Html msg
insertAfter =
    Styled.span
        [ StyledAttribs.css
            [ Css.width (Css.px 20)
            , Css.displayFlex
            ]
        ]
        [ SvgStyled.svg [ SvgAttribs.viewBox "0 0 20 20" ]
            [ SvgStyled.path
                [ SvgAttribs.fill "currentColor"
                , SvgAttribs.d "M13.3333 10.8333H10.8333V2.5H9.16666V10.8333H6.66666L9.99999 14.1667L13.3333 10.8333ZM3.33333 15.8333V17.5H16.6667V15.8333H3.33333Z"
                ]
                []
            ]
        ]


code : Html msg
code =
    Styled.span
        [ StyledAttribs.css
            [ Css.width (Css.px 20)
            , Css.displayFlex
            ]
        ]
        [ SvgStyled.svg [ SvgAttribs.viewBox "0 0 20 20" ]
            [ SvgStyled.path
                [ SvgAttribs.fill "currentColor"
                , SvgAttribs.d "M7.83334 13.8333L4.00001 10L7.83334 6.16667L6.66667 5L1.66667 10L6.66667 15L7.83334 13.8333ZM12.1667 13.8333L16 10L12.1667 6.16667L13.3333 5L18.3333 10L13.3333 15L12.1667 13.8333V13.8333Z"
                ]
                []
            ]
        ]


addToBlocks : Html msg
addToBlocks =
    Styled.span
        [ StyledAttribs.css
            [ Css.width (Css.px 20)
            , Css.displayFlex
            ]
        ]
        [ SvgStyled.svg [ SvgAttribs.viewBox "0 0 20 20" ]
            [ SvgStyled.path
                [ SvgAttribs.fill "currentColor"
                , SvgAttribs.d "M10 1.66663C5.40001 1.66663 1.66667 5.39996 1.66667 9.99996C1.66667 14.6 5.40001 18.3333 10 18.3333C14.6 18.3333 18.3333 14.6 18.3333 9.99996C18.3333 5.39996 14.6 1.66663 10 1.66663ZM14.1667 10.8333H10.8333V14.1666H9.16667V10.8333H5.83334V9.16663H9.16667V5.83329H10.8333V9.16663H14.1667V10.8333Z"
                ]
                []
            ]
        ]
