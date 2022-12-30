module Chapters.Welcome exposing (Model, init, welcomeChapter)

import Css
import ElmBook.Actions exposing (mapUpdateWithCmd)
import ElmBook.Chapter exposing (chapter, render, withStatefulComponentList)
import ElmBook.ElmCSS exposing (Chapter)
import Html.Styled as Styled exposing (Html, div, input, label, text)
import Html.Styled.Attributes as Attribs exposing (type_)
import Html.Styled.Events exposing (onCheck)
import Select


type Msg
    = SingleMsg (SingleMsg Color)
    | MultiMsg MultiMsg
    | SingleNativeMsg NativeMsg
    | SingleGroupedMsg (SingleMsg Group)


type MultiMsg
    = MultiSelectMsg (Select.Msg Color)
    | MultiModifierMsg ModifierMsg


type NativeMsg
    = SingleNativeSelectMsg (Select.Msg Color)
    | SingleNativeModifierMsg ModifierMsg


type SingleMsg item
    = SingleSelectMsg (Select.Msg item)
    | SingleModifierMsg ModifierMsg


type ModifierMsg
    = Clearable Bool
    | Searchable Bool
    | Disabled Bool
    | Loading Bool


type Color
    = Ocean
    | Blue
    | Purple
    | Red
    | Orange
    | Yellow
    | Green
    | Forrest
    | Slate
    | Silver


type Flavour
    = Vanilla
    | Chocolate
    | Strawberry
    | SaltedCaramel


type Group
    = Color_ Color
    | Flavour_ Flavour


colorGroup : Select.Group
colorGroup =
    Select.group "color"


flavorGroup : Select.Group
flavorGroup =
    Select.group "flavour"


type alias SelectModel selected item =
    { state : Select.State
    , items : List item
    , selected : selected
    , clearable : Bool
    , searchable : Bool
    , disabled : Bool
    , loading : Bool
    }


type alias Model =
    { single :
        SelectModel (Maybe Color) Color
    , singleGrouped : SelectModel (Maybe Group) Group
    , multi : SelectModel (List Color) Color
    , singleNative : SelectModel (Maybe Color) Color
    }


type alias SharedState x =
    { x | welcomeState : Model }


init : Model
init =
    { single =
        { state = Select.initState (Select.selectIdentifier "single")
        , items =
            colors
        , selected = Nothing
        , clearable = False
        , searchable = False
        , disabled = False
        , loading = False
        }
    , singleGrouped =
        { state = Select.initState (Select.selectIdentifier "single-grouped")
        , items =
            groups
        , selected = Nothing
        , clearable = False
        , searchable = False
        , disabled = False
        , loading = False
        }
    , multi =
        { state = Select.initState (Select.selectIdentifier "multi")
        , items = colors
        , selected = []
        , clearable = False
        , searchable = False
        , disabled = False
        , loading = False
        }
    , singleNative =
        { state = Select.initState (Select.selectIdentifier "single-native")
        , items =
            colors
        , selected = Nothing
        , clearable = False
        , searchable = False
        , disabled = False
        , loading = False
        }
    }


colors : List Color
colors =
    [ Ocean
    , Blue
    , Purple
    , Red
    , Orange
    , Yellow
    , Green
    , Forrest
    , Slate
    , Silver
    ]


flavours : List Flavour
flavours =
    [ Vanilla
    , Chocolate
    , Strawberry
    , SaltedCaramel
    ]


groups : List Group
groups =
    [ Color_ Ocean
    , Color_ Blue
    , Color_ Purple
    , Color_ Red
    , Color_ Orange
    , Color_ Yellow
    , Color_ Green
    , Color_ Forrest
    , Color_ Slate
    , Color_ Silver
    , Flavour_ Vanilla
    , Flavour_ Chocolate
    , Flavour_ Strawberry
    , Flavour_ SaltedCaramel
    ]


