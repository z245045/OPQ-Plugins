# -*- coding:utf-8 -*-

RESOURCES_BASE_PATH = './resources/revoke'

# ==========================================

# 屏蔽群 例：[12345678, 87654321]
blockGroupNumber = []
max_info_length = 341

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


def cut(obj, sec):
    return [obj[i:i + sec] for i in range(0, len(obj), sec)]


def receive_group_msg(ctx: GroupMsg):
    if ctx.FromUserId == ctx.CurrentQQ:
        return
    if ctx.MsgType == 'AtMsg':
        content = json.loads(ctx.Content)
        msg = content['Content']
        at_user_id = content['UserID'][0] if "UserID" in content else 0
        if at_user_id == 0:
            return
        info_ret = re.findall(r'最近撤回\s*(\d.*)', msg)
        info_1 = re.findall(r'最近撤回', msg)
        if info_1:
            page_no = info_ret[0] if info_ret else 1
            userGroup = ctx.FromGroupId
            userQQ = ctx.FromUserId
            try:
                if op.is_group_owner(userGroup, userQQ) is True or op.is_group_admin(userGroup, userQQ) is True or op.is_bot_master(ctx.CurrentQQ, userQQ) is True:
                    msg_revoke = op.find_group_msg_member_revoke(userGroup, at_user_id, page_no)
                    msg = '\n%s(%s)所有撤回的消息，第%s条:\n' % (get_user_nick(at_user_id), at_user_id, page_no)
                    if len(msg_revoke) == 0:
                        msg += '[呃，没有更多记录了]'
                        action.send_group_text_msg(userGroup, msg, atUser=userQQ)
                        return
                    else:
                        msg_revoke = msg_revoke[0]
                        if msg_revoke["msg_type"] == 'TextMsg':
                            action.send_group_text_msg(userGroup, msg + msg_revoke["content"], atUser=userQQ)
                        elif msg_revoke["msg_type"] == 'VoiceMsg':
                            action.send_group_text_msg(userGroup, msg, atUser=userQQ)
                            action.send_group_voice_msg(msg_revoke["from_group_id"], voiceUrl=msg_revoke['voice_url'])
                        elif msg_revoke["msg_type"] == 'AtMsg':
                            action.send_group_text_msg(userGroup, msg + msg_revoke["content"], atUser=userQQ)
                        elif msg_revoke["msg_type"] == 'PicMsg':
                            msg_content = msg_revoke["content"] if msg_revoke["content"] is not None else ""
                            action.send_group_text_msg(userGroup, msg + msg_content, atUser=userQQ)
                            pics = json.loads(msg_revoke["pics"])
                            for pic_id in pics:
                                pic_content = op.find_img_by_id(pic_id)[0]
                                action.send_group_pic_msg(
                                    msg_revoke["from_group_id"],
                                    fileMd5=pic_content['FileMd5'],
                                    picBase64Buf=pic_content['ForwordBuf']
                                )
                else:
                    action.send_group_text_msg(userGroup, '\n只有群主和管理员可以使用“最近撤回”指令', atUser=userQQ)  # 群员可尝试“提议”方式执行指令
            except Exception as e:
                print('db.find returns null result')
                print(e)
                return
    elif ctx.MsgType == 'TextMsg':
        msg = ctx.Content
        info_ret = re.findall(r'最近撤回\s*(\d.*)', msg)
        info_1 = re.findall(r'最近撤回', msg)
        if info_1:
            page_no = info_ret[0] if info_ret else 1
            userGroup = ctx.FromGroupId
            userQQ = ctx.FromUserId
            try:
                if op.is_group_owner(userGroup, userQQ) is True or op.is_group_admin(userGroup, userQQ) is True or op.is_bot_master(ctx.CurrentQQ, userQQ) is True:
                    msg_revokes = op.find_group_msg_recent_revoke(userGroup, page_no)
                    msg = '\n本群所有撤回的消息，第%s页（10条/页）:\n' % page_no
                    if len(msg_revokes) == 0:
                        msg += '[呃，没有更多记录了]'
                        action.send_group_text_msg(userGroup, msg, atUser=userQQ)
                        return
                    for msg_revoke in msg_revokes:
                        msg += '【' + str(
                            time.strftime("%H:%M:%S",
                                          time.localtime(msg_revoke["revoke_time"]))) + '】 ' + get_user_nick(
                            msg_revoke["revoke_AdminUserID"]) + " 撤回了"
                        if msg_revoke["revoke_AdminUserID"] == msg_revoke["revoke_UserID"]:
                            msg += '自己'
                        else:
                            msg += get_user_nick(msg_revoke["revoke_UserID"]) + '(' + str(
                                msg_revoke["revoke_UserID"]) + ')'
                        msg += '的消息：“%s”\n' % msg_revoke["content"]

                    cut_msgs = cut(msg, max_info_length)
                    for cut_msg in cut_msgs:
                        action.send_group_text_msg(userGroup, cut_msg, atUser=userQQ)
                        userQQ = 0
                else:
                    action.send_group_text_msg(userGroup, '\n只有群主和管理员可以使用“最近撤回”指令',
                                               atUser=userQQ)  # ToDo:群员可尝试“提议”方式执行指令
            except Exception as e:
                print('db.find returns null result')
                print(e)
                return


def receive_events(ctx: dict):
    if ctx['CurrentPacket']['Data']['EventName'] == 'ON_EVENT_GROUP_ADMINSYSNOTIFY':
        msg_set = ctx['CurrentPacket']['Data']['EventData']
        msg_group_id = msg_set['GroupId']

        # 管理员变更，强制刷新成员列表
        op.check_group_member_list(msg_group_id, 0)

    elif ctx['CurrentPacket']['Data']['EventName'] == 'ON_EVENT_GROUP_REVOKE' and \
            ctx['CurrentPacket']['Data']['EventData']['UserID'] != int(os.getenv('BOTQQ')):
        msg_set = ctx['CurrentPacket']['Data']['EventData']
        msg_seq = msg_set['MsgSeq']
        msg_group_id = msg_set['GroupID']
        admin_user_id = msg_set['AdminUserID']
        user_id = msg_set['UserID']

        try:
            # 置群消息为撤回状态
            op.update_group_msg_is_revoked_by_msg_seq(msg_seq, msg_group_id, admin_user_id, user_id)
        except Exception as e:
            print('db.find returns null result')
            return
