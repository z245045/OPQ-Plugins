local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")
local mysql = require("mysql")

--版本号(不要改动)
Vabr = "1.0.2"
--数据库配置
mysqlhost = "localhost"--默认不动
mysqldb = "ffaxx001"--数据库名
mysqluser = "ffaxx001"--数据库用户名
mysqlpass = "123456"--数据库密码
--不使用请不要改动

function ReceiveFriendMsg(CurrentQQ, data)
    if (data.Content == "使用方法") then
	    sendfrimsg(CurrentQQ,data,"添加授权者的方法\n对单个机器人私聊发送[添加授权者+授权者QQ]\n\n授权群的方法\n到需要授权的群里发送[授权+主人QQ]。注意:授权必须是授权者进行操作,管理员授权不了")
	end
    --数据初始化
    if (data.Content == "初始化") then
	    root = Read("mimoio\/"..data.FromUin..".txt")
	    if (root ~= nil) then
		    sendfrimsg(CurrentQQ,data,"∴请不要重复初始化")
			return 1
		end
    --os.execute('mkdir mimoio/机器授权')
	    os.execute('mkdir mimoio')
		os.execute('mkdir mimoio/复读机')
		os.execute('mkdir mimoio/复读机/次数')
		os.execute('mkdir mimoio/复读机/内容')
		os.execute('mkdir mimoio/机器授权')
		os.execute('mkdir mimoio/机器配置')
		os.execute('mkdir mimoio/机器配置/机器主人')
		os.execute('mkdir mimoio/机器配置/机器聊天')
		os.execute('mkdir mimoio/机器调教')
		os.execute('mkdir mimoio/状态数据')
		os.execute('mkdir mimoio/状态数据/抢红包')
		os.execute('mkdir mimoio/状态数据/机器聊天')
		os.execute('mkdir mimoio/状态数据/机器开关')
		os.execute('mkdir mimoio/状态数据/撤回检测')
		os.execute('mkdir mimoio/状态数据/图片解析')
		os.execute('mkdir mimoio/状态数据/视频解析')
		os.execute('mkdir mimoio/状态数据/闪照检测')
		Wirte("mimoio\/"..data.FromUin..".txt","999")
		sendfrimsg(CurrentQQ,data,"初始化完毕！\n发送[使用方法]了解使用吧")
	end
	--添加授权者操作(私聊机器人发送)
	if (string.find(data.Content, "^添加授权者")) then
	    msg = data.Content:gsub("添加授权者", "")
		--Wirte("mimoio\/状态数据\/抢红包\/"..data.FromUin..".txt","关闭")
		root = Read("mimoio\/"..data.FromUin..".txt")
	    if (root == nil) then
		    sendfrimsg(CurrentQQ,data,"∴你不是我的管理者")
			return 1
		end
		Wirte("mimoio\/机器授权\/"..msg..CurrentQQ..".txt","999")
		sendfrimsg(CurrentQQ,data,"∴添加授权者成功")
	end
	--删除授权者操作(私聊机器人发送)
	if (string.find(data.Content, "^删除授权者")) then
	    msg = data.Content:gsub("删除授权者", "")
		--Wirte("mimoio\/状态数据\/抢红包\/"..data.FromUin..".txt","关闭")
		root = Read("mimoio\/"..data.FromUin..".txt")
	    if (root == nil) then
		    sendfrimsg(CurrentQQ,data,"∴你不是我的管理者")
			return 1
		end
		os.remove("mimoio\/机器授权\/"..msg..CurrentQQ..".txt")
		sendfrimsg(CurrentQQ,data,"∴删除授权者成功")
	end
    return 1
