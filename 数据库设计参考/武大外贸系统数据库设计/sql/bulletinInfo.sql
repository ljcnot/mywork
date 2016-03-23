use newfTradeDB2
/*
	武大外贸合同管理信息系统-公告板管理
	根据设备管理系统改编
	author:		卢苇
	CreateDate:	2011-11-23
	UpdateDate: 2013-10-06与OA系统一致化
*/
--1.站内公告一览表（bulletinInfo）：
drop TABLE bulletinInfo
CREATE TABLE bulletinInfo
(
	bulletinID char(12) not null,			--主键：公告编号，使用第 10010 号号码发生器产生
	bulletinTime datetime null,				--公告时间
	bulletinTitle nvarchar(100) null,		--公告标题
	bulletinHTML nvarchar(max) null,		--公告内容

	onTop int default(0),					--是否置顶显示：0->不置顶，1->置顶显示 add by lw 2013-9-8
	isActive int default(0),				--是否发布：0->未发布，1->已发布
	activeDate smalldatetime null,			--发布日期
	isClosed int default(0),				--是否关闭（历史公告）：0->未关闭，1->已关闭 add by lw 2013-9-8
	closedTime smalldatetime null,			--关闭日期 add by lw 2013-9-8
	orderNum smallint default(-1),			--显示排序号
	autoCloseDate smalldatetime null,		--自动关闭日期

	--投票：
	enableVote smallint default(0),			--是否允许投票：0->允许，1->不允许
	voteOption xml null,					--投票选项 add by lw 2013-07-12
												--N'<root>'+
												--	'<item ID="1" itemDesc="同意" />'+
												--	'<item ID="2" itemDesc="不同意" />'+
												--	'<item ID="3" itemDesc="弃权" />'+
												--'</root>'	
	--发布对象：
	publishTo xml null,						--发布对象（阅读权限）：采用如下xml格式存放
												--N'<root>'+
												--	'<user userID="G201300001" userCName="程远" />'+	--包含的用户
												--	'<unit uCode="001001" uName="办公室" />'+			--包含的部门
												--	'<sysRole id="3" desc="场地管理员" />'+				--包含的角色
												--	'<exceptUser userID="G201300003" userCName="杨斌" />'+			--除外人员
												--'</root>'	
	--创建人：
	createrID varchar(10) null,			--创建人工号
	creater varchar(30) null,			--创建人
	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName varchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
CONSTRAINT [PK_bulletinInfo] PRIMARY KEY CLUSTERED 
(
	[bulletinID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_bulletinInfo] ON [dbo].[bulletinInfo] 
(
	[bulletinTime] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_bulletinInfo_0] ON [dbo].[bulletinInfo] 
(
	[isActive] ASC,
	[orderNum] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

--1.1.1公告投票一览表：
DROP TABLE bulletinVote
CREATE TABLE bulletinVote
(
	bulletinID char(12) not null,			--主键/外键：公告编号
	voterID varchar(10) not null,			--主键：投票人ID
	voter nvarchar(30) null,				--冗余设计：投票人
	voteTime datetime default(getdate()),	--投票时间
	voteResult smallint default(0),			--表决结果：对应投票选项的ID
CONSTRAINT [PK_bulletinVote] PRIMARY KEY CLUSTERED 
(
	[bulletinID] ASC,
	[voterID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--外键：
ALTER TABLE [dbo].[bulletinVote] WITH CHECK ADD CONSTRAINT [FK_bulletinVote_bulletinInfo] FOREIGN KEY([bulletinID])
REFERENCES [dbo].[bulletinInfo] ([bulletinID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[bulletinVote] CHECK CONSTRAINT [FK_bulletinVote_bulletinInfo]
GO

select bulletinID, voterID, voter, convert(varchar(19),voteTime,120) voteTime, voteResult
from bulletinVote

--1.1.2公告评论一览表：
drop TABLE bulletinDiscuss
CREATE TABLE bulletinDiscuss
(
	bulletinID char(12) not null,		--主键/外键：公告编号
	rowNum int IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL, --内部行号
	discussTitle nvarchar(100) null,	--标题：暂时未使用
	discussHTML nvarchar(4000) null,	--内容

	discussTime datetime default(getdate()),--发表时间
	discusserID varchar(10) null,		--发表人ID
	discusser varchar(30) null,			--发表人姓名:冗余设计
CONSTRAINT [PK_bulletinDiscuss] PRIMARY KEY CLUSTERED 
(
	[bulletinID] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[bulletinDiscuss] WITH CHECK ADD CONSTRAINT [FK_bulletinDiscuss_bulletinInfo] FOREIGN KEY([bulletinID])
REFERENCES [dbo].[bulletinInfo] ([bulletinID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[bulletinDiscuss] CHECK CONSTRAINT [FK_bulletinDiscuss_bulletinInfo] 
GO

select bulletinID, rowNum, discussTitle, discussHTML, convert(varchar(19),d.discussTime,120) discussTime, discusserID, discusser
from bulletinDiscuss d
where bulletinID = '201307130008'
order by d.discussTime

--1.2公告板多媒体资源管理表
--多媒体文件放在bulletin\media中
drop TABLE bulletinResouce
CREATE TABLE bulletinResouce(
	resouceName nvarchar(30) not null,	--资源名称
	resouceType smallint not null,		--资源类型：1->图片，2->影音文件
	fileGUID36 varchar(36) not NULL,	--资源文件对应的36位全球唯一编码文件名
	oldFilename varchar(128) not null,	--资源文件原始文件名
	extFileName varchar(8) not NULL,	--资源文件文件扩展名
	notes nvarchar(100) null,			--说明
	ownerID varchar(10) null,			--所有人工号
	ownerName varchar(30) null,			--所有人姓名
	isShare char(1) default('N')		--是否共享
 CONSTRAINT [PK_bulletinResouce] PRIMARY KEY CLUSTERED 
(
	[resouceType] ASC,
	[fileGUID36] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--资源名索引：
CREATE NONCLUSTERED INDEX [IX_bulletinResouce] ON [dbo].[bulletinResouce]
(
	[resouceName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--1.3.公告附件库：add by lw 2013-9-8
select * from bulletinAttachment where bulletinID='201310020001'
drop TABLE bulletinAttachment
CREATE TABLE bulletinAttachment(
	bulletinID char(12) not null,					--外键/主键：公告编号
	rowNum bigint IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,--主键：行号
	
	aFilename varchar(128) null,					--原始文件名
	uidFilename varchar(128) not null,				--UID文件名
	fileSize bigint null,							--文件尺寸
	fileType varchar(10),							--文件类型
	uploadTime smalldatetime default(getdate()),	--上传日期
 CONSTRAINT [PK_bulletinAttachment] PRIMARY KEY CLUSTERED 
(
	[bulletinID] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[bulletinAttachment] WITH CHECK ADD CONSTRAINT [FK_bulletinAttachment_bulletinInfo] FOREIGN KEY([bulletinID])
REFERENCES [dbo].[bulletinInfo] ([bulletinID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[bulletinAttachment] CHECK CONSTRAINT [FK_bulletinAttachment_bulletinInfo] 
GO
--索引：
--原始文件名索引：
CREATE NONCLUSTERED INDEX [IX_bulletinAttachment] ON [dbo].[bulletinAttachment]
(
	[aFilename] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--文件类型索引：
CREATE NONCLUSTERED INDEX [IX_bulletinAttachment_1] ON [dbo].[bulletinAttachment]
(
	[fileType] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

drop FUNCTION canSeeBulletinInfo
/*
	name:		canSeeBulletinInfo
	function:	0.判定指定的用户能否浏览指定的公告
				注意：该存储过程与OA系统不一样，这里没有部门，只有院部！
	input: 
				@bulletinID char(12),			--公告编号
				@userID varchar(10)			--用户工号
	output: 
				return char(1)	--能否使用：“Y”->能使用，“N”->不能使用
	author:		卢苇
	CreateDate:	2013-6-23
	UpdateDate: 
*/
create FUNCTION canSeeBulletinInfo
(  
	@bulletinID char(12),		--公告编号
	@userID varchar(10)			--用户工号
)  
RETURNS char(1)
WITH ENCRYPTION
AS      
begin
	--检查公告是否存在：
	declare @count int
	set @count = ISNULL((select count(*) from bulletinInfo where bulletinID = @bulletinID),0)
	if (@count=0)
	begin
		return 'N'
	end
	
	--判断是否有发布对象：
	declare @publishTo xml			--发布对象（阅读权限）：采用如下xml格式存放
												--N'<root>'+
												--	'<user userID="G201300001" userCName="范家才" />'+	--包含的用户
												--	'<college clgCode="001001" clgName="实验室与设备处" />'+			--包含的院部
												--	'<sysRole id="3" desc="设备管理员" />'+				--包含的角色
												--	'<exceptUser userID="G201300003" userCName="杨斌" />'+			--除外人员
												--'</root>'	
	select @publishTo = publishTo
	from bulletinInfo 
	where bulletinID = @bulletinID
	if (@publishTo is null)	--没有角色限制，返回全体人员
	begin
		return 'Y'
	end
	
	--获取指定公告的发布对象：
	declare @selectedMan as table(
		userID varchar(10),
		userCName nvarchar(30)
	)
	declare @isAllEmpty char(1)	--是否全部为空
	set @isAllEmpty = 'Y'
	--添加系统角色定义的用户：
	set @count=(select @publishTo.exist('/root/sysRole'))
	if (@count>0)
	begin
		insert @selectedMan(userID, userCName)
		select u.userID, u.cName 
		from sysUserInfo u inner join sysUserRole s on u.userID = s.userID
		where s.sysRoleID in (SELECT A.sysRole.value('./@id','int') from @publishTo.nodes('/root/sysRole') as A(sysRole))
		set @isAllEmpty = 'N'
	end
	--添加直接定义的用户：
	set @count=(select @publishTo.exist('/root/user'))
	if (@count>0)
	begin
		insert @selectedMan(userID, userCName)
		SELECT cast(A.col1.query('data(./@userID)') as varchar(10)),
			cast(A.col1.query('data(./@userCName)') as nvarchar(30))
		from @publishTo.nodes('/root/user') as A(col1)
		set @isAllEmpty = 'N'
	end
	--添加部门用户：
	set @count=(select @publishTo.exist('/root/college'))
	if (@count>0)
	begin
		insert @selectedMan(userID, userCName)
		select u.jobNumber, u.cName 
		from userInfo u 
		where u.uCode in (SELECT A.unit.value('./@clgCode','varchar(8)') from @publishTo.nodes('/root/college') as A(unit))
		set @isAllEmpty = 'N'
	end
		
	set @count = (select count(*) from @selectedMan)
	if (@count>0)
	begin
		--除外人员：
		delete	@selectedMan
		where userID in (SELECT A.col1.value('./@userID','varchar(10)') from @publishTo.nodes('/root/exceptUser') as A(col1))

		set @count = (select count(*) from @selectedMan where userID = @userID)
		if (@count>0)
			return 'Y'
	end
	else
	begin
		if (@isAllEmpty = 'Y')
		begin
			if (@userID not in (SELECT A.col1.value('./@userID','varchar(10)') from @publishTo.nodes('/root/exceptUser') as A(col1)))
				return 'Y'
		end
	end
	return 'N'
end
--测试：
update bulletinInfo
set publishTo=N'<root>'+
					'<user userID="00011275" userCName="范家才" />'+	--包含的用户
					'<college clgCode="000" clgName="实验室与设备处" />'+			--包含的部门
					--'<sysRole id="3" desc="设备管理员" />'+				--包含的角色
					--'<exceptUser userID="G201300003" userCName="杨斌" />'+			--除外人员
				'</root>'
where bulletinID='201306270005'

select * from bulletinInfo
select * from useUnit

select * from useUnit
select * from sysRole
select * from userInfo

select dbo.canSeeBulletinInfo('201311010003','00011275')
select dbo.canSeeBulletinInfo('201306270005','G201300001')
select dbo.canSeeBulletinInfo('201304170001','G201300003')

select * from bulletinInfo where publishTo is not null

declare @publishTo xml			--发布对象（阅读权限）：采用如下xml格式存放
set @publishTo=N'<root>
  <sysRole id="1" desc="超级用户" />
  <sysRole id="2" desc="一般用户" />
  <sysRole id="3" desc="部长" />
  <sysRole id="4" desc="角色1" />
</root>'
SELECT A.sysRole.value('./@id','int') from @publishTo.nodes('/root/sysRole') as A(sysRole)

--查询指定用户能浏览的公告：
select * from bulletinInfo where dbo.canSeeBulletinInfo(bulletinID,'G201300040')='Y'

select publishTo, * from bulletinInfo where publishTo is not null
update bulletinInfo 
set publishTo=null
where bulletinID in ('201306220010','201306220007')


drop PROCEDURE addBulletinInfo
/*
	name:		addBulletinInfo
	function:	1.添加公告信息
				注意：该存储过程自动锁定单据
	input: 
				@bulletinTitle nvarchar(100),	--公告标题
				@bulletinTime varchar(10),		--公告日期
				@autoCloseDate varchar(10),		--公告自动关闭日期
				@bulletinHTML nvarchar(max),	--公告内容
				@enableVote smallint,			--是否允许投票：0->允许，1->不允许
				@voteOption xml,				--投票选项
												--N'<root>'+
												--	'<item ID="1" itemDesc="同意" />'+
												--	'<item ID="2" itemDesc="不同意" />'+
												--	'<item ID="3" itemDesc="弃权" />'+
												--'</root>'	

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output,
				@bulletinID char(12) output		--主键：公告编号，使用第 10010 号号码发生器产生
	author:		卢苇
	CreateDate:	2011-11-23
	UpdateDate: modi by lw 2011-12-4增加公告日期和自动关闭日期参数
				modi by lw 2013-6-21增加是否允许投票
				modi by lw 2013-07-12增加投票选项设定

*/
create PROCEDURE addBulletinInfo
	@bulletinTitle nvarchar(100),		--公告标题
	@bulletinTime varchar(10),			--公告日期
	@autoCloseDate varchar(10),			--公告自动关闭日期
	@bulletinHTML nvarchar(max),		--公告内容
	@enableVote smallint,				--是否允许投票：0->允许，1->不允许
	@voteOption xml,					--投票选项

	@createManID varchar(10),			--创建人工号

	@Ret		int output,
	@createTime smalldatetime output,
	@bulletinID char(12) output			--主键：公告编号，使用第 10010 号号码发生器产生
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 10010, 1, @curNumber output
	set @bulletinID = @curNumber

	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	
	set @createTime = getdate()
	if (@bulletinTime='')
		set @bulletinTime = CONVERT(varchar(10), @createTime, 120)
		
	--处理自动关闭日期：
	declare @closeDate smalldatetime
	if (@autoCloseDate='')
		set @closeDate=null
	else
		set @closeDate=convert(smalldatetime,@autoCloseDate,120)

	insert bulletinInfo(bulletinID, bulletinTime, autoCloseDate, bulletinTitle, bulletinHTML,
						enableVote, voteOption,
						publishTo, lockManID, modiManID, modiManName, modiTime,	createrID, creater) 
	values (@bulletinID, @bulletinTime, @closeDate, @bulletinTitle, @bulletinHTML,
			@enableVote, @voteOption, N'<root />',@createManID, @createManID, @createManName, @createTime, @createManID, @createManName)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加公告', '系统根据用户' + @createManName + 
					'的要求添加了公告[' + @bulletinID + ']。')
GO

DROP PROCEDURE cloneBulletinInfo
/*
	name:		cloneBulletinInfo
	function:	1.0.克隆指定的公告
	input: 
				@bulletinID char(12),			--公告编号
				--维护情况:
				@modiManID varchar(10) output,	--维护人
	output: 
				@updateTime smalldatetime output,--更新时间
				@Ret		int output,			--操作成功标识
							0:成功，1：要克隆的公告不存在，9：未知错误
				@newBulletinID char(12) output	--主键：克隆的公告编号，使用第 10010 号号码发生器产生
	author:		卢苇
	CreateDate:	2013-09-08
	UpdateDate: 
*/
create PROCEDURE cloneBulletinInfo
	@bulletinID char(12),			--公告编号
	--维护情况:
	@modiManID varchar(10) output,	--维护人

	@updateTime smalldatetime output,--更新时间
	@Ret		int output,			--操作成功标识
	@newBulletinID char(12) output	--主键：克隆的公告编号，使用第 10010 号号码发生器产生
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要克隆的公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 10010, 1, @curNumber output
	set @newBulletinID = @curNumber

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	set @updateTime = getdate()
	begin tran
		insert bulletinInfo(bulletinID, bulletinTime, bulletinTitle, bulletinHTML,
							enableVote, voteOption,
							publishTo, modiManID, modiManName, modiTime,	createrID, creater)
		select @newBulletinID, bulletinTime, bulletinTitle, bulletinHTML,
							enableVote, voteOption,
							publishTo, @modiManID, @modiManName, @updateTime, @modiManID, @modiManName
		from bulletinInfo
		where bulletinID = @bulletinID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    
		
		insert bulletinAttachment(bulletinID, aFilename, uidFilename, fileSize, fileType, uploadTime)
		select @newBulletinID, aFilename, uidFilename, fileSize, fileType, uploadTime
		from bulletinAttachment
		where bulletinID = @bulletinID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    
	commit tran
	
	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '克隆公告', '用户' + @modiManName 
												+ '克隆公告['+ @bulletinID +']为['+@newBulletinID+']。')
GO
--测试:
declare @updateTime smalldatetime--更新时间
declare @Ret		int		--操作成功标识
declare @newBulletinID char(12)--主键：克隆的公告编号，使用第 10010 号号码发生器产生
exec dbo.cloneBulletinInfo '201307180001','G201300040', @updateTime output, @Ret output, @newBulletinID output
select @updateTime, @Ret, @newBulletinID

select * from bulletinInfo

drop PROCEDURE addBulletinAttachment
/*
	name:		1.1.addBulletinAttachment
	function:	添加公告附件
				@bulletinID char(12),		--公告编号
				@aFilename varchar(128),	--原始文件名
				@uidFilename varchar(128),	--UID文件名
				@fileSize bigint,			--文件尺寸
				@fileType varchar(10),		--文件类型
	output: 
				@Ret		int output		--操作成功标识
										0:成功，1:指定的公告不存在,9：未知错误
	author:		卢苇
	CreateDate:	2013-9-8
	UpdateDate: 
*/
create PROCEDURE addBulletinAttachment
	@bulletinID char(12),		--公告编号
	@aFilename varchar(128),	--原始文件名
	@uidFilename varchar(128),	--UID文件名
	@fileSize bigint,			--文件尺寸
	@fileType varchar(10),		--文件类型
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	insert bulletinAttachment(bulletinID, aFilename, uidFilename, fileSize, fileType)
	values(@bulletinID, @aFilename, @uidFilename, @fileSize, @fileType)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
GO

drop PROCEDURE delBulletinAttachment
/*
	name:		delBulletinAttachment
	function:	1.2.删除指定公告指定UID的附件
	input: 
				@bulletinID char(12),		--公告编号
				@uidFilename varchar(128),	--UID文件名
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1:指定的公告不存在,2：指定的附件不存在，9：未知错误
	author:		卢苇
	CreateDate:	2013-9-8
	UpdateDate: 
*/
create PROCEDURE delBulletinAttachment
	@bulletinID char(12),		--公告编号
	@uidFilename varchar(128),	--UID文件名
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--判断要锁定的公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	--判断指定的附件是否存在
	set @count=(select count(*) from bulletinAttachment where bulletinID = @bulletinID and uidFilename = @uidFilename)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 2
		return
	end

	delete bulletinAttachment where bulletinID = @bulletinID  and uidFilename = @uidFilename
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0
GO

drop PROCEDURE delBulletinAllAttachment
/*
	name:		delBulletinAllAttachment
	function:	1.3.删除指定公告的全部附件
	input: 
				@bulletinID char(12),		--公告编号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1:指定的公告不存在,9：未知错误
	author:		卢苇
	CreateDate:	2013-9-8
	UpdateDate: 
*/
create PROCEDURE delBulletinAllAttachment
	@bulletinID char(12),		--公告编号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--要排除其他公告引用的附件（这里主要是考虑克隆公告的情况）
	delete bulletinAttachment where bulletinID = @bulletinID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0
GO

drop PROCEDURE bulletinAttachmentIsExist
/*
	name:		bulletinAttachmentIsExist
	function:	1.4.检查指定UID的附件被公告引用次数
				这里主要是考虑克隆公告中附件文件可能被多个公告引用，在数据库删除后再次检查，如果未被引用则删除上传文件
	input: 
				@uidFilename varchar(128),	--UID文件名
	output: 
				@Ret		int output		--被引用的次数：0:未引用，>1:被引用
	author:		卢苇
	CreateDate:	2013-9-8
	UpdateDate: 
*/
create PROCEDURE bulletinAttachmentIsExist
	@uidFilename varchar(128),	--UID文件名
	@Ret		int output		--被引用的次数：0:未引用，>1:被引用
	WITH ENCRYPTION 
AS
	set @Ret=(select count(*) from bulletinAttachment where uidFilename = @uidFilename)	
GO


DROP PROCEDURE activeBulletinInfo
/*
	name:		activeBulletinInfo
	function:	2.发布指定的公告，并自动排序在最后
	input: 
				@bulletinID char(12),			--公告编号
				@autoCloseDate varchar(10),		--自动关闭日期
				@publishTo xml,					--发布对象（阅读权限）：采用如下xml格式存放
												--N'<root>'+
												--	'<user userID="G201300001" userCName="程远" />'+	--包含的用户
												--	'<unit uCode="001001" uName="办公室" />'+			--包含的部门
												--	'<sysRole id="3" desc="场地管理员" />'+				--包含的角色
												--	'<exceptUser userID="G201300003" userCName="杨斌" />'+			--除外人员
												--'</root>'	
				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要发布的公告不存在，2:要发布的公告正在被别人编辑，3：要发布的公告已经关闭，4:要发布的公告已经是发布状态，
							9：未知错误
	author:		卢苇
	CreateDate:	2011-11-23
	UpdateDate: modi by lw 2013-6-21增加指定发布对象接口
				modi by lw 2013-9-8增加发布状态和关闭状态判断
*/
create PROCEDURE activeBulletinInfo
	@bulletinID char(12),			--公告编号
	@autoCloseDate varchar(10),		--自动关闭日期
	@publishTo xml,					--发布对象（阅读权限）

	--维护情况:
	@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @isActive int	--是否显示（激活）：0->未激活，1->已激活
	declare @isClosed int	--是否关闭：0->未关闭，1->已关闭
	select @thisLockMan=isnull(lockManID,''), @isActive=isActive, @isClosed=isClosed 
	from bulletinInfo 
	where bulletinID = @bulletinID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查关闭状态：
	if (@isClosed=1)
	begin
		set @Ret = 3
		return
	end
	--检查发布状态：
	if (@isActive=1)
	begin
		set @Ret = 4
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--检查默认关闭时间：根据客户要求去掉自动关闭功能modi by lw 2013-09-08
	if (@autoCloseDate ='')
		set @autoCloseDate=null
		--set @autoCloseDate = convert(varchar(10), dateadd(day, 7, getdate()), 120)
	
	set @updateTime = getdate()
	declare @curMaxOrderNum int
	set @curMaxOrderNum = isnull((select max(orderNum) from bulletinInfo where isActive = 1),0) + 1
	update bulletinInfo
	set isActive = 1, activeDate = @updateTime,
		autoCloseDate = @autoCloseDate, publishTo = @publishTo,
		orderNum = @curMaxOrderNum,
		isClosed=0, closedTime=null,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where bulletinID = @bulletinID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

/*	--将该公告置顶：
	declare @execRet int
	exec dbo.setBulletinToTop @bulletinID, @modiManID output, @execRet output
*/
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '发布公告', '用户' + @modiManName 
												+ '发布了公告['+ @bulletinID +']。')
GO

update bulletinInfo
set onTop=0
select * from bulletinInfo where isActive=1

DROP PROCEDURE setOffBulletinInfo
/*
	name:		setOffBulletinInfo
	function:	3.撤销指定的公告
	input: 
				@bulletinID char(12),			--公告编号

				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要撤销的公告不存在，2:要撤销的公告正在被别人编辑，3：要撤销的公告已经关闭，4:要撤销的公告已经是未发布状态，
							9：未知错误
	author:		卢苇
	CreateDate:	2011-11-23
	UpdateDate: modi by lw 2013-9-8增加发布状态和关闭状态判断
*/
create PROCEDURE setOffBulletinInfo
	@bulletinID char(12),			--公告编号

	--维护情况:
	@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @isActive int	--是否显示（激活）：0->未激活，1->已激活
	declare @isClosed int	--是否关闭：0->未关闭，1->已关闭
	select @thisLockMan=isnull(lockManID,''), @isActive=isActive, @isClosed=isClosed 
	from bulletinInfo 
	where bulletinID = @bulletinID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查关闭状态：
	if (@isClosed=1)
	begin
		set @Ret = 3
		return
	end
	--检查发布状态：
	if (@isActive=0)
	begin
		set @Ret = 4
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	set @updateTime = getdate()
	update bulletinInfo
	set isActive = 0, activeDate = null, autoCloseDate = null,
		orderNum = -1, onTop=0,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where bulletinID = @bulletinID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '撤销公告', '用户' + @modiManName 
												+ '撤销了公告['+ @bulletinID +']。')
GO

DROP PROCEDURE closeBulletinInfo
/*
	name:		closeBulletinInfo
	function:	3.1.关闭指定的公告
	input: 
				@bulletinID char(12),			--公告编号

				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要关闭的公告不存在，2:要关闭的公告正在被别人编辑，3:要关闭的公告已经是关闭状态，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-9-8
	UpdateDate: 
*/
create PROCEDURE closeBulletinInfo
	@bulletinID char(12),			--公告编号

	--维护情况:
	@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @isActive int	--是否显示（激活）：0->未激活，1->已激活
	declare @isClosed int	--是否关闭：0->未关闭，1->已关闭
	select @thisLockMan=isnull(lockManID,''), @isActive=isActive, @isClosed=isClosed 
	from bulletinInfo 
	where bulletinID = @bulletinID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查关闭状态：
	if (@isClosed=1)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	set @updateTime = getdate()
	update bulletinInfo
	set isActive = 0, orderNum = -1,
		isClosed=1, closedTime=@updateTime, onTop=0,

		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where bulletinID = @bulletinID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '关闭公告', '用户' + @modiManName 
												+ '关闭了公告['+ @bulletinID +']。')
GO

DROP PROCEDURE recallBulletinInfo
/*
	name:		recallBulletinInfo
	function:	3.2.重新启用指定的公告
	input: 
				@bulletinID char(12),			--公告编号

				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要重新启用的公告不存在，2:要重新启用的公告正在被别人编辑，3:要重新启用的公告已经是启用状态，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-9-8
	UpdateDate: 
*/
create PROCEDURE recallBulletinInfo
	@bulletinID char(12),			--公告编号

	--维护情况:
	@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @isActive int	--是否显示（激活）：0->未激活，1->已激活
	declare @isClosed int	--是否关闭：0->未关闭，1->已关闭
	select @thisLockMan=isnull(lockManID,''), @isActive=isActive, @isClosed=isClosed 
	from bulletinInfo 
	where bulletinID = @bulletinID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查关闭状态：
	if (@isClosed=0)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	set @updateTime = getdate()
	update bulletinInfo
	set isActive = 0, activeDate = null, autoCloseDate = null,
		orderNum = -1,
		isClosed=0, closedTime=null,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where bulletinID = @bulletinID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '重新启用公告', '用户' + @modiManName 
												+ '重新启用了公告['+ @bulletinID +']。')
GO

drop PROCEDURE delBulletinInfo
/*
	name:		delBulletinInfo
	function:	4.删除指定的公告
	input: 
				@bulletinID char(12),			--公告编号
				@delManID varchar(10) output,	--删除人，如果当前公告正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：该公告不存在，2:要删除的公告信息正被别人锁定，3:该公告已经发布,
							9：未知错误
	author:		卢苇
	CreateDate:	2011-11-24
	UpdateDate: modi by lw 2013-9-8增加发布状态判断
*/
create PROCEDURE delBulletinInfo
	@bulletinID char(12),			--公告编号
	@delManID varchar(10) output,	--删除人，如果当前公告正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @isActive int	--是否显示（激活）：0->未激活，1->已激活
	declare @isClosed int	--是否关闭：0->未关闭，1->已关闭
	select @thisLockMan=isnull(lockManID,''), @isActive=isActive, @isClosed=isClosed 
	from bulletinInfo 
	where bulletinID = @bulletinID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查发布状态:
	if (@isActive <> 0)
	begin
		set @Ret = 3
		return
	end
	
	delete bulletinInfo where bulletinID = @bulletinID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除公告', '用户' + @delManName
												+ '删除了公告['+ @bulletinID +']。')

GO
--测试：


DROP PROCEDURE updateBulletinInfo
/*
	name:		updateBulletinInfo
	function:	5.更新指定的公告内容或标题
	input: 
				@bulletinID char(12),			--公告编号
				@bulletinTitle nvarchar(100),	--公告标题
				@bulletinTime varchar(10),		--公告日期
				@autoCloseDate varchar(10),		--公告自动关闭日期
				@bulletinHTML nvarchar(max),	--公告内容
				@enableVote smallint,			--是否允许投票：0->允许，1->不允许
				@voteOption xml,				--投票选项
												--N'<root>'+
												--	'<item ID="1" itemDesc="同意" />'+
												--	'<item ID="2" itemDesc="不同意" />'+
												--	'<item ID="3" itemDesc="弃权" />'+
												--'</root>'	

				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要修改的公告不存在，2:要修改的公告正在被别人编辑，3:该公告已发布，4:该公告已经关闭，
							9：未知错误
	author:		卢苇
	CreateDate:	2011-11-24
	UpdateDate: modi by lw 2011-12-4增加公告日期和自动关闭日期参数
				modi by lw 2013-6-21增加是否允许投票接口
				modi by lw 2013-07-12增加投票选项设定
				modi by lw 2013-9-8增加发布状态和关闭状态判断
*/
create PROCEDURE updateBulletinInfo
	@bulletinID char(12),			--公告编号
	@bulletinTitle nvarchar(100),	--公告标题
	@bulletinTime varchar(10),		--公告日期
	@autoCloseDate varchar(10),		--公告自动关闭日期
	@bulletinHTML nvarchar(max),	--公告内容
	@enableVote smallint,			--是否允许投票：0->允许，1->不允许
	@voteOption xml,				--投票选项

	--维护情况:
	@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @isActive int	--是否显示（激活）：0->未激活，1->已激活
	declare @isClosed int	--是否关闭：0->未关闭，1->已关闭
	select @thisLockMan=isnull(lockManID,''), @isActive=isActive, @isClosed=isClosed 
	from bulletinInfo 
	where bulletinID = @bulletinID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查关闭状态：
	if (@isClosed=1)
	begin
		set @Ret = 4
		return
	end
	--检查发布状态:
	if (@isActive <> 0)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	set @updateTime = getdate()
	if (@bulletinTime='')
		set @bulletinTime=CONVERT(varchar(10),@updateTime, 120)

	update bulletinInfo
	set bulletinTitle = @bulletinTitle, bulletinHTML = @bulletinHTML,
		bulletinTime = @bulletinTime, autoCloseDate = @autoCloseDate,
		enableVote = @enableVote, voteOption = @voteOption,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where bulletinID = @bulletinID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '修改公告', '用户' + @modiManName 
												+ '修改了公告['+ @bulletinID +']。')
GO

select * from bulletinInfo where bulletinID='201310240004'
DROP PROCEDURE voteBulletin
/*
	name:		voteBulletin
	function:	6.投票指定的公告
				注意：本过程不检查编辑锁，不登记工作日志，每个人只允许投票一次，后面的投票结果覆盖前面的
	input: 
				@bulletinID char(12),			--公告编号
				@voteResult smallint,			--表决结果：投票选项ID
				@voterID varchar(10),			--投票人ID
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：指定的公告不存在，2:指定的公告不是发布状态
							9：未知错误
	author:		卢苇
	CreateDate:	2013-06-21
	UpdateDate: 增加公告发布状态检查 modi by lw 2013-9-8
*/
create PROCEDURE voteBulletin
	@bulletinID char(12),			--公告编号
	@voteResult smallint,			--表决结果：0->弃权，1->同意，2->不同意
	@voterID varchar(10),			--投票人ID
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查发布状态:
	declare @isActive int	--是否显示（激活）：0->未激活，1->已激活
	select @isActive=isActive
	from bulletinInfo 
	where bulletinID = @bulletinID
	if (@isActive <> 1)
	begin
		set @Ret = 2
		return
	end

	--取投票人的姓名：
	declare @voter nvarchar(30)	--投票人
	set @voter = isnull((select userCName from activeUsers where userID = @voterID),'')
	
	--删除可能存在的历史投票情况：
	begin tran
		delete bulletinVote where bulletinID = @bulletinID and voterID = @voterID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		insert bulletinVote(bulletinID, voterID, voter, voteResult)
		values(@bulletinID, @voterID, @voter, @voteResult)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
	commit tran
	set @Ret = 0
GO


drop PROCEDURE addBulletinDiscuss
/*
	name:		addBulletinDiscuss
	function:	7.添加指定公告的评论
				注意：该存储过程检查编辑锁
	input: 
				@bulletinID char(12),			--公告编号
				@discussTitle nvarchar(100),	--标题：暂时未使用
				@discussHTML nvarchar(4000),	--内容
				@discusserID varchar(10),		--评论人ID
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：指定的公告不存在，2:指定的公告不是发布状态
							9：未知错误
	author:		卢苇
	CreateDate:	2013-06-21
	UpdateDate: 增加公告发布状态检查 modi by lw 2013-9-8
*/
create PROCEDURE addBulletinDiscuss
	@bulletinID char(12),			--公告编号
	@discussTitle nvarchar(100),	--标题：暂时未使用
	@discussHTML nvarchar(4000),	--内容
	@discusserID varchar(10),		--评论人ID

	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	--检查发布状态:
	declare @isActive int	--是否显示（激活）：0->未激活，1->已激活
	select @isActive=isActive
	from bulletinInfo 
	where bulletinID = @bulletinID
	if (@isActive <> 0)
	begin
		set @Ret = 2
		return
	end

	--取评论人的姓名：
	declare @discusser varchar(30)
	set @discusser = isnull((select userCName from activeUsers where userID = @discusserID),'')

	insert bulletinDiscuss(bulletinID, discussTitle, discussHTML, discusserID, discusser)
	values (@bulletinID, @discussTitle, @discussHTML, @discusserID, @discusser)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@discusserID, @discusser, GETDATE(), '公告评论', '用户[' + @discusser + 
					']对公告['+@bulletinID+']发表了一个评论。')
GO
select * from bulletinDiscuss

drop PROCEDURE delBulletinDiscuss
/*
	name:		delBulletinDiscuss
	function:	8.删除指定的公告评论
				注意：本过程不检查编辑锁
	input: 
				@bulletinID char(12),			--公告编号
				@rowNum bigint,					--内部行号
				@delManID varchar(10),			--删除人
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：该公告评论不存在，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-06-21
	UpdateDate:
*/
create PROCEDURE delBulletinDiscuss
	@bulletinID char(12),			--公告编号
	@rowNum bigint,					--内部行号
	@delManID varchar(10),			--删除人
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinDiscuss where bulletinID = @bulletinID and rowNum=@rowNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	delete bulletinDiscuss where bulletinID = @bulletinID and rowNum=@rowNum
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除公告评论', '用户' + @delManName
												+ '删除了公告['+ @bulletinID +']的一个评论。')

GO

drop PROCEDURE closeDieingBulletinInfo
/*
	name:		closeDieingBulletinInfo
	function:	9.自动关闭到期的公告（这个过程是给维护计划调度用，用户不用包装）
	input: 
	output: 
	author:		卢苇
	CreateDate:	2011-11-27
	UpdateDate:
*/
create PROCEDURE closeDieingBulletinInfo
	WITH ENCRYPTION 
AS
	declare @count as int
	set @count=(select count(*) from bulletinInfo 
		where isActive =1 and autoCloseDate is not null and convert(varchar(10),autoCloseDate,120) <= convert(varchar(10),getdate(),120))	
	if (@count = 0)	--不存在
	begin
		return
	end

	declare @updateTime smalldatetime
	set @updateTime=GETDATE()
	update bulletinInfo
	set isActive = 0, orderNum = -1,
		isClosed=1, closedTime=@updateTime, onTop=0
	where isActive =1 and autoCloseDate is not null and convert(varchar(10),autoCloseDate,120) <= convert(varchar(10),getdate(),120)

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values('', 'System', @updateTime, '自动关闭到期公告', '系统执行了自动关闭到期公告的计划关闭了'+cast(@count as varchar(10))+'个到期的公告。')
GO
--测试：
exec dbo.closeDieingBulletinInfo
select * from bulletinInfo where isActive =1
update bulletinInfo
set autoCloseDate = getdate()
where bulletinID='201111260001'


DROP PROCEDURE setBulletinToTop
/*
	name:		setBulletinToTop
	function:	10.将指定的公告置顶
	input: 
				@bulletinID char(12),			--公告编号

				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要置顶的公告不存在，2:要置顶的公告正在被别人编辑，3.该公告未发布，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-9-8
	UpdateDate: 
*/
create PROCEDURE setBulletinToTop
	@bulletinID char(12),			--公告编号

	--维护情况:
	@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @isActive int
	select @thisLockMan = isnull(lockManID,''), @isActive = isActive from bulletinInfo where bulletinID = @bulletinID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查公告状态:
	if (@isActive <> 1)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--将已发布的公告重新排序：
	declare @tab table
					(
						bulletinID char(12) not null,			--主键：公告编号，使用第 10010 号号码发生器产生
						orderNum smallint default(-1)			--显示排序号
					)
	insert @tab
	select bulletinID, orderNum from bulletinInfo 
	where isActive =1 and bulletinID <> @bulletinID
	order by orderNum
	begin tran
		declare @bID char(12), @i int
		set @i = 1
		declare tar cursor for
		select bulletinID from @tab
		order by orderNum
		OPEN tar
		FETCH NEXT FROM tar INTO @bID
		WHILE @@FETCH_STATUS = 0
		begin
			update bulletinInfo
			set orderNum = @i
			where bulletinID = @bID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
			
			set @i = @i + 1
			FETCH NEXT FROM tar INTO @bID
		end
		CLOSE tar
		DEALLOCATE tar
		--将指定的公告置顶：	
		update bulletinInfo
		set orderNum = 0,onTop=1
		where bulletinID = @bulletinID
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
	values(@modiManID, @modiManName, getdate(), '公告置顶', '用户' + @modiManName 
												+ '将公告['+ @bulletinID +']置顶。')
GO
--测试：
select * from bulletinInfo
declare @Ret int 
exec dbo.setBulletinToTop '201111260001', '00200977', @Ret output

DROP PROCEDURE closeBulletinOnTop
/*
	name:		closeBulletinOnTop
	function:	10.1.撤销指定公告的置顶
	input: 
				@bulletinID char(12),			--公告编号

				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要撤销置顶的公告不存在，2:要撤销置顶的公告正在被别人编辑，3.该公告未发布，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-9-8
	UpdateDate: 
*/
create PROCEDURE closeBulletinOnTop
	@bulletinID char(12),			--公告编号

	--维护情况:
	@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @isActive int
	select @thisLockMan = isnull(lockManID,''), @isActive = isActive from bulletinInfo where bulletinID = @bulletinID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查公告状态:
	if (@isActive <> 1)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	update bulletinInfo
	set onTop=0
	where bulletinID = @bulletinID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, getdate(), '撤销公告置顶', '用户' + @modiManName 
												+ '撤销了公告['+ @bulletinID +']置顶。')
GO
--测试：
select * from bulletinInfo
declare @Ret int 
exec dbo.closeBulletinOnTop '201111260001', '00200977', @Ret output

DROP PROCEDURE setBulletinToFirst
/*
	name:		setBulletinToFirst
	function:	10.2.将指定的公告设置为首行显示（不包括置顶公告）
	input: 
				@bulletinID char(12),			--公告编号

				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要设置的公告不存在，2:要设置的公告正在被别人编辑，3.该公告未发布，
							9：未知错误
	author:		卢苇
	CreateDate:	2011-11-27
	UpdateDate: 将置顶和首行显示功能分离重新设计 modi by lw 2013-9-8
*/
create PROCEDURE setBulletinToFirst
	@bulletinID char(12),			--公告编号

	--维护情况:
	@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @isActive int
	select @thisLockMan = isnull(lockManID,''), @isActive = isActive from bulletinInfo where bulletinID = @bulletinID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查公告状态:
	if (@isActive <> 1)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--将已发布的公告重新排序：
	declare @tab table
					(
						bulletinID char(12) not null,			--主键：公告编号，使用第 10010 号号码发生器产生
						orderNum smallint default(-1)			--显示排序号
					)
	insert @tab
	select bulletinID, orderNum from bulletinInfo 
	where isActive =1 and bulletinID <> @bulletinID
	order by orderNum
	begin tran
		declare @bID char(12), @i int
		set @i = 1
		declare tar cursor for
		select bulletinID from @tab
		order by orderNum
		OPEN tar
		FETCH NEXT FROM tar INTO @bID
		WHILE @@FETCH_STATUS = 0
		begin
			update bulletinInfo
			set orderNum = @i
			where bulletinID = @bID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
			
			set @i = @i + 1
			FETCH NEXT FROM tar INTO @bID
		end
		CLOSE tar
		DEALLOCATE tar
		--将指定的公告置顶：	
		update bulletinInfo
		set orderNum = 0
		where bulletinID = @bulletinID
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
	values(@modiManID, @modiManName, getdate(), '公告移动到首行', '用户' + @modiManName 
												+ '将公告['+ @bulletinID +']移动到首行。')
GO
--测试：
select * from bulletinInfo
declare @Ret int 
exec dbo.setBulletinToFirst '201111260001', '00200977', @Ret output

DROP PROCEDURE setBulletinToLast
/*
	name:		setBulletinToLast
	function:	11.将指定的可显示公告上移一行
	input: 
				@bulletinID char(12),			--公告编号

				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要移动的公告不存在，2:要移动的公告正在被别人编辑，3.该公告未发布，
							9：未知错误
	author:		卢苇
	CreateDate:	2011-11-27
	UpdateDate: 
*/
create PROCEDURE setBulletinToLast
	@bulletinID char(12),			--公告编号

	--维护情况:
	@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @isActive int
	declare @myOrderNum smallint --本公告的排序号
	select @thisLockMan = isnull(lockManID,''), @isActive = isActive, @myOrderNum = orderNum from bulletinInfo where bulletinID = @bulletinID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查公告状态:
	if (@isActive <> 1)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--将已发布的位置在本公告前面的公告重新排序：
	declare @tab table
					(
						bulletinID char(12) not null,			--主键：公告编号，使用第 10010 号号码发生器产生
						orderNum smallint default(-1)			--显示排序号
					)
	insert @tab
	select bulletinID, orderNum from bulletinInfo 
	where isActive =1 and orderNum < @myOrderNum
	order by orderNum
	
	begin tran
		declare @bID char(12), @i int
		set @i = 1
		declare tar cursor for
		select bulletinID from @tab
		order by orderNum
		OPEN tar
		FETCH NEXT FROM tar INTO @bID
		WHILE @@FETCH_STATUS = 0
		begin
			update bulletinInfo
			set orderNum = @i
			where bulletinID = @bID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
			
			set @i = @i + 1
			FETCH NEXT FROM tar INTO @bID
		end
		CLOSE tar
		DEALLOCATE tar
		--将指定的公告上移一行：	
		update bulletinInfo
		set orderNum = @i
		where bulletinID = @bID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		update bulletinInfo
		set orderNum = @i - 1
		where bulletinID = @bulletinID
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
	values(@modiManID, @modiManName, getdate(), '公告上移一行', '用户' + @modiManName 
												+ '将公告['+ @bulletinID +']上移了一行。')
GO
--测试：
select * from bulletinInfo 
where isActive =1 
order by orderNum

declare @updateTime smalldatetime 
declare @Ret int 
exec dbo.setBulletinToLast '201111270001', '00200977', @Ret output

DROP PROCEDURE setBulletinToNext
/*
	name:		setBulletinToNext
	function:	12.将指定的可显示公告下移一行
	input: 
				@bulletinID char(12),			--公告编号

				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要移动的公告不存在，2:要移动的公告正在被别人编辑，3.该公告未发布，
							9：未知错误
	author:		卢苇
	CreateDate:	2011-11-27
	UpdateDate: 
*/
create PROCEDURE setBulletinToNext
	@bulletinID char(12),			--公告编号

	--维护情况:
	@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @isActive int
	declare @myOrderNum smallint --本公告的排序号
	select @thisLockMan = isnull(lockManID,''), @isActive = isActive, @myOrderNum = orderNum from bulletinInfo where bulletinID = @bulletinID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查公告状态:
	if (@isActive <> 1)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--将本公告与下一个公告交换位置：
	declare @nextBulletinID char(12), @nextOrderNum smallint
	select top 1 @nextBulletinID = bulletinID, @nextOrderNum = orderNum 
	from bulletinInfo 
	where isActive =1 and orderNum > @myOrderNum
	order by orderNum
	
	if (@nextBulletinID is not null)
	begin
		begin tran
			update bulletinInfo 
			set orderNum = @nextOrderNum
			where bulletinID = @bulletinID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    

			update bulletinInfo 
			set orderNum = @myOrderNum
			where bulletinID = @nextBulletinID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
		commit tran
	end
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, getdate(), '公告下移一行', '用户' + @modiManName 
												+ '将公告['+ @bulletinID +']下移了一行。')
GO
--测试：
select * from bulletinInfo 
where isActive =1 
order by orderNum

declare @updateTime smalldatetime 
declare @Ret int 
exec dbo.setBulletinToNext '201111270001', '00200977', @Ret output

drop PROCEDURE queryBulletinLocMan
/*
	name:		queryBulletinLocMan
	function:	13.查询指定公告是否有人正在编辑
	input: 
				@bulletinID char(12),			--公告号,使用10010号号码发生器产生
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的公告不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2011-11-27
	UpdateDate: 
*/
create PROCEDURE queryBulletinLocMan
	@bulletinID char(12),			--公告号,使用10010号号码发生器产生
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from bulletinInfo where bulletinID = @bulletinID),'')
	set @Ret = 0
GO


drop PROCEDURE lockBulletin4Edit
/*
	name:		lockBulletin4Edit
	function:	14.锁定公告开始编辑，避免编辑冲突
	input: 
				@bulletinID char(12),			--公告号,使用10010号号码发生器产生
				@lockManID varchar(10) output,	--锁定人，如果当前公告正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的公告不存在，2:要锁定的公告正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2011-11-27
	UpdateDate: 
*/
create PROCEDURE lockBulletin4Edit
	@bulletinID char(12),			--公告号,使用10010号号码发生器产生
	@lockManID varchar(10) output,	--锁定人，如果当前公告正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from bulletinInfo where bulletinID = @bulletinID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	update bulletinInfo
	set lockManID = @lockManID 
	where bulletinID = @bulletinID
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定公告编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了公告['+ @bulletinID +']为独占式编辑。')
GO

drop PROCEDURE unlockBulletinEditor
/*
	name:		unlockBulletinEditor
	function:	15.释放公告编辑锁
				注意：本过程不检查单据是否存在！
	input: 
				@bulletinID char(12),			--公告号,使用10010号号码发生器产生
				@lockManID varchar(10) output,	--锁定人，如果当前公告正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2011-11-27
	UpdateDate: 
*/
create PROCEDURE unlockBulletinEditor
	@bulletinID char(12),			--公告号,使用10010号号码发生器产生
	@lockManID varchar(10) output,	--锁定人，如果当前公告正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from bulletinInfo where bulletinID = @bulletinID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update bulletinInfo set lockManID = '' where bulletinID = @bulletinID
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
	values(@lockManID, @lockManName, getdate(), '释放公告编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了公告['+ @bulletinID +']的编辑锁。')
GO

drop PROCEDURE addResource
/*
	name:		20.addResource
	function:	添加资源文件
				注意：该存储过程不登记工作日志
	input: 
				@resouceName nvarchar(30),	--资源名称
				@resouceType smallint,		--资源类型：1->图片，2->影音文件
				@oldFilename varchar(128),	--资源文件原始文件名
				@extFileName varchar(8),	--资源文件文件扩展名
				@notes nvarchar(100),		--说明
				@ownerID varchar(10),		--所有人工号
				@isShare char(1),			--是否共享
	output: 
				@Ret		int output,	--操作成功标识
							0:成功，9：未知错误
				@fileGUID36 varchar(36) output	--系统分配的资源文件36位全球唯一编码文件名
	author:		卢苇
	CreateDate:	2011-11-27
	UpdateDate: 
*/
create PROCEDURE addResource
	@resouceName nvarchar(30),	--资源名称
	@resouceType smallint,		--资源类型：1->图片，2->影音文件
	@oldFilename varchar(128),	--资源文件原始文件名
	@extFileName varchar(8),	--资源文件文件扩展名
	@notes nvarchar(100),		--说明
	@ownerID varchar(10),		--所有人工号
	@isShare char(1),			--是否共享

	@Ret int output,			--操作成功标识
	@fileGUID36 varchar(36) output	--系统分配的资源文件36位全球唯一编码文件名
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--取所有人姓名：
	declare @ownerName varchar(30)		--所有人姓名
	set @ownerName = isnull((select userCName from activeUsers where userID = @ownerID),'')

	--生成唯一的文件名：
	set @fileGUID36 = (select newid())

	--登记资源信息：
	insert bulletinResouce(resouceName, resouceType, fileGUID36, oldFilename, extFileName,
							notes, ownerID, ownerName, isShare)
	values(@resouceName, @resouceType, @fileGUID36, @oldFilename, @extFileName,
							@notes, @ownerID, @ownerName, @isShare)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end   

	set @Ret = 0
GO


drop PROCEDURE delResource
/*
	name:		delResource
	function:	21.删除指定的资源文件
				注意：该存储过程不登记工作日志，也不删除文件！
	input: 
				@fileGUID36 varchar(36),	--资源文件名称
				@delManID varchar(10),		--删除人
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：未知错误
	author:		卢苇
	CreateDate:	2011-11-27
	UpdateDate: 

*/
create PROCEDURE delResource
	@fileGUID36 varchar(36),	--资源文件名称
	@delManID varchar(10),		--删除人
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	delete bulletinResouce where fileGUID36 = @fileGUID36
	set @Ret = 0
GO

