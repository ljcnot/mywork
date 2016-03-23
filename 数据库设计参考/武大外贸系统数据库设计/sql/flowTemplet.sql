use fTradeDB
/*
	武大外贸合同管理信息系统--流程模板管理
	author:		卢苇
	CreateDate:	2012-3-30
	UpdateDate: 
*/

--1.流程模板表：
drop TABLE flowTemplet
CREATE TABLE flowTemplet
(
	templetID varchar(12) not null,		--主键：模板编号
	templetName nvarchar(30) not null,	--模板名称
	notes nvarchar(300) null,			--说明

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName varchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号

 CONSTRAINT [PK_flowTemplet] PRIMARY KEY CLUSTERED 
(
	[templetID] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--测试数据：
insert flowTemplet(templetID, templetName, notes)
values('201204010001','标准模板','这是一个标准模板')

--2.流程模板节点表：
drop TABLE flowTempletNode
CREATE TABLE flowTempletNode
(
	templetID varchar(12) not null,		--主键：模板编号
	nodeNum int not null,				--主键：节点序号
	nodeName nvarchar(30) not null,		--节点名称
	startTimeType varchar(30) default('startTime'),--起算时间类型:'startTime'从流程开始时间，
																--'lastNodeCompleted'->上一节点完成日期，
																--'goodsArrivalTime'->到货时间
	nodeDays int not null,				--节点允许时间（天）
	
 CONSTRAINT [PK_flowTempletNode] PRIMARY KEY CLUSTERED 
(
	[templetID] asc,
	[nodeNum] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[flowTempletNode] WITH CHECK ADD CONSTRAINT [FK_flowTempletNode_flowTemplet] FOREIGN KEY([templetID])
REFERENCES [dbo].[flowTemplet] ([templetID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[flowTempletNode] CHECK CONSTRAINT [FK_flowTempletNode_flowTemplet] 
GO

--测试数据：
truncate table flowTempletNode

select * from flowTempletNode

insert flowTempletNode(templetID, nodeNum, nodeName, nodeDays)
values('201204010001',1,'签订代理协议',4)
insert flowTempletNode(templetID, nodeNum, nodeName, nodeDays)
values('201204010001',2,'签订外贸合同',6)
insert flowTempletNode(templetID, nodeNum, nodeName, nodeDays)
values('201204010001',3,'开证付款',21)
insert flowTempletNode(templetID, nodeNum, nodeName, nodeDays)
values('201204010001',4,'办理免表',33)
insert flowTempletNode(templetID, nodeNum, nodeName, startTimeType, nodeDays)
values('201204010001',5,'报关','goodsArrivalTime',17)
insert flowTempletNode(templetID, nodeNum, nodeName, startTimeType, nodeDays)
values('201204010001',6,'送交材料','lastNodeCompleted',17)
insert flowTempletNode(templetID, nodeNum, nodeName, startTimeType, nodeDays)
values('201204010001',7,'验收','lastNodeCompleted',15)
insert flowTempletNode(templetID, nodeNum, nodeName, startTimeType, nodeDays)
values('201204010001',8,'结清余款','lastNodeCompleted',90)

insert flowTempletNode(templetID, nodeNum, nodeName, nodeDays)
select '201204010002',nodeNum, nodeName, nodeDays from flowTempletNode

delete flowTempletNode where templetID='201204010002' and nodeNum=2
select * from flowTempletNode for xml auto