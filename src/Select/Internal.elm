module Select.Internal exposing
    ( BaseMenuItem
    , Direction(..)
    , Group
    , InitialAction(..)
    , LengthOrNoneOrMinMaxDimension(..)
    , UiFocused(..)
    , VirtualItemConfig
    , ariaActiveDescendant
    , ariaControls
    , ariaDescribedby
    , ariaExpanded
    , ariaHasPopup
    , ariaLabelledby
    , ariaSelected
    , calculateNextActiveTarget
    , illegalChars
    , removeIllegalChars
    , role
    , shouldQueryNextTargetElement
    , viewIf
    )

import Css
import Html.Styled as Styled
import Html.Styled.Attributes exposing (attribute)


type Direction
    = Up
    | Down


type LengthOrNoneOrMinMaxDimension
    = Px (Css.LengthOrNoneOrMinMaxDimension Css.Px)
    | Vh (Css.LengthOrNoneOrMinMaxDimension Css.Vh)


illegalChars : String
illegalChars =
    "' '/\\?\t\n\u{000D}%"


removeIllegalChars : String -> String
removeIllegalChars =
    let
        withEmpty x =
            if List.isEmpty x then
                [ '_' ]

            else
                x
    in
    String.toList
        >> withEmpty
        >> List.foldr
            (\s acc ->
                if String.contains (String.fromChar s) illegalChars then
                    String.cons '_' acc

                else
                    String.cons s acc
            )
            ""


calculateNextActiveTarget : Int -> Int -> Direction -> Int
calculateNextActiveTarget currentTargetIndex totalTargetCount direction =
    case direction of
        Up ->
            if currentTargetIndex == 0 then
                -- active target is last item
                totalTargetCount - 1

            else if totalTargetCount < currentTargetIndex + 1 then
                0

            else
                currentTargetIndex - 1

        Down ->
            -- active target is first item
            if currentTargetIndex + 1 == totalTargetCount then
                0

            else if totalTargetCount < currentTargetIndex + 1 then
                0

            else
                currentTargetIndex + 1


shouldQueryNextTargetElement : Int -> Int -> Bool
shouldQueryNextTargetElement nextTargetIndex activeTargetIndex =
    nextTargetIndex /= activeTargetIndex


nothing : Styled.Html msg
nothing =
    Styled.text ""


viewIf : Bool -> Styled.Html msg -> Styled.Html msg
viewIf condition html =
    if condition then
        html

    else
        nothing



-- Aria


{-| Indicates the availability and type of interactive popup element, such as menu or dialog, that can be triggered by an element.
See the [official specs](https://www.w3.org/TR/wai-aria-1.1/#aria-haspopup).

    div [ ariaHasPopup "menu" ] [ text "Hello aria!" ]

-}
ariaHasPopup : String -> Styled.Attribute msg
ariaHasPopup =
    attribute "aria-haspopup"


{-| Indicates whether the element, or another grouping element it controls, is currently expanded or collapsed.
See the [official specs](https://www.w3.org/TR/wai-aria-1.1/#aria-expanded).

    div [ ariaExpanded "true" ] [ text "Hello aria!" ]

-}
ariaExpanded : String -> Styled.Attribute msg
ariaExpanded =
    attribute "aria-expanded"


{-| Identifies the element (or elements) whose contents or presence are controlled by the current element.
See the [official specs](https://www.w3.org/TR/wai-aria-1.1/#aria-controls).

    div [ ariaControls "dropdown-menu" ] [ text "Hello aria!" ]

-}
ariaControls : String -> Styled.Attribute msg
ariaControls =
    attribute "aria-controls"


ariaSelected : String -> Styled.Attribute msg
ariaSelected =
    attribute "aria-selected"


role : String -> Styled.Attribute msg
role =
    attribute "role"


{-| Identifies the element (or elements) that labels the current element.
See the [official specs](https://www.w3.org/TR/wai-aria-1.1/#aria-labelledby).

    div [ ariaLabelledby "id" ] [ text "Hello aria!" ]

-}
ariaLabelledby : String -> Styled.Attribute msg
ariaLabelledby =
    attribute "aria-labelledby"


{-| Identifies the element (or elements) that describes the object.
See the [official specs](https://www.w3.org/TR/wai-aria-1.1/#aria-describedby).

    div [ ariaDescribedby "id" ] [ text "Hello aria!" ]

-}
ariaDescribedby : String -> Styled.Attribute msg
ariaDescribedby =
    attribute "aria-describedby"


{-| Identifies the currently active descendant of a composite widget.
See the [official specs](https://www.w3.org/TR/wai-aria-1.1/#aria-activedescendant).

    div [ ariaActiveDescendant "id" ] [ text "Hello aria!" ]

-}
ariaActiveDescendant : String -> Styled.Attribute msg
ariaActiveDescendant =
    attribute "aria-activedescendant"


type alias VirtualItemConfig =
    { index : Int
    , height : Float
    }


type alias BaseMenuItem comparable groupConfig stylesConfig =
    { comparable
        | filterable : Bool
        , dismissible : Bool
        , styles : Maybe stylesConfig
        , group : Maybe (Group groupConfig)
        , value : Maybe String
        , virtualConfig : Maybe VirtualItemConfig
    }


type alias Group config =
    { name : String
    , styles : Maybe config
    , view : Maybe (Styled.Html Never)
    }


type UiFocused
    = ControlInput
    | Clearable


type InitialAction
    = MultiItemMousedown Int
    | MenuItemMousedown Int
    | ContainerMousedown
    | NothingMousedown
