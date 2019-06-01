module Context exposing
    ( Model
    , Msg(..)
    , User
    , signIn
    , signOut
    )


type alias User =
    String


type alias Model =
    { user : Maybe User
    }


type Msg
    = SignIn User
    | SignOut


signIn : User -> Model -> Model
signIn user context =
    { context | user = Just user }


signOut : Model -> Model
signOut context =
    { context | user = Nothing }
