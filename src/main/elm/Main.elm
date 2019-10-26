module Main exposing (..)

import Bootstrap.Button as Button
import Bootstrap.ListGroup as ListGroup
import Html exposing (Html, div, h1, h2, text)
import Html.Attributes exposing (..)
import Browser.Navigation as Navigation
import Browser exposing (UrlRequest)
import Html.Events exposing (onClick)
import String exposing (concat, join)
import Time
import Url exposing (Url)
import Url.Parser as UrlParser exposing ((</>), Parser, s, top)
import Bootstrap.Navbar as NavBar
import Bootstrap.Grid as Grid
import Bootstrap.Modal as Modal


type alias Flags =
    {}

type alias Model =
    { navKey : Navigation.Key
    , page : Page
    , navState : NavBar.State
    , modalVisibility : Modal.Visibility
    , numberOfSeconds : Int
    , timerStarted : Bool
    , times : List Int
    }

type alias TimeForDisplay =
    { hours : Int
    , minutes : Int
    , seconds : Int
    }

type Page
    = Home
    | About
    | NotFound


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = ClickedLink
        , onUrlChange = UrlChange
        }

init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        ( navState, navCmd ) =
            NavBar.initialState NavMsg

        ( model, urlCmd ) =
            urlUpdate url { navKey = key
                          , navState = navState
                          , page = Home
                          , modalVisibility = Modal.hidden
                          , numberOfSeconds = 0
                          , timerStarted = False
                          , times = []
                          }
    in
        ( model, Cmd.batch [ urlCmd, navCmd ] )


type Msg
    = UrlChange Url
    | ClickedLink UrlRequest
    | NavMsg NavBar.State
    | Tick Time.Posix
    | StartTimer
    | StopTimer
    | LapTimer
    | ResetTimer


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ NavBar.subscriptions model.navState NavMsg
        , case model.timerStarted of
            True -> Time.every 1000 Tick
            False -> Sub.none
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedLink req ->
             case req of
                 Browser.Internal url ->
                     ( model, Navigation.pushUrl model.navKey <| Url.toString url )

                 Browser.External href ->
                     ( model, Navigation.load href )

        UrlChange url ->
            urlUpdate url model

        NavMsg state ->
            ( { model | navState = state }
            , Cmd.none
            )

        Tick _->
            let
                nos = model.numberOfSeconds
            in
                ( { model | numberOfSeconds = nos + 1}
                , Cmd.none
                )


        StartTimer ->
            ( { model | timerStarted = True }
            , Cmd.none
            )


        StopTimer ->
            ( { model | timerStarted = False }
            , Cmd.none
            )


        LapTimer ->
            let
                nos = model.numberOfSeconds
                oldTimes = model.times
            in
                ( {model | times = nos :: oldTimes} , Cmd.none)


        ResetTimer ->
            ( { model | numberOfSeconds = 0 }
            , Cmd.none
            )



urlUpdate : Url -> Model -> ( Model, Cmd Msg )
urlUpdate url model =
    case decode url of
        Nothing ->
            ( { model | page = NotFound }, Cmd.none )

        Just route ->
            ( { model | page = route }, Cmd.none )


decode : Url -> Maybe Page
decode url =
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
    |> UrlParser.parse routeParser


routeParser : Parser (Page -> a) a
routeParser =
    UrlParser.oneOf
        [ UrlParser.map Home top
        , UrlParser.map About (s "about")
        ]


view : Model -> Browser.Document Msg
view model =
    { title = "Elm Stopwatch"
    , body =
        [ div []
            [ menu model
            , mainContent model
            ]
        ]
    }


menu : Model -> Html Msg
menu model =
    NavBar.config NavMsg
        |> NavBar.withAnimation
        |> NavBar.container
        |> NavBar.brand [ href "#" ] [ text "Elm Stopwatch" ]
        |> NavBar.items
            [ NavBar.itemLink [ href "#about" ] [ text "About" ]
            ]
        |> NavBar.view model.navState


mainContent : Model -> Html Msg
mainContent model =
    Grid.container [] <|
        case model.page of
            Home ->
                pageHome model

            About ->
                pageAbout model

            NotFound ->
                pageNotFound


pageHome : Model -> List (Html Msg)
pageHome model =
    [ h1 [] [ text "Stopwatch" ]
    , Grid.row []
        [ Grid.col []
            [ h2 [] [ text (model.numberOfSeconds
                        |> secondsToTimeForDisplay
                        |> timeForDisplayToString)
                    ]
            , Button.button
                    [ Button.primary
                    , Button.large
                    , Button.attrs [ onClick (messageFromButton model) ]
                    ]
                    [ text (titleForButton model) ]
            , showStopButtonIfNeeded model
            , showResetButtonIfNeeded model
            ]
        ]
    , Grid.row []
        [ Grid.col []
            [ h2 [] [text "Laps:"]
            , ListGroup.ul
                (List.map (\time -> ListGroup.li [] [ text (timeForDisplayToString (secondsToTimeForDisplay time))]) model.times)
            ]
        ]
    ]


pageAbout : Model -> List (Html Msg)
pageAbout _ =
    [ h1 [] [ text "About" ]
    , text "TODO: About VG soft and link to repo"
    ]


pageNotFound : List (Html Msg)
pageNotFound =
    [ h1 [] [ text "Not found" ]
    , text "Sorry couldn't find that page"
    ]



secondsToTimeForDisplay : Int -> TimeForDisplay
secondsToTimeForDisplay numberOfSeconds =
    let
        hours = numberOfSeconds // 3600
        minutes = (numberOfSeconds - (hours * 3600))  // 60
        seconds = modBy 60 numberOfSeconds
    in
    { hours = hours
    , minutes = minutes
    , seconds = seconds
    }


timeForDisplayToString : TimeForDisplay -> String
timeForDisplayToString timeForDisplay =
    join ":" [ (convertToTimeFormat timeForDisplay.hours)
             , (convertToTimeFormat timeForDisplay.minutes)
             , (convertToTimeFormat timeForDisplay.seconds)
             ]


convertToTimeFormat : Int -> String
convertToTimeFormat number =
    if number < 10 then
        concat ["0", (String.fromInt number)]
    else
        String.fromInt number

titleForButton : Model -> String
titleForButton model =
    case model.timerStarted of
        True -> "Lap"
        False -> "Start"

messageFromButton : Model -> Msg
messageFromButton model =
    case model.timerStarted of
        True -> LapTimer
        False -> StartTimer


showStopButtonIfNeeded : Model -> Html Msg
showStopButtonIfNeeded model =
    case model.timerStarted of
        True -> Button.button
                    [ Button.secondary
                    , Button.large
                    , Button.attrs [ onClick StopTimer ]
                    ]
                    [ text "Stop" ]
        False -> text ""


showResetButtonIfNeeded : Model -> Html Msg
showResetButtonIfNeeded model =
    if model.timerStarted == False && model.numberOfSeconds > 0 then
        Button.button
            [ Button.secondary
            , Button.large
            , Button.attrs [ onClick ResetTimer ]
            ]
            [ text "Reset" ]
    else
        text ""
