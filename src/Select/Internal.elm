module Select.Internal exposing (Direction(..), calculateNextActiveTarget, shouldQueryNextTargetElement)


type Direction
    = Up
    | Down


calculateNextActiveTarget : Int -> Int -> Direction -> Int
calculateNextActiveTarget currentTargetIndex totalTargetCount direction =
    case direction of
        Up ->
            if currentTargetIndex == 0 then
                0

            else if totalTargetCount < currentTargetIndex + 1 then
                0

            else
                currentTargetIndex - 1

        Down ->
            if currentTargetIndex + 1 == totalTargetCount then
                currentTargetIndex

            else if totalTargetCount < currentTargetIndex + 1 then
                0

            else
                currentTargetIndex + 1


shouldQueryNextTargetElement : Int -> Int -> Bool
shouldQueryNextTargetElement nextTargetIndex activeTargetIndex =
    nextTargetIndex /= activeTargetIndex
