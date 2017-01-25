module App exposing (Model, Msg, init, view, update, subscriptions)


import Html exposing (Html, img, text, table, tbody, td, thead, tr, th)
import Html.Attributes exposing (alt, src)
import Json.Decode exposing (Decoder, int, string)
import Json.Decode.Pipeline exposing (decode, required)


type alias Camper =
    { username: String
    , img: String
    , alltime: Int
    , recent: Int
    }


type alias Model =
    List Camper


init : (Model, Cmd Msg)
init =
    (mockCampers, Cmd.none)


type Msg =
    NoOp


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NoOp -> (model, Cmd.none)


camperDecoder : Decoder Camper
camperDecoder =
    decode Camper
    |> required "username" string
    |> required "img" string
    |> required "alltime" int
    |> required "recent" int


mockCampers : Model
mockCampers =
    [ Camper "Marcus" "#" 50 100
    , Camper "Burger" "##" 20 200
    ]


view : Model -> Html Msg
view model =
    table []
          [ thead []
                  [ tr []
                       [ th [] [text "#"]
                       , th [] [text "Camper Name"]
                       , th [] [text "Points in past 30 days"]
                       , th [] [text "All time points"]
                       ]
                  ]
          , tbody [] (List.map (camperTableRow) (List.indexedMap (,) model))
          ]


camperTableRow : (Int, Camper) -> Html Msg
camperTableRow (rank, camper) =
    tr []
       [ td [] [text (toString rank)]
       , td [] [ img [src camper.img, alt "Camper profile picture"] []
               , text camper.username
               ]
       , td [] [text (toString camper.alltime)]
       , td [] [text (toString camper.recent)]
       ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
