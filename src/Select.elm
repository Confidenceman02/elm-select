module Select exposing (Action(..), MenuItem, Msg, State, initState, menuItems, placeholder, selectIdentifier, single, state, update, view)

import Browser.Dom as Dom
import Css
import Events
import Html.Styled exposing (Html, div, input, span, text)
import Html.Styled.Attributes as StyledAttribs exposing (id, readonly, style, tabindex, value)
import Html.Styled.Attributes.Aria exposing (role)
import Html.Styled.Events exposing (on, onBlur, onFocus, preventDefaultOn)
import Html.Styled.Extra exposing (viewIf)
import Html.Styled.Keyed as Keyed
import Html.Styled.Lazy exposing (lazy)
import Json.Decode as Decode
import List.Extra as ListExtra
import SelectInput
import Task


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


type alias ViewMenuItemData item =
    { index : Int
    , itemSelected : Bool
    , isClickFocused : Bool
    , menuItemIsTarget : Bool
    , selectId : SelectId
    , menuItem : MenuItem item
    , menuNavigation : MenuNavigation
    , initialMousedown : InitialMousedown
    }


type alias ViewMenuData item =
    { variant : Variant item
    , selectId : SelectId
    , viewableMenuItems : List (MenuItem item)
    , initialMousedown : InitialMousedown
    , activeTargetIndex : Int
    , menuNavigation : MenuNavigation
    }


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


type alias MenuListBoundaries =
    ( Float, Float )


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



-- DEFAULTS


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



-- MODIFIERS


placeholder : String -> Config item -> Config item
placeholder plc (Config config) =
    Config { config | placeholder = plc }


state : State -> Config item -> Config item
state state_ (Config config) =
    Config { config | state = state_ }


menuItems : List (MenuItem item) -> Config item -> Config item
menuItems items (Config config) =
    Config { config | menuItems = items }



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



-- UPDATE


