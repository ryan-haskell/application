module Page.NotFound exposing (view)

-- Here's an example of a static page
-- that doesn't get registered as a handler.

import Html exposing (..)


view : Html msg
view =
    div [] [ text "Page not found." ]