colorToItem : Color -> Select.MenuItem Color
colorToItem clr =
    case clr of
        Ocean ->
            Select.basicMenuItem { item = clr, label = "Ocean" }

        Blue ->
            Select.basicMenuItem { item = clr, label = "Blue" }

        Purple ->
            Select.basicMenuItem { item = clr, label = "Purple" }

        Red ->
            Select.basicMenuItem { item = clr, label = "Red" }

        Orange ->
            Select.basicMenuItem { item = clr, label = "Orange" }

        Yellow ->
            Select.basicMenuItem { item = clr, label = "Yellow" }

        Green ->
            Select.basicMenuItem { item = clr, label = "Green" }

        Forrest ->
            Select.basicMenuItem { item = clr, label = "Forrest" }

        Slate ->
            Select.basicMenuItem { item = clr, label = "Slate" }

        Silver ->
            Select.basicMenuItem { item = clr, label = "Silver" }


groupToGroupedItem : Group -> Select.MenuItem Group
groupToGroupedItem gr =
    case gr of
        Color_ clr ->
            colourToGroupedItem clr

        Flavour_ fl ->
            flavourToGroupedItem fl


colourToGroupedItem : Color -> Select.MenuItem Group
colourToGroupedItem clr =
    case clr of
        Ocean ->
            itemToGroupedItem colorGroup (Select.basicMenuItem { item = Color_ clr, label = "Ocean" })

        Blue ->
            itemToGroupedItem colorGroup (Select.basicMenuItem { item = Color_ clr, label = "Blue" })

        Purple ->
            itemToGroupedItem colorGroup (Select.basicMenuItem { item = Color_ clr, label = "Purple" })

        Red ->
            itemToGroupedItem colorGroup (Select.basicMenuItem { item = Color_ clr, label = "Red" })

        Orange ->
            itemToGroupedItem colorGroup (Select.basicMenuItem { item = Color_ clr, label = "Orange" })

        Yellow ->
            itemToGroupedItem colorGroup (Select.basicMenuItem { item = Color_ clr, label = "Yellow" })

        Green ->
            itemToGroupedItem colorGroup (Select.basicMenuItem { item = Color_ clr, label = "Green" })

        Forrest ->
            itemToGroupedItem colorGroup (Select.basicMenuItem { item = Color_ clr, label = "Forrest" })

        Slate ->
            itemToGroupedItem colorGroup (Select.basicMenuItem { item = Color_ clr, label = "Slate" })

        Silver ->
            itemToGroupedItem colorGroup (Select.basicMenuItem { item = Color_ clr, label = "Silver" })


flavourToGroupedItem : Flavour -> Select.MenuItem Group
flavourToGroupedItem fl =
    case fl of
        Vanilla ->
            itemToGroupedItem flavorGroup (Select.basicMenuItem { item = Flavour_ fl, label = "Vanilla" })

        Chocolate ->
            itemToGroupedItem flavorGroup (Select.basicMenuItem { item = Flavour_ fl, label = "Chocolate" })

        Strawberry ->
            itemToGroupedItem flavorGroup (Select.basicMenuItem { item = Flavour_ fl, label = "Strawberry" })

        SaltedCaramel ->
            itemToGroupedItem flavorGroup (Select.basicMenuItem { item = Flavour_ fl, label = "Salted Caramel" })


itemToGroupedItem : Select.Group -> Select.MenuItem item -> Select.MenuItem item
itemToGroupedItem grp mi =
    Select.groupedMenuItem grp mi


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SingleNativeMsg (SingleNativeSelectMsg msg2) ->
            let
                ( maybeAction, updatedSelect, cmds ) =
                    Select.update msg2 model.singleNative.state

                selected =
                    case maybeAction of
                        Just (Select.Select clr) ->
                            Just clr

                        Just Select.ClearSingleSelectItem ->
                            Nothing

                        _ ->
                            model.singleNative.selected

                singleState =
                    model.singleNative
            in
            ( { model
                | singleNative =
                    { singleState
                        | state = updatedSelect
                        , selected = selected
                    }
              }
            , Cmd.map (SingleNativeSelectMsg >> SingleNativeMsg) cmds
            )

        SingleNativeMsg (SingleNativeModifierMsg mdf) ->
            ( { model | singleNative = updateModifier mdf model.singleNative }, Cmd.none )

        SingleMsg (SingleSelectMsg msg2) ->
            let
                ( maybeAction, updatedSelect, cmds ) =
                    Select.update msg2 model.single.state

                selected =
                    case maybeAction of
                        Just (Select.Select clr) ->
                            Just clr

                        Just Select.ClearSingleSelectItem ->
                            Nothing

                        _ ->
                            model.single.selected

                singleState =
                    model.single
            in
            ( { model
                | single =
                    { singleState
                        | state = updatedSelect
                        , selected = selected
                    }
              }
            , Cmd.map (SingleSelectMsg >> SingleMsg) cmds
            )

        SingleMsg (SingleModifierMsg mdf) ->
            ( { model | single = updateModifier mdf model.single }, Cmd.none )

        SingleGroupedMsg (SingleSelectMsg msg2) ->
            let
                ( maybeAction, updatedSelect, cmds ) =
                    Select.update msg2 model.singleGrouped.state

                selected =
                    case maybeAction of
                        Just (Select.Select clr) ->
                            Just clr

                        Just Select.ClearSingleSelectItem ->
                            Nothing

                        _ ->
                            model.singleGrouped.selected

                singleGroupedState =
                    model.singleGrouped
            in
            ( { model
                | singleGrouped =
                    { singleGroupedState
                        | state = updatedSelect
                        , selected = selected
                    }
              }
            , Cmd.map (SingleSelectMsg >> SingleGroupedMsg) cmds
            )

        SingleGroupedMsg (SingleModifierMsg mdf) ->
            ( { model | singleGrouped = updateModifier mdf model.singleGrouped }, Cmd.none )

        MultiMsg (MultiModifierMsg mdf) ->
            ( { model | multi = updateModifier mdf model.multi }, Cmd.none )

        MultiMsg (MultiSelectMsg msg2) ->
            let
                ( maybeAction, updatedSelect, cmds ) =
                    Select.update msg2 model.multi.state

                updatedSelected =
                    case maybeAction of
                        Just (Select.Select clr) ->
                            model.multi.selected ++ [ clr ]

                        Just (Select.DeselectMulti deselectedItems) ->
                            List.filter (\c -> not (List.member c deselectedItems)) model.multi.selected

                        _ ->
                            model.multi.selected

                multiState =
                    model.multi
            in
            ( { model
                | multi =
                    { multiState
                        | state = updatedSelect
                        , selected = updatedSelected
                    }
              }
            , Cmd.map (MultiMsg << MultiSelectMsg) cmds
            )


updateModifier : ModifierMsg -> SelectModel variant item -> SelectModel variant item
updateModifier msg model =
    case msg of
        Clearable pred ->
            { model | clearable = pred }

        Searchable pred ->
            { model | searchable = pred }

        Disabled pred ->
            { model | disabled = pred }

        Loading pred ->
            { model | loading = pred }


singleExample : SelectModel (Maybe Color) Color -> Html Msg
singleExample model =
    withModifiers (SingleMsg << SingleModifierMsg)
        [ Select.view
            (Select.single (Maybe.map colorToItem model.selected)
                |> Select.state model.state
                |> Select.clearable model.clearable
                |> Select.searchable model.searchable
                |> Select.disabled model.disabled
                |> Select.loading model.loading
                |> Select.menuItems
                    (List.map colorToItem model.items)
            )
            |> Styled.map (SingleSelectMsg >> SingleMsg)
        ]


singleGroupedExample : SelectModel (Maybe Group) Group -> Html Msg
singleGroupedExample model =
    withModifiers (SingleGroupedMsg << SingleModifierMsg)
        [ Select.view
            (Select.single (Maybe.map groupToGroupedItem model.selected)
                |> Select.state model.state
                |> Select.clearable model.clearable
                |> Select.searchable model.searchable
                |> Select.disabled model.disabled
                |> Select.loading model.loading
                |> Select.menuItems
                    (List.map groupToGroupedItem model.items)
            )
            |> Styled.map (SingleSelectMsg >> SingleGroupedMsg)
        ]


multiExample : SelectModel (List Color) Color -> Html Msg
multiExample model =
    withModifiers (MultiMsg << MultiModifierMsg)
        [ Select.view
            (Select.multi (List.map colorToItem model.selected)
                |> Select.state model.state
                |> Select.clearable model.clearable
                |> Select.searchable model.searchable
                |> Select.disabled model.disabled
                |> Select.loading model.loading
                |> Select.menuItems
                    (List.map colorToItem model.items)
            )
            |> Styled.map (MultiMsg << MultiSelectMsg)
        ]


nativeExample : SelectModel (Maybe Color) Color -> Html Msg
nativeExample model =
    withModifiers (SingleNativeMsg << SingleNativeModifierMsg)
        [ Select.view
            (Select.singleNative (Maybe.map colorToItem model.selected)
                |> Select.state model.state
                |> Select.clearable model.clearable
                |> Select.disabled model.disabled
                |> Select.loading model.loading
                |> Select.menuItems
                    (List.map colorToItem model.items)
            )
            |> Styled.map (SingleNativeSelectMsg >> SingleNativeMsg)
        ]


withModifiers : (ModifierMsg -> Msg) -> List (Html Msg) -> Html Msg
withModifiers inject content =
    div
        []
        (content
            ++ [ div
                    [ Attribs.css
                        [ Css.color (Css.rgb 102 102 102)
                        , Css.displayFlex
                        , Css.property "gap" (Css.rem 0.5).value
                        , Css.fontSize (Css.px 12)
                        , Css.fontStyle Css.italic
                        , Css.marginTop (Css.rem 0.5)
                        ]
                    ]
                    [ label
                        [ Attribs.css
                            [ Css.displayFlex
                            , Css.alignItems Css.center
                            ]
                        ]
                        [ input [ type_ "checkbox", onCheck (inject << Clearable) ] [], text "Clearable" ]
                    , label
                        [ Attribs.css
                            [ Css.displayFlex
                            , Css.alignItems Css.center
                            ]
                        ]
                        [ input [ type_ "checkbox", onCheck (inject << Searchable) ] [], text "Searchable" ]
                    , label
                        [ Attribs.css
                            [ Css.displayFlex
                            , Css.alignItems Css.center
                            ]
                        ]
                        [ input [ type_ "checkbox", onCheck (inject << Disabled) ] [], text "Disabled" ]
                    , label
                        [ Attribs.css
                            [ Css.displayFlex
                            , Css.alignItems Css.center
                            ]
                        ]
                        [ input [ type_ "checkbox", onCheck (inject << Loading) ] [], text "Loading" ]
                    ]
               ]
        )


bookUpdate :
    { toState : SharedState x -> Model -> SharedState x
    , fromState : SharedState x -> Model
    , update : Msg -> Model -> ( Model, Cmd Msg )
    }
bookUpdate =
    { toState = \state m -> { state | welcomeState = m }
    , fromState = .welcomeState
    , update = update
    }


welcomeChapter : Chapter (SharedState x)
welcomeChapter =
    chapter "Welcome"
        |> withStatefulComponentList
            [ ( "Single"
              , \{ welcomeState } ->
                    singleExample welcomeState.single
                        |> Styled.map
                            (mapUpdateWithCmd
                                bookUpdate
                            )
              )
            , ( "Single grouped"
              , \{ welcomeState } ->
                    singleGroupedExample welcomeState.singleGrouped
                        |> Styled.map
                            (mapUpdateWithCmd
                                bookUpdate
                            )
              )
            , ( "Multi"
              , \{ welcomeState } ->
                    multiExample welcomeState.multi
                        |> Styled.map
                            (mapUpdateWithCmd bookUpdate)
              )
            , ( "Native (Single)"
              , \{ welcomeState } ->
                    nativeExample welcomeState.singleNative
                        |> Styled.map
                            (mapUpdateWithCmd bookUpdate)
              )
            ]
        |> render """
This project provides interactive examples for the [Confidenceman02/elm-select](https://package.elm-lang.org/packages/Confidenceman02/elm-select/latest/) package.

To contribute, or open an issue, check out the [source code on GitHub](https://github.com/Confidenceman02/elm-select/tree/6.0.1)

---
The single variant lets you select single items.

<component with-label="Single" />

---

<component with-label="Single grouped" />

---
The multi variant lets you select multiple items.

<component with-label="Multi" />


---
The native single variant lets you select single items.

<component with-label="Native (Single)" />


"""
