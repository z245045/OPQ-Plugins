local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")
--本插件运行在linux 有桌面环境 下请安装 scrot截图工具
--[[　
    在 Debian，Ubuntu 或 Linux Mint 上安装Scrot：

　　$ sudo apt-get install scrot

　　在 Fedora 上安装Scrot：

　　$ sudo yum install scrot
]]

function ReceiveFriendMsg(CurrentQQ, data)
    log.notice("From Lua Log ReceiveFriendMsg %s", CurrentQQ)
    return 1
end
function ReceiveGroupMsg(CurrentQQ, data)
if data.FromUserId == 2450459910 then --换为自己的QQ号
    if CurrentQQ ~= "1689236904" then --响应消息的QQ机器人
        return 1
    end
    	if data.Content == '服务器截图' then 
        res, err = readAll("./running.png") 
        if err == nil then --判断框架根目录是否有历史截图有则上传 无则截图
            return 1
        end
        os.execute("scrot ./running.png") --执行 截图操作
        Sleep(1)--等待截图
        res = readAll("./running.png") --读入截图文件 
        base64 = PkgCodec.EncodeBase64(res)
        Api.Api_SendMsg(
            CurrentQQ,
            {
                toUser = data.FromGroupId,
                sendToType = 2,
                sendMsgType = "PicMsg",
                content = "[PICFLAG]✅当前正在运行Running😄\r",
                atUser = 0,
                voiceUrl = "",
                voiceBase64Buf = "",
                picUrl = "",
                picBase64Buf = base64,--发送图片内容
                fileMd5 = ""
            }
        )
	   os.remove("./running.png") --删除截图(伪仿刷屏 懒人代码)
    end
end
    return 1
end
function ReceiveEvents(CurrentQQ, data, extData)
    return 1
end
function readAll(filePath)
    local f, err = io.open(filePath, "rb")

    if err ~= nil then
        return nil, err
    end

    local content = f:read("*all")

    f:close()

    return content, err
end

function Sleep(n)
    log.notice("==========Sleep==========\n%d", n)
    local t0 = os.clock()
    while os.clock() - t0 <= n do
    end
    log.notice("==========over Sleep==========\n%d", n)
end
