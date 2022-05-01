module CustomMenuItems exposing (..)

import Browser
import Css
import Html.Styled as Styled exposing (Html, div, text)
import Html.Styled.Attributes as StyledAttribs
import Select exposing (MenuItem, basicMenuItem, customMenuItem, initState, selectIdentifier, update)


type Msg
    = SelectMsg (Select.Msg Element)


type alias Model =
    { selectState : Select.State
    , items : List Element
    , selectedItem : Maybe Element
    }


type Element
    = Element ElementConfig


type Symbol
    = H
    | Be
    | N
    | Ne
    | Al
    | S
    | K
    | Ti
    | Mn


type alias ElementConfig =
    { symbol : Symbol
    , am : Float
    }


symbolToAtomicMass : Symbol -> Float
symbolToAtomicMass sym =
    case sym of
        H ->
            1.008

        Be ->
            9.01218

        N ->
            14.007

        Ne ->
            20.18

        Al ->
            26.98

        S ->
            32.06

        K ->
            39.0983

        Ti ->
            47.867

        Mn ->
            54.938


symbolToString : Symbol -> String
symbolToString el =
    case el of
        H ->
            "H"

        Be ->
            "B"

        N ->
            "N"

        Ne ->
            "Ne"

        Al ->
            "A"

        S ->
            "S"

        K ->
            "K"

        Ti ->
            "Ti"

        Mn ->
            "Mn"


symbolToLabel : Symbol -> String
symbolToLabel el =
    case el of
        H ->
            "Hydrogen"

        Be ->
            "Beryllium"

        N ->
            "Nitrogen"

        Ne ->
            "Neon"

        Al ->
            "Aluminium"

        S ->
            "Sulfur"

        K ->
            "Potassium"

        Ti ->
            "Titanium"

        Mn ->
            "Manganese"


init : ( Model, Cmd Msg )
init =
    ( { selectState = initState
      , items =
            [ Element { symbol = H, am = symbolToAtomicMass H }
            , Element { symbol = Be, am = symbolToAtomicMass Be }
            , Element { symbol = N, am = symbolToAtomicMass N }
            , Element { symbol = Ne, am = symbolToAtomicMass Ne }
            , Element { symbol = Al, am = symbolToAtomicMass Al }
            , Element { symbol = S, am = symbolToAtomicMass S }
            , Element { symbol = K, am = symbolToAtomicMass K }
            , Element { symbol = Ti, am = symbolToAtomicMass Ti }
            , Element { symbol = Mn, am = symbolToAtomicMass Mn }
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

                        _ ->
                            model.selectedItem
            in
            ( { model | selectState = selectState, selectedItem = updatedSelectedItem }, Cmd.map SelectMsg cmds )


view : Model -> Html Msg
view m =
    let
        selectedItem =
            case m.selectedItem of
                Just ((Element elemConfig) as i) ->
                    Just (Select.basicMenuItem { item = i, label = symbolToLabel elemConfig.symbol })

                _ ->
                    Nothing

        menuItems =
            List.map
                (\((Element elConfig) as item) ->
                    customMenuItem
                        { item = item
                        , label = symbolToLabel elConfig.symbol
                        , view = elementToCustomView elConfig
                        }
                )
                m.items
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
                    |> Select.menuItems menuItems
                    |> Select.placeholder "Placeholder"
                )
                (selectIdentifier "SingleSelectExample")
        ]


elementToCustomView : ElementConfig -> Html Never
elementToCustomView elConfig =
    div
        [ StyledAttribs.css
            [ Css.displayFlex
            , Css.property "gap" "8px"
            ]
        ]
        [ viewSymbol elConfig, viewDivider, viewRichDescription elConfig ]


viewSymbol : ElementConfig -> Html Never
viewSymbol elConfig =
    div
        [ StyledAttribs.css
            [ Css.fontWeight Css.bold
            , Css.fontSize (Css.rem 1.6)
            , Css.marginTop Css.auto
            ]
        ]
        [ text (symbolToString elConfig.symbol) ]


viewDivider : Html Never
viewDivider =
    div
        [ StyledAttribs.css
            [ Css.width (Css.px 0)
            , Css.height Css.auto
            , Css.border2 (Css.px 1) Css.solid
            ]
        ]
        []


viewRichDescription : ElementConfig -> Html Never
viewRichDescription elConfig =
    div [ StyledAttribs.css [ Css.alignSelf Css.center, Css.flexDirection Css.column ] ]
        [ div [] [ text (symbolToLabel elConfig.symbol) ]
        , div [ StyledAttribs.css [ Css.color (Css.hex "#C93B55"), Css.fontSize (Css.rem 0.75) ] ]
            [ text (String.fromFloat elConfig.am) ]
        ]
