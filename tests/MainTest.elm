module MainTest exposing (..)

import Expect
import Main exposing (convertToTimeFormat, secondsToTimeForDisplay, timeForDisplayToString)
import Test exposing (..)

suite : Test
suite =
    describe "Main module"
        [ describe "Testing secondsToTimeForDisplay method"
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
        , describe "Testing showing TimeToDisplay data"
            [ test "When {hours = 0, minutes = 1, seconds = 0} is given 00:01:00 is returned" <|
                \_ ->
                    let
                        actual = timeForDisplayToString {hours = 0, minutes = 1, seconds = 0}
                    in
                        Expect.equal "00:01:00" actual
            ]
        , describe "Testing convertToTimeFormat"
            [ test "when calling convertToTimeFormat with 9 return 09" <|
                \_ ->
                    Expect.equal "09" (convertToTimeFormat 9)
            , test "when calling convertToTimeFormat with 15 return 15" <|
                \_ ->
                    Expect.equal "15" (convertToTimeFormat 15)
            ]
        ]