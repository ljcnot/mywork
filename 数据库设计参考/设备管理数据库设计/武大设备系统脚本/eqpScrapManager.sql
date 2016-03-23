use ydepdc211
/*
	武大设备管理信息系统-设备报废管理
	需求：
		1.设备报废流程：申请->审核->复核
		2.设备一旦提出报废申请就将该设备状态转入“待报废”；
		3.复核后将涉及的设备转入“已报废”；
	author:		卢苇
	CreateDate:	2010-11-28
	UpdateDate: 2011-1-19 by lw 复查数据库设计，增加大型设备明细字段，修改相应存储过程，增加设备状态维护
				modi by lw 2012-8-10将大型报废单和小型报废单的添加和更新过程分拆，将明细单的写入过程变成内部过程；
									增加长事务锁，增加单据创建人字段
*/


--1.设备报废单：
--注意：大型设备（价格超过10万元）一张单据一个设备
select * from sEquipmentScrapDetail 

--残值合计字段增加要做的数据转换：
	--处理小型报废单的合计残值：
select e.scrapNum, e.sumLeaveMoney, sum(d.leaveMoney) 
from equipmentScrap e left join sEquipmentScrapDetail d on e.scrapNum = d.scrapNum
where e.isBigEquipment = 0
group by e.scrapNum, e.sumLeaveMoney, d.scrapNum

update equipmentScrap
set sumLeaveMoney = t.total
from equipmentScrap e left join 
	(select scrapNum, sum(leaveMoney) total from sEquipmentScrapDetail group by scrapNum) as t on e.scrapNum = t.scrapNum
where e.isBigEquipment = 0
	--处理大型报废单的合计残值：
update equipmentScrap
set sumLeaveMoney = b.leaveMoney
from equipmentScrap e left join bEquipmentScrapDetail b on e.scrapNum = b.scrapNum
where e.isBigEquipment = 1

