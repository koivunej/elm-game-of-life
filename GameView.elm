module GameView (..) where

import Html exposing (Html, Attribute)
import Html.Attributes exposing (class, style)
import Matrix exposing (..)
import Types exposing (..)
import Array exposing (..)

gameView : Matrix State -> Html
gameView world =
    Html.table
        []
        [ Html.tbody
            []
            (Array.toList (Array.map row world))
        ]

row : Array State -> Html
row r =
    Html.tr [] (Array.toList (Array.map cell r))

rowStyle =
    style [  ]

cell : State -> Html
cell c =
    Html.td [ cellStyle c ] [ Html.text " " ]

cellStyle : State -> Attribute
cellStyle s =
    case s of
        Alive -> style [ ("width", "1em"), ("height", "1em"), ("background-color", "green") ]
        Dead  -> style [ ("width", "1em"), ("height", "1em"), ("background-color", "white") ]

