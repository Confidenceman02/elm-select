module Select.Events exposing
    ( isDownArrow
    , isEnter
    , isEscape
    , isSpace
    , isTab
    , isTabWithShift
    , isUpArrow
    , onInputAt
    , onInputAtInt
    , onMultiSelect
    )

import Html.Styled exposing (Attribute)
import Html.Styled.Events exposing (keyCode, on)
import Json.Decode as Decode


type Key
    = Escape
    | UpArrow
    | DownArrow
    | Enter
    | Backspace
    | Space
    | Shift
    | Tab
    | Other


decoder : Int -> Key
decoder =
    keyCodeToKey


backspace : Int
backspace =
    8


tab : Int
tab =
    9


enter : Int
enter =
    13


escape : Int
escape =
    27


upArrow : Int
upArrow =
    38


downArrow : Int
downArrow =
    40


space : Int
space =
    32


shift : Int
shift =
    16


stringAt : List String -> Decode.Decoder String
stringAt path =
    Decode.at path Decode.string


intAt : List String -> Decode.Decoder Int
intAt path =
    Decode.at path Decode.int


mapAt : List String -> (String -> msg) -> Decode.Decoder msg
mapAt path msg =
    Decode.map msg (stringAt path)


mapAtInt : List String -> (Int -> msg) -> Decode.Decoder msg
mapAtInt path msg =
    Decode.map msg (intAt path)


keyCodeToKey : Int -> Key
keyCodeToKey keyCode =
    if keyCode == escape then
        Escape

    else if keyCode == backspace then
        Backspace

    else if keyCode == upArrow then
        UpArrow

    else if keyCode == downArrow then
        DownArrow

    else if keyCode == enter then
        Enter

    else if keyCode == space then
        Space

    else if keyCode == shift then
        Shift

    else if keyCode == tab then
        Tab

    else
        Other


onMultiSelect : (List Int -> msg) -> Attribute msg
onMultiSelect msg =
    on "input"
        (intAt [ "target", "selectedOptions", "length" ]
            |> Decode.andThen (optionsAt msg)
        )


optionsAt : (List Int -> msg) -> Int -> Decode.Decoder msg
optionsAt msg l =
    let
        map1 : List Int -> Int -> List Int
        map1 acc v =
            acc ++ [ v ]

        map2 : List Int -> Int -> Int -> List Int
        map2 acc v1 v2 =
            acc ++ [ v1, v2 ]

        map3 : List Int -> Int -> Int -> Int -> List Int
        map3 acc v1 v2 v3 =
            acc ++ [ v1, v2, v3 ]

        map4 : List Int -> Int -> Int -> Int -> Int -> List Int
        map4 acc v1 v2 v3 v4 =
            acc ++ [ v1, v2, v3, v4 ]

        map5 : List Int -> Int -> Int -> Int -> Int -> Int -> List Int
        map5 acc v1 v2 v3 v4 v5 =
            acc ++ [ v1, v2, v3, v4, v5 ]

        map6 : List Int -> Int -> Int -> Int -> Int -> Int -> Int -> List Int
        map6 acc v1 v2 v3 v4 v5 v6 =
            acc ++ [ v1, v2, v3, v4, v5, v6 ]

        map7 : List Int -> Int -> Int -> Int -> Int -> Int -> Int -> Int -> List Int
        map7 acc v1 v2 v3 v4 v5 v6 v7 =
            acc ++ [ v1, v2, v3, v4, v5, v6, v7 ]

        map8 : List Int -> Int -> Int -> Int -> Int -> Int -> Int -> Int -> Int -> List Int
        map8 acc v1 v2 v3 v4 v5 v6 v7 v8 =
            acc ++ [ v1, v2, v3, v4, v5, v6, v7, v8 ]

        mapOptions : Int -> Int -> List Int -> Decode.Decoder (List Int)
        mapOptions total ix acc =
            let
                stringIndex offset =
                    String.fromInt (ix + offset)

                newTotal =
                    total - 8

                newIndex =
                    ix + 8
            in
            case total of
                1 ->
                    Decode.map (map1 acc) (intAt [ "target", "selectedOptions", stringIndex 0, "index" ])

                2 ->
                    Decode.map2 (map2 acc)
                        (intAt [ "target", "selectedOptions", stringIndex 0, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 1, "index" ])

                3 ->
                    Decode.map3 (map3 acc)
                        (intAt [ "target", "selectedOptions", stringIndex 0, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 1, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 2, "index" ])

                4 ->
                    Decode.map4 (map4 acc)
                        (intAt [ "target", "selectedOptions", stringIndex 0, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 1, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 2, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 3, "index" ])

                5 ->
                    Decode.map5 (map5 acc)
                        (intAt [ "target", "selectedOptions", stringIndex 0, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 1, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 2, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 3, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 4, "index" ])

                6 ->
                    Decode.map6 (map6 acc)
                        (intAt [ "target", "selectedOptions", stringIndex 0, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 1, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 2, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 3, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 4, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 5, "index" ])

                7 ->
                    Decode.map7 (map7 acc)
                        (intAt [ "target", "selectedOptions", stringIndex 0, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 1, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 2, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 3, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 4, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 5, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 6, "index" ])

                8 ->
                    Decode.map8 (map8 acc)
                        (intAt [ "target", "selectedOptions", stringIndex 0, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 1, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 2, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 3, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 4, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 5, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 6, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 7, "index" ])

                _ ->
                    Decode.map8 (map8 acc)
                        (intAt [ "target", "selectedOptions", stringIndex 0, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 1, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 2, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 3, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 4, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 5, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 6, "index" ])
                        (intAt [ "target", "selectedOptions", stringIndex 7, "index" ])
                        |> Decode.andThen
                            (\x -> mapOptions newTotal newIndex x)
    in
    if l == 0 then
        Decode.fail "No selected options"

    else
        mapOptions l 0 []
            |> Decode.andThen (msg >> Decode.succeed)


onInputAt : List String -> (String -> msg) -> Attribute msg
onInputAt path msg =
    on "input" <| mapAt path msg


onInputAtInt : List String -> (Int -> msg) -> Attribute msg
onInputAtInt path msg =
    on "input" <| mapAtInt path msg


isCode : Key -> msg -> Int -> Decode.Decoder msg
isCode key msg code =
    if decoder code == key then
        Decode.succeed msg

    else
        Decode.fail "not the right key"


isEnter : msg -> Decode.Decoder msg
isEnter msg =
    keyCode |> Decode.andThen (isCode Enter msg)


isSpace : msg -> Decode.Decoder msg
isSpace msg =
    keyCode |> Decode.andThen (isCode Space msg)


isEscape : msg -> Decode.Decoder msg
isEscape msg =
    keyCode |> Decode.andThen (isCode Escape msg)


isTabWithShift : (Bool -> msg) -> Decode.Decoder msg
isTabWithShift msg =
    Decode.field "shiftKey" Decode.bool
        |> Decode.map2
            (\_ isShift ->
                msg isShift
            )
            (keyCode |> Decode.andThen (isCode Tab (msg True)))


isTab : msg -> Decode.Decoder msg
isTab msg =
    keyCode |> Decode.andThen (isCode Tab msg)


isDownArrow : msg -> Decode.Decoder msg
isDownArrow msg =
    keyCode |> Decode.andThen (isCode DownArrow msg)


isUpArrow : msg -> Decode.Decoder msg
isUpArrow msg =
    keyCode |> Decode.andThen (isCode UpArrow msg)
