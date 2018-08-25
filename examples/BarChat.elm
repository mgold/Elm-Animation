module BarChart exposing (main)

{- This module demonstrates bars that grow at a constant
   speed, even though they have different lengths.
-}

import Animation exposing (..)
import Browser
import Browser.Events exposing (onAnimationFrameDelta)
import Color exposing (gray, red)
import Element exposing (Element, color, down, flow, right, spacer)
import Json.Decode exposing (Value)
import Random


data : List Int
data =
    let
        gen =
            Random.int 1 12 |> Random.list 20

        seed =
            Random.initialSeed 42000
    in
    Random.step gen seed |> Tuple.first


animations : List Animation
animations =
    List.scanl
        (\val prev -> prev |> to val |> delay (timeRemaining 0 prev))
        (static 0 |> speed 0.5)
        -- size up to bar length now for smoother animation
        (List.map (\x -> toFloat x * 80) data)


render1 : Int -> Element
render1 x =
    flow
        down
        [ spacer 1 10
        , flow
            right
            [ spacer x 30 |> color gray
            , spacer
                (if x == 0 then
                    0

                 else
                    1
                )
                30
                |> color red
            ]
        ]


render : List Animation -> Clock -> Element
render anims t =
    flow
        right
        [ spacer 40 1
        , flow down <| List.map (animate t >> round >> render1) anims
        ]


renderClosure =
    render animations


main : Program Value Clock Float
main =
    Browser.element
        { init = always ( 0, Cmd.none )
        , update = \dt t -> ( t + dt, Cmd.none )
        , subscriptions = \model -> onAnimationFrameDelta identity
        , view = renderClosure >> Element.toHtml
        }
