local Api = require('coreApi')

function ReceiveGroupMsg(CurrentQQ, data)
    if data.FromUserId == tonumber(CurrentQQ) then
        if data.Content:find('30s自动撤回') then
            local delay = 30 --默认10s后撤回
            local num = data.Content:match('30s自动撤回%[(%d+)%]') --revoke[20] 20s后撤回
            if tonumber(num) then
                delay = tonumber(num)
            end
            os.execute('sleep ' .. delay)
            Api.Api_CallFunc(
                CurrentQQ,
                'PbMessageSvc.PbMsgWithDraw',
                {
                    GroupID = data.FromGroupId,
                    MsgSeq = data.MsgSeq,
                    MsgRandom = data.MsgRandom
                }
            )
            return 2
        end
    end
end

function ReceiveFriendMsg(CurrentQQ, data)
    return 1
end

function ReceiveEvents(CurrentQQ, data, extData)
    return 1
end
