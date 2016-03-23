use newfTradeDB2
/*
	武大外贸合同管理信息系统--合同管理
	author:		卢苇
	CreateDate:	2012-3-1
	UpdateDate: 
*/
/*备忘：
1.userInfo数据库要扩展加入电话
2.要重新设计一个登录用的用户库
*/

update contractInfo
set event2Manager='N'

select * from sysUserInfo where sysUserName='fjc'
where contractStatus in (0,1) and contractStatus<>9
order by contractStatus, curNode, curLeftDays

select * from contractFlow
select * from contractInfo where contractStatus = 9

select dbo.getEqpInfoOfContract('201204060002')
update contractInfo set curLeftDays=2 where contractID='20120015'
update contractInfo set curLeftDays=-2 where contractID='20120025'
select * from contractFlow where contractID='20120015'
update contractFlow set curLeftDays = 3 where contractID='20120015' and nodeNum=1
select * from sysUserInfo where sysUserName='fjc'
select * from sysUserInfo where sysUserName='ab'
update sysUserInfo set sysPassword='9369A71B2CA05876A068A505462AD673' where sysUserName='ab'

--合同列表：
select contractStatus, isnull(ci.curLeftDays,0) curNodeLeftDays, ci.contractID, curNode, curNodeName,
	--设备信息：
	dbo.getEqpInfoOfContract(ci.contractID) eqpInfo,
	--订货信息：
	totalAmount, currency, cd.objDesc currencyName,
	dbo.getClgInfoOfContract(ci.contractID) clgInfo,
	dbo.getClgInfoOfContract(ci.contractID) userIDInfo,
	dbo.getClgInfoOfContract(ci.contractID) userInfo,
	--供货单位：
	supplierID, supplierName, supplierOprMan, supplierOprManMobile, supplierOprManTel, convert(varchar(10),supplierSignedTime,120) supplierSignedTime,
	--委托外贸公司：
	traderID, abbTraderName, traderName, traderOprMan, traderOprManMobile, traderOprManTel, convert(varchar(10),traderSignedTime,120) traderSignedTime,
	--主要环节状态：
	case f1.nStatus when 0 then '' when 1 then cast(f1.curLeftDays as varchar(10)) when -1 then '←' when 9 then '√' end nodeSignProtocol,
	case f3.nStatus when 0 then '' when 1 then cast(f3.curLeftDays as varchar(10)) when -1 then '←' when 9 then '√' end nodePay,
	case f4.nStatus when 0 then '' when 1 then cast(f4.curLeftDays as varchar(10)) when -1 then '←' when 9 then '√' end nodeTaxFree,
	case f5.nStatus when 0 then '' when 1 then cast(f5.curLeftDays as varchar(10)) when -1 then '←' when 9 then '√' end nodeDeclaration,
    case f6.nStatus when 0 then '' when 1 then cast(f6.curLeftDays as varchar(10)) when -1 then '←' when 9 then '√' end nodeCommit,
    case f7.nStatus when 0 then '' when 1 then cast(f7.curLeftDays as varchar(10)) when -1 then '←' when 9 then '√' end nodeAccept,
    case f8.nStatus when 0 then '' when 1 then cast(f8.curLeftDays as varchar(10)) when -1 then '←' when 9 then '√' end nodeAccount,
	--监控:
	dbo.getTimeoutOfContract(ci.contractID) timeoutRecord, dbo.getEventOfContract(ci.contractID,'00011275') haveEvent,
    dbo.getDiscussStatusOfContract(ci.contractID,'00011275') haveMsg,
    --主要事件：
	paymentMode, cd2.objDesc paymentModeDesc, goodsArrivalTime,
	convert(varchar(10),acceptedTime,120) acceptedTime, convert(varchar(10),completedTime,120) completedTime, notes,
    convert(varchar(10),ci.startTime,120) startTime
from contractInfo ci left join codeDictionary cd on ci.currency = cd.objCode and cd.classCode=3 
	left join codeDictionary cd2 on ci.paymentMode = cd2.objCode and cd2.classCode=4 
	left join contractFlow f1 on ci.contractID = f1.contractID and f1.nodeName ='签订协议'
    left join contractFlow f3 on ci.contractID = f3.contractID and f3.nodeName ='开证付款'
    left join contractFlow f4 on ci.contractID = f4.contractID and f4.nodeName ='办理免表'
    left join contractFlow f5 on ci.contractID = f5.contractID and f5.nodeName ='报关'
    left join contractFlow f6 on ci.contractID = f6.contractID and f6.nodeName ='送交材料'
    left join contractFlow f7 on ci.contractID = f7.contractID and f7.nodeName ='验收'
    left join contractFlow f8 on ci.contractID = f8.contractID and f8.nodeName ='结清余款'
where  cast(dbo.getEventOfContract(ci.contractID,'00009661') as varchar(max)) <> '<root/>' and contractStatus<>9
order by contractStatus, curNodeLeftDays, curNode                
select * from userInfo where jobNumber='00009661'
select * from country
select * from contractInfo

