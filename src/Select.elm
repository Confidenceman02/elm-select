module Select exposing
    ( State, MenuItem, BasicMenuItem, basicMenuItem, CustomMenuItem, customMenuItem, Action(..), initState, Msg, menuItems, placeholder, selectIdentifier, state, update, view, searchable, setStyles
    , single, clearable
    , multi, truncateMultiTag, multiTagColor, initMultiConfig
    , singleNative
    , disabled, labelledBy, ariaDescribedBy, loading, loadingMessage
    , jsOptimize
    )

{-| Select items from a menu list.


# Set up

@docs State, MenuItem, BasicMenuItem, basicMenuItem, CustomMenuItem, customMenuItem, Action, initState, Msg, menuItems, placeholder, selectIdentifier, state, update, view, searchable, setStyles


# Single select

@docs single, clearable


# Multi select

@docs multi, truncateMultiTag, multiTagColor, initMultiConfig


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
import Select.SelectInput as SelectInput
import Select.Styles as Styles
import Select.Tag as Tag
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
    | InputChangedNativeSingle (List (MenuItem item)) Bool Int
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
    | EnterSelect (MenuItem item)
    | EnterSelectMulti (MenuItem item) SelectId
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
    , menuItemStyles : Styles.MenuItemConfig
    }


type alias ViewMenuData item =
    { variant : Variant item
    , selectId : SelectId
    , viewableMenuItems : List (MenuItem item)
    , initialMousedown : InitialMousedown
    , activeTargetIndex : Int
    , menuNavigation : MenuNavigation
    , loading : Bool
    , loadingMessage : String
    , menuStyles : Styles.MenuConfig
    , menuItemStyles : Styles.MenuItemConfig
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
    , ariaDescribedBy : Maybe String
    , jsOptmized : Bool
    , controlUiFocused : Bool
    }


type alias ViewDummyInputData item =
    { id : String
    , maybeTargetItem : Maybe (MenuItem item)
    , totalViewableMenuItems : Int
    , menuOpen : Bool
    , labelledBy : Maybe String
    , ariaDescribedBy : Maybe String
    }


type alias ViewNativeData item =
    { controlStyles : Styles.ControlConfig
    , variant : NativeVariant item
    , menuItems : List (MenuItem item)
    , selectId : SelectId
    , labelledBy : Maybe String
    , ariaDescribedBy : Maybe String
    , placeholder : String
    }


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


{-| -}
type MenuItem item
    = Basic (BasicMenuItem item)
    | Custom (CustomMenuItem item)