end
function ReceiveGroupMsg(CurrentQQ, data)
    if (tostring(data.FromUserId) == CurrentQQ) then
	    return 1
	end
	--群聊授权(到需要授权的群里操作)
	if (string.find(data.Content, "^授权")) then
	    root = Read("mimoio\/机器授权\/"..data.FromUserId..CurrentQQ..".txt","999")
		if (root == nil) then
		    sedmsg(CurrentQQ,data,"∴你不是我的授权者")
			return 1
		end
		msg = data.Content:gsub("授权", "")
		os.execute('mkdir mimoio/机器调教/'..data.FromGroupId)
		os.execute('mkdir mimoio/机器配置/机器主人/'..data.FromGroupId)
		Wirte("mimoio\/机器配置\/机器主人\/"..data.FromGroupId.."\/"..msg..".txt","999")
		Wirte("mimoio\/状态数据\/抢红包\/"..data.FromGroupId..".txt","关闭")
		Wirte("mimoio\/状态数据\/机器聊天\/"..data.FromGroupId..".txt","关闭")
		Wirte("mimoio\/状态数据\/撤回检测\/"..data.FromGroupId..".txt","关闭")
		Wirte("mimoio\/状态数据\/视频解析\/"..data.FromGroupId..".txt","关闭")
		Wirte("mimoio\/状态数据\/闪照检测\/"..data.FromGroupId..".txt","关闭")
		Wirte("mimoio\/状态数据\/图片解析\/"..data.FromGroupId..".txt","关闭")
		Wirte("mimoio\/机器配置\/机器聊天\/"..data.FromGroupId..".txt","回复聊天")
		sedmsg(CurrentQQ,data,"∴授权成功！\n发送[开启机器人]使用吧")
	end
	--删除授权操作(到需要删除授权的群里操作)
	if (string.find(data.Content, "^删除授权")) then
	    root = Read("mimoio\/机器授权\/"..data.FromUserId..CurrentQQ..".txt","999")
		if (root == nil) then
		    sedmsg(CurrentQQ,data,"∴你不是我的授权者")
			return 1
		end
		msg = data.Content:gsub("删除授权", "")
		os.remove("mimoio\/机器配置\/机器主人\/"..data.FromGroupId.."\/"..msg..".txt")
		os.remove("mimoio\/状态数据\/机器开关\/"..data.FromGroupId..CurrentQQ..".txt")
		sedmsg(CurrentQQ,data,"∴删除授权成功！")
	end
	--机器开关指令
	if (data.Content == "开启机器人" or data.Content == "关闭机器人") then
        mim = Read("mimoio\/机器配置\/机器主人\/"..data.FromGroupId.."\/"..data.FromUserId..".txt")
        if (mim ~= nil) then
            msg = data.Content:gsub("机器人", "")
            str = Read("mimoio\/状态数据\/机器开关\/"..data.FromGroupId..CurrentQQ..".txt")
			if (str == nil) then
			    Wirte("mimoio\/状态数据\/机器开关\/"..data.FromGroupId..CurrentQQ..".txt",msg)
                sedmsg(CurrentQQ,data,"∴机器人"..msg.."成功！")
				log.info("Str ====> %s", str)
                return 1
			end
			
            if (string.find(str, msg)) then
                sedmsg(CurrentQQ,data,"∴机器人一直是"..msg.."的呐")
                return 1
            end
            Wirte("mimoio\/状态数据\/机器开关\/"..data.FromGroupId..CurrentQQ..".txt",msg)
            sedmsg(CurrentQQ,data,"∴机器人"..msg.."成功！")
            return 1
        else
            sedmsg(CurrentQQ,data,"∴你不是我主人呐")
            return 1
        end
	end
    --机器人开启检测
    str = Read("mimoio\/状态数据\/机器开关\/"..data.FromGroupId..CurrentQQ..".txt")
	if (str == nil) then
	    log.info("Str ====> %s", str)
        return 1
	end
	if (string.find(str, "关闭")) then
	    return 1
	end
	--at消息处理
	msgs = ""
	atqq = 0
	if (string.find(data.Content, "AT消息")) then
	    msgs = json.decode(data.Content).Content
		atqq = json.decode(data.Content).UserID
	end
	--尾巴自定义(待完善)
	tips = "——凤飞翱翔兮丷"
    --功能模块
    if (data.Content == "功能" or data.Content == "主界面") then
        face = faceArray()
        sedimgmsg(CurrentQQ,data,"http://q1.qlogo.cn/g?b=qq&nk="..data.FromUserId.."&s=640",face.."影视搜索\n"..face.."聊天娱乐\n"..face.."便利功能\n"..face.."机器调教\n"..face.."管理系统\n"..face.."bug反馈\n"..face.."本群状态\n"..face.."更新检测\n\n"..tips)
    end
    --影视搜索模块
    if (data.Content == "影视搜索") then
        face = faceArray()
		sedimgmsg(CurrentQQ,data,"http://q1.qlogo.cn/g?b=qq&nk="..data.FromUserId.."&s=640",face.."搜索+影视名\n"..face.."我想看+影视名\n"..face.."我要看+影视名\n\n"..tips)
    elseif (string.find(data.Content, "^搜索")) then
	    msg = data.Content:gsub("搜索", "")
		Sousuo(CurrentQQ,data,msg)
	elseif (string.find(data.Content, "^我想看")) then
	    msg = data.Content:gsub("我想看", "")
		Sousuo(CurrentQQ,data,msg)
    elseif (string.find(data.Content, "^我要看")) then
	    msg = data.Content:gsub("我要看", "")
		Sousuo(CurrentQQ,data,msg)
	end
	--聊天娱乐模块
	if (data.Content == "聊天娱乐") then
        face = faceArray()
		sedimgmsg(CurrentQQ,data,"http://q1.qlogo.cn/g?b=qq&nk="..data.FromUserId.."&s=640",face.."切换文字聊天\n"..face.."切换回复聊天\n"..face.."切换语音聊天\n\n"..tips)
    elseif (data.Content == "切换文字聊天") then
		liaotian(CurrentQQ,data,1)
	elseif (data.Content == "切换语音聊天") then
	    liaotian(CurrentQQ,data,2)
    elseif (data.Content == "切换回复聊天") then
	    liaotian(CurrentQQ,data,3)
	else
	    ownthink(CurrentQQ,data,msgs,atqq)
	end
	--便利功能模块
	if (data.Content == "便利功能") then
        face = faceArray()
		sedimgmsg(CurrentQQ,data,"http://q1.qlogo.cn/g?b=qq&nk="..data.FromUserId.."&s=640",face.."百科大全\n"..face.."音乐点歌\n"..face.."闪他@xx\n"..face.."天气查询\n\n"..tips)
	elseif (data.Content == "百科大全") then
		sedmsg(CurrentQQ,data,"发送:[百科+关键词]\n例如:百科洛妾身")
    elseif (data.Content == "音乐点歌") then
		sedmsg(CurrentQQ,data,"发送:[点歌+歌名]\n例如:点歌青柠")
	elseif (data.Content == "天气查询") then
		sedmsg(CurrentQQ,data,"发送:[天气+地方名]\n例如:天气北京(限于国内)")
    elseif (string.find(data.Content, "^天气")) then
        tianqi(CurrentQQ,data)
	    --msg = data.Content:gsub("搜索", "")
		--Sousuo(CurrentQQ,data,msg)
--	elseif (string.find(data.Content, "^百科")) then
--	    baike(CurrentQQ,data)
	    --msg = data.Content:gsub("我想看", "")
		--Sousuo(CurrentQQ,data,msg)music(CurrentQQ,data)
    elseif (string.find(data.Content, "^点歌")) then
	    music(CurrentQQ,data)
	end
	--机器调教模块
	if (data.Content == "机器调教") then
        face = faceArray()
		sedimgmsg(CurrentQQ,data,"http://q1.qlogo.cn/g?b=qq&nk="..data.FromUserId.."&s=640",face.."文字调教\n"..face.."语音调教\n"..face.."唱歌调教\n"..face.."音乐调教\n"..face.."图片调教\n"..face.."删除调教\n\n"..tips)
    elseif (data.Content == "文字调教") then
		sedmsg(CurrentQQ,data,"发送[调教(指令)#(内容)]\n例如:调教你好#你好啊")
	elseif (data.Content == "语音调教") then
		sedmsg(CurrentQQ,data,"发送[调教(指令)#语音(内容)]\n例如:调教你好#语音你好啊")
	elseif (data.Content == "图片调教") then
		sedmsg(CurrentQQ,data,"发送[调教(指令)#图片(链接)]\n例如:调教你好#图片http://../1.jpg")
	elseif (data.Content == "音乐调教") then
		sedmsg(CurrentQQ,data,"发送[调教(指令)#点歌(歌名)]\n例如:调教喵#点歌学猫叫")
	elseif (data.Content == "唱歌调教") then
		sedmsg(CurrentQQ,data,"发送[调教(指令)#唱歌(歌名)]\n例如:调教喵#唱歌学猫叫")
	elseif (data.Content == "删除调教") then
		sedmsg(CurrentQQ,data,"发送[删除调教(指令)]\n例如:删除调教你好")
	elseif (string.find(data.Content, "^调教")) then
        tiaojiao(CurrentQQ,data)
	elseif (string.find(data.Content, "^删除调教")) then
        tiaojiao(CurrentQQ,data)
	end
	--管理系统模块
	if (data.Content == "管理系统") then
        face = faceArray()
		sedimgmsg(CurrentQQ,data,"http://q1.qlogo.cn/g?b=qq&nk="..data.FromUserId.."&s=640",face.."开启/关闭机器人\n"..face.."开启/关闭抢红包\n"..face.."开启/关闭机器聊天\n"..face.."开启/关闭闪照检测\n"..face.."开启/关闭图片解析\n"..face.."开启/关闭视频解析\n"..face.."开启/关闭撤回检测\n\n"..tips)
    elseif (data.Content == "开启机器聊天" or data.Content == "关闭机器聊天") then
        adminio(CurrentQQ,data,"机器聊天")
    elseif (data.Content == "开启撤回检测" or data.Content == "关闭撤回检测") then
        adminio(CurrentQQ,data,"撤回检测")
	elseif (data.Content == "开启闪照检测" or data.Content == "关闭闪照检测") then
        adminio(CurrentQQ,data,"闪照检测")
	elseif (data.Content == "开启抢红包" or data.Content == "关闭抢红包") then
        adminio(CurrentQQ,data,"抢红包")
	elseif (data.Content == "开启视频解析" or data.Content == "关闭视频解析") then
        adminio(CurrentQQ,data,"视频解析")
	elseif (data.Content == "开启图片解析" or data.Content == "关闭图片解析") then
        adminio(CurrentQQ,data,"图片解析")
	end
	--bug反馈模块
	if (data.Content == "BUG反馈" or data.Content == "bug反馈") then
        face = faceArray()
		sedimgmsg(CurrentQQ,data,"http://q1.qlogo.cn/g?b=qq&nk="..data.FromUserId.."&s=640",face.."邮件反馈\n"..face.."QQ反馈\n\n"..tips)
    elseif (data.Content == "QQ反馈") then
        sedmsg(CurrentQQ,data,"???Σ(ﾟ∀ﾟﾉ)ﾉ\n插件有问题可以反馈到:\nQQ:2353065854")
    elseif (data.Content == "邮件反馈") then
        sedmsg(CurrentQQ,data,"宝贝咋啦=͟͟͞͞(꒪ᗜ꒪ ‧̣̥̇)\n插件有问题可以反馈到:\n邮箱📬:ym-o@qq.com")
	end
	--本群状态模板
	if (data.Content == "本群状态") then
        face = faceArray()
        hb = Read("mimoio\/状态数据\/抢红包\/"..data.FromGroupId..".txt")
        sz = Read("mimoio\/状态数据\/闪照检测\/"..data.FromGroupId..".txt")
		tp = Read("mimoio\/状态数据\/图片解析\/"..data.FromGroupId..".txt")
        sp = Read("mimoio\/状态数据\/视频解析\/"..data.FromGroupId..".txt")
        jqr = Read("mimoio\/状态数据\/机器开关\/"..data.FromGroupId..CurrentQQ..".txt")
        lt = Read("mimoio\/状态数据\/机器聊天\/"..data.FromGroupId..".txt")
        ch = Read("mimoio\/状态数据\/撤回检测\/"..data.FromGroupId..".txt")
		sedmsg(CurrentQQ,data,"状态数据列表↓↓↓\n"..face.."机器人:"..jqr.."\n"..face.."抢红包:"..hb.."\n"..face.."图片解析:"..tp.."\n"..face.."撤回检测:"..ch.."\n"..face.."视频解析:"..sp.."\n"..face.."机器聊天:"..lt.."\n"..face.."闪照检测:"..sz.."\n\n"..tips)
	end
	--更新模块
	if (data.Content == "更新检测") then
        str = geturl("GET","http://118.25.41.32/Lsb/lua/Vabr.txt","")
		log.info("Str ====> %s", str)
        if (string.find(str, Vabr)) then
            sedmsg(CurrentQQ,data,"当前版本为最新版")
        else
            sedmsg(CurrentQQ,data,"发现新版本!\n当前版本:"..Vabr.."\n新版本号:"..str.."\n赶快发送[更新插件]吧")
        end
	elseif (data.Content == "更新插件") then
	    mim = Read("mimoio\/机器配置\/机器主人\/"..data.FromGroupId.."\/"..data.FromUserId..".txt")
        if (mim == nil) then
            sedmsg(CurrentQQ,data,"∴你不是我主人呐")
            return 1
        end
        str = geturl("GET","http://118.25.41.32/Lsb/lua/Vabr.txt","")
		log.info("Str ====> %s", str)
        if (string.find(str, Vabr)) then
            sedmsg(CurrentQQ,data,"当前版本为最新版")
        else
            str = geturl("GET","http://118.25.41.32/Lsb/lua/mimoio.txt","")
            Wirte("Plugins\/mimoio.lua",str)
            sedmsg(CurrentQQ,data,"更新完毕！")
        end
	end
	--图片类型消息处理
    if (data.MsgType == "PicMsg") then
	    msg = Read("mimoio\/状态数据\/图片解析\/"..data.FromGroupId..".txt")
		jData = json.decode(data.Content)
	    if (msg ~= nil and jData.tips ~= "[群消息-QQ闪照]") then
            if (string.find(str, "开启")) then
	            sedmsg(CurrentQQ,data,"图片链接解析如下↓↓\n"..jData.url)
				return 1
	        end
	    end
	    --开关判断模块
	    str = Read("mimoio\/状态数据\/闪照检测\/"..data.FromGroupId..".txt")
	    if (str == nil) then
            return 1
	    end
	    if (string.find(str, "关闭")) then
	        return 1
	    end
	    --闪照、图片处理模块
		PicFlag(CurrentQQ, data)
    end
	--抢红包处理
	if (string.find(data.MsgType, "RedBagMsg") == 1) then
	    --开关判断模块
	    str = Read("mimoio\/状态数据\/抢红包\/"..data.FromGroupId..".txt")
		if (str == nil) then
	        log.info("Str ====> %s", str)
            return 1
	    end
	    if (string.find(str, "关闭")) then
	        return 1
	    end
	    RedBag(CurrentQQ, data)
	end
	--视频解析处理
	if (string.find(data.MsgType, "VideoMsg") == 1) then
	    --开关判断模块
	    str = Read("mimoio\/状态数据\/视频解析\/"..data.FromGroupId..".txt")
		if (str == nil) then
	        log.info("Str ====> %s", str)
            return 1
	    end
	    if (string.find(str, "关闭")) then
	        return 1
	    end
	    Video(CurrentQQ, data)
	end
	--at闪图
