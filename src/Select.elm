module Select exposing (Msg, State, initState, selectIdentifier, single, view)

import Browser.Dom as Dom
import Css
import Events
import Html.Styled exposing (Html, div, input, text)
import Html.Styled.Attributes as StyledAttribs exposing (id, readonly, style, tabindex, value)
import Html.Styled.Events exposing (onBlur, onFocus, preventDefaultOn)
import Html.Styled.Lazy exposing (lazy)
import Json.Decode as Decode
import List.Extra as ListExtra
import SelectInput


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



-- VIEW FUNCTiON DATA
-- These data structures make using 'lazy' function a breeze


type alias ViewSelectInputData item =
    { id : String
    , maybeInputValue : Maybe String
    , maybeActiveTarget : Maybe (MenuItem item)
    , totalViewableMenuItems : Int
    , menuOpen : Bool
    , usePorts : Bool
    }


type alias ViewDummyInputData item =
    { id : String
    , maybeTargetItem : Maybe (MenuItem item)
    , totalViewableMenuItems : Int
    , menuOpen : Bool
    }


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

        enterSelectTargetItem =
            if state_.menuOpen && not (List.isEmpty viewableMenuItems) then
                ListExtra.getAt state_.activeTargetIndex viewableMenuItems

            else
                Nothing

        totalMenuItems =
            List.length viewableMenuItems

        viewableMenuItems =
            buildMenuItems config state_
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

                buildInput =
                    if not config.disabled then
                        if config.searchable then
                            lazy viewSelectInput
                                (ViewSelectInputData (getSelectId selectId) state_.inputValue enterSelectTargetItem totalMenuItems state_.menuOpen state_.usePorts)

                        else
                            lazy viewDummyInput
                                (ViewDummyInputData
                                    (getSelectId selectId)
                                    enterSelectTargetItem
                                    totalMenuItems
                                    state_.menuOpen
                                )

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
                [ buildPlaceholder, buildInput ]
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


viewSelectInput : ViewSelectInputData item -> Html (Msg item)
viewSelectInput viewSelectInputData =
    let
        enterKeydownDecoder =
            -- There will always be a target item if the menu is
            -- open and not empty
            case viewSelectInputData.maybeActiveTarget of
                Just mi ->
                    [ Events.isEnter (EnterSelect mi.item) ]

                Nothing ->
                    []

        resolveInputValue =
            Maybe.withDefault "" viewSelectInputData.maybeInputValue

        spaceKeydownDecoder decoders =
            if canBeSpaceToggled viewSelectInputData.menuOpen viewSelectInputData.maybeInputValue then
                Events.isSpace (ToggleMenuAtKey <| SelectId viewSelectInputData.id) :: decoders

            else
                decoders

        whenArrowEvents =
            if viewSelectInputData.menuOpen && 0 == viewSelectInputData.totalViewableMenuItems then
                []

            else
                [ Events.isDownArrow (KeyboardDown (SelectId viewSelectInputData.id) viewSelectInputData.totalViewableMenuItems)
                , Events.isUpArrow (KeyboardUp (SelectId viewSelectInputData.id) viewSelectInputData.totalViewableMenuItems)
                ]

        resolveInputWidth selectInputConfig =
            if viewSelectInputData.usePorts then
                -- Fixed because javascript controls its width via ports
                SelectInput.inputSizing SelectInput.Fixed selectInputConfig

            else
                SelectInput.inputSizing SelectInput.Dynamic selectInputConfig
    in
    SelectInput.view
        (SelectInput.default
            |> SelectInput.onInput (InputChanged <| SelectId viewSelectInputData.id)
            |> SelectInput.onBlurMsg (OnInputBlurred (Just <| SelectId viewSelectInputData.id))
            |> SelectInput.onFocusMsg (InputReceivedFocused (Just <| SelectId viewSelectInputData.id))
            |> SelectInput.currentValue resolveInputValue
            |> SelectInput.onMousedown InputMousedowned
            |> resolveInputWidth
            |> (SelectInput.preventKeydownOn <|
                    (enterKeydownDecoder |> spaceKeydownDecoder)
                        ++ [ Events.isEscape CloseMenu
                           ]
                        ++ whenArrowEvents
               )
        )
        viewSelectInputData.id


