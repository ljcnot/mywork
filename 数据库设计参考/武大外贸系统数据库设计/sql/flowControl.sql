use fTradeDB
/*
	武大外贸合同管理信息系统--流程管理
	author:		卢苇
	CreateDate:	2012-4-8
	UpdateDate: 
*/
--1.标准流程表：
drop TABLE standFlow
CREATE TABLE standFlow
(
	flowID int IDENTITY(1,1) NOT NULL,--主键：流程编号
	flowName nvarchar(30) null,		--流程名称
		
	isActive int default(0),		--是否可用（激活）：0->未激活，1->已激活
	activeDate smalldatetime null,	--激活日期
	notes nvarchar(500) null,		--备注
	
	--最新维护情况:
	modiManID varchar(10) null,		--维护人工号
	modiManName varchar(30) null,	--维护人姓名
	modiTime smalldatetime null,	--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),			--当前正在锁定编辑的人工号

 CONSTRAINT [PK_standFlow] PRIMARY KEY CLUSTERED 
(
	[flowID] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--测试数据：
insert standFlow(flowName, isActive,activeDate, notes)
values('标准流程（货前付款）', 1, GETDATE(), '')
insert standFlow(flowName, isActive,activeDate, notes)
values('标准流程（货后付款）', 1, GETDATE(), '')

--2.流程环节表：
drop TABLE flowNodes
CREATE TABLE flowNodes
(
	flowID int NOT NULL,	--主键：流程编号
	nodeNum int not null,				--主键：节点序号
	nodeName nvarchar(30) not null,		--节点名称
	startTimeType varchar(30) default('lastNodeCompleted'),--起算时间类型:'lastNodeCompleted'->上一节点完成日期，'goodsArrivalTime'->到货时间
	nodeDays int not null,				--节点允许时间（天）
 CONSTRAINT [PK_flowNodes] PRIMARY KEY CLUSTERED 
(
	[flowID] asc,
	[nodeNum] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[flowNodes] WITH CHECK ADD CONSTRAINT [FK_flowNodes_standFlow] FOREIGN KEY([flowID])
REFERENCES [dbo].[standFlow] ([flowID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[flowNodes] CHECK CONSTRAINT [FK_flowNodes_standFlow]
GO
--测试数据：
select * from standFlow
insert flowNodes(flowID, nodeNum, nodeName, startTimeType, nodeDays)
select 1, nodeNum, nodeName, startTimeType, nodeDays from contractFlow
insert flowNodes(flowID, nodeNum, nodeName, startTimeType, nodeDays)
select 2, nodeNum, nodeName, startTimeType, nodeDays from contractFlow

select * from flowNodes
select * from codeDictionary where classCode=4