--	if (data.MsgType == "AtMsg") and (string.find(data.Content, "闪他")) then
--	    shantu(CurrentQQ, data)
--    end
	--调教搜索引擎
	mim = Read("mimoio\/机器调教\/"..data.FromGroupId.."\/"..data.Content..".txt")
	if (mim == nil) then
	    --人类的本质是复读机
	    msg = Read("mimoio\/复读机\/内容\/"..data.FromGroupId..".txt")
		if (msg ~= nil) then
		    cs = Read("mimoio\/复读机\/次数\/"..data.FromGroupId..".txt")
			ii = tonumber(cs)
			if (string.find(msg, "^"..data.Content.."$")) then
			    if (ii > 2) then
			         math.randomseed(os.time())
                     sj = math.random(1, 5)
		             if (sj == 1 or sj == 2) then
			             sedmsg(CurrentQQ,data,msg)
					     rr = ii + 1
		                 Wirte("mimoio\/复读机\/次数\/"..data.FromGroupId..".txt",tostring(rr))
				     elseif (sj == 3) then
				         os.remove("mimoio\/复读机\/次数\/"..data.FromGroupId..".txt")
					     os.remove("mimoio\/复读机\/内容\/"..data.FromGroupId..".txt")
					     fdArray = {"突然截断复读(ﾟ⊿ﾟ)ﾂ","复读可耻(•̀へ •́ ╮ )","不要复读了啦","这就是所谓的人类的本质","你们咋不上天呐","又复读上瘾了啊"}
                         math.randomseed(os.time())
                         fdsj = math.random(1, 6)
				         sedmsg(CurrentQQ,data,fdArray[fdsj])
				     else
			             rr = ii + 1
		                 Wirte("mimoio\/复读机\/次数\/"..data.FromGroupId..".txt",tostring(rr))
		             end
			    else
			        rr = ii + 1
		            Wirte("mimoio\/复读机\/次数\/"..data.FromGroupId..".txt",tostring(rr))
			    end
			else
			    if (ii > 2) then
			        math.randomseed(os.time())
                    sj2 = math.random(1, 3)
					if (sj2 == 2) then
					    fdArray2 = {"中断复读可耻","打断复读可耻(•̀へ •́ ╮ )","你为什么要打断复读啊","复读不香嘛","破坏氛围(งᵒ̌皿ᵒ̌)ง⁼³₌₃"}
                        math.randomseed(os.time())
                        fdsj2 = math.random(1, 5)
				        sedmsg(CurrentQQ,data,fdArray2[fdsj2])
					end
				end
				Wirte("mimoio\/复读机\/次数\/"..data.FromGroupId..".txt","1")
			    Wirte("mimoio\/复读机\/内容\/"..data.FromGroupId..".txt",data.Content)
			end
		else
		    Wirte("mimoio\/复读机\/次数\/"..data.FromGroupId..".txt","1")
			Wirte("mimoio\/复读机\/内容\/"..data.FromGroupId..".txt",data.Content)
		end
	    --如果调教指令不存在，则进行其他操作
	    msgsql(CurrentQQ,data)--数据储蓄
		--随机回复消息概率0.04
	    math.randomseed(os.time())
        num = math.random(1, 40)
		if (num == 12) then
		    j = xiaosiapi(CurrentQQ,data,data.Content)
			sedmsg(CurrentQQ,data,j.data.info.text)
		end
	else
	    --触发调教指令
		funic(CurrentQQ,data,mim)
	end
    return 1
end

function ReceiveEvents(CurrentQQ, data, extData)
  if data.MsgType == "ON_EVENT_GROUP_REVOKE" then --监听 群撤回事件
    --撤回事件处理
    str = Read("mimoio\/状态数据\/撤回检测\/"..extData.GroupID..".txt")
    if (str == nil) then
	    log.info("Str ====> %s", str)
        return 1
	end
	if (string.find(str, "关闭")) then
		return 1
	end
	CheHui(CurrentQQ, data, extData)
	--xxxxxxxxxxxxxxx
    return 1
  end
end
  --进群秀图欢迎


--闪照检测处理


--功能组
function funic(CurrentQQ,data,msg)
    if string.find(msg, "^点歌") then
	    data.Content = msg
        music(CurrentQQ,data,msg)
		return 1
	elseif string.find(msg, "^语音") then
	    keyWord = msg:gsub("语音", "")
        sedvoicemsg(CurrentQQ,data,keyWord)
		return 1
	elseif string.find(msg, "^图片") then
	    keyWord = msg:gsub("图片", "")
        sedimgmsg(CurrentQQ,data,keyWord,"")
		return 1
    elseif string.find(msg, "^唱歌") then
        keyWord = msg:gsub("唱歌", "")
		if (keyWord == "") then
		    sedmsg(CurrentQQ,data,"歌名不能空着哦")
		    return 1
		end
		sedmsg(CurrentQQ,data,"妾身正在努力加载٩(˃̶͈̀௰˂̶͈́)و")
        response, error_message =
            http.request(
            "POST",
            "http://127.0.0.1:8888/SilkApi/UrlToBuf",--修改此处ip及端口即可
            {
                body = keyWord --传入歌曲名
            }
        )
        log.notice("err   %v", error_message)
        html = response.body --返回silk base64 buf
		if (string.find(html, "δ")) then
				    sedmsg(CurrentQQ,data,"天依没有找到相关的歌呀(ÒωÓױ)！")
					c.close(c)
				    return 2
				end
        luaRes =
            Api.Api_SendMsg(
            CurrentQQ,
            {
                toUser = data.FromGroupId,
                sendToType = 2,
                sendMsgType = "VoiceMsg",
                groupid = 0,
                content = "",
                atUser = 0,
                voiceUrl = "",
                voiceBase64Buf = html 
            }
        )
		return 1
	end
    sedmsg(CurrentQQ,data,msg)
end

--影视搜索用
function Sousuo(CurrentQQ,data,msg)
    response, error_message =
        http.request(
            "GET",
            "http://localhost/index.php/ajax/suggest",
            {
                query = "mid=1&f=admin&wd="..msg.."&limit=10&timestamp=1567914326746"
            }
        )
    html = response.body
	json = json.decode(html)
	if (json.total == 0) then
	    sedmsg(CurrentQQ,data,"影视查询错误\n请检查影视名是否正确\n═══════════\n注意⚠️影视名不要带无关或多余的字符")
	else
        sedmsg(CurrentQQ,data,"资源地址如下↓↓↓\n══════════\nhttp://118.25.41.32/index.php/vod/search/wd/"..escape(msg)..".html\n═══════════\n注意:如果QQ出现停止访问现象，请复制链接用浏览器打开")
	end
end

--单纯发消息图文通用
function sedimgmsg(CurrentQQ,data,url,msg)
    ApiRet = Api.Api_SendMsg(
        CurrentQQ,
        {
        toUser = data.FromGroupId,
        sendToType = 2,
        sendMsgType = "PicMsg",
        groupid = 0,
        content = msg,
        picBase64Buf = "",
        --发本地送图片的buf 转 bas64 编码 文本型
        fileMd5 = "",
		picUrl = url,
        atUser = 0
        }
    )
	return ApiRet
end

--单纯发消息用
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

