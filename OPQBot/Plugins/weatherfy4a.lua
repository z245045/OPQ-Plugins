local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")
local hour = (os.date("%H",os.time())) - 9
local date = os.date("%Y%m%d",os.time())

if hour < 10 then
    hour = "0"..hour..""
end

function ReceiveFriendMsg(CurrentQQ, data)
    return 1
end

function ReceiveGroupMsg(CurrentQQ, data)
    if data.FromUserId == 1689236904 then
        return 1
    end
    
if data.Content == '真彩色' then --发送真彩色获取风云4A最新的真彩色高清图像
        response, error_message =
            http.request(
            "GET",
            "http://www.nmc.cn/rest/category/d3236549863e453aab0ccc4027105bad" --从官方json接口获取图像列表
        )
        local html = response.body
        local str = html:gsub("/medium","") --从返回包体中替换掉medium图片路径，转为原文件
	local image = json.decode(str) --反序列化json
		ApiRet =
            Api.Api_SendMsg( 
            CurrentQQ,
            {
                toUser = data.FromGroupId,
                sendToType = 2,
                sendMsgType = "PicMsg",
                content = "已获取最新的FY-4A图像\n发布于" ..image.dataList[1].updateDate.. "", --获取最后发布时间
                atUser = 0,
                voiceUrl = "",
                voiceBase64Buf = "",
                picUrl = "http://image.nmc.cn/" ..image.dataList[1].imgPath.. "", --从中央气象台的image站获取最后的图像
                picBase64Buf = "",
		fileMd5 = ""
            }
        )
	html = nil
        str = nil
	image = nil
end

    if data.FromUserId == 845324058 then
        return 1
    end
    if data.Content == '超清风云' then 
        local img_url_hd = "http://img.nsmc.org.cn/PORTAL/FY4/IMG/FY4A/AGRI/IMG/DISK/MTCC/NOM/FY4A-_AGRI--_N_DISK_1047E_L1C_MTCC_MULT_NOM_"..date..""..hour.."0000_"..date..""..hour.."1459_1000M_V0001.JPG"
        ApiRet =
            Api.Api_SendMsg(--调用发消息的接口
                CurrentQQ,
                {
                    toUser = data.FromGroupId, --回复当前消息的来源群ID
                    sendToType = 2, --2发送给群1发送给好友3私聊
                    sendMsgType = "PicMsg", --进行文本复读回复
                    groupid = 0, --不是私聊自然就为0咯
                    content = "已获取"..date..""..hour.."时(UTC)的超清风云四号A星圆盘图（图片大概15M，谨慎查看原图）", --回复内容
                    picUrl = img_url_hd,
                    picBase64Buf = "",
                    fileMd5 = "",
                    atUser = 0 --是否 填上data.FromUserId就可以复读给他并@了
                }
            )
end
    if data.Content == '高清风云' then 
    local img_url = "http://img.nsmc.org.cn/CLOUDIMAGE/FY4A/MTCC/FY4A_DISK.JPG"
    ApiRet =
        Api.Api_SendMsg(--调用发消息的接口
            CurrentQQ,
            {
                toUser = data.FromGroupId, --回复当前消息的来源群ID
                sendToType = 2, --2发送给群1发送给好友3私聊
                sendMsgType = "PicMsg", --进行文本复读回复
                groupid = 0, --不是私聊自然就为0咯
                content = "已获取"..date..""..hour.."时(UTC)的高清风云四号A星圆盘图", --回复内容
                picUrl = img_url,
                picBase64Buf = "",
                fileMd5 = "",
                atUser = 0 --是否 填上data.FromUserId就可以复读给他并@了
            }
        )
        html = nil
        str = nil
	    image = nil
end

    return 1
end
