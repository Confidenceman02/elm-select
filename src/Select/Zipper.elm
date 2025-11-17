module Select.Zipper exposing (Zipper, findZipper, findZipperBy, fromZipper)

{-| Zippers are a way of denoting a special point in a data structure.

A normal list makes the first element directly accessible, but the rest take O(n) to reach.
A zipper splits up a (non-empty) list into a "point", which is the element of
the list which can be reached in constant time, the elements to the left, and
the elements to the right.

The idea is you can walk "point" around in constant time, by adjusting the items.

So take the right-most element in the left list of elements and make it point, and put the current point as the left-most
element of the elements on the right.

Think of something like a highlighted selection in a game's menu screen.

For more: <https://en.wikipedia.org/wiki/Zipper_(data_structure)>

-}


type alias Zipper a =
    ( List a, a, List a )


findZipperBy : (a -> k) -> k -> List a -> Maybe (Zipper a)
findZipperBy f k =
    findZipper (\x -> bool Nothing (Just x) (f x == k))
        >> Maybe.map Tuple.second


{-| Find an element that satisfied a predicate, and return the predicate result
along with a Zipper focused on the item that satisfied the predicate.

To reconstruct the original list you would write

    case findZipper pred xs of
        Just ( _, ( ls, x, rs ) ) ->
            reverse ls ++ x :: rs

        Nothing ->
            xs

-}
findZipper : (a -> Maybe b) -> List a -> Maybe ( b, Zipper a )
findZipper f =
    let
        go ls rs =
            case rs of
                [] ->
                    Nothing

                x :: xs ->
                    case f x of
                        Nothing ->
                            go (x :: ls) xs

                        Just b ->
                            Just ( b, ( ls, x, xs ) )
    in
    go []


fromZipper : Zipper a -> List a
fromZipper ( a, b, c ) =
    List.foldl (::) (b :: c) a


bool : a -> a -> Bool -> a
bool f t x =
    if x then
        t

    else
        f
