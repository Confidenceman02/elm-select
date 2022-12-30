module Book exposing (..)

import Chapters.Welcome as Welcome
import ElmBook exposing (withChapters, withStatefulOptions)
import ElmBook.ElmCSS exposing (Book, book)
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
