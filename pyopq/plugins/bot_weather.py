import requests
import json
from iotbot import Action
from iotbot import GroupMsg
from iotbot.decorators import equal_content
from iotbot.decorators import not_botself
from datetime import datetime
from iotbot.sugar import Text

from iotbot.decorators import equal_content
from iotbot.decorators import not_botself

# 推荐用lua写


# 屏蔽群 例：[12345678, 87654321]
blockGroupNumber = []
# ==========================================

@not_botself
def receive_group_msg(ctx: GroupMsg):
    userGroup = ctx.FromGroupId
    if(userGroup in blockGroupNumber):
        return
    c = ctx.Content
    if  c.startswith('天气'):
        plugin_name = c[3:]
        print('keyWord------>'+plugin_name)
        response = requests.get('http://wthrcdn.etouch.cn/weather_mini?city='+str(plugin_name),timeout=10).text
        res = json.loads(response)
        if(res['status'] !=1000):
            Text('不支持查询的地点，请输入正确的城市名')
        else:
            '''获取时间表情'''
            now_ = datetime.now()
            hour = now_.hour
            minute = now_.minute
            now = hour + minute / 60
            if 5.5 < now < 18:
                biaoqing = '[表情74]'
            else:
                biaoqing = '[表情75]'

            title = '\n'+biaoqing +'你正在查找的'+res['data']['city']+'的天气'
            todayWeather = '\n🔥'+res['data']['forecast'][0]['date']+'的天气:'+ res['data']['forecast'][0]['type']+''+returnWeatherBiaoqing(res['data']['forecast'][0]['type'])
            toMoWeather = '\n🔥'+res['data']['forecast'][1]['date']+'的天气:'+ res['data']['forecast'][1]['type']+''+returnWeatherBiaoqing(res['data']['forecast'][1]['type'])
            tips ='\n[表情89]体表温度为'+res['data']['wendu']+'℃\n💊群助手防感冒提醒你：'+ res['data']['ganmao']
            returnContent =(title+''+todayWeather+''+toMoWeather+''+tips)
            Action(ctx.CurrentQQ).send_group_text_msg(
                ctx.FromGroupId,
                content=returnContent,
                atUser=ctx.FromUserId

            )

def returnWeatherBiaoqing(weatherType):
    if ('晴' in weatherType):
        weatherBiaoqing = '☀️'
    elif ('雨' in weatherType):
        weatherBiaoqing = '☔️'
    elif ('雷' in weatherType):
        weatherBiaoqing = '🌩️'
    elif ('阴' in weatherType):
        weatherBiaoqing = '☁️️'
    elif ('云' in weatherType):
        weatherBiaoqing = '☁️️'
    elif ('雪' in weatherType):
        weatherBiaoqing = '❄️️️'
    else:
        weatherBiaoqing = ''
    return weatherBiaoqing