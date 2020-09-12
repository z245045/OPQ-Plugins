local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")

local whitelist = { 959562190,
    383770908,
    581168848,
    661780072,
} -- 只有白名单里的群中可以使用色图指令

local function contains(table, val)
   for i = 1, #table do
      if table[i] == val then 
         return true
      end
   end
   return false
end

function ReceiveFriendMsg(CurrentQQ, data)
    return 1
end
function ReceiveGroupMsg(CurrentQQ, data)
    if (string.find(data.Content, "来点涩图") ~= 1 and string.find(data.Content, "不够色") ~= 1 ) then
        return 1
    end
    if not contains(whitelist, data.FromGroupId) then
        return 1
    end
    
    local idx = math.random(0, 95) -- 有效的索引从0000 ~ 0095
    idx = string.format('%04d', idx) -- 前面填充0,
    local url = "https://cdn.jsdelivr.net/gh/ipchi9012/setu_pics@latest/setu_" .. idx .. ".js" -- 索引文件地址
    log.info("url=%s", url)
    local resp = http.request("GET", url).body
    idx = string.find(resp, "(", 1, true)
    resp = string.sub(resp, idx + 1, -2) -- 去掉前面的setu_xxxx(和后面的)
    resp = json.decode(resp)
    local item = resp[math.random(#resp)] -- 从数组中随机选取一个元素
    local url = "https://cdn.jsdelivr.net/gh/ipchi9012/setu_pics@latest/" .. item.path
    local text = "『" .. item.title .. "』 作者：" .. item.author .. "\n原图：" .. item.url
    log.info("url=%s, text=%s", url, text)
    ApiRet = Api.Api_SendMsg(
        CurrentQQ,
        {
            toUser = data.FromGroupId,
            sendToType = 2,
            sendMsgType = "PicMsg", 
            groupid = 0,
            content = "30s自动撤回",
            picUrl = url,
            atUser = 0
        }
    )
    return 1
end

function ReceiveEvents(CurrentQQ, data, extData)
    return 1
end