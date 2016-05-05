module GameOfLife (..) where

import Html exposing (Html)
import Html.Attributes
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

type SimulationMode
    = Manual
    | Automatic Int -- speed?

type alias Model =
    { world : Matrix.Matrix State
    , seed : Random.Seed
    , mode : SimulationMode
    }

type Action = StepOne | Start

initialModel =
    let
        seed = Random.initialSeed 42
    in
       { world = generateRandomWorld seed
       , seed = seed
       , mode = Manual
       }

generateRandomWorld initialSeed =
    fst
        <| Random.generate
            (RandomMatrix.matrix
                (Random.int 25 25)
                (Random.int 25 25)
                (Random.map (\b -> if b then Alive else Dead) Random.bool))
            initialSeed


view : Signal.Address Action -> Model -> Html
view address m =
    Html.div
        []
        [ gameView m.world
        , stepOneButton address m
        , simulationButton address m
        ]

stepOneButton address model =
    Html.button
        [ Html.Events.onClick address StepOne ]
        [ Html.text "Step" ]

simulationButton address model =
    Html.button
        [ Html.Events.onClick address Start, Html.Attributes.disabled True ]
        [ Html.text "Start" ]

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