update : Msg item -> State -> ( Maybe (Action item), State, Cmd (Msg item) )
update msg (State state_) =
    case msg of
        EnterSelect item ->
            let
                ( _, State stateWithClosedMenu, cmdWithClosedMenu ) =
                    update CloseMenu (State state_)
            in
            ( Just (Select item)
            , State
                { stateWithClosedMenu
                    | initialMousedown = NothingMousedown
                    , inputValue = Nothing
                }
            , cmdWithClosedMenu
            )

        HoverFocused i ->
            ( Nothing, State { state_ | activeTargetIndex = i }, Cmd.none ) |> Debug.log "HOVER FOCUSED"

        InputChanged _ inputValue ->
            let
                ( _, State stateWithOpenMenu, cmdWithOpenMenu ) =
                    update OpenMenu (State state_)
            in
            ( Just (InputChange inputValue), State { stateWithOpenMenu | inputValue = Just inputValue }, cmdWithOpenMenu )

        InputReceivedFocused maybeSelectId ->
            case maybeSelectId of
                Just selectId ->
                    ( Nothing, State { state_ | controlFocused = True }, Cmd.none )

                Nothing ->
                    ( Nothing, State { state_ | controlFocused = True }, Cmd.none )

        SelectedItem item ->
            let
                ( _, State stateWithClosedMenu, cmdWithClosedMenu ) =
                    update CloseMenu (State state_)
            in
            ( Just (Select item)
            , State
                { stateWithClosedMenu
                    | initialMousedown = NothingMousedown
                    , inputValue = Nothing
                }
            , cmdWithClosedMenu
            )
                |> Debug.log
                    "SelectedItem"

        DeselectedMultiItem deselectedItem ->
            ( Just (Deselect deselectedItem), State { state_ | initialMousedown = NothingMousedown }, Cmd.none )

        -- focusing the input is usually the last thing that happens after all the mousedown events.
        -- Its important to ensure we have a NothingInitClicked so that if the user clicks outside of the
        -- container it will close the menu and un focus the container. OnInputBlurred treats ContainerInitClick and
        -- MutiItemInitClick as special cases to avoid flickering when an input gets blurred then focused again.
        OnInputFocused focusResult ->
            case focusResult of
                Ok () ->
                    ( Nothing, State { state_ | initialMousedown = NothingMousedown }, Cmd.none )

                Err _ ->
                    ( Nothing, State state_, Cmd.none )

        FocusMenuViewport selectId (Ok ( menuListElem, menuItemElem )) ->
            let
                ( viewportFocusCmd, newViewportY ) =
                    menuItemOrientationInViewport menuListElem menuItemElem
                        |> setMenuViewportPosition selectId state_.menuListScrollTop menuListElem menuItemElem
            in
            ( Nothing, State { state_ | menuViewportFocusNodes = Just ( menuListElem, menuItemElem ), menuListScrollTop = newViewportY }, viewportFocusCmd )

        -- If the menu list element was not found it likely has no viewable menu items.
        -- In this case the menu does not render therefore no id is present on menu element.
        FocusMenuViewport _ (Err _) ->
            ( Nothing, State { state_ | menuViewportFocusNodes = Nothing }, Cmd.none )

        DoNothing ->
            ( Nothing, State state_, Cmd.none )

        OnInputBlurred maybeSelectId ->
            let
                ( _, State stateWithClosedMenu, cmdWithClosedMenu ) =
                    update CloseMenu (State state_)

                ( updatedState, updatedCmds ) =
                    case state_.initialMousedown of
                        ContainerMousedown ->
                            ( { state_ | inputValue = Nothing }, Cmd.none )

                        MultiItemMousedown _ ->
                            ( state_, Cmd.none )

                        _ ->
                            ( { stateWithClosedMenu
                                | initialMousedown = NothingMousedown
                                , controlFocused = False
                                , inputValue = Nothing
                              }
                            , Cmd.batch [ cmdWithClosedMenu, Cmd.none ]
                            )

                -- ports =
                --     case maybeSelectId of
                --         Just id_ ->
                --             if state_.usePorts then
                --                 Ports.kaizenDisconnectSelectInputDynamicWidth <| buildEncodedValueForPorts id_
                --             else
                --                 Cmd.none
                --         Nothing ->
                --             Cmd.none
            in
            ( Nothing
            , State updatedState
            , updatedCmds
            )
                |> Debug.log "ONINPUTBLURRED"

        MenuItemClickFocus i ->
            ( Nothing, State { state_ | initialMousedown = MenuItemMousedown i }, Cmd.none ) |> Debug.log "MENUITEMCLICKFOCUS"

        MultiItemFocus index ->
            ( Nothing, State { state_ | initialMousedown = MultiItemMousedown index }, Cmd.none )

        InputMousedowned ->
            ( Nothing, State { state_ | initialMousedown = InputMousedown }, Cmd.none )

        ClearFocusedItem ->
            ( Nothing, State { state_ | initialMousedown = NothingMousedown }, Cmd.none ) |> Debug.log "CLEARFOCUSEDITEM"

        SearchableSelectContainerClicked (SelectId id) ->
            let
                inputId =
                    SelectInput.inputId id

                ( _, State stateWithOpenMenu, cmdWithOpenMenu ) =
                    update OpenMenu (State state_)

                ( _, State stateWithClosedMenu, cmdWithClosedMenu ) =
                    update CloseMenu (State state_)

                ( updatedState, updatedCmds ) =
                    case state_.initialMousedown of
                        -- A mousedown on a multi tag dismissible icon has been registered. This will
                        -- bubble and fire the the mousedown on the container div which toggles the menu.
                        -- To avoid the annoyance of opening and closing the menu whenever a multi tag item is dismissed
                        -- we just want to leave the menu open which it will be when it reaches here.
                        MultiItemMousedown _ ->
                            ( state_, Cmd.none )

                        -- This is set by a mousedown event in the input. Because the container mousedown will also fire
                        -- as a result of bubbling we want to ensure that the preventDefault on the container is set to
                        -- false and allow the input to do all the native click things i.e. double click to select text.
                        -- If the initClicked values are InputInitClick || NothingInitClick we will not preventDefault.
                        InputMousedown ->
                            ( { stateWithOpenMenu | initialMousedown = NothingMousedown }, cmdWithOpenMenu )

                        -- When no container children i.e. tag, input, have initiated a click, then this means a click on the container itself
                        -- has been initiated.
                        NothingMousedown ->
                            if state_.menuOpen then
                                ( { stateWithClosedMenu | initialMousedown = ContainerMousedown }, cmdWithClosedMenu )

                            else
                                ( { stateWithOpenMenu | initialMousedown = ContainerMousedown }, cmdWithOpenMenu )

                        ContainerMousedown ->
                            if state_.menuOpen then
                                ( { stateWithClosedMenu | initialMousedown = NothingMousedown }, cmdWithClosedMenu )

                            else
                                ( { stateWithOpenMenu | initialMousedown = NothingMousedown }, cmdWithOpenMenu )

                        _ ->
                            if state_.menuOpen then
                                ( stateWithClosedMenu, cmdWithClosedMenu )

                            else
                                ( stateWithOpenMenu, cmdWithOpenMenu )
            in
            ( Nothing, State { updatedState | controlFocused = True }, Cmd.batch [ updatedCmds, Task.attempt OnInputFocused (Dom.focus inputId) ] )

        UnsearchableSelectContainerClicked (SelectId id) ->
            let
                ( _, State stateWithOpenMenu, cmdWithOpenMenu ) =
                    update OpenMenu (State state_)

                ( _, State stateWithClosedMenu, cmdWithClosedMenu ) =
                    update CloseMenu (State state_)

                ( updatedState, updatedCmd ) =
                    if state_.menuOpen then
                        ( stateWithClosedMenu, cmdWithClosedMenu )

                    else
                        ( stateWithOpenMenu, cmdWithOpenMenu )
            in
            ( Nothing, State { updatedState | controlFocused = True }, Cmd.batch [ updatedCmd, Task.attempt OnInputFocused (Dom.focus (dummyInputId <| SelectId id)) ] )

        ToggleMenuAtKey _ ->
            let
                ( _, State stateWithOpenMenu, cmdWithOpenMenu ) =
                    update OpenMenu (State state_)

                ( _, State stateWithClosedMenu, cmdWithClosedMenu ) =
                    update CloseMenu (State state_)

                ( updatedState, updatedCmd ) =
                    if state_.menuOpen then
                        ( stateWithClosedMenu, cmdWithClosedMenu )

                    else
                        ( stateWithOpenMenu, cmdWithOpenMenu )
            in
            ( Nothing, State { updatedState | controlFocused = True }, updatedCmd )

        KeyboardDown selectId totalTargetCount ->
            let
                ( _, State stateWithOpenMenu, cmdWithOpenMenu ) =
                    update OpenMenu (State state_)

                nextActiveTargetIndex =
                    calculateNextActiveTarget state_.activeTargetIndex totalTargetCount Down

                nodeQueryForViewportFocus =
                    if shouldQueryNextTargetElement nextActiveTargetIndex state_ then
                        queryNodesForViewportFocus selectId nextActiveTargetIndex

                    else
                        Cmd.none

                ( updatedState, updatedCmd ) =
                    if state_.menuOpen then
                        ( { state_ | activeTargetIndex = nextActiveTargetIndex, menuNavigation = Keyboard }, nodeQueryForViewportFocus )

                    else
                        ( { stateWithOpenMenu | menuNavigation = Keyboard }, cmdWithOpenMenu )
            in
            ( Nothing, State updatedState, updatedCmd )

        KeyboardUp selectId totalTargetCount ->
            let
                ( _, State stateWithOpenMenu, cmdWithOpenMenu ) =
                    update OpenMenu (State state_)

                nextActiveTargetIndex =
                    calculateNextActiveTarget state_.activeTargetIndex totalTargetCount Up

                nodeQueryForViewportFocus =
                    if shouldQueryNextTargetElement nextActiveTargetIndex state_ then
                        queryNodesForViewportFocus selectId nextActiveTargetIndex

                    else
                        Cmd.none

                ( updatedState, updatedCmd ) =
                    if state_.menuOpen then
                        ( { state_ | activeTargetIndex = nextActiveTargetIndex, menuNavigation = Keyboard }, nodeQueryForViewportFocus )

                    else
                        ( { stateWithOpenMenu | menuNavigation = Keyboard }, cmdWithOpenMenu )
            in
            ( Nothing, State updatedState, updatedCmd )

        OpenMenu ->
            ( Nothing, State { state_ | menuOpen = True, activeTargetIndex = 0 }, Cmd.none )

        CloseMenu ->
            ( Nothing
            , State
                { state_
                    | menuOpen = False
                    , activeTargetIndex = 0
                    , menuViewportFocusNodes = Nothing
                    , menuListScrollTop = 0
                    , menuNavigation = Mouse
                }
            , Cmd.none
            )

        MenuListScrollTop position ->
            ( Nothing, State { state_ | menuListScrollTop = position }, Cmd.none )

        SetMouseMenuNavigation ->
            ( Nothing, State { state_ | menuNavigation = Mouse }, Cmd.none )

        SingleSelectClearButtonPressed ->
            ( Just DeselectSingleSelectItem, State state_, Cmd.none )


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

        preventDefault =
            if config.searchable then
                case state_.initialMousedown of
                    NothingMousedown ->
                        False

                    InputMousedown ->
                        False

                    _ ->
                        True

            else
                True

        resolveContainerMsg =
            if config.searchable then
                SearchableSelectContainerClicked selectId

            else
                UnsearchableSelectContainerClicked selectId
    in
    div [ StyledAttribs.css [ Css.position Css.relative, Css.boxSizing Css.borderBox ] ]
        [ -- container
          let
            controlFocusedStyles =
                if state_.controlFocused then
                    [ Css.borderColor (Css.hex "#0168b3") ]

                else
                    []
          in
          div
            ([ -- control
               StyledAttribs.css
                ([ Css.alignItems Css.center
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

                 -- TODO add hover styles
                 , Css.hover [ Css.backgroundColor (Css.hex "#F0F1F4"), Css.borderColor (Css.hex "#4B4D68") ]
                 ]
                    ++ controlFocusedStyles
                )
             ]
                ++ (if config.disabled then
                        []

                    else
                        [ preventDefaultOn "mousedown" <|
                            Decode.map
                                (\msg ->
                                    ( msg
                                    , preventDefault
                                    )
                                )
                            <|
                                Decode.succeed resolveContainerMsg
                        ]
                   )
            )
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
                [ buildPlaceholder
                , buildInput
                ]
            , let
                resolveLoadingSpinner =
                    if config.isLoading && config.searchable then
                        viewLoading

                    else
                        text ""

                clearButtonVisible =
                    if config.clearable && not config.disabled then
                        case config.variant of
                            Multi _ _ ->
                                -- clearable is only applicable to Single Select
                                False

                            Single maybeSelectedItem ->
                                case maybeSelectedItem of
                                    Just _ ->
                                        True

                                    Nothing ->
                                        False

                    else
                        False

                resolveIconButtonStyles =
                    if config.disabled then
                        [ Css.height (Css.px 20) ]

                    else
                        [ Css.height (Css.px 20), Css.cursor Css.pointer ]
              in
              div [ StyledAttribs.css [ Css.alignItems Css.center, Css.alignSelf Css.stretch, Css.displayFlex, Css.flexShrink Css.zero, Css.boxSizing Css.borderBox ] ]
                [ div [ StyledAttribs.css [ Css.displayFlex, Css.boxSizing Css.borderBox, Css.padding (Css.px 8) ] ]
                    [ resolveLoadingSpinner
                    , if clearButtonVisible then
                        viewClearButton

                      else
                        text ""
                    , span
                        [ StyledAttribs.css resolveIconButtonStyles ]
                        [-- TODO Create chevron
                         -- Icon.view Icon.presentation
                         --   (svgAsset "@kaizen/component-library/icons/chevron-down.icon.svg")
                         --   |> Html.map never
                        ]
                    ]
                ]
            ]
        , viewIf state_.menuOpen
            (lazy viewMenu
                (ViewMenuData
                    config.variant
                    selectId
                    viewableMenuItems
                    state_.initialMousedown
                    state_.activeTargetIndex
                    state_.menuNavigation
                )
            )
        ]


