module Select exposing
    ( State, MenuItem, Action(..), initState, Msg, menuItems, placeholder, selectIdentifier, state, update, view
    , single, clearable
    , multi, truncateMultiTag, multiTagColor, initMultiConfig
    , disabled, labelledBy, loading
    , jsOptimize
    )

{-| Select items from a menu list.


# Set up

@docs State, MenuItem, Action, initState, Msg, menuItems, placeholder, selectIdentifier, state, update, view


# Single select

@docs single, clearable


# Multi select

@docs multi, truncateMultiTag, multiTagColor, initMultiConfig


# Common

@docs disabled, labelledBy, loading


# Advanced

@docs jsOptimize

-}

import Browser.Dom as Dom
import ClearIcon
import Css
import DotLoadingIcon
import Events
import Html.Styled exposing (Html, button, div, input, li, span, text)
import Html.Styled.Attributes as StyledAttribs exposing (attribute, id, readonly, style, tabindex, value)
import Html.Styled.Attributes.Aria exposing (ariaSelected, role)
import Html.Styled.Events exposing (custom, on, onBlur, onFocus, preventDefaultOn)
import Html.Styled.Extra exposing (viewIf)
import Html.Styled.Keyed as Keyed
import Html.Styled.Lazy exposing (lazy)
import Json.Decode as Decode
import List.Extra as ListExtra
import Select.Internal as Internal
import SelectInput
import Svg.Styled exposing (path, svg)
import Svg.Styled.Attributes exposing (d, height, viewBox)
import Tag
import Task


type Config item
    = Config (Configuration item)


type MultiSelectConfig
    = MultiSelectConfig MultiSelectConfiguration


type SelectId
    = SelectId String


{-| -}
type Msg item
    = InputChanged SelectId String
    | InputReceivedFocused (Maybe SelectId)
    | SelectedItem item
    | SelectedItemMulti item SelectId
    | DeselectedMultiItem item SelectId
    | SearchableSelectContainerClicked SelectId
    | UnsearchableSelectContainerClicked SelectId
    | ToggleMenuAtKey SelectId
    | OnInputFocused (Result Dom.Error ())
    | OnInputBlurred (Maybe SelectId)
    | MenuItemClickFocus Int
    | MultiItemFocus Int
    | InputMousedowned
    | InputEscape
    | ClearFocusedItem
    | HoverFocused Int
    | EnterSelect item
    | EnterSelectMulti item SelectId
    | KeyboardDown SelectId Int
    | KeyboardUp SelectId Int
    | OpenMenu
    | CloseMenu
    | FocusMenuViewport SelectId (Result Dom.Error ( MenuListElement, MenuItemElement ))
    | MenuListScrollTop Float
    | SetMouseMenuNavigation
    | DoNothing
    | SingleSelectClearButtonMouseDowned
    | SingleSelectClearButtonKeyDowned SelectId


{-| Specific events happen in the Select that you can react to from your update.

Maybe you want to find out what country someone is from?

When they select a country from the menu, it will be reflected in the Select action.

    import Select exposing ( Action(..) )

    type Msg
        = SelectMsg (Select.Msg Country)
        -- your other Msg's

    type Country
        = Australia
        | Japan
        | Taiwan
        -- other countries

    update : Msg -> Model -> (Model, Cmd Msg)
    update msg model =
        case msg of
            SelectMsg selectMsg ->
                let
                    (maybeAction, selectState, selectCmds) =
                        Select.update selectMsg model.selectState

                    selectedCountry : Maybe Country
                    selectedCountry =
                        case maybeAction of
                            Just (Select.Select someCountry) ->
                                Just someCountry

                            Nothing ->
                                Nothing

                in
                -- (model, cmd)

-}
type Action item
    = InputChange String
    | Select item
    | DeselectMulti item
    | ClearSingleSelectItem


{-| -}
type State
    = State SelectState



-- Determines what was mousedowned first within the container


type InitialMousedown
    = MultiItemMousedown Int
    | MenuItemMousedown Int
    | InputMousedown
    | ContainerMousedown
    | NothingMousedown


type MenuItemVisibility
    = Within
    | Above
    | Below
    | Both


type MenuItemElement
    = MenuItemElement Dom.Element


type MenuListElement
    = MenuListElement Dom.Element



-- VIEW FUNCTION DATA
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
    , variant : Variant item
    }


type alias ViewMenuData item =
    { variant : Variant item
    , selectId : SelectId
    , viewableMenuItems : List (MenuItem item)
    , initialMousedown : InitialMousedown
    , activeTargetIndex : Int
    , menuNavigation : MenuNavigation
    , loading : Bool
    }


