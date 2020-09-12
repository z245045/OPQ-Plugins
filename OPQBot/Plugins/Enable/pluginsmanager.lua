local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")

function ReceiveFriendMsg(CurrentQQ, data)
    return 1
end

function ReceiveGroupMsg(CurrentQQ, data)
	if data.Content == '插件列表' then 
        local ts = io.popen("ls ./Plugins/")
        local ls = ts:read("*all")

        Api.Api_SendMsg(
            CurrentQQ,
            {
                toUser = data.FromGroupId,
                sendToType = 2,
                sendMsgType = "TextMsg",
                groupid = 0,
                content = "Lua插件：\n" .. ls,
                atUser = 0
            }
        )
    end

    return 1
end

function ReceiveEvents(CurrentQQ, data, extData)
    return 1
end
	