-- pix 动漫图
local api = require("coreApi")
local http = require("http")

function ReceiveFriendMsg(CurrentQQ, data)
    return 1
end

function ReceiveGroupMsg(CurrentQQ, data)
    if data.FromGroupId == 383770908 
    or data.FromGroupId == 959562190 
    or data.FromGroupId == 661780072 
    then
    
    if data.Content == '买家秀' then
       api.Api_SendMsg(
           CurrentQQ,
            {
              toUser = data.FromGroupId,
              sendToType = 2,
              sendMsgType = "PicMsg",
              content = "30s自动撤回",
              groupid = 0,
              atUser = 0,
              picUrl = "https://api.lyiqk.cn/mjx",
              picBase64Buf = "",
              fileMd5 = ""
            }
       )
    end
    if data.Content == '买家秀' then
       api.Api_SendMsg(
           CurrentQQ,
            {
              toUser = data.FromGroupId,
              sendToType = 2,
              sendMsgType = "PicMsg",
              content = "30s自动撤回",
              groupid = 0,
              atUser = 0,
              picUrl = "https://api.uomg.com/api/rand.img3",
              picBase64Buf = "",
              fileMd5 = ""
            }
       )
        end
    if data.Content == '买家秀' then
       api.Api_SendMsg(
           CurrentQQ,
            {
              toUser = data.FromGroupId,
              sendToType = 2,
              sendMsgType = "PicMsg",
              content = "30s自动撤回",
              groupid = 0,
              atUser = 0,
              picUrl = "https://api.66mz8.com/api/rand.tbimg.php",
              picBase64Buf = "",
              fileMd5 = ""
            }
       )
    end
    end
    return 1
end

function ReceiveEvents(CurrentQQ, data, extData)
    return 1
end
