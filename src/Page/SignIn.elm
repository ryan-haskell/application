module Page.SignIn exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

-- This is an example of an `ApplicationPage`

import Browser
import Context
import Html exposing (..)
import Html.Attributes as Attr exposing (style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Task exposing (Task)
import Time exposing (Posix)


type alias Model =
    { username : String
    , password : String
    }


type Field
    = Username
    | Password


labelOf : Field -> String
labelOf field =
    case field of
        Username ->
            "Username"

        Password ->
            "Password"


type Msg
    = UserEnteredInput Field String
    | SignIn
    | SignOut


init : Context.Model -> ( Model, Cmd Msg, Cmd Context.Msg )
init context =
    ( Model "" ""
    , Cmd.none
    , Cmd.none
    )


update : Context.Model -> Msg -> Model -> ( Model, Cmd Msg, Cmd Context.Msg )
update context msg model =
    case msg of
        UserEnteredInput Username username ->
            ( { model | username = username }
            , Cmd.none
            , Cmd.none
            )

        UserEnteredInput Password password ->
            ( { model | password = password }
            , Cmd.none
            , Cmd.none
            )

        SignIn ->
            if String.isEmpty model.username then
                ( model, Cmd.none, Cmd.none )

            else
                ( clearFields model
                , Cmd.none
                , send (Context.SignIn model.username)
                )

        SignOut ->
            ( model, Cmd.none, send Context.SignOut )


send : msg -> Cmd msg
send msg =
    Task.succeed ()
        |> Task.perform (always msg)


clearFields : Model -> Model
clearFields model =
    { model
        | username = ""
        , password = ""
    }


view : Context.Model -> Model -> Browser.Document Msg
view context model =
    { title = "SignIn"
    , body =
        [ div []
            [ text "This is the sign in page!"
            , case context.user of
                Just user ->
                    div []
                        [ text ("Hey " ++ user)
                        , div []
                            [ button
                                [ onClick SignOut ]
                                [ text "Sign me out!" ]
                            ]
                        ]

                Nothing ->
                    form [ onSubmit SignIn ]
                        [ viewField
                            { field = Username
                            , value = model.username
                            , type_ = "text"
                            }
                        , viewField
                            { field = Password
                            , value = model.password
                            , type_ = "password"
                            }
                        , div [] [ button [ type_ "submit" ] [ text "Sign in" ] ]
                        ]
            ]
        ]
    }


viewField : { field : Field, value : String, type_ : String } -> Html Msg
viewField config =
    label
        [ style "display" "flex"
        , style "flex-direction" "column"
        , style "align-items" "flex-start"
        ]
        [ span [] [ text (labelOf config.field) ]
        , input
            [ type_ config.type_
            , value config.value
            , onInput (UserEnteredInput config.field)
            ]
            []
        ]


subscriptions : Context.Model -> Model -> Sub Msg
subscriptions context model =
    Sub.none