viewMenu : ViewMenuData item -> Html (Msg item)
viewMenu viewMenuData =
    let
        resolveMouseover =
            if viewMenuData.menuNavigation == Keyboard then
                [ on "mousemove" <| Decode.succeed SetMouseMenuNavigation ]

            else
                []
    in
    viewIf (hasMenuItems viewMenuData.viewableMenuItems)
        (div
            -- menu
            ([ StyledAttribs.css
                [ Css.top (Css.pct 100)
                , Css.backgroundColor (Css.hex "#FFFFFF")
                , Css.marginBottom (Css.px 8)
                , Css.position Css.absolute
                , Css.width (Css.pct 100)
                , Css.boxSizing Css.borderBox
                , Css.border3 (Css.px 6) Css.solid Css.transparent
                , Css.borderRadius (Css.px 4)

                -- , Css.border3 (Css.px 6) Css.solid Css.transparent
                , Css.borderRadius (Css.px 7)
                , Css.boxShadow4 (Css.px 0) (Css.px 0) (Css.px 12) (Css.rgba 0 0 0 0.19)
                , Css.marginTop (Css.px menuMarginTop)
                , Css.zIndex (Css.int 1)
                ]
             ]
                ++ resolveMouseover
            )
            [ -- menuList
              Keyed.node "div"
                [ StyledAttribs.css
                    [ Css.maxHeight (Css.px 215)
                    , Css.overflowY Css.auto
                    , Css.paddingBottom (Css.px 6)
                    , Css.paddingTop (Css.px 4)
                    , Css.boxSizing Css.borderBox
                    , Css.position Css.relative
                    ]

                -- styles.class .menuList
                -- , id (menuListId viewMenuData.selectId)
                -- , on "scroll" <| Decode.map MenuListScrollTop <| Decode.at [ "target", "scrollTop" ] Decode.float
                ]
                (List.indexedMap
                    (buildMenuItem viewMenuData.selectId viewMenuData.variant viewMenuData.initialMousedown viewMenuData.activeTargetIndex viewMenuData.menuNavigation)
                    viewMenuData.viewableMenuItems
                )
            ]
        )


