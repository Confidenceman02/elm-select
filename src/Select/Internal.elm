module Select.Internal exposing
    ( BaseMenuItem
    , Direction(..)
    , Group
    , InitialAction(..)
    , UiFocused(..)
    , calculateNextActiveTarget
    , shouldQueryNextTargetElement
    , viewIf
    )

import Html.Styled as Styled
import Select.Styles exposing (GroupConfig, MenuItemConfig)


type Direction
    = Up
    | Down


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


type alias BaseMenuItem comparable =
    { comparable
        | filterable : Bool
        , styles : Maybe MenuItemConfig
        , group : Maybe Group
    }


type alias Group =
    { name : String
    , styles : Maybe GroupConfig
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
