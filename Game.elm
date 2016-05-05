module Game (..) where

import Matrix
import Types exposing (..)

step : Matrix.Matrix State -> Matrix.Matrix State
step m =
    Matrix.mapWithLocation (stepLocation m) m

stepLocation : Matrix.Matrix State -> Matrix.Location -> State -> State
stepLocation m loc current =
    let
        neighs = List.map (\m -> Maybe.withDefault Dead m) (neighbours loc m)
    in
        stepByNeighbors current neighs

stepByNeighbors : State -> List State -> State
stepByNeighbors state neighs =
    let
        alive = List.length (List.filter (\m -> m == Alive) neighs)
    in
       if state == Alive then
          if alive < 2 then
            Dead
          else if alive == 2 || alive == 3 then
            Alive
          else
            Dead
       else if alive == 3 then
          Alive
       else
          Dead

neighbours : Matrix.Location -> Matrix.Matrix a -> List (Maybe a)
neighbours loc matrix =
    [ Matrix.get (wrappedOffset matrix loc (-1, 0)) matrix
    , Matrix.get (wrappedOffset matrix loc (-1, 1)) matrix
    , Matrix.get (wrappedOffset matrix loc (0, 1)) matrix
    , Matrix.get (wrappedOffset matrix loc (1, 1)) matrix
    , Matrix.get (wrappedOffset matrix loc (1, 0)) matrix
    , Matrix.get (wrappedOffset matrix loc (1, -1)) matrix
    , Matrix.get (wrappedOffset matrix loc (0, -1)) matrix
    , Matrix.get (wrappedOffset matrix loc (-1, -1)) matrix
    ]

wrappedOffset : Matrix.Matrix a -> Matrix.Location -> Matrix.Location -> Matrix.Location
wrappedOffset m offset original =
    (
        wrap (Matrix.rowCount m) (Matrix.row original) (Matrix.row offset),
        wrap (Matrix.colCount m) (Matrix.col original) (Matrix.col offset)
    )

wrap : Int -> Int -> Int -> Int
wrap limit value offset =
    let
        off = (value + offset) % limit
    in
       if off < 0 then
          limit + off
       else
          off % limit
