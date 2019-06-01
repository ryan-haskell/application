module Page.Careers exposing (Model, Msg, init, subscriptions, update, view)

-- This is an example of an `ElementPage`

import Browser.Dom as Dom
import Browser.Events as Events
import Context
import Html exposing (..)
import Task exposing (Task)


type alias Model =
    { window : Maybe { width : Int, height : Int }
    }


type Msg
    = AppGotViewport Dom.Viewport
    | WindowResized Int Int


init : Context.Model -> ( Model, Cmd Msg )
init _ =
    ( Model Nothing
    , Task.perform AppGotViewport Dom.getViewport
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AppGotViewport { viewport } ->
            ( { model
                | window =
                    Just
                        { width = floor viewport.width
                        , height = floor viewport.height
                        }
              }
            , Cmd.none
            )

        WindowResized width height ->
            ( { model
                | window =
                    Just
                        { width = width
                        , height = height
                        }
              }
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    div []
        [ case model.window of
            Just { width, height } ->
                text ("The window is: " ++ String.fromInt width ++ "px by " ++ String.fromInt height ++ "px")

            Nothing ->
                text "I don't know the window size..."
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Events.onResize WindowResized
