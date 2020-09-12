local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")

function ReceiveFriendMsg(CurrentQQ, data)
    return 1
end

function ReceiveGroupMsg(CurrentQQ, data)
    if data.FromGroupId == 1048779434 then
    if data.content == data.content then
        --log.notice("From Lua data.FromGroupId %d", data.FromGroupId)
        luaRes =
            Api.Api_SendMsg(
            CurrentQQ,
            {
                toUser = 959562190,
                sendToType = 2,
                sendMsgType = "TextMsg",
                groupid = 959562190,
                content = "【就业指导群】：\n"..data.FromNickName.."："..data.content,
                atUser = 0
            }
        )
        log.notice("From Lua SendMsg Ret-->%d", luaRes.Ret)
    end
    end
    
    if data.FromGroupId == 1048779434 then
    if data.content == data.content then
        --log.notice("From Lua data.FromGroupId %d", data.FromGroupId)
        luaRes =
            Api.Api_SendMsg(
            CurrentQQ,
            {
                toUser = 383770908,
                sendToType = 2,
                sendMsgType = "TextMsg",
                groupid = 383770908,
                content = "【就业指导群】：\n"..data.FromNickName.."："..data.content,
                atUser = 0
            }
        )
        log.notice("From Lua SendMsg Ret-->%d", luaRes.Ret)
    end
    end
    
    return 1
end

function ReceiveEvents(CurrentQQ, data, extData)
    return 1
end
