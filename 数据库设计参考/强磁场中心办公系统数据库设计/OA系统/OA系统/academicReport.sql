use hustOA
/*
	强磁场中心办公系统-学术报告管理
	author:		卢苇
	CreateDate:	2012-12-23
	UpdateDate: 
*/
--1.学术报告管理表：
select * from academicReports
select * from AReportEnterMans
update AReportEnterMans
set isLate = 0
drop table academicReports
CREATE TABLE academicReports(
	aReportID varchar(10) not null,		--主键：学术报告编号,本系统使用第200号号码发生器产生（'BG'+4位年份代码+4位流水号）
	topic  nvarchar(40) null,			--主题
	reportManID varchar(100) not null,	--报告人工号：支持多个人，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放
	reportMan nvarchar(300) not null,	--报告人姓名：支持多个人，采用"XXX,XXX"格式存放。冗余设计
	reportStartTime smalldatetime null,	--报告开始时间
	reportEndTime smalldatetime null,	--报告结束时间
	summary nvarchar(300) null,			--内容摘要
	
	reportPlaceID varchar(10) null,		--报告地点的标识号（场地ID）
	reportPlace nvarchar(60) null,		--报告地点
	placeIsReady smallint default(0),	--报告需要的场地是否准备好：0->未准备好，1->准备就绪
	
	needEqpCodes varchar(80) null,		--报告需要的设备编号：支持多个设备，采用"XXXXXXXX,XXXXXXXX"格式存放
	needEqpNames nvarchar(300) null,	--报告需要的设备名称：支持多个设备，采用"设备1,设备2"格式存放，冗余设计。
	eqpIsReady smallint default(0),		--报告需要的设备是否准备好：0->未准备好，1->准备就绪
	
	--程远提出需要通知和提醒，并且学术报告要能够限定查阅范围，这些功能都没有做！
	--以下两个字段是预留将来扩展这些功能的！
	--add by lw 2013-1-3
	needSMSInvitation smallint default(0),--是否需要短信通知：0->不需要, 1->需要
	needSMSRemind smallint default(0),	--是否需要短信提醒（会议前1小时提醒）：0->不需要，1->需要

	isPublish smallint default(0),		--(原isSendMsg字段)是否学术报告：0->未发布学术报告（或学术报告撤回），1->已发布学术报告 modi by lw 2013-1-3
	publishTime smalldatetime null,		--发布日期add by lw 2013-1-3
	isOver smallint default(0),			--是否报告结束：0->未结束，1->结束 注意：这个是不能撤销的 add by lw 2013-1-3

	orderNum smallint default(-1),		--显示排序号 add by lw 2013-3-20
	
	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_academicReports] PRIMARY KEY CLUSTERED 
