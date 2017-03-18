module Models exposing (..)


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
