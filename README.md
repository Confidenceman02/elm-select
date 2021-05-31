# elm-select
Select things in style! Inspired and built on top of Culture Amp's [Kaizen design system](https://cultureamp.design) select component. 

## Why not just use the Kaizen select?
1. The [Kaizen design system](https://cultureamp.design/) is a wonderful project with both react and elm components/views. To use the elm views in particular requires some tooling in your project. This is partly due to the Kaizen elm views being styled in scss and the way it loads assets. Your project would need to handle the scss by adding a transpiler as well as an asset loader. This package takes the scss and svg's and converts it all to standard elm with the help of [rtfeldman/elm-css](https://package.elm-lang.org/packages/rtfeldman/elm-css/latest/).

2. The [Kaizen elm select](https://cultureamp.design/storybook/?path=/story/select-elm--multi-select-searchable) is largely a port of the [react select](https://react-select.com/home) project which is a widely used piece of work. Whilst this package matches most of the functionality of [react select]() and [Kaizen select](), it endeavours to implement the [WAI aria](https://www.w3.org/TR/wai-aria-practices/examples/combobox/aria1.1pattern/listbox-combo.html) best practices for select accessibility.

## Opt in JS optimizations
The [Kaizen elm select](https://cultureamp.design/storybook/?path=/story/select-elm--multi-select-searchable) has some JS performance optimisations that dynamically size the input width. There are some sensible reasons why this optimization was done.

First lets think about how we would dynamically resize an input node as someone types in elm. 
1. We would handle some sort of InputChanged message.
2. We would query the input node for its dimensions or decode its dimension information from the initial event.
3. We would update the size of the input.

Resizing an input dynamically using the above method ends up being not very performant. It is highly likely someone will experience a lag between them typing and the input resizing.

The [react select](https://react-select.com/home) project gets around this by using a [ref](https://reactjs.org/docs/refs-and-the-dom.html) whilst Kaizen select uses a mutation observer to handle the resizing.

When you opt in to JS optimization, elm-select uses a mutation observer which allows for a zero lag, performant, dynamically sized input.

If you don't want use a JS optimization thats totally ok! Elm-select handles dynamic width via the [size atribute](https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/size) by default. The size attribute is not an ideal solution despite the fact it mostly just works. Consider adding the very minimal JS in to your project to get the best performance.

NOTE: It doesn't matter how many `elm-select`'s you render, on the page. The javascript included will detect and handle all of them.

__Opt in to JS optimization__
```elm

{ selectState = initState |> jsOptimize True }
```

```javascript

-- index.js 
import { Elm } from "./src/Main";
import dynamicElmSelectInput from "elm-select"

dynamicElmSelectInput()

Elm.Main.init({node, flags})
```

## Configurable styles
Out of the box `elm-select` makes some styling decisions that may not suit your branding or taste. In order to be flexible, `elm-select` lets you tweak things to your liking either through you're own elm CSS or values it exposes.
Things you can tweak include 
```
Multi variant selected tag
Focus ring color
Menu item hover color
Menu item selected color
```

## Modular elements
For the ultimate control on how things look `elm-select` lets you completely replace certain elements with your own views. Perhaps you want to completely customise how the menu items look with react components?
Opting in to this does require some javascript but the `elm-select` package provides helpers to do this.

## Usage
__Set an initial state__ in your model.

```elm
init : Model
init = 
    {  selectState = initState
    ,  items = []
    }
```

__Set up an update `Msg`__ in your update function.

```elm
    update : Msg -> Model -> (Model, Cmd Msg)
    update msg model =
        SelectMsg selectMsg ->
            let
                (action, selectState, selectCmds) = update selectMsg model.selectState
            in
            ({ model | selectState = selectState }, Cmd.map SelectMsg selectCmds)

```

__Handle the `Action`__ in your update function.

```elm
    update : Msg -> Model -> (Model, Cmd Msg)
    update msg model =
        SelectMsg selectMsg ->
            let
                (maybeAction, selectState, selectCmds) = update selectMsg model.selectState

                handledAction =
                    case maybeAction of 
                        -- an item has been selected
                        Just Select item ->
                            -- handle selected item
                        -- Clear single select selection
                        Just ClearSingleSelectItem item ->
                            -- handle cleared item
                        -- Multi item has been deselected
                        Just DeselectMultiItem ->
                            -- handle deselected multi item
                        -- Input value has changed
                        Just InputChange value ->
                            -- handle changed input
                        _ ->
                          -- no action
            in
            -- (model, Cmd Msg)
```

__Render your view__.

```elm
view : Model -> Msg
view model =
  Select.view 
      (Select.single Nothing)
          |> Select.state model.selectState
          |> Select.menuItems model.items
          |> Select.placeholder "Placeholder"
      )
      (selectIdentifier "SingleSelectExample")
```

