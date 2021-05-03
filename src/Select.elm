module Select exposing (Msg, State, initState, selectIdentifier, single, view)

import Browser.Dom as Dom
import Css
import Html.Styled as Styled exposing (Html, div, text)
import Html.Styled.Attributes as StyledAttribs


type Config item
    = Config (Configuration item)


type SelectId
    = SelectId String


type Msg item
    = InputChanged SelectId String
    | InputReceivedFocused (Maybe SelectId)
    | SelectedItem item
    | DeselectedMultiItem item
    | SearchableSelectContainerClicked SelectId
    | UnsearchableSelectContainerClicked SelectId
    | ToggleMenuAtKey SelectId
    | OnInputFocused (Result Dom.Error ())
    | OnInputBlurred (Maybe SelectId)
    | MenuItemClickFocus Int
    | MultiItemFocus Int
    | InputMousedowned
    | ClearFocusedItem
    | HoverFocused Int
    | EnterSelect item
    | KeyboardDown SelectId Int
    | KeyboardUp SelectId Int
    | OpenMenu
    | CloseMenu
    | FocusMenuViewport SelectId (Result Dom.Error ( MenuListElement, MenuItemElement ))
    | MenuListScrollTop Float
    | SetMouseMenuNavigation
    | DoNothing
    | SingleSelectClearButtonPressed


type Action item
    = InputChange String
    | Select item
    | Deselect item
    | DeselectSingleSelectItem


type State
    = State SelectState


type InitialMousedown
    = MultiItemMousedown Int
    | MenuItemMousedown Int
    | InputMousedown
    | ContainerMousedown
    | NothingMousedown


type Direction
    = Up
    | Down


type MenuItemVisibility
    = Within
    | Above
    | Below
    | Both


type MenuItemElement
    = MenuItemElement Dom.Element


type MenuListElement
    = MenuListElement Dom.Element


type alias Configuration item =
    { variant : Variant item
    , isLoading : Bool
    , state : State
    , menuItems : List (MenuItem item)
    , searchable : Bool
    , placeholder : String
    , clearable : Bool
    , disabled : Bool
    }


type alias SelectState =
    { inputValue : Maybe String
    , menuOpen : Bool
    , initialMousedown : InitialMousedown
    , controlFocused : Bool
    , activeTargetIndex : Int
    , menuViewportFocusNodes : Maybe ( MenuListElement, MenuItemElement )
    , menuListScrollTop : Float
    , menuNavigation : MenuNavigation
    , usePorts : Bool
    }


type MenuNavigation
    = Keyboard
    | Mouse


type alias MenuItem item =
    { item : item
    , label : String
    }


initState : State
initState =
    State
        { inputValue = Nothing
        , menuOpen = False
        , initialMousedown = NothingMousedown
        , controlFocused = False

        -- Always focus the first menu item by default. This facilitates auto selecting the first item on Enter
        , activeTargetIndex = 0
        , menuViewportFocusNodes = Nothing
        , menuListScrollTop = 0
        , menuNavigation = Mouse
        , usePorts = False
        }


defaults : Configuration item
defaults =
    { variant = Single Nothing
    , isLoading = False
    , state = initState
    , placeholder = "Select..."
    , menuItems = []
    , searchable = True
    , clearable = False
    , disabled = False
    }



-- VARIANT


type Variant item
    = Single (Maybe (MenuItem item))
    | Multi MultiSelectTagConfig (List (MenuItem item))


single : Maybe (MenuItem item) -> Config item
single maybeSelectedItem =
    Config { defaults | variant = Single maybeSelectedItem }


multi : MultiSelectTagConfig -> List (MenuItem item) -> Config item
multi multiSelectTagConfig selectedItems =
    Config { defaults | variant = Multi multiSelectTagConfig selectedItems }


type alias MultiSelectTagConfig =
    { truncationWidth : Maybe Float }


selectIdentifier : String -> SelectId
selectIdentifier id_ =
    SelectId id_


view : Config item -> SelectId -> Html (Msg item)
view (Config config) selectId =
    let
        (State state_) =
            config.state
    in
    div [ StyledAttribs.css [ Css.position Css.relative, Css.boxSizing Css.borderBox ] ]
        [ -- container
          div
            [ StyledAttribs.css
                [ Css.alignItems Css.center
                , Css.backgroundColor (Css.hex "#FFFFFF")
                , Css.cursor Css.default
                , Css.displayFlex
                , Css.flexWrap Css.wrap
                , Css.justifyContent Css.spaceBetween
                , Css.minHeight (Css.px 48)
                , Css.position Css.relative
                , Css.boxSizing Css.borderBox
                , Css.border3 (Css.px 2) Css.solid (Css.hex "#898BA9")
                , Css.borderRadius (Css.px 7)
                , Css.outline Css.zero
                ]
            ]
            [ -- valueContainer
              let
                withDisabledStyles =
                    if config.disabled then
                        [ Css.position Css.static ]

                    else
                        []

                resolvePlaceholder =
                    case config.variant of
                        Multi _ [] ->
                            viewPlaceholder config

                        Multi _ _ ->
                            text ""

                        Single (Just v) ->
                            viewSelectedPlaceholder v

                        Single Nothing ->
                            viewPlaceholder config

                buildPlaceholder =
                    if isEmptyInputValue state_.inputValue then
                        resolvePlaceholder

                    else
                        text ""
              in
              div
                [ StyledAttribs.css
                    ([ Css.displayFlex
                     , Css.flexWrap Css.wrap
                     , Css.position Css.relative
                     , Css.alignItems Css.center
                     , Css.boxSizing Css.borderBox
                     , Css.flex (Css.int 1)
                     , Css.padding2 (Css.px 2) (Css.px 8)
                     , Css.overflow Css.hidden
                     ]
                        ++ withDisabledStyles
                    )
                ]
                [ buildPlaceholder ]
            ]
        ]


viewPlaceholder : Configuration item -> Html (Msg item)
viewPlaceholder config =
    div
        [ -- basePlaceholder
          -- TODO: add typography styles
          StyledAttribs.css
            basePlaceholder
        ]
        [ text config.placeholder ]


viewSelectedPlaceholder : MenuItem item -> Html (Msg item)
viewSelectedPlaceholder item =
    let
        addedStyles =
            [ Css.maxWidth (Css.calc (Css.pct 100) Css.minus (Css.px 8))
            , Css.textOverflow Css.ellipsis
            , Css.whiteSpace Css.noWrap
            , Css.overflow Css.hidden
            ]
    in
    div
        [ StyledAttribs.css
            (basePlaceholder
                ++ bold
                ++ addedStyles
            )
        ]
        [ text item.label ]



-- CHECKERS


isEmptyInputValue : Maybe String -> Bool
isEmptyInputValue inputValue =
    String.isEmpty (Maybe.withDefault "" inputValue)



-- STYLES


basePlaceholder : List Css.Style
basePlaceholder =
    [ Css.marginLeft (Css.px 2)
    , Css.marginRight (Css.px 2)
    , Css.top (Css.pct 50)
    , Css.position Css.absolute
    , Css.boxSizing Css.borderBox
    , Css.transform (Css.translateY (Css.pct -50))
    , Css.opacity (Css.num 0.5)
    ]


bold : List Css.Style
bold =
    [ Css.color (Css.hex "##35374A")
    , Css.fontWeight (Css.int 400)
    ]
