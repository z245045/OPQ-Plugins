# -*- coding:utf-8 -*-

import os

from iotbot import IOTBOT, Action, GroupMsg

bot_qq = 1689236904

# 使得并发命令时，插件可以排队处理
os.environ['BOTQQ'] = str(bot_qq)

bot = IOTBOT(
    qq=bot_qq,
    # 若非默认，请在 .iotbot.json 内配置 ↓
    # host = 'http://127.0.0.1', 
    # port = 8888,
    use_plugins=True
)
action = Action(bot)


@bot.on_group_msg
def on_group_msg(ctx: GroupMsg):
    # 不处理自身消息
    if ctx.FromUserId == ctx.CurrentQQ:
        return


if __name__ == "__main__":
    bot.run()
