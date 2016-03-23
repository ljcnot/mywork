use fTradeDB
/*
	�����ó��ͬ������Ϣϵͳ--����ģ�����
	author:		¬έ
	CreateDate:	2012-3-30
	UpdateDate: 
*/

--1.����ģ���
drop TABLE flowTemplet
CREATE TABLE flowTemplet
(
	templetID varchar(12) not null,		--������ģ����
	templetName nvarchar(30) not null,	--ģ������
	notes nvarchar(300) null,			--˵��

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName varchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���

 CONSTRAINT [PK_flowTemplet] PRIMARY KEY CLUSTERED 
(
	[templetID] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�������ݣ�
insert flowTemplet(templetID, templetName, notes)
values('201204010001','��׼ģ��','����һ����׼ģ��')

--2.����ģ��ڵ��
drop TABLE flowTempletNode
CREATE TABLE flowTempletNode
(
	templetID varchar(12) not null,		--������ģ����
	nodeNum int not null,				--�������ڵ����
	nodeName nvarchar(30) not null,		--�ڵ�����
	startTimeType varchar(30) default('startTime'),--����ʱ������:'startTime'�����̿�ʼʱ�䣬
																--'lastNodeCompleted'->��һ�ڵ�������ڣ�
																--'goodsArrivalTime'->����ʱ��
	nodeDays int not null,				--�ڵ�����ʱ�䣨�죩
	
 CONSTRAINT [PK_flowTempletNode] PRIMARY KEY CLUSTERED 
(
	[templetID] asc,
	[nodeNum] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[flowTempletNode] WITH CHECK ADD CONSTRAINT [FK_flowTempletNode_flowTemplet] FOREIGN KEY([templetID])
REFERENCES [dbo].[flowTemplet] ([templetID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[flowTempletNode] CHECK CONSTRAINT [FK_flowTempletNode_flowTemplet] 
GO

--�������ݣ�
truncate table flowTempletNode

select * from flowTempletNode

insert flowTempletNode(templetID, nodeNum, nodeName, nodeDays)
values('201204010001',1,'ǩ������Э��',4)
insert flowTempletNode(templetID, nodeNum, nodeName, nodeDays)
values('201204010001',2,'ǩ����ó��ͬ',6)
insert flowTempletNode(templetID, nodeNum, nodeName, nodeDays)
values('201204010001',3,'��֤����',21)
insert flowTempletNode(templetID, nodeNum, nodeName, nodeDays)
values('201204010001',4,'�������',33)
insert flowTempletNode(templetID, nodeNum, nodeName, startTimeType, nodeDays)
values('201204010001',5,'����','goodsArrivalTime',17)
insert flowTempletNode(templetID, nodeNum, nodeName, startTimeType, nodeDays)
values('201204010001',6,'�ͽ�����','lastNodeCompleted',17)
insert flowTempletNode(templetID, nodeNum, nodeName, startTimeType, nodeDays)
values('201204010001',7,'����','lastNodeCompleted',15)
insert flowTempletNode(templetID, nodeNum, nodeName, startTimeType, nodeDays)
values('201204010001',8,'�������','lastNodeCompleted',90)

insert flowTempletNode(templetID, nodeNum, nodeName, nodeDays)
select '201204010002',nodeNum, nodeName, nodeDays from flowTempletNode

delete flowTempletNode where templetID='201204010002' and nodeNum=2
select * from flowTempletNode for xml auto