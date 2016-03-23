use hustOA
/*
	强磁场OA系统-邮件管理表设计
	author:		卢苇
	CreateDate:	2012-12-30
	UpdateDate:
				
*/
--1.绑定邮箱列表：
select * from mailBindOption
drop TABLE mailBindOption
CREATE TABLE mailBindOption(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号
	mailerID varchar(10) not null,			--主键：邮件管理人工号
	mailServer varchar(128) not null default('imap.163.com'),	--邮箱服务器
	mailServerPort int default(143),		--绑定邮箱服务器端口:163邮箱不使用SSL加密的端口号是143，使用SSL加密的端口号是993.
	mailAddr varchar(60) not null,			--主键：邮箱地址（绑定邮箱的登录账号），采用"lw_bk@163.com"方式
	loginPSW varchar(128) null,				--登录密码：使用AES128位加密算法加密
	usedSSL smallint default(0),			--是否使用SSL加密:0->不使用，1->使用
	SMTPServer varchar(128) null,			--smtp发送邮件服务器名称
	SMTPUsedSSL smallint default(0),		--smtp服务器是否使用SSL加密:0->不使用，1->使用
	isDefaultSMTP smallint default(0),		--是否为默认的SMTP邮箱（该邮箱将用来发送邮件）：0->是，1->否
	--以下是IMAP协议对应的服务器文件夹：
	inBoxFolder nvarchar(30) null,			--收件箱文件夹名称
	outBoxFolder nvarchar(30) null,			--发件箱文件夹名称
	sketchBoxFolder nvarchar(30) null,		--草稿箱文件夹名称
	trashBoxFolder nvarchar(30) null,		--垃圾邮件存放文件夹
	deletedBoxFolder nvarchar(30) null,		--已删除邮件存放文件夹
	adBoxFolder nvarchar(30) null,			--广告邮件存放文件夹
	subscribeBoxFolder nvarchar(30) null,	--订阅邮件存放文件夹

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_mailBindOption] PRIMARY KEY CLUSTERED 
(
	[mailerID] ASC,
	[mailAddr] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--以下表的管理没有设计锁，使用中如果防止并发请使用mailBindOption的锁操作！
--2.邮件列表：
drop TABLE mailList
CREATE TABLE mailList(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号
	mailerID varchar(10) not null,		--邮件管理人工号
	mailAddr varchar(60) not null,		--主键：来源邮箱，采用"lw_bk@163.com"方式
	folder nvarchar(128) not null,		--邮箱目录
	--以下为邮件的概要信息：
	messageNum int not null,			--在指定邮箱内邮件文件夹内的邮件编号:要始终保证是从1:*
	messageID varchar(128) not null,	--主键：在指定邮箱内邮件的唯一标识(UID)
	/*改用子表描述：del by lw 2013-3-30
	mailFrom xml null,					--邮件来源：可能有多个地址，采用<root><from>地址1</from><from>地址2</from>...</root>方式存放
	mailTo xml null,					--发送到：可能有多个地址，采用<root><to>地址1</to><to>地址2</to>...</root>方式存放
	*/
	mailSubject nvarchar(300) null,		--邮件主题
	mailReceivedTime datetime null,		--邮件接收到时间：指到达服务器时间
	mailSize int null,					--邮件大小
	--邮件标记：add by lw 2013-2-15
    isSeen smallint default(0),			--是否阅读：0->未阅读，1->已阅读
	isAnswered smallint default(0),		--是否回复：0->未回复，1->已回复
	isFlagged smallint default(0),		--是否标记：0->未标记，1->已标记
	isRecent smallint default(0),		--是否最近到达：0->否，1->是
	haveAttach smallint default(0),		--是否有附件：0->无，1->有
	isDeleted smallint default(0),		--是否删除：0->未删除，1->已删除
	isDraft smallint default(0),		--是否草稿：0->正式邮件，1->草稿
	
 CONSTRAINT [PK_mailList] PRIMARY KEY CLUSTERED
(
	[mailAddr] ASC,
	[folder] ASC,
	[messageID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--日期索引：
CREATE NONCLUSTERED INDEX [IX_mailList] ON [dbo].[mailList]
(
	[mailReceivedTime] DESC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--目录索引：
CREATE NONCLUSTERED INDEX [IX_mailList_1] ON [dbo].[mailList]
(
	[mailerID] ASC,
	[mailAddr] ASC,
	[folder] ASC,
	[messageID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
select * from mailList 
where mailAddr+folder+messageID in (
	select mailAddr+folder+messageID from mailAddrList where name like '%卢苇%' and fromCCOrTo = 1
)
select * from mailAddrList
--2.1邮件地址列表：本表中存储的是邮件来源或发送到的地址信息
--add by lw 2013-3-30
drop TABLE mailAddrList
CREATE TABLE mailAddrList(
	rowNum int IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,
	mailAddr varchar(60) not null,		--主键/外键：来源邮箱，采用"lw_bk@163.com"方式
	folder nvarchar(128) not null,		--邮箱目录
	messageID varchar(128) not null,	--主键/外键：在指定邮箱内邮件的唯一标识(UID)
	name nvarchar(30) null,				--邮件地址人名
	eMailAddr varchar(128) not null,	--主键:邮件地址
	fromCCOrTo smallint default(0),		--所在邮件信封结构的字段：0->不明，1->From，2->To，3->CC
 CONSTRAINT [PK_mailAddrList] PRIMARY KEY CLUSTERED 
(
	[mailAddr] ASC,
	[folder] ASC,
	[messageID] ASC,
	[rowNum] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--外键：
ALTER TABLE [dbo].[mailAddrList] WITH CHECK ADD CONSTRAINT [FK_mailAddrList_mailList] FOREIGN KEY([mailAddr],[folder],[messageID])
REFERENCES [dbo].[mailList] ([mailAddr],[folder],[messageID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[mailAddrList] CHECK CONSTRAINT [FK_mailAddrList_mailList]
GO

--姓名索引：
CREATE NONCLUSTERED INDEX [IX_mailAddrList] ON [dbo].[mailAddrList]
(
	[name] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--3.草稿箱（本地邮件保存表）：因为邮件只有本人才能编辑，所以没有提供编辑锁！
--add by lw 2013-3-31
select * from mailInfo where mailerID='G201300040'
drop TABLE mailInfo
CREATE TABLE mailInfo(
	messageID int IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,
	mailerID varchar(10) not null,		--邮件书写人工号
	mFrom xml,							--发送邮箱：这是为了以后扩展而设计的可保存多个邮箱
										/*可能有多个地址，采用<root>
																	<row><name>张三</name><eMailAddr>地址1</eMailAddr></row>
																	<row><name>李四</name><eMailAddr>地址2</eMailAddr></row>
																	...
																</root>方式存放
										*/
	mTo xml null,						--发送至
										/*可能有多个地址，采用<root>
																	<row><name>张三</name><eMailAddr>地址1</eMailAddr></row>
																	<row><name>李四</name><eMailAddr>地址2</eMailAddr></row>
																	...
																</root>方式存放
										*/
	mSubject nvarchar(1000) null,		--邮件主题
	mBody nvarchar(max) null,			--邮件主体
	AttachFiles nvarchar(1000) null,	--邮件附件（序列化后的字符串）
	mCC xml null,						--抄送
										/*可能有多个地址，采用<root>
																	<row><name>张三</name><eMailAddr>地址1</eMailAddr></row>
																	<row><name>李四</name><eMailAddr>地址2</eMailAddr></row>
																	...
																</root>方式存放
										*/
	saveTime smalldatetime default(getdate())	--保存时间
 CONSTRAINT [PK_mailInfo] PRIMARY KEY CLUSTERED 
(
	[mailerID] ASC,
	[messageID] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

select messageID, mailerID, mFrom, mTo, mSubject, mBody, AttachFiles, mCC, convert(varchar(19),saveTime,120) saveTime
from mailInfo


--4.个性化签名信息表：
drop TABLE signInfo
CREATE TABLE signInfo(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号
	mailerID varchar(10) not null,		--邮件管理人工号
	signName nvarchar(20) not null,		--签名的名字
	signBody nvarchar(4000) null,		--签名设计的HTML

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_signInfo] PRIMARY KEY CLUSTERED 
(
	[mailerID] ASC,
	[signName] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--5.常用联系人分组表：
drop TABLE contactsGroup
CREATE TABLE contactsGroup(
	groupID int IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,	--主键：分组号
	mailerID varchar(10) not null,		--主键:邮件管理人工号
	groupName nvarchar(30) null,	--分组名称
	notes nvarchar(300) null,		--备注
	createTime smalldatetime default(getdate())	--创建时间
 CONSTRAINT [PK_contactsGroup] PRIMARY KEY CLUSTERED 
(
	[mailerID] ASC,
	[groupID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


--5.1.常用联系人表：
drop TABLE mailContacts
CREATE TABLE mailContacts(
	groupID int default(0),				--分组号：这里没有强制连接到分组表，允许联系人不在预定义的分组中.0表示没有分组
	groupName nvarchar(30) null,		--冗余设计：分组名称
	mailerID varchar(10) not null,		--主键:邮件管理人工号
	eMailAddr varchar(128) not null,	--主键:邮件地址
	mailerName nvarchar(30) null,		--邮件地址人名
	isShared smallint default(0),		--是否分享：0->不分享，1->分享
	createrID varchar(10) null,			--创建人工号
	creater nvarchar(30) null,			--创建人
	createTime smalldatetime default(getdate())	--创建时间
 CONSTRAINT [PK_mailContacts] PRIMARY KEY CLUSTERED 
(
	[mailerID] ASC,
	[eMailAddr] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--分组索引：
CREATE NONCLUSTERED INDEX [IX_mailContacts] ON [dbo].[mailContacts]
(
	[groupName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--是否分享索引：
CREATE NONCLUSTERED INDEX [IX_mailContacts_1] ON [dbo].[mailContacts]
(
	[isShared] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


drop PROCEDURE checkMailAddr
/*
	name:		checkMailAddr
	function:	0.检查指定的邮箱地址是否已经存在
	input: 
				@rowNum int,			--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
				@mailAddr varchar(60),	--邮箱地址（绑定邮箱的登录账号），采用"lw_bk@163.com"方式
	output: 
				@Ret		int output		--操作成功标识
							0:不存在，>1：存在，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE checkMailAddr
	@rowNum int,			--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
	@mailAddr varchar(60),	--邮箱地址（绑定邮箱的登录账号），采用"lw_bk@163.com"方式
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	declare @count int
	set @count = (select count(*) from mailBindOption where mailAddr = @mailAddr and rowNum <> @rowNum)
	set @Ret = @count
GO

drop PROCEDURE queryMailBindOptionLocMan
/*
	name:		queryMailBindOptionLocMan
	function:	1.查询指定的邮箱是否有人正在编辑
	input: 
				@mailAddr varchar(60),			--邮箱地址（绑定邮箱的登录账号），采用"lw_bk@163.com"方式
	output: 
				@Ret		int output			--操作成功标识
							0:成功，9：查询出错，可能是指定的邮箱不存在
				@lockManID varchar(10) output	--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2012-12-30
	UpdateDate: 
*/
create PROCEDURE queryMailBindOptionLocMan
	@mailAddr varchar(60),			--邮箱地址（绑定邮箱的登录账号），采用"lw_bk@163.com"方式
	@Ret int output,				--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from mailBindOption where mailAddr = @mailAddr),'')
	set @Ret = 0
GO


drop PROCEDURE lockMailBindOption4Edit
/*
	name:		lockMailBindOption4Edit
	function:	2.锁定邮箱编辑，避免编辑冲突
	input: 
				@rowNum int,					--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号
				@lockManID varchar(10) output,	--锁定人，如果当前邮箱正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：要锁定的邮箱不存在，2:要锁定的邮箱正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-12-30
	UpdateDate: 
*/
create PROCEDURE lockMailBindOption4Edit
	@rowNum int,					--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号
	@lockManID varchar(10) output,	--锁定人，如果当前邮箱正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的邮箱是否存在
	declare @count as int
	set @count=(select count(*) from mailBindOption where rowNum = @rowNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from mailBindOption where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update mailBindOption 
	set lockManID = @lockManID 
	where rowNum = @rowNum

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定邮箱编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了第['+str(@rowNum)+']号邮箱为独占式编辑。')
GO

drop PROCEDURE unlockMailBindOptionEditor
/*
	name:		unlockMailBindOptionEditor
	function:	3.释放邮箱编辑锁
				注意：这是给编辑绑定邮箱使用的过程，本过程不检查邮箱参数是否存在！
	input: 
				@rowNum int,					--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号
				@lockManID varchar(10) output,	--锁定人，如果当前邮箱正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-30
	UpdateDate: 
*/
create PROCEDURE unlockMailBindOptionEditor
	@rowNum int,					--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号
	@lockManID varchar(10) output,	--锁定人，如果当前邮箱正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from mailBindOption where rowNum = @rowNum),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update mailBindOption  set lockManID = '' where rowNum = @rowNum
	end
	else
	begin
		set @Ret = 0
		return
	end
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '释放邮箱编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了第['+str(@rowNum)+']号邮箱的编辑锁。')
GO

drop PROCEDURE addMailBindOption
/*
	name:		addMailBindOption
	function:	4.添加绑定邮箱
	input: 
				@mailerID varchar(10),			--主键：邮件管理人工号
				@mailServer varchar(128),		--主键：绑定邮箱服务器
				@mailServerPort int,			--绑定邮箱服务器端口:163邮箱不使用SSL加密的端口号是143，使用SSL加密的端口号是993.
				@mailAddr varchar(60),			--主键：邮箱地址（绑定邮箱的登录账号），采用"lw_bk@163.com"方式
				@loginPSW varchar(128),			--登录密码：使用AES128位加密算法加密
				@usedSSL smallint,				--是否使用SSL加密:0->不使用，1->使用
				@SMTPServer varchar(128),		--smtp发送邮件服务器名称
				@SMTPUsedSSL smallint,			--smtp服务器是否使用SSL加密:0->不使用，1->使用
				--以下是IMAP协议对应的服务器文件夹：
				@inBoxFolder nvarchar(128),		--收件箱文件夹名称
				@outBoxFolder nvarchar(128),	--发件箱文件夹名称
				@sketchBoxFolder nvarchar(128),	--草稿箱文件夹名称
				@trashBoxFolder nvarchar(128),	--垃圾邮件存放文件夹
				@deletedBoxFolder nvarchar(128),--已删除邮件存放文件夹
				@adBoxFolder nvarchar(128),		--广告邮件存放文件夹
				@subscribeBoxFolder nvarchar(128),	--订阅邮件存放文件夹

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output			--操作成功标识：0:成功，9:未知错误
				@createTime smalldatetime output--添加时间
	author:		卢苇
	CreateDate:	2012-12-30
	UpdateDate: modi by lw 2013-1-27增加SMTP服务器参数
*/
create PROCEDURE addMailBindOption
	@mailerID varchar(10),			--主键：邮件管理人工号
	@mailServer varchar(128),		--主键：绑定邮箱服务器
	@mailServerPort int,			--绑定邮箱服务器端口:163邮箱不使用SSL加密的端口号是143，使用SSL加密的端口号是993.
	@mailAddr varchar(60),			--主键：邮箱地址（绑定邮箱的登录账号），采用"lw_bk@163.com"方式
	@loginPSW varchar(128),			--登录密码：使用AES128位加密算法加密
	@usedSSL smallint,				--是否使用SSL加密:0->不使用，1->使用
	@SMTPServer varchar(128),		--smtp发送邮件服务器名称
	@SMTPUsedSSL smallint,			--smtp服务器是否使用SSL加密:0->不使用，1->使用
	--以下是IMAP协议对应的服务器文件夹：
	@inBoxFolder nvarchar(128),		--收件箱文件夹名称
	@outBoxFolder nvarchar(128),	--发件箱文件夹名称
	@sketchBoxFolder nvarchar(128),	--草稿箱文件夹名称
	@trashBoxFolder nvarchar(128),	--垃圾邮件存放文件夹
	@deletedBoxFolder nvarchar(128),--已删除邮件存放文件夹
	@adBoxFolder nvarchar(128),		--广告邮件存放文件夹
	@subscribeBoxFolder nvarchar(128),	--订阅邮件存放文件夹

	@createManID varchar(10),		--创建人工号
	@Ret		int output,
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--取创建人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert mailBindOption(mailerID, mailServer, mailServerPort, mailAddr, loginPSW, usedSSL,
							SMTPServer, SMTPUsedSSL,
							--以下是IMAP协议对应的服务器文件夹：
							inBoxFolder, outBoxFolder, sketchBoxFolder, trashBoxFolder,
							deletedBoxFolder, adBoxFolder, subscribeBoxFolder,
							--最新维护情况:
							modiManID, modiManName, modiTime)
	values(@mailerID, @mailServer, @mailServerPort, @mailAddr, @loginPSW, @usedSSL,
					@SMTPServer, @SMTPUsedSSL,
					--以下是IMAP协议对应的服务器文件夹：
					@inBoxFolder, @outBoxFolder, @sketchBoxFolder, @trashBoxFolder,
					@deletedBoxFolder, @adBoxFolder, @subscribeBoxFolder,
					--最新维护情况:
					@createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '绑定邮箱', '系统根据用户' + @createManName + 
					'的要求绑定了邮箱['+@mailAddr+']。')
GO
--测试:
declare	@Ret		int
declare	@createTime smalldatetime
select * from userInfo

drop PROCEDURE setDefaultSMTP
/*
	name:		setDefaultSMTP
	function:	4.1.将指定的邮箱设置为SMTP默认的服务器
	input: 
				@mailAddr varchar(60),		--主键：邮箱地址（绑定邮箱的登录账号），采用"lw_bk@163.com"方式

				@modiManID varchar(10) output,	--修改人工号：如果当前邮箱正有人编辑锁定，则返回锁定人工号
	output: 
				@Ret		int output		--操作成功标识：0:成功，
											1:要修改的邮箱不存在，
											2:要修改的邮箱正被别人锁定编辑，
											9:未知错误
	author:		卢苇
	CreateDate:	2013-1-27
	UpdateDate: 
*/
create PROCEDURE setDefaultSMTP
	@mailAddr varchar(60),		--邮箱地址（绑定邮箱的登录账号），采用"lw_bk@163.com"方式

	@modiManID varchar(10) output,	--修改人工号：如果当前邮箱正有人编辑锁定，则返回锁定人工号
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的邮箱是否存在
	declare @count as int
	set @count=(select count(*) from mailBindOption where mailAddr = @mailAddr)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from mailBindOption where mailAddr = @mailAddr),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--获取邮箱对应的邮件人工号：
	declare @mailerID varchar(10)
	set @mailerID = (select top 1 mailerID from mailBindOption where mailAddr = @mailAddr)

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	declare @modiTime smalldatetime
	set @modiTime = getdate()
	begin tran 
		update mailBindOption
		set isDefaultSMTP = 0
		where mailerID = @mailerID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		update mailBindOption
		set isDefaultSMTP = 1,
			--最新维护情况:
			modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
		where mailAddr = @mailAddr
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
	commit tran
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '设置默认发件箱', '系统根据用户' + @modiManName + 
					'的要求将['+@mailerID+']的['+@mailAddr+']邮箱设置为默认的发件箱。')
GO

drop PROCEDURE updateMailBindOption
/*
	name:		updateMailBindOption
	function:	5.修改邮箱参数
	input: 
				@rowNum int,					--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号
				@mailerID varchar(10),			--主键：邮件管理人工号
				@mailServer varchar(128),		--主键：绑定邮箱服务器
				@mailServerPort int,			--绑定邮箱服务器端口:163邮箱不使用SSL加密的端口号是143，使用SSL加密的端口号是993.
				@mailAddr varchar(60),			--主键：邮箱地址（绑定邮箱的登录账号），采用"lw_bk@163.com"方式
				@loginPSW varchar(128),			--登录密码：使用AES128位加密算法加密
				@usedSSL smallint,				--是否使用SSL加密:0->不使用，1->使用
				@SMTPServer varchar(128),		--smtp发送邮件服务器名称
				@SMTPUsedSSL smallint,			--smtp服务器是否使用SSL加密:0->不使用，1->使用
				--以下是IMAP协议对应的服务器文件夹：
				@inBoxFolder nvarchar(128),		--收件箱文件夹名称
				@outBoxFolder nvarchar(128),	--发件箱文件夹名称
				@sketchBoxFolder nvarchar(128),	--草稿箱文件夹名称
				@trashBoxFolder nvarchar(128),	--垃圾邮件存放文件夹
				@deletedBoxFolder nvarchar(128),--已删除邮件存放文件夹
				@adBoxFolder nvarchar(128),		--广告邮件存放文件夹
				@subscribeBoxFolder nvarchar(128),	--订阅邮件存放文件夹

				@modiManID varchar(10) output,	--修改人工号：如果当前邮箱正有人编辑锁定，则返回锁定人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:要修改的邮箱不存在，
							2:要修改的邮箱正被别人锁定编辑，
							9:未知错误
				@modiTime smalldatetime output	--添加时间
	author:		卢苇
	CreateDate:	2012-12-30
	UpdateDate: 
*/
create PROCEDURE updateMailBindOption
	@rowNum int,					--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号
	@mailerID varchar(10),			--主键：邮件管理人工号
	@mailServer varchar(128),		--主键：绑定邮箱服务器
	@mailServerPort int,			--绑定邮箱服务器端口:163邮箱不使用SSL加密的端口号是143，使用SSL加密的端口号是993.
	@mailAddr varchar(60),			--主键：邮箱地址（绑定邮箱的登录账号），采用"lw_bk@163.com"方式
	@loginPSW varchar(128),			--登录密码：使用AES128位加密算法加密
	@usedSSL smallint,				--是否使用SSL加密:0->不使用，1->使用
	@SMTPServer varchar(128),		--smtp发送邮件服务器名称
	@SMTPUsedSSL smallint,			--smtp服务器是否使用SSL加密:0->不使用，1->使用
	--以下是IMAP协议对应的服务器文件夹：
	@inBoxFolder nvarchar(128),		--收件箱文件夹名称
	@outBoxFolder nvarchar(128),	--发件箱文件夹名称
	@sketchBoxFolder nvarchar(128),	--草稿箱文件夹名称
	@trashBoxFolder nvarchar(128),	--垃圾邮件存放文件夹
	@deletedBoxFolder nvarchar(128),--已删除邮件存放文件夹
	@adBoxFolder nvarchar(128),		--广告邮件存放文件夹
	@subscribeBoxFolder nvarchar(128),	--订阅邮件存放文件夹

	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的邮箱是否存在
	declare @count as int
	set @count=(select count(*) from mailBindOption where rowNum = @rowNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from mailBindOption where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	update mailBindOption
	set mailerID = @mailerID, mailServer = @mailServer, mailServerPort = @mailServerPort, mailAddr = @mailAddr,
		loginPSW = @loginPSW, usedSSL = @usedSSL,
		SMTPServer = @SMTPServer, SMTPUsedSSL = @SMTPUsedSSL,
		--以下是IMAP协议对应的服务器文件夹：
		inBoxFolder = @inBoxFolder, outBoxFolder = @outBoxFolder, 
		sketchBoxFolder = @sketchBoxFolder, trashBoxFolder = @trashBoxFolder,
		deletedBoxFolder = @deletedBoxFolder, adBoxFolder = @adBoxFolder, subscribeBoxFolder = @subscribeBoxFolder,
		--最新维护情况:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where rowNum = @rowNum
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '修改邮箱参数', '系统根据用户' + @modiManName + 
					'的要求修改了['+@mailerID+']的第['+str(@rowNum)+']号邮箱的参数]”。')
GO
--测试:
declare	@Ret		int
declare	@modiTime smalldatetime
exec dbo.updateMailBindOption 10,'00006745','imap.163.com',143,'wyfttp@163.com','13507236429',0,
	'草稿箱','草稿箱','已发送','已发送','已发送','已发送','已发送','00006745',@Ret output,@modiTime output
	
select @Ret

select * from mailBindOption

drop PROCEDURE delMailBindOption
/*
	name:		delMailBindOption
	function:	6.删除指定的邮箱
	input: 
				@rowNum int,					--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号
				@delManID varchar(10) output,	--删除人，如果当前邮箱正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的邮箱不存在，2：要删除的邮箱正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-30
	UpdateDate: 

*/
create PROCEDURE delMailBindOption
	@rowNum int,					--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号
	@delManID varchar(10) output,	--删除人，如果当前邮箱正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要删除的邮箱是否存在
	declare @count as int
	set @count=(select count(*) from mailBindOption where rowNum = @rowNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @mailAddr varchar(60)			--主键：邮箱地址（绑定邮箱的登录账号），采用"lw_bk@163.com"方式
	select @thisLockMan = isnull(lockManID,''), @mailAddr = mailAddr from mailBindOption where rowNum = @rowNum
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete mailBindOption where mailAddr = @mailAddr
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除邮箱', '用户' + @delManName
												+ '删除了邮箱['+@mailAddr+']。')

GO

drop PROCEDURE addMailInfo
/*
	name:		addMailInfo
	function:	7.添加邮件概要信息
	input: 
				@mailAddr varchar(60),		--主键：来源邮箱，采用"lw_bk@163.com"方式
				@folder nvarchar(30),		--邮件文件夹
				--以下为邮件的概要信息：
				@messageNum int,			--在指定邮箱内邮件文件夹内的邮件编号:要始终保证是从1:*,该参数需要与服务器同步，所以暂时未启用
				@messageID varchar(128),	--主键：在指定邮箱内邮件的唯一标识(UID)
				@mailFrom xml,				--邮件来源：可能有多个地址，采用<root>
																				<row><name>张三</name><eMailAddr>地址1</eMailAddr></row>
																				<row><name>李四</name><eMailAddr>地址2</eMailAddr></row>
																				...
																			</root>方式存放
				@mailTo xml,				--发送到：可能有多个地址，采用<root>
																				<row><name>张三</name><eMailAddr>地址1</eMailAddr></row>
																				<row><name>李四</name><eMailAddr>地址2</eMailAddr></row>
																				...
																			</root>方式存放
				@mailSubject nvarchar(300),	--邮件主题
				@mailReceivedTime varchar(19),--邮件接收到时间：指到达服务器时间
				@mailSize int,				--邮件大小
				@isSeen smallint,			--是否阅读：0->未阅读，1->已阅读
				@isAnswered smallint,		--是否回复：0->未回复，1->已回复
				@isFlagged smallint,		--是否标记：0->未标记，1->已标记
				@isRecent smallint,			--是否最近到达：0->否，1->是
				@haveAttach smallint,		--是否有附件：0->无，1->有
				@isDeleted smallint,		--是否删除：0->未删除，1->已删除
				@isDraft smallint,			--是否草稿：0->正式邮件，1->草稿
	output: 
				@Ret		int output			--操作成功标识0:成功，1:该邮件已存在，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-30
	UpdateDate: modi by lw 2013-1-27简化接口
				modi by lw 2013-2-18增加邮件标记
				modi by lw 2013-3-30修改收件人和发件人为从表结构！
*/
create PROCEDURE addMailInfo
	@mailAddr varchar(60),		--主键：来源邮箱，采用"lw_bk@163.com"方式
	@folder nvarchar(30),		--邮件文件夹
	--以下为邮件的概要信息：
	@messageNum int,			--在指定邮箱内邮件文件夹内的邮件编号:要始终保证是从1:*
	@messageID varchar(128),	--主键：在指定邮箱内邮件的唯一标识(UID)
	@mailFrom xml,				/*邮件来源：可能有多个地址，采用<root>
																	<row><name>张三</name><eMailAddr>地址1</eMailAddr></row>
																	<row><name>李四</name><eMailAddr>地址2</eMailAddr></row>
																	...
																</root>方式存放*/
	@mailTo xml,				/*发送到：可能有多个地址，采用<root>
																	<row><name>张三</name><eMailAddr>地址1</eMailAddr></row>
																	<row><name>李四</name><eMailAddr>地址2</eMailAddr></row>
																	...
																</root>方式存放*/
	@mailSubject nvarchar(300),	--邮件主题
	@mailReceivedTime  varchar(19),--邮件接收到时间：指到达服务器时间
	@mailSize int,				--邮件大小
	@isSeen smallint,			--是否阅读：0->未阅读，1->已阅读
	@isAnswered smallint,		--是否回复：0->未回复，1->已回复
	@isFlagged smallint,		--是否标记：0->未标记，1->已标记
	@isRecent smallint,			--是否最近到达：0->否，1->是
	@haveAttach smallint,		--是否有附件：0->无，1->有
	@isDeleted smallint,		--是否删除：0->未删除，1->已删除
	@isDraft smallint,			--是否草稿：0->正式邮件，1->草稿

	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--获取邮件所有人工号：
	declare @mailerID varchar(10)
	set @mailerID = (select mailerID from mailBindOption where mailAddr = @mailAddr)
	
	declare @count int
	set @count = (select count(*) from mailList where mailAddr = @mailAddr and folder = @folder and messageID = @messageID)
	if (@count>0)
	begin
		set @Ret = 1
		return
	end
	begin tran
		insert mailList(mailerID, mailAddr, folder, messageNum, messageID, 
						mailSubject, mailReceivedTime, mailSize,
						isSeen, isAnswered, isFlagged, isRecent, haveAttach, isDeleted, isDraft)
		values(@mailerID, @mailAddr, @folder, @messageNum, @messageID, 
				@mailSubject, @mailReceivedTime, @mailSize,
				@isSeen, @isAnswered, @isFlagged, @isRecent, @haveAttach, @isDeleted, @isDraft)
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		print '1'
		--插入邮件来源列表：--fromCCOrTo所在邮件信封结构的字段：0->不明，1->From，2->To，3->CC
		insert mailAddrList(mailAddr, folder, messageID, name, eMailAddr, fromCCOrTo) 
		select @mailAddr, @folder, @messageID, cast(T.x.query('data(./name)') as nvarchar(30)) name, 
				cast(T.x.query('data(./eMailAddr)') as varchar(128)) eMailAddr,1
		from(select @mailFrom.query('/root/row') Col1) A
			OUTER APPLY A.Col1.nodes('/row') AS T(x)
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		print '2'
		--插入邮件发送到列表：--fromCCOrTo所在邮件信封结构的字段：0->不明，1->From，2->To，3->CC
		insert mailAddrList(mailAddr, folder, messageID, name, eMailAddr, fromCCOrTo) 
		select @mailAddr, @folder, @messageID, cast(T.x.query('data(./name)') as nvarchar(30)) name, 
				cast(T.x.query('data(./eMailAddr)') as varchar(128)) eMailAddr,2
		from(select @mailTo.query('/root/row') Col1) A
			OUTER APPLY A.Col1.nodes('/row') AS T(x)
		if @@ERROR <> 0 
		begin
print @@ERROR		
			rollback tran
			set @Ret = 9
			return
		end
		print '3'
	commit tran
	set @Ret = 0

GO
declare @mailFrom xml
set @mailFrom = N'<root><row><name></name><eMailAddr>lw_bk@163.com</eMailAddr></row></root>'
		select cast(T.x.query('data(./name)') as nvarchar(30)) name, 
				cast(T.x.query('data(./eMailAddr)') as varchar(128)) eMailAddr
		from(select @mailFrom.query('/root/row') Col1) A
			OUTER APPLY A.Col1.nodes('/row') AS T(x)

select * from mailList
select * from mailAddrList
delete mailList

declare	@Ret		int --操作成功标识
exec dbo.addMailInfo 'lw_bk@163.com','INBOX',2159,'1320997306',
'<root><row><name>s</name><eMailAddr>lw_bk@163.com</eMailAddr></row></root>',
'<root><row><name>卢苇</name><eMailAddr>lw_bk@162.com</eMailAddr></row></root>',
'Hello','2013-03-31 01:00:00',888,0,0,0,1,1,0,0,@Ret output
select @Ret
select * from mailAddrList where messageID=''

select * from mailBindOption 
insert mailList(mailerID, mailAddr, folder, messageNum, messageID, 
				mailSubject, mailReceivedTime, mailSize,
				isSeen, isAnswered, isFlagged, isRecent, haveAttach, isDeleted, isDraft)
values('G201300040','lw_bk@163.com','INBOX',2159,'1320997305',
'Hello','2013-03-31 01:00:00',888,0,0,0,1,1,0,0)

select * from mailList where messageID='1320997249'
select mailerID from mailBindOption where mailAddr='lw_bk@163.com'


drop PROCEDURE delMailInfo
/*
	name:		delMailInfo
	function:	8.删除邮件概要信息
				注：该过程应该维护messageNum字段（在指定邮箱内邮件文件夹内的邮件编号:要始终保证是从1:*,该参数需要与服务器同步，但现则未维护），
	input: 
				@mailAddr varchar(60),		--主键：来源邮箱，采用"lw_bk@163.com"方式
				@folder nvarchar(30),		--邮件文件夹
				@messageID varchar(128),	--主键：在指定邮箱内邮件的唯一标识(UID)
	output: 
				@Ret		int output			--操作成功标识0:成功，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-30
	UpdateDate: modi by lw 2013-1-27简化接口

*/
create PROCEDURE delMailInfo
	@mailAddr varchar(60),		--主键：来源邮箱，采用"lw_bk@163.com"方式
	@folder nvarchar(30),		--邮件文件夹
	@messageID varchar(128),	--主键：在指定邮箱内邮件的唯一标识(UID)

	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	delete mailList where mailAddr = @mailAddr and folder = @folder and messageID = @messageID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
GO


drop PROCEDURE setMailInfoSeen
/*
	name:		setMailInfoSeen
	function:	10.将邮件设置为已读
	input: 
				@mailAddr varchar(60),		--主键：来源邮箱，采用"lw_bk@163.com"方式
				@folder nvarchar(30),		--邮件文件夹
				@messageID varchar(128),	--主键：在指定邮箱内邮件的唯一标识(UID)
	output: 
				@Ret		int output			--操作成功标识0:成功，9：未知错误
	author:		卢苇
	CreateDate:	2013-2-18
	UpdateDate: 

*/
create PROCEDURE setMailInfoSeen
	@mailAddr varchar(60),		--主键：来源邮箱，采用"lw_bk@163.com"方式
	@folder nvarchar(30),		--邮件文件夹
	@messageID varchar(128),	--主键：在指定邮箱内邮件的唯一标识(UID)

	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	update mailList
	set isSeen = 1
	where mailAddr = @mailAddr and folder = @folder and messageID = @messageID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
GO

drop PROCEDURE setMailInfoAnswered
/*
	name:		setMailInfoAnswered
	function:	11.将邮件设置为已回复
	input: 
				@mailAddr varchar(60),		--主键：来源邮箱，采用"lw_bk@163.com"方式
				@folder nvarchar(30),		--邮件文件夹
				@messageID varchar(128),	--主键：在指定邮箱内邮件的唯一标识(UID)
	output: 
				@Ret		int output			--操作成功标识0:成功，9：未知错误
	author:		卢苇
	CreateDate:	2013-2-18
	UpdateDate: 

*/
create PROCEDURE setMailInfoAnswered
	@mailAddr varchar(60),		--主键：来源邮箱，采用"lw_bk@163.com"方式
	@folder nvarchar(30),		--邮件文件夹
	@messageID varchar(128),	--主键：在指定邮箱内邮件的唯一标识(UID)

	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	update mailList
	set isAnswered = 1
	where mailAddr = @mailAddr and folder = @folder and messageID = @messageID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
GO

drop FUNCTION getEMailAddrInfo
/*
	name:		getEMailAddrInfo
	function:	12.获取指定信件指定字段的邮件地址列表
	input: 
				@mailAddr varchar(60),		--来源邮箱，采用"lw_bk@163.com"方式
				@messageID varchar(128),	--在指定邮箱内邮件的唯一标识(UID)
				@fromCCOrTo smallint 		--所在邮件信封结构的字段：1->From，2->To，3->CC
	output: 
				return xml					--返回可能有多个地址，采用<root>
																		<row><name>张三</name><eMailAddr>地址1</eMailAddr></row>
																		<row><name>李四</name><eMailAddr>地址2</eMailAddr></row>
																		...
																	</root>方式存放
	author:		卢苇
	CreateDate:	2013-3-30
	UpdateDate: 
*/
create FUNCTION getEMailAddrInfo
(  
	@mailAddr varchar(60),		--来源邮箱，采用"lw_bk@163.com"方式
	@messageID varchar(128),	--在指定邮箱内邮件的唯一标识(UID)
	@fromCCOrTo smallint 		--所在邮件信封结构的字段：1->From，2->To，3->CC
)  
RETURNS xml	
WITH ENCRYPTION
AS      
begin
	DECLARE @list xml;
	
	set @list = (select name, eMailAddr from mailAddrList
						where mailAddr = @mailAddr and messageID=@messageID and fromCCOrTo=@fromCCOrTo
						FOR XML RAW)
	return N'<root>' + cast(@list as nvarchar(max)) + N'</root>'
end

select * from mailAddrList
order by mailAddr,messageID,fromCCOrTo

DECLARE @statusRemark xml;
set @statusRemark = (select name, eMailAddr 
from mailAddrList
where mailAddr = '1356054110@qq.com' and messageID='14' and fromCCOrTo =1
FOR XML RAW)
select @statusRemark

--测试
select dbo.getEMailAddrInfo('1356054110@qq.com','14',1)
-------------------------------------------本地邮件的存储过程------------------------------------------
drop PROCEDURE addLocalMailInfo
/*
	name:		addLocalMailInfo
	function:	15.添加邮件到本地邮箱
	input: 
				@mailerID varchar(10),		--邮件书写人工号
				@mFrom xml,					--邮件来源（发送邮箱）：这是为了以后扩展而设计的可保存多个邮箱
											/*可能有多个地址，采用<root>
																		<row><name>张三</name><eMailAddr>地址1</eMailAddr></row>
																		<row><name>李四</name><eMailAddr>地址2</eMailAddr></row>
																		...
																	</root>方式存放
											*/
				@mTo xml,					--发送至
											/*可能有多个地址，采用<root>
																		<row><name>张三</name><eMailAddr>地址1</eMailAddr></row>
																		<row><name>李四</name><eMailAddr>地址2</eMailAddr></row>
																		...
																	</root>方式存放
											*/
				@mSubject nvarchar(1000),	--邮件主题
				@mBody nvarchar(max),		--邮件主体
				@AttachFiles nvarchar(1000),--邮件附件（序列化后的字符串）
				@mCC xml,					--抄送
											/*可能有多个地址，采用<root>
																		<row><name>张三</name><eMailAddr>地址1</eMailAddr></row>
																		<row><name>李四</name><eMailAddr>地址2</eMailAddr></row>
																		...
																	</root>方式存放
											*/
	output: 
				@Ret		int output			--操作成功标识0:成功，9：未知错误
	author:		卢苇
	CreateDate:	2013-6-2
	UpdateDate: 
*/
create PROCEDURE addLocalMailInfo
	@mailerID varchar(10),		--邮件书写人工号
	@mFrom xml,					--邮件来源（发送邮箱）：这是为了以后扩展而设计的可保存多个邮箱
	@mTo xml,					--发送至
	@mSubject nvarchar(1000),	--邮件主题
	@mBody nvarchar(max),		--邮件主体
	@AttachFiles nvarchar(1000),--邮件附件（序列化后的字符串）
	@mCC xml,					--抄送
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	insert mailInfo(mailerID, mFrom, mTo, mSubject, mBody, AttachFiles, mCC)
	values(@mailerID, @mFrom, @mTo, @mSubject, @mBody, @AttachFiles, @mCC)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0

GO


drop PROCEDURE updateLocalMailInfo
/*
	name:		updateLocalMailInfo
	function:	16.修改本地邮件
	input: 
				@messageID int,				--邮件标识ID				
				@mailerID varchar(10),		--邮件书写人工号
				@mFrom xml,					--邮件来源（发送邮箱）：这是为了以后扩展而设计的可保存多个邮箱
											/*可能有多个地址，采用<root>
																		<row><name>张三</name><eMailAddr>地址1</eMailAddr></row>
																		<row><name>李四</name><eMailAddr>地址2</eMailAddr></row>
																		...
																	</root>方式存放
											*/
				@mTo xml,					--发送至
											/*可能有多个地址，采用<root>
																		<row><name>张三</name><eMailAddr>地址1</eMailAddr></row>
																		<row><name>李四</name><eMailAddr>地址2</eMailAddr></row>
																		...
																	</root>方式存放
											*/
				@mSubject nvarchar(1000),	--邮件主题
				@mBody nvarchar(max),		--邮件主体
				@AttachFiles nvarchar(1000),--邮件附件（序列化后的字符串）
				@mCC xml,					--抄送
											/*可能有多个地址，采用<root>
																		<row><name>张三</name><eMailAddr>地址1</eMailAddr></row>
																		<row><name>李四</name><eMailAddr>地址2</eMailAddr></row>
																		...
																	</root>方式存放
											*/
	output: 
				@Ret		int output			--操作成功标识0:成功，1:该邮件不存在，9：未知错误
	author:		卢苇
	CreateDate:	2013-6-2
	UpdateDate: 
*/
create PROCEDURE updateLocalMailInfo
	@messageID int,				--邮件标识ID				
	@mailerID varchar(10),		--邮件书写人工号
	@mFrom xml,					--邮件来源（发送邮箱）：这是为了以后扩展而设计的可保存多个邮箱
	@mTo xml,					--发送至
	@mSubject nvarchar(1000),	--邮件主题
	@mBody nvarchar(max),		--邮件主体
	@AttachFiles nvarchar(1000),--邮件附件（序列化后的字符串）
	@mCC xml,					--抄送
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	declare @count int
	set @count=isnull((select count(*) from mailInfo where messageID=@messageID),0)
	if (@count=0)
	begin
		set @Ret = 1
		return
	end
	
	update mailInfo
	set mailerID = @mailerID, mFrom = @mFrom, mTo = @mTo, 
	mSubject = @mSubject, mBody = @mBody, AttachFiles = @AttachFiles, mCC = @mCC,
	saveTime = getdate()
	where messageID=@messageID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0

GO

drop PROCEDURE delLocalMailInfo
/*
	name:		delLocalMailInfo
	function:	17.删除指定的本地邮件
	input: 
				@messageID int,
				@mailerID varchar(10),		--删除人（邮件书写人）工号
	output: 
				@Ret		int output			--操作成功标识0:成功，9：未知错误
	author:		卢苇
	CreateDate:	2013-6-2
	UpdateDate: 

*/
create PROCEDURE delLocalMailInfo
	@messageID int,
	@mailerID varchar(10),		--删除人（邮件书写人）工号

	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	delete mailInfo where messageID = @messageID and messageID = @messageID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
GO

-------------------------------------------签名的存储过程------------------------------------------
drop PROCEDURE checkSignName
/*
	name:		checkSignName
	function:	20.检查指定人员的签名是否已经存在
	input: 
				@rowNum int,				--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
				@mailerID varchar(10),		--邮件管理人工号
				@signName nvarchar(20),		--签名的名字
	output: 
				@Ret		int output		--操作成功标识
							0:不存在，>1：存在，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE checkSignName
	@rowNum int,				--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
	@mailerID varchar(10),		--邮件管理人工号
	@signName nvarchar(20),		--签名的名字
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	declare @count int
	set @count = (select count(*) from signInfo where mailerID = @mailerID and signName = @signName and rowNum <> @rowNum)
	set @Ret = @count
GO


drop PROCEDURE querySignNameLocMan
/*
	name:		querySignNameLocMan
	function:	21.查询指定的人员的签名是否有人正在编辑
	input: 
				@mailerID varchar(10),		--邮件管理人工号
				@signName nvarchar(20),		--签名的名字
	output: 
				@Ret		int output,			--操作成功标识
							0:成功，9：查询出错，可能是指定的签名不存在
				@lockManID varchar(10) output	--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2012-12-30
	UpdateDate: 
*/
create PROCEDURE querySignNameLocMan
	@mailerID varchar(10),		--邮件管理人工号
	@signName nvarchar(20),		--签名的名字
	
	@Ret		int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from signInfo where mailerID = @mailerID and signName = @signName),'')
	set @Ret = 0
GO


drop PROCEDURE lockSignInfo4Edit
/*
	name:		lockSignInfo4Edit
	function:	22.锁定指定人员的签名编辑，避免编辑冲突
	input: 
				@rowNum int,					--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号
				@lockManID varchar(10) output,	--锁定人，如果当前签名正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：要锁定的签名不存在，2:要锁定的签名正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-12-30
	UpdateDate: 
*/
create PROCEDURE lockSignInfo4Edit
	@rowNum int,					--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号
	@lockManID varchar(10) output,	--锁定人，如果当前签名正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的签名是否存在
	declare @count as int
	set @count=(select count(*) from signInfo where rowNum = @rowNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from signInfo where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update signInfo
	set lockManID = @lockManID 
	where rowNum = @rowNum

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定签名编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了签名['+ str(@rowNum) +']为独占式编辑。')
GO

drop PROCEDURE unlockSignInfoEditor
/*
	name:		unlockSignInfoEditor
	function:	23.释放签名编辑锁
				注意：本过程不检查签名是否存在！
	input: 
				@rowNum int,					--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号
				@lockManID varchar(10) output,	--锁定人，如果当前签名正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-30
	UpdateDate: 
*/
create PROCEDURE unlockSignInfoEditor
	@rowNum int,					--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号
	@lockManID varchar(10) output,	--锁定人，如果当前签名正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from signInfo where rowNum = @rowNum),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update signInfo set lockManID = '' where rowNum = @rowNum
	end
	else
	begin
		set @Ret = 0
		return
	end
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '释放签名编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了签名['+ str(@rowNum)+']的编辑锁。')
GO


drop PROCEDURE addSignInfo
/*
	name:		addSignInfo
	function:	24.添加签名
	input: 
				@mailerID varchar(10),		--邮件管理人工号
				@signName nvarchar(20),		--签名的名字
				@signBody nvarchar(4000),	--签名设计的HTML

				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output		--操作成功标识：0:成功，9:未知错误
				@createTime smalldatetime output--添加时间
	author:		卢苇
	CreateDate:	2012-12-30
	UpdateDate: 
*/
create PROCEDURE addSignInfo
	@mailerID varchar(10),		--邮件管理人工号
	@signName nvarchar(20),		--签名的名字
	@signBody nvarchar(4000),	--签名设计的HTML

	@createManID varchar(10),	--创建人工号
	@Ret		int output,
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--取创建人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert signInfo(mailerID, signName, signBody,
					--最新维护情况:
					modiManID, modiManName, modiTime)
	values(@mailerID, @signName, @signBody,
			--最新维护情况:
			@createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加签名', '系统根据用户' + @createManName + 
					'的要求添加了签名['+@signName+']。')
GO
--测试:
declare	@Ret		int
declare	@createTime smalldatetime


drop PROCEDURE updateSignInfo
/*
	name:		updateSignInfo
	function:	25.修改签名
	input: 
				@rowNum int,					--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号
				@mailerID varchar(10),			--邮件管理人工号
				@signName nvarchar(20),			--签名的名字
				@signBody nvarchar(4000),		--签名设计的HTML

				@modiManID varchar(10) output,	--修改人工号：如果当前签名正有人编辑锁定，则返回锁定人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:要修改的签名不存在，
							2:要修改的签名正被别人锁定编辑，
							9:未知错误
				@modiTime smalldatetime output	--添加时间
	author:		卢苇
	CreateDate:	2012-12-30
	UpdateDate: 
*/
create PROCEDURE updateSignInfo
	@rowNum int,					--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号
	@mailerID varchar(10),			--邮件管理人工号
	@signName nvarchar(20),			--签名的名字
	@signBody nvarchar(4000),		--签名设计的HTML

	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要修改的签名是否存在
	declare @count as int
	set @count=(select count(*) from signInfo where rowNum = @rowNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from signInfo where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	update signInfo
	set mailerID = @mailerID, signName = @signName, signBody = @signBody,
		--最新维护情况:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where rowNum = @rowNum
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '修改签名', '系统根据用户' + @modiManName + 
					'的要求修改了签名['+str(@rowNum)+']。')
GO
--测试:
declare	@Ret		int
declare	@modiTime smalldatetime

drop PROCEDURE delSignInfo
/*
	name:		delSignInfo
	function:	26.删除指定的签名
	input: 
				@rowNum int,					--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号
				@delManID varchar(10) output,	--删除人，如果当前签名正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的签名不存在，2：要删除的签名正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-30
	UpdateDate: 

*/
create PROCEDURE delSignInfo
	@rowNum int,					--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号
	@delManID varchar(10) output,	--删除人，如果当前签名正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要修改的签名是否存在
	declare @count as int
	set @count=(select count(*) from signInfo where rowNum = @rowNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @mailerID varchar(10)		--邮件管理人工号
	declare @signName nvarchar(20)		--签名的名字
	select @thisLockMan = isnull(lockManID,''), @mailerID=mailerID, @signName = signName 
	from signInfo where rowNum = @rowNum
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete signInfo where rowNum = @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除签名', '用户' + @delManName
												+ '删除了['+@mailerID+']的签名['+@signName+']。')

GO





select rowNum, mailerID, mailServer, mailServerPort, mailAddr, loginPSW, usedSSL,
	SMTPServer, SMTPUsedSSL, isDefaultSMTP,
	--以下是IMAP协议对应的服务器文件夹：
	inBoxFolder, outBoxFolder, sketchBoxFolder, trashBoxFolder, deletedBoxFolder, adBoxFolder, subscribeBoxFolder
from mailBindOption
where isnull(inBoxFolder,'') <>''




select rowNum, mailerID, mailServer, mailServerPort, mailAddr, loginPSW, usedSSL, 
SMTPServer, SMTPUsedSSL, isDefaultSMTP,outBoxFolder folder 
from mailBindOption where mailerID='G201300040' and isnull(outBoxFolder,'') <>'' 
order by rowNum
use hustOA
delete mailList
select * from mailList where messageID='1320997305' order by messageID desc
select * from mailAddrList

select * from mailBindOption


-------------------------------------------常用联系人的存储过程------------------------------------------


drop PROCEDURE checkContactsGroupName
/*
	name:		checkContactsGroupName
	function:	30.检查指定的分组名是否已经存在
	input: 
				@mailerID varchar(10),		--邮件管理人工号
				@groupName nvarchar(30),	--分组名称
	output: 
				@Ret		int output		--操作成功标识
							0:不存在，>1：存在，9：未知错误
	author:		卢苇
	CreateDate:	2013-06-02
	UpdateDate: 
*/
create PROCEDURE checkContactsGroupName
	@mailerID varchar(10),		--邮件管理人工号
	@groupName nvarchar(30),	--分组名称
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	declare @count int
	set @count = (select count(*) from contactsGroup where groupName = @groupName and mailerID = @mailerID)
	set @Ret = @count
GO

drop PROCEDURE addContactsGroup
/*
	name:		addContactsGroup
	function:	31.添加联系人分组
	input: 
				@mailerID varchar(10),		--邮件管理人工号
				@groupName nvarchar(30),	--分组名称
				@notes nvarchar(300),		--备注
	output: 
				@Ret		int output		--操作成功标识：0:成功，1：该分组名称已经存在，9:未知错误
				@createTime smalldatetime output--添加时间
	author:		卢苇
	CreateDate:	2013-06-02
	UpdateDate: 
*/
create PROCEDURE addContactsGroup
	@mailerID varchar(10),		--邮件管理人工号
	@groupName nvarchar(30),	--分组名称
	@notes nvarchar(300),		--备注

	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--检查分组名称是否唯一：
	declare @count int
	set @count = ISNULL((select count(*) from contactsGroup where groupName = @groupName and mailerID=@mailerID),0)
	if (@count >0)
	begin
		set @Ret = 1
		return
	end
	
	--取创建人的姓名：
	declare @creater nvarchar(30)
	set @creater = isnull((select userCName from activeUsers where userID = @mailerID),'')
	
	insert contactsGroup(mailerID, groupName, notes)
	values(@mailerID, @groupName, @notes)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@mailerID, @creater, GETDATE(), '添加联系人分组', '系统根据用户' + @creater + 
					'的要求添加了联系人分组['+@groupName+']。')
GO
--测试：
declare	@Ret		int 
exec dbo.addContactsGroup 'G201300004','我的同学','这是我的同学的分组', @Ret output
exec dbo.addContactsGroup 'G201300004','我的家人','这是我的亲属', @Ret output
exec dbo.addContactsGroup 'G201300004','我的中学同学','这是我的同学的分组', @Ret output

select * from contactsGroup
select * from userInfo where sysUserName='zml'


drop PROCEDURE addContacter
/*
	name:		addContacter
	function:	32.添加常用联系人
	input: 
				@mailerID varchar(10),		--主键:邮件管理人工号
				@groupID int,				--分组号：这里没有强制连接到分组表，允许联系人不在预定义的分组中.0表示没有分组
				@mailerName nvarchar(30),	--邮件地址人名
				@eMailAddr varchar(128),	--主键:邮件地址
				@isShared smallint,			--是否分享：0->不分享，1->分享
	output: 
				@Ret		int output		--操作成功标识：0:成功，1：该联系人已经存在，9:未知错误
				@createTime smalldatetime output--添加时间
	author:		卢苇
	CreateDate:	2013-06-02
	UpdateDate: 
*/
create PROCEDURE addContacter
	@mailerID varchar(10),		--主键:邮件管理人工号
	@groupID int,				--分组号：这里没有强制连接到分组表，允许联系人不在预定义的分组中.0表示没有分组
	@mailerName nvarchar(30),	--邮件地址人名
	@eMailAddr varchar(128),	--主键:邮件地址
	@isShared smallint,			--是否分享：0->不分享，1->分享

	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	declare @count int
	set @count = ISNULL((select count(*) from mailContacts where mailerID = @mailerID and eMailAddr = @eMailAddr),0)
	if (@count >0)
	begin
		set @Ret = 1
		return
	end

	--获取分组名：
	declare @groupName nvarchar(30)	--分组名称
	set @groupName = ISNULL((select groupName from contactsGroup where groupID=@groupID),'')
	if (@groupName='')
		set @groupID = 0
	
	--取创建人的姓名：
	declare @creater nvarchar(30)
	set @creater = isnull((select userCName from activeUsers where userID = @mailerID),'')
	
	insert mailContacts(mailerID, groupID, groupName, mailerName, eMailAddr, isShared, createrID, creater)
	values(@mailerID, @groupID, @groupName, @mailerName, @eMailAddr, @isShared, @mailerID, @creater)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@mailerID, @creater, GETDATE(), '添加常用联系人', '系统根据用户' + @creater + 
					'的要求添加了常用联系人['+@mailerName+']。')
GO
--测试：
declare	@Ret		int 
exec dbo.addContacter 'G201300004',1,'卢苇','lw_bk@163.com',0,@Ret output
exec dbo.addContacter 'G201300004',2,'张晓华','zxh@163.com',0,@Ret output
declare	@Ret		int 
exec dbo.addContacter 'G201300004',0,'张XX','zxx@163.com',0,@Ret output
declare	@Ret		int 
exec dbo.addContacter 'G201300004',0,'张共享','zgx@163.com',0,@Ret output

select * from mailContacts


drop PROCEDURE updateContactsGroup
/*
	name:		updateContactsGroup
	function:	33.修改联系人分组的分组名与备注
	input: 
				@mailerID varchar(10),		--邮件管理人工号
				@groupID int,				--分组号
				@groupName nvarchar(30),	--分组名称
				@notes nvarchar(300),		--备注
	output: 
				@Ret		int output		--操作成功标识：0:成功，1：该分组不存在，9:未知错误
				@createTime smalldatetime output--添加时间
	author:		卢苇
	CreateDate:	2013-06-02
	UpdateDate: 
*/
create PROCEDURE updateContactsGroup
	@mailerID varchar(10),		--邮件管理人工号
	@groupID int,				--分组号
	@groupName nvarchar(30),	--分组名称
	@notes nvarchar(300),		--备注

	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--检查分组是否存在：
	declare @oldGroupName nvarchar(30)	--分组名称
	set @oldGroupName = ISNULL((select groupName from contactsGroup where mailerID = @mailerID and groupID = @groupID),'')
	if (@oldGroupName = '')
	begin
		set @Ret = 1
		return
	end
	
	--取修改人的姓名：
	declare @updater nvarchar(30)
	set @updater = isnull((select userCName from activeUsers where userID = @mailerID),'')
	
	update contactsGroup
	set groupName = @groupName, notes = @notes
	where mailerID = @mailerID and groupID = @groupID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@mailerID, @updater, GETDATE(), '修改联系人分组信息', '系统根据用户' + @updater + 
					'的要求修改了联系人分组['+@oldGroupName+']的信息。')
GO

drop PROCEDURE moveContacterToGroup
/*
	name:		moveContacterToGroup
	function:	34.修改联系人所在分组（包含从共享的名单中移动到私人的名单中）
	input: 
				@mailerID varchar(10),		--主键:邮件管理人工号
				@eMailAddr varchar(128),	--主键:邮件地址
				@groupID int,				--分组号

				@moverID varchar(10),		--移动人工号
	output: 
				@Ret		int output		--操作成功标识：0:成功，1：该联系人不存在，9:未知错误
				@createTime smalldatetime output--添加时间
	author:		卢苇
	CreateDate:	2013-06-02
	UpdateDate: 
*/
create PROCEDURE moveContacterToGroup
	@mailerID varchar(10),		--主键:邮件管理人工号
	@eMailAddr varchar(128),	--主键:邮件地址
	@groupID int,				--分组号

	@moverID varchar(10),		--移动人工号

	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	declare @count int
	set @count = ISNULL((select count(*) from mailContacts where mailerID = @mailerID and eMailAddr = @eMailAddr),0)
	if (@count =0)
	begin
		set @Ret = 1
		return
	end

	--获取分组名：
	declare @groupName nvarchar(30)	--分组名称
	set @groupName = ISNULL((select groupName from contactsGroup where groupID=@groupID),'')
	if (@groupName='')
		set @groupID = 0
	
	if (@mailerID <> @moverID)	--从共享名单中移动到私人的名单中
	begin
		insert mailContacts(mailerID, groupID, groupName, mailerName, eMailAddr, isShared, createrID, creater)
		select @moverID, @groupID, @groupName, mailerName, @eMailAddr, 0, createrID, creater
		from mailContacts
		where mailerID = @mailerID and eMailAddr = @eMailAddr
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end    
	end
	else
	begin
		update mailContacts
		set groupID = @groupID, groupName = @groupName
		where mailerID = @mailerID and eMailAddr = @eMailAddr
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end    
	end
	
	set @Ret = 0

	--取移动人的姓名：
	declare @mover nvarchar(30)
	set @mover = isnull((select userCName from activeUsers where userID = @moverID),'')
	
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@moverID, @mover, GETDATE(), '移动联系人分组', '系统根据用户' + @mover + 
					'的要求将联系人移动到分组['+@groupName+']中。')
GO

drop PROCEDURE delContactsGroup
/*
	name:		delContactsGroup
	function:	35.删除指定的分组（本存储过程保证级联删除分组类的联系人）
	input: 
				@mailerID varchar(10),		--邮件管理人工号
				@groupID int,				--分组号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：指定的分组不存在，9：未知错误
	author:		卢苇
	CreateDate:	2013-06-02
	UpdateDate: 

*/
create PROCEDURE delContactsGroup
	@mailerID varchar(10),		--邮件管理人工号
	@groupID int,				--分组号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--获取分组名：
	declare @groupName nvarchar(30)	--分组名称
	set @groupName = ISNULL((select groupName from contactsGroup where mailerID = @mailerID and groupID = @groupID),'')

	--判断要删除的分组是否存在
	if (@groupName = '')	--不存在
	begin
		set @Ret = 1
		return
	end

	begin tran
		delete mailContacts where mailerID = @mailerID and groupID = @groupID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    
		delete contactsGroup where mailerID = @mailerID and groupID = @groupID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    
	commit tran
	set @Ret = 0

	
	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @mailerID),'')


	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@mailerID, @delManName, getdate(), '删除联系人分组', '用户' + @delManName
												+ '删除了联系人分组['+@groupName+']。')

GO

drop PROCEDURE delContacter
/*
	name:		delContacter
	function:	36.删除指定的联系人
	input: 
				@mailerID varchar(10),		--邮件管理人工号
				@eMailAddr varchar(128),	--联系人（邮件地址）
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：指定的联系人不存在，9：未知错误
	author:		卢苇
	CreateDate:	2013-06-02
	UpdateDate: 
*/
create PROCEDURE delContacter
	@mailerID varchar(10),		--邮件管理人工号
	@eMailAddr varchar(128),	--联系人（邮件地址）
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要删除的联系人是否存在
	declare @count int
	set @count = ISNULL((select count(*) from mailContacts where mailerID = @mailerID and eMailAddr = @eMailAddr),0)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	delete mailContacts where mailerID = @mailerID and eMailAddr = @eMailAddr
	if @@ERROR <> 0 
	begin
		rollback tran
		set @Ret = 9
		return
	end    

	set @Ret = 0

	
	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @mailerID),'')


	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@mailerID, @delManName, getdate(), '删除联系人', '用户' + @delManName
												+ '删除了联系人['+@eMailAddr+']。')

GO

drop PROCEDURE shareContacter
/*
	name:		shareContacter
	function:	37.分享（取消分享）指定的联系人
	input: 
				@mailerID varchar(10),		--邮件管理人工号
				@eMailAddr varchar(128),	--联系人（邮件地址）
				@isShared smallint,			--是否分享：0->不分享，1->分享
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：指定的联系人不存在，9：未知错误
	author:		卢苇
	CreateDate:	2013-06-02
	UpdateDate: 
*/
create PROCEDURE shareContacter
	@mailerID varchar(10),		--邮件管理人工号
	@eMailAddr varchar(128),	--联系人（邮件地址）
	@isShared smallint,			--是否分享：0->不分享，1->分享

	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的联系人是否存在
	declare @count int
	set @count = ISNULL((select count(*) from mailContacts where mailerID = @mailerID and eMailAddr = @eMailAddr),0)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	update mailContacts 
	set isShared = @isShared
	where mailerID = @mailerID and eMailAddr = @eMailAddr
	if @@ERROR <> 0 
	begin
		rollback tran
		set @Ret = 9
		return
	end    

	set @Ret = 0

	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @mailerID),'')

	--登记工作日志：
	if (@isShared=0)
		insert workNote(userID, userName, actionTime, actions, actionObject)
		values(@mailerID, @modiManName, getdate(), '停止分享联系人', '用户' + @modiManName + '停止了分享联系人['+@eMailAddr+']。')
	else
		insert workNote(userID, userName, actionTime, actions, actionObject)
		values(@mailerID, @modiManName, getdate(), '分享联系人', '用户' + @modiManName + '分享了联系人['+@eMailAddr+']。')

GO
--测试：
declare	@Ret		int 
exec dbo.shareContacter 'G201300004','zgx@163.com',1,@Ret output


select * from mailContacts

--常用联系人列表：
select 1 orderID, clgName className, uName groupName, '' mailerID, cName mailerName, e_mail eMailAddr
from userInfo
where isnull(e_mail,'')<>''
union all
select 2, '常用联系人', g.groupName, m.mailerID, m.mailerName, m.eMailAddr 
from contactsGroup g left join mailContacts m on g.groupID=m.groupID
union all
select 3, '共享联系人', '', mailerID, mailerName, eMailAddr 
from mailContacts
where isShared=1
union all
select 4, '未分组', '', mailerID, mailerName, eMailAddr 
from mailContacts
where isnull(groupName,'')=''
order by orderID, className, groupName, cName


select * from contactsGroup


update userInfo
set clgCode='001',clgName='脉冲强磁场科学中心'

select * from userInfo



select 1 orderID, clgName className, uName groupName, '' mailerID, cName mailerName, e_mail eMailAddr 
from userInfo 
where isnull(e_mail,'')<>'' 
union all 
select 2, '常用联系人', g.groupName, m.mailerID, m.mailerName, m.eMailAddr 
from contactsGroup g left join mailContacts m on g.groupID=m.groupID 
where g.mailerID='G201300040' union all select 3, '共享联系人', '', mailerID, mailerName, eMailAddr from mailContacts where isShared=1 union all select 4, '未分组', '', mailerID, mailerName, eMailAddr from mailContacts where mailerID='G201300040' and isnull(groupName,'')='' order by orderID, className, groupName, cName



--除草稿箱外的其他邮箱的邮件查询语句：
select m.mailerID, m.mailAddr, m.folder, m.isSeen, m.isAnswered, m.isFlagged, m.isRecent, m.haveAttach,
m.messageNum, m.messageID, dbo.getEMailAddrInfo(m.mailAddr,m.messageID,1) mailFrom, dbo.getEMailAddrInfo(m.mailAddr,m.messageID,2) mailTo, m.mailSubject,
convert(varchar(19),m.mailReceivedTime,120) mailReceivedTime, m.mailSize
from mailList m
where mailAddr='lw_bk@163.com' and folder='INBOX' 
and messageID in (select messageID from mailAddrList 
				  where fromCCOrTo=1 and eMailAddr='scwang@east-dawn.com.cn' 
					and mailAddr='lw_bk@163.com' and folder='INBOX')

--草稿箱的查询语句：
select * from mailInfo where cast(mTo as varchar(max)) like '%<eMailAddr>huying_52000@sina.com</eMailAddr>%'