--单纯发私聊消息用
function sendfrimsg(CurrentQQ,data,msg)
    ApiRet = Api.Api_SendMsg(
        CurrentQQ,
        {
        toUser = data.FromUin,
        sendToType = 1,
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

--单纯发json消息用
function sedjsonmsg(CurrentQQ,data,msg)
    ApiRet = Api.Api_SendMsg(
        CurrentQQ,
        {
        toUser = data.FromGroupId,
        sendToType = 2,
        sendMsgType = "JsonMsg",
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

--聊天模块切换函数
function liaotian(CurrentQQ,data,msg)
    mim = Read("mimoio\/机器配置\/机器主人\/"..data.FromGroupId.."\/"..data.FromUserId..".txt")
    if (mim == nil) then
        sedmsg(CurrentQQ,data,"∴你不是我主人呐")
        return 1
    end
    str = Read("mimoio\/状态数据\/机器聊天\/"..data.FromGroupId..".txt")
	if (str == nil) then
        return 1
    end
	if (string.find(str, "关闭")) then
	    sedmsg(CurrentQQ,data,"机器聊天处于关闭状态\n∴请先开启机器聊天")
	    return 1
	end
	--切换处理
	file = io.open("mimoio\/机器配置\/机器聊天\/"..data.FromGroupId..".txt", "w")
	if (msg == 1) then
	    file:write("文字聊天")
	    sedmsg(CurrentQQ,data,"∴成功切换到文字聊天")
	elseif (msg == 2) then
	    file:write("语音聊天")
	    sedmsg(CurrentQQ,data,"∴成功切换到语音聊天")
	elseif (msg == 3) then
	    file:write("回复聊天")
	    sedmsg(CurrentQQ,data,"∴成功切换到回复聊天")
	end
	file:close()
end

--随机表情函数
function faceArray()
    faceArray = {"[表情147]","🍀","🔥","🍻","💎","[表情185]","[表情219]","[表情176]"}
    math.randomseed(os.time())
    num = math.random(1, 9)
    return faceArray[num]
end

--url编码转换
function escape(w)
	pattern="[^%w%d%._%-%* ]"
	s=string.gsub(w,pattern,function(c)
		local c=string.format("%%%02X",string.byte(c))
		return c
	end)
	s=string.gsub(s," ","+")
	return s
end

--读取数据函数
function Read(url)
    file = io.open(url, "r")
	if (file == nil) then
	    return nil
	else
        file:seek("set")
	    str = file:read("*a")
	    file:close()
        return str
	end
end

--写入数据函数
function Wirte(url,msg)
    file = io.open(url, "w+")
    file:write(msg)
	file:close()
    return "ok"
end

--小思聊天函数
function xiaosiapi(CurrentQQ,data,str)
    response, error_message =
            http.request(
            "GET",
            "https://api.ownthink.com/bot",
            {
                query = "appid="..tostring(data.FromUserId).."&spoken=" .. url_encode(str),
                headers = {
                    Accept = "*/*"
                }
            }
        )
        html = response.body
		jData = json.decode(html)
		return jData
end

--机器聊天函数
function ownthink(CurrentQQ,data,msgs,atqq)
    if (tostring(atqq) == CurrentQQ) then
        m = Read("mimoio\/状态数据\/机器聊天\/"..data.FromGroupId..".txt")
        if (m == nil) then
	        log.info("Str ====> %s", m)
            return 1
	    end
	    if (string.find(m, "关闭")) then
	        sedmsg(CurrentQQ,data,"机器聊天处于关闭状态\n∴请先开启机器聊天")
	        return 1
	    end
		res2 = string.find(msgs, " ")
		str = string.sub(msgs,res2)
		jData = xiaosiapi(CurrentQQ,data,str)
		Data = json.decode(data.Content)
		m = Read("mimoio\/机器配置\/机器聊天\/"..data.FromGroupId..".txt")
		if (m == nil) then
	        log.info("Str ====> %s", m)
            return 1
	    end
		if (string.find(m, "回复聊天")) then
		    Api.Api_SendMsg(
                CurrentQQ,
                {
                toUser = data.FromGroupId,
                sendToType = 2,
                sendMsgType = "ReplayMsg",
                groupid = 0,
                content = jData.data.info.text,
                atUser = 0,
				replayInfo = {
                    MsgSeq = data.MsgSeq,
                    --回复消息的Seq
                    MsgTime = data.MsgTime,
                    --回复消息的事件
                    UserID = data.FromUserId,
                    --回复消息对象
                    RawContent = Data.Content --回复消息的原内容
                }
				}
            )
			return 1
		elseif (string.find(m, "文字聊天")) then
		    sedmsg(CurrentQQ,data,jData.data.info.text)
		else
		    sedvoicemsg(CurrentQQ,data,url_encode(jData.data.info.text))
		end
    end
end

--发送语音消息
function sedvoicemsg(CurrentQQ,data,str)
    ApiRet = Api.Api_SendMsg(
        CurrentQQ,
        {
        toUser = data.FromGroupId,
        sendToType = 2,
        sendMsgType = "VoiceMsg",
        groupid = 0,
		voiceUrl = "https://dds.dui.ai/runtime/v1/synthesize?voiceId=qianranfa&speed=0.7&volume=100&audioType=wav&text="..str, --发送语音的网络地址 文本型
        voiceBase64Buf = "",
        content = "",
        atUser = 0
        }
    )
	return ApiRet
end


--调教处理函数(待处理)
function tiaojiao(CurrentQQ,data)
    mim = Read("mimoio\/机器配置\/机器主人\/"..data.FromGroupId.."\/"..data.FromUserId..".txt")
	if (mim == nil) then
		sedmsg(CurrentQQ,data,"∴你不是我主人哇")
		return 1
	end
	if (string.find(data.Content, "^删除调教")) then
	    msg = data.Content:gsub("删除调教", "")
	    if (msg == "") then
		    sedmsg(CurrentQQ,data,"要删除的调教指令不能为空哦")
		    return 1
		end
		rese = Read("mimoio\/机器调教\/"..tostring(data.FromGroupId).."\/"..msg..".txt")
	    if (rese == nil) then
			sedmsg(CurrentQQ,data,"这个指令不存在了哦")
		    return 1
		end
		rm_file = os.remove("mimoio\/机器调教\/"..tostring(data.FromGroupId).."\/"..msg..".txt")
		log.info("删除调教 ====> %s", rm_file)
		sedmsg(CurrentQQ,data,"删除成功\n你不喜欢被这样调教的我吗[表情9]")
		return 1
	end
    msgs = data.Content:gsub("调教", "")
		res2 = string.find(msgs, "#")
		str = string.sub(msgs,res2+1)
		str2 = string.sub(msgs,1,res2-1)
		        
		        if (str == "") then
		            sedmsg(CurrentQQ,data,"调教的回答内容不能为空哦")
			        return 1
		        end
				if (str2 == "") then
		            sedmsg(CurrentQQ,data,"调教的指令内容不能为空哦")
			        return 1
		        end
		        rese = Read("mimoio\/机器调教\/"..data.FromGroupId.."\/"..str2..".txt")
					if (rese ~= nil) then
				        sedmsg(CurrentQQ,data,"指令已经存在了哦")
				        return 1
				    end
				Wirte("mimoio\/机器调教\/"..data.FromGroupId.."\/"..str2..".txt",str)
				sedmsg(CurrentQQ,data,"调教成功\n你还想再调教我一次吗[表情6]")
		        return 1
end

function url_encode(str)
    if (str) then
        str = string.gsub(str, "\n", "\r\n")
        str =
            string.gsub(
            str,
            "([^%w ])",
            function(c)
                return string.format("%%%02X", string.byte(c))
            end
        )
        str = string.gsub(str, " ", "+")
    end
    return str
end

--抢红包处理
function RedBag(CurrentQQ, data)
    Api.Api_OpenRedBag(CurrentQQ, data.RedBaginfo)
    if (data.RedBaginfo.RedType == 12) then
         luaRes =
                Api.Api_SendMsg(
                CurrentQQ,
                {
                    toUser = data.FromGroupId,
                    sendToType = 2,
                    sendMsgType = "TextMsg",
                    groupid = 0,
                    content = data.RedBaginfo.Tittle,
                    atUser = 0
                }
            )
        log.notice("From Lua SendMsg Ret\n%d", luaRes.Ret)
    end
end

--视频解析处理
function Video(CurrentQQ, data)
    vdata = json.decode(data.Content)
        videodata = {
            GroupID = data.FromGroupId,
            VideoUrl = vdata.VideoUrl,
            VideoMd5 = vdata.VideoMd5
        }
        --构造table 参数表
        luaResp = Api.Api_CallFunc(CurrentQQ, "PttCenterSvr.ShortVideoDownReq", videodata) --通过cmd调用功能包
        luaRes =
            Api.Api_SendMsg(
            CurrentQQ,
            {
                toUser = data.FromGroupId,
                sendToType = 2,
                sendMsgType = "TextMsg",
                groupid = 0,
                content = "解析视频URL-->" .. luaResp.VideoUrl,
                atUser = 0
            }
        )
end

--管理开关通用
function adminio(CurrentQQ,data,oio)
    mim = Read("mimoio\/机器配置\/机器主人\/"..data.FromGroupId.."\/"..data.FromUserId..".txt")
        if (mim ~= nil) then
            msg = data.Content:gsub(oio, "")
            str = Read("mimoio\/状态数据\/机器开关\/"..data.FromGroupId..CurrentQQ..".txt")
            if (string.find(str, "关闭")) then
                sedmsg(CurrentQQ,data,"∴机器人已被关闭...\n请先开启机器人")
                return 1
            end
			str2 = Read("mimoio\/状态数据\/"..oio.."\/"..data.FromGroupId..".txt")
			if (string.find(str2, msg)) then
			    sedmsg(CurrentQQ,data,"∴"..oio.."本就是"..str2.."状态")
                return 1
			end
            Wirte("mimoio\/状态数据\/"..oio.."\/"..data.FromGroupId..".txt",msg)
            sedmsg(CurrentQQ,data,"∴"..oio..msg.."成功")
            return 1
        else
            sedmsg(CurrentQQ,data,"∴你不是我主人呐")
            return 1
        end
end

--百科大全
--[[function baike(CurrentQQ,data)
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
]]
--音乐点歌
function music(CurrentQQ,data)
    keyWord = data.Content:gsub("点歌", "")
        if keyWord == "" then
            return 1
        end
        response, error_message =
            http.request(
            "GET",
            "https://c.y.qq.com/soso/fcgi-bin/client_search_cp",
            {
                query = "aggr=1&cr=1&flag_qc=0&p=1&n=6&w=" .. url_encode(keyWord)
            }
        )
        html = response.body
		str = string.sub(html,10,-2)
        j = json.decode(str)
        if (j.code == 0) then
            msg = ""
            num = j.data.song.list
            list = num[1]
            songname = list.songname
            singername = list.singer[1].name
            payplay = list.pay.payplay
			albummid = list.albummid
			songmid = list.songmid
	        sedjsonmsg(CurrentQQ,data,'{"app":"com.tencent.structmsg","desc":"音乐","view":"music","ver":"0.0.0.1","prompt":"[分享]' ..songname.. '","meta":{"music":{"sourceMsgId":"0","title":"' ..songname.. '","desc":"' ..singername.. '","preview":"y.gtimg.cn/music/photo_new/T002R150x150M000'..albummid..'.jpg","tag":"QQ音乐","musicUrl":"https://v1.itooi.cn/tencent/url?id='..songmid..'","jumpUrl":"y.qq.com/n/yqq/song/'..songmid..'.html","appid":100497308,"app_type":1,"action":"","source_url":"url.cn/5aSZ8Gc","source_icon":"url.cn/5tLgzTm","android_pkg_name":"com.tencent.qqmusic"}},"config":{"forward":true,"type":"normal","autosize":true}}')
			return 1
        else
            sedmsg(CurrentQQ,data,"∴Error:"..j.code)
			return 1
        end
end

--访问url
function geturl(url_class,url,caulrt)
        response, error_message =
            http.request(
            url_class,
            url,
            {
                query = caulrt
            }
        )
        html = response.body
		return html
end

--消息储蓄
function msgsql(CurrentQQ,data)
    if (mysqlpass == "") then
	    return 1
	end
    c = mysql.new()
    -- 初始化mysql对象
    ok, err = c:connect({host = mysqlhost, port = 3306, database = mysqldb, user = mysqluser, password = mysqlpass})
    --建立连接
    if ok then
        sqlstr =
            string.format(
            [[INSERT INTO msgcache (GroupID, MsgSeq, MsgRandom,MsgType,Data,MsgTime)VALUES (%d,%d,%d,'%s','%s',%d)]],
            data.FromGroupId,
            data.MsgSeq,
            data.MsgRandom,
            data.MsgType,
            data.Content,
            data.MsgTime
        )
        res, err = c:query(sqlstr) --入库缓存消息
        log.info("%s", err)
        c.close(c)
    --释放连接
    end
    return 1
end

--撤回检测
function CheHui(CurrentQQ, data, extData)
    c = mysql.new()
    -- 初始化mysql对象
	if (mysqlpass == "") then
	    return 1
	end
	
    if data.MsgType == "ON_EVENT_GROUP_REVOKE" then --监听 群撤回事件
        str = string.format("群成 %d  成员 UserID %s 撤回了消息Seq %s \n", extData.GroupID, extData.UserID, extData.MsgSeq)
        log.info("%s", str)
        ok, err = c:connect({host = mysqlhost, port = 3306, database = mysqldb, user = mysqluser, password = mysqlpass})
        --建立连接
        log.info("sql %v", err)
        if ok then
            sqlstr =
                string.format(
                "select * from msgcache where `GroupID`= %d and `MsgSeq` = %d",
                extData.GroupID,
                extData.MsgSeq
            )
            res, err = c:query(sqlstr) --跟群群id和消息SEQ查询出撤回的消息内容
            if err == nil then
                c.close(c)
                GroupID = tonumber(res[1]["GroupID"])
                MsgType = res[1]["MsgType"]
                Data = res[1]["Data"]

                if MsgType == "TextMsg" then
                    Api.Api_SendMsg(
                        CurrentQQ,
                        {
                            toUser = GroupID,
                            sendToType = 2,
                            sendMsgType = "TextMsg",
                            --发送文本消息
                            groupid = 0,
                            content = string.format(
                                "捕获到成员 %d\n═══════════\n撤回了一条文本消息\n消息内容为：\n%s",
                                extData.UserID,
                                Data
                            ),
                            atUser = 0
                        }
                    )
                end
                if MsgType == "SmallFaceMsg" then
                    --Data {"Content":"[表情101]","Hex":"FKY=","Index":101,"tips":"[小表情]"}
                    Api.Api_SendMsg(
                        CurrentQQ,
                        {
                            toUser = GroupID,
                            sendToType = 2,
                            sendMsgType = "TextMsg",
                            groupid = 0,
                            content = string.format(
                                "捕获到成员 %d\n═══════════\n撤回了一条表情消息\n消息内容为：\n%s",
                                extData.UserID,
                                json.decode(Data).Content
                            ),
                            atUser = 0
                        }
                    )
                end
                if MsgType == "PicMsg" then
                    --Data {"Content":"","FileId":2820717626,"FileMd5":"q0oEC5aloJJMFr10mplaXw==","FileSize":7026,"tips":"[群图片]","url":"http://gchat.qpic.cn/gchatpic_new/1700487478/960839480-2534335053-AB4A040B96A5A0924C16BD749A995A5F/0?vuin=u0026term=255u0026pictype=0"}
                    jData = json.decode(Data)
					if (jData.tips == "[群消息-QQ闪照]") then
					    
					Api.Api_SendMsg( 
                    CurrentQQ,
                    {
                        toUser = GroupID,
                        sendToType = 2,
                        sendMsgType = "ForwordMsg",
                        content = "",
                        atUser = 0,
                        groupid = 0,
                        voiceUrl = "",
                        voiceBase64Buf = "",
                        picUrl = "",
                        picBase64Buf = "",
                        forwordBuf = json.decode(Data).ForwordBuf, --欲转发的base64buf 图片消息 视频消息 会给出此参数
                        forwordField = json.decode(Data).ForwordField --欲写入协议的字段ID 图片消息 视频消息 会给出此参数
                    }
                )
				    return 1
					end
                    Api.Api_SendMsg( --通过图片md5发送图片 秒发不用上传 相当于转发
                        CurrentQQ,
                        {
                            toUser = GroupID,
                            sendToType = 2,
                            sendMsgType = "PicMsg",
                            --发送图文消息
                            content = string.format(
                                "捕获到成员 %d\n═══════════\n撤回了一条图片消息\n消息内容为：[PICFLAG]%s",
                                extData.UserID,
                                jData.Content
                            ),
                            --通过宏[PICFLAG]改变图文顺序  改为现文字后图片
                            atUser = 0,
                            voiceUrl = "",
                            voiceBase64Buf = "",
                            picUrl = "",
                            picBase64Buf = "",
                            fileMd5 = jData.FileMd5
                        }
                    )
                end
                if MsgType == "AtMsg" then
                    --Data {"Content":"@Kar98k skjjkssjkjs","UserID":123456789,"tips":"[AT消息]"}
                    Api.Api_SendMsg(
                        CurrentQQ,
                        {
                            toUser = GroupID,
                            sendToType = 2,
                            sendMsgType = "TextMsg",
                            groupid = 0,
                            content = string.format(
                                "捕获到成员 %d\n═══════════\n撤回了一条at消息\n消息内容为：\n%s",
                                extData.UserID,
                                json.decode(Data).Content
                            ),
                            atUser = 0
                        }
                    )
                end
                if MsgType == "VoiceMsg" then
                    --Data {"tips":"[语音]","url":"http://grouptalk.c2c.qq.com/?ver=0u0026rkey=3062020101045b305902010102010102041fdef8ae042439416931554e5142586c536d78706a314c686843664959725f327a5f573064697653755902045dac2a21041f0000000866696c6574797065000000013100000005636f64656300000001310400u0026filetype=1u0026voice_codec=1"}
                    --log.info("sql %s", json.decode(Data).url)
                    Api.Api_SendMsg(
                        CurrentQQ,
                        {
                            toUser = GroupID,
                            sendToType = 2,
                            sendMsgType = "VoiceMsg",
                            --发送群语音消息
                            groupid = 0,
                            content = "",
                            atUser = 0,
                            voiceUrl = json.decode(Data).url,
                            --通过网络url进行发送语音
                            voiceBase64Buf = "",
                            picUrl = "",
                            picBase64Buf = ""
                        }
                    )
                end

                if MsgType == "ReplayMsg" then
                    --Data {"MsgSeq":3536,"ReplayContent":"11 @Mac","SrcContent":"...","UserID":123123,"tips":"[回复]"}
                    --log.info("sql %s", json.decode(Data).url)
                    Api.Api_SendMsg(
                        CurrentQQ,
                        {
                            toUser = GroupID,
                            sendToType = 2,
                            sendMsgType = "TextMsg",
                            groupid = 0,
                            content = string.format(
                                "捕获到成员 %d\n═══════════\n撤回了一条回复消息\n消息内容为：\n%s",
                                extData.UserID,
                                json.decode(Data).ReplayContent
                            ),
                            atUser = 0
                        }
                    )
                end
				if MsgType == "VideoMsg" then
	             Api.Api_SendMsg( 
                    CurrentQQ,
                    {
                        toUser = GroupID,
                        sendToType = 2,
                        sendMsgType = "ForwordMsg",
                        content = "",
                        atUser = 0,
                        groupid = 0,
                        voiceUrl = "",
                        voiceBase64Buf = "",
                        picUrl = "",
                        picBase64Buf = "",
                        forwordBuf = json.decode(Data).ForwordBuf, --欲转发的base64buf 图片消息 视频消息 会给出此参数
                        forwordField = json.decode(Data).ForwordField --欲写入协议的字段ID 图片消息 视频消息 会给出此参数
                    }
                )
				end
                if MsgType == "XmlMsg" then
				    
                    --Data {"MsgSeq":3536,"ReplayContent":"11 @Mac","SrcContent":"...","UserID":123123,"tips":"[回复]"}
                    --log.info("sql %s", json.decode(Data).url)
                    Api.Api_SendMsg(
                        CurrentQQ,
                        {
                            toUser = GroupID,
                            sendToType = 2,
                            sendMsgType = "XmlMsg",
                            groupid = 0,
                            content = string.format("%s", Data),
                            atUser = 0
                        }
                    )
                end
				if MsgType == "JsonMsg" then
				    
                    --Data {"MsgSeq":3536,"ReplayContent":"11 @Mac","SrcContent":"...","UserID":123123,"tips":"[回复]"}
                    --log.info("sql %s", json.decode(Data).url)
                    Api.Api_SendMsg(
                        CurrentQQ,
                        {
                            toUser = GroupID,
                            sendToType = 2,
                            sendMsgType = "JsonMsg",
                            groupid = 0,
                            content = string.format("%s", Data),
                            atUser = 0
                        }
                    )
                end
            end
        end
    end
    return 1
end