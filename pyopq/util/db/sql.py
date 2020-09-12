# -*- coding:utf-8 -*-

import json
import os
import time

import pymysql
from iotbot import GroupMsg, FriendMsg, Action

from util.db.config import config

action = Action(
    # 注意更换您的 bot.py 文件为最新
    qq_or_bot=int(os.getenv('BOTQQ'))
)


class Mysql:
    def __init__(self):
        self.db = pymysql.connect(host=config.mysql_host, port=config.mysql_port, user=config.mysql_user,
                                  password=config.mysql_pass, database=config.mysql_db, charset='utf8mb4')
        self.cursor = self.db.cursor(pymysql.cursors.DictCursor)

    def __del__(self):
        self.cursor.close()
        self.db.close()

    def commit(self, sql):
        try:
            self.cursor.execute(sql)
            self.db.commit()
        except Exception as error:
            print('\033[031m', error, '\033[0m', sep='')

    def update(self, table, dt_update, dt_condition):
        sql = 'UPDATE %s SET ' % table + ','.join('%s=%r' % (k, dt_update[k]) for k in dt_update) \
              + ' WHERE ' + ' AND '.join('%s=%r' % (k, dt_condition[k]) for k in dt_condition) + ';'
        try:
            self.commit(sql)
        except Exception as e:
            print(sql)
            print(e)

    def insert(self, tb, dt):
        ls = [(k, dt[k]) for k in dt if dt[k] is not None]
        sql = 'insert %s (' % tb + ','.join(i[0] for i in ls) + \
              ') values (' + ','.join('%r' % i[1] for i in ls) + ');'
        try:
            self.cursor.execute(sql)
        except Exception as e:
            print(sql)
            print(e)
        res = self.db.insert_id()
        self.db.commit()
        return res

    def query(self, sql):
        self.cursor.execute(sql)
        res = self.cursor.fetchall()
        return res


def find_group_list_by_group_owner(from_group_id, member_id):
    db = Mysql()
    res = db.query('''SELECT * FROM `trooplist` WHERE GroupId=%s AND GroupOwner=%s''' % (from_group_id, member_id))
    return res


def find_group_list_by_group_admin(from_group_id, member_id):
    db = Mysql()
    res = db.query('''SELECT * FROM `memberlist` WHERE GroupUin=%s AND MemberUin=%s AND GroupAdmin=1''' % (
        from_group_id, member_id))
    return res


def find_qq_bot_master(current_qq, master_qq):
    db = Mysql()
    res = db.query('''SELECT * FROM `bot_config` WHERE current_qq=%s AND master_qq=%s''' % (
        current_qq, master_qq))
    return res


def check_group_list(msg_group_id):
    try:
        r = find_group_by_group_id(msg_group_id)
        if len(r) == 0:
            print(str(msg_group_id) + ' -> 检测到新的群组，刷新群列表中...')
            for troop_list in action.get_group_list()['TroopList']:
                re = find_group_by_group_id(troop_list['GroupId'])
                if len(re) == 0:
                    insert_group_list(troop_list)
                else:
                    update_group_list(troop_list)
    except Exception as e:
        print('check_group_list')
        print(e)
        return


def check_group_member_list(msg_group_id, admin_user_id):
    try:
        r = find_member_by_uin(msg_group_id, admin_user_id)
        if len(r) == 0:
            print(str(msg_group_id) + ' -> 检测到新的群成员/管理员变更，刷新群成员列表中...')
            for group_user_list in action.get_group_user_list(msg_group_id):
                re = find_member_by_uin(msg_group_id, group_user_list['MemberUin'])
                group_user_list['GroupUin'] = msg_group_id
                group_user_list['LastUin'] = 0
                group_user_list['Count'] = 0
                if len(re) == 0:
                    insert_member_list(group_user_list)
                else:
                    update_member_list(group_user_list)
    except Exception as e:
        print('check_group_member_list')
        print(e)
        return


def is_group_owner(msg_group_id, member_id):
    try:
        r = find_group_list_by_group_owner(msg_group_id, member_id)
        if len(r) == 0:
            return False
        else:
            return True
    except Exception as e:
        print('is_group_owner')
        print(e)
        return False


