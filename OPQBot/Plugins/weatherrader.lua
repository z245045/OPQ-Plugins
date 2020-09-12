local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")

function ReceiveFriendMsg(CurrentQQ, data)
    return 1
end

function ReceiveGroupMsg(CurrentQQ, data)
    --雷达
    if data.Content == '华南' then 
        local time = os.time()
		response, error_message =
		    http.request(
		    "GET",
		    "http://www.nmc.cn/rest/weather",
		    {
		        query = "stationid=59027&_=" ..
		            time,
		        headers = {
		            ["Accept"] = "*/*",
					["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36"
		        }
		    }
		)
		local html = response.body
        local j = json.decode(html)
        local img_url = j.data.radar.image
		local prefix = "http://image.nmc.cn"
		Api.Api_SendMsg(--调用发消息的接口
		    CurrentQQ,
		    {
                toUser = data.FromGroupId, --回复当前消息的来源群ID
		        sendToType = 2, --2发送给群1发送给好友3私聊
		        sendMsgType = "PicMsg", --进行文本复读回复
		        groupid = 0, --不是私聊自然就为0咯
		        content = "", --回复内容
                picUrl = prefix .. img_url,
                picBase64Buf = "",
                fileMd5 = "",
		        atUser = 0 --是否 填上data.FromUserId就可以复读给他并@了
		    }
		)
    end

    if data.Content == '西南' then 
        local time = os.time()
		response, error_message =
		    http.request(
		    "GET",
		    "http://www.nmc.cn/rest/weather",
		    {
		        query = "stationid=56767&_=" ..
		            time,
		        headers = {
		            ["Accept"] = "*/*",
					["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36"
		        }
		    }
		)
		local html = response.body
        local j = json.decode(html)
        local img_url = j.data.radar.image
		local prefix = "http://image.nmc.cn"
		Api.Api_SendMsg(--调用发消息的接口
		    CurrentQQ,
		    {
                toUser = data.FromGroupId, --回复当前消息的来源群ID
		        sendToType = 2, --2发送给群1发送给好友3私聊
		        sendMsgType = "PicMsg", --进行文本复读回复
		        groupid = 0, --不是私聊自然就为0咯
		        content = "", --回复内容
                picUrl = prefix .. img_url,
                picBase64Buf = "",
                fileMd5 = "",
		        atUser = 0 --是否 填上data.FromUserId就可以复读给他并@了
		    }
		)
    end

    if data.Content == '华北' then 
        local time = os.time()
		response, error_message =
		    http.request(
		    "GET",
		    "http://www.nmc.cn/rest/weather",
		    {
		        query = "stationid=54511&_=" ..
		            time,
		        headers = {
		            ["Accept"] = "*/*",
					["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36"
		        }
		    }
		)
		local html = response.body
        local j = json.decode(html)
        local img_url = j.data.radar.image
		local prefix = "http://image.nmc.cn"
		Api.Api_SendMsg(--调用发消息的接口
		    CurrentQQ,
		    {
                toUser = data.FromGroupId, --回复当前消息的来源群ID
		        sendToType = 2, --2发送给群1发送给好友3私聊
		        sendMsgType = "PicMsg", --进行文本复读回复
		        groupid = 0, --不是私聊自然就为0咯
		        content = "", --回复内容
                picUrl = prefix .. img_url,
                picBase64Buf = "",
                fileMd5 = "",
		        atUser = 0 --是否 填上data.FromUserId就可以复读给他并@了
		    }
		)
    end

    if data.Content == '华东' then 
        local time = os.time()
		response, error_message =
		    http.request(
		    "GET",
		    "http://www.nmc.cn/rest/weather",
		    {
		        query = "stationid=58357&_=" ..
		            time,
		        headers = {
		            ["Accept"] = "*/*",
					["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36"
		        }
		    }
		)
		local html = response.body
        local j = json.decode(html)
        local img_url = j.data.radar.image
		local prefix = "http://image.nmc.cn"
		Api.Api_SendMsg(--调用发消息的接口
		    CurrentQQ,
		    {
                toUser = data.FromGroupId, --回复当前消息的来源群ID
		        sendToType = 2, --2发送给群1发送给好友3私聊
		        sendMsgType = "PicMsg", --进行文本复读回复
		        groupid = 0, --不是私聊自然就为0咯
		        content = "", --回复内容
                picUrl = prefix .. img_url,
                picBase64Buf = "",
                fileMd5 = "",
		        atUser = 0 --是否 填上data.FromUserId就可以复读给他并@了
		    }
		)
	end

    if data.Content == '雷达' then 
        local time = os.time()
		response, error_message =
		    http.request(
		    "GET",
		    "http://www.nmc.cn/rest/relevant/380",
		    {
		        query = "_=" ..
		            time,
		        headers = {
		            ["Accept"] = "*/*",
					["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36"
		        }
		    }
		)
		local html = response.body
        local j = json.decode(html)
        local img_url = j[4].image
		local prefix = "http://image.nmc.cn"
		Api.Api_SendMsg(--调用发消息的接口
		    CurrentQQ,
		    {
                toUser = data.FromGroupId, --回复当前消息的来源群ID
		        sendToType = 2, --2发送给群1发送给好友3私聊
		        sendMsgType = "PicMsg", --进行文本复读回复
		        groupid = 0, --不是私聊自然就为0咯
		        content = "", --回复内容
                picUrl = prefix .. img_url,
                picBase64Buf = "",
                fileMd5 = "",
		        atUser = 0 --是否 填上data.FromUserId就可以复读给他并@了
		    }
		)
    end

    return 1
end

function ReceiveEvents(CurrentQQ, data, extData)
    return 1
end