# -*- coding:utf-8 -*-
RESOURCES_BASE_PATH = './resources/zan'  
# 在这个文件夹下建立一个文件夹   实例/zan/date/
# ==========================================

# 屏蔽群 例：[12345678, 87654321]
blockGroupNumber = []

# ==========================================
import requests
import json
from iotbot import Action
from iotbot import GroupMsg
from iotbot.decorators import equal_content
from iotbot.decorators import not_botself
from iotbot.sugar import Text
import time
import datetime
import os

# 屏蔽群 例：[12345678, 87654321]
blockGroupNumber = []

blockUserNumber =[]
# ==========================================

@not_botself()
def receive_group_msg(ctx: GroupMsg):
    userGroup = ctx.FromGroupId
    if (userGroup in blockGroupNumber):
        return
    qq = ctx.FromUserId
    c = ctx.Content
    if(c.startswith('#赞我')):
        f = read(ctx.FromUserId)
        if(f == 0):
            Action(ctx.CurrentQQ).send_group_text_msg(
                ctx.FromGroupId,
                content='正在赞~~请稍等，大概花费30s左右',
                atUser=ctx.FromUserId
            )
            nowTime = returnDate()
            save(nowTime,ctx.FromUserId)

            for i in range(50):
                Action(ctx.CurrentQQ).like(
                    ctx.FromUserId
                )
                time.sleep(0.4)
            Action(ctx.CurrentQQ).send_group_text_msg(
                ctx.FromGroupId,
                content='赞好啦~请查收',
                atUser=ctx.FromUserId
            )
        else:
            if(isToday(f) == 1):
                Text('你已经赞过了，请明天在来吧~')
            else :
                Action(ctx.CurrentQQ).send_group_text_msg(
                    ctx.FromGroupId,
                    content='正在赞~~请稍等，大概花费30s左右',
                    atUser=ctx.FromUserId
                )
                nowTime = returnDate()
                save(nowTime, ctx.FromUserId)

                for i in range(50):
                    Action(ctx.CurrentQQ).like(
                        ctx.FromUserId
                    )
                    time.sleep(0.4)
                Action(ctx.CurrentQQ).send_group_text_msg(
                    ctx.FromGroupId,
                    content='赞好啦~请查收',
                    atUser=ctx.FromUserId
                )

def returnDate():
    now = time.time()
    return now

def isToday(zantime):
    today = datetime.date.today()
    tomorrow = today + datetime.timedelta(days=1)
    tomorrow_start_time = int(time.mktime(time.strptime(str(tomorrow), '%Y-%m-%d')))
    yesterday_end_time = int(time.mktime(time.strptime(str(today), '%Y-%m-%d'))) - 1
    if(zantime > yesterday_end_time and zantime<tomorrow_start_time):
        return 1
    else:
        return 0
def save(json,qq):
    fullPath = RESOURCES_BASE_PATH + '/date/' + str(qq) + '.json'
    with open(fullPath, 'w', encoding='utf-8') as f:
        f.write(str(json))
    return 1


def read(qq):
    fullPath = RESOURCES_BASE_PATH + '/date/' + str(qq) + '.json'
    if not os.path.exists(fullPath):
        return 0
    with open(fullPath, 'r', encoding='utf-8') as f:
        return json.loads(f.read())
