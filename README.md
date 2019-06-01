# ryannhg/application
> an experimental way to build single page applications with Elm!

## Overview

The goal of this project is to make it easy to add new pages to a single page app, while allowing the pages to be as simple/complex as they need to be.

The idea is asking users for a record that provides their page information (`init`, `update`, `view`, etc).

To be consistent with [elm/browser](https://package.elm-lang.org/packages/elm/browser/latest/Browser), I stole the same terminology and function signatures.

### Sandbox Pages

These are the simplest pages, just like [the classic counter example](https://guide.elm-lang.org).

```elm
type alias SandboxPage model msg appModel appMsg =
    { title : String
    , init : model
    , update : msg -> model -> model
    , view : model -> Html msg
    , toMsg : msg -> appMsg
    , toModel : model -> appModel
    }
```

__Example:__ [`Page.About`](./src/Page/About.elm)

### Element Pages

When you are ready for `Cmd` and `Sub`, and need to read the global context you can upgrade to an `ElementPage`.

```elm
type alias ElementPage context model msg appModel appMsg =
    { title : String
    , init : context -> ( model, Cmd msg )
    , view : model -> Html msg
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , toMsg : model -> msg -> appMsg
    , toModel : model -> appModel
    }
```

__Example:__ [`Page.Careers`](./src/Page/Careers.elm)

### Document Pages

For when you want to control the tab title, you can make an `DocumentPage`.

```elm
type alias DocumentPage context model msg appModel appMsg =
    { init : context -> ( model, Cmd msg )
    , view : model -> Browser.Document msg
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , toMsg : msg -> appMsg
    , toModel : model -> appModel
    }
```

__Example:__ [`Page.Homepage`](./src/Page/Homepage.elm)


### Application Pages

If you need to update the `Context` with global messages, you can upgrade to a full application page.

```elm
type alias ApplicationPage context contextMsg model msg appModel appMsg =
    { init : context -> ( model, Cmd msg, Cmd contextMsg )
    , view : context -> model -> Browser.Document msg
    , update : context -> msg -> model -> ( model, Cmd msg, Cmd contextMsg )
    , subscriptions : context -> model -> Sub msg
    , toMsg : msg -> appMsg
    , toModel : model -> appModel
    }
```

__Example:__ [`Page.SignIn`](./src/Page/SignIn.elm)

## Adding in a page

With `ryannhg/application`, this diff shows us how to add in a new page:

https://github.com/ryannhg/application/commit/e534ffb56bfc24adbcc153f30e0a13d972ffbfc9


## Try it out!

To get a better understanding, pull this repo and play around with the code:

1. `npm install`

1. `npm run dev`
