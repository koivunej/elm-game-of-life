module GameView exposing (gameView)

import Html exposing (Html, Attribute)
import Html.Attributes exposing (class, style)
import Matrix exposing (..)
import Types exposing (..)
import Array exposing (..)


gameView : Matrix State -> Html a
gameView world =
  Html.table
    [ class "gol-map" ]
    [ Html.tbody
        []
        (Array.toList (Array.map row world))
    ]


row : Array State -> Html a
row r =
  Html.tr [] (Array.toList (Array.map cell r))


cell : State -> Html a
cell c =
  Html.td [ cellStyle c ] [ Html.text " " ]


cellStyle : State -> Attribute a
cellStyle s =
  case s of
    Alive ->
      class "gol-alive"

    Dead ->
      class "gol-dead"