def is_group_admin(msg_group_id, member_id):
    try:
        r = find_group_list_by_group_admin(msg_group_id, member_id)
        if len(r) == 0:
            return False
        else:
            return True
    except Exception as e:
        print('is_group_admin')
        print(e)
        return False


def is_bot_master(current_qq, master_qq):
    try:
        r = find_qq_bot_master(current_qq, master_qq)
        if len(r) == 0:
            return False
        else:
            return True
    except Exception as e:
        print('is_bot_master')
        print(e)
        return False


# img
def find_img_by_id(id):
    db = Mysql()
    res = db.query('''SELECT * FROM `img` WHERE FileId=%d''' % id)
    return res


# group_list
def find_group_by_group_id(from_group_id):
    db = Mysql()
    res = db.query('''SELECT * FROM `trooplist` WHERE GroupId=%s''' % from_group_id)
    return res


def insert_group_list(troop_list):
    db = Mysql()
    res = db.insert('trooplist', dict(
        GroupId=troop_list['GroupId'],
        GroupMemberCount=troop_list['GroupMemberCount'],
        GroupName=troop_list['GroupName'],
        GroupNotice=troop_list['GroupNotice'],
        GroupOwner=troop_list['GroupOwner'],
        GroupTotalCount=troop_list['GroupTotalCount'],
    ))
    return res


def update_group_list(troop_list):
    db = Mysql()
    db.update('trooplist', dict(
        GroupId=troop_list['GroupId'],
        GroupMemberCount=troop_list['GroupMemberCount'],
        GroupName=troop_list['GroupName'],
        GroupNotice=troop_list['GroupNotice'],
        GroupOwner=troop_list['GroupOwner'],
        GroupTotalCount=troop_list['GroupTotalCount'],
    ), dict(
        GroupId=troop_list['GroupId']
    ))
    return


# member_list
def find_member_by_uin(from_group_id, member_uin):
    db = Mysql()
    res = db.query('''SELECT * FROM `memberlist` WHERE GroupUin=%s AND MemberUin=%d''' % (from_group_id, member_uin))
    return res


def insert_member_list(member_list):
    db = Mysql()
    res = db.insert('memberlist', dict(
        GroupUin=member_list['GroupUin'],
        LastUin=member_list['LastUin'],
        Count=member_list['Count'],
        Age=member_list['Age'],
        AutoRemark=member_list['AutoRemark'],
        CreditLevel=member_list['CreditLevel'],
        Email=member_list['Email'],
        FaceId=member_list['FaceId'],
        Gender=member_list['Gender'],
        GroupAdmin=member_list['GroupAdmin'],
        GroupCard=member_list['GroupCard'],
        JoinTime=member_list['JoinTime'],
        LastSpeakTime=member_list['LastSpeakTime'],
        MemberLevel=member_list['MemberLevel'],
        MemberUin=member_list['MemberUin'],
        Memo=member_list['Memo'],
        NickName=member_list['NickName'],
        ShowName=member_list['ShowName'],
        SpecialTitle=member_list['SpecialTitle'],
        Status=member_list['Status'],
    ))


def update_member_list(member_list):
    db = Mysql()
    db.update('memberlist', dict(
        GroupUin=member_list['GroupUin'],
        LastUin=member_list['LastUin'],
        Count=member_list['Count'],
        Age=member_list['Age'],
        AutoRemark=member_list['AutoRemark'],
        CreditLevel=member_list['CreditLevel'],
        Email=member_list['Email'],
        FaceId=member_list['FaceId'],
        Gender=member_list['Gender'],
        GroupAdmin=member_list['GroupAdmin'],
        GroupCard=member_list['GroupCard'],
        JoinTime=member_list['JoinTime'],
        LastSpeakTime=member_list['LastSpeakTime'],
        MemberLevel=member_list['MemberLevel'],
        MemberUin=member_list['MemberUin'],
        Memo=member_list['Memo'],
        NickName=member_list['NickName'],
        ShowName=member_list['ShowName'],
        SpecialTitle=member_list['SpecialTitle'],
        Status=member_list['Status'],
    ), dict(
        GroupUin=member_list['GroupUin'],
        MemberUin=member_list['MemberUin']
    ))


def update_group_msg_is_revoked_by_msg_seq(msg_seq, from_group_id, admin_user_id, user_id):
    db = Mysql()
    db.update('group_msg', dict(
        is_revoke=1,
        revoke_AdminUserID=admin_user_id,
        revoke_UserID=user_id,
        revoke_time=int(time.time()),
    ), dict(
        msg_seq=msg_seq,
        from_group_id=from_group_id
    ))
    return


# group_msg
def find_group_msg_by_msg_seq(msg_seq, from_group_id=None):
    db = Mysql()
    if from_group_id is None:
        res = db.query('''SELECT * FROM `group_msg` WHERE msg_seq=%d''' % msg_seq)
    else:
        res = db.query('''SELECT * FROM `group_msg` WHERE msg_seq=%s AND from_group_id=%d''' % (msg_seq, from_group_id))
    return res


def find_group_msg_member_flash_pic(from_group_id, from_user_id, page_no):
    db = Mysql()
    res = db.query(
        '''SELECT * FROM `group_msg` WHERE from_group_id=%s AND from_user_id=%s AND tips='[群消息-QQ闪照]' AND msg_type='PicMsg' ORDER BY msg_time DESC LIMIT %s,1''' % (
            from_group_id, from_user_id, int(page_no) - 1))
    return res


def find_group_msg_recent_flash_pic(from_group_id, page_no):
    db = Mysql()
    res = db.query(
        '''SELECT * FROM `group_msg` WHERE from_group_id=%s AND tips='[群消息-QQ闪照]' AND msg_type='PicMsg' ORDER BY msg_time DESC LIMIT %s,1''' % (
            from_group_id, int(page_no) - 1))
    return res


def find_group_msg_member_revoke(from_group_id, from_user_id, page_no):
    db = Mysql()
    res = db.query(
        '''SELECT * FROM `group_msg` WHERE from_group_id=%s AND from_user_id=%s AND is_revoke=1 ORDER BY msg_time DESC LIMIT %s,1''' % (
            from_group_id, from_user_id, int(page_no) - 1))
    return res


def find_group_msg_recent_revoke(from_group_id, page_no):
    db = Mysql()
    res = db.query(
        '''SELECT * FROM `group_msg` WHERE from_group_id=%s AND is_revoke=1 ORDER BY msg_time DESC LIMIT %s,10''' % (
            from_group_id, (int(page_no) - 1) * 10))
    return res


def insert_group_msg(ctx: GroupMsg):
    db = Mysql()
    if ctx.MsgType == 'TextMsg':
        res = db.insert('group_msg', dict(
            current_qq=ctx.CurrentQQ,
            from_nickname=ctx.FromNickName,
            from_user_id=ctx.FromUserId,
            from_group_name=ctx.FromGroupName,
            from_group_id=ctx.FromGroupId,
            at_user_id=None,
            content=ctx.Content,
            pics=None,
            tips="",
            redbag_info=ctx.RedBaginfo,
            msg_time=ctx.MsgTime,
            msg_type=ctx.MsgType,
            msg_seq=ctx.MsgSeq,
            msg_random=ctx.MsgRandom
        ))
        # print(res)
    elif ctx.MsgType == 'PicMsg':
        content = json.loads(ctx.Content)
        pics = []
        if content["Tips"] == '[群消息-QQ闪照]':
            ret = db.insert('img', dict(
                FileId=content['FileId'],
                FileMd5=content['FileMd5'],
                FileSize=content['FileSize'],
                ForwordBuf=content['ForwordBuf'],
                ForwordField=content['ForwordField'],
                Url=content['Url'],
            ))
            pics.append(ret)
        else:
            for pic in content["GroupPic"]:
                ret = db.insert('img', dict(
                    FileId=pic['FileId'],
                    FileMd5=pic['FileMd5'],
                    FileSize=pic['FileSize'],
                    ForwordBuf=pic['ForwordBuf'],
                    ForwordField=pic['ForwordField'],
                    Url=pic['Url'],
                ))
                pics.append(ret)
        db.insert('group_msg', dict(
            current_qq=ctx.CurrentQQ,
            from_nickname=ctx.FromNickName,
            from_user_id=ctx.FromUserId,
            from_group_name=ctx.FromGroupName,
            from_group_id=ctx.FromGroupId,
            at_user_id=json.dumps(content["UserID"]) if "UserID" in content else None,
            content=content["Content"] if "Content" in content else None,
            pics=json.dumps(pics),
            tips=content["Tips"],
            redbag_info=ctx.RedBaginfo,
            msg_time=ctx.MsgTime,
            msg_type=ctx.MsgType,
            msg_seq=ctx.MsgSeq,
            msg_random=ctx.MsgRandom
        ))
    elif ctx.MsgType == 'AtMsg':
        content = json.loads(ctx.Content)
        db.insert('group_msg', dict(
            current_qq=ctx.CurrentQQ,
            from_nickname=ctx.FromNickName,
            from_user_id=ctx.FromUserId,
            from_group_name=ctx.FromGroupName,
            from_group_id=ctx.FromGroupId,
            at_user_id=json.dumps(content["UserID"]) if "UserID" in content else None,
            content=content["Content"] if "Content" in content else None,
            pics=None,
            tips=content["Tips"] if "Tips" in content else None,
            redbag_info=ctx.RedBaginfo,
            msg_time=ctx.MsgTime,
            msg_type=ctx.MsgType,
            msg_seq=ctx.MsgSeq,
            msg_random=ctx.MsgRandom
        ))
    elif ctx.MsgType == 'VoiceMsg':
        content = json.loads(ctx.Content)
        db.insert('group_msg', dict(
            current_qq=ctx.CurrentQQ,
            from_nickname=ctx.FromNickName,
            from_user_id=ctx.FromUserId,
            from_group_name=ctx.FromGroupName,
            from_group_id=ctx.FromGroupId,
            at_user_id=None,
            content=None,
            pics=None,
            tips=content["Tips"] if "Tips" in content else None,
            redbag_info=ctx.RedBaginfo,
            msg_time=ctx.MsgTime,
            msg_type=ctx.MsgType,
            msg_seq=ctx.MsgSeq,
            msg_random=ctx.MsgRandom,
            voice_url=content["Url"] if "Url" in content else None,
        ))
    else:
        print('Unspecified message type')


