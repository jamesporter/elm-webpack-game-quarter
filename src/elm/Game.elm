module Game exposing (..)

import Html exposing (Html, text)
import Html.Attributes exposing (style)
import Html.Events
import Keyboard exposing (KeyCode)
import Svg exposing (svg, polygon, circle)
import Svg.Attributes exposing (version, viewBox, points, fill, cx, cy, r)
import Svg.Events exposing (onClick)
import AnimationFrame
import Time exposing (Time)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- PARAMETERS


levelLength : Float
levelLength =
    5.0


initialEnemies : List Enemy
initialEnemies =
    [ { angle = pi
      , velocity = 0.5
      , maxVelocity = 2.0
      , radius = 80
      }
    , { angle = -pi / 2
      , velocity = 0.2
      , maxVelocity = 3.0
      , radius = 120
      }
    ]



-- MODEL


type Cell
    = Top
    | Bottom
    | Right
    | Left


type State
    = Game
    | Start
    | Over


type alias Enemy =
    { angle : Float
    , velocity : Float
    , maxVelocity : Float
    , radius : Float
    }


type alias Model =
    { cell : Cell
    , pendingCell : Maybe Cell
    , enemies : List Enemy
    , time : Float
    , alive : Bool
    , state : State
    }


model : Model
model =
    { enemies = initialEnemies
    , cell = Bottom
    , pendingCell = Nothing
    , time = 0.0
    , alive = True
    , state = Start
    }


init : ( Model, Cmd Msg )
init =
    ( model, Cmd.none )



-- UPDATE


type Msg
    = TimeUpdate Time
    | KeyDown KeyCode
    | CellSelection Cell
    | StartGame


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TimeUpdate dt ->
            ( updatePosition dt model, Cmd.none )

        KeyDown keyCode ->
            ( keyDown keyCode model, Cmd.none )

        CellSelection cell ->
            ( selectCell cell model, Cmd.none )

        StartGame ->
            ( restart model, Cmd.none )


restart : Model -> Model
restart model =
    { model
        | enemies = initialEnemies
        , cell = Bottom
        , pendingCell = Nothing
        , time = 0.0
        , alive = True
        , state = Game
    }


updatePosition : Time -> Model -> Model
updatePosition dt model =
    case model.state of
        Game ->
            if model.alive then
                { model
                    | enemies = updateBoots model dt
                    , time = model.time + dt
                    , alive = isAlive model
                    , cell =
                        case model.pendingCell of
                            Just c ->
                                c

                            Nothing ->
                                model.cell
                    , pendingCell = Nothing
                }
            else
                { model
                    | state = Over
                }

        _ ->
            model


isAlive : Model -> Bool
isAlive model =
    not (List.any (isIntersecting model.cell) model.enemies)


isIntersecting : Cell -> Enemy -> Bool
isIntersecting cell boot =
    let
        x =
            cos boot.angle

        y =
            sin boot.angle
    in
        case cell of
            Top ->
                -y > abs (x)

            Bottom ->
                -y < -(abs x)

            Right ->
                x > (abs y)

            Left ->
                x < -(abs y)


updateBoots : Model -> Float -> List Enemy
updateBoots model dt =
    List.map (updateBoot dt) model.enemies


updateBoot : Float -> Enemy -> Enemy
updateBoot dt boot =
    let
        newVelocity =
            boot.velocity * (1.0 + dt / 10000)

        constrained =
            (clamp -1.0 boot.maxVelocity newVelocity)
    in
        { boot
            | angle = boot.angle + 0.001 * boot.velocity * dt
            , velocity = constrained
        }


keyDown : KeyCode -> Model -> Model
keyDown keyCode model =
    case keyCode of
        38 ->
            (selectCell Top model)

        40 ->
            (selectCell Bottom model)

        37 ->
            (selectCell Left model)

        39 ->
            (selectCell Right model)

        27 ->
            { model
                | state = Start
            }

        32 ->
            restart model

        _ ->
            model


selectCell : Cell -> Model -> Model
selectCell cell model =
    { model | pendingCell = Just cell }



-- VIEW


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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ AnimationFrame.diffs TimeUpdate
        , Keyboard.downs KeyDown
        ]
