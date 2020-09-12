# -*- coding:utf-8 -*-

RESOURCES_BASE_PATH = './resources/record'

# ==========================================

# 屏蔽群 例：[12345678, 87654321]
blockGroupNumber = []
max_info_length = 341

# ==========================================

from iotbot import GroupMsg, FriendMsg

import util.db.sql as op

try:
    import ujson as json
except:
    import json


def receive_group_msg(ctx: GroupMsg):
    # 群消息存入数据库
    op.insert_group_msg(ctx)

    # 检查群列表及群成员数据是否存在
    msg_group_id = ctx.FromGroupId
    admin_user_id = ctx.FromUserId
    op.check_group_list(msg_group_id)
    op.check_group_member_list(msg_group_id, admin_user_id)

    # print(ctx.FromNickName + '是群主：' + str(op.is_group_owner(msg_group_id, admin_user_id)))
    # print(ctx.FromNickName + '是管理员：' + str(op.is_group_admin(msg_group_id, admin_user_id)))
    # print(ctx.FromNickName + '是主人：' + str(op.is_bot_master(ctx.CurrentQQ, admin_user_id)))


def receive_friend_msg(ctx: FriendMsg):
    # 好友消息存入数据库
    op.insert_friend_msg(ctx)
