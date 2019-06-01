module Page.Homepage exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

-- This is an example of an `DocumentPage`

import Browser
import Context
import DateFormat
import Html exposing (..)
import Task exposing (Task)
import Time exposing (Posix, Zone)


type alias Model =
    { posix : Maybe Posix
    , zone : Maybe Zone
    }


type Msg
    = AppReceivedTime Posix
    | AppReceivedZone Zone


init : Context.Model -> ( Model, Cmd Msg )
init context =
    ( Model Nothing Nothing
    , Cmd.batch
        [ Task.perform AppReceivedTime Time.now
        , Task.perform AppReceivedZone Time.here
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AppReceivedTime posix ->
            ( { model | posix = Just posix }
            , Cmd.none
            )

        AppReceivedZone zone ->
            ( { model | zone = Just zone }
            , Cmd.none
            )


view : Model -> Browser.Document Msg
view model =
    { title =
        case ( model.zone, model.posix ) of
            ( Just zone, Just posix ) ->
                format zone posix

            ( _, _ ) ->
                "Homepage"
    , body =
        [ h1 [] [ text "This is the homepage!" ]
        , p []
            [ case ( model.zone, model.posix ) of
                ( Just zone, Just posix ) ->
                    text ("You loaded this page at " ++ format zone posix ++ "? Just ask the browser tab!")

                ( _, _ ) ->
                    text "And I dont even know what time it is!"
            ]
        ]
    }


format : Zone -> Posix -> String
format =
    DateFormat.format
        [ DateFormat.monthNameFull
        , DateFormat.text " "
        , DateFormat.dayOfMonthSuffix
        , DateFormat.text ", "
        , DateFormat.yearNumber
        , DateFormat.text " at "
        , DateFormat.hourNumber
        , DateFormat.text ":"
        , DateFormat.minuteFixed
        , DateFormat.amPmLowercase
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
