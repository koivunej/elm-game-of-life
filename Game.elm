module Game (step) where

import Matrix
import Types exposing (..)
import Debug exposing (crash)

step : Matrix.Matrix State -> Matrix.Matrix State
step m =
    Matrix.mapWithLocation (stepLocation m) m

stepLocation : Matrix.Matrix State -> Matrix.Location -> State -> State
stepLocation m loc current =
    let
        neighs = neighbours loc m
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

neighbours : Matrix.Location -> Matrix.Matrix a -> List a
neighbours loc matrix =
    [ (-1, 0)
    , (-1, 1)
    , (0, 1)
    , (1, 1)
    , (1, 0)
    , (1, -1)
    , (0, -1)
    , (-1, -1)
    ]
        |> List.map (wrappedOffset matrix loc)
        |> List.map (\loc -> Matrix.get loc matrix)
        |> List.map unwrap

wrappedOffset : Matrix.Matrix a -> Matrix.Location -> Matrix.Location -> Matrix.Location
wrappedOffset m offset original =
    (
        wrapAround (Matrix.rowCount m) (Matrix.row original) (Matrix.row offset),
        wrapAround (Matrix.colCount m) (Matrix.col original) (Matrix.col offset)
    )

wrapAround : Int -> Int -> Int -> Int
wrapAround limit value offset =
    let
        off = (value + offset) % limit
    in
       if off < 0 then
          limit + off
       else
          off % limit

unwrap : Maybe a -> a
unwrap maybe =
    case maybe of
        Just a -> a
        Nothing -> (Debug.crash "Invalid coordinates resulted in Nothing")
