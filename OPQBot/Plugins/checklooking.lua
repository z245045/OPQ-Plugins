local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")

function ReceiveFriendMsg(CurrentQQ, data)
	return 1
end

function ReceiveGroupMsg(CurrentQQ, data)
	if string.find(data.Content, "有人窥屏") == 1 then
	
        Api.Api_SendMsg(
            CurrentQQ,
            {
                toUser = data.FromGroupId,
                sendToType = 2,
                sendMsgType = "XmlMsg",
                groupid = 0,
                content = "<?xml version='1.0' encoding='UTF-8' standalone='yes' ?><msg serviceID=\"146\" templateID=\"1\" action=\"web\" brief=\"[分享] 窥屏检测\" sourceMsgId=\"0\" url=\"https://hanximeng.com\" flag=\"0\" adverSign=\"0\" multiMsgFlag=\"0\"><item layout=\"2\" advertiser_id=\"0\" aid=\"0\"><picture cover=\"http://fh-1.ml:81/QQ_BOT/Plugins/kuiping/api.php?username=" .. data.FromGroupId .. "&amp;time=" .. data.MsgTime .. "\" w=\"0\" h=\"0\" /><title>窥屏检测</title><summary>正在获取数据中……</summary></item><source name=\"寒曦朦_BOT\" icon=\"http://url.cn/Vz4VWiP4\" url=\"https://hanximeng.com\" action=\"app\" a_actionData=\"https://hanximeng.com\" i_actionData=\"https://hanximeng.com\" appid=\"-1\" /></msg>",
                atUser = data.FromUserId
            }
        )
        
        function sleep(n)
  local t = os.clock()
  while os.clock() - t <= n do
    -- nothing
  end
end
sleep(10)
response, error_message =
		    http.request(
		    "GET",
		    "http://fh-1.ml:81/QQ_BOT/Plugins/kuiping/api.php",
		    {
		        query = "type=info&username=" .. data.FromGroupId
		    }
		)
Api.Api_SendMsg(
            CurrentQQ,
            {
                toUser = data.FromGroupId,
                sendToType = 2,
                sendMsgType = "TextMsg",
                groupid = 0,
                content = response.body,
                atUser = data.FromUserId
            }
        )
       end

       
    return 1
end
function ReceiveEvents(CurrentQQ, data, extData)
    return 1
end