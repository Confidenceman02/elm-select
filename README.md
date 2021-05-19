# elm-select
Select things in style! Inspired and built on top of Culture Amp's [Kaizen design system](https://cultureamp.design) select component. 

## Why not just use the Kaizen select?
1. The [Kaizen design system](https://cultureamp.design/) is a wonderful project with both react and elm components/views. To use the elm views in particular requires some tooling in your project. This is partly due to the Kaizen elm views being styled in scss and the way it loads assets like images. Your project would need to handle the scss by adding adding a transpiler as well as an asset loader. This package takes all the scss and images and converts it all to standard elm with the help of [rtfeldman/elm-css](https://package.elm-lang.org/packages/rtfeldman/elm-css/latest/).

2. The [Kaizen elm select](https://cultureamp.design/storybook/?path=/story/select-elm--multi-select-searchable) is largely a port of the [react select](https://react-select.com/home) project which is a widely used piece of work. Whilst this package matches most of the functionality of [react select]() and [Kaizen select](), it endeavours to implement the [wai aria](https://www.w3.org/TR/wai-aria-practices/examples/combobox/aria1.1pattern/listbox-combo.html) best practices for selects.

## Opt in JS optimizations
The [Kaizen elm select](https://cultureamp.design/storybook/?path=/story/select-elm--multi-select-searchable) has some JS performance optimisations that dynamically size the input width. There are some sensible reasons why this optimization was done.

First lets think about how we would dynamically resize an input node as someone types in elm. 
1. We would handle some sort of InputChanged message.
2. We would query the input node for its dimensions or decode its dimension information from the initial event.
3. We would update the size of the input.

Resizing an input dynamically using the above method ends up being not very performant. It is highly likely someone will experience a lag between them typing and the input resizing.

The [react select](https://react-select.com/home) project gets around this by using a [ref](https://reactjs.org/docs/refs-and-the-dom.html) whilst Kaizen select uses a mutation observer to handle the resizing.

Elm-select, much like the Kaizen select, uses a mutation observer which allows for a zero lag, peformant dynamically sized input.

If you don't want use a JS optimization thats totally ok! Elm-select handles dynamic width via the [size atribute](https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/size) by default. The size attribute is not an ideal solution despite the fact it mostly just works. Consider adding the very minimal JS in to your project to handle this.

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