viewclearbutton : Html (Msg item)
viewclearbutton =
    -- TODO create clear button
    text ""



-- span [ styles.class .clearbuttonwrapper ]
--     [ button.view
--         (button.iconbutton
--             (svgasset "@kaizen/component-library/icons/clear.icon.svg")
--             |> button.onclick singleselectclearbuttonpressed
--         )
--         "clear"
--     ]


viewLoading : Html msg
viewLoading =
    -- todo create loading spinner
    text ""



-- span [ styles.class .iconbutton ]
--     [ icon.view icon.presentation
--         (svgasset "@kaizen/component-library/icons/spinner.icon.svg")
--         |> Html.map never
--     ]


viewMenuItem : ViewMenuItemData item -> ( String, Html (Msg item) )
viewMenuItem viewMenuItemData =
    ( String.fromInt viewMenuItemData.index
    , lazy
        (\data ->
            let
                resolveMouseLeave =
                    if data.isClickFocused then
                        [ on "mouseleave" <| Decode.succeed ClearFocusedItem ]

                    else
                        []

                resolveMouseUp =
                    case data.initialMousedown of
                        MenuItemMousedown _ ->
                            [ on "mouseup" <| Decode.succeed (SelectedItem data.menuItem.item) ]

                        _ ->
                            []
            in
            div
                ([ role "listitem"
                 , tabindex -1
                 , preventDefaultOn "mousedown" <| Decode.map (\msg -> ( msg, True )) <| Decode.succeed (MenuItemClickFocus data.index)
                 , on "mouseover" <| Decode.succeed (HoverFocused data.index)
                 , id (menuItemId data.selectId data.index)
                 , -- .option
                   StyledAttribs.css
                    [ Css.backgroundColor Css.transparent
                    , Css.color Css.inherit
                    , Css.cursor Css.default
                    , Css.display Css.block
                    , Css.fontSize Css.inherit
                    , Css.width (Css.pct 100)
                    , Css.property "user-select" "none"
                    , Css.boxSizing Css.borderBox

                    -- kaizen uses a calc here
                    , Css.padding2 (Css.px 8) (Css.px 8)
                    , Css.outline Css.none

                    -- TODO Handle when it's a target but not selected
                    -- TODO Handle when it's clicked focused but not selected
                    -- TODO Handle when it's selected
                    -- TODO Prevent pointer when keyboard navigating
                    , Css.color (Css.hex "#000000")
                    ]

                 -- styles.classList
                 -- [ ( .option, True )
                 -- , ( .isSelected, data.itemSelected )
                 -- , ( .isFocused, data.isClickFocused )
                 -- , ( .isTarget, data.menuItemIsTarget )
                 -- , ( .preventPointer, data.menuNavigation == Keyboard )
                 -- ]
                 ]
                    ++ resolveMouseLeave
                    ++ resolveMouseUp
                )
                [ text data.menuItem.label ]
        )
        viewMenuItemData
    )


