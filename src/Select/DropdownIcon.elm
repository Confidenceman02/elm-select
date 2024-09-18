module Select.DropdownIcon exposing (view)

import Html.Styled as Styled
import Html.Styled.Attributes exposing (attribute)
import Svg.Styled exposing (path, svg)
import Svg.Styled.Attributes exposing (d, fill, height, viewBox)


view : Styled.Html msg
view =
    svg [ height "20", viewBox "0 0 20 20", fill "currentColor", attribute "aria-hidden" "true", attribute "focusable" "false" ]
        [ path [ d "M6.18 6.845L10 10.747l3.82-3.902L15 8.049l-5 5.106-5-5.106z" ] [] ]
