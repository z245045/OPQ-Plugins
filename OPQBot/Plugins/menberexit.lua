-- 群员退群通知
local Api = require("coreApi")

function ReceiveFriendMsg(CurrentQQ, data) return 1 end
function ReceiveGroupMsg(CurrentQQ, data) return 1 end

function ReceiveEvents(CurrentQQ, data, extData) 
    if data.FromGroupId == 383770908 
    or data.FromGroupId == 959562190 
    or data.FromGroupId == 661780072 
    then
        
    if data.MsgType == "ON_EVENT_GROUP_EXIT" then
        Api.Api_SendMsg(
            CurrentQQ,
            {
                toUser = data.FromUin,
                sendToType = 2,
                sendMsgType = "TextMsg",
                groupid = 0,
                content = string.format(
                    '群友【%d】\n[表情107]莫得了。\n肯定是没有GHS失望了',
                    extData.UserID
                ),
                atUser = 0
            }
        )
    end
    end
    return 1
end