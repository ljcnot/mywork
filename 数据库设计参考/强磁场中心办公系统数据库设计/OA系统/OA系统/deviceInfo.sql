/*
	强磁场中心办公系统-装置管理
	author:		卢苇
	CreateDate:	2013-1-8
	UpdateDate: 
*/
use hustOA
select * from deviceInfo
--1.装置一览表：
drop table deviceInfo
CREATE TABLE deviceInfo(
	deviceID varchar(10) not null,		--主键：装置编号,本系统使用第70号号码发生器产生（'ZZ'+4位年份代码+4位流水号）
	deviceName nvarchar(30) null,		--装置名称
	devicePhotoFile varchar(128) null,	--装置缩略图文件路径
	buildDate smalldatetime null,		--装置建立日期
	scrappedDate smalldatetime null,	--报废日期
	keeperID varchar(10) null,			--保管人工号
	keeper nvarchar(30) null,			--保管人
	
	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_deviceInfo] PRIMARY KEY CLUSTERED 
(
	[deviceID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
insert deviceInfo(deviceID, deviceName, devicePhotoFile, buildDate, scrappedDate, keeperID, keeper)
values('ZZ20130001','装置1','','2013-01-01',null,'00001','卢苇')

insert deviceRepairInfo(repairID, deviceID, deviceName, repairStartTime,remark)
values('WX20130001','ZZ20130001','装置1','2013-01-07','装置调试')

--2.装置状态一览表：该表只登记装置维修状态，其他时间为正常状态
select * from deviceRepairInfo
drop TABLE deviceRepairInfo
CREATE TABLE deviceRepairInfo(
	repairID varchar(10) not null,		--主键：装置维修单编号,本系统使用第71号号码发生器产生（'ZZ'+4位年份代码+4位流水号）
	deviceID varchar(10) not null,		--主键/外键：装置编号
	deviceName nvarchar(30) null,		--装置名称：冗余设计
	repairManID varchar(10) null,		--维修负责人ID
	repairMan nvarchar(10) null,		--维修负责人
	repairStartTime smalldatetime null,	--维修开始时间
	repairEndTime smalldatetime null,	--维修预计结束时间
	remark nvarchar(300) not null,		--说明（原因）
	isCompleted smallint default(0),	--是否完成：0->未完工，1->已完工
	completedTime smalldatetime null,	--维修实际完成时间
	completedDesc nvarchar(300) null,	--维修完成情况
	
	--以下是统计使用的字段，由数据库自动维护
	repairMinute int default(0),		--本次维修时间：单位：分钟
	
	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_deviceRepairInfo] PRIMARY KEY CLUSTERED 
(
	[repairID] ASC,
	[deviceID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[deviceRepairInfo] WITH CHECK ADD CONSTRAINT [FK_deviceRepairInfo_deviceInfo] FOREIGN KEY([deviceID])
REFERENCES [dbo].[deviceInfo] ([deviceID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[deviceRepairInfo] CHECK CONSTRAINT [FK_deviceRepairInfo_deviceInfo]
GO

--索引：
--维修时间索引：
CREATE NONCLUSTERED INDEX [IX_deviceRepairInfo] ON [dbo].[deviceRepairInfo] 
(
	[deviceID] ASC,
	[repairStartTime] ASC,
	[repairEndTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


drop FUNCTION getDeviceStatus
/*
	name:		getDeviceStatus
	function:	0.获取装置状态
	input: 
				@deviceID varchar(10),		--装置编号
				@statusTime smalldatetime	--状态时间
	output: 
				return xml					--返回
											N'<root>
												<status>正常</status>
												<statusCode>1</statusCode>
												<remark>说明：<remark>'
											</root>
											状态码：0->该设备不存在1->正常-1->维修中
	author:		卢苇
	CreateDate:	2013-1-9
	UpdateDate: 
*/
create FUNCTION getDeviceStatus
(  
	@deviceID varchar(10),	--装置编号
	@statusTime smalldatetime	--状态时间
)  
RETURNS xml	
WITH ENCRYPTION
AS      
begin
	DECLARE @statusRemark nvarchar(300);
	select top 1 @statusRemark = remark from deviceRepairInfo 
	where deviceID = @deviceID and @statusTime BETWEEN repairStartTime and isnull(repairEndTime,getdate())
	if (@statusRemark is null)
		set @statusRemark = '<root><status>正常</status><statusCode>1</statusCode><remark></remark></root>'
	else
		set @statusRemark = '<root><status>维修中</status><statusCode>-1</statusCode><remark>'+@statusRemark+'</remark></root>'
	
	return @statusRemark
end


drop PROCEDURE queryDeviceInfoLocMan
/*
	name:		queryDeviceInfoLocMan
	function:	1.查询指定装置是否有人正在编辑
	input: 
				@deviceID varchar(10),		--装置编号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的装置不存在
				@lockManID varchar(10) output	--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2013-1-9
	UpdateDate: 
*/
create PROCEDURE queryDeviceInfoLocMan
	@deviceID varchar(10),		--装置编号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from deviceInfo where deviceID= @deviceID),'')
	set @Ret = 0
GO


drop PROCEDURE lockDeviceInfo4Edit
/*
	name:		lockDeviceInfo4Edit
	function:	2.锁定装置编辑，避免编辑冲突
	input: 
				@deviceID varchar(10),			--装置编号
				@lockManID varchar(10) output,	--锁定人，如果当前装置正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的装置不存在，2:要锁定的装置正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-9
	UpdateDate: 
*/
create PROCEDURE lockDeviceInfo4Edit
	@deviceID varchar(10),		--装置编号
	@lockManID varchar(10) output,	--锁定人，如果当前装置正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的装置是否存在
	declare @count as int
	set @count=(select count(*) from deviceInfo where deviceID= @deviceID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from deviceInfo where deviceID= @deviceID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update deviceInfo
	set lockManID = @lockManID 
	where deviceID= @deviceID
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
	values(@lockManID, @lockManName, getdate(), '锁定装置编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了装置['+ @deviceID +']为独占式编辑。')
GO

drop PROCEDURE unlockDeviceInfoEditor
/*
	name:		unlockDeviceInfoEditor
	function:	3.释放装置编辑锁
				注意：本过程不检查装置是否存在！
	input: 
				@deviceID varchar(10),			--装置编号
				@lockManID varchar(10) output,	--锁定人，如果当前装置正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-9
	UpdateDate: 
*/
create PROCEDURE unlockDeviceInfoEditor
	@deviceID varchar(10),			--装置编号
	@lockManID varchar(10) output,	--锁定人，如果当前装置呢正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from deviceInfo where deviceID= @deviceID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update deviceInfo set lockManID = '' where deviceID= @deviceID
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
	values(@lockManID, @lockManName, getdate(), '释放装置编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了装置['+ @deviceID +']的编辑锁。')
GO

drop PROCEDURE addDeviceInfo
/*
	name:		addDeviceInfo
	function:	4.添加装置信息
	input: 
				@deviceName nvarchar(30),		--装置名称
				@devicePhotoFile varchar(128),	--装置缩略图文件路径
				@buildDate varchar(10),			--装置建立日期:采用“yyyy-MM-dd”格式传送
				@keeperID varchar(10),			--保管人工号

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output,--添加时间
				@deviceID varchar(10) output	--装置编号,本系统使用第70号号码发生器产生（'ZZ'+4位年份代码+4位流水号）
	author:		卢苇
	CreateDate:	2013-1-9
	UpdateDate: 
*/
create PROCEDURE addDeviceInfo
	@deviceName nvarchar(30),		--装置名称
	@devicePhotoFile varchar(128),	--装置缩略图文件路径
	@buildDate varchar(10),			--装置建立日期:采用“yyyy-MM-dd”格式传送
	@keeperID varchar(10),			--保管人工号

	@createManID varchar(10),		--创建人工号
	@Ret		int output,
	@createTime smalldatetime output,
	@deviceID varchar(10) output	--装置编号,本系统使用第70号号码发生器产生（'ZZ'+4位年份代码+4位流水号）
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生装置编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 70, 1, @curNumber output
	set @deviceID = @curNumber

	--取保管人/创建人的姓名：
	declare @keeper nvarchar(300), @createManName nvarchar(30)
	set @keeper = isnull((select cName from userInfo where jobNumber = @keeperID),'')
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert deviceInfo(deviceID, deviceName, devicePhotoFile, buildDate, keeperID, keeper,
					--最新维护情况:
					modiManID, modiManName, modiTime)
	values(@deviceID, @deviceName, @devicePhotoFile, @buildDate, @keeperID, @keeper,
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
	values(@createManID, @createManName, @createTime, '登记装置', '系统根据用户' + @createManName + 
					'的要求登记了装置“' + @deviceName + '['+@deviceID+']”。')
GO
--测试：
declare	@Ret		int
declare	@createTime smalldatetime
declare	@deviceID varchar(10)
exec dbo.addDeviceInfo '装置2', '', '2012-12-30', '00002', '00002', @Ret output, @createTime output, @deviceID output
select @Ret, @deviceID

select * from deviceInfo
select * from deviceRepairInfo
delete deviceInfo


drop PROCEDURE updateDeviceInfo
/*
	name:		updateDeviceInfo
	function:	5.修改装置信息
	input: 
				@deviceID varchar(10),			--装置编号
				@deviceName nvarchar(30),		--装置名称
				@devicePhotoFile varchar(128),	--装置缩略图文件路径
				@buildDate varchar(10),			--装置建立日期:采用“yyyy-MM-dd”格式传送
				@scrappedDate varchar(10),		--报废日期:采用“yyyy-MM-dd”格式传送
				@keeperID varchar(10),			--保管人工号

				@modiManID varchar(10) output,	--修改人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:要修改的装置不存在，
							2:要修改的装置正被别人锁定编辑，
							9:未知错误
				@modiTime smalldatetime output	--修改时间
	author:		卢苇
	CreateDate:	2013-1-9
	UpdateDate: 
*/
create PROCEDURE updateDeviceInfo
	@deviceID varchar(10),			--装置编号
	@deviceName nvarchar(30),		--装置名称
	@devicePhotoFile varchar(128),	--装置缩略图文件路径
	@buildDate varchar(10),			--装置建立日期:采用“yyyy-MM-dd”格式传送
	@scrappedDate varchar(10),		--报废日期:采用“yyyy-MM-dd”格式传送
	@keeperID varchar(10),			--保管人工号

	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的装置是否存在
	declare @count as int
	set @count=(select count(*) from deviceInfo where deviceID= @deviceID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from deviceInfo where deviceID= @deviceID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--保管人/取维护人的姓名：
	declare @keeper nvarchar(300)
	set @keeper = isnull((select cName from userInfo where jobNumber = @keeperID),'')
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	update deviceInfo
	set deviceName = @deviceName, devicePhotoFile = @devicePhotoFile, buildDate = @buildDate, scrappedDate = @scrappedDate, 
		keeperID = @keeperID, keeper = @keeper,
		--最新维护情况:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where deviceID= @deviceID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '修改装置', '系统根据用户' + @modiManName + 
					'的要求修改了装置“' + @deviceName + '['+@deviceID+']”的登记信息。')
GO

drop PROCEDURE delDeviceInfo
/*
	name:		delDeviceInfo
	function:	6.删除指定的装置
	input: 
				@deviceID varchar(10),			--装置编号
				@delManID varchar(10) output,	--删除人，如果当前装置正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的装置不存在，2：要删除的装置正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-9
	UpdateDate: 

*/
create PROCEDURE delDeviceInfo
	@deviceID varchar(10),			--装置编号
	@delManID varchar(10) output,	--删除人，如果当前装置正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的装置是否存在
	declare @count as int
	set @count=(select count(*) from deviceInfo where deviceID= @deviceID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from deviceInfo where deviceID= @deviceID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete deviceInfo where deviceID= @deviceID
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除装置', '用户' + @delManName
												+ '删除了装置['+@deviceID+']。')

GO


--------------------------------------------装置维修存储过程----------------------------------
drop PROCEDURE queryDeviceRepairLocMan
/*
	name:		queryDeviceRepairLocMan
	function:	10.查询指定装置维修申请单是否有人正在编辑
	input: 
				@repairID varchar(10),		--装置维修申请单号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的装置维修申请单不存在
				@lockManID varchar(10) output	--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2013-1-9
	UpdateDate: 
*/
create PROCEDURE queryDeviceRepairLocMan
	@repairID varchar(10),		--装置维修申请单号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from deviceRepairInfo where repairID= @repairID),'')
	set @Ret = 0
GO

drop PROCEDURE lockDeviceRepair4Edit
/*
	name:		lockDeviceRepair4Edit
	function:	11.锁定装置维修申请单编辑，避免编辑冲突
	input: 
				@repairID varchar(10),			--装置维修申请单号
				@lockManID varchar(10) output,	--锁定人，如果当前装置维修申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的装置维修申请单不存在，2:要锁定的装置维修申请单正在被别人编辑，
							3:该单据已经完成，不能编辑锁定
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-9
	UpdateDate: 
*/
create PROCEDURE lockDeviceRepair4Edit
	@repairID varchar(10),			--装置维修申请单号
	@lockManID varchar(10) output,	--锁定人，如果当前装置维修申请单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的装置维修申请单是否存在
	declare @count as int
	set @count=(select count(*) from deviceRepairInfo where repairID= @repairID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查锁与单据状态：
	declare @thisLockMan varchar(10), @isCompleted smallint
	select @thisLockMan = isnull(lockManID,''), @isCompleted = isCompleted from deviceRepairInfo where repairID= @repairID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	--判断单据状态：
	if (@isCompleted=1)
	begin
		set @Ret = 3
		return
	end

	update deviceRepairInfo
	set lockManID = @lockManID 
	where repairID= @repairID
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
	values(@lockManID, @lockManName, getdate(), '锁定装置维修编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了装置维修申请单['+ @repairID +']为独占式编辑。')
GO

drop PROCEDURE unlockDeviceRepairEditor
/*
	name:		unlockDeviceRepairEditor
	function:	12.释放装置维修申请单编辑锁
				注意：本过程不检查装置维修申请单是否存在！
	input: 
				@repairID varchar(10),			--装置维修申请单编号
				@lockManID varchar(10) output,	--锁定人，如果当前装置维修申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-9
	UpdateDate: 
*/
create PROCEDURE unlockDeviceRepairEditor
	@repairID varchar(10),			--装置维修申请单编号
	@lockManID varchar(10) output,	--锁定人，如果当前装置维修申请单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from deviceRepairInfo where repairID= @repairID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update deviceRepairInfo set lockManID = '' where repairID= @repairID
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
	values(@lockManID, @lockManName, getdate(), '释放装置维修编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了装置维修单['+ @repairID +']的编辑锁。')
GO


	
drop PROCEDURE addDeviceRepairInfo
/*
	name:		addDeviceRepairInfo
	function:	13.添加装置维修单
	input: 
				@deviceID varchar(10),			--装置编号
				@repairManID varchar(10),		--维修负责人ID
				@repairStartTime varchar(19),	--维修开始时间：采用"yyyy-MM-dd hh:mm:ss"格式传送
				@repairEndTime varchar(19),		--维修预计结束时间：采用"yyyy-MM-dd hh:mm:ss"格式传送
				@remark nvarchar(300),			--说明（原因）

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1:该装置还有未完成的维修工程，9:未知错误
				@createTime smalldatetime output,--添加时间
				@repairID varchar(10) output	--装置维修单编号,本系统使用第71号号码发生器产生（'ZZ'+4位年份代码+4位流水号）
	author:		卢苇
	CreateDate:	2013-1-9
	UpdateDate: 
*/
create PROCEDURE addDeviceRepairInfo
	@deviceID varchar(10),			--装置编号
	@repairManID varchar(10),		--维修负责人ID
	@repairStartTime varchar(19),	--维修开始时间：采用"yyyy-MM-dd hh:mm:ss"格式传送
	@repairEndTime varchar(19),		--维修预计结束时间：采用"yyyy-MM-dd hh:mm:ss"格式传送
	@remark nvarchar(300),			--说明（原因）

	@createManID varchar(10),		--创建人工号
	@Ret		int output,
	@createTime smalldatetime output,
	@repairID varchar(10) output	--装置维修单编号,本系统使用第71号号码发生器产生（'ZZ'+4位年份代码+4位流水号）
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查是否有未完成的维修：
	declare @count int
	set @count = isnull((select count(*) from deviceRepairInfo where deviceID = @deviceID and isCompleted = 0),0)
	if (@count>0)
	begin
		set @Ret = 1
		return
	end
	
	--使用号码发生器产生装置编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 71, 1, @curNumber output
	set @repairID = @curNumber

	--取装置名称：
	declare @deviceName nvarchar(30)
	set @deviceName = isnull((select deviceName from deviceInfo where deviceID = @deviceID),'')
	
	--维修负责人/创建人的姓名：
	declare @repairMan nvarchar(300), @createManName nvarchar(30)
	set @repairMan = isnull((select cName from userInfo where jobNumber = @repairManID),'')
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	--计算本次维修时间：
	declare @repairMinute int --单位：分钟
	set @repairMinute = DATEDIFF(MINUTE,@repairStartTime, @repairEndTime)

	set @createTime = getdate()
	insert deviceRepairInfo(repairID, deviceID, deviceName, repairManID, repairMan, 
					repairStartTime, repairEndTime, remark, repairMinute,
					--最新维护情况:
					modiManID, modiManName, modiTime)
	values(@repairID, @deviceID, @deviceName, @repairManID, @repairMan, 
					@repairStartTime, @repairEndTime, @remark, @repairMinute,
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
	values(@createManID, @createManName, @createTime, '登记装置维修', '系统根据用户' + @createManName + 
					'的要求登记了装置“' + @deviceName + '”的维修单['+@repairID+']”。')
GO
--测试：
declare	@Ret		int
declare	@createTime smalldatetime
declare	@repairID varchar(10)
exec dbo.addDeviceRepairInfo 'ZZ20130025', '00001', '2013-1-9 12:00:00', '2013-1-10 12:00:00', '年度保养', '00002',
		 @Ret output, @createTime output, @repairID output
select @Ret, @repairID


select * from deviceInfo
select * from deviceRepairInfo
delete deviceRepairInfo


drop PROCEDURE updateDeviceRepairInfo
/*
	name:		updateDeviceRepairInfo
	function:	14.修改装置维修单信息
	input: 
				@repairID varchar(10),			--装置维修单编号
				@deviceID varchar(10),			--装置编号
				@repairManID varchar(10),		--维修负责人ID
				@repairStartTime varchar(19),	--维修开始时间：采用"yyyy-MM-dd hh:mm:ss"格式传送
				@repairEndTime varchar(19),		--维修预计结束时间：采用"yyyy-MM-dd hh:mm:ss"格式传送
				@remark nvarchar(300),			--说明（原因）

				@modiManID varchar(10) output,	--修改人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:要修改的装置维修单不存在，
							2:要修改的装置维修单正被别人锁定编辑，
							3:该维修单已经完成，不能修改
							9:未知错误
				@modiTime smalldatetime output	--修改时间
	author:		卢苇
	CreateDate:	2013-1-9
	UpdateDate: 
*/
create PROCEDURE updateDeviceRepairInfo
	@repairID varchar(10),			--装置维修单编号
	@deviceID varchar(10),			--装置编号
	@repairManID varchar(10),		--维修负责人ID
	@repairStartTime varchar(19),	--维修开始时间：采用"yyyy-MM-dd hh:mm:ss"格式传送
	@repairEndTime varchar(19),		--维修预计结束时间：采用"yyyy-MM-dd hh:mm:ss"格式传送
	@remark nvarchar(300),			--说明（原因）

	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的装置维修单是否存在
	declare @count as int
	set @count=(select count(*) from deviceRepairInfo where repairID= @repairID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查锁与单据状态：
	declare @thisLockMan varchar(10), @isCompleted smallint
	select @thisLockMan = isnull(lockManID,''), @isCompleted = isCompleted from deviceRepairInfo where repairID= @repairID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--判断单据状态：
	if (@isCompleted=1)
	begin
		set @Ret = 3
		return
	end

	--取装置名称：
	declare @deviceName nvarchar(30)
	set @deviceName = isnull((select deviceName from deviceInfo where deviceID = @deviceID),'')
	
	--维修负责人/取维护人的姓名
	declare @repairMan nvarchar(300)
	set @repairMan = isnull((select cName from userInfo where jobNumber = @repairManID),'')
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--计算本次维修时间：
	declare @repairMinute int --单位：分钟
	set @repairMinute = DATEDIFF(MINUTE,@repairStartTime, @repairEndTime)

	set @modiTime = getdate()
	update deviceRepairInfo
	set deviceID = @deviceID, deviceName = @deviceName, repairManID = @repairManID, repairMan = @repairMan, 
					repairStartTime = @repairStartTime, repairEndTime = @repairEndTime, 
					remark = @remark, repairMinute = @repairMinute,
		--最新维护情况:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where deviceID= @deviceID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '修改装置维修单', '系统根据用户' + @modiManName + 
					'的要求修改了装置“' + @deviceName + '”的维修单['+@repairID+']”的信息。')
GO

drop PROCEDURE delDeviceRepairInfo
/*
	name:		delDeviceRepairInfo
	function:	15.删除指定的装置维修单
	input: 
				@repairID varchar(10),			--装置维修单编号
				@delManID varchar(10) output,	--删除人，如果当前装置维修单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的装置维修单不存在，2：要删除的装置维修单正被别人锁定，
							3:该维修单已经完成，不能删除，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-9
	UpdateDate: 

*/
create PROCEDURE delDeviceRepairInfo
	@repairID varchar(10),			--装置维修单编号
	@delManID varchar(10) output,	--删除人，如果当前装置维修单正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的装置维修单是否存在
	declare @count as int
	set @count=(select count(*) from deviceRepairInfo where repairID= @repairID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @isCompleted smallint
	select @thisLockMan = isnull(lockManID,''), @isCompleted = isCompleted from deviceRepairInfo where repairID= @repairID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	--判断单据状态：
	if (@isCompleted=1)
	begin
		set @Ret = 3
		return
	end

	delete deviceRepairInfo where repairID= @repairID
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除装置维修单', '用户' + @delManName
												+ '删除了装置维修单['+@repairID+']。')
GO

drop PROCEDURE completeDeviceRepair
/*
	name:		completeDeviceRepair
	function:	15.完成指定装置的维修：将维修单设置为完成状态
				注意：这里使用的是装置编号，系统自动定位到未完成的维修单号
	input: 
				@deviceID varchar(10),			--装置编号
				@completedTime varchar(19),		--维修实际完成时间:采用“yyyy-MM-dd  hh:mm:ss”格式传递
				@completedDesc nvarchar(300),	--维修完成情况
				@completerID varchar(10) output,--完成人，如果当前装置维修单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：当前装置并不在维修状态，2：要完成的装置维修单正被别人锁定，
							3:该单据已经是完成状态，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-9
	UpdateDate: 

*/
create PROCEDURE completeDeviceRepair
	@deviceID varchar(10),			--装置编号
	@completedTime varchar(19),		--维修实际完成时间:采用“yyyy-MM-dd  hh:mm:ss”格式传递
	@completedDesc nvarchar(300),	--维修完成情况
	@completerID varchar(10) output,--完成人，如果当前装置维修单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--获取当前正在维修的单号：
	declare @repairID varchar(10)
	set @repairID = isnull((select top 1 repairID from deviceRepairInfo where deviceID = @deviceID and isCompleted = 0),'')
	--判断要锁定的装置维修单是否存在
	if (@repairID='')	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @isCompleted smallint
	select @thisLockMan = isnull(lockManID,''), @isCompleted = isCompleted from deviceRepairInfo where repairID= @repairID
	if (@thisLockMan <> '' and @thisLockMan <> @completerID)
	begin
		set @completerID = @thisLockMan
		set @Ret = 2
		return
	end
	--判断单据状态：
	if (@isCompleted=1)
	begin
		set @Ret = 3
		return
	end

	--取完成人姓名
	declare @completer nvarchar(30)
	set @completer = isnull((select userCName from activeUsers where userID = @completerID),'')

	declare @modiTime smalldatetime
	set @modiTime = getdate()
	update deviceRepairInfo 
	set isCompleted = 1, completedTime = @completedTime, completedDesc = @completedDesc,
		repairMinute = DATEDIFF(MINUTE,repairStartTime, @completedTime),
		--最新维护情况:
		modiManID = @completerID, modiManName = @completer, modiTime = @modiTime
	where repairID= @repairID
	set @Ret = 0


	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@completerID, @completer, @modiTime, '完成装置维修', '用户' + @completer
												+ '完成了装置维修的设定，完成了维修单['+@repairID+']。')
GO


--装置当前状态查询语句：
select deviceID, deviceName, devicePhotoFile, buildDate, scrappedDate, keeperID, keeper, 
	dbo.getDeviceStatus(deviceID, GETDATE()) statusRemark	--返回{status:"正常", statusCode:1, remark:""} Json对象，状态码：0->该设备不存在1->正常-1->维修中
from deviceInfo

	
--装置历史状态查询语句：
select deviceID, deviceName, devicePhotoFile, buildDate, scrappedDate, keeperID, keeper, 
	dbo.getDeviceStatus(deviceID, '2012-01-01') statusRemark	--返回{status:"正常", statusCode:1, remark:""} Json对象，状态码：0->该设备不存在1->正常-1->维修中
from deviceInfo

select cast(N'<root><status>正常</status><statusCode>1</statusCode><remark></remark></root>'  as XML)


select convert(smalldatetime, '2012-01-01', 120)


--维修申请单查询语句：
select repairID, deviceID, deviceName, repairManID, repairMan, repairStartTime, repairEndTime, remark
from deviceRepairInfo