(
	[aReportID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--报告时间索引：
CREATE NONCLUSTERED INDEX [IX_academicReports] ON [dbo].[academicReports] 
(
	[reportStartTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--报告排序索引：
CREATE NONCLUSTERED INDEX [IX_academicReports_1] ON [dbo].[academicReports] 
(
	[orderNum] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


select * from academicReports
select * from AReportEnterMans

--2.学术报告报名表：
select * from AReportEnterMans
drop table AReportEnterMans
CREATE TABLE AReportEnterMans(
	aReportID varchar(10) not null,		--外键：学术报告编号
	topic  nvarchar(40) null,			--主题：冗余设计
	applyManID varchar(10) not null,	--申请人工号
	applyMan nvarchar(30) null,			--申请人姓名
	applyTime smalldatetime null,		--申请时间
	checkManID varchar(10) null,		--考勤人工号
	checkMan nvarchar(30) null,			--考勤人姓名
	arriveTime smalldatetime null,		--到达时间
	isLate smallint default(0),			--是否迟到：0->未到达，1->正常到达，-1->迟到
 CONSTRAINT [PK_AReportEnterMans] PRIMARY KEY CLUSTERED 
(
	[aReportID] ASC,
	[applyManID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[AReportEnterMans] WITH CHECK ADD CONSTRAINT [FK_AReportEnterMans_academicReports] FOREIGN KEY([aReportID])
REFERENCES [dbo].[academicReports] ([aReportID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AReportEnterMans] CHECK CONSTRAINT [FK_AReportEnterMans_academicReports]
GO


drop PROCEDURE queryAcademicReportLocMan
/*
	name:		queryAcademicReportLocMan
	function:	1.查询指定学术报告是否有人正在编辑
	input: 
				@aReportID varchar(10),		--学术报告编号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的学术报告不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2012-12-23
	UpdateDate: 
*/
create PROCEDURE queryAcademicReportLocMan
	@aReportID varchar(10),		--学术报告编号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from academicReports where aReportID= @aReportID),'')
	set @Ret = 0
GO


drop PROCEDURE lockAcademicReport4Edit
/*
	name:		lockAcademicReport4Edit
	function:	2.锁定学术报告编辑，避免编辑冲突
	input: 
				@aReportID varchar(10),			--学术报告编号
				@lockManID varchar(10) output,	--锁定人，如果当前学术报告正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的学术报告不存在，2:要锁定的学术报告正在被别人编辑，
							3：该学术报告已发布，不允许编辑锁定，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-12-23
	UpdateDate: 
*/
create PROCEDURE lockAcademicReport4Edit
	@aReportID varchar(10),		--学术报告编号
	@lockManID varchar(10) output,	--锁定人，如果当前学术报告正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的学术报告是否存在
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @isPublish smallint
	select @thisLockMan = isnull(lockManID,''), @isPublish = isPublish from academicReports where aReportID= @aReportID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查状态：
	if (@isPublish=1)
	begin
		set @Ret = 3
		return
	end

	update academicReports
	set lockManID = @lockManID 
	where aReportID= @aReportID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定学术报告编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了学术报告['+ @aReportID +']为独占式编辑。')
GO

drop PROCEDURE unlockAcademicReportEditor
/*
	name:		unlockAcademicReportEditor
	function:	3.释放学术报告编辑锁
				注意：本过程不检查学术报告是否存在！
	input: 
				@aReportID varchar(10),			--学术报告编号
				@lockManID varchar(10) output,	--锁定人，如果当前学术报告正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-23
	UpdateDate: 
*/
create PROCEDURE unlockAcademicReportEditor
	@aReportID varchar(10),			--学术报告编号
	@lockManID varchar(10) output,	--锁定人，如果当前学术报告呢正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from academicReports where aReportID= @aReportID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update academicReports set lockManID = '' where aReportID= @aReportID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end    
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
	values(@lockManID, @lockManName, getdate(), '释放学术报告编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了学术报告['+ @aReportID +']的编辑锁。')
GO

drop PROCEDURE addAcademicReport
/*
	name:		addAcademicReport
	function:	4.添加学术报告信息
	input: 
				@topic  nvarchar(40),		--主题
				@reportManID varchar(100),	--报告人工号：支持多个人，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放
				@reportMan nvarchar(300),	--报告人姓名：支持多个人，采用"XXX,XXX"格式存放。冗余设计
				@reportStartTime varchar(19),--报告开始时间：采用"yyyy-MM-dd hh:MM:ss"格式存放
				@reportEndTime varchar(19),	--报告结束时间：采用"yyyy-MM-dd hh:MM:ss"格式存放
				@summary nvarchar(300),		--内容摘要
				
				@reportPlaceID varchar(10),	--报告地点的标识号（场地ID）
				@reportPlace nvarchar(60),	--报告地点
				
				@needEqpCodes varchar(80),	--报告需要的设备编号：支持多个设备，采用"XXXXXXXX,XXXXXXXX"格式存放
				@needEqpNames nvarchar(300),--报告需要的设备名称：支持多个设备，采用"设备1,设备2"格式存放，冗余设计。

				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output,--添加时间
				@aReportID varchar(10) output--学术报告编号
	author:		卢苇
	CreateDate:	2012-12-23
	UpdateDate: 
*/
create PROCEDURE addAcademicReport
	@topic  nvarchar(40),		--主题
	@reportManID varchar(100),	--报告人工号：支持多个人，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放
	@reportMan nvarchar(300),	--报告人姓名：支持多个人，采用"XXX,XXX"格式存放。冗余设计
	@reportStartTime varchar(19),--报告开始时间：采用"yyyy-MM-dd hh:MM:ss"格式存放
	@reportEndTime varchar(19),	--报告结束时间：采用"yyyy-MM-dd hh:MM:ss"格式存放
	@summary nvarchar(300),		--内容摘要
	
	@reportPlaceID varchar(10),	--报告地点的标识号（场地ID）
	@reportPlace nvarchar(60),	--报告地点
	
	@needEqpCodes varchar(80),	--报告需要的设备编号：支持多个设备，采用"XXXXXXXX,XXXXXXXX"格式存放
	@needEqpNames nvarchar(300),--报告需要的设备名称：支持多个设备，采用"设备1,设备2"格式存放，冗余设计。

	@createManID varchar(10),	--创建人工号
	@Ret		int output,
	@createTime smalldatetime output,
	@aReportID varchar(10) output--学术报告编号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生学术报告编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 200, 1, @curNumber output
	set @aReportID = @curNumber

	--取创建人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert academicReports(aReportID, topic, reportManID, reportMan, reportStartTime, reportEndTime, summary,
					reportPlaceID, reportPlace, needEqpCodes, needEqpNames,
					--最新维护情况:
					modiManID, modiManName, modiTime)
	values(@aReportID, @topic, @reportManID, @reportMan, @reportStartTime, @reportEndTime, @summary,
					@reportPlaceID, @reportPlace, @needEqpCodes, @needEqpNames,
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
	values(@createManID, @createManName, @createTime, '登记学术报告', '系统根据用户' + @createManName + 
					'的要求登记了学术报告“' + @topic + '['+@aReportID+']”。')
GO

drop PROCEDURE updateAcademicReport
/*
	name:		updateAcademicReport
	function:	5.修改学术报告信息
	input: 
				@aReportID varchar(10),		--学术报告编号
				@topic  nvarchar(40),		--主题
				@reportManID varchar(100),	--报告人工号：支持多个人，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放
				@reportMan nvarchar(300),	--报告人姓名：支持多个人，采用"XXX,XXX"格式存放。冗余设计
				@reportStartTime varchar(19),--报告开始时间：采用"yyyy-MM-dd hh:MM:ss"格式存放
				@reportEndTime varchar(19),	--报告结束时间：采用"yyyy-MM-dd hh:MM:ss"格式存放
				@summary nvarchar(300),		--内容摘要
				
				@reportPlaceID varchar(10),	--报告地点的标识号（场地ID）
				@reportPlace nvarchar(60),	--报告地点
				
				@needEqpCodes varchar(80),	--报告需要的设备编号：支持多个设备，采用"XXXXXXXX,XXXXXXXX"格式存放
				@needEqpNames nvarchar(300),--报告需要的设备名称：支持多个设备，采用"设备1,设备2"格式存放，冗余设计。

				@modiManID varchar(10) output,	--修改人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:要修改的学术报告不存在，
							2:要修改的学术报告正被别人锁定编辑，
							3：该学术报告已发布，不允许修改，
							9:未知错误
				@modiTime smalldatetime output	--添加时间
	author:		卢苇
	CreateDate:	2012-12-23
	UpdateDate: 
*/
create PROCEDURE updateAcademicReport
	@aReportID varchar(10),		--学术报告编号
	@topic  nvarchar(40),		--主题
	@reportManID varchar(100),	--报告人工号：支持多个人，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放
	@reportMan nvarchar(300),	--报告人姓名：支持多个人，采用"XXX,XXX"格式存放。冗余设计
	@reportStartTime varchar(19),--报告开始时间：采用"yyyy-MM-dd hh:MM:ss"格式存放
	@reportEndTime varchar(19),	--报告结束时间：采用"yyyy-MM-dd hh:MM:ss"格式存放
	@summary nvarchar(300),		--内容摘要
	
	@reportPlaceID varchar(10),	--报告地点的标识号（场地ID）
	@reportPlace nvarchar(60),	--报告地点
	
	@needEqpCodes varchar(80),	--报告需要的设备编号：支持多个设备，采用"XXXXXXXX,XXXXXXXX"格式存放
	@needEqpNames nvarchar(300),--报告需要的设备名称：支持多个设备，采用"设备1,设备2"格式存放，冗余设计。

	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的学术报告是否存在
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @isPublish smallint
	select @thisLockMan = isnull(lockManID,''), @isPublish = isPublish from academicReports where aReportID= @aReportID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查状态：
	if (@isPublish=1)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--检查是否有时间变化:
	--检查是否有场地变化：
	--检查是否有设备变化:
	
	set @modiTime = getdate()
	update academicReports
	set aReportID = @aReportID, topic = @topic, 
		reportManID = @reportManID, reportMan = @reportMan, 
		reportStartTime = @reportStartTime, reportEndTime = @reportEndTime, summary = @summary,
		reportPlaceID = @reportPlaceID, reportPlace = @reportPlace, needEqpCodes = @needEqpCodes, needEqpNames = @needEqpNames,
		--最新维护情况:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where aReportID= @aReportID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '修改学术报告', '系统根据用户' + @modiManName + 
					'的要求修改了学术报告“' + @topic + '['+@aReportID+']”的登记信息。')
GO

drop PROCEDURE delAcademicReport
/*
	name:		delAcademicReport
	function:	6.删除指定的学术报告
	input: 
				@aReportID varchar(10),			--学术报告编号
				@delManID varchar(10) output,	--删除人，如果当前学术报告正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的学术报告不存在，2：要删除的学术报告正被别人锁定，3：该学术报告已发布，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-23
	UpdateDate: 

*/
create PROCEDURE delAcademicReport
	@aReportID varchar(10),			--学术报告编号
	@delManID varchar(10) output,	--删除人，如果当前学术报告正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的学术报告是否存在
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @isPublish smallint
	select @thisLockMan = isnull(lockManID,''), @isPublish = isPublish from academicReports where aReportID= @aReportID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查状态：
	if (@isPublish=1)
	begin
		set @Ret = 3
		return
	end

	delete academicReports where aReportID= @aReportID
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除学术报告', '用户' + @delManName
												+ '删除了学术报告['+@aReportID+']。')

GO


drop PROCEDURE placeIsReady4AReport
/*
	name:		placeIsReady4AReport
	function:	7.通知指定的学术报告场地已经准备好
	input: 
				@aReportID varchar(10),			--学术报告编号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的学术报告不存在，2：指定的学术报告正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-23
	UpdateDate: 

*/
create PROCEDURE placeIsReady4AReport
	@aReportID varchar(10),			--学术报告编号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的学术报告是否存在
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from academicReports where aReportID= @aReportID),'')
	if (@thisLockMan <> '')
	begin
		set @Ret = 2
		return
	end

	update academicReports
	set placeIsReady = 1
	where aReportID= @aReportID
	
	set @Ret = 0
	--检查是否设备也准备好，如果也准备好了就开始发送通知
GO

drop PROCEDURE eqpIsReady4AReport
/*
	name:		eqpIsReady4AReport
	function:	8.通知指定的学术报告设备已经准备好
	input: 
				@aReportID varchar(10),			--学术报告编号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的学术报告不存在，2：指定的学术报告正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-23
	UpdateDate: 

*/
create PROCEDURE eqpIsReady4AReport
	@aReportID varchar(10),			--学术报告编号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的学术报告是否存在
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from academicReports where aReportID= @aReportID),'')
	if (@thisLockMan <> '')
	begin
		set @Ret = 2
		return
	end

	update academicReports
	set eqpIsReady = 1
	where aReportID= @aReportID
	
	set @Ret = 0
	--检查是否场地也准备好，如果也准备好了就开始发送学术报告
	
GO


drop PROCEDURE publishAReport
/*
	name:		publishAReport
	function:	9.发布学术报告学术报告
	input: 
				@aReportID varchar(10),			--学术报告编号
				@publishManID varchar(10) output,	--发布人，如果当前学术报告正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的学术报告不存在，2：指定的学术报告正被别人锁定，3：该学术报告已经是发布状态，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-3
	UpdateDate: 

*/
create PROCEDURE publishAReport
	@aReportID varchar(10),			--学术报告编号
	@publishManID varchar(10) output,	--发布人，如果当前学术报告正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要发布的学术报告是否存在
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @isPublish smallint
	select @thisLockMan = isnull(lockManID,''), @isPublish = isPublish from academicReports where aReportID= @aReportID
	if (@thisLockMan <> '' and @thisLockMan <> @publishManID)
	begin
		set @publishManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查状态：
	if (@isPublish=1)
	begin
		set @Ret = 3
		return
	end
	
	--取发布人的姓名：
	declare @publishMan nvarchar(30)
	set @publishMan = isnull((select userCName from activeUsers where userID = @publishManID),'')

	--生成发布序号：
	declare @curMaxOrderNum int
	set @curMaxOrderNum = isnull((select max(orderNum) from academicReports  where isPublish = 1),0) + 1
	
	declare @publishTime smalldatetime --发布日期
	set @publishTime = GETDATE()
	update academicReports 
	set isPublish = 1, publishTime = @publishTime, orderNum = @curMaxOrderNum,
		--最新维护情况:
		modiManID = @publishManID, modiManName = @publishMan, modiTime = @publishTime
	where aReportID= @aReportID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0

	--将该学术报告置顶：
	declare @execRet int
	exec dbo.setAReportToTop @publishManID, @publishManID output, @execRet output

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@publishManID, @publishMan, @publishTime, '发布学术报告', '用户' + @publishMan
												+ '发布了学术报告['+@aReportID+']。')

GO

drop PROCEDURE cancelPublishAReport
/*
	name:		cancelPublishAReport
	function:	9.1.撤销发布学术报告学术报告
	input: 
				@aReportID varchar(10),			--学术报告编号
				@cancelManID varchar(10) output,--撤销人，如果当前学术报告正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的学术报告不存在，2：指定的学术报告正被别人锁定，3：该学术报告还未发布，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-3
	UpdateDate: 

*/
create PROCEDURE cancelPublishAReport
	@aReportID varchar(10),			--学术报告编号
	@cancelManID varchar(10) output,--撤销人，如果当前学术报告正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要撤销发布的学术报告是否存在
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @isPublish smallint
	select @thisLockMan = isnull(lockManID,''), @isPublish = isPublish from academicReports where aReportID= @aReportID
	if (@thisLockMan <> '' and @thisLockMan <> @cancelManID)
	begin
		set @cancelManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查状态：
	if (@isPublish=0)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @cancelMan nvarchar(30)
	set @cancelMan = isnull((select userCName from activeUsers where userID = @cancelManID),'')

	declare @cancelTime smalldatetime --发布日期
	set @cancelTime = GETDATE()
	update academicReports 
	set isPublish = 0, publishTime = null, 
		orderNum = -1,
		--最新维护情况:
		modiManID = @cancelManID, modiManName = @cancelMan, modiTime = @cancelTime
	where aReportID= @aReportID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@cancelManID, @cancelMan, @cancelTime, '撤销学术报告', '用户' + @cancelMan
												+ '撤销了学术报告['+@aReportID+']。')

