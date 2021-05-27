module ClearIcon exposing (view)

import Html.Styled exposing (Html)
import Svg.Styled exposing (path, svg)
import Svg.Styled.Attributes exposing (d, height, viewBox)


view : Html msg
view =
    svg svgCommonStyles
        [ path
            [ d "M10 2c-4.424 0-8 3.576-8 8 0 4.424 3.576 8 8 8 4.424 0 8-3.576 8-8 0-4.424-3.576-8-8-8zm4 10.872L12.872 14 10 11.128 7.128 14 6 12.872 8.872 10 6 7.128 7.128 6 10 8.872 12.872 6 14 7.128 11.128 10 14 12.872z"
            ]
            []
        ]


svgCommonStyles : List (Svg.Styled.Attribute msg)
svgCommonStyles =
    [ height "16", viewBox "0 0 20 20" ]
