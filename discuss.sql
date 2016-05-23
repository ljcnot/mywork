use PM100
/*
	版块管理系统--论坛管理
	备注：移植自公司网站--论坛管理
	author:	卢嘉城
	CreateDate:	2013-8-25
	UpdateDate: 
*/
--1.论坛版块表：
select * from discussSection

drop table discussSection
create table discussSection
(
	sectionID varchar(12) not null,		--主键：版块编号：由第20号号码发生器
	sectionType int default(1),			--版块类别：1->技术论坛，2->产品论坛
	sectionName nvarchar(30) not null,	--版块名称（产品名称）
	sectionDesc  nvarchar(300) null,	--版块介绍（产品简介）
	sectionLogo varchar(128) null,		--版块logo
	sectionManagerID varchar(12) null,	--版主ID
	sectionManager nvarchar(30) not null,--版主姓名
	isClosed smallint default(1),		--是否关闭：0->正常，1->关闭
	closeDate smalldatetime default(getdate()),		--关闭日期

	--最新维护情况:
	createDate smalldatetime default(getdate()),	--创建日期
	createrID varchar(10) null,			--创建人ID
	creater nvarchar(30) null,			--创建人姓名
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10)				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_discussSection] PRIMARY KEY CLUSTERED 
(
	[sectionID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

select 	sectionID, sectionType, sectionName, sectionDesc, isnull(sectionLogo,''),
	sectionManagerID, sectionManager,convert(varchar(19),createTime,120) createTime,
	isClosed, convert(varchar(19),isnull(closeDate,''),120) closeDate,
	--最新维护情况:
	convert(varchar(19),createDate,120) createDate,createrID,creater,
	modiManID, modiManName, convert(varchar(19),isnull(modiTime,''),120) modiTime,
	--编辑锁定人：
	isnull(lockManID,'')
from discussSection

--2.论坛主题表（帖子）：
drop table discussTopic
create table discussTopic
(
	sectionID varchar(12) not null,		--外键/主键：版块编号
	topicID varchar(13) not null,		--主键：主题编号：由第21号号码发生器定义
	title nvarchar(100)not null,		--标题
	topicDesc nvarchar(4000) null,		--主题描述
	authorID varchar(12) null,			--作者ID
	author nvarchar(30) null,			--作者
	createDate smalldatetime default(getdate()),	--创建日期
	viewNum int null,					--查看次数
	isBoutique int null,				--是否精华贴 0-->不是  1-->是
	sequence int null,                  --排序
	isTop int default(0),				--是否置顶：0->不置顶，1->置顶
	isRecommend int default(0),			--是否推荐：0->普通，1->推荐
	
 CONSTRAINT [PK_discussTopic] PRIMARY KEY CLUSTERED 
(
	[sectionID] ASC,
	[topicID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--外键：
ALTER TABLE [dbo].[discussTopic] WITH CHECK ADD CONSTRAINT [FK_discussTopic_discussSection] FOREIGN KEY([sectionID])
REFERENCES [dbo].[discussSection] ([sectionID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[discussTopic] CHECK CONSTRAINT [FK_discussTopic_discussSection]
GO
--索引：
CREATE NONCLUSTERED INDEX [IX_discussTopic] ON [dbo].[discussTopic]
(
	[sequence] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_discussTopic_1] ON [dbo].[discussTopic] 
(
	[authorID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

select * from discussTopic
select sectionID, topicID, rowNum, replyContent, replyTime, authorID, authorName
from discussReply


select * from discussReply
--3.论坛版块主题跟帖（回复）表：
drop table discussReply
create table discussReply
(
	sectionID varchar(12) not null,		--外键/主键：版块编号
	topicID varchar(13) not null,		--外键/主键：议题编号
	replyID varchar(16) not null,		--主键：回复编号
	replyContent nvarchar(4000) null,	--内容
	replyTime datetime default(getdate()),--发表时间
	authorID varchar(10) null,			--发表人ID
	authorName varchar(30) null,		--发表人姓名
CONSTRAINT [PK_discussReply] PRIMARY KEY CLUSTERED 
(
	[sectionID] ASC,
	[topicID] ASC,
	[replyID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--外键：
ALTER TABLE [dbo].[discussReply] WITH CHECK ADD CONSTRAINT [FK_discussReply_discussTopic] FOREIGN KEY([sectionID],[topicID])
REFERENCES [dbo].[discussTopic] ([sectionID],[topicID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[discussReply] CHECK CONSTRAINT [FK_discussReply_discussTopic]
GO


--4.论坛版块、主题（帖子）、跟帖（回复）附件表：
drop table discussAttach
create table discussAttach
(
	sectionID varchar(12) not null,		--外键/主键：版块编号
	topicID varchar(13) default(''),	--外键/主键：议题编号
	replyID varchar(16) default(''),	--外键/主键：回复编号
	rowNum bigint IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,--主键:行号
	aFilename varchar(128) null,		--原始文件名
	uidFilename varchar(128) not null,	--UID文件名
	title nvarchar(32) null,			--标题
	fileSize bigint null,				--文件尺寸
	fileType varchar(10),				--文件类型
	uploadTime smalldatetime default(getdate()),	--上传日期
	fileLog varchar(128) null,			--文件log：如果没有没有定义，则使用默认的文件类型LOG
 CONSTRAINT [PK_discussAttach] PRIMARY KEY CLUSTERED 
(
	[sectionID] ASC,
	[topicID] ASC,
	[replyID] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--外键：
ALTER TABLE [dbo].[discussAttach]  WITH CHECK ADD  CONSTRAINT [FK_discussAttach_discussSection] FOREIGN KEY([sectionID])
REFERENCES [dbo].[discussSection] ([sectionID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[discussAttach] CHECK CONSTRAINT [FK_discussAttach_discussSection]
GO



select * from discussAttach
--5.两个重要的查询视图：
--论坛板块概况视图(板块信息+主题（帖子）数+回复数+最新发表+今日发帖)：
drop view discussOverview
create view discussOverview
as
	select ds.isClosed, isnull(convert(varchar(19),ds.closeDate,120),'') closeDate, ds.sectionID, ds.sectionName,ds.sectionType, ds.sectionDesc, 
		ds.sectionLogo, ds.sectionManagerID,ds.sectionManager, 
		convert(varchar(19),ds.createDate,120) createDate, 
		--统计：主题（帖子）总数、回复总数
		isnull(t.topics,0) topics, isnull(r.replys,0) replys,
		--最新回复：
		isnull(dr.topicID,'') topicID, isnull(dr.replyID,'') replyID,isnull(dr.replyContent,'') replyContent, 
		isnull(convert(varchar(19),dr.replyTime,120),'') replyTime, isnull(dr.authorID,'') authorID, isnull(dr.authorName,'') authorName, 
		--今日回复总数：
		isnull(dc.dCount,0) dCount,
		--附件：
		dbo.getDiscussAttach(ds.sectionID,'','') attachMent
	from discussSection ds left join (select sectionID, count(*) topics from discussTopic group by sectionID) t on ds.sectionID= t.sectionID
	left join (select sectionID, count(*) replys from discussReply group by sectionID) r on ds.sectionID= r.sectionID
	left join (select d.sectionID, d.topicID, d.replyID, d.replyContent, d.replyTime, d.authorID, d.authorName
				from discussReply d right join 
					(select sectionID, max(replyID) rowNum
					 from discussReply
					 group by sectionID) m on d.replyID=m.rowNum) dr on ds.sectionID = dr.sectionID
	left join (select sectionID, count(*) dCount from discussReply
				where convert(varchar(10),replyTime,120)=CONVERT(varchar(10),getdate(),120)
				group by sectionID) dc on ds.sectionID = dc.sectionID
go

select * from discussOverview

--论坛板块主题概况（主题（帖子）信息+最新回复+今日回帖数+附件）视图：
drop view discussTopicOverview
create view discussTopicOverview
as
	select dt.sectionID, ds.sectionName,ds.sectionManager,dt.topicID, dt.title, dt.topicDesc, 
			convert(varchar(10),dt.createDate,120) createDate,dt.authorID, dt.author,
			dt.viewNum,isnull(r.replyNum,0) replyNum, dt.isBoutique, dt.sequence,
			dt.isTop, dt.isRecommend,
			--最新回复：
			isnull(dr.replyID,'') replyID, isnull(dr.replyContent,'') replyContent, 
			isnull(convert(varchar(19),dr.replyTime,120),'') replyTime, 
			isnull(dr.authorID,'') replyAuthorID, isnull(dr.authorName,'') replyAuthorName,
			--今日回复总数：
			isnull(dc.dCount,0) dCount,
			--附件：
			dbo.getDiscussAttach(dt.sectionID,dt.topicID,'') attachMent
	from discussTopic dt
	left join (select d.sectionID, d.topicID, d.replyID, d.replyContent, d.replyTime, d.authorID, d.authorName
				from discussReply d right join 
					(select sectionID, topicID, max(replyID) rowNum
					from discussReply
					group by sectionID, topicID) m on d.replyID=m.rowNum) dr on dt.sectionID = dr.sectionID and dt.topicID=dr.topicID
	left join (select sectionID,sectionName,sectionManager from discussSection) ds on dt.sectionID=ds.sectionID
	left join (select topicID, count(*) replyNum from discussReply group by topicID) r on dt.topicID= r.topicID
	left join (select topicID, count(*) dCount from discussReply
				where convert(varchar(10),replyTime,120)=CONVERT(varchar(10),getdate(),120)
				group by topicID) dc on dt.topicID= dc.topicID
go

select * from discussTopicOverview

drop procedure addDiscussSection
/*
	name:		addDiscussSection
	function:	1.添加论坛版块
				注意：该存储过程不锁定论坛
	input: 
				@sectionType int,			--版块类别：1->技术论坛，2->产品论坛
				@sectionName nvarchar(30),	--版块名称（产品名称）
				@sectionDesc nvarchar(300),	--版块介绍（产品简介）
				@sectionLogo varchar(128),	--版块logo
				@sectionManagerID varchar(12),	--版主ID

				--最新维护情况:
				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output,			--操作成功标识
												0:成功，9:未知错误
				@sectionID varchar(12) output,	--版块编号
	author:		卢苇
	CreateDate:	2015-11-1
	UpdateDate: 

*/
create procedure addDiscussSection
	@sectionType int,			--版块类别：1->技术论坛，2->产品论坛
	@sectionName nvarchar(30),	--版块名称
	@sectionDesc nvarchar(300),	--版块介绍
	@sectionLogo varchar(128),	--版块logo
	@sectionManagerID varchar(12),	--版主ID

	--最新维护情况:
	@createManID varchar(10),		--创建人工号
	
	@Ret		int output,			--操作成功标识
	@sectionID varchar(12) output	--版块编号
as
begin
	set @Ret = 9
	--由20号号码发生器获取sectionID
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 20, 1, @curNumber output
	set @sectionID = @curNumber

	--取版主\创建人姓名：
	declare @sectionManager nvarchar(30),@createManName nvarchar(30)
	set @sectionManager = isnull((select cName from userInfo where userID = @sectionManagerID),'')
	set @createManName = isnull((select cName from userInfo where userID = @createManID),'')
		
	declare @createTime smalldatetime
	set @createTime = getdate()
	insert into discussSection(sectionID, sectionType, sectionName, sectionDesc, sectionLogo, 
				sectionManagerID, sectionManager, 
				--最新维护情况:
				createDate, createrID, creater, modiManID, modiManName, modiTime)
	values(@sectionID, @sectionType, @sectionName, @sectionDesc, @sectionLogo, 
			@sectionManagerID, @sectionManager, 
			--最新维护情况:
			@createTime, @createManID, @createManName, @createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, 
								'添加论坛版块','系统根据' + @createManName + 
								'的要求添加了论坛版块[' + @sectionName + ']的信息。')
end
--测试：
declare @Ret int, @sectionID varchar(12)
exec dbo.addDiscussSection 1,'友道办公系统公共开发平台-设计讨论',
'友道办公系统公共开发平台 是在我公司开发的《设备管理系统》、《外贸合同管理系统》、《实验室OA办公系统》等办公系统基础上统一接口，重新规划设计组织机构管理、用户管理，增强 客户关系管理、人事管理，新增开发版块管理、财务管理等半系统的一整套办公系统常用的服务集。并提供完整的开发接口手册和一步一步（Step By Step）教程。
　　本平台积木式的堆叠开发，大大降低了web办公系统的开发难度，缩减了开发时间，节约了开发费用。
　　本版块是该平台开发计划中的设计思路讨论区，欢迎大家在此讨论本计划的设计思路。',
'images/productdeveloping_new.gif','U201510004','U201510004', @Ret output, @sectionID output
select @Ret, @sectionID

select * from discussSection
update discussSection
set sectionName='友道办公系统公共开发平台-设计讨论'
where sectionid='S20151105005'

declare @Ret int, @sectionID varchar(12)
exec dbo.addDiscussSection 1,'友道办公系统公共开发平台-进度监督',
'友道办公系统公共开发平台 是在我公司开发的《设备管理系统》、《外贸合同管理系统》、《实验室OA办公系统》等办公系统基础上统一接口，重新规划设计组织机构管理、用户管理，增强 客户关系管理、人事管理，新增开发版块管理、财务管理等半系统的一整套办公系统常用的服务集。并提供完整的开发接口手册和一步一步（Step By Step）教程。
　　本平台积木式的堆叠开发，大大降低了web办公系统的开发难度，缩减了开发时间，节约了开发费用。
　　本版块是该平台开发计划中的进度监督讨论区，欢迎大家在此讨论本计划的实施问题。',
'images/bbsbig.jpg','U201510004','U201510004', @Ret output, @sectionID output
select @Ret, @sectionID

declare @Ret int, @sectionID varchar(12)
exec dbo.addDiscussSection 1,'友道办公系统公共开发平台-前台开发问题讨论',
'友道办公系统公共开发平台 是在我公司开发的《设备管理系统》、《外贸合同管理系统》、《实验室OA办公系统》等办公系统基础上统一接口，重新规划设计组织机构管理、用户管理，增强 客户关系管理、人事管理，新增开发版块管理、财务管理等半系统的一整套办公系统常用的服务集。并提供完整的开发接口手册和一步一步（Step By Step）教程。
　　本平台积木式的堆叠开发，大大降低了web办公系统的开发难度，缩减了开发时间，节约了开发费用。
　　本版块是该平台的前台开发技术讨论区，欢迎大家在此讨论本平台前台开发问题。',
'images/webDeveloping.jpg','U201510004','U201510004', @Ret output, @sectionID output
select @Ret, @sectionID

select * from userInfo

delete discussSection
select * from discussSection
select * from workNote
  
 
drop PROCEDURE queryDiscussSectionLocMan
/*
	name:		queryDiscussSectionLocMan
	function:	2.查询指定版块是否有人正在编辑
	input: 
				@sectionID varchar(12),		--版块编号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的版块不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2015-11-1
	UpdateDate: 
*/
create PROCEDURE queryDiscussSectionLocMan
	@sectionID varchar(12),		--版块编号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from discussSection where sectionID = @sectionID),'')
	set @Ret = 0
GO


drop PROCEDURE lockDiscussSection4Edit
/*
	name:		lockDiscussSection4Edit
	function:	3.锁定版块编辑，避免编辑冲突
	input: 
				@sectionID varchar(12),			--版块编号
				@lockManID varchar(10) output,	--锁定人，如果当前版块正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
												0:成功，1：要锁定的版块不存在，2:要锁定的版块正在被别人编辑，
												9：未知错误
	author:		卢苇
	CreateDate:	2015-11-1
	UpdateDate: 
*/
create PROCEDURE lockDiscussSection4Edit
	@sectionID varchar(12),			--版块编号
	@lockManID varchar(10) output,	--锁定人，如果当前版块正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的版块是否存在
	declare @count as int
	set @count=(select count(*) from discussSection where sectionID = @sectionID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from discussSection where sectionID = @sectionID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update discussSection
	set lockManID = @lockManID 
	where sectionID = @sectionID
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定版块编辑', '系统根据用户' + @lockManName
												+ '的要求锁定编号为：[' + @sectionID + ']的版块为独占式编辑。')
GO

drop PROCEDURE unlockDiscussSectionEditor
/*
	name:		unlockDiscussSectionEditor
	function:	4.释放版块编辑锁
				注意：本过程不检查版块是否存在！
	input: 
				@sectionID varchar(12),			--版块编号
				@lockManID varchar(10) output,	--锁定人，如果当前版块正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2015-11-1
	UpdateDate: 
*/
create PROCEDURE unlockDiscussSectionEditor
	@sectionID varchar(12),			--版块编号
	@lockManID varchar(10) output,	--锁定人，如果当前版块正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from discussSection where sectionID = @sectionID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update discussSection set lockManID = '' where sectionID = @sectionID
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
	values(@lockManID, @lockManName, getdate(), '释放版块编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了编号为：[' + @sectionID + ']的版块的编辑锁。')
GO

drop PROCEDURE delDiscussSection
/*
	name:		delDiscussSection
	function:	5.删除指定的论坛版块
	input: 
				@sectionID varchar(12),			--版块编号
				@delManID varchar(10) output,	--删除人，如果当前版块正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
												0:成功，1：指定的版块不存在，2：要删除的版块正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2015-11-1
	UpdateDate: 

*/
create PROCEDURE delDiscussSection
	@sectionID varchar(12),			--版块编号
	@delManID varchar(10) output,	--删除人，如果当前版块正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的版块是否存在
	declare @count as int
	set @count=(select count(*) from discussSection where sectionID = @sectionID)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from discussSection where sectionID = @sectionID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete discussSection where sectionID = @sectionID
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除版块', '用户' + @delManName
												+ '删除了编号为：[' + @sectionID + ']的版块。')
GO

drop procedure updateDiscussSection
/*
	name:		updateDiscussSection
	function:	6.更新论坛版块
	input: 
				@sectionID varchar(12),		--版块编号
				@sectionType int,			--版块类别：1->技术论坛，2->产品论坛
				@sectionName nvarchar(30),	--版块名称（产品名称）
				@sectionDesc nvarchar(300),	--版块介绍（产品简介）
				@sectionLogo varchar(128),	--版块logo
				@sectionManagerID varchar(12),	--版主ID

				--最新维护情况:
				@modiManID varchar(10) output,	--维护人工号：如果由别人占用，则返回占用人工号
	output: 
				@Ret		int output			--操作成功标识
												0:成功，1:该版块不存在，2：该版块正被别人锁定编辑，9:未知错误
	author:		卢苇
	CreateDate:	2015-11-1
	UpdateDate: 

*/
create procedure updateDiscussSection
	@sectionID varchar(12),		--版块编号
	@sectionType int,			--版块类别：1->技术论坛，2->产品论坛
	@sectionName nvarchar(30),	--版块名称
	@sectionDesc nvarchar(300),	--版块介绍
	@sectionLogo varchar(128),	--版块logo
	@sectionManagerID varchar(12),	--版主ID

	--最新维护情况:
	@modiManID varchar(10) output,	--维护人工号
	@Ret		int output			--操作成功标识
as
begin
	set @Ret = 9

	--判断指定的版块是否存在
	declare @count as int
	set @count=(select count(*) from discussSection where sectionID = @sectionID)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from discussSection where sectionID = @sectionID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--取版主\维护人姓名：
	declare @sectionManager nvarchar(30),@modiManName nvarchar(30)
	set @sectionManager = isnull((select cName from userInfo where userID = @sectionManagerID),'')
	set @modiManName = isnull((select cName from userInfo where userID = modiManID),'')
		
	declare @updateTime smalldatetime
	set @updateTime = getdate()
	update discussSection
	set sectionType = @sectionType, 
		sectionName = @sectionName, 
		sectionDesc = @sectionDesc, 
		sectionLogo = @sectionLogo, 
		sectionManagerID = @sectionManagerID, 
		sectionManager = @sectionManager, 
		--最新维护情况:
		modiManID = @modiManID, 
		modiManName = @modiManName, 
		modiTime = @updateTime
	where sectionID= @sectionID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, 
								'修改论坛版块','系统根据' + @modiManName + 
								'的要求修改了论坛版块[' + @sectionID + ']的信息。')
end
--测试：

drop procedure changeDiscussSectionManager
/*
	name:		changeDiscussSectionManager
	function:	6.1.更换版主
	input: 
				@sectionID varchar(12),		--版块编号
				@sectionManagerID varchar(12),	--版主ID

				--最新维护情况:
				@modiManID varchar(10) output,	--维护人工号：如果由别人占用，则返回占用人工号
	output: 
				@Ret		int output			--操作成功标识
												0:成功，1:该版块不存在，2：该版块正被别人锁定编辑，9:未知错误
	author:		卢苇
	CreateDate:	2015-11-1
	UpdateDate: 

*/
create procedure changeDiscussSectionManager
	@sectionID varchar(12),		--版块编号
	@sectionManagerID varchar(12),	--版主ID

	--最新维护情况:
	@modiManID varchar(10) output,	--维护人工号
	@Ret		int output			--操作成功标识
as
begin
	set @Ret = 9

	--判断指定的版块是否存在
	declare @count as int
	set @count=(select count(*) from discussSection where sectionID = @sectionID)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from discussSection where sectionID = @sectionID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--取版主\维护人姓名：
	declare @sectionManager nvarchar(30),@modiManName nvarchar(30)
	set @sectionManager = isnull((select cName from userInfo where userID = @sectionManagerID),'')
	set @modiManName = isnull((select cName from userInfo where userID = modiManID),'')
		
	declare @updateTime smalldatetime
	set @updateTime = getdate()
	update discussSection
	set sectionManagerID = @sectionManagerID, 
		sectionManager = @sectionManager, 
		--最新维护情况:
		modiManID = @modiManID, 
		modiManName = @modiManName, 
		modiTime = @updateTime
	where sectionID= @sectionID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, 
								'更换版主','系统根据' + @modiManName + 
								'的要求更换了版块[' + @sectionID + ']的版主。')
end

drop procedure changeDiscussSectionLogo
/*
	name:		changeDiscussSectionLogo
	function:	6.2.更换版块图标
	input: 
				@sectionID varchar(12),		--版块编号
				@sectionLogo varchar(128),	--版块logo

				--最新维护情况:
				@modiManID varchar(10) output,	--维护人工号：如果由别人占用，则返回占用人工号
	output: 
				@Ret		int output			--操作成功标识
												0:成功，1:该版块不存在，2：该版块正被别人锁定编辑，9:未知错误
	author:		卢苇
	CreateDate:	2015-11-14
	UpdateDate: 

*/
create procedure changeDiscussSectionLogo
	@sectionID varchar(12),		--版块编号
	@sectionLogo varchar(128),	--版块logo

	--最新维护情况:
	@modiManID varchar(10) output,	--维护人工号
	@Ret		int output			--操作成功标识
as
begin
	set @Ret = 9

	--判断指定的版块是否存在
	declare @count as int
	set @count=(select count(*) from discussSection where sectionID = @sectionID)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from discussSection where sectionID = @sectionID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--取版主\维护人姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select cName from userInfo where userID = modiManID),'')
		
	declare @updateTime smalldatetime
	set @updateTime = getdate()
	update discussSection
	set sectionLogo = @sectionLogo,
		--最新维护情况:
		modiManID = @modiManID, 
		modiManName = @modiManName, 
		modiTime = @updateTime
	where sectionID= @sectionID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, 
								'更换版块图标','系统根据' + @modiManName + 
								'的要求更换了版块[' + @sectionID + ']的图标。')
end

drop PROCEDURE closeDiscussSection
/*
	name:		closeDiscussSection
	function:	7.关闭指定的论坛版块
	input: 
				@sectionID varchar(12),			--版块编号
				@closeManID varchar(10) output,	--关闭人，如果当前版块正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
												0:成功，1：指定的版块不存在，2：要关闭的版块正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2015-11-4
	UpdateDate: 

*/
create PROCEDURE closeDiscussSection
	@sectionID varchar(12),			--版块编号
	@closeManID varchar(10) output,	--关闭人，如果当前版块正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的版块是否存在
	declare @count as int
	set @count=(select count(*) from discussSection where sectionID = @sectionID)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from discussSection where sectionID = @sectionID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @closeManID)
	begin
		set @closeManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--取维护人的姓名：
	declare @closeManName nvarchar(30)
	set @closeManName = isnull((select userCName from activeUsers where userID = @closeManID),'')

	declare @closeDate smalldatetime
	set @closeDate = getdate()
	update discussSection 
	set isClosed = 1, closeDate = @closeDate,
		--最新维护情况:
		modiManID = @closeManID, 
		modiManName = @closeManName, 
		modiTime = @closeDate
	where sectionID = @sectionID
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@closeManID, @closeManName, @closeDate, '关闭版块', '用户' + @closeManName
												+ '关闭了编号为：[' + @sectionID + ']的版块。')
GO

drop PROCEDURE openDiscussSection
/*
	name:		openDiscussSection
	function:	7.开放指定的论坛版块
	input: 
				@sectionID varchar(12),			--版块编号
				@openManID varchar(10) output,	--开放人，如果当前版块正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
												0:成功，1：指定的版块不存在，2：要开放的版块正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2015-11-4
	UpdateDate: 

*/
create PROCEDURE openDiscussSection
	@sectionID varchar(12),			--版块编号
	@openManID varchar(10) output,	--开放人，如果当前版块正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的版块是否存在
	declare @count as int
	set @count=(select count(*) from discussSection where sectionID = @sectionID)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from discussSection where sectionID = @sectionID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @openManID)
	begin
		set @openManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--取维护人的姓名：
	declare @openManName nvarchar(30)
	set @openManName = isnull((select userCName from activeUsers where userID = @openManID),'')

	declare @openDate smalldatetime
	set @openDate = getdate()
	update discussSection 
	set isClosed = 0, closeDate = null,
		--最新维护情况:
		modiManID = @openManID, 
		modiManName = @openManName, 
		modiTime = @openDate
	where sectionID = @sectionID
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@openManID, @openManName, @openDate, '开放版块', '用户' + @openManName
												+ '开放了编号为：[' + @sectionID + ']的版块。')
GO

drop PROCEDURE addDiscussAttachment
/*
	name:		8.addDiscussAttachment
	function:	添加附件
				@sectionID varchar(12),		--版块编号
				@topicID varchar(13),		--主题编号
				@replyID varchar(16),		--跟帖行号
				@aFilename varchar(128),	--原始文件名
				@uidFilename varchar(128),	--UID文件名
				@title nvarchar(32),		--标题
				@fileSize bigint,			--文件尺寸
				@fileType varchar(10),		--文件类型
				@fileLog varchar(128),		--文件log：如果没有没有定义，则使用默认的文件类型LOG
	output: 
				@Ret		int output		--操作成功标识
										0:成功，9：未知错误
	author:		卢苇
	CreateDate:	2015-11-5
	UpdateDate: 
*/
create PROCEDURE addDiscussAttachment
	@sectionID varchar(12),		--版块编号
	@topicID varchar(13),		--主题编号
	@replyID varchar(16),		--跟帖行号
	@aFilename varchar(128),	--原始文件名
	@uidFilename varchar(128),	--UID文件名
	@title nvarchar(32),		--标题
	@fileSize bigint,			--文件尺寸
	@fileType varchar(10),		--文件类型
	@fileLog varchar(128),		--文件log：如果没有没有定义，则使用默认的文件类型LOG
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	insert into discussAttach(sectionID, topicID, replyID,
			aFilename, uidFilename, title, fileSize, fileType, uploadTime, fileLog)
	values(@sectionID, @topicID, @replyID,
			@aFilename, @uidFilename, @title, @fileSize, @fileType, getdate(), @fileLog)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
GO

drop PROCEDURE delDiscussAttachment
/*
	name:		delDiscussAttachment
	function:	9.删除指定UID的附件
	input: 
				@uidFilename varchar(128),	--UID文件名
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：指定的附件不存在，9：未知错误
	author:		卢苇
	CreateDate:	2015-11-5
	UpdateDate: 
*/
create PROCEDURE delDiscussAttachment
	@uidFilename varchar(128),	--UID文件名
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--判断指定的附件是否存在
	declare @count as int
	set @count=(select count(*) from discussAttach where uidFilename = @uidFilename)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	delete discussAttach where uidFilename = @uidFilename
	
	set @Ret = 0
GO

drop PROCEDURE clearDiscussAttachment
/*
	name:		clearDiscussAttachment
	function:	10.清除指定板块、主题、回复的全部附件
				注意：本函数不检查是否有附件
	input: 
				@sectionID varchar(12),		--版块编号
				@topicID varchar(13),		--主题编号
				@replyID varchar(16),		--跟帖行号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：未知错误
	author:		卢苇
	CreateDate:	2015-11-5
	UpdateDate: 
*/
create PROCEDURE clearDiscussAttachment
	@sectionID varchar(12),		--版块编号
	@topicID varchar(13),		--主题编号
	@replyID varchar(16),		--跟帖行号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	delete discussAttach where sectionID= @sectionID and isnull(topicID,'') = @topicID and isnull(replyID,'') = @replyID

	set @Ret = 0
GO

select * from discussAttach
------------------------------------------------------------------------------------------


drop procedure addDiscussTopic
/*
	name:		addDiscussTopic
	function:	11.添加讨论主题
				注意：这个存储过程不填写工作日志
	input: 
				@sectionID varchar(12),			--版块编号
				@title varchar(100),			--标题
				@topicDesc nvarchar(4000),		--主题描述
				@authorID varchar(12),			--作者ID
	output: 
				@Ret		int output,			--操作成功标识
												0:成功，9:未知错误
				@topicID varchar(13) output		--主题编号
	author:		卢嘉城
	CreateDate:	2013-8-25
	UpdateDate: 

*/
create procedure addDiscussTopic
	@sectionID varchar(12),			--版块编号
	@title varchar(100),			--标题
	@topicDesc nvarchar(4000),		--主题描述
	@authorID varchar(12),			--作者ID
	@Ret int output,				--操作成功标识
	@topicID varchar(13) output		--主题编号
as
begin
	set @Ret = 9
	--由21号号码发生器获取topicID
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 21, 1, @curNumber output
	set @topicID = @curNumber

	--取发表人的姓名：
	declare @authorName varchar(30)
	if (@authorID is not null and @authorID!='')
		set @authorName = isnull((select cName from userInfo where userID = @authorID),'')
	if (@authorID is null or @authorID='' or @authorName is null or @authorName='')
		set @authorName = '匿名'
		
	insert into discussTopic(sectionID,topicID,title,topicDesc,authorID,author,viewNum ,isBoutique,sequence,createDate) 
	values(@sectionID,@topicID,@title,@topicDesc,@authorID,@authorName,0,0,9,GETDATE())
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end
	set @Ret = 0
end

drop procedure updateTopicViewNum
/*
	name:		updateTopicViewNum
	function:	12.将主题浏览次数+1
	input: 
				@topicID varchar(13)	--主题编号
	output: 
	author:		卢嘉城
	CreateDate:	2013-8-25
	UpdateDate: 

*/
create procedure updateTopicViewNum
	@topicID varchar(13)
as
begin
	declare @oldNum int,@newNum int
	set @oldNum=(select viewNum from discussTopic where topicID=@topicID)
	set @newNum=@oldNum+1;
	update discussTopic set viewNum=@newNum where topicID=@topicID
end


select * from discussTopicOverview
go


drop PROCEDURE topicDetail
/*
	name:		topicDetail
	function:	13.分页获取讨论主题的详细信息
	input: 
				@topicID varchar(13),	--主题编号
				@pageSize int,			--分页尺寸
				@pageIndex int,			--分页号
	output: 
				@title varchar(100) output,			--标题
				@topicDesc varchar(4000) output,	--主题描述
				@attachMent varchar(8000) output,	--主题附件
				@viewNum int output,			--浏览次数
				@replyNum int output,			--回帖数
				@authorID varchar(12) output,	--作者ID
				@author nvarchar(30) output,	--作者
				@createTime varchar(16) output,	--创建时间
				@creatorTopicNum int output,	--主题创建人帖子数
				@creatorBoutiqueNum int output,	--主题创建人帖子精华数
				@nextTopicID varchar(12) output,--下一主题ID
				@nextTitle nvarchar(100) output,--下一主题
				@lastTopicID varchar(12) output,--上一主题ID
				@lastTitle nvarchar(100) output	--上一主题
	author:		卢嘉城
	CreateDate:	2013-8-25
	UpdateDate: 

*/
CREATE PROCEDURE topicDetail
	@topicID varchar(13),	--主题编号
	@pageSize int,			--分页尺寸
	@pageIndex int,			--分页号
	@title varchar(100) output,			--标题
	@topicDesc varchar(4000) output,	--主题描述
	@attachMent varchar(8000) output,	--主题附件
	@viewNum int output,			--浏览次数
	@replyNum int output,			--回帖数
	@authorID varchar(12) output,	--作者ID
	@author nvarchar(30) output,	--作者
	@createDate varchar(19) output,	--创建时间
	@creatorTopicNum int output,	--主题创建人帖子数
	@creatorBoutiqueNum int output,	--主题创建人帖子精华数
	@nextTopicID varchar(12) output,--下一主题ID
	@nextTitle nvarchar(100) output,--下一主题
	@lastTopicID varchar(12) output,--上一主题ID
	@lastTitle nvarchar(100) output	--上一主题
	WITH ENCRYPTION
AS
BEGIN
	declare @sectionID varchar(12)
	select @sectionID = sectionID, @title=title,@topicDesc=topicDesc,@viewNum=viewNum,@authorID=authorID,@author=author,
			@createDate =convert(varchar(19),createDate,120) 
	from discussTopic 
	where topicID=@topicID--ID，主题，查看数，创建人ID，创建人，创建时间
	
	select @replyNum=isnull(COUNT(replyID),0) from discussReply where topicID=@topicID--回复数
	
	select @creatorTopicNum=COUNT(topicID) 
	from discussTopic 
	where authorID in(select authorID from discussTopic where topicID=@topicID)--主题创建人帖子数
	select @creatorBoutiqueNum=COUNT(topicID) 
	from discussTopic 
	where authorID = @authorID and isBoutique=1--主题创建人帖子精华数

	select @nextTopicID=topicID,@nextTitle=title 
	from discussTopic 
	where topicID in(select top 1 topicID from discussTopic where topicID>@topicID 
						and sectionID = @sectionID order by topicID asc)--下一贴
	
	select @lastTopicID=topicID,@lastTitle=title 
	from discussTopic 
	where topicID in(select top 1 topicID from discussTopic where topicID<@topicID 
						and sectionID = @sectionID order by topicID desc)--上一贴
	--附件：
	set @attachMent = dbo.getDiscussAttach(@sectionID,@topicID,'') 
	
	--回复人信息：回复内容，时间，回复人精华帖子数，回复人所有帖子数，回复人ID，回复人姓名
	SELECT * FROM 
		(SELECT top 100 percent ROW_NUMBER() OVER(ORDER BY replyTime asc) AS rowNum,
		topicID,replyID,replyContent,convert(varchar(19),replyTime,120) replyTime, 
		isnull(b.boutiqueNum,0) as replyBoutiqueNum,ISNULL(c.replyTopicNum,0) as replyTopicNum,
		d.authorID as replyManID,authorName as replyManName,
		dbo.getDiscussAttach(d.sectionID,d.topicID,d.replyID) attachMent
		FROM discussReply d left join 
			(select authorID, COUNT(topicID) as boutiqueNum 
			from discussTopic 
			where authorID in(select authorID from discussReply where topicID=@topicID) and isBoutique=1
			group by authorID) b on d.authorID = b.authorID 
		left join
			(select authorID,COUNT(topicID) as replyTopicNum 
			from discussTopic 
			where authorID in(select authorID from discussReply where topicID=@topicID)
								group by authorID) c on d.authorID=c.authorID
		where topicID=@topicID order by replyTime asc)AS D
	WHERE rowNum BETWEEN (@pageIndex-1)*@pageSize+1 AND @pageIndex*@pageSize
	ORDER BY replyTime asc
	
END
GO 


drop PROCEDURE delDiscussTopic
/*
	name:		delDiscussTopic
	function:	14.删除指定的论坛主题（帖子）
	input: 
				@topicID varchar(13),			--主题编号
				@delManID varchar(10) output,	--删除人，如果当前主题所在板块正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
												0:成功，1：指定的主题不存在，2：要删除的主题所在板块正被别人锁定编辑，9：未知错误
	author:		卢苇
	CreateDate:	2015-11-07
	UpdateDate: 

*/
create PROCEDURE delDiscussTopic
	@topicID varchar(13),			--主题编号
	@delManID varchar(10) output,	--删除人，如果当前主题所在板块正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的主题是否存在
	declare @count as int
	set @count=(select count(*) from discussTopic where topicID = @topicID)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @sectionID varchar(12)
	set @sectionID=(select sectionID from discussTopic where topicID = @topicID)
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from discussSection where sectionID = @sectionID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	begin tran
		delete discussTopic where topicID = @topicID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		--删除附件（含旗下的回复附件）：
		delete discussAttach where topicID = @topicID
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
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除主题', '用户' + @delManName
												+ '删除了编号为：[' + @topicID + ']的主题。')
GO

------------------------------------------------------------------

drop procedure addDiscussReply
/*
	name:		addDiscussReply
	function:	20.添加主题回复
				注意：这个存储过程不填写工作日志
	input: 
				@sectionID varchar(12),			--版块编号
				@topicID varchar(13),			--主题编号
				@replyContent nvarchar(4000),	--内容
				@authorID varchar(12),			--作者ID
	output: 
				@Ret		int output			--操作成功标识
												0:成功，9:未知错误
				@replyID varchar(16) output		--回复编号
	author:		卢苇
	CreateDate:	2015-11-5
	UpdateDate: 

*/
create procedure addDiscussReply
	@sectionID varchar(12),			--版块编号
	@topicID varchar(13),			--主题编号
	@replyContent nvarchar(4000),	--内容
	@authorID varchar(12),			--作者ID
	@Ret int output,				--操作成功标识
	@replyID varchar(16) output		--回复编号
as
begin
	set @Ret = 9

	--由22号号码发生器获取replyID
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 22, 1, @curNumber output
	set @replyID = @curNumber

	--取发表人的姓名：
	declare @authorName varchar(30)
	if (@authorID is not null and @authorID!='')
		set @authorName = isnull((select cName from userInfo where userID = @authorID),'')
	if (@authorID is null or @authorID='' or @authorName is null or @authorName='')
		set @authorName = '匿名'
		
	insert into discussReply(sectionID,topicID, replyID, replyContent,replyTime,authorID,authorName) 
	values(@sectionID,@topicID, @replyID, @replyContent,getdate(),@authorID,@authorName)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end
	set @Ret = 0
end

drop PROCEDURE delDiscussReply
/*
	name:		delDiscussReply
	function:	21.删除指定的论坛主题的回帖
	input: 
				@replyID varchar(16),			--回复编号
				@delManID varchar(10) output,	--删除人，如果当前回帖所在板块正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
												0:成功，1：指定的回帖不存在，2：要删除的回帖所在板块正被别人锁定编辑，9：未知错误
	author:		卢苇
	CreateDate:	2015-11-07
	UpdateDate: 

*/
create PROCEDURE delDiscussReply
	@replyID varchar(16),			--回复编号
	@delManID varchar(10) output,	--删除人，如果当前回帖所在板块正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的回帖是否存在
	declare @count as int
	set @count=(select count(*) from discussReply where replyID = @replyID)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @sectionID varchar(12)
	set @sectionID=(select sectionID from discussReply where replyID = @replyID)
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from discussSection where sectionID = @sectionID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	begin tran
		delete discussReply where replyID = @replyID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		--删除附件（含旗下的回复附件）：
		delete discussAttach where replyID = @replyID
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
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除回帖', '用户' + @delManName
												+ '删除了编号为：[' + @replyID + ']的回帖。')
GO


drop FUNCTION getDiscussAttach
/*
	name:		getDiscussAttach
	function:	100.获取附件，采用json格式输出
	input: 
				@sectionID varchar(12),	--板块编号
				@topicID varchar(13),	--主题编号，可以为""
				@replyID varchar(16)	--回复编号，可以为""
	output: 
				return varchar(max),	--附件的Json描述
	author:		卢苇
	CreateDate:	2015-11-6
	UpdateDate: 
*/
create FUNCTION getDiscussAttach(@sectionID varchar(12),@topicID varchar(13),@replyID varchar(16))
RETURNS varchar(max)
WITH ENCRYPTION
AS      
begin
	declare @result varchar(max)
	set @result = ''
	declare @rowNum bigint, @aFilename varchar(128), @uidFilename varchar(128), 
			@title nvarchar(32), @fileSize bigint, @fileType varchar(10),
			@uploadTime varchar(19), @fileLog varchar(128)

	declare tar cursor for
	select rowNum, aFileName, uidFilename,isnull(title,'') title, fileSize, fileType, convert(varchar(19),uploadTime,120), isnull(fileLog,'')
	from discussAttach 
	where sectionID = @sectionID and topicID = @topicID and replyID = @replyID
	order by rowNum
	OPEN tar
	FETCH NEXT FROM tar INTO @rowNum, @aFilename, @uidFilename, @title, @fileSize, @fileType, @uploadTime, @fileLog
	WHILE @@FETCH_STATUS = 0
	begin
		declare @row varchar(1000)
		set @row = dbo.attachToJson(@rowNum, @aFilename, @uidFilename, 
									@title, @fileSize, @fileType,@uploadTime, @fileLog)
		set @result += @row
		FETCH NEXT FROM tar INTO @rowNum, @aFilename, @uidFilename, @title, @fileSize, @fileType, @uploadTime, @fileLog
	end
	CLOSE tar
	DEALLOCATE tar
	if @result <> ''
		set @result = '[' + substring(@result,1, len(@result)-1) + ']'
	else
		set @result = '[]'

	return @result
end
--测试：
select dbo.getDiscussAttach('S20151107001','D201511070001','R201511070000001')
select * from discussAttach
delete discussAttach

select substring('S20151105005',1,3)
S2
--输出附件xml
select * from discussAttach FOR XML RAW,TYPE,ELEMENTS


drop FUNCTION attachToJson
/*
	name:		attachToJson
	function:	100.1.将附件转换为Json
	input: 
				@sectionID varchar(12),	--板块编号
				@topicID varchar(13),	--主题编号，可以为""
				@replyID varchar(16)	--回复编号，可以为""
	output: 
				return varchar(max),	--附件的Json描述
	author:		卢苇
	CreateDate:	2015-11-8
	UpdateDate: 
*/
create FUNCTION attachToJson(@rowNum bigint, @aFilename varchar(128), @uidFilename varchar(128), 
			@title nvarchar(32), @fileSize bigint, @fileType varchar(10),
			@uploadTime varchar(19), @fileLog varchar(128))
RETURNS varchar(max)
WITH ENCRYPTION
AS      
begin
	declare @result varchar(max)
	set @result = '{' + '"rowNum":' + '"' + cast(@rowNum as varchar(10)) + '",' 
					   + '"filename":' + '"' + @aFilename + '",'
					   + '"uid":' + '"' + @uidFilename + '",'
					   + '"title":' + '"' + @title + '",'
					   + '"size":' + '"' + cast(@fileSize as varchar(18)) + '",'
					   + '"type":' + '"' + @fileType + '",'
					   + '"uploadTime":' + '"' + @uploadTime + '",'
					   + '"fileLog":' + '"' + @fileLog + '"},'
	return @result
end


drop PROCEDURE getAllAttachInSection
/*
	name:		getAllAttachInSection
	function:	101.获取板块的全部附件（包含旗下的主题和回复的附件），采用json格式输出
	input: 
				@sectionID varchar(12),	--板块编号
	output: 
				@result varchar(8000) output	--附件Json描述字串
	author:		卢苇
	CreateDate:	2015-11-8
	UpdateDate: 
*/
create PROCEDURE getAllAttachInSection
	@sectionID varchar(12),			--板块编号
	@result varchar(8000) output	--附件Json描述字串
	WITH ENCRYPTION 
AS
	set @result = ''
	declare @rowNum bigint, @aFilename varchar(128), @uidFilename varchar(128), 
			@title nvarchar(32), @fileSize bigint, @fileType varchar(10),
			@uploadTime varchar(19), @fileLog varchar(128)

	declare tar cursor for
	select rowNum, aFileName, uidFilename,isnull(title,'') title, fileSize, fileType, convert(varchar(19),uploadTime,120), isnull(fileLog,'')
	from discussAttach 
	where sectionID = @sectionID
	order by rowNum
	OPEN tar
	FETCH NEXT FROM tar INTO @rowNum, @aFilename, @uidFilename, @title, @fileSize, @fileType, @uploadTime, @fileLog
	WHILE @@FETCH_STATUS = 0
	begin
		declare @row varchar(1000)
		set @row = dbo.attachToJson(@rowNum, @aFilename, @uidFilename, 
									@title, @fileSize, @fileType,@uploadTime, @fileLog)
		set @result += @row
		FETCH NEXT FROM tar INTO @rowNum, @aFilename, @uidFilename, @title, @fileSize, @fileType, @uploadTime, @fileLog
	end
	CLOSE tar
	DEALLOCATE tar
	if @result <> ''
		set @result = '[' + substring(@result,1, len(@result)-1) + ']'
	else
		set @result = '[]'
go
--测试：
declare @result varchar(8000)
exec dbo.getAllAttachInSection 'S20151107001', @result output
select @result

drop PROCEDURE getAllAttachInTopic
/*
	name:		getAllAttachInTopic
	function:	102.获取主题的全部附件（包含旗下的回复的附件），采用json格式输出
	input: 
				@topicID varchar(13),	--主题编号
	output: 
				@result varchar(8000) output	--附件Json描述字串
	author:		卢苇
	CreateDate:	2015-11-8
	UpdateDate: 
*/
create PROCEDURE getAllAttachInTopic
	@topicID varchar(13),			--主题编号
	@result varchar(8000) output	--附件Json描述字串
	WITH ENCRYPTION 
AS
	set @result = ''
	declare @rowNum bigint, @aFilename varchar(128), @uidFilename varchar(128), 
			@title nvarchar(32), @fileSize bigint, @fileType varchar(10),
			@uploadTime varchar(19), @fileLog varchar(128)

	declare tar cursor for
	select rowNum, aFileName, uidFilename,isnull(title,'') title, fileSize, fileType, convert(varchar(19),uploadTime,120), isnull(fileLog,'')
	from discussAttach 
	where topicID = @topicID
	order by rowNum
	OPEN tar
	FETCH NEXT FROM tar INTO @rowNum, @aFilename, @uidFilename, @title, @fileSize, @fileType, @uploadTime, @fileLog
	WHILE @@FETCH_STATUS = 0
	begin
		declare @row varchar(1000)
		set @row = dbo.attachToJson(@rowNum, @aFilename, @uidFilename, 
									@title, @fileSize, @fileType,@uploadTime, @fileLog)
		set @result += @row
		FETCH NEXT FROM tar INTO @rowNum, @aFilename, @uidFilename, @title, @fileSize, @fileType, @uploadTime, @fileLog
	end
	CLOSE tar
	DEALLOCATE tar
	if @result <> ''
		set @result = '[' + substring(@result,1, len(@result)-1) + ']'
	else
		set @result = '[]'
go
--测试：
declare @result varchar(8000)
exec dbo.getAllAttachInTopic 'D201511070001', @result output
select @result

drop PROCEDURE getAllAttachInReply
/*
	name:		getAllAttachInReply
	function:	102.获取回复的全部附件，采用json格式输出
	input: 
				@replyID varchar(16),			--回复编号
	output: 
				@result varchar(8000) output	--附件Json描述字串
	author:		卢苇
	CreateDate:	2015-11-8
	UpdateDate: 
*/
create PROCEDURE getAllAttachInReply
	@replyID varchar(16),			--回复编号
	@result varchar(8000) output	--附件Json描述字串
	WITH ENCRYPTION 
AS
	set @result = ''
	declare @rowNum bigint, @aFilename varchar(128), @uidFilename varchar(128), 
			@title nvarchar(32), @fileSize bigint, @fileType varchar(10),
			@uploadTime varchar(19), @fileLog varchar(128)

	declare tar cursor for
	select rowNum, aFileName, uidFilename,isnull(title,'') title, fileSize, fileType, convert(varchar(19),uploadTime,120), isnull(fileLog,'')
	from discussAttach 
	where replyID = @replyID
	order by rowNum
	OPEN tar
	FETCH NEXT FROM tar INTO @rowNum, @aFilename, @uidFilename, @title, @fileSize, @fileType, @uploadTime, @fileLog
	WHILE @@FETCH_STATUS = 0
	begin
		declare @row varchar(1000)
		set @row = dbo.attachToJson(@rowNum, @aFilename, @uidFilename, 
									@title, @fileSize, @fileType,@uploadTime, @fileLog)
		set @result += @row
		FETCH NEXT FROM tar INTO @rowNum, @aFilename, @uidFilename, @title, @fileSize, @fileType, @uploadTime, @fileLog
	end
	CLOSE tar
	DEALLOCATE tar
	if @result <> ''
		set @result = '[' + substring(@result,1, len(@result)-1) + ']'
	else
		set @result = '[]'
go
--测试：
declare @result varchar(8000)
exec dbo.getAllAttachInReply 'R201511070000001', @result output
select @result
 
update discussAttach
set topicid='',replyID=''
where sectionID='S20151107001' and topicID='D201511080046'


select * from discussTopic where topicID='S20151107001'

select * from discussAttach 

delete discussAttach 