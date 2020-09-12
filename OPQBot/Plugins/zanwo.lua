local Api = require("coreApi")
local http = require("http")
local json = require("json")

function checkUser(id)
    local today = tonumber(os.date('%d'))
    local cacheFileName = './Plugins/CachedLikeYouData'..today
    local f_r, _ = io.open(cacheFileName, 'r')
    if f_r == nil then
        os.execute('rm ./Plugins/CachedLikeYouData*')
        local users = {}
        table.insert (users, id)
        local f_w, _ = io.open(cacheFileName, 'w')
        f_w:write(json.encode(users))
        f_w:close()
        return true
    end
    local users = json.decode(f_r:read("*all"))
    for _,user in ipairs(users) do
        if user == id then
            return false
        end
    end
    table.insert(users, id)
    local f_w, _ = io.open(cacheFileName, 'w')
    f_w:write(json.encode(users))
    f_w:close()
    return true
end

function send(bot, gid, text, at)
    if at == nil then
        at = 0
    end
    Api.Api_SendMsg(
        bot,
        {
            toUser = gid,
            sendToType = 2,
            sendMsgType = "TextMsg",
            groupid = 0,
            content = text,
            atUser = at
        }
    )
end

function ReceiveGroupMsg(CurrentQQ, data)
    if data.FromUserId == tonumber(CurrentQQ) then
        return 1
    end
    if data.Content:find('赞我') then
        if checkUser(data.FromUserId) then
            send(CurrentQQ, data.FromGroupId, '\n正在赞...', data.FromUserId)
            for _ = 1, 10 do
                Api.Api_CallFunc(
                    CurrentQQ,
                    "OidbSvc.0x7e5_4",
                    { UserID = data.FromUserId}
                )
                os.execute('sleep 0.5') --20/50
            end
            send(CurrentQQ, data.FromGroupId, '\n赞完啦~', data.FromUserId)
        else
            send(CurrentQQ, data.FromGroupId, '\n今日已赞!', data.FromUserId)
        end
    end
    return 1
end

function ReceiveFriendMsg(CurrentQQ, data) return 1 end
function ReceiveEvents(CurrentQQ, data, extData) return 1 end