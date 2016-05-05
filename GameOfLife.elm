module GameOfLife (..) where

import Html exposing (Html)
import Html.Attributes
import Html.Events
import Matrix
import Matrix.Random as RandomMatrix
import Array exposing (Array)
import StartApp
import Effects exposing (Effects)
import Task
import Time exposing (Time)
import Random
import Debug

import Types exposing (..)
import Game exposing (step)
import GameView exposing (gameView)

type SimulationMode
    = Manual
    | Automatic

type alias Model =
    { world : Matrix.Matrix State
    , seed : Random.Seed
    , mode : SimulationMode
    , simulationState : SimulationState
    , round : Int
    }

type Action = StepOne | Start | Stop | Tick Time

type alias SimulationState =
    Maybe { previousClock : Time, elapsedSince : Time }

duration = (1 / 5) * Time.second

init : (Model, Effects Action)
init =
    (initialModel, Effects.none)

initialModel : Model
initialModel =
    let
        seed = Random.initialSeed 42
    in
       { world = generateRandomWorld seed
       , seed = seed
       , mode = Manual
       , round = 0
       , simulationState = Nothing
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
            Manual    -> (Start, "Start")
            Automatic -> (Stop, "Stop")
    in
        Html.button
            [ Html.Events.onClick address action
            ]
            [ Html.text text ]

update : Action -> Model -> (Model, Effects Action)
update action m =
    case action of
        StepOne -> ({ m | world = step m.world, round = m.round + 1, simulationState = Nothing }, Effects.tick Tick)
        Start   -> ({ m | mode = Automatic }, Effects.tick Tick)
        Stop    -> ({ m | mode = Manual, simulationState = Nothing }, Effects.none)
        Tick t  ->
            case m.mode of
                Manual    -> (m, Effects.none)
                Automatic ->
                    let
                        dt = case m.simulationState of
                            Nothing -> 0
                            Just { previousClock, elapsedSince } -> elapsedSince + (t - previousClock)
                    in
                       if dt >= duration then
                          -- just trigger a StepOne since we have awaited enough
                           ( m, Effects.task (Task.succeed StepOne) )
                       else
                           ( { m | simulationState = Just { previousClock = t, elapsedSince = dt} }
                           , Effects.tick Tick
                           )

app =
    StartApp.start { init = init
                   , update = update
                   , view = view
                   , inputs = [ ]
                   }

port tasks : Signal.Signal (Task.Task Effects.Never ())
port tasks =
    app.tasks

main : Signal.Signal Html
main =
    app.html
