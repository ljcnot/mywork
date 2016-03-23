use hustOA
/*
	强磁场中心办公系统-试验站管理
	author:		卢苇
	CreateDate:	2013-1-13
	UpdateDate: 
*/
--1.试验站一览表：
select * from expStationInfo
drop table expStationInfo
CREATE TABLE expStationInfo(
	expStationID varchar(10) not null,		--主键：试验站编号,本系统使用第55号号码发生器产生（'SY'+4位年份代码+4位流水号）
	expStationName nvarchar(30) null,		--试验站名称
	expStationMapFile varchar(128) null,	--试验站缩略图文件路径
	buildDate smalldatetime null,			--试验站建立日期
	scrappedDate smalldatetime null,		--试验站废止日期
	keeperID varchar(10) null,				--保管人工号
	keeper nvarchar(30) null,				--保管人:冗余设计
	
	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_expStationInfo] PRIMARY KEY CLUSTERED 
(
	[expStationID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--2.试验站使用申请表
drop table expStationApplyInfo
CREATE TABLE expStationApplyInfo(
	applyID varchar(10) not null,		--主键：试验站使用申请单号,本系统使用第51号号码发生器产生（'CA'+4位年份代码+4位流水号）
	expStationID varchar(10) not null,	--试验站编号：不使用外键，保存历史数据
	expStationName nvarchar(30) null,	--试验站名称：冗余字段
	applyManID varchar(10) not null,	--申请人工号
	applerMan nvarchar(30) not null,	--申请人姓名
	applyTime smalldatetime null,		--申请日期
	usedTime smalldatetime null,		--申请使用日期
	timeBlock xml null,					--申请使用时段：采用--<root>
															--	<timeBlock>A</timeBlock>
															--	<timeBlock>B</timeBlock>
															--</root>
										--格式存放。timeBlock中的数字表示时段，取值范围：A->上午，B->中午，C->晚上
	applyReason nvarchar(300) null,		--申请事由
	applyStatus smallint default(0),	--申请批复状态：0->未处理，1->已批准，-1：不批准
	
	approveTime smalldatetime null,		--批准时间
	approveManID varchar(10) null,		--批准人工号
	approveMan nvarchar(30) null,		--批准人姓名。冗余设计
	approveOpinion nvarchar(300) null,	--批复意见

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_expStationApplyInfo] PRIMARY KEY CLUSTERED 
(
	[applyID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--试验站ID索引：
CREATE NONCLUSTERED INDEX [IX_expStationApplyInfo] ON [dbo].[expStationApplyInfo] 
(
	[expStationID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--试验站申请使用日期状态索引：
CREATE NONCLUSTERED INDEX [IX_expStationApplyInfo_1] ON [dbo].[expStationApplyInfo] 
(
	[expStationID] ASC,
	[usedTime] ASC,
	[applyStatus] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]



drop PROCEDURE queryExpStationLocMan
/*
	name:		queryExpStationLocMan
	function:	1.查询指定试验站是否有人正在编辑
	input: 
				@expStationID varchar(10),		--试验站编号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的试验站不存在
				@lockManID varchar(10) output	--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2013-1-13
	UpdateDate: 
*/
create PROCEDURE queryExpStationLocMan
	@expStationID varchar(10),		--试验站编号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from expStationInfo where expStationID= @expStationID),'')
	set @Ret = 0
GO


drop PROCEDURE lockExpStation4Edit
/*
	name:		lockExpStation4Edit
	function:	2.锁定试验站编辑，避免编辑冲突
	input: 
				@expStationID varchar(10),		--试验站编号
				@lockManID varchar(10) output,	--锁定人，如果当前试验站正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：要锁定的试验站不存在，2:要锁定的试验站正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-13
	UpdateDate: 
*/
create PROCEDURE lockExpStation4Edit
	@expStationID varchar(10),		--试验站编号
	@lockManID varchar(10) output,	--锁定人，如果当前试验站正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的试验站是否存在
	declare @count as int
	set @count=(select count(*) from expStationInfo where expStationID= @expStationID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from expStationInfo where expStationID= @expStationID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update expStationInfo
	set lockManID = @lockManID 
	where expStationID= @expStationID
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
	values(@lockManID, @lockManName, getdate(), '锁定试验站编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了试验站['+ @expStationID +']为独占式编辑。')
GO

drop PROCEDURE unlockExpStationEditor
/*
	name:		unlockExpStationEditor
	function:	3.释放试验站编辑锁
				注意：本过程不检查试验站是否存在！
	input: 
				@expStationID varchar(10),		--试验站编号
				@lockManID varchar(10) output,	--锁定人，如果当前试验站正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-13
	UpdateDate: 
*/
create PROCEDURE unlockExpStationEditor
	@expStationID varchar(10),		--试验站编号
	@lockManID varchar(10) output,	--锁定人，如果当前试验站呢正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from expStationInfo where expStationID= @expStationID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update expStationInfo set lockManID = '' where expStationID= @expStationID
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
	values(@lockManID, @lockManName, getdate(), '释放试验站编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了试验站['+ @expStationID +']的编辑锁。')
GO

drop PROCEDURE addExpStation
/*
	name:		addExpStation
	function:	4.添加试验站信息
	input: 
				@expStationName nvarchar(30),	--试验站名称
				@expStationMapFile varchar(128),--试验站缩略图文件路径
				@buildDate varchar(10),				--试验站建立日期:采用“yyyy-MM-dd”格式传送
				@keeperID varchar(10),			--保管人工号

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output,--添加时间
				@expStationID varchar(10) output--试验站编号：本系统使用第55号号码发生器产生（'SY'+4位年份代码+4位流水号）
	author:		卢苇
	CreateDate:	2013-1-13
	UpdateDate: 
*/
create PROCEDURE addExpStation
	@expStationName nvarchar(30),		--试验站名称
	@expStationMapFile varchar(128),	--试验站缩略图文件路径
	@buildDate varchar(10),				--试验站建立日期:采用“yyyy-MM-dd”格式传送
	@keeperID varchar(10),				--保管人工号

	@createManID varchar(10),			--创建人工号
	@Ret		int output,
	@createTime smalldatetime output,
	@expStationID varchar(10) output	--试验站编号：本系统使用第55号号码发生器产生（'SY'+4位年份代码+4位流水号）
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生试验站编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 55, 1, @curNumber output
	set @expStationID = @curNumber

	--取保管人/创建人的姓名：
	declare @keeper nvarchar(30), @createManName nvarchar(30)
	set @keeper = isnull((select cName from userInfo where jobNumber = @keeperID),'')
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert expStationInfo(expStationID, expStationName, expStationMapFile, buildDate, keeperID, keeper,
					--最新维护情况:
					modiManID, modiManName, modiTime)
	values(@expStationID, @expStationName, @expStationMapFile, @buildDate, @keeperID, @keeper,
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
	values(@createManID, @createManName, @createTime, '登记试验站', '系统根据用户' + @createManName + 
					'的要求登记了试验站“' + @expStationName + '['+@expStationID+']”。')
GO
--测试：
declare	@Ret		int
declare	@createTime smalldatetime
declare	@expStationID varchar(10)
exec dbo.addExpStation '试验站3', '', '2013-1-13','G201300001','00002', @Ret output, @createTime output, @expStationID output
select @Ret, @expStationID
select * from expStationInfo

drop PROCEDURE updateExpStation
/*
	name:		updateExpStation
	function:	5.修改试验站信息
	input: 
				@expStationID varchar(10),			--试验站编号
				@expStationName nvarchar(30),		--试验站名称
				@expStationMapFile varchar(128),	--试验站缩略图文件路径
				@buildDate varchar(10),				--试验站建立日期:采用“yyyy-MM-dd”格式传送
				@keeperID varchar(10),				--保管人工号

				@modiManID varchar(10) output,	--修改人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:要修改的试验站不存在，
							2:要修改的试验站正被别人锁定编辑，
							9:未知错误
				@modiTime smalldatetime output	--修改时间
	author:		卢苇
	CreateDate:	2013-1-13
	UpdateDate: 
*/
create PROCEDURE updateExpStation
	@expStationID varchar(10),		--试验站编号
	@expStationName nvarchar(30),	--试验站名称
	@expStationMapFile varchar(128),--试验站缩略图文件路径
	@buildDate varchar(10),			--试验站建立日期:采用“yyyy-MM-dd”格式传送
	@keeperID varchar(10),			--保管人工号

	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的试验站是否存在
	declare @count as int
	set @count=(select count(*) from expStationInfo where expStationID= @expStationID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from expStationInfo where expStationID= @expStationID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--取保管人/维护人的姓名：
	declare @keeper nvarchar(30), @modiManName nvarchar(30)
	set @keeper = isnull((select cName from userInfo where jobNumber = @keeperID),'')
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')


	set @modiTime = getdate()
	update expStationInfo
	set expStationName = @expStationName, expStationMapFile = @expStationMapFile,
		buildDate=@buildDate, keeperID = @keeperID, keeper = @keeper,
		--最新维护情况:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where expStationID= @expStationID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '修改试验站', '系统根据用户' + @modiManName + 
					'的要求修改了试验站“' + @expStationName + '['+@expStationID+']”的登记信息。')
GO

drop PROCEDURE delExpStation
/*
	name:		delExpStation
	function:	6.删除指定的试验站
	input: 
				@expStationID varchar(10),		--试验站编号
				@delManID varchar(10) output,	--删除人，如果当前试验站正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的试验站不存在，2：要删除的试验站正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-13
	UpdateDate: 

*/
create PROCEDURE delExpStation
	@expStationID varchar(10),			--试验站编号
	@delManID varchar(10) output,	--删除人，如果当前试验站正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的试验站是否存在
	declare @count as int
	set @count=(select count(*) from expStationInfo where expStationID= @expStationID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from expStationInfo where expStationID= @expStationID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete expStationInfo where expStationID= @expStationID
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除试验站', '用户' + @delManName
												+ '删除了试验站['+@expStationID+']。')

GO

drop PROCEDURE stopExpStation
/*
	name:		stopExpStation
	function:	7.停用指定的试验站
	input: 
				@expStationID varchar(10),		--试验站编号
				@stopManID varchar(10) output,	--停用人，如果当前试验站正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的试验站不存在，2：要停用的试验站正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-13
	UpdateDate: 

*/
create PROCEDURE stopExpStation
	@expStationID varchar(10),		--试验站编号
	@stopManID varchar(10) output,	--停用人，如果当前试验站正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要停用的试验站是否存在
	declare @count as int
	set @count=(select count(*) from expStationInfo where expStationID= @expStationID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from expStationInfo where expStationID= @expStationID
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete expStationInfo where expStationID= @expStationID
	set @Ret = 0

	--取维护人的姓名：
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, getdate(), '停用试验站', '用户' + @stopManName
												+ '停用了试验站['+@expStationID+']。')

GO
----------------------------------------------试验站申请表管理------------------------------------------------------
drop PROCEDURE queryExpStationApplyLocMan
/*
	name:		queryExpStationApplyLocMan
	function:	11.查询指定试验站申请单是否有人正在编辑
	input: 
				@applyID varchar(10),		--试验站申请单编号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的试验站申请单不存在
				@lockManID varchar(10) output	--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2013-1-13
	UpdateDate: 
*/
create PROCEDURE queryExpStationApplyLocMan
	@applyID varchar(10),		--试验站申请单编号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from expStationApplyInfo where applyID= @applyID),'')
	set @Ret = 0
GO


drop PROCEDURE lockExpStationApply4Edit
/*
	name:		lockExpStationApply4Edit
	function:	12.锁定试验站申请单编辑，避免编辑冲突
	input: 
				@applyID varchar(10),			--试验站申请单编号
				@lockManID varchar(10) output,	--锁定人，如果当前试验站申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的试验站申请单不存在，2:要锁定的试验站申请单正在被别人编辑，
							3:该单据已经批复，不能编辑锁定，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-13
	UpdateDate: 
*/
create PROCEDURE lockExpStationApply4Edit
	@applyID varchar(10),		--试验站申请单编号
	@lockManID varchar(10) output,	--锁定人，如果当前试验站申请单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的试验站申请单是否存在
	declare @count as int
	set @count=(select count(*) from expStationApply where applyID= @applyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @applyStatus smallint	--锁定人/申请批复状态：0->未处理，1->已批准，-1：不批准
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus 
	from expStationApplyInfo 
	where applyID= @applyID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态：
	if (@applyStatus<>0)
	begin
		set @Ret = 3
		return
	end

	update expStationApplyInfo
	set lockManID = @lockManID 
	where applyID= @applyID
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
	values(@lockManID, @lockManName, getdate(), '锁定试验站申请编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了试验站申请['+ @applyID +']为独占式编辑。')
GO

drop PROCEDURE unlockExpStationApplyEditor
/*
	name:		unlockExpStationApplyEditor
	function:	13.释放试验站申请单编辑锁
				注意：本过程不检查试验站申请单是否存在！
	input: 
				@applyID varchar(10),			--试验站申请单编号
				@lockManID varchar(10) output,	--锁定人，如果当前试验站申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-13
	UpdateDate: 
*/
create PROCEDURE unlockExpStationApplyEditor
	@applyID varchar(10),			--试验站申请单编号
	@lockManID varchar(10) output,	--锁定人，如果当前试验站申请单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from expStationApplyInfo where applyID= @applyID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update expStationApplyInfo set lockManID = '' where applyID= @applyID
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
	values(@lockManID, @lockManName, getdate(), '释放试验站申请编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了试验站申请单['+ @applyID +']的编辑锁。')
GO

drop PROCEDURE addExpStationApply
/*
	name:		addExpStationApply
	function:	14.添加试验站申请单
	input: 
				@expStationID varchar(10),		--试验站编号：不使用外键，保存历史数据
				@applyManID varchar(10),	--申请人工号
				@applyTime varchar(10),		--申请日期：采用"yyyy-MM-dd"格式传送
				@usedTime varchar(10),		--申请使用日期：采用"yyyy-MM-dd"格式传送
				@timeBlock xml,				--申请使用时段：采用--<root>
																--	<timeBlock>A</timeBlock>
																--	<timeBlock>B</timeBlock>
																--</root>
											--格式存放。timeBlock中的数字表示时段，取值范围：A->上午，B->中午，C->晚上
				@applyReason nvarchar(300),	--申请事由

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output,--添加时间
				@applyID varchar(10) output	--试验站申请单号：本系统使用第56号号码发生器产生（'SA'+4位年份代码+4位流水号）
	author:		卢苇
	CreateDate:	2013-1-13
	UpdateDate: 
*/
create PROCEDURE addExpStationApply
	@expStationID varchar(10),		--试验站编号：不使用外键，保存历史数据
	@applyManID varchar(10),	--申请人工号
	@applyTime varchar(10),		--申请日期：采用"yyyy-MM-dd"格式传送
	@usedTime varchar(10),		--申请使用日期：采用"yyyy-MM-dd"格式传送
	@timeBlock xml,				--申请使用时段：采用--<root>
													--	<timeBlock>A</timeBlock>
													--	<timeBlock>B</timeBlock>
													--</root>
								--格式存放。timeBlock中的数字表示时段，取值范围：A->上午，B->中午，C->晚上
	@applyReason nvarchar(300),	--申请事由
	
	@createManID varchar(10),	--创建人工号
	@Ret		int output,
	@createTime smalldatetime output,
	@applyID varchar(10) output	--试验站申请单号：本系统使用第56号号码发生器产生（'SA'+4位年份代码+4位流水号）
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生试验站编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 56, 1, @curNumber output
	set @applyID = @curNumber
	
	--取试验站名称：
	declare @expStationName nvarchar(30)		--试验站名称
	set @expStationName = isnull((select expStationName from expStationInfo where expStationID = @expStationID),'')
	--取创建人的姓名：
	declare @createManName nvarchar(30), @applerMan nvarchar(30)	--申请人姓名
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @applerMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')
	
	set @createTime = getdate()
	insert expStationApplyInfo(applyID, expStationID, expStationName, applyManID, applerMan, 
						applyTime, usedTime, timeBlock, applyReason, 
						--最新维护情况:
						modiManID, modiManName, modiTime)
	values(@applyID, @expStationID, @expStationName, @applyManID, @applerMan, 
			@applyTime, @usedTime, @timeBlock, @applyReason,
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
	values(@createManID, @createManName, @createTime, '登记试验站申请', '系统根据用户' + @createManName + 
					'的要求登记了试验站“' + @expStationName + '”的申请单['+@applyID+']”。')
GO
--测试：
declare	@Ret		int
declare	@createTime smalldatetime
declare	@applyID varchar(10)
exec dbo.addExpStationApply 'SY20130001', '00002', '2013-01-08', '2013-01-9',
	N'<root>
		<timeBlock>B</timeBlock>
	</root>',
	'1.实验；2.实验','00002',
	 @Ret output, @createTime output, @applyID output
select @Ret, @applyID
select * from expStationApplyInfo

drop PROCEDURE updateExpStationApply
/*
	name:		updateExpStationApply
	function:	15.修改试验站申请单信息
	input: 
				@applyID varchar(10),		--试验站申请单编号
				@expStationID varchar(10),	--试验站编号：不使用外键，保存历史数据
				@applyManID varchar(10),	--申请人工号
				@applyTime varchar(10),		--申请日期：采用"yyyy-MM-dd"格式传送
				@usedTime varchar(10),		--申请使用日期：采用"yyyy-MM-dd"格式传送
				@timeBlock xml,				--申请使用时段：采用--<root>
																--	<timeBlock>A</timeBlock>
																--	<timeBlock>B</timeBlock>
																--</root>
											--格式存放。timeBlock中的数字表示时段，取值范围：A->上午，B->中午，C->晚上
				@applyReason nvarchar(300),	--申请事由

				@modiManID varchar(10) output,	--修改人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:要修改的单据不存在，
							2:要修改的单据正被别人锁定编辑，
							3:该单据已经批复，不能修改
							9:未知错误
				@modiTime smalldatetime output	--修改时间
	author:		卢苇
	CreateDate:	2013-1-13
	UpdateDate: 
*/
create PROCEDURE updateExpStationApply
	@applyID varchar(10),		--试验站申请单编号
	@expStationID varchar(10),	--试验站编号：不使用外键，保存历史数据
	@applyManID varchar(10),	--申请人工号
	@applyTime varchar(10),		--申请日期：采用"yyyy-MM-dd"格式传送
	@usedTime varchar(10),		--申请使用日期：采用"yyyy-MM-dd"格式传送
	@timeBlock xml,				--申请使用时段：采用--<root>
													--	<timeBlock>A</timeBlock>
													--	<timeBlock>B</timeBlock>
													--</root>
								--格式存放。timeBlock中的数字表示时段，取值范围：A->上午，B->中午，C->晚上
	@applyReason nvarchar(300),	--申请事由

	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--注意：这里没有做试验站是否存在的判断！

	--判断要锁定的试验站申请单是否存在
	declare @count as int
	set @count=(select count(*) from expStationApplyInfo where applyID= @applyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @applyStatus smallint	--锁定人/申请批复状态：0->未处理，1->已批准，-1：不批准
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus 
	from expStationApplyInfo 
	where applyID= @applyID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态：
	if (@applyStatus<>0)
	begin
		set @Ret = 3
		return
	end

	--取试验站名称：
	declare @expStationName nvarchar(30)		--试验站名称
	set @expStationName = isnull((select expStationName from expStationInfo where expStationID = @expStationID),'')
	--取维护人/申请人的姓名：
	declare @modiManName nvarchar(30), @applerMan nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	set @applerMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')

	set @modiTime = getdate()
	update expStationApplyInfo
	set expStationID = @expStationID, expStationName = @expStationName,
		applyManID = @applyManID, applerMan = @applerMan, 
		applyTime = @applyTime, usedTime = @usedTime, timeBlock = @timeBlock,
		applyReason = @applyReason, 
		--最新维护情况:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where applyID= @applyID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '修改试验站申请', '系统根据用户' + @modiManName + 
					'的要求修改了试验站“' + @expStationName + '”的申请单['+@applyID+']”的登记信息。')
GO

drop PROCEDURE delExpStationApply
/*
	name:		delExpStationApply
	function:	16.删除指定的试验站申请单
	input: 
				@applyID varchar(10),			--试验站申请单编号
				@delManID varchar(10) output,	--删除人，如果当前试验站申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的试验站申请单不存在，2：要删除的试验站申请单正被别人锁定，
							3：该单据已经批复，不能删除，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-13
	UpdateDate: 

*/
create PROCEDURE delExpStationApply
	@applyID varchar(10),			--试验站申请单编号
	@delManID varchar(10) output,	--删除人，如果当前试验站申请单正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的试验站申请单是否存在
	declare @count as int
	set @count=(select count(*) from expStationApplyInfo where applyID= @applyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @applyStatus smallint	--锁定人/申请批复状态：0->未处理，1->已批准，-1：不批准
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus 
	from expStationApplyInfo 
	where applyID= @applyID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态：
	if (@applyStatus<>0)
	begin
		set @Ret = 3
		return
	end

	delete expStationApplyInfo where applyID= @applyID
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除试验站申请', '用户' + @delManName
												+ '删除了试验站申请单['+@applyID+']。')

GO

drop PROCEDURE approveExpStationApply
/*
	name:		approveExpStationApply
	function:	17.批复指定的试验站申请单
	input: 
				@applyID varchar(10),				--试验站申请单编号
				@isAgree smallint,					--是否同意：1->同意,-1：不同意
				@approveOpinion nvarchar(300),		--批复意见
				@approveManID varchar(10) output,	--批复人，如果当前试验站申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output				--操作成功标识
							0:成功，1：指定的试验站申请单不存在，2：要批复的试验站申请单正被别人锁定，
							3：该试验站申请单已经批复，4:在执行关联单据的操作时出错，
							5：该单据申请的时间段已经被占用，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-13
	UpdateDate: 

*/
create PROCEDURE approveExpStationApply
	@applyID varchar(10),				--试验站申请单编号
	@isAgree smallint,					--是否同意：1->同意,-1：不同意
	@approveOpinion nvarchar(300),		--批复意见
	@approveManID varchar(10) output,	--批复人，如果当前试验站申请单正在被人占用编辑则返回该人的工号
	@Ret		int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的试验站申请单是否存在
	declare @count as int
	set @count=(select count(*) from expStationApplyInfo where applyID= @applyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @applyStatus smallint	--锁定人/申请批复状态：0->未处理，1->已批准，-1：不批准
	declare @usedTime smalldatetime
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus, @usedTime = usedTime
	from expStationApplyInfo 
	where applyID= @applyID
	if (@thisLockMan <> '' and @thisLockMan <> @approveManID)
	begin
		set @approveManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态：
	if (@applyStatus<>0)
	begin
		set @Ret = 3
		return
	end
	--检查时间块是否有冲突：
	declare @usedBlock table(expStationID varchar(10), block varchar(4))
	insert @usedBlock(expStationID, block)
	select p.expStationID, cast(T2.timeBlock.query('./text()') as varchar(4)) timeB
	from expStationApplyInfo p 
	CROSS APPLY timeBlock.nodes('/root/timeBlock') as T2(timeBlock)
	where convert(varchar(10),p.usedTime,120)=convert(varchar(10),@usedTime,120) and p.applyStatus = 1
	order by timeB;
	WITH CTE
	AS ( 
		select p.expStationID, cast(T2.timeBlock.query('./text()') as varchar(4)) timeB
		from expStationApplyInfo p 
		CROSS APPLY timeBlock.nodes('/root/timeBlock') as T2(timeBlock)
		where p.applyID = @applyID
	)
	select @count = count(*) from CTE where timeB in (select block from @usedBlock)
	if (@count > 0)	--冲突
	begin
		set @Ret = 5
		return
	end

	--取批复人的姓名：
	declare @approveMan nvarchar(30)
	set @approveMan = isnull((select userCName from activeUsers where userID = @approveManID),'')
	
	declare @approveTime smalldatetime
	set @approveTime = GETDATE()
	update expStationApplyInfo
	set applyStatus = @isAgree,approveTime = @approveTime,
		approveManID = @approveManID, approveMan = @approveMan, approveOpinion = @approveOpinion
	where applyID= @applyID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@approveManID, @approveMan, @approveTime, '批复试验站申请', '用户' + @approveMan
												+ '批复了试验站申请单['+@applyID+']。')
GO
--测试：
declare @Ret int	--操作成功标识
exec dbo.approveExpStationApply 'SA20130003', 1, '同意', 'G20130001', @Ret output
select @Ret

select * from expStationApplyInfo



--试验站的查询语句：
select expStationID, expStationName, expStationMapFile
from expStationInfo

use hustOA
--试验站使用申请表查询语句：用xml表示时间块
select applyID, expStationID, expStationName, applyManID, applerMan, applyTime, 
	usedTime, timeBlock,					--申请使用时段：采用--<root>
											--	<timeBlock>A</timeBlock>
											--	<timeBlock>B</timeBlock>
											--</root>
										--格式存放。timeBlock中的数字表示时段，取值范围：A->上午，B->下午,C->晚上
	applyReason, applyStatus, approveTime, approveManID, approveMan, approveOpinion
from expStationApplyInfo


--试验站使用申请表查询语句：时间块转换为行集
select a.expStationID, a.expStationName, p.applyID, p.expStationID, p.expStationName, p.applyManID, p.applerMan, p.applyTime, p.usedTime, 
	p.applyReason, p.applyStatus, p.approveTime, p.approveManID, p.approveMan, p.approveOpinion,
	cast(T2.timeBlock.query('./text()') as varchar(4)) timeB
from expStationInfo a left join (expStationApplyInfo p 
CROSS APPLY timeBlock.nodes('/root/timeBlock') as T2(timeBlock)) on a.expStationID = p.expStationID 
order by a.expStationID, timeB

--试验站时间状态查询语句：
select p.applyID, p.expStationID, p.expStationName, p.applyManID, p.applerMan, p.applyTime, p.usedTime,
p.applyReason, p.applyStatus,
cast(T2.timeBlock.query('./text()') as varchar(4)) timeB
from expStationApplyInfo p 
CROSS APPLY timeBlock.nodes('/root/timeBlock') as T2(timeBlock)
where convert(varchar(10),p.usedTime,120)='2013-1-13' and p.applyStatus <> -1
order by timeB, p.applyStatus


select applyID, expStationID, expStationName, applyManID, applerMan, applyTime, 
	usedTime, timeBlock,					--申请使用时段：采用--<root>
											--	<timeBlock>8</timeBlock>
											--	<timeBlock>9</timeBlock>
											--</root>
										--格式存放。timeBlock中的数字表示时段，取值范围：0~23
	applyReason, applyStatus, approveTime, approveManID, approveMan, approveOpinion
from expStationApplyInfo
order by applyID desc





select expStationID, expStationName, expStationMapFile, buildDate, keeperID, keeper
from expStationInfo
order by expStationID