GO



drop PROCEDURE applyEnterAReport
/*
	name:		applyEnterAReport
	function:	10.申请参加指定的学术报告
	input: 
				@aReportID varchar(10),			--学术报告编号
				@applyManID varchar(10) output,	--申请人，如果当前学术报告正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的学术报告不存在，2：要申请参加的学术报告正被别人锁定，3：您已经申请参加了，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-23
	UpdateDate: 

*/
create PROCEDURE applyEnterAReport
	@aReportID varchar(10),			--学术报告编号
	@applyManID varchar(10) output,	--申请人，如果当前学术报告正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的学术报告是否存在
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from academicReports where aReportID= @aReportID),'')
	if (@thisLockMan <> '')
	begin
		set @applyManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--检查是否重复申请：
	set @count =(select count(*) from AReportEnterMans where aReportID = @aReportID and applyManID = @applyManID)
	if (@count > 0)	--已申请
	begin
		set @Ret = 3
		return
	end

	--取申请人的姓名：
	declare @applyMan nvarchar(30)
	set @applyMan = isnull((select userCName from activeUsers where userID = @applyManID),'')

	declare @applyTime smalldatetime	--申请时间
	set @applyTime = GETDATE()
	
	insert AReportEnterMans(aReportID, topic, applyManID, applyMan, applyTime)
	select aReportID, topic, @applyManID, @applyMan, @applyTime
	from academicReports 
	where aReportID= @aReportID
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@applyManID, @applyMan, @applyTime, '学术报告报名', '用户' + @applyMan
												+ '报名参加了学术报告['+@aReportID+']。')
GO
--测试：
declare @Ret int
exec dbo.applyEnterAReport 'BG20120019','00001', @Ret output
select @Ret


select * from AReportEnterMans
select * from academicReports
select * from userInfo

drop PROCEDURE cancelEnterAReport
/*
	name:		cancelEnterAReport
	function:	11.取消参加指定的学术报告
	input: 
				@aReportID varchar(10),			--学术报告编号
				@cancelManID varchar(10) output,--取消人（原申请人），如果当前学术报告正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的学术报告不存在，2：要申请参加的学术报告正被别人锁定，3：您没有申请参加该学术报告，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-23
	UpdateDate: 

*/
create PROCEDURE cancelEnterAReport
	@aReportID varchar(10),			--学术报告编号
	@cancelManID varchar(10) output,--取消人（原申请人），如果当前学术报告正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的学术报告是否存在
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from academicReports where aReportID= @aReportID),'')
	if (@thisLockMan <> '')
	begin
		set @cancelManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--检查是否有申请：
	set @count =(select count(*) from AReportEnterMans where aReportID = @aReportID and applyManID = @cancelManID)
	if (@count = 0)	--未申请
	begin
		set @Ret = 3
		return
	end

	--取申请人的姓名：
	declare @cancelMan nvarchar(30)
	set @cancelMan = isnull((select userCName from activeUsers where userID = @cancelManID),'')

	delete AReportEnterMans
	where aReportID = @aReportID and applyManID = @cancelManID

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@cancelManID, @cancelMan, getdate(), '取消学术报告报名', '用户' + @cancelMan
												+ '取消了参加学术报告['+@aReportID+']。')
GO
--测试：
declare	@Ret		int	--操作成功标识
exec dbo.cancelEnterAReport 'BG20120032', '0005', @Ret output
select @Ret

select * from academicReports
select * from AReportEnterMans

drop PROCEDURE checkEnterAReport
/*
	name:		checkEnterAReport
	function:	12.到达指定的学术报告（考勤）
	input: 
				@aReportID varchar(10),			--学术报告编号
				@enterManID varchar(10),		--到达人（原申请人）
				@checkManID varchar(10) output,	--检查人，如果当前学术报告正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output,			--操作成功标识
							0:成功，1：指定的学术报告不存在，2：要申请参加的学术报告正被别人锁定，9：未知错误
				@isLate smallint output			--系统返回的到达状态：1:正常到达，-1：迟到
	author:		卢苇
	CreateDate:	2012-12-23
	UpdateDate: 

*/
create PROCEDURE checkEnterAReport
	@aReportID varchar(10),			--学术报告编号
	@enterManID varchar(10),		--到达人（原申请人）
	@checkManID varchar(10) output,	--检查人，如果当前学术报告正在被人占用编辑则返回该人的工号
	@Ret		int output,			--操作成功标识
	@isLate smallint output			--系统返回的到达状态：1:正常到达，-1：迟到, 0：未知
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @isLate = 0

	--判断要锁定的学术报告是否存在
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from academicReports where aReportID= @aReportID),'')
	if (@thisLockMan <> '')
	begin
		set @checkManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--取到达人和考勤人的姓名：
	declare @enterMan nvarchar(30), @checkMan nvarchar(30)
	set @enterMan = isnull((select cName from userInfo where jobNumber = @enterManID),'')
	set @checkMan = isnull((select userCName from activeUsers where userID = @checkManID),'')

	--取学术报告时间和到达时间：
	declare @reportTime smalldatetime, @arriveTime smalldatetime
	set @reportTime = (select reportStartTime from academicReports where aReportID=@aReportID)
	set @arriveTime = GETDATE()
	if (@reportTime > @arriveTime)
		set @isLate = 1
	else
		set @isLate = -1
	
	--检查是否报名分别处理：
	set @count =(select count(*) from AReportEnterMans where aReportID = @aReportID and applyManID = @enterManID)
	if (@count = 0)	--未申请
	begin
		insert AReportEnterMans(aReportID, topic, applyManID, applyMan, applyTime, checkManID, checkMan, arriveTime, isLate)
		select aReportID, topic, @enterManID, @enterMan, @arriveTime, @checkManID, @checkMan, @arriveTime, @isLate
		from academicReports 
		where aReportID= @aReportID
	end
	else
	begin
		update AReportEnterMans
		set checkManID = @checkManID, checkMan = @checkMan, arriveTime = @arriveTime, isLate = @isLate
		where aReportID= @aReportID and applyManID = @enterManID
	end

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@checkManID, @checkMan, @arriveTime, '学术报告点名', '用户' + @checkMan
												+ '将['+@enterMan+']设置为到达学术报告['+@aReportID+']。')
GO


drop PROCEDURE checkEnterAReportByFlag
/*
	name:		checkEnterAReportByFlag
	function:	13.使用标志状态考勤
	input: 
				@aReportID varchar(10),			--学术报告编号
				@enterManID varchar(10),		--到达人（原申请人）
				@isLate smallint,				--到达状态：1:正常到达， -1:迟到到达
				@checkManID varchar(10) output,	--检查人，如果当前学术报告正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的学术报告不存在，2：要申请参加的学术报告正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-1
	UpdateDate: 

*/
create PROCEDURE checkEnterAReportByFlag
	@aReportID varchar(10),			--学术报告编号
	@enterManID varchar(10),		--到达人（原申请人）
	@isLate smallint,				--到达状态：1:正常到达， -1:迟到到达
	@checkManID varchar(10) output,	--检查人，如果当前学术报告正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的学术报告是否存在
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from academicReports where aReportID= @aReportID),'')
	if (@thisLockMan <> '')
	begin
		set @checkManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--取到达人和考勤人的姓名：
	declare @enterMan nvarchar(30), @checkMan nvarchar(30)
	set @enterMan = isnull((select cName from userInfo where jobNumber = @enterManID),'')
	set @checkMan = isnull((select userCName from activeUsers where userID = @checkManID),'')

	--取学术报告时间和到达时间：
	declare @reportTime smalldatetime, @arriveTime smalldatetime
	set @reportTime = (select reportStartTime from academicReports where aReportID=@aReportID)

	--根据到达状态设置到达时间：正常到达设置为会议开始时间，迟到到达设置为会议开始后15分钟
	if (@isLate=1)
		set @arriveTime = @reportTime
	else
		set @arriveTime = DATEADD(minute, 15, @reportTime)
	
	--检查是否报名分别处理：
	set @count =(select count(*) from AReportEnterMans where aReportID = @aReportID and applyManID = @enterManID)
	if (@count = 0)	--未申请
	begin
		insert AReportEnterMans(aReportID, topic, applyManID, applyMan, applyTime, checkManID, checkMan, arriveTime, isLate)
		select aReportID, topic, @enterManID, @enterMan, @arriveTime, @checkManID, @checkMan, @arriveTime, @isLate
		from academicReports 
		where aReportID= @aReportID
	end
	else
	begin
		update AReportEnterMans
		set checkManID = @checkManID, checkMan = @checkMan, arriveTime = @arriveTime, isLate = @isLate
		where aReportID= @aReportID and applyManID = @enterManID
	end

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@checkManID, @checkMan, @arriveTime, '学术报告点名', '用户' + @checkMan
												+ '将['+@enterMan+']设置为到达学术报告['+@aReportID+']。')
GO

drop PROCEDURE cancelCheckEnterAReport
/*
	name:		cancelCheckEnterAReport
	function:	14.取消到达（误操作后的取消功能）
	input: 
				@aReportID varchar(10),			--学术报告编号
				@enterManID varchar(10),		--到达人（原申请人）
				@checkManID varchar(10) output,	--检查人，如果当前学术报告正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的学术报告不存在，2：要申请参加的学术报告正被别人锁定，3:没有该申请人或还未到达，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-1
	UpdateDate: 

*/
create PROCEDURE cancelCheckEnterAReport
	@aReportID varchar(10),			--学术报告编号
	@enterManID varchar(10),		--到达人（原申请人）
	@checkManID varchar(10) output,	--检查人，如果当前学术报告正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的学术报告是否存在
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from academicReports where aReportID= @aReportID),'')
	if (@thisLockMan <> '')
	begin
		set @checkManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--检查参加人是否存在并到达：
	set @count =(select count(*) from AReportEnterMans where aReportID = @aReportID and applyManID = @enterManID and isLate<>0)
	if (@count=0)
	begin
		set @Ret =3
		return
	end

	--取到达人和考勤人的姓名：
	declare @enterMan nvarchar(30), @checkMan nvarchar(30)
	set @enterMan = isnull((select cName from userInfo where jobNumber = @enterManID),'')
	set @checkMan = isnull((select userCName from activeUsers where userID = @checkManID),'')

	update AReportEnterMans
	set checkManID = @checkManID, checkMan = @checkMan, arriveTime = null, isLate = 0
	where aReportID = @aReportID and applyManID = @enterManID

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@checkManID, @checkMan, GETDATE(), '取消学术报告到达', '用户' + @checkMan
												+ '将['+@enterMan+']设置为未到达学术报告['+@aReportID+']。')
GO
--测试：
declare @checkManID varchar(10) 
set @checkManID='0000000000'
declare @Ret		int 
exec dbo.cancelCheckEnterAReport 'BG20120038','0005',@checkManID output, @Ret output
select @Ret

select * from AReportEnterMans


drop PROCEDURE aReportIsOver
/*
	name:		aReportIsOver
	function:	15.将指定的学术报告设置为完成状态
	input: 
				@aReportID varchar(10),			--学术报告编号
				@overManID varchar(10) output,	--完成设定人，如果当前学术报告正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的学术报告不存在，2：指定的学术报告正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-3
	UpdateDate: 

*/
create PROCEDURE aReportIsOver
	@aReportID varchar(10),			--学术报告编号
	@overManID varchar(10) output,	--完成设定人，如果当前学术报告正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要完成的学术报告是否存在
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from academicReports where aReportID= @aReportID
	if (@thisLockMan <> '' and @thisLockMan <> @overManID)
	begin
		set @overManID = @thisLockMan
		set @Ret = 2
		return
	end

	--取维护人的姓名：
	declare @overMan nvarchar(30)
	set @overMan = isnull((select userCName from activeUsers where userID = @overManID),'')

	declare @overTime smalldatetime
	set @overTime = GETDATE()
	update academicReports 
	set isOver = 1,
		--最新维护情况:
		modiManID = @overManID, modiManName = @overMan, modiTime = @overTime
	where aReportID= @aReportID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@overManID, @overMan, @overTime, '完成发布学术报告', '用户' + @overMan
												+ '将学术报告['+@aReportID+']设置为完成状态。')

GO


DROP PROCEDURE setAReportToTop
/*
	name:		setAReportToTop
	function:	20.将指定的已发布的学术报告置顶
	input: 
				@aReportID varchar(10),			--学术报告编号

				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前学术报告正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要置顶的学术报告不存在，2:要置顶的学术报告正在被别人编辑，3.该学术报告未激活，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-3-20
	UpdateDate: 
*/
create PROCEDURE setAReportToTop
	@aReportID varchar(10),			--学术报告编号

	--维护情况:
	@modiManID varchar(10) output,	--维护人，如果当前学术报告正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的学术报告是否存在
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID = @aReportID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @isPublish int
	select @thisLockMan = isnull(lockManID,''), @isPublish = isPublish from academicReports where aReportID = @aReportID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查学术报告状态:
	if (@isPublish <> 1)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--将已发布的学术报告重新排序：
	declare @tab table
					(
						aReportID varchar(10) not null,			--学术报告编号
						orderNum smallint default(-1)			--显示排序号
					)
	insert @tab
	select aReportID, orderNum from academicReports 
	where isPublish =1 and aReportID <> @aReportID
	order by orderNum
	begin tran
		declare @bID char(12), @i int
		set @i = 1
		declare tar cursor for
		select aReportID from @tab
		order by orderNum
		OPEN tar
		FETCH NEXT FROM tar INTO @bID
		WHILE @@FETCH_STATUS = 0
		begin
			update academicReports
			set orderNum = @i
			where aReportID = @bID
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
		--将指定的学术报告置顶：	
		update academicReports
		set orderNum = 0
		where aReportID = @aReportID
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
	values(@modiManID, @modiManName, getdate(), '学术报告置顶', '用户' + @modiManName 
												+ '将学术报告['+ @aReportID +']置顶。')
GO
--测试：
select * from academicReports
declare @Ret int 
exec dbo.setAReportToTop '201111260001', '00200977', @Ret output

DROP PROCEDURE setAReportToLast
/*
	name:		setAReportToLast
	function:	21.将指定的已发布的学术报告上移一行
	input: 
				@aReportID varchar(10),			--学术报告编号

				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前学术报告正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要移动的学术报告不存在，2:要移动的学术报告正在被别人编辑，3.该学术报告未激活，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-3-20
	UpdateDate: 
*/
create PROCEDURE setAReportToLast
	@aReportID varchar(10),			--学术报告编号

	--维护情况:
	@modiManID varchar(10) output,	--维护人，如果当前学术报告正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的学术报告是否存在
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID = @aReportID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @isPublish int
	declare @myOrderNum smallint --本学术报告的排序号
	select @thisLockMan = isnull(lockManID,''), @isPublish = isPublish, @myOrderNum = orderNum from academicReports where aReportID = @aReportID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查学术报告状态:
	if (@isPublish <> 1)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--将已发布的位置在本学术报告前面的学术报告重新排序：
	declare @tab table
					(
						aReportID char(12) not null,			--学术报告编号
						orderNum smallint default(-1)			--显示排序号
					)
	insert @tab
	select aReportID, orderNum from academicReports 
	where isPublish =1 and orderNum < @myOrderNum
	order by orderNum
	
	begin tran
		declare @bID char(12), @i int
		set @i = 1
		declare tar cursor for
		select aReportID from @tab
		order by orderNum
		OPEN tar
		FETCH NEXT FROM tar INTO @bID
		WHILE @@FETCH_STATUS = 0
		begin
			update academicReports
			set orderNum = @i
			where aReportID = @bID
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
		--将指定的学术报告上移一行：	
		update academicReports
		set orderNum = @i
		where aReportID = @bID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		update academicReports
		set orderNum = @i - 1
		where aReportID = @aReportID
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
	values(@modiManID, @modiManName, getdate(), '学术报告上移一行', '用户' + @modiManName 
												+ '将学术报告['+ @aReportID +']上移了一行。')
GO
--测试：
select * from academicReports 
where isPublish =1 
order by orderNum

declare @updateTime smalldatetime 
declare @Ret int 
exec dbo.setAReportToLast '201111270001', '00200977', @Ret output

DROP PROCEDURE setAReportToNext
/*
	name:		setAReportToNext
	function:	22.将指定的已发布的学术报告下移一行
	input: 
				@aReportID varchar(10),			--学术报告编号

				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前学术报告正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要移动的学术报告不存在，2:要移动的学术报告正在被别人编辑，3.该学术报告未激活，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-3-20
	UpdateDate: 
*/
create PROCEDURE setAReportToNext
	@aReportID varchar(10),			--学术报告编号

	--维护情况:
	@modiManID varchar(10) output,	--维护人，如果当前学术报告正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的学术报告是否存在
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID = @aReportID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @isPublish int
	declare @myOrderNum smallint --本学术报告的排序号
	select @thisLockMan = isnull(lockManID,''), @isPublish = isPublish, @myOrderNum = orderNum from academicReports where aReportID = @aReportID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查学术报告状态:
	if (@isPublish <> 1)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--将本学术报告与下一个学术报告交换位置：
	declare @nextBulletinID char(12), @nextOrderNum smallint
	select top 1 @nextBulletinID = aReportID, @nextOrderNum = orderNum 
	from academicReports 
	where isPublish =1 and orderNum > @myOrderNum
	order by orderNum
	
	if (@nextBulletinID is not null)
	begin
		begin tran
			update academicReports 
			set orderNum = @nextOrderNum
			where aReportID = @aReportID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    

			update academicReports 
			set orderNum = @myOrderNum
			where aReportID = @nextBulletinID
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
	values(@modiManID, @modiManName, getdate(), '学术报告下移一行', '用户' + @modiManName 
												+ '将学术报告['+ @aReportID +']下移了一行。')
GO
--测试：
select * from academicReports 
where isPublish =1 
order by orderNum

declare @updateTime smalldatetime 
declare @Ret int 
exec dbo.setBulletinToNext '201111270001', '00200977', @Ret output


drop PROCEDURE closeTimeOutAcademicReports
/*
	name:		closeTimeOutAcademicReports
	function:	23.自动关闭到期的学术报告（这个过程是给维护计划调度用，用户不用包装）
	input: 
	output: 
	author:		卢苇
	CreateDate:	2013-07-14
	UpdateDate:
*/
create PROCEDURE closeTimeOutAcademicReports
	WITH ENCRYPTION 
AS
	declare @count as int
	set @count=(select count(*) from academicReports where isPublish =1 and isOver=0 and convert(varchar(10),reportStartTime,120) <= convert(varchar(10),getdate(),120))	
	if (@count = 0)	--不存在
	begin
		return
	end

	update academicReports
	set isOver = 1
	where isPublish =1 and isOver=0 and convert(varchar(10),reportStartTime,120) <= convert(varchar(10),getdate(),120)

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values('', 'System', getdate(), '自动关闭到期学术报告', '系统执行了自动关闭到期学术报告的计划关闭了'+cast(@count as varchar(10))+'个到期的学术报告。')
GO




--学术报告查询语句：
select a.aReportID, a.topic, a.reportManID, a.reportMan, 
	convert(varchar(19),a.reportStartTime,120) reportStartTime, 
	convert(varchar(19),a.reportEndTime,120) reportEndTime, a.summary,
	a.reportPlaceID, a.reportPlace, a.placeIsReady,
	a.needEqpCodes, a.needEqpNames, a.eqpIsReady
from academicReports a


--报名人员查询语句：
select m.aReportID, a.topic, convert(varchar(19),a.reportStartTime,120) reportStartTime, 
	convert(varchar(19),a.reportEndTime,120) reportEndTime, 
	m.applyManID, m.applyMan, convert(varchar(10),applyTime,120) applyTime, 
	checkManID, checkMan, convert(varchar(19),m.arriveTime,120) arriveTime, isLate
from AReportEnterMans m
left join academicReports a on m.aReportID = a.aReportID