# friend_msg
def insert_friend_msg(ctx: FriendMsg):
    db = Mysql()
    if ctx.MsgType == 'TextMsg':
        content = ctx.Content
        db.insert('friend_msg', dict(
            current_qq=ctx.CurrentQQ,
            from_user_id=ctx.FromUin,
            content=content,
            pics=None,
            tips=None,
            redbag_info=ctx.RedBaginfo,
            msg_time=int(time.time()),
            msg_type=ctx.MsgType,
            msg_seq=ctx.MsgSeq
        ))
    elif ctx.MsgType == 'PicMsg':
        content = json.loads(ctx.Content)
        pics = []
        if content["Tips"] == '[好友消息-QQ闪照]':
            ret = db.insert('img', dict(
                Path=content['Path'],
                FileMd5=content['FileMd5'],
                FileSize=content['FileSize'],
                ForwordBuf=content['ForwordBuf'],
                ForwordField=content['ForwordField'],
                Url=content['Url'],
            ))
            pics.append(ret)
        else:
            for pic in content["FriendPic"]:
                ret = db.insert('img', dict(
                    # FileId=pic['FileId'],
                    FileMd5=pic['FileMd5'],
                    FileSize=pic['FileSize'],
                    Path=pic['Path'],
                    # ForwordField=pic['ForwordField'],
                    Url=pic['Url'],
                ))
                pics.append(ret)
        db.insert('friend_msg', dict(
            current_qq=ctx.CurrentQQ,
            from_user_id=ctx.FromUin,
            content=content["Content"] if "Content" in content else None,
            pics=json.dumps(pics),
            tips=content["Tips"] if "Tips" in content else None,
            redbag_info=ctx.RedBaginfo,
            msg_time=int(time.time()),
            msg_type=ctx.MsgType,
            msg_seq=ctx.MsgSeq
        ))
    elif ctx.MsgType == 'VoiceMsg':
        content = json.loads(ctx.Content)
        db.insert('friend_msg', dict(
            current_qq=ctx.CurrentQQ,
            from_user_id=ctx.FromUin,
            content=None,
            pics=None,
            tips=content["Tips"] if "Tips" in content else None,
            redbag_info=ctx.RedBaginfo,
            msg_time=int(time.time()),
            msg_type=ctx.MsgType,
            msg_seq=ctx.MsgSeq,
            voice_url=content["Url"]
        ))
    else:
        print('Unspecified message type')

# if __name__ == '__main__':
#     insert_msg()
