-- nmc/天气
local Api = require("coreApi")
local json = require("json")
local http = require("http")

function startswith(str, Start)
   return string.sub(str, 1, string.len(Start)) == Start
end

function getWeather(cityID)
    local res, err = http.request('GET', 'http://www.nmc.cn/rest/weather?stationid='..cityID)
    if err ~= nil then
        return nil
    end
    local info = json.decode(res.body)
    local info_real = info['data']['real']
    local info_predict = info['data']['predict']
    local real = string.format(
        '%s\n气温: %.1f°C  %s\n体感温度: %.1f°C\n气温变化: %.1f°C \n空气压力: %.1fhPa\n湿度: %d %%\n降雨量: %dmm\n%s %s\n%s',
        info_real['station']['province']..info_real['station']['city'],
        info_real['weather']['temperature'],
        info_real['weather']['info'],
        info_real['weather']['feelst'],
        info_real['weather']['temperatureDiff'],
        info_real['weather']['airpressure'],
        info_real['weather']['humidity'],
        info_real['weather']['rain'],
        info_real['wind']['direct'],
        info_real['wind']['power'],
        info_real['publish_time']
    )
    local predict_detail = info_predict['detail']
    local predict =  string.format(
        '%s\n白天: %s°C %s %s%s\n夜间: %s°C %s %s%s',
        info_predict['publish_time'],
        predict_detail[1]['day']['weather']['temperature'],
        predict_detail[1]['day']['weather']['info'],
        predict_detail[1]['day']['wind']['direct'],
        predict_detail[1]['day']['wind']['power'],
        predict_detail[1]['night']['weather']['temperature'],
        predict_detail[1]['night']['weather']['info'],
        predict_detail[1]['night']['wind']['direct'],
        predict_detail[1]['night']['wind']['power']
    )
    return real..'\n----------\n'..predict
end


function ReceiveGroupMsg(CurrentQQ, data)
    if data.FromUserId == tonumber(CurrentQQ) then
        return 1
    end

    if startswith(data.Content, 'nmc') or startswith(data.Content, '天气') then
        local city = data.Content:gsub('nmc', ''):gsub('天气', '')
        local f, _ = io.open('./Plugins/stationID.json', "r")
        local content = f:read("*all")
        f:close()
        local ID_Data = json.decode(content)
        local cityID = ID_Data[city]
        if cityID then
            Api.Api_SendMsg(
                CurrentQQ,
                {
                    toUser = data.FromGroupId,
                    sendToType = 2,
                    sendMsgType = "TextMsg",
                    groupid = 0,
                    content = getWeather(cityID),
                    atUser = 0
                }
            )
            return 2
        end
    end
    return 1
end



function ReceiveFriendMsg(CurrentQQ, data)
    return 1
end

function ReceiveEvents(CurrentQQ, data, extData)
    return 1
end
