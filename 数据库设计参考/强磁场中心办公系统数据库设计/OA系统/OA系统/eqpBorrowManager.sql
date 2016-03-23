use hustOA
/*
	强磁场中心办公系统-共享设备管理
	author:		卢苇
	CreateDate:	2013-1-22
	UpdateDate: 
*/
--1.共享设备状态表：这是一个与设备库中共享设备一一对应的一个设备状态表
--为了保留历史数据，这个表没有设计成与设备表级联，但是设备共享的时候要相应设置本表！
update shareEqpStatus
set borrowerID='',
	borrower='',
	lentTime=null,
	expectedReturnTime=null,
	borrowReason=''
select * from shareEqpStatus
DROP TABLE shareEqpStatus
CREATE TABLE shareEqpStatus(
	eCode char(8) not null,				--主键：设备编号

	borrowerID varchar(10) null,		--现借用人工号
	borrower nvarchar(30) null,			--现借用人
	lentTime smalldatetime null,		--借出时间
	expectedReturnTime smalldatetime null,--预计归还时间
	borrowReason nvarchar(300) null,	--借用事由
	
	isShare int default(1),				--是否允许借用：0->不允许，1->允许。这个字段是由设备的是否共享来设定的！
	setOffDate smalldatetime,			--取消可以借用（共享）属性的日期

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_shareEqpStatus] PRIMARY KEY CLUSTERED 
(
	[eCode] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--借用人索引：
CREATE NONCLUSTERED INDEX [IX_shareEqpStatus] ON [dbo].[shareEqpStatus] 
(
	[borrower] DESC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--借出时间索引：
CREATE NONCLUSTERED INDEX [IX_shareEqpStatus_1] ON [dbo].[shareEqpStatus] 
(
	[lentTime] DESC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--预计归还时间索引：
CREATE NONCLUSTERED INDEX [IX_shareEqpStatus_2] ON [dbo].[shareEqpStatus] 
(
	[expectedReturnTime] DESC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--是否允许借用索引：
CREATE NONCLUSTERED INDEX [IX_shareEqpStatus_3] ON [dbo].[shareEqpStatus] 
(
	[isShare] DESC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--2.设备借用情况登记表：

select * from eqpBorrowInfo
drop table eqpBorrowInfo
CREATE TABLE eqpBorrowInfo(
	rowNum int IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL, --主键：内部行号
	eCode char(8) not null,				--主键：设备编号

	applyID varchar(10) null,			--申请单号：可以为空，即设备的借用申请表编号
	borrowerID varchar(10) not null,	--借用人工号
	borrower nvarchar(30) not null,		--借用人
	lentTime smalldatetime not null,	--借出时间
	expectedReturnTime smalldatetime null,--预计归还时间
	borrowReason nvarchar(300) null,	--借用事由
	returnTime smalldatetime null,		--实际归还时间
 CONSTRAINT [PK_eqpBorrowInfo] PRIMARY KEY CLUSTERED 
(
	[eCode] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--外键：
ALTER TABLE [dbo].[eqpBorrowInfo] WITH CHECK ADD CONSTRAINT [FK_eqpBorrowInfo_shareEqpStatus] FOREIGN KEY([eCode])
REFERENCES [dbo].[shareEqpStatus] ([eCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[eqpBorrowInfo] CHECK CONSTRAINT [FK_eqpBorrowInfo_shareEqpStatus]
GO

--索引：
--借出时间索引：
CREATE NONCLUSTERED INDEX [IX_eqpBorrowInfo] ON [dbo].[eqpBorrowInfo] 
(
	[lentTime] DESC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--预计归还时间索引：
CREATE NONCLUSTERED INDEX [IX_eqpBorrowInfo_1] ON [dbo].[eqpBorrowInfo] 
(
	[expectedReturnTime] DESC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--实际归还时间索引：
CREATE NONCLUSTERED INDEX [IX_eqpBorrowInfo_2] ON [dbo].[eqpBorrowInfo] 
(
	[returnTime] DESC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--3.共享设备借用申请表
alter table eqpBorrowApplyInfo add linkInvoiceType smallint default(0)--关联单据：0->未知，1->学术报告，2->会议，9->其他 
alter table eqpBorrowApplyInfo add linkInvoice varchar(12) null		--关联单据号
drop table eqpBorrowApplyInfo
CREATE TABLE eqpBorrowApplyInfo(
	applyID varchar(10) not null,		--主键：设备借用情况使用申请单号,本系统使用第7号号码发生器产生（'JY'+4位年份代码+4位流水号）
	eCode char(8) not null,				--主键：设备编号,本系统使用第6号号码发生器产生（4位年份代码+4位流水号）
	applyStatus smallint default(0),	--申请批复状态：0->未处理，1->已批准，-1：不批准
	eName nvarchar(30) not null,		--设备名称（仪器名称）:冗余设计
	eModel nvarchar(20) not null,		--设备型号:冗余设计
	eFormat nvarchar(30) not null,		--设备规格:冗余设计

	borrowerID varchar(10) not null,	--借用人工号
	borrower nvarchar(30) not null,		--借用人
	lentTime smalldatetime not null,	--借出时间
	expectedReturnTime smalldatetime null,--预计归还时间
	borrowReason nvarchar(300) null,	--借用事由
	--add by lw 2013-1-29
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
 CONSTRAINT [PK_eqpBorrowApplyInfo] PRIMARY KEY CLUSTERED 
(
	[eCode] ASC,
	[applyID] DESC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--索引：
--借用人索引：
CREATE NONCLUSTERED INDEX [IX_eqpBorrowApplyInfo] ON [dbo].[eqpBorrowApplyInfo] 
(
	[borrowerID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

drop PROCEDURE queryShareEqpLocMan
/*
	name:		queryShareEqpLocMan
	function:	1.查询指定共享设备是否有人正在编辑
	input: 
				@eCode char(8),				--主键：设备编号
	output: 
				@Ret		int output	--操作成功标识
							0:成功，9：查询出错，可能是指定的共享设备不存在
				@lockManID varchar(10) output	--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2013-1-22
	UpdateDate: 
*/
create PROCEDURE queryShareEqpLocMan
	@eCode char(8),				--主键：设备编号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from shareEqpStatus where eCode= @eCode),'')
	set @Ret = 0
GO


drop PROCEDURE lockShareEqp4Lent
/*
	name:		lockShareEqp4Lent
	function:	2.锁定共享设备，避免借出冲突
	input: 
				@eCode char(8),				--主键：设备编号
				@lockManID varchar(10) output,	--锁定人，如果当前共享设备正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的共享设备不存在，2:要锁定的共享设备正在被别人编辑，
							3:该设备已经不是共享状态，
							4：该设备已经借出，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-22
	UpdateDate: 
*/
create PROCEDURE lockShareEqp4Lent
	@eCode char(8),					--主键：设备编号
	@lockManID varchar(10) output,	--锁定人，如果当前共享设备正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的共享设备是否存在
	declare @count as int
	set @count=(select count(*) from shareEqpStatus where eCode= @eCode)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from shareEqpStatus where eCode= @eCode
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	--获取共享设备状态/现借用人：
	declare @isShare int, @borrowerID varchar(10)
	select @isShare = isShare, @borrowerID= borrowerID from shareEqpStatus where eCode = @eCode
	--检查状态：
	if (@isShare=0)
	begin
		set @Ret = 3
		return
	end
	if (isnull(@borrowerID,'') <> '')
	begin
		set @Ret = 4
		return
	end

	update shareEqpStatus
	set lockManID = @lockManID 
	where eCode = @eCode
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
	values(@lockManID, @lockManName, getdate(), '锁定共享设备借出编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了设备['+@eCode+']为独占式借出编辑。')
GO

drop PROCEDURE lockShareEqp4Return
/*
	name:		lockShareEqp4Return
	function:	3.锁定共享设备，避免归还冲突
	input: 
				@eCode char(8),				--主键：设备编号
				@lockManID varchar(10) output,	--锁定人，如果当前共享设备正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的共享设备不存在，2:要锁定的共享设备正在被别人编辑，
							4：该设备已经归还，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-22
	UpdateDate: 
*/
create PROCEDURE lockShareEqp4Return
	@eCode char(8),					--主键：设备编号
	@lockManID varchar(10) output,	--锁定人，如果当前共享设备正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的共享设备是否存在
	declare @count as int
	set @count=(select count(*) from shareEqpStatus where eCode= @eCode)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from shareEqpStatus where eCode= @eCode
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	--获取现借用人：
	declare @isShare int, @borrowerID varchar(10)
	select @isShare = isShare, @borrowerID= borrowerID from shareEqpStatus where eCode = @eCode
	if (isnull(@borrowerID,'') = '')
	begin
		set @Ret = 4
		return
	end

	update shareEqpStatus
	set lockManID = @lockManID 
	where eCode = @eCode
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
	values(@lockManID, @lockManName, getdate(), '锁定共享设备归还编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了设备['+@eCode+']为独占式归还编辑。')
GO

drop PROCEDURE unlockShareEqpEditor
/*
	name:		unlockShareEqpEditor
	function:	4.释放共享设备编辑锁
				注意：本过程不检查共享设备是否存在！
	input: 
				@eCode char(8),					--主键：设备编号
				@lockManID varchar(10) output,	--锁定人，如果当前共享设备正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-22
	UpdateDate: 
*/
create PROCEDURE unlockShareEqpEditor
	@eCode char(8),					--主键：设备编号
	@lockManID varchar(10) output,	--锁定人，如果当前共享设备正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from shareEqpStatus where eCode= @eCode),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update shareEqpStatus set lockManID = '' where eCode= @eCode
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
	values(@lockManID, @lockManName, getdate(), '释放共享设备编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了设备['+@eCode+']的编辑锁。')
GO

drop PROCEDURE lentEqp
/*
	name:		lentEqp
	function:	5.借出设备登记
	input: 
				@eCode char(8),					--设备编号
				@applyID varchar(10),			--申请单号：可以为空，即设备的借用申请表编号
				@borrowerID varchar(10),		--借用人工号
				@lentTime varchar(19),			--借出时间
				@expectedReturnTime varchar(19),--预计归还时间
				@borrowReason nvarchar(300),	--借用事由

				@keeperID varchar(10)  output,	--保管人工号：如果当前共享设备正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：要借用的共享设备不存在，2:要借用的共享设备正在被别人编辑，
							3:该设备已经不是共享状态，
							4：该设备已经借出，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-22
	UpdateDate: 
*/
create PROCEDURE lentEqp
	@eCode char(8),					--设备编号
	@applyID varchar(10),			--申请单号：可以为空，即设备的借用申请表编号
	@borrowerID varchar(10),		--借用人工号
	@lentTime varchar(19),			--借出时间
	@expectedReturnTime varchar(19),--预计归还时间
	@borrowReason nvarchar(300),	--借用事由

	@keeperID varchar(10) output,	--保管人工号：如果当前共享设备正在被人占用编辑则返回该人的工号
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的共享设备是否存在
	declare @count as int
	set @count=(select count(*) from shareEqpStatus where eCode= @eCode)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from shareEqpStatus where eCode= @eCode
	if (@thisLockMan <> '' and @thisLockMan <> @keeperID)
	begin
		set @keeperID = @thisLockMan
		set @Ret = 2
		return
	end

	--获取共享设备状态/现借用人：
	declare @isShare int, @curBorrowerID varchar(10)
	select @isShare = isShare, @curBorrowerID= borrowerID from shareEqpStatus where eCode = @eCode
	--检查状态：
	if (@isShare=0)
	begin
		set @Ret = 3
		return
	end
	if (isnull(@curBorrowerID,'') <> '')
	begin
		set @Ret = 4
		return
	end

	--取保管人/借用人的姓名：
	declare @keeper nvarchar(30), @borrower nvarchar(30)
	set @keeper = isnull((select userCName from activeUsers where userID = @keeperID),'')
	set @borrower = isnull((select cName from userInfo where jobNumber = @borrowerID),'')
	
	declare @createTime smalldatetime
	set @createTime = getdate()
	begin tran
		--登记设备借用情况登记表
		insert eqpBorrowInfo(eCode, applyID, borrowerID, borrower, lentTime, expectedReturnTime, borrowReason)
		values(@eCode, @applyID, @borrowerID, @borrower, @lentTime, @expectedReturnTime, @borrowReason)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end   
		--更新共享设备状态表： 
		update shareEqpStatus
		set borrowerID = @borrowerID, borrower = @borrower,
			lentTime = @lentTime, expectedReturnTime = @expectedReturnTime,
			borrowReason = @borrowReason,	--借用事由
			--最新维护情况:
			modiManID = @keeperID, modiManName = @keeper, modiTime = @createTime
		where eCode = @eCode
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
	values(@keeperID, @keeper, @createTime, '借出设备', '系统根据用户' + @keeper + 
					'的要求登记了设备['+@eCode+']借用情况。')
GO
--测试：
declare	@Ret		int
declare	@createTime smalldatetime
declare	@rowNum varchar(10)

select * from eqpBorrowInfo

drop PROCEDURE returnEqp
/*
	name:		returnEqp
	function:	6.归还设备
	input: 
				@eCode char(8),					--设备编号
				@borrowerID varchar(10),		--借用人工号
				@returnTime varchar(19),		--实际归还时间

				@keeperID varchar(10),			--保管人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：要归还的共享设备不存在，2:要归还的共享设备正在被别人编辑，
							3：归还人不是借用人
							4：该设备已经归还，
							5：没有借出单据，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-22
	UpdateDate: 
*/
create PROCEDURE returnEqp
	@eCode char(8),					--设备编号
	@borrowerID varchar(10),		--借用人工号
	@returnTime varchar(19),		--实际归还时间

	@keeperID varchar(10) output,	--保管人工号：如果当前共享设备正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的共享设备是否存在
	declare @count as int
	set @count=(select count(*) from shareEqpStatus where eCode= @eCode)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from shareEqpStatus where eCode= @eCode
	if (@thisLockMan <> '' and @thisLockMan <> @keeperID)
	begin
		set @keeperID = @thisLockMan
		set @Ret = 2
		return
	end

	--获取现借用人：
	declare @curBorrowerID varchar(10)
	select @curBorrowerID= borrowerID from shareEqpStatus where eCode = @eCode
	if (isnull(@curBorrowerID,'') = '')
	begin
		set @Ret = 4
		return
	end
	if (@curBorrowerID<>@borrowerID)
	begin
		set @Ret = 3
		return
	end
	
	--获取借用登记信息单据的行号：
	declare @rowNum int 
	set @rowNum = (select top 1 rowNum from eqpBorrowInfo 
					where eCode = @eCode and borrowerID=@borrowerID and returnTime is null order by lentTime desc)
	if (@rowNum is null)
	begin
		set @Ret = 5
		return
	end

	--取保管人/借用人的姓名：
	declare @keeper nvarchar(30), @borrower nvarchar(30)
	set @keeper = isnull((select userCName from activeUsers where userID = @keeperID),'')
	set @borrower = isnull((select cName from userInfo where jobNumber = @borrowerID),'')

	declare @modiTime smalldatetime
	set @modiTime = getdate()
	begin tran
		--登记设备借用情况登记表
		update eqpBorrowInfo
		set returnTime = @returnTime
		where rowNum=@rowNum
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end   
		--更新共享设备状态表： 
		update shareEqpStatus
		set borrowerID = '', borrower = '',
			lentTime = null, expectedReturnTime = null,
			borrowReason = '',	--借用事由
			--最新维护情况:
			modiManID = @keeperID, modiManName = @keeper, modiTime = @modiTime
		where eCode = @eCode
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
	values(@keeperID, @keeper, @modiTime, '归还设备', '系统根据用户' + @keeper + 
					'的要求登记了设备['+@eCode+']的归还情况。')
GO


----------------------------------------------设备借用情况申请单管理------------------------------------------------------
drop PROCEDURE queryEqpBorrowApplyLocMan
/*
	name:		queryEqpBorrowApplyLocMan
	function:	11.查询指定设备借用申请单是否有人正在编辑
	input: 
				@applyID varchar(10),		--设备借用申请单编号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的设备借用申请单不存在
				@lockManID varchar(10) output	--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2013-1-22
	UpdateDate: 
*/
create PROCEDURE queryEqpBorrowApplyLocMan
	@applyID varchar(10),		--设备借用申请单编号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from eqpBorrowApplyInfo where applyID= @applyID),'')
	set @Ret = 0
GO

drop PROCEDURE lockEqpBorrowApply4Edit
/*
	name:		lockEqpBorrowApply4Edit
	function:	12.锁定设备借用申请单编辑，避免编辑冲突
	input: 
				@applyID varchar(10),			--设备借用申请单编号
				@lockManID varchar(10) output,	--锁定人，如果当前设备借用申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的设备借用申请单不存在，2:要锁定的设备借用申请单正在被别人编辑，
							3:该单据已经批复，不能编辑锁定，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-22
	UpdateDate: 
*/
create PROCEDURE lockEqpBorrowApply4Edit
	@applyID varchar(10),		--设备借用申请单编号
	@lockManID varchar(10) output,	--锁定人，如果当前设备借用申请单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的设备借用申请单是否存在
	declare @count as int
	set @count=(select count(*) from eqpBorrowApplyInfo where applyID= @applyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @applyStatus smallint	--锁定人/申请批复状态：0->未处理，1->已批准，-1：不批准
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus 
	from eqpBorrowApplyInfo 
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

	update eqpBorrowApplyInfo
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
	values(@lockManID, @lockManName, getdate(), '锁定设备借用申请编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了设备借用申请单['+ @applyID +']为独占式编辑。')
GO

drop PROCEDURE unlockEqpBorrowApplyEditor
/*
	name:		unlockEqpBorrowApplyEditor
	function:	13.释放设备借用申请单编辑锁
				注意：本过程不检查设备借用申请单是否存在！
	input: 
				@applyID varchar(10),			--设备借用申请单编号
				@lockManID varchar(10) output,	--锁定人，如果当前设备借用申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-22
	UpdateDate: 
*/
create PROCEDURE unlockEqpBorrowApplyEditor
	@applyID varchar(10),			--设备借用申请单编号
	@lockManID varchar(10) output,	--锁定人，如果当前设备借用申请单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpBorrowApplyInfo where applyID= @applyID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update eqpBorrowApplyInfo set lockManID = '' where applyID= @applyID
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
	values(@lockManID, @lockManName, getdate(), '释放设备借用申请锁', '系统根据用户' + @lockManName
												+ '的要求释放了设备借用申请单['+ @applyID +']的编辑锁。')
GO


drop PROCEDURE addEqpBorrowApply
/*
	name:		addEqpBorrowApply
	function:	14.添加设备借用申请单
	input: 
				@eCode char(8),					--设备编号
				@borrowerID varchar(10),		--借用人工号
				@lentTime varchar(19),			--借出时间:采用“yyyy-MM-dd hh:mm:ss”格式传送
				@expectedReturnTime varchar(19),--预计归还时间:采用“yyyy-MM-dd hh:mm:ss”格式传送
				@borrowReason nvarchar(300),	--借用事由
				@linkInvoiceType smallint,		--关联单据：0->未知，1->学术报告，2->会议，9->其他 
				@linkInvoice varchar(12),		--关联单据号

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output,--添加时间
				@applyID varchar(10) output		--设备借用申请单编号：本系统使用第7号号码发生器产生（'JY'+4位年份代码+4位流水号）
	author:		卢苇
	CreateDate:	2013-1-22
	UpdateDate: modi by lw 2013-1-29增加设备借用申请关联单据
*/
create PROCEDURE addEqpBorrowApply
	@eCode char(8),					--设备编号
	@borrowerID varchar(10),		--借用人工号
	@lentTime varchar(19),			--借出时间:采用“yyyy-MM-dd hh:mm:ss”格式传送
	@expectedReturnTime varchar(19),--预计归还时间:采用“yyyy-MM-dd hh:mm:ss”格式传送
	@borrowReason nvarchar(300),	--借用事由
	@linkInvoiceType smallint,		--关联单据：0->未知，1->学术报告，2->会议，9->其他 
	@linkInvoice varchar(12),		--关联单据号

	@createManID varchar(10),		--创建人工号
	@Ret		int output,
	@createTime smalldatetime output,
	@applyID varchar(10) output		--设备借用申请单编号：本系统使用第7号号码发生器产生（'JY'+4位年份代码+4位流水号）
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生设备借用申请单编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 7, 1, @curNumber output
	set @applyID = @curNumber
	
	--取创建人、借用人姓名：
	declare @createManName nvarchar(30), @borrower nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @borrower = isnull((select cName from userInfo where jobNumber = @borrowerID),'')
	
	set @createTime = getdate()
	insert eqpBorrowApplyInfo(applyID, eCode, eName, eModel, eFormat,
						borrowerID, borrower, lentTime, expectedReturnTime, borrowReason,
						linkInvoiceType, linkInvoice,		--关联单据
						--最新维护情况:
						modiManID, modiManName, modiTime)
	select @applyID, @eCode, eName, eModel, eFormat,
			@borrowerID, @borrower, @lentTime, @expectedReturnTime, @borrowReason,
			@linkInvoiceType,@linkInvoice,		--关联单据
						--最新维护情况:
			@createManID, @createManName, @createTime
	from equipmentList
	where eCode = @eCode
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '登记设备借用申请', '系统根据用户' + @createManName + 
					'的要求登记了设备借用申请单['+@applyID+']。')
GO
--测试：
declare	@Ret		int
declare	@createTime smalldatetime
declare	@applyID varchar(10)
select @Ret, @applyID
select * from gasApplyInfo

drop PROCEDURE updateEqpBorrowApply
/*
	name:		updateEqpBorrowApply
	function:	15.修改设备借用申请单信息
	input: 
				@applyID varchar(10),			--设备借用申请单编号
				@eCode char(8),					--设备编号
				@borrowerID varchar(10),		--借用人工号
				@lentTime varchar(19),			--借出时间:采用“yyyy-MM-dd hh:mm:ss”格式传送
				@expectedReturnTime varchar(19),--预计归还时间:采用“yyyy-MM-dd hh:mm:ss”格式传送
				@borrowReason nvarchar(300),	--借用事由
				@linkInvoiceType smallint,		--关联单据：0->未知，1->学术报告，2->会议，9->其他 
				@linkInvoice varchar(12),		--关联单据号

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
	CreateDate:	2013-1-22
	UpdateDate: 
*/
create PROCEDURE updateEqpBorrowApply
	@applyID varchar(10),		--设备借用申请单编号
	@eCode char(8),					--设备编号
	@borrowerID varchar(10),		--借用人工号
	@lentTime varchar(19),			--借出时间:采用“yyyy-MM-dd hh:mm:ss”格式传送
	@expectedReturnTime varchar(19),--预计归还时间:采用“yyyy-MM-dd hh:mm:ss”格式传送
	@borrowReason nvarchar(300),	--借用事由
	@linkInvoiceType smallint,		--关联单据：0->未知，1->学术报告，2->会议，9->其他 
	@linkInvoice varchar(12),		--关联单据号

	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--注意：这里没有做要借用的设备是否存在的判断！

	--判断要锁定的设备借用申请单是否存在
	declare @count as int
	set @count=(select count(*) from eqpBorrowApplyInfo where applyID= @applyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	
	declare @thisLockMan varchar(10), @applyStatus smallint	--锁定人/申请批复状态：0->未处理，1->已批准，-1：不批准
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus 
	from eqpBorrowApplyInfo
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

	--取维护人/借用人的姓名：
	declare @modiManName nvarchar(30), @borrower nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	set @borrower = isnull((select cName from userInfo where jobNumber = @borrowerID),'')

	set @modiTime = getdate()
	update eqpBorrowApplyInfo
	set borrowerID = @borrowerID, borrower = @borrower, lentTime = @lentTime, 
		expectedReturnTime = @expectedReturnTime, borrowReason = @borrowReason,
		linkInvoiceType = @linkInvoiceType, linkInvoice = @linkInvoice,		--关联单据
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
	values(@modiManID, @modiManName, @modiTime, '修改设备借用申请', '系统根据用户' + @modiManName + 
					'的要求修改了设备借用申请单['+@applyID+']的信息。')
GO

drop PROCEDURE delEqpBorrowApply
/*
	name:		delEqpBorrowApply
	function:	16.删除指定的设备借用申请单
	input: 
				@applyID varchar(10),			--设备借用申请单编号
				@delManID varchar(10) output,	--删除人，如果当前设备借用申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的设备借用申请单不存在，2：要删除的设备借用申请单正被别人锁定，
							3：该单据已经批复，不能删除，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-22
	UpdateDate: 

*/
create PROCEDURE delEqpBorrowApply
	@applyID varchar(10),			--设备借用申请单编号
	@delManID varchar(10) output,	--删除人，如果当前设备借用申请单正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要删除的设备借用申请单是否存在
	declare @count as int
	set @count=(select count(*) from eqpBorrowApplyInfo where applyID= @applyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @applyStatus smallint	--锁定人/申请批复状态：0->未处理，1->已批准，-1：不批准
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus 
	from eqpBorrowApplyInfo
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

	delete eqpBorrowApplyInfo where applyID= @applyID
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除设备借用申请', '用户' + @delManName
												+ '删除了设备借用申请单['+@applyID+']。')

GO
--测试：
declare @Ret		int		--操作成功标识
exec dbo.delEqpBorrowApply 'JY20130298','G201300001',@Ret output
select @Ret


drop PROCEDURE approveEqpBorrowApply
/*
	name:		approveEqpBorrowApply
	function:	17.批复指定的设备借用申请单
	input: 
				@applyID varchar(10),				--设备借用申请单编号
				@isAgree smallint,					--是否同意：1->同意,-1：不同意
				@approveOpinion nvarchar(300),		--批复意见
				@approveManID varchar(10) output,	--批复人，如果当前设备借用申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output				--操作成功标识
							0:成功，1：指定的设备借用申请单不存在，2：要批复的设备借用申请单正被别人锁定，
							3：该设备借用申请单已经批复，
							4：该单据申请的时间段已经被占用，
							5:在执行关联单据的操作时出错，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-22
	UpdateDate: modi by lw 2013-3-34增加关联单据处理

*/
create PROCEDURE approveEqpBorrowApply
	@applyID varchar(10),				--设备借用申请单编号
	@isAgree smallint,					--是否同意：1->同意,-1：不同意
	@approveOpinion nvarchar(300),		--批复意见
	@approveManID varchar(10) output,	--批复人，如果当前设备借用申请单正在被人占用编辑则返回该人的工号
	@Ret		int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的设备借用申请单是否存在
	declare @count as int
	set @count=(select count(*) from eqpBorrowApplyInfo where applyID= @applyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @applyStatus smallint	--锁定人/申请批复状态：0->未处理，1->已批准，-1：不批准
	declare @eCode char(8)	--设备编号
	select @eCode = eCode, @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus
	from eqpBorrowApplyInfo 
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
	
	--获取单据信息，检查时间段是否冲突：
	declare @lentTime smalldatetime, @expectedReturnTime smalldatetime
	declare @linkInvoiceType smallint	--关联单据：0->未知，1->学术报告，2->会议，9->其他 
	declare @linkInvoice varchar(12)	--关联单据号
	select @lentTime = lentTime, @expectedReturnTime = expectedReturnTime, 
			@linkInvoiceType = linkInvoiceType, @linkInvoice = linkInvoice
	from eqpBorrowApplyInfo
	where applyID = @applyID
	set @count = isnull((select count(*) from eqpBorrowApplyInfo
					where eCode = @eCode and applyStatus = 1 and (@lentTime between lentTime and expectedReturnTime 
											or @expectedReturnTime between lentTime and expectedReturnTime )),0)
	if (@count > 0)
	begin
		set @Ret = 4
		return
	end

	--取批复人的姓名：
	declare @approveMan nvarchar(30)
	set @approveMan = isnull((select userCName from activeUsers where userID = @approveManID),'')

	declare @approveTime smalldatetime
	set @approveTime = GETDATE()
	update eqpBorrowApplyInfo
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
	values(@approveManID, @approveMan, @approveTime, '批复设备借用申请', '用户' + @approveMan
												+ '批复了设备借用申请单['+@applyID+']。')

	--设置关联单据：
	declare @execRet int
	declare @needEqpCodes varchar(80)	--关联单据的设备编号
	if (@linkInvoiceType=1)	--1->学术报告
	begin
		set @needEqpCodes = isnull((select needEqpCodes from academicReports where aReportID = @linkInvoice),'')

		set @count = isnull((select count(*) from eqpBorrowApplyInfo 
						where linkInvoiceType = 1 and linkInvoice = @linkInvoice and applyStatus=0
						and eCode in (SELECT cast(T.x.query('data(.)') as char(8)) FROM 
										(SELECT CONVERT(XML,'<x>'+REPLACE(@needEqpCodes,',','</x><x>')+'</x>',1) Col1) A
										OUTER APPLY A.Col1.nodes('/x') AS T(x))
									),'')
		if (@count=0)
		begin
			exec dbo.eqpIsReady4Meeting @linkInvoice, @execRet output
			if (@execRet <> 0)
				set @Ret = 5
		end
	end
	else if (@linkInvoiceType=2)--2->会议
	begin
		set @needEqpCodes = isnull((select needEqpCodes from meetingInfo where meetingID = @linkInvoice),'')

		set @count = isnull((select count(*) from eqpBorrowApplyInfo 
						where linkInvoiceType = 2 and linkInvoice = @linkInvoice and applyStatus=0
						and eCode in (SELECT cast(T.x.query('data(.)') as char(8)) FROM 
										(SELECT CONVERT(XML,'<x>'+REPLACE(@needEqpCodes,',','</x><x>')+'</x>',1) Col1) A
										OUTER APPLY A.Col1.nodes('/x') AS T(x))
									),'')
		if (@count=0)
		begin
			exec dbo.eqpIsReady4Meeting @linkInvoice, @execRet output
			if (@execRet <> 0)
				set @Ret = 5
		end
	end
GO



--共享设备状态一览表查询语句：
select s.eCode, e.eName, e.eModel, e.eFormat, e.curEqpStatus, e.unit, e.price, e.totalAmount, 
	e.currency, e.cPrice, e.cTotalAmount, 
	e.uCode, u.uName, e.keeperID, e.keeper, e.eqpLocate,
	isnull(s.borrowerID,'') borrowerID, isnull(s.borrower,''), convert(varchar(19),s.lentTime,120) lentTime, 
	convert(varchar(19),s.expectedReturnTime,120) expectedReturnTime, s.borrowReason,
	s.isShare, convert(varchar(19),s.setOffDate,120) setOffDate
from shareEqpStatus s left join equipmentList e on s.eCode = e.eCode
	left join useUnit u on u.uCode = e.uCode


--指定的共享设备借用情况登记表
select b.eCode, e.eName, e.eModel, e.eFormat,
	isnull(b.applyID,'') applyID, isnull(b.borrowerID,''), isnull(b.borrower,''), 
	convert(varchar(19),b.lentTime,120) lentTime, 
	convert(varchar(19),b.expectedReturnTime,120) expectedReturnTime,
	b.borrowReason, convert(varchar(19),b.returnTime,120) returnTime
from eqpBorrowInfo b left join equipmentList e on b.eCode = e.eCode
order by rowNum desc



--查询指定共享设备指定日期后的所有借用申请单：
select applyID, eCode, applyStatus, eName, eModel, eFormat, 
	borrowerID, borrower,
	convert(varchar(19),lentTime,120) lentTime, 
	convert(varchar(19),expectedReturnTime,120) expectedReturnTime,
	borrowReason
from eqpBorrowApplyInfo


select b.eCode, e.eName, e.eModel, e.eFormat,isnull(b.applyID,'') applyID, isnull(b.borrowerID,'') borrowerID, 
isnull(b.borrower,'') borrower, convert(varchar(19),b.lentTime,120) lentTime, 
convert(varchar(19),b.expectedReturnTime,120) expectedReturnTime,b.borrowReason, 
convert(varchar(19),b.returnTime,120) returnTime
from  eqpBorrowInfo b left join equipmentList e on b.eCode = e.eCode




select s.eCode, e.eName, e.eModel, e.eFormat, e.curEqpStatus, e.unit, e.price, 
e.totalAmount, e.currency, e.cPrice, e.cTotalAmount,e.uCode, u.uName, e.keeperID, e.keeper, e.eqpLocate,
isnull(s.borrowerID,'') borrowerID, isnull(s.borrower,'') borrower, 
convert(varchar(19),s.lentTime,120) lentTime, 
convert(varchar(19),s.expectedReturnTime,120) expectedReturnTime, 
s.borrowReason,s.isShare, convert(varchar(19),s.setOffDate,120) setOffDate
from shareEqpStatus s left join equipmentList e on s.eCode = e.eCode
left join useUnit u on u.uCode = e.uCode


select applyID, eCode, applyStatus, eName, eModel, eFormat,
borrowerID, borrower,
convert(varchar(19),lentTime,120) lentTime, 
convert(varchar(19),expectedReturnTime,120) expectedReturnTime,
borrowReason
from eqpBorrowApplyInfo
where eCode = '20130190' and (lentTime BETWEEN '2013-03-20 12:00:00' and '2013-03-20 14:00:00')
order by lentTime
