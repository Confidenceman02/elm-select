module Select.DotLoadingIcon exposing (view)

import Css
import Css.Animations as CssAnimation
import Html.Styled exposing (Html)
import Svg.Styled exposing (path, svg)
import Svg.Styled.Attributes as SvgAttribs exposing (d, fill, height, viewBox, width)


view : Html msg
view =
    svg svgCommonStyles
        [ path
            [ SvgAttribs.css
                [ Css.opacity <| Css.num 0
                , Css.animationName <|
                    CssAnimation.keyframes
                        [ ( 0, [ CssAnimation.opacity (Css.num 0) ] )
                        , ( 33, [ CssAnimation.opacity (Css.num 1) ] )

                        -- , ( 75, [ CssAnimation.opacity (Css.num 0.5) ] )
                        -- , ( 100, [ CssAnimation.opacity (Css.num 0) ] )
                        ]
                , Css.animationDuration (Css.sec logoAnimationDuration)
                , Css.animationIterationCount Css.infinite
                , Css.animationDelay (Css.sec (logoAnimationDelay * 2))
                , Css.property "animation-play-state" "running"
                ]
            , d "M30.8284 1.17157C32.3905 2.73366 32.3905 5.26633 30.8284 6.82842C29.2663 8.39051 26.7336 8.39051 25.1715 6.82842C23.6094 5.26633 23.6094 2.73366 25.1715 1.17157C26.7336 -0.390523 29.2663 -0.390523 30.8284 1.17157Z"
            ]
            []
        , path
            [ SvgAttribs.css
                [ Css.opacity <| Css.num 0
                , Css.animationName <|
                    CssAnimation.keyframes
                        [ ( 0, [ CssAnimation.opacity (Css.num 0) ] )
                        , ( 33, [ CssAnimation.opacity (Css.num 1) ] )

                        -- , ( 75, [ CssAnimation.opacity (Css.num 0.5) ] )
                        -- , ( 100, [ CssAnimation.opacity (Css.num 0) ] )
                        ]
                , Css.animationDuration (Css.sec logoAnimationDuration)
                , Css.animationIterationCount Css.infinite
                , Css.animationDelay (Css.sec logoAnimationDelay)
                , Css.property "animation-play-state" "running"
                ]
            , d "M18.8285 1.17157C20.3906 2.73366 20.3906 5.26633 18.8285 6.82842C17.2664 8.39051 14.7337 8.39051 13.1716 6.82842C11.6095 5.26633 11.6095 2.73366 13.1716 1.17157C14.7337 -0.390523 17.2664 -0.390523 18.8285 1.17157Z"
            ]
            []
        , path
            [ SvgAttribs.css
                [ Css.opacity <| Css.num 0
                , Css.animationName <|
                    CssAnimation.keyframes
                        [ ( 0, [ CssAnimation.opacity (Css.num 0) ] )
                        , ( 33, [ CssAnimation.opacity (Css.num 1) ] )

                        -- , ( 75, [ CssAnimation.opacity (Css.num 0.5) ] )
                        -- , ( 100, [ CssAnimation.opacity (Css.num 0) ] )
                        ]
                , Css.animationDuration (Css.sec logoAnimationDuration)
                , Css.animationIterationCount Css.infinite
                , Css.property "animation-play-state" "running"
                ]
            , d "M6.82848 1.17157C8.39057 2.73366 8.39057 5.26633 6.82848 6.82842C5.26639 8.39051 2.73372 8.39051 1.17163 6.82842C-0.390462 5.26633 -0.390462 2.73366 1.17163 1.17157C2.73372 -0.390523 5.26639 -0.390523 6.82848 1.17157Z"
            ]
            []
        ]


svgCommonStyles : List (Svg.Styled.Attribute msg)
svgCommonStyles =
    [ fill "currentColor", width "29", height "5", viewBox "0 0 32 8" ]



-- CONSTANTS


logoAnimationDuration : Float
logoAnimationDuration =
    1


logoAnimationDelay : Float
logoAnimationDelay =
    0.2
