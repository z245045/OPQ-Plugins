# -*- coding:utf-8 -*-

RESOURCES_BASE_PATH = './resources/flash-pic'

# ==========================================

# 屏蔽群 例：[12345678, 87654321]
blockGroupNumber = []

# ==========================================

import os
import re
import time

from iotbot import Action, GroupMsg

import util.db.sql as op

try:
    import ujson as json
except:
    import json

action = Action(
    # 注意更换您的 bot.py 文件为最新
    qq_or_bot=int(os.getenv('BOTQQ')),
    queue=True,
    queue_delay=0.5
)


def get_user_nick(user_id):
    return '[GETUSERNICK(%s)]' % user_id


def receive_group_msg(ctx: GroupMsg):
    if ctx.FromUserId == ctx.CurrentQQ:
        return
    if ctx.MsgType == 'AtMsg':
        content = json.loads(ctx.Content)
        msg = content['Content']
        at_user_id = content['UserID'][0] if "UserID" in content else 0
        if at_user_id == 0:
            return
        info_ret = re.findall(r'闪照现\s*(\d.*)', msg)
        info_1 = re.findall(r'闪照现', msg)
        if info_1:
            page_no = info_ret[0] if info_ret else 1
            userGroup = ctx.FromGroupId
            userQQ = ctx.FromUserId
            try:
                if op.is_group_owner(userGroup, userQQ) is True or op.is_group_admin(userGroup,
                                                                                     userQQ) is True or op.is_bot_master(
                        ctx.CurrentQQ, userQQ) is True:
                    msg_flash_pic = op.find_group_msg_member_flash_pic(userGroup, at_user_id, page_no)
                    if len(msg_flash_pic) == 0:
                        msg = '\n[呃，没有更多记录了]'
                        action.send_group_text_msg(userGroup, msg, atUser=userQQ)
                    else:
                        msg_flash_pic = msg_flash_pic[0]
                        msg = '\n%s(%s)在%s发送的闪照，第%s条:\n' % (get_user_nick(at_user_id), at_user_id,
                                                            time.strftime("%H:%M:%S",
                                                                          time.localtime(msg_flash_pic["msg_time"])),
                                                            page_no)
                        pics = json.loads(msg_flash_pic["pics"])
                        for pic_id in pics:
                            pic_content = op.find_img_by_id(pic_id)[0]
                            action.send_group_pic_msg(
                                userGroup,
                                content='[ATUSER(%s)][PICFLAG]' % userQQ + msg,
                                fileMd5=pic_content['FileMd5'],
                                picBase64Buf=pic_content['ForwordBuf']
                            )
                else:
                    action.send_group_text_msg(userGroup, '\n只有群主和管理员可以使用“闪照现”指令', atUser=userQQ)  # 群员可尝试“提议”方式执行指令
            except Exception as e:
                print('db.find returns null result')
                print(e)
                return
    if ctx.MsgType == 'TextMsg':
        msg = ctx.Content

        info_ret = re.findall(r'闪照现\s*(\d.*)', msg)
        info_1 = re.findall(r'闪照现', msg)
        if info_1:
            page_no = info_ret[0] if info_ret else 1
            userGroup = ctx.FromGroupId
            userQQ = ctx.FromUserId
            try:
                if op.is_group_owner(userGroup, userQQ) is True or op.is_group_admin(userGroup,
                                                                                     userQQ) is True or op.is_bot_master(
                        ctx.CurrentQQ, userQQ) is True:
                    msg_flash_pic = op.find_group_msg_recent_flash_pic(userGroup, page_no)
                    if len(msg_flash_pic) == 0:
                        msg = '\n[呃，没有更多记录了]'
                        action.send_group_text_msg(userGroup, msg, atUser=userQQ)
                    else:
                        msg_flash_pic = msg_flash_pic[0]
                        msg = '\n%s(%s)在%s发送的闪照，第%s条:\n' % (
                            msg_flash_pic['from_nickname'], msg_flash_pic['from_user_id'],
                            time.strftime("%H:%M:%S", time.localtime(msg_flash_pic["msg_time"])), page_no)
                        pics = json.loads(msg_flash_pic["pics"])
                        for pic_id in pics:
                            pic_content = op.find_img_by_id(pic_id)[0]
                            action.send_group_pic_msg(
                                userGroup,
                                content='[ATUSER(%s)][PICFLAG]' % userQQ + msg,
                                fileMd5=pic_content['FileMd5'],
                                picBase64Buf=pic_content['ForwordBuf']
                            )
                else:
                    action.send_group_text_msg(userGroup, '\n只有群主和管理员可以使用“闪照现”指令',
                                               atUser=userQQ)  # ToDo:群员可尝试“提议”方式执行指令
            except Exception as e:
                print('db.find returns null result')
                print(e)
                return
