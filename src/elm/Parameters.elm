module Parameters exposing (..)

import Models exposing (Enemy)


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


levelLength : Float
levelLength =
    5.0
