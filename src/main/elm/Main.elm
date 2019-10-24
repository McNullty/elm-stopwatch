module Main exposing (..)

import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (..)
import Browser.Navigation as Navigation
import Browser exposing (UrlRequest)
import Url exposing (Url)
import Url.Parser as UrlParser exposing ((</>), Parser, s, top)
import Bootstrap.Navbar as NavBar
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Modal as Modal


type alias Flags =
    {}

type alias Model =
    { navKey : Navigation.Key
    , page : Page
    , navState : NavBar.State
    , modalVisibility : Modal.Visibility
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
            urlUpdate url { navKey = key, navState = navState, page = Home, modalVisibility= Modal.hidden }
    in
        ( model, Cmd.batch [ urlCmd, navCmd ] )




type Msg
    = UrlChange Url
    | ClickedLink UrlRequest
    | NavMsg NavBar.State
    | CloseModal
    | ShowModal


subscriptions : Model -> Sub Msg
subscriptions model =
    NavBar.subscriptions model.navState NavMsg


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

        CloseModal ->
            ( { model | modalVisibility = Modal.hidden }
            , Cmd.none
            )

        ShowModal ->
            ( { model | modalVisibility = Modal.shown }
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
            , modal model
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
pageHome _ =
    [ h1 [] [ text "Stopwatch" ]
    , Grid.row []
        [ Grid.col []
            [ text "TODO"
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


modal : Model -> Html Msg
modal model =
    Modal.config CloseModal
        |> Modal.small
        |> Modal.h4 [] [ text "Getting started ?" ]
        |> Modal.body []
            [ Grid.containerFluid []
                [ Grid.row []
                    [ Grid.col
                        [ Col.xs6 ]
                        [ text "Col 1" ]
                    , Grid.col
                        [ Col.xs6 ]
                        [ text "Col 2" ]
                    ]
                ]
            ]
        |> Modal.view model.modalVisibility