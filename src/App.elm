module App exposing (Model, Msg, init, view, update, subscriptions)


import Html exposing (Html, img, text, table, tbody, td, thead, tr, th)
import Html.Attributes exposing (alt, src)
import Http exposing (get, send)
import Json.Decode exposing (Decoder, int, list, string)
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
    ([], loadTop100CampersRecent)


type Msg =
    LoadTop100CampersRecent (Result Http.Error Model)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        LoadTop100CampersRecent (Ok top100CampersRecent) ->
            (top100CampersRecent, Cmd.none)

        LoadTop100CampersRecent (Err _) ->
            (model, Cmd.none)


loadTop100CampersRecent : Cmd Msg
loadTop100CampersRecent =
    send LoadTop100CampersRecent fetchTop100CampersRecent


fetchTop100CampersRecent: Http.Request Model
fetchTop100CampersRecent =
    let
      url = "https://fcctop100.herokuapp.com/api/fccusers/top/recent"
    in
      get url campersDecoder


campersDecoder : Decoder Model
campersDecoder =
    list camperDecoder


camperDecoder : Decoder Camper
camperDecoder =
    decode Camper
    |> required "username" string
    |> required "img" string
    |> required "alltime" int
    |> required "recent" int


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
