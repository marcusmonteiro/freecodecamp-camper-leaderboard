module App exposing (Model, Msg, init, view, update, subscriptions)


import Html exposing (Html, button, img, div, text, table, tbody, td, thead, tr, th)
import Html.Attributes exposing (alt, class, src, style)
import Html.Events exposing (onClick)
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


type Msg
  = FetchTop100CampersRecent
  | LoadTop100CampersRecent (Result Http.Error Model)
  | FetchTop100CampersAllTime
  | LoadTop100CampersAllTime (Result Http.Error Model)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        FetchTop100CampersRecent ->
            (model, loadTop100CampersRecent)

        LoadTop100CampersRecent (Ok top100CampersRecent) ->
            (List.sortWith descendingRecent top100CampersRecent, Cmd.none)

        LoadTop100CampersRecent (Err _) ->
            (model, Cmd.none)

        FetchTop100CampersAllTime ->
            (model, loadTop100CampersAllTime)

        LoadTop100CampersAllTime (Ok top100CampersAllTime) ->
            (List.sortWith descendingAllTime top100CampersAllTime, Cmd.none)

        LoadTop100CampersAllTime (Err _) ->
            (model, Cmd.none)


descendingRecent a b =
    case compare a.recent b.recent of
        LT -> GT
        EQ -> EQ
        GT -> LT


descendingAllTime a b =
    case compare a.alltime b.alltime of
        LT -> GT
        EQ -> EQ
        GT -> LT


loadTop100CampersRecent : Cmd Msg
loadTop100CampersRecent =
    send LoadTop100CampersRecent fetchTop100CampersRecent


fetchTop100CampersRecent: Http.Request Model
fetchTop100CampersRecent =
    let
      url = "https://fcctop100.herokuapp.com/api/fccusers/top/recent"
    in
      get url campersDecoder


loadTop100CampersAllTime : Cmd Msg
loadTop100CampersAllTime =
    send LoadTop100CampersAllTime fetchTop100CampersAllTime


fetchTop100CampersAllTime: Http.Request Model
fetchTop100CampersAllTime =
    let
      url = "https://fcctop100.herokuapp.com/api/fccusers/top/alltime"
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
    div [class "container-fluid"]
        [ div [class "row"]
              [ div [class "table-responsive"]
                    [ table [class "table table-hover"]
                      [ thead []
                              [ tr []
                                   [ th [] [text "#"]
                                   , th [] [text "Camper Name"]
                                   , th [] [button [class "btn btn-default", onClick FetchTop100CampersRecent] [text "Points in past 30 days"]]
                                   , th [] [button [class "btn btn-default", onClick FetchTop100CampersAllTime] [text "All time points"]]
                                   ]
                              ]
                      , tbody [] (List.map (camperTableRow) (List.indexedMap (,) model))
                      ]
                    ]
              ]
        ]


camperTableRow : (Int, Camper) -> Html Msg
camperTableRow (rank, camper) =
    tr []
       [ td [] [text (toString rank)]
       , td [] [ img [ class "img-responsive img-thumbnail"
                     , src camper.img
                     , alt (String.concat ["Camper ", camper.username, " picture"])
                     , style [("max-width", "7em")]
                     ]
                     []
               , text (camper.username)
               ]
       , td [] [text (toString camper.recent)]
       , td [] [text (toString camper.alltime)]
       ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