type alias ViewSelectInputData item =
    { id : SelectId
    , maybeInputValue : Maybe String
    , maybeActiveTarget : Maybe (MenuItem item)
    , activeTargetIndex : Int
    , totalViewableMenuItems : Int
    , menuOpen : Bool
    , variant : Variant item
    , labelledBy : Maybe String
    , jsOptmized : Bool
    , controlUiFocused : Bool
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
    , disabled : Bool
    , clearable : Bool
    , labelledBy : Maybe String
    }


type alias MultiSelectConfiguration =
    { tagTruncation : Maybe Float
    , multiTagColor : Maybe Css.Color
    }


type alias SelectState =
    { inputValue : Maybe String
    , menuOpen : Bool
    , initialMousedown : InitialMousedown
    , controlUiFocused : Bool
    , activeTargetIndex : Int
    , menuViewportFocusNodes : Maybe ( MenuListElement, MenuItemElement )
    , menuListScrollTop : Float
    , menuNavigation : MenuNavigation
    , jsOptimize : Bool
    }


type MenuNavigation
    = Keyboard
    | Mouse


{-| The menu item that will be represented in the menu list.

The `item` property is the type representation of the menu item that will be used in an Action.

The `label` is the text representation that will be shown in the menu.

    type Tool
        = Screwdriver
        | Hammer
        | Drill

    toolItems : MenuItem Tool
    toolItems =
        [ { item = Screwdriver, label = "Screwdriver" }
        , { item = Hammer, label = "Hammer" }
        , { item = Drill, label = "Drill" }
        ]

    yourView model =
        Html.map SelectMsg <|
            view
                (single Nothing
                    |> menuItems toolItems
                    |> state model.selectState
                )
                (selectIdentifier "SingleSelectExample")

-}
type alias MenuItem item =
    { item : item
    , label : String
    }



-- DEFAULTS


{-| Set up an initial state in your init function.

    type Country
        = Australia
        | Japan
        | Taiwan

    type alias Model =
        { selectState : Select.State
        , items : List (Select.MenuItem Country)
        , selectedCountry : Maybe Country
        }

    init : Model
    init =
        { selectState = Select.initState
        , items =
            [ { item = Australia, label = "Australia" }
            , { item = Japan, label = "Japan" }
            , { item = Taiwan, label = "Taiwan" }
            ]
        , selectedCountry = Nothing
        }

-}
initState : State
initState =
    State
        { inputValue = Nothing
        , menuOpen = False
        , initialMousedown = NothingMousedown
        , controlUiFocused = False

        -- Always focus the first menu item by default. This facilitates auto selecting the first item on Enter
        , activeTargetIndex = 0
        , menuViewportFocusNodes = Nothing
        , menuListScrollTop = 0
        , menuNavigation = Mouse
        , jsOptimize = False
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
    , labelledBy = Nothing
    }


multiDefaults : MultiSelectConfiguration
multiDefaults =
    { tagTruncation = Nothing, multiTagColor = Nothing }



-- MULTI MODIFIERS


{-| Starting value for the ['multi'](*multi) variant.

        yourView model =
            Html.map SelectMsg <|
                view
                    (multi initMultiConfig [])
                    (selectIdentifier "1234")

-}
initMultiConfig : MultiSelectConfig
initMultiConfig =
    MultiSelectConfig multiDefaults


{-| Limit the width of a multi select tag.

Handy for when the selected item text is excessively long.
Text that breaches the set width will display as an ellipses.

Width will be in px values.

        yourView model =
            Html.map SelectMsg <|
                view
                    (multi
                        ( initMultiConfig
                            |> truncateMultitag 30
                        )
                        model.selectedCountries
                    )
                    (selectIdentifier "1234")

-}
truncateMultiTag : Float -> MultiSelectConfig -> MultiSelectConfig
truncateMultiTag w (MultiSelectConfig config) =
    MultiSelectConfig { config | tagTruncation = Just w }


