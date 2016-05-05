module GameOfLife (..) where

import Html exposing (Html)
import Html.Attributes exposing (min, max, value, type')
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
import ParseInt exposing (parseInt)

import Types exposing (..)
import Game exposing (step)
import GameView exposing (gameView)

type SimulationMode
    = Manual
    | Automatic
    | Complete

type alias Model =
    { world : Matrix.Matrix State
    , previousWorld : Maybe (Matrix.Matrix State)
    , seed : Int
    , mode : SimulationMode
    , round : Int
    , seedInput : Maybe Int
    }

type Action
    = StepOne
    | Start
    | Stop
    | Tick Time
    | ResetToSeed Int
    | Reset
    | SeedInputChanged String

init : (Model, Effects Action)
init =
    (initialModel 42, Effects.none)

initialModel : Int -> Model
initialModel s =
    let
        seed = Random.initialSeed s
    in
       { world = generateRandomWorld seed
       , previousWorld = Nothing
       , seed = s
       , mode = Manual
       , round = 0
       , seedInput = Nothing
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
        , Html.hr [] []
        , Html.button [ Html.Events.onClick address Reset ] [ Html.text "Reset" ]
        , Html.input
            [ (type' "number")
            , (value (toString (Maybe.withDefault m.seed m.seedInput)))
            , Html.Events.on "input" Html.Events.targetValue (\input -> Signal.message address (SeedInputChanged input))
            ] [ ]
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
            _ -> (Stop, "Stop")
    in
        Html.button
            [ Html.Events.onClick address action
            , Html.Attributes.disabled (model.mode == Complete)
            ]
            [ Html.text text ]

update : Action -> Model -> (Model, Effects Action)
update action m =
    case action of
        StepOne ->
            -- note here we compare the new calculated to the one we had before
            -- before we had A, current is B, and we check if A == C, where C = step B
            -- this stops if the world has stabilized into flickering or fully stopped
            let
                next = step m.world
                mode =
                    case m.mode of
                        Automatic -> Automatic
                        _ -> m.mode
                continuingModel = { m | world = next, previousWorld = Just m.world, round = m.round + 1, mode = mode }
            in
               case m.previousWorld of
                 Nothing -> (continuingModel, Effects.tick Tick)
                 Just prev ->
                     if prev /= next then
                        (continuingModel, Effects.tick Tick)
                     else
                        ({ m | mode = Complete }, Effects.none)

        Start   -> ({ m | mode = Automatic }, Effects.tick Tick)

        Stop    -> ({ m | mode = Manual }, Effects.none)

        Tick t  ->
            case m.mode of
                Automatic -> ( m, Effects.task (Task.succeed StepOne) )
                _ -> (m, Effects.none)

        SeedInputChanged s -> ({ m | seedInput = (Result.toMaybe (parseInt s))}, Effects.none)

        Reset ->
            let
                fresh = initialModel (Maybe.withDefault m.seed m.seedInput)
                mode =
                    if m.mode /= Complete
                    then m.mode
                    else Manual
                fx =
                    if mode == Manual
                    then Effects.none
                    else Effects.tick Tick
            in
                ({ fresh | mode = mode }, fx)

        _ -> (m, Effects.none)

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
