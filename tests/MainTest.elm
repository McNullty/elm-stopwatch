module MainTest exposing (..)

import Expect
import Main exposing (secondsToTimeForDisplay)
import Test exposing (..)

suite : Test
suite =
    describe "Testing secondsToTimeForDisplay method"
        [ test "when 3666 is input response 01:01:06" <|
            \_ ->
                let
                    model = secondsToTimeForDisplay 3666
                in
                    Expect.equal {hours = 1, minutes = 1, seconds = 6} model
        , test "when 60 is input response 00:01:00" <|
                     \_ ->
                         let
                             model = secondsToTimeForDisplay 60
                         in
                             Expect.equal {hours = 0, minutes = 1, seconds = 0} model
        ]