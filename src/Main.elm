module Main exposing (main)

import Application
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Context
import Html exposing (..)
import Html.Attributes exposing (href)
import Page.Careers
import Page.Homepage
import Page.NotFound
import Page.SignIn
import Route exposing (Route)
import Url exposing (Url)


type alias Flags =
    ()


type alias Model =
    { key : Nav.Key
    , url : Url
    , context : Context.Model
    , page : Page
    }


type Page
    = Careers Page.Careers.Model
    | Homepage Page.Homepage.Model
    | SignIn Page.SignIn.Model
    | NotFound


type Msg
    = AppRequestedUrl UrlRequest
    | AppChangedUrl Url
    | AppSentContextMsg Context.Msg
    | CareersPageSentMsg Page.Careers.Msg
    | HomepagePageSentMsg Page.Homepage.Msg
    | SignInPageSentMsg Page.SignIn.Msg


createPage =
    Application.createPageHandler AppSentContextMsg


pages =
    { careers =
        createPage <|
            Application.fromElementPage
                { title = "Careers"
                , init = Page.Careers.init
                , view = Page.Careers.view
                , update = Page.Careers.update
                , subscriptions = Page.Careers.subscriptions
                , toMsg = CareersPageSentMsg
                , toModel = Careers
                }
    , homepage =
        createPage <|
            Application.fromDocumentPage
                { init = Page.Homepage.init
                , update = Page.Homepage.update
                , view = Page.Homepage.view
                , subscriptions = Page.Homepage.subscriptions
                , toMsg = HomepagePageSentMsg
                , toModel = Homepage
                }
    , signIn =
        createPage
            { init = Page.SignIn.init
            , update = Page.SignIn.update
            , view = Page.SignIn.view
            , subscriptions = Page.SignIn.subscriptions
            , toMsg = SignInPageSentMsg
            , toModel = SignIn
            }
    }


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = AppRequestedUrl
        , onUrlChange = AppChangedUrl
        }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        context =
            Context.Model Nothing

        ( pageModel, cmd ) =
            initPage context (Route.fromUrl url)
    in
    ( { key = key
      , url = url
      , context = context
      , page = pageModel
      }
    , cmd
    )


initPage : Context.Model -> Route -> ( Page, Cmd Msg )
initPage context route =
    case route of
        Route.Homepage ->
            pages.homepage.init context

        Route.SignIn ->
            pages.signIn.init context

        Route.Careers ->
            pages.careers.init context

        Route.NotFound ->
            ( NotFound, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    let
        page =
            viewPage model

        route =
            Route.fromUrl model.url
    in
    { title = page.title
    , body =
        [ div []
            [ ol []
                (List.map (viewLink route model.url)
                    [ ( Route.Careers, "Careers (Element)" )
                    , ( Route.Homepage, "Home (Document)" )
                    , ( Route.SignIn, "Sign In (Application)" )
                    , ( Route.NotFound, "Not Found (Static)" )
                    ]
                )
            , div [] page.body
            ]
        ]
    }


viewLink : Route -> Url -> ( Route, String ) -> Html Msg
viewLink currentRoute url ( route, label ) =
    li []
        [ a [ href (Route.toUrl route url |> Url.toString) ] [ text label ]
        , text
            (if currentRoute == route then
                " (current route)"

             else
                ""
            )
        ]


viewPage : Model -> Browser.Document Msg
viewPage { url, page, context } =
    case page of
        Homepage model ->
            pages.homepage.view context model

        SignIn model ->
            pages.signIn.view context model

        Careers model ->
            pages.careers.view context model

        NotFound ->
            { title = "Not Found"
            , body = [ Page.NotFound.view ]
            }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AppRequestedUrl urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )

        AppChangedUrl url ->
            let
                ( pageModel, pageCmd ) =
                    initPage model.context (Route.fromUrl url)
            in
            ( { model
                | url = url
                , page = pageModel
              }
            , pageCmd
            )

        AppSentContextMsg msg_ ->
            case msg_ of
                Context.SignIn user ->
                    ( { model | context = Context.signIn user model.context }
                    , Cmd.none
                    )

                Context.SignOut ->
                    ( { model | context = Context.signOut model.context }
                    , Cmd.none
                    )

        CareersPageSentMsg msg_ ->
            case model.page of
                Careers model_ ->
                    updatePage model (pages.careers.update model.context msg_ model_)

                _ ->
                    ( model, Cmd.none )

        HomepagePageSentMsg msg_ ->
            case model.page of
                Homepage model_ ->
                    updatePage model (pages.homepage.update model.context msg_ model_)

                _ ->
                    ( model, Cmd.none )

        SignInPageSentMsg msg_ ->
            case model.page of
                SignIn model_ ->
                    updatePage model (pages.signIn.update model.context msg_ model_)

                _ ->
                    ( model, Cmd.none )


updatePage : Model -> ( Page, Cmd Msg ) -> ( Model, Cmd Msg )
updatePage model ( page, cmd ) =
    ( { model | page = page }
    , cmd
    )


subscriptions : Model -> Sub Msg
subscriptions { page, context } =
    case page of
        Homepage model ->
            pages.homepage.subscriptions model context

        SignIn model ->
            pages.signIn.subscriptions model context

        Careers model ->
            pages.careers.subscriptions model context

        NotFound ->
            Sub.none
