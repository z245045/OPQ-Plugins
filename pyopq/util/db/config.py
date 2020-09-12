# -*- coding:utf-8 -*-

import json


class _config:
    def __init__(self, c: dict) -> None:
        # mysql 配置, 不存在只能为None
        mysql_host = c.get('mysql_host')
        if mysql_host:
            self.mysql_host = str(mysql_host)
        else:
            self.mysql_host = None

        try:
            self.mysql_port = int(c.get('mysql_port'))
        except Exception:
            self.mysql_port = None

        mysql_user = c.get('mysql_user')
        if mysql_user:
            self.mysql_user = str(mysql_user)
        else:
            self.mysql_user = None

        mysql_pass = c.get('mysql_pass')
        if mysql_pass:
            self.mysql_pass = str(mysql_pass)
        else:
            self.mysql_pass = None

        mysql_db = c.get('mysql_db')
        if mysql_db:
            self.mysql_db = str(mysql_db)
        else:
            self.mysql_db = None


config_dict = {}
try:
    with open('./.mysql.json', encoding='utf-8') as f:
        config_dict = json.load(f)
except FileNotFoundError:
    pass
except json.JSONDecodeError as e:
    print('Mysql 数据库配置文件不规范')

config = _config(config_dict)
