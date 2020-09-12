
-- --------------------------------------------------------

--
-- 表的结构 `bot_config`
--

CREATE TABLE `bot_config` (
  `current_qq` bigint(20) NOT NULL,
  `master_qq` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `friend_msg`
--

CREATE TABLE `friend_msg` (
  `current_qq` bigint(20) NOT NULL,
  `from_user_id` bigint(20) NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `pics` text COLLATE utf8mb4_unicode_ci,
  `tips` text COLLATE utf8mb4_unicode_ci,
  `redbag_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `msg_time` bigint(20) NOT NULL,
  `msg_type` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `msg_seq` bigint(20) NOT NULL,
  `voice_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- 表的结构 `group_msg`
--

CREATE TABLE `group_msg` (
  `current_qq` bigint(20) NOT NULL,
  `from_nickname` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `from_user_id` bigint(20) NOT NULL,
  `from_group_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `from_group_id` bigint(20) NOT NULL,
  `at_user_id` text COLLATE utf8mb4_unicode_ci,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `pics` text COLLATE utf8mb4_unicode_ci,
  `tips` text COLLATE utf8mb4_unicode_ci,
  `redbag_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `msg_time` bigint(20) NOT NULL,
  `msg_type` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `msg_seq` bigint(20) NOT NULL,
  `msg_random` bigint(20) NOT NULL,
  `voice_url` text COLLATE utf8mb4_unicode_ci,
  `is_revoke` tinyint(1) DEFAULT '0',
  `revoke_AdminUserID` bigint(20) DEFAULT NULL,
  `revoke_UserID` bigint(20) DEFAULT NULL,
  `revoke_time` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- 表的结构 `img`
--

CREATE TABLE `img` (
  `FileId` bigint(20) NOT NULL,
  `FileMd5` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `FileSize` bigint(20) NOT NULL,
  `ForwordBuf` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `ForwordField` bigint(20) DEFAULT NULL,
  `Url` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `Path` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- 表的结构 `memberlist`
--

CREATE TABLE `memberlist` (
  `GroupUin` bigint(20) NOT NULL,
  `LastUin` bigint(20) NOT NULL,
  `Count` bigint(20) NOT NULL,
  `Age` int(11) NOT NULL,
  `AutoRemark` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `CreditLevel` int(11) NOT NULL DEFAULT '0',
  `Email` varchar(100) DEFAULT NULL,
  `FaceId` bigint(20) NOT NULL,
  `Gender` int(11) NOT NULL DEFAULT '0',
  `GroupAdmin` int(11) NOT NULL DEFAULT '0',
  `GroupCard` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `JoinTime` bigint(20) NOT NULL,
  `LastSpeakTime` bigint(20) NOT NULL,
  `MemberLevel` int(11) NOT NULL,
  `MemberUin` bigint(20) NOT NULL,
  `Memo` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `NickName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ShowName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `SpecialTitle` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Status` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `trooplist`
--

CREATE TABLE `trooplist` (
  `GroupId` bigint(20) NOT NULL,
  `GroupMemberCount` bigint(20) NOT NULL,
  `GroupName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `GroupNotice` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `GroupOwner` bigint(20) NOT NULL,
  `GroupTotalCount` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 转储表的索引
--

--
-- 表的索引 `bot_config`
--
ALTER TABLE `bot_config`
  ADD PRIMARY KEY (`current_qq`);

--
-- 表的索引 `friend_msg`
--
ALTER TABLE `friend_msg`
  ADD PRIMARY KEY (`current_qq`,`from_user_id`,`msg_seq`);

--
-- 表的索引 `group_msg`
--
ALTER TABLE `group_msg`
  ADD PRIMARY KEY (`current_qq`,`from_user_id`,`from_group_id`,`msg_seq`);

--
-- 表的索引 `img`
--
ALTER TABLE `img`
  ADD PRIMARY KEY (`FileId`);

--
-- 表的索引 `memberlist`
--
ALTER TABLE `memberlist`
  ADD PRIMARY KEY (`GroupUin`,`MemberUin`);

--
-- 表的索引 `trooplist`
--
ALTER TABLE `trooplist`
  ADD PRIMARY KEY (`GroupId`);

--
-- 在导出的表使用AUTO_INCREMENT
--

--
-- 使用表AUTO_INCREMENT `bot_config`
--
ALTER TABLE `bot_config`
  MODIFY `current_qq` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `img`
--
ALTER TABLE `img`
  MODIFY `FileId` bigint(20) NOT NULL AUTO_INCREMENT;
COMMIT;