select * from equipmentScrap where scrapNum='201312030002'
drop table equipmentScrap
CREATE TABLE equipmentScrap(
	scrapNum char(12) not null,			--主键：设备报废单号,使用2号号码发生器产生
											--8位日期代码+4位流水号
	applyState int default(0),			--设备报废单状态：0->新建，1->已发送，等待审核，2->已审核（一级），3->已处置（并已复核）
	replyState int default(0),			--处置结果：0->未处置，1->全部同意，2->部分同意，3->全部不同意。原字段：state
	--单据类型：	
	isBigEquipment int default(0),		--是否大型设备:0->小型设备，1->大型设备
	
	--申请报废单位：
	clgCode char(3) not null,			--学院代码
	clgName nvarchar(30) not null,		--学院名称：冗余字段，但是可以解释历史数据
	clgManager nvarchar(30) null,		--院别负责人：这是院部信息中定义的院部领导，冗余字段，但是可以解释历史数据
		--add by lw 2011-1-19
	uCode varchar(8) not null,			--使用单位代码,modi by lw 2011-2-11根据设备处要求延长编码长度！
	uName nvarchar(30) null,			--使用单位名称:冗余字段，但是可以保留历史名称
	
	--无法统一，所以删除！keeper nvarchar(30) null,			--保管人:冗余字段，但是可以保留历史名称
	
	applyManID varchar(10) null,		--申请人工号add by lw 2012-8-10
	applyMan nvarchar(30) null,			--申请人（原bgr[保管人]）
	applyDate smalldatetime not null,	--申请日期
	tel varchar(30) null,				--电话
	
	--统计信息：
	totalNum int default(0),			--总数量
	totalMoney numeric(15,2) default(0),--总金额（原值）
	sumLeaveMoney numeric(15,2) default(0),--残值合计：add by lw 2012-9-18

	--小型设备报废的经办情况（大型设备报废的复核情况，即设备主管部门意见）：
	processManID char(10) null,			--经办人ID（设备处人员——第一次审核人员）
	processMan nvarchar(30) null,		--经办人（设备处人员）
	processDesc nvarchar(300) null,		--处理意见（小型设备可不填）
	processDate smalldatetime null,		--经办人签署处理意见日期：现卡片上没有的字段，预留扩充
	--小型设备报废的复核情况（大型设备报废的审核意见）：
	eManagerID char(10) null,			--设备主管部门负责人ID（复核人员）
	eManager nvarchar(30) null,			--设备主管部门负责人
	scrapDesc nvarchar(300) null,		--设备主管部门意见,原czjg[处置结果]字段的含义
	scrapDate smalldatetime null,		--处置时间：现卡片上没有的字段，预留扩充

	notes nvarchar(200) null,			--备注

	--创建人：add by lw 2012-8-8为了保持操作的范围——个人的一致性增加的字段
	createManID varchar(10) null,		--创建人工号
	createManName varchar(30) null,		--创建人姓名
	createTime smalldatetime null,		--创建时间

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_equipmentScrap] PRIMARY KEY CLUSTERED 
(
	[scrapNum] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


--索引：
CREATE NONCLUSTERED INDEX [IX_equipmentScrap] ON [dbo].[equipmentScrap] 
(
	[isBigEquipment] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_equipmentScrap_1] ON [dbo].[equipmentScrap] 
(
	[scrapDate] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--2.小型设备报废明细单:
update sEquipmentScrapDetail
set scrapDesc='测试'
where isnull(scrapDesc,'')=''
select * from sEquipmentScrapDetail d left join equipmentList e on e.eCode=d.eCode
where e.eName is null
select * from equipmentList 
drop table sEquipmentScrapDetail
CREATE TABLE sEquipmentScrapDetail(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号
	scrapNum char(12) not null,			--外键：设备报废单号
	eCode char(8) not null,				--设备编号
	eName nvarchar(30) not null,		--设备名称：冗余字段，保证历史单据的完整性
	eModel nvarchar(20),				--设备型号：冗余字段，保证历史单据的完整性
	eFormat nvarchar(20),				--设备规格：冗余字段，保证历史单据的完整性
	oldEqpStatus char(1) null,			--原设备状态 add by lw 2011-10-15
	buyDate smalldatetime null,			--购置日期：冗余字段，保证历史单据的完整性
	eTypeCode char(8) not null,			--分类编号（教）最后4位不允许同时为“0”：冗余字段，保证历史单据的完整性
	eTypeName nvarchar(30),				--教育部分类名称:为了解决多对多的问题需要增加的字段：冗余字段，保证历史单据的完整性
	totalAmount numeric(12,2) not null,	--设备总价（原值）
	leaveMoney numeric(12,2) default(0),		--设备残值
	scrapDesc nvarchar(300) null,		--报废原因
	identifyDesc nvarchar(300) null,	--鉴定意见
	--lydate?
	processState int default(0),		--处理结果状态：0->不同意，1->同意，9->未定
 CONSTRAINT [PK_sEquipmentScrapDetail] PRIMARY KEY CLUSTERED 
(
	[scrapNum] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[sEquipmentScrapDetail] WITH CHECK ADD CONSTRAINT [FK_sEquipmentScrapDetail_equipmentScrap] FOREIGN KEY([scrapNum])
REFERENCES [dbo].[equipmentScrap] ([scrapNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[sEquipmentScrapDetail] CHECK CONSTRAINT [FK_sEquipmentScrapDetail_equipmentScrap]
GO


--3.大型设备报废明细表:
drop table bEquipmentScrapDetail
CREATE TABLE bEquipmentScrapDetail(
	scrapNum char(12) not null,			--外键：设备报废单号
	eCode char(8) not null,				--设备编号
	eName nvarchar(30) not null,		--设备名称：冗余字段，保证历史单据的完整性
	eModel nvarchar(20) not null,		--设备型号：冗余字段，保证历史单据的完整性
	eFormat nvarchar(20) not null,		--设备规格：冗余字段，保证历史单据的完整性
	oldEqpStatus char(1) null,			--原设备状态 add by lw 2011-10-15
	buyDate smalldatetime null,			--购置日期：冗余字段，保证历史单据的完整性
	eTypeCode char(8) not null,			--分类编号（教）最后4位不允许同时为“0”：冗余字段，保证历史单据的完整性
	eTypeName nvarchar(30) null,		--教育部分类名称:为了解决多对多的问题需要增加的字段：冗余字段，保证历史单据的完整性

	totalAmount numeric(12,2) not null,	--设备总价（原值）
	leaveMoney numeric(12,2) default(0),--设备残值：预备扩充字段！
	
	applyDesc nvarchar(300) null,		--报废原因（这是申请人填写，同主表的申请人、申请日期一起组成“报废原因”一栏）
	
	clgDesc nvarchar(300) null,			--所在单位意见（院部）意见
	clgManagerID varchar(10) null,		--所在单位负责人工号add by lw 2012-8-10
	clgManager nvarchar(30) null,		--所在单位负责人姓名
	mDate smalldatetime null,			--负责人签署意见日期：现卡片上没有的字段，预留扩充
	
	identifyDesc nvarchar(300) null,	--技术鉴定意见
	tManagerID varchar(10) null,		--鉴定人工号add by lw 2012-8-10
	tManager varchar(30) null,			--鉴定人
	tDate smalldatetime null,			--鉴定日期：现卡片上没有的字段，预留扩充
	
	gzwDesc nvarchar(300) null,			--国资委意见
	notificationNum nvarchar(20) null,	--国资处置通知书编号

 CONSTRAINT [PK_bEquipmentScrapDetail] PRIMARY KEY CLUSTERED 
(
	[scrapNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[bEquipmentScrapDetail] WITH CHECK ADD CONSTRAINT [FK_bEquipmentScrapDetail_equipmentScrap] FOREIGN KEY([scrapNum])
REFERENCES [dbo].[equipmentScrap] ([scrapNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[bEquipmentScrapDetail] CHECK CONSTRAINT [FK_bEquipmentScrapDetail_equipmentScrap]
GO

drop FUNCTION getEqpStatusBeforeScrap
/*
	name:		getEqpStatusBeforeScrap
	function:	0.1.获取设备报废前的状态
	input: 
				@eCode char(8)	--设备编号
	output: 
				return char(1)	--设备报废前的状态
	author:		卢苇
	CreateDate:	2012-9-18
	UpdateDate: 
*/
create FUNCTION getEqpStatusBeforeScrap
(  
	@eCode char(8)	--设备编号
)  
RETURNS char(1)
WITH ENCRYPTION
AS      
begin
	DECLARE @status char(1);
	--增加top 1的目的是避免多次报废的脏数据
	set @status = (select top 1 oldEqpStatus from sEquipmentScrapDetail where eCode = @eCode)
	if (@status is null)
		set @status = (select top 1 oldEqpStatus from bEquipmentScrapDetail where eCode = @eCode)
	if (@status is null)
		set @status = '9'	--其他：现状不详
	return @status
end
--测试：
select dbo.getEqpStatusBeforeScrap('00019951')

drop PROCEDURE addSmallScrapApply
/*
	name:		addSmallScrapApply
	function:	1.添加小型设备报废申请单
				注意：本存储过程自动锁定编辑，需要手工释放编辑锁！
	input: 
				--申请报废单位：
				@clgCode char(3),			--学院代码
				@uCode varchar(8),			--使用单位代码
				@applyManID varchar(10),	--申请人工号add by lw 2012-8-10
				@applyDate varchar(19),		--申请日期:采用ODBC格式存放的日期时间格式的字符串——"yyyy-MM-dd hh:mm:ss"
				@tel varchar(30),			--电话
				@scrapApplyDetail xml,		--使用xml存储的明细清单：N'<root>
																	--	<row id="1">
																	--		<eCode>10000014</eCode>
																	--		<leaveMoney>0</leaveMoney>
																	--		<scrapDesc>报废原因：损坏</scrapDesc>
																	--		<identifyDesc>经手人意见：同意</identifyDesc>
																	--		<processState>1</processState>
																	--	</row>
																	--	<row id="2">
																	--		<eCode>10000015</eCode>
																	--		<leaveMoney>200.01</leaveMoney>
																	--		<scrapDesc>报废原因：损坏</scrapDesc>
																	--		<identifyDesc>经手人意见：不同意</identifyDesc>
																	--		<processState>0</processState>
																	--	</row>
																	--	...
																	--</root>'
				
				@notes nvarchar(200),		--备注

				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output,	--操作成功标识：
										0:成功，
										1：要报废的设备有编辑锁或长事务锁，
										4:待报废设备清单中有设备不是“在用”现状，
										9：未知错误
				@createTime smalldatetime output,	--实际创建日期，这个日期与申请日期可以不同！
				@scrapNum char(12) output	--主键：报废单号，使用第 2 号号码发生器产生
	author:		卢苇
	CreateDate:	2010-11-28
	UpdateDate: 2011-1-19 by lw 增加申请日期\使用单位字段
				modi by lw 2011-2-11根据设备处要求延长编码长度！
				modi by lw 2012-8-10将大型设备报废单分拆出去，将明细单的写入过程变成内部过程,增加长事务锁处理，增加创建人字段，
									将申请人改成工号
*/
create PROCEDURE addSmallScrapApply
	--申请报废单位：
	@clgCode char(3),			--学院代码
	@uCode varchar(8),			--使用单位代码
	@applyManID varchar(10),	--申请人工号add by lw 2012-8-10
	@applyDate varchar(19),		--申请日期:采用ODBC格式存放的日期时间格式的字符串——"yyyy-MM-dd hh:mm:ss"
	@tel varchar(30),			--电话
	@scrapApplyDetail xml,		--使用xml存储的明细清单
	@notes nvarchar(200),		--备注

	@createManID varchar(10),	--创建人工号

	@Ret		int output,
	@createTime smalldatetime output,	--实际创建日期，这个日期与申请日期可以不同！
	@scrapNum char(12) output	--主键：报废单号，使用第 2 号号码发生器产生
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查报废的设备是否有编辑锁或长事务锁：
	declare @count int
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select cast(T.x.query('data(./eCode)') as char(8)) eCode
										from(select @scrapApplyDetail.query('/root/row') Col1) A
											OUTER APPLY A.Col1.nodes('/row') AS T(x)
										)
						  and (isnull(lockManID,'') <> '' or lock4LongTime <> 0))
	if (@count>0)
	begin
		set @Ret = 1
		return
	end
	
	--检查待报废设备清单中是否有非“在用”（“待修、待报废、已报废”）状态的设备：
	set @count = (select count(*)
					from (select cast(T.x.query('data(./eCode)') as char(8)) eCode
							from(select @scrapApplyDetail.query('/root/row') Col1) A
								OUTER APPLY A.Col1.nodes('/row') AS T(x)
						) as d left join equipmentList e on d.eCode = e.eCode
					where e.curEqpStatus not in ('1', '3'))
	if (@count > 0)
	begin
		set @Ret = 4
		return
	end


	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 2, 1, @curNumber output
	set @scrapNum = @curNumber

	--获取院别名称\负责人姓名\使用单位名称：
	declare @clgName nvarchar(30), @clgManager nvarchar(30)		--学院名称/院别负责人
	select @clgName = clgName, @clgManager = manager from college where clgCode = @clgCode
	declare @uName nvarchar(30)	--使用单位名称:冗余字段，但是可以保留历史名称
	if (@uCode <> '')
		set @uName = (select uName from useUnit where uCode = @uCode)
	else 
		set @uName = ''
		
	--取申请人姓名：
	declare @applyMan nvarchar(30)
	set @applyMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')
	
	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	--检查日期是否有效：
	if (@applyDate='')
		set @applyDate = convert(varchar(19), getdate(), 120)

	set @createTime = getdate()
	begin tran
		insert equipmentScrap(scrapNum, clgCode, clgName, clgManager, uCode, uName, 
								applyManID, applyMan, applyDate, tel, isBigEquipment, notes,
								lockManID, modiManID, modiManName, modiTime,
								createManID, createManName, createTime) 
		values (@scrapNum, @clgCode, @clgName, @clgManager, @uCode, @uName, 
								@applyManID, @applyMan, convert(smalldatetime, @applyDate, 120), @tel, 0, @notes,
								@createManID, @createManID, @createManName, @createTime,
								@createManID, @createManName, @createTime) 
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--插入明细表数据：
		insert sEquipmentScrapDetail(scrapNum, eCode, eName, eModel, eFormat, buyDate, eTypeCode, eTypeName, totalAmount,
									leaveMoney, scrapDesc, identifyDesc, processState, oldEqpStatus)
		select @scrapNum, d.eCode, e.eName, e.eModel, e.eFormat, e.buyDate, e.eTypeCode, e.eTypeName, e.totalAmount, 
				d.leaveMoney, d.scrapDesc, d.identifyDesc, d.processState, e.curEqpStatus
		from (select cast(T.x.query('data(./eCode)') as char(8)) eCode, cast(cast(T.x.query('data(./leaveMoney)') as varchar(13)) as numeric(12,2)) leaveMoney,
				cast(T.x.query('data(./scrapDesc)') as nvarchar(300)) scrapDesc, cast(T.x.query('data(./identifyDesc)') as nvarchar(300)) identifyDesc,
				cast(cast(T.x.query('data(./processState)') as varchar(10)) as int) processState
			from(select @scrapApplyDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
			) as d left join equipmentList e on d.eCode = e.eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		--设置待报废设备清单的现状：
		update equipmentList
		set curEqpStatus = '4',	--现状码：
									--1：在用，指正在使用的仪器设备；
									--2：多余，指具有使用价值而未使用的仪器设备；
									--3：待修，指待修或正在修理的仪器设备；
									--4：待报废：指已经失去使用价值，而未履行正式报废手续的仪器设备；
									--5：丢失，
									--6：报废，
									--7：调出，
									--8：降档，指金学校批准允许降档次使用、管理的仪器设备；
									--9：其他，现状不详的仪器设备。
				scrapNum = @scrapNum,	--对应的报废单号,add by lw 2011-05-16
				lock4LongTime = 3, lInvoiceNum=@scrapNum	--长事务锁
		where eCode in (select eCode from sEquipmentScrapDetail where scrapNum = @scrapNum)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--计算汇总信息：
		declare @totalNum int, @totalMoney numeric(15,2), @sumLeaveMoney numeric(15,2)	--总数量/总金额/残值合计
		select @totalNum = count(*), @totalMoney = sum(totalAmount), @sumLeaveMoney = SUM(leaveMoney)
		from sEquipmentScrapDetail 
		where scrapNum = @scrapNum
		
		--登记概要信息：
		update equipmentScrap 
		set totalNum = @totalNum, totalMoney = @totalMoney, sumLeaveMoney = @sumLeaveMoney
		where scrapNum = @scrapNum
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
	values(@createManID, @createManName, @createTime, '添加小型设备报废单', '系统根据用户' + @createManName + 
					'的要求添加了小型设备报废申请单[' + @scrapNum + ']。')
GO

drop PROCEDURE updateSmallScrapApplyInfo
/*
	name:		updateSmallScrapApplyInfo
	function:	2.更新小型设备报废单
	input: 
				@scrapNum char(12),			--主键：设备报废单号,使用号码发生器产生
														--8位日期代码+4位流水号
				--申请报废单位：
				@clgCode char(3),			--学院代码
				@uCode varchar(8),			--使用单位代码
				@applyManID varchar(10),	--申请人工号add by lw 2012-8-10
				@applyDate varchar(19),		--申请日期:采用ODBC格式存放的日期时间格式的字符串——"yyyy-MM-dd hh:mm:ss"
				@tel varchar(30),			--电话
				@scrapApplyDetail xml,		--使用xml存储的明细清单：N'<root>
																	--	<row id="1">
																	--		<eCode>10000014</eCode>
																	--		<leaveMoney>0</leaveMoney>
																	--		<scrapDesc>报废原因：损坏</scrapDesc>
																	--		<identifyDesc>经手人意见：同意</identifyDesc>
																	--		<processState>1</processState>
																	--	</row>
																	--	<row id="2">
																	--		<eCode>10000015</eCode>
																	--		<leaveMoney>200.01</leaveMoney>
																	--		<scrapDesc>报废原因：损坏</scrapDesc>
																	--		<identifyDesc>经手人意见：不同意</identifyDesc>
																	--		<processState>0</processState>
																	--	</row>
																	--	...
																	--</root>'
				
				@notes nvarchar(200),		--备注

				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前报废单正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0：成功，
							1：指定的小型报废单不存在，
							2：要更新的报废单正被别人锁定，
							3：该单据已经通过审核，不允许修改，
							4：要报废的设备有编辑锁或长事务锁，
							5：待报废设备清单中有设备不是“在用”或“待修”现状，
							6：该报废单中的设备正在清查，
							9：未知错误
	author:		卢苇
	CreateDate:	2010-11-28
	UpdateDate: 2011-1-19 by lw 增加申请日期\使用单位字段
				modi by lw 2011-2-11根据设备处要求延长编码长度！
				modi by lw 2012-8-10将明细表的更新包含在本过程内部，增加长事务锁处理，将申请人改成工号
				modi by lw 2013-5-27检查是否有叠加的设备清查事务锁！
*/
create PROCEDURE updateSmallScrapApplyInfo
	@scrapNum char(12),			--主键：设备报废单号,使用号码发生器产生
											--8位日期代码+4位流水号
	--申请报废单位：
	@clgCode char(3),			--学院代码
	@uCode varchar(8),			--使用单位代码
	@applyManID varchar(10),	--申请人工号add by lw 2012-8-10
	@applyDate varchar(19),		--申请日期:采用ODBC格式存放的日期时间格式的字符串——"yyyy-MM-dd hh:mm:ss"
	@tel varchar(30),			--电话
	@scrapApplyDetail xml,		--使用xml存储的明细清单：N'<root>
	
	@notes nvarchar(200),		--备注

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前报废单正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的报废单是否存在
	declare @count as int
	set @count=(select count(*) from equipmentScrap where scrapNum = @scrapNum and isBigEquipment=0)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	declare @applyState int
	declare @isBigEquipment int			--报废单类型（是否大型设备）:0->小型设备，1->大型设备
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState, @isBigEquipment = isBigEquipment
	from equipmentScrap 
	where scrapNum = @scrapNum
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态:
	if (@applyState <> 0)
	begin
		set @Ret = 3
		return
	end
	
	--检查原报废的设备是否有编辑锁或长事务锁（清查事务锁）：
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from sEquipmentScrapDetail where scrapNum = @scrapNum)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	if (@count>0)
	begin
		set @Ret = 6
		return
	end

	--检查报废的设备是否有编辑锁或长事务锁：
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select cast(T.x.query('data(./eCode)') as char(8)) eCode
										from(select @scrapApplyDetail.query('/root/row') Col1) A
											OUTER APPLY A.Col1.nodes('/row') AS T(x)
										)
						  and (isnull(lockManID,'') <> '' or (lock4LongTime <> 0 and not (lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	if (@count>0)
	begin
		set @Ret = 4
		return
	end

	--检查待报废设备清单中是否有非“在用或待修”（“待报废、已报废”）状态的设备：
	set @count = (select count(*)
					from (select cast(T.x.query('data(./eCode)') as char(8)) eCode
							from(select @scrapApplyDetail.query('/root/row') Col1) A
								OUTER APPLY A.Col1.nodes('/row') AS T(x)
						) as d left join equipmentList e on d.eCode = e.eCode
					where e.curEqpStatus not in ('1', '3') and d.eCode not in (select eCode from sEquipmentScrapDetail where scrapNum = @scrapNum))
	if (@count > 0)
	begin
		set @Ret = 5
		return
	end

	--检查日期是否有效：
	if (@applyDate='')
		set @applyDate = convert(varchar(19), getdate(), 120)
		
	--获取院别名称和负责人姓名：
	declare @clgName nvarchar(30), @rClgManager nvarchar(30)		--学院名称/院别负责人（院部信息中定义的领导）
	select @clgName = clgName, @rClgManager = manager from college where clgCode = @clgCode
	declare @uName nvarchar(30)	--使用单位名称:冗余字段，但是可以保留历史名称
	set @uName = (select uName from useUnit where uCode = @uCode)
	
	--取申请人姓名：
	declare @applyMan nvarchar(30)
	set @applyMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	begin tran
		update equipmentScrap 
		set clgCode = @clgCode, clgName = @clgName, clgManager = @rClgManager, uCode = @uCode, uName = @uName,
			applyManID = @applyManID, applyMan = @applyMan, applyDate = convert(smalldatetime, @applyDate, 120), tel = @tel, 
			isBigEquipment = @isBigEquipment, notes = @notes,
			--维护情况:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where scrapNum = @scrapNum
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--更新明细表：
		--恢复原待报废设备清单的现状：
		update equipmentList
		set curEqpStatus = s.oldEqpStatus,	--现状码：
									--1：在用，指正在使用的仪器设备；
									--2：多余，指具有使用价值而未使用的仪器设备；
									--3：待修，指待修或正在修理的仪器设备；
									--4：待报废：指已经失去使用价值，而未履行正式报废手续的仪器设备；
									--5：丢失，
									--6：报废，
									--7：调出，
									--8：降档，指金学校批准允许降档次使用、管理的仪器设备；
									--9：其他，现状不详的仪器设备。
				scrapNum = null,	--对应的报废单号,add by lw 2011-05-16
				lock4LongTime = 0, lInvoiceNum=''	--释放长事务锁
		from equipmentList e left join sEquipmentScrapDetail s on e.eCode = s.eCode and s.scrapNum = @scrapNum
		where e.eCode in (select eCode from sEquipmentScrapDetail where scrapNum = @scrapNum)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--更新待报废设备列表：
		delete sEquipmentScrapDetail where scrapNum = @scrapNum
		insert sEquipmentScrapDetail(scrapNum, eCode, eName, eModel, eFormat, buyDate, eTypeCode, eTypeName, totalAmount,
									leaveMoney, scrapDesc, identifyDesc, processState, oldEqpStatus)
		select @scrapNum, d.eCode, e.eName, e.eModel, e.eFormat, e.buyDate, e.eTypeCode, e.eTypeName, e.totalAmount, 
				d.leaveMoney, d.scrapDesc, d.identifyDesc, d.processState, e.curEqpStatus
		from (select cast(T.x.query('data(./eCode)') as char(8)) eCode, cast(cast(T.x.query('data(./leaveMoney)') as varchar(13)) as numeric(12,2)) leaveMoney,
				cast(T.x.query('data(./scrapDesc)') as nvarchar(300)) scrapDesc, 
				cast(T.x.query('data(./identifyDesc)') as nvarchar(300)) identifyDesc,
				cast(cast(T.x.query('data(./processState)') as varchar(10)) as int) processState
			from(select @scrapApplyDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
			) as d left join equipmentList e on d.eCode = e.eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
			
		--设置待报废设备清单的现状：
		update equipmentList
		set curEqpStatus = '4',	--现状码：
									--1：在用，指正在使用的仪器设备；
									--2：多余，指具有使用价值而未使用的仪器设备；
									--3：待修，指待修或正在修理的仪器设备；
									--4：待报废：指已经失去使用价值，而未履行正式报废手续的仪器设备；
									--5：丢失，
									--6：报废，
									--7：调出，
									--8：降档，指金学校批准允许降档次使用、管理的仪器设备；
									--9：其他，现状不详的仪器设备。
				scrapNum = @scrapNum,	--对应的报废单号,add by lw 2011-05-16
				lock4LongTime = 3, lInvoiceNum=@scrapNum	--长事务锁
		where eCode in (select eCode from sEquipmentScrapDetail where scrapNum = @scrapNum)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--计算汇总信息：
		declare @totalNum int, @totalMoney numeric(12,2), @sumLeaveMoney numeric(12,2)	--总数量/总金额/残值合计
		select @totalNum = count(*), @totalMoney = sum(totalAmount), @sumLeaveMoney = SUM(leaveMoney)
		from sEquipmentScrapDetail 
		where scrapNum = @scrapNum
		
		--登记概要信息：
		update equipmentScrap 
		set totalNum = @totalNum, totalMoney = @totalMoney, sumLeaveMoney = @sumLeaveMoney
		where scrapNum = @scrapNum
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
	values(@modiManID, @modiManName, @updateTime, '更新小型设备报废单', '用户' + @modiManName 
												+ '更新了小型设备报废单['+ @scrapNum +']。')
GO


drop PROCEDURE smallScrapInfoCheck1
/*
	name:		smallScrapInfoCheck1
	function:	3.审核小型设备报废单
	input: 
				@scrapNum char(12),			--主键：设备报废单号,使用号码发生器产生
														--8位日期代码+4位流水号
				@scrapApplyDetail xml,		--使用xml存储的明细清单：N'<root>
																	--	<row id="1">
																	--		<eCode>10000014</eCode>
																	--		<leaveMoney>0</leaveMoney>
																	--		<scrapDesc>报废原因：损坏</scrapDesc>
																	--		<identifyDesc>经手人意见：同意</identifyDesc>
																	--		<processState>1</processState>
																	--	</row>
																	--	<row id="2">
																	--		<eCode>10000015</eCode>
																	--		<leaveMoney>200.01</leaveMoney>
																	--		<scrapDesc>报废原因：损坏</scrapDesc>
																	--		<identifyDesc>经手人意见：不同意</identifyDesc>
																	--		<processState>0</processState>
																	--	</row>
																	--	...
																	--</root>'
				@processManID char(10),		--经办人ID（设备处人员——第一次审核人员）
				@processDesc nvarchar(300),	--处理意见（小型设备可不填）
				@processDate varchar(19),	--经办人签署处理意见日期：现卡片上没有的字段，预留扩充。采用ODBC格式存放的日期时间格式的字符串——"yyyy-MM-dd hh:mm:ss"

				@notes nvarchar(200),		--备注（可以连续更新）
				
				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前报废单正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，
							1：指定的小型报废单不存在，
							2：要审核的报废单正被别人锁定，
							3：该单据已经通过审核，不允许修改，
							6：该报废单中的设备正在清查，
							9：未知错误
	author:		卢苇
	CreateDate:	2010-11-28
	UpdateDate: 2011-1-19 by lw 增加“经办人签署处理意见日期”字段
				modi by lw 2011-12-16根据毕处的意见，大型设备报废的流程与小型设备报废的流程不一样，将大型设备报废的审核分拆出来！
				modi by lw 2012-8-10将更新明细表的过程合并到该过程内部
				modi by lw 2012-10-6修正了没有保存设备原状态的错误
				modi by lw 2013-5-27检查是否有叠加的设备清查事务锁！
*/
create PROCEDURE smallScrapInfoCheck1
	@scrapNum char(12),			--主键：设备报废单号,使用号码发生器产生
											--8位日期代码+4位流水号
	@scrapApplyDetail xml,		--使用xml存储的明细清单
	@processManID char(10),		--经办人ID（设备处人员——第一次审核人员）
	@processDesc nvarchar(300),	--处理意见处理意见（小型设备可不填）
	@processDate varchar(19),	--经办人签署处理意见日期：现卡片上没有的字段，预留扩充。采用ODBC格式存放的日期时间格式的字符串——"yyyy-MM-dd hh:mm:ss"

	@notes nvarchar(200),		--备注（可以连续更新）

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前报废单正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的报废单是否存在
	declare @count as int
	set @count=(select count(*) from equipmentScrap where scrapNum = @scrapNum and isBigEquipment=0)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	declare @applyState int
	declare @isBigEquipment int			--报废单类型（是否大型设备）:0->小型设备，1->大型设备
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState, @isBigEquipment = isBigEquipment
	from equipmentScrap 
	where scrapNum = @scrapNum
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态:
	if (@applyState >= 2)
	begin
		set @Ret = 3
		return
	end
	
	--检查报废的设备是否有编辑锁或长事务锁（清查事务锁）：
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from sEquipmentScrapDetail where scrapNum = @scrapNum)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	if (@count>0)
	begin
		set @Ret = 6
		return
	end

	--获取经办人人姓名：
	declare @processMan nvarchar(30)	--经办人（设备处人员）
	set @processMan = isnull((select cName from userInfo where jobNumber = @processManID),'')

	--检查日期是否有效：
	if (@processDate='')
		set @processDate = convert(varchar(19), getdate(), 120)

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	begin tran
		--更新明细列表的鉴定意见：不检测设备的编辑锁、长事务锁和设备状态
		--保存设备的原状态：
		declare @sTab as table (
			eCode char(8) not null,			--设备编号
			oldEqpStatus char(1) not null	--设备的原来状态
		)
		insert @sTab(eCode,oldEqpStatus)
		select eCode,oldEqpStatus
		from sEquipmentScrapDetail 
		where scrapNum = @scrapNum
		
		delete sEquipmentScrapDetail where scrapNum = @scrapNum
		insert sEquipmentScrapDetail(scrapNum, eCode, eName, eModel, eFormat, buyDate, eTypeCode, eTypeName, totalAmount,
									leaveMoney, scrapDesc, identifyDesc, processState,oldEqpStatus)
		select @scrapNum, d.eCode, e.eName, e.eModel, e.eFormat, e.buyDate, e.eTypeCode, e.eTypeName, e.totalAmount, 
				d.leaveMoney, d.scrapDesc, d.identifyDesc, d.processState,s.oldEqpStatus
		from (select cast(T.x.query('data(./eCode)') as char(8)) eCode, cast(cast(T.x.query('data(./leaveMoney)') as varchar(13)) as numeric(12,2)) leaveMoney,
				cast(T.x.query('data(./scrapDesc)') as nvarchar(300)) scrapDesc, cast(T.x.query('data(./identifyDesc)') as nvarchar(300)) identifyDesc,
				cast(cast(T.x.query('data(./processState)') as varchar(10)) as int) processState
			from(select @scrapApplyDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
			) as d left join equipmentList e on d.eCode = e.eCode left join @sTab s on e.eCode = s.eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--计算汇总信息：
		declare @totalNum int, @totalMoney numeric(15,2), @sumLeaveMoney numeric(15,2)	--总数量/总金额/残值合计
		select @totalNum = count(*), @totalMoney = sum(totalAmount), @sumLeaveMoney = SUM(leaveMoney)
		from sEquipmentScrapDetail 
		where scrapNum = @scrapNum and processState<>0
		--更新概要表：
		update equipmentScrap 
		set processManID = @processManID, processMan = @processMan, processDesc = @processDesc,
			processDate = convert(smalldatetime,@processDate,120), notes = @notes,
			applyState = 2,	--设备报废单状态：0->新建，1->已发送，等待审核，2->已审核（一级），3->已处置（并已复核）
			totalNum = @totalNum, totalMoney = @totalMoney, sumLeaveMoney = @sumLeaveMoney,
			--维护情况:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where scrapNum = @scrapNum
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
	values(@modiManID, @modiManName, @updateTime, '审核小型设备报废单', '用户' + @modiManName 
												+ '审核了小型设备报废单['+ @scrapNum +']。')
GO

drop PROCEDURE smallScrapInfoCheck2
/*
	name:		smallScrapInfoCheck2
	function:	4.复核小型设备报废单
				注意：这个存储过程同时也生效报废单
					  这个存储过程没有检测单据是否存在，所以要先行锁定！
					  这个存储过程只处理小型设备报废单的复核，大型设备报废单分拆出去了！
	input: 
				@scrapNum char(12),			--主键：设备报废单号,使用号码发生器产生
														--8位日期代码+4位流水号
				@scrapApplyDetail xml,		--使用xml存储的明细清单：N'<root>
																	--	<row id="1">
																	--		<eCode>10000014</eCode>
																	--		<leaveMoney>0</leaveMoney>
																	--		<scrapDesc>报废原因：损坏</scrapDesc>
																	--		<identifyDesc>经手人意见：同意</identifyDesc>
																	--		<processState>1</processState>
																	--	</row>
																	--	<row id="2">
																	--		<eCode>10000015</eCode>
																	--		<leaveMoney>200.01</leaveMoney>
																	--		<scrapDesc>报废原因：损坏</scrapDesc>
																	--		<identifyDesc>经手人意见：不同意</identifyDesc>
																	--		<processState>0</processState>
																	--	</row>
																	--	...
																	--</root>'
				@eManagerID char(10),		--设备处管理负责人ID
				@scrapDesc nvarchar(300),	--处置意见,原czjg[处置结果]字段的含义
				@scrapDate varchar(19),		--处置时间：现卡片上没有的字段，预留扩充。采用ODBC格式存放的日期时间格式的字符串——"yyyy-MM-dd hh:mm:ss"
							
				@notes nvarchar(200),		--备注

				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前报废单正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0：成功，
							1：指定的小型报废单不存在，
							2：要复核的报废单正被别人锁定，
							3：该单据已经通过复核（生效），不允许修改，
							4：意见签署不全，
							5：复核人与审核人不能相同，
							6：该单据还没有审核, 
							7：该报废单中的设备正在清查，
							9：未知错误
	author:		卢苇
	CreateDate:	2010-11-28
	UpdateDate: 2011-1-19 by lw 增加处置日期，设置处置结果，维护设备生命周期信息
				modi by lw 2011-2-11根据设备处要求延长编码长度！
				modi by lw 2011-5-16在制作筛选功能时发现构造where子句不方便，在设备清单中增加了“对应的报废单”字段而做的相应修改！
				modi by lw 2011-10-15增加设备生命周期表中的变动类型、变动凭证登记！明细表中登记了设备原状态，相应恢复设备原状态。
				modi by lw 2011-12-15根据设备处方堃和毕处的意见将大型设备报废单国资委签署意见移入复核阶段，因此将大型设备报废单的复核分拆出去。
									并增加了一个5，6号返回信息。
				modi by lw 2012-8-9将更新明细表包含在过程内部，增加长事务锁处理
				modi by lw 2012-10-6修正了没有保存设备原状态的错误
				modi by lw 2013-5-27检查是否有叠加的设备清查事务锁！
*/
create PROCEDURE smallScrapInfoCheck2
	@scrapNum char(12),			--主键：设备报废单号,使用号码发生器产生
											--8位日期代码+4位流水号
	@scrapApplyDetail xml,		--使用xml存储的明细清单
	@eManagerID char(10),		--设备处管理负责人ID
	@scrapDesc nvarchar(300),	--处置意见,原czjg[处置结果]字段的含义
	@scrapDate varchar(19),		--处置时间：现卡片上没有的字段，预留扩充
	
	@notes nvarchar(200),		--备注

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前报废单正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的报废单是否存在
	declare @count as int
	set @count=(select count(*) from equipmentScrap where scrapNum = @scrapNum and isBigEquipment=0)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)	--锁定人
	declare @applyState int				--单据状态
	declare @processManID char(10)		--审核人
	declare @isBigEquipment int			--报废单类型（是否大型设备）:0->小型设备，1->大型设备
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState, @processManID = processManID, @isBigEquipment = isBigEquipment
	from equipmentScrap where scrapNum = @scrapNum
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--检查单据状态:
	if (@applyState >= 3)
	begin
		set @Ret = 3
		return
	end
	else if (@applyState < 2)
	begin
		set @Ret = 6
		return
	end
	
	--检查复核人和审核人是否相同:
	if (@processManID = @eManagerID)
	begin
		set @Ret = 5
		return
	end
	
	--检查报废的设备是否有编辑锁或长事务锁（清查事务锁）：
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from sEquipmentScrapDetail where scrapNum = @scrapNum)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	if (@count>0)
	begin
		set @Ret = 7
		return
	end
	--获取复核人姓名：
	declare @eManager nvarchar(30)		--设备处管理负责人
	set @eManager = isnull((select cName from userInfo where jobNumber = @eManagerID),'')

	--检查日期是否有效：
	if (@scrapDate='')
		set @scrapDate = convert(varchar(19), getdate(), 120)

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()

	--生效报废单：
	declare @replyState int	--处置结果：0->未处置，1->全部同意，2->部分同意，3->全部不同意。原字段：state
	begin tran
		--更新明细列表的鉴定意见：不检测设备的编辑锁、长事务锁和设备状态
		--保存设备的原状态：
		declare @sTab as table (
			eCode char(8) not null,			--设备编号
			oldEqpStatus char(1) not null	--设备的原来状态
		)
		insert @sTab(eCode,oldEqpStatus)
		select eCode,oldEqpStatus
		from sEquipmentScrapDetail 
		where scrapNum = @scrapNum

		delete sEquipmentScrapDetail where scrapNum = @scrapNum
		insert sEquipmentScrapDetail(scrapNum, eCode, eName, eModel, eFormat, buyDate, eTypeCode, eTypeName, totalAmount,
									leaveMoney, scrapDesc, identifyDesc, processState, oldEqpStatus)
		select @scrapNum, d.eCode, e.eName, e.eModel, e.eFormat, e.buyDate, e.eTypeCode, e.eTypeName, e.totalAmount, 
				d.leaveMoney, d.scrapDesc, d.identifyDesc, d.processState, s.oldEqpStatus
		from (select cast(T.x.query('data(./eCode)') as char(8)) eCode, cast(cast(T.x.query('data(./leaveMoney)') as varchar(13)) as numeric(12,2)) leaveMoney,
				cast(T.x.query('data(./scrapDesc)') as nvarchar(300)) scrapDesc, cast(T.x.query('data(./identifyDesc)') as nvarchar(300)) identifyDesc,
				cast(cast(T.x.query('data(./processState)') as varchar(10)) as int) processState
			from(select @scrapApplyDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
			) as d left join equipmentList e on d.eCode = e.eCode left join @sTab s on e.eCode = s.eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--计算报废的范围：
		declare @rows int, @scrappedRows int
		set @rows = (select count(*) from sEquipmentScrapDetail where scrapNum = @scrapNum)
		set @scrappedRows = (select count(*) from sEquipmentScrapDetail where scrapNum = @scrapNum and processState = 1)
		--处置结果：0->未处置，1->全部同意，2->部分同意，3->全部不同意。原字段：state
		if (@scrappedRows = 0)
			set @replyState = 3
		else if (@scrappedRows = @rows)
			set @replyState = 1
		else
			set @replyState = 2
		
		--更新设备表：
		--确定报废的设备：
		update equipmentList
		set curEqpStatus = '6',	--设备现状码：
								--1：在用，指正在使用的仪器设备；
								--2：多余，指具有使用价值而未使用的仪器设备；
								--3：待修，指待修或正在修理的仪器设备；
								--4：待报废：指已经失去使用价值，而未履行正式报废手续的仪器设备；
								--5：丢失，
								--6：报废，
								--7：调出，
								--8：降档，指金学校批准允许降档次使用、管理的仪器设备；
								--9：其他，现状不详的仪器设备。
			scrapDate = @updateTime,--报废日期，原[ISDORE] [bit] NOT NULL,是已经确认报废，现改为使用报废日期
			scrapNum = @scrapNum,	--对应的报废单号,add by lw 2011-05-16
			lock4LongTime = 0, lInvoiceNum=''	--释放长事务锁
		where eCode in (select eCode 
						from sEquipmentScrapDetail 
						where scrapNum = @scrapNum and processState = 1)
		--本次不报废的设备恢复原状（在用）：
		update equipmentList
		set curEqpStatus = s.oldEqpStatus,		--现状码：
									--1：在用，指正在使用的仪器设备；
									--2：多余，指具有使用价值而未使用的仪器设备；
									--3：待修，指待修或正在修理的仪器设备；
									--4：待报废：指已经失去使用价值，而未履行正式报废手续的仪器设备；
									--5：丢失，
									--6：报废，
									--7：调出，
									--8：降档，指金学校批准允许降档次使用、管理的仪器设备；
									--9：其他，现状不详的仪器设备。
			scrapDate = null,	--报废日期，原[ISDORE] [bit] NOT NULL,是已经确认报废，现改为使用报废日期
			scrapNum = null,	--对应的报废单号,add by lw 2011-05-16
			lock4LongTime = 0, lInvoiceNum=''	--释放长事务锁
		from equipmentList e left join sEquipmentScrapDetail s on e.eCode = s.eCode and s.scrapNum = @scrapNum
		where e.eCode in (select eCode 
						from sEquipmentScrapDetail 
						where scrapNum = @scrapNum and processState <> 1)

		--登记设备生命周期信息：
		insert eqpLifeCycle(eCode,eName, eModel, eFormat,
			clgCode, clgName, uCode, uName, keeper,
			annexAmount, price, totalAmount,
			changeDate, changeDesc,changeType,changeInvoiceID) 
		select s.eCode, e.eName, e.eModel, e.eFormat,
				e.clgCode, clg.clgName, e.uCode, u.uName, e.keeper,
				e.annexAmount, e.price, e.totalAmount,
				@scrapDate, '设备报废','报废',@scrapNum
		from sEquipmentScrapDetail s left join equipmentList e on s.eCode = e.eCode 
				left join college clg on e.clgCode = clg.clgCode
				left join useUnit u on e.uCode = u.uCode
		where s.scrapNum = @scrapNum and s.processState = 1

		--计算汇总信息：
		declare @totalNum int, @totalMoney numeric(15,2), @sumLeaveMoney numeric(15,2)	--总数量/总金额/残值合计
		select @totalNum = count(*), @totalMoney = sum(totalAmount), @sumLeaveMoney = SUM(leaveMoney)
		from sEquipmentScrapDetail 
		where scrapNum = @scrapNum and processState<>0
		--更新报废单
		update equipmentScrap 
		set eManagerID = @eManagerID, eManager = @eManager, scrapDesc = @scrapDesc,
			scrapDate = convert(smalldatetime,@scrapDate,120), notes = @notes,
			applyState = 3,				--设备报废单状态：0->新建，1->已发送，等待审核，2->已审核（一级），3->已处置（并已复核）
			replyState = @replyState,	--处置结果：0->未处置，1->全部同意，2->部分同意，3->全部不同意。原字段：state
			totalNum = @totalNum, totalMoney = @totalMoney, sumLeaveMoney = @sumLeaveMoney,
			--维护情况:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where scrapNum = @scrapNum
		set @Ret = 0
	commit tran
	
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '复核小型设备报废单', '用户' + @modiManName 
												+ '复核并生效了小型报废单['+ @scrapNum +']。')
GO



drop PROCEDURE addBigScrapApply
/*
	name:		addBigScrapApply
	function:	5.添加大型设备报废申请单
				注意：本存储过程自动锁定编辑，需要手工释放编辑锁！
	input: 
				--申请报废单位：
				@clgCode char(3),			--学院代码
				@uCode varchar(8),			--使用单位代码
				@applyManID varchar(10),	--申请人工号add by lw 2012-8-10
				@applyDate varchar(19),		--申请日期:采用ODBC格式存放的日期时间格式的字符串——"yyyy-MM-dd hh:mm:ss"
				@tel varchar(30),			--电话
				@notes nvarchar(200),		--备注
				--明细表项目：
				@eCode char(8),				--设备编号
				@leaveMoney numeric(12,2),			--设备残值：预备扩充字段！
				@applyDesc nvarchar(300),	--报废原因（这是申请人填写，同主表的申请人、申请日期一起组成“报废原因”一栏）
				@clgDesc nvarchar(300),		--院别意见
				@clgManagerID varchar(10),	--所在单位负责人工号add by lw 2012-8-10
				@mDate varchar(19),			--负责人签署意见日期：现卡片上没有的字段，预留扩充。采用ODBC格式存放的日期时间格式的字符串——"yyyy-MM-dd hh:mm:ss"
				@identifyDesc nvarchar(300),--鉴定意见
				@tManagerID varchar(10),	--鉴定人工号add by lw 2012-8-10
				@tDate varchar(19),			--鉴定日期：现卡片上没有的字段，预留扩充。采用ODBC格式存放的日期时间格式的字符串——"yyyy-MM-dd hh:mm:ss"

				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output,	--操作成功标识：
										0:成功，
										1：要报废的设备有编辑锁或长事务锁，
										4:待报废设备不是“在用”现状，
										9：未知错误
				@createTime smalldatetime output,	--实际创建日期，这个日期与申请日期可以不同！
				@scrapNum char(12) output	--主键：报废单号，使用第 2 号号码发生器产生
	author:		卢苇
	CreateDate:	2010-11-28
	UpdateDate: 2011-1-19 by lw 增加申请日期\使用单位字段
				modi by lw 2011-2-11根据设备处要求延长编码长度！
				modi by lw 2012-8-10将明细表的处理包含在本过程内部，增加长事务所处理，增加创建人字段，
									将申请人、院部负责人、鉴定人使用工号处理
*/
create PROCEDURE addBigScrapApply
	--申请报废单位：
	@clgCode char(3),			--学院代码
	@uCode varchar(8),			--使用单位代码
	@applyManID varchar(10),	--申请人工号add by lw 2012-8-10
	@applyDate varchar(19),		--申请日期:采用ODBC格式存放的日期时间格式的字符串——"yyyy-MM-dd hh:mm:ss"
	@tel varchar(30),			--电话
	@notes nvarchar(200),		--备注
	--明细表项目：
	@eCode char(8),				--设备编号
	@leaveMoney numeric(12,2),			--设备残值：预备扩充字段！
	@applyDesc nvarchar(300),	--报废原因（这是申请人填写，同主表的申请人、申请日期一起组成“报废原因”一栏）
	@clgDesc nvarchar(300),		--院别意见
	@clgManagerID varchar(10),	--所在单位负责人工号add by lw 2012-8-10
	@mDate varchar(19),			--负责人签署意见日期：现卡片上没有的字段，预留扩充。采用ODBC格式存放的日期时间格式的字符串——"yyyy-MM-dd hh:mm:ss"
	@identifyDesc nvarchar(300),--鉴定意见
	@tManagerID varchar(10),	--鉴定人工号add by lw 2012-8-10
	@tDate varchar(19),			--鉴定日期：现卡片上没有的字段，预留扩充。采用ODBC格式存放的日期时间格式的字符串——"yyyy-MM-dd hh:mm:ss"

	@createManID varchar(10),	--创建人工号

	@Ret		int output,
	@createTime smalldatetime output,	--实际创建日期，这个日期与申请日期可以不同！
	@scrapNum char(12) output	--主键：报废单号，使用第 2 号号码发生器产生
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查报废的设备是否有编辑锁或长事务锁：
	declare @count int
	set @count = (select COUNT(*) from equipmentList
					where eCode = @eCode
						  and (isnull(lockManID,'') <> '' or lock4LongTime <> 0))
	if (@count>0)
	begin
		set @Ret = 1
		return
	end
	--检查待报废设备清单中是否有非“在用”或“待修”（“待修、待报废、已报废”）状态的设备：
	declare @curEqpStatus char(1)
	set @curEqpStatus =(select curEqpStatus from equipmentList where eCode = @eCode)
	if (@curEqpStatus <> '1' and @curEqpStatus <> '3')
	begin
		set @Ret = 4
		return
	end

	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 2, 1, @curNumber output
	set @scrapNum = @curNumber

	--获取院别名称\负责人姓名\使用单位名称：
	declare @clgName nvarchar(30), @rClgManager nvarchar(30)		--学院名称/院别负责人（院部信息中登记的领导）
	select @clgName = clgName, @rClgManager = manager from college where clgCode = @clgCode
	declare @uName nvarchar(30)	--使用单位名称:冗余字段，但是可以保留历史名称
	if (@uCode <> '')
		set @uName = (select uName from useUnit where uCode = @uCode)
	else 
		set @uName = ''

	--取申请人、所在单位负责人、鉴定人姓名：
	declare @applyMan nvarchar(30), @clgManager nvarchar(30), @tManager varchar(30)
	set @applyMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')
	set @clgManager = isnull((select cName from userInfo where jobNumber = @clgManagerID),'')
	set @tManager = isnull((select cName from userInfo where jobNumber = @tManagerID),'')

	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	--检查日期是否有效：
	if (@applyDate='')
		set @applyDate = convert(varchar(19), getdate(), 120)

	set @createTime = getdate()
	begin tran 
		insert equipmentScrap(scrapNum, clgCode, clgName, clgManager, uCode, uName, 
								applyManID, applyMan, applyDate, tel, isBigEquipment, notes,
								lockManID, modiManID, modiManName, modiTime,
								createManID, createManName, createTime) 
		values (@scrapNum, @clgCode, @clgName, @rClgManager, @uCode, @uName, 
								@applyManID, @applyMan, convert(smalldatetime, @applyDate, 120), @tel, 1, @notes,
								@createManID, @createManID, @createManName, @createTime,
								@createManID, @createManName, @createTime) 
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--插入待报废设备列表：
		insert bEquipmentScrapDetail(scrapNum, eCode, eName, eModel, eFormat, buyDate, eTypeCode, eTypeName, totalAmount,
							leaveMoney, applyDesc, clgDesc, clgManagerID, clgManager, mDate, 
							identifyDesc, tManagerID, tManager, tDate,
							oldEqpStatus)
		select @scrapNum, eCode, eName, eModel, eFormat, buyDate, eTypeCode, eTypeName, totalAmount,
							@leaveMoney, @applyDesc, @clgDesc, @clgManagerID, @clgManager, convert(smalldatetime, @mDate, 120), 
							@identifyDesc, @tManagerID, @tManager, convert(smalldatetime, @tDate, 120),
							curEqpStatus
		from equipmentList 
		where eCode = @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--设置待报废设备清单的现状：
		update equipmentList
		set curEqpStatus = '4',		--现状码：
									--1：在用，指正在使用的仪器设备；
									--2：多余，指具有使用价值而未使用的仪器设备；
									--3：待修，指待修或正在修理的仪器设备；
									--4：待报废：指已经失去使用价值，而未履行正式报废手续的仪器设备；
									--5：丢失，
									--6：报废，
									--7：调出，
									--8：降档，指金学校批准允许降档次使用、管理的仪器设备；
									--9：其他，现状不详的仪器设备。
				scrapNum = @scrapNum,		--对应的报废单号,add by lw 2011-05-16
				lock4LongTime = 3, lInvoiceNum=@scrapNum	--长事务锁
		where eCode = @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--计算汇总信息：
		declare @totalMoney numeric(15,2)	--总金额
		select @totalMoney = totalAmount
		from equipmentList
		where eCode = @eCode
		
		--登记概要信息和维护信息：
		update equipmentScrap 
		set totalNum = 1, totalMoney = @totalMoney, sumLeaveMoney = @leaveMoney
		where scrapNum = @scrapNum
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
	values(@createManID, @createManName, @createTime, '添加大型设备报废单', '系统根据用户' + @createManName + 
					'的要求添加了大型设备报废申请单[' + @scrapNum + ']。')
GO


drop PROCEDURE updateBigScrapApplyInfo
/*
	name:		updateBigScrapApplyInfo
	function:	6.更新大型报废单
	input: 
				@scrapNum char(12),			--主键：设备报废单号,使用号码发生器产生
														--8位日期代码+4位流水号
				--申请报废单位：
				@clgCode char(3),			--学院代码
				@uCode varchar(8),			--使用单位代码
				@applyManID varchar(10),	--申请人工号add by lw 2012-8-10
				@applyDate varchar(19),		--申请日期:采用ODBC格式存放的日期时间格式的字符串——"yyyy-MM-dd hh:mm:ss"
				@tel varchar(30),			--电话
				@notes nvarchar(200),		--备注
				--明细表项目：
				@eCode char(8),				--设备编号：注意更新不允许变更设备！
				@leaveMoney numeric(12,2),			--设备残值：预备扩充字段！
				@applyDesc nvarchar(300),	--报废原因（这是申请人填写，同主表的申请人、申请日期一起组成“报废原因”一栏）
				@clgDesc nvarchar(300),		--院别意见
				@clgManagerID varchar(10),	--所在单位负责人工号add by lw 2012-8-10
				@mDate varchar(19),			--负责人签署意见日期：现卡片上没有的字段，预留扩充。采用ODBC格式存放的日期时间格式的字符串——"yyyy-MM-dd hh:mm:ss"
				@identifyDesc nvarchar(300),--鉴定意见
				@tManagerID varchar(10),	--鉴定人工号add by lw 2012-8-10
				@tDate varchar(19),			--鉴定日期：现卡片上没有的字段，预留扩充。采用ODBC格式存放的日期时间格式的字符串——"yyyy-MM-dd hh:mm:ss"

				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前报废单正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0：成功，
							1：指定的大型设备报废单不存在，
							2：要更新的报废单息正被别人锁定，
							3：该单据已经通过审核，不允许修改，
							6：该报废单中的设备正在清查，
							8：该报废单的设备明细记录被删除
							9：未知错误
	author:		卢苇
	CreateDate:	2010-11-28
	UpdateDate: 2011-1-19 by lw 增加申请日期\使用单位字段
				modi by lw 2011-2-11根据设备处要求延长编码长度！
				modi by lw 2012-8-10将明细表的处理包含在本过程内，增加涉及到的申请人、鉴定人等使用工号处理
				modi by lw 2013-5-27检查是否有叠加的设备清查事务锁！
*/
create PROCEDURE updateBigScrapApplyInfo
	@scrapNum char(12),			--主键：设备报废单号,使用号码发生器产生
											--8位日期代码+4位流水号
	--申请报废单位：
	@clgCode char(3),			--学院代码
	@uCode varchar(8),			--使用单位代码
	@applyManID varchar(10),	--申请人工号add by lw 2012-8-10
	@applyDate varchar(19),		--申请日期:采用ODBC格式存放的日期时间格式的字符串——"yyyy-MM-dd hh:mm:ss"
	@tel varchar(30),			--电话
	@notes nvarchar(200),		--备注
	--明细表项目：
	@eCode char(8),				--设备编号：注意更新不允许变更设备！
	@leaveMoney numeric(12,2),	--设备残值：预备扩充字段！
	@applyDesc nvarchar(300),	--报废原因（这是申请人填写，同主表的申请人、申请日期一起组成“报废原因”一栏）
	@clgDesc nvarchar(300),		--院别意见
	@clgManagerID varchar(10),	--所在单位负责人工号add by lw 2012-8-10
	@mDate varchar(19),			--负责人签署意见日期：现卡片上没有的字段，预留扩充。采用ODBC格式存放的日期时间格式的字符串——"yyyy-MM-dd hh:mm:ss"
	@identifyDesc nvarchar(300),--鉴定意见
	@tManagerID varchar(10),	--鉴定人工号add by lw 2012-8-10
	@tDate varchar(19),			--鉴定日期：现卡片上没有的字段，预留扩充。采用ODBC格式存放的日期时间格式的字符串——"yyyy-MM-dd hh:mm:ss"

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前报废单正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的报废单是否存在
	declare @count as int
	set @count=(select count(*) from equipmentScrap where scrapNum = @scrapNum and isBigEquipment=1)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	declare @applyState int
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState
	from equipmentScrap 
	where scrapNum = @scrapNum
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态:
	if (@applyState <> 0)
	begin
		set @Ret = 3
		return
	end

	--检查明细单据中的设备是否存在：
	set @count=(select count(*) from bEquipmentScrapDetail where scrapNum = @scrapNum and eCode=@eCode)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 8
		return
	end
	
	--检查日期是否有效：
	if (@applyDate='')
		set @applyDate = convert(varchar(19), getdate(), 120)
		
	--检查原报废的设备是否有编辑锁或长事务锁（清查事务锁）：
	set @count = (select COUNT(*) from equipmentList
					where eCode = @eCode
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	if (@count>0)
	begin
		set @Ret = 6
		return
	end

	--获取院别\使用单位名称：
	declare @clgName nvarchar(30),@rClgManager nvarchar(30)		--院部名称\院部领导
	select @clgName = clgName, @rClgManager = manager from college where clgCode = @clgCode
	declare @uName nvarchar(30)	--使用单位名称:冗余字段，但是可以保留历史名称
	set @uName = (select uName from useUnit where uCode = @uCode)
	
	--取申请人、所在单位负责人、鉴定人姓名：
	declare @applyMan nvarchar(30), @clgManager nvarchar(30), @tManager varchar(30)
	set @applyMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')
	set @clgManager = isnull((select cName from userInfo where jobNumber = @clgManagerID),'')
	set @tManager = isnull((select cName from userInfo where jobNumber = @tManagerID),'')

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	begin tran
		update equipmentScrap 
		set clgCode = @clgCode, clgName = @clgName, clgManager = @rClgManager, uCode = @uCode, uName = @uName,
			applyManID = @applyManID, applyMan = @applyMan, applyDate = convert(smalldatetime, @applyDate, 120), tel = @tel, 
			sumLeaveMoney = @leaveMoney,
			isBigEquipment = 1, notes = @notes,
			--维护情况:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where scrapNum = @scrapNum
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--更新明细表：
		update bEquipmentScrapDetail
		set leaveMoney = @leaveMoney, applyDesc = @applyDesc, 
			clgDesc = @clgDesc, clgManagerID=@clgManagerID, clgManager=@clgManager, mDate = convert(smalldatetime, @mDate, 120), 
			identifyDesc=@identifyDesc, tManagerID=@tManagerID, tManager=@tManager, tDate=convert(smalldatetime, @tDate, 120)
		where scrapNum = @scrapNum and eCode = @eCode
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
	values(@modiManID, @modiManName, @updateTime, '更新大型设备报废单', '用户' + @modiManName 
												+ '更新了大型设备报废单['+ @scrapNum +']。')
GO

drop PROCEDURE checkBigScrappedInfo
/*
	name:		checkBigScrappedInfo
	function:	7.审核大型设备报废单（填报设备主管部门意见）
	input: 
				@scrapNum char(12),			--主键：设备报废单号,使用号码发生器产生
														--8位日期代码+4位流水号
				@eManagerID char(10),		--设备处管理负责人ID
				@scrapDesc nvarchar(300),	--处置意见,原czjg[处置结果]字段的含义
				@scrapDate varchar(19),		--处置时间：现卡片上没有的字段，预留扩充。采用ODBC格式存放的日期时间格式的字符串——"yyyy-MM-dd hh:mm:ss"

				@notes nvarchar(200),		--备注（可以连续更新）
				
				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前报废单正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，
							1：指定的大型设备报废单不存在，
							2：要更新的报废单息正被别人锁定，
							3:该单据已经通过审核，不允许再次审核，
							6：该报废单中的设备正在清查，
							9：未知错误
	author:		卢苇
	CreateDate:	2011-12-16
	UpdateDate: modi by lw 2012-8-10增加了出错信息
				modi by lw 2013-5-27检查是否有叠加的设备清查事务锁！
*/
create PROCEDURE checkBigScrappedInfo
	@scrapNum char(12),			--主键：设备报废单号,使用号码发生器产生
											--8位日期代码+4位流水号
	@eManagerID char(10),		--设备处管理负责人ID
	@scrapDesc nvarchar(300),	--处置意见,原czjg[处置结果]字段的含义
	@scrapDate varchar(19),		--处置时间：现卡片上没有的字段，预留扩充。采用ODBC格式存放的日期时间格式的字符串——"yyyy-MM-dd hh:mm:ss"

	@notes nvarchar(200),		--备注（可以连续更新）

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前报废单正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的报废单是否存在
	declare @count as int
	set @count=(select count(*) from equipmentScrap where scrapNum = @scrapNum and isBigEquipment=1)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	declare @applyState int
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState from equipmentScrap where scrapNum = @scrapNum
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态:
	if (@applyState >= 2)
	begin
		set @Ret = 3
		return
	end
	
	--检查原报废的设备是否有编辑锁或长事务锁（清查事务锁）：
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from bEquipmentScrapDetail where scrapNum = @scrapNum)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	if (@count>0)
	begin
		set @Ret = 6
		return
	end

	--获取设备主管部门负责人姓名：
	declare @eManager nvarchar(30)
	set @eManager = isnull((select cName from userInfo where jobNumber = @eManagerID),'')

	--检查日期是否有效：
	if (@scrapDate='')
		set @scrapDate = convert(varchar(19), getdate(), 120)

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update equipmentScrap 
	set eManagerID = @eManagerID, eManager = @eManager, 
		scrapDesc = @scrapDesc, scrapDate = convert(smalldatetime,@scrapDate,120),
		notes = @notes,
		applyState = 2,	--设备报废单状态：0->新建，1->已发送，等待审核，2->已审核（一级），3->已处置（并已复核）
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where scrapNum = @scrapNum
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '审核大型设备报废单', '用户' + @modiManName 
												+ '审核了大型设备报废单['+ @scrapNum +']。')
GO


drop PROCEDURE recheckBigScrappedInfo
/*
	name:		recheckBigScrappedInfo
	function:	8.复核大型设备报废单
				注意：这个存储过程没有检测单据是否存在，所以要先行锁定！
					   本存储过程是从updateScrapCheck2Info中分拆而来。
	input: 
				@scrapNum char(12),			--主键：设备报废单号,使用号码发生器产生
														--8位日期代码+4位流水号
				@processManID char(10),		--经办人ID（设备处人员——第一次审核人员）
				@processDesc nvarchar(300),	--处理意见（小型设备可不填）
				@processDate varchar(19),	--经办人签署处理意见日期：现卡片上没有的字段，预留扩充。采用ODBC格式存放的日期时间格式的字符串——"yyyy-MM-dd hh:mm:ss"
							
				@gzwDesc nvarchar(300),		--国资委意见
				@notificationNum nvarchar(20),--国资处置通知书编号
				@notes nvarchar(200),		--备注

				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前报废单正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，
							1：指定的大型设备报废单不存在，
							2：要更新的报废单息正被别人锁定，
							3：该单据已经通过复核（生效），不允许再次复核，
							4：意见签署不全，
							5：复核人与审核人不能相同，
							6：该单据还没有审核, 
							7：该报废单中的设备正在清查，
							9：未知错误
	author:		卢苇
	CreateDate:	2011-12-15
	UpdateDate: modi by lw 2011-12-16根据毕处的意见，将处置意见放入复核过程！
				modi by lw 2012-8-10增加长事务锁的处理
				modi by lw 2013-5-27检查是否有叠加的设备清查事务锁！
*/
create PROCEDURE recheckBigScrappedInfo
	@scrapNum char(12),			--主键：设备报废单号,使用号码发生器产生
											--8位日期代码+4位流水号
	@processManID char(10),		--经办人ID（设备处人员——第一次审核人员）
	@processDesc nvarchar(300),	--处理意见（小型设备可不填）
	@processDate varchar(19),	--经办人签署处理意见日期：现卡片上没有的字段，预留扩充。采用ODBC格式存放的日期时间格式的字符串——"yyyy-MM-dd hh:mm:ss"
	
	@gzwDesc nvarchar(300),		--国资委意见
	@notificationNum nvarchar(20),--国资处置通知书编号
	@notes nvarchar(200),		--备注

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前报废单正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的报废单是否存在
	declare @count as int
	set @count=(select count(*) from equipmentScrap where scrapNum = @scrapNum and isBigEquipment=1)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)	--锁定人
	declare @applyState int				--单据状态
	declare @eManagerID char(10)		--审核人（设备主管部门负责人）
	--检查编辑锁：
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState, @eManagerID = eManagerID
	from equipmentScrap where scrapNum = @scrapNum
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态:
	if (@applyState >= 3)
	begin
		set @Ret = 3
		return
	end
	else if (@applyState < 2)
	begin
		set @Ret = 6
		return
	end
	--检查复核人和审核人是否相同:
	if (@processManID = @eManagerID)
	begin
		set @Ret = 5
		return
	end

	--检查原报废的设备是否有编辑锁或长事务锁（清查事务锁）：
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from bEquipmentScrapDetail where scrapNum = @scrapNum)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	if (@count>0)
	begin
		set @Ret = 6
		return
	end

	--获取复核人姓名：
	declare @processMan nvarchar(30)	--经办人（设备处人员）
	set @processMan = isnull((select cName from userInfo where jobNumber = @processManID),'')

	--检查日期是否有效：
	if (@processDate='')
		set @processDate = convert(varchar(19), getdate(), 120)

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()

	--生效报废单：
	begin tran
		declare @eCode char(8), @eName nvarchar(30), @eModel nvarchar(20), @eFormat nvarchar(20)	--设备编号/名称/型号/规格
		declare @clgCode char(3), @clgName nvarchar(30), @uCode varchar(8), @uName nvarchar(30), @keeper nvarchar(30)	--现隶属信息:院部/使用单位/保管人
		declare @annexAmount numeric(12,2), @price numeric(12,2), @totalAmount numeric(12,2)			--现值：附件金额/单价/总价
		--意见与签名字段：
		declare @applyDesc nvarchar(300), @clgDesc nvarchar(300), @clgManager nvarchar(30)	--报废原因/院别意见/院别负责人
		declare @identifyDesc nvarchar(300), @tManager varchar(30)		--鉴定意见/鉴定人/设备处意见
		declare @scrapDesc nvarchar(300)			--设备主管部门负责人、意见、处置时间：现卡片上没有的字段，预留扩充。采用ODBC格式存放的日期时间格式的字符串——"yyyy-MM-dd hh:mm:ss"
		
		select @eCode = s.eCode, @eName = e.eName, @eModel = e.eModel, @eFormat = e.eFormat,
				@clgCode = e.clgCode, @clgName = clg.clgName, @uCode = e.uCode, @uName = u.uName, @keeper = e.keeper,
				@annexAmount = e.annexAmount, @price = e.price, @totalAmount = e.totalAmount,
				@applyDesc = applyDesc, @clgDesc = clgDesc, @clgManager = clgManager, @identifyDesc = identifyDesc, @tManager = tManager
		from bEquipmentScrapDetail s left join equipmentList e on s.eCode = e.eCode 
				left join college clg on e.clgCode = clg.clgCode
				left join useUnit u on e.uCode = u.uCode
		where s.scrapNum = @scrapNum
		select @eManagerID = eManagerID, @scrapDesc = scrapDesc
		from equipmentScrap
		where scrapNum = @scrapNum
		
		--检查意见是否签署完备：
		if (rtrim(isnull(@applyDesc,'')) = '' or rtrim(isnull(@clgDesc,'')) = '' or rtrim(isnull(@clgManager,'')) = ''
			or rtrim(isnull(@identifyDesc,'')) = '' or rtrim(isnull(@tManager,'')) = '' 
			or rtrim(isnull(@gzwDesc,'')) = '' or rtrim(isnull(@notificationNum,'')) = ''
			or rtrim(isnull(@scrapDesc,'')) = '')
		begin
			set @Ret = 4
			rollback tran
			return
		end
		--更新设备表：
		update equipmentList
		set curEqpStatus = '6',	--设备现状码：
								--1：在用，指正在使用的仪器设备；
								--2：多余，指具有使用价值而未使用的仪器设备；
								--3：待修，指待修或正在修理的仪器设备；
								--4：待报废：指已经失去使用价值，而未履行正式报废手续的仪器设备；
								--5：丢失，
								--6：报废，
								--7：调出，
								--8：降档，指金学校批准允许降档次使用、管理的仪器设备；
								--9：其他，现状不详的仪器设备。
			scrapDate = convert(smalldatetime, @processDate,120),	--报废日期，原[ISDORE] [bit] NOT NULL,是已经确认报废，现改为使用报废日期
			scrapNum = @scrapNum,	--对应的报废单号,add by lw 2011-05-16
			lock4LongTime = 0, lInvoiceNum=''	--释放长事务锁
		where eCode = @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--登记设备生命周期信息：
		insert eqpLifeCycle(eCode,eName, eModel, eFormat,
			clgCode, clgName, uCode, uName, keeper,
			annexAmount, price, totalAmount,
			changeDate, changeDesc,changeType,changeInvoiceID) 
		values(@eCode, @eName, @eModel, @eFormat, 
			@clgCode, @clgName, @uCode, @uName, @keeper,
			@annexAmount, @price, @totalAmount,
			@processDate, '设备报废','报废',@scrapNum)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--更新报废单：
		update equipmentScrap 
		set processManID = @processManID, processMan = @processMan, processDesc = @processDesc, processDate = convert(smalldatetime,@processDate,120),
			notes = @notes,
			applyState = 3,				--设备报废单状态：0->新建，1->已发送，等待审核，2->已审核（一级），3->已处置（并已复核）
			replyState = 1,	--处置结果：0->未处置，1->全部同意，2->部分同意，3->全部不同意。原字段：state
			--维护情况:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where scrapNum = @scrapNum
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--更新报废明细单：
		update bEquipmentScrapDetail
		set gzwDesc = @gzwDesc, notificationNum = @notificationNum
		where scrapNum = @scrapNum
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
	values(@modiManID, @modiManName, @updateTime, '复核大型设备报废单', '用户' + @modiManName 
												+ '复核并生效了大型设备报废单['+ @scrapNum +']。')
GO

drop PROCEDURE queryScrapApplyLocMan
/*
	name:		queryScrapApplyLocMan
	function:	9.查询指定报废申请单是否有人正在编辑
	input: 
				@scrapNum char(12),			--报废单号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的报废单不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2010-11-28
	UpdateDate: 
*/
create PROCEDURE queryScrapApplyLocMan
	@scrapNum char(12),			--报废单号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from equipmentScrap where scrapNum = @scrapNum),'')
	set @Ret = 0
GO


drop PROCEDURE lockScrapApply4Edit
/*
	name:		lockScrapApply4Edit
	function:	10.锁定报废单编辑，避免编辑冲突
	input: 
				@scrapNum char(12),			--报废单号
				@lockManID varchar(10) output,	--锁定人，如果当前报废单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的报废单不存在，2:要锁定的报废单正在被别人编辑，
							3：该申请单已经被审核生效，不能编辑，
							6：该报废单中的设备正在清查，
							9：未知错误
	author:		卢苇
	CreateDate:	2010-11-28
	UpdateDate: modi by lw 2013-5-27检查是否有叠加的设备清查事务锁！
*/
create PROCEDURE lockScrapApply4Edit
	@scrapNum char(12),			--报废单号
	@lockManID varchar(10) output,	--锁定人，如果当前报废单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的报废单是否存在
	declare @count as int
	set @count=(select count(*) from equipmentScrap where scrapNum = @scrapNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @applyState int, @isBigEquipment int	--是否大型设备:0->小型设备，1->大型设备
	declare @thisLockMan varchar(10)
	--检查编辑锁：
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState, @isBigEquipment = isBigEquipment
	from equipmentScrap 
	where scrapNum = @scrapNum
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态:
	if (@applyState = 3)
	begin
		set @Ret = 3
		return
	end

	--检查报废的设备是否有编辑锁或长事务锁（清查事务锁）：
	if (@isBigEquipment=1)
		set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from bEquipmentScrapDetail where scrapNum = @scrapNum)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	else
		set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from sEquipmentScrapDetail where scrapNum = @scrapNum)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	if (@count>0)
	begin
		set @Ret = 6
		return
	end
	
	update equipmentScrap
	set lockManID = @lockManID 
	where scrapNum = @scrapNum
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定报废单编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了报废单['+ @scrapNum +']为独占式编辑。')
GO

drop PROCEDURE unlockScrapApplyEditor
/*
	name:		unlockScrapApplyEditor
	function:	11.释放报废单编辑锁
				注意：本过程不检查单据是否存在！
	input: 
				@scrapNum char(12),				--报废单号
				@lockManID varchar(10) output,	--锁定人，如果当前报废单正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-28
	UpdateDate: 
*/
create PROCEDURE unlockScrapApplyEditor
	@scrapNum char(12),				--报废单号
	@lockManID varchar(10) output,	--锁定人，如果当前报废单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from equipmentScrap where scrapNum = @scrapNum),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update equipmentScrap set lockManID = '' where scrapNum = @scrapNum
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
	values(@lockManID, @lockManName, getdate(), '释放报废单编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了报废单['+ @scrapNum +']的编辑锁。')
GO


drop PROCEDURE delScrapApply
/*
	name:		delScrapApply
	function:	12.删除指定的报废申请单
	input: 
				@scrapNum char(12),			--设备报废单号
				@delManID varchar(10) output,	--删除人，如果当前报废申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的报废申请单不存在，2：要删除的报废申请单正被别人锁定，3：该申请单已经被审核生效，不能删除，
							6：该报废单中的设备正在清查，
							9：未知错误
	author:		卢苇
	CreateDate:	2010-11-28
	UpdateDate: 2011-1-19 by lw 恢复设备现状码到“在用”
				modi by lw 2011-5-16在制作筛选功能时发现构造where子句不方便，在设备清单中增加了“对应的报废单”字段而做的相应修改！
				modi by lw 2011-10-15增加设备报废申请前状态，增加“待修”状态可以申请报废，相应修改本存储过程恢复状态到原状态！
				modi by lw 2012-8-10增加长事务锁处理
				modi by lw 2013-5-27检查是否有叠加的设备清查事务锁！
*/
create PROCEDURE delScrapApply
	@scrapNum char(12),			--设备报废单号
	@delManID varchar(10) output,	--删除人，如果当前报废申请单正在被人占用编辑则返回该人的工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的报废申请单是否存在
	declare @count as int
	set @count=(select count(*) from equipmentScrap where scrapNum = @scrapNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	declare @thisLockMan varchar(10)	--锁定人
	declare @applyState int, @isBigEquipment int	--是否大型设备:0->小型设备，1->大型设备
	--检查编辑锁：
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState, @isBigEquipment = isBigEquipment
	from equipmentScrap where scrapNum = @scrapNum
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态:
	if (@applyState <> 0)
	begin
		set @Ret = 3
		return
	end
	
	--检查报废的设备是否有编辑锁或长事务锁（清查事务锁）：
	if (@isBigEquipment=1)
		set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from bEquipmentScrapDetail where scrapNum = @scrapNum)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	else
		set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from sEquipmentScrapDetail where scrapNum = @scrapNum)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	if (@count>0)
	begin
		set @Ret = 6
		return
	end

	begin tran
		--恢复设备现状：
		if (@isBigEquipment = 0) --小型设备
			update equipmentList
			set curEqpStatus = s.oldEqpStatus,		--现状码：
										--1：在用，指正在使用的仪器设备；
										--2：多余，指具有使用价值而未使用的仪器设备；
										--3：待修，指待修或正在修理的仪器设备；
										--4：待报废：指已经失去使用价值，而未履行正式报废手续的仪器设备；
										--5：丢失，
										--6：报废，
										--7：调出，
										--8：降档，指金学校批准允许降档次使用、管理的仪器设备；
										--9：其他，现状不详的仪器设备。
					scrapNum = null,	--对应的报废单号,add by lw 2011-05-16
					lock4LongTime = 0, lInvoiceNum=''	--释放长事务锁
			from equipmentList e left join sEquipmentScrapDetail s on e.eCode = s.eCode and s.scrapNum = @scrapNum
			where e.eCode in (select eCode 
							from sEquipmentScrapDetail 
							where scrapNum = @scrapNum)
		else --大型设备
			update equipmentList
			set curEqpStatus = b.oldEqpStatus,		--现状码：
										--1：在用，指正在使用的仪器设备；
										--2：多余，指具有使用价值而未使用的仪器设备；
										--3：待修，指待修或正在修理的仪器设备；
										--4：待报废：指已经失去使用价值，而未履行正式报废手续的仪器设备；
										--5：丢失，
										--6：报废，
										--7：调出，
										--8：降档，指金学校批准允许降档次使用、管理的仪器设备；
										--9：其他，现状不详的仪器设备。
					scrapNum = null,	--对应的报废单号,add by lw 2011-05-16
					lock4LongTime = 0, lInvoiceNum=''	--释放长事务锁
			from equipmentList e left join bEquipmentScrapDetail b on e.eCode = b.eCode and b.scrapNum = @scrapNum
			where e.eCode in (select eCode from bEquipmentScrapDetail where scrapNum = @scrapNum)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		delete equipmentScrap where scrapNum = @scrapNum	--明细单会自动级联删除！
	commit tran
	set @Ret = 0
	
	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除报废申请单', '用户' + @delManName
												+ '删除了报废申请单['+ @scrapNum +']。')
GO

drop PROCEDURE cancelScrapCheck2
/*
	name:		cancelScrapCheck2
	function:	13.撤销报废单复核情况（审核情况二）
				注意：这个存储过程检查复核后是否有数据更动，如果有更动则返回出错信息！
					  本存储过程直接将报废单恢复到申请状态
	input: 
				@scrapNum char(12),			--主键：设备报废单号,使用号码发生器产生
														--8位日期代码+4位流水号
				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前报废单正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：指定的报废单不存在,2：要取消复核的报废单正被别人锁定，
							3：该单据不是已复核状态，
							4：该报废单中的设备已经变动，（有本项检查就不需要再检查设备的“在用”状态）
							5：该报废单中的设备正被人编辑或有长事务锁，
							9：未知错误
	author:		卢苇
	CreateDate:	2011-10-15
	UpdateDate: modi by lw 2011-11-29撤销报废的时候不检查“不同意”报废的设备的状态
				modi by lw 2011-12-16客户要求退回到上一步，并根据分拆大型设备报废单后相应调整
				modi by lw 2012-8-10增加长事务锁处理
				modi by lw 2013-5-27修订检查是否有叠加的设备清查事务锁的错误！
*/
create PROCEDURE cancelScrapCheck2
	@scrapNum char(12),			--主键：设备报废单号,使用号码发生器产生
											--8位日期代码+4位流水号
	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前报废单正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的报废单是否存在
	declare @count as int
	set @count=(select count(*) from equipmentScrap where scrapNum = @scrapNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)	--锁定人
	declare @applyState int				--单据状态
	declare @isBigEquipment int			--是否大型设备:0->小型设备，1->大型设备
	--检查编辑锁：
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState, @isBigEquipment = isBigEquipment
	from equipmentScrap where scrapNum = @scrapNum
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--检查单据状态:
	if (@applyState <> 3)
	begin
		set @Ret = 3
		return
	end
	
	--检查该报废单涉及的设备是否有编辑锁或长事务锁：
	if (@isBigEquipment = 0)	--小型设备报废单
		set @count = (select COUNT(*) from equipmentList
						where eCode in (select eCode from sEquipmentScrapDetail where scrapNum = @scrapNum)
							  and (isnull(lockManID,'') <> '' 
									or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	else
		set @count = (select COUNT(*) from equipmentList
						where eCode in (select eCode from bEquipmentScrapDetail where scrapNum = @scrapNum)
							  and (isnull(lockManID,'') <> '' 
									or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	if (@count>0)
	begin
		set @Ret = 5
		return
	end

	--逐个扫描检查生成的设备：检查报废后是否有变动
	declare @eCode char(8)
	if (@isBigEquipment = 0)	--小型设备报废单
	begin	
		declare tar cursor for
		select eCode from sEquipmentScrapDetail
		where scrapNum = @scrapNum and processState = 1
	end
	else	--大型设备报废单
	begin	
		declare tar cursor for
		select eCode from bEquipmentScrapDetail
		where scrapNum = @scrapNum
	end
	OPEN tar
	FETCH NEXT FROM tar INTO @eCode
	WHILE @@FETCH_STATUS = 0
	begin
		declare @lastChangeType varchar(10)
		declare @lastChangeInvoiceID varchar(30)
		select top 1 @lastChangeInvoiceID = changeInvoiceID, @lastChangeType = changeType 
		from eqpLifeCycle 
		where eCode = @eCode
		order by rowNum desc
		
		if (isnull(@lastChangeType,'')<>'报废' and isnull(@lastChangeInvoiceID,'')<>@scrapNum)	--有其他操作
		begin
			CLOSE tar
			DEALLOCATE tar
			set @Ret = 4
			return
		end
		FETCH NEXT FROM tar INTO @eCode
	end
	CLOSE tar
	DEALLOCATE tar
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()

	--取消生效报废单：
	begin tran
		if (@isBigEquipment = 1)	--大型设备报废单
		begin
			--更新设备表：
			update equipmentList
			set curEqpStatus = 4,		--现状码：
										--1：在用，指正在使用的仪器设备；
										--2：多余，指具有使用价值而未使用的仪器设备；
										--3：待修，指待修或正在修理的仪器设备；
										--4：待报废：指已经失去使用价值，而未履行正式报废手续的仪器设备；
										--5：丢失，
										--6：报废，
										--7：调出，
										--8：降档，指金学校批准允许降档次使用、管理的仪器设备；
										--9：其他，现状不详的仪器设备。
					scrapNum = null,	--对应的报废单号,add by lw 2011-05-16
					lock4LongTime = 3, lInvoiceNum=@scrapNum	--长事务锁
			where eCode = @eCode
		end
		else	--小型设备报废单
		begin
			--更新设备表：
			update equipmentList
			set curEqpStatus = 4,		--现状码：
										--1：在用，指正在使用的仪器设备；
										--2：多余，指具有使用价值而未使用的仪器设备；
										--3：待修，指待修或正在修理的仪器设备；
										--4：待报废：指已经失去使用价值，而未履行正式报废手续的仪器设备；
										--5：丢失，
										--6：报废，
										--7：调出，
										--8：降档，指金学校批准允许降档次使用、管理的仪器设备；
										--9：其他，现状不详的仪器设备。
					scrapNum = null,	--对应的报废单号,add by lw 2011-05-16
					lock4LongTime = 3, lInvoiceNum=@scrapNum	--长事务锁
			where eCode in (select eCode 
							from sEquipmentScrapDetail 
							where scrapNum = @scrapNum)

		end
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--删除设备生命周期表中的报废信息：
		delete eqpLifeCycle where changeInvoiceID= @scrapNum and changeType = '报废'

		if (@isBigEquipment=1)	--大型设备报废单
		begin
			update equipmentScrap 
			set applyState = 2,		--设备报废单状态：0->新建，1->已发送，等待审核，2->已审核（一级），3->已处置（并已复核）
				replyState = 0,		--处置结果：0->未处置，1->全部同意，2->部分同意，3->全部不同意。原字段：state
				processManID = '', processMan = '', processDesc = '', processDate = null,
				--维护情况:
				modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
			where scrapNum = @scrapNum
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    

			update bEquipmentScrapDetail
			set gzwDesc='', notificationNum = ''
			where scrapNum = @scrapNum
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
		end
		else	--小型设备报废单
		begin
			update equipmentScrap 
			set applyState = 2,		--设备报废单状态：0->新建，1->已发送，等待审核，2->已审核（一级），3->已处置（并已复核）
				replyState = 0,		--处置结果：0->未处置，1->全部同意，2->部分同意，3->全部不同意。原字段：state
				eManagerID = '', eManager = '', scrapDesc = '', scrapDate = null,
				--维护情况:
				modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
			where scrapNum = @scrapNum
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
	values(@modiManID, @modiManName, @updateTime, '取消复核报废单', '用户' + @modiManName 
												+ '取消了报废单['+ @scrapNum +']的复核。')
GO

drop PROCEDURE cancelScrapCheck1
/*
	name:		cancelScrapCheck1
	function:	14.撤销报废单审核情况
	input: 
				@scrapNum char(12),			--主键：设备报废单号,使用号码发生器产生
														--8位日期代码+4位流水号
				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前报废单正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，
							1：指定的报废单不存在,
							2：要取消审核的报废单正被别人锁定，
							3：该单据不是已审核状态，
							5：该报废单中的设备正被人编辑或有长事务锁，
							9：未知错误
	author:		卢苇
	CreateDate:	2011-10-15
	UpdateDate: modi by lw 2011-12-16分拆大型设备报废单后相应调整
				modi by lw 2013-5-27检查是否有叠加的设备清查事务锁！
*/
create PROCEDURE cancelScrapCheck1
	@scrapNum char(12),			--主键：设备报废单号,使用号码发生器产生
											--8位日期代码+4位流水号
	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前报废单正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的报废单是否存在
	declare @count as int
	set @count=(select count(*) from equipmentScrap where scrapNum = @scrapNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)	--锁定人
	declare @applyState int				--单据状态
	declare @isBigEquipment int			--是否大型设备:0->小型设备，1->大型设备
	--检查编辑锁：
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState, @isBigEquipment = isBigEquipment
	from equipmentScrap where scrapNum = @scrapNum
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态:
	if (@applyState <> 2)
	begin
		set @Ret = 3
		return
	end

	--检查该报废单涉及的设备是否有编辑锁或长事务锁：
	if (@isBigEquipment = 0)	--小型设备报废单
		set @count = (select COUNT(*) from equipmentList
						where eCode in (select eCode from sEquipmentScrapDetail where scrapNum = @scrapNum)
							  and (isnull(lockManID,'') <> '' 
									or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	else
		set @count = (select COUNT(*) from equipmentList
						where eCode in (select eCode from bEquipmentScrapDetail where scrapNum = @scrapNum)
							  and (isnull(lockManID,'') <> '' 
									or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	if (@count>0)
	begin
		set @Ret = 5
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()

	--生效取消报废单审核：
	begin tran
		if (@isBigEquipment=1)
		begin
			update equipmentScrap 
			set applyState = 0,				--设备报废单状态：0->新建，1->已发送，等待审核，2->已审核（一级），3->已处置（并已复核）
				replyState = 0,	--处置结果：0->未处置，1->全部同意，2->部分同意，3->全部不同意。原字段：state
				eManagerID ='', eManager = '', scrapDesc = '', scrapDate =null,
				--维护情况:
				modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
			where scrapNum = @scrapNum
		end
		else
		begin
			update equipmentScrap 
			set applyState = 0,				--设备报废单状态：0->新建，1->已发送，等待审核，2->已审核（一级），3->已处置（并已复核）
				replyState = 0,	--处置结果：0->未处置，1->全部同意，2->部分同意，3->全部不同意。原字段：state
				processManID = '', processMan = '', processDesc = '', processDate = null,
				--维护情况:
				modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
			where scrapNum = @scrapNum
		end
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
	values(@modiManID, @modiManName, @updateTime, '取消审核报废单', '用户' + @modiManName 
												+ '取消了报废单['+ @scrapNum +']的审核。')
GO


select scrapNum, convert(varchar(10),applyDate,120) as applyDate,case applyState when 0 then '' when 1 then '...' when 2 then '█' when 3 then '√' end applyState,
case replyState when 0 then '' when 1 then '√' when 2 then '≈' when 3 then '╳' end replyState,
clgCode, clgName, clgManager, uCode, uName, applyMan, tel,case isBigEquipment when 0 then '' when 1 then '√' end isBigEquipment,
totalNum, totalMoney,processManID, processMan, processDesc,convert(varchar(10),processDate,120) as processDate, eManagerID, eManager, scrapDesc,
convert(varchar(10),scrapDate,120) as scrapDate,notes 
from equipmentScrap where scrapNum='201101200017';
select scrapNum,eCode, eName, eModel, eFormat, eTypeCode, eTypeName,convert(varchar(10),buyDate,120) as buyDate,
totalAmount, leaveMoney,applyDesc, clgDesc, clgManager, convert(varchar(10), mDate, 120) as mDate,identifyDesc, tManager,
convert(varchar(10),tDate,120) as tDate, gzwDesc, notificationNum
from bEquipmentScrapDetail
where scrapNum='201101200017'