{-| Set the color for the multi select tag.

        yourView =
            Html.map SelectMsg <|
                view
                    (multi
                        ( initMultiConfig
                            |> multiTagColor (Css.hex "#E1E2EA"
                        )
                        model.selectedCountries
                    )
                    (selectIdentifier "1234")

-}
multiTagColor : Css.Color -> MultiSelectConfig -> MultiSelectConfig
multiTagColor c (MultiSelectConfig config) =
    MultiSelectConfig { config | multiTagColor = Just c }



-- MODIFIERS


{-| The text that will appear as an input placeholder.

        yourView model =
            Html.map SelectMsg <|
                view
                    (single Nothing |> placeholder "some placeholder")
                    (selectIdentifier "1234")

-}
placeholder : String -> Config item -> Config item
placeholder plc (Config config) =
    Config { config | placeholder = plc }


{-|

        model : Model
        model =
            { selectState = initState }

        yourView : Model
        yourView model =
            Html.map SelectMsg <|
                view
                    (single Nothing |> state model.selectState)
                    (selectIdentifier "1234")

-}
state : State -> Config item -> Config item
state state_ (Config config) =
    Config { config | state = state_ }


{-| The items that will appear in the menu list.

NOTE: When using the (multi) select, selected items will be reflected as a tags and
visually removed from the menu list.

      items =
          [ { item = SomeValue, label = "Some label" } ]

      yourView =
          view
              (Single Nothing |> menuItems items)
              (selectIdentifier "1234")

-}
menuItems : List (MenuItem item) -> Config item -> Config item
menuItems items (Config config) =
    Config { config | menuItems = items }


{-| Allows a [single](#single) variant selected menu item to be cleared.

To handle a cleared item refer to the [ClearedSingleSelect](#Action ) action.

        yourView model =
            Html.map SelectMsg <|
                view
                    ( single Nothing
                        |> clearable True
                        |> menuItems -- [ menu items ]
                    )
                    (selectIdentifier "SingleSelectExample")

-}
clearable : Bool -> Config item -> Config item
clearable clear (Config config) =
    Config { config | clearable = clear }


{-| Disables the select input so that it cannot be interacted with.

        yourView model =
            Html.map SelectMsg <|
                view
                    (single Nothing |> disabled True)
                    (selectIdentifier "SingleSelectExample")

-}
disabled : Bool -> Config item -> Config item
disabled predicate (Config config) =
    Config { config | disabled = predicate }


{-| Displays an animated loading icon to visually represent that menu items are being loaded.

This would be useful if you are loading menu options asynchronously, like from a server.

        yourView model =
            Html.map SelectMsg <|
                view
                    (single Nothing |> loading True)
                    (selectIdentifier "SingleSelectExample")

-}
loading : Bool -> Config item -> Config item
loading predicate (Config config) =
    Config { config | isLoading = predicate }


{-| The element ID of the label that describes the select.

It is best practice to render the select with a label.

    yourView model =
        label
            [ id "selectLabelId" ]
            [ text "Select your country"
            , Html.map SelectMsg <|
                view
                    (single Nothing |> labelledBy "selectLabelId")
                    (selectIdentifier "SingleSelectExample")
            ]

-}
labelledBy : String -> Config item -> Config item
labelledBy s (Config config) =
    Config { config | labelledBy = Just s }



-- STATE MODIFIERS


{-| Opt in to a Javascript optimization.

Read the [Advanced](https://package.elm-lang.org/packages/Confidenceman02/elm-select/latest/#opt-in-javascript-optimisation)
section of the README for a good explanation on why you might like to opt in.

        model : Model model =
            { selectState = initState |> jsOptimize True }

Install the Javascript package:

**npm**

> `npm install @confidenceman02/elm-select`

**Import script**

    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <title>Viewer</title>

        <script src="/node_modules/@confidenceman02/elm-select/dist/dynamic.min.js"></script>
      </head>
      <body>
        <main></main>
        <script src="index.js"></script>
      </body>
    </html>

Alternatively you can import the script wherever you are initialising your program.

    import { Elm } from "./src/Main";
    import "@confidenceman02/elm-select"

    Elm.Main.init({node, flags})

-}
jsOptimize : Bool -> State -> State
jsOptimize pred (State state_) =
    State { state_ | jsOptimize = pred }



-- VARIANT


type Variant item
    = Single (Maybe (MenuItem item))
    | Multi MultiSelectConfig (List (MenuItem item))
    | Native NativeVariant


type NativeVariant
    = SingleNative
    | MultiNative


{-| Select a single item.

      countries : List (MenuItem Country)
      countries =
          [ { item = Australia, label = "Australia" }
          , { item = Taiwan, label = "Taiwan"
          -- other countries
          ]

      yourView =
          Html.map SelectMsg <|
              view
                  (Single Nothing |> menuItems countries)
                  (selectIdentifier "1234")

-}
single : Maybe (MenuItem item) -> Config item
single maybeSelectedItem =
    Config { defaults | variant = Single maybeSelectedItem }


{-| Select multiple items.

Selected items will render as tags and be visually removed from the menu list.

    yourView model =
        Html.map SelectMsg <|
            view
                (multi
                    (initMultiConfig
                        |> menuItems model.countries
                    )
                    model.selectedCountries
                )
                (selectIdentifier "1234")

-}
multi : MultiSelectConfig -> List (MenuItem item) -> Config item
multi multiSelectTagConfig selectedItems =
    Config { defaults | variant = Multi multiSelectTagConfig selectedItems }


{-| The ID for the rendered Select input

NOTE: It is important that the ID's of all selects that exist on
a page remain unique.

    yourView model =
        Html.map SelectMsg <|
            view
                (single Nothing)
                (selectIdentifier "someUniqueId")

-}
selectIdentifier : String -> SelectId
selectIdentifier id_ =
    SelectId id_



-- UPDATE


{-| Add a branch in your update to handle the view Msg's.

        yourUpdate msg model =
            case msg of
                SelectMsg selectMsg ->
                    update selectMsg model.selectState

-}
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

        EnterSelectMulti item (SelectId id) ->
            let
                inputId =
                    SelectInput.inputId id

                ( _, State stateWithClosedMenu, cmdWithClosedMenu ) =
                    update CloseMenu (State state_)
            in
            ( Just (Select item)
            , State
                { stateWithClosedMenu
                    | initialMousedown = NothingMousedown
                    , inputValue = Nothing
                }
            , Cmd.batch [ cmdWithClosedMenu, Task.attempt OnInputFocused (Dom.focus inputId) ]
            )

        HoverFocused i ->
            ( Nothing, State { state_ | activeTargetIndex = i }, Cmd.none )

        InputChanged _ inputValue ->
            let
                ( _, State stateWithOpenMenu, cmdWithOpenMenu ) =
                    update OpenMenu (State state_)
            in
            ( Just (InputChange inputValue), State { stateWithOpenMenu | inputValue = Just inputValue }, cmdWithOpenMenu )

        InputReceivedFocused maybeSelectId ->
            case maybeSelectId of
                Just _ ->
                    ( Nothing, State { state_ | controlUiFocused = True }, Cmd.none )

                Nothing ->
                    ( Nothing, State { state_ | controlUiFocused = True }, Cmd.none )

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

        SelectedItemMulti item (SelectId id) ->
            let
                inputId =
                    SelectInput.inputId id

                ( _, State stateWithClosedMenu, cmdWithClosedMenu ) =
                    update CloseMenu (State state_)
            in
            ( Just (Select item)
            , State
                { stateWithClosedMenu
                    | initialMousedown = NothingMousedown
                    , inputValue = Nothing
                }
            , Cmd.batch [ cmdWithClosedMenu, Task.attempt OnInputFocused (Dom.focus inputId) ]
            )

        DeselectedMultiItem deselectedItem (SelectId id) ->
            let
                inputId =
                    SelectInput.inputId id
            in
            ( Just (DeselectMulti deselectedItem), State { state_ | initialMousedown = NothingMousedown }, Task.attempt OnInputFocused (Dom.focus inputId) )

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

        OnInputBlurred _ ->
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
                                , controlUiFocused = False
                                , inputValue = Nothing
                              }
                            , Cmd.batch [ cmdWithClosedMenu, Cmd.none ]
                            )
            in
            ( Nothing
            , State updatedState
            , updatedCmds
            )

        MenuItemClickFocus i ->
            ( Nothing, State { state_ | initialMousedown = MenuItemMousedown i }, Cmd.none )

        MultiItemFocus index ->
            ( Nothing, State { state_ | initialMousedown = MultiItemMousedown index }, Cmd.none )

        InputMousedowned ->
            ( Nothing, State { state_ | initialMousedown = InputMousedown }, Cmd.none )

        InputEscape ->
            let
                ( _, State stateWithClosedMenu, cmdWithClosedMenu ) =
                    update CloseMenu (State state_)
            in
            ( Nothing, State { stateWithClosedMenu | inputValue = Nothing }, cmdWithClosedMenu )

        ClearFocusedItem ->
            ( Nothing, State { state_ | initialMousedown = NothingMousedown }, Cmd.none )

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
            ( Nothing, State { updatedState | controlUiFocused = True }, Cmd.batch [ updatedCmds, Task.attempt OnInputFocused (Dom.focus inputId) ] )

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
            ( Nothing, State { updatedState | controlUiFocused = True }, Cmd.batch [ updatedCmd, Task.attempt OnInputFocused (Dom.focus (dummyInputId <| SelectId id)) ] )

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
            ( Nothing, State { updatedState | controlUiFocused = True }, updatedCmd )

        KeyboardDown selectId totalTargetCount ->
            let
                ( _, State stateWithOpenMenu, cmdWithOpenMenu ) =
                    update OpenMenu (State state_)

                nextActiveTargetIndex =
                    Internal.calculateNextActiveTarget state_.activeTargetIndex totalTargetCount Internal.Down

                nodeQueryForViewportFocus =
                    if Internal.shouldQueryNextTargetElement nextActiveTargetIndex state_.activeTargetIndex then
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
                    Internal.calculateNextActiveTarget state_.activeTargetIndex totalTargetCount Internal.Up

                nodeQueryForViewportFocus =
                    if Internal.shouldQueryNextTargetElement nextActiveTargetIndex state_.activeTargetIndex then
                        queryNodesForViewportFocus selectId nextActiveTargetIndex

                    else
                        Cmd.none

                ( updatedState, updatedCmd ) =
                    if state_.menuOpen then
                        ( { state_ | activeTargetIndex = nextActiveTargetIndex, menuNavigation = Keyboard }, nodeQueryForViewportFocus )

                    else
                        ( { stateWithOpenMenu
                            | menuNavigation = Keyboard
                            , activeTargetIndex = nextActiveTargetIndex
                          }
                        , Cmd.batch [ cmdWithOpenMenu, nodeQueryForViewportFocus ]
                        )
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

        SingleSelectClearButtonMouseDowned ->
            ( Just ClearSingleSelectItem, State state_, Cmd.none )

        SingleSelectClearButtonKeyDowned (SelectId id) ->
            let
                inputId =
                    SelectInput.inputId id
            in
            ( Just ClearSingleSelectItem, State state_, Task.attempt OnInputFocused (Dom.focus inputId) )


{-| Render the select

        yourView model =
            Html.map SelectMsg <|
                view
                    (single Nothing)
                    (selectIdentifier "SingleSelectExample")

-}
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
    div
        (StyledAttribs.css [ Css.position Css.relative, Css.boxSizing Css.borderBox ]
            :: (if config.disabled then
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
        [ -- container
          let
            controlFocusedStyles =
                if state_.controlUiFocused then
                    [ Css.borderColor (Css.hex "#0168b3") ]

                else
                    []
          in
          div
            -- control
            (StyledAttribs.css
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
                 , if config.disabled then
                    Css.opacity (Css.num 0.3)

                   else
                    Css.hover [ Css.backgroundColor (Css.hex "#F0F1F4"), Css.borderColor (Css.hex "#4B4D68") ]
                 ]
                    ++ controlFocusedStyles
                )
                :: (if config.disabled then
                        []

                    else
                        [ attribute "data-test-id" "selectContainer"
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

                buildMulti =
                    case config.variant of
                        Multi (MultiSelectConfig tagConfig) multiSelectedValues ->
                            let
                                resolveMultiValueStyles =
                                    if 0 < List.length multiSelectedValues then
                                        [ StyledAttribs.css [ Css.marginRight (Css.rem 0.4375) ] ]

                                    else
                                        []
                            in
                            div resolveMultiValueStyles <|
                                (List.indexedMap
                                    (viewMultiValue selectId tagConfig state_.initialMousedown)
                                    multiSelectedValues
                                    ++ [ buildInput ]
                                )

                        Single _ ->
                            buildInput

                        _ ->
                            text ""

                resolvePlaceholder =
                    case config.variant of
                        Multi _ [] ->
                            viewPlaceholder config

                        -- Multi selected values render differently
                        Multi _ _ ->
                            text ""

                        Single (Just v) ->
                            viewSelectedPlaceholder v

                        Single Nothing ->
                            viewPlaceholder config

                        _ ->
                            text ""

                buildPlaceholder =
                    if isEmptyInputValue state_.inputValue then
                        resolvePlaceholder

                    else
                        text ""

                buildInput =
                    if not config.disabled then
                        if config.searchable then
                            lazy viewSelectInput
                                (ViewSelectInputData
                                    selectId
                                    state_.inputValue
                                    enterSelectTargetItem
                                    state_.activeTargetIndex
                                    totalMenuItems
                                    state_.menuOpen
                                    config.variant
                                    config.labelledBy
                                    state_.jsOptimize
                                    state_.controlUiFocused
                                )

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
                [ buildMulti
                , buildPlaceholder
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
                            Single (Just _) ->
                                True

                            _ ->
                                False

                    else
                        False
              in
              -- indicators
              div
                [ StyledAttribs.css
                    [ Css.alignItems Css.center, Css.alignSelf Css.stretch, Css.displayFlex, Css.flexShrink Css.zero, Css.boxSizing Css.borderBox ]
                ]
                [ viewIf clearButtonVisible <| div [ StyledAttribs.css indicatorContainerStyles ] [ clearIndicator config selectId ]
                , div [ StyledAttribs.css indicatorContainerStyles ] [ resolveLoadingSpinner ]

                -- indicatorSeprator
                , span
                    [ StyledAttribs.css
                        [ Css.alignSelf Css.stretch
                        , Css.backgroundColor (Css.rgb 204 204 204)
                        , Css.marginBottom (Css.px 8)
                        , Css.marginTop (Css.px 8)
                        , Css.width (Css.px 1)
                        , Css.boxSizing Css.borderBox
                        ]
                    ]
                    []
                , -- indicatorContainer
                  div
                    [ StyledAttribs.css indicatorContainerStyles ]
                    [ dropdownIndicator config
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
                        config.isLoading
                    )
                )
            ]
        ]


viewMenu : ViewMenuData item -> Html (Msg item)
viewMenu viewMenuData =
    let
        resolveAttributes =
            if viewMenuData.menuNavigation == Keyboard then
                [ attribute "data-test-id" "listBox", on "mousemove" <| Decode.succeed SetMouseMenuNavigation ]

            else
                [ attribute "data-test-id" "listBox" ]

        menuStyles =
            [ Css.top (Css.pct 100)
            , Css.backgroundColor (Css.hex "#FFFFFF")
            , Css.marginBottom (Css.px 8)
            , Css.position Css.absolute
            , Css.width (Css.pct 100)
            , Css.boxSizing Css.borderBox
            , Css.border3 (Css.px listBoxBorder) Css.solid Css.transparent
            , Css.borderRadius (Css.px 4)

            -- , Css.border3 (Css.px 6) Css.solid Css.transparent
            , Css.borderRadius (Css.px 7)
            , Css.boxShadow4 (Css.px 0) (Css.px 0) (Css.px 12) (Css.rgba 0 0 0 0.19)
            , Css.marginTop (Css.px menuMarginTop)
            , Css.zIndex (Css.int 1)
            ]

        menuListStyles =
            [ Css.maxHeight (Css.px 215)
            , Css.overflowY Css.auto
            , Css.paddingBottom (Css.px listBoxPaddingBottom)
            , Css.paddingTop (Css.px listBoxPaddingTop)
            , Css.paddingLeft (Css.px 0)
            , Css.marginTop (Css.px 0)
            , Css.marginBottom (Css.px 0)
            , Css.boxSizing Css.borderBox
            , Css.position Css.relative
            ]
                ++ menuStyles
    in
    case viewMenuData.viewableMenuItems of
        [] ->
            if viewMenuData.loading then
                div [ StyledAttribs.css menuStyles ]
                    [ div
                        [ StyledAttribs.css (menuListStyles ++ [ Css.textAlign Css.center, Css.opacity (Css.num 0.5) ]) ]
                        [ text "Loading..." ]
                    ]

            else
                text ""

        _ ->
            -- listbox
            Keyed.node "ul"
                ([ StyledAttribs.css menuListStyles
                 , id (menuListId viewMenuData.selectId)
                 , on "scroll" <| Decode.map MenuListScrollTop <| Decode.at [ "target", "scrollTop" ] Decode.float
                 , role "listbox"
                 , custom "mousedown"
                    (Decode.map
                        (\msg -> { message = msg, stopPropagation = True, preventDefault = True })
                     <|
                        Decode.succeed DoNothing
                    )
                 ]
                    ++ resolveAttributes
                )
                (List.indexedMap
                    (buildMenuItem viewMenuData.selectId viewMenuData.variant viewMenuData.initialMousedown viewMenuData.activeTargetIndex viewMenuData.menuNavigation)
                    viewMenuData.viewableMenuItems
                )


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

                resolveMouseUpMsg =
                    case viewMenuItemData.variant of
                        Multi _ _ ->
                            SelectedItemMulti data.menuItem.item viewMenuItemData.selectId

                        _ ->
                            SelectedItem data.menuItem.item

                resolveMouseUp =
                    case data.initialMousedown of
                        MenuItemMousedown _ ->
                            [ on "mouseup" <| Decode.succeed resolveMouseUpMsg ]

                        _ ->
                            []

                resolveDataTestId =
                    if data.menuItemIsTarget then
                        [ attribute "data-test-id" ("listBoxItemTargetFocus" ++ String.fromInt data.index) ]

                    else
                        []

                withTargetStyles =
                    if data.menuItemIsTarget && not data.itemSelected then
                        [ Css.color (Css.hex "#0168B3"), Css.backgroundColor (Css.hex "#E6F0F7") ]

                    else
                        []

                withIsClickedStyles =
                    if data.isClickFocused then
                        [ Css.backgroundColor (Css.hex "#E6F0F7") ]

                    else
                        []

                withIsSelectedStyles =
                    if data.itemSelected then
                        [ Css.backgroundColor (Css.hex "#E6F0F7"), Css.hover [ Css.color (Css.hex "#0168B3") ] ]

                    else
                        []

                resolveSelectedAriaAttribs =
                    if data.itemSelected then
                        [ ariaSelected "true" ]

                    else
                        [ ariaSelected "false" ]

                resolvePosinsetAriaAttrib =
                    [ attribute "aria-posinset" (String.fromInt <| data.index + 1) ]
            in
            -- option
            li
                ([ role "option"
                 , tabindex -1
                 , preventDefaultOn "mousedown" <| Decode.map (\msg -> ( msg, True )) <| Decode.succeed (MenuItemClickFocus data.index)
                 , on "mouseover" <| Decode.succeed (HoverFocused data.index)
                 , id (menuItemId data.selectId data.index)
                 , StyledAttribs.css
                    ([ Css.backgroundColor Css.transparent
                     , Css.color Css.inherit
                     , Css.cursor Css.default
                     , Css.display Css.block
                     , Css.fontSize Css.inherit
                     , Css.width (Css.pct 100)
                     , Css.property "user-select" "none"
                     , Css.boxSizing Css.borderBox
                     , Css.borderRadius (Css.px 4)

                     -- kaizen uses a calc here
                     , Css.padding2 (Css.px 8) (Css.px 8)
                     , Css.outline Css.none
                     , Css.color (Css.hex "#000000")
                     ]
                        ++ withTargetStyles
                        ++ withIsClickedStyles
                        ++ withIsSelectedStyles
                    )
                 ]
                    ++ resolveMouseLeave
                    ++ resolveMouseUp
                    ++ resolveDataTestId
                    ++ resolveSelectedAriaAttribs
                    ++ resolvePosinsetAriaAttrib
                )
                [ text data.menuItem.label ]
        )
        viewMenuItemData
    )


viewPlaceholder : Configuration item -> Html (Msg item)
viewPlaceholder config =
    div
        [ -- baseplaceholder
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
        , attribute "data-test-id" "selectedItem"
        ]
        [ text item.label ]


viewSelectInput : ViewSelectInputData item -> Html (Msg item)
viewSelectInput viewSelectInputData =
    let
        selectId =
            getSelectId viewSelectInputData.id

        resolveEnterMsg mi =
            case viewSelectInputData.variant of
                Multi _ _ ->
                    EnterSelectMulti mi.item (SelectId selectId)

                _ ->
                    EnterSelect mi.item

        enterKeydownDecoder =
            -- there will always be a target item if the menu is
            -- open and not empty
            case viewSelectInputData.maybeActiveTarget of
                Just mi ->
                    [ Events.isEnter (resolveEnterMsg mi) ]

                Nothing ->
                    []

        resolveInputValue =
            Maybe.withDefault "" viewSelectInputData.maybeInputValue

        spaceKeydownDecoder decoders =
            if canBeSpaceToggled viewSelectInputData.menuOpen viewSelectInputData.maybeInputValue then
                Events.isSpace (ToggleMenuAtKey <| SelectId selectId) :: decoders

            else
                decoders

        whenArrowEvents =
            if viewSelectInputData.menuOpen && 0 == viewSelectInputData.totalViewableMenuItems then
                []

            else
                [ Events.isDownArrow (KeyboardDown (SelectId selectId) viewSelectInputData.totalViewableMenuItems)
                , Events.isUpArrow (KeyboardUp (SelectId selectId) viewSelectInputData.totalViewableMenuItems)
                ]

        resolveInputWidth selectInputConfig =
            if viewSelectInputData.jsOptmized then
                SelectInput.inputSizing (SelectInput.DynamicJsOptimized viewSelectInputData.controlUiFocused) selectInputConfig

            else
                SelectInput.inputSizing SelectInput.Dynamic selectInputConfig

        resolveAriaActiveDescendant config =
            case viewSelectInputData.maybeActiveTarget of
                Just _ ->
                    SelectInput.activeDescendant (menuItemId viewSelectInputData.id viewSelectInputData.activeTargetIndex) config

                _ ->
                    config

        resolveAriaControls config =
            SelectInput.setAriaControls (menuListId viewSelectInputData.id) config

        resolveAriaLabelledBy config =
            case viewSelectInputData.labelledBy of
                Just s ->
                    SelectInput.setAriaLabelledBy s config

                _ ->
                    config

        resolveAriaExpanded config =
            SelectInput.setAriaExpanded viewSelectInputData.menuOpen config
    in
    SelectInput.view
        (SelectInput.default
            |> SelectInput.onInput (InputChanged <| SelectId selectId)
            |> SelectInput.onBlurMsg (OnInputBlurred (Just <| SelectId selectId))
            |> SelectInput.onFocusMsg (InputReceivedFocused (Just <| SelectId selectId))
            |> SelectInput.currentValue resolveInputValue
            |> SelectInput.onMousedown InputMousedowned
            |> resolveInputWidth
            |> resolveAriaActiveDescendant
            |> resolveAriaControls
            |> resolveAriaLabelledBy
            |> resolveAriaExpanded
            |> (SelectInput.preventKeydownOn <|
                    (enterKeydownDecoder |> spaceKeydownDecoder)
                        ++ (Events.isEscape InputEscape
                                :: whenArrowEvents
                           )
               )
        )
        selectId


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


viewMultiValue : SelectId -> MultiSelectConfiguration -> InitialMousedown -> Int -> MenuItem item -> Html (Msg item)
viewMultiValue selectId config mousedownedItem index menuItem =
    let
        isMousedowned =
            case mousedownedItem of
                MultiItemMousedown i ->
                    i == index

                _ ->
                    False

        resolveMouseleave tagConfig =
            if isMousedowned then
                Tag.onMouseleave ClearFocusedItem tagConfig

            else
                tagConfig

        resolveTruncationWidth tagConfig =
            case config.tagTruncation of
                Just width ->
                    Tag.truncateWidth width tagConfig

                Nothing ->
                    tagConfig

        resolveVariant =
            Tag.default

        withTagColor tagConfig =
            case config.multiTagColor of
                Just c ->
                    Tag.backgroundColor c tagConfig

                _ ->
                    tagConfig
    in
    Tag.view
        (resolveVariant
            |> Tag.onDismiss (DeselectedMultiItem menuItem.item selectId)
            |> Tag.onMousedown (MultiItemFocus index)
            |> Tag.rightMargin True
            |> Tag.dataTestId ("multiSelectTag" ++ String.fromInt index)
            |> withTagColor
            |> resolveTruncationWidth
            |> resolveMouseleave
        )
        menuItem.label


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


canBeSpaceToggled : Bool -> Maybe String -> Bool
canBeSpaceToggled menuOpen inputValue =
    not menuOpen && isEmptyInputValue inputValue



-- CALC


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

        _ ->
            []


buildMenuItem : SelectId -> Variant item -> InitialMousedown -> Int -> MenuNavigation -> Int -> MenuItem item -> ( String, Html (Msg item) )
buildMenuItem selectId variant initialMousedown activeTargetIndex menuNavigation idx item =
    case variant of
        Single maybeSelectedItem ->
            viewMenuItem <|
                ViewMenuItemData idx (isSelected item maybeSelectedItem) (isMenuItemClickFocused initialMousedown idx) (isTarget activeTargetIndex idx) selectId item menuNavigation initialMousedown variant

        _ ->
            viewMenuItem <|
                ViewMenuItemData idx False (isMenuItemClickFocused initialMousedown idx) (isTarget activeTargetIndex idx) selectId item menuNavigation initialMousedown variant


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
                    menuListElem.element.y - menuItemElem.element.y + listBoxPaddingTop + listBoxBorder
            in
            ( Task.attempt (\_ -> DoNothing) <|
                Dom.setViewportOf (menuListId selectId) 0 (menuListViewport - menuItemDistanceAbove)
            , menuListViewport - menuItemDistanceAbove
            )

        Below ->
            let
                menuItemDistanceBelow =
                    (menuItemElem.element.y + menuItemElem.element.height + listBoxPaddingBottom + listBoxBorder) - (menuListElem.element.y + menuListElem.element.height)
            in
            ( Task.attempt (\_ -> DoNothing) <|
                Dom.setViewportOf (menuListId selectId) 0 (menuListViewport + menuItemDistanceBelow)
            , menuListViewport + menuItemDistanceBelow
            )

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
    ]


placeholderStyles : List Css.Style
placeholderStyles =
    Css.opacity (Css.num 0.5) :: basePlaceholder



-- ICONS


viewLoading : Html msg
viewLoading =
    DotLoadingIcon.view


clearIndicator : Configuration item -> SelectId -> Html (Msg item)
clearIndicator config id =
    let
        resolveIconButtonStyles =
            if config.disabled then
                [ Css.height (Css.px 20) ]

            else
                [ Css.height (Css.px 20), Css.cursor Css.pointer ]
    in
    button
        [ custom "mousedown" <|
            Decode.map (\msg -> { message = msg, stopPropagation = True, preventDefault = True }) <|
                Decode.succeed SingleSelectClearButtonMouseDowned
        , StyledAttribs.css (resolveIconButtonStyles ++ iconButtonStyles)
        , on "keydown"
            (Decode.oneOf
                [ Events.isSpace (SingleSelectClearButtonKeyDowned id)
                , Events.isEnter (SingleSelectClearButtonKeyDowned id)
                ]
            )
        ]
        [ ClearIcon.view
        ]


dropdownIndicator : Configuration item -> Html msg
dropdownIndicator config =
    let
        resolveIconButtonStyles =
            if config.disabled then
                [ Css.height (Css.px 20) ]

            else
                [ Css.height (Css.px 20), Css.cursor Css.pointer ]
    in
    span
        [ StyledAttribs.css resolveIconButtonStyles ]
        [ svg svgCommonStyles [ path [ d "M6.18 6.845L10 10.747l3.82-3.902L15 8.049l-5 5.106-5-5.106z" ] [] ]
        ]



-- STYLES


indicatorContainerStyles : List Css.Style
indicatorContainerStyles =
    [ Css.displayFlex, Css.boxSizing Css.borderBox, Css.padding (Css.px 8) ]


svgCommonStyles : List (Svg.Styled.Attribute msg)
svgCommonStyles =
    [ height "20", viewBox "0 0 20 20" ]


iconButtonStyles : List Css.Style
iconButtonStyles =
    [ Css.displayFlex
    , Css.backgroundColor Css.transparent
    , Css.padding (Css.px 0)
    , Css.borderColor (Css.rgba 0 0 0 0)
    , Css.border (Css.px 0)
    , Css.color Css.inherit
    ]


menuMarginTop : Float
menuMarginTop =
    8


bold : List Css.Style
bold =
    [ Css.color (Css.hex "#35374A")
    , Css.fontWeight (Css.int 400)
    ]


listBoxPaddingBottom : Float
listBoxPaddingBottom =
    6


listBoxPaddingTop : Float
listBoxPaddingTop =
    4


listBoxBorder : Float
listBoxBorder =
    6
