module Updates exposing (..)

import Models exposing (..)
import Parameters exposing (initialEnemies)
import Time exposing (Time)
import Keyboard exposing (KeyCode)


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


initialModel : Model
initialModel =
    { enemies = initialEnemies
    , cell = Bottom
    , pendingCell = Nothing
    , time = 0.0
    , alive = True
    , state = Start
    }


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
