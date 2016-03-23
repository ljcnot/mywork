use hustOA
/*
	强磁场中心办公系统-气体管理
	author:		卢苇
	CreateDate:	2013-1-13
	UpdateDate: 
*/
--1.气体一览表：
alter TABLE gasInfo add	gasUnit nvarchar(4) null		--计量单位
update gasInfo
set gasUnit='L'

select * from gasInfo
drop table gasInfo
CREATE TABLE gasInfo(
	gasID varchar(10) not null,		--主键：气体编号,本系统使用第60号号码发生器产生（'QT'+4位年份代码+4位流水号）
	gasName nvarchar(30) null,		--气体名称
	gasUnit nvarchar(4) null,		--计量单位
	buildDate smalldatetime null,	--气体建立日期
	scrappedDate smalldatetime null,--气体废止日期
	keeperID varchar(10) null,		--保管人工号
	keeper nvarchar(30) null,		--保管人:冗余设计
	
	--最新维护情况:
	modiManID varchar(10) null,		--维护人工号
	modiManName nvarchar(30) null,	--维护人姓名
	modiTime smalldatetime null,	--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),			--当前正在锁定编辑的人工号
 CONSTRAINT [PK_gasInfo] PRIMARY KEY CLUSTERED 
(
	[gasID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--2.气体每日存量用量一览表：
alter table gasStock add	applyID varchar(10) null		--气体使用申请单号,当是用量时填写add by lw 2013-3-24
select * from gasStock
drop table gasStock
CREATE TABLE gasStock(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号：排序使用
	gasID varchar(10) not null,		--外键：气体编号
	gasName nvarchar(30) null,		--气体名称：冗余设计
	applyID varchar(10) null,		--气体使用申请单号,当是用量时填写,为支持审批后的单据继续审批add by lw 2013-3-24
	theDate smalldatetime not null,	--日期
	stockQuantity int default(0),	--库存数量，指添加的数量,单位：L
	usedQuantity int default(0),	--用量，单位：L

 CONSTRAINT [PK_gasStock] PRIMARY KEY CLUSTERED 
(
	[gasID] ASC,
	[theDate] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[gasStock] WITH CHECK ADD CONSTRAINT [FK_gasStock_gasInfo] FOREIGN KEY([gasID])
REFERENCES [dbo].[gasInfo] ([gasID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[gasStock] CHECK CONSTRAINT [FK_gasStock_gasInfo] 
GO


--3.气体使用申请表
drop table gasApplyInfo
CREATE TABLE gasApplyInfo(
	applyID varchar(10) not null,		--主键：气体使用申请单号,本系统使用第61号号码发生器产生（'QA'+4位年份代码+4位流水号）
	gasID varchar(10) not null,			--气体编号：不使用外键，保存历史数据
	gasName nvarchar(30) null,			--气体名称：冗余字段
	applyManID varchar(10) not null,	--申请人工号
	applerMan nvarchar(30) not null,	--申请人姓名
	applyTime smalldatetime null,		--申请日期
	usedTime smalldatetime null,		--申请使用日期
	applyQuantity int default(0),		--申请用量
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
 CONSTRAINT [PK_gasApplyInfo] PRIMARY KEY CLUSTERED 
(
	[applyID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--气体ID索引：
CREATE NONCLUSTERED INDEX [IX_gasApplyInfo] ON [dbo].[gasApplyInfo] 
(
	[gasID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--气体申请使用日期状态索引：
CREATE NONCLUSTERED INDEX [IX_gasApplyInfo_1] ON [dbo].[gasApplyInfo] 
(
	[gasID] ASC,
	[usedTime] ASC,
	[applyStatus] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]



drop PROCEDURE queryGasInfoLocMan
/*
	name:		queryGasInfoLocMan
	function:	1.查询指定气体是否有人正在编辑
	input: 
				@gasID varchar(10),		--气体编号
	output: 
				@Ret		int output	--操作成功标识
							0:成功，9：查询出错，可能是指定的气体不存在
				@lockManID varchar(10) output	--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2013-1-14
	UpdateDate: 
*/
create PROCEDURE queryGasInfoLocMan
	@gasID varchar(10),		--气体编号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from gasInfo where gasID= @gasID),'')
	set @Ret = 0
GO


drop PROCEDURE lockGasInfo4Edit
/*
	name:		lockGasInfo4Edit
	function:	2.锁定气体编辑，避免编辑冲突
	input: 
				@gasID varchar(10),				--气体编号
				@lockManID varchar(10) output,	--锁定人，如果当前气体正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的气体不存在，2:要锁定的气体正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-14
	UpdateDate: 
*/
create PROCEDURE lockGasInfo4Edit
	@gasID varchar(10),		--气体编号
	@lockManID varchar(10) output,	--锁定人，如果当前气体正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的气体是否存在
	declare @count as int
	set @count=(select count(*) from gasInfo where gasID= @gasID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from gasInfo where gasID= @gasID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update gasInfo
	set lockManID = @lockManID 
	where gasID= @gasID
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
	values(@lockManID, @lockManName, getdate(), '锁定气体编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了气体['+ @gasID +']为独占式编辑。')
GO

drop PROCEDURE unlockGasInfoEditor
/*
	name:		unlockGasInfoEditor
	function:	3.释放气体编辑锁
				注意：本过程不检查气体是否存在！
	input: 
				@gasID varchar(10),				--气体编号
				@lockManID varchar(10) output,	--锁定人，如果当前气体正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-14
	UpdateDate: 
*/
create PROCEDURE unlockGasInfoEditor
	@gasID varchar(10),			--气体编号
	@lockManID varchar(10) output,	--锁定人，如果当前气体呢正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from gasInfo where gasID= @gasID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update gasInfo set lockManID = '' where gasID= @gasID
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
	values(@lockManID, @lockManName, getdate(), '释放气体编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了气体['+ @gasID +']的编辑锁。')
GO

drop PROCEDURE addGasInfo
/*
	name:		addGasInfo
	function:	4.添加气体信息
	input: 
				@gasName nvarchar(30),		--气体名称
				@gasUnit nvarchar(4),		--计量单位
				@buildDate varchar(10),		--气体建立日期:采用“yyyy-MM-dd”格式传送
				@keeperID varchar(10),		--保管人工号

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output,--添加时间
				@gasID varchar(10) output		--气体编号：本系统使用第60号号码发生器产生（'qt'+4位年份代码+4位流水号）
	author:		卢苇
	CreateDate:	2013-1-14
	UpdateDate: modi by lw 2013-4-23增加计量单位
*/
create PROCEDURE addGasInfo
	@gasName nvarchar(30),		--气体名称
	@gasUnit nvarchar(4),		--计量单位
	@buildDate varchar(10),		--气体建立日期:采用“yyyy-MM-dd”格式传送
	@keeperID varchar(10),		--保管人工号

	@createManID varchar(10),		--创建人工号
	@Ret		int output,
	@createTime smalldatetime output,
	@gasID varchar(10) output		--气体编号：本系统使用第60号号码发生器产生（'QT'+4位年份代码+4位流水号）
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生气体编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 60, 1, @curNumber output
	set @gasID = @curNumber

	--取保管人/创建人的姓名：
	declare @keeper nvarchar(30), @createManName nvarchar(30)
	set @keeper = isnull((select cName from userInfo where jobNumber = @keeperID),'')
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert gasInfo(gasID, gasName, gasUnit, buildDate, keeperID, keeper,
					--最新维护情况:
					modiManID, modiManName, modiTime)
	values(@gasID, @gasName, @gasUnit, @buildDate, @keeperID, @keeper,
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
	values(@createManID, @createManName, @createTime, '登记气体', '系统根据用户' + @createManName + 
					'的要求登记了气体“' + @gasName + '['+@gasID+']”。')
GO
--测试：
declare	@Ret		int
declare	@createTime smalldatetime
declare	@gasID varchar(10)
exec dbo.addGasInfo 'He气', '2013-1-13','G201300001','00002', @Ret output, @createTime output, @gasID output
select @Ret, @gasID

select * from gasInfo

drop PROCEDURE updateGasInfo
/*
	name:		updateGasInfo
	function:	5.修改气体信息
	input: 
				@gasID varchar(10),			--气体编号
				@gasName nvarchar(30),		--气体名称
				@gasUnit nvarchar(4),		--计量单位
				@buildDate varchar(10),		--气体建立日期:采用“yyyy-MM-dd”格式传送
				@keeperID varchar(10),		--保管人工号

				@modiManID varchar(10) output,	--修改人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:要修改的气体不存在，
							2:要修改的气体正被别人锁定编辑，
							9:未知错误
				@modiTime smalldatetime output	--修改时间
	author:		卢苇
	CreateDate:	2013-1-14
	UpdateDate: modi by lw 2013-4-23增加计量单位
*/
create PROCEDURE updateGasInfo
	@gasID varchar(10),			--气体编号
	@gasName nvarchar(30),		--气体名称
	@gasUnit nvarchar(4),		--计量单位
	@buildDate varchar(10),		--气体建立日期:采用“yyyy-MM-dd”格式传送
	@keeperID varchar(10),		--保管人工号

	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的气体是否存在
	declare @count as int
	set @count=(select count(*) from gasInfo where gasID= @gasID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from gasInfo where gasID= @gasID
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
	update gasInfo
	set gasName = @gasName, gasUnit = @gasUnit,
		buildDate=@buildDate, keeperID = @keeperID, keeper = @keeper,
		--最新维护情况:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where gasID= @gasID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '修改气体', '系统根据用户' + @modiManName + 
					'的要求修改了气体“' + @gasName + '['+@gasID+']”的登记信息。')
GO

drop PROCEDURE delGasInfo
/*
	name:		delGasInfo
	function:	6.删除指定的气体
	input: 
				@gasID varchar(10),			--气体编号
				@delManID varchar(10) output,	--删除人，如果当前气体正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的气体不存在，2：要删除的气体正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-14
	UpdateDate: 

*/
create PROCEDURE delGasInfo
	@gasID varchar(10),			--气体编号
	@delManID varchar(10) output,	--删除人，如果当前气体正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要删除的气体是否存在
	declare @count as int
	set @count=(select count(*) from gasInfo where gasID= @gasID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from gasInfo where gasID= @gasID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete gasInfo where gasID= @gasID
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除气体', '用户' + @delManName
												+ '删除了气体['+@gasID+']。')

GO

drop PROCEDURE stopGasInfo
/*
	name:		stopGasInfo
	function:	7.停用指定的气体
	input: 
				@gasID varchar(10),				--气体编号
				@stopManID varchar(10) output,	--停用人，如果当前气体正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的气体不存在，2：要停用的气体正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-14
	UpdateDate: 

*/
create PROCEDURE stopGasInfo
	@gasID varchar(10),				--气体编号
	@stopManID varchar(10) output,	--停用人，如果当前气体正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要停用的气体是否存在
	declare @count as int
	set @count=(select count(*) from gasInfo where gasID= @gasID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from gasInfo where gasID= @gasID
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end

	update gasInfo 
	set scrappedDate = GETDATE()
	where gasID= @gasID
	set @Ret = 0

	--取维护人的姓名：
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, getdate(), '停用气体', '用户' + @stopManName
												+ '停用了气体['+@gasID+']。')

GO


drop PROCEDURE addGasStock
/*
	name:		addGasStock
	function:	8.添加指定的气体指定日期的库存量
	input: 
				@gasID varchar(10),				--气体编号
				@theDate varchar(10),			--指定的日期：采用“yyyy-MM-dd”格式传送
				@stockQuantity int,				--库存量
				@addManID varchar(10) output,	--添加人，如果当前气体正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的气体不存在，2：该气体正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-14
	UpdateDate: 

*/
create PROCEDURE addGasStock
	@gasID varchar(10),				--气体编号
	@theDate varchar(10),			--指定的日期：采用“yyyy-MM-dd”格式传送
	@stockQuantity int,				--库存量
	@addManID varchar(10) output,	--添加人，如果当前气体正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要停用的气体是否存在
	declare @count as int
	set @count=(select count(*) from gasInfo where gasID= @gasID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10),@gasName nvarchar(30)
	select @thisLockMan = isnull(lockManID,''), @gasName = gasName from gasInfo where gasID= @gasID
	if (@thisLockMan <> '' and @thisLockMan <> @addManID)
	begin
		set @addManID = @thisLockMan
		set @Ret = 2
		return
	end

	--将前期剩余库存量加入：add by lw2013-3-24
	insert gasStock(gasID,gasName,theDate,stockQuantity)
	values(@gasID,@gasName,@theDate,@stockQuantity)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--取维护人的姓名：
	declare @addManName nvarchar(30)
	set @addManName = isnull((select userCName from activeUsers where userID = @addManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@addManID, @addManName, getdate(), '添加气体库存量', '用户' + @addManName
												+ '添加了气体['+@gasName+']的库存量['+STR(@stockQuantity,4)+']升。')

GO
--测试：
declare	@Ret		int --操作成功标识
EXEC DBO.addGasStock 'QT20130004','2013-01-16', 200, 'G201300001', @Ret output
select @Ret

select * from gasInfo
----------------------------------------------气体申请表管理------------------------------------------------------
drop PROCEDURE queryGasApplyLocMan
/*
	name:		queryGasApplyLocMan
	function:	11.查询指定气体申请单是否有人正在编辑
	input: 
				@applyID varchar(10),		--气体申请单编号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的气体申请单不存在
				@lockManID varchar(10) output	--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2013-1-14
	UpdateDate: 
*/
create PROCEDURE queryGasApplyLocMan
	@applyID varchar(10),		--气体申请单编号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from gasApplyInfo where applyID= @applyID),'')
	set @Ret = 0
GO


drop PROCEDURE lockGasApply4Edit
/*
	name:		lockGasApply4Edit
	function:	12.锁定气体申请单编辑，避免编辑冲突
	input: 
				@applyID varchar(10),			--气体申请单编号
				@lockManID varchar(10) output,	--锁定人，如果当前气体申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的气体申请单不存在，2:要锁定的气体申请单正在被别人编辑，
							3:该单据已经批复，不能编辑锁定，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-14
	UpdateDate: 
*/
create PROCEDURE lockGasApply4Edit
	@applyID varchar(10),		--气体申请单编号
	@lockManID varchar(10) output,	--锁定人，如果当前气体申请单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的气体申请单是否存在
	declare @count as int
	set @count=(select count(*) from gasApplyInfo where applyID= @applyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @applyStatus smallint	--锁定人/申请批复状态：0->未处理，1->已批准，-1：不批准
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus 
	from gasApplyInfo 
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

	update gasApplyInfo
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
	values(@lockManID, @lockManName, getdate(), '锁定气体申请编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了气体申请['+ @applyID +']为独占式编辑。')
GO

drop PROCEDURE unlockGasApplyEditor
/*
	name:		unlockGasApplyEditor
	function:	13.释放气体申请单编辑锁
				注意：本过程不检查气体申请单是否存在！
	input: 
				@applyID varchar(10),			--气体申请单编号
				@lockManID varchar(10) output,	--锁定人，如果当前气体申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-14
	UpdateDate: 
*/
create PROCEDURE unlockGasApplyEditor
	@applyID varchar(10),			--气体申请单编号
	@lockManID varchar(10) output,	--锁定人，如果当前气体申请单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from gasApplyInfo where applyID= @applyID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update gasApplyInfo set lockManID = '' where applyID= @applyID
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
	values(@lockManID, @lockManName, getdate(), '释放气体申请编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了气体申请单['+ @applyID +']的编辑锁。')
GO

drop PROCEDURE addGasApply
/*
	name:		addGasApply
	function:	14.添加气体申请单
	input: 
				@gasID varchar(10),			--气体编号：不使用外键，保存历史数据
				@applyManID varchar(10),	--申请人工号
				@applyTime varchar(10),		--申请日期：采用"yyyy-MM-dd"格式传送
				@usedTime varchar(10),		--申请使用日期：采用"yyyy-MM-dd"格式传送
				@applyQuantity int,			--申请用量
				@applyReason nvarchar(300),	--申请事由
				
				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output,--添加时间
				@applyID varchar(10) output	--气体申请单编号：本系统使用第61号号码发生器产生（'QA'+4位年份代码+4位流水号）
	author:		卢苇
	CreateDate:	2013-1-14
	UpdateDate: 
*/
create PROCEDURE addGasApply
	@gasID varchar(10),			--气体编号：不使用外键，保存历史数据
	@applyManID varchar(10),	--申请人工号
	@applyTime varchar(10),		--申请日期：采用"yyyy-MM-dd"格式传送
	@usedTime varchar(10),		--申请使用日期：采用"yyyy-MM-dd"格式传送
	@applyQuantity int,			--申请用量
	@applyReason nvarchar(300),	--申请事由
	
	@createManID varchar(10),	--创建人工号
	@Ret		int output,
	@createTime smalldatetime output,
	@applyID varchar(10) output	--气体申请单编号：本系统使用第61号号码发生器产生（'QA'+4位年份代码+4位流水号）
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生气体编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 61, 1, @curNumber output
	set @applyID = @curNumber
	
	--取气体名称：
	declare @gasName nvarchar(30)		--气体名称
	set @gasName = isnull((select gasName from gasInfo where gasID = @gasID),'')
	--取创建人的姓名：
	declare @createManName nvarchar(30), @applerMan nvarchar(30)	--申请人姓名
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @applerMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')
	
	set @createTime = getdate()
	insert gasApplyInfo(applyID, gasID, gasName, applyManID, applerMan, 
						applyTime, usedTime, applyQuantity,
						applyReason,
						--最新维护情况:
						modiManID, modiManName, modiTime)
	values(@applyID, @gasID, @gasName, @applyManID, @applerMan, 
			@applyTime, @usedTime, @applyQuantity,
			@applyReason,
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
	values(@createManID, @createManName, @createTime, '登记气体申请', '系统根据用户' + @createManName + 
					'的要求登记了气体“' + @gasName + '”的申请单['+@applyID+']”。')
GO
--测试：
declare	@Ret		int
declare	@createTime smalldatetime
declare	@applyID varchar(10)
exec dbo.addGasApply 'QT20130002', '00002', '2013-01-16', '2013-01-16',
	10,'试验用','00002',
	 @Ret output, @createTime output, @applyID output
select @Ret, @applyID
select * from gasApplyInfo

drop PROCEDURE updateGasApply
/*
	name:		updateGasApply
	function:	15.修改气体申请单信息
	input: 
				@applyID varchar(10),		--气体申请单编号
				@gasID varchar(10),		--气体编号：不使用外键，保存历史数据
				@applyManID varchar(10),	--申请人工号
				@applyTime varchar(10),		--申请日期：采用"yyyy-MM-dd"格式传送
				@usedTime varchar(10),		--申请使用日期：采用"yyyy-MM-dd"格式传送
				@applyQuantity int,			--申请用量
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
	CreateDate:	2013-1-14
	UpdateDate: 
*/
create PROCEDURE updateGasApply
	@applyID varchar(10),		--气体申请单编号
	@gasID varchar(10),		--气体编号：不使用外键，保存历史数据
	@applyManID varchar(10),	--申请人工号
	@applyTime varchar(10),		--申请日期：采用"yyyy-MM-dd"格式传送
	@usedTime varchar(10),		--申请使用日期：采用"yyyy-MM-dd"格式传送
	@applyQuantity int,			--申请用量
	@applyReason nvarchar(300),	--申请事由

	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--注意：这里没有做气体是否存在的判断！

	--判断要锁定的气体申请单是否存在
	declare @count as int
	set @count=(select count(*) from gasApplyInfo where applyID= @applyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @applyStatus smallint	--锁定人/申请批复状态：0->未处理，1->已批准，-1：不批准
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus 
	from gasApplyInfo 
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

	--取气体名称：
	declare @gasName nvarchar(30)		--气体名称
	set @gasName = isnull((select gasName from gasInfo where gasID = @gasID),'')
	--取维护人/申请人的姓名：
	declare @modiManName nvarchar(30), @applerMan nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	set @applerMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')

	set @modiTime = getdate()
	update gasApplyInfo
	set gasID = @gasID, gasName = @gasName,
		applyManID = @applyManID, applerMan = @applerMan, 
		applyTime = @applyTime, usedTime = @usedTime, applyQuantity = @applyQuantity,
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
	values(@modiManID, @modiManName, @modiTime, '修改气体申请', '系统根据用户' + @modiManName + 
					'的要求修改了气体“' + @gasName + '”的申请单['+@applyID+']”的登记信息。')
GO

drop PROCEDURE delGasApply
/*
	name:		delGasApply
	function:	16.删除指定的气体申请单
	input: 
				@applyID varchar(10),			--气体申请单编号
				@delManID varchar(10) output,	--删除人，如果当前气体申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的气体申请单不存在，2：要删除的气体申请单正被别人锁定，
							3：该单据已经批复，不能删除，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-14
	UpdateDate: 

*/
create PROCEDURE delGasApply
	@applyID varchar(10),			--气体申请单编号
	@delManID varchar(10) output,	--删除人，如果当前气体申请单正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要删除的气体申请单是否存在
	declare @count as int
	set @count=(select count(*) from gasApplyInfo where applyID= @applyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @applyStatus smallint	--锁定人/申请批复状态：0->未处理，1->已批准，-1：不批准
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus 
	from gasApplyInfo 
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

	delete gasApplyInfo where applyID= @applyID
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除气体申请', '用户' + @delManName
												+ '删除了气体申请单['+@applyID+']。')

GO


drop PROCEDURE approveGasApply
/*
	name:		approveGasApply
	function:	17.批复指定的气体申请单
	input: 
				@applyID varchar(10),				--气体申请单编号
				@isAgree smallint,					--是否同意：1->同意,-1：不同意
				@approveOpinion nvarchar(300),		--批复意见
				@approveManID varchar(10) output,	--批复人，如果当前气体申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output				--操作成功标识
							0:成功，1：指定的气体申请单不存在，2：要批复的气体申请单正被别人锁定，
							3：该气体申请单已经批复，
							4：该单据申请的用量超出库存量，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-14
	UpdateDate: modi by lw 2013-3-24修改内部逻辑

*/
create PROCEDURE approveGasApply
	@applyID varchar(10),				--气体申请单编号
	@isAgree smallint,					--是否同意：1->同意,-1：不同意
	@approveOpinion nvarchar(300),		--批复意见
	@approveManID varchar(10) output,	--批复人，如果当前气体申请单正在被人占用编辑则返回该人的工号
	@Ret		int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的气体申请单是否存在
	declare @count as int
	set @count=(select count(*) from gasApplyInfo where applyID= @applyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @applyStatus smallint	--锁定人/申请批复状态：0->未处理，1->已批准，-1：不批准
	declare @gasID varchar(10), @gasName nvarchar(30)		--申请气体名称
	declare @usedTime smalldatetime, @applyQuantity	int		--申请使用日期、用量
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus, 
		@gasID = gasID, @gasName = gasName,
		@usedTime = usedTime, @applyQuantity = applyQuantity
	from gasApplyInfo 
	where applyID= @applyID
	if (@thisLockMan <> '' and @thisLockMan <> @approveManID)
	begin
		set @approveManID = @thisLockMan
		set @Ret = 2
		return
	end
	----检查单据状态：允许管理员修改审批
	--if (@applyStatus<>0)
	--begin
	--	set @Ret = 3
	--	return
	--end

	if (@isAgree=1)
	begin
		--检查剩余量是否够：
		declare @leftQuantity int
		set @leftQuantity = isnull((select SUM(stockQuantity) - SUM(usedQuantity) 
									from gasStock 
									where convert(varchar(10),theDate,120)<= CONVERT(varchar(10),@usedTime,120)
										and gasID = @gasID),0)
		if (@applyQuantity > @leftQuantity)
		begin
			set @Ret = 4
			return
		end
	end
								
	--取批复人的姓名：
	declare @approveMan nvarchar(30)
	set @approveMan = isnull((select userCName from activeUsers where userID = @approveManID),'')

	declare @approveTime smalldatetime
	set @approveTime = GETDATE()
	begin tran
		update gasApplyInfo
		set applyStatus = @isAgree,approveTime = @approveTime,
			approveManID = @approveManID, approveMan = @approveMan, approveOpinion = @approveOpinion
		where applyID= @applyID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		set @Ret = 0
		
		--删除可能存在的以前同意的审批量：
		delete gasStock where gasID = @gasID and applyID= @applyID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		if (@isAgree=1)
		begin
			insert gasStock(gasID, gasName, applyID, theDate,usedQuantity)
			values(@gasID, @gasName, @applyID, @usedTime,@applyQuantity)
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
		end
	commit tran
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@approveManID, @approveMan, @approveTime, '批复气体申请', '用户' + @approveMan
												+ '批复了气体申请单['+@applyID+']。')
GO



--气体基本信息查询语句：
select gasID, gasName, convert(varchar(10),g.buildDate,120) buildDate, keeperID, keeper
from gasInfo g


--气体指定日期的库存量查询语句：
select g.gasID, g.gasName, g.buildDate, g.keeperID, g.keeper, 
	isnull(SUM(s.stockQuantity),0) stockQuantity, isnull(SUM(s.usedQuantity),0) usedQuantity, 
	isnull(SUM(s.stockQuantity),0) - isnull(SUM(s.usedQuantity),0) leftQuantity
from gasInfo g left join gasStock s on g.gasID = s.gasID and CONVERT(varchar(10),s.theDate,120) = '2013-01-16'
group by g.gasID, g.gasName, g.buildDate, g.keeperID, g.keeper

SELECT * FROM gasStock

--查询申请单：
select g.applyID, g.gasID, g.gasName, g.applyManID, g.applerMan, 
	convert(varchar(10),g.applyTime,120) applyTime, 
	convert(varchar(10),g.usedTime,120) usedTime, 
	g.applyQuantity, g.applyReason, g.applyStatus
from gasApplyInfo g
order by applyTime

select * from user

delete activeUsers