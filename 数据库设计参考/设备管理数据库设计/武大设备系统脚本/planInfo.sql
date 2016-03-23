use epdc211

/*
	武大设备管理信息系统-采购计划类表与存储过程
	author:		卢苇
	CreateDate:	2010-12-1
	UpdateDate: modi by lw 2012-8-15将涉及到人员的部分改成使用工号控制，增加创建人字段，将明细单和概要单存储过程处理集成
*/


--客户需求：考虑采购申请，采购申请审批要调阅同类设备情况

--1.采购计划概要单：
select ROW_NUMBER() OVER(order by buyDate) AS RowID, eTypeCode, eTypeName, aTypeCode, eName, eModel, eFormat, convert(char(10),buyDate,120) buyDate, price, totalAmount, keeper
from equipmentList

select * from eqpPlanInfo
delete eqpPlanInfo where planApplyID not in ('201101240001','201101230003')
drop TABLE eqpPlanInfo

alter TABLE eqpPlanInfo alter column totalMoney numeric(15,2) default(0)--总金额:修改数据类型 modi by lw 2012-10-27
alter TABLE eqpPlanInfo alter column totalNowNum int default(0)			--总现有数量


drop TABLE eqpPlanInfo
CREATE TABLE eqpPlanInfo
(
	planApplyID char(12) not null,		--主键：采购计划单号，使用第 10 号号码发生器产生
	applyDate smalldatetime default(getdate()),	--申请日期
	planApplyStatus int default(0),		--采购计划单状态：0->正在编制，1->已执行

	--申请单位：需要用户确认是只到院部还是到使用单位！！
	clgCode char(3) not null,			--学院代码
	clgName nvarchar(30) null,			--学院名称:冗余设计，保存历史数据
	uCode varchar(8) null,				--使用单位代码, modi by lw 2011-2-11根据设备处要求延长编码长度！
	uName nvarchar(30) null,			--使用单位名称:冗余设计，保存历史数据

	fCode char(2) not null,				--经费来源代码
	aCode char(2) not null,				--使用方向代码
	
	totalNum int default(0),			--总数量:数量限制在100以内
	totalMoney numeric(15,2) default(0),--总金额:修改数据类型 modi by lw 2012-10-27
	totalNowNum int default(0),			--总现有数量
	
	buyReason nvarchar(300) null,		--申请购置理由
	clgManagerID varchar(10) null,		--单位负责人工号 add by lw 2012-8-15
	clgManager nvarchar(30) null,		--单位负责人
	clgManagerADate smalldatetime null,	--单位负责人签字日期
	
	leaderComments nvarchar(300) null,	--校领导意见
	leaderID varchar(10) null,			--校领导工号 add by lw 2012-8-15
	leaderName nvarchar(30) null,		--校领导姓名
	leaderADate smalldatetime null,		--校领导签字日期
	
	processManID varchar(10) null,		--执行人（设备处人员）工号（UI中暂时不要出现，直接使用当前用户存档）
	processMan nvarchar(30) null,		--执行人（设备处人员）
	processDate smalldatetime null,		--执行日期

	--创建人：add by lw 2012-8-15为了保持操作的范围——个人的一致性增加的字段
	createManID varchar(10) null,		--创建人工号
	createManName varchar(30) null,		--创建人姓名
	createTime smalldatetime null,		--创建时间

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName varchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_eqpPlanInfo] PRIMARY KEY CLUSTERED 
(
	[planApplyID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
CREATE NONCLUSTERED INDEX [IX_eqpPlanInfo] ON [dbo].[eqpPlanInfo] 
(
	[clgCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_eqpPlanInfo_1] ON [dbo].[eqpPlanInfo] 
(
	[applyDate] desc
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_eqpPlanInfo_2] ON [dbo].[eqpPlanInfo] 
(
	[processDate] desc
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_eqpPlanInfo_3] ON [dbo].[eqpPlanInfo] 
(
	[fCode] desc
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_eqpPlanInfo_4] ON [dbo].[eqpPlanInfo] 
(
	[aCode] desc
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--2.采购计划明细表：
drop table eqpPlanDetail
CREATE TABLE eqpPlanDetail(
	planApplyID char(12) not null,		--主键：采购计划单号，使用第 10 号号码发生器产生
	rowNum int IDENTITY(1,1) NOT NULL,	--序号
	eTypeCode char(8) not null,			--分类编号（教）
	eTypeName nvarchar(30) not null,	--教育部分类名称:为了解决多对多的问题需要增加的字段，add by lw 2010-11-30
	aTypeCode char(6) not null,			--分类编号（财）
	
	eName nvarchar(30) not null,		--设备名称
	eModel nvarchar(20) not null,		--设备型号
	price numeric(12,2) null,			--单价:修改数据类型 modi by lw 2012-10-27
	sumNumber int not null,				--数量
	nowNum int default(0),				--现有数量
 CONSTRAINT [PK_eqpPlanDetail] PRIMARY KEY CLUSTERED 
(
	[planApplyID] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[eqpPlanDetail] WITH CHECK ADD CONSTRAINT [FK_eqpPlanDetail_eqpPlanInfo] FOREIGN KEY([planApplyID])
REFERENCES [dbo].[eqpPlanInfo] ([planApplyID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[eqpPlanDetail] CHECK CONSTRAINT [FK_eqpPlanDetail_eqpPlanInfo]
GO

select * from eqpPlanDetail
insert eqpPlanDetail(planApplyID, eTypeCode, eTypeName, aTypeCode, eName,eModel,price,sumNumber,nowNum)
select planApplyID, eTypeCode, eTypeName, aTypeCode, '测试设备',eModel,price,sumNumber,nowNum
from eqpPlanDetail

drop PROCEDURE addPlanInfo
/*
	name:		addPlanInfo
	function:	1.添加采购计划申请单
				注意：该存储过程自动锁定单据
	input: 
				@applyDate varchar(10),			--申请日期
				--申请单位：
				@clgCode char(3),				--学院代码
				@uCode varchar(8),				--使用单位代码
				@fCode char(2),					--经费来源代码
				@aCode char(2),					--使用方向代码
				@planApplyDetail xml,			--使用xml存储的明细清单：N'<root>
																			--<row id="1">
																			--	<eTypeCode>04090401</eTypeCode>
																			--	<eTypeName>交流电动机</eTypeName>
																			--	<aTypeCode>603200</aTypeCode>
																			--	<eName>一般用途异步电动机</eName>
																			--	<eModel>YD100</eModel>
																			--	<price>1250.00</price>
																			--	<sumNumber>5</sumNumber>
																			--	<nowNum>10</nowNum>
																			--</row>
																			--<row id="2">
																			--	<eTypeCode>04090401</eTypeCode>
																			--	<eTypeName>三相滑环式异步电机</eTypeName>
																			--	<aTypeCode>603200</aTypeCode>
																			--	<eName>一般用途异步电动机</eName>
																			--	<eModel>SX100</eModel>
																			--	<price>2000.00</price>
																			--	<sumNumber>2</sumNumber>
																			--	<nowNum>5</nowNum>
																			--</row>
																		--</root>'
				@buyReason nvarchar(300),		--申请购置理由
				@clgManagerID varchar(10),		--单位负责人工号
				@clgManagerADate varchar(10),	--单位负责人签字日期
				
				@leaderComments nvarchar(300),	--校领导意见
				@leaderID varchar(10),			--校领导工号
				@leaderADate varchar(10),		--校领导签字日期
				
				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output	--添加时间
				@planApplyID char(12) output	--主键：采购计划单号，使用第 10 号号码发生器产生
	author:		卢苇
	CreateDate:	2011-1-16
	UpdateDate: modi by lw 2011-2-11根据设备处要求延长编码长度！
				modi by lw 2012-8-15将人员改用工号处理，将明细单的保存放在本过程内部，增加创建人字段
				modi by lw 2012-10-27修改金额相关字段的数据类型
*/
create PROCEDURE addPlanInfo
	@applyDate varchar(10),			--申请日期
	--申请单位：
	@clgCode char(3),				--学院代码
	@uCode varchar(8),				--使用单位代码
	@fCode char(2),					--经费来源代码
	@aCode char(2),					--使用方向代码
	@planApplyDetail xml,			--使用xml存储的明细清单
	@buyReason nvarchar(300),		--申请购置理由
	@clgManagerID varchar(10),		--单位负责人工号
	@clgManagerADate varchar(10),	--单位负责人签字日期
	
	@leaderComments nvarchar(300),	--校领导意见
	@leaderID varchar(10),			--校领导工号
	@leaderADate varchar(10),		--校领导签字日期
	
	@createManID varchar(10),		--创建人工号

	@Ret		int output,
	@createTime smalldatetime output,
	@planApplyID char(12) output	--主键：采购计划单号，使用第 10 号号码发生器产生
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 10, 1, @curNumber output
	set @planApplyID = @curNumber

	--获取院别和使用单位的名称：
	declare @clgName nvarchar(30), @uName nvarchar(30)	--学院名称/使用单位名称
	set @clgName = (select clgName from college where clgCode = @clgCode)
	set @uName = (select uName from useUnit where uCode = @uCode)

	--获取单位负责人\校领导姓名：
	declare @clgManager nvarchar(30), @leaderName nvarchar(30)
	set @clgManager = isnull((select cName from userInfo where jobNumber = @clgManagerID),'')
	set @leaderName = isnull((select cName from userInfo where jobNumber = @leaderID),'')

	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	begin tran
		insert eqpPlanInfo(planApplyID,applyDate,
							--申请单位：需要用户确认是只到院部还是到使用单位！！
							clgCode, clgName, uCode, uName,
							fCode, aCode,
							buyReason, clgManagerID, clgManager, clgManagerADate,
							leaderComments, leaderID, leaderName, leaderADate,
							processManID, processMan,
							lockManID, modiManID, modiManName, modiTime,
							createManID, createManName, createTime) 
		values (@planApplyID,@applyDate,
							--申请单位：需要用户确认是只到院部还是到使用单位！！
							@clgCode, @clgName, @uCode, @uName,
							@fCode, @aCode,
							@buyReason, @clgManagerID, @clgManager, @clgManagerADate,
							@leaderComments, @leaderID, @leaderName, @leaderADate,
							@createManID, @createManName,
							@createManID, @createManID, @createManName, @createTime,
							@createManID, @createManName, @createTime) 
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--插入明细表：
		insert eqpPlanDetail(planApplyID, eTypeCode, eTypeName, aTypeCode,	
								eName, eModel, price, sumNumber, nowNum)
		select @planApplyID, cast(T.x.query('data(./eTypeCode)') as char(8)), 
			cast(T.x.query('data(./eTypeName)') as nvarchar(30)),
			cast(T.x.query('data(./aTypeCode)') as char(8)), 
			cast(T.x.query('data(./eName)') as nvarchar(30)), 
			cast(T.x.query('data(./eModel)') as nvarchar(20)), 
			cast(cast(T.x.query('data(./price)') as varchar(20)) as numeric(12,2)), 
			cast(cast(T.x.query('data(./sumNumber)') as varchar(10)) as int), 
			cast(cast(T.x.query('data(./nowNum)') as varchar(10)) as int)
			from(select @planApplyDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--计算汇总信息：
		declare @totalNum int, @totalMoney numeric(15,2), @totalNowNum int			--总数量/总金额/总现有数量
		select @totalNum = sum(sumNumber), @totalMoney = sum(price * sumNumber), @totalNowNum = sum(nowNum)
		from eqpPlanDetail
		where planApplyID = @planApplyID
		
		update eqpPlanInfo
		set totalNum = @totalNum, totalMoney = @totalMoney, totalNowNum = @totalNowNum
		where planApplyID = @planApplyID
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
	values(@createManID, @createManName, @createTime, '添加采购计划申请单', '系统根据用户' + @createManName + 
					'的要求添加了采购计划申请单[' + @planApplyID + ']。')
GO
--测试：
select * from eqpPlanInfo
declare @createTime smalldatetime; set @createTime = getdate();
declare	@planApplyID char(12), @Ret int
DECLARE @String xml;
set @String = N'
<root>
	<row id="1">
	<eTypeCode>01010101</eTypeCode>
	<eTypeName>教学科研用房</eTypeName>
	<aTypeCode>025201 </aTypeCode>
	<eName>教学科研用房</eName>
	<eModel>*</eModel>
	<price>20101.00</price>
	<sumNumber>2</sumNumber>
	<nowNum>0</nowNum>
	</row>
</root>
'
exec dbo.addPlanInfo @createTime, '000', '00000','1','1', '00000000000', @Ret output, @createTime output, @planApplyID output
select @createTime, @planApplyID, @Ret

select * from eqpPlanInfo


update eqpPlanInfo 
set lockManID = ''
where planApplyID = '201101180004'
select * from eqpPlanDetail where planApplyID = '201101180004'
select * from eqpPlanInfo where planApplyID = '201101180004'
select * from workNote order by actionTime desc

drop PROCEDURE updatePlanInfo
/*
	name:		updatePlanInfo
	function:	2.更新采购计划单
	input: 
				@planApplyID char(12),				--采购计划单号
				@applyDate varchar(10),				--申请日期

				--申请单位：需要用户确认是只到院部还是到使用单位！！
				@clgCode char(3),					--学院代码
				@uCode varchar(8),					--使用单位代码

				@fCode char(2),						--经费来源代码
				@aCode char(2),						--使用方向代码
				@planApplyDetail xml,			--使用xml存储的明细清单：N'<root>
																			--<row id="1">
																			--	<eTypeCode>04090401</eTypeCode>
																			--	<eTypeName>交流电动机</eTypeName>
																			--	<aTypeCode>603200</aTypeCode>
																			--	<eName>一般用途异步电动机</eName>
																			--	<eModel>YD100</eModel>
																			--	<price>1250.00</price>
																			--	<sumNumber>5</sumNumber>
																			--	<nowNum>10</nowNum>
																			--</row>
																			--<row id="2">
																			--	<eTypeCode>04090401</eTypeCode>
																			--	<eTypeName>三相滑环式异步电机</eTypeName>
																			--	<aTypeCode>603200</aTypeCode>
																			--	<eName>一般用途异步电动机</eName>
																			--	<eModel>SX100</eModel>
																			--	<price>2000.00</price>
																			--	<sumNumber>2</sumNumber>
																			--	<nowNum>5</nowNum>
																			--</row>
																		--</root>'
				
				@buyReason nvarchar(300),			--申请购置理由
				@clgManagerID varchar(10),			--单位负责人工号
				@clgManagerADate varchar(10),		--单位负责人签字日期
				
				@leaderComments nvarchar(300),		--校领导意见
				@leaderID nvarchar(30),				--校领导工号
				@leaderADate varchar(10),			--校领导签字日期

				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前采购计划单正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0：成功，1：要更新的单据不存在，
							2：要更新的采购计划单正被别人锁定，
							3：该单据已经执行，不允许修改，
							9：未知错误
	author:		卢苇
	CreateDate:	2010-1-16
	UpdateDate: modi by lw 2011-2-11根据设备处要求延长编码长度！
				modi by lw 2012-8-15将人员改用工号处理，将明细单的保存放在本过程内部
				modi by lw 2012-10-27修改金额相关字段的数据类型
*/
create PROCEDURE updatePlanInfo
	@planApplyID char(12),				--采购计划单号
	@applyDate varchar(10),				--申请日期

	--申请单位：需要用户确认是只到院部还是到使用单位！！
	@clgCode char(3),					--学院代码
	@uCode varchar(8),					--使用单位代码

	@fCode char(2),						--经费来源代码
	@aCode char(2),						--使用方向代码
	@planApplyDetail xml,				--使用xml存储的明细清单
	
	@buyReason nvarchar(300),			--申请购置理由
	@clgManagerID varchar(10),			--单位负责人工号
	@clgManagerADate varchar(10),		--单位负责人签字日期
	
	@leaderComments nvarchar(300),		--校领导意见
	@leaderID varchar(10),				--校领导工号
	@leaderADate varchar(10),			--校领导签字日期
	
	--维护人:
	@modiManID varchar(10) output,		--维护人，如果当前采购计划单正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,	--更新时间
	@Ret		int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的验收申请单是否存在
	declare @count as int
	set @count=(select count(*) from eqpPlanInfo where planApplyID = @planApplyID)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpPlanInfo where planApplyID = @planApplyID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--检查单据状态:
	declare @planApplyStatus int
	set @planApplyStatus = (select planApplyStatus from eqpPlanInfo where planApplyID = @planApplyID)
	if (@planApplyStatus <> 0)
	begin
		set @Ret = 3
		return
	end
	
	--获取院别和使用单位的名称：
	declare @clgName nvarchar(30), @uName nvarchar(30)	--学院名称/使用单位名称
	set @clgName = (select clgName from college where clgCode = @clgCode)
	set @uName = (select uName from useUnit where uCode = @uCode)

	--获取单位负责人\校领导姓名：
	declare @clgManager nvarchar(30), @leaderName nvarchar(30)
	set @clgManager = isnull((select cName from userInfo where jobNumber = @clgManagerID),'')
	set @leaderName = isnull((select cName from userInfo where jobNumber = @leaderID),'')

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	begin tran
		--更新概要表：
		update eqpPlanInfo 
		set applyDate = @applyDate, 
			clgCode = @clgCode, clgName = @clgName, uCode = @uCode, uName = @uName,
			fCode = @fCode, aCode = @aCode,
			buyReason = @buyReason, clgManagerID = @clgManagerID, clgManager = @clgManager, clgManagerADate = @clgManagerADate,	
			leaderComments = @leaderComments, leaderID = @leaderID, leaderName = @leaderName, leaderADate = @leaderADate,
			processManID = @modiManID, processMan = @modiManName,
			--维护情况:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where planApplyID = @planApplyID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--删除原采购计划明细单：
		delete eqpPlanDetail where planApplyID = @planApplyID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--插入明细单：
		insert eqpPlanDetail(planApplyID, eTypeCode, eTypeName, aTypeCode,	
								eName, eModel, price, sumNumber, nowNum)
		select @planApplyID, cast(T.x.query('data(./eTypeCode)') as char(8)), 
			cast(T.x.query('data(./eTypeName)') as nvarchar(30)),
			cast(T.x.query('data(./aTypeCode)') as char(8)), 
			cast(T.x.query('data(./eName)') as nvarchar(30)), 
			cast(T.x.query('data(./eModel)') as nvarchar(20)), 
			cast(cast(T.x.query('data(./price)') as varchar(20)) as numeric(12,2)), 
			cast(cast(T.x.query('data(./sumNumber)') as varchar(10)) as int), 
			cast(cast(T.x.query('data(./nowNum)') as varchar(10)) as int)
			from(select @planApplyDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--计算汇总信息：
		declare @totalNum int, @totalMoney numeric(15,2), @totalNowNum int			--总数量/总金额/总现有数量
		select @totalNum = sum(sumNumber), @totalMoney = sum(price * sumNumber), @totalNowNum = sum(nowNum)
		from eqpPlanDetail
		where planApplyID = @planApplyID
		
		update eqpPlanInfo
		set totalNum = @totalNum, totalMoney = @totalMoney, totalNowNum = @totalNowNum
		where planApplyID = @planApplyID
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
	values(@modiManID, @modiManName, @updateTime, '更新采购计划单', '用户' + @modiManName 
												+ '更新了采购计划单['+ @planApplyID +']。')
GO




drop PROCEDURE queryPlanApplyLocMan
/*
	name:		queryPlanApplyLocMan
	function:	3.查询指定采购计划申请单是否有人正在编辑
	input: 
				@planApplyID char(12),		--主键：采购计划单号，使用第 10 号号码发生器产生
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的采购计划单不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2011-1-16
	UpdateDate: 
*/
create PROCEDURE queryPlanApplyLocMan
	@planApplyID char(12),		--主键：采购计划单号，使用第 10 号号码发生器产生
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from eqPlanInfo where planApplyID = @planApplyID),'')
	set @Ret = 0
GO


drop PROCEDURE lockPlanInfo4Edit
/*
	name:		lockPlanInfo4Edit
	function:	4.锁定采购计划单编辑，避免编辑冲突
	input: 
				@planApplyID char(12),		--主键：采购计划单号，使用第 10 号号码发生器产生
				@lockManID varchar(10) output,	--锁定人，如果当前采购计划单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的采购计划单不存在，2:要锁定的采购计划单正在被别人编辑，3:该单据已审核
							9：未知错误
	author:		卢苇
	CreateDate:	2011-1-16
	UpdateDate: 
*/
create PROCEDURE lockPlanInfo4Edit
	@planApplyID char(12),		--主键：采购计划单号，使用第 10 号号码发生器产生
	@lockManID varchar(10) output,	--锁定人，如果当前采购计划单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的采购计划单是否存在
	declare @count as int
	set @count=(select count(*) from eqpPlanInfo where planApplyID = @planApplyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpPlanInfo where planApplyID = @planApplyID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--检查单据状态:
	declare @planApplyStatus int
	set @planApplyStatus = (select planApplyStatus from eqpPlanInfo where planApplyID = @planApplyID)
	if (@planApplyStatus <> 0)
	begin
		set @Ret = 3
		return
	end

	update eqpPlanInfo 
	set lockManID = @lockManID 
	where planApplyID = @planApplyID
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定采购计划单编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了采购计划单['+ @planApplyID +']为独占式编辑。')
GO

drop PROCEDURE unlockPlanInfoEditor
/*
	name:		unlockPlanInfoEditor
	function:	5.释放采购计划单编辑锁
				注意：本过程不检查单据是否存在！
	input: 
				@planApplyID char(12),		--主键：采购计划单号，使用第 10 号号码发生器产生
				@lockManID varchar(10) output,	--锁定人，如果当前采购计划单正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2011-1-16
	UpdateDate: 
*/
create PROCEDURE unlockPlanInfoEditor
	@planApplyID char(12),		--主键：采购计划单号，使用第 10 号号码发生器产生
	@lockManID varchar(10) output,	--锁定人，如果当前采购计划单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpPlanInfo where planApplyID = @planApplyID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update eqpPlanInfo set lockManID = '' where planApplyID = @planApplyID
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
	values(@lockManID, @lockManName, getdate(), '释放采购计划单编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了采购计划单['+ @planApplyID +']的编辑锁。')
GO



drop PROCEDURE delPlanApply
/*
	name:		delPlanApply
	function:	7.删除指定的验收申请单
	input: 
				@planApplyID char(12),	--验收申请单号
				@delManID varchar(10) output,	--删除人，如果当前验收申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的验收申请单不存在，2：要删除的验收申请单正被别人锁定，3：单据已执行，不能删除，9：未知错误
	author:		卢苇
	CreateDate:	2011-1-16
	UpdateDate: 

*/
create PROCEDURE delPlanApply
	@planApplyID char(12),	--采购计划单号
	@delManID varchar(10) output,	--删除人，如果当前验收申请单正在被人占用编辑则返回该人的工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的验收申请单是否存在
	declare @count as int
	set @count=(select count(*) from eqpPlanInfo where planApplyID = @planApplyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpPlanInfo where planApplyID = @planApplyID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查单据状态:
	declare @planApplyStatus int			--采购计划单状态：0->未执行， 1->已执行
	set @planApplyStatus = (select planApplyStatus from eqpPlanInfo where planApplyID = @planApplyID)
	if (@planApplyStatus <> 0)
	begin
		set @Ret = 3
		return
	end

	delete eqpPlanInfo where planApplyID = @planApplyID
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除验收申请单', '用户' + @delManName
												+ '删除了验收申请单['+ @planApplyID +']。')

GO


drop PROCEDURE execPlanApply
/*
	name:		execPlanApply
	function:	8.执行采购计划申请单，并生成验收单
	input: 
				@planApplyID char(12),			--采购计划单号

				--维护人:
				@execManID varchar(10) output,	--执行人，如果当前采购计划单正在被人占用编辑则返回该人的工号
	output: 
				@execDate smalldatetime output,	--执行日期
				@Ret		int output				--操作成功标识
													0:成功，1：要执行的采购计划单正被别人锁定，2：该采购计划单已经执行，3：系统在执行采购计划的时候发生未知错误，
													9：未知错误
	author:		卢苇
	CreateDate:	201-1-16
	UpdateDate: modi by lw 2012-6-10修正国别代码不能为空的错误！
				modi by lw 2012-10-27修改金额相关字段的数据类型
*/
create PROCEDURE execPlanApply
	@planApplyID char(12),			--采购计划单号

	--维护人:
	@execManID varchar(10) output,	--执行人，如果当前采购计划单正在被人占用编辑则返回该人的工号

	@execDate smalldatetime output,	--执行日期
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpPlanInfo where planApplyID = @planApplyID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @execManID)
	begin
		set @execManID = @thisLockMan
		set @Ret = 1
		return
	end

	--再次检查单据状态:
	declare @planApplyStatus int			--采购计划单状态：0->未执行， 1->已执行
	set @planApplyStatus = (select planApplyStatus from eqpPlanInfo where planApplyID = @planApplyID)
	if (@planApplyStatus <> 0)
	begin
		set @Ret = 2
		return
	end

	--取维护人的姓名：
	declare @execMan nvarchar(30)
	set @execMan = isnull((select userCName from activeUsers where userID = @execManID),'')
	
	set @execDate = getdate()
	
	--取概要表中的申请单位等信息：
	declare @clgCode char(3)	--学院代码
	declare @uCode char(5)		--使用单位代码
	declare @fCode char(2)		--经费来源代码
	declare @aCode char(2)		--使用方向代码
	select @clgCode = clgCode, @uCode = uCode, @fCode = fCode, @aCode = aCode
	from eqpPlanInfo 
	where planApplyID = @planApplyID
	--获取院别和使用单位的名称：
	declare @clgName nvarchar(30), @uName nvarchar(30)	--学院名称/使用单位名称
	set @clgName = (select clgName from college where clgCode = @clgCode)
	set @uName = (select uName from useUnit where uCode = @uCode)
	--执行采购申请单：
	begin tran
		set @Ret = 3
		--逐个生成验收申请清单：
		declare @eTypeCode char(8)		--分类编号（教）
		declare @eTypeName nvarchar(30)	--教育部分类名称:为了解决多对多的问题需要增加的字段，add by lw 2010-11-30
		declare @aTypeCode char(6)		--分类编号（财）
		declare @eName nvarchar(30)		--设备名称
		declare @eModel nvarchar(20)	--设备型号
		declare @price money			--单价
		declare @sumNumber int			--数量
		declare tar cursor for
		select eTypeCode, eTypeName, aTypeCode, eName, eModel, price, sumNumber
		from eqpPlanDetail
		where planApplyID = @planApplyID
		order by rowNum
		OPEN tar
		FETCH NEXT FROM tar INTO @eTypeCode, @eTypeName, @aTypeCode, @eName, @eModel, @price, @sumNumber
		WHILE @@FETCH_STATUS = 0
		begin
			--使用号码发生器产生新的号码：
			declare @acceptApplyID char(12)			--验收单号
			declare @curNumber varchar(50)
			exec dbo.getClassNumber 1, 1, @curNumber output
			set @acceptApplyID = @curNumber

			--计算金额：
			declare @totalAmount numeric(12,2)			--总价, >0（单价）
			declare @sumAmount numeric(15,2)			--合计金额
			set @totalAmount = 	@price
			set @sumAmount = @totalAmount * @sumNumber
			
			--根据数量，构造出厂编号和附件编号：
			declare @serialNumber nvarchar(2100)	--出厂编号:采用“1|2|3|..."方式存放,最长支持20字符*100个号码
			declare @annexCode nvarchar(2100)		--随机附件编号:采用“1|2|3|..."方式存放,最长支持20字符*100个号码
			exec dbo.buildNumberString @sumNumber, @serialNumber output
			exec dbo.buildNumberString @sumNumber, @annexCode output
			
			insert eqpAcceptInfo(acceptApplyID, applyDate, procurementPlanID, eTypeCode, eTypeName, aTypeCode, eName,
									eModel, eFormat, cCode, serialNumber, 
									clgCode, clgName, uCode, uName, 
									fCode, aCode,
									factory, buyDate, business,
									price, totalAmount, sumNumber, sumAmount,
									lockManID, modiManID, modiManName, modiTime) 
			values (@acceptApplyID, @execDate, @planApplyID, @eTypeCode, @eTypeName, @aTypeCode, @eName,
									@eModel, '', '', @serialNumber, 
									@clgCode, @clgName, @uCode, @uName, 
									@fCode, @aCode,
									'', GETDATE(), '',
									@price, @totalAmount, @sumNumber, @sumAmount,
									'', @execManID, @execMan, @execDate)
			if @@ERROR <> 0 
			begin
				rollback tran
				CLOSE tar
				DEALLOCATE tar
				set @Ret = 9
				return
			end    
			FETCH NEXT FROM tar INTO @eTypeCode, @eTypeName, @aTypeCode, @eName, @eModel, @price, @sumNumber
		end
		CLOSE tar
		DEALLOCATE tar

		--更新采购申请单状态：
		update eqpPlanInfo
		set planApplyStatus = 1,	 --采购计划单状态：0->未执行， 1->已执行
			--执行人
			processManID = @execManID, processMan = @execMan, processDate = @execDate,
			--维护人：
			modiManID = @execManID, modiManName = @execMan,	modiTime = @execDate
		where planApplyID = @planApplyID
	commit tran	
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@execManID, @execMan, @execDate, '执行采购计划', '用户' + @execMan
												+ '执行了采购计划单['+ @planApplyID +'],系统自动生成了相应的验收单。')
GO
--测试：
select * from eqpPlanDetail where planApplyID = '201101180003'
select * from eqpPlanInfo where planApplyID = '201101180003'
select * from workNote order by actionTime desc
update eqpPlanInfo
set lockManID = ''
where planApplyID = '201101180003'

declare @execDate smalldatetime
declare @Ret int
exec dbo.execPlanApply '201101180003', '10000020', @execDate output, @Ret output
select @execDate, @Ret

select top 1000 * from eqpAcceptInfo order by applyDate desc

drop PROCEDURE buildNumberString
/*
	name:		buildNumberString
	function:	8.1构建用“|”分割的字串
	input: 
				@items int,						--数量
	output: 
				@sNumber varchar(2000) output	--构造的字符串
	author:		卢苇
	CreateDate:	201-1-18
	UpdateDate: 
*/
create PROCEDURE buildNumberString
	@items int,						--数量
	@sNumber nvarchar(2100) output	--构造的字符串
	WITH ENCRYPTION 
AS
	set @sNumber = ''
    if (@items <= 0)
        return

    declare @i int
    set @i = 1
    while @i <= @items
    begin
		set @sNumber = @sNumber + ltrim(str(@i)) + '|'
	    set @i = @i + 1
    end
	set @sNumber = substring(@sNumber, 1, len(@sNumber) -1)
go
--测试：
declare @str varchar(2000)
exec dbo.buildNumberString 5,@str output
select @str

drop PROCEDURE unexecPlanApply
/*
	name:		unexecPlanApply
	function:	9.取消执行采购计划申请单，并相应删除生成的验收单
	input: 
				@planApplyID char(12),			--采购计划单号

				--维护人:
				@unexecManID varchar(10),		--取消执行人
	output: 
				@unexecDate smalldatetime output,	--取消日期
				@Ret		int output				--操作成功标识
													0:成功，
													1: 该单据不是已执行状态，
													2：要取消的采购计划单生成的验收申请单正被别人锁定编辑，
													3：要取消的采购计划单生成的验收申请单已经执行，请先取消验收，
													9：未知错误
	author:		卢苇
	CreateDate:	201-1-18
	UpdateDate: 
*/
create PROCEDURE unexecPlanApply
	@planApplyID char(12),			--采购计划单号

	--维护人:
	@unexecManID varchar(10),		--取消执行人
	@unexecDate smalldatetime output,--取消日期
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查单据状态:
	declare @planApplyStatus int			--采购计划单状态：0->未执行， 1->已执行
	set @planApplyStatus = (select planApplyStatus from eqpPlanInfo where planApplyID = @planApplyID)
	if (@planApplyStatus <> 1)
	begin
		set @Ret = 1
		return
	end

	--取维护人的姓名：
	declare @unexecMan nvarchar(30)
	set @unexecMan = isnull((select userCName from activeUsers where userID = @unexecManID),'')
	
	--判断该计划生成的验收单的状态：
	declare @count int
		--判断验收单是否有人锁定编辑
	set @count = (select count(*) from eqpAcceptInfo
					where procurementPlanID = @planApplyID and isnull(lockManID,'') <> '')
	if (@count > 0)
	begin
		set @Ret = 2
		return
	end
		--判断验收单是否已经审核
	set @count = (select count(*) from eqpAcceptInfo
					where procurementPlanID = @planApplyID and acceptApplyStatus <> 0)
	if (@count > 0)
	begin
		set @Ret = 3
		return
	end
	
	set @unexecDate = getdate()
	
	begin tran
		delete eqpAcceptInfo
		where procurementPlanID = @planApplyID
		--更新采购申请单状态：
		update eqpPlanInfo
		set planApplyStatus = 0,	 --采购计划单状态：0->未执行， 1->已执行
			--执行人
			processManID = @unexecManID, processMan = @unexecMan, processDate = null,
			--维护人：
			modiManID = @unexecManID, modiManName = @unexecMan,	modiTime = @unexecDate
		where planApplyID = @planApplyID
	commit tran	
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@unexecManID, @unexecMan, @unexecDate, '取消执行采购计划', '用户' + @unexecMan
												+ '取消了执行的采购计划单['+ @planApplyID +'],系统自动删除了相应的验收单。')
GO
--测试：
declare @unexecDate smalldatetime
declare @Ret int
exec dbo.unexecPlanApply '201101180003', '10000020', @unexecDate output, @Ret output
select @unexecDate, @Ret

select top 1000 * from eqpAcceptInfo order by applyDate desc
select * from eqpPlanInfo where planApplyID = '201101180003'


select * from wd.dbo.eqpPlanInfo




--采购列表报表设计视图：
use epdc211
create view procurementInfo
as
	select p.planApplyID,convert(varchar(10),p.applyDate,120) applyDate,
			p.clgCode,p.clgName,p.uCode,p.uName,p.fCode,p.aCode,p.totalNum,p.totalMoney,p.totalNowNum,
            p.buyReason,p.clgManager,convert(varchar(10),p.clgManagerADate,120) clgManagerADate,p.leaderComments,p.leaderName,convert(varchar(10),p.leaderADate,120) leaderADate,
            p.processManID,p.processMan,convert(varchar(10),p.processDate,120) processDate,a.aName,f.fName
	from eqpPlanInfo p left join fundSrc f on p.fCode = f.fCode
		 left join appDir a on p.aCode = a.aCode
go




