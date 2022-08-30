module Select exposing
    ( SelectId, Config, State, MenuItem, BasicMenuItem, basicMenuItem, CustomMenuItem, customMenuItem, filterableMenuItem, Action(..), initState, focus, isFocused, isMenuOpen, Msg, menuItems, clearable
    , placeholder, selectIdentifier, state, update, view, searchable, setStyles
    , single
    , singleMenu, menu
    , multi
    , singleNative
    , disabled, labelledBy, ariaDescribedBy, loading, loadingMessage
    , jsOptimize
    )

{-| Select items from a menu list.


# Set up

@docs SelectId, Config, State, MenuItem, BasicMenuItem, basicMenuItem, CustomMenuItem, customMenuItem, filterableMenuItem, Action, initState, focus, isFocused, isMenuOpen, Msg, menuItems, clearable
@docs placeholder, selectIdentifier, state, update, view, searchable, setStyles


# Single select

@docs single


# Menu select

@docs singleMenu, menu


# Multi select

@docs multi


# Native Single select

@docs singleNative


# Common

@docs disabled, labelledBy, ariaDescribedBy, loading, loadingMessage


# Advanced

@docs jsOptimize

-}

import Browser.Dom as Dom
import Css
import Html.Styled as Styled exposing (Html, button, div, input, li, option, select, span, text)
import Html.Styled.Attributes as StyledAttribs exposing (attribute, id, readonly, style, tabindex, type_, value)
import Html.Styled.Attributes.Aria as Aria exposing (ariaSelected, role)
import Html.Styled.Events exposing (custom, on, onBlur, onFocus, preventDefaultOn)
import Html.Styled.Keyed as Keyed
import Html.Styled.Lazy exposing (lazy, lazy2)
import Json.Decode as Decode
import List.Extra as ListExtra
import Select.ClearIcon as ClearIcon
import Select.DotLoadingIcon as DotLoadingIcon
import Select.DropdownIcon as DropdownIcon
import Select.Events as Events
import Select.Internal as Internal
import Select.SearchIcon as SearchIcon
import Select.SelectInput as SelectInput
import Select.Styles as Styles
import Select.Tag as Tag
import Task


{-| -}
type Config item
    = Config (Configuration item)


{-| -}
type SelectId
    = SelectId String


type HeadlessMsg
    = FocusInputH


type HeadlessState
    = FocusingInputH
    | FocusingClearableH


{-| -}
type Msg item
    = InputChanged String
    | InputChangedNativeSingle (List (MenuItem item)) Bool Int
    | InputReceivedFocused (Variant item)
    | SelectedItem item
    | SelectedItemMulti item
    | DeselectedMultiItem item
    | SearchableSelectContainerClicked (CustomVariant item)
    | UnsearchableSelectContainerClicked
    | ToggleMenuAtKey
    | OnInputFocused (Result Dom.Error ())
    | OnInputBlurred (Variant item)
    | OnMenuClearableFocus (Result Dom.Error ())
    | OnMenuInputTabbed Bool
    | OnMenuClearableShiftTabbed Bool
    | OnMenuClearableBlurred
    | MenuItemClickFocus Int
    | MultiItemFocus Int
    | InputMousedowned
    | InputEscape
    | ClearFocusedItem
    | HoverFocused Int
    | EnterSelect (MenuItem item)
    | EnterSelectMulti (MenuItem item)
    | KeyboardDown Int
    | KeyboardUp Int
    | OpenMenu
    | CloseMenu
    | FocusMenuViewport (Result Dom.Error ( MenuListElement, MenuItemElement ))
    | MenuListScrollTop Float
    | SetMouseMenuNavigation
    | DoNothing
    | ClearButtonMouseDowned (CustomVariant item)
    | ClearButtonKeyDowned (CustomVariant item)
    | HeadlessMsg HeadlessMsg


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
    | FocusSet
    | MenuInputCleared


{-| -}
type State
    = State SelectState


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


type alias MenuListBoundaries =
    ( Float, Float )


type alias Configuration item =
    { variant : Variant item
    , isLoading : Bool
    , loadingMessage : String
    , state : State
    , menuItems : List (MenuItem item)
    , searchable : Bool
    , placeholder : String
    , disabled : Bool
    , clearable : Bool
    , labelledBy : Maybe String
    , ariaDescribedBy : Maybe String
    , styles : Styles.Config
    }


type alias SelectState =
    { inputValue : Maybe String
    , menuOpen : Bool
    , initialMousedown : Internal.InitialMousedown
    , controlUiFocused : Maybe Internal.UiFocused
    , activeTargetIndex : Int
    , menuViewportFocusNodes : Maybe ( MenuListElement, MenuItemElement )
    , menuListScrollTop : Float
    , menuNavigation : MenuNavigation
    , jsOptimize : Bool
    , selectId : SelectId
    , headlessEvent : Maybe HeadlessState
    }


type MenuNavigation
    = Keyboard
    | Mouse


{-| -}
type MenuItem item
    = Basic (Internal.BaseMenuItem (BasicMenuItem item))
    | Custom (Internal.BaseMenuItem (CustomMenuItem item))


{-| A menu item that will be represented in the menu list.

The `item` property is the type representation of the menu item that will be used in an [Action](#Action).

The `label` is the text representation that will be shown in the menu.

    type Tool
        = Screwdriver
        | Hammer
        | Drill

    toolItems : MenuItem Tool
    toolItems =
        [ basicMenuItem { item = Screwdriver, label = "Screwdriver" }
        , basicMenuItem { item = Hammer, label = "Hammer" }
        , basicMenuItem { item = Drill, label = "Drill" }
        ]

    yourView model =
        Html.map SelectMsg <|
            view
                (single Nothing
                    |> menuItems toolItems
                    |> state model.selectState
                )

Combine this with [basicMenuItem](#basicMenuItem) to create a [MenuItem](#MenuItem)

-}
type alias BasicMenuItem item =
    { item : item
    , label : String
    }


{-| A menu item that will be represented in the menu list by a view you supply.

The `item` property is the type representation of the menu item that will be used in an [Action](#Action).

The `label` is the text representation of the item.

The view is a `Html` view that you supply.

    type Tool
        = Screwdriver
        | Hammer
        | Drill

    toolItems : MenuItem Tool
    toolItems =
        [ customMenuItem { item = Screwdriver, label = "Screwdriver", view = text "Screwdriver" }
        , customMenuItem { item = Hammer, label = "Hammer", view = text "Hammer" }
        , customMenuItem { item = Drill, label = "Drill", view = text "Drill" }
        ]

    yourView model =
        Html.map SelectMsg <|
            view
                (single Nothing
                    |> menuItems toolItems
                    |> state model.selectState
                )

The view you provide will be rendered in a `li` element that is styled according to the value set by [setStyles](#setStyles).

        customMenuItem { item = Hammer, label = "Hammer", view = text "Hammer" }
        -- => <li>Hammer</>

Combine this with [customMenuItem](#customMenuItem) to create a [MenuItem](#MenuItem).

-}
type alias CustomMenuItem item =
    { item : item
    , label : String
    , view : Html Never
    }


getMenuItemLabel : MenuItem item -> String
getMenuItemLabel item =
    case item of
        Basic config ->
            config.label

        Custom config ->
            config.label


getMenuItemItem : MenuItem item -> item
getMenuItemItem item =
    case item of
        Basic config ->
            config.item

        Custom config ->
            config.item



-- DEFAULTS


{-| Set up an initial state in your init function.

    type Country
        = Australia
        | Japan
        | Taiwan

    type alias Model =
        { selectState : State
        , items : List (MenuItem Country)
        , selectedCountry : Maybe Country
        }

    init : Model
    init =
        { selectState = initState (selectIdentifier "country-select")
        , items =
            [ basicMenuItem
                { item = Australia, label = "Australia" }
            , basicMenuItem
                { item = Japan, label = "Japan" }
            , basicMenuItem
                { item = Taiwan, label = "Taiwan" }
            ]
        , selectedCountry = Nothing
        }

-}
initState : SelectId -> State
initState id_ =
    State
        { inputValue = Nothing
        , menuOpen = False
        , initialMousedown = Internal.NothingMousedown
        , controlUiFocused = Nothing

        -- Always focus the first menu item by default. This facilitates auto selecting the first item on Enter
        , activeTargetIndex = 0
        , menuViewportFocusNodes = Nothing
        , menuListScrollTop = 0
        , menuNavigation = Mouse
        , jsOptimize = False
        , selectId = id_
        , headlessEvent = Nothing
        }


defaults : Configuration item
defaults =
    { variant = CustomVariant (Single Nothing)
    , isLoading = False
    , loadingMessage = "Loading..."
    , state = initState (selectIdentifier "elm-select")
    , placeholder = "Select..."
    , menuItems = []
    , searchable = True
    , clearable = False
    , disabled = False
    , labelledBy = Nothing
    , ariaDescribedBy = Nothing
    , styles = Styles.default
    }



-- MENU ITEM MODIFIERS


{-| Create a [basic](#BasicMenuItem) type of [MenuItem](#MenuItem).

Use [customMenuItem](#customMenuItem) if you want more flexibility
on how a menu item will look in the menu.

        type Tool
            = Screwdriver
            | Hammer
            | Drill

        menuItems : List (MenuItem Tool)
        menuItems =
            [ basicMenuItem
                { item = Screwdriver, label = "Screwdriver" }
            , basicMenuItem
                { item = Hammer, label = "Hammer" }
            , basicMenuItem
                { item = Drill, label = "Drill" }
            ]

-}
basicMenuItem : BasicMenuItem item -> MenuItem item
basicMenuItem bscItem =
    Basic
        { item = bscItem.item
        , label = bscItem.label
        , filterable = True
        }


{-| Create a [custom](#CustomMenuItem) type of [MenuItem](#MenuItem).

        type Tool
            = Screwdriver
            | Hammer
            | Drill

        menuItems : List (MenuItem Tool)
        menuItems =
            [ customMenuItem
                { item = Screwdriver, label = "Screwdriver", view = text "Screwdriver" }
            , customMenuItem
                { item = Hammer, label = "Hammer", view = text "Hammer" }
            , customMenuItem
                { item = Drill, label = "Drill", view = text "Drill" }
            ]

-}
customMenuItem : CustomMenuItem item -> MenuItem item
customMenuItem i =
    Custom
        { item = i.item
        , label = i.label
        , view = i.view
        , filterable = True
        }


{-| Choose whether a menu item is filterable.

Useful for when you always want to have a selectable option in the menu.

Menu items are filterable by default.

        type Tool
            = Screwdriver
            | Hammer
            | Drill

        menuItems : List (MenuItem Tool)
        menuItems =
            [ customMenuItem
                { item = Screwdriver, label = "Screwdriver", view = text "Screwdriver" }
            , customMenuItem
                { item = Hammer, label = "Hammer", view = text "Hammer" }
            , customMenuItem
                { item = Drill, label = "Drill", view = text "Drill" }
                |> filterableMenuItem False
            ]

NOTE: This only takes effect when [searchable](#searchable) is `True`.

-}
filterableMenuItem : Bool -> MenuItem item -> MenuItem item
filterableMenuItem pred mi =
    case mi of
        Basic obj ->
            Basic { obj | filterable = pred }

        Custom obj ->
            Custom { obj | filterable = pred }



-- MODIFIERS


{-| Change some of the visual styles of the select.

Useful for styling the select using your
color branding.

      import Select.Styles as Styles

      baseStyles : Styles.Config
      baseStyles =
          Styles.default

      controlBranding : Styles.ControlConfig
      controlBranding =
          Styles.getControlConfig baseStyles
              |> Styles.setControlBorderColor (Css.hex "#FFFFFF")
              |> Styles.setControlBorderColorFocus (Css.hex "#0168B3")

      selectBranding : Styles.Config
      selectBranding =
        baseStyles
            |> Styles.setControlStyles controlBranding

      yourView model =
          Html.map SelectMsg <|
              view
                  (single Nothing |> setStyles selectBranding)

-}
setStyles : Styles.Config -> Config item -> Config item
setStyles sc (Config config) =
    Config
        { config
            | styles = sc
        }


{-| Renders an input that let's you input text to search for menu items.

      yourView model =
          Html.map SelectMsg <|
              view
                  (single Nothing |> searchable True)

NOTE: This doesn't affect the [Native single select](#native-single-select)
variant.

-}
searchable : Bool -> Config item -> Config item
searchable pred (Config config) =
    Config { config | searchable = pred }


{-| The text that will appear as an input placeholder.

      yourView model =
          Html.map SelectMsg <|
              view
                  (single Nothing |> placeholder "some placeholder")

-}
placeholder : String -> Config item -> Config item
placeholder plc (Config config) =
    Config { config | placeholder = plc }


{-| The select state.

This is usually persisted in your model.

      model : Model
      model =
          { selectState = initState }

      yourView : Model
      yourView model =
          Html.map SelectMsg <|
              view
                  (single Nothing
                      |> state model.selectState
                  )

-}
state : State -> Config item -> Config item
state state_ (Config config) =
    Config { config | state = state_ }


{-| The items that will appear in the menu list.

NOTE: When using the (multi) select, selected items will be reflected as a tags and
visually removed from the menu list.

      items =
          [ basicMenuItem
              { item = SomeValue, label = "Some label" }
          ]

      yourView =
          view
              (Single Nothing |> menuItems items)

-}
menuItems : List (MenuItem item) -> Config item -> Config item
menuItems items (Config config) =
    Config { config | menuItems = items }


{-| Allows a [single](#single) variant selected menu item to be cleared.

To handle a cleared item refer to the [ClearedSingleSelect](#Action ) action.

      items =
          [ basicMenuItem
              { item = SomeValue, label = "Some label" }
          ]

        yourView model =
            Html.map SelectMsg <|
                view
                    ( single Nothing
                        |> clearable True
                        |> menuItems items
                    )

-}
clearable : Bool -> Config item -> Config item
clearable clear (Config config) =
    Config { config | clearable = clear }


{-| Disables the select input so that it cannot be interacted with.

        yourView model =
            Html.map SelectMsg <|
                view
                    (single Nothing |> disabled True)

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

-}
loading : Bool -> Config item -> Config item
loading predicate (Config config) =
    Config { config | isLoading = predicate }


{-| Displays when there are no matched menu items and [loading](#loading) is True.

        yourView model =
            Html.map SelectMsg <|
                view
                    (single Nothing |> loadingMessage "Fetching items...")

-}
loadingMessage : String -> Config item -> Config item
loadingMessage m (Config config) =
    Config { config | loadingMessage = m }


{-| The element ID of the label for the select.

It is best practice to render the select with a label.

    yourView model =
        label
            [ id "selectLabelId" ]
            [ text "Select your country"
            , Html.map SelectMsg <|
                view
                    (single Nothing |> labelledBy "selectLabelId")
            ]

-}
labelledBy : String -> Config item -> Config item
labelledBy s (Config config) =
    Config { config | labelledBy = Just s }


{-| The ID of an element that describes the select.

    yourView model =
        label
            [ id "selectLabelId" ]
            [ text "Select your country"
            , Html.map SelectMsg <|
                view
                    (single Nothing
                        |> labelledBy "selectLabelId"
                        |> ariaDescribedBy "selectDescriptionId"
                    )
            , div [ id "selectDescriptionId" ] [ text "This text describes the select" ]
            ]

-}
ariaDescribedBy : String -> Config item -> Config item
ariaDescribedBy s (Config config) =
    Config { config | labelledBy = Just s }



-- STATE MODIFIERS


{-| Opt in to a Javascript optimization.

Read the [Advanced](https://package.elm-lang.org/packages/Confidenceman02/elm-select/latest/#opt-in-javascript-optimisation)
section of the README for a good explanation on why you might like to opt in.

        model : Model model =
            { selectState =
                initState (selectIdentifier "some-unique-id")
                        |> jsOptimize True
            }

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


{-| Opens the menu and sets focus on the Variant.

Handy when using a menu [Variant](#Variant) as dropdown.

      yourUpdate : (model, Cmd msg )
      yourUpdate msg model =
          case msg of
              FocusTheSelect ->
                let
                  ( actions, updatedState, cmds ) =
                      update focus model.selectState
                in
                ({ model | selectState = updatedState }, Cmd.map SelectMsg cmds)

NOTE: Successfull focus will dispatch the `FocusSet` [Action](#Action)

-}
focus : Msg item
focus =
    HeadlessMsg FocusInputH


{-| Check to see that the variant has focus.

This will return true if any focusable element inside the control has focus
i.e. If the clear button is visible and has focus.

      yourUpdate : (State, Cmd msg )
      yourUpdate msg state =
          case msg of
              SelectMsg msg ->
                  let
                    ( actions, updatedState, cmds ) =
                        update msg state
                  in
                  if isFocused updatedState then
                    (updatedState, makeSomeRequest)
                  else
                    (updatedState, Cmd.none)

-}
isFocused : State -> Bool
isFocused (State state_) =
    state_.controlUiFocused == Just Internal.ControlInput || state_.controlUiFocused == Just Internal.Clearable


{-| Check that the menu is open and visible.

      yourUpdate : (State, Cmd msg )
      yourUpdate msg state =
          case msg of
              SelectMsg msg ->
                let
                  ( actions, updatedState, cmds ) =
                      update msg state
                in
                if isFocused updatedState && isMenuOpen updatedState then
                  (updatedState, makeSomeRequest)

                else
                  (updatedState, Cmd.none)

-}
isMenuOpen : State -> Bool
isMenuOpen (State state_) =
    state_.menuOpen


internalFocus : String -> (Result Dom.Error () -> msg) -> Cmd msg
internalFocus id msg =
    Task.attempt msg (Dom.focus id)



-- VARIANT


type Variant item
    = CustomVariant (CustomVariant item)
    | Native (NativeVariant item)


type CustomVariant item
    = Single (Maybe (MenuItem item))
    | Multi (List (MenuItem item))
    | SingleMenu (Maybe (MenuItem item))


type NativeVariant item
    = SingleNative (Maybe (MenuItem item))


{-| Select a single item.

      countries : List (MenuItem Country)
      countries =
          [ basicMenuItem
              { item = Australia, label = "Australia" }
          , basicMenuitem
              { item = Taiwan, label = "Taiwan"
            -- other countries
          ]

      yourView =
          Html.map SelectMsg <|
              view
                  (single Nothing |> menuItems countries)

-}
single : Maybe (MenuItem item) -> Config item
single maybeSelectedItem =
    Config { defaults | variant = CustomVariant (Single maybeSelectedItem) }


{-| Menu only single select.

      countries : List (MenuItem Country)
      countries =
          [ basicMenuItem
              { item = Australia, label = "Australia" }
          , basicMenuitem
              { item = Taiwan, label = "Taiwan"
            -- other countries
          ]

      yourView =
          Html.map SelectMsg <|
              view
                (singleMenu Nothing |> menuItems countries)

NOTE: By default the menu will not render until it is focused and interacted with.
This is for accessibility reasons.

You can use [focus](#focus) to open and focus the menu if you are
using this variant as a dropdown.

-}
singleMenu : Maybe (MenuItem item) -> Config item
singleMenu mi =
    Config { defaults | variant = CustomVariant (SingleMenu mi) }


{-| Menu only select.

Unlike a [singleMenu](#singleMenu) this variant does not
accept or display options as selected.

Useful when you want to know what someone has selected like
a list of settings or options.

      actions : List (MenuItem Actions)
      actions =
          [ basicMenuItem
              { item = Update, label = "Update" }
          , basicMenuitem
              { item = Delete, label = "Delete"
            -- other actions
          ]

      yourView =
          Html.map SelectMsg <|
              view
                (menu |> menuItems actions)

NOTE: By default the menu will not render until it is focused and interacted with.
This is for accessibility reasons.

You can use [focus](#focus) to open and focus the menu if you are
using this variant as a dropdown.

-}
menu : Config item
menu =
    Config { defaults | variant = CustomVariant (SingleMenu Nothing) }


{-| Select a single item with a native html [select](https://www.w3schools.com/tags/tag_select.asp) element.

Useful for when you want to give a native select experience such as on touch
devices.

      countries : List (MenuItem Country)
      countries =
          [ basicMenuItem
              { item = Australia, label = "Australia" }
          , basicMenuItem
              { item = Taiwan, label = "Taiwan"
          -- other countries
          ]

      yourView =
          Html.map SelectMsg <|
              view
                  (singleNative Nothing |> menuItems countries)

**Note**

  - The only [Action](#Action) event that will be fired from the native single select is
    the `Select` [Action](#Action). The other actions are not currently supported.

  - Some [Config](#Config) values will not take effect when using the single native variant

-}
singleNative : Maybe (MenuItem item) -> Config item
singleNative mi =
    Config { defaults | variant = Native (SingleNative mi) }


{-| Select multiple items.

Selected items will render as tags and be visually removed from the menu list.

    yourView model =
        Html.map SelectMsg <|
            view
                (multi model.selectedCountries
                    |> menuItems model.countries
                )

-}
multi : List (MenuItem item) -> Config item
multi selectedItems =
    Config { defaults | variant = CustomVariant (Multi selectedItems) }


{-| The ID for the rendered Select input

NOTE: It is important that the ID's of all selects that exist on
a page remain unique.

    init : State
    init =
        initState (selectIdentifier "someUniqueId")

-}
selectIdentifier : String -> SelectId
selectIdentifier id_ =
    SelectId (id_ ++ "__elm-select")



-- UPDATE


{-| Add a branch in your update to handle the view Msg's.

      yourUpdate msg model =
          case msg of
              SelectMsg selectMsg ->
                  update selectMsg model.selectState

-}
update : Msg item -> State -> ( Maybe (Action item), State, Cmd (Msg item) )
update msg ((State state_) as wrappedState) =
    let
        (SelectId idString) =
            state_.selectId
    in
    case msg of
        HeadlessMsg FocusInputH ->
            let
                updatedState =
                    State { state_ | headlessEvent = Just FocusingInputH, menuOpen = True }
            in
            ( Nothing, updatedState, internalFocus idString OnInputFocused )

        InputChangedNativeSingle allMenuItems hasCurrentSelection selectedOptionIndex ->
            let
                resolveIndex =
                    if hasCurrentSelection then
                        selectedOptionIndex

                    else
                        -- Account for the placeholder item
                        selectedOptionIndex - 1
            in
            case ListExtra.getAt resolveIndex allMenuItems of
                Nothing ->
                    ( Nothing, State state_, Cmd.none )

                Just mi ->
                    ( Just <| Select (getMenuItemItem mi), State state_, Cmd.none )

        EnterSelect menuItem ->
            let
                ( _, State stateWithClosedMenu, cmdWithClosedMenu ) =
                    update CloseMenu (State state_)
            in
            ( Just (Select (getMenuItemItem menuItem))
            , State
                { stateWithClosedMenu
                    | initialMousedown = Internal.NothingMousedown
                    , inputValue = Nothing
                }
            , cmdWithClosedMenu
            )

        EnterSelectMulti menuItem ->
            let
                ( _, State stateWithClosedMenu, cmdWithClosedMenu ) =
                    update CloseMenu (State state_)
            in
            ( Just (Select (getMenuItemItem menuItem))
            , State
                { stateWithClosedMenu
                    | initialMousedown = Internal.NothingMousedown
                    , inputValue = Nothing
                }
            , Cmd.batch [ cmdWithClosedMenu, internalFocus idString OnInputFocused ]
            )

        HoverFocused i ->
            ( Nothing, State { state_ | activeTargetIndex = i }, Cmd.none )

        InputChanged inputValue ->
            let
                ( _, State stateWithOpenMenu, cmdWithOpenMenu ) =
                    update OpenMenu (State state_)
            in
            ( Just (InputChange inputValue), State { stateWithOpenMenu | inputValue = Just inputValue }, cmdWithOpenMenu )

        InputReceivedFocused variant ->
            let
                ( action, updatedState ) =
                    case variant of
                        CustomVariant _ ->
                            case state_.headlessEvent of
                                Just FocusingInputH ->
                                    ( Just FocusSet
                                    , { state_
                                        | menuOpen = True
                                        , initialMousedown = Internal.NothingMousedown
                                        , controlUiFocused = Just Internal.ControlInput
                                        , headlessEvent = Nothing
                                      }
                                    )

                                _ ->
                                    ( Nothing, { state_ | controlUiFocused = Just Internal.ControlInput } )

                        _ ->
                            ( Nothing, { state_ | controlUiFocused = Just Internal.ControlInput } )
            in
            ( action
            , State
                updatedState
            , Cmd.none
            )

        SelectedItem item ->
            let
                ( _, State stateWithClosedMenu, cmdWithClosedMenu ) =
                    update CloseMenu (State state_)
            in
            ( Just (Select item)
            , State
                { stateWithClosedMenu
                    | initialMousedown = Internal.NothingMousedown
                    , inputValue = Nothing
                }
            , cmdWithClosedMenu
            )

        SelectedItemMulti item ->
            let
                ( _, State stateWithClosedMenu, cmdWithClosedMenu ) =
                    update CloseMenu (State state_)
            in
            ( Just (Select item)
            , State
                { stateWithClosedMenu
                    | initialMousedown = Internal.NothingMousedown
                    , inputValue = Nothing
                }
            , Cmd.batch [ cmdWithClosedMenu, internalFocus idString OnInputFocused ]
            )

        DeselectedMultiItem deselectedItem ->
            ( Just (DeselectMulti deselectedItem)
            , State { state_ | initialMousedown = Internal.NothingMousedown }
            , internalFocus idString OnInputFocused
            )

        -- focusing the input is usually the last thing that happens after all the mousedown events.
        -- Its important to ensure we have a NothingInitClicked so that if the user clicks outside of the
        -- container it will close the menu and un focus the container. OnInputBlurred treats ContainerInitClick and
        -- MutiItemInitClick as special cases to avoid flickering when an input gets blurred then focused again.
        OnInputFocused focusResult ->
            case focusResult of
                Ok () ->
                    ( Nothing, State { state_ | initialMousedown = Internal.NothingMousedown }, Cmd.none )

                Err _ ->
                    ( Nothing, wrappedState, Cmd.none )

        OnMenuClearableFocus focusResult ->
            case focusResult of
                Ok () ->
                    ( Nothing
                    , State
                        { state_
                            | headlessEvent = Nothing
                            , controlUiFocused = Just Internal.Clearable
                            , initialMousedown = Internal.NothingMousedown
                        }
                    , Cmd.none
                    )

                Err _ ->
                    ( Nothing, State { state_ | headlessEvent = Nothing }, Cmd.none )

        FocusMenuViewport (Ok ( menuListElem, menuItemElem )) ->
            let
                ( viewportFocusCmd, newViewportY ) =
                    menuItemOrientationInViewport menuListElem menuItemElem
                        |> setMenuViewportPosition state_.selectId state_.menuListScrollTop menuListElem menuItemElem
            in
            ( Nothing, State { state_ | menuViewportFocusNodes = Just ( menuListElem, menuItemElem ), menuListScrollTop = newViewportY }, viewportFocusCmd )

        -- If the menu list element was not found it likely has no viewable menu items.
        -- In this case the menu does not render therefore no id is present on menu element.
        FocusMenuViewport (Err _) ->
            ( Nothing, State { state_ | menuViewportFocusNodes = Nothing }, Cmd.none )

        DoNothing ->
            ( Nothing, State state_, Cmd.none )

        OnInputBlurred variant ->
            let
                resolveAction =
                    case state_.inputValue of
                        Just "" ->
                            Nothing

                        Just _ ->
                            Just (InputChange "")

                        _ ->
                            Nothing

                ( _, State stateWithClosedMenu, cmdWithClosedMenu ) =
                    update CloseMenu (State state_)

                ( updatedState, updatedCmds, action ) =
                    case state_.initialMousedown of
                        Internal.ContainerMousedown ->
                            case variant of
                                CustomVariant (SingleMenu _) ->
                                    ( { stateWithClosedMenu
                                        | initialMousedown = Internal.NothingMousedown
                                        , controlUiFocused = Nothing
                                        , inputValue = Nothing
                                      }
                                    , Cmd.batch [ cmdWithClosedMenu, Cmd.none ]
                                    , resolveAction
                                    )

                                _ ->
                                    ( { state_ | inputValue = Nothing }, Cmd.none, resolveAction )

                        Internal.MultiItemMousedown _ ->
                            ( state_, Cmd.none, Nothing )

                        _ ->
                            ( { stateWithClosedMenu
                                | initialMousedown = Internal.NothingMousedown
                                , controlUiFocused = Nothing
                                , inputValue = Nothing
                              }
                            , Cmd.batch [ cmdWithClosedMenu, Cmd.none ]
                            , resolveAction
                            )
            in
            case state_.headlessEvent of
                -- Keep menu open for menu variants when tabbing to clear icon.
                -- Only works for menu varaints for now.
                Just FocusingClearableH ->
                    ( Nothing, wrappedState, Cmd.none )

                _ ->
                    ( action
                    , State updatedState
                    , updatedCmds
                    )

        OnMenuInputTabbed clearButtonVisible ->
            if clearButtonVisible then
                ( Nothing
                , State { state_ | headlessEvent = Just FocusingClearableH }
                , internalFocus (clearableId state_.selectId) OnMenuClearableFocus
                )

            else
                update CloseMenu wrappedState

        OnMenuClearableShiftTabbed shiftKey ->
            if shiftKey then
                ( Nothing, State { state_ | headlessEvent = Just FocusingInputH }, internalFocus idString OnInputFocused )

            else
                update CloseMenu wrappedState

        OnMenuClearableBlurred ->
            case state_.initialMousedown of
                Internal.NothingMousedown ->
                    case state_.headlessEvent of
                        -- Dont close the menu when the blur occurs as a
                        -- result of focusing the input programatically.
                        Just FocusingInputH ->
                            ( Nothing, wrappedState, Cmd.none )

                        _ ->
                            update CloseMenu wrappedState

                _ ->
                    ( Nothing, wrappedState, Cmd.none )

        MenuItemClickFocus i ->
            ( Nothing, State { state_ | initialMousedown = Internal.MenuItemMousedown i }, Cmd.none )

        MultiItemFocus index ->
            ( Nothing, State { state_ | initialMousedown = Internal.MultiItemMousedown index }, Cmd.none )

        InputMousedowned ->
            ( Nothing, State { state_ | initialMousedown = Internal.NothingMousedown }, Cmd.none )

        InputEscape ->
            let
                resolveAction =
                    case state_.inputValue of
                        Just "" ->
                            Nothing

                        Just _ ->
                            Just (InputChange "")

                        _ ->
                            Nothing

                ( _, State stateWithClosedMenu, cmdWithClosedMenu ) =
                    update CloseMenu (State state_)
            in
            ( resolveAction, State { stateWithClosedMenu | inputValue = Nothing }, cmdWithClosedMenu )

        ClearFocusedItem ->
            ( Nothing, State { state_ | initialMousedown = Internal.NothingMousedown }, Cmd.none )

        SearchableSelectContainerClicked variant ->
            let
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
                        Internal.MultiItemMousedown _ ->
                            ( state_, internalFocus idString OnInputFocused )

                        Internal.NothingMousedown ->
                            if state_.menuOpen then
                                case variant of
                                    SingleMenu _ ->
                                        ( { state_ | initialMousedown = Internal.ContainerMousedown }, Cmd.none )

                                    _ ->
                                        ( { stateWithClosedMenu
                                            | initialMousedown = Internal.ContainerMousedown
                                          }
                                        , Cmd.batch [ cmdWithClosedMenu, internalFocus idString OnInputFocused ]
                                        )

                            else
                                ( { stateWithOpenMenu | initialMousedown = Internal.ContainerMousedown }
                                , Cmd.batch [ cmdWithOpenMenu, internalFocus idString OnInputFocused ]
                                )

                        Internal.ContainerMousedown ->
                            case variant of
                                SingleMenu _ ->
                                    ( { state_ | initialMousedown = Internal.ContainerMousedown }, Cmd.none )

                                _ ->
                                    if state_.menuOpen then
                                        ( { stateWithClosedMenu | initialMousedown = Internal.NothingMousedown }
                                        , Cmd.batch [ cmdWithClosedMenu, internalFocus idString OnInputFocused ]
                                        )

                                    else
                                        ( { stateWithOpenMenu | initialMousedown = Internal.NothingMousedown }
                                        , Cmd.batch [ cmdWithOpenMenu, internalFocus idString OnInputFocused ]
                                        )

                        _ ->
                            if state_.menuOpen then
                                ( stateWithClosedMenu, Cmd.batch [ cmdWithClosedMenu, internalFocus idString OnInputFocused ] )

                            else
                                ( stateWithOpenMenu, Cmd.batch [ cmdWithOpenMenu, internalFocus idString OnInputFocused ] )
            in
            ( Nothing
            , State
                { updatedState
                    | controlUiFocused = Just Internal.ControlInput
                }
            , updatedCmds
            )

        UnsearchableSelectContainerClicked ->
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
            ( Nothing
            , State { updatedState | controlUiFocused = Just Internal.ControlInput }
            , Cmd.batch [ updatedCmd, internalFocus idString OnInputFocused ]
            )

        ToggleMenuAtKey ->
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
            ( Nothing, State { updatedState | controlUiFocused = Just Internal.ControlInput }, updatedCmd )

        KeyboardDown totalTargetCount ->
            let
                ( _, State stateWithOpenMenu, cmdWithOpenMenu ) =
                    update OpenMenu (State state_)

                nextActiveTargetIndex =
                    Internal.calculateNextActiveTarget state_.activeTargetIndex totalTargetCount Internal.Down

                nodeQueryForViewportFocus =
                    if Internal.shouldQueryNextTargetElement nextActiveTargetIndex state_.activeTargetIndex then
                        queryNodesForViewportFocus state_.selectId nextActiveTargetIndex

                    else
                        Cmd.none

                ( updatedState, updatedCmd ) =
                    if state_.menuOpen then
                        ( { state_ | activeTargetIndex = nextActiveTargetIndex, menuNavigation = Keyboard }, nodeQueryForViewportFocus )

                    else
                        ( { stateWithOpenMenu | menuNavigation = Keyboard }, cmdWithOpenMenu )
            in
            ( Nothing, State updatedState, updatedCmd )

        KeyboardUp totalTargetCount ->
            let
                ( _, State stateWithOpenMenu, cmdWithOpenMenu ) =
                    update OpenMenu (State state_)

                nextActiveTargetIndex =
                    Internal.calculateNextActiveTarget state_.activeTargetIndex totalTargetCount Internal.Up

                nodeQueryForViewportFocus =
                    if Internal.shouldQueryNextTargetElement nextActiveTargetIndex state_.activeTargetIndex then
                        queryNodesForViewportFocus state_.selectId nextActiveTargetIndex

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
            , resetState (State state_)
            , Cmd.none
            )

        MenuListScrollTop position ->
            ( Nothing, State { state_ | menuListScrollTop = position }, Cmd.none )

        SetMouseMenuNavigation ->
            ( Nothing, State { state_ | menuNavigation = Mouse }, Cmd.none )

        ClearButtonMouseDowned variant ->
            case variant of
                SingleMenu _ ->
                    ( Just MenuInputCleared, State { state_ | inputValue = Nothing }, Cmd.none )

                _ ->
                    ( Just ClearSingleSelectItem, State state_, Cmd.none )

        ClearButtonKeyDowned variant ->
            case variant of
                SingleMenu _ ->
                    ( Just MenuInputCleared, State { state_ | inputValue = Nothing }, internalFocus idString OnInputFocused )

                _ ->
                    ( Just ClearSingleSelectItem, State state_, internalFocus idString OnInputFocused )


{-| Render the select

      yourView model =
          Html.map SelectMsg <|
              view (single Nothing)

-}
view : Config item -> Html (Msg item)
view (Config config) =
    let
        (State state_) =
            config.state

        selectId =
            state_.selectId

        totalMenuItems =
            List.length viewableMenuItems

        viewableMenuItems =
            buildViewableMenuItems
                (BuildViewableMenuItemsData
                    config.searchable
                    state_.inputValue
                    config.menuItems
                    config.variant
                )

        ctrlStyles =
            Styles.getControlConfig config.styles

        menuStyles =
            Styles.getMenuConfig config.styles
    in
    case config.variant of
        Native variant ->
            div []
                [ viewNative
                    (ViewNativeData ctrlStyles
                        variant
                        config.menuItems
                        selectId
                        config.labelledBy
                        config.ariaDescribedBy
                        config.placeholder
                    )
                , span
                    [ StyledAttribs.css
                        [ Css.position Css.absolute
                        , Css.right (Css.px 0)
                        , Css.top (Css.pct 50)
                        , Css.transform (Css.translateY (Css.pct -50))
                        , Css.padding (Css.px 8)
                        , Css.pointerEvents Css.none
                        ]
                    ]
                    [ dropdownIndicator ctrlStyles False ]
                ]

        CustomVariant ((SingleMenu _) as singleVariant) ->
            -- Compose the SingleMenu variant, def can be improved
            Internal.viewIf state_.menuOpen
                (viewWrapper
                    (ViewWrapperData state_
                        config.searchable
                        singleVariant
                        config.disabled
                    )
                    [ Keyed.node "div"
                        [ StyledAttribs.css (menuWrapperStyles (Styles.getMenuConfig config.styles)) ]
                        [ if not config.searchable then
                            ( "dummy-input"
                            , lazy viewDummyInput
                                (ViewDummyInputData
                                    (getSelectId config.state)
                                    singleVariant
                                    (enterSelectTargetItem state_ viewableMenuItems)
                                    totalMenuItems
                                    state_.menuOpen
                                    config.labelledBy
                                    config.ariaDescribedBy
                                    config.disabled
                                    config.clearable
                                    state_
                                )
                            )

                          else
                            ( "controlled-input"
                            , viewControlWrapper
                                (ViewControlWrapperData
                                    config.disabled
                                    config.state
                                    (Styles.getControlConfig config.styles)
                                    (Styles.getMenuConfig config.styles)
                                    singleVariant
                                )
                                [ viewSearchIndicator (Styles.getMenuControlSearchIndicatorColor menuStyles)
                                , viewInputWrapper config.disabled
                                    [ Internal.viewIf (not config.disabled)
                                        (lazy viewSelectInput
                                            (ViewSelectInputData
                                                (enterSelectTargetItem state_ viewableMenuItems)
                                                totalMenuItems
                                                singleVariant
                                                config.labelledBy
                                                config.ariaDescribedBy
                                                config.disabled
                                                config.clearable
                                                state_
                                            )
                                        )
                                    , buildPlaceholder
                                        (BuildPlaceholderData singleVariant
                                            state_
                                            ctrlStyles
                                            config.placeholder
                                        )
                                    ]
                                , viewIndicatorWrapper
                                    [ viewClearIndicator
                                        (ViewClearIndicatorData
                                            config.disabled
                                            config.clearable
                                            singleVariant
                                            config.state
                                            config.styles
                                        )
                                    , viewLoadingSpinner
                                        (ViewLoadingSpinnerData config.isLoading
                                            config.searchable
                                            (Styles.getMenuControlLoadingIndicatorColor menuStyles)
                                        )
                                    ]
                                ]
                            )

                        -- , ( "divider"
                        --   , div
                        --         [ StyledAttribs.css
                        --             [ Css.height (Css.px 0)
                        --             , Css.marginTop (Css.rem 1.5)
                        --             , Css.border3 (Css.px 1) Css.solid (Styles.getMenuDividerColor menuStyles)
                        --             ]
                        --         ]
                        --         []
                        --   )
                        , ( "menu-list"
                          , viewMenuItemsWrapper
                                (ViewMenuItemsWrapperData
                                    singleVariant
                                    (Styles.getMenuConfig config.styles)
                                    state_.menuNavigation
                                    selectId
                                )
                                (if config.isLoading && List.isEmpty viewableMenuItems then
                                    [ ( "loading-menu"
                                      , viewLoadingMenu
                                            (ViewLoadingMenuData singleVariant
                                                config.loadingMessage
                                                (Styles.getMenuConfig config.styles)
                                            )
                                      )
                                    ]

                                 else
                                    viewMenuItems
                                        (ViewMenuItemsData
                                            (Styles.getMenuItemConfig config.styles)
                                            selectId
                                            singleVariant
                                            state_.initialMousedown
                                            state_.activeTargetIndex
                                            state_.menuNavigation
                                            viewableMenuItems
                                            config.disabled
                                        )
                                )
                          )
                        ]
                    ]
                )

        CustomVariant variant ->
            viewWrapper
                (ViewWrapperData state_
                    config.searchable
                    variant
                    config.disabled
                )
                [ lazy viewCustomControl
                    (ViewControlData
                        config.state
                        ctrlStyles
                        config.styles
                        (enterSelectTargetItem state_ viewableMenuItems)
                        totalMenuItems
                        variant
                        config.placeholder
                        config.disabled
                        config.searchable
                        config.labelledBy
                        config.ariaDescribedBy
                        config.clearable
                        config.isLoading
                    )
                , Internal.viewIf state_.menuOpen
                    (if config.isLoading && List.isEmpty viewableMenuItems then
                        viewLoadingMenu
                            (ViewLoadingMenuData
                                variant
                                config.loadingMessage
                                (Styles.getMenuConfig config.styles)
                            )

                     else
                        lazy viewMenu
                            (ViewMenuData
                                variant
                                selectId
                                viewableMenuItems
                                state_.initialMousedown
                                state_.activeTargetIndex
                                state_.menuNavigation
                                (Styles.getMenuConfig config.styles)
                                (Styles.getMenuItemConfig config.styles)
                                config.disabled
                            )
                    )
                ]


type alias ViewControlData item =
    { state : State
    , controlStyles : Styles.ControlConfig
    , styles : Styles.Config
    , enterSelectTargetItem : Maybe (MenuItem item)
    , totalMenuItems : Int
    , variant : CustomVariant item
    , placeholder : String
    , disabled : Bool
    , searchable : Bool
    , labelledBy : Maybe String
    , ariaDescribedBy : Maybe String
    , clearable : Bool
    , loading : Bool
    }


viewCustomControl : ViewControlData item -> Html (Msg item)
viewCustomControl data =
    let
        (State state_) =
            data.state

        menuStyles =
            Styles.getMenuConfig data.styles

        buildVariantInput =
            case data.variant of
                Multi multiSelectedValues ->
                    let
                        resolveMultiValueStyles =
                            if 0 < List.length multiSelectedValues then
                                [ StyledAttribs.css
                                    [ Css.marginRight (Css.rem 0.4375)
                                    , Css.lineHeight (Css.num 1.9)
                                    ]
                                ]

                            else
                                []
                    in
                    div resolveMultiValueStyles <|
                        (List.indexedMap
                            (viewMultiValue state_.initialMousedown data.controlStyles)
                            multiSelectedValues
                            ++ [ buildInput ]
                        )

                Single _ ->
                    buildInput

                SingleMenu _ ->
                    buildInput

        resolvePlaceholder =
            buildPlaceholder
                (BuildPlaceholderData data.variant
                    state_
                    data.controlStyles
                    data.placeholder
                )

        buildInput =
            if not data.disabled then
                if data.searchable then
                    lazy viewSelectInput
                        (ViewSelectInputData
                            data.enterSelectTargetItem
                            data.totalMenuItems
                            data.variant
                            data.labelledBy
                            data.ariaDescribedBy
                            data.disabled
                            data.clearable
                            state_
                        )

                else
                    lazy viewDummyInput
                        (ViewDummyInputData
                            (getSelectId data.state)
                            data.variant
                            data.enterSelectTargetItem
                            data.totalMenuItems
                            state_.menuOpen
                            data.labelledBy
                            data.ariaDescribedBy
                            data.disabled
                            data.clearable
                            state_
                        )

            else
                text ""

        -- resolveIndicators =
    in
    viewControlWrapper
        (ViewControlWrapperData
            data.disabled
            data.state
            data.controlStyles
            menuStyles
            data.variant
        )
        [ viewInputWrapper data.disabled
            [ buildVariantInput
            , resolvePlaceholder
            ]

        -- indicators
        , viewIndicatorWrapper
            [ viewClearIndicator
                (ViewClearIndicatorData data.disabled
                    data.clearable
                    data.variant
                    data.state
                    data.styles
                )
            , viewLoadingSpinner
                (ViewLoadingSpinnerData data.loading
                    data.searchable
                    (Styles.getControlLoadingIndicatorColor data.controlStyles)
                )
            , indicatorSeparator data.controlStyles
            , viewDropdownIndicator
                (ViewDropdownIndicatorData data.disabled data.controlStyles)
            ]
        ]


viewInputWrapper : Bool -> List (Html (Msg item)) -> Html (Msg item)
viewInputWrapper dsbl =
    let
        withDisabledStyles =
            if dsbl then
                [ Css.position Css.static ]

            else
                []
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


type alias ViewDropdownIndicatorData =
    { disabled : Bool
    , controlStyles : Styles.ControlConfig
    }


viewDropdownIndicator : ViewDropdownIndicatorData -> Html msg
viewDropdownIndicator data =
    div
        [ StyledAttribs.css indicatorContainerStyles ]
        [ dropdownIndicator data.controlStyles data.disabled
        ]


type alias ViewLoadingSpinnerData =
    { isLoading : Bool
    , searchable : Bool
    , loadingIndicatorColor : Css.Color
    }


viewLoadingSpinner : ViewLoadingSpinnerData -> Html msg
viewLoadingSpinner data =
    let
        resolveLoadingSpinner =
            if data.isLoading && data.searchable then
                viewLoading

            else
                text ""
    in
    div [ StyledAttribs.css indicatorContainerStyles ]
        [ span
            [ StyledAttribs.css
                [ Css.color data.loadingIndicatorColor
                , Css.height (Css.px 20)
                , Css.displayFlex
                , Css.alignItems Css.center
                ]
            ]
            [ resolveLoadingSpinner ]
        ]


viewSearchIndicator : Css.Color -> Html (Msg item)
viewSearchIndicator color =
    span
        [ StyledAttribs.css
            [ Css.displayFlex
            , Css.alignItems Css.center
            , Css.property "margin-inline-start" (Css.rem 0.5).value
            , Css.height (Css.px 16)
            , Css.color color
            ]
        ]
        [ SearchIcon.view ]


type alias ViewClearIndicatorData item =
    { disabled : Bool
    , clearable : Bool
    , variant : CustomVariant item
    , state : State
    , styles : Styles.Config
    }


viewClearIndicator : ViewClearIndicatorData item -> Html (Msg item)
viewClearIndicator data =
    let
        (State state_) =
            data.state

        clearButtonVisible =
            showClearButton
                (ShowClearButtonData data.variant
                    data.disabled
                    data.clearable
                    state_
                )

        ctrlStyles =
            Styles.getControlConfig data.styles

        menuStyles =
            Styles.getMenuConfig data.styles

        resolveClearIndicatorData =
            case data.variant of
                SingleMenu _ ->
                    ClearIndicatorData data.disabled
                        (Styles.getMenuControlClearIndicatorColor menuStyles)
                        (Styles.getMenuControlClearIndicatorColorHover menuStyles)
                        data.variant
                        state_.selectId

                _ ->
                    ClearIndicatorData data.disabled
                        (Styles.getControlClearIndicatorColor ctrlStyles)
                        (Styles.getControlClearIndicatorColorHover ctrlStyles)
                        data.variant
                        state_.selectId
    in
    Internal.viewIf clearButtonVisible <|
        div [ StyledAttribs.css indicatorContainerStyles ] [ clearIndicator resolveClearIndicatorData ]


viewIndicatorWrapper : List (Html (Msg item)) -> Html (Msg item)
viewIndicatorWrapper =
    div
        [ StyledAttribs.css
            [ Css.alignItems Css.center
            , Css.alignSelf Css.stretch
            , Css.displayFlex
            , Css.flexShrink Css.zero
            , Css.boxSizing Css.borderBox
            ]
        ]


type alias ViewControlWrapperData item =
    { disabled : Bool
    , state : State
    , controlStyles : Styles.ControlConfig
    , menuStyles : Styles.MenuConfig
    , variant : CustomVariant item
    }


viewControlWrapper : ViewControlWrapperData item -> List (Html (Msg item)) -> Html (Msg item)
viewControlWrapper data =
    let
        (State state_) =
            data.state

        resolveControlStyles =
            case data.variant of
                SingleMenu _ ->
                    [ Css.margin4
                        (Css.px 6)
                        (Css.px 6)
                        (Css.px 0)
                        (Css.px 6)
                    , Css.batch
                        (menuControlStyles data.menuStyles state_ data.disabled)
                    ]

                _ ->
                    controlStyles data.controlStyles state_ data.disabled
    in
    div
        -- control
        (StyledAttribs.css
            resolveControlStyles
            :: (if data.disabled then
                    []

                else
                    [ attribute "data-test-id" "selectContainer"
                    ]
               )
        )


type alias ViewNativeData item =
    { controlStyles : Styles.ControlConfig
    , variant : NativeVariant item
    , menuItems : List (MenuItem item)
    , selectId : SelectId
    , labelledBy : Maybe String
    , ariaDescribedBy : Maybe String
    , placeholder : String
    }


viewNative : ViewNativeData item -> Html (Msg item)
viewNative data =
    case data.variant of
        SingleNative maybeSelectedItem ->
            let
                withSelectedOption item =
                    case maybeSelectedItem of
                        Just selectedItem ->
                            if selectedItem == item then
                                [ StyledAttribs.attribute "selected" "" ]

                            else
                                []

                        _ ->
                            []

                withPlaceholder =
                    case maybeSelectedItem of
                        Just _ ->
                            text ""

                        _ ->
                            option
                                [ StyledAttribs.hidden True
                                , StyledAttribs.selected True
                                , StyledAttribs.disabled True
                                ]
                                [ text ("(" ++ data.placeholder ++ ")") ]

                buildList menuItem =
                    option (StyledAttribs.value (getMenuItemLabel menuItem) :: withSelectedOption menuItem) [ text (getMenuItemLabel menuItem) ]

                (SelectId selectId) =
                    data.selectId

                withLabelledBy =
                    case data.labelledBy of
                        Just s ->
                            [ Aria.ariaLabelledby s ]

                        _ ->
                            []

                withAriaDescribedBy =
                    case data.ariaDescribedBy of
                        Just s ->
                            [ Aria.ariaDescribedby s ]

                        _ ->
                            []

                hasCurrentSelection =
                    case maybeSelectedItem of
                        Just _ ->
                            True

                        _ ->
                            False
            in
            select
                ([ id selectId
                 , StyledAttribs.attribute "data-test-id" "nativeSingleSelect"
                 , StyledAttribs.name "SomeSelect"
                 , Events.onInputAtInt [ "target", "selectedIndex" ] (InputChangedNativeSingle data.menuItems hasCurrentSelection)
                 , onFocus (InputReceivedFocused (Native data.variant))
                 , onBlur (OnInputBlurred (Native data.variant))
                 , StyledAttribs.css
                    [ Css.width (Css.pct 100)
                    , Css.height (Css.px (Styles.getControlMinHeight data.controlStyles))
                    , controlRadius (Styles.getControlBorderRadius data.controlStyles)
                    , Css.backgroundColor (Styles.getControlBackgroundColor data.controlStyles)
                    , controlBorder (Styles.getControlBorderColor data.controlStyles)
                    , Css.padding2 (Css.px 2) (Css.px 8)
                    , Css.property "appearance" "none"
                    , Css.property "-webkit-appearance" "none"
                    , Css.color (Styles.getControlColor data.controlStyles)
                    , Css.fontSize (Css.px 16)
                    , Css.focus
                        [ controlBorderFocused (Styles.getControlBorderColorFocus data.controlStyles), Css.outline Css.none ]
                    , controlHover
                        (ControlHoverData
                            (Styles.getControlBackgroundColorHover data.controlStyles)
                            (Styles.getControlBorderColor data.controlStyles)
                        )
                    ]
                 ]
                    ++ withLabelledBy
                    ++ withAriaDescribedBy
                )
                (withPlaceholder :: List.map buildList data.menuItems)


type alias ViewWrapperData item =
    { state : SelectState
    , searchable : Bool
    , variant : CustomVariant item
    , disabled : Bool
    }


viewWrapper : ViewWrapperData item -> List (Html (Msg item)) -> Html (Msg item)
viewWrapper data =
    let
        preventDefault =
            case data.state.initialMousedown of
                Internal.NothingMousedown ->
                    case data.variant of
                        SingleMenu _ ->
                            data.state.controlUiFocused == Just Internal.ControlInput

                        _ ->
                            False

                Internal.ContainerMousedown ->
                    True

                _ ->
                    True

        resolveContainerMsg =
            if data.searchable then
                SearchableSelectContainerClicked data.variant

            else
                UnsearchableSelectContainerClicked
    in
    div
        (StyledAttribs.css [ Css.position Css.relative, Css.boxSizing Css.borderBox ]
            :: (if data.disabled then
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


type alias ViewMenuItemsWrapperData item =
    { variant : CustomVariant item
    , menuStyles : Styles.MenuConfig
    , menuNavigation : MenuNavigation
    , selectId : SelectId
    }


viewMenuItemsWrapper : ViewMenuItemsWrapperData item -> List ( String, Html (Msg item) ) -> Html (Msg item)
viewMenuItemsWrapper data =
    let
        resolveAttributes =
            if data.menuNavigation == Keyboard then
                [ attribute "data-test-id" "listBox", on "mousemove" <| Decode.succeed SetMouseMenuNavigation ]

            else
                [ attribute "data-test-id" "listBox" ]

        resolveStyles =
            case data.variant of
                SingleMenu _ ->
                    menuListStyles

                _ ->
                    menuWrapperStyles data.menuStyles ++ menuListStyles
    in
    Keyed.node "ul"
        ([ StyledAttribs.css resolveStyles
         , id (menuListId data.selectId)
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


type alias ViewMenuData item =
    { variant : CustomVariant item
    , selectId : SelectId
    , viewableMenuItems : List (MenuItem item)
    , initialMousedown : Internal.InitialMousedown
    , activeTargetIndex : Int
    , menuNavigation : MenuNavigation
    , menuStyles : Styles.MenuConfig
    , menuItemStyles : Styles.MenuItemConfig
    , disabled : Bool
    }


viewMenu : ViewMenuData item -> Html (Msg item)
viewMenu data =
    viewMenuItemsWrapper
        (ViewMenuItemsWrapperData
            data.variant
            data.menuStyles
            data.menuNavigation
            data.selectId
        )
        (viewMenuItems
            (ViewMenuItemsData
                data.menuItemStyles
                data.selectId
                data.variant
                data.initialMousedown
                data.activeTargetIndex
                data.menuNavigation
                data.viewableMenuItems
                data.disabled
            )
        )


type alias ViewLoadingMenuData item =
    { variant : CustomVariant item
    , loadingText : String
    , menuStyles : Styles.MenuConfig
    }


viewLoadingMenu : ViewLoadingMenuData item -> Html msg
viewLoadingMenu data =
    let
        variantStyles =
            case data.variant of
                SingleMenu _ ->
                    []

                _ ->
                    menuWrapperStyles data.menuStyles
                        ++ menuListStyles
    in
    div
        [ StyledAttribs.css
            [ Css.textAlign Css.center, Css.opacity (Css.num 0.5), Css.batch variantStyles ]
        ]
        [ text data.loadingText
        ]


type alias ViewMenuItemsData item =
    { menuItemStyles : Styles.MenuItemConfig
    , selectId : SelectId
    , variant : CustomVariant item
    , initialMousedown : Internal.InitialMousedown
    , activeTargetIndex : Int
    , menuNavigation : MenuNavigation
    , viewableMenuItems : List (MenuItem item)
    , disabled : Bool
    }


viewMenuItems : ViewMenuItemsData item -> List ( String, Html (Msg item) )
viewMenuItems data =
    List.indexedMap
        (buildMenuItem
            (BuildMenuItemData data.menuItemStyles
                data.selectId
                data.variant
                data.initialMousedown
                data.activeTargetIndex
                data.menuNavigation
                data.disabled
            )
        )
        data.viewableMenuItems


viewMenuItem : ViewMenuItemData item -> List (Html (Msg item)) -> Html (Msg item)
viewMenuItem data content =
    let
        resolveMouseLeave =
            if data.isClickFocused then
                [ on "mouseleave" <| Decode.succeed ClearFocusedItem ]

            else
                []

        resolveMouseUpMsg =
            case data.variant of
                Multi _ ->
                    SelectedItemMulti (getMenuItemItem data.menuItem)

                _ ->
                    SelectedItem (getMenuItemItem data.menuItem)

        resolveMouseUp =
            case data.initialMousedown of
                Internal.MenuItemMousedown _ ->
                    [ on "mouseup" <| Decode.succeed resolveMouseUpMsg ]

                _ ->
                    []

        resolveDataTestId =
            if data.menuItemIsTarget then
                [ attribute "data-test-id" ("listBoxItemTargetFocus" ++ String.fromInt data.index) ]

            else
                []

        resolveSelectedAriaAttribs =
            if data.itemSelected then
                [ ariaSelected "true" ]

            else
                [ ariaSelected "false" ]

        resolvePosinsetAriaAttrib =
            [ attribute "aria-posinset" (String.fromInt <| data.index + 1) ]

        allEvents =
            if data.disabled then
                []

            else
                [ preventDefaultOn "mousedown" <| Decode.map (\msg -> ( msg, True )) <| Decode.succeed (MenuItemClickFocus data.index)
                , on "mouseover" <| Decode.succeed (HoverFocused data.index)
                ]
                    ++ resolveMouseLeave
                    ++ resolveMouseUp
    in
    li
        ([ role "option"
         , tabindex -1
         , id (menuItemId data.selectId data.index)
         , StyledAttribs.css
            (menuItemContainerStyles data)
         ]
            ++ resolveDataTestId
            ++ resolveSelectedAriaAttribs
            ++ resolvePosinsetAriaAttrib
            ++ allEvents
        )
        content


type alias ViewPlaceholderData =
    { placeholderOpac : Float
    , placeholder : String
    }


viewPlaceholder : ViewPlaceholderData -> Html msg
viewPlaceholder data =
    div
        [ StyledAttribs.css
            (placeholderStyles data.placeholderOpac)
        ]
        [ text data.placeholder ]


viewSelectedPlaceholder : Styles.ControlConfig -> MenuItem item -> Html msg
viewSelectedPlaceholder styles item =
    let
        addedStyles =
            [ Css.maxWidth (Css.calc (Css.pct 100) Css.minus (Css.px 8))
            , Css.textOverflow Css.ellipsis
            , Css.whiteSpace Css.noWrap
            , Css.overflow Css.hidden
            , Css.color (Styles.getControlSelectedColor styles)
            , Css.fontWeight (Css.int 400)
            ]
    in
    div
        [ StyledAttribs.css
            (basePlaceholderStyles
                ++ addedStyles
            )
        , attribute "data-test-id" "selectedItem"
        ]
        [ text (getMenuItemLabel item) ]


type alias ViewSelectInputData item =
    { maybeActiveTarget : Maybe (MenuItem item)
    , totalViewableMenuItems : Int
    , variant : CustomVariant item
    , labelledBy : Maybe String
    , ariaDescribedBy : Maybe String
    , disabled : Bool
    , clearable : Bool
    , state : SelectState
    }


viewSelectInput : ViewSelectInputData item -> Html (Msg item)
viewSelectInput data =
    let
        (SelectId selectId) =
            data.state.selectId

        resolveEnterMsg mi =
            case data.variant of
                Multi _ ->
                    EnterSelectMulti mi

                _ ->
                    EnterSelect mi

        tabKeydownDecoder decoders =
            case data.variant of
                SingleMenu _ ->
                    Events.isTab (OnMenuInputTabbed clearButtonVisible) :: decoders

                _ ->
                    decoders

        enterKeydownDecoder =
            -- there will always be a target item if the menu is
            -- open and not empty
            case data.maybeActiveTarget of
                Just mi ->
                    [ Events.isEnter (resolveEnterMsg mi) ]

                Nothing ->
                    []

        resolveInputValue =
            Maybe.withDefault "" data.state.inputValue

        spaceKeydownDecoder decoders =
            if canBeSpaceToggled data.state.menuOpen data.state.inputValue then
                Events.isSpace ToggleMenuAtKey :: decoders

            else
                decoders

        whenArrowEvents =
            if data.state.menuOpen && 0 == data.totalViewableMenuItems then
                []

            else
                [ Events.isDownArrow (KeyboardDown data.totalViewableMenuItems)
                , Events.isUpArrow (KeyboardUp data.totalViewableMenuItems)
                ]

        resolveInputWidth selectInputConfig =
            if data.state.jsOptimize then
                SelectInput.inputSizing
                    (SelectInput.DynamicJsOptimized
                        (data.state.controlUiFocused == Just Internal.ControlInput)
                    )
                    selectInputConfig

            else
                SelectInput.inputSizing SelectInput.Dynamic selectInputConfig

        resolveAriaActiveDescendant config =
            case data.maybeActiveTarget of
                Just _ ->
                    SelectInput.activeDescendant (menuItemId data.state.selectId data.state.activeTargetIndex) config

                _ ->
                    config

        resolveAriaControls config =
            SelectInput.setAriaControls (menuListId data.state.selectId) config

        resolveAriaLabelledBy config =
            case data.labelledBy of
                Just s ->
                    SelectInput.setAriaLabelledBy s config

                _ ->
                    config

        resolveAriaDescribedBy config =
            case data.ariaDescribedBy of
                Just s ->
                    SelectInput.setAriaDescribedBy s config

                _ ->
                    config

        resolveAriaExpanded config =
            SelectInput.setAriaExpanded data.state.menuOpen config

        clearButtonVisible =
            showClearButton
                (ShowClearButtonData
                    data.variant
                    data.disabled
                    data.clearable
                    data.state
                )

        preventDefault msg =
            case msg of
                OnMenuInputTabbed _ ->
                    ( msg, False )

                _ ->
                    ( msg, True )

        stopProp =
            case data.variant of
                SingleMenu _ ->
                    \msg -> ( msg, True )

                _ ->
                    \msg -> ( msg, False )
    in
    SelectInput.view
        (SelectInput.default
            |> SelectInput.onInput InputChanged
            |> SelectInput.onBlurMsg (OnInputBlurred (CustomVariant data.variant))
            |> SelectInput.onFocusMsg
                (InputReceivedFocused
                    (CustomVariant data.variant)
                )
            |> SelectInput.currentValue resolveInputValue
            |> SelectInput.onMousedown ( InputMousedowned, stopProp )
            |> resolveInputWidth
            |> resolveAriaActiveDescendant
            |> resolveAriaControls
            |> resolveAriaLabelledBy
            |> resolveAriaDescribedBy
            |> resolveAriaExpanded
            |> (SelectInput.preventKeydownOn <|
                    ( (enterKeydownDecoder
                        |> spaceKeydownDecoder
                        |> tabKeydownDecoder
                      )
                        ++ (Events.isEscape InputEscape
                                :: whenArrowEvents
                           )
                    , preventDefault
                    )
               )
        )
        selectId


type alias ViewDummyInputData item =
    { id : String
    , variant : CustomVariant item
    , maybeTargetItem : Maybe (MenuItem item)
    , totalViewableMenuItems : Int
    , menuOpen : Bool
    , labelledBy : Maybe String
    , ariaDescribedBy : Maybe String
    , disabled : Bool
    , clearable : Bool
    , state : SelectState
    }


viewDummyInput : ViewDummyInputData item -> Html (Msg item)
viewDummyInput data =
    let
        whenEnterEvent =
            -- there will always be a target item if the menu is
            -- open and not empty
            case data.maybeTargetItem of
                Just menuItem ->
                    [ Events.isEnter (EnterSelect menuItem) ]

                Nothing ->
                    []

        whenArrowEvents =
            if data.menuOpen && 0 == data.totalViewableMenuItems then
                []

            else
                [ Events.isDownArrow (KeyboardDown data.totalViewableMenuItems)
                , Events.isUpArrow (KeyboardUp data.totalViewableMenuItems)
                ]

        withLabelledBy =
            case data.labelledBy of
                Just s ->
                    [ Aria.ariaLabelledby s ]

                _ ->
                    []

        withAriaDescribedBy =
            case data.ariaDescribedBy of
                Just s ->
                    [ Aria.ariaDescribedby s ]

                _ ->
                    []
    in
    input
        ([ style "label" "dummyinput"
         , style "background" "0"
         , style "position" "absolute"
         , style "border" "0"
         , style "font-size" "inherit"
         , style "outline" "0"
         , style "padding" "0"
         , style "width" "1px"
         , style "color" "transparent"
         , readonly True
         , value ""
         , tabindex 0
         , attribute "data-test-id" "dummyInputSelect"
         , id data.id
         , onFocus (InputReceivedFocused (CustomVariant data.variant))
         , onBlur (OnInputBlurred (CustomVariant data.variant))
         , preventDefaultOn "keydown" <|
            Decode.map
                (\msg -> ( msg, True ))
                (Decode.oneOf
                    ([ Events.isSpace ToggleMenuAtKey
                     , Events.isEscape CloseMenu
                     ]
                        ++ whenEnterEvent
                        ++ whenArrowEvents
                    )
                )
         ]
            ++ withLabelledBy
            ++ withAriaDescribedBy
        )
        []


viewMultiValue : Internal.InitialMousedown -> Styles.ControlConfig -> Int -> MenuItem item -> Html (Msg item)
viewMultiValue mousedownedItem styles index menuItem =
    let
        isMousedowned =
            case mousedownedItem of
                Internal.MultiItemMousedown i ->
                    i == index

                _ ->
                    False

        resolveMouseleave tagConfig =
            if isMousedowned then
                Tag.onMouseleave ClearFocusedItem tagConfig

            else
                tagConfig

        resolveVariant =
            Tag.default
    in
    Tag.view
        (resolveVariant
            |> Tag.onDismiss (DeselectedMultiItem (getMenuItemItem menuItem))
            |> Tag.onMousedown (MultiItemFocus index)
            |> Tag.rightMargin True
            |> Tag.dataTestId ("multiSelectTag" ++ String.fromInt index)
            |> Tag.setControlStyles styles
            |> resolveMouseleave
        )
        (getMenuItemLabel menuItem)


menuItemId : SelectId -> Int -> String
menuItemId (SelectId id_) index =
    "select-menu-item-" ++ String.fromInt index ++ "-" ++ id_


menuListId : SelectId -> String
menuListId (SelectId id_) =
    "select-menu-list-" ++ id_


getSelectId : State -> String
getSelectId (State { selectId }) =
    let
        (SelectId idString) =
            selectId
    in
    idString



-- CHECKERS


isMenuItemFilterable : MenuItem item -> Bool
isMenuItemFilterable mi =
    case mi of
        Basic obj ->
            obj.filterable

        Custom obj ->
            obj.filterable


isSelected : MenuItem item -> Maybe (MenuItem item) -> Bool
isSelected menuItem maybeSelectedItem =
    case maybeSelectedItem of
        Just item ->
            getMenuItemItem item == getMenuItemItem menuItem

        Nothing ->
            False


isMenuItemClickFocused : Internal.InitialMousedown -> Int -> Bool
isMenuItemClickFocused initialMousedown i =
    case initialMousedown of
        Internal.MenuItemMousedown int ->
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



-- UTILS


type alias BuildPlaceholderData item =
    { variant : CustomVariant item
    , state : SelectState
    , controlStyles : Styles.ControlConfig
    , placeholder : String
    }


buildPlaceholder : BuildPlaceholderData item -> Html msg
buildPlaceholder data =
    if isEmptyInputValue data.state.inputValue then
        case data.variant of
            Multi [] ->
                viewPlaceholder
                    (ViewPlaceholderData
                        (Styles.getControlPlaceholderOpacity data.controlStyles)
                        data.placeholder
                    )

            -- Multi selected values render differently
            Multi _ ->
                text ""

            Single (Just v) ->
                viewSelectedPlaceholder data.controlStyles v

            Single Nothing ->
                viewPlaceholder
                    (ViewPlaceholderData
                        (Styles.getControlPlaceholderOpacity data.controlStyles)
                        data.placeholder
                    )

            SingleMenu _ ->
                viewPlaceholder
                    (ViewPlaceholderData
                        (Styles.getControlPlaceholderOpacity data.controlStyles)
                        data.placeholder
                    )

    else
        text ""


clearableId : SelectId -> String
clearableId (SelectId id_) =
    id_ ++ "__Clearable"


type alias ShowClearButtonData item =
    { variant : CustomVariant item
    , disabled : Bool
    , clearable : Bool
    , state : SelectState
    }


showClearButton : ShowClearButtonData item -> Bool
showClearButton data =
    if data.clearable && not data.disabled then
        case data.variant of
            Single (Just _) ->
                True

            SingleMenu _ ->
                case data.state.inputValue of
                    Just "" ->
                        False

                    Just _ ->
                        True

                    _ ->
                        False

            _ ->
                False

    else
        False


resetState : State -> State
resetState (State state_) =
    State
        { state_
            | menuOpen = False
            , activeTargetIndex = 0
            , menuViewportFocusNodes = Nothing
            , menuListScrollTop = 0
            , menuNavigation = Mouse
            , headlessEvent = Nothing
        }


enterSelectTargetItem : SelectState -> List (MenuItem item) -> Maybe (MenuItem item)
enterSelectTargetItem state_ viewableMenuItems =
    if state_.menuOpen && not (List.isEmpty viewableMenuItems) then
        ListExtra.getAt state_.activeTargetIndex viewableMenuItems

    else
        Nothing


type alias BuildViewableMenuItemsData item =
    { searchable : Bool
    , inputValue : Maybe String
    , menuItems : List (MenuItem item)
    , variant : Variant item
    }


buildViewableMenuItems : BuildViewableMenuItemsData item -> List (MenuItem item)
buildViewableMenuItems data =
    let
        filteredMenuItems =
            case ( data.searchable, data.inputValue ) of
                ( True, Just value ) ->
                    if String.isEmpty value then
                        data.menuItems

                    else
                        List.filter (filterMenuItem value) data.menuItems

                _ ->
                    data.menuItems
    in
    case data.variant of
        CustomVariant (Single _) ->
            filteredMenuItems

        CustomVariant (Multi maybeSelectedMenuItems) ->
            filteredMenuItems
                |> filterMultiSelectedItems maybeSelectedMenuItems

        CustomVariant (SingleMenu _) ->
            filteredMenuItems

        _ ->
            []


type alias BuildMenuItemData item =
    { menuItemStyles : Styles.MenuItemConfig
    , selectId : SelectId
    , variant : CustomVariant item
    , initialMousedown : Internal.InitialMousedown
    , activeTargetIndex : Int
    , menuNavigation : MenuNavigation
    , disabled : Bool
    }


buildMenuItem :
    BuildMenuItemData item
    -> Int
    -> MenuItem item
    -> ( String, Html (Msg item) )
buildMenuItem data idx item =
    case item of
        Basic _ ->
            case data.variant of
                Single maybeSelectedItem ->
                    ( getMenuItemLabel item
                    , lazy2 viewMenuItem
                        (ViewMenuItemData
                            idx
                            (isSelected item maybeSelectedItem)
                            (isMenuItemClickFocused data.initialMousedown idx)
                            (isTarget data.activeTargetIndex idx)
                            data.selectId
                            item
                            data.menuNavigation
                            data.initialMousedown
                            data.variant
                            data.menuItemStyles
                            data.disabled
                        )
                        [ text (getMenuItemLabel item) ]
                    )

                SingleMenu maybeSelectedItem ->
                    ( getMenuItemLabel item
                    , lazy2 viewMenuItem
                        (ViewMenuItemData
                            idx
                            (isSelected item maybeSelectedItem)
                            (isMenuItemClickFocused data.initialMousedown idx)
                            (isTarget data.activeTargetIndex idx)
                            data.selectId
                            item
                            data.menuNavigation
                            data.initialMousedown
                            data.variant
                            data.menuItemStyles
                            data.disabled
                        )
                        [ text (getMenuItemLabel item) ]
                    )

                -- We don't render selected multi select variant options
                _ ->
                    ( getMenuItemLabel item
                    , lazy2 viewMenuItem
                        (ViewMenuItemData
                            idx
                            False
                            (isMenuItemClickFocused data.initialMousedown idx)
                            (isTarget data.activeTargetIndex idx)
                            data.selectId
                            item
                            data.menuNavigation
                            data.initialMousedown
                            data.variant
                            data.menuItemStyles
                            data.disabled
                        )
                        [ text (getMenuItemLabel item) ]
                    )

        Custom ci ->
            case data.variant of
                Single maybeSelectedItem ->
                    ( getMenuItemLabel item
                    , lazy2 viewMenuItem
                        (ViewMenuItemData
                            idx
                            (isSelected item maybeSelectedItem)
                            (isMenuItemClickFocused data.initialMousedown idx)
                            (isTarget data.activeTargetIndex idx)
                            data.selectId
                            item
                            data.menuNavigation
                            data.initialMousedown
                            data.variant
                            data.menuItemStyles
                            data.disabled
                        )
                        [ Styled.map never ci.view ]
                    )

                _ ->
                    ( getMenuItemLabel item
                    , lazy2 viewMenuItem
                        (ViewMenuItemData
                            idx
                            False
                            (isMenuItemClickFocused data.initialMousedown idx)
                            (isTarget data.activeTargetIndex idx)
                            data.selectId
                            item
                            data.menuNavigation
                            data.initialMousedown
                            data.variant
                            data.menuItemStyles
                            data.disabled
                        )
                        [ Styled.map never ci.view ]
                    )


filterMenuItem : String -> MenuItem item -> Bool
filterMenuItem query item =
    String.contains (String.toLower query) (String.toLower (getMenuItemLabel item))
        || not (isMenuItemFilterable item)


filterMultiSelectedItems : List (MenuItem item) -> List (MenuItem item) -> List (MenuItem item)
filterMultiSelectedItems selectedItems currentMenuItems =
    if List.isEmpty selectedItems then
        currentMenuItems

    else
        List.filter
            (\i ->
                not
                    (List.any (\si -> getMenuItemItem i == getMenuItemItem si) selectedItems)
            )
            currentMenuItems


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
    Task.attempt FocusMenuViewport <|
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


basePlaceholderStyles : List Css.Style
basePlaceholderStyles =
    [ Css.property "margin-inline-start" (Css.px 2).value
    , Css.marginRight (Css.px 2)
    , Css.top (Css.pct 50)
    , Css.position Css.absolute
    , Css.boxSizing Css.borderBox
    , Css.transform (Css.translateY (Css.pct -50))
    ]


placeholderStyles : Float -> List Css.Style
placeholderStyles opac =
    Css.opacity (Css.num opac) :: basePlaceholderStyles



-- ICONS


viewLoading : Html msg
viewLoading =
    DotLoadingIcon.view


type alias ClearIndicatorData item =
    { disabled : Bool
    , indicatorColor : Css.Color
    , indicatorColorHover : Css.Color
    , variant : CustomVariant item
    , selectId : SelectId
    }


clearIndicator : ClearIndicatorData item -> Html (Msg item)
clearIndicator data =
    let
        resolveIconButtonStyles =
            if data.disabled then
                [ Css.height (Css.px 16) ]

            else
                [ Css.height (Css.px 16), Css.cursor Css.pointer ]

        resolveTab =
            case data.variant of
                SingleMenu _ ->
                    [ Events.isTabWithShift OnMenuClearableShiftTabbed ]

                _ ->
                    []

        withMenuBlur =
            case data.variant of
                SingleMenu _ ->
                    [ onBlur OnMenuClearableBlurred
                    ]

                _ ->
                    []

        preventDefault msg =
            case msg of
                OnMenuClearableShiftTabbed _ ->
                    ( msg, True )

                _ ->
                    ( msg, False )
    in
    button
        ([ attribute "data-test-id" "clear"
         , type_ "button"
         , id (clearableId data.selectId)
         , custom "mousedown" <|
            Decode.map (\msg -> { message = msg, stopPropagation = True, preventDefault = True }) <|
                Decode.succeed (ClearButtonMouseDowned data.variant)
         , StyledAttribs.css (resolveIconButtonStyles ++ iconButtonStyles)
         , preventDefaultOn "keydown"
            (Decode.map preventDefault <|
                Decode.oneOf
                    ([ Events.isSpace (ClearButtonKeyDowned data.variant)
                     , Events.isEnter (ClearButtonKeyDowned data.variant)
                     ]
                        ++ resolveTab
                    )
            )
         ]
            ++ withMenuBlur
        )
        [ span
            [ StyledAttribs.css
                [ Css.color data.indicatorColor
                , Css.displayFlex
                , Css.hover [ Css.color data.indicatorColorHover ]
                ]
            ]
            [ ClearIcon.view
            ]
        ]


indicatorSeparator : Styles.ControlConfig -> Html msg
indicatorSeparator styles =
    span
        [ StyledAttribs.css
            [ Css.alignSelf Css.stretch
            , Css.backgroundColor (Styles.getControlSeparatorColor styles)
            , Css.marginBottom (Css.px 8)
            , Css.marginTop (Css.px 8)
            , Css.width (Css.px 1)
            , Css.boxSizing Css.borderBox
            ]
        ]
        []


dropdownIndicator : Styles.ControlConfig -> Bool -> Html msg
dropdownIndicator styles disabledInput =
    let
        resolveIconButtonStyles =
            if disabledInput then
                [ Css.height (Css.px 20)
                ]

            else
                [ Css.height (Css.px 20)
                , Css.cursor Css.pointer
                , Css.color (Styles.getControlDropdownIndicatorColor styles)
                , Css.hover [ Css.color (Styles.getControlDropdownIndicatorColorHover styles) ]
                ]
    in
    span
        [ StyledAttribs.css [ Css.displayFlex, Css.batch resolveIconButtonStyles ] ]
        [ DropdownIcon.view ]



-- STYLES


menuWrapperStyles : Styles.MenuConfig -> List Css.Style
menuWrapperStyles menuStyles =
    [ Css.paddingBottom (Css.px listBoxPaddingBottom)
    , Css.paddingTop (Css.px listBoxPaddingTop)
    , Css.boxSizing Css.borderBox
    , Css.top (Css.pct 100)
    , Css.backgroundColor (Styles.getMenuBackgroundColor menuStyles)
    , Css.position Css.absolute
    , Css.width (Css.pct 100)
    , Css.boxSizing Css.borderBox
    , Css.borderRadius (Css.px (Styles.getMenuBorderRadius menuStyles))
    , Css.boxShadow4
        (Css.px <| Styles.getMenuBoxShadowHOffset menuStyles)
        (Css.px <| Styles.getMenuBoxShadowVOffset menuStyles)
        (Css.px <| Styles.getMenuBoxShadowBlur menuStyles)
        (Styles.getMenuBoxShadowColor menuStyles)
    , Css.marginTop (Css.px menuMarginTop)
    , Css.zIndex (Css.int 2)
    ]


menuWrapperBorderStyle : List Css.Style
menuWrapperBorderStyle =
    [ Css.border3 (Css.px listBoxBorder) Css.solid Css.transparent
    ]


menuListStyles : List Css.Style
menuListStyles =
    menuWrapperBorderStyle
        ++ [ Css.maxHeight (Css.px 215)
           , Css.overflowY Css.auto
           , Css.paddingLeft (Css.px 0)
           , Css.marginBottom (Css.px 8)
           ]


type alias ViewMenuItemData item =
    { index : Int
    , itemSelected : Bool
    , isClickFocused : Bool
    , menuItemIsTarget : Bool
    , selectId : SelectId
    , menuItem : MenuItem item
    , menuNavigation : MenuNavigation
    , initialMousedown : Internal.InitialMousedown
    , variant : CustomVariant item
    , menuItemStyles : Styles.MenuItemConfig
    , disabled : Bool
    }


menuItemContainerStyles : ViewMenuItemData item -> List Css.Style
menuItemContainerStyles data =
    let
        withTargetStyles =
            if data.menuItemIsTarget && not data.itemSelected then
                [ Css.color (Styles.getMenuItemColorHoverNotSelected data.menuItemStyles)
                , Css.backgroundColor (Styles.getMenuItemBackgroundColorNotSelected data.menuItemStyles)
                ]

            else
                []

        withIsClickedStyles =
            if data.isClickFocused then
                [ Css.backgroundColor (Styles.getMenuItemBackgroundColorClicked data.menuItemStyles) ]

            else
                []

        withIsSelectedStyles =
            if data.itemSelected then
                [ Css.backgroundColor (Styles.getMenuItemBackgroundColorSelected data.menuItemStyles)
                , Css.hover [ Css.color (Styles.getMenuItemColorHoverSelected data.menuItemStyles) ]
                ]

            else
                []

        allStyles =
            if data.disabled then
                [ controlDisabled 0.3 ]

            else
                withTargetStyles
                    ++ withIsClickedStyles
                    ++ withIsSelectedStyles
    in
    [ Css.cursor Css.default
    , Css.display Css.block
    , Css.fontSize Css.inherit
    , Css.width (Css.pct 100)
    , Css.property "user-select" "none"
    , Css.boxSizing Css.borderBox
    , Css.borderRadius (Css.px (Styles.getMenuItemBorderRadius data.menuItemStyles))
    , Css.padding2 (Css.px (Styles.getMenuItemBlockPadding data.menuItemStyles)) (Css.px (Styles.getMenuItemInlinePadding data.menuItemStyles))
    , Css.outline Css.none
    , Css.color (Styles.getMenuItemColor data.menuItemStyles)
    , Css.batch allStyles
    ]


indicatorContainerStyles : List Css.Style
indicatorContainerStyles =
    [ Css.displayFlex, Css.boxSizing Css.borderBox, Css.padding (Css.px 8) ]


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


listBoxPaddingBottom : Float
listBoxPaddingBottom =
    6


listBoxPaddingTop : Float
listBoxPaddingTop =
    4


listBoxBorder : Float
listBoxBorder =
    6


menuControlStyles : Styles.MenuConfig -> SelectState -> Bool -> List Css.Style
menuControlStyles styles state_ dsb =
    let
        controlFocusedStyles =
            case state_.controlUiFocused of
                Just _ ->
                    [ controlBorderFocused (Styles.getMenuControlBorderColorFocus styles) ]

                _ ->
                    []
    in
    [ Css.alignItems Css.center
    , Css.backgroundColor (Styles.getMenuControlBackgroundColor styles)
    , Css.color (Styles.getMenuControlColor styles)
    , Css.cursor Css.default
    , Css.displayFlex
    , Css.flexWrap Css.wrap
    , Css.justifyContent Css.spaceBetween
    , Css.minHeight (Css.px (Styles.getMenuControlMinHeight styles))
    , Css.position Css.relative
    , Css.boxSizing Css.borderBox
    , controlBorder (Styles.getMenuControlBorderColor styles)
    , controlRadius (Styles.getMenuControlBorderRadius styles)
    , Css.outline Css.zero
    , if dsb then
        controlDisabled (Styles.getMenuControlDisabledOpacity styles)

      else
        controlHover (ControlHoverData (Styles.getMenuControlBackgroundColor styles) (Styles.getMenuControlBorderColor styles))
    ]
        ++ controlFocusedStyles


controlStyles : Styles.ControlConfig -> SelectState -> Bool -> List Css.Style
controlStyles styles state_ dsb =
    let
        controlFocusedStyles =
            case state_.controlUiFocused of
                Just Internal.ControlInput ->
                    [ controlBorderFocused (Styles.getControlBorderColorFocus styles) ]

                _ ->
                    []
    in
    [ Css.alignItems Css.center
    , Css.backgroundColor (Styles.getControlBackgroundColor styles)
    , Css.color (Styles.getControlColor styles)
    , Css.cursor Css.default
    , Css.displayFlex
    , Css.flexWrap Css.wrap
    , Css.justifyContent Css.spaceBetween
    , Css.minHeight (Css.px (Styles.getControlMinHeight styles))
    , Css.position Css.relative
    , Css.boxSizing Css.borderBox
    , controlBorder (Styles.getControlBorderColor styles)
    , controlRadius (Styles.getControlBorderRadius styles)
    , Css.outline Css.zero
    , if dsb then
        controlDisabled (Styles.getControlDisabledOpacity styles)

      else
        controlHover
            (ControlHoverData
                (Styles.getControlBackgroundColorHover styles)
                (Styles.getControlBorderColor styles)
            )
    ]
        ++ controlFocusedStyles


controlRadius : Float -> Css.Style
controlRadius rad =
    Css.borderRadius <| Css.px rad


controlBorder : Css.Color -> Css.Style
controlBorder cb =
    Css.border3 (Css.px 2) Css.solid cb


controlBorderFocused : Css.Color -> Css.Style
controlBorderFocused bcf =
    Css.borderColor bcf


controlDisabled : Float -> Css.Style
controlDisabled dsbOpac =
    Css.opacity (Css.num dsbOpac)


type alias ControlHoverData =
    { backgroundColorHover : Css.Color
    , borderColor : Css.Color
    }


controlHover : ControlHoverData -> Css.Style
controlHover styles =
    Css.hover
        [ Css.backgroundColor styles.backgroundColorHover
        , Css.borderColor styles.borderColor
        ]
