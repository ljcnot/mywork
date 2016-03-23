use hustOA
/*
	强磁场中心办公系统-公文申请管理
	author:		卢苇
	CreateDate:	2012-12-27
	UpdateDate: 
*/
--0.公文附件库：公文附件采用独立设计，这样就支持多个附件 add by lw 2013-2-27
select * from docAttachment
drop TABLE docAttachment
CREATE TABLE docAttachment(
	applyID varchar(12) not null,					--公文编号
	rowNum bigint IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,
	
	aFilename varchar(128) null,					--原始文件名
	uidFilename varchar(128) not null,				--UID文件名
	fileSize bigint null,							--文件尺寸
	fileType varchar(10),							--文件类型
	uploadTime smalldatetime default(getdate()),	--上传日期
 CONSTRAINT [PK_docAttachment] PRIMARY KEY CLUSTERED 
(
	[applyID] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--原始文件名索引：
CREATE NONCLUSTERED INDEX [IX_docAttachment] ON [dbo].[docAttachment]
(
	[aFilename] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--文件类型索引：
CREATE NONCLUSTERED INDEX [IX_docAttachment_1] ON [dbo].[docAttachment]
(
	[fileType] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--1.请假条登记表：
select l.leaveRequestID, l.applyStatus, 
	convert(varchar(10),l.applyTime,120) applyTime, 
	l.applyManType, l.applyManID, l.applyMan, 
	convert(varchar(10),l.leaveStartTime,120) leaveStartTime, convert(varchar(10),l.leaveEndTime,120) leaveEndTime, 
	l.leaveReason
from leaveRequestInfo l
select l.leaveRequestID, l.applyStatus, convert(varchar(10),l.applyTime,120) applyTime, l.applyManType, l.applyManID, l.applyMan, convert(varchar(10),l.leaveStartTime,120) leaveStartTime, convert(varchar(10),l.leaveEndTime,120) leaveEndTime, l.leaveReason,convert(varchar(10),l.approveTime,120) approveTime,l.approveManID,l.approveMan,l.approveStatus from leaveRequestInfo l where l.leaveRequestID ='QJ20130110'

select * from leaveRequestInfo
update leaveRequestInfo
set applystatus = 0
delete leaveRequestInfo
drop table leaveRequestInfo
CREATE TABLE leaveRequestInfo(
	leaveRequestID varchar(10) not null,--主键：请假条编号,本系统使用第300号号码发生器产生（'QJ'+4位年份代码+4位流水号）,由工作流引擎提供号码
	applyStatus smallint default(0),	--单据状态：0->新建未发送，1->发送等待审批，9->审批完成，-1->退回：将批准状态分离，放入批复状态字段
	applyTime smalldatetime null,		--申请时间
	applyManType smallint null,			--请假人类别：1->教工，9->学生
	applyManID varchar(10) not null,	--请假人工号
	applyMan nvarchar(30) not null,		--请假人姓名。冗余设计
	
	leaveStartTime smalldatetime null,	--请假开始时间
	leaveEndTime smalldatetime null,	--请假结束时间
	leaveReason nvarchar(300) null,		--请假事由
	--attachment varchar(128) null,			--附件文件名	del by lw2013-2-27附件采用集中设计，支持多个附件
	
	--批复状态：完整的审批意见请查阅工作流引擎add by lw 2013-2-27
	approveTime smalldatetime null,		--批准时间
	approveManID varchar(10) null,		--批准人工号
	approveMan nvarchar(30) null,		--批准人姓名：冗余设计
	approveStatus smallint null,		--批准状态：0->未知，1->批准，-1->不批准
 CONSTRAINT [PK_leaveRequestInfo] PRIMARY KEY CLUSTERED 
(
	[leaveRequestID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--请假人工号索引：
CREATE NONCLUSTERED INDEX [IX_leaveRequestInfo] ON [dbo].[leaveRequestInfo] 
(
	[applyManID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--请假人姓名索引：
CREATE NONCLUSTERED INDEX [IX_leaveRequestInfo_1] ON [dbo].[leaveRequestInfo] 
(
	[applyMan] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--批准人工号索引：
CREATE NONCLUSTERED INDEX [IX_leaveRequestInfo_2] ON [dbo].[leaveRequestInfo] 
(
	[approveManID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--批准人索引：
CREATE NONCLUSTERED INDEX [IX_leaveRequestInfo_3] ON [dbo].[leaveRequestInfo] 
(
	[approveMan] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

delete eqpApplyInfo
--2.设备采购申请表：
drop table eqpApplyInfo
CREATE TABLE eqpApplyInfo(
	eqpApplyID varchar(10) not null,	--主键：设备采购申请编号,本系统使用第301号号码发生器产生（'CG'+4位年份代码+4位流水号）,由工作流引擎提供号码
	applyStatus smallint default(0),	--单据状态：0->新建未发送，-1->驳回，1->发起人编辑，发送至部长审批，2->部长批准，发送至总工审批，
													--3->总工批准，发回发起人办理招标手续，
													--4->发起人填报招标信息，发送至总经济师审批
													--5->总经济师批准，发送至总经理审批
													--6->总经理审批
													--9->执行完成归档
	applyReason nvarchar(300) null,		--采购理由/用途
	
	applyManID varchar(10) not null,	--申请人工号
	applyMan nvarchar(30) not null,		--申请人姓名。冗余设计
	applyTime smalldatetime null,		--申请日期
	
	preSumQuantity int default(0),		--预计总台套数
	preSumMoney numeric(15,2) default(0),--预计总金额

	sumQuantity int default(0),			--总台套数
	sumMoney numeric(15,2) default(0),	--总金额

	tSumQuantity int default(0),		--招标总台套数
	tSumMoney numeric(15,2) default(0),	--招标总金额

	--招标情况：
	tenderInfo nvarchar(300) null,		--招标完成情况说明 add by lw 2013-2-28
	
	departManagerID varchar(10) null,	--部长工号
	departManager nvarchar(30) null,	--部长姓名。冗余设计
	dApproveTime smalldatetime null,	--批准时间
	departOpinion nvarchar(300) null,	--部长意见
	
	chiefEngineerID varchar(10) null,	--总工工号
	chiefEngineer nvarchar(30) null,	--总工姓名。冗余设计
	eApproveTime smalldatetime null,	--批准时间
	chiefEngineerOpinion nvarchar(300) null,	--总工意见
	
	chiefEconomistID varchar(10) null,	--总经济师工号
	chiefEconomist nvarchar(30) null,	--总经济师姓名。冗余设计
	ecApproveTime smalldatetime null,	--批准时间
	chiefEconomistOpinion nvarchar(300) null,	--总经济师意见
	
	generalManagerID varchar(10) null,	--总经理工号
	generalManager nvarchar(30) null,	--总经理姓名
	gApproveTime smalldatetime null,	--批准时间
	generalManagerOpinion nvarchar(300) null,	--总经理意见
	
	remark nvarchar(300) null,			--备注

 CONSTRAINT [PK_eqpApplyInfo] PRIMARY KEY CLUSTERED 
(
	[eqpApplyID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--申请人工号索引：
CREATE NONCLUSTERED INDEX [IX_eqpApplyInfo] ON [dbo].[eqpApplyInfo] 
(
	[applyManID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--2.1采购申请设备明细表
drop TABLE eqpApplyDetail
CREATE TABLE eqpApplyDetail(
	eqpApplyID varchar(10) not null,	--外键/主键：设备采购申请编号
	rowNum int IDENTITY(1,1) NOT NULL,	--主键：序号
	
	--申请：
	preEqpCode nvarchar(30) not null,	--设备编号及概算书页码
	preEqpName nvarchar(60) not null,	--设备名称及型号
	prePrice numeric(12,2) null,		--预计单价（元）
	preQuantity int null,				--预计数量
	preTotalMoney numeric(15,2) default(0),--预计总价（元）
	
	--招标完成：
	business nvarchar(20) null,			--销售单位
	eqpName nvarchar(60) null,			--设备名称及型号
	price numeric(12,2) null,			--单价（元）
	quantity int null,					--数量
	totalMoney numeric(15,2) default(0),--总价（元）

 CONSTRAINT [PK_eqpApplyDetail] PRIMARY KEY CLUSTERED 
(
	[eqpApplyID] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[eqpApplyDetail] WITH CHECK ADD CONSTRAINT [FK_eqpApplyDetail_eqpApplyInfo] FOREIGN KEY([eqpApplyID])
REFERENCES [dbo].[eqpApplyInfo] ([eqpApplyID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[eqpApplyDetail] CHECK CONSTRAINT [FK_eqpApplyDetail_eqpApplyInfo]
GO


--3.论文发表申请表：
select t.thesisPublishApplyID, t.applyManID, t.applyMan, convert(varchar(10),t.applyTime,120) applyTime,
	t.elseAuthor, t.thesisTitle, t.summary, t.keys, t.prePeriodicalName,
	t.elseAuthorNum, t.agreeNum
from thesisPublishApplyInfo t

drop table thesisPublishApplyInfo
CREATE TABLE thesisPublishApplyInfo(
	thesisPublishApplyID varchar(10) not null,	--主键：论文发表申请编号,本系统使用第302号号码发生器产生（'WF'+4位年份代码+4位流水号）,由工作流引擎提供号码
	applyStatus smallint default(0),	--单据状态：0->新建未发送，-1->驳回，1->审批中，9->执行完成归档
	applyManID varchar(10) not null,	--申请人工号
	applyMan nvarchar(30) not null,		--申请人姓名。冗余设计
	applyTime smalldatetime null,		--申请日期
	elseAuthor xml,						--其他作者：采用N'<root><elseAuthor id="G201300001" name="程远"></elseAuthor></root>'格式存放
	thesisTitle nvarchar(40) null,		--论文题目
	summary nvarchar(300) null,			--内容简介
	keys nvarchar(30) null,				--关键字：多个关键字使用","分隔

	prePeriodicalName nvarchar(40) not null,--拟投杂志名称

	elseAuthorNum int null,				--其他作者人数
	agreeNum smallint default(0),		--同意总数：0->未知，-1：有反对，1~n：同意票数
	isCanPublish smallint default(0),	--表决结果：0->未知，1：同意发表，2：不同意发表
 CONSTRAINT [PK_thesisPublishApplyInfo] PRIMARY KEY CLUSTERED 
(
	[thesisPublishApplyID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--申请人工号索引：
CREATE NONCLUSTERED INDEX [IX_thesisPublishApplyInfo] ON [dbo].[thesisPublishApplyInfo] 
(
	[applyManID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--4.车间加工申请表：
drop table processApplyInfo
CREATE TABLE processApplyInfo(
	processApplyID varchar(10) not null,	--主键：车间加工申请编号,本系统使用第303号号码发生器产生（'JG'+4位年份代码+4位流水号）
	applyStatus smallint default(0),		--单据状态：0->新建未发送，1->发送等待审批，9->审批完成，-1->退回：将批准状态分离，放入批复状态字段
	applyManID varchar(10) not null,		--申请人工号
	applyMan nvarchar(30) not null,			--申请人姓名。冗余设计
	applyTime smalldatetime null,			--申请日期
	
	preCompletedTime smalldatetime null,	--期望完成时间
	applyReason nvarchar(300) null,			--申请理由
	--attachmentFile varchar(128) null,		--附件文件路径	del by lw 2013-3-2统一设计考虑附件

	processerID varchar(10) null,			--加工人工号
	processer nvarchar(30) null,			--加工人。冗余设计
	appointTime smalldatetime null,			--指派时间
	isCompleted smallint default(0),		--加工状态：0->未知，1->正在加工，9->完成, 10->无法完成
	completedTime smalldatetime null,		--完成时间
	completeIntro nvarchar(300) null,		--完成情况
 CONSTRAINT [PK_processApplyInfo] PRIMARY KEY CLUSTERED 
(
	[processApplyID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--申请人工号索引：
CREATE NONCLUSTERED INDEX [IX_processApplyInfo] ON [dbo].[processApplyInfo] 
(
	[applyManID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--5.其他申请表：
select * from otherApplyInfo
drop table otherApplyInfo
CREATE TABLE otherApplyInfo(
	otherApplyID varchar(10) not null,	--主键：其他申请编号,本系统使用第304号号码发生器产生（'QT'+4位年份代码+4位流水号）
	applyStatus smallint default(0),	--单据状态：0->新建未发送，-1->驳回，1->审批中，9->执行完成归档
	applyManID varchar(10) not null,	--申请人工号
	applyMan nvarchar(30) not null,		--申请人姓名。冗余设计
	applyTime smalldatetime null,		--申请日期
	
	title nvarchar(40) null,			--主题
	summary nvarchar(300) null,			--内容
	keys nvarchar(30) null,				--关键字：多个关键字使用","分隔

 CONSTRAINT [PK_otherApplyInfo] PRIMARY KEY CLUSTERED 
(
	[otherApplyID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--申请人工号索引：
CREATE NONCLUSTERED INDEX [IX_otherApplyInfo] ON [dbo].[otherApplyInfo] 
(
	[applyManID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


drop PROCEDURE addDocAttachment
/*
	name:		1.addDocAttachment
	function:	添加公文附件
				@applyID varchar(12),		--公文编号
				@aFilename varchar(128),	--原始文件名
				@uidFilename varchar(128),	--UID文件名
				@fileSize bigint,			--文件尺寸
				@fileType varchar(10),		--文件类型
	output: 
				@Ret		int output		--操作成功标识
										0:成功，9：未知错误
	author:		卢苇
	CreateDate:	2013-6-20
	UpdateDate: 
*/
create PROCEDURE addDocAttachment
	@applyID varchar(12),		--公文编号
	@aFilename varchar(128),	--原始文件名
	@uidFilename varchar(128),	--UID文件名
	@fileSize bigint,			--文件尺寸
	@fileType varchar(10),		--文件类型
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	insert docAttachment(applyID, aFilename, uidFilename, fileSize, fileType)
	values(@applyID, @aFilename, @uidFilename, @fileSize, @fileType)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
GO

drop PROCEDURE delDocAttachment
/*
	name:		delDocAttachment
	function:	2.删除指定公文指定UID的附件
	input: 
				@applyID varchar(12),		--公文编号
				@uidFilename varchar(128),	--UID文件名
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：指定的附件不存在，9：未知错误
	author:		卢苇
	CreateDate:	2013-6-20
	UpdateDate: 
*/
create PROCEDURE delDocAttachment
	@applyID varchar(12),		--公文编号
	@uidFilename varchar(128),	--UID文件名
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--判断指定的附件是否存在
	declare @count as int
	set @count=(select count(*) from docAttachment where applyID = @applyID and uidFilename = @uidFilename)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	delete docAttachment where applyID = @applyID and uidFilename = @uidFilename
	
	set @Ret = 0
GO


drop PROCEDURE addLeaveRequest
/*
	name:		addLeaveRequest
	function:	1.1.添加请假条信息
	input: 
				@leaveRequestID varchar(10),	--请假条编号
				@leaveStartTime varchar(19),	--请假开始时间：采用"yyyy-MM-dd hh:mm:ss"格式存放
				@leaveEndTime varchar(19),		--请假结束时间：采用"yyyy-MM-dd hh:mm:ss"格式存放
				@leaveReason nvarchar(300),		--请假事由

				@createManID varchar(10),		--创建人工号

	output: 
				@Ret		int output			--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output--添加时间
	author:		卢苇
	CreateDate:	2012-12-27
	UpdateDate: modi by lw 2013-1-20 采用工作流引擎，单号由引擎产生，锁由引擎管理，相应修改接口
*/
create PROCEDURE addLeaveRequest
	@leaveRequestID varchar(10),	--请假条编号
	@leaveStartTime varchar(19),	--请假开始时间：采用"yyyy-MM-dd hh:mm:ss"格式存放
	@leaveEndTime varchar(19),		--请假结束时间：采用"yyyy-MM-dd hh:mm:ss"格式存放
	@leaveReason nvarchar(300),		--请假事由

	@createManID varchar(10),		--创建人工号
	@Ret		int output,
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--取申请人的类型、姓名：
	declare @applyManType smallint, @createManName nvarchar(30)
	select @createManName = cName, @applyManType = manType from userInfo where jobNumber = @createManID
	
	set @createTime = getdate()
	insert leaveRequestInfo(leaveRequestID, applyTime, applyManType, applyManID, applyMan,
					leaveStartTime, leaveEndTime, leaveReason)
	values(@leaveRequestID, @createTime, @applyManType, @createManID, @createManName,
					@leaveStartTime, @leaveEndTime, @leaveReason)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '登记请假条', '系统根据用户' + @createManName + 
					'的要求登记请假条['+@leaveRequestID+']。')
GO

drop PROCEDURE updateLeaveRequest
/*
	name:		updateLeaveRequest
	function:	1.2.修改请假条信息
	input: 
				@leaveRequestID varchar(10),	--请假条编号
				@leaveStartTime varchar(19),	--请假开始时间：采用"yyyy-MM-dd hh:mm:ss"格式存放
				@leaveEndTime varchar(19),		--请假结束时间：采用"yyyy-MM-dd hh:mm:ss"格式存放
				@leaveReason nvarchar(300),		--请假事由

				@modiManID varchar(10) output,	--修改人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:要修改的请假条不存在，
							3：该请假条已经发送，不能编辑，
							4：该请假条已经批复，不能编辑，
							9:未知错误
				@modiTime smalldatetime output	--修改时间
	author:		卢苇
	CreateDate:	2012-12-27
	UpdateDate: modi by lw 2013-2-27 采用工作流引擎，锁由引擎管理，相应修改处理
*/
create PROCEDURE updateLeaveRequest
	@leaveRequestID varchar(10),	--请假条编号
	@leaveStartTime varchar(19),	--请假开始时间：采用"yyyy-MM-dd hh:mm:ss"格式存放
	@leaveEndTime varchar(19),		--请假结束时间：采用"yyyy-MM-dd hh:mm:ss"格式存放
	@leaveReason nvarchar(300),		--请假事由

	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要修改的请假条是否存在
	declare @count as int
	set @count=(select count(*) from leaveRequestInfo where leaveRequestID= @leaveRequestID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁和状态：
	declare @applyStatus smallint	--单据状态：0->新建未发送，1->发送等待审批，9->审批完成，-1->退回：将批准状态分离，放入批复状态字段
	select @applyStatus = applyStatus
	from leaveRequestInfo 
	where leaveRequestID= @leaveRequestID
	--判断状态：
	if (@applyStatus=1)
	begin
		set @Ret = 3
		return
	end
	else if (@applyStatus=9)
	begin
		set @Ret = 4
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	update leaveRequestInfo
	set leaveStartTime = @leaveStartTime, leaveEndTime = @leaveEndTime, leaveReason = @leaveReason,
		applyStatus = 0		--状态恢复到初始状态
	where leaveRequestID= @leaveRequestID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '修改请假条', '系统根据用户' + @modiManName + 
					'的要求修改了请假条['+@leaveRequestID+']。')
GO

drop PROCEDURE delLeaveRequest
/*
	name:		delLeaveRequest
	function:	1.3.删除指定的请假条
	input: 
				@leaveRequestID varchar(10),	--请假条编号
				@delManID varchar(10) output,	--删除人，如果当前请假条正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的请假条不存在，
							3：该请假条已经发送，不能删除，
							4：该请假条已经批复，不能删除，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-12-27
	UpdateDate: modi by lw 2013-2-27 采用工作流引擎，锁由引擎管理，相应修改处理

*/
create PROCEDURE delLeaveRequest
	@leaveRequestID varchar(10),	--请假条编号
	@delManID varchar(10) output,	--删除人，如果当前请假条正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的请假条是否存在
	declare @count as int
	set @count=(select count(*) from leaveRequestInfo where leaveRequestID= @leaveRequestID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁和状态：
	declare @applyStatus smallint	--单据状态：0->新建未发送，1->发送等待审批，9->审批完成，-1->退回：将批准状态分离，放入批复状态字段
	select @applyStatus = applyStatus
	from leaveRequestInfo 
	where leaveRequestID= @leaveRequestID
	--判断状态：
	if (@applyStatus=1)
	begin
		set @Ret = 3
		return
	end
	else if (@applyStatus=9)
	begin
		set @Ret = 4
		return
	end

	delete leaveRequestInfo where leaveRequestID= @leaveRequestID
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除请假条', '用户' + @delManName
												+ '删除了请假条['+@leaveRequestID+']。')

GO

drop PROCEDURE approvalLeaveRequest
/*
	name:		approvalLeaveRequest
	function:	1.4.批复请假条
	input: 
				@leaveRequestID varchar(10),		--请假条编号

				@approveManID varchar(10),			--批准人工号
				@approveStatus smallint,			--批复意见类型：0->未知，1->批准，-1->不批准
	output: 
				@Ret		int output				--操作成功标识
							0:成功，1：指定的请假条不存在，2：该请假条已经批复，9：未知错误
	author:		卢苇
	CreateDate:	2013-2-27
	UpdateDate: 
*/				
create PROCEDURE approvalLeaveRequest
	@leaveRequestID varchar(10),	--请假条编号
	@approveManID varchar(10),		--批准人工号
	@approveStatus smallint,		--批复意见类型：0->未知，1->批准，-1->不批准
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的请假条是否存在
	declare @count as int
	set @count=(select count(*) from leaveRequestInfo where leaveRequestID= @leaveRequestID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--获取单据基本信息，检查单据状态：
	declare @applyManID varchar(10), @applyMan nvarchar(30)	--请假申请人
	declare @applyStatus smallint	--单据状态：0->新建未发送，1->发送等待审批，9->审批完成，-1->退回：将批准状态分离，放入批复状态字段
	declare @leaveStartTime smalldatetime	--请假开始时间
	declare @leaveEndTime smalldatetime		--请假结束时间
	declare @leaveReason nvarchar(300)		--请假事由
	select @applyManID = applyManID, @applyMan = applyMan, @applyStatus = applyStatus, @leaveStartTime = leaveStartTime,
			@leaveEndTime = leaveEndTime, @leaveReason = leaveReason
	from leaveRequestInfo 
	where leaveRequestID= @leaveRequestID
	--判断状态：
	if (@applyStatus=9)
	begin
		set @Ret = 2
		return
	end

	--取批准人姓名：
	declare @approveMan nvarchar(30)			--批准人姓名
	select @approveMan = cName from userInfo where jobNumber=@approveManID
	
	--批准时间：
	declare @approveTime smalldatetime
	set @approveTime = GETDATE()
	begin tran	
		update leaveRequestInfo
		set applyStatus = 9,				--单据状态：0->新建未发送，1->发送等待审批，9->审批完成，-1->退回：将批准状态分离，放入批复状态字段
			--批复状态：
			approveTime = @approveTime,		--批准时间
			approveManID = @approveManID,	--批准人工号
			approveMan = @approveMan,		--批准人姓名：冗余设计
			approveStatus = @approveStatus	--批准状态：0->未知，1->批准，-1->不批准
		where leaveRequestID = @leaveRequestID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    
		if (@approveStatus=1)
		begin
			--登记勤务状态：
			declare @runRet int
			declare @createTime smalldatetime	--添加时间
			declare @rowNum int		--内部行号

			exec dbo.addDutyStatusInfo @applyManID, 2, @leaveStartTime, @leaveEndTime, @leaveReason, @applyManID, 
					@runRet output, @createTime output, @rowNum output
			if @runRet = 9
			begin
				rollback tran
				set @Ret = 9
				return
			end  
		end  
	commit tran
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@approveManID, @approveMan, @approveTime, '批复请假条', '用户' + @applyMan
												+ '批准了['+@applyMan+']的请假条['+@leaveRequestID+']。')

GO

drop PROCEDURE setLeaveRequestStatus
/*
	name:		setLeaveRequestStatus
	function:	1.5.设置请假条状态
				注意：这个过程没有登记工作日志
	input: 
				@leaveRequestID varchar(10),		--请假条编号
				@applyStatus smallint,				--单据状态：0->新建未发送，1->发送等待审批，9->审批完成，-1->退回：将批准状态分离，放入批复状态字段
	output: 
				@Ret		int output				--操作成功标识
							0:成功，1：指定的请假条不存在，2：该请假条已经批复，9：未知错误
	author:		卢苇
	CreateDate:	2013-2-27
	UpdateDate: 
*/				
create PROCEDURE setLeaveRequestStatus
	@leaveRequestID varchar(10),	--请假条编号
	@applyStatus smallint,			--单据状态：0->新建未发送，1->发送等待审批，9->审批完成，-1->退回：将批准状态分离，放入批复状态字段
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的请假条是否存在
	declare @count as int
	set @count=(select count(*) from leaveRequestInfo where leaveRequestID= @leaveRequestID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--获取单据基本信息，检查单据状态：
	declare @applyOldStatus smallint			--单据状态：0->新建未发送，1->发送等待审批，9->审批完成，-1->退回：将批准状态分离，放入批复状态字段
	select @applyOldStatus = applyStatus
	from leaveRequestInfo 
	where leaveRequestID= @leaveRequestID
	--判断状态：
	if (@applyOldStatus=9)
	begin
		set @Ret = 2
		return
	end

	update leaveRequestInfo
	set applyStatus = @applyStatus				--单据状态：0->新建未发送，1->发送等待审批，9->审批完成，-1->退回：将批准状态分离，放入批复状态字段
	where leaveRequestID = @leaveRequestID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0
GO

drop PROCEDURE sendLeaveRequest
drop PROCEDURE cancelSendLeaveRequest
drop PROCEDURE approveLeaveRequest

--请假条查询语句：
select l.leaveRequestID, l.applyStatus, 
	convert(varchar(10),l.applyTime,120) applyTime, 
	l.applyManType, l.applyManID, l.applyMan, 
	convert(varchar(10),l.leaveStartTime,120) leaveStartTime, convert(varchar(10),l.leaveEndTime,120) leaveEndTime, 
	l.leaveReason
from leaveRequestInfo l



drop PROCEDURE addEqpApplyInfo
/*
	name:		addEqpApplyInfo
	function:	2.1.添加设备采购申请
	input: 
				@eqpApplyID varchar(10),	--设备采购申请编号,本系统使用第301号号码发生器产生（'CG'+4位年份代码+4位流水号）,有工作流引擎预生成
				@applyReason nvarchar(300),	--采购理由/用途
				@eqpApplyDetail xml,		--计划采购设备明细 N'<root>
																--	<row id="1">
																--		<preEqpCode>10000014，概算书P1</preEqpCode>
																--		<preEqpName>继电器5000W</preEqpName>
																--		<prePrice>10000.00</prePrice>
																--		<preQuantity>2</preQuantity>
																--	</row>
																--	<row id="2">
																--		<preEqpCode>10000015，概算书P2</preEqpCode>
																--		<preEqpName>继电器3000W</preEqpName>
																--		<prePrice>8000.00</prePrice>
																--		<preQuantity>9</preQuantity>
																--	</row>
																--	...
																--</root>'
				
				@applyManID varchar(10),	--申请人工号
				@applyTime varchar(10),		--申请日期
				@remark nvarchar(300),		--备注

				@createManID varchar(10),	--创建人工号

	output: 
				@Ret		int output		--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output--添加时间
	author:		卢苇
	CreateDate:	2012-12-28
	UpdateDate: modi by lw 2013-2-28 采用工作流引擎，单号由引擎产生，锁由引擎管理，相应修改接口
*/
create PROCEDURE addEqpApplyInfo
	@eqpApplyID varchar(10),	--设备采购申请编号,本系统使用第301号号码发生器产生（'CG'+4位年份代码+4位流水号）,有工作流引擎预生成
	@applyReason nvarchar(300),	--采购理由/用途
	@eqpApplyDetail xml,		--计划采购设备明细
	@applyManID varchar(10),	--申请人工号
	@applyTime varchar(10),		--申请日期
	@remark nvarchar(300),		--备注

	@createManID varchar(10),	--创建人工号
	@Ret		int output,
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--取申请人、创建人的姓名：
	declare @applyMan nvarchar(30), @createManName nvarchar(30)
	set @applyMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	begin tran
		insert eqpApplyInfo(eqpApplyID, applyReason, applyManID, applyMan, applyTime, remark)
		values(@eqpApplyID, @applyReason, @applyManID, @applyMan, @applyTime, @remark)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--插入明细表数据：
		insert eqpApplyDetail(eqpApplyID, preEqpCode, preEqpName, prePrice, preQuantity, preTotalMoney)
		select @eqpApplyID, preEqpCode, preEqpName, prePrice, preQuantity, prePrice * preQuantity 
		from (select cast(T.x.query('data(./preEqpCode)') as nvarchar(30)) preEqpCode, 
				cast(T.x.query('data(./preEqpName)') as nvarchar(60)) preEqpName,
				cast(cast(T.x.query('data(./prePrice)') as varchar(13)) as numeric(12,2)) prePrice,
				cast(cast(T.x.query('data(./preQuantity)') as varchar(8)) as int) preQuantity
			from(select @eqpApplyDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
				) as tab
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		--更新总计：
		declare @preSumQuantity int, @preSumMoney numeric(15,2)
		set @preSumQuantity = isnull((select SUM(preQuantity) from eqpApplyDetail where eqpApplyID = @eqpApplyID),0)
		set @preSumMoney = isnull((select SUM(preTotalMoney) from eqpApplyDetail where eqpApplyID = @eqpApplyID),0)
		update eqpApplyInfo
		set preSumQuantity = @preSumQuantity, preSumMoney = @preSumMoney
		where eqpApplyID = @eqpApplyID
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
	values(@createManID, @createManName, @createTime, '登记设备采购申请', '系统根据用户' + @createManName + 
					'的要求登记设备采购申请['+@eqpApplyID+']。')
GO
--测试：
declare @Ret		int
declare @createTime smalldatetime
declare @eqpApplyID varchar(10) 
declare @eqpApplyDetail xml		--计划采购设备明细 
set @eqpApplyDetail =N'<root>
						<row id="1">
							<preEqpCode>10000014，概算书P1</preEqpCode>
							<preEqpName>继电器5000W</preEqpName>
							<prePrice>10000.00</prePrice>
							<preQuantity>2</preQuantity>
						</row>
						<row id="2">
							<preEqpCode>10000015，概算书P2</preEqpCode>
							<preEqpName>继电器3000W</preEqpName>
							<prePrice>8000.00</prePrice>
							<preQuantity>9</preQuantity>
						</row>
						...
					</root>'
exec dbo.addEqpApplyInfo '测试',@eqpApplyDetail, '00001', '2012-12-28', '备注测试','00001', @Ret output, @createTime output, @eqpApplyID output
select @Ret

select * from eqpApplyDetail
select * from eqpApplyInfo



drop PROCEDURE updateEqpApplyInfo
/*
	name:		updateEqpApplyInfo
	function:	2.2.修改设备采购申请书
	input: 
				@eqpApplyID varchar(10),	--设备采购申请编号
				@applyReason nvarchar(300),	--采购理由/用途
				@eqpApplyDetail xml,		--计划采购设备明细
				@applyManID varchar(10),	--申请人工号
				@applyTime varchar(10),		--申请日期
				@remark nvarchar(300),		--备注

				@modiManID varchar(10) output,	--修改人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:要修改的设备采购申请不存在，
							3:该设备采购申请已经进入审批环节，不能编辑，
							9:未知错误
				@modiTime smalldatetime output	--修改时间
	author:		卢苇
	CreateDate:	2012-12-28
	UpdateDate: modi by lw 2013-2-28 采用工作流引擎，锁由引擎管理，相应修改接口
*/
create PROCEDURE updateEqpApplyInfo
	@eqpApplyID varchar(10),	--设备采购申请编号
	@applyReason nvarchar(300),	--采购理由/用途
	@eqpApplyDetail xml,		--计划采购设备明细
	@applyManID varchar(10),	--申请人工号
	@applyTime varchar(10),		--申请日期
	@remark nvarchar(300),		--备注

	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要修改的设备采购申请是否存在
	declare @count as int
	set @count=(select count(*) from eqpApplyInfo where eqpApplyID= @eqpApplyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查单据状态：
	declare @applyStatus smallint	----单据状态：0->新建未发送，-1->驳回，1->发起人编辑，发送至部长审批，2->部长批准，发送至总工审批，
													--3->总工批准，发回发起人办理招标手续，
													--4->发起人填报招标信息，发送至总经济师审批
													--5->总经济师批准，发送至总经理审批
													--6->总经理审批
													--9->执行完成归档
	select @applyStatus = applyStatus
	from eqpApplyInfo 
	where eqpApplyID= @eqpApplyID
	--判断状态：
	if (@applyStatus not in (0,-1))
	begin
		set @Ret = 3
		return
	end

	--取申请人：
	declare @applyMan nvarchar(30)
	set @applyMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	begin tran
		update eqpApplyInfo
		set applyReason = @applyReason, applyManID = @applyManID, applyMan = @applyMan, 
			applyTime = @applyTime, remark = @remark
		where eqpApplyID = @eqpApplyID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--插入明细表数据：
		delete eqpApplyDetail where eqpApplyID = @eqpApplyID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		insert eqpApplyDetail(eqpApplyID, preEqpCode, preEqpName, prePrice, preQuantity, preTotalMoney)
		select @eqpApplyID, preEqpCode, preEqpName, prePrice, preQuantity, prePrice * preQuantity 
		from (select cast(T.x.query('data(./preEqpCode)') as nvarchar(30)) preEqpCode, 
				cast(T.x.query('data(./preEqpName)') as nvarchar(60)) preEqpName,
				cast(cast(T.x.query('data(./prePrice)') as varchar(13)) as numeric(12,2)) prePrice,
				cast(cast(T.x.query('data(./preQuantity)') as varchar(8)) as int) preQuantity
			from(select @eqpApplyDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
				) as tab
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		--更新总计：
		declare @preSumQuantity int, @preSumMoney numeric(15,2)
		set @preSumQuantity = isnull((select SUM(preQuantity) from eqpApplyDetail where eqpApplyID = @eqpApplyID),0)
		set @preSumMoney = isnull((select SUM(preTotalMoney) from eqpApplyDetail where eqpApplyID = @eqpApplyID),0)
		update eqpApplyInfo
		set preSumQuantity = @preSumQuantity, preSumMoney = @preSumMoney
		where eqpApplyID = @eqpApplyID
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
	values(@modiManID, @modiManName, @modiTime, '修改设备采购申请', '系统根据用户' + @modiManName + 
					'的要求修改了设备采购申请['+@eqpApplyID+']。')
GO
declare @modiManID varchar(10)	--创建人工号
set @modiManID='00001'
declare @Ret		int
declare @modiTime smalldatetime
declare @eqpApplyDetail xml		--计划采购设备明细 
set @eqpApplyDetail =N'<root>
						<row id="1">
							<preEqpCode>10000014，概算书P12</preEqpCode>
							<preEqpName>继电器5000W</preEqpName>
							<prePrice>10000.00</prePrice>
							<preQuantity>2</preQuantity>
						</row>
						<row id="2">
							<preEqpCode>10000015，概算书P23</preEqpCode>
							<preEqpName>继电器3000W</preEqpName>
							<prePrice>8000.00</prePrice>
							<preQuantity>9</preQuantity>
						</row>
						...
					</root>'
exec dbo.updateEqpApplyInfo 'CG20120002', '测试修改',@eqpApplyDetail, '00001', '2012-12-28', '备注测试修改',
	@modiManID output, @Ret output, @modiTime output
select @Ret

select * from eqpApplyDetail
select * from eqpApplyInfo

drop PROCEDURE delEqpApplyInfo
/*
	name:		delEqpApplyInfo
	function:	2.3.删除指定的设备采购申请
	input: 
				@eqpApplyID varchar(10),		--设备采购申请编号
				@delManID varchar(10),			--删除人
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的设备采购申请不存在，
							3:该设备采购申请已经进入审批环节，不能删除，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-12-28
	UpdateDate: modi by lw 2013-2-28 采用工作流引擎，锁由引擎管理，相应修改接口

*/
create PROCEDURE delEqpApplyInfo
	@eqpApplyID varchar(10),		--设备采购申请编号
	@delManID varchar(10) output,	--删除人，如果当前设备采购申请正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要删除的设备采购申请是否存在
	declare @count as int
	set @count=(select count(*) from eqpApplyInfo where eqpApplyID= @eqpApplyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查单据状态：
	declare @applyStatus smallint	----单据状态：0->新建未发送，-1->驳回，1->发起人编辑，发送至部长审批，2->部长批准，发送至总工审批，
													--3->总工批准，发回发起人办理招标手续，
													--4->发起人填报招标信息，发送至总经济师审批
													--5->总经济师批准，发送至总经理审批
													--6->总经理审批
													--9->执行完成归档
	select @applyStatus = applyStatus
	from eqpApplyInfo
	where eqpApplyID= @eqpApplyID
	--判断状态：
	if (@applyStatus not in (0,-1))
	begin
		set @Ret = 3
		return
	end

	delete eqpApplyInfo where eqpApplyID= @eqpApplyID
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除设备采购申请', '用户' + @delManName
												+ '删除了设备采购申请['+@eqpApplyID+']。')

GO

drop PROCEDURE approvalEqpApplyInfo
/*
	name:		approvalEqpApplyInfo
	function:	1.4.区分节点填写批复意见
	input: 
				@eqpApplyID varchar(10),		--设备采购申请单号
				@flowID int,					--节点编号
				@approveManID varchar(10),		--批准人工号
				@approveStatus smallint,		--批复意见类型：0->未知，1->批准，-1->不批准
				@approveOpinion nvarchar(300),	--批复意见
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的请假条不存在，2：该申请已经完成，9：未知错误
	author:		卢苇
	CreateDate:	2013-2-28
	UpdateDate: 
*/				
create PROCEDURE approvalEqpApplyInfo
	@eqpApplyID varchar(10),		--设备采购申请单号
	@flowID int,					--节点编号
	@approveManID varchar(10),		--批准人工号
	@approveStatus smallint,		--批复意见类型：0->未知，1->批准，-1->不批准
	@approveOpinion nvarchar(300),	--批复意见
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的申请单是否存在
	declare @count as int
	set @count=(select count(*) from eqpApplyInfo where eqpApplyID= @eqpApplyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--获取单据基本信息，检查单据状态：
	declare @applyStatus smallint	----单据状态：0->新建未发送，-1->驳回，1->发起人编辑，发送至部长审批，2->部长批准，发送至总工审批，
													--3->总工批准，发回发起人办理招标手续，
													--4->发起人填报招标信息，发送至总经济师审批
													--5->总经济师批准，发送至总经理审批
													--6->总经理审批
													--9->执行完成归档
	select @applyStatus = applyStatus from eqpApplyInfo where eqpApplyID= @eqpApplyID
	--判断状态：
	if (@applyStatus=9)
	begin
		set @Ret = 2
		return
	end

	--取批准人姓名：
	declare @approveMan nvarchar(30)			--批准人姓名
	select @approveMan = cName from userInfo where jobNumber=@approveManID
	
	--批准时间：
	declare @approveTime smalldatetime
	set @approveTime = GETDATE()
	
	if (@flowID=2)	--部长审批
	begin
		update eqpApplyInfo
		set departManagerID =@approveManID,	--部长工号
			departManager =@approveMan,	--部长姓名。冗余设计
			dApproveTime =@approveTime,	--批准时间
			departOpinion =@approveOpinion	--部长意见
		where eqpApplyID= @eqpApplyID
	end
	else if (@flowID=3)
	begin
		update eqpApplyInfo
		set chiefEngineerID =@approveManID,	--总工工号
			chiefEngineer =@approveMan,	--总工姓名。冗余设计
			eApproveTime =@approveTime,	--批准时间
			chiefEngineerOpinion =@approveOpinion	--总工意见
		where eqpApplyID= @eqpApplyID
	end
	else if (@flowID=5)
	begin
		update eqpApplyInfo
		set chiefEconomistID=@approveManID,	--总经济师工号
			chiefEconomist =@approveMan,	--总经济师姓名。冗余设计
			ecApproveTime =@approveTime,	--批准时间
			chiefEconomistOpinion =@approveOpinion	--总经济师意见
		where eqpApplyID= @eqpApplyID
	end
	else if (@flowID=6)
	begin
		update eqpApplyInfo
		set generalManagerID=@approveManID,	--总经理工号
			generalManager=@approveMan,	--总经理姓名
			gApproveTime=@approveTime,	--批准时间
			generalManagerOpinion=@approveOpinion	--总经理意见
		where eqpApplyID= @eqpApplyID
	end
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@approveManID, @approveMan, @approveTime, '批复设备采购申请单', '用户' + @approveMan
												+ '批准了设备采购申请单['+@eqpApplyID+']。')

GO

drop PROCEDURE setEqpApplyStatus
/*
	name:		setEqpApplyStatus
	function:	2.5.设置设备采购申请单状态
				注意：这个过程没有登记工作日志
	input: 
				@eqpApplyID varchar(10),		--设备采购申请单号
				@applyStatus smallint,			----单据状态：0->新建未发送，-1->驳回，1->发起人编辑，发送至部长审批，2->部长批准，发送至总工审批，
													--3->总工批准，发回发起人办理招标手续，
													--4->发起人填报招标信息，发送至总经济师审批
													--5->总经济师批准，发送至总经理审批
													--6->总经理审批
													--9->执行完成归档
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的设备采购申请单不存在，2：该申请单已经完成，9：未知错误
	author:		卢苇
	CreateDate:	2013-2-28
	UpdateDate: 
*/				
create PROCEDURE setEqpApplyStatus
	@eqpApplyID varchar(10),		--设备采购申请单号
	@applyStatus smallint,			----单据状态：0->新建未发送，-1->驳回，1->发起人编辑，发送至部长审批，2->部长批准，发送至总工审批，
													--3->总工批准，发回发起人办理招标手续，
													--4->发起人填报招标信息，发送至总经济师审批
													--5->总经济师批准，发送至总经理审批
													--6->总经理审批
													--9->执行完成归档

	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断申请单是否存在：
	declare @count as int
	set @count=(select count(*) from eqpApplyInfo where eqpApplyID= @eqpApplyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--获取单据基本信息，检查单据状态：
	declare @applyOldStatus smallint			----单据状态：0->新建未发送，-1->驳回，1->发起人编辑，发送至部长审批，2->部长批准，发送至总工审批，
													--3->总工批准，发回发起人办理招标手续，
													--4->发起人填报招标信息，发送至总经济师审批
													--5->总经济师批准，发送至总经理审批
													--6->总经理审批
													--9->执行完成归档
	select @applyOldStatus = applyStatus
	from eqpApplyInfo 
	where eqpApplyID= @eqpApplyID
	--判断状态：
	if (@applyOldStatus=9)
	begin
		set @Ret = 2
		return
	end

	update eqpApplyInfo 
	set applyStatus = @applyStatus				----单据状态：0->新建未发送，-1->驳回，1->发起人编辑，发送至部长审批，2->部长批准，发送至总工审批，
													--3->总工批准，发回发起人办理招标手续，
													--4->发起人填报招标信息，发送至总经济师审批
													--5->总经济师批准，发送至总经理审批
													--6->总经理审批
													--9->执行完成归档
	where eqpApplyID= @eqpApplyID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0
GO

drop PROCEDURE addTenderInfo
/*
	name:		addTenderInfo
	function:	2.6.添加设备采购申请书招标情况说明
				注意：附件采用统一传送
	input: 
				@eqpApplyID varchar(10),	--设备采购申请编号
				@tenderInfo nvarchar(300) ,	--招标完成情况说明
				@remark nvarchar(300),		--备注
				@eqpTenderDetail xml,		--采购招标设备明细

				@modiManID varchar(10) output,	--修改人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:要修改的设备采购申请不存在，
							3:该设备采购申请还没有到达填报环节，
							9:未知错误
				@modiTime smalldatetime output	--修改时间
	author:		卢苇
	CreateDate:	2012-12-28
	UpdateDate: modi by lw 2013-2-28 采用工作流引擎，锁由引擎管理，相应修改接口
*/
create PROCEDURE addTenderInfo
	@eqpApplyID varchar(10),	--设备采购申请编号
	@tenderInfo nvarchar(300) ,	--招标完成情况说明
	@remark nvarchar(300),		--备注
	@eqpTenderDetail xml,		--采购招标设备明细
	
	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要修改的设备采购申请是否存在
	declare @count as int
	set @count=(select count(*) from eqpApplyInfo where eqpApplyID= @eqpApplyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查单据状态：
	declare @applyStatus smallint	--单据状态：0->新建未发送，-1->驳回，1->发送等待审批，2->部长批准等待总工批准，3->总工批准等待招标，
													--4->填报招标信息完成等待总经济师批准
													--5->总经济师批准等待总经理批准
													--6->总经理批准
													--9->执行完成归档
	select @applyStatus = applyStatus
	from eqpApplyInfo 
	where eqpApplyID= @eqpApplyID
	--判断状态：
	if (@applyStatus <> 4)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiMan nvarchar(30)
	set @modiMan = isnull((select cName from userInfo where jobNumber = @modiManID),'')
	
	set @modiTime = getdate()
	begin tran
		update eqpApplyInfo
		set tenderInfo = @tenderInfo, remark = @remark
		where eqpApplyID = @eqpApplyID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--添加招标明细表数据：
		update eqpApplyDetail
		set eqpName = t.eqpName, business = t.business,
			price = t.price, quantity = t.quantity, totalMoney=t.price * t.quantity
		from eqpApplyDetail e left join (
					select cast((cast(T.x.query('data(./rowNum)') as nvarchar(12))) as int) rowNum,	--原申请中的设备行号
									cast(T.x.query('data(./eqpName)') as nvarchar(60)) eqpName,
									cast(T.x.query('data(./business)') as varchar(20)) business,
									cast(cast(T.x.query('data(./price)') as varchar(13)) as numeric(12,2)) price,
									cast(cast(T.x.query('data(./quantity)') as varchar(8)) as int) quantity
								from(select @eqpTenderDetail.query('/root/row') Col1) A
									OUTER APPLY A.Col1.nodes('/row') AS T(x)
					) t on e.eqpApplyID= @eqpApplyID and e.rowNum = t.rowNum
					
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end

		--更新总计：
		declare @tSumQuantity int, @tSumMoney numeric(15,2)
		set @tSumQuantity = isnull((select SUM(quantity) from eqpApplyDetail where eqpApplyID = @eqpApplyID),0)
		set @tSumMoney = isnull((select SUM(totalMoney) from eqpApplyDetail where eqpApplyID = @eqpApplyID),0)
		update eqpApplyInfo
		set tSumQuantity= @tSumQuantity, tSumMoney = @tSumMoney
		where eqpApplyID = @eqpApplyID
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
	values(@modiManID, @modiMan, @modiTime, '修改设备采购申请', '系统根据用户' + @modiMan + 
					'的要求修改了设备采购申请['+@eqpApplyID+']。')
GO
declare @eqpTenderDetail xml		--计划采购设备明细 
set @eqpTenderDetail =N'<root>
						<row id="1">
							<rowNum>10000014</rowNum>
							<eqpName>继电器5000W</eqpName>
							<business>东之友道</business>
							<price>10000.00</price>
							<quantity>2</quantity>
						</row>
					</root>'
select T.rowNum
from
(
select cast((cast(T.x.query('data(./rowNum)') as nvarchar(12))) as int) rowNum,	--原申请中的设备行号
				cast(T.x.query('data(./eqpName)') as nvarchar(60)) eqpName,
				cast(T.x.query('data(./business)') as varchar(20)) business,
				cast(cast(T.x.query('data(./price)') as varchar(13)) as numeric(12,2)) price,
				cast(cast(T.x.query('data(./quantity)') as varchar(8)) as int) quantity
			from(select @eqpTenderDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
)as t

--设备采购申请查询语句：
select e.eqpApplyID, e.applyStatus, e.applyReason, 
	e.applyManID, e.applyMan, convert(varchar(10),e.applyTime,120) applyTime, 
	e.preSumQuantity, e.preSumMoney, e.sumQuantity, e.sumMoney
from eqpApplyInfo e


---------------------论文发表申请表存储过程：-------------------------------------------
drop PROCEDURE addThesisPublishApplyInfo
/*
	name:		addThesisPublishApplyInfo
	function:	3.1.添加论文发表申请单
	input: 
				@thesisPublishApplyID varchar(10),	--论文发表申请编号,由工作流引擎分配使用第302号号码发生器产生（'WF'+4位年份代码+4位流水号）
				@applyManID varchar(10),			--申请人工号
				@applyTime varchar(10),				--申请日期:采用“yyyy-MM-dd”格式传送
				@elseAuthor xml,					--其他作者：采用N'<root><elseAuthor id="G201300001" name="程远"></elseAuthor></root>'格式存放
				@thesisTitle nvarchar(40),			--论文题目
				@summary nvarchar(300),				--内容简介
				@keys nvarchar(30),					--关键字：多个关键字使用","分隔
				@prePeriodicalName nvarchar(40),	--拟投杂志名称
	output: 
				@Ret		int output			--操作成功标识
							0:成功，9:未知错误
	author:		卢苇
	CreateDate:	2013-1-24
	UpdateDate: 
*/
create PROCEDURE addThesisPublishApplyInfo
	@thesisPublishApplyID varchar(10),	--论文发表申请编号,由工作流引擎分配使用第302号号码发生器产生（'WF'+4位年份代码+4位流水号）
	@applyManID varchar(10),			--申请人工号
	@applyTime varchar(10),				--申请日期:采用“yyyy-MM-dd”格式传送
	@elseAuthor xml,					--其他作者：采用N'<root><elseAuthor id="G201300001" name="程远"></elseAuthor></root>'格式存放
	@thesisTitle nvarchar(40),			--论文题目
	@summary nvarchar(300),				--内容简介
	@keys nvarchar(30),					--关键字：多个关键字使用","分隔
	@prePeriodicalName nvarchar(40),	--拟投杂志名称

	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--取申请人的姓名：
	declare @applyMan nvarchar(30)
	select @applyMan = cName from userInfo where jobNumber = @applyManID
	
	--统计其他作者人数：
	declare @count int
	set @count = (select @elseAuthor.value('count(/root/elseAuthor)','int'))
	
	insert thesisPublishApplyInfo(thesisPublishApplyID, applyManID, applyMan, applyTime, elseAuthor,
				thesisTitle, summary, keys, prePeriodicalName, elseAuthorNum)
	values(@thesisPublishApplyID, @applyManID, @applyMan, @applyTime, @elseAuthor,
		@thesisTitle, @summary, @keys, @prePeriodicalName, @count)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@applyManID, @applyMan, GETDATE(), '登记论文发表审批申请', '系统根据用户' + @applyMan + 
					'的要求登记论文发表审批申请['+@thesisPublishApplyID+']。')
GO

drop PROCEDURE updateThesisPublishApplyInfo
/*
	name:		updateThesisPublishApplyInfo
	function:	3.2.修改论文发表申请
	input: 
				@thesisPublishApplyID varchar(10),	--论文发表申请编号,由工作流引擎分配使用第302号号码发生器产生（'WF'+4位年份代码+4位流水号）
				@applyManID varchar(10),			--申请人工号
				@applyTime varchar(10),				--申请日期:采用“yyyy-MM-dd”格式传送
				@elseAuthor xml,					--其他作者：采用N'<root><elseAuthor id="G201300001" name="程远"></elseAuthor></root>'格式存放
				@thesisTitle nvarchar(40),			--论文题目
				@summary nvarchar(300),				--内容简介
				@keys nvarchar(30),					--关键字：多个关键字使用","分隔
				@prePeriodicalName nvarchar(40),	--拟投杂志名称
	output: 
				@Ret		int output	--操作成功标识
							0:成功，
							1:要修改的申请单不存在，
							3:要修改的申请单已经发送，不允许修改，
							9:未知错误
	author:		卢苇
	CreateDate:	2013-1-24
	UpdateDate: 
*/
create PROCEDURE updateThesisPublishApplyInfo
	@thesisPublishApplyID varchar(10),	--论文发表申请编号,由工作流引擎分配使用第302号号码发生器产生（'WF'+4位年份代码+4位流水号）
	@applyManID varchar(10),			--申请人工号
	@applyTime varchar(10),				--申请日期:采用“yyyy-MM-dd”格式传送
	@elseAuthor xml,					--其他作者：采用N'<root><elseAuthor id="G201300001" name="程远"></elseAuthor></root>'格式存放
	@thesisTitle nvarchar(40),			--论文题目
	@summary nvarchar(300),				--内容简介
	@keys nvarchar(30),					--关键字：多个关键字使用","分隔
	@prePeriodicalName nvarchar(40),	--拟投杂志名称

	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--检查单据是否存在
	declare @count as int
	set @count=(select count(*) from thesisPublishApplyInfo where thesisPublishApplyID= @thesisPublishApplyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	--检查单据状态：
	declare @applyStatus smallint	--单据状态：0->新建未发送，-1->驳回，1->审批中
													--9->执行完成归档
	select @applyStatus = applyStatus from thesisPublishApplyInfo where thesisPublishApplyID= @thesisPublishApplyID
	if (@applyStatus not in(0,-1))
	begin
		set @Ret = 3
		return
	end

	--取申请人/创建人的姓名：
	declare @applyMan nvarchar(30)
	set @applyMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')

	--统计其他作者人数：
	set @count = (select @elseAuthor.value('count(/root/elseAuthor)','int'))
	
	update thesisPublishApplyInfo
	set applyManID = @applyManID, applyMan = @applyMan, applyTime = @applyTime, elseAuthor = @elseAuthor,
				thesisTitle = @thesisTitle, summary = @summary, keys = @keys, 
				prePeriodicalName = @prePeriodicalName, elseAuthorNum = @count
	where thesisPublishApplyID = @thesisPublishApplyID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@applyManID, @applyMan, GETDATE(), '修改论文发表审批申请', '系统根据用户' + @applyMan + 
					'的要求修改了论文发表审批申请['+@thesisPublishApplyID+']。')
GO

drop PROCEDURE delThesisPublishApplyInfo
/*
	name:		delThesisPublishApplyInfo
	function:	3.3.删除指定的论文发表申请
	input: 
				@thesisPublishApplyID varchar(10),	--论文发表申请编号,由工作流引擎分配使用第302号号码发生器产生（'WF'+4位年份代码+4位流水号）
				@delManID varchar(10),			--删除人
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的申请不存在，，
							3：该申请已经发送，不允许删除，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-24
	UpdateDate: 

*/
create PROCEDURE delThesisPublishApplyInfo
	@thesisPublishApplyID varchar(10),	--论文发表申请编号,由工作流引擎分配使用第302号号码发生器产生（'WF'+4位年份代码+4位流水号）
	@delManID varchar(10),			--删除人
	@Ret		int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--检查单据是否存在
	declare @count as int
	set @count=(select count(*) from thesisPublishApplyInfo where thesisPublishApplyID= @thesisPublishApplyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	--检查单据状态：
	declare @applyStatus smallint	--单据状态：0->新建未发送，-1->驳回，1->审批中
													--9->执行完成归档
	select @applyStatus = applyStatus from thesisPublishApplyInfo where thesisPublishApplyID= @thesisPublishApplyID
	if (@applyStatus not in(0,-1))
	begin
		set @Ret = 3
		return
	end

	delete thesisPublishApplyInfo where thesisPublishApplyID= @thesisPublishApplyID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除论文发表审批申请', '用户' + @delManName
												+ '删除了论文发表审批申请['+@thesisPublishApplyID+']。')

	set @Ret = 0
GO
use hustOA
select * from thesisPublishApplyInfo
update thesisPublishApplyInfo
set applyStatus=1, agreeNum=0, isCanPublish=0
where thesisPublishApplyID='WF20130222'

drop PROCEDURE approvalThesisPublishApply
/*
	name:		approvalThesisPublishApply
	function:	3.4.批复论文发表申请
	input: 
				@thesisPublishApplyID varchar(10),	--论文发表申请编号

				@approveManID varchar(10),			--批准人工号
				@approveStatus smallint,			--批复意见类型：0->未知，1->批准，-1->不批准
	output: 
				@Ret		int output				--操作成功标识
							0:成功，1：指定的论文发表申请不存在，2：该论文发表申请已经审批完成，9：未知错误
	author:		卢苇
	CreateDate:	2013-3-25
	UpdateDate: 
*/				
create PROCEDURE approvalThesisPublishApply
	@thesisPublishApplyID varchar(10),	--论文发表申请编号
	@approveManID varchar(10),			--批准人工号
	@approveStatus smallint,			--批复意见类型：0->未知，1->批准，-1->不批准
	@Ret		int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的论文发表申请是否存在
	declare @count as int
	set @count=(select count(*) from thesisPublishApplyInfo where thesisPublishApplyID= @thesisPublishApplyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--获取单据基本信息，检查单据状态：
	declare @applyManID varchar(10), @applyMan nvarchar(30)	--申请人
	declare @applyStatus smallint	--单据状态：0->新建未发送，1->发送等待审批，9->审批完成，-1->退回：将批准状态分离，放入批复状态字段
	declare @elseAuthorNum int		--其他作者人数
	declare @agreeNum smallint		--同意总数：0->未知，-1：有反对，1~n：同意票数
	select @applyManID = applyManID, @applyMan = applyMan, @applyStatus = applyStatus, 
			@elseAuthorNum = isnull(elseAuthorNum,0), @agreeNum = isnull(agreeNum,0)
	from thesisPublishApplyInfo 
	where thesisPublishApplyID= @thesisPublishApplyID
	--判断状态：
	if (@applyStatus=9)
	begin
		set @Ret = 2
		return
	end

	--取批准人姓名：
	declare @approveMan nvarchar(30)			--批准人姓名
	select @approveMan = cName from userInfo where jobNumber=@approveManID
	
	--批准时间：
	declare @approveTime smalldatetime
	set @approveTime = GETDATE()
	begin tran	
		if (@agreeNum>=0 and @approveStatus=1)--批复意见类型：0->未知，1->批准，-1->不批准
		begin
			set @agreeNum = @agreeNum + 1
			update thesisPublishApplyInfo
			set agreeNum = @agreeNum
			where thesisPublishApplyID = @thesisPublishApplyID
		end
		else if (@approveStatus=-1)--批复意见类型：0->未知，1->批准，-1->不批准
		begin
			update thesisPublishApplyInfo
			set agreeNum = -1,
				applyStatus = 9,
				isCanPublish =2			--表决结果：0->未知，1：同意发表，2：不同意发表
			where thesisPublishApplyID = @thesisPublishApplyID
		end
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end 
		if (@elseAuthorNum=@agreeNum)
		begin   
			update thesisPublishApplyInfo
			set applyStatus = 9,
				isCanPublish =1			--表决结果：0->未知，1：同意发表，2：不同意发表
			where thesisPublishApplyID = @thesisPublishApplyID
			if @@ERROR <> 0 
			begin
				rollback tran
				set @Ret = 9
				return
			end 
		end
	commit tran
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@approveManID, @approveMan, @approveTime, '批复论文发表申请', '用户' + @applyMan
												+ '批准了['+@applyMan+']的论文发表申请['+@thesisPublishApplyID+']。')

GO


drop PROCEDURE setThesisPublishApplyStatus
/*
	name:		setThesisPublishApplyStatus
	function:	3.5.设置论文发表申请单状态
				注意：这个过程没有登记工作日志
	input: 
				@thesisPublishApplyID varchar(10),	--论文发表申请编号
				@applyStatus smallint,				--单据状态：0->新建未发送，1->发送等待审批，9->审批完成，-1->退回：将批准状态分离，放入批复状态字段
	output: 
				@Ret		int output				--操作成功标识
							0:成功，1：指定的论文发表申请不存在，2：该论文发表申请已经审批完成，9：未知错误
	author:		卢苇
	CreateDate:	2013-3-25
	UpdateDate: 
*/				
create PROCEDURE setThesisPublishApplyStatus
	@thesisPublishApplyID varchar(10),	--论文发表申请编号
	@applyStatus smallint,				--单据状态：0->新建未发送，1->发送等待审批，9->审批完成，-1->退回：将批准状态分离，放入批复状态字段
	@Ret		int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的论文发表申请是否存在
	declare @count as int
	set @count=(select count(*) from thesisPublishApplyInfo where thesisPublishApplyID= @thesisPublishApplyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--获取单据基本信息，检查单据状态：
	declare @applyOldStatus smallint			--单据状态：0->新建未发送，1->发送等待审批，9->审批完成，-1->退回：将批准状态分离，放入批复状态字段
	select @applyOldStatus = applyStatus
	from thesisPublishApplyInfo 
	where thesisPublishApplyID= @thesisPublishApplyID
	--判断状态：
	if (@applyOldStatus=9)
	begin
		set @Ret = 2
		return
	end

	update thesisPublishApplyInfo
	set applyStatus = @applyStatus				--单据状态：0->新建未发送，1->发送等待审批，9->审批完成，-1->退回：将批准状态分离，放入批复状态字段
	where thesisPublishApplyID= @thesisPublishApplyID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0
GO


----------------------------------------------------------------
drop PROCEDURE addProcessApply
/*
	name:		addProcessApply
	function:	4.1.添加车间加工申请信息
	input: 
				@processApplyID varchar(10),	--主键：车间加工申请编号,本系统使用第303号号码发生器产生（'JG'+4位年份代码+4位流水号），现改用工作流引擎生成
				@applyManID varchar(10),		--申请人工号
				@applyTime varchar(10),			--申请日期:采用“yyyy-MM-dd”格式传递
				
				@preCompletedTime varchar(19),	--期望完成时间:采用“yyyy-MM-dd hh:mm:ss”格式传递
				@applyReason nvarchar(300),		--申请理由
				--@attachmentFile varchar(128),	--附件文件路径 del by lw 2013-3-2统一设计考虑附件

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output--添加时间
	author:		卢苇
	CreateDate:	2013-1-9
	UpdateDate: modi by lw 2013-3-1改用工作流引擎生成单号，进行锁操作！
*/
create PROCEDURE addProcessApply
	@processApplyID varchar(10),	--主键：车间加工申请编号,本系统使用第303号号码发生器产生（'JG'+4位年份代码+4位流水号），现改用工作流引擎生成
	@applyManID varchar(10),		--申请人工号
	@applyTime varchar(10),			--申请日期:采用“yyyy-MM-dd”格式传递
	
	@preCompletedTime varchar(19),	--期望完成时间
	@applyReason nvarchar(300),		--申请理由
	--@attachmentFile varchar(128),	--附件文件路径 del by lw 2013-3-2统一设计考虑附件

	@createManID varchar(10),		--创建人工号
	@Ret		int output,
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--取申请人/创建人的姓名：
	declare @applyMan nvarchar(30), @createManName nvarchar(30)
	set @applyMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert processApplyInfo(processApplyID, applyManID, applyMan, applyTime, 
					preCompletedTime, applyReason)
	values(@processApplyID, @applyManID, @applyMan, @applyTime, 
					@preCompletedTime, @applyReason)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '登记车间加工申请', '系统根据用户' + @createManName + 
					'的要求登记了车间加工申请['+@processApplyID+']。')
GO

drop PROCEDURE updateProcessApply
/*
	name:		updateProcessApply
	function:	4.2.修改车间加工申请信息
	input: 
				@processApplyID varchar(10),	--车间加工申请编号
				@applyManID varchar(10),		--申请人工号
				@applyTime varchar(10),			--申请日期:采用“yyyy-MM-dd”格式传递
				
				@preCompletedTime varchar(19),	--期望完成时间:采用“yyyy-MM-dd hh:mm:ss”格式传递
				@applyReason nvarchar(300),		--申请理由
				--@attachmentFile varchar(128),	--附件文件路径	del by lw 2013-3-2统一设计考虑附件

				@modiManID varchar(10),			--修改人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:要修改的申请单不存在，
							3：该申请单已经发送，不允许修改，
							9:未知错误
				@modiTime smalldatetime output	--添加时间
	author:		卢苇
	CreateDate:	2013-1-9
	UpdateDate: modi by lw 2013-3-1改用工作流引擎锁操作
*/
create PROCEDURE updateProcessApply
	@processApplyID varchar(10),	--车间加工申请编号
	@applyManID varchar(10),		--申请人工号
	@applyTime varchar(10),			--申请日期:采用“yyyy-MM-dd”格式传递
	
	@preCompletedTime varchar(19),	--期望完成时间
	@applyReason nvarchar(300),		--申请理由
	--@attachmentFile varchar(128),	--附件文件路径

	@modiManID varchar(10),			--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要修改的申请单是否存在
	declare @count as int
	set @count=(select count(*) from processApplyInfo where processApplyID= @processApplyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查单据状态：
	declare @applyStatus smallint	--单据状态：0->新建未发送，-1->驳回，1->审批中，9->执行完成归档
	select @applyStatus = applyStatus from processApplyInfo where processApplyID= @processApplyID
	if (@applyStatus not in (0,-1))
	begin
		set @Ret = 3
		return
	end

	--取申请人/创建人的姓名：
	declare @applyMan nvarchar(30)
	set @applyMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	update processApplyInfo
	set applyMan = @applyMan, applyTime = @applyTime, 
		preCompletedTime = @preCompletedTime, applyReason = @applyReason
	where processApplyID= @processApplyID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '修改车间加工申请', '系统根据用户' + @modiManName + 
					'的要求修改了车间加工申请['+@processApplyID+']的登记信息。')
GO

drop PROCEDURE delProcessApply
/*
	name:		delProcessApply
	function:	4.3.删除指定的车间加工申请
	input: 
				@processApplyID varchar(10),	--车间加工申请编号
				@delManID varchar(10),	--删除人
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的申请不存在，
							3：该申请已经发送，不允许删除，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-9
	UpdateDate: modi by lw 2013-3-1改用工作流引擎提供锁操作

*/
create PROCEDURE delProcessApply
	@processApplyID varchar(10),	--车间加工申请编号
	@delManID varchar(10),			--删除人
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要删除的其他申请是否存在
	declare @count as int
	set @count=(select count(*) from processApplyInfo where processApplyID= @processApplyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查单据状态：
	declare @applyStatus smallint	--单据状态：0->新建未发送，-1->驳回，1->审批中，9->执行完成归档
	select @applyStatus = applyStatus 
	from processApplyInfo 
	where processApplyID= @processApplyID
	if (@applyStatus not in (0,-1))
	begin
		set @Ret = 3
		return
	end

	delete processApplyInfo where processApplyID= @processApplyID
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除车间加工申请', '用户' + @delManName
												+ '删除了车间加工申请['+@processApplyID+']。')

GO

drop PROCEDURE appointProcesser
/*
	name:		appointProcesser
	function:	4.4.指派加工人员
	input: 
				@processApplyID varchar(10),	--车间加工申请编号
				@processerID varchar(10),		--加工人工号

				@modiManID varchar(10),			--指派人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的申请不存在，2：该单据已经完成，9:未知错误
	author:		卢苇
	CreateDate:	2013-3-2
	UpdateDate: 
*/
create PROCEDURE appointProcesser
	@processApplyID varchar(10),	--车间加工申请编号
	@processerID varchar(10),		--加工人工号

	@modiManID varchar(10),			--指派人工号
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断申请单是否存在
	declare @count as int
	set @count=(select count(*) from processApplyInfo where processApplyID= @processApplyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查单据状态：
	declare @applyStatus smallint	--单据状态：0->新建未发送，-1->驳回，1->审批中，9->执行完成归档
	select @applyStatus = applyStatus from processApplyInfo where processApplyID= @processApplyID
	if (@applyStatus =9)
	begin
		set @Ret = 2
		return
	end

	--取指派人/指派人员的姓名：
	declare @processer nvarchar(30)
	set @processer = isnull((select cName from userInfo where jobNumber = @processerID),'')
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	declare @modiTime smalldatetime
	set @modiTime = getdate()
	update processApplyInfo
	set processerID = @processerID, processer = @processer,
		appointTime = @modiTime
	where processApplyID= @processApplyID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '指派加工人', '系统根据用户' + @modiManName + 
					'的要求将车间加工申请['+@processApplyID+']指派给['+@processer+']加工。')
GO

drop PROCEDURE setProcessStatus
/*
	name:		setProcessStatus
	function:	4.5.设置加工状态
	input: 
				@processApplyID varchar(10),	--车间加工申请编号
				@isCompleted smallint,			--加工状态：0->未知，1->正在加工，9->完成, 10->无法完成
				@completedTime varchar(19),		--完成时间:采用"yyyy-MM-dd hh:mm:ss"格式存放
				@completeIntro nvarchar(300),	--完成情况

				@modiManID varchar(10),			--设置人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的申请不存在，2：该单据已经完成，9:未知错误
	author:		卢苇
	CreateDate:	2013-3-2
	UpdateDate: 
*/
create PROCEDURE setProcessStatus
	@processApplyID varchar(10),	--车间加工申请编号
	@isCompleted smallint,			--加工状态：0->未知，1->正在加工，9->完成
	@completedTime varchar(19),		--完成时间:采用"yyyy-MM-dd hh:mm:ss"格式存放
	@completeIntro nvarchar(300),	--完成情况

	@modiManID varchar(10),			--设置人工号
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断申请单是否存在
	declare @count as int
	set @count=(select count(*) from processApplyInfo where processApplyID= @processApplyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查单据状态：
	declare @applyStatus smallint	--单据状态：0->新建未发送，-1->驳回，1->审批中，9->执行完成归档
	select @applyStatus = applyStatus from processApplyInfo where processApplyID= @processApplyID
	if (@applyStatus =9)
	begin
		set @Ret = 2
		return
	end

	--取设置人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	declare @modiTime smalldatetime
	set @modiTime = getdate()
	update processApplyInfo
	set isCompleted = @isCompleted,			--加工状态：0->未知，1->正在加工，9->完成
		completedTime = @completedTime,		--完成时间:采用"yyyy-MM-dd hh:mm:ss"格式存放
		@completeIntro = @completeIntro		--完成情况
	where processApplyID= @processApplyID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '填报加工状态', '系统根据用户' + @modiManName + 
					'的要求填报了车间加工申请['+@processApplyID+']的加工情况。')
GO

drop PROCEDURE setProcessApplyStatus
/*
	name:		setProcessApplyStatus
	function:	4.6.设置车间加工申请单状态
				注意：这个过程没有登记工作日志
	input: 
				@processApplyID varchar(10),	--车间加工申请编号
				@applyStatus smallint,			----单据状态：0->新建未发送，-1->驳回，1->审批中，9->执行完成归档
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的申请不存在，2：该单据已经完成，9:未知错误
	author:		卢苇
	CreateDate:	2013-3-2
	UpdateDate: 
*/				
create PROCEDURE setProcessApplyStatus
	@processApplyID varchar(10),	--车间加工申请编号
	@applyStatus smallint,			----单据状态：0->新建未发送，-1->驳回，1->审批中，9->执行完成归档

	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断申请单是否存在
	declare @count as int
	set @count=(select count(*) from processApplyInfo where processApplyID= @processApplyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--获取单据基本信息，检查单据状态：
	declare @applyOldStatus smallint	--单据状态：0->新建未发送，-1->驳回，1->审批中，9->执行完成归档
	select @applyOldStatus = applyStatus from processApplyInfo where processApplyID= @processApplyID
	--判断状态：
	if (@applyOldStatus=9)
	begin
		set @Ret = 2
		return
	end

	update processApplyInfo
	set applyStatus = @applyStatus
	where processApplyID= @processApplyID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0
GO

--车间加工列表查询语句：
select p.processApplyID, p.applyStatus, p.applyManID, p.applyMan, 
	convert(varchar(10), p.applyTime,120) applyTime, p.applyReason, p.attachmentFile, 
	p.processerID, p.process, p.isCompleted, 
	convert(varchar(10), p.completedTime,120) completedTime, p.completeIntro
from processApplyInfo p

----------------------------------------------------------------

drop PROCEDURE addOtherApplyInfo
/*
	name:		addOtherApplyInfo
	function:	4.添加其他申请信息
				注意：只支持添加本人的其他申请
	input: 
				@otherApplyID varchar(10),		--其他申请编号
				@applyTime smalldatetime,		--申请日期
				@title nvarchar(40),			--主题
				@summary nvarchar(300),			--内容
				@keys nvarchar(30),				--关键字：多个关键字使用","分隔

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output--添加时间
	author:		卢苇
	CreateDate:	2013-1-7
	UpdateDate: modi by lw2013-3-25按工作流引擎标准化接口
*/
create PROCEDURE addOtherApplyInfo
	@otherApplyID varchar(10),		--其他申请编号
	@applyTime varchar(10),			--申请日期:采用“yyyy-MM-dd”格式传递
	@title nvarchar(40),			--主题
	@summary nvarchar(300),			--内容
	@keys nvarchar(30),				--关键字：多个关键字使用","分隔

	@createManID varchar(10),		--创建人工号
	@Ret		int output,
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--取创建人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert otherApplyInfo(otherApplyID, applyManID, applyMan, applyTime, title, summary, keys)
	values(@otherApplyID, @createManID, @createManName, @applyTime, @title, @summary, @keys)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '登记其他申请', '系统根据用户' + @createManName + 
					'的要求登记了其他申请“' + @title + '['+@otherApplyID+']”。')
GO

drop PROCEDURE updateOtherApplyInfo
/*
	name:		updateOtherApplyInfo
	function:	5.修改其他申请信息
				注意：只支持修改本人的其他申请
	input: 
				@otherApplyID varchar(10),		--其他申请编号
				@applyTime varchar(10),			--申请日期:采用“yyyy-MM-dd”格式传递
				@title nvarchar(40),			--主题
				@summary nvarchar(300),			--内容
				@keys nvarchar(30),				--关键字：多个关键字使用","分隔

				@modiManID varchar(10) output,	--修改人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:要修改的其他申请不存在，
							3：该其他申请已经发送，不允许修改，
							9:未知错误
				@modiTime smalldatetime output	--添加时间
	author:		卢苇
	CreateDate:	2013-1-7
	UpdateDate: modi by lw 2013-3-25按工作流引擎标准化接口
*/
create PROCEDURE updateOtherApplyInfo
	@otherApplyID varchar(10),		--其他申请编号
	@applyTime varchar(10),			--申请日期:采用“yyyy-MM-dd”格式传递
	@title nvarchar(40),			--主题
	@summary nvarchar(300),			--内容
	@keys nvarchar(30),				--关键字：多个关键字使用","分隔

	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的其他申请是否存在
	declare @count as int
	set @count=(select count(*) from otherApplyInfo where otherApplyID= @otherApplyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查状态：
	declare @applyStatus smallint	--单据状态：0->新建未发送，1->发送
	select @applyStatus = applyStatus from otherApplyInfo where otherApplyID= @otherApplyID
	if (@applyStatus=1)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	update otherApplyInfo
	set applyTime = @applyTime, title = @title, summary = @summary, keys = @keys
	where otherApplyID= @otherApplyID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '修改其他申请', '系统根据用户' + @modiManName + 
					'的要求修改了其他申请“' + @title + '['+@otherApplyID+']”的登记信息。')
GO

drop PROCEDURE delOtherApplyInfo
/*
	name:		delOtherApplyInfo
	function:	6.删除指定的其他申请
	input: 
				@otherApplyID varchar(10),		--其他申请编号
				@delManID varchar(10) output,	--删除人
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的其他申请不存在，
							3：该其他申请已经发送，不允许删除，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-7
	UpdateDate: 

*/
create PROCEDURE delOtherApplyInfo
	@otherApplyID varchar(10),		--其他申请编号
	@delManID varchar(10) output,	--删除人
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的其他申请是否存在
	declare @count as int
	set @count=(select count(*) from otherApplyInfo where otherApplyID= @otherApplyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查状态：
	declare @applyStatus smallint	--单据状态：0->新建未发送，1->发送
	select @applyStatus = applyStatus 
	from otherApplyInfo 
	where otherApplyID= @otherApplyID
	if (@applyStatus=1)
	begin
		set @Ret = 3
		return
	end

	delete otherApplyInfo where otherApplyID= @otherApplyID
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除其他申请', '用户' + @delManName
												+ '删除了其他申请['+@otherApplyID+']。')

GO

/*
号码发生器：
        LeaveRequestCode = 300, //请假条编号
        EqpApplyCode = 301,     //设备采购申请编号
        ThesisPublishApplyCode = 302,   //论文发表申请编号
        ProcessApplyCode = 303, //车间加工申请编号
        OtherApplyCode = 304,   //其他申请编号
*/


--其他申请列表查询语句：
select t.otherApplyID, t.applyStatus, t.applyManID, t.applyMan, 
CONVERT(varchar(10), t.applyTime,120) applyTime, t.title, t.summary, t.keys
from otherApplyInfo t

select t.otherApplyID, t.applyStatus, t.applyManID, t.applyMan, 
CONVERT(varchar(10), t.applyTime,120) applyTime, t.title, t.summary, t.keys
 from otherApplyInfo t
 where t.otherApplyID ='" + otherApplyID + "'


select * from processApplyInfo
select * from workFlowInstance
where LEFT(instanceID,2)='JG'


select * from eqpApplyDetail
select * from eqpApplyInfo



select * from workFlowTemplateFlow