select * from contractInfo where contractID='20130255'
select * from contractFlow
select * from flowTempletNode
--1.外贸合同单：
drop TABLE contractInfo
CREATE TABLE contractInfo
(
	contractID varchar(12) not null,	--主键：合同编号，使用第 1 号号码发生器产生
	contractStatus int default(0),		--合同状态:0->合同刚定义，未启动，1->在线合同，9->已完成合同
	curNode int null,					--当前执行节点编号
	curNodeName nvarchar(30) null,		--当前执行节点名称：冗余设计
	curLeftDays int null,				--当前节点剩余时间(天)，由数据库计算程序每天计算
	
/*	--订货单位：根据客户意见要求支持1对多的关系，改成外挂表
	clgCode char(3) not null,			--学院代码
	clgName nvarchar(30) null,			--学院名称:冗余设计，保存历史数据 add by lw 2010-11-30
	oprMan nvarchar(30) null,			--订货单位经办人
	oprManMobile varchar(30) null,		--订货单位经办人联系电话，手机
	oprManTel varchar(30) null,			--订货单位经办人联系电话，其他电话
	
	根据2012-4-1讨论，设备应该可以是多种，改为外挂表
	eName nvarchar(30) not null,		--设备名称
	eFormat nvarchar(20) not null,		--型号规格
	cCode char(3) not null,				--原产地（国家代码）
	quantity int not null,				--数量
	price money null,					--单价，>0
*/

	--供货单位：
	supplierID varchar(12) not null,	--供货单位编号
	supplierName nvarchar(30) null,		--供货单位名称：冗余设计，保存历史数据 add by lw 2012-3-27
	supplierOprManID varchar(18) null,	--供货单位经办人ID
	supplierOprMan nvarchar(30) null,	--供货单位经办人：冗余设计，保存历史数据 add by lw 2012-3-27
	supplierOprManMobile varchar(30) null,	--供货单位经办人联系电话，手机：冗余设计，保存历史数据 add by lw 2012-3-27
	supplierOprManTel varchar(30) null,	--供货单位经办人联系电话，其他电话：冗余设计，保存历史数据 add by lw 2012-3-27
	supplierSignedTime smalldatetime null,	--签约时间
	
	--委托外贸公司及经办人
	traderID varchar(12) not null,		--外贸公司编号
	traderName nvarchar(30) null,		--外贸公司名称：冗余设计，保存历史数据 add by lw 2012-3-27
	abbTraderName nvarchar(6) null,		--外贸公司简称:冗余设计，add by lw 2012-4-27根据客户要求增加
	traderOprManID varchar(18) null,	--外贸公司经办人ID
	traderOprMan nvarchar(30) null,		--外贸公司经办人：冗余设计，保存历史数据 add by lw 2012-3-27
	traderOprManMobile varchar(30) null,--外贸公司经办人联系电话，手机：冗余设计，保存历史数据 add by lw 2012-3-27
	traderOprManTel varchar(30) null,	--外贸公司经办人联系电话，其他电话：冗余设计，保存历史数据 add by lw 2012-3-27
	traderSignedTime smalldatetime null,--委托时间
	
	totalAmount money null,				--设备总价
	currency smallint not null,			--币种,由第3号代码字典定义
	dollar money null,					--折合美元
	payFee money default(0),			--实付手续费（人民币）：按分段计算（费率固定），20万美元以上议价	add by lw 2013-6-12
	paymentMode smallint not null,		--付款方式, 由第4号代码字典定义
	goodsArrivalTime smalldatetime null,--预计到货时间
	realGoodsArrivalTime smalldatetime null,--实际到货时间

/*	根据2012-4-1讨论，删除招标中心联系人信息：	
	tenderingCenterOprManID varchar(10) null,--招标中心（？经办人）ID:采用工号
	tenderingCenterOprMan nvarchar(30) null,--招标中心（？经办人）：冗余设计，保存历史数据 add by lw 2012-3-27
	tenderingCenterOprManMobile varchar(30) null,	--招标中心经办人联系电话，手机：冗余设计，保存历史数据 add by lw 2012-3-27
	tenderingCenterOprManTel varchar(30) null,	--招标中心经办人联系电话，其他电话：冗余设计，保存历史数据 add by lw 2012-3-27
*/
						--受理招投标中心订货协议
	acceptedTime smalldatetime null,	--受理时间(签约时间)（这个需要客户这是招标中心传递合同的时间，时间写在原始合同上，客户确认不用显式登记）
	startTime smalldatetime null,		--合同启动时间 add by lw 2012-5-8 客户提出前4个要监控的时间都是以启动时间为开始时间的天数
	completedTime smalldatetime null,	--归档时间
	notes nvarchar(500) null,			--备注
	
	event2Manager char(1) default('N'),	--是否有设备处管理人员需要处理的事件：当外贸公司上传了附件和有流程变更批复时，生成要处理的事件。add by lw 2012-4-24 从流程表中移入 by lw 2012-5-9
	event2ManagerType smallint default(0),	--给管理人员的事件类别：1->通知，仅需要浏览，2->有新的附件，需要审阅并检查是否是否完成本环节，3->有流程变更需要批复
	event2ManagerText nvarchar(100) null,	--给管理人员的事件内容
	event2ManagerTime smalldatetime null,	--给管理人员的事件生成事件
	event2Trader char(1) default('N'),	--是否有外贸公司需要处理的事件：当环节流转发生时、环节超期提醒和流程变更审批后时，生成要处理的事件。add lw 2012-5-9
	event2TraderType smallint default(0),	--给外贸公司的事件类别：1->通知，仅需要浏览，2->环节超期，需要上传完成的工作附件
	event2TraderText nvarchar(100) null,	--给外贸公司的事件内容
	event2TraderTime smalldatetime null,	--给外贸公司的事件生成事件
	event2ClgMan char(1) default('N'),	--是否有订货单位需要处理的事件：当流程变更申请时，生成要处理的事件。add lw 2012-5-9
	event2ClgManType smallint default(0),	--给订货单位的事件类别：1->通知，仅需要浏览，3->有流程变更需要批复
	event2ClgManText nvarchar(100) null,	--给订货单位的事件内容
	event2ClgManTime smalldatetime null,	--给订货单位的事件生成事件

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName varchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号

 CONSTRAINT [PK_contractInfo] PRIMARY KEY CLUSTERED 
(
	[contractID] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
CREATE NONCLUSTERED INDEX [IX_contractInfo] ON [dbo].[contractInfo] 
(
	[completedTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--2.外贸合同订货单位表：
--根据2012年4月28日会议决定将订货单位与订货人关系改成一对多关系，将订货设备改成与订货人挂接
--院部简称	add by lw 2012-5-19根据客户要求增加
select contractID, clgCode, clgName, abbClgName, ordererID, orderer, ordererMobile, ordererTel
from contractCollege

drop TABLE contractCollege
CREATE TABLE contractCollege
(
	contractID varchar(12) not null,	--主键：合同编号
	clgCode char(3) not null,			--主键：学院代码
	clgName nvarchar(30) null,			--学院名称:冗余设计，保存历史数据
	abbClgName nvarchar(6) null,		--院部简称	add by lw 2012-5-19根据客户要求增加
/*	根据2012-4-1讨论，订货单位只管理到二级单位（院部）
	uCode varchar(8) not null,			--主键：使用单位代码
	uName nvarchar(30) not null,		--使用单位名称	
*/	
	ordererID varchar(10) not null,		--主键：订货人ID
	orderer nvarchar(30) not null,		--冗余设计：订货人姓名 add by lw 2013-5-5
	ordererMobile varchar(30) null,		--订货单位经办人联系电话，手机:冗余设计，保存历史数据
	ordererTel varchar(30) null,			--订货单位经办人联系电话，其他电话:冗余设计，保存历史数据
	
 CONSTRAINT [PK_contractCollege] PRIMARY KEY CLUSTERED 
(
	[contractID] desc,
	[clgCode] asc,
	[ordererID] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[contractCollege] WITH CHECK ADD CONSTRAINT [FK_contractCollege_contractInfo] FOREIGN KEY([contractID])
REFERENCES [dbo].[contractInfo] ([contractID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[contractCollege] CHECK CONSTRAINT [FK_contractCollege_contractInfo] 
GO

--索引：
CREATE NONCLUSTERED INDEX [IX_contractCollege] ON [dbo].[contractCollege] 
(
	[contractID] asc,
	[ordererMobile] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


select * from contractEqp
--3.外贸合同订货设备表：
--根据2012年4月28日会议决定将订货单位与订货人关系改成一对多关系，将订货设备改成与订货人挂接
drop TABLE contractEqp
CREATE TABLE contractEqp
(
	rowNum bigint IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,	--行号：保证正确顺序
	contractID varchar(12) not null,	--主键：合同编号
	clgCode char(3) not null,			--主键：学院代码	--根据武大要求，将订货设备与订货单位关联add by lw 2012-5-8
	clgName nvarchar(30) null,			--学院名称:冗余设计，保存历史数据
	ordererID varchar(10) not null,		--主键：订货人ID
	orderer nvarchar(30) not null,		--冗余设计：订货人姓名 add by lw 2013-5-5
	eName nvarchar(30) not null,		--主键：设备名称
	eFormat nvarchar(20) not null,		--主键：型号规格
	cCode char(3) not null,				--原产地（国家代码）
	quantity int not null,				--数量
	price money null,					--单价，>0
	
 CONSTRAINT [PK_contractEqp] PRIMARY KEY CLUSTERED 
(
	[contractID] desc,
	[rowNum] asc,
	[clgCode] asc,
	[ordererID] asc,
	[eName] asc,
	[eFormat] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


--外键：
ALTER TABLE [dbo].[contractEqp]  WITH CHECK ADD  CONSTRAINT [FK_contractEqp_contractCollege] FOREIGN KEY([contractID], [clgCode],[ordererID])
REFERENCES [dbo].[contractCollege] ([contractID], [clgCode],[ordererID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[contractEqp] CHECK CONSTRAINT [FK_contractEqp_contractCollege]
GO


--4.外贸合同执行流程表：
drop TABLE contractFlow
CREATE TABLE contractFlow
(
	contractID varchar(12) not null,	--主键：合同编号
	nodeNum int not null,				--主键：节点序号
	nodeName nvarchar(30) not null,		--节点名称
	startTimeType varchar(30) default('lastNodeCompleted'),--起算时间类型:'startTime'从流程开始时间，
																		--'lastNodeCompleted'->上一节点完成日期，
																		--'goodsArrivalTime'->到货时间
	nodeDays int not null,				--节点允许时间（天）
	curLeftDays int null,				--节点剩余时间(天)，由数据库计算程序每天计算 add by lw 2012-4-19
	startTime smalldatetime null,		--节点开始时间
	endTime smalldatetime null,			--节点完成时间
	nStatus int default(0),				--节点状态：0->未启动，1->到达，-1->返回上一节点，9->完成
	undoneChange int default(0),		--是否有未完成的变更：0->没有，1->有 add by lw 2013-10-15
	--超期记录：
	yellowLampTimes smallint default(0),--黄灯次数
	redLampTimes smallint default(0),	--红灯次数
	SMSTimes smallint default(0),		--短信次数
 CONSTRAINT [PK_contractFlow] PRIMARY KEY CLUSTERED 
(
	[contractID] desc,
	[nodeNum] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[contractFlow] WITH CHECK ADD CONSTRAINT [FK_contractFlow_contractInfo] FOREIGN KEY([contractID])
REFERENCES [dbo].[contractInfo] ([contractID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[contractFlow] CHECK CONSTRAINT [FK_contractFlow_contractInfo] 
GO

--5.外贸合同附件表：
drop TABLE contractAttachment
CREATE TABLE contractAttachment
(
	rowNum int IDENTITY(1,1) NOT NULL,	--主键:行号
	contractID varchar(12) not null,	--外键：合同编号
	attachmentType smallint not null,	--附件类型：由第5号代码字典定义
	aFilename varchar(128) not NULL,	--主键：图片文件对应的36位全球唯一编码文件名
	notes nvarchar(100) null,			--说明
 CONSTRAINT [PK_contractAttachment] PRIMARY KEY CLUSTERED 
(
	[aFilename] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[contractAttachment] WITH CHECK ADD CONSTRAINT [FK_contractAttachment_contractInfo] FOREIGN KEY([contractID])
REFERENCES [dbo].[contractInfo] ([contractID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[contractAttachment] CHECK CONSTRAINT [FK_contractAttachment_contractInfo] 
GO

--索引：
CREATE NONCLUSTERED INDEX [IX_contractAttachment] ON [dbo].[contractAttachment] 
(
	[contractID] asc,
	[attachmentType] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--6.外贸合同流程环节提醒短信表：
drop TABLE contractSMS
CREATE TABLE contractSMS
(
	rowNum int IDENTITY(1,1) NOT NULL,	--主键:行号
	contractID varchar(12) not null,	--合同编号
	mobile varchar(30) not null,		--手机号
	msg nvarchar(100) null,				--短信
	isSend char(1) default('N')			--是否发送
	
 CONSTRAINT [PK_contractSMS] PRIMARY KEY CLUSTERED 
(
	[rowNum] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

/*
--外键：使用外键会删除历史信息！
ALTER TABLE [dbo].[contractSMS] WITH CHECK ADD CONSTRAINT [FK_contractSMS_contractInfo] FOREIGN KEY([contractID])
REFERENCES [dbo].[contractInfo] ([contractID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[contractSMS] CHECK CONSTRAINT [FK_contractSMS_contractInfo] 
GO
*/

--7.外贸合同变更申请表：
drop TABLE contractFlowChange
CREATE TABLE contractFlowChange
(
	flowChangeApplyID varchar(12) not null,	--主键：变更申请单号，使用第 3 号号码发生器产生
	applyStatus smallint default(0),	--变更申请状态：-1->作废的变更：比如环节退回时自动作废，
														--0->编辑中，未发送，1->已发送，等待回复，2->已接收回复，同意变更，等待审核，
														--3->回复意见不同意变更，8->已审核，同意变更，9->已审核，不同意变更，10：完成变更
														
	contractID varchar(12) not null,	--外键：合同编号
	applicantType smallint not null,	--申请人类型（用户类别）：由101号代码字典定义
	applicantID varchar(10) not null,	--申请人ID
	applicantName nvarchar(30) not null,--申请人姓名
	applyDate smalldatetime not null,	--申请变更日期
	applyChangeFlowNode varchar(30) not null,--申请变更的环节
	applyReason nvarchar(300) not null,	--申请变更理由

	--如果存在多个接受人需要将此移出到外挂表：	
	recipientID varchar(10) not null,	--变更接收人ID
	recipient nvarchar(30) not null,	--变更接收人姓名
	replyDate smalldatetime not null,	--回复日期
	replyDesc nvarchar(300) not null,	--回复说明
	
	checkerID varchar(10) null,			--核准人ID
	checker nvarchar(30) null,			--核准人姓名
	checkDate smalldatetime null,		--核准日期
	checkDesc nvarchar(300) null,		--核准与否意见
	
	changeDate smalldatetime null,		--处理日期
	
 CONSTRAINT [PK_contractFlowChange] PRIMARY KEY CLUSTERED 
(
	[flowChangeApplyID] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[contractFlowChange] WITH CHECK ADD CONSTRAINT [FK_contractFlowChange_contractInfo] FOREIGN KEY([contractID])
REFERENCES [dbo].[contractInfo] ([contractID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[contractFlowChange] CHECK CONSTRAINT [FK_contractFlowChange_contractInfo]
GO




drop FUNCTION getClgInfoOfContract
/*
	name:		getClgInfoOfContract
	function:	1.根据外贸合同编号获取指定合同的订货单位
	input: 
				@contractID varchar(12)	--合同编号
	output: 
				return xml				--用xml方式存储的订货单位列表
	author:		卢苇
	CreateDate:	2012-3-28
	UpdateDate: 
*/
create FUNCTION getClgInfoOfContract
(  
	@contractID varchar(12)	--合同编号
)  
RETURNS xml
WITH ENCRYPTION
AS      
begin
	declare @result as xml
	SET @result = (SELECT distinct contractID, clgCode, clgName, isnull(abbClgName,clgName) abbClgName 
					FROM contractCollege where contractID = @contractID FOR XML auto, TYPE)
	set @result = N'<root>' + convert(varchar(max), @result) + N'</root>'
	return @result
end
--测试：
select dbo.getClgInfoOfContract('20120012')
select * from contractInfo
select * from college


drop FUNCTION getOrdererInfoOfContract
/*
	name:		getOrdererInfoOfContract
	function:	1.1.根据外贸合同编号和单位代码获取指定合同的订货人
	input: 
				@contractID varchar(12)	--合同编号
				@clgCode char(3)		--单位代码
	output: 
				return xml				--用xml方式存储的订货人
	author:		卢苇
	CreateDate:	2012-5-5
	UpdateDate: 
*/
create FUNCTION getOrdererInfoOfContract
(  
	@contractID varchar(12),	--合同编号
	@clgCode char(3)			--单位代码
)  
RETURNS xml
WITH ENCRYPTION
AS      
begin
	declare @result as xml
	SET @result = (SELECT contractID, clgCode, clgName, isnull(abbClgName,clgName) abbClgName, orderer, ordererMobile, ordererTel
					FROM contractCollege where contractID = @contractID and clgCode=@clgCode FOR XML auto, TYPE)
	set @result = N'<root>' + convert(varchar(max), @result) + N'</root>'
	return @result
end
--测试：
select dbo.getOrdererInfoOfContract('20130003','031')
select * from contractInfo
select * from college


drop FUNCTION getClgEqpInfoOfContract
/*
	name:		getClgEqpInfoOfContract
	function:	1.1.根据外贸合同编号获取指定合同的订货单位与订货设备
	input: 
				@contractID varchar(12)	--合同编号
	output: 
				return xml				--用xml方式存储的订货单位与订货设备列表
	author:		卢苇
	CreateDate:	2012-5-9
	UpdateDate: 
*/
create FUNCTION getClgEqpInfoOfContract
(  
	@contractID varchar(12)	--合同编号
)  
RETURNS xml
WITH ENCRYPTION
AS      
begin
	declare @result as xml
	SET @result = (select * from contractCollege 
					left join (SELECT contractID, clgCode, clgName, ordererID, orderer, eName, eFormat, e.cCode cCode, c.cName cName, quantity, price
								FROM contractEqp e left join country c on e.cCode=c.cCode 
									where contractID = @contractID) as contractEqp on contractCollege.clgCode = contractEqp.clgCode
					where contractCollege.contractID = @contractID
					FOR XML auto, TYPE)
	set @result = N'<root>' + convert(varchar(max), @result) + N'</root>'
	return @result
end
--测试：
select dbo.getClgEqpInfoOfContract('20120001')
select * from contractInfo


drop FUNCTION getTimeoutOfContract
/*
	name:		getTimeoutOfContract
	function:	1.2.根据外贸合同编号获取指定合同的警告记录
	input: 
				@contractID varchar(12)	--合同编号
	output: 
				return xml				--用xml方式存储的订货单位列表
	author:		卢苇
	CreateDate:	2013-6-13
	UpdateDate: 
*/
create FUNCTION getTimeoutOfContract
(  
	@contractID varchar(12)	--合同编号
)  
RETURNS xml
WITH ENCRYPTION
AS      
begin
	declare @info as xml, @result as xml
	
	declare @count int
	set @count = (select sum(yellowLampTimes+redLampTimes+SMSTimes) from contractFlow where contractID = @contractID)
	if (@count=0)
		return N'<root />'

	SET @info = (select contractID, curNode, curNodeName, traderID, abbTraderName, traderName, traderOprMan 
					from contractInfo
					where contractID = @contractID
					FOR XML auto, TYPE)

	SET @result = (select nodeName, nStatus, yellowLampTimes, redLampTimes, SMSTimes 
					from contractFlow
					where contractID = @contractID and nodeNum < 5 
					order by nodeNum FOR XML auto, TYPE)
	set @result = N'<root>' + convert(varchar(max), @info) + convert(varchar(max), @result) + N'</root>'
	return @result
end
--测试：
select dbo.getTimeoutOfContract('20120046')
select * from contractInfo
select * from college

drop FUNCTION getEqpInfoOfContract
/*
	name:		getEqpInfoOfContract
	function:	2.根据外贸合同编号获取指定合同的订货设备
	input: 
				@contractID varchar(12)	--合同编号
	output: 
				return xml				--用xml方式存储的订货设备列表
	author:		卢苇
	CreateDate:	2012-4-4
	UpdateDate: 
*/
create FUNCTION getEqpInfoOfContract
(  
	@contractID varchar(12)	--合同编号
)  
RETURNS xml
WITH ENCRYPTION
AS      
begin
	declare @result as xml
	SET @result = isnull((select * from (SELECT contractID, clgCode, clgName, ordererID, orderer, eName, eFormat, e.cCode cCode, c.cName cName, quantity, price
										FROM contractEqp e left join country c on e.cCode=c.cCode 
										where contractID = @contractID) as contractEqp
							FOR XML auto, TYPE),'');
	set @result = N'<root>' + convert(varchar(max), @result) + N'</root>'
	return @result
end
--测试：
select dbo.getEqpInfoOfContract('20120011')


drop FUNCTION getAttachmentOfContract
/*
	name:		getAttachmentOfContract
	function:	3.根据外贸合同编号获取指定合同的附件
	input: 
				@contractID varchar(12)	--合同编号
	output: 
				return xml				--用xml方式存储的订货设备列表
	author:		卢苇
	CreateDate:	2012-4-24
	UpdateDate: 
*/
create FUNCTION getAttachmentOfContract
(  
	@contractID varchar(12)	--合同编号
)  
RETURNS xml
WITH ENCRYPTION
AS      
begin
	declare @result as xml
	SET @result = isnull((SELECT * FROM contractAttachment where contractID = @contractID order by rowNum FOR XML auto, TYPE),'');
	set @result = N'<root>' + convert(varchar(max), @result) + N'</root>'
	return @result
end
--测试：
select dbo.getAttachmentOfContract('20120025')

select * from contractInfo

drop FUNCTION getEventOfContract
/*
	name:		getEventOfContract
	function:	4.根据外贸合同编号和用户ID获取指定合同的事件
	input: 
				@contractID varchar(12),--合同编号
				@userID varchar(10),	--用户识别号
	output: 
				return xml				--用xml方式存储的事件
	author:		卢苇
	CreateDate:	2012-5-9
	UpdateDate: modi by lw 2013-10-07增加约束条件
*/
create FUNCTION getEventOfContract
(  
	@contractID varchar(12),	--合同编号
	@userID varchar(10)			--用户识别号
)  
RETURNS xml
WITH ENCRYPTION
AS      
begin
	declare @userType int	--用户类别：由101号代码字典定义
	set @userType = isnull((select userType from sysUserInfo where userID = @userID),0)
	if (@userType=1)	--进一步判断是否设备处管理人员
	begin
		declare @clgCode char(3) --院部代码
		set @clgCode = isnull((select clgCode from userInfo where jobNumber = @userID),'')
		if (@clgCode = '000')
			set @userType = 101
		else
			set @userType = 102
	end

	declare @haveEvent char(1)
	declare @result as xml
	if (@userType = 101)
	begin
		set @haveEvent = isnull((select event2Manager from contractInfo where contractID = @contractID),'N')
		if (@haveEvent='Y')
			SET @result = isnull((SELECT contractID, event2ManagerType eventType, event2ManagerText eventText, 
								  convert(varchar(19),event2ManagerTime,120) eventTime
								  FROM contractInfo where contractID = @contractID FOR XML auto, TYPE),'');
		else
			set @result = ''
	end
	else if (@userType = 102)
	begin
		set @haveEvent = isnull((select event2ClgMan from contractInfo where contractID = @contractID),'N')
		if (@haveEvent='Y')
			SET @result = isnull((SELECT c.contractID, c.event2ClgManType eventType, c.event2ClgManText eventText, 
								  convert(varchar(19),c.event2ClgManTime,120) eventTime
								  FROM contractInfo c left join contractCollege clg on c.contractID= clg.contractID
								  where c.contractID = @contractID and clg.ordererID=@userID FOR XML auto, TYPE),'');
		else
			set @result = ''
	end
	else if (@userType = 3)
	begin
		declare @traderID varchar(12)	--外贸公司编号
		set @traderID = (select traderID from traderManInfo where manID = @userID)
		set @haveEvent = isnull((select event2Trader from contractInfo where contractID = @contractID),'N')
		if (@haveEvent='Y')
			SET @result = isnull((SELECT contractID, event2TraderType eventType, event2TraderText eventText, 
								  convert(varchar(19),event2TraderTime,120) eventTime
								  FROM contractInfo where contractID = @contractID and traderID=@traderID FOR XML auto, TYPE),'');
		else
			set @result = ''
	end
	else
		set @result = ''
	set @result = N'<root>' + convert(varchar(max), @result) + N'</root>'
	return @result
end
--测试：
select dbo.getEventOfContract('20120067','00000891')
select * from contractInfo
select userType from sysUserInfo where userID = '201204230009'
select * from contractCollege

drop FUNCTION getDiscussStatusOfContract
/*
	name:		getDiscussStatusOfContract
	function:	5.根据外贸合同编号和用户ID获取是否有未阅读的讨论意见
	input: 
				@contractID varchar(12),--合同编号
				@userID varchar(10),	--用户识别号
	output: 
				return varchar(12)		--'XXXX'档案号：有未阅读的讨论意见，''：没有未阅读的讨论意见
	author:		卢苇
	CreateDate:	2012-5-9
	UpdateDate: 
*/
create FUNCTION getDiscussStatusOfContract
(  
	@contractID varchar(12),	--合同编号
	@userID varchar(10)			--用户识别号
)  
RETURNS varchar(12)
WITH ENCRYPTION
AS      
begin
	declare @updateTime datetime, @readTime datetime 		--更新时间，阅读时间
	set @updateTime = (select top 1 discussTime from discussInfo where contractID = @contractID order by discussTime desc)
	set @readTime = (select readerTime from discussReadInfo where contractID = @contractID and readerID = @userID)
	
	if (@updateTime is null)
		return ''
	if (@readTime is null)
		return @contractID
	if (@readTime < @updateTime)
		return @contractID
	
	return ''
end
--测试：
select dbo.getDiscussStatusOfContract('20120067','00000008')
select * from contractEqp where contractID='20120068'

drop PROCEDURE addContractInfo
/*
	name:		addContractInfo
	function:	1.添加外贸合同
				注意：该存储过程自动锁定单据
	input: 
				@contractID varchar(12) output,	--主键：合同编号，使用第 1 号号码发生器产生
				--订货单位信息/订货设备信息（可能有多条）：
				@clgInfo xml,	--采用如下方式存放:
									N'<root>
									  <contractCollege clgCode="123" jobNumber="00000891" oprManMobile="18602702392">
											<contractEqp contractID="201203280001" eName="Sony巨型计算机" eFormat="100Cpu" cCode="392" quantity="4" price="1000.0000" />
									  </contractCollege>
									  <contractCollege clgCode="124" jobNumber="00000906" oprManMobile="18602702391">
											<contractEqp contractID="201203280001" eName="IBM巨型计算机" eFormat="300Cpu" cCode="392" quantity="1" price="2000.0000" />
											<contractEqp contractID="201203280001" eName="HP巨型计算机" eFormat="200Cpu" cCode="392" quantity="5" price="3000.0000" />
									  </contractCollege>
									</root>'

				--供货单位：
				@supplierID varchar(12),		--供货单位编号
				@supplierOprManID varchar(18),	--供货单位经办人ID
				@supplierOprManMobile varchar(30),	--供货单位经办人联系电话，手机：冗余设计，保存历史数据 add by lw 2012-3-27
				--@supplierSignedTime varchar(10),--签约时间:采用“yyyy-MM-dd”存放的日期数据
				
				--委托外贸公司及经办人
				@traderID varchar(12),			--外贸公司编号
				@traderOprManID varchar(18),	--外贸公司经办人ID
				@traderOprManMobile varchar(30),--外贸公司经办人联系电话，手机：冗余设计，保存历史数据 add by lw 2012-3-27
				--@traderSignedTime varchar(10),	--委托时间:采用“yyyy-MM-dd”存放的日期数据
				

				@totalAmount money,				--设备总价
				@currency smallint,				--币种,由第3号代码字典定义
				@dollar money,					--折合美元
				@paymentMode smallint,			--付款方式, 由第4号代码字典定义
				@goodsArrivalTime varchar(10),	--预计到货时间：采用“yyyy-MM-dd”存放的日期数据
									--受理招投标中心订货协议
				@acceptedTime varchar(10),		--受理时间:采用“yyyy-MM-dd”存放的日期数据
				@notes nvarchar(500),			--备注
				
				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output	--添加时间
	author:		卢苇
	CreateDate:	2012-3-30
	UpdateDate: 根据客户需求，设备与合同为一对多关系，流程为固定模式，调整接口 by lw 2012-4-8
				根据客户要求，在登记合同中可以临时修改手机号码，调整接口,并将设备总价和折算美元放在外部计算 by lw 2012-4-24
				根据客户要求，将订货单位与订货设备关联；合同编号改成可以手工输入。by lw 2012-5-8
				修改手工输入号码带来的可能有重号的错误 by lw 2012-5-10
				modi by lw 2012-5-21增加xml中特殊字符"<>"的处理

*/
create PROCEDURE addContractInfo
	@contractID varchar(12) output,	--主键：合同编号，使用第 1 号号码发生器产生
	--订货单位信息（可能有多条）：
	@clgInfo xml,	

	--供货单位：
	@supplierID varchar(12),		--供货单位编号
	@supplierOprManID varchar(18),	--供货单位经办人ID
	@supplierOprManMobile varchar(30),	--供货单位经办人联系电话，手机：冗余设计，保存历史数据 add by lw 2012-3-27
	--@supplierSignedTime varchar(10),--签约时间:采用“yyyy-MM-dd”存放的日期数据
	
	--委托外贸公司及经办人
	@traderID varchar(12),			--外贸公司编号
	@traderOprManID varchar(18),	--外贸公司经办人ID
	@traderOprManMobile varchar(30),--外贸公司经办人联系电话，手机：冗余设计，保存历史数据 add by lw 2012-3-27
	--@traderSignedTime varchar(10),	--委托时间:采用“yyyy-MM-dd”存放的日期数据
	
	@totalAmount money,				--设备总价
	@currency smallint,				--币种,由第3号代码字典定义
	@dollar money,					--折合美元
	@paymentMode smallint,			--付款方式, 由第4号代码字典定义
	@goodsArrivalTime varchar(10),	--预计到货时间：采用“yyyy-MM-dd”存放的日期数据
						--受理招投标中心订货协议
	@acceptedTime varchar(10),		--受理时间(签约时间):采用“yyyy-MM-dd”存放的日期数据
	@notes nvarchar(500),			--备注

	@createManID varchar(10),	--创建人工号

	@Ret		int output,
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	declare @count int
	if (@contractID<>'')	--检查是否重号
	begin
		set @count = (select count(*) from contractInfo where contractID = @contractID)
		if (@count > 0)
			set @contractID = ''
	end
	set @count = 1
	if (@contractID='')
		while (@count > 0)
		begin
			--使用号码发生器产生新的号码：
			declare @curNumber varchar(50)
			exec dbo.getClassNumber 1, 1, @curNumber output
			set @contractID = @curNumber
			set @count = (select count(*) from contractInfo where contractID = @contractID)
		end
	else if (patindex('%[^0-9]%',@contractID COLLATE  Chinese_PRC_BIN ) = 0)	--判断是否为数字序列
	begin
		declare @sysNumber varchar(30) --号码发生器中当前号码
		set @sysNumber = isnull((select curNumber from sysNumbers where numberClass = 1),'')
		if (@contractID > @sysNumber)
		begin
			update sysNumbers 
			set curNumber = @contractID
			where numberClass = 1
		end
	end

	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	--解析订货单位和订货设备：
	declare @eqpInfoTab as TABLE (
		contractID varchar(12) not null,	--合同编号
		clgCode char(3) not null,			--订货单位：学院代码	--根据武大要求，将订货设备与订货单位关联add by lw 2012-5-8
		ordererID varchar(10) not null,		--主键：订货人ID
		eName nvarchar(30) not null,		--设备名称
		eFormat nvarchar(20) not null,		--型号规格
		cCode char(3) not null,				--原产地（国家代码）
		quantity int not null,				--数量
		price money null					--单价，>0
	)
	insert @eqpInfoTab(contractID, clgCode, ordererID, eName, eFormat, cCode, quantity, price)
	select @contractID, tabXML.clgCode, tabXML.ordererID, REPLACE(REPLACE(tabXML.eName,'&lt;','<'),'&gt;','>'), 
										REPLACE(REPLACE(tabXML.eFormat,'&lt;','<'),'&gt;','>'), tabXML.cCode, tabXML.quantity, tabXML.price
	from (select cast(T.x.query('data(../@clgCode)') as char(3)) clgCode, 
			cast(T.x.query('data(../@jobNumber)') as varchar(10)) ordererID, 
			cast(T.x.query('data(./@eName)') as nvarchar(30)) eName, 
			cast(T.x.query('data(./@eFormat)') as nvarchar(20)) eFormat,
			cast(T.x.query('data(./@cCode)') as char(3)) cCode, 
			cast(cast(T.x.query('data(./@quantity)') as varchar(10)) as int) quantity,
			cast(cast(T.x.query('data(./@price)') as varchar(12)) as money) price
			from (select @clgInfo.query('/root/contractCollege') Col1) A OUTER APPLY A.Col1.nodes('/contractCollege/contractEqp') AS T(x)
	) as tabXML
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end
	
/*	改在外部计算：modi by lw 2012-4-24
	declare @totalAmount money	--总金额
	set @totalAmount = 	isnull((select SUM(quantity * price) from @eqpInfoTab),0)
	--获取汇率,计算折算的美元价格：这里等汇率表设计好后还需要定义！
	declare @dollar money
	set @dollar = @totalAmount
*/

	--获取供货单位信息：
	declare @supplierName nvarchar(30)			--供货单位名称：冗余设计，保存历史数据 add by lw 2012-3-27
	set @supplierName = (select supplierName from supplierInfo where supplierID = @supplierID)
	declare @supplierOprMan	nvarchar(30)	--供货单位经办人：冗余设计，保存历史数据 add by lw 2012-3-27
	declare @supplierOprManTel varchar(30)	--供货单位经办人联系电话，其他电话：冗余设计，保存历史数据 add by lw 2012-3-27
	select @supplierOprMan = manName, @supplierOprManTel = tel
	from supplierManInfo where supplierID = @supplierID and manID = @supplierOprManID
	
	--获取外贸公司信息：
	declare @traderName nvarchar(30)		--外贸公司名称：冗余设计，保存历史数据 add by lw 2012-3-27
	declare @abbTraderName nvarchar(6)		--外贸公司简称	add by lw 2012-4-27根据客户要求增加
	select @traderName = traderName, @abbTraderName = abbTraderName 
	from traderInfo 
	where traderID = @traderID
	
	declare @traderOprMan nvarchar(30)		--外贸公司经办人：冗余设计，保存历史数据 add by lw 2012-3-27
	declare @traderOprManTel varchar(30)	--外贸公司经办人联系电话，其他电话：冗余设计，保存历史数据 add by lw 2012-3-27
	select @traderOprMan = manName, @traderOprManTel = tel
	from traderManInfo where traderID = @traderID and manID = @traderOprManID
	
	set @createTime = getdate()
	begin tran
		insert contractInfo(contractID, supplierID, supplierName, 
				supplierOprManID, supplierOprMan, supplierOprManMobile, supplierOprManTel,
				traderID, traderName, abbTraderName, traderOprManID, traderOprMan, traderOprManMobile, traderOprManTel,
				totalAmount, currency, dollar,
				paymentMode, goodsArrivalTime,
				acceptedTime, notes,
				lockManID, modiManID, modiManName, modiTime) 
		values (@contractID, @supplierID, @supplierName, 
				@supplierOprManID, @supplierOprMan, @supplierOprManMobile, @supplierOprManTel,
				@traderID, @traderName, @abbTraderName, @traderOprManID, @traderOprMan, @traderOprManMobile, @traderOprManTel,
				@totalAmount, @currency, @dollar,
				@paymentMode, @goodsArrivalTime, 
				@acceptedTime, @notes,
				@createManID, @createManID, @createManName, @createTime)
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end  
--print '合同主体'
		--登记订货单位信息：
		insert contractCollege(contractID, clgCode, clgName, ordererID, orderer, ordererMobile,ordererTel)
		select @contractID, tabXML.clgCode, clg.clgName, tabXML.jobNumber, ui.cName, tabXML.mobile, '' 
		from (select cast(T.x.query('data(./@clgCode)') as char(3)) clgCode,
				cast(T.x.query('data(./@jobNumber)') as varchar(10)) jobNumber,
				cast(T.x.query('data(./@oprManMobile)') as varchar(30)) mobile
				from (select @clgInfo.query('/root/contractCollege') Col1) A OUTER APPLY A.Col1.nodes('/contractCollege') AS T(x)
			) as tabXML
			left join college clg on tabXML.clgCode = clg.clgCode
			left join userInfo ui on tabXML.jobNumber = ui.jobNumber
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    
--print '订货单位'
		--登记订货设备信息：
		insert contractEqp(contractID, clgCode, ordererID, orderer, clgName, eName, eFormat, cCode, quantity, price)
		select contractID, e.clgCode, e.ordererID, u.cName, clg.clgName, eName, eFormat, cCode, quantity, price 
		from @eqpInfoTab e left join college clg on e.clgCode = clg.clgCode
			left join userInfo u on e.ordererID=u.jobNumber
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
--print '订货设备'
		
		--定制流程：根据客户要求流程不用显式配置，只根据付款方式（货前/货后）做一个小的调整（是否有开证或付款环节）
		--所以流程在合同登记的时候就配置上去！modi by lw 2012-4-8
		if (@paymentMode>10)	--货前付款
		begin
			insert contractFlow(contractID, nodeNum, nodeName,startTimeType,nodeDays)
			select @contractID, nodeNum, nodeName,startTimeType,nodeDays
			from flowTempletNode
			where templetID = '201204010001'
		end
		else					--货后付款
		begin
			insert contractFlow(contractID, nodeNum, nodeName,startTimeType,nodeDays)
			select @contractID, nodeNum, nodeName,startTimeType,nodeDays
			from flowTempletNode
			where templetID = '201204010002'	--这里应该定义一个不同的流程
		end
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		
	commit tran

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加外贸合同', '系统根据用户' + @createManName + 
					'的要求添加了外贸合同[' + @contractID + ']。')
GO
select * from flowTemplet
select * from flowTempletNode
select * from contractFlow
select * from contractInfo
select * from contractCollege
delete contractInfo
--测试：
declare @clgInfo as xml
set @clgInfo = 
N'<root>
  <contractCollege clgCode="123" jobNumber="00000891" oprManMobile="18602702392">
		<contractEqp contractID="201203280001" eName="Sony巨型计算机" eFormat="100Cpu" cCode="392" quantity="4" price="1000.0000" />
  </contractCollege>
  <contractCollege clgCode="124" jobNumber="00000906" oprManMobile="18602702391">
		<contractEqp contractID="201203280001" eName="IBM巨型计算机" eFormat="300Cpu" cCode="392" quantity="1" price="2000.0000" />
		<contractEqp contractID="201203280001" eName="HP巨型计算机" eFormat="200Cpu" cCode="392" quantity="5" price="3000.0000" />
  </contractCollege>
</root>'

declare @Ret int, @createTime smalldatetime, @contractID varchar(12)
set @contractID = ''
exec dbo.addContractInfo @contractID output, @clgInfo,	
	--供货单位：
	'201204240018','G0000039','18602702392',
	--委托外贸公司及经办人
	'201204230009','W0000009','18602702391',
	3200,1,3200,10,	
	'2012-05-29','2012-04-29', '测试数据2',
	'00201314', @Ret output, @createTime output
select @Ret, @createTime, @contractID

update contractInfo set lockManID=''
select * from contractInfo

select * from traderManInfo
select * from contractInfo where contractID='201204060002'
delete contractInfo
update contractInfo set lockManID=''


select * from contractInfo
select * from college
select * from supplierInfo
select * from supplierManInfo

select * from traderInfo
select * from traderManInfo
/*备忘：
1.userInfo数据库要扩展加入电话
2.要重新设计一个登录用的用户库
3.制作添加流程存储过程
4.制作启动流程存储过程
5.制作节点完成存储过程
6.制作归档存储过程
*/

drop PROCEDURE queryContractInfoLocMan
/*
	name:		queryContractInfoLocMan
	function:	2.查询指定合同是否有人正在编辑
	input: 
				@contractID varchar(12),	--合同编号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的合同不存在
				@lockManID varchar(10) output--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2012-3-29
	UpdateDate: 
*/
create PROCEDURE queryContractInfoLocMan
	@contractID varchar(12),	--合同编号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output		--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from contractInfo where contractID = @contractID),'')
	set @Ret = 0
GO


drop PROCEDURE lockContractInfo4Edit
/*
	name:		lockContractInfo4Edit
	function:	3.锁定合同编辑，避免编辑冲突
	input: 
				@contractID varchar(12),	--合同编号
				@lockManID varchar(10) output,	--锁定人，如果当前合同正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的合同不存在，2:要锁定的合同正在被别人编辑，3:该单据已完成
							9：未知错误
	author:		卢苇
	CreateDate:	2012-3-29
	UpdateDate: 
*/
create PROCEDURE lockContractInfo4Edit
	@contractID varchar(12),	--合同编号
	@lockManID varchar(10) output,	--锁定人，如果当前合同正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的合同是否存在
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @contractStatus int
	select @thisLockMan= isnull(lockManID,''), @contractStatus = contractStatus
	from contractInfo 
	where contractID = @contractID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态:
	if (@contractStatus = 9)
	begin
		set @Ret = 3
		return
	end

	update contractInfo
	set lockManID = @lockManID 
	where contractID = @contractID
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定合同编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了合同['+ @contractID +']为独占式编辑。')
GO

drop PROCEDURE unlockContractInfoEditor
/*
	name:		unlockContractInfoEditor
	function:	4.释放合同编辑锁
				注意：本过程不检查合同是否存在！
	input: 
				@contractID varchar(12),	--合同编号
				@lockManID varchar(10) output,	--锁定人，如果当前合同正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2012-3-29
	UpdateDate: 
*/
create PROCEDURE unlockContractInfoEditor
	@contractID varchar(12),	--合同编号
	@lockManID varchar(10) output,	--锁定人，如果当前合同正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from contractInfo where contractID = @contractID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update contractInfo set lockManID = '' where contractID = @contractID
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
	values(@lockManID, @lockManName, getdate(), '释放合同编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了合同['+ @contractID +']的编辑锁。')
GO

drop PROCEDURE updateContractFlow
/*
	name:		updateContractFlow
	function:	5.更新合同执行流程
				注意：该存储过程先删除后添加执行的流程。如果当前节点被删除，合同自动回到初始状态！
				这个存储过程暂未使用，使用前要更新！！！
	input: 
				@contractID varchar(12),--合同编号
				@flow xml,				--采用xml方式存放的流程节点信息
												N'<root>
													<node nodeNum="1" nodeName="办理签订委托代理进口协议" startTimeType="lastNodeCompleted" nodeDays="10" startTime="2012-03-30T13:23:00"/>
													<node nodeNum="2" nodeName="开信用证或付款" startTimeType="lastNodeCompleted" nodeDays="21" />
													<node nodeNum="3" nodeName="办理免表" startTimeType="lastNodeCompleted" nodeDays="33" />
													<node nodeNum="4" nodeName="办理报关单" startTimeType="goodsArrivalTime" nodeDays="0" />
												</root>'
												
				@modiManID varchar(10) output,		--维护人，如果当前合同正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：指定的合同不存在，2：要更新的合同正被别人锁定，3:该单据已经完成，不允许修改，9：未知错误
	author:		卢苇
	CreateDate:	2012-3-30
	UpdateDate: 

*/
create PROCEDURE updateContractFlow
	@contractID varchar(12),	--合同编号
	@flow xml,					--采用xml方式存放的流程节点信息

	--维护人:
	@modiManID varchar(10) output,		--维护人，如果当前合同正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,	--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的合同是否存在
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @contractStatus int
	declare @curNode int
	select @thisLockMan= isnull(lockManID,''), @contractStatus = contractStatus, @curNode = curNode
	from contractInfo 
	where contractID = @contractID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态:
	if (@contractStatus = 9)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	set @updateTime = getdate()
	begin tran
		delete contractFlow where contractID = @contractID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    
		insert contractFlow(contractID, nodeNum, nodeName, startTimeType, nodeDays, startTime, endTime)
		select @contractID, cast(cast(T.x.query('data(./@nodeNum)') as varchar(10)) as int) nodeNum, 
				cast(T.x.query('data(./@nodeName)') as nvarchar(30)) nodeName,
				cast(T.x.query('data(./@startTimeType)') as varchar(30)) startTimeType,
				cast(cast(T.x.query('data(./@nodeDays)') as varchar(10)) as int) nodeDays,
				case cast(T.x.query('data(./@startTime)') as varchar(30)) 
					when '' then null 
					else cast(T.x.query('data(./@startTime)') as varchar(30))
				end startTime,
				case cast(T.x.query('data(./@endTime)') as varchar(30)) 
					when '' then null 
					else cast(T.x.query('data(./@endTime)') as varchar(30))
				end endTime 
				from (select @flow.query('/root/node') Col1) A OUTER APPLY A.Col1.nodes('/node') AS T(x)
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    
		
		--更新合同状态：
		declare @curNodeIsExist int
		declare @nodeName nvarchar(30)	--节点名称
		select @curNodeIsExist = nodeNum, @nodeName = nodeName from contractFlow where contractID=@contractID and nodeNum=@curNode
		if (@contractStatus=0 or @curNode is null or @curNodeIsExist is null)	--如果当前节点被删除，合同自动回到初始状态！
		begin
			update contractInfo
			set contractStatus = 0, curNode = null, curNodeName = null,
				modiManID = @modiManID, modiManName = @modiManName, modiTime = @updateTime
			where contractID = @contractID
			if @@ERROR <> 0 
			begin
				rollback tran
				set @Ret = 9
				return
			end  
		end
		else
		begin
			declare @nodeDays int, @startTimeType varchar(30), @startTime smalldatetime
			select @nodeDays = nodeDays, @startTimeType = startTimeType, @startTime = startTime
			from contractFlow 
			where contractID = @contractID and nodeNum = @curNode

			declare @leftDays int			
			if (@startTimeType='lastNodeCompleted')
				set @leftDays = @nodeDays - DATEDIFF(day, @startTime, @updateTime)
			else if (@startTimeType='goodsArrivalTime')
			begin
				declare @goodsArrivalTime smalldatetime
				set @goodsArrivalTime = (select goodsArrivalTime from contractInfo where contractID = @contractID)
				set @leftDays = DATEDIFF(day, @updateTime,@goodsArrivalTime) + @nodeDays
			end
			
			update contractInfo
			set curNode = @curNode, curNodeName=@nodeName, curLeftDays = @leftDays,
				modiManID = @modiManID, modiManName = @modiManName, modiTime = @updateTime
			where contractID = @contractID
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
	values(@modiManID, @modiManName, @updateTime, '更新合同流程', '用户' + @modiManName 
												+ '更新了合同['+ @contractID +']的流程。')
GO
--测试：
declare @flow xml
set @flow = N'<root>
			<node nodeNum="1" nodeName="办理签订委托代理进口协议" startTimeType="lastNodeCompleted" nodeDays="10" startTime="2012-03-30T13:23:00"/>
			<node nodeNum="2" nodeName="开信用证或付款" startTimeType="lastNodeCompleted" nodeDays="21" />
			<node nodeNum="3" nodeName="办理免表" startTimeType="lastNodeCompleted" nodeDays="33" />
			<node nodeNum="4" nodeName="办理报关单" startTimeType="goodsArrivalTime" nodeDays="0" />
			</root>'
declare @updateTime smalldatetime--更新时间
declare @Ret		int			--操作成功标识
declare @contractID varchar(12)
set @contractID = '20120010'
exec dbo.lockContractInfo4Edit @contractID,'00201314',@Ret output
exec dbo.updateContractFlow @contractID,@flow, '00201314',@updateTime output, @Ret output
exec dbo.unlockContractInfoEditor @contractID,'00201314',@Ret output
select * from contractFlow
select * from contractInfo

update contractInfo set curNode = 5 where contractID = '201203300003'
select * from contractFlow for xml auto

drop PROCEDURE startContractFlow
/*
	name:		startContractFlow
	function:	6.启动合同执行流程
				注意：该存储过程检测编辑锁但不锁定
	input: 
				@contractID varchar(12),	--合同编号

				@modiManID varchar(10) output,		--维护人，如果当前合同正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：指定的合同不存在，2：要启动的合同正被别人锁定，3:该单据已经完成，不允许启动，9：未知错误
	author:		卢苇
	CreateDate:	2012-3-30
	UpdateDate: modi by lw 2012-5-8 增加环节监控起算时间为合同启动时间
				modi by lw 2012-5-9 增加通知事件

*/
create PROCEDURE startContractFlow
	@contractID varchar(12),	--合同编号

	--维护人:
	@modiManID varchar(10) output,		--维护人，如果当前合同正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,	--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的合同是否存在
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @contractStatus int
	select @thisLockMan= isnull(lockManID,''), @contractStatus = contractStatus
	from contractInfo 
	where contractID = @contractID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态:
	if (@contractStatus = 9)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--取节点信息：
	declare @nodeDays int, @startTimeType varchar(30)
	declare @nodeName nvarchar(30)	--节点名称
	select @nodeName = nodeName, @nodeDays = nodeDays, @startTimeType = startTimeType
	from contractFlow 
	where contractID = @contractID and nodeNum = 1

	set @updateTime = GETDATE()
	begin tran
		--计算当前节点的剩余天数：
		declare @leftDays int
		if (@startTimeType='startTime')
			set @leftDays = @nodeDays
		else if (@startTimeType='lastNodeCompleted')
			set @leftDays = @nodeDays
		else if (@startTimeType='goodsArrivalTime')
		begin
			declare @goodsArrivalTime smalldatetime
			set @goodsArrivalTime = (select goodsArrivalTime from contractInfo where contractID = @contractID)
			set @leftDays = DATEDIFF(day, @updateTime,@goodsArrivalTime) + @nodeDays
		end
		
		--更新合同执行流程表状态：
		update contractFlow
		set startTime = @updateTime, curLeftDays = @leftDays,
			nStatus = 1 --节点状态：0->未启动，1->到达，-1->返回上一节点，9->完成
		where contractID = @contractID and nodeNum = 1
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    

		--更新合同信息并生成事件：
		update contractInfo
		set contractStatus = 1, curNode = 1, curNodeName = @nodeName, curLeftDays = @leftDays,
			startTime = @updateTime,
			event2Trader = 'Y', event2TraderType = 1, event2TraderText = '外贸合同['+@contractID+']启动执行了。',
			event2TraderTime = @updateTime,
			event2ClgMan = 'Y', event2ClgManType = 1, event2ClgManText  = '外贸合同['+@contractID+']启动执行了。',
			event2ClgManTime = @updateTime,
			modiManID = @modiManID, modiManName = @modiManName, modiTime = @updateTime
		where contractID = @contractID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end  
		
	commit tran

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '启动合同', '用户' + @modiManName 
												+ '启动了合同['+ @contractID +']的流程。')
GO
--测试：
declare @updateTime smalldatetime--更新时间
declare @Ret		int			--操作成功标识
exec dbo.startContractFlow '20120067','00201314',@updateTime output, @Ret output
select @Ret

select * from contractInfo
select * from contractFlow

drop PROCEDURE stopContractFlow
/*
	name:		stopContractFlow
	function:	6.1.停止合同执行流程
				注意：该存储过程检测编辑锁但不锁定
	input: 
				@contractID varchar(12),		--合同编号

				@modiManID varchar(10) output,	--维护人，如果当前合同正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,--更新时间
				@Ret		int output			--操作成功标识
							0:成功，1：指定的合同不存在，2：要停止的合同正被别人锁定，3:该合同不是正在执行状态，不允许停止，9：未知错误
	author:		卢苇
	CreateDate:	2013-6-8
	UpdateDate: 

*/
create PROCEDURE stopContractFlow
	@contractID varchar(12),		--合同编号

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前合同正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的合同是否存在
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @contractStatus int
	select @thisLockMan= isnull(lockManID,''), @contractStatus = contractStatus
	from contractInfo 
	where contractID = @contractID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态:
	if (@contractStatus <> 1)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--取节点信息：
	declare @nodeDays int, @startTimeType varchar(30)
	declare @nodeName nvarchar(30)	--节点名称
	select @nodeName = nodeName, @nodeDays = nodeDays, @startTimeType = startTimeType
	from contractFlow 
	where contractID = @contractID and nodeNum = 1

	set @updateTime = GETDATE()
	begin tran
		--更新合同执行流程表状态：
		update contractFlow
		set nStatus = -1 --节点状态：0->未启动，1->到达，-1->返回上一节点，9->完成
		where contractID = @contractID and nStatus<>0
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    

		--更新合同信息并生成事件：
		update contractInfo
		set contractStatus = 0, curNode = 1, curNodeName = @nodeName, 
			event2Trader = 'Y', event2TraderType = 1, event2TraderText = '外贸合同['+@contractID+']停止执行了。',
			event2TraderTime = @updateTime,
			event2ClgMan = 'Y', event2ClgManType = 1, event2ClgManText  = '外贸合同['+@contractID+']停止执行了。',
			event2ClgManTime = @updateTime,
			modiManID = @modiManID, modiManName = @modiManName, modiTime = @updateTime
		where contractID = @contractID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end  
		
	commit tran

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '停止合同', '用户' + @modiManName 
												+ '停止了合同['+ @contractID +']的流程。')
GO
--测试：
declare @updateTime smalldatetime--更新时间
declare @Ret		int			--操作成功标识
exec dbo.stopContractFlow '20120001','00201314',@updateTime output, @Ret output
select @Ret

drop PROCEDURE completeContractNode
/*
	name:		completeContractNode
	function:	7.完成合同流程的当前节点,并合同当前节点移动到下一个节点
				注意：该存储过程检测编辑锁但不锁定
	input: 
				@contractID varchar(12),	--合同编号

				@modiManID varchar(10) output,	--维护人，如果当前合同正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：指定的合同不存在，2：要启动的合同正被别人锁定，3:该合同已经完成，不允许前进，9：未知错误
	author:		卢苇
	CreateDate:	2012-3-30
	UpdateDate: modi by lw 2012-5-8 增加环节监控起算时间为合同启动时间,及节点号修改成可能不连续.
				modi by lw 2012-5-9 增加通知事件

*/
create PROCEDURE completeContractNode
	@contractID varchar(12),	--合同编号

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前合同正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的合同是否存在
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @contractStatus int
	select @thisLockMan= isnull(lockManID,''), @contractStatus = contractStatus
	from contractInfo 
	where contractID = @contractID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态:
	if (@contractStatus = 9)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--取下一个节点信息：
	declare @curNode int, @nextNode int	--当前节点号，下一个节点号
	declare @nodeDays int, @startTimeType varchar(30), @nodeName nvarchar(30)	--节点天数，开始时间类型，节点名称
	set @curNode = (select curNode from contractInfo where contractID = @contractID)
	set @nextNode = (select top 1 nodeNum from contractFlow where contractID = @contractID and nodeNum > @curNode order by nodeNum)	--取下一个节点号

	if (@nextNode is not null)
		select @nodeName = nodeName, @nodeDays = nodeDays, @startTimeType = startTimeType
		from contractFlow 
		where contractID = @contractID and nodeNum = @nextNode

	set @updateTime = GETDATE()
	begin tran
		--更新当前节点状态：
		update contractFlow
		set endTime = @updateTime,
			nStatus = 9 --节点状态：0->未启动，1->到达，-1->返回上一节点，9->完成
		where contractID = @contractID and nodeNum = @curNode
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    

		if (@nextNode is null)	--合同全部节点流转完成
		begin
			update contractInfo
			set contractStatus = 9, completedTime=@updateTime,
				modiManID = @modiManID, modiManName = @modiManName, modiTime = @updateTime
			where contractID = @contractID
			if @@ERROR <> 0 
			begin
				rollback tran
				set @Ret = 9
				return
			end  
		end
		else
		begin
			--计算剩余天数：
			declare @leftDays int			
			if (@startTimeType='startTime')
			begin
				declare @startTime smalldatetime
				set @startTime = (select startTime from contractInfo where contractID = @contractID)
				set @leftDays = @nodeDays - DATEDIFF(day, @startTime, @updateTime)
			end
			else if (@startTimeType='lastNodeCompleted')
				set @leftDays = @nodeDays
			else if (@startTimeType='goodsArrivalTime')
			begin
				declare @goodsArrivalTime smalldatetime
				set @goodsArrivalTime = (select goodsArrivalTime from contractInfo where contractID = @contractID)
				set @leftDays = DATEDIFF(day, @updateTime,@goodsArrivalTime) + @nodeDays
			end

			--更新下一个节点的状态：
			update contractFlow
			set startTime = @updateTime, curLeftDays = @leftDays,
				nStatus = 1 --节点状态：0->未启动，1->到达，-1->返回上一节点，9->完成
			where contractID = @contractID and nodeNum = @nextNode
			if @@ERROR <> 0 
			begin
				rollback tran
				set @Ret = 9
				return
			end
			
			--更新合同状态及生成事件：			
			update contractInfo
			set contractStatus = 1, curNode = @nextNode, curNodeName = @nodeName, curLeftDays = @leftDays,
				event2Trader = 'Y', event2TraderType = 1, event2TraderText = '外贸合同['+@contractID+']上一环节的工作完成，推进到环节['+@nodeName+']。',
				event2TraderTime = @updateTime,
				event2ClgMan = 'Y', event2ClgManType = 1, event2ClgManText  = '外贸合同['+@contractID+']上一环节的工作完成，推进到环节['+@nodeName+']。',
				event2ClgManTime = @updateTime,
				modiManID = @modiManID, modiManName = @modiManName, modiTime = @updateTime
			where contractID = @contractID
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
	values(@modiManID, @modiManName, @updateTime, '标定合同节点完成', '用户' + @modiManName 
												+ '标定了合同['+ @contractID +']节点['+str(@curNode,2,0)+']完成。')
GO
--测试：
update contractInfo set lockManID=''
declare @updateTime smalldatetime--更新时间
declare @Ret		int			--操作成功标识
exec dbo.completeContractNode '20120067','00201314',@updateTime output, @Ret output
select @Ret

select * from contractInfo where contractID='20120189'

update contractInfo 
set lockManID=''
where contractID='20120189'
select * from contractFlow


drop PROCEDURE gobackContractNode
/*
	name:		gobackContractNode
	function:	8.将合同的当前节点退回到上一个节点
				注意：该存储过程检测编辑锁但不锁定
	input: 
				@contractID varchar(12),	--合同编号

				@modiManID varchar(10) output,		--维护人，如果当前合同正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：指定的合同不存在，2：要启动的合同正被别人锁定，3:该单据已经完成，不允许退回，
							4:这是第一个节点，不允许退回，5：节点配置错误，9：未知错误
	author:		卢苇
	CreateDate:	2012-3-30
	UpdateDate: modi by lw 2012-5-8 增加环节监控起算时间为合同启动时间,及节点号修改成可能不连续.
				modi by lw 2012-5-9 增加通知事件

*/
create PROCEDURE gobackContractNode
	@contractID varchar(12),	--合同编号

	--维护人:
	@modiManID varchar(10) output,		--维护人，如果当前合同正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,	--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的合同是否存在
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @contractStatus int
	select @thisLockMan= isnull(lockManID,''), @contractStatus = contractStatus
	from contractInfo 
	where contractID = @contractID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态:
	if (@contractStatus = 9)
	begin
		set @Ret = 3
		return
	end
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--取节点信息：
	declare @curNode int
	set @curNode = (select curNode from contractInfo where contractID = @contractID)
	if (@curNode=1)
	begin
		set @Ret = 4
		return
	end
	
	--取上一个节点信息：
	declare @lastNode int	--上一个节点号
	declare @nodeDays int, @startTimeType varchar(30), @nodeName nvarchar(30), @startTime smalldatetime	--节点天数，开始时间类型，节点名称，节点开始时间
	set @lastNode = (select top 1 nodeNum from contractFlow where contractID = @contractID and nodeNum < @curNode order by nodeNum desc)	--取上一个节点号
	if (@lastNode is null)
	begin
		set @Ret = 5
		return
	end
	select @nodeName = nodeName, @nodeDays = nodeDays, @startTimeType = startTimeType, @startTime = startTime
	from contractFlow 
	where contractID = @contractID and nodeNum = @lastNode
	
	set @updateTime = GETDATE()
	begin tran
		--计算剩余天数：
		declare @leftDays int			
		if (@startTimeType='startTime')
		begin
			declare @contractStartTime smalldatetime
			set @contractStartTime = (select startTime from contractInfo where contractID = @contractID)
			set @leftDays = @nodeDays - DATEDIFF(day, @contractStartTime, @updateTime)
		end
		else if (@startTimeType='lastNodeCompleted')
			set @leftDays = @nodeDays - DATEDIFF(day, @startTime, @updateTime)
		else if (@startTimeType='goodsArrivalTime')
		begin
			declare @goodsArrivalTime smalldatetime
			set @goodsArrivalTime = (select goodsArrivalTime from contractInfo where contractID = @contractID)
			set @leftDays = DATEDIFF(day, @updateTime,@goodsArrivalTime) + @nodeDays
		end

		--更新当前节点状态：
		update contractFlow
		set startTime=null, endTime = null,
			nStatus = -1 --节点状态：0->未启动，1->到达，-1->返回上一节点，9->完成
		where contractID = @contractID and nodeNum = @curNode
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    

		--更新上一节点状态：
		update contractFlow
		set startTime=(case when startTime is null then @updateTime else startTime end),
			curLeftDays = @leftDays, endTime = null,
			nStatus = 1 --节点状态：0->未启动，1->到达，-1->返回上一节点，9->完成
		where contractID = @contractID and nodeNum = @lastNode
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end

		--更新合同状态并生成通知事件：
		update contractInfo
		set contractStatus = 1, curNode = @lastNode, curNodeName=@nodeName, curLeftDays = @leftDays,
			event2Trader = 'Y', event2TraderType = 1, event2TraderText = '外贸合同['+@contractID+']环节['+@nodeName+']中的部分文件不符合要求，设备处管理人员做了退回处理。',
			event2TraderTime = @updateTime,
			event2ClgMan = 'Y', event2ClgManType = 1, event2ClgManText  = '外贸合同['+@contractID+']环节['+@nodeName+']中的部分文件不符合要求，设备处管理人员做了退回处理。',
			event2ClgManTime = @updateTime,
			modiManID = @modiManID, modiManName = @modiManName, modiTime = @updateTime
		where contractID = @contractID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end  
	commit tran

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '退回合同流程', '用户' + @modiManName 
												+ '将合同['+ @contractID +']从节点['+str(@curNode,2,0)+']退回了一步。')
GO
--测试：
declare @updateTime smalldatetime--更新时间
declare @Ret		int			--操作成功标识
exec dbo.gobackContractNode '20120067','00201314',@updateTime output, @Ret output
select @Ret

select * from contractInfo
select * from contractFlow


drop PROCEDURE updateContractInfo
/*
	name:		updateContractInfo
	function:	9.更新合同
	input: 
				@contractID char(12),			--合同编号
				--订货单位信息/订货设备信息（可能有多条）：
				@clgInfo xml,	--采用如下方式存放:
									N'<root>
									  <contractCollege clgCode="123" jobNumber="00000891" oprManMobile="18602702392">
											<contractEqp contractID="201203280001" eName="Sony巨型计算机" eFormat="100Cpu" cCode="392" quantity="4" price="1000.0000" />
									  </contractCollege>
									  <contractCollege clgCode="124" jobNumber="00000906" oprManMobile="18602702391">
											<contractEqp contractID="201203280001" eName="IBM巨型计算机" eFormat="300Cpu" cCode="392" quantity="1" price="2000.0000" />
											<contractEqp contractID="201203280001" eName="HP巨型计算机" eFormat="200Cpu" cCode="392" quantity="5" price="3000.0000" />
									  </contractCollege>
									</root>'

				--供货单位：
				@supplierID varchar(12),		--供货单位编号
				@supplierOprManID varchar(18),	--供货单位经办人ID
				@supplierOprManMobile varchar(30),	--供货单位经办人联系电话，手机：冗余设计，保存历史数据 add by lw 2012-3-27
				--@supplierSignedTime varchar(10),--签约时间:采用“yyyy-MM-dd”存放的日期数据
				
				--委托外贸公司及经办人
				@traderID varchar(12),			--外贸公司编号
				@traderOprManID varchar(18),	--外贸公司经办人ID
				@traderOprManMobile varchar(30),--外贸公司经办人联系电话，手机：冗余设计，保存历史数据 add by lw 2012-3-27
				--@traderSignedTime varchar(10),	--委托时间:采用“yyyy-MM-dd”存放的日期数据
				
				@totalAmount money,				--设备总价
				@currency smallint,				--币种,由第3号代码字典定义
				@dollar money,					--折合美元
				@paymentMode smallint,			--付款方式, 由第4号代码字典定义
				@goodsArrivalTime varchar(10),	--预计到货时间：采用“yyyy-MM-dd”存放的日期数据
				@acceptedTime varchar(10),		--受理时间（签约时间）:采用“yyyy-MM-dd”存放的日期数据
				@notes nvarchar(500),			--备注

				
				@modiManID varchar(10) output,		--维护人，如果当前合同正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：指定的合同不存在，2：要更新的合同正被别人锁定，3:该合同已经完成，不允许修改，
							4:这是第一个节点，不允许退回，5：节点配置错误，9：未知错误
	author:		卢苇
	CreateDate:	2012-3-30
	UpdateDate: 根据客户需求，设备与合同为一对多关系，流程为固定模式，调整接口 by lw 2012-4-8
				根据客户要求，在登记合同中可以临时修改手机号码，调整接口,并将设备总价和折算美元放在外部计算 by lw 2012-4-24
				根据客户要求，将订货单位与订货设备关联。by lw 2012-5-8
				modi by lw 2012-5-9 增加通知事件
				modi by lw 2012-5-21增加xml中特殊字符"<>"的处理
*/
create PROCEDURE updateContractInfo
	@contractID char(12),			--合同编号
	--订货单位信息（可能有多条）：
	@clgInfo xml,	

	--供货单位：
	@supplierID varchar(12),		--供货单位编号
	@supplierOprManID varchar(18),	--供货单位经办人ID
	@supplierOprManMobile varchar(30),	--供货单位经办人联系电话，手机：冗余设计，保存历史数据 add by lw 2012-3-27
	--@supplierSignedTime varchar(10),--签约时间:采用“yyyy-MM-dd”存放的日期数据
	
	--委托外贸公司及经办人
	@traderID varchar(12),			--外贸公司编号
	@traderOprManID varchar(18),	--外贸公司经办人ID
	@traderOprManMobile varchar(30),--外贸公司经办人联系电话，手机：冗余设计，保存历史数据 add by lw 2012-3-27
	--@traderSignedTime varchar(10),	--委托时间:采用“yyyy-MM-dd”存放的日期数据


	@totalAmount money,				--设备总价
	@currency smallint,				--币种,由第3号代码字典定义
	@dollar money,					--折合美元
	@paymentMode smallint,			--付款方式, 由第4号代码字典定义
	@goodsArrivalTime varchar(10),	--预计到货时间：采用“yyyy-MM-dd”存放的日期数据
	@acceptedTime varchar(10),		--受理时间（签约时间）:采用“yyyy-MM-dd”存放的日期数据
	@notes nvarchar(500),			--备注
	
	@modiManID varchar(10) output,		--维护人，如果当前合同正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,	--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的验收申请单是否存在
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @contractStatus int
	select @thisLockMan = isnull(lockManID,''), @contractStatus = contractStatus
	from contractInfo
	where contractID = @contractID
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态:
	if (@contractStatus = 9)
	begin
		set @Ret = 3
		return
	end
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--解析订货单位和订货设备：
	declare @eqpInfoTab as TABLE (
		contractID varchar(12) not null,	--合同编号
		clgCode char(3) not null,			--订货单位：学院代码	--根据武大要求，将订货设备与订货单位关联add by lw 2012-5-8
		ordererID varchar(10) not null,		--主键：订货人ID
		eName nvarchar(30) not null,		--设备名称
		eFormat nvarchar(20) not null,		--型号规格
		cCode char(3) not null,				--原产地（国家代码）
		quantity int not null,				--数量
		price money null					--单价，>0
	)
	insert @eqpInfoTab(contractID, clgCode, ordererID, eName, eFormat, cCode, quantity, price)
	select @contractID, tabXML.clgCode, tabXML.ordererID, REPLACE(REPLACE(tabXML.eName,'&lt;','<'),'&gt;','>'), 
										REPLACE(REPLACE(tabXML.eFormat,'&lt;','<'),'&gt;','>'), tabXML.cCode, tabXML.quantity, tabXML.price
	from (select cast(T.x.query('data(../@clgCode)') as char(3)) clgCode, 
			cast(T.x.query('data(../@jobNumber)') as varchar(10)) ordererID, 
			cast(T.x.query('data(./@eName)') as nvarchar(30)) eName, 
			cast(T.x.query('data(./@eFormat)') as nvarchar(20)) eFormat,
			cast(T.x.query('data(./@cCode)') as char(3)) cCode, 
			cast(cast(T.x.query('data(./@quantity)') as varchar(10)) as int) quantity,
			cast(cast(T.x.query('data(./@price)') as varchar(12)) as money) price
			from (select @clgInfo.query('/root/contractCollege') Col1) A OUTER APPLY A.Col1.nodes('/contractCollege/contractEqp') AS T(x)
	) as tabXML
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end
		
	--获取供货单位信息：
	declare @supplierName nvarchar(30)			--供货单位名称：冗余设计，保存历史数据 add by lw 2012-3-27
	set @supplierName = (select supplierName from supplierInfo where supplierID = @supplierID)
	declare @supplierOprMan	nvarchar(30)	--供货单位经办人：冗余设计，保存历史数据 add by lw 2012-3-27
	declare @supplierOprManTel varchar(30)	--供货单位经办人联系电话，其他电话：冗余设计，保存历史数据 add by lw 2012-3-27
	select @supplierOprMan = manName, @supplierOprManTel = tel
	from supplierManInfo where supplierID = @supplierID and manID = @supplierOprManID
	
	--获取外贸公司信息：
	declare @traderName nvarchar(30)		--外贸公司名称：冗余设计，保存历史数据 add by lw 2012-3-27
	declare @abbTraderName nvarchar(6)		--外贸公司简称	add by lw 2012-4-27根据客户要求增加
	select @traderName = traderName, @abbTraderName = abbTraderName 
	from traderInfo 
	where traderID = @traderID

	declare @traderOprMan nvarchar(30)		--外贸公司经办人：冗余设计，保存历史数据 add by lw 2012-3-27
	declare @traderOprManTel varchar(30)	--外贸公司经办人联系电话，其他电话：冗余设计，保存历史数据 add by lw 2012-3-27
	select @traderOprMan = manName, @traderOprManTel = tel
	from traderManInfo where traderID = @traderID and manID = @traderOprManID
	
	set @updateTime = getdate()
	begin tran
		declare @oldPaymentMode smallint			--以前的付款方式, 由第4号代码字典定义
		set @oldPaymentMode = (select paymentMode from contractInfo where contractID = @contractID)

		update contractInfo
		set supplierID = @supplierID, supplierName = @supplierName, 
			supplierOprManID = @supplierOprManID, supplierOprMan = @supplierOprMan, 
			supplierOprManMobile = @supplierOprManMobile, supplierOprManTel = @supplierOprManTel, 
			traderID = @traderID, traderName = @traderName, abbTraderName = @abbTraderName, traderOprManID = @traderOprManID, 
			traderOprMan = @traderOprMan, traderOprManMobile = @traderOprManMobile, traderOprManTel = @traderOprManTel, 
			totalAmount = @totalAmount, currency = @currency, dollar = @dollar,
			paymentMode = @paymentMode, goodsArrivalTime = @goodsArrivalTime, 
			acceptedTime = @acceptedTime, notes = @notes,
			modiManID = @modiManID, modiManName = @modiManName, modiTime = @updateTime
		where contractID = @contractID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end  
--print '更新合同主体'		  
		  
		--更新订货单位信息：
		delete contractCollege where contractID = @contractID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    
		insert contractCollege(contractID, clgCode, clgName, ordererID, orderer, ordererMobile,ordererTel)
		select @contractID, tabXML.clgCode, clg.clgName, tabXML.jobNumber, ui.cName, tabXML.mobile, '' 
		from (select cast(T.x.query('data(./@clgCode)') as char(3)) clgCode,
				cast(T.x.query('data(./@jobNumber)') as varchar(10)) jobNumber,
				cast(T.x.query('data(./@oprManMobile)') as varchar(30)) mobile
				from (select @clgInfo.query('/root/contractCollege') Col1) A OUTER APPLY A.Col1.nodes('/contractCollege') AS T(x)
			) as tabXML
			left join college clg on tabXML.clgCode = clg.clgCode
			left join userInfo ui on tabXML.jobNumber = ui.jobNumber
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
--print '更新订货单位'		  

		--更新订货设备信息：
		delete contractEqp where contractID = @contractID
		insert contractEqp(contractID, clgCode, ordererID, orderer, clgName, eName, eFormat, cCode, quantity, price)
		select contractID, e.clgCode, e.ordererID, u.cName, clg.clgName, eName, eFormat, cCode, quantity, price 
		from @eqpInfoTab e left join college clg on e.clgCode = clg.clgCode
			left join userInfo u on e.ordererID=u.jobNumber
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
--print '更新订货设备'		  
		
		--检查付款方式是否变更，如果变更重新配置流程：
		if (@oldPaymentMode <> @paymentMode)
		begin
--print '更新了付款方式'
			--备份以前的流程状态：
			declare @contractFlow TABLE
			(
				contractID varchar(12) not null,	--主键：合同编号
				nodeNum int not null,				--主键：节点序号
				nodeName nvarchar(30) not null,		--节点名称
				startTimeType varchar(30) ,			--起算时间类型:'startTime'从流程开始时间，
																					--'lastNodeCompleted'->上一节点完成日期，
																					--'goodsArrivalTime'->到货时间
				nodeDays int not null,				--节点允许时间（天）
				curLeftDays int null,				--节点剩余时间(天)，由数据库计算程序每天计算 add by lw 2012-4-19
				startTime smalldatetime null,		--节点开始时间
				endTime smalldatetime null,			--节点完成时间
				nStatus int,						--节点状态：0->未启动，1->到达，-1->返回上一节点，9->完成
				yellowLampTimes smallint,			--黄灯次数
				redLampTimes smallint,				--红灯次数
				SMSTimes smallint					--短信次数
			)
			insert @contractFlow
			select * from contractFlow where contractID = @contractID

			delete contractFlow where contractID = @contractID
			if (@paymentMode>10)	--货前付款
			begin
				insert contractFlow(contractID, nodeNum, nodeName,startTimeType,nodeDays)
				select @contractID, nodeNum, nodeName,startTimeType,nodeDays
				from flowTempletNode
				where templetID = '201204010001'
			end
			else					--货后付款
			begin
				insert contractFlow(contractID, nodeNum, nodeName,startTimeType,nodeDays)
				select @contractID, nodeNum, nodeName,startTimeType,nodeDays
				from flowTempletNode
				where templetID = '201204010002'
			end
			if @@ERROR <> 0 
			begin
				rollback tran
				set @Ret = 9
				return
			end

			--拷贝流程状态：
			update contractFlow
			set curLeftDays = o.curLeftDays,
				startTime = o.startTime,
				endTime = o.endTime,
				nStatus = o.nStatus,
				yellowLampTimes = o.yellowLampTimes,
				redLampTimes = o.redLampTimes,
				SMSTimes = o.SMSTimes
			from contractFlow c left join @contractFlow o on c.contractID = o.contractID and c.nodeNum = o.nodeNum
			where c.contractID = @contractID
			
			--检查合同的当前环节是否存在：如果不存在回溯一个节点！
			declare @curNode int--当前节点号
			set @curNode = (select curNode from contractInfo where contractID = @contractID)
			set @count = (select count(*) from contractFlow where contractID = @contractID and nodeNum = @curNode)
			if (@curNode > 0 and @count = 0)
			begin
				--取上一个节点信息：
				declare @lastNode int	--上一个节点号
				declare @nodeDays int, @startTimeType varchar(30), @nodeName nvarchar(30), @startTime smalldatetime	--节点天数，开始时间类型，节点名称，节点开始时间
				set @lastNode = (select top 1 nodeNum from contractFlow where contractID = @contractID and nodeNum < @curNode order by nodeNum desc)	--取上一个节点号
				if (@lastNode is null)
				begin
					rollback tran
					set @Ret = 5
					return
				end
				select @nodeName = nodeName, @nodeDays = nodeDays, @startTimeType = startTimeType, @startTime = startTime
				from contractFlow 
				where contractID = @contractID and nodeNum = @lastNode
			
--print '起算时间类型：' + @startTimeType
				--计算剩余天数：
				declare @leftDays int			
				if (@startTimeType='startTime')
				begin
					declare @contractStartTime smalldatetime
					set @contractStartTime = (select startTime from contractInfo where contractID = @contractID)
					set @leftDays = @nodeDays - DATEDIFF(day, @contractStartTime, @updateTime)
				end
				else if (@startTimeType='lastNodeCompleted')
					set @leftDays = @nodeDays - DATEDIFF(day, @startTime, @updateTime)
				else if (@startTimeType='goodsArrivalTime')
				begin
					set @leftDays = DATEDIFF(day, @updateTime,@goodsArrivalTime) + @nodeDays
				end
--print '剩余天数：' + cast(@leftDays as varchar(3))
				--更新上一节点状态：
				update contractFlow
				set curLeftDays = @leftDays, startTime=@updateTime, endTime = null,
					nStatus = 1 --节点状态：0->未启动，1->到达，-1->返回上一节点，9->完成
				where contractID = @contractID and nodeNum = @lastNode
				if @@ERROR <> 0 
				begin
					rollback tran
					set @Ret = 9
					return
				end

				--更新合同状态并生成通知事件：
				update contractInfo
				set contractStatus = 1, curNode = @lastNode, curNodeName=@nodeName, curLeftDays = @leftDays,
					event2Trader = 'Y', event2TraderType = 1, event2TraderText = '外贸合同['+@contractID+']的部分条款发生了变化，请查看详情。',
					event2TraderTime = @updateTime,
					event2ClgMan = 'Y', event2ClgManType = 1, event2ClgManText  = '外贸合同['+@contractID+']的部分条款发生了变化，请查看详情。',
					event2ClgManTime = @updateTime,
					modiManID = @modiManID, modiManName = @modiManName, modiTime = @updateTime
				where contractID = @contractID
				if @@ERROR <> 0 
				begin
					rollback tran
					set @Ret = 9
					return
				end  
--print '完成合同状态更新'
			end
		end
	commit tran
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新合同', '用户' + @modiManName
												+ '更新了合同['+ @contractID +']。')
GO
--测试：
declare @Ret int 
exec dbo.lockContractInfo4Edit '20120067', '00201314', @Ret output
select @Ret

declare @clgInfo as xml
set @clgInfo = 
N'<root>
<contractCollege clgCode="123" jobNumber="00000891" oprManMobile="18602702392">
	<contractEqp contractID="20120067" eName="Sony巨型计算机" eFormat="100Cpu" cCode="392" quantity="4" price="1000.0000" />
</contractCollege>
<contractCollege clgCode="124" jobNumber="00000906" oprManMobile="18602702391">
	<contractEqp contractID="20120067" eName="dell巨型计算机" eFormat="300Cpu" cCode="392" quantity="1" price="21000.0000" />
	<contractEqp contractID="20120067" eName="HP巨型计算机" eFormat="200Cpu" cCode="392" quantity="5" price="3000.0000" />
</contractCollege>
</root>'
declare @Ret int, @createTime smalldatetime, @contractID varchar(12)
exec dbo.updateContractInfo  '20120067', @clgInfo,	
	--供货单位：
	'201204240018','G0000039','18602702392',
	--委托外贸公司及经办人
	'201204230009','W0000009','18602702391',
	3200,1,3200,12,	
	'2012-05-29','2012-04-29', '测试数据2',
	'00201314', @createTime output, @Ret output
select @Ret, @createTime, @contractID

update contractInfo set lockManID=''

select * from contractInfo where contractID='20120067'
select * from contractFlow where contractID='20120067'

select * from traderManInfo
select * from contractInfo where contractID='201204060002'
select * from contractInfo
update contractInfo set lockManID=''

drop PROCEDURE delContractInfo
/*
	name:		delContractInfo
	function:	10.删除指定的合同
	input: 
				@contractID char(12),			--合同编号
				@delManID varchar(10) output,	--删除人，如果当前合同正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的合同不存在，2：要删除的合同正被别人锁定，3：该合同已经完成，不能删除，9：未知错误
	author:		卢苇
	CreateDate:	2012-3-30
	UpdateDate: 

*/
create PROCEDURE delContractInfo
	@contractID char(12),			--合同编号
	@delManID varchar(10) output,	--删除人，如果当前合同正在被人占用编辑则返回该人的工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要指定的合同是否存在
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @contractStatus int
	select @thisLockMan= isnull(lockManID,''), @contractStatus = contractStatus
	from contractInfo 
	where contractID = @contractID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态:
	if (@contractStatus = 9)
	begin
		set @Ret = 3
		return
	end
	
	delete contractInfo where contractID = @contractID
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除合同', '用户' + @delManName
												+ '删除了合同['+ @contractID +']。')

GO


drop PROCEDURE addContractAttachment
/*
	name:		11.addContractAttachment
	function:	添加合同附件
				注意：本存储过程先删除，再添加。
	input: 
				@contractID varchar(12),	--合同编号
				--附件信息（可能有多条）：
				@attachmentInfo xml,	--采用如下方式存放:
									N'<root>
									  <attachment attachmentType="1" aFileName="90b2bd1c-8789-4223-9f05-2c38f6f000a7.png" notes="这是合同第1页"/>
									  <attachment attachmentType="2" aFileName="bc1a3c47-00c1-4c7c-93de-f75149db7a9d.png" notes="这是协议第1页"/>
									</root>'				
				@modiManID varchar(10) output,		--维护人，如果当前合同正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output				--操作成功标识
										0:成功，1：指定的合同不存在，2：要更新的合同正被别人锁定，3:该合同已经完成，不允许修改，9：未知错误
	author:		卢苇
	CreateDate:	2012-3-31
	UpdateDate: 根据UI设计的调整将本函数改成成批发送。
				modi by lw 2012-5-9 增加通知事件
*/
create PROCEDURE addContractAttachment
	@contractID varchar(12),	--合同编号
	@attachmentInfo xml,	--附件信息（可能有多条）

	@modiManID varchar(10) output,		--维护人，如果当前合同正在被人占用编辑则返回该人的工号
	@updateTime smalldatetime output,	--更新时间
	@Ret		int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的验收申请单是否存在
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @contractStatus int
	select @thisLockMan = isnull(lockManID,''), @contractStatus = contractStatus
	from contractInfo
	where contractID = @contractID
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态:
	if (@contractStatus = 9)
	begin
		set @Ret = 3
		return
	end
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	begin tran
		delete contractAttachment where contractID = @contractID

		if (cast(@attachmentInfo as nvarchar(max))<>N'<root/>')
		begin
			--登记附件：
			insert contractAttachment(contractID, attachmentType, aFileName, notes)
			select @contractID, cast(cast(T.x.query('data(./@attachmentType)') as varchar(3)) as int) attachmentType,
					cast(T.x.query('data(./@aFileName)') as varchar(128)) aFileName,
					cast(T.x.query('data(./@notes)') as nvarchar(500)) notes
			from (select @attachmentInfo.query('/root/attachment') Col1) A OUTER APPLY A.Col1.nodes('/attachment') AS T(x)
			if @@ERROR <> 0 
			begin
				rollback tran
				set @Ret = 9
				return
			end    
		end

		--登记更新信息并生成事件：
		update contractInfo
		set event2Manager = 'Y', event2ManagerType = 2, event2ManagerText='有新的附件，请审阅并检查是否完成本环节工作。', event2TraderTime = @updateTime,
			modiManID = @modiManID, modiManName = @modiManName, modiTime = @updateTime
		where contractID = @contractID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end  
		  
	commit tran

	set @Ret = 0

	--登记工作日志：
	declare @attachmentName varchar(100)
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '添加合同附件', '用户' + @modiManName 
												+ '添加了合同['+ @contractID +']的附件。')
GO
--测试：
declare	@Ret		int
declare @updateTime smalldatetime
exec dbo.addContractAttachment '20120039','<root></root>','00011275',@updateTime output,@Ret output
select @Ret


drop PROCEDURE delATypeContractAttachment
/*
	name:		delATypeContractAttachment
	function:	12.删除指定的类别的合同附件
	input: 
				@contractID varchar(12),	--合同编号
				@attachmentType smallint,	--附件类型：由第5号代码字典定义

				@delManID varchar(10) output,--删除人：当合同被别人锁定的时候返回锁定人的ID
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：指定的合同不存在，2：要删除的合同正被别人锁定，3：该合同已经完成，不能删除附件，9：未知错误
	author:		卢苇
	CreateDate:	2012-4-24
	UpdateDate: 

*/
create PROCEDURE delATypeContractAttachment
	@contractID varchar(12),	--合同编号
	@attachmentType smallint,	--附件类型：由第5号代码字典定义

	@delManID varchar(10) output,--删除人
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--判断指定的合同是否存在
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @contractStatus int
	select @thisLockMan= isnull(lockManID,''), @contractStatus = contractStatus
	from contractInfo 
	where contractID = @contractID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态:
	if (@contractStatus = 9)
	begin
		set @Ret = 3
		return
	end
	
	delete contractAttachment where contractID = @contractID and attachmentType = @attachmentType
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--获取附件类别的信息：
	declare @attachmentName varchar(100)
	select @attachmentName = objDesc
	from codeDictionary cd 
	where objCode = @attachmentType and classCode=5

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除合同附件', '用户' + @delManName
												+ '删除了合同['+ @contractID +']的附件['+ @attachmentName +']的一个文件。')
GO

drop PROCEDURE addATypeContractAttachment
/*
	name:		13.addATypeContractAttachment
	function:	添加合同指定类别的附件
	input: 
				@contractID varchar(12),	--合同编号
				@attachmentType smallint,	--附件类型：由第5号代码字典定义
				--附件信息（可能有多条）：
				@attachmentInfo xml,	--采用如下方式存放:
									N'<root>
									  <attachment attachmentType="1" aFileName="90b2bd1c-8789-4223-9f05-2c38f6f000a7.png" notes="这是合同第1页"/>
									  <attachment attachmentType="1" aFileName="bc1a3c47-00c1-4c7c-93de-f75149db7a9d.png" notes="这是协议第1页"/>
									</root>'				
				@modiManID varchar(10) output,		--维护人，如果当前合同正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output				--操作成功标识
										0:成功，1：指定的合同不存在，2：要更新的合同正被别人锁定，3:该单据已经完成，不允许修改，9：未知错误
	author:		卢苇
	CreateDate:	2012-4-24
	UpdateDate: modi by lw 2012-5-9 增加通知事件
*/
create PROCEDURE addATypeContractAttachment
	@contractID varchar(12),	--合同编号
	@attachmentType smallint,	--附件类型：由第5号代码字典定义
	@attachmentInfo xml,	--附件信息（可能有多条）

	@modiManID varchar(10) output,		--维护人，如果当前合同正在被人占用编辑则返回该人的工号
	@updateTime smalldatetime output,	--更新时间
	@Ret		int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的验收申请单是否存在
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @contractStatus int
	select @thisLockMan = isnull(lockManID,''), @contractStatus = contractStatus
	from contractInfo
	where contractID = @contractID
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态:
	if (@contractStatus = 9)
	begin
		set @Ret = 3
		return
	end
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	begin tran
		--登记附件：
		if (cast(@attachmentInfo as varchar(max))<>'<root></root>')
		begin
			insert contractAttachment(contractID, attachmentType, aFileName, notes)
			select @contractID, @attachmentType,
					cast(T.x.query('data(./@aFileName)') as varchar(128)) aFileName,
					cast(T.x.query('data(./@notes)') as nvarchar(500)) notes
			from (select @attachmentInfo.query('/root/attachment') Col1) A OUTER APPLY A.Col1.nodes('/attachment') AS T(x)
			if @@ERROR <> 0 
			begin
				rollback tran
				set @Ret = 9
				return
			end    
		end
		
		--登记更新信息并生成事件：
		update contractInfo
		set event2Manager = 'Y', event2ManagerType = 2, event2ManagerText='有新的附件，请审阅并检查是否完成本环节工作。', event2TraderTime = @updateTime,
			modiManID = @modiManID, modiManName = @modiManName, modiTime = @updateTime
		where contractID = @contractID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end  
		  
	commit tran

	set @Ret = 0

	--登记工作日志：
	declare @attachmentName varchar(100)
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '添加合同附件', '用户' + @modiManName 
												+ '添加了合同['+ @contractID +']的附件。')
GO

drop PROCEDURE addEvent2ContractInfo
/*
	name:		14.addEvent2ContractInfo
	function:	给指定合同添加事件
				注意：本存储过程不填写工作日志！
	input: 
				@contractID varchar(12),	--合同编号
				@event2Who smallint,		--事件发送对象:1->给设备处管理人员的事件，2->给外贸公司的事件，3->给订货单位的事件
				@eventType smallint,		--事件类型：
												--给管理人员的事件类别：1->通知，仅需要浏览，2->有新的附件，需要审阅并检查是否是否完成本环节，3->有流程变更需要批复
												--给外贸公司的事件类别：1->通知，仅需要浏览，2->环节超期，需要上传完成的工作附件
												--给订货单位的事件类别：1->通知，仅需要浏览，3->有流程变更需要批复
				@eventText nvarchar(100),	--事件内容

				
				@modiManID varchar(10) output,		--维护人，如果当前合同正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output				--操作成功标识
										0:成功，1：指定的合同不存在，2：要更新的合同正被别人锁定，3:该单据已经完成，不允许修改，9：未知错误
	author:		卢苇
	CreateDate:	2012-5-9
	UpdateDate: 
*/
create PROCEDURE addEvent2ContractInfo
	@contractID varchar(12),	--合同编号
	@event2Who smallint,		--事件发送对象:1->给设备处管理人员的事件，2->给外贸公司的事件，3->给订货单位的事件
	@eventType smallint,		--事件类型：
									--给管理人员的事件类别：1->通知，仅需要浏览，2->有新的附件，需要审阅并检查是否是否完成本环节，3->有流程变更需要批复
									--给外贸公司的事件类别：1->通知，仅需要浏览，2->环节超期，需要上传完成的工作附件
									--给订货单位的事件类别：1->通知，仅需要浏览，3->有流程变更需要批复
	@eventText nvarchar(100),	--事件内容

	@modiManID varchar(10) output,		--维护人，如果当前合同正在被人占用编辑则返回该人的工号
	@Ret		int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的验收申请单是否存在
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @contractStatus int
	select @thisLockMan = isnull(lockManID,''), @contractStatus = contractStatus
	from contractInfo
	where contractID = @contractID
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态:
	if (@contractStatus = 9)
	begin
		set @Ret = 3
		return
	end
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	declare @updateTime smalldatetime
	set @updateTime = getdate()
	
	if (@event2Who = 1)	
		update contractInfo
		set event2Manager = 'Y', event2ManagerType = @eventType, event2ManagerText = @eventText, event2ManagerTime = @updateTime
		where contractID = @contractID
	else if (@event2Who = 2)	
		update contractInfo
		set event2Trader = 'Y', event2TraderType = @eventType, event2TraderText = @eventText, event2TraderTime = @updateTime
		where contractID = @contractID
	else if (@event2Who = 3)
		update contractInfo
		set event2ClgMan = 'Y', event2ClgManType = @eventType, event2ClgManText = @eventText, event2ClgManTime = @updateTime
		where contractID = @contractID
	if @@ERROR <> 0 
	begin
		rollback tran
		set @Ret = 9
		return
	end  
		  
	set @Ret = 0

GO


drop PROCEDURE clearContractInfoEvent
/*
	name:		15.clearContractInfoEvent
	function:	删除指定合同的事件
				注意：本存储过程不填写工作日志！
	input: 
				@contractID varchar(12),	--合同编号
				@event2Who smallint,		--事件发送对象:1->给设备处管理人员的事件，2->给外贸公司的事件，3->给订货单位的事件
				
				@modiManID varchar(10) output,		--维护人，如果当前合同正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output				--操作成功标识
										0:成功，1：指定的合同不存在，2：要更新的合同正被别人锁定，3:该单据已经完成，不允许修改，9：未知错误
	author:		卢苇
	CreateDate:	2012-5-9
	UpdateDate: 
*/
create PROCEDURE clearContractInfoEvent
	@contractID varchar(12),	--合同编号
	@event2Who smallint,		--事件发送对象:1->给设备处管理人员的事件，2->给外贸公司的事件，3->给订货单位的事件

	@modiManID varchar(10) output,		--维护人，如果当前合同正在被人占用编辑则返回该人的工号
	@Ret		int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的验收申请单是否存在
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @contractStatus int
	select @thisLockMan = isnull(lockManID,''), @contractStatus = contractStatus
	from contractInfo
	where contractID = @contractID
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态:
	if (@contractStatus = 9)
	begin
		set @Ret = 3
		return
	end
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	declare @updateTime smalldatetime
	set @updateTime = getdate()
	
	if (@event2Who = 1)	
		update contractInfo
		set event2Manager = 'N', event2ManagerType = 0, event2ManagerText = '', event2ManagerTime = null
		where contractID = @contractID
	else if (@event2Who = 2)	
		update contractInfo
		set event2Trader = 'N', event2TraderType = 0, event2TraderText = '', event2TraderTime = null
		where contractID = @contractID
	else if (@event2Who = 3)
		update contractInfo
		set event2ClgMan = 'N', event2ClgManType = 0, event2ClgManText = '', event2ClgManTime = null
		where contractID = @contractID
	if @@ERROR <> 0 
	begin
		rollback tran
		set @Ret = 9
		return
	end  
		  
	set @Ret = 0

GO
--测试：
select lockManID, * from contractInfo where contractID='20130258'

drop PROCEDURE calcContract
/*
	name:		calcContract
	function:	20.计算全部在线合同的状态，并生成提示短信表
				注意：该存储过程为后台计算程序，该存储过程会清除所有的用户编辑锁，独占式锁定所有在线合同
	input: 
	output: 
	author:		卢苇
	CreateDate:	2012-3-30
	UpdateDate: modi by lw 2012-5-9 增加通知事件

*/
create PROCEDURE calcContract
	WITH ENCRYPTION 
AS
	declare @Ret int
	set @Ret = 9
	begin tran
		--锁定全部在线合同：
		update contractInfo
		set lockManID='0000000000'
		where contractStatus = 1
		if @@ERROR <> 0 
		begin
			rollback tran
			return
		end  
	
		--计算合同状态：
		update contractInfo
		set curLeftDays = curLeftDays - 1
		where contractStatus = 1
		if @@ERROR <> 0 
		begin
			rollback tran
			return
		end  
		
		--计算合同执行流程中的节点状态：add by lw 2012-4-19
		update contractFlow
		set curLeftDays = curLeftDays - 1
		where contractID in (select contractID from contractInfo where contractStatus=1)

		--生成提醒短信：
		declare @contractID varchar(12)			--合同编号
		declare @curNode int, @curNodeName nvarchar(30), @curLeftDays int
		declare @traderOprMan nvarchar(30)		--外贸公司经办人：冗余设计，保存历史数据 add by lw 2012-3-27
		declare @traderOprManMobile varchar(30)	--外贸公司经办人联系电话，手机：冗余设计，保存历史数据 add by lw 2012-3-27
		declare @manager nvarchar(30)			--负责人
		declare @managerMobile varchar(30)		--负责人联系手机
		
		declare tar cursor for
		select contractID, c.curNode, c.curNodeName, c.curLeftDays, c.traderOprMan, c.traderOprManMobile, t.manager, t.managerMobile
		from contractInfo c left join traderInfo t on c.traderID = t.traderID
		where contractStatus = 1 and curLeftDays <= 3
		OPEN tar
		FETCH NEXT FROM tar INTO @contractID, @curNode, @curNodeName, @curLeftDays, @traderOprMan, @traderOprManMobile, @manager, @managerMobile
		WHILE @@FETCH_STATUS = 0
		begin
			declare @msg nvarchar(100)
			if (@traderOprManMobile is not null and @traderOprManMobile<>'')	--生成给经办人的短信
			begin
				if (@curLeftDays > 0)
					set @msg = @traderOprMan + '您好！您经办的我处外贸合同['+@contractID
								+']的['+@curNodeName+']时间快要到期了，还剩下['+str(@curLeftDays,2,0)+']天，请及时办理！\n武汉大学设备处。'
				else
					set @msg = @traderOprMan + '您好！您经办的我处外贸合同['+@contractID
								+']的['+@curNodeName+']时间已经超期了['+str(@curLeftDays*-1,2,0)+']天，请及时办理！\n武汉大学设备处。'
				insert contractSMS(contractID, mobile, msg)
				values(@contractID, @traderOprManMobile,@msg)
				if @@ERROR <> 0 
				begin
					rollback tran
					return
				end  
			end
			if (@managerMobile is not null and @managerMobile<>'' and @managerMobile<>@traderOprManMobile)	--生成给负责人的短信
			begin
				if (@curLeftDays > 0)
					set @msg = @traderOprMan + '您好！您经办的我处外贸合同['+@contractID
								+']的['+@curNodeName+']时间快要到期了，还剩下['+str(@curLeftDays,2,0)+']天，请及时办理！\n武汉大学设备处。'
				else
					set @msg = @traderOprMan + '您好！您经办的我处外贸合同['+@contractID
								+']的['+@curNodeName+']时间已经超期了['+str(@curLeftDays*-1,2,0)+']天，请及时办理！\n武汉大学设备处。'
				insert contractSMS(contractID, mobile, msg)
				values(@contractID, @managerMobile,@msg)
				if @@ERROR <> 0 
				begin
					rollback tran
					return
				end  
			end
			
			--生成事件：
			update contractInfo
			set event2Trader = 'Y', event2TraderType = 2, event2TraderText = '您经办的我处外贸合同['+@contractID
								+']的['+@curNodeName+']时间已经超期了['+str(@curLeftDays*-1,2,0)+']天，请尽快处理！如果工作已经完成，请尽快上传附件。',
				event2TraderTime = getdate()
			where contractID = @contractID
			if @@ERROR <> 0 
			begin
				rollback tran
				return
			end  
			--超时记录：
			if (@curLeftDays>0)
				update contractFlow
				set yellowLampTimes = yellowLampTimes + 1, SMSTimes = SMSTimes + 1
				where contractID = @contractID and nodeNum = @curNode
			else
				update contractFlow
				set redLampTimes = redLampTimes + 1, SMSTimes = SMSTimes + 1
				where contractID = @contractID and nodeNum = @curNode
			if @@ERROR <> 0 
			begin
				rollback tran
				return
			end  
			
			FETCH NEXT FROM tar INTO @contractID, @curNode, @curNodeName, @curLeftDays, @traderOprMan, @traderOprManMobile, @manager, @managerMobile
		end
		CLOSE tar
		DEALLOCATE tar
		
		--释放全部在线合同的编辑锁：
		update contractInfo
		set lockManID=''
		where contractStatus = 1
		if @@ERROR <> 0 
		begin
			rollback tran
			return
		end  
		set @Ret = 0
	commit tran
	
	--应该有一个全局事务的表，一方面防止在全局事务的时候有人编辑合同，另一个方面检测是否完成事务！！
	
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values('0000000000', '系统', GETDATE(), '计算合同状态', '系统完成了合同的状态计算。')
GO
--测试：
exec dbo.calcContract
select * from contractInfo
select * from contractFlow

select * from contractSMS




select * from contractFlow where contractID='20120037'




select contractStatus, ci.curLeftDays, ci.contractID, curNode, curNodeName,dbo.getEqpInfoOfContract(ci.contractID) eqpInfo,totalAmount, currency, cd.objDesc currencyName,dbo.getClgInfoOfContract(ci.contractID) clgInfo,supplierID, supplierName, supplierOprMan, supplierOprManMobile, supplierOprManTel, convert(varchar(10),supplierSignedTime,120) supplierSignedTime,traderID, abbTraderName, traderName, traderOprMan, traderOprManMobile, traderOprManTel, convert(varchar(10),traderSignedTime,120) traderSignedTime,case f1.nStatus when 0 then '' when 1 then cast(f1.curLeftDays as varchar(10)) when -1 then '←' when 9 then '√' end nodeSignContract,case f2.nStatus when 0 then '' when 1 then cast(f2.curLeftDays as varchar(10)) when -1 then '←' when 9 then '√' end nodePay,case f3.nStatus when 0 then '' when 1 then cast(f3.curLeftDays as varchar(10)) when -1 then '←' when 9 then '√' end nodeTaxFree,case f4.nStatus when 0 then '' when 1 then cast(f4.curLeftDays as varchar(10)) when -1 then '←' when 9 then '√' end nodeDeclaration,case f5.nStatus when 0 then '' when 1 then cast(f5.curLeftDays as varchar(10)) when -1 then '←' when 9 then '√' end nodeCommit,case f6.nStatus when 0 then '' when 1 then cast(f6.curLeftDays as varchar(10)) when -1 then '←' when 9 then '√' end nodeAccept,case f7.nStatus when 0 then '' when 1 then cast(f7.curLeftDays as varchar(10)) when -1 then '←' when 9 then '√' end nodeAccount,ci.contractID timeoutRecord, dbo.getEventOfContract(ci.contractID,'00200977') haveEvent,dbo.getDiscussStatusOfContract(ci.contractID,'00200977') haveMsg,paymentMode, cd2.objDesc paymentModeDesc, goodsArrivalTime,convert(varchar(10),acceptedTime,120) acceptedTime, convert(varchar(10),completedTime,120) completedTime, notes,convert(varchar(10),ci.startTime,120) startTime
from contractInfo ci left join codeDictionary cd on ci.currency = cd.objCode and cd.classCode=3 left join codeDictionary cd2 on ci.paymentMode = cd2.objCode and cd2.classCode=4 left join contractFlow f1 on ci.contractID = f1.contractID and f1.nodeName ='签订协议' left join contractFlow f2 on ci.contractID = f2.contractID and f2.nodeName ='开证付款' left join contractFlow f3 on ci.contractID = f3.contractID and f3.nodeName ='办理免表' left join contractFlow f4 on ci.contractID = f4.contractID and f4.nodeName ='报关' left join contractFlow f5 on ci.contractID = f5.contractID and f5.nodeName ='送交材料' left join contractFlow f6 on ci.contractID = f6.contractID and f6.nodeName ='验收' left join contractFlow f7 on ci.contractID = f7.contractID and f7.nodeName ='结清余款'
--where contractStatus in (0,1)
order by currencyName 



--汉字内码转换：
select cast(UNICODE('帮') as varbinary(4))
select cast(UNICODE('助') as varbinary(4))
declare @chr as varbinary(4)
set @chr = 0x5e2e
select @chr
select NCHAR(@chr)




select * from contractInfo
delete contractInfo
insert contractInfo
select * from fTradeDBR.dbo.contractInfo

select * from contractAttachment
insert contractAttachment(contractID, attachmentType,aFilename,notes)
select contractID, attachmentType,aFilename,notes from fTradeDBR.dbo.contractAttachment
order by rowNum

select * from contractCollege
insert contractCollege
select * from fTradeDBR.dbo.contractCollege

select * from contractEqp
insert contractEqp
select * from fTradeDBR.dbo.contractEqp

select * from contractFlow
insert contractFlow
select * from fTradeDBR.dbo.contractFlow

select * from discussInfo
insert discussInfo
select * from fTradeDBR.dbo.discussInfo

select * from discussReadInfo
insert discussReadInfo
select * from fTradeDBR.dbo.discussReadInfo

select * from flowTemplet
select * from fTradeDBR.dbo.flowTemplet

select * from flowTempletNode
select * from fTradeDBR.dbo.flowTempletNode

select * from supplierInfo
delete supplierInfo
insert supplierInfo
select * from fTradeDBR.dbo.supplierInfo

select * from supplierManInfo
insert supplierManInfo
select * from fTradeDBR.dbo.supplierManInfo

select * from traderInfo
delete traderInfo
insert traderInfo
select * from fTradeDBR.dbo.traderInfo

select * from traderManInfo
--select * from fTradeDBR.dbo.traderManInfo

delete sysUserInfo
insert sysUserInfo
select * from fTradeDBR.dbo.sysUserInfo

delete college
insert college
select * from fTradeDBR.dbo.college



--流程修改后重新定义流程:
delete contractFlow
declare @contractID varchar(12)	--主键：合同编号，使用第 1 号号码发生器产生
declare @paymentMode smallint		--付款方式, 由第4号代码字典定义
declare tar cursor for
select contractID,paymentMode
from contractInfo
OPEN tar
FETCH NEXT FROM tar INTO @contractID, @paymentMode
WHILE @@FETCH_STATUS = 0
begin
	if (@paymentMode>10)	--货前付款
	begin
		insert contractFlow(contractID, nodeNum, nodeName,startTimeType,nodeDays)
		select @contractID, nodeNum, nodeName,startTimeType,nodeDays
		from flowTempletNode
		where templetID = '201204010001'
	end
	else					--货后付款
	begin
		insert contractFlow(contractID, nodeNum, nodeName,startTimeType,nodeDays)
		select @contractID, nodeNum, nodeName,startTimeType,nodeDays
		from flowTempletNode
		where templetID = '201204010002'	--这里应该定义一个不同的流程
	end
	if @@ERROR <> 0 
	begin
		break
	end
	FETCH NEXT FROM tar INTO @contractID, @paymentMode
end
CLOSE tar
DEALLOCATE tar


--历史数据清理：2013-10-15
use fTradeDB2
select * from flowTempletNode
select * from contractFlow where contractID='20120001'
update contractFlow
set	startTimeType='startTime',	--起算时间类型:'startTime'从流程开始时间，
								--'lastNodeCompleted'->上一节点完成日期，
								--'goodsArrivalTime'->到货时间
	nodeDays=7,			--节点允许时间（天）
	curLeftDays=0,		--节点剩余时间(天)，由数据库计算程序每天计算 add by lw 2012-4-19
	startTime='',		--节点开始时间
	endTime='',			--节点完成时间
	nStatus=9			--节点状态：0->未启动，1->到达，-1->返回上一节点，9->完成
select * from contractFlow
where contractID='20133104' and nodeNum='1'

select acceptedTime, startTime, completedTime, * from contractInfo
	--acceptedTime smalldatetime null,	--受理时间(签约时间)（这个需要客户这是招标中心传递合同的时间，时间写在原始合同上，客户确认不用显式登记）
	--startTime smalldatetime null,		--合同启动时间 add by lw 2012-5-8 客户提出前4个要监控的时间都是以启动时间为开始时间的天数
	--completedTime smalldatetime null,	--归档时间