{-| A menu item that will be represented in the menu list.

The `item` property is the type representation of the menu item that will be used in an Action.

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
                (selectIdentifier "SingleSelectExample")

Combine this with [basicMenuItem](#basicMenuItem) to create a [MenuItem](#MenuItem)

-}
type alias BasicMenuItem item =
    { item : item
    , label : String
    }


{-| A menu item that will be represented in the menu list by a view you supply.

The `item` property is the type representation of the menu item that will be used in an Action.

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
                (selectIdentifier "SingleSelectExample")

The view you provide will be rendered in a `li` element that is styled according to the value set by [setStyles](#setStyles).

        customMenuItem { item = Hammer, label = "Hammer", view = text "Hammer" }
        => <li>Hammer</>

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
        { selectState = initState
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
    , loadingMessage = "Loading..."
    , state = initState
    , placeholder = "Select..."
    , menuItems = []
    , searchable = True
    , clearable = False
    , disabled = False
    , labelledBy = Nothing
    , ariaDescribedBy = Nothing
    , styles = Styles.default
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



-- MENU ITEM MODIFIERS


{-| Create a [basic](#BasicMenuItem) type of [MenuItem](#MenuItem).

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
    Basic bscItem


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
customMenuItem customItem =
    Custom customItem



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
                    (selectIdentifier "1234")

-}
setStyles : Styles.Config -> Config item -> Config item
setStyles sc (Config config) =
    Config { config | styles = sc }


{-| Renders an input that let's you input text to search for menu items.

        yourView model =
            Html.map SelectMsg <|
                view
                    (single Nothing |> searchable True)
                    (selectIdentifier "1234")

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
          [ basicMenuItem
              { item = SomeValue, label = "Some label" }
          ]

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


{-| Displays when there are no matched menu items and [loading](#loading) is True.

        yourView model =
            Html.map SelectMsg <|
                view
                    (single Nothing |> loadingMessage "Fetching items...")
                    (selectIdentifier "SingleSelectExample")

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
                    (selectIdentifier "SingleSelectExample")
            ]

-}
labelledBy : String -> Config item -> Config item
labelledBy s (Config config) =
    Config { config | labelledBy = Just s }


{-| The ID of element that describes the select.

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
                    (selectIdentifier "SingleSelectExample")
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
    | Native (NativeVariant item)


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
                  (selectIdentifier "1234")

-}
single : Maybe (MenuItem item) -> Config item
single maybeSelectedItem =
    Config { defaults | variant = Single maybeSelectedItem }


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
                  (selectIdentifier "1234")

**Note**

  - The only [Action](#Action) event that will be fired from the native single select is
    the `Select` [Action](#Action). The other actions are not currently supported.

  - Some [Config](#Config) values will not currently take effect when using the single native variant
    i.e. [loading](#loading), [placeholder](#placeholder), [clearable](#clearable), [labelledBy](#labelledBy), [disabled](#disabled)

-}
singleNative : Maybe (MenuItem item) -> Config item
singleNative mi =
    Config { defaults | variant = Native (SingleNative mi) }


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
                    | initialMousedown = NothingMousedown
                    , inputValue = Nothing
                }
            , cmdWithClosedMenu
            )

        EnterSelectMulti menuItem (SelectId id) ->
            let
                inputId =
                    SelectInput.inputId id

                ( _, State stateWithClosedMenu, cmdWithClosedMenu ) =
                    update CloseMenu (State state_)
            in
            ( Just (Select (getMenuItemItem menuItem))
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

        selectWrapper =
            viewWrapper config
                selectId

        controlStyles =
            Styles.getControlConfig config.styles
    in
    selectWrapper
        (case config.variant of
            Native variant ->
                [ viewNative
                    (ViewNativeData controlStyles
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
                    [ dropdownIndicator controlStyles False ]
                ]

            _ ->
                [ -- container
                  let
                    controlFocusedStyles =
                        if state_.controlUiFocused then
                            [ controlBorderFocused controlStyles ]

                        else
                            []
                  in
                  div
                    -- control
                    (StyledAttribs.css
                        ([ Css.alignItems Css.center
                         , Css.backgroundColor (Styles.getControlBackgroundColor controlStyles)
                         , Css.color (Styles.getControlColor controlStyles)
                         , Css.cursor Css.default
                         , Css.displayFlex
                         , Css.flexWrap Css.wrap
                         , Css.justifyContent Css.spaceBetween
                         , Css.minHeight (Css.px controlHeight)
                         , Css.position Css.relative
                         , Css.boxSizing Css.borderBox
                         , controlBorder controlStyles
                         , controlRadius controlStyles
                         , Css.outline Css.zero
                         , if config.disabled then
                            controlDisabled controlStyles

                           else
                            controlHover controlStyles
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
                                    viewSelectedPlaceholder (Styles.getControlConfig config.styles) v

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
                                            config.ariaDescribedBy
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
                                            config.labelledBy
                                            config.ariaDescribedBy
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
                        [ Internal.viewIf clearButtonVisible <| div [ StyledAttribs.css indicatorContainerStyles ] [ clearIndicator config selectId ]
                        , div [ StyledAttribs.css indicatorContainerStyles ]
                            [ span
                                [ StyledAttribs.css
                                    [ Css.color (Styles.getControlLoadingIndicatorColor controlStyles)
                                    , Css.height (Css.px 20)
                                    ]
                                ]
                                [ resolveLoadingSpinner ]
                            ]
                        , indicatorSeparator controlStyles
                        , -- indicatorContainer
                          div
                            [ StyledAttribs.css indicatorContainerStyles ]
                            [ dropdownIndicator controlStyles config.disabled
                            ]
                        ]
                    , Internal.viewIf state_.menuOpen
                        (lazy viewMenu
                            (ViewMenuData
                                config.variant
                                selectId
                                viewableMenuItems
                                state_.initialMousedown
                                state_.activeTargetIndex
                                state_.menuNavigation
                                config.isLoading
                                config.loadingMessage
                                (Styles.getMenuConfig config.styles)
                                (Styles.getMenuItemConfig config.styles)
                            )
                        )
                    ]
                ]
        )


viewNative : ViewNativeData item -> Html (Msg item)
viewNative viewNativeData =
    case viewNativeData.variant of
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
                                [ text ("(" ++ viewNativeData.placeholder ++ ")") ]

                buildList menuItem =
                    option (StyledAttribs.value (getMenuItemLabel menuItem) :: withSelectedOption menuItem) [ text (getMenuItemLabel menuItem) ]

                (SelectId selectId) =
                    viewNativeData.selectId

                withLabelledBy =
                    case viewNativeData.labelledBy of
                        Just s ->
                            [ Aria.ariaLabelledby s ]

                        _ ->
                            []

                withAriaDescribedBy =
                    case viewNativeData.ariaDescribedBy of
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
                ([ id ("native-single-select-" ++ selectId)
                 , StyledAttribs.attribute "data-test-id" "nativeSingleSelect"
                 , StyledAttribs.name "SomeSelect"
                 , Events.onInputAtInt [ "target", "selectedIndex" ] (InputChangedNativeSingle viewNativeData.menuItems hasCurrentSelection)
                 , StyledAttribs.css
                    [ Css.width (Css.pct 100)
                    , Css.height (Css.px controlHeight)
                    , controlRadius viewNativeData.controlStyles
                    , Css.backgroundColor (Styles.getControlBackgroundColor viewNativeData.controlStyles)
                    , controlBorder viewNativeData.controlStyles
                    , Css.padding2 (Css.px 2) (Css.px 8)
                    , Css.property "appearance" "none"
                    , Css.property "-webkit-appearance" "none"
                    , Css.color (Styles.getControlColor viewNativeData.controlStyles)
                    , Css.fontSize (Css.px 16)
                    , Css.focus
                        [ controlBorderFocused viewNativeData.controlStyles, Css.outline Css.none ]
                    , controlHover viewNativeData.controlStyles
                    ]
                 ]
                    ++ withLabelledBy
                    ++ withAriaDescribedBy
                )
                (withPlaceholder :: List.map buildList viewNativeData.menuItems)


viewWrapper : Configuration item -> SelectId -> List (Html (Msg item)) -> Html (Msg item)
viewWrapper config selectId =
    let
        (State state_) =
            config.state

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
            :: (if config.disabled || isNativeVariant config.variant then
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
            , Css.backgroundColor (Styles.getMenuBackgroundColor viewMenuData.menuStyles)
            , Css.marginBottom (Css.px 8)
            , Css.position Css.absolute
            , Css.width (Css.pct 100)
            , Css.boxSizing Css.borderBox
            , Css.border3 (Css.px listBoxBorder) Css.solid Css.transparent
            , Css.borderRadius (Css.px (Styles.getMenuBorderRadius viewMenuData.menuStyles))
            , Css.boxShadow4
                (Css.px <| Styles.getMenuBoxShadowHOffset viewMenuData.menuStyles)
                (Css.px <| Styles.getMenuBoxShadowVOffset viewMenuData.menuStyles)
                (Css.px <| Styles.getMenuBoxShadowBlur viewMenuData.menuStyles)
                (Styles.getMenuBoxShadowColor viewMenuData.menuStyles)
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
                div [ StyledAttribs.css (menuListStyles ++ [ Css.textAlign Css.center, Css.opacity (Css.num 0.5) ]) ]
                    [ text viewMenuData.loadingMessage
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
                    (buildMenuItem
                        viewMenuData.menuItemStyles
                        viewMenuData.selectId
                        viewMenuData.variant
                        viewMenuData.initialMousedown
                        viewMenuData.activeTargetIndex
                        viewMenuData.menuNavigation
                    )
                    viewMenuData.viewableMenuItems
                )


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
                Multi _ _ ->
                    SelectedItemMulti (getMenuItemItem data.menuItem) data.selectId

                _ ->
                    SelectedItem (getMenuItemItem data.menuItem)

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

        resolveSelectedAriaAttribs =
            if data.itemSelected then
                [ ariaSelected "true" ]

            else
                [ ariaSelected "false" ]

        resolvePosinsetAriaAttrib =
            [ attribute "aria-posinset" (String.fromInt <| data.index + 1) ]
    in
    li
        ([ role "option"
         , tabindex -1
         , preventDefaultOn "mousedown" <| Decode.map (\msg -> ( msg, True )) <| Decode.succeed (MenuItemClickFocus data.index)
         , on "mouseover" <| Decode.succeed (HoverFocused data.index)
         , id (menuItemId data.selectId data.index)
         , StyledAttribs.css
            (menuItemContainerStyles data)
         ]
            ++ resolveMouseLeave
            ++ resolveMouseUp
            ++ resolveDataTestId
            ++ resolveSelectedAriaAttribs
            ++ resolvePosinsetAriaAttrib
        )
        content


viewPlaceholder : Configuration item -> Html msg
viewPlaceholder config =
    let
        controlStyles =
            Styles.getControlConfig config.styles
    in
    div
        [ -- baseplaceholder
          StyledAttribs.css
            (placeholderStyles controlStyles)
        ]
        [ text config.placeholder ]


viewSelectedPlaceholder : Styles.ControlConfig -> MenuItem item -> Html msg
viewSelectedPlaceholder controlStyles item =
    let
        addedStyles =
            [ Css.maxWidth (Css.calc (Css.pct 100) Css.minus (Css.px 8))
            , Css.textOverflow Css.ellipsis
            , Css.whiteSpace Css.noWrap
            , Css.overflow Css.hidden
            , Css.color (Styles.getControlSelectedColor controlStyles)
            , Css.fontWeight (Css.int 400)
            ]
    in
    div
        [ StyledAttribs.css
            (basePlaceholder
                ++ addedStyles
            )
        , attribute "data-test-id" "selectedItem"
        ]
        [ text (getMenuItemLabel item) ]


viewSelectInput : ViewSelectInputData item -> Html (Msg item)
viewSelectInput viewSelectInputData =
    let
        selectId =
            getSelectId viewSelectInputData.id

        resolveEnterMsg mi =
            case viewSelectInputData.variant of
                Multi _ _ ->
                    EnterSelectMulti mi (SelectId selectId)

                _ ->
                    EnterSelect mi

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

        resolveAriaDescribedBy config =
            case viewSelectInputData.ariaDescribedBy of
                Just s ->
                    SelectInput.setAriaDescribedBy s config

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
            |> resolveAriaDescribedBy
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
                Just menuItem ->
                    [ Events.isEnter (EnterSelect menuItem) ]

                Nothing ->
                    []

        whenArrowEvents =
            if viewDummyInputData.menuOpen && 0 == viewDummyInputData.totalViewableMenuItems then
                []

            else
                [ Events.isDownArrow (KeyboardDown (SelectId viewDummyInputData.id) viewDummyInputData.totalViewableMenuItems)
                , Events.isUpArrow (KeyboardUp (SelectId viewDummyInputData.id) viewDummyInputData.totalViewableMenuItems)
                ]

        withLabelledBy =
            case viewDummyInputData.labelledBy of
                Just s ->
                    [ Aria.ariaLabelledby s ]

                _ ->
                    []

        withAriaDescribedBy =
            case viewDummyInputData.ariaDescribedBy of
                Just s ->
                    [ Aria.ariaDescribedby s ]

                _ ->
                    []
    in
    input
        ([ style "label" "dummyinput"
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
         , attribute "data-test-id" "dummyInputSelect"
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
            ++ withLabelledBy
            ++ withAriaDescribedBy
        )
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
            |> Tag.onDismiss (DeselectedMultiItem (getMenuItemItem menuItem) selectId)
            |> Tag.onMousedown (MultiItemFocus index)
            |> Tag.rightMargin True
            |> Tag.dataTestId ("multiSelectTag" ++ String.fromInt index)
            |> withTagColor
            |> resolveTruncationWidth
            |> resolveMouseleave
        )
        (getMenuItemLabel menuItem)


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
            getMenuItemItem item == getMenuItemItem menuItem

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


isNativeVariant : Variant item -> Bool
isNativeVariant variant =
    case variant of
        Native _ ->
            True

        _ ->
            False



-- CALC


calculateMenuBoundaries : MenuListElement -> MenuListBoundaries
calculateMenuBoundaries (MenuListElement menuListElem) =
    ( menuListElem.element.y, menuListElem.element.y + menuListElem.element.height )



-- BUILDERS


buildMenuItems : Configuration item -> SelectState -> List (MenuItem item)
buildMenuItems config state_ =
    let
        filteredMenuItems =
            case ( config.searchable, state_.inputValue ) of
                ( True, Just value ) ->
                    if String.isEmpty value then
                        config.menuItems

                    else
                        List.filter (filterMenuItem value) config.menuItems

                _ ->
                    config.menuItems
    in
    case config.variant of
        Single _ ->
            filteredMenuItems

        Multi _ maybeSelectedMenuItems ->
            filteredMenuItems
                |> filterMultiSelectedItems maybeSelectedMenuItems

        _ ->
            []


buildMenuItem :
    Styles.MenuItemConfig
    -> SelectId
    -> Variant item
    -> InitialMousedown
    -> Int
    -> MenuNavigation
    -> Int
    -> MenuItem item
    -> ( String, Html (Msg item) )
buildMenuItem menuItemStyles selectId variant initialMousedown activeTargetIndex menuNavigation idx item =
    case item of
        Basic _ ->
            case variant of
                Single maybeSelectedItem ->
                    ( getMenuItemLabel item
                    , lazy2 viewMenuItem
                        (ViewMenuItemData
                            idx
                            (isSelected item maybeSelectedItem)
                            (isMenuItemClickFocused initialMousedown idx)
                            (isTarget activeTargetIndex idx)
                            selectId
                            item
                            menuNavigation
                            initialMousedown
                            variant
                            menuItemStyles
                        )
                        [ text (getMenuItemLabel item) ]
                    )

                _ ->
                    ( getMenuItemLabel item
                    , lazy2 viewMenuItem
                        (ViewMenuItemData
                            idx
                            False
                            (isMenuItemClickFocused initialMousedown idx)
                            (isTarget activeTargetIndex idx)
                            selectId
                            item
                            menuNavigation
                            initialMousedown
                            variant
                            menuItemStyles
                        )
                        [ text (getMenuItemLabel item) ]
                    )

        Custom ci ->
            case variant of
                Single maybeSelectedItem ->
                    ( getMenuItemLabel item
                    , lazy2 viewMenuItem
                        (ViewMenuItemData
                            idx
                            (isSelected item maybeSelectedItem)
                            (isMenuItemClickFocused initialMousedown idx)
                            (isTarget activeTargetIndex idx)
                            selectId
                            item
                            menuNavigation
                            initialMousedown
                            variant
                            menuItemStyles
                        )
                        [ Styled.map never ci.view ]
                    )

                _ ->
                    ( getMenuItemLabel item
                    , lazy2 viewMenuItem
                        (ViewMenuItemData
                            idx
                            False
                            (isMenuItemClickFocused initialMousedown idx)
                            (isTarget activeTargetIndex idx)
                            selectId
                            item
                            menuNavigation
                            initialMousedown
                            variant
                            menuItemStyles
                        )
                        [ Styled.map never ci.view ]
                    )


filterMenuItem : String -> MenuItem item -> Bool
filterMenuItem query item =
    String.contains (String.toLower query) <| String.toLower (getMenuItemLabel item)


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


placeholderStyles : Styles.ControlConfig -> List Css.Style
placeholderStyles styles =
    Css.opacity (Css.num (Styles.getControlPlaceholderOpacity styles)) :: basePlaceholder



-- ICONS


viewLoading : Html msg
viewLoading =
    DotLoadingIcon.view


clearIndicator : Configuration item -> SelectId -> Html (Msg item)
clearIndicator config id =
    let
        resolveIconButtonStyles =
            if config.disabled then
                [ Css.height (Css.px 16) ]

            else
                [ Css.height (Css.px 16), Css.cursor Css.pointer ]

        controlStyles =
            Styles.getControlConfig config.styles
    in
    button
        [ attribute "data-test-id" "clear"
        , type_ "button"
        , custom "mousedown" <|
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
        [ span
            [ StyledAttribs.css
                [ Css.color <| Styles.getControlClearIndicatorColor controlStyles
                , Css.displayFlex
                , Css.hover [ Css.color (Styles.getControlClearIndicatorColorHover controlStyles) ]
                ]
            ]
            [ ClearIcon.view
            ]
        ]


indicatorSeparator : Styles.ControlConfig -> Html msg
indicatorSeparator controlStyles =
    span
        [ StyledAttribs.css
            [ Css.alignSelf Css.stretch
            , Css.backgroundColor (Styles.getControlSeparatorColor controlStyles)
            , Css.marginBottom (Css.px 8)
            , Css.marginTop (Css.px 8)
            , Css.width (Css.px 1)
            , Css.boxSizing Css.borderBox
            ]
        ]
        []


dropdownIndicator : Styles.ControlConfig -> Bool -> Html msg
dropdownIndicator controlStyles disabledInput =
    let
        resolveIconButtonStyles =
            if disabledInput then
                [ Css.height (Css.px 20)
                ]

            else
                [ Css.height (Css.px 20)
                , Css.cursor Css.pointer
                , Css.color (Styles.getControlDropdownIndicatorColor controlStyles)
                , Css.hover [ Css.color (Styles.getControlDropdownIndicatorColorHover controlStyles) ]
                ]
    in
    span
        [ StyledAttribs.css resolveIconButtonStyles ]
        [ DropdownIcon.view ]



-- STYLES


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
    ]
        ++ withTargetStyles
        ++ withIsClickedStyles
        ++ withIsSelectedStyles


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


controlRadius : Styles.ControlConfig -> Css.Style
controlRadius controlStyles =
    Css.borderRadius <| Css.px (Styles.getControlBorderRadius controlStyles)


controlHeight : Float
controlHeight =
    48


controlBorder : Styles.ControlConfig -> Css.Style
controlBorder controlStyles =
    Css.border3 (Css.px 2) Css.solid (Styles.getControlBorderColor controlStyles)


controlBorderFocused : Styles.ControlConfig -> Css.Style
controlBorderFocused styles =
    Css.borderColor (Styles.getControlBorderColorFocus styles)


controlDisabled : Styles.ControlConfig -> Css.Style
controlDisabled controlStyles =
    Css.opacity (Css.num (Styles.getControlDisabledOpacity controlStyles))


controlHover : Styles.ControlConfig -> Css.Style
controlHover controlStyles =
    Css.hover
        [ Css.backgroundColor (Styles.getControlBackgroundColorHover controlStyles)
        , Css.borderColor (Styles.getControlBorderColorHover controlStyles)
        ]
