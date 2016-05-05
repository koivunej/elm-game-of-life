module GameOfLife (..) where

import Html exposing (Html)
import Html.Events
import Matrix
import Matrix.Random as RandomMatrix
import Array exposing (Array)
import StartApp.Simple
import Time
import Random

import Types exposing (..)
import Game exposing (step)
import GameView exposing (gameView)

type alias Model =
    { world : Matrix.Matrix State }

type Action = Step

initialModel =
    { world = fst
        <| Random.generate
            (RandomMatrix.matrix (Random.int 25 25) (Random.int 25 25) (Random.map (\b -> if b then Alive else Dead) Random.bool))
            (Random.initialSeed 42)
    }

view : Signal.Address Action -> Model -> Html
view address m =
    Html.div
        []
        [ gameView m.world
        , Html.button
            [ Html.Events.onClick address Step ]
            [ Html.text "Step" ]
        ]


update : Action -> Model -> Model
update _ m =
    { m | world = step m.world }

main : Signal.Signal Html
main =
    StartApp.Simple.start
        { model = initialModel
        , view = view
        , update = update
        }
