# elm-select
Select things in style! Inspired and built on top of Culure Amp's [Kaizen design system](https://cultureamp.design) select component. 

## Why not just use the Kaizen select?
1. The [Kaizen design system](https://cultureamp.design/) is a wonderful project with both react and elm components/views. To use the elm views in particular requires some tooling in your project. This is partly due to the Kaizen elm views being styled in scss. Your project would need to handle the scss by adding adding a transpiler. This package takes all the scss and converts it to css written with the very excellent [rtfeldman/elm-css](https://package.elm-lang.org/packages/rtfeldman/elm-css/latest/).

2. The [Kaizen elm select](https://cultureamp.design/storybook/?path=/story/select-elm--multi-select-searchable) is largely a port of [react select](https://react-select.com/home). Whilst [react select](https://react-select.com/home) is a widely used piece of work, I took the opportunity Instead to follow the wai aria best practices by using a [combobox](https://www.w3.org/TR/wai-aria-practices/examples/combobox/aria1.1pattern/listbox-combo.html) design pattern.

## Opt in JS optimizations
The [Kaizen elm select](https://cultureamp.design/storybook/?path=/story/select-elm--multi-select-searchable) has some performance optimisations that are triggered via ports to autosize the input width. There are some sensible reasons why this optimisation was done.

First lets think about how we would dynamically resize an input tag as someone types in elm. 
1. We would receive a InputChanged message.
2. We would query the element for its size or decode its dimension information from an onchange event.
3. We would update the size of the input.

Both Querying the DOM and the onchange event are slow ways to dynamically size the input whilst someone types.
This lag is even more obvious if the person typing is a top notch typist!

The react-select component gets around this by using references (fast). 
Kaizen select dispatches a port and leverages a mutation observer to handle the resizing (fast). 

The solution elm-select takes is more like the Kaizen method under the hood minus the ports. 

If you don't want use a JS optimization thats totally ok! Elm-select handles dynamic width via the [size atribute](https://www.w3schools.com/tags/att_size.asp) by default. There are some drawbacks to using the size attribute as it's really not intended to be used that way.

__Opt in to JS optimization__
```elm

{selectState = initState |> jsOptimise True}
```

```javascript

-- index.js 
import { Elm } from "./src/Main";
import dynamicSelectInput from "elm-select"

dynamicSelectInput()

Elm.Main.init({node, flags})
```
This will handle any number of selects on the same page.

## Usage
__Set an initial state__ in your model.

```elm
init : Model
init = initialState (uniqueContainerId "123")
```

__Set up an update `Msg`__ in your update function.

```elm
    update : Msg -> State -> (State, Cmd Msg)
    update msg state =
        AnimateMsg animMsg ->
            let
                (newState, cmds) = update model.animState
            in
            ({ model | animState = newState }, Cmd.map AnimateHeight cmds)

```

__Render your view__ in the `AnimateHeight` container.

```elm
someCoolView : Html Msg
someCoolView : 
    -- cool view stuff --
    
view : Model -> Msg
view model =
  container 
    (default 
      |> content someCoolView
      |> state model.animHeightState
     )
```

