module GameOfLife exposing (..)

import Html exposing (Html)
import Html.App as App
import Html.Attributes exposing (value, type')
import Html.Events
import Matrix
import Matrix.Random as RandomMatrix
import Array exposing (Array)
import Platform.Cmd as Cmd exposing (Cmd)
import Task
import Time exposing (Time)
import AnimationFrame
import Random
import Types exposing (State(..))
import Game exposing (step)
import GameView exposing (gameView)
import String
import Json.Decode as Json


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


type Msg
  = StepOne
  | Start
  | Stop
  | Tick Time
  | Reset
  | SeedInputChanged String


init : ( Model, Cmd Msg )
init =
  ( initialModel 42, Cmd.none )


initialModel : Int -> Model
initialModel s =
  let
    seed =
      Random.initialSeed s
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
    <| Random.step
        (RandomMatrix.matrix
          (Random.int 25 25)
          (Random.int 25 25)
          (Random.map
            (\b ->
              if b then
                Alive
              else
                Dead
            )
            Random.bool
          )
        )
        initialSeed


view : Model -> Html Msg
view m =
  Html.div
    []
    [ Html.dl
        []
        [ Html.dt [] [ Html.text "Round" ]
        , Html.dd [] [ Html.text (toString m.round) ]
        ]
    , gameView m.world
    , stepOneButton m
    , simulationButton m
    , Html.hr [] []
    , Html.button [ Html.Events.onClick Reset ] [ Html.text "Reset" ]
    , Html.input
        [ (type' "number")
        , (value (toString (Maybe.withDefault m.seed m.seedInput)))
        , Html.Events.on "input" (Json.map SeedInputChanged Html.Events.targetValue)
        ]
        []
    ]


stepOneButton model =
  Html.button
    [ Html.Events.onClick StepOne
    , Html.Attributes.disabled (model.mode /= Manual)
    ]
    [ Html.text "Step" ]


simulationButton model =
  let
    ( action, text ) =
      case model.mode of
        Manual ->
          ( Start, "Start" )

        _ ->
          ( Stop, "Stop" )
  in
    Html.button
      [ Html.Events.onClick action
      , Html.Attributes.disabled (model.mode == Complete)
      ]
      [ Html.text text ]


update : Msg -> Model -> ( Model, Cmd Msg )
update action m =
  let
      noCmd = Cmd.none
  in
    case action of
      StepOne ->
        -- note here we compare the new calculated to the one we had before
        -- before we had A, current is B, and we check if A == C, where C = step B
        -- this stops if the world has stabilized into flickering or fully stopped
        ( stepOne m, noCmd )

      Start ->
        ( { m | mode = Automatic }, noCmd )

      Stop ->
        ( { m | mode = Manual }, noCmd )

      Tick _ ->
        case m.mode of
          Automatic ->
            ( stepOne m, noCmd )

          _ ->
            ( m, noCmd )

      SeedInputChanged s ->
        ( { m | seedInput = (Result.toMaybe (String.toInt s)) }, noCmd )

      Reset ->
        let
          fresh =
            initialModel (Maybe.withDefault m.seed m.seedInput)

          mode =
            if m.mode /= Complete then
              m.mode
            else
              Manual

        in
          ( { fresh | mode = mode }, noCmd )

stepOne : Model -> Model
stepOne m =
    let
      next =
        step m.world

      continuingModel =
        { m | world = next, previousWorld = Just m.world, round = m.round + 1 }
    in
      case m.previousWorld of
        Nothing ->
          continuingModel

        Just prev ->
          if prev /= next then
            continuingModel
          else
            { m | mode = Complete }

subscriptions : Model -> Sub Msg
subscriptions _ =
  AnimationFrame.times Tick

-- main : Program flags ?
main =
  App.program
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions }
