module Select exposing
    ( SelectId, Config, State, MenuItem, BasicMenuItem, basicMenuItem, CustomMenuItem, customMenuItem, Group, group, groupedMenuItem, groupStyles, groupView, filterableMenuItem, dismissibleMenuItemTag, stylesMenuItem, valueMenuItem, virtualFixedMenuItems
    , Action(..), ToggleAction(..), initState, keepMenuOpen, focus, isFocused, isMenuOpen, Msg
    , menuItems, menuItemsVirtual, clearable
    , placeholder, selectIdentifier, staticSelectIdentifier, state, update, view, viewVirtual, searchable, setStyles, name, required
    , single, singleVirtual, multiVirtual
    , singleMenu, menu
    , multi
    , singleNative
    , multiNative
    , disabled, labelledBy, ariaDescribedBy, loading, loadingMessage
    , jsOptimize
    )

{-| Select items from a menu list.


# Set up

@docs SelectId, Config, State, MenuItem, BasicMenuItem, basicMenuItem, CustomMenuItem, customMenuItem, Group, group, groupedMenuItem, groupStyles, groupView, filterableMenuItem, dismissibleMenuItemTag, stylesMenuItem, valueMenuItem, virtualFixedMenuItems
@docs Action, ToggleAction, initState, keepMenuOpen, focus, isFocused, isMenuOpen, Msg
@docs menuItems, menuItemsVirtual, clearable
@docs placeholder, selectIdentifier, staticSelectIdentifier, state, update, view, viewVirtual, searchable, setStyles, name, required


# Single select

@docs single, singleVirtual, multiVirtual


# Menu select

@docs singleMenu, menu


# Multi select

@docs multi


# Native Single select

@docs singleNative


# Native Multi select

@docs multiNative


# Common

@docs disabled, labelledBy, ariaDescribedBy, loading, loadingMessage


# Advanced

@docs jsOptimize

-}

import Array
import Browser.Dom as Dom
import Css
import Dict
import Html.Styled as Styled exposing (Html, button, div, input, li, optgroup, option, select, span, text)
import Html.Styled.Attributes as StyledAttribs exposing (attribute, id, readonly, style, tabindex, type_, value)
import Html.Styled.Events exposing (custom, on, onBlur, onFocus, preventDefaultOn)
import Html.Styled.Keyed as Keyed
import Html.Styled.Lazy exposing (lazy, lazy4)
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
type Config item items
    = Config (Configuration item items)


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
    | InputChangedNativeSingle (MenuItems item) Bool Int
    | InputChangedNativeMulti (MenuItems item) (List Int)
    | InputReceivedFocused (Variant item)
    | SelectedItem item
    | SelectedItemMulti item
    | DeselectedMultiItem item
    | SearchableSelectContainerClicked (CustomVariant item)
    | UnsearchableSelectContainerClicked
    | ToggleMenuAtKey
    | OnInputFocused (Result Dom.Error ())
    | OnInputBlurred (Variant item)
      -- MENU
    | OnMenuClearableFocus (Result Dom.Error ())
    | OnMenuInputTabbed Bool
    | OnMenuClearableShiftTabbed Bool
    | OnMenuClearableBlurred
    | MenuItemClickFocus Int
    | MenuListScrollTop Float
    | OpenMenu
    | CloseMenu
    | FocusMenuViewport (Result Dom.Error ( MenuListElement, MenuItemElement ))
    | FocusMenuViewportTop
    | SetMouseMenuNavigation
      --
    | MultiItemMousedown Int
    | InputMousedowned
    | InputEscape
    | ClearFocusedItem
    | HoverFocused Int
    | EnterSelect (MenuItem item)
    | EnterSelectMulti (MenuItem item)
    | KeyboardDown Int
    | KeyboardUp Int
      -- CLEAR BUTTON
    | ClearButtonMouseDowned (Variant item)
    | ClearButtonKeyDowned (Variant item)
      -- HEADLESS
    | HeadlessMsg HeadlessMsg
      --
    | DoNothing


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

NOTE: Multi native variants use the `SelectBatch` action to determine selections.

-}
type Action item
    = InputChange String
    | Select item
    | SelectBatch (List item)
    | Deselect (List item)
    | Clear
    | FocusSet
    | Focus
    | Blur
    | MenuToggle ToggleAction


{-| Actions reflecting whether a menu will close or open as a result of some [Action](#Action)
-}
type ToggleAction
    = MenuClose
    | MenuOpen


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


type alias Configuration item items =
    { variant : Variant item
    , isLoading : Bool
    , loadingMessage : String
    , state : State
    , menuItems : items
    , searchable : Bool
    , placeholder : String
    , disabled : Bool
    , clearable : Bool
    , labelledBy : Maybe String
    , ariaDescribedBy : Maybe String
    , styles : Styles.Config
    , name : Maybe String
    , required : Bool
    }


type alias SelectState =
    { inputValue : Maybe String
    , menuOpen : Bool
    , keepOpen : Bool
    , initialAction : Internal.InitialAction
    , controlUiFocused : Maybe Internal.UiFocused
    , activeTargetIndex : Int
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
    = Basic (Internal.BaseMenuItem (BasicMenuItem item) Styles.GroupConfig Styles.MenuItemConfig)
    | Custom (Internal.BaseMenuItem (CustomMenuItem item) Styles.GroupConfig Styles.MenuItemConfig)


{-| -}
type alias MenuItems item =
    List (MenuItem item)


type MenuItemsKind item
    = MenuItems_ (MenuItems item)
    | MenuItemsVirtual_ (VirtualConfig item)


{-| -}
type VirtualConfig item
    = FixedSizeMenuItems (VirtualConfiguration item)


type alias VirtualConfiguration item =
    { height : Float
    , overscanCount : Int
    , menuItems : MenuItems item
    }


{-| -}
type Group
    = Group (Internal.Group Styles.GroupConfig)


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


getMenuItemValue : MenuItem item -> Maybe String
getMenuItemValue item =
    case item of
        Basic config ->
            config.value

        Custom config ->
            config.value


isMenuItemDismissible : MenuItem item -> Bool
isMenuItemDismissible item =
    case item of
        Basic config ->
            config.dismissible

        Custom config ->
            config.dismissible



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
        , keepOpen = False
        , initialAction = Internal.NothingMousedown
        , controlUiFocused = Nothing

        -- Always focus the first menu item by default. This facilitates auto selecting the first item on Enter
        , activeTargetIndex = 0
        , menuListScrollTop = 0
        , menuNavigation = Mouse
        , jsOptimize = False
        , selectId = id_
        , headlessEvent = Nothing
        }



-- STATE MODIFIERS


defaultsVirtualVariant : Configuration item (VirtualConfig item)
defaultsVirtualVariant =
    { variant = CustomVariant (Single Nothing)
    , isLoading = False
    , loadingMessage = "Loading..."
    , state = initState (selectIdentifier "elm-select")
    , placeholder = "Select..."
    , menuItems = FixedSizeMenuItems virtualMenuDefaults
    , searchable = True
    , clearable = False
    , disabled = False
    , labelledBy = Nothing
    , ariaDescribedBy = Nothing
    , styles = Styles.default
    , name = Nothing
    , required = False
    }


defaults : Configuration item (List items)
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
    , name = Nothing
    , required = False
    }



-- GROUP MODIFIERS


{-| Create a [MenuItem](#MenuItem) group to provide visual organisation for
your menu items.

Use with [groupedMenuItem](#groupedMenuItem) to add a [MenuItem](#MenuItem)
to a group.

        type Tool
            = Screwdriver
            | Hammer
            | Drill

        toolGroup : Group
        toolGroup =
          group "tool"

        menuItems : List (MenuItem Tool)
        menuItems =
          [ groupedMenuItem toolGroup
                ( basicMenuItem { item = Screwdriver, label = "Screwdriver" } )
          , groupedMenuItem toolGroup
                ( basicMenuItem { item = Hammer, label = "Hammer" } )
          , groupedMenuItem toolGroup
                ( basicMenuItem { item = Drill, label = "Drill" } )
          ]

-}
group : String -> Group
group label =
    Group
        { name = label
        , styles = Nothing
        , view = Nothing
        }


{-| Create custom styling for a [Group](#Group).

This will override global styles for this group when using
[setGroupStyles](/packages/Confidenceman02/elm-select/latest/Select-Styles#setGroupStyles)

        groupStyles : GroupConfig
        groupStyles =
            getGroupConfig default
                |> setGroupColor (Css.hex "#EEEEEE")

        toolGroup : Group
        toolGroup =
          group "tool"
              |> groupStyles groupStyles

        menuItems : List (MenuItem Tool)
        menuItems =
          [ groupedMenuItem toolGroup
                ( basicMenuItem { item = Screwdriver, label = "Screwdriver" } )
          , groupedMenuItem toolGroup
                ( basicMenuItem { item = Hammer, label = "Hammer" } )
          , groupedMenuItem toolGroup
                ( basicMenuItem { item = Drill, label = "Drill" } )
          ]

-}
groupStyles : Styles.GroupConfig -> Group -> Group
groupStyles styles (Group config) =
    Group { config | styles = Just styles }


{-| Create a custom view for a [Group](#Group).

        customView : Html Never
        customView =
          text "My custom group"

        customGroup : Group
        customGroup =
          group "tool"
              |> groupView customView

        menuItems : List (MenuItem Tool)
        menuItems =
          [ groupedMenuItem customGroup
                ( basicMenuItem { item = Screwdriver, label = "Screwdriver" } )
          , groupedMenuItem customGroup
                ( basicMenuItem { item = Hammer, label = "Hammer" } )
          , groupedMenuItem customGroup
                ( basicMenuItem { item = Drill, label = "Drill" } )
          ]

-}
groupView : Html Never -> Group -> Group
groupView c (Group config) =
    Group { config | view = Just c }



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
        , dismissible = True
        , styles = Nothing
        , group = Nothing
        , value = Nothing
        , virtualConfig = Nothing
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
        , dismissible = True
        , styles = Nothing
        , group = Nothing
        , value = Nothing
        , virtualConfig = Nothing
        }


{-| Create a menu with virtual menu items that are a fixed size.

Use with virtual variants such as [singleVirtual](#singleVirtual)

        type Tool
            = Screwdriver
            | Hammer
            | Drill

        virtualMenuItems : List (VirtualConfig Tool)
        virtualMenuItems =
            [ customMenuItem
                { item = Screwdriver, label = "Screwdriver", view = text "Screwdriver" }
            , customMenuItem
                { item = Hammer, label = "Hammer", view = text "Hammer" }
            , customMenuItem
                { item = Drill, label = "Drill", view = text "Drill" }
            ]
                |>  virtualFixedMenuItems 35

-}
virtualFixedMenuItems : Float -> List (MenuItem item) -> VirtualConfig item
virtualFixedMenuItems h items =
    FixedSizeMenuItems { virtualMenuDefaults | menuItems = items, height = h }


{-| Create a grouped [MenuItem](#MenuItem).

        type Tool
            = Screwdriver
            | Hammer
            | Drill

        toolGroup : Group
        toolGroup =
          group "tool"

        menuItems : List (MenuItem Tool)
        menuItems =
            [ groupedMenuItem toolGroup
                  ( customMenuItem
                        { item = Screwdriver
                        , label = "Screwdriver"
                        , view = text "Screwdriver"
                        }
                  )
            , customMenuItem
                { item = Hammer, label = "Hammer", view = text "Hammer" }
            , customMenuItem
                { item = Drill, label = "Drill", view = text "Drill" }
            ]

-}
groupedMenuItem : Group -> MenuItem item -> MenuItem item
groupedMenuItem (Group grp) mi =
    case mi of
        Basic obj ->
            Basic { obj | group = Just grp }

        Custom obj ->
            Custom { obj | group = Just grp }


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


{-| Choose whether a selected menu item tag can produce a `Deselect` action.

This affects the [multi](#multi) Variant and is useful for when
you want a selected tag to not be individually dismissible.

The tag will not render a dismiss button if `False`.

**default:** `True`

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
                |> dismissibleMenuItemTag False
            ]

-}
dismissibleMenuItemTag : Bool -> MenuItem item -> MenuItem item
dismissibleMenuItemTag pred mi =
    case mi of
        Basic obj ->
            Basic { obj | dismissible = pred }

        Custom obj ->
            Custom { obj | dismissible = pred }


{-| Set individual styles for a menu item.

These styles will override any global menu item styles set via
[setStyles](#setStyles).

To set a global style for all menu items use [setStyles](#setStyles).

        import Styles exposing (MenuItemConfig, default, getMenuItemConfig)
        import Css

        type Tool
            = Screwdriver
            | Hammer
            | Drill

        drillStyles : MenuItemConfig
        drillStyles =
            getMenuItemConfig default
                |> setMenuItemColorHoverSelected (Css.hex "#EEEEEE")

        menuItems : List (MenuItem Tool)
        menuItems =
            [ customMenuItem
                { item = Screwdriver, label = "Screwdriver", view = text "Screwdriver" }
            , customMenuItem
                { item = Drill, label = "Drill", view = text "Drill" }
                |> stylesMenuItem drillStyles
            ]

-}
stylesMenuItem : Styles.MenuItemConfig -> MenuItem item -> MenuItem item
stylesMenuItem cfg mi =
    case mi of
        Basic obj ->
            Basic { obj | styles = Just cfg }

        Custom obj ->
            Custom { obj | styles = Just cfg }


{-| Explicitly set the value attribute for the input form control.

This is handy for when you are submitting a form and your server is expecting a `value` that is different
from the label, like a database id.

Take the following selection

      <option value="2" selected>Pagani BC</option>

When a form is submitted the server will see:

      something: "2"

instead of:

      something: "Pagani BC"

By default, the value attribute will be populated with the `MenuItem` label.

      type Tool
          = Screwdriver
          | Hammer
          | Drill

      menuItems : List (MenuItem Tool)
      menuItems =
          [ customMenuItem
              { item = Hammer, label = "Hammer", view = text "Hammer" }
              |> valueMenuItem "2"
          , customMenuItem
              { item = Drill, label = "Drill", view = text "Drill" }
              |> valueMenuItem "3"
          ]

-}
valueMenuItem : String -> MenuItem item -> MenuItem item
valueMenuItem v mi =
    case mi of
        Basic obj ->
            Basic { obj | value = Just v }

        Custom obj ->
            Custom { obj | value = Just v }



-- VIRTUAL MENU MODIFIERS


virtualMenuDefaults : VirtualConfiguration item
virtualMenuDefaults =
    { height = 35
    , overscanCount = 2
    , menuItems = []
    }


{-| Private modifier to set menu items on a virtual menu
-}
setVirtualMenuItems : VirtualConfig item -> MenuItems item -> VirtualConfig item
setVirtualMenuItems c items =
    case c of
        FixedSizeMenuItems config ->
            FixedSizeMenuItems { config | menuItems = items }



-- PRIVATE MENU ITEM MODIFIERS


applyVirtualConfigMenuItem : Int -> Float -> MenuItem item -> MenuItem item
applyVirtualConfigMenuItem idx h item =
    case item of
        Basic i ->
            Basic { i | virtualConfig = Just (Internal.VirtualItemConfig idx h) }

        Custom i ->
            Custom { i | virtualConfig = Just (Internal.VirtualItemConfig idx h) }



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
setStyles : Styles.Config -> Config item items -> Config item items
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
searchable : Bool -> Config item items -> Config item items
searchable pred (Config config) =
    Config { config | searchable = pred }


{-| The text that will appear as an input placeholder.

      yourView model =
          Html.map SelectMsg <|
              view
                  (single Nothing |> placeholder "some placeholder")

-}
placeholder : String -> Config item items -> Config item items
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
state : State -> Config item items -> Config item items
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
              (single Nothing |> menuItems items)

-}
menuItems : MenuItems item -> Config item (MenuItems item) -> Config item (MenuItems item)
menuItems items (Config config) =
    Config { config | menuItems = items }


{-| Turn your menu items to virtual menu items

Used with virtual variants such as [singleVirtual](#singleVirtual)

      items =
          [ basicMenuItem
              { item = SomeValue, label = "Some label" }
          ]

      yourView =
          viewVirtual
              (singleVirtual Nothing
                  |> menuItemsVirtual (virtualFixedMenuItems 35 items)
              )

NOTE: 35 here represents a height in pixels.

-}
menuItemsVirtual : VirtualConfig item -> Config item (VirtualConfig item) -> Config item (VirtualConfig item)
menuItemsVirtual items (Config config) =
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
clearable : Bool -> Config item items -> Config item items
clearable clear (Config config) =
    Config { config | clearable = clear }


{-| Disables the select input so that it cannot be interacted with.

        yourView model =
            Html.map SelectMsg <|
                view
                    (single Nothing |> disabled True)

-}
disabled : Bool -> Config item items -> Config item items
disabled predicate (Config config) =
    Config { config | disabled = predicate }


{-| Displays an animated loading icon to visually represent that menu items are being loaded.

This would be useful if you are loading menu options asynchronously, like from a server.

        yourView model =
            Html.map SelectMsg <|
                view
                    (single Nothing |> loading True)

-}
loading : Bool -> Config item items -> Config item items
loading predicate (Config config) =
    Config { config | isLoading = predicate }


{-| Displays when there are no matched menu items and [loading](#loading) is True.

        yourView model =
            Html.map SelectMsg <|
                view
                    (single Nothing |> loadingMessage "Fetching items...")

-}
loadingMessage : String -> Config item items -> Config item items
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
labelledBy : String -> Config item items -> Config item items
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
ariaDescribedBy : String -> Config item items -> Config item items
ariaDescribedBy s (Config config) =
    Config { config | labelledBy = Just s }


{-| The name attribute of a native select variant

A form will need this attribute to know how to label the data.

    yourView model =
        label
            [ id "selectLabelId" ]
            [ text "Select your country"
            , Html.map SelectMsg <|
                view
                    (singleNative Nothing
                        |> name "country"
                    )
            ]

-}
name : String -> Config item items -> Config item items
name n (Config config) =
    Config { config | name = Just n }


{-| Make the input required within a form context.

Form submissions will fail to submit and you will receive a native prompt when
a select input value has not been selected when required = `True`

Defaults to `False`

    yourView model =
        label
            [ id "selectLabelId" ]
            [ text "Select your country"
            , Html.map SelectMsg <|
                view
                    (singleNative Nothing
                        |> required True
                    )
            ]

-}
required : Bool -> Config item items -> Config item items
required pred (Config config) =
    Config { config | required = pred }



-- STATE MODIFIERS


{-| Keeps the menu open at all times.

Use this with care as all actions that normally close the menu like
selections, or escape, or clicking away will not close it.

-}
keepMenuOpen : Bool -> State -> State
keepMenuOpen pred (State state_) =
    State { state_ | menuOpen = pred, keepOpen = pred }


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
    | NativeVariant (NativeVariant item)


type CustomVariant item
    = Single (Maybe (MenuItem item))
    | SingleVirtual (Maybe (MenuItem item))
    | Multi (MenuItems item)
    | SingleMenu (Maybe (MenuItem item))


type NativeVariant item
    = SingleNative (Maybe (MenuItem item))
    | MultiNative (MenuItems item)


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
single : Maybe (MenuItem item) -> Config item (MenuItems item)
single maybeSelectedItem =
    Config { defaults | variant = CustomVariant (Single maybeSelectedItem) }


{-| Select a single virtual item.

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
              viewVirtual
                  (singleVirtual Nothing |>
                      menuItemsVirtual (virtualFixedMenuItems 35 countries)
                  )

-}
singleVirtual : Maybe (MenuItem item) -> Config item (VirtualConfig item)
singleVirtual maybeSelectedItem =
    Config { defaultsVirtualVariant | variant = CustomVariant (SingleVirtual maybeSelectedItem) }


{-| Select a multi virtual item.

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
              viewVirtual
                  (multiVirtual [] |>
                      menuItemsVirtual (virtualFixedMenuItems 35 countries)
                  )

-}
multiVirtual : MenuItems item -> Config item (VirtualConfig item)
multiVirtual selectedItems =
    Config { defaultsVirtualVariant | variant = CustomVariant (Multi selectedItems) }


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
singleMenu : Maybe (MenuItem item) -> Config item (MenuItems item)
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
menu : Config item (List items)
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
singleNative : Maybe (MenuItem item) -> Config item (MenuItems item)
singleNative mi =
    Config { defaults | variant = NativeVariant (SingleNative mi) }


{-| Select multiple items with a native html [select](https://www.w3schools.com/tags/tag_select.asp) element.

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
                  (multiNative [] |> menuItems countries)

**Note**

  - The only [Action](#Action) event that will be fired from the native multi select is
    the `SelectBatch` [Action](#Action). The other actions are not currently supported.

  - Some [Config](#Config) values will not take effect when using the multi native variant

-}
multiNative : MenuItems item -> Config item (MenuItems item)
multiNative mis =
    Config { defaults | variant = NativeVariant (MultiNative mis) }


{-| Select multiple items.

Selected items will render as tags and be visually removed from the menu list.

    yourView model =
        Html.map SelectMsg <|
            view
                (multi model.selectedCountries
                    |> menuItems model.countries
                )

-}
multi : MenuItems item -> Config item (MenuItems item)
multi selectedItems =
    Config { defaults | variant = CustomVariant (Multi selectedItems) }


{-| The ID for the rendered Select input

NOTE: It is important that the ID's of all selects that exist on
a page remain unique so I add some extra stuff at the end of the String
you provide to help out.

If you don't want this see [staticSelectIdentifier](#staticSelectIdentifier).

Illegal id characters will be replaced with "\_".

    init : State
    init =
        initState (selectIdentifier "someUniqueId")

-}
selectIdentifier : String -> SelectId
selectIdentifier =
    Internal.removeIllegalChars
        >> (\id_ -> SelectId (id_ ++ "__elm-select"))


{-| A static ID for the rendered Select input

The exact string you pass will be the ID used internally.

This is handy when you want a label tags `for` attribute to match the variant id
without needing to remember to add the extra stuff.

See also [selectIdentifier](#selectIdentifier).

Illegal id characters will be replaced with "\_".

    init : State
    init =
        initState (staticSelectIdentifier "someUniqueStaticId")

-}
staticSelectIdentifier : String -> SelectId
staticSelectIdentifier =
    Internal.removeIllegalChars
        >> (\id_ -> SelectId id_)



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

        InputChangedNativeSingle orderedItems hasCurrentSelection selectedOptionIndex ->
            let
                resolveIndex =
                    if hasCurrentSelection then
                        selectedOptionIndex

                    else
                        -- Account for the placeholder item
                        selectedOptionIndex - 1
            in
            case ListExtra.getAt resolveIndex orderedItems of
                Nothing ->
                    ( Nothing, State state_, Cmd.none )

                Just mi ->
                    ( Just <| Select (unwrapItem mi), State state_, Cmd.none )

        InputChangedNativeMulti orderedItems selectedIndices ->
            let
                getItem ix acc =
                    acc
                        ++ (case ListExtra.getAt ix orderedItems of
                                Just i ->
                                    [ Just (unwrapItem i) ]

                                _ ->
                                    [ Nothing ]
                           )

                allSelected =
                    List.filterMap identity <|
                        List.foldl getItem [] selectedIndices
            in
            ( Just (SelectBatch allSelected), State state_, Cmd.none )

        EnterSelect menuItem ->
            let
                ( _, State stateWithClosedMenu, cmdWithClosedMenu ) =
                    update CloseMenu (State state_)
            in
            ( Just (Select (unwrapItem menuItem))
            , State
                { stateWithClosedMenu
                    | initialAction = Internal.NothingMousedown
                    , inputValue = Nothing
                }
            , cmdWithClosedMenu
            )

        EnterSelectMulti menuItem ->
            let
                ( _, State stateWithClosedMenu, cmdWithClosedMenu ) =
                    update CloseMenu (State state_)
            in
            ( Just (Select (unwrapItem menuItem))
            , State
                { stateWithClosedMenu
                    | initialAction = Internal.NothingMousedown
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
                                        , initialAction = Internal.NothingMousedown
                                        , controlUiFocused = Just Internal.ControlInput
                                        , headlessEvent = Nothing
                                      }
                                    )

                                Just FocusingClearableH ->
                                    ( Nothing, { state_ | controlUiFocused = Just Internal.ControlInput } )

                                Nothing ->
                                    ( Just Focus, { state_ | controlUiFocused = Just Internal.ControlInput } )

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
                    | initialAction = Internal.NothingMousedown
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
                    | initialAction = Internal.NothingMousedown
                    , inputValue = Nothing
                }
            , Cmd.batch [ cmdWithClosedMenu, internalFocus idString OnInputFocused ]
            )

        DeselectedMultiItem deselectedItem ->
            ( Just (Deselect [ deselectedItem ])
            , State { state_ | initialAction = Internal.NothingMousedown }
            , internalFocus idString OnInputFocused
            )

        -- focusing the input is usually the last thing that happens after all the mousedown events.
        -- Its important to ensure we have a NothingInitClicked so that if the user clicks outside of the
        -- container it will close the menu and un focus the container. OnInputBlurred treats ContainerInitClick and
        -- MutiItemInitClick as special cases to avoid flickering when an input gets blurred then focused again.
        OnInputFocused focusResult ->
            case focusResult of
                Ok () ->
                    ( Nothing, State { state_ | initialAction = Internal.NothingMousedown }, Cmd.none )

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
                            , initialAction = Internal.NothingMousedown
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
            ( Nothing, State { state_ | menuListScrollTop = newViewportY }, viewportFocusCmd )

        -- If the menu list element was not found it likely has no viewable menu items.
        -- In this case the menu does not render therefore no id is present on menu element.
        FocusMenuViewport (Err _) ->
            ( Nothing, State state_, Cmd.none )

        FocusMenuViewportTop ->
            ( Nothing, State { state_ | menuListScrollTop = 0 }, Cmd.none )

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
                    case state_.initialAction of
                        Internal.ContainerMousedown ->
                            case variant of
                                CustomVariant (SingleMenu _) ->
                                    ( { stateWithClosedMenu
                                        | initialAction = Internal.NothingMousedown
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

                        Internal.NothingMousedown ->
                            ( { stateWithClosedMenu
                                | initialAction = Internal.NothingMousedown
                                , controlUiFocused = Nothing
                                , inputValue = Nothing
                                , activeTargetIndex = 0
                              }
                            , Cmd.batch [ cmdWithClosedMenu, Cmd.none ]
                            , Just Blur
                            )

                        _ ->
                            ( { stateWithClosedMenu
                                | initialAction = Internal.NothingMousedown
                                , controlUiFocused = Nothing
                                , inputValue = Nothing
                                , activeTargetIndex = 0
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
            case state_.initialAction of
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
            ( Nothing, State { state_ | initialAction = Internal.MenuItemMousedown i }, Cmd.none )

        MultiItemMousedown index ->
            ( Nothing, State { state_ | initialAction = Internal.MultiItemMousedown index }, Cmd.none )

        InputMousedowned ->
            ( Nothing, State { state_ | initialAction = Internal.NothingMousedown }, Cmd.none )

        InputEscape ->
            let
                resolveAction =
                    case state_.inputValue of
                        Just "" ->
                            Just (MenuToggle MenuClose)

                        Just _ ->
                            Just (InputChange "")

                        _ ->
                            Just (MenuToggle MenuClose)

                ( _, State stateWithClosedMenu, cmdWithClosedMenu ) =
                    update CloseMenu (State state_)
            in
            ( resolveAction, State { stateWithClosedMenu | inputValue = Nothing }, cmdWithClosedMenu )

        ClearFocusedItem ->
            ( Nothing, State { state_ | initialAction = Internal.NothingMousedown }, Cmd.none )

        SearchableSelectContainerClicked variant ->
            let
                ( _, State stateWithOpenMenu, cmdWithOpenMenu ) =
                    update OpenMenu (State state_)

                ( _, State stateWithClosedMenu, cmdWithClosedMenu ) =
                    update CloseMenu (State state_)

                ( updatedAction, updatedState, updatedCmds ) =
                    case state_.initialAction of
                        -- The MultiItemMousedown will blur the input if it is focused. We want to return
                        -- focus to the input. Might be better to experiment with preventDefault.
                        Internal.MultiItemMousedown _ ->
                            if isFocused wrappedState then
                                ( Nothing, state_, Cmd.none )

                            else
                                ( Nothing, state_, internalFocus idString OnInputFocused )

                        Internal.NothingMousedown ->
                            if state_.menuOpen then
                                case variant of
                                    SingleMenu _ ->
                                        if state_.keepOpen && state_.controlUiFocused == Nothing then
                                            ( Nothing
                                            , { state_ | initialAction = Internal.ContainerMousedown }
                                            , internalFocus idString OnInputFocused
                                            )

                                        else
                                            ( Nothing, { state_ | initialAction = Internal.ContainerMousedown }, Cmd.none )

                                    _ ->
                                        ( Just (MenuToggle MenuClose)
                                        , { stateWithClosedMenu
                                            | initialAction = Internal.ContainerMousedown
                                          }
                                        , Cmd.batch [ cmdWithClosedMenu, internalFocus idString OnInputFocused ]
                                        )

                            else
                                ( Just (MenuToggle MenuOpen)
                                , { stateWithOpenMenu | initialAction = Internal.ContainerMousedown }
                                , Cmd.batch [ cmdWithOpenMenu, internalFocus idString OnInputFocused ]
                                )

                        Internal.ContainerMousedown ->
                            case variant of
                                SingleMenu _ ->
                                    ( Nothing, { state_ | initialAction = Internal.ContainerMousedown }, Cmd.none )

                                _ ->
                                    if state_.menuOpen then
                                        ( Just (MenuToggle MenuClose)
                                        , { stateWithClosedMenu | initialAction = Internal.NothingMousedown }
                                        , Cmd.batch [ cmdWithClosedMenu, internalFocus idString OnInputFocused ]
                                        )

                                    else
                                        ( Just (MenuToggle MenuOpen)
                                        , { stateWithOpenMenu | initialAction = Internal.NothingMousedown }
                                        , Cmd.batch [ cmdWithOpenMenu, internalFocus idString OnInputFocused ]
                                        )

                        _ ->
                            if state_.menuOpen then
                                ( Nothing, stateWithClosedMenu, Cmd.batch [ cmdWithClosedMenu, internalFocus idString OnInputFocused ] )

                            else
                                ( Nothing, stateWithOpenMenu, Cmd.batch [ cmdWithOpenMenu, internalFocus idString OnInputFocused ] )
            in
            ( updatedAction
            , State
                { updatedState
                    | controlUiFocused = Just Internal.ControlInput
                }
            , updatedCmds
            )

        UnsearchableSelectContainerClicked ->
            let
                ( _, State stateWithOpenMenu, _ ) =
                    update OpenMenu (State state_)

                ( _, State stateWithClosedMenu, _ ) =
                    update CloseMenu (State state_)

                updatedState =
                    if state_.menuOpen then
                        stateWithClosedMenu

                    else
                        stateWithOpenMenu

                focusCmd =
                    case state_.controlUiFocused of
                        Just Internal.ControlInput ->
                            Cmd.none

                        _ ->
                            internalFocus idString OnInputFocused

                toggleAction =
                    if state_.menuOpen then
                        MenuToggle MenuClose

                    else
                        MenuToggle MenuOpen
            in
            ( Just toggleAction
            , State { updatedState | controlUiFocused = Just Internal.ControlInput }
            , focusCmd
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
                    if nextActiveTargetIndex <= 0 then
                        -- Bypass querying menu elements and go straight to the top
                        Task.attempt (\_ -> FocusMenuViewportTop) <| Dom.setViewportOf (menuListId state_.selectId) 0 0

                    else if Internal.shouldQueryNextTargetElement nextActiveTargetIndex state_.activeTargetIndex then
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
                    if nextActiveTargetIndex == (totalTargetCount - 1) then
                        Task.attempt (\_ -> DoNothing)
                            (Dom.setViewportOf (menuListId state_.selectId) 0 512000000)

                    else if Internal.shouldQueryNextTargetElement nextActiveTargetIndex state_.activeTargetIndex then
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
            , if state_.keepOpen then
                State state_

              else
                resetState (State state_)
            , Cmd.none
            )

        MenuListScrollTop position ->
            ( Nothing, State { state_ | menuListScrollTop = position }, Cmd.none )

        SetMouseMenuNavigation ->
            ( Nothing, State { state_ | menuNavigation = Mouse }, Cmd.none )

        ClearButtonMouseDowned variant ->
            case variant of
                CustomVariant (SingleMenu _) ->
                    ( Just Clear, State { state_ | inputValue = Nothing }, Cmd.none )

                CustomVariant (Multi _) ->
                    ( Just Clear
                    , State state_
                    , internalFocus idString OnInputFocused
                    )

                _ ->
                    ( Just Clear, State state_, Cmd.none )

        ClearButtonKeyDowned variant ->
            case variant of
                CustomVariant (SingleMenu _) ->
                    ( Just Clear
                    , State { state_ | inputValue = Nothing }
                    , internalFocus idString OnInputFocused
                    )

                CustomVariant (Multi selectedItems) ->
                    ( Just (Deselect (List.map unwrapItem selectedItems))
                    , State { state_ | inputValue = Nothing }
                    , internalFocus idString OnInputFocused
                    )

                _ ->
                    ( Just Clear
                    , State state_
                    , internalFocus idString OnInputFocused
                    )


type alias BuildViewHelpData =
    { state : SelectState
    , selectId : SelectId
    , ctrlStyles : Styles.ControlConfig
    , menuStyles : Styles.MenuConfig
    }


viewDataHelp : Configuration item items -> BuildViewHelpData
viewDataHelp config =
    let
        (State state_) =
            config.state
    in
    { state = state_
    , selectId = state_.selectId
    , ctrlStyles = Styles.getControlConfig config.styles
    , menuStyles = Styles.getMenuConfig config.styles
    }


{-| Render the select with a virtual scroll menu.

Select inputs with a large number of menu items (>500) can degrade a user experience mostly due to
the browser struggling to render all the items. This can result in a sluggish feeling select input.

Virtualizing the menu allows you to work with thousands of menu items whilst keeping the
select input feeling snappy and performant.

NOTE: Only use if you absolutely need it as there are accessibility short falls by virtualizing the menu.

      yourView model =
          Html.map SelectMsg <|
              viewVirtual (singleVirtual Nothing)

-}
viewVirtual : Config item (VirtualConfig item) -> Html (Msg item)
viewVirtual (Config config) =
    -- NOTE: When the combined virtual height is below the max-height, we have to manage
    -- the height of the menu list manually as all virtual items are position absolute so the menu-list
    -- wont snap to the desired height by itself.
    --
    -- example 1.
    --
    -- The max-height of the menu-list is 100px and the user has filtered the items via a search string.
    -- The combined height of the items is 50px so We set the menu list height to 50px and account for padding.
    let
        viewData =
            viewDataHelp config

        (State state_) =
            config.state

        virtualConfig =
            case config.menuItems of
                FixedSizeMenuItems cfg ->
                    cfg

        maxHeight : Float
        maxHeight =
            case Styles.getMenuConfig config.styles |> Styles.getMenuMaxHeightRawType of
                Internal.Px i ->
                    i.numericValue

                _ ->
                    215

        ( filteredMenuItems, filteredCount, filteredVirtualHeight ) =
            case config.menuItems of
                FixedSizeMenuItems cfg ->
                    let
                        items =
                            getViewableMenuItems
                                (BuildViewableMenuItemsData
                                    config.searchable
                                    viewData.state.inputValue
                                    cfg.menuItems
                                    config.variant
                                )
                    in
                    ( items, List.length items, cfg.height * toFloat (List.length items) )

        virtualizedMenuItemsUnwrapped =
            case virtualizedMenuItems of
                FixedSizeMenuItems cfg ->
                    cfg.menuItems

        calculateWindowHeight =
            if
                filteredVirtualHeight
                    < (maxHeight
                        - Styles.menuPaddingTop
                        - Styles.menuPaddingBottom
                        - ((Styles.getMenuConfig config.styles |> Styles.getMenuBorderWidth) * 2)
                      )
            then
                filteredVirtualHeight

            else
                maxHeight
                    - Styles.menuPaddingTop
                    - Styles.menuPaddingBottom
                    - ((Styles.getMenuConfig config.styles |> Styles.getMenuBorderWidth) * 2)

        virtualizedMenuItems =
            ListExtra.indexedFoldl
                (\idx mi acc ->
                    let
                        adjustedItem =
                            applyVirtualConfigMenuItem idx virtualConfig.height mi
                    in
                    Array.push adjustedItem acc
                )
                Array.empty
                filteredMenuItems
                |> sliceItems
                |> setVirtualMenuItems config.menuItems

        sliceItems cache =
            Array.slice startIndex (stopIndex + 1) cache |> Array.toList

        startIndexForOffset : Int
        startIndexForOffset =
            max
                0
                (min (filteredCount - 1)
                    (floor
                        ((state_.menuListScrollTop
                            + Styles.menuPaddingTop
                            + (Styles.getMenuConfig config.styles |> Styles.getMenuBorderWidth)
                         )
                            / virtualConfig.height
                        )
                    )
                )

        offset : Float
        offset =
            toFloat startIndexForOffset * virtualConfig.height

        numVisibleItems : Int
        numVisibleItems =
            ceiling
                ((calculateWindowHeight
                    + state_.menuListScrollTop
                    - offset
                 )
                    / virtualConfig.height
                )

        stopIndexforStartIndex : Int
        stopIndexforStartIndex =
            max 0 (min (filteredCount - 1) (startIndexForOffset + numVisibleItems - 1))

        overscan =
            max 1 virtualConfig.overscanCount

        startIndex =
            max 0 (startIndexForOffset - overscan)

        stopIndex =
            max 0 (min (filteredCount - 1) (stopIndexforStartIndex + overscan))
    in
    case config.variant of
        CustomVariant ((SingleVirtual _) as variant) ->
            viewWrapper
                (ViewWrapperData viewData.state
                    config.searchable
                    variant
                    config.disabled
                )
                ([ lazy viewCustomControl
                    (ViewCustomControlData
                        config.state
                        viewData.ctrlStyles
                        config.styles
                        (enterSelectTargetItem viewData.state virtualizedMenuItemsUnwrapped)
                        filteredCount
                        variant
                        config.placeholder
                        config.disabled
                        config.searchable
                        config.labelledBy
                        config.ariaDescribedBy
                        config.clearable
                        config.isLoading
                        config.required
                    )
                 , lazy renderMenu
                    (RenderMenuData viewData.state.menuOpen
                        viewData.state.initialAction
                        viewData.state.activeTargetIndex
                        viewData.state.menuNavigation
                        viewData.state.controlUiFocused
                        config.isLoading
                        (MenuItemsVirtual_ virtualizedMenuItems)
                        variant
                        config.loadingMessage
                        config.styles
                        viewData.selectId
                        config.disabled
                        filteredCount
                    )
                 ]
                    ++ viewHiddenFormControl variant config.name
                )

        CustomVariant ((Multi _) as variant) ->
            viewWrapper
                (ViewWrapperData viewData.state
                    config.searchable
                    variant
                    config.disabled
                )
                ([ lazy viewCustomControl
                    (ViewCustomControlData
                        config.state
                        viewData.ctrlStyles
                        config.styles
                        (enterSelectTargetItem viewData.state virtualizedMenuItemsUnwrapped)
                        filteredCount
                        variant
                        config.placeholder
                        config.disabled
                        config.searchable
                        config.labelledBy
                        config.ariaDescribedBy
                        config.clearable
                        config.isLoading
                        config.required
                    )
                 , lazy renderMenu
                    (RenderMenuData viewData.state.menuOpen
                        viewData.state.initialAction
                        viewData.state.activeTargetIndex
                        viewData.state.menuNavigation
                        viewData.state.controlUiFocused
                        config.isLoading
                        (MenuItemsVirtual_ virtualizedMenuItems)
                        variant
                        config.loadingMessage
                        config.styles
                        viewData.selectId
                        config.disabled
                        filteredCount
                    )
                 ]
                    ++ viewHiddenFormControl variant config.name
                )

        _ ->
            text ""


{-| Render the select

      yourView model =
          Html.map SelectMsg <|
              view (single Nothing)

-}
view : Config item (MenuItems item) -> Html (Msg item)
view (Config config) =
    let
        viewData =
            viewDataHelp config

        totalFilteredMenuItemsCount =
            List.length filteredMenuItems

        totalMenuItems =
            List.length config.menuItems

        filteredMenuItems =
            getViewableMenuItems
                (BuildViewableMenuItemsData
                    config.searchable
                    viewData.state.inputValue
                    config.menuItems
                    config.variant
                )
    in
    case config.variant of
        NativeVariant variant ->
            div [ StyledAttribs.css [ Css.position Css.relative ] ]
                [ viewNative
                    (ViewNativeData viewData.ctrlStyles
                        variant
                        config.menuItems
                        viewData.selectId
                        config.labelledBy
                        config.ariaDescribedBy
                        config.placeholder
                        config.disabled
                        config.name
                        config.required
                    )
                , span
                    [ StyledAttribs.css
                        [ Css.position Css.absolute
                        , Css.right (Css.px 0)
                        , Css.top (Css.pct 50)
                        , Css.transform (Css.translateY (Css.pct -50))
                        , Css.property "padding-block" (Css.px 8).value
                        , Css.property "padding-inline" (Css.px 8).value
                        , Css.pointerEvents Css.none
                        ]
                    ]
                    [ viewIndicatorWrapper
                        [ viewClearIndicator
                            (ViewClearIndicatorData
                                config.disabled
                                config.clearable
                                config.variant
                                config.state
                                config.styles
                            )
                        , viewLoadingSpinner
                            (ViewLoadingSpinnerData config.isLoading
                                (Styles.getControlLoadingIndicatorColor viewData.ctrlStyles)
                                viewData.ctrlStyles
                            )
                        , indicatorSeparator viewData.ctrlStyles
                        , viewDropdownIndicator (ViewDropdownIndicatorData False viewData.ctrlStyles)
                        ]
                    ]
                ]

        CustomVariant ((SingleMenu _) as singleVariant) ->
            -- Compose the SingleMenu variant, def can be improved
            Internal.viewIf viewData.state.menuOpen
                (viewWrapper
                    (ViewWrapperData viewData.state
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
                                    (enterSelectTargetItem viewData.state filteredMenuItems)
                                    totalFilteredMenuItemsCount
                                    viewData.state.menuOpen
                                    config.labelledBy
                                    config.ariaDescribedBy
                                    config.disabled
                                    config.clearable
                                    viewData.state
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
                                    config.searchable
                                )
                                [ viewSearchIndicator (Styles.getMenuControlSearchIndicatorColor viewData.menuStyles)
                                , viewInputWrapper config.disabled
                                    [ Internal.viewIf (not config.disabled)
                                        (lazy viewSelectInput
                                            (ViewSelectInputData
                                                (enterSelectTargetItem viewData.state filteredMenuItems)
                                                totalFilteredMenuItemsCount
                                                singleVariant
                                                config.labelledBy
                                                config.ariaDescribedBy
                                                config.disabled
                                                config.clearable
                                                config.required
                                                viewData.state
                                            )
                                        )
                                    , buildPlaceholder
                                        (BuildPlaceholderData singleVariant
                                            viewData.state
                                            viewData.ctrlStyles
                                            config.placeholder
                                        )
                                    ]
                                , viewIndicatorWrapper
                                    [ viewClearIndicator
                                        (ViewClearIndicatorData
                                            config.disabled
                                            config.clearable
                                            config.variant
                                            config.state
                                            config.styles
                                        )
                                    , viewLoadingSpinner
                                        (ViewLoadingSpinnerData config.isLoading
                                            (Styles.getMenuControlLoadingIndicatorColor viewData.menuStyles)
                                            viewData.ctrlStyles
                                        )
                                    ]
                                ]
                            )
                        , ( "menu-list"
                          , viewMenuItemsWrapper
                                (ViewMenuItemsWrapperData
                                    singleVariant
                                    (Styles.getMenuConfig config.styles)
                                    viewData.state.menuNavigation
                                    viewData.selectId
                                    (MenuItems_ filteredMenuItems)
                                    totalMenuItems
                                )
                                (if config.isLoading && List.isEmpty filteredMenuItems then
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
                                            (Styles.getGroupConfig config.styles)
                                            viewData.selectId
                                            singleVariant
                                            viewData.state.initialAction
                                            viewData.state.activeTargetIndex
                                            viewData.state.menuNavigation
                                            filteredMenuItems
                                            config.disabled
                                            viewData.state.controlUiFocused
                                            totalMenuItems
                                        )
                                )
                          )
                        ]
                    ]
                )

        CustomVariant variant ->
            viewWrapper
                (ViewWrapperData viewData.state
                    config.searchable
                    variant
                    config.disabled
                )
                ([ lazy viewCustomControl
                    (ViewCustomControlData
                        config.state
                        viewData.ctrlStyles
                        config.styles
                        (enterSelectTargetItem viewData.state filteredMenuItems)
                        totalFilteredMenuItemsCount
                        variant
                        config.placeholder
                        config.disabled
                        config.searchable
                        config.labelledBy
                        config.ariaDescribedBy
                        config.clearable
                        config.isLoading
                        config.required
                    )
                 , lazy renderMenu
                    (RenderMenuData viewData.state.menuOpen
                        viewData.state.initialAction
                        viewData.state.activeTargetIndex
                        viewData.state.menuNavigation
                        viewData.state.controlUiFocused
                        config.isLoading
                        (MenuItems_ filteredMenuItems)
                        variant
                        config.loadingMessage
                        config.styles
                        viewData.selectId
                        config.disabled
                        totalMenuItems
                    )
                 ]
                    ++ viewHiddenFormControl variant config.name
                )


viewHiddenFormControl : CustomVariant item -> Maybe String -> List (Html msg)
viewHiddenFormControl variant maybeName =
    -- This renders an input for a Custom variants so that form submissions include the given selection/s.
    -- Without this, the selections made will not be included in the submitted form.
    -- It's basically just how forms work!
    case ( variant, maybeName ) of
        ( Single (Just mi), Just n ) ->
            [ viewHiddenInput n (Maybe.withDefault (getMenuItemLabel mi) (getMenuItemValue mi)) ]

        ( Multi selected, Just n ) ->
            List.map (\mi -> viewHiddenInput n (Maybe.withDefault (getMenuItemLabel mi) (getMenuItemValue mi))) selected

        _ ->
            [ text "" ]


type alias ViewCustomControlData item =
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
    , required : Bool
    }


viewCustomControl : ViewCustomControlData item -> Html (Msg item)
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
                                    [ Css.property "margin-inline-end" (Css.rem 0.4375).value
                                    , Css.displayFlex
                                    , Css.alignItems Css.center
                                    , Css.flex3 (Css.int 1) (Css.int 1) (Css.pct 0)
                                    , Css.flexWrap Css.wrap
                                    , Css.position Css.relative
                                    , Css.overflow Css.hidden
                                    , Css.boxSizing Css.borderBox
                                    ]
                                ]

                            else
                                []
                    in
                    Keyed.node "div" resolveMultiValueStyles <|
                        (List.indexedMap
                            (\ix i ->
                                ( "selected-item-" ++ String.fromInt ix
                                , lazy4 viewMultiValue
                                    state_.initialAction
                                    data.controlStyles
                                    ix
                                    i
                                )
                            )
                            multiSelectedValues
                            ++ [ ( "built-input", buildInput ) ]
                        )

                Single _ ->
                    buildInput

                SingleVirtual _ ->
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
                            data.required
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
    in
    viewControlWrapper
        (ViewControlWrapperData
            data.disabled
            data.state
            data.controlStyles
            menuStyles
            data.variant
            data.searchable
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
                    (CustomVariant data.variant)
                    data.state
                    data.styles
                )
            , viewLoadingSpinner
                (ViewLoadingSpinnerData data.loading
                    (Styles.getControlLoadingIndicatorColor data.controlStyles)
                    data.controlStyles
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
             , Css.property "padding-block" (Css.px 2).value
             , Css.property "padding-inline" (Css.px 8).value
             , Css.overflow Css.hidden
             ]
                ++ withDisabledStyles
            )
        ]


type alias ViewDropdownIndicatorData =
    { disabled : Bool
    , controlStyles : Styles.ControlConfig
    }


viewDropdownIndicator : ViewDropdownIndicatorData -> Html (Msg item)
viewDropdownIndicator data =
    div
        [ StyledAttribs.css (indicatorContainerStyles data.controlStyles)
        ]
        [ dropdownIndicator data.controlStyles data.disabled
        ]


type alias ViewLoadingSpinnerData =
    { isLoading : Bool
    , loadingIndicatorColor : Css.Color
    , controlStyles : Styles.ControlConfig
    }


viewLoadingSpinner : ViewLoadingSpinnerData -> Html msg
viewLoadingSpinner data =
    let
        resolveLoadingSpinner =
            if data.isLoading then
                viewLoading

            else
                text ""
    in
    div [ StyledAttribs.css (indicatorContainerStyles data.controlStyles) ]
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
    , variant : Variant item
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
                CustomVariant (SingleMenu _) ->
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
        div
            [ StyledAttribs.css
                (indicatorContainerStyles ctrlStyles
                    ++ [ Css.pointerEvents Css.auto ]
                )
            ]
            [ clearIndicator resolveClearIndicatorData ]


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
    , searchable : Bool
    }


viewControlWrapper : ViewControlWrapperData item -> List (Html (Msg item)) -> Html (Msg item)
viewControlWrapper data =
    let
        (State state_) =
            data.state

        resolveControlStyles =
            case data.variant of
                SingleMenu _ ->
                    [ Css.property "margin-block-start" (Css.px 6).value
                    , Css.property "margin-inline" (Css.px 6).value
                    , Css.property "margin-block-end" (Css.px 0).value
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
                    attribute "data-test-id" "selectContainer"
                        :: (case data.variant of
                                SingleMenu _ ->
                                    containerClickedMsg
                                        (ContainerClickedMsgData data.disabled
                                            state_
                                            data.variant
                                            data.searchable
                                        )

                                _ ->
                                    []
                           )
               )
        )


type alias ViewNativeData item =
    { controlStyles : Styles.ControlConfig
    , variant : NativeVariant item
    , menuItems : MenuItems item
    , selectId : SelectId
    , labelledBy : Maybe String
    , ariaDescribedBy : Maybe String
    , placeholder : String
    , disabled : Bool
    , name : Maybe String
    , required : Bool
    }


viewNative : ViewNativeData item -> Html (Msg item)
viewNative data =
    let
        (SelectId selectId) =
            data.selectId

        withAriaDescribedBy =
            case data.ariaDescribedBy of
                Just s ->
                    [ Internal.ariaDescribedby s ]

                _ ->
                    []

        withLabelledBy =
            case data.labelledBy of
                Just s ->
                    [ Internal.ariaLabelledby s ]

                _ ->
                    []

        buildGroupedViews :
            ( String, ( MenuItems item, Internal.Group Styles.GroupConfig ) )
            -> List (Html (Msg item))
            -> List (Html (Msg item))
        buildGroupedViews ( _, ( v, g ) ) acc =
            acc
                ++ [ optgroup [ StyledAttribs.attribute "label" g.name ]
                        (List.map
                            buildList
                            v
                        )
                   ]

        buildList menuItem =
            case data.variant of
                SingleNative (Just selectedItem) ->
                    buildMenuItemNative [ selectedItem ] menuItem

                SingleNative _ ->
                    buildMenuItemNative [] menuItem

                MultiNative selectedItems ->
                    buildMenuItemNative selectedItems menuItem

        withPlaceholder =
            case data.variant of
                SingleNative maybeSelectedItem ->
                    case maybeSelectedItem of
                        Just _ ->
                            text ""

                        _ ->
                            option
                                [ StyledAttribs.hidden True
                                , StyledAttribs.selected True
                                , StyledAttribs.disabled True
                                , StyledAttribs.attribute "value" ""
                                ]
                                [ text ("(" ++ data.placeholder ++ ")") ]

                MultiNative _ ->
                    text ""

        ( ungroupedItems, groupedItems ) =
            sortMenuItemsHelp 0 data.menuItems ( [], Dict.empty )

        itemsInOrder =
            ungroupedItems
                ++ List.concatMap (Tuple.second >> Tuple.first) (Dict.toList groupedItems)

        groupedViews =
            List.foldl buildGroupedViews
                []
                (Dict.toList groupedItems)

        resolveOnInputMsg =
            case data.variant of
                SingleNative (Just _) ->
                    Events.onInputAtInt [ "target", "selectedIndex" ] (InputChangedNativeSingle itemsInOrder True)

                SingleNative Nothing ->
                    Events.onInputAtInt [ "target", "selectedIndex" ] (InputChangedNativeSingle itemsInOrder False)

                _ ->
                    Events.onMultiSelect (InputChangedNativeMulti itemsInOrder)

        resolveTestId =
            case data.variant of
                SingleNative _ ->
                    "nativeSingleSelect"

                MultiNative _ ->
                    "nativeMultiSelect"

        onMultiple =
            case data.variant of
                MultiNative _ ->
                    [ StyledAttribs.multiple True ]

                _ ->
                    []

        resolveName =
            case data.name of
                Just n ->
                    [ StyledAttribs.name n ]

                _ ->
                    []
    in
    select
        ([ id selectId
         , StyledAttribs.attribute "data-test-id" resolveTestId
         , StyledAttribs.disabled data.disabled
         , resolveOnInputMsg
         , StyledAttribs.required data.required
         , onFocus (InputReceivedFocused (NativeVariant data.variant))
         , onBlur (OnInputBlurred (NativeVariant data.variant))
         , StyledAttribs.css
            [ Css.width (Css.pct 100)
            , Css.height (Css.px (Styles.getControlMinHeight data.controlStyles))
            , Css.property "border" "none"
            , controlRadius (Styles.getControlBorderRadius data.controlStyles)
            , Css.backgroundColor (Styles.getControlBackgroundColor data.controlStyles)
            , controlBorder (Styles.getControlBorderColor data.controlStyles)
            , if data.disabled then
                controlDisabled (Styles.getControlDisabledOpacity data.controlStyles)

              else
                controlHover
                    (ControlHoverData
                        (Styles.getControlBackgroundColorHover data.controlStyles)
                        (Styles.getControlBorderColorHover data.controlStyles)
                    )
            , Css.property "padding-block" (Css.px 2).value
            , Css.property "padding-inline" (Css.px 8).value
            , Css.property "appearance" "none"
            , Css.property "-webkit-appearance" "none"
            , Css.color (Styles.getControlColor data.controlStyles)
            , Css.fontSize (Css.px 16)
            , Css.focus
                [ controlBorderFocused (Styles.getControlBorderColorFocus data.controlStyles), Css.outline Css.none ]
            ]
         ]
            ++ withLabelledBy
            ++ withAriaDescribedBy
            ++ onMultiple
            ++ resolveName
        )
        (withPlaceholder
            :: (List.map buildList ungroupedItems
                    ++ groupedViews
               )
        )


type alias ViewWrapperData item =
    { state : SelectState
    , searchable : Bool
    , variant : CustomVariant item
    , disabled : Bool
    }


viewWrapper : ViewWrapperData item -> List (Html (Msg item)) -> Html (Msg item)
viewWrapper data =
    div
        (StyledAttribs.css [ Css.position Css.relative, Css.boxSizing Css.borderBox ]
            :: (case data.variant of
                    -- viewInputWrapper handles ContainerClicked msg's
                    SingleMenu _ ->
                        []

                    _ ->
                        containerClickedMsg
                            (ContainerClickedMsgData data.disabled
                                data.state
                                data.variant
                                data.searchable
                            )
               )
        )


type alias ViewMenuItemsWrapperData item =
    { variant : CustomVariant item
    , menuStyles : Styles.MenuConfig
    , menuNavigation : MenuNavigation
    , selectId : SelectId
    , menuItemsKind : MenuItemsKind item
    , totalMenuItems : Int
    }


viewMenuItemsWrapper : ViewMenuItemsWrapperData item -> List ( String, Html (Msg item) ) -> Html (Msg item)
viewMenuItemsWrapper data items =
    let
        resolveAttributes =
            if data.menuNavigation == Keyboard then
                [ attribute "data-test-id" "listBox", on "mousemove" <| Decode.succeed SetMouseMenuNavigation ]

            else
                [ attribute "data-test-id" "listBox" ]

        resolveStyles =
            case data.variant of
                SingleMenu _ ->
                    menuListStyles data.menuStyles

                _ ->
                    case data.menuItemsKind of
                        MenuItemsVirtual_ itemsV ->
                            case itemsV of
                                FixedSizeMenuItems cfg ->
                                    let
                                        combinedVirtualHeight : Float
                                        combinedVirtualHeight =
                                            cfg.height * toFloat data.totalMenuItems

                                        maxHeight : Float
                                        maxHeight =
                                            case Styles.getMenuMaxHeightRawType data.menuStyles of
                                                Internal.Px i ->
                                                    i.numericValue

                                                _ ->
                                                    215

                                        adjustedMenuHeight : Css.Style
                                        adjustedMenuHeight =
                                            if
                                                combinedVirtualHeight
                                                    < (maxHeight
                                                        - Styles.menuPaddingTop
                                                        - Styles.menuPaddingBottom
                                                        - (Styles.getMenuBorderWidth data.menuStyles * 2)
                                                      )
                                            then
                                                Css.height
                                                    (Css.px
                                                        (combinedVirtualHeight
                                                            + Styles.menuPaddingTop
                                                            + Styles.menuPaddingBottom
                                                            + (Styles.getMenuBorderWidth data.menuStyles * 2)
                                                        )
                                                    )

                                            else
                                                Css.batch []
                                    in
                                    adjustedMenuHeight :: menuWrapperStyles data.menuStyles ++ menuListStyles data.menuStyles

                        _ ->
                            menuWrapperStyles data.menuStyles ++ menuListStyles data.menuStyles

        innerContainervirtualAttribs =
            case data.menuItemsKind of
                MenuItemsVirtual_ itemsV ->
                    case itemsV of
                        FixedSizeMenuItems cfg ->
                            [ Css.position Css.relative
                            , Css.height (Css.px (cfg.height * toFloat data.totalMenuItems))
                            ]

                _ ->
                    []
    in
    case data.menuItemsKind of
        MenuItems_ _ ->
            Keyed.lazyNode "ul"
                ([ StyledAttribs.css resolveStyles
                 , id (menuListId data.selectId)
                 , on "scroll" <| Decode.map MenuListScrollTop <| Decode.at [ "target", "scrollTop" ] Decode.float
                 , Internal.role "listbox"
                 , custom "mousedown"
                    (Decode.map
                        (\msg -> { message = msg, stopPropagation = True, preventDefault = True })
                     <|
                        Decode.succeed DoNothing
                    )
                 ]
                    ++ resolveAttributes
                )
                identity
                items

        MenuItemsVirtual_ _ ->
            Styled.ul
                ([ StyledAttribs.css resolveStyles
                 , id (menuListId data.selectId)
                 , on "scroll" <| Decode.map MenuListScrollTop <| Decode.at [ "target", "scrollTop" ] Decode.float
                 , Internal.role "listbox"
                 , custom "mousedown"
                    (Decode.map
                        (\msg -> { message = msg, stopPropagation = True, preventDefault = True })
                     <|
                        Decode.succeed DoNothing
                    )
                 ]
                    ++ resolveAttributes
                )
                [ Keyed.lazyNode "div"
                    [ StyledAttribs.css innerContainervirtualAttribs ]
                    identity
                    items
                ]


type alias ViewMenuData item =
    { variant : CustomVariant item
    , selectId : SelectId
    , menuItemsKind : MenuItemsKind item
    , initialAction : Internal.InitialAction
    , activeTargetIndex : Int
    , menuNavigation : MenuNavigation
    , menuStyles : Styles.MenuConfig
    , menuItemStyles : Styles.MenuItemConfig
    , menuItemGroupStyles : Styles.GroupConfig
    , disabled : Bool
    , controlUiFocused : Maybe Internal.UiFocused
    , totalMenuItems : Int
    }


viewMenu : ViewMenuData item -> Html (Msg item)
viewMenu data =
    viewMenuItemsWrapper
        (ViewMenuItemsWrapperData
            data.variant
            data.menuStyles
            data.menuNavigation
            data.selectId
            data.menuItemsKind
            data.totalMenuItems
        )
        (case data.menuItemsKind of
            MenuItemsVirtual_ itemsV ->
                case itemsV of
                    FixedSizeMenuItems cfg ->
                        viewMenuItems
                            (ViewMenuItemsData
                                data.menuItemStyles
                                data.menuItemGroupStyles
                                data.selectId
                                data.variant
                                data.initialAction
                                data.activeTargetIndex
                                data.menuNavigation
                                cfg.menuItems
                                data.disabled
                                data.controlUiFocused
                                data.totalMenuItems
                            )

            MenuItems_ items ->
                viewMenuItems
                    (ViewMenuItemsData
                        data.menuItemStyles
                        data.menuItemGroupStyles
                        data.selectId
                        data.variant
                        data.initialAction
                        data.activeTargetIndex
                        data.menuNavigation
                        items
                        data.disabled
                        data.controlUiFocused
                        data.totalMenuItems
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
                        ++ menuListStyles data.menuStyles
    in
    div
        [ StyledAttribs.css
            [ Css.textAlign Css.center, Css.color (Css.rgba 0 0 0 0.5), Css.batch variantStyles ]
        ]
        [ text data.loadingText
        ]


type alias ViewMenuItemsData item =
    { menuItemStyles : Styles.MenuItemConfig
    , menuItemGroupStyles : Styles.GroupConfig
    , selectId : SelectId
    , variant : CustomVariant item
    , initialAction : Internal.InitialAction
    , activeTargetIndex : Int
    , menuNavigation : MenuNavigation
    , menuItems : MenuItems item
    , disabled : Bool
    , controlUiFocused : Maybe Internal.UiFocused
    , totalMenuItems : Int
    }


viewMenuItems : ViewMenuItemsData item -> List ( String, Html (Msg item) )
viewMenuItems data =
    let
        buildGroupedViews :
            ( String, ( MenuItems item, Internal.Group Styles.GroupConfig ) )
            -> ( Int, List ( String, Html (Msg item) ) )
            -> ( Int, List ( String, Html (Msg item) ) )
        buildGroupedViews ( _, ( v, g ) ) ( idx, acc ) =
            let
                newIndex =
                    idx + List.length v

                resolveGroupStyles =
                    case g.styles of
                        Just styles ->
                            styles

                        _ ->
                            data.menuItemGroupStyles
            in
            ( newIndex
            , acc
                ++ viewSectionLabel resolveGroupStyles g
                :: List.map2 builder
                    (List.range (idx + 1) (idx + List.length v))
                    v
            )

        builder : Int -> MenuItem item -> ( String, Html (Msg item) )
        builder =
            buildMenuItem
                (BuildMenuItemData data.menuItemStyles
                    data.selectId
                    data.variant
                    data.initialAction
                    data.activeTargetIndex
                    data.menuNavigation
                    data.disabled
                    data.controlUiFocused
                    data.totalMenuItems
                )

        ( ungroupedViews, groupedItems ) =
            sortMenuItemsHelp 0 data.menuItems ( [], Dict.empty )

        groupedViews =
            List.foldl buildGroupedViews
                ( List.length ungroupedViews - 1, [] )
                (Dict.toList groupedItems)
                |> Tuple.second
    in
    -- There is almost certainly a more performant way to do this.
    List.indexedMap builder ungroupedViews
        ++ groupedViews


viewSectionLabel : Styles.GroupConfig -> Internal.Group Styles.GroupConfig -> ( String, Html msg )
viewSectionLabel styles g =
    ( g.name
    , div
        [ StyledAttribs.css
            [ Css.property "text-transform"
                (Styles.getGroupTextTransformationLabel styles)
            , Css.property "font-size" (Styles.getGroupFontSizeLabel styles)
            , Css.property "font-weight" (Styles.getGroupFontWeightLabel styles)
            , Css.property "margin-block-end" (Css.em 0.25).value
            , Css.property "margin-block-start" (Css.em 0.25).value
            , Css.property "padding-inline-start" (Css.px 8).value
            , Css.property "padding-inline-end" (Css.px 8).value
            , Css.boxSizing Css.borderBox
            , Css.color (Styles.getGroupColor styles)
            ]
        , attribute "data-test-id" "group"
        ]
        [ case g.view of
            Just v ->
                Styled.map never v

            _ ->
                text g.name
        ]
    )


type alias ViewMenuItemData item =
    { index : Int
    , itemSelected : Bool
    , isClickFocused : Bool
    , menuItemIsTarget : Bool
    , selectId : SelectId
    , menuItem : MenuItem item
    , menuNavigation : MenuNavigation
    , initialAction : Internal.InitialAction
    , variant : CustomVariant item
    , menuItemStyles : Styles.MenuItemConfig
    , disabled : Bool
    , controlUiFocused : Maybe Internal.UiFocused
    , totalMenuItems : Int
    }


viewMenuItem : ViewMenuItemData item -> List (Html (Msg item)) -> ( String, Html (Msg item) )
viewMenuItem data content =
    let
        virtualConfig =
            case data.menuItem of
                Basic cfg ->
                    cfg.virtualConfig

                Custom cfg ->
                    cfg.virtualConfig

        resolveMouseLeave =
            if data.isClickFocused then
                [ on "mouseleave" <| Decode.succeed ClearFocusedItem ]

            else
                []

        resolveMouseUpMsg =
            case data.variant of
                Multi _ ->
                    SelectedItemMulti (unwrapItem data.menuItem)

                _ ->
                    SelectedItem (unwrapItem data.menuItem)

        resolveMouseUp =
            case data.initialAction of
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
                [ Internal.ariaSelected "true" ]

            else
                [ Internal.ariaSelected "false" ]

        resolvePosinsetAriaAttrib =
            [ attribute "aria-posinset" (String.fromInt <| data.index + 1) ]

        resolveMouseover =
            case data.controlUiFocused of
                Just _ ->
                    [ on "mouseover" <| Decode.succeed (HoverFocused data.index) ]

                _ ->
                    []

        allEvents =
            if data.disabled then
                []

            else
                (preventDefaultOn "mousedown" <| Decode.map (\msg -> ( msg, True )) <| Decode.succeed (MenuItemClickFocus data.index))
                    :: resolveMouseLeave
                    ++ resolveMouseUp
                    ++ resolveMouseover

        virtualAttribs =
            case virtualConfig of
                Just cfg ->
                    [ StyledAttribs.style "position" "absolute"
                    , StyledAttribs.style "height" (String.fromFloat cfg.height ++ "px")
                    , StyledAttribs.style "top" (String.fromFloat (cfg.height * toFloat cfg.index) ++ "px")
                    ]

                _ ->
                    []
    in
    ( menuItemId data.selectId data.index
    , li
        ([ Internal.role "option"
         , tabindex -1
         , StyledAttribs.css
            (menuItemContainerStyles data)
         ]
            ++ resolveDataTestId
            ++ resolveSelectedAriaAttribs
            ++ resolvePosinsetAriaAttrib
            ++ allEvents
            ++ virtualAttribs
        )
        content
    )


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
    , required : Bool
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

        resolveRequired config =
            case data.variant of
                Single Nothing ->
                    SelectInput.onRequired data.required config

                Multi [] ->
                    SelectInput.onRequired data.required config

                SingleVirtual Nothing ->
                    SelectInput.onRequired data.required config

                _ ->
                    config

        clearButtonVisible =
            showClearButton
                (ShowClearButtonData
                    (CustomVariant data.variant)
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
            |> resolveRequired
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


viewHiddenInput : String -> String -> Html msg
viewHiddenInput n value =
    Styled.input
        [ StyledAttribs.type_ "hidden"
        , StyledAttribs.name n
        , StyledAttribs.value value
        ]
        []


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
                    [ Internal.ariaLabelledby s ]

                _ ->
                    []

        withAriaDescribedBy =
            case data.ariaDescribedBy of
                Just s ->
                    [ Internal.ariaDescribedby s ]

                _ ->
                    []

        resolvePosition =
            case data.variant of
                SingleMenu _ ->
                    style "position" "absolute"

                _ ->
                    style "position" "initial"
    in
    input
        ([ style "label" "dummyinput"
         , style "background" "0"
         , resolvePosition
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


viewMultiValue : Internal.InitialAction -> Styles.ControlConfig -> Int -> MenuItem item -> Html (Msg item)
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

        resolveDismiss cfg =
            if isMenuItemDismissible menuItem then
                Tag.onDismiss (DeselectedMultiItem (unwrapItem menuItem)) cfg

            else
                cfg
    in
    Tag.view
        (resolveVariant
            |> resolveDismiss
            |> Tag.onMousedown (MultiItemMousedown index)
            |> Tag.rightMargin True
            |> Tag.dataTestId ("multi-select-tag-" ++ String.fromInt index)
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
            unwrapItem item == unwrapItem menuItem

        Nothing ->
            False


isMenuItemClickFocused : Internal.InitialAction -> Int -> Bool
isMenuItemClickFocused initialAction i =
    case initialAction of
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


type alias RenderMenuData item =
    { menuOpen : Bool
    , initialAction : Internal.InitialAction
    , activeTargetIndex : Int
    , menuNavigation : MenuNavigation
    , controlUiFocused : Maybe Internal.UiFocused
    , isLoading : Bool
    , menuItemsKind : MenuItemsKind item
    , variant : CustomVariant item
    , loadingMessage : String
    , styles : Styles.Config
    , selectId : SelectId
    , disabled : Bool
    , totalMenuitems : Int
    }


renderMenu : RenderMenuData item -> Html (Msg item)
renderMenu data =
    let
        unwrappedItems =
            case data.menuItemsKind of
                MenuItems_ items ->
                    items

                MenuItemsVirtual_ itemsV ->
                    case itemsV of
                        FixedSizeMenuItems cfg ->
                            cfg.menuItems
    in
    Internal.viewIf data.menuOpen
        (if data.isLoading && List.isEmpty unwrappedItems then
            viewLoadingMenu
                (ViewLoadingMenuData
                    data.variant
                    data.loadingMessage
                    (Styles.getMenuConfig data.styles)
                )

         else
            lazy viewMenu
                (ViewMenuData
                    data.variant
                    data.selectId
                    data.menuItemsKind
                    data.initialAction
                    data.activeTargetIndex
                    data.menuNavigation
                    (Styles.getMenuConfig data.styles)
                    (Styles.getMenuItemConfig data.styles)
                    (Styles.getGroupConfig data.styles)
                    data.disabled
                    data.controlUiFocused
                    data.totalMenuitems
                )
        )


sortMenuItemsHelp :
    Int
    -> MenuItems item
    ->
        ( MenuItems item
        , Dict.Dict String ( MenuItems item, Internal.Group Styles.GroupConfig )
        )
    ->
        ( MenuItems item
        , Dict.Dict String ( MenuItems item, Internal.Group Styles.GroupConfig )
        )
sortMenuItemsHelp =
    let
        updateGroupedItem :
            Internal.Group Styles.GroupConfig
            -> MenuItem item
            -> Maybe ( MenuItems item, Internal.Group Styles.GroupConfig )
            -> Maybe ( MenuItems item, Internal.Group Styles.GroupConfig )
        updateGroupedItem g mi maybeItems =
            case maybeItems of
                Just i ->
                    Just (Tuple.mapFirst (\acc -> acc ++ [ mi ]) i)

                _ ->
                    Just ( [ mi ], g )

        sort idx items accum =
            case items of
                [] ->
                    accum

                head :: [] ->
                    case getGroup head of
                        Just g ->
                            Tuple.mapSecond
                                (Dict.update g.name (updateGroupedItem g head))
                                accum

                        _ ->
                            Tuple.mapFirst (\it -> it ++ [ head ]) accum

                head :: rest ->
                    case getGroup head of
                        Just g ->
                            sort
                                (idx + 1)
                                rest
                                (Tuple.mapSecond
                                    (Dict.update g.name (updateGroupedItem g head))
                                    accum
                                )

                        _ ->
                            sort
                                (idx + 1)
                                rest
                                (Tuple.mapFirst (\it -> it ++ [ head ]) accum)
    in
    sort


getGroup : MenuItem item -> Maybe (Internal.Group Styles.GroupConfig)
getGroup mi =
    case mi of
        Basic cfg ->
            cfg.group

        Custom cfg ->
            cfg.group


unwrapItem : MenuItem item -> item
unwrapItem mi =
    case mi of
        Custom i ->
            i.item

        Basic i ->
            i.item


type alias ContainerClickedMsgData item =
    { disabled : Bool
    , state : SelectState
    , variant : CustomVariant item
    , searchable : Bool
    }


containerClickedMsg : ContainerClickedMsgData item -> List (Styled.Attribute (Msg item))
containerClickedMsg data =
    let
        preventDefault =
            case data.state.initialAction of
                Internal.NothingMousedown ->
                    case data.variant of
                        SingleMenu _ ->
                            data.state.controlUiFocused == Just Internal.ControlInput

                        _ ->
                            case resolveContainerMsg of
                                -- We are only preventing default when the input is actually focused
                                -- to avoid a blur event on the input.
                                -- Should do for SearchableSelectContainerClicked also.
                                UnsearchableSelectContainerClicked ->
                                    data.state.controlUiFocused == Just Internal.ControlInput

                                _ ->
                                    False

                _ ->
                    True

        resolveContainerMsg =
            if data.searchable then
                SearchableSelectContainerClicked data.variant

            else
                UnsearchableSelectContainerClicked
    in
    if data.disabled then
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

            SingleVirtual (Just v) ->
                viewSelectedPlaceholder data.controlStyles v

            Single Nothing ->
                viewPlaceholder
                    (ViewPlaceholderData
                        (Styles.getControlPlaceholderOpacity data.controlStyles)
                        data.placeholder
                    )

            SingleVirtual Nothing ->
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
    { variant : Variant item
    , disabled : Bool
    , clearable : Bool
    , state : SelectState
    }


showClearButton : ShowClearButtonData item -> Bool
showClearButton data =
    if data.clearable && not data.disabled then
        case data.variant of
            CustomVariant (Single (Just _)) ->
                True

            CustomVariant (SingleMenu _) ->
                case data.state.inputValue of
                    Just "" ->
                        False

                    Just _ ->
                        True

                    _ ->
                        False

            CustomVariant (Multi (_ :: _)) ->
                True

            NativeVariant (SingleNative (Just _)) ->
                True

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
            , menuListScrollTop = 0
            , menuNavigation = Mouse
            , headlessEvent = Nothing
        }


getTargetItem : Int -> MenuItem item -> ( Int, Maybe (MenuItem item) ) -> ListExtra.Step ( Int, Maybe (MenuItem item) )
getTargetItem targetIndex item ( idx, _ ) =
    case item of
        Basic mi ->
            case mi.virtualConfig of
                Just cfg ->
                    if targetIndex == cfg.index then
                        ListExtra.Stop ( idx, Just item )

                    else
                        ListExtra.Continue ( idx + 1, Nothing )

                _ ->
                    if targetIndex == idx then
                        ListExtra.Stop ( idx, Just item )

                    else
                        ListExtra.Continue ( idx + 1, Nothing )

        Custom mi ->
            case mi.virtualConfig of
                Just cfg ->
                    if targetIndex == cfg.index then
                        ListExtra.Stop ( idx, Just item )

                    else
                        ListExtra.Continue ( idx + 1, Nothing )

                _ ->
                    if targetIndex == idx then
                        ListExtra.Stop ( idx, Just item )

                    else
                        ListExtra.Continue ( idx + 1, Nothing )


enterSelectTargetItem : SelectState -> MenuItems item -> Maybe (MenuItem item)
enterSelectTargetItem state_ viewableMenuItems =
    if state_.menuOpen && not (List.isEmpty viewableMenuItems) then
        ListExtra.stoppableFoldl (getTargetItem state_.activeTargetIndex) ( 0, Nothing ) viewableMenuItems
            |> Tuple.second

    else
        Nothing


type alias BuildViewableMenuItemsData item =
    { searchable : Bool
    , inputValue : Maybe String
    , menuItems : MenuItems item
    , variant : Variant item
    }


getViewableMenuItems : BuildViewableMenuItemsData item -> MenuItems item
getViewableMenuItems data =
    let
        filterMenuItem : String -> MenuItem item -> Bool
        filterMenuItem query item =
            String.contains (String.toLower query) (String.toLower (getMenuItemLabel item))
                || not (isMenuItemFilterable item)

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

        CustomVariant (SingleVirtual _) ->
            filteredMenuItems

        _ ->
            []


type alias BuildMenuItemData item =
    { menuItemStyles : Styles.MenuItemConfig
    , selectId : SelectId
    , variant : CustomVariant item
    , initialAction : Internal.InitialAction
    , activeTargetIndex : Int
    , menuNavigation : MenuNavigation
    , disabled : Bool
    , controlUiFocused : Maybe Internal.UiFocused
    , totalMenuItems : Int
    }


buildMenuItemNative : MenuItems item -> MenuItem item -> Html (Msg item)
buildMenuItemNative selectedItems menuItem =
    let
        withSelectedOption item =
            if List.any (\i -> unwrapItem i == unwrapItem item) selectedItems then
                [ StyledAttribs.attribute "selected" "" ]

            else
                []
    in
    option
        (StyledAttribs.value
            (Maybe.withDefault (getMenuItemLabel menuItem) (getMenuItemValue menuItem))
            :: withSelectedOption menuItem
        )
        [ text (getMenuItemLabel menuItem) ]


buildMenuItem :
    BuildMenuItemData item
    -> Int
    -> MenuItem item
    -> ( String, Html (Msg item) )
buildMenuItem data idx item =
    let
        virtualConfig =
            case item of
                Basic cfg ->
                    cfg.virtualConfig

                Custom cfg ->
                    cfg.virtualConfig

        resolveIndex =
            case virtualConfig of
                Just cfg ->
                    cfg.index

                _ ->
                    idx

        resolveIsSelected =
            (case data.variant of
                Single maybeItem ->
                    maybeItem

                SingleVirtual maybeItem ->
                    maybeItem

                SingleMenu maybeItem ->
                    maybeItem

                Multi _ ->
                    Nothing
            )
                |> isSelected item

        maybeIndividualStyles =
            case item of
                Basic cfg ->
                    cfg.styles

                Custom cfg ->
                    cfg.styles
    in
    case item of
        Basic _ ->
            viewMenuItem
                (ViewMenuItemData
                    resolveIndex
                    resolveIsSelected
                    (isMenuItemClickFocused data.initialAction resolveIndex)
                    (isTarget data.activeTargetIndex resolveIndex)
                    data.selectId
                    item
                    data.menuNavigation
                    data.initialAction
                    data.variant
                    (Maybe.withDefault data.menuItemStyles maybeIndividualStyles)
                    data.disabled
                    data.controlUiFocused
                    data.totalMenuItems
                )
                [ text (getMenuItemLabel item) ]

        Custom ci ->
            viewMenuItem
                (ViewMenuItemData
                    resolveIndex
                    resolveIsSelected
                    (isMenuItemClickFocused data.initialAction resolveIndex)
                    (isTarget data.activeTargetIndex resolveIndex)
                    data.selectId
                    item
                    data.menuNavigation
                    data.initialAction
                    data.variant
                    (Maybe.withDefault data.menuItemStyles maybeIndividualStyles)
                    data.disabled
                    data.controlUiFocused
                    data.totalMenuItems
                )
                [ Styled.map never ci.view ]


filterMultiSelectedItems : MenuItems item -> MenuItems item -> MenuItems item
filterMultiSelectedItems selectedItems currentMenuItems =
    if List.isEmpty selectedItems then
        currentMenuItems

    else
        List.filter
            (\i ->
                not
                    (List.any (\si -> unwrapItem i == unwrapItem si) selectedItems)
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
                    menuListElem.element.y - menuItemElem.element.y + Styles.menuPaddingTop + listBoxBorder
            in
            ( Task.attempt (\_ -> DoNothing) <|
                Dom.setViewportOf (menuListId selectId) 0 (menuListViewport - menuItemDistanceAbove)
            , menuListViewport - menuItemDistanceAbove
            )

        Below ->
            let
                menuItemDistanceBelow =
                    (menuItemElem.element.y + menuItemElem.element.height + Styles.menuPaddingBottom + listBoxBorder) - (menuListElem.element.y + menuListElem.element.height)
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
    , Css.property "margin-inline-end" (Css.px 2).value
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
    , variant : Variant item
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
                CustomVariant (SingleMenu _) ->
                    [ Events.isTabWithShift OnMenuClearableShiftTabbed ]

                _ ->
                    []

        withMenuBlur =
            case data.variant of
                CustomVariant (SingleMenu _) ->
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
            , Css.property "margin-block-end" (Css.px 8).value
            , Css.property "margin-block-start" (Css.px 8).value
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
    [ Css.property "padding-block-end" (Css.px Styles.menuPaddingBottom).value
    , Css.property "padding-block-start" (Css.px Styles.menuPaddingTop).value
    , Css.boxSizing Css.borderBox
    , Css.top (Css.pct 100)
    , Css.backgroundColor (Styles.getMenuBackgroundColor menuStyles)
    , Css.position (Styles.getMenuPosition menuStyles)
    , Css.width (Css.pct 100)
    , Css.boxSizing Css.borderBox
    , Css.borderRadius (Css.px (Styles.getMenuBorderRadius menuStyles))
    , Css.boxShadow4
        (Css.px <| Styles.getMenuBoxShadowHOffset menuStyles)
        (Css.px <| Styles.getMenuBoxShadowVOffset menuStyles)
        (Css.px <| Styles.getMenuBoxShadowBlur menuStyles)
        (Styles.getMenuBoxShadowColor menuStyles)
    , Css.property "margin-block-start" (Css.px menuMarginTop).value
    , Css.zIndex (Css.int 2)
    ]


menuWrapperBorderStyle : Styles.MenuConfig -> List Css.Style
menuWrapperBorderStyle menuConfig =
    [ Css.border3 (Css.px (Styles.getMenuBorderWidth menuConfig)) Css.solid Css.transparent
    ]


menuListStyles : Styles.MenuConfig -> List Css.Style
menuListStyles styles =
    menuWrapperBorderStyle styles
        ++ [ Css.property "max-height" (Styles.getMenuMaxHeight styles)
           , Css.overflowY Css.auto
           , Css.property "padding-inline-start" (Css.px 0).value
           , Css.property "margin-block-end" (Css.px 8).value
           ]


menuItemContainerStyles : ViewMenuItemData item -> List Css.Style
menuItemContainerStyles data =
    let
        withTargetStyles =
            case data.controlUiFocused of
                Just _ ->
                    if data.menuItemIsTarget && not data.itemSelected then
                        [ Css.color (Styles.getMenuItemColorHover data.menuItemStyles)
                        , Css.backgroundColor (Styles.getMenuItemBackgroundColorHover data.menuItemStyles)
                        ]

                    else
                        []

                _ ->
                    [ Css.hover
                        [ Css.color (Styles.getMenuItemColorHover data.menuItemStyles)
                        , Css.backgroundColor (Styles.getMenuItemBackgroundColorHover data.menuItemStyles)
                        ]
                    ]

        withIsClickedStyles =
            if data.isClickFocused then
                [ Css.backgroundColor (Styles.getMenuItemBackgroundColorMouseDown data.menuItemStyles)
                , Css.color (Styles.getMenuItemColorMouseDown data.menuItemStyles)
                ]

            else
                []

        withIsSelectedStyles =
            if data.itemSelected then
                [ Css.backgroundColor (Styles.getMenuItemBackgroundColorSelected data.menuItemStyles)
                , Css.color (Styles.getMenuItemColorSelected data.menuItemStyles)
                , Css.hover [ Css.color (Styles.getMenuItemColorHoverSelected data.menuItemStyles) ]
                ]

            else
                []

        allStyles =
            if data.disabled then
                [ controlDisabled 0.3 ]

            else
                (Maybe.map (\s -> [ Css.backgroundColor s ]) (Styles.getMenuItemBackgroundColor data.menuItemStyles) |> Maybe.withDefault [])
                    ++ (withTargetStyles
                            ++ withIsClickedStyles
                            ++ withIsSelectedStyles
                       )
    in
    [ Css.cursor Css.default
    , Css.display Css.block
    , Css.fontSize Css.inherit
    , Css.width (Css.pct 100)
    , Css.property "user-select" "none"
    , Css.boxSizing Css.borderBox
    , Css.borderRadius (Css.px (Styles.getMenuItemBorderRadius data.menuItemStyles))
    , Css.property "padding-block"
        (Css.px
            (Styles.getMenuItemBlockPadding data.menuItemStyles)
        ).value
    , Css.property "padding-inline" (Css.px (Styles.getMenuItemInlinePadding data.menuItemStyles)).value
    , Css.outline Css.none
    , Css.color (Styles.getMenuItemColor data.menuItemStyles)
    , Css.batch allStyles
    ]


indicatorContainerStyles : Styles.ControlConfig -> List Css.Style
indicatorContainerStyles cc =
    [ Css.displayFlex
    , Css.boxSizing Css.borderBox
    , Css.property "padding-block" (Css.px (Styles.getControlIndicatorPadding cc)).value
    , Css.property "padding-inline" (Css.px (Styles.getControlIndicatorPadding cc)).value
    ]


iconButtonStyles : List Css.Style
iconButtonStyles =
    [ Css.displayFlex
    , Css.backgroundColor Css.transparent
    , Css.property "padding-block" (Css.px 0).value
    , Css.property "padding-inline" (Css.px 0).value
    , Css.borderColor (Css.rgba 0 0 0 0)
    , Css.border (Css.px 0)
    , Css.color Css.inherit
    ]


menuMarginTop : Float
menuMarginTop =
    8


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
        controlHover
            (ControlHoverData
                (Styles.getMenuControlBackgroundColor styles)
                (Styles.getMenuControlBorderColorHover styles)
            )
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
                (Styles.getControlBorderColorHover styles)
            )
    ]
        ++ controlFocusedStyles


controlRadius : Float -> Css.Style
controlRadius rad =
    Css.borderRadius <| Css.px rad


controlBorder : Css.Color -> Css.Style
controlBorder cb =
    Css.property "box-shadow"
        ("rgb(255, 255, 255) 0px 0px 0px 0px inset,"
            ++ cb.value
            ++ " 0px 0px 0px 1px inset, rgba(0, 0, 0, 0.05) 0px 1px 2px 0px"
        )


controlBorderFocused : Css.Color -> Css.Style
controlBorderFocused bcf =
    Css.property "box-shadow"
        ("rgb(255, 255, 255) 0px 0px 0px 0px inset,"
            ++ bcf.value
            ++ " 0px 0px 0px 2px inset, rgba(0, 0, 0, 0.05) 0px 1px 2px 0px"
        )


controlDisabled : Float -> Css.Style
controlDisabled dsbOpac =
    Css.opacity (Css.num dsbOpac)


type alias ControlHoverData =
    { backgroundColorHover : Css.Color
    , borderColorHover : Css.Color
    }


controlHover : ControlHoverData -> Css.Style
controlHover styles =
    Css.hover
        [ Css.backgroundColor styles.backgroundColorHover
        , Css.borderColor styles.borderColorHover
        ]
