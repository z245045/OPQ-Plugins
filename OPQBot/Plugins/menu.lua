local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")

function ReceiveFriendMsg(CurrentQQ, data)
	if data.Content == '菜单' then 
		menu =  "1.看图命令有：\n漫画、插画、随机、首页、周排行、cos、私服、cos周排行、cos月排行、私服排行、少前、来点色图（Loli）。\n"..
						"2.天气查询：天气+城市\n"..
						"3.复读+文字\n"..
						"4.秀头像：闪我、闪+@群员\n"..
						"5.QQ音乐：点歌+歌名\n"..
						"6.搜图+图片\n"..
						"7.语音+文字(文字转语音)\n"
					luaMsg =
					    Api.Api_SendMsg(--调用发消息的接口
					    CurrentQQ,
					    {
					       toUser = data.FromUin, --回复当前消息的来源群ID
					       sendToType = 1, --2发送给群1发送给好友3私聊
					       sendMsgType = "TextMsg", --进行文本复读回复
					       groupid = 0, --不是私聊自然就为0咯
					       content = menu, --回复内容
					       atUser = 0 --是否 填上data.FromUserId就可以复读给他并@了
					    }
					)
		end
    return 1
end
function ReceiveGroupMsg(CurrentQQ, data)

	if data.Content == '菜单' then 
	menu =  "1.看图功能：发送【看图】\n"..
					"2.QQ音乐：点歌+歌名歌手、VIP歌曲-->听歌+歌名歌手\n"..
					"3.搜图+图片\n"..
					"4.搜番+图片\n"..
					"12.百度百科：百科+内容\n"..
					"13.翻译：翻译+外文\n"
					luaMsg =
				    Api.Api_SendMsg(--调用发消息的接口
				    CurrentQQ,
				    {
				       toUser = data.FromGroupId, --回复当前消息的来源群ID
				       sendToType = 2, --2发送给群1发送给好友3私聊
				       sendMsgType = "TextMsg", --进行文本复读回复
				       groupid = 0, --不是私聊自然就为0咯
				       content = menu, --回复内容
				       atUser = 0 --是否 填上data.FromUserId就可以复读给他并@了
				    }
				)
	end
	
	if data.Content == '看图' then 
		luaMsg =
		Api.Api_SendMsg(--调用发消息的接口
		CurrentQQ,
		{
		toUser = data.FromGroupId, --回复当前消息的来源群ID
		sendToType = 2, --2发送给群1发送给好友3私聊
		sendMsgType = "TextMsg", --进行文本复读回复
		groupid = 0, --不是私聊自然就为0咯
		content = "二次元看图请发送：\n【涩图、来点涩图、18涩图（r18）】\n三次元看图请发送：\n【妹子、买家秀、18妹子（r18）、涩图啊（r18）】\nTip：r18涩图请找管理员开通", --回复内容
		atUser = 0 --是否 填上data.FromUserId就可以复读给他并@了
				    }
				)
		end

    return 1
end
function ReceiveEvents(CurrentQQ, data, extData)
    return 1
end
	