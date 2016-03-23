use fTradeDB
/*
	�����ó��ͬ������Ϣϵͳ--���̹���
	author:		¬έ
	CreateDate:	2012-4-8
	UpdateDate: 
*/
--1.��׼���̱�
drop TABLE standFlow
CREATE TABLE standFlow
(
	flowID int IDENTITY(1,1) NOT NULL,--���������̱��
	flowName nvarchar(30) null,		--��������
		
	isActive int default(0),		--�Ƿ���ã������0->δ���1->�Ѽ���
	activeDate smalldatetime null,	--��������
	notes nvarchar(500) null,		--��ע
	
	--����ά�����:
	modiManID varchar(10) null,		--ά���˹���
	modiManName varchar(30) null,	--ά��������
	modiTime smalldatetime null,	--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),			--��ǰ���������༭���˹���

 CONSTRAINT [PK_standFlow] PRIMARY KEY CLUSTERED 
(
	[flowID] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�������ݣ�
insert standFlow(flowName, isActive,activeDate, notes)
values('��׼���̣���ǰ���', 1, GETDATE(), '')
insert standFlow(flowName, isActive,activeDate, notes)
values('��׼���̣����󸶿', 1, GETDATE(), '')

--2.���̻��ڱ�
drop TABLE flowNodes
CREATE TABLE flowNodes
(
	flowID int NOT NULL,	--���������̱��
	nodeNum int not null,				--�������ڵ����
	nodeName nvarchar(30) not null,		--�ڵ�����
	startTimeType varchar(30) default('lastNodeCompleted'),--����ʱ������:'lastNodeCompleted'->��һ�ڵ�������ڣ�'goodsArrivalTime'->����ʱ��
	nodeDays int not null,				--�ڵ�����ʱ�䣨�죩
 CONSTRAINT [PK_flowNodes] PRIMARY KEY CLUSTERED 
(
	[flowID] asc,
	[nodeNum] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[flowNodes] WITH CHECK ADD CONSTRAINT [FK_flowNodes_standFlow] FOREIGN KEY([flowID])
REFERENCES [dbo].[standFlow] ([flowID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[flowNodes] CHECK CONSTRAINT [FK_flowNodes_standFlow]
GO
--�������ݣ�
select * from standFlow
insert flowNodes(flowID, nodeNum, nodeName, startTimeType, nodeDays)
select 1, nodeNum, nodeName, startTimeType, nodeDays from contractFlow
insert flowNodes(flowID, nodeNum, nodeName, startTimeType, nodeDays)
select 2, nodeNum, nodeName, startTimeType, nodeDays from contractFlow

select * from flowNodes
select * from codeDictionary where classCode=4
