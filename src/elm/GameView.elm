module GameView exposing (..)

import Updates exposing (..)
import Models exposing (..)
import Html exposing (Html, text)
import Html.Attributes exposing (style)
import Html.Events
import Svg exposing (svg, polygon, circle)
import Svg.Attributes exposing (version, viewBox, points, fill, cx, cy, r)
import Svg.Events exposing (onClick)


view : Model -> Html Msg
view model =
    Html.div
        [ style
            [ ( "width", "100%" )
            , ( "height", "100%" )
            , ( "background", "#1f1f1f" )
            , ( "color", "white" )
            , ( "display", "flex" )
            , ( "align-items", "center" )
            , ( "justify-content", "center" )
            , ( "font-family", "Futura" )
            , ( "text-align", "center" )
            ]
        ]
        [ case model.state of
            Start ->
                viewStart model

            Game ->
                viewGame model

            Over ->
                viewOver model
        ]


viewGame : Model -> Html Msg
viewGame model =
    Html.div
        [ style [ ( "max-width", "400px" ), ( "min-width", "280px" ), ( "flex", "1" ) ] ]
        [ Html.h1 []
            [ Html.text (toString (round (model.time / 1000))) ]
        , svg [ version "1.1", viewBox "0 0 400 400" ]
            (List.concat
                [ [ viewCell Top model
                  , viewCell Bottom model
                  , viewCell Left model
                  , viewCell Right model
                  ]
                , (List.map viewEnemy model.enemies)
                ]
            )
        ]


viewStart : Model -> Html Msg
viewStart model =
    Html.div
        [ style [ ( "max-width", "400px" ), ( "min-width", "280px" ), ( "flex", "1" ) ] ]
        [ Html.h1 [ style [ ( "font-size", "3em" ), ( "color", "#E31743" ) ] ]
            [ Html.text "Quarter Past" ]
        , Html.p []
            [ Html.text "Quarter Past is a simple game of coordination, skill and not panicking." ]
        , Html.p []
            [ Html.text "Use the arrow keys (or on touch screen devices touches) to select the active Quarter." ]
        , Html.p []
            [ Html.text "Avoid the rotating circles touching your active Quarter. Earn points for how long you last. Good luck. You will need it." ]
        , Html.h2 [ Html.Events.onClick StartGame ]
            [ Html.text "Start" ]
        ]


viewOver : Model -> Html Msg
viewOver model =
    Html.div
        [ style [ ( "max-width", "400px" ), ( "min-width", "280px" ), ( "flex", "1" ) ] ]
        [ Html.h1 [ style [ ( "font-size", "3em" ), ( "color", "#17e3b7" ) ] ]
            [ Html.text "Game Over" ]
        , Html.p []
            [ Html.text "Your score this time was:" ]
        , Html.h1 []
            [ Html.text (toString (round model.time)) ]
        , Html.p []
            [ Html.text
                (if model.time > 20000 then
                    "Good effort."
                 else
                    "Be better."
                )
            ]
        , Html.h2 [ Html.Events.onClick StartGame ]
            [ Html.text "Restart" ]
        ]


viewCell : Cell -> Model -> Html Msg
viewCell cell model =
    polygon [ fill (colourForCell cell model.cell), points (pointsForCell cell), onClick (CellSelection cell) ] []


viewEnemy : Enemy -> Html Msg
viewEnemy enemy =
    let
        x =
            200 + enemy.radius * cos (enemy.angle)

        y =
            200 + enemy.radius * sin (enemy.angle)
    in
        circle [ fill "#e9e9e9", r "20", cx (toString x), cy (toString y) ] []


colourForCell : Cell -> Cell -> String
colourForCell cell selectedCell =
    if cell == selectedCell then
        "#E31743"
    else
        case cell of
            Top ->
                "#444444"

            Bottom ->
                "#4f4f4f"

            Right ->
                "#5f5f5f"

            Left ->
                "#555555"


pointsForCell : Cell -> String
pointsForCell cell =
    case cell of
        Top ->
            "0,0 400,0 200,200"

        Bottom ->
            "0,400 400,400 200,200"

        Right ->
            "400,0 400,400 200,200"

        Left ->
            "0,0 0,400 200,200"
