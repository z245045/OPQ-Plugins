local Api = require("coreApi")
local http = require("http")


function ReceiveFriendMsg(CurrentQQ, data)
    return 1
end

function ReceiveEvents(CurrentQQ, data, extData)
    return 1
end

function ReceiveGroupMsg(CurrentQQ, data)
    if data.FromUserId ~= tonumber(CurrentQQ) then
        if data.Content == "微博" then
            rep, _ = http.request(
                "GET",
                "http://127.0.0.1:8888/weibo_hot/"
            )
            Api.Api_SendMsg(
                CurrentQQ,
                {
                    toUser = data.FromGroupId,
                    sendToType = 2,
                    sendMsgType = "TextMsg",
                    groupid = 0,
                    content = rep.body,
                    atUser = 0
                }
            )
        end
    end
    return 1
end
