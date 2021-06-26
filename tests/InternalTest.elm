module InternalTest exposing (..)

import Expect
import Select.Internal exposing (..)
import Test exposing (Test, describe, test)


internal : Test
internal =
    describe "Internal functions"
        [ describe "calculateNextActiveTarget"
            [ test "Should calculate next active target with Down Direction" <|
                let
                    nextTarget =
                        calculateNextActiveTarget 1 4 Down
                in
                \() -> Expect.equal 2 nextTarget
            , test "Should calculate next active target with Up Direction" <|
                let
                    nextTarget =
                        calculateNextActiveTarget 1 4 Up
                in
                \() -> Expect.equal 0 nextTarget
            , test "Should calculate active target when current index is 0 and Direction is Up" <|
                let
                    nextTarget =
                        calculateNextActiveTarget 0 4 Up
                in
                \() -> Expect.equal 3 nextTarget
            ]
        , describe "shouldQueryNextTargetElement"
            [ test "should query the next target element when the next target index is not the current target index " <|
                \() -> Expect.equal (shouldQueryNextTargetElement 2 3) True
            , test "Should not query the next target element when the next target element is the current target index" <|
                \() -> Expect.equal (shouldQueryNextTargetElement 2 2) False
            ]
        ]
