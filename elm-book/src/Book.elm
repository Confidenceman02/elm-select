module Book exposing (..)


import Chapters.Welcome as Welcome
import ElmBook exposing (Book, book, withChapters, withStatefulOptions)
import ElmBook.StatefulOptions


type alias SharedState =
    { welcomeState : Welcome.Model }


sharedState : SharedState
sharedState =
    { welcomeState = Welcome.init }


main : Book SharedState
main =
    book "Elm Select"
        |> withStatefulOptions [ ElmBook.StatefulOptions.initialState sharedState ]
        |> withChapters [ Welcome.welcomeChapter ]
