module Application exposing
    ( createPageHandler
    , fromDocumentPage
    , fromElementPage
    , fromSandboxPage
    )

import Browser
import Html exposing (Html)


type alias PageHandler context model msg appModel appMsg =
    { init : PageInitHandler context appModel appMsg
    , update : PageUpdateHandler context model msg appModel appMsg
    , view : PageViewHandler context model appMsg
    , subscriptions : PageSubscriptionsHandler context model appMsg
    }


createPageHandler :
    (contextMsg -> appMsg)
    -> ApplicationPage context contextMsg model msg appModel appMsg
    -> PageHandler context model msg appModel appMsg
createPageHandler toContextMsg { init, update, view, subscriptions, toMsg, toModel } =
    { init =
        handlePageInit
            { init = init
            , toMsg = toMsg
            , toModel = toModel
            , toContextMsg = toContextMsg
            }
    , update =
        handlePageUpdate
            { update = update
            , toModel = toModel
            , toMsg = toMsg
            , toContextMsg = toContextMsg
            }
    , view =
        handlePageView
            { view = view
            , toMsg = toMsg
            }
    , subscriptions =
        handlePageSubscriptions
            { subscriptions = subscriptions
            , toMsg = toMsg
            }
    }



-- SANDBOX


type alias SandboxPage model msg appModel appMsg =
    { title : String
    , init : model
    , update : msg -> model -> model
    , view : model -> Html msg
    , toMsg : msg -> appMsg
    , toModel : model -> appModel
    }


fromSandboxPage :
    SandboxPage model msg appModel appMsg
    -> ApplicationPage context contextMsg model msg appModel appMsg
fromSandboxPage { title, init, view, update, toMsg, toModel } =
    fromElementPage
        { title = title
        , init = always ( init, Cmd.none )
        , view = view
        , update = \msg model -> ( update msg model, Cmd.none )
        , subscriptions = always Sub.none
        , toMsg = toMsg
        , toModel = toModel
        }



-- ELEMENT


type alias ElementPage context model msg appModel appMsg =
    { title : String
    , init : context -> ( model, Cmd msg )
    , view : model -> Html msg
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , toMsg : msg -> appMsg
    , toModel : model -> appModel
    }


fromElementPage :
    ElementPage context model msg appModel appMsg
    -> ApplicationPage context contextMsg model msg appModel appMsg
fromElementPage { title, init, view, update, subscriptions, toMsg, toModel } =
    fromDocumentPage
        { init = init
        , view = \model -> view model |> (\html -> { title = title, body = [ html ] })
        , update = update
        , subscriptions = subscriptions
        , toMsg = toMsg
        , toModel = toModel
        }



-- DOCUMENT


type alias DocumentPage context model msg appModel appMsg =
    { init : context -> ( model, Cmd msg )
    , view : model -> Browser.Document msg
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , toMsg : msg -> appMsg
    , toModel : model -> appModel
    }


fromDocumentPage :
    DocumentPage context model msg appModel appMsg
    -> ApplicationPage context contextMsg model msg appModel appMsg
fromDocumentPage { init, view, update, subscriptions, toMsg, toModel } =
    { init = init >> appendCmdNone
    , view = always view
    , update = \_ msg model -> update msg model |> appendCmdNone
    , subscriptions = always subscriptions
    , toMsg = toMsg
    , toModel = toModel
    }


appendCmdNone : ( model, Cmd msg ) -> ( model, Cmd msg, Cmd otherMsg )
appendCmdNone ( model, cmd ) =
    ( model, cmd, Cmd.none )



-- APPLICATION


type alias ApplicationPage context contextMsg model msg appModel appMsg =
    { init : context -> ( model, Cmd msg, Cmd contextMsg )
    , view : context -> model -> Browser.Document msg
    , update : context -> msg -> model -> ( model, Cmd msg, Cmd contextMsg )
    , subscriptions : context -> model -> Sub msg
    , toMsg : msg -> appMsg
    , toModel : model -> appModel
    }



-- INIT


type alias PageInitConfig context contextMsg model msg appModel appMsg =
    { init : context -> ( model, Cmd msg, Cmd contextMsg )
    , toMsg : msg -> appMsg
    , toModel : model -> appModel
    , toContextMsg : contextMsg -> appMsg
    }


type alias PageInitHandler context appModel appMsg =
    context -> ( appModel, Cmd appMsg )


handlePageInit :
    PageInitConfig context contextMsg model msg appModel appMsg
    -> PageInitHandler context appModel appMsg
handlePageInit config context =
    let
        ( pageModel, pageCmd, contextCmd ) =
            config.init context
    in
    ( config.toModel pageModel
    , Cmd.batch
        [ Cmd.map config.toMsg pageCmd
        , Cmd.map config.toContextMsg contextCmd
        ]
    )



-- UPDATE


type alias PageUpdateConfig context contextMsg model msg appModel appMsg =
    { update : context -> msg -> model -> ( model, Cmd msg, Cmd contextMsg )
    , toModel : model -> appModel
    , toMsg : msg -> appMsg
    , toContextMsg : contextMsg -> appMsg
    }


type alias PageUpdateHandler context model msg appModel appMsg =
    context
    -> msg
    -> model
    -> ( appModel, Cmd appMsg )


handlePageUpdate :
    PageUpdateConfig context contextMsg model msg appModel appMsg
    -> PageUpdateHandler context model msg appModel appMsg
handlePageUpdate config context msg_ model_ =
    let
        ( pageModel, pageCmd, contextCmd ) =
            config.update context msg_ model_
    in
    ( config.toModel pageModel
    , Cmd.batch
        [ Cmd.map config.toMsg pageCmd
        , Cmd.map config.toContextMsg contextCmd
        ]
    )



-- VIEW


type alias PageViewConfig context model msg appMsg =
    { view : context -> model -> Browser.Document msg
    , toMsg : msg -> appMsg
    }


type alias PageViewHandler context model appMsg =
    context
    -> model
    -> Browser.Document appMsg


handlePageView :
    PageViewConfig context model msg appMsg
    -> PageViewHandler context model appMsg
handlePageView config context model =
    let
        { title, body } =
            config.view context model
    in
    { title = title
    , body = List.map (Html.map config.toMsg) body
    }



-- SUBSCRIPTIONS


type alias PageSubscriptionsConfig context model msg appMsg =
    { toMsg : msg -> appMsg
    , subscriptions : context -> model -> Sub msg
    }


type alias PageSubscriptionsHandler context model appMsg =
    model
    -> context
    -> Sub appMsg


handlePageSubscriptions :
    PageSubscriptionsConfig context model msg appMsg
    -> PageSubscriptionsHandler context model appMsg
handlePageSubscriptions config model context =
    Sub.map
        config.toMsg
        (config.subscriptions context model)