viewDummyInput : ViewDummyInputData item -> Html (Msg item)
viewDummyInput viewDummyInputData =
    let
        whenEnterEvent =
            -- There will always be a target item if the menu is
            -- open and not empty
            case viewDummyInputData.maybeTargetItem of
                Just menuItem ->
                    [ Events.isEnter (EnterSelect menuItem.item) ]

                Nothing ->
                    []

        whenArrowEvents =
            if viewDummyInputData.menuOpen && 0 == viewDummyInputData.totalViewableMenuItems then
                []

            else
                [ Events.isDownArrow (KeyboardDown (SelectId viewDummyInputData.id) viewDummyInputData.totalViewableMenuItems)
                , Events.isUpArrow (KeyboardUp (SelectId viewDummyInputData.id) viewDummyInputData.totalViewableMenuItems)
                ]
    in
    input
        [ style "label" "dummyInput"
        , style "background" "0"
        , style "border" "0"
        , style "font-size" "inherit"
        , style "outline" "0"
        , style "padding" "0"
        , style "width" "1px"
        , style "color" "transparent"
        , readonly True
        , value ""
        , tabindex 0
        , id ("dummy-input-" ++ viewDummyInputData.id)
        , onFocus (InputReceivedFocused Nothing)
        , onBlur (OnInputBlurred Nothing)
        , preventDefaultOn "keydown" <|
            Decode.map
                (\msg -> ( msg, True ))
                (Decode.oneOf
                    ([ Events.isSpace (ToggleMenuAtKey <| SelectId viewDummyInputData.id)
                     , Events.isEscape CloseMenu
                     , Events.isDownArrow (KeyboardDown (SelectId viewDummyInputData.id) viewDummyInputData.totalViewableMenuItems)
                     , Events.isUpArrow (KeyboardUp (SelectId viewDummyInputData.id) viewDummyInputData.totalViewableMenuItems)
                     ]
                        ++ whenEnterEvent
                        ++ whenArrowEvents
                    )
                )
        ]
        []



-- GETTERS


getSelectId : SelectId -> String
getSelectId (SelectId id_) =
    id_



-- CHECKERS


isEmptyInputValue : Maybe String -> Bool
isEmptyInputValue inputValue =
    String.isEmpty (Maybe.withDefault "" inputValue)


canBeSpaceToggled : Bool -> Maybe String -> Bool
canBeSpaceToggled menuOpen inputValue =
    not menuOpen && isEmptyInputValue inputValue



-- BUILDERS


buildMenuItems : Configuration item -> SelectState -> List (MenuItem item)
buildMenuItems config state_ =
    case config.variant of
        Single _ ->
            if config.searchable then
                List.filter (filterMenuItem state_.inputValue) config.menuItems

            else
                config.menuItems

        Multi _ maybeSelectedMenuItems ->
            if config.searchable then
                List.filter (filterMenuItem state_.inputValue) config.menuItems
                    |> filterMultiSelectedItems maybeSelectedMenuItems

            else
                config.menuItems
                    |> filterMultiSelectedItems maybeSelectedMenuItems



-- FILTERS


filterMenuItem : Maybe String -> MenuItem item -> Bool
filterMenuItem maybeQuery item =
    case maybeQuery of
        Nothing ->
            True

        Just "" ->
            True

        Just query ->
            String.contains (String.toLower query) <| String.toLower item.label


filterMultiSelectedItems : List (MenuItem item) -> List (MenuItem item) -> List (MenuItem item)
filterMultiSelectedItems selectedItems currentMenuItems =
    if List.isEmpty selectedItems then
        currentMenuItems

    else
        List.filter (\i -> not (List.member i selectedItems)) currentMenuItems



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
