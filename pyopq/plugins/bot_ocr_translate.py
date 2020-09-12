# -*- coding:utf-8 -*-

RESOURCES_BASE_PATH = './resources/ocr-translate'

# ==========================================

# 屏蔽群 例：[12345678, 87654321]
blockGroupNumber = []

max_info_length = 341

# 触发命令列表
ocrCommandList = ['OCR', 'ocr', '识图', '转文字', '图片转文字']
translateCommandList = ['翻译']

# 自行到百度 https://ai.baidu.com/tech/ocr/ 申请API
# API_key 为官网获取的AK， Secret_Key 为官网获取的SK
API_key = "pUmwiU9SiR3a973ZBhudo86b"
Secret_Key = "xTQ5sues9xatbI84Z9VRn8oGGFHXFef2"

# 你所选用的API识别接口
API_URL = "https://aip.baidubce.com/rest/2.0/ocr/v1/general_basic"

# ==========================================

import base64
import os
from enum import Enum

import requests
from googletrans import Translator
from iotbot import Action, GroupMsg, FriendMsg

try:
    import ujson as json
except:
    import json

bot = Action(
    qq_or_bot=int(os.getenv('BOTQQ')),
    queue=True,
    queue_delay=0.5
)


# ==========================================

def receive_friend_msg(ctx: FriendMsg):
    if ctx.FromUin == ctx.CurrentQQ:
        return

    userQQ = ctx.FromUin
    msg = ctx.Content

    handlingmessages_friend(msg, bot, userQQ)


def receive_group_msg(ctx: GroupMsg):
    if ctx.FromUserId == ctx.CurrentQQ:
        return

    userGroup = ctx.FromGroupId

    if Tools.commandMatch(userGroup, blockGroupNumber):
        return

    userQQ = ctx.FromUserId
    msg = ctx.Content

    handlingMessages(msg, bot, userGroup, userQQ)


class Model(Enum):
    ALL = '_all'

    BLURRY = '_blurry'

    SEND_AT = '_send_at'

    SEND_DEFAULT = '_send_default'


class Status(Enum):
    SUCCESS = '_success'

    FAILURE = '_failure'


class Tools():

    @staticmethod
    def textOnly(msgType):
        return True if msgType == 'TextMsg' else False

    @staticmethod
    def atOnly(msgType):
        return True if msgType == 'AtMsg' else False

    @staticmethod
    def writeFile(p, content):
        with open(p, 'w', encoding='utf-8') as f:
            f.write(content)

    @staticmethod
    def readFileByLine(p):
        if not os.path.exists(p):
            return Status.FAILURE
        with open(p, 'r', encoding='utf-8') as f:
            return f.readlines()

    @staticmethod
    def readJsonFile(p):
        if not os.path.exists(p):
            return Status.FAILURE
        with open(p, 'r', encoding='utf-8') as f:
            return json.loads(f.read())

    @staticmethod
    def writeJsonFile(p, content):
        with open(p, 'w', encoding='utf-8') as f:
            f.write(json.dumps(content))
        return Status.SUCCESS

    @staticmethod
    def readFileContent(p):
        if not os.path.exists(p):
            return Status.FAILURE
        with open(p, 'r', encoding='utf-8') as f:
            return f.read().strip()

    @staticmethod
    def readPictureFile(picPath):
        if not os.path.exists(picPath):
            return Status.FAILURE
        with open(picPath, 'rb') as f:
            return f.read()

    @classmethod
    def base64conversion(cls, picPath):
        picByte = cls.readPictureFile(picPath)
        if picByte == Status.FAILURE:
            raise Exception('图片文件不存在！')
        return str(base64.b64encode(picByte), encoding='utf-8')

    @classmethod
    def sendPictures(cls, userGroup, picPath, bot, content='', atUser=0):
        bot.send_group_pic_msg(
            toUser=int(userGroup),
            picBase64Buf=cls.base64conversion(picPath),
            atUser=int(atUser),
            content=str(content)
        )

    @staticmethod
    def sendText(userGroup, msg, bot, model=Model.SEND_DEFAULT, atQQ=''):
        if msg != '' and msg != Status.FAILURE:
            if model == Model.SEND_DEFAULT:
                bot.send_group_text_msg(
                    toUser=int(userGroup),
                    content=str(msg)
                )
            if model == Model.SEND_AT:
                if atQQ == '':
                    raise Exception('没有指定 at 的人！')
                at = f'[ATUSER({atQQ})]\n'
                bot.send_group_text_msg(
                    toUser=int(userGroup),
                    content=at + str(msg)
                )

    @staticmethod
    def commandMatch(msg, commandList, model=Model.ALL):
        if model == Model.ALL:
            for c in commandList:
                if c == msg:
                    return True
        if model == Model.BLURRY:
            for c in commandList:
                if msg.find(c) != -1:
                    return True
        return False

    @staticmethod
    def checkFolder(dir):
        if not os.path.exists(dir):
            os.makedirs(dir)

    @staticmethod
    def atQQ(userQQ):
        return f'[ATUSER({userQQ})]\n'

    @staticmethod
    def identifyAt(content):
        try:
            result = json.loads(content)
            return [result['Content'], result['UserID']]
        except:
            return Status.FAILURE

    @staticmethod
    def identifyImgMsg(content):
        try:
            result = json.loads(content)
            return [result['Content'], result['GroupPic'][0]['Url']]
        except:
            return Status.FAILURE

    @staticmethod
    def identifyImgMsg_friend(content):
        try:
            result = json.loads(content)
            return [result['Content'], result['FriendPic'][0]['Url']]
        except:
            return Status.FAILURE


def cut(obj, sec):
    return [obj[i:i + sec] for i in range(0, len(obj), sec)]


def handlingmessages_friend(msg, bot, userQQ):
    params = Tools.identifyImgMsg_friend(msg)
    if params != Status.FAILURE:
        result = Tools.commandMatch(params[0], ocrCommandList, Model.BLURRY)
        if result:
            ocr_re = OCR.imgToText(params[1])
            sendMsg = '识别结果：\n' + ocr_re
            cut_Msgs = cut(sendMsg, max_info_length)
            for cut_Msg in cut_Msgs:
                bot.send_friend_text_msg(userQQ, cut_Msg)
            return
        result = Tools.commandMatch(params[0], translateCommandList, Model.BLURRY)
        if result:
            ocr_re = OCR.imgToText(params[1])
            translator = Translator(service_urls=['translate.google.cn'])
            # dest_lang = ''
            if translator.detect(ocr_re).lang != 'zh-CN':
                dest_lang = 'zh-CN'
            else:
                dest_lang = 'en'
            sendMsg = '翻译结果：\n' + translator.translate(ocr_re, dest=dest_lang).text
            cut_Msgs = cut(sendMsg, max_info_length)
            for cut_Msg in cut_Msgs:
                bot.send_friend_text_msg(userQQ, cut_Msg)


def handlingMessages(msg, bot, userGroup, userQQ):
    params = Tools.identifyImgMsg(msg)
    if params != Status.FAILURE:
        result = Tools.commandMatch(params[0], ocrCommandList, Model.BLURRY)
        if result:
            ocr_re = OCR.imgToText(params[1])
            sendMsg = '识别结果：\n' + ocr_re
            cut_Msgs = cut(sendMsg, max_info_length)
            for cut_Msg in cut_Msgs:
                Tools.sendText(
                    userGroup=userGroup,
                    msg=cut_Msg,
                    bot=bot,
                    model=Model.SEND_AT,
                    atQQ=userQQ)
            return
        result = Tools.commandMatch(params[0], translateCommandList, Model.BLURRY)
        if result:
            ocr_re = OCR.imgToText(params[1])
            translator = Translator(service_urls=['translate.google.cn'])
            # dest_lang = ''
            if translator.detect(ocr_re).lang != 'zh-CN':
                dest_lang = 'zh-CN'
            else:
                dest_lang = 'en'
            sendMsg = '翻译结果：\n' + translator.translate(ocr_re, dest=dest_lang).text
            cut_Msgs = cut(sendMsg, max_info_length)
            for cut_Msg in cut_Msgs:
                Tools.sendText(
                    userGroup=userGroup,
                    msg=cut_Msg,
                    bot=bot,
                    model=Model.SEND_AT,
                    atQQ=userQQ)


class OCR:
    @staticmethod
    def imgToText(image_url):

        global API_key
        global Secret_Key
        global API_URL

        text_result = ""
        # words_result_num = 0

        try:
            host = 'https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id={AK}&client_secret={SK}'.format(
                AK=API_key, SK=Secret_Key)

            access_token = ""
            response = requests.get(host)
            if response:
                access_token = response.json()['access_token']

            params = {"url": image_url}
            request_url = API_URL + "?access_token=" + access_token
            headers = {'content-type': 'application/x-www-form-urlencoded'}
            response = requests.post(request_url, data=params, headers=headers)
            if response:
                json_data = response.json()
                words_result_num = int(json_data['words_result_num'])
                for i in json_data['words_result']:
                    text_result = text_result + i['words'] + "\n"
        except Exception:
            text_result = "识别失败！"
            # words_result_num = -1

        return text_result
