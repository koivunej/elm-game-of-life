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
    , round : Int
    }

type Action = StepOne | Start | Stop

initialModel =
    let
        seed = Random.initialSeed 42
    in
       { world = generateRandomWorld seed
       , seed = seed
       , mode = Manual
       , round = 0
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
        [ Html.dl
            []
            [ Html.dt [] [ Html.text "Round" ]
            , Html.dd [] [ Html.text (toString m.round) ]
            ]
        , gameView m.world
        , stepOneButton address m
        , simulationButton address m
        ]

stepOneButton address model =
    Html.button
        [ Html.Events.onClick address StepOne
        , Html.Attributes.disabled (model.mode /= Manual)
        ]
        [ Html.text "Step" ]

simulationButton address model =
    let
        (action, text) = case model.mode of
            Manual -> (Start, "Start")
            Automatic _ -> (Stop, "Stop")
    in
        Html.button
            [ Html.Events.onClick address action
            , Html.Attributes.disabled True
            ]
            [ Html.text text ]


update : Action -> Model -> Model
update _ m =
    { m | world = step m.world, round = m.round + 1 }

main : Signal.Signal Html
main =
    StartApp.Simple.start
        { model = initialModel
        , view = view
        , update = update
        }