viewClearButton : Html msg
viewClearButton =
    text ""



-- span [ styles.class .clearButtonWrapper ]
--     [ Button.view
--         (Button.iconButton
--             (svgAsset "@kaizen/component-library/icons/clear.icon.svg")
--             |> Button.onClick SingleSelectClearButtonPressed
--         )
--         "clear"
--     ]


viewPlaceholder : Configuration item -> Html (Msg item)
viewPlaceholder config =
    div
        [ -- baseplaceholder
          -- todo: add typography styles
          StyledAttribs.css
            placeholderStyles
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
            -- there will always be a target item if the menu is
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
                -- fixed because javascript controls its width via ports
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
                        ++ (Events.isEscape CloseMenu
                                :: whenArrowEvents
                           )
               )
        )
        viewSelectInputData.id


viewDummyInput : ViewDummyInputData item -> Html (Msg item)
viewDummyInput viewDummyInputData =
    let
        whenEnterEvent =
            -- there will always be a target item if the menu is
            -- open and not empty
            case viewDummyInputData.maybeTargetItem of
                Just menuitem ->
                    [ Events.isEnter (EnterSelect menuitem.item) ]

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
        [ style "label" "dummyinput"
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



-- getters


dummyInputId : SelectId -> String
dummyInputId selectId =
    dummyInputIdPrefix ++ getSelectId selectId


dummyInputIdPrefix : String
dummyInputIdPrefix =
    "dummy-input-"


menuItemId : SelectId -> Int -> String
menuItemId selectId index =
    "select-menu-item-" ++ String.fromInt index ++ "-" ++ getSelectId selectId


menuListId : SelectId -> String
menuListId selectId =
    "select-menu-list-" ++ getSelectId selectId


getSelectId : SelectId -> String
getSelectId (SelectId id_) =
    id_



-- CHECKERS


hasMenuItems : List (MenuItem item) -> Bool
hasMenuItems items =
    0 /= List.length items


isSelected : MenuItem item -> Maybe (MenuItem item) -> Bool
isSelected menuItem maybeSelectedItem =
    case maybeSelectedItem of
        Just item ->
            item == menuItem

        Nothing ->
            False


isMenuItemClickFocused : InitialMousedown -> Int -> Bool
isMenuItemClickFocused initialMousedown i =
    case initialMousedown of
        MenuItemMousedown int ->
            int == i

        _ ->
            -- if menuitem is not focused we dont care about what is at this stage
            False


isTarget : Int -> Int -> Bool
isTarget activeTargetIndex i =
    activeTargetIndex == i


isMenuItemWithinTopBoundary : MenuItemElement -> Float -> Bool
isMenuItemWithinTopBoundary (MenuItemElement menuItemElement) topBoundary =
    topBoundary <= menuItemElement.element.y


isMenuItemWithinBottomBoundary : MenuItemElement -> Float -> Bool
isMenuItemWithinBottomBoundary (MenuItemElement menuItemElement) bottomBoundary =
    (menuItemElement.element.y + menuItemElement.element.height) <= bottomBoundary


isEmptyInputValue : Maybe String -> Bool
isEmptyInputValue inputValue =
    String.isEmpty (Maybe.withDefault "" inputValue)


shouldQueryNextTargetElement : Int -> SelectState -> Bool
shouldQueryNextTargetElement nextTargetIndex state_ =
    nextTargetIndex /= state_.activeTargetIndex


canBeSpaceToggled : Bool -> Maybe String -> Bool
canBeSpaceToggled menuOpen inputValue =
    not menuOpen && isEmptyInputValue inputValue


calculateNextActiveTarget : Int -> Int -> Direction -> Int
calculateNextActiveTarget currentTargetIndex totalTargetCount direction =
    case direction of
        Up ->
            if currentTargetIndex == 0 then
                0

            else if totalTargetCount < currentTargetIndex + 1 then
                0

            else
                currentTargetIndex - 1

        Down ->
            if currentTargetIndex + 1 == totalTargetCount then
                currentTargetIndex

            else if totalTargetCount < currentTargetIndex + 1 then
                0

            else
                currentTargetIndex + 1


calculateMenuBoundaries : MenuListElement -> MenuListBoundaries
calculateMenuBoundaries (MenuListElement menuListElem) =
    ( menuListElem.element.y, menuListElem.element.y + menuListElem.element.height )



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


buildMenuItem : SelectId -> Variant item -> InitialMousedown -> Int -> MenuNavigation -> Int -> MenuItem item -> ( String, Html (Msg item) )
buildMenuItem selectId variant initialMousedown activeTargetIndex menuNavigation idx item =
    case variant of
        Single maybeSelectedItem ->
            viewMenuItem <|
                ViewMenuItemData idx (isSelected item maybeSelectedItem) (isMenuItemClickFocused initialMousedown idx) (isTarget activeTargetIndex idx) selectId item menuNavigation initialMousedown

        Multi _ _ ->
            viewMenuItem <|
                ViewMenuItemData idx False (isMenuItemClickFocused initialMousedown idx) (isTarget activeTargetIndex idx) selectId item menuNavigation initialMousedown



-- buildEncodedValueForPorts : SelectId -> Encode.Value
-- buildEncodedValueForPorts (SelectId id_) =
--     let
--         ( sizerId, inputId ) =
--             ( SelectInput.sizerId id_, SelectInput.inputId id_ )
--     in
--     Encode.object
--         [ ( "sizerId", Encode.string sizerId )
--         , ( "inputId", Encode.string inputId )
--         , ( "defaultInputWidth", Encode.int SelectInput.defaultWidth )
--         ]
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


menuItemOrientationInViewport : MenuListElement -> MenuItemElement -> MenuItemVisibility
menuItemOrientationInViewport menuListElem menuItemElem =
    let
        ( topBoundary, bottomBoundary ) =
            calculateMenuBoundaries menuListElem
    in
    case ( isMenuItemWithinTopBoundary menuItemElem topBoundary, isMenuItemWithinBottomBoundary menuItemElem bottomBoundary ) of
        ( True, True ) ->
            Within

        ( False, True ) ->
            Above

        ( True, False ) ->
            Below

        ( False, False ) ->
            Both


queryMenuListElement : SelectId -> Task.Task Dom.Error Dom.Element
queryMenuListElement selectId =
    Dom.getElement (menuListId selectId)


queryNodesForViewportFocus : SelectId -> Int -> Cmd (Msg item)
queryNodesForViewportFocus selectId menuItemIndex =
    Task.attempt (FocusMenuViewport selectId) <|
        Task.map2 (\menuListElem menuItemElem -> ( MenuListElement menuListElem, MenuItemElement menuItemElem ))
            (queryMenuListElement selectId)
            (queryActiveTargetElement selectId menuItemIndex)


queryActiveTargetElement : SelectId -> Int -> Task.Task Dom.Error Dom.Element
queryActiveTargetElement selectId index =
    Dom.getElement (menuItemId selectId index)


setMenuViewportPosition : SelectId -> Float -> MenuListElement -> MenuItemElement -> MenuItemVisibility -> ( Cmd (Msg item), Float )
setMenuViewportPosition selectId menuListViewport (MenuListElement menuListElem) (MenuItemElement menuItemElem) menuItemVisibility =
    case menuItemVisibility of
        Within ->
            ( Cmd.none, menuListViewport )

        Above ->
            let
                menuItemDistanceAbove =
                    menuListElem.element.y - menuItemElem.element.y
            in
            ( Task.attempt (\_ -> DoNothing) <| Dom.setViewportOf (menuListId selectId) 0 (menuListViewport - menuItemDistanceAbove), menuListViewport - menuItemDistanceAbove )

        Below ->
            let
                menuItemDistanceBelow =
                    (menuItemElem.element.y + menuItemElem.element.height) - (menuListElem.element.y + menuListElem.element.height)
            in
            ( Task.attempt (\_ -> DoNothing) <| Dom.setViewportOf (menuListId selectId) 0 (menuListViewport + menuItemDistanceBelow), menuListViewport + menuItemDistanceBelow )

        Both ->
            let
                menuItemDistanceAbove =
                    menuListElem.element.y - menuItemElem.element.y
            in
            ( Task.attempt (\_ -> DoNothing) <| Dom.setViewportOf (menuListId selectId) 0 (menuListViewport - menuItemDistanceAbove), menuListViewport - menuItemDistanceAbove )


basePlaceholder : List Css.Style
basePlaceholder =
    [ Css.marginLeft (Css.px 2)
    , Css.marginRight (Css.px 2)
    , Css.top (Css.pct 50)
    , Css.position Css.absolute
    , Css.boxSizing Css.borderBox
    , Css.transform (Css.translateY (Css.pct -50))

    -- TODO handle when disabled
    -- , Css.opacity (Css.num 0.5)
    ]


placeholderStyles : List Css.Style
placeholderStyles =
    Css.opacity (Css.num 0.5) :: basePlaceholder



-- STYLES


menuMarginTop : Float
menuMarginTop =
    8


bold : List Css.Style
bold =
    [ Css.color (Css.hex "#35374A")
    , Css.fontWeight (Css.int 400)
    ]
