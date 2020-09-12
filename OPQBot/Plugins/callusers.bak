-- 召唤群友
local Api = require("coreApi")

function ReceiveFriendMsg(CurrentQQ, data)
    return 1
end

function ReceiveEvents(CurrentQQ, data, extData)
    return 1
end

function ReceiveGroupMsg(CurrentQQ, data)
    if data.FromUserId == tonumber(CurrentQQ) then
        return 1
    end
    if data.Content == '召唤群友' then
        Api.Api_SendMsg(
            CurrentQQ,
            {
                toUser = data.FromGroupId,
                sendToType = 2,
                sendMsgType = "XmlMsg",
                groupid = 0,
                content = [[<?xml version='1.0' encoding='UTF-8' standalone='yes' ?><msg serviceID="107" templateID="1" action="viewReceiptMessage" brief="[回执消息]" m_resid="1tko/MQMaPR0jedOx6T8tbleZtAZudGqTFakakLqukDzuTjrZS1/1V1QEUnZ8/2Y" m_fileName="6828184148041033822" sourceMsgId="0" url="" flag="3" adverSign="0" multiMsgFlag="0"><item layout="29" advertiser_id="0" aid="0"><type>1</type></item><source name="" icon="" action="" appid="-1" /></msg>]],
                atUser = data.FromUserId
            }
        )
        return 2
    end
    return 1
end

