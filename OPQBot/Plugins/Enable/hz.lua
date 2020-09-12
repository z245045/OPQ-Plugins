local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")

function ReceiveFriendMsg(CurrentQQ, data)
    if string.find(data.Content, "hz") == 1 then --判断一下所接收的消息里是否含有复读机字样 有则进行处理
        keyWord = data.Content:gsub("hz", "") --提取关键词 保存到keyWord里
				log.notice("keyWord-->%s",keyWord)
		if keyWord == "" then
							return 1
					end
		response, error_message =
							http.request(
							"GET",
							"http://hz.goodby.xyz:81/api.php",
							{
									query = "act=user&key=goodby&phone=".. keyWord
							 --    headers = {
								-- 		User-Agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.132 Safari/537.36"
								-- 	}
							}
					)			
					local html = response.body
					local strJson = json.decode(html)
					local result = strJson["msg"]
					if result == "" then
					    result="请求成功发送"
					    end
					local content = string.format(
                        "hz执行状态:%s\n被hz的小可怜:%s",
                        result,
                        keyWord
                    )
        
		Api.Api_SendMsg(--调用发消息的接口
		    CurrentQQ,
		    {
		        toUser = data.FromUin, --回复当前消息的来源群ID
			    sendToType = 1, --2发送给群1发送给好友3私聊
			    sendMsgType = "TextMsg", --进行文本复读回复
				groupid = 0, --不是私聊自然就为0咯
				content = content, --回复内容
				atUser = 0 --是否 填上data.FromUserId就可以复读给他并@了
		    }
		)
		
	end
    return 1
end
function ReceiveGroupMsg(CurrentQQ, data)
	if string.find(data.Content, "hz") == 1 then --判断一下所接收的消息里是否含有复读机字样 有则进行处理
        keyWord = data.Content:gsub("hz", "") --提取关键词 保存到keyWord里
				log.notice("keyWord-->%s",keyWord)
		if keyWord == "" then
							return 1
					end
		response, error_message =
							http.request(
							"GET",
							"http://127.0.0.1:81/api.php",
							{
									query = "act=user&key=goodby&phone=".. keyWord
							 --    headers = {
								-- 		User-Agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.132 Safari/537.36"
								-- 	}
							}
					)			
					local html = response.body
					local strJson = json.decode(html)
					local result = strJson["msg"]
					if result == "" then
					    result="请求成功发送"
					    end
					local content = string.format(
                        "hz执行状态:%s\n被hz的小可怜:%s",
                        result,
                        keyWord
                    )
        
		Api.Api_SendMsg(--调用发消息的接口
		    CurrentQQ,
		    {
		        toUser = data.FromGroupId, --回复当前消息的来源群ID
		        sendToType = 2, --2发送给群1发送给好友3私聊
		        sendMsgType = "TextMsg", --进行文本复读回复
		        groupid = 0, --不是私聊自然就为0咯
		        content = content, --回复内容
		        atUser = data.FromUserId --是否 填上data.FromUserId就可以复读给他并@了
		    }
		)
		
	end
    return 1
end
function ReceiveEvents(CurrentQQ, data, extData)
    return 1
end
