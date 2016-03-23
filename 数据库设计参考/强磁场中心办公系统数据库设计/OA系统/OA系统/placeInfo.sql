use hustOA
/*
	强磁场中心办公系统-场地管理
	author:		卢苇
	CreateDate:	2013-1-7
	UpdateDate: 
*/
--1.场地一览表：
select * from placeInfo
drop table placeInfo
CREATE TABLE placeInfo(
	placeID varchar(10) not null,		--主键：场地编号,本系统使用第50号号码发生器产生（'CD'+4位年份代码+4位流水号）
	placeName nvarchar(30) null,		--场地名称
	placeMapFile varchar(128) null,		--场地缩略图文件路径
	buildDate smalldatetime null,		--场地建立日期
	scrappedDate smalldatetime null,	--场地废止日期
	keeperID varchar(10) null,			--保管人工号
	keeper nvarchar(30) null,			--保管人:冗余设计
	
	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_placeInfo] PRIMARY KEY CLUSTERED 
(
	[placeID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--2.场地使用申请表
drop table placeApplyInfo
CREATE TABLE placeApplyInfo(
	applyID varchar(10) not null,		--主键：场地使用申请单号,本系统使用第51号号码发生器产生（'CA'+4位年份代码+4位流水号）
	placeID varchar(10) not null,		--场地编号：不使用外键，保存历史数据
	placeName nvarchar(30) null,		--场地名称：冗余字段
	applyManID varchar(10) not null,	--申请人工号
	applerMan nvarchar(30) not null,	--申请人姓名
	applyTime smalldatetime null,		--申请日期
	usedTime smalldatetime null,		--申请使用日期
	timeBlock xml null,					--申请使用时段：采用--<root>
															--	<timeBlock>8</timeBlock>
															--	<timeBlock>9</timeBlock>
															--</root>
										--格式存放。timeBlock中的数字表示时段，取值范围：0~23
	applyReason nvarchar(300) null,		--申请事由
	applyStatus smallint default(0),	--申请批复状态：0->未处理，1->已批准，-1：不批准
	linkInvoiceType smallint default(0),--关联单据：0->未知，1->学术报告，2->会议，9->其他 
	linkInvoice varchar(12) null,		--关联单据号
	
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
 CONSTRAINT [PK_placeApplyInfo] PRIMARY KEY CLUSTERED 
(
	[applyID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--场地ID索引：
CREATE NONCLUSTERED INDEX [IX_placeApplyInfo] ON [dbo].[placeApplyInfo] 
(
	[placeID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--场地申请使用日期状态索引：
CREATE NONCLUSTERED INDEX [IX_placeApplyInfo_1] ON [dbo].[placeApplyInfo] 
(
	[placeID] ASC,
	[usedTime] ASC,
	[applyStatus] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]



drop PROCEDURE queryPlaceInfoLocMan
/*
	name:		queryPlaceInfoLocMan
	function:	1.查询指定场地是否有人正在编辑
	input: 
				@placeID varchar(10),		--场地编号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的场地不存在
				@lockManID varchar(10) output	--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2013-1-7
	UpdateDate: 
*/
create PROCEDURE queryPlaceInfoLocMan
	@placeID varchar(10),		--场地编号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from placeInfo where placeID= @placeID),'')
	set @Ret = 0
GO


drop PROCEDURE lockPlaceInfo4Edit
/*
	name:		lockPlaceInfo4Edit
	function:	2.锁定场地编辑，避免编辑冲突
	input: 
				@placeID varchar(10),			--场地编号
				@lockManID varchar(10) output,	--锁定人，如果当前场地正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的场地不存在，2:要锁定的场地正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-7
	UpdateDate: 
*/
create PROCEDURE lockPlaceInfo4Edit
	@placeID varchar(10),		--场地编号
	@lockManID varchar(10) output,	--锁定人，如果当前场地正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的场地是否存在
	declare @count as int
	set @count=(select count(*) from placeInfo where placeID= @placeID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from placeInfo where placeID= @placeID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update placeInfo
	set lockManID = @lockManID 
	where placeID= @placeID
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
	values(@lockManID, @lockManName, getdate(), '锁定场地编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了场地['+ @placeID +']为独占式编辑。')
GO

drop PROCEDURE unlockPlaceInfoEditor
/*
	name:		unlockPlaceInfoEditor
	function:	3.释放场地编辑锁
				注意：本过程不检查场地是否存在！
	input: 
				@placeID varchar(10),			--场地编号
				@lockManID varchar(10) output,	--锁定人，如果当前场地正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-7
	UpdateDate: 
*/
create PROCEDURE unlockPlaceInfoEditor
	@placeID varchar(10),			--场地编号
	@lockManID varchar(10) output,	--锁定人，如果当前场地呢正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from placeInfo where placeID= @placeID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update placeInfo set lockManID = '' where placeID= @placeID
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
	values(@lockManID, @lockManName, getdate(), '释放场地编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了场地['+ @placeID +']的编辑锁。')
GO

drop PROCEDURE addPlaceInfo
/*
	name:		addPlaceInfo
	function:	4.添加场地信息
	input: 
				@placeName nvarchar(30),		--场地名称
				@placeMapFile varchar(128),		--场地缩略图文件路径
				@buildDate varchar(10),			--场地建立日期:采用“yyyy-MM-dd”格式传送
				@keeperID varchar(10),			--保管人工号

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output,--添加时间
				@placeID varchar(10) output		--场地编号：本系统使用第50号号码发生器产生（'CD'+4位年份代码+4位流水号）
	author:		卢苇
	CreateDate:	2013-1-7
	UpdateDate: 
*/
create PROCEDURE addPlaceInfo
	@placeName nvarchar(30),		--场地名称
	@placeMapFile varchar(128),		--场地缩略图文件路径
	@buildDate varchar(10),			--场地建立日期:采用“yyyy-MM-dd”格式传送
	@keeperID varchar(10),			--保管人工号

	@createManID varchar(10),		--创建人工号
	@Ret		int output,
	@createTime smalldatetime output,
	@placeID varchar(10) output		--场地编号：本系统使用第50号号码发生器产生（'CD'+4位年份代码+4位流水号）
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生场地编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 50, 1, @curNumber output
	set @placeID = @curNumber

	--取保管人/创建人的姓名：
	declare @keeper nvarchar(30), @createManName nvarchar(30)
	set @keeper = isnull((select cName from userInfo where jobNumber = @keeperID),'')
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert placeInfo(placeID, placeName, placeMapFile, buildDate, keeperID, keeper,
					--最新维护情况:
					modiManID, modiManName, modiTime)
	values(@placeID, @placeName, @placeMapFile, @buildDate, @keeperID, @keeper,
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
	values(@createManID, @createManName, @createTime, '登记场地', '系统根据用户' + @createManName + 
					'的要求登记了场地“' + @placeName + '['+@placeID+']”。')
GO
--测试：
declare	@Ret		int
declare	@createTime smalldatetime
declare	@placeID varchar(10)
exec dbo.addPlaceInfo '会议室3', '', '2013-1-13','G201300001','00002', @Ret output, @createTime output, @placeID output
select @Ret, @placeID

select * from placeInfo

drop PROCEDURE updatePlaceInfo
/*
	name:		updatePlaceInfo
	function:	5.修改场地信息
	input: 
				@placeID varchar(10),			--场地编号
				@placeName nvarchar(30),		--场地名称
				@placeMapFile varchar(128),		--场地缩略图文件路径
				@buildDate varchar(10),			--场地建立日期:采用“yyyy-MM-dd”格式传送
				@keeperID varchar(10),			--保管人工号

				@modiManID varchar(10) output,	--修改人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:要修改的场地不存在，
							2:要修改的场地正被别人锁定编辑，
							9:未知错误
				@modiTime smalldatetime output	--修改时间
	author:		卢苇
	CreateDate:	2013-1-7
	UpdateDate: 
*/
create PROCEDURE updatePlaceInfo
	@placeID varchar(10),			--场地编号
	@placeName nvarchar(30),		--场地名称
	@placeMapFile varchar(128),		--场地缩略图文件路径
	@buildDate varchar(10),			--场地建立日期:采用“yyyy-MM-dd”格式传送
	@keeperID varchar(10),			--保管人工号

	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的场地是否存在
	declare @count as int
	set @count=(select count(*) from placeInfo where placeID= @placeID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from placeInfo where placeID= @placeID
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
	update placeInfo
	set placeName = @placeName, placeMapFile = @placeMapFile,
		buildDate=@buildDate, keeperID = @keeperID, keeper = @keeper,
		--最新维护情况:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where placeID= @placeID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '修改场地', '系统根据用户' + @modiManName + 
					'的要求修改了场地“' + @placeName + '['+@placeID+']”的登记信息。')
GO

drop PROCEDURE delPlaceInfo
/*
	name:		delPlaceInfo
	function:	6.删除指定的场地
	input: 
				@placeID varchar(10),			--场地编号
				@delManID varchar(10) output,	--删除人，如果当前场地正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的场地不存在，2：要删除的场地正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-7
	UpdateDate: 

*/
create PROCEDURE delPlaceInfo
	@placeID varchar(10),			--场地编号
	@delManID varchar(10) output,	--删除人，如果当前场地正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的场地是否存在
	declare @count as int
	set @count=(select count(*) from placeInfo where placeID= @placeID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from placeInfo where placeID= @placeID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete placeInfo where placeID= @placeID
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除场地', '用户' + @delManName
												+ '删除了场地['+@placeID+']。')

GO

drop PROCEDURE stopPlaceInfo
/*
	name:		stopPlaceInfo
	function:	7.停用指定的场地
	input: 
				@placeID varchar(10),			--场地编号
				@stopManID varchar(10) output,	--停用人，如果当前场地正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的场地不存在，2：要停用的场地正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-13
	UpdateDate: 

*/
create PROCEDURE stopPlaceInfo
	@placeID varchar(10),			--场地编号
	@stopManID varchar(10) output,	--停用人，如果当前场地正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要停用的场地是否存在
	declare @count as int
	set @count=(select count(*) from placeInfo where placeID= @placeID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from placeInfo where placeID= @placeID
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end

	update placeInfo 
	set scrappedDate = GETDATE()
	where placeID= @placeID
	set @Ret = 0

	--取维护人的姓名：
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, getdate(), '停用场地', '用户' + @stopManName
												+ '停用了场地['+@placeID+']。')

GO

----------------------------------------------场地申请表管理------------------------------------------------------
drop PROCEDURE queryPlaceApplyLocMan
/*
	name:		queryPlaceApplyLocMan
	function:	11.查询指定场地申请单是否有人正在编辑
	input: 
				@applyID varchar(10),		--场地申请单编号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的场地申请单不存在
				@lockManID varchar(10) output	--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2013-1-8
	UpdateDate: 
*/
create PROCEDURE queryPlaceApplyLocMan
	@applyID varchar(10),		--场地申请单编号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from placeApplyInfo where applyID= @applyID),'')
	set @Ret = 0
GO


drop PROCEDURE lockPlaceApply4Edit
/*
	name:		lockPlaceApply4Edit
	function:	12.锁定场地申请单编辑，避免编辑冲突
	input: 
				@applyID varchar(10),		--场地申请单编号
				@lockManID varchar(10) output,	--锁定人，如果当前场地申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的场地申请单不存在，2:要锁定的场地申请单正在被别人编辑，
							3:该单据已经批复，不能编辑锁定，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-8
	UpdateDate: 
*/
create PROCEDURE lockPlaceApply4Edit
	@applyID varchar(10),		--场地申请单编号
	@lockManID varchar(10) output,	--锁定人，如果当前场地申请单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的场地申请单是否存在
	declare @count as int
	set @count=(select count(*) from placeApply where applyID= @applyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @applyStatus smallint	--锁定人/申请批复状态：0->未处理，1->已批准，-1：不批准
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus 
	from placeApplyInfo 
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

	update placeApplyInfo
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
	values(@lockManID, @lockManName, getdate(), '锁定场地申请编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了场地申请['+ @applyID +']为独占式编辑。')
GO

drop PROCEDURE unlockPlaceApplyEditor
/*
	name:		unlockPlaceApplyEditor
	function:	13.释放场地申请单编辑锁
				注意：本过程不检查场地申请单是否存在！
	input: 
				@applyID varchar(10),			--场地申请单编号
				@lockManID varchar(10) output,	--锁定人，如果当前场地申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-8
	UpdateDate: 
*/
create PROCEDURE unlockPlaceApplyEditor
	@applyID varchar(10),			--场地申请单编号
	@lockManID varchar(10) output,	--锁定人，如果当前场地申请单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from placeApplyInfo where applyID= @applyID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update placeApplyInfo set lockManID = '' where applyID= @applyID
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
	values(@lockManID, @lockManName, getdate(), '释放场地申请编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了场地申请单['+ @applyID +']的编辑锁。')
GO

drop PROCEDURE addPlaceApply
/*
	name:		addPlaceApply
	function:	14.添加场地申请单
	input: 
				@placeID varchar(10),		--场地编号：不使用外键，保存历史数据
				@applyManID varchar(10),	--申请人工号
				@applyTime varchar(10),		--申请日期：采用"yyyy-MM-dd"格式传送
				@usedTime varchar(10),		--申请使用日期：采用"yyyy-MM-dd"格式传送
				@timeBlock xml,				--申请使用时段：采用--<root>
																	--	<timeBlock>8</timeBlock>
																	--	<timeBlock>9</timeBlock>
																	--</root>
												--格式存放。timeBlock中的数字表示时段，取值范围：0~23
				@applyReason nvarchar(300),	--申请事由
				@linkInvoiceType smallint,	--关联单据类型：0->未知，1->学术报告，2->会议，9->其他 
				@linkInvoice varchar(12),	--关联单据号

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output,--添加时间
				@applyID varchar(10) output	--场地申请单编号：本系统使用第51号号码发生器产生（'CA'+4位年份代码+4位流水号）
	author:		卢苇
	CreateDate:	2013-1-8
	UpdateDate: 
*/
create PROCEDURE addPlaceApply
	@placeID varchar(10),		--场地编号：不使用外键，保存历史数据
	@applyManID varchar(10),	--申请人工号
	@applyTime varchar(10),		--申请日期：采用"yyyy-MM-dd"格式传送
	@usedTime varchar(10),		--申请使用日期：采用"yyyy-MM-dd"格式传送
	@timeBlock xml,				--申请使用时段：采用--<root>
														--	<timeBlock>8</timeBlock>
														--	<timeBlock>9</timeBlock>
														--</root>
									--格式存放。timeBlock中的数字表示时段，取值范围：0~23
	@applyReason nvarchar(300),	--申请事由
	@linkInvoiceType smallint,	--关联单据类型：0->未知，1->学术报告，2->会议，9->其他 
	@linkInvoice varchar(12),	--关联单据号
	
	@createManID varchar(10),	--创建人工号
	@Ret		int output,
	@createTime smalldatetime output,
	@applyID varchar(10) output	--场地申请单编号：本系统使用第51号号码发生器产生（'CA'+4位年份代码+4位流水号）
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生场地编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 51, 1, @curNumber output
	set @applyID = @curNumber
	
	--取场地名称：
	declare @placeName nvarchar(30)		--场地名称
	set @placeName = isnull((select placeName from placeInfo where placeID = @placeID),'')
	--取创建人的姓名：
	declare @createManName nvarchar(30), @applerMan nvarchar(30)	--申请人姓名
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @applerMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')
	
	set @createTime = getdate()
	insert placeApplyInfo(applyID, placeID, placeName, applyManID, applerMan, 
						applyTime, usedTime, timeBlock,
						applyReason, linkInvoiceType, linkInvoice,
						--最新维护情况:
						modiManID, modiManName, modiTime)
	values(@applyID, @placeID, @placeName, @applyManID, @applerMan, 
			@applyTime, @usedTime, @timeBlock,
			@applyReason, @linkInvoiceType, @linkInvoice,
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
	values(@createManID, @createManName, @createTime, '登记场地申请', '系统根据用户' + @createManName + 
					'的要求登记了场地“' + @placeName + '”的申请单['+@applyID+']”。')
GO
--测试：
declare	@Ret		int
declare	@createTime smalldatetime
declare	@applyID varchar(10)
exec dbo.addPlaceApply 'CD20130002', '00002', '2013-01-08', '2013-01-9',
	N'<root>
		<timeBlock>9</timeBlock>
		<timeBlock>10</timeBlock>
		<timeBlock>11</timeBlock>
	</root>',
	'召开须知报告会','','','00002',
	 @Ret output, @createTime output, @applyID output
select @Ret, @applyID
select * from placeApplyInfo

drop PROCEDURE updatePlaceApply
/*
	name:		updatePlaceApply
	function:	15.修改场地申请单信息
	input: 
				@applyID varchar(10),		--场地申请单编号
				@placeID varchar(10),		--场地编号：不使用外键，保存历史数据
				@applyManID varchar(10),	--申请人工号
				@applyTime varchar(10),		--申请日期：采用"yyyy-MM-dd"格式传送
				@usedTime varchar(10),		--申请使用日期：采用"yyyy-MM-dd"格式传送
				@timeBlock xml,				--申请使用时段：采用--<root>
																	--	<timeBlock>8</timeBlock>
																	--	<timeBlock>9</timeBlock>
																	--</root>
												--格式存放。timeBlock中的数字表示时段，取值范围：0~23
				@applyReason nvarchar(300),	--申请事由
				@linkInvoiceType smallint,	--关联单据类型：0->未知，1->学术报告，2->会议，9->其他 
				@linkInvoice varchar(12),	--关联单据号

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
	CreateDate:	2013-1-8
	UpdateDate: 
*/
create PROCEDURE updatePlaceApply
	@applyID varchar(10),		--场地申请单编号
	@placeID varchar(10),		--场地编号：不使用外键，保存历史数据
	@applyManID varchar(10),	--申请人工号
	@applyTime varchar(10),		--申请日期：采用"yyyy-MM-dd"格式传送
	@usedTime varchar(10),		--申请使用日期：采用"yyyy-MM-dd"格式传送
	@timeBlock xml,				--申请使用时段：采用--<root>
														--	<timeBlock>8</timeBlock>
														--	<timeBlock>9</timeBlock>
														--</root>
									--格式存放。timeBlock中的数字表示时段，取值范围：0~23
	@applyReason nvarchar(300),	--申请事由
	@linkInvoiceType smallint,	--关联单据类型：0->未知，1->学术报告，2->会议，9->其他 
	@linkInvoice varchar(12),	--关联单据号

	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--注意：这里没有做场地是否存在的判断！

	--判断要锁定的场地申请单是否存在
	declare @count as int
	set @count=(select count(*) from placeApplyInfo where applyID= @applyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @applyStatus smallint	--锁定人/申请批复状态：0->未处理，1->已批准，-1：不批准
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus 
	from placeApplyInfo 
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

	--取场地名称：
	declare @placeName nvarchar(30)		--场地名称
	set @placeName = isnull((select placeName from placeInfo where placeID = @placeID),'')
	--取维护人/申请人的姓名：
	declare @modiManName nvarchar(30), @applerMan nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	set @applerMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')

	set @modiTime = getdate()
	update placeApplyInfo
	set placeID = @placeID, placeName = @placeName,
		applyManID = @applyManID, applerMan = @applerMan, 
		applyTime = @applyTime, usedTime = @usedTime, timeBlock = @timeBlock,
		applyReason = @applyReason, linkInvoiceType = @linkInvoiceType, linkInvoice = @linkInvoice,
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
	values(@modiManID, @modiManName, @modiTime, '修改场地申请', '系统根据用户' + @modiManName + 
					'的要求修改了场地“' + @placeName + '”的申请单['+@applyID+']”的登记信息。')
GO

drop PROCEDURE delPlaceApply
/*
	name:		delPlaceApply
	function:	16.删除指定的场地申请单
	input: 
				@applyID varchar(10),			--场地申请单编号
				@delManID varchar(10) output,	--删除人，如果当前场地申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的场地申请单不存在，2：要删除的场地申请单正被别人锁定，
							3：该单据已经批复，不能删除，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-8
	UpdateDate: 

*/
create PROCEDURE delPlaceApply
	@applyID varchar(10),			--场地申请单编号
	@delManID varchar(10) output,	--删除人，如果当前场地申请单正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的场地申请单是否存在
	declare @count as int
	set @count=(select count(*) from placeApplyInfo where applyID= @applyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @applyStatus smallint	--锁定人/申请批复状态：0->未处理，1->已批准，-1：不批准
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus 
	from placeApplyInfo 
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

	delete placeApplyInfo where applyID= @applyID
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除场地申请', '用户' + @delManName
												+ '删除了场地申请单['+@applyID+']。')

GO

drop PROCEDURE approvePlaceApply
/*
	name:		approvePlaceApply
	function:	17.批复指定的场地申请单
	input: 
				@applyID varchar(10),				--场地申请单编号
				@isAgree smallint,					--是否同意：1->同意,-1：不同意
				@approveOpinion nvarchar(300),		--批复意见
				@approveManID varchar(10) output,	--批复人，如果当前场地申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output				--操作成功标识
							0:成功，1：指定的场地申请单不存在，2：要批复的场地申请单正被别人锁定，
							3：该场地申请单已经批复，4:在执行关联单据的操作时出错，
							5：该单据申请的时间段已经被占用，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-8
	UpdateDate: 

*/
create PROCEDURE approvePlaceApply
	@applyID varchar(10),				--场地申请单编号
	@isAgree smallint,					--是否同意：1->同意,-1：不同意
	@approveOpinion nvarchar(300),		--批复意见
	@approveManID varchar(10) output,	--批复人，如果当前场地申请单正在被人占用编辑则返回该人的工号
	@Ret		int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的场地申请单是否存在
	declare @count as int
	set @count=(select count(*) from placeApplyInfo where applyID= @applyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @applyStatus smallint	--锁定人/申请批复状态：0->未处理，1->已批准，-1：不批准
	declare @usedTime smalldatetime, @placeID varchar(10)	--使用时间、场地ID
	declare @linkInvoiceType smallint, @linkInvoice varchar(12)--关联单据类型：0->未知，1->学术报告，2->会议，9->其他 /关联单据号
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus, @placeID = placeID, @usedTime = usedTime,
		@linkInvoiceType = linkInvoiceType, @linkInvoice = linkInvoice
	from placeApplyInfo 
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
	declare @usedBlock table(placeID varchar(10), block varchar(4))	--已批准暂用的时间表
	insert @usedBlock(placeID, block)
	select p.placeID, cast(T2.timeBlock.query('./text()') as varchar(4)) timeB
	from placeApplyInfo p 
	CROSS APPLY timeBlock.nodes('/root/timeBlock') as T2(timeBlock)
	where convert(varchar(10),p.usedTime,120)=convert(varchar(10),@usedTime,120) and placeID=@placeID and p.applyStatus = 1
	order by timeB;
	
	WITH CTE	--本次申请的时间块
	AS ( 
		select p.placeID, cast(T2.timeBlock.query('./text()') as varchar(4)) timeB
		from placeApplyInfo p 
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
	update placeApplyInfo
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
	values(@approveManID, @approveMan, @approveTime, '批复场地申请', '用户' + @approveMan
												+ '批复了场地申请单['+@applyID+']。')
	
	--设置关联单据：
	declare @execRet int
	if (@linkInvoiceType=1)	--1->学术报告
	begin
		exec dbo.placeIsReady4AReport @linkInvoice, @execRet output
		if (@execRet <> 0)
			set @Ret = 4
	end
	else if (@linkInvoiceType=2)--2->会议
	begin
		exec dbo.placeIsReady4Meeting @linkInvoice, @execRet output
		if (@execRet <> 0)
			set @Ret = 4
	end

GO
select * from placeApplyInfo
declare @usedTime smalldatetime
set @usedTime = '2013-01-29'
declare @usedBlock table(placeID varchar(10), block varchar(4))	--已批准暂用的时间表
insert @usedBlock(placeID, block)
select p.placeID, cast(T2.timeBlock.query('./text()') as varchar(4)) timeB
from placeApplyInfo p 
CROSS APPLY timeBlock.nodes('/root/timeBlock') as T2(timeBlock)
where convert(varchar(10),p.usedTime,120)=convert(varchar(10),@usedTime,120) and p.applyStatus = 1
order by timeB;
select * from @usedBlock

select * from placeApplyInfo
where applyID='CA20130141'

use hustOA
--场地的查询语句：
select * from placeInfo
select * from placeApplyInfo

use hustOA
--场地使用申请表查询语句：用xml表示时间块
select applyID, placeID, placeName, applyManID, applerMan, applyTime, 
	usedTime, timeBlock,					--申请使用时段：采用--<root>
											--	<timeBlock>8</timeBlock>
											--	<timeBlock>9</timeBlock>
											--</root>
										--格式存放。timeBlock中的数字表示时段，取值范围：0~23
	applyReason, applyStatus, linkInvoiceType, linkInvoice, approveTime, approveManID, approveMan, approveOpinion
from placeApplyInfo

insert placeApplyInfo(applyID, placeID, placeName, applyManID, applerMan, applyTime, 
	usedTime, timeBlock,					--申请使用时段：采用--<root>
											--	<timeBlock>8</timeBlock>
											--	<timeBlock>9</timeBlock>
											--</root>
										--格式存放。timeBlock中的数字表示时段，取值范围：0~23
	applyReason)
values('CA20130002','cd20130002','会议室','00002','杨斌','2013-01-07','2013-01-08',
	N'<root>' +
		'<timeBlock>14</timeBlock>'+
		'<timeBlock>15</timeBlock>'+
		'<timeBlock>16</timeBlock>'+
	'</root>',
	'学术报告')

--场地使用申请表查询语句：时间块转换为行集
select a.placeID, a.placeName, p.applyID, p.placeID, p.placeName, p.applyManID, p.applerMan, p.applyTime, p.usedTime, 
	p.applyReason, p.applyStatus, p.linkInvoiceType, p.linkInvoice, p.approveTime, p.approveManID, p.approveMan, p.approveOpinion,
	cast(cast(T2.timeBlock.query('./text()') as varchar(4)) as int) timeB
from placeInfo a left join (placeApplyInfo p 
CROSS APPLY timeBlock.nodes('/root/timeBlock') as T2(timeBlock)) on a.placeID = p.placeID 
order by a.placeID, timeB

--场地时间状态查询语句：
select p.placeID, p.placeName, p.applyID, p.applyManID, p.applerMan, p.applyTime, p.usedTime, 
	p.applyReason, p.applyStatus, 
	cast(cast(T2.timeBlock.query('./text()') as varchar(4)) as int) timeB
from placeApplyInfo p CROSS APPLY timeBlock.nodes('/root/timeBlock') as T2(timeBlock)
where p.applyStatus <> -1
order by p.placeID, timeB, p.applyStatus



select applyID, placeID, placeName, applyManID, applerMan, applyTime, 
	usedTime, timeBlock,					--申请使用时段：采用--<root>
											--	<timeBlock>8</timeBlock>
											--	<timeBlock>9</timeBlock>
											--</root>
										--格式存放。timeBlock中的数字表示时段，取值范围：0~23
	applyReason, applyStatus, linkInvoiceType, linkInvoice, approveTime, approveManID, approveMan, approveOpinion
from placeApplyInfo
order by applyID desc




select p.applyID, p.placeID, p.placeName, p.applyManID, p.applerMan, p.applyTime, p.usedTime,
p.applyReason, p.applyStatus,
cast(cast(T2.timeBlock.query('./text()') as varchar(4)) as int) timeB
from placeApplyInfo p 
CROSS APPLY timeBlock.nodes('/root/timeBlock') as T2(timeBlock)
where p.applyStatus <> -1
order by p.applyID, timeB, p.applyStatus


update placeApplyInfo
set applyStatus = 1
where applyID = 'CA20130002'

use hustoa
select messageID, messageType, messageLevel, senderID, sender, sendTime, isSend, receiverID, receiver, messageBody from messageInfo where isSend=0



select applyID, placeID, placeName, applyManID, applerMan, 
applyTime,usedTime, timeBlock,applyReason, applyStatus, linkInvoiceType, linkInvoice, 
approveTime, approveManID, approveMan, approveOpinion 
from placeApplyInfo 
where applyID = 'CD20130023' 
order by applyID desc


use hustOA
select * from placeApplyInfo
delete placeApplyInfo where applyID ='CA20130031'

