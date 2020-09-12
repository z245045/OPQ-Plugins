local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")

function ReceiveFriendMsg(CurrentQQ, data) 
    return 1 
end

function ReceiveGroupMsg(CurrentQQ, data)
	if (string.find(data.Content, "百科")) then
	    baike(CurrentQQ,data)
	end
	return 1
end

function baike(CurrentQQ,data)
    keyWord = data.Content:gsub("百科", "")
        if keyWord == "" then
            return 1
        end
        response, error_message =
            http.request(
            "GET",
            "http://baike.baidu.com/api/openapi/BaikeLemmaCardApi",
            {
                query = "scope=103&format=json&appid=379020&bk_key=" .. url_encode(keyWord) .. "&bk_length=600"
            }
        )
        html = response.body
        while(string.find(html, '"errno":2')) do
            response, error_message =
            http.request(
            "GET",
            "http://baike.baidu.com/api/openapi/BaikeLemmaCardApi",
            {
                query = "scope=103&format=json&appid=379020&bk_key=" .. url_encode(keyWord) .. "&bk_length=600"
            })
			html = response.body
        end
        local j = json.decode(html)
        sedmsg(CurrentQQ,data,j.abstract.."\n"..j.url)
end

function sedmsg(CurrentQQ,data,msg)
    ApiRet = Api.Api_SendMsg(
        CurrentQQ,
        {
        toUser = data.FromGroupId,
        sendToType = 2,
        sendMsgType = "TextMsg",
        groupid = 0,
        content = msg,
        picBase64Buf = "",
        --发本地送图片的buf 转 bas64 编码 文本型
        fileMd5 = "",
		picUrl = "",
        atUser = 0
        }
    )
	return ApiRet
end

function ReceiveEvents(CurrentQQ, data, extData)
    return 1
end