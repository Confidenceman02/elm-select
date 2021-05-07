port module Ports exposing (kaizenConnectSelectInputDynamicWidth, kaizenDisconnectSelectInputDynamicWidth)

import Json.Encode as Encode


port kaizenConnectSelectInputDynamicWidth : Encode.Value -> Cmd msg


port kaizenDisconnectSelectInputDynamicWidth : Encode.Value -> Cmd msg
