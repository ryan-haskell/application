module Page.About exposing (Model, Msg, init, update, view)

-- This is an example of a `SandboxPage`

import Html exposing (..)
import Html.Events exposing (onClick)


type alias Model =
    { counter : Int
    }


type Msg
    = Increment
    | Decrement


init : Model
init =
    { counter = 0 }


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            { model | counter = model.counter + 1 }

        Decrement ->
            { model | counter = model.counter - 1 }


view : Model -> Html Msg
view model =
    div []
        [ div [ onClick Increment ] [ text "+" ]
        , div [] [ text (String.fromInt model.counter) ]
        , div [ onClick Decrement ] [ text "-" ]
        ]
