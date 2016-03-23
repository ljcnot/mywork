use newfTradeDB2
/*
	�����ó��ͬ������Ϣϵͳ--��ͬ����
	author:		¬έ
	CreateDate:	2012-3-1
	UpdateDate: 
*/
/*������
1.userInfo���ݿ�Ҫ��չ����绰
2.Ҫ�������һ����¼�õ��û���
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

--��ͬ�б�
select contractStatus, isnull(ci.curLeftDays,0) curNodeLeftDays, ci.contractID, curNode, curNodeName,
	--�豸��Ϣ��
	dbo.getEqpInfoOfContract(ci.contractID) eqpInfo,
	--������Ϣ��
	totalAmount, currency, cd.objDesc currencyName,
	dbo.getClgInfoOfContract(ci.contractID) clgInfo,
	dbo.getClgInfoOfContract(ci.contractID) userIDInfo,
	dbo.getClgInfoOfContract(ci.contractID) userInfo,
	--������λ��
	supplierID, supplierName, supplierOprMan, supplierOprManMobile, supplierOprManTel, convert(varchar(10),supplierSignedTime,120) supplierSignedTime,
	--ί����ó��˾��
	traderID, abbTraderName, traderName, traderOprMan, traderOprManMobile, traderOprManTel, convert(varchar(10),traderSignedTime,120) traderSignedTime,
	--��Ҫ����״̬��
	case f1.nStatus when 0 then '' when 1 then cast(f1.curLeftDays as varchar(10)) when -1 then '��' when 9 then '��' end nodeSignProtocol,
	case f3.nStatus when 0 then '' when 1 then cast(f3.curLeftDays as varchar(10)) when -1 then '��' when 9 then '��' end nodePay,
	case f4.nStatus when 0 then '' when 1 then cast(f4.curLeftDays as varchar(10)) when -1 then '��' when 9 then '��' end nodeTaxFree,
	case f5.nStatus when 0 then '' when 1 then cast(f5.curLeftDays as varchar(10)) when -1 then '��' when 9 then '��' end nodeDeclaration,
    case f6.nStatus when 0 then '' when 1 then cast(f6.curLeftDays as varchar(10)) when -1 then '��' when 9 then '��' end nodeCommit,
    case f7.nStatus when 0 then '' when 1 then cast(f7.curLeftDays as varchar(10)) when -1 then '��' when 9 then '��' end nodeAccept,
    case f8.nStatus when 0 then '' when 1 then cast(f8.curLeftDays as varchar(10)) when -1 then '��' when 9 then '��' end nodeAccount,
	--���:
	dbo.getTimeoutOfContract(ci.contractID) timeoutRecord, dbo.getEventOfContract(ci.contractID,'00011275') haveEvent,
    dbo.getDiscussStatusOfContract(ci.contractID,'00011275') haveMsg,
    --��Ҫ�¼���
	paymentMode, cd2.objDesc paymentModeDesc, goodsArrivalTime,
	convert(varchar(10),acceptedTime,120) acceptedTime, convert(varchar(10),completedTime,120) completedTime, notes,
    convert(varchar(10),ci.startTime,120) startTime
from contractInfo ci left join codeDictionary cd on ci.currency = cd.objCode and cd.classCode=3 
	left join codeDictionary cd2 on ci.paymentMode = cd2.objCode and cd2.classCode=4 
	left join contractFlow f1 on ci.contractID = f1.contractID and f1.nodeName ='ǩ��Э��'
    left join contractFlow f3 on ci.contractID = f3.contractID and f3.nodeName ='��֤����'
    left join contractFlow f4 on ci.contractID = f4.contractID and f4.nodeName ='�������'
    left join contractFlow f5 on ci.contractID = f5.contractID and f5.nodeName ='����'
    left join contractFlow f6 on ci.contractID = f6.contractID and f6.nodeName ='�ͽ�����'
    left join contractFlow f7 on ci.contractID = f7.contractID and f7.nodeName ='����'
    left join contractFlow f8 on ci.contractID = f8.contractID and f8.nodeName ='�������'
where  cast(dbo.getEventOfContract(ci.contractID,'00009661') as varchar(max)) <> '<root/>' and contractStatus<>9
order by contractStatus, curNodeLeftDays, curNode                
select * from userInfo where jobNumber='00009661'
select * from country
select * from contractInfo

select * from contractInfo where contractID='20130255'
select * from contractFlow
select * from flowTempletNode
--1.��ó��ͬ����
drop TABLE contractInfo
CREATE TABLE contractInfo
(
	contractID varchar(12) not null,	--��������ͬ��ţ�ʹ�õ� 1 �ź��뷢��������
	contractStatus int default(0),		--��ͬ״̬:0->��ͬ�ն��壬δ������1->���ߺ�ͬ��9->����ɺ�ͬ
	curNode int null,					--��ǰִ�нڵ���
	curNodeName nvarchar(30) null,		--��ǰִ�нڵ����ƣ��������
	curLeftDays int null,				--��ǰ�ڵ�ʣ��ʱ��(��)�������ݿ�������ÿ�����
	
/*	--������λ�����ݿͻ����Ҫ��֧��1�Զ�Ĺ�ϵ���ĳ���ұ�
	clgCode char(3) not null,			--ѧԺ����
	clgName nvarchar(30) null,			--ѧԺ����:������ƣ�������ʷ���� add by lw 2010-11-30
	oprMan nvarchar(30) null,			--������λ������
	oprManMobile varchar(30) null,		--������λ��������ϵ�绰���ֻ�
	oprManTel varchar(30) null,			--������λ��������ϵ�绰�������绰
	
	����2012-4-1���ۣ��豸Ӧ�ÿ����Ƕ��֣���Ϊ��ұ�
	eName nvarchar(30) not null,		--�豸����
	eFormat nvarchar(20) not null,		--�ͺŹ��
	cCode char(3) not null,				--ԭ���أ����Ҵ��룩
	quantity int not null,				--����
	price money null,					--���ۣ�>0
*/

	--������λ��
	supplierID varchar(12) not null,	--������λ���
	supplierName nvarchar(30) null,		--������λ���ƣ�������ƣ�������ʷ���� add by lw 2012-3-27
	supplierOprManID varchar(18) null,	--������λ������ID
	supplierOprMan nvarchar(30) null,	--������λ�����ˣ�������ƣ�������ʷ���� add by lw 2012-3-27
	supplierOprManMobile varchar(30) null,	--������λ��������ϵ�绰���ֻ���������ƣ�������ʷ���� add by lw 2012-3-27
	supplierOprManTel varchar(30) null,	--������λ��������ϵ�绰�������绰��������ƣ�������ʷ���� add by lw 2012-3-27
	supplierSignedTime smalldatetime null,	--ǩԼʱ��
	
	--ί����ó��˾��������
	traderID varchar(12) not null,		--��ó��˾���
	traderName nvarchar(30) null,		--��ó��˾���ƣ�������ƣ�������ʷ���� add by lw 2012-3-27
	abbTraderName nvarchar(6) null,		--��ó��˾���:������ƣ�add by lw 2012-4-27���ݿͻ�Ҫ������
	traderOprManID varchar(18) null,	--��ó��˾������ID
	traderOprMan nvarchar(30) null,		--��ó��˾�����ˣ�������ƣ�������ʷ���� add by lw 2012-3-27
	traderOprManMobile varchar(30) null,--��ó��˾��������ϵ�绰���ֻ���������ƣ�������ʷ���� add by lw 2012-3-27
	traderOprManTel varchar(30) null,	--��ó��˾��������ϵ�绰�������绰��������ƣ�������ʷ���� add by lw 2012-3-27
	traderSignedTime smalldatetime null,--ί��ʱ��
	
	totalAmount money null,				--�豸�ܼ�
	currency smallint not null,			--����,�ɵ�3�Ŵ����ֵ䶨��
	dollar money null,					--�ۺ���Ԫ
	payFee money default(0),			--ʵ�������ѣ�����ң������ֶμ��㣨���ʹ̶�����20����Ԫ�������	add by lw 2013-6-12
	paymentMode smallint not null,		--���ʽ, �ɵ�4�Ŵ����ֵ䶨��
	goodsArrivalTime smalldatetime null,--Ԥ�Ƶ���ʱ��
	realGoodsArrivalTime smalldatetime null,--ʵ�ʵ���ʱ��

/*	����2012-4-1���ۣ�ɾ���б�������ϵ����Ϣ��	
	tenderingCenterOprManID varchar(10) null,--�б����ģ��������ˣ�ID:���ù���
	tenderingCenterOprMan nvarchar(30) null,--�б����ģ��������ˣ���������ƣ�������ʷ���� add by lw 2012-3-27
	tenderingCenterOprManMobile varchar(30) null,	--�б����ľ�������ϵ�绰���ֻ���������ƣ�������ʷ���� add by lw 2012-3-27
	tenderingCenterOprManTel varchar(30) null,	--�б����ľ�������ϵ�绰�������绰��������ƣ�������ʷ���� add by lw 2012-3-27
*/
						--������Ͷ�����Ķ���Э��
	acceptedTime smalldatetime null,	--����ʱ��(ǩԼʱ��)�������Ҫ�ͻ������б����Ĵ��ݺ�ͬ��ʱ�䣬ʱ��д��ԭʼ��ͬ�ϣ��ͻ�ȷ�ϲ�����ʽ�Ǽǣ�
	startTime smalldatetime null,		--��ͬ����ʱ�� add by lw 2012-5-8 �ͻ����ǰ4��Ҫ��ص�ʱ�䶼��������ʱ��Ϊ��ʼʱ�������
	completedTime smalldatetime null,	--�鵵ʱ��
	notes nvarchar(500) null,			--��ע
	
	event2Manager char(1) default('N'),	--�Ƿ����豸��������Ա��Ҫ������¼�������ó��˾�ϴ��˸����������̱������ʱ������Ҫ������¼���add by lw 2012-4-24 �����̱������� by lw 2012-5-9
	event2ManagerType smallint default(0),	--��������Ա���¼����1->֪ͨ������Ҫ�����2->���µĸ�������Ҫ���Ĳ�����Ƿ��Ƿ���ɱ����ڣ�3->�����̱����Ҫ����
	event2ManagerText nvarchar(100) null,	--��������Ա���¼�����
	event2ManagerTime smalldatetime null,	--��������Ա���¼������¼�
	event2Trader char(1) default('N'),	--�Ƿ�����ó��˾��Ҫ������¼�����������ת����ʱ�����ڳ������Ѻ����̱��������ʱ������Ҫ������¼���add lw 2012-5-9
	event2TraderType smallint default(0),	--����ó��˾���¼����1->֪ͨ������Ҫ�����2->���ڳ��ڣ���Ҫ�ϴ���ɵĹ�������
	event2TraderText nvarchar(100) null,	--����ó��˾���¼�����
	event2TraderTime smalldatetime null,	--����ó��˾���¼������¼�
	event2ClgMan char(1) default('N'),	--�Ƿ��ж�����λ��Ҫ������¼��������̱������ʱ������Ҫ������¼���add lw 2012-5-9
	event2ClgManType smallint default(0),	--��������λ���¼����1->֪ͨ������Ҫ�����3->�����̱����Ҫ����
	event2ClgManText nvarchar(100) null,	--��������λ���¼�����
	event2ClgManTime smalldatetime null,	--��������λ���¼������¼�

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName varchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���

 CONSTRAINT [PK_contractInfo] PRIMARY KEY CLUSTERED 
(
	[contractID] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
CREATE NONCLUSTERED INDEX [IX_contractInfo] ON [dbo].[contractInfo] 
(
	[completedTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--2.��ó��ͬ������λ��
--����2012��4��28�ջ��������������λ�붩���˹�ϵ�ĳ�һ�Զ��ϵ���������豸�ĳ��붩���˹ҽ�
--Ժ�����	add by lw 2012-5-19���ݿͻ�Ҫ������
select contractID, clgCode, clgName, abbClgName, ordererID, orderer, ordererMobile, ordererTel
from contractCollege

drop TABLE contractCollege
CREATE TABLE contractCollege
(
	contractID varchar(12) not null,	--��������ͬ���
	clgCode char(3) not null,			--������ѧԺ����
	clgName nvarchar(30) null,			--ѧԺ����:������ƣ�������ʷ����
	abbClgName nvarchar(6) null,		--Ժ�����	add by lw 2012-5-19���ݿͻ�Ҫ������
/*	����2012-4-1���ۣ�������λֻ����������λ��Ժ����
	uCode varchar(8) not null,			--������ʹ�õ�λ����
	uName nvarchar(30) not null,		--ʹ�õ�λ����	
*/	
	ordererID varchar(10) not null,		--������������ID
	orderer nvarchar(30) not null,		--������ƣ����������� add by lw 2013-5-5
	ordererMobile varchar(30) null,		--������λ��������ϵ�绰���ֻ�:������ƣ�������ʷ����
	ordererTel varchar(30) null,			--������λ��������ϵ�绰�������绰:������ƣ�������ʷ����
	
 CONSTRAINT [PK_contractCollege] PRIMARY KEY CLUSTERED 
(
	[contractID] desc,
	[clgCode] asc,
	[ordererID] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[contractCollege] WITH CHECK ADD CONSTRAINT [FK_contractCollege_contractInfo] FOREIGN KEY([contractID])
REFERENCES [dbo].[contractInfo] ([contractID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[contractCollege] CHECK CONSTRAINT [FK_contractCollege_contractInfo] 
GO

--������
CREATE NONCLUSTERED INDEX [IX_contractCollege] ON [dbo].[contractCollege] 
(
	[contractID] asc,
	[ordererMobile] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


select * from contractEqp
--3.��ó��ͬ�����豸��
--����2012��4��28�ջ��������������λ�붩���˹�ϵ�ĳ�һ�Զ��ϵ���������豸�ĳ��붩���˹ҽ�
drop TABLE contractEqp
CREATE TABLE contractEqp
(
	rowNum bigint IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,	--�кţ���֤��ȷ˳��
	contractID varchar(12) not null,	--��������ͬ���
	clgCode char(3) not null,			--������ѧԺ����	--�������Ҫ�󣬽������豸�붩����λ����add by lw 2012-5-8
	clgName nvarchar(30) null,			--ѧԺ����:������ƣ�������ʷ����
	ordererID varchar(10) not null,		--������������ID
	orderer nvarchar(30) not null,		--������ƣ����������� add by lw 2013-5-5
	eName nvarchar(30) not null,		--�������豸����
	eFormat nvarchar(20) not null,		--�������ͺŹ��
	cCode char(3) not null,				--ԭ���أ����Ҵ��룩
	quantity int not null,				--����
	price money null,					--���ۣ�>0
	
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


--�����
ALTER TABLE [dbo].[contractEqp]  WITH CHECK ADD  CONSTRAINT [FK_contractEqp_contractCollege] FOREIGN KEY([contractID], [clgCode],[ordererID])
REFERENCES [dbo].[contractCollege] ([contractID], [clgCode],[ordererID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[contractEqp] CHECK CONSTRAINT [FK_contractEqp_contractCollege]
GO


--4.��ó��ִͬ�����̱�
drop TABLE contractFlow
CREATE TABLE contractFlow
(
	contractID varchar(12) not null,	--��������ͬ���
	nodeNum int not null,				--�������ڵ����
	nodeName nvarchar(30) not null,		--�ڵ�����
	startTimeType varchar(30) default('lastNodeCompleted'),--����ʱ������:'startTime'�����̿�ʼʱ�䣬
																		--'lastNodeCompleted'->��һ�ڵ�������ڣ�
																		--'goodsArrivalTime'->����ʱ��
	nodeDays int not null,				--�ڵ�����ʱ�䣨�죩
	curLeftDays int null,				--�ڵ�ʣ��ʱ��(��)�������ݿ�������ÿ����� add by lw 2012-4-19
	startTime smalldatetime null,		--�ڵ㿪ʼʱ��
	endTime smalldatetime null,			--�ڵ����ʱ��
	nStatus int default(0),				--�ڵ�״̬��0->δ������1->���-1->������һ�ڵ㣬9->���
	undoneChange int default(0),		--�Ƿ���δ��ɵı����0->û�У�1->�� add by lw 2013-10-15
	--���ڼ�¼��
	yellowLampTimes smallint default(0),--�Ƶƴ���
	redLampTimes smallint default(0),	--��ƴ���
	SMSTimes smallint default(0),		--���Ŵ���
 CONSTRAINT [PK_contractFlow] PRIMARY KEY CLUSTERED 
(
	[contractID] desc,
	[nodeNum] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[contractFlow] WITH CHECK ADD CONSTRAINT [FK_contractFlow_contractInfo] FOREIGN KEY([contractID])
REFERENCES [dbo].[contractInfo] ([contractID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[contractFlow] CHECK CONSTRAINT [FK_contractFlow_contractInfo] 
GO

--5.��ó��ͬ������
drop TABLE contractAttachment
CREATE TABLE contractAttachment
(
	rowNum int IDENTITY(1,1) NOT NULL,	--����:�к�
	contractID varchar(12) not null,	--�������ͬ���
	attachmentType smallint not null,	--�������ͣ��ɵ�5�Ŵ����ֵ䶨��
	aFilename varchar(128) not NULL,	--������ͼƬ�ļ���Ӧ��36λȫ��Ψһ�����ļ���
	notes nvarchar(100) null,			--˵��
 CONSTRAINT [PK_contractAttachment] PRIMARY KEY CLUSTERED 
(
	[aFilename] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[contractAttachment] WITH CHECK ADD CONSTRAINT [FK_contractAttachment_contractInfo] FOREIGN KEY([contractID])
REFERENCES [dbo].[contractInfo] ([contractID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[contractAttachment] CHECK CONSTRAINT [FK_contractAttachment_contractInfo] 
GO

--������
CREATE NONCLUSTERED INDEX [IX_contractAttachment] ON [dbo].[contractAttachment] 
(
	[contractID] asc,
	[attachmentType] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--6.��ó��ͬ���̻������Ѷ��ű�
drop TABLE contractSMS
CREATE TABLE contractSMS
(
	rowNum int IDENTITY(1,1) NOT NULL,	--����:�к�
	contractID varchar(12) not null,	--��ͬ���
	mobile varchar(30) not null,		--�ֻ���
	msg nvarchar(100) null,				--����
	isSend char(1) default('N')			--�Ƿ���
	
 CONSTRAINT [PK_contractSMS] PRIMARY KEY CLUSTERED 
(
	[rowNum] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

/*
--�����ʹ�������ɾ����ʷ��Ϣ��
ALTER TABLE [dbo].[contractSMS] WITH CHECK ADD CONSTRAINT [FK_contractSMS_contractInfo] FOREIGN KEY([contractID])
REFERENCES [dbo].[contractInfo] ([contractID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[contractSMS] CHECK CONSTRAINT [FK_contractSMS_contractInfo] 
GO
*/

--7.��ó��ͬ��������
drop TABLE contractFlowChange
CREATE TABLE contractFlowChange
(
	flowChangeApplyID varchar(12) not null,	--������������뵥�ţ�ʹ�õ� 3 �ź��뷢��������
	applyStatus smallint default(0),	--�������״̬��-1->���ϵı�������绷���˻�ʱ�Զ����ϣ�
														--0->�༭�У�δ���ͣ�1->�ѷ��ͣ��ȴ��ظ���2->�ѽ��ջظ���ͬ�������ȴ���ˣ�
														--3->�ظ������ͬ������8->����ˣ�ͬ������9->����ˣ���ͬ������10����ɱ��
														
	contractID varchar(12) not null,	--�������ͬ���
	applicantType smallint not null,	--���������ͣ��û���𣩣���101�Ŵ����ֵ䶨��
	applicantID varchar(10) not null,	--������ID
	applicantName nvarchar(30) not null,--����������
	applyDate smalldatetime not null,	--����������
	applyChangeFlowNode varchar(30) not null,--�������Ļ���
	applyReason nvarchar(300) not null,	--����������

	--������ڶ����������Ҫ�����Ƴ�����ұ�	
	recipientID varchar(10) not null,	--���������ID
	recipient nvarchar(30) not null,	--�������������
	replyDate smalldatetime not null,	--�ظ�����
	replyDesc nvarchar(300) not null,	--�ظ�˵��
	
	checkerID varchar(10) null,			--��׼��ID
	checker nvarchar(30) null,			--��׼������
	checkDate smalldatetime null,		--��׼����
	checkDesc nvarchar(300) null,		--��׼������
	
	changeDate smalldatetime null,		--��������
	
 CONSTRAINT [PK_contractFlowChange] PRIMARY KEY CLUSTERED 
(
	[flowChangeApplyID] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
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
	function:	1.������ó��ͬ��Ż�ȡָ����ͬ�Ķ�����λ
	input: 
				@contractID varchar(12)	--��ͬ���
	output: 
				return xml				--��xml��ʽ�洢�Ķ�����λ�б�
	author:		¬έ
	CreateDate:	2012-3-28
	UpdateDate: 
*/
create FUNCTION getClgInfoOfContract
(  
	@contractID varchar(12)	--��ͬ���
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
--���ԣ�
select dbo.getClgInfoOfContract('20120012')
select * from contractInfo
select * from college


drop FUNCTION getOrdererInfoOfContract
/*
	name:		getOrdererInfoOfContract
	function:	1.1.������ó��ͬ��ź͵�λ�����ȡָ����ͬ�Ķ�����
	input: 
				@contractID varchar(12)	--��ͬ���
				@clgCode char(3)		--��λ����
	output: 
				return xml				--��xml��ʽ�洢�Ķ�����
	author:		¬έ
	CreateDate:	2012-5-5
	UpdateDate: 
*/
create FUNCTION getOrdererInfoOfContract
(  
	@contractID varchar(12),	--��ͬ���
	@clgCode char(3)			--��λ����
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
--���ԣ�
select dbo.getOrdererInfoOfContract('20130003','031')
select * from contractInfo
select * from college


drop FUNCTION getClgEqpInfoOfContract
/*
	name:		getClgEqpInfoOfContract
	function:	1.1.������ó��ͬ��Ż�ȡָ����ͬ�Ķ�����λ�붩���豸
	input: 
				@contractID varchar(12)	--��ͬ���
	output: 
				return xml				--��xml��ʽ�洢�Ķ�����λ�붩���豸�б�
	author:		¬έ
	CreateDate:	2012-5-9
	UpdateDate: 
*/
create FUNCTION getClgEqpInfoOfContract
(  
	@contractID varchar(12)	--��ͬ���
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
--���ԣ�
select dbo.getClgEqpInfoOfContract('20120001')
select * from contractInfo


drop FUNCTION getTimeoutOfContract
/*
	name:		getTimeoutOfContract
	function:	1.2.������ó��ͬ��Ż�ȡָ����ͬ�ľ����¼
	input: 
				@contractID varchar(12)	--��ͬ���
	output: 
				return xml				--��xml��ʽ�洢�Ķ�����λ�б�
	author:		¬έ
	CreateDate:	2013-6-13
	UpdateDate: 
*/
create FUNCTION getTimeoutOfContract
(  
	@contractID varchar(12)	--��ͬ���
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
--���ԣ�
select dbo.getTimeoutOfContract('20120046')
select * from contractInfo
select * from college

drop FUNCTION getEqpInfoOfContract
/*
	name:		getEqpInfoOfContract
	function:	2.������ó��ͬ��Ż�ȡָ����ͬ�Ķ����豸
	input: 
				@contractID varchar(12)	--��ͬ���
	output: 
				return xml				--��xml��ʽ�洢�Ķ����豸�б�
	author:		¬έ
	CreateDate:	2012-4-4
	UpdateDate: 
*/
create FUNCTION getEqpInfoOfContract
(  
	@contractID varchar(12)	--��ͬ���
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
--���ԣ�
select dbo.getEqpInfoOfContract('20120011')


drop FUNCTION getAttachmentOfContract
/*
	name:		getAttachmentOfContract
	function:	3.������ó��ͬ��Ż�ȡָ����ͬ�ĸ���
	input: 
				@contractID varchar(12)	--��ͬ���
	output: 
				return xml				--��xml��ʽ�洢�Ķ����豸�б�
	author:		¬έ
	CreateDate:	2012-4-24
	UpdateDate: 
*/
create FUNCTION getAttachmentOfContract
(  
	@contractID varchar(12)	--��ͬ���
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
--���ԣ�
select dbo.getAttachmentOfContract('20120025')

select * from contractInfo

drop FUNCTION getEventOfContract
/*
	name:		getEventOfContract
	function:	4.������ó��ͬ��ź��û�ID��ȡָ����ͬ���¼�
	input: 
				@contractID varchar(12),--��ͬ���
				@userID varchar(10),	--�û�ʶ���
	output: 
				return xml				--��xml��ʽ�洢���¼�
	author:		¬έ
	CreateDate:	2012-5-9
	UpdateDate: modi by lw 2013-10-07����Լ������
*/
create FUNCTION getEventOfContract
(  
	@contractID varchar(12),	--��ͬ���
	@userID varchar(10)			--�û�ʶ���
)  
RETURNS xml
WITH ENCRYPTION
AS      
begin
	declare @userType int	--�û������101�Ŵ����ֵ䶨��
	set @userType = isnull((select userType from sysUserInfo where userID = @userID),0)
	if (@userType=1)	--��һ���ж��Ƿ��豸��������Ա
	begin
		declare @clgCode char(3) --Ժ������
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
		declare @traderID varchar(12)	--��ó��˾���
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
--���ԣ�
select dbo.getEventOfContract('20120067','00000891')
select * from contractInfo
select userType from sysUserInfo where userID = '201204230009'
select * from contractCollege

drop FUNCTION getDiscussStatusOfContract
/*
	name:		getDiscussStatusOfContract
	function:	5.������ó��ͬ��ź��û�ID��ȡ�Ƿ���δ�Ķ����������
	input: 
				@contractID varchar(12),--��ͬ���
				@userID varchar(10),	--�û�ʶ���
	output: 
				return varchar(12)		--'XXXX'�����ţ���δ�Ķ������������''��û��δ�Ķ����������
	author:		¬έ
	CreateDate:	2012-5-9
	UpdateDate: 
*/
create FUNCTION getDiscussStatusOfContract
(  
	@contractID varchar(12),	--��ͬ���
	@userID varchar(10)			--�û�ʶ���
)  
RETURNS varchar(12)
WITH ENCRYPTION
AS      
begin
	declare @updateTime datetime, @readTime datetime 		--����ʱ�䣬�Ķ�ʱ��
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
--���ԣ�
select dbo.getDiscussStatusOfContract('20120067','00000008')
select * from contractEqp where contractID='20120068'

drop PROCEDURE addContractInfo
/*
	name:		addContractInfo
	function:	1.�����ó��ͬ
				ע�⣺�ô洢�����Զ���������
	input: 
				@contractID varchar(12) output,	--��������ͬ��ţ�ʹ�õ� 1 �ź��뷢��������
				--������λ��Ϣ/�����豸��Ϣ�������ж�������
				@clgInfo xml,	--�������·�ʽ���:
									N'<root>
									  <contractCollege clgCode="123" jobNumber="00000891" oprManMobile="18602702392">
											<contractEqp contractID="201203280001" eName="Sony���ͼ����" eFormat="100Cpu" cCode="392" quantity="4" price="1000.0000" />
									  </contractCollege>
									  <contractCollege clgCode="124" jobNumber="00000906" oprManMobile="18602702391">
											<contractEqp contractID="201203280001" eName="IBM���ͼ����" eFormat="300Cpu" cCode="392" quantity="1" price="2000.0000" />
											<contractEqp contractID="201203280001" eName="HP���ͼ����" eFormat="200Cpu" cCode="392" quantity="5" price="3000.0000" />
									  </contractCollege>
									</root>'

				--������λ��
				@supplierID varchar(12),		--������λ���
				@supplierOprManID varchar(18),	--������λ������ID
				@supplierOprManMobile varchar(30),	--������λ��������ϵ�绰���ֻ���������ƣ�������ʷ���� add by lw 2012-3-27
				--@supplierSignedTime varchar(10),--ǩԼʱ��:���á�yyyy-MM-dd����ŵ���������
				
				--ί����ó��˾��������
				@traderID varchar(12),			--��ó��˾���
				@traderOprManID varchar(18),	--��ó��˾������ID
				@traderOprManMobile varchar(30),--��ó��˾��������ϵ�绰���ֻ���������ƣ�������ʷ���� add by lw 2012-3-27
				--@traderSignedTime varchar(10),	--ί��ʱ��:���á�yyyy-MM-dd����ŵ���������
				

				@totalAmount money,				--�豸�ܼ�
				@currency smallint,				--����,�ɵ�3�Ŵ����ֵ䶨��
				@dollar money,					--�ۺ���Ԫ
				@paymentMode smallint,			--���ʽ, �ɵ�4�Ŵ����ֵ䶨��
				@goodsArrivalTime varchar(10),	--Ԥ�Ƶ���ʱ�䣺���á�yyyy-MM-dd����ŵ���������
									--������Ͷ�����Ķ���Э��
				@acceptedTime varchar(10),		--����ʱ��:���á�yyyy-MM-dd����ŵ���������
				@notes nvarchar(500),			--��ע
				
				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output	--���ʱ��
	author:		¬έ
	CreateDate:	2012-3-30
	UpdateDate: ���ݿͻ������豸���ͬΪһ�Զ��ϵ������Ϊ�̶�ģʽ�������ӿ� by lw 2012-4-8
				���ݿͻ�Ҫ���ڵǼǺ�ͬ�п�����ʱ�޸��ֻ����룬�����ӿ�,�����豸�ܼۺ�������Ԫ�����ⲿ���� by lw 2012-4-24
				���ݿͻ�Ҫ�󣬽�������λ�붩���豸��������ͬ��Ÿĳɿ����ֹ����롣by lw 2012-5-8
				�޸��ֹ������������Ŀ������غŵĴ��� by lw 2012-5-10
				modi by lw 2012-5-21����xml�������ַ�"<>"�Ĵ���

*/
create PROCEDURE addContractInfo
	@contractID varchar(12) output,	--��������ͬ��ţ�ʹ�õ� 1 �ź��뷢��������
	--������λ��Ϣ�������ж�������
	@clgInfo xml,	

	--������λ��
	@supplierID varchar(12),		--������λ���
	@supplierOprManID varchar(18),	--������λ������ID
	@supplierOprManMobile varchar(30),	--������λ��������ϵ�绰���ֻ���������ƣ�������ʷ���� add by lw 2012-3-27
	--@supplierSignedTime varchar(10),--ǩԼʱ��:���á�yyyy-MM-dd����ŵ���������
	
	--ί����ó��˾��������
	@traderID varchar(12),			--��ó��˾���
	@traderOprManID varchar(18),	--��ó��˾������ID
	@traderOprManMobile varchar(30),--��ó��˾��������ϵ�绰���ֻ���������ƣ�������ʷ���� add by lw 2012-3-27
	--@traderSignedTime varchar(10),	--ί��ʱ��:���á�yyyy-MM-dd����ŵ���������
	
	@totalAmount money,				--�豸�ܼ�
	@currency smallint,				--����,�ɵ�3�Ŵ����ֵ䶨��
	@dollar money,					--�ۺ���Ԫ
	@paymentMode smallint,			--���ʽ, �ɵ�4�Ŵ����ֵ䶨��
	@goodsArrivalTime varchar(10),	--Ԥ�Ƶ���ʱ�䣺���á�yyyy-MM-dd����ŵ���������
						--������Ͷ�����Ķ���Э��
	@acceptedTime varchar(10),		--����ʱ��(ǩԼʱ��):���á�yyyy-MM-dd����ŵ���������
	@notes nvarchar(500),			--��ע

	@createManID varchar(10),	--�����˹���

	@Ret		int output,
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	declare @count int
	if (@contractID<>'')	--����Ƿ��غ�
	begin
		set @count = (select count(*) from contractInfo where contractID = @contractID)
		if (@count > 0)
			set @contractID = ''
	end
	set @count = 1
	if (@contractID='')
		while (@count > 0)
		begin
			--ʹ�ú��뷢���������µĺ��룺
			declare @curNumber varchar(50)
			exec dbo.getClassNumber 1, 1, @curNumber output
			set @contractID = @curNumber
			set @count = (select count(*) from contractInfo where contractID = @contractID)
		end
	else if (patindex('%[^0-9]%',@contractID COLLATE  Chinese_PRC_BIN ) = 0)	--�ж��Ƿ�Ϊ��������
	begin
		declare @sysNumber varchar(30) --���뷢�����е�ǰ����
		set @sysNumber = isnull((select curNumber from sysNumbers where numberClass = 1),'')
		if (@contractID > @sysNumber)
		begin
			update sysNumbers 
			set curNumber = @contractID
			where numberClass = 1
		end
	end

	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	--����������λ�Ͷ����豸��
	declare @eqpInfoTab as TABLE (
		contractID varchar(12) not null,	--��ͬ���
		clgCode char(3) not null,			--������λ��ѧԺ����	--�������Ҫ�󣬽������豸�붩����λ����add by lw 2012-5-8
		ordererID varchar(10) not null,		--������������ID
		eName nvarchar(30) not null,		--�豸����
		eFormat nvarchar(20) not null,		--�ͺŹ��
		cCode char(3) not null,				--ԭ���أ����Ҵ��룩
		quantity int not null,				--����
		price money null					--���ۣ�>0
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
	
/*	�����ⲿ���㣺modi by lw 2012-4-24
	declare @totalAmount money	--�ܽ��
	set @totalAmount = 	isnull((select SUM(quantity * price) from @eqpInfoTab),0)
	--��ȡ����,�����������Ԫ�۸�����Ȼ��ʱ���ƺú���Ҫ���壡
	declare @dollar money
	set @dollar = @totalAmount
*/

	--��ȡ������λ��Ϣ��
	declare @supplierName nvarchar(30)			--������λ���ƣ�������ƣ�������ʷ���� add by lw 2012-3-27
	set @supplierName = (select supplierName from supplierInfo where supplierID = @supplierID)
	declare @supplierOprMan	nvarchar(30)	--������λ�����ˣ�������ƣ�������ʷ���� add by lw 2012-3-27
	declare @supplierOprManTel varchar(30)	--������λ��������ϵ�绰�������绰��������ƣ�������ʷ���� add by lw 2012-3-27
	select @supplierOprMan = manName, @supplierOprManTel = tel
	from supplierManInfo where supplierID = @supplierID and manID = @supplierOprManID
	
	--��ȡ��ó��˾��Ϣ��
	declare @traderName nvarchar(30)		--��ó��˾���ƣ�������ƣ�������ʷ���� add by lw 2012-3-27
	declare @abbTraderName nvarchar(6)		--��ó��˾���	add by lw 2012-4-27���ݿͻ�Ҫ������
	select @traderName = traderName, @abbTraderName = abbTraderName 
	from traderInfo 
	where traderID = @traderID
	
	declare @traderOprMan nvarchar(30)		--��ó��˾�����ˣ�������ƣ�������ʷ���� add by lw 2012-3-27
	declare @traderOprManTel varchar(30)	--��ó��˾��������ϵ�绰�������绰��������ƣ�������ʷ���� add by lw 2012-3-27
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
--print '��ͬ����'
		--�ǼǶ�����λ��Ϣ��
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
--print '������λ'
		--�ǼǶ����豸��Ϣ��
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
--print '�����豸'
		
		--�������̣����ݿͻ�Ҫ�����̲�����ʽ���ã�ֻ���ݸ��ʽ����ǰ/������һ��С�ĵ������Ƿ��п�֤�򸶿�ڣ�
		--���������ں�ͬ�Ǽǵ�ʱ���������ȥ��modi by lw 2012-4-8
		if (@paymentMode>10)	--��ǰ����
		begin
			insert contractFlow(contractID, nodeNum, nodeName,startTimeType,nodeDays)
			select @contractID, nodeNum, nodeName,startTimeType,nodeDays
			from flowTempletNode
			where templetID = '201204010001'
		end
		else					--���󸶿�
		begin
			insert contractFlow(contractID, nodeNum, nodeName,startTimeType,nodeDays)
			select @contractID, nodeNum, nodeName,startTimeType,nodeDays
			from flowTempletNode
			where templetID = '201204010002'	--����Ӧ�ö���һ����ͬ������
		end
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		
	commit tran

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '�����ó��ͬ', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ���������ó��ͬ[' + @contractID + ']��')
GO
select * from flowTemplet
select * from flowTempletNode
select * from contractFlow
select * from contractInfo
select * from contractCollege
delete contractInfo
--���ԣ�
declare @clgInfo as xml
set @clgInfo = 
N'<root>
  <contractCollege clgCode="123" jobNumber="00000891" oprManMobile="18602702392">
		<contractEqp contractID="201203280001" eName="Sony���ͼ����" eFormat="100Cpu" cCode="392" quantity="4" price="1000.0000" />
  </contractCollege>
  <contractCollege clgCode="124" jobNumber="00000906" oprManMobile="18602702391">
		<contractEqp contractID="201203280001" eName="IBM���ͼ����" eFormat="300Cpu" cCode="392" quantity="1" price="2000.0000" />
		<contractEqp contractID="201203280001" eName="HP���ͼ����" eFormat="200Cpu" cCode="392" quantity="5" price="3000.0000" />
  </contractCollege>
</root>'

declare @Ret int, @createTime smalldatetime, @contractID varchar(12)
set @contractID = ''
exec dbo.addContractInfo @contractID output, @clgInfo,	
	--������λ��
	'201204240018','G0000039','18602702392',
	--ί����ó��˾��������
	'201204230009','W0000009','18602702391',
	3200,1,3200,10,	
	'2012-05-29','2012-04-29', '��������2',
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
/*������
1.userInfo���ݿ�Ҫ��չ����绰
2.Ҫ�������һ����¼�õ��û���
3.����������̴洢����
4.�����������̴洢����
5.�����ڵ���ɴ洢����
6.�����鵵�洢����
*/

drop PROCEDURE queryContractInfoLocMan
/*
	name:		queryContractInfoLocMan
	function:	2.��ѯָ����ͬ�Ƿ��������ڱ༭
	input: 
				@contractID varchar(12),	--��ͬ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ���ĺ�ͬ������
				@lockManID varchar(10) output--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2012-3-29
	UpdateDate: 
*/
create PROCEDURE queryContractInfoLocMan
	@contractID varchar(12),	--��ͬ���
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from contractInfo where contractID = @contractID),'')
	set @Ret = 0
GO


drop PROCEDURE lockContractInfo4Edit
/*
	name:		lockContractInfo4Edit
	function:	3.������ͬ�༭������༭��ͻ
	input: 
				@contractID varchar(12),	--��ͬ���
				@lockManID varchar(10) output,	--�����ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����ĺ�ͬ�����ڣ�2:Ҫ�����ĺ�ͬ���ڱ����˱༭��3:�õ��������
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-3-29
	UpdateDate: 
*/
create PROCEDURE lockContractInfo4Edit
	@contractID varchar(12),	--��ͬ���
	@lockManID varchar(10) output,	--�����ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����ĺ�ͬ�Ƿ����
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
	--��鵥��״̬:
	if (@contractStatus = 9)
	begin
		set @Ret = 3
		return
	end

	update contractInfo
	set lockManID = @lockManID 
	where contractID = @contractID
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '������ͬ�༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˺�ͬ['+ @contractID +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockContractInfoEditor
/*
	name:		unlockContractInfoEditor
	function:	4.�ͷź�ͬ�༭��
				ע�⣺�����̲�����ͬ�Ƿ���ڣ�
	input: 
				@contractID varchar(12),	--��ͬ���
				@lockManID varchar(10) output,	--�����ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-3-29
	UpdateDate: 
*/
create PROCEDURE unlockContractInfoEditor
	@contractID varchar(12),	--��ͬ���
	@lockManID varchar(10) output,	--�����ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
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

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�ͷź�ͬ�༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ��˺�ͬ['+ @contractID +']�ı༭����')
GO

drop PROCEDURE updateContractFlow
/*
	name:		updateContractFlow
	function:	5.���º�ִͬ������
				ע�⣺�ô洢������ɾ�������ִ�е����̡������ǰ�ڵ㱻ɾ������ͬ�Զ��ص���ʼ״̬��
				����洢������δʹ�ã�ʹ��ǰҪ���£�����
	input: 
				@contractID varchar(12),--��ͬ���
				@flow xml,				--����xml��ʽ��ŵ����̽ڵ���Ϣ
												N'<root>
													<node nodeNum="1" nodeName="����ǩ��ί�д������Э��" startTimeType="lastNodeCompleted" nodeDays="10" startTime="2012-03-30T13:23:00"/>
													<node nodeNum="2" nodeName="������֤�򸶿�" startTimeType="lastNodeCompleted" nodeDays="21" />
													<node nodeNum="3" nodeName="�������" startTimeType="lastNodeCompleted" nodeDays="33" />
													<node nodeNum="4" nodeName="�����ص�" startTimeType="goodsArrivalTime" nodeDays="0" />
												</root>'
												
				@modiManID varchar(10) output,		--ά���ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ���ĺ�ͬ�����ڣ�2��Ҫ���µĺ�ͬ��������������3:�õ����Ѿ���ɣ��������޸ģ�9��δ֪����
	author:		¬έ
	CreateDate:	2012-3-30
	UpdateDate: 

*/
create PROCEDURE updateContractFlow
	@contractID varchar(12),	--��ͬ���
	@flow xml,					--����xml��ʽ��ŵ����̽ڵ���Ϣ

	--ά����:
	@modiManID varchar(10) output,		--ά���ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,	--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����ĺ�ͬ�Ƿ����
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
	--��鵥��״̬:
	if (@contractStatus = 9)
	begin
		set @Ret = 3
		return
	end

	--ȡά���˵�������
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
		
		--���º�ͬ״̬��
		declare @curNodeIsExist int
		declare @nodeName nvarchar(30)	--�ڵ�����
		select @curNodeIsExist = nodeNum, @nodeName = nodeName from contractFlow where contractID=@contractID and nodeNum=@curNode
		if (@contractStatus=0 or @curNode is null or @curNodeIsExist is null)	--�����ǰ�ڵ㱻ɾ������ͬ�Զ��ص���ʼ״̬��
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
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '���º�ͬ����', '�û�' + @modiManName 
												+ '�����˺�ͬ['+ @contractID +']�����̡�')
GO
--���ԣ�
declare @flow xml
set @flow = N'<root>
			<node nodeNum="1" nodeName="����ǩ��ί�д������Э��" startTimeType="lastNodeCompleted" nodeDays="10" startTime="2012-03-30T13:23:00"/>
			<node nodeNum="2" nodeName="������֤�򸶿�" startTimeType="lastNodeCompleted" nodeDays="21" />
			<node nodeNum="3" nodeName="�������" startTimeType="lastNodeCompleted" nodeDays="33" />
			<node nodeNum="4" nodeName="�����ص�" startTimeType="goodsArrivalTime" nodeDays="0" />
			</root>'
declare @updateTime smalldatetime--����ʱ��
declare @Ret		int			--�����ɹ���ʶ
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
	function:	6.������ִͬ������
				ע�⣺�ô洢���̼��༭����������
	input: 
				@contractID varchar(12),	--��ͬ���

				@modiManID varchar(10) output,		--ά���ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ���ĺ�ͬ�����ڣ�2��Ҫ�����ĺ�ͬ��������������3:�õ����Ѿ���ɣ�������������9��δ֪����
	author:		¬έ
	CreateDate:	2012-3-30
	UpdateDate: modi by lw 2012-5-8 ���ӻ��ڼ������ʱ��Ϊ��ͬ����ʱ��
				modi by lw 2012-5-9 ����֪ͨ�¼�

*/
create PROCEDURE startContractFlow
	@contractID varchar(12),	--��ͬ���

	--ά����:
	@modiManID varchar(10) output,		--ά���ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,	--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����ĺ�ͬ�Ƿ����
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
	--��鵥��״̬:
	if (@contractStatus = 9)
	begin
		set @Ret = 3
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--ȡ�ڵ���Ϣ��
	declare @nodeDays int, @startTimeType varchar(30)
	declare @nodeName nvarchar(30)	--�ڵ�����
	select @nodeName = nodeName, @nodeDays = nodeDays, @startTimeType = startTimeType
	from contractFlow 
	where contractID = @contractID and nodeNum = 1

	set @updateTime = GETDATE()
	begin tran
		--���㵱ǰ�ڵ��ʣ��������
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
		
		--���º�ִͬ�����̱�״̬��
		update contractFlow
		set startTime = @updateTime, curLeftDays = @leftDays,
			nStatus = 1 --�ڵ�״̬��0->δ������1->���-1->������һ�ڵ㣬9->���
		where contractID = @contractID and nodeNum = 1
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    

		--���º�ͬ��Ϣ�������¼���
		update contractInfo
		set contractStatus = 1, curNode = 1, curNodeName = @nodeName, curLeftDays = @leftDays,
			startTime = @updateTime,
			event2Trader = 'Y', event2TraderType = 1, event2TraderText = '��ó��ͬ['+@contractID+']����ִ���ˡ�',
			event2TraderTime = @updateTime,
			event2ClgMan = 'Y', event2ClgManType = 1, event2ClgManText  = '��ó��ͬ['+@contractID+']����ִ���ˡ�',
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
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '������ͬ', '�û�' + @modiManName 
												+ '�����˺�ͬ['+ @contractID +']�����̡�')
GO
--���ԣ�
declare @updateTime smalldatetime--����ʱ��
declare @Ret		int			--�����ɹ���ʶ
exec dbo.startContractFlow '20120067','00201314',@updateTime output, @Ret output
select @Ret

select * from contractInfo
select * from contractFlow

drop PROCEDURE stopContractFlow
/*
	name:		stopContractFlow
	function:	6.1.ֹͣ��ִͬ������
				ע�⣺�ô洢���̼��༭����������
	input: 
				@contractID varchar(12),		--��ͬ���

				@modiManID varchar(10) output,	--ά���ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,--����ʱ��
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���ĺ�ͬ�����ڣ�2��Ҫֹͣ�ĺ�ͬ��������������3:�ú�ͬ��������ִ��״̬��������ֹͣ��9��δ֪����
	author:		¬έ
	CreateDate:	2013-6-8
	UpdateDate: 

*/
create PROCEDURE stopContractFlow
	@contractID varchar(12),		--��ͬ���

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����ĺ�ͬ�Ƿ����
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
	--��鵥��״̬:
	if (@contractStatus <> 1)
	begin
		set @Ret = 3
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--ȡ�ڵ���Ϣ��
	declare @nodeDays int, @startTimeType varchar(30)
	declare @nodeName nvarchar(30)	--�ڵ�����
	select @nodeName = nodeName, @nodeDays = nodeDays, @startTimeType = startTimeType
	from contractFlow 
	where contractID = @contractID and nodeNum = 1

	set @updateTime = GETDATE()
	begin tran
		--���º�ִͬ�����̱�״̬��
		update contractFlow
		set nStatus = -1 --�ڵ�״̬��0->δ������1->���-1->������һ�ڵ㣬9->���
		where contractID = @contractID and nStatus<>0
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    

		--���º�ͬ��Ϣ�������¼���
		update contractInfo
		set contractStatus = 0, curNode = 1, curNodeName = @nodeName, 
			event2Trader = 'Y', event2TraderType = 1, event2TraderText = '��ó��ͬ['+@contractID+']ִֹͣ���ˡ�',
			event2TraderTime = @updateTime,
			event2ClgMan = 'Y', event2ClgManType = 1, event2ClgManText  = '��ó��ͬ['+@contractID+']ִֹͣ���ˡ�',
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
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, 'ֹͣ��ͬ', '�û�' + @modiManName 
												+ 'ֹͣ�˺�ͬ['+ @contractID +']�����̡�')
GO
--���ԣ�
declare @updateTime smalldatetime--����ʱ��
declare @Ret		int			--�����ɹ���ʶ
exec dbo.stopContractFlow '20120001','00201314',@updateTime output, @Ret output
select @Ret

drop PROCEDURE completeContractNode
/*
	name:		completeContractNode
	function:	7.��ɺ�ͬ���̵ĵ�ǰ�ڵ�,����ͬ��ǰ�ڵ��ƶ�����һ���ڵ�
				ע�⣺�ô洢���̼��༭����������
	input: 
				@contractID varchar(12),	--��ͬ���

				@modiManID varchar(10) output,	--ά���ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ���ĺ�ͬ�����ڣ�2��Ҫ�����ĺ�ͬ��������������3:�ú�ͬ�Ѿ���ɣ�������ǰ����9��δ֪����
	author:		¬έ
	CreateDate:	2012-3-30
	UpdateDate: modi by lw 2012-5-8 ���ӻ��ڼ������ʱ��Ϊ��ͬ����ʱ��,���ڵ���޸ĳɿ��ܲ�����.
				modi by lw 2012-5-9 ����֪ͨ�¼�

*/
create PROCEDURE completeContractNode
	@contractID varchar(12),	--��ͬ���

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����ĺ�ͬ�Ƿ����
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
	--��鵥��״̬:
	if (@contractStatus = 9)
	begin
		set @Ret = 3
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--ȡ��һ���ڵ���Ϣ��
	declare @curNode int, @nextNode int	--��ǰ�ڵ�ţ���һ���ڵ��
	declare @nodeDays int, @startTimeType varchar(30), @nodeName nvarchar(30)	--�ڵ���������ʼʱ�����ͣ��ڵ�����
	set @curNode = (select curNode from contractInfo where contractID = @contractID)
	set @nextNode = (select top 1 nodeNum from contractFlow where contractID = @contractID and nodeNum > @curNode order by nodeNum)	--ȡ��һ���ڵ��

	if (@nextNode is not null)
		select @nodeName = nodeName, @nodeDays = nodeDays, @startTimeType = startTimeType
		from contractFlow 
		where contractID = @contractID and nodeNum = @nextNode

	set @updateTime = GETDATE()
	begin tran
		--���µ�ǰ�ڵ�״̬��
		update contractFlow
		set endTime = @updateTime,
			nStatus = 9 --�ڵ�״̬��0->δ������1->���-1->������һ�ڵ㣬9->���
		where contractID = @contractID and nodeNum = @curNode
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    

		if (@nextNode is null)	--��ͬȫ���ڵ���ת���
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
			--����ʣ��������
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

			--������һ���ڵ��״̬��
			update contractFlow
			set startTime = @updateTime, curLeftDays = @leftDays,
				nStatus = 1 --�ڵ�״̬��0->δ������1->���-1->������һ�ڵ㣬9->���
			where contractID = @contractID and nodeNum = @nextNode
			if @@ERROR <> 0 
			begin
				rollback tran
				set @Ret = 9
				return
			end
			
			--���º�ͬ״̬�������¼���			
			update contractInfo
			set contractStatus = 1, curNode = @nextNode, curNodeName = @nodeName, curLeftDays = @leftDays,
				event2Trader = 'Y', event2TraderType = 1, event2TraderText = '��ó��ͬ['+@contractID+']��һ���ڵĹ�����ɣ��ƽ�������['+@nodeName+']��',
				event2TraderTime = @updateTime,
				event2ClgMan = 'Y', event2ClgManType = 1, event2ClgManText  = '��ó��ͬ['+@contractID+']��һ���ڵĹ�����ɣ��ƽ�������['+@nodeName+']��',
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
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '�궨��ͬ�ڵ����', '�û�' + @modiManName 
												+ '�궨�˺�ͬ['+ @contractID +']�ڵ�['+str(@curNode,2,0)+']��ɡ�')
GO
--���ԣ�
update contractInfo set lockManID=''
declare @updateTime smalldatetime--����ʱ��
declare @Ret		int			--�����ɹ���ʶ
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
	function:	8.����ͬ�ĵ�ǰ�ڵ��˻ص���һ���ڵ�
				ע�⣺�ô洢���̼��༭����������
	input: 
				@contractID varchar(12),	--��ͬ���

				@modiManID varchar(10) output,		--ά���ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ���ĺ�ͬ�����ڣ�2��Ҫ�����ĺ�ͬ��������������3:�õ����Ѿ���ɣ��������˻أ�
							4:���ǵ�һ���ڵ㣬�������˻أ�5���ڵ����ô���9��δ֪����
	author:		¬έ
	CreateDate:	2012-3-30
	UpdateDate: modi by lw 2012-5-8 ���ӻ��ڼ������ʱ��Ϊ��ͬ����ʱ��,���ڵ���޸ĳɿ��ܲ�����.
				modi by lw 2012-5-9 ����֪ͨ�¼�

*/
create PROCEDURE gobackContractNode
	@contractID varchar(12),	--��ͬ���

	--ά����:
	@modiManID varchar(10) output,		--ά���ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,	--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����ĺ�ͬ�Ƿ����
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
	--��鵥��״̬:
	if (@contractStatus = 9)
	begin
		set @Ret = 3
		return
	end
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--ȡ�ڵ���Ϣ��
	declare @curNode int
	set @curNode = (select curNode from contractInfo where contractID = @contractID)
	if (@curNode=1)
	begin
		set @Ret = 4
		return
	end
	
	--ȡ��һ���ڵ���Ϣ��
	declare @lastNode int	--��һ���ڵ��
	declare @nodeDays int, @startTimeType varchar(30), @nodeName nvarchar(30), @startTime smalldatetime	--�ڵ���������ʼʱ�����ͣ��ڵ����ƣ��ڵ㿪ʼʱ��
	set @lastNode = (select top 1 nodeNum from contractFlow where contractID = @contractID and nodeNum < @curNode order by nodeNum desc)	--ȡ��һ���ڵ��
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
		--����ʣ��������
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

		--���µ�ǰ�ڵ�״̬��
		update contractFlow
		set startTime=null, endTime = null,
			nStatus = -1 --�ڵ�״̬��0->δ������1->���-1->������һ�ڵ㣬9->���
		where contractID = @contractID and nodeNum = @curNode
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    

		--������һ�ڵ�״̬��
		update contractFlow
		set startTime=(case when startTime is null then @updateTime else startTime end),
			curLeftDays = @leftDays, endTime = null,
			nStatus = 1 --�ڵ�״̬��0->δ������1->���-1->������һ�ڵ㣬9->���
		where contractID = @contractID and nodeNum = @lastNode
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end

		--���º�ͬ״̬������֪ͨ�¼���
		update contractInfo
		set contractStatus = 1, curNode = @lastNode, curNodeName=@nodeName, curLeftDays = @leftDays,
			event2Trader = 'Y', event2TraderType = 1, event2TraderText = '��ó��ͬ['+@contractID+']����['+@nodeName+']�еĲ����ļ�������Ҫ���豸��������Ա�����˻ش���',
			event2TraderTime = @updateTime,
			event2ClgMan = 'Y', event2ClgManType = 1, event2ClgManText  = '��ó��ͬ['+@contractID+']����['+@nodeName+']�еĲ����ļ�������Ҫ���豸��������Ա�����˻ش���',
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
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '�˻غ�ͬ����', '�û�' + @modiManName 
												+ '����ͬ['+ @contractID +']�ӽڵ�['+str(@curNode,2,0)+']�˻���һ����')
GO
--���ԣ�
declare @updateTime smalldatetime--����ʱ��
declare @Ret		int			--�����ɹ���ʶ
exec dbo.gobackContractNode '20120067','00201314',@updateTime output, @Ret output
select @Ret

select * from contractInfo
select * from contractFlow


drop PROCEDURE updateContractInfo
/*
	name:		updateContractInfo
	function:	9.���º�ͬ
	input: 
				@contractID char(12),			--��ͬ���
				--������λ��Ϣ/�����豸��Ϣ�������ж�������
				@clgInfo xml,	--�������·�ʽ���:
									N'<root>
									  <contractCollege clgCode="123" jobNumber="00000891" oprManMobile="18602702392">
											<contractEqp contractID="201203280001" eName="Sony���ͼ����" eFormat="100Cpu" cCode="392" quantity="4" price="1000.0000" />
									  </contractCollege>
									  <contractCollege clgCode="124" jobNumber="00000906" oprManMobile="18602702391">
											<contractEqp contractID="201203280001" eName="IBM���ͼ����" eFormat="300Cpu" cCode="392" quantity="1" price="2000.0000" />
											<contractEqp contractID="201203280001" eName="HP���ͼ����" eFormat="200Cpu" cCode="392" quantity="5" price="3000.0000" />
									  </contractCollege>
									</root>'

				--������λ��
				@supplierID varchar(12),		--������λ���
				@supplierOprManID varchar(18),	--������λ������ID
				@supplierOprManMobile varchar(30),	--������λ��������ϵ�绰���ֻ���������ƣ�������ʷ���� add by lw 2012-3-27
				--@supplierSignedTime varchar(10),--ǩԼʱ��:���á�yyyy-MM-dd����ŵ���������
				
				--ί����ó��˾��������
				@traderID varchar(12),			--��ó��˾���
				@traderOprManID varchar(18),	--��ó��˾������ID
				@traderOprManMobile varchar(30),--��ó��˾��������ϵ�绰���ֻ���������ƣ�������ʷ���� add by lw 2012-3-27
				--@traderSignedTime varchar(10),	--ί��ʱ��:���á�yyyy-MM-dd����ŵ���������
				
				@totalAmount money,				--�豸�ܼ�
				@currency smallint,				--����,�ɵ�3�Ŵ����ֵ䶨��
				@dollar money,					--�ۺ���Ԫ
				@paymentMode smallint,			--���ʽ, �ɵ�4�Ŵ����ֵ䶨��
				@goodsArrivalTime varchar(10),	--Ԥ�Ƶ���ʱ�䣺���á�yyyy-MM-dd����ŵ���������
				@acceptedTime varchar(10),		--����ʱ�䣨ǩԼʱ�䣩:���á�yyyy-MM-dd����ŵ���������
				@notes nvarchar(500),			--��ע

				
				@modiManID varchar(10) output,		--ά���ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ���ĺ�ͬ�����ڣ�2��Ҫ���µĺ�ͬ��������������3:�ú�ͬ�Ѿ���ɣ��������޸ģ�
							4:���ǵ�һ���ڵ㣬�������˻أ�5���ڵ����ô���9��δ֪����
	author:		¬έ
	CreateDate:	2012-3-30
	UpdateDate: ���ݿͻ������豸���ͬΪһ�Զ��ϵ������Ϊ�̶�ģʽ�������ӿ� by lw 2012-4-8
				���ݿͻ�Ҫ���ڵǼǺ�ͬ�п�����ʱ�޸��ֻ����룬�����ӿ�,�����豸�ܼۺ�������Ԫ�����ⲿ���� by lw 2012-4-24
				���ݿͻ�Ҫ�󣬽�������λ�붩���豸������by lw 2012-5-8
				modi by lw 2012-5-9 ����֪ͨ�¼�
				modi by lw 2012-5-21����xml�������ַ�"<>"�Ĵ���
*/
create PROCEDURE updateContractInfo
	@contractID char(12),			--��ͬ���
	--������λ��Ϣ�������ж�������
	@clgInfo xml,	

	--������λ��
	@supplierID varchar(12),		--������λ���
	@supplierOprManID varchar(18),	--������λ������ID
	@supplierOprManMobile varchar(30),	--������λ��������ϵ�绰���ֻ���������ƣ�������ʷ���� add by lw 2012-3-27
	--@supplierSignedTime varchar(10),--ǩԼʱ��:���á�yyyy-MM-dd����ŵ���������
	
	--ί����ó��˾��������
	@traderID varchar(12),			--��ó��˾���
	@traderOprManID varchar(18),	--��ó��˾������ID
	@traderOprManMobile varchar(30),--��ó��˾��������ϵ�绰���ֻ���������ƣ�������ʷ���� add by lw 2012-3-27
	--@traderSignedTime varchar(10),	--ί��ʱ��:���á�yyyy-MM-dd����ŵ���������


	@totalAmount money,				--�豸�ܼ�
	@currency smallint,				--����,�ɵ�3�Ŵ����ֵ䶨��
	@dollar money,					--�ۺ���Ԫ
	@paymentMode smallint,			--���ʽ, �ɵ�4�Ŵ����ֵ䶨��
	@goodsArrivalTime varchar(10),	--Ԥ�Ƶ���ʱ�䣺���á�yyyy-MM-dd����ŵ���������
	@acceptedTime varchar(10),		--����ʱ�䣨ǩԼʱ�䣩:���á�yyyy-MM-dd����ŵ���������
	@notes nvarchar(500),			--��ע
	
	@modiManID varchar(10) output,		--ά���ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,	--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ�����������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @contractStatus int
	select @thisLockMan = isnull(lockManID,''), @contractStatus = contractStatus
	from contractInfo
	where contractID = @contractID
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--��鵥��״̬:
	if (@contractStatus = 9)
	begin
		set @Ret = 3
		return
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--����������λ�Ͷ����豸��
	declare @eqpInfoTab as TABLE (
		contractID varchar(12) not null,	--��ͬ���
		clgCode char(3) not null,			--������λ��ѧԺ����	--�������Ҫ�󣬽������豸�붩����λ����add by lw 2012-5-8
		ordererID varchar(10) not null,		--������������ID
		eName nvarchar(30) not null,		--�豸����
		eFormat nvarchar(20) not null,		--�ͺŹ��
		cCode char(3) not null,				--ԭ���أ����Ҵ��룩
		quantity int not null,				--����
		price money null					--���ۣ�>0
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
		
	--��ȡ������λ��Ϣ��
	declare @supplierName nvarchar(30)			--������λ���ƣ�������ƣ�������ʷ���� add by lw 2012-3-27
	set @supplierName = (select supplierName from supplierInfo where supplierID = @supplierID)
	declare @supplierOprMan	nvarchar(30)	--������λ�����ˣ�������ƣ�������ʷ���� add by lw 2012-3-27
	declare @supplierOprManTel varchar(30)	--������λ��������ϵ�绰�������绰��������ƣ�������ʷ���� add by lw 2012-3-27
	select @supplierOprMan = manName, @supplierOprManTel = tel
	from supplierManInfo where supplierID = @supplierID and manID = @supplierOprManID
	
	--��ȡ��ó��˾��Ϣ��
	declare @traderName nvarchar(30)		--��ó��˾���ƣ�������ƣ�������ʷ���� add by lw 2012-3-27
	declare @abbTraderName nvarchar(6)		--��ó��˾���	add by lw 2012-4-27���ݿͻ�Ҫ������
	select @traderName = traderName, @abbTraderName = abbTraderName 
	from traderInfo 
	where traderID = @traderID

	declare @traderOprMan nvarchar(30)		--��ó��˾�����ˣ�������ƣ�������ʷ���� add by lw 2012-3-27
	declare @traderOprManTel varchar(30)	--��ó��˾��������ϵ�绰�������绰��������ƣ�������ʷ���� add by lw 2012-3-27
	select @traderOprMan = manName, @traderOprManTel = tel
	from traderManInfo where traderID = @traderID and manID = @traderOprManID
	
	set @updateTime = getdate()
	begin tran
		declare @oldPaymentMode smallint			--��ǰ�ĸ��ʽ, �ɵ�4�Ŵ����ֵ䶨��
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
--print '���º�ͬ����'		  
		  
		--���¶�����λ��Ϣ��
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
--print '���¶�����λ'		  

		--���¶����豸��Ϣ��
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
--print '���¶����豸'		  
		
		--��鸶�ʽ�Ƿ����������������������̣�
		if (@oldPaymentMode <> @paymentMode)
		begin
--print '�����˸��ʽ'
			--������ǰ������״̬��
			declare @contractFlow TABLE
			(
				contractID varchar(12) not null,	--��������ͬ���
				nodeNum int not null,				--�������ڵ����
				nodeName nvarchar(30) not null,		--�ڵ�����
				startTimeType varchar(30) ,			--����ʱ������:'startTime'�����̿�ʼʱ�䣬
																					--'lastNodeCompleted'->��һ�ڵ�������ڣ�
																					--'goodsArrivalTime'->����ʱ��
				nodeDays int not null,				--�ڵ�����ʱ�䣨�죩
				curLeftDays int null,				--�ڵ�ʣ��ʱ��(��)�������ݿ�������ÿ����� add by lw 2012-4-19
				startTime smalldatetime null,		--�ڵ㿪ʼʱ��
				endTime smalldatetime null,			--�ڵ����ʱ��
				nStatus int,						--�ڵ�״̬��0->δ������1->���-1->������һ�ڵ㣬9->���
				yellowLampTimes smallint,			--�Ƶƴ���
				redLampTimes smallint,				--��ƴ���
				SMSTimes smallint					--���Ŵ���
			)
			insert @contractFlow
			select * from contractFlow where contractID = @contractID

			delete contractFlow where contractID = @contractID
			if (@paymentMode>10)	--��ǰ����
			begin
				insert contractFlow(contractID, nodeNum, nodeName,startTimeType,nodeDays)
				select @contractID, nodeNum, nodeName,startTimeType,nodeDays
				from flowTempletNode
				where templetID = '201204010001'
			end
			else					--���󸶿�
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

			--��������״̬��
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
			
			--����ͬ�ĵ�ǰ�����Ƿ���ڣ���������ڻ���һ���ڵ㣡
			declare @curNode int--��ǰ�ڵ��
			set @curNode = (select curNode from contractInfo where contractID = @contractID)
			set @count = (select count(*) from contractFlow where contractID = @contractID and nodeNum = @curNode)
			if (@curNode > 0 and @count = 0)
			begin
				--ȡ��һ���ڵ���Ϣ��
				declare @lastNode int	--��һ���ڵ��
				declare @nodeDays int, @startTimeType varchar(30), @nodeName nvarchar(30), @startTime smalldatetime	--�ڵ���������ʼʱ�����ͣ��ڵ����ƣ��ڵ㿪ʼʱ��
				set @lastNode = (select top 1 nodeNum from contractFlow where contractID = @contractID and nodeNum < @curNode order by nodeNum desc)	--ȡ��һ���ڵ��
				if (@lastNode is null)
				begin
					rollback tran
					set @Ret = 5
					return
				end
				select @nodeName = nodeName, @nodeDays = nodeDays, @startTimeType = startTimeType, @startTime = startTime
				from contractFlow 
				where contractID = @contractID and nodeNum = @lastNode
			
--print '����ʱ�����ͣ�' + @startTimeType
				--����ʣ��������
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
--print 'ʣ��������' + cast(@leftDays as varchar(3))
				--������һ�ڵ�״̬��
				update contractFlow
				set curLeftDays = @leftDays, startTime=@updateTime, endTime = null,
					nStatus = 1 --�ڵ�״̬��0->δ������1->���-1->������һ�ڵ㣬9->���
				where contractID = @contractID and nodeNum = @lastNode
				if @@ERROR <> 0 
				begin
					rollback tran
					set @Ret = 9
					return
				end

				--���º�ͬ״̬������֪ͨ�¼���
				update contractInfo
				set contractStatus = 1, curNode = @lastNode, curNodeName=@nodeName, curLeftDays = @leftDays,
					event2Trader = 'Y', event2TraderType = 1, event2TraderText = '��ó��ͬ['+@contractID+']�Ĳ���������˱仯����鿴���顣',
					event2TraderTime = @updateTime,
					event2ClgMan = 'Y', event2ClgManType = 1, event2ClgManText  = '��ó��ͬ['+@contractID+']�Ĳ���������˱仯����鿴���顣',
					event2ClgManTime = @updateTime,
					modiManID = @modiManID, modiManName = @modiManName, modiTime = @updateTime
				where contractID = @contractID
				if @@ERROR <> 0 
				begin
					rollback tran
					set @Ret = 9
					return
				end  
--print '��ɺ�ͬ״̬����'
			end
		end
	commit tran
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '���º�ͬ', '�û�' + @modiManName
												+ '�����˺�ͬ['+ @contractID +']��')
GO
--���ԣ�
declare @Ret int 
exec dbo.lockContractInfo4Edit '20120067', '00201314', @Ret output
select @Ret

declare @clgInfo as xml
set @clgInfo = 
N'<root>
<contractCollege clgCode="123" jobNumber="00000891" oprManMobile="18602702392">
	<contractEqp contractID="20120067" eName="Sony���ͼ����" eFormat="100Cpu" cCode="392" quantity="4" price="1000.0000" />
</contractCollege>
<contractCollege clgCode="124" jobNumber="00000906" oprManMobile="18602702391">
	<contractEqp contractID="20120067" eName="dell���ͼ����" eFormat="300Cpu" cCode="392" quantity="1" price="21000.0000" />
	<contractEqp contractID="20120067" eName="HP���ͼ����" eFormat="200Cpu" cCode="392" quantity="5" price="3000.0000" />
</contractCollege>
</root>'
declare @Ret int, @createTime smalldatetime, @contractID varchar(12)
exec dbo.updateContractInfo  '20120067', @clgInfo,	
	--������λ��
	'201204240018','G0000039','18602702392',
	--ί����ó��˾��������
	'201204230009','W0000009','18602702391',
	3200,1,3200,12,	
	'2012-05-29','2012-04-29', '��������2',
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
	function:	10.ɾ��ָ���ĺ�ͬ
	input: 
				@contractID char(12),			--��ͬ���
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���ĺ�ͬ�����ڣ�2��Ҫɾ���ĺ�ͬ��������������3���ú�ͬ�Ѿ���ɣ�����ɾ����9��δ֪����
	author:		¬έ
	CreateDate:	2012-3-30
	UpdateDate: 

*/
create PROCEDURE delContractInfo
	@contractID char(12),			--��ͬ���
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫָ���ĺ�ͬ�Ƿ����
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
	--��鵥��״̬:
	if (@contractStatus = 9)
	begin
		set @Ret = 3
		return
	end
	
	delete contractInfo where contractID = @contractID
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ����ͬ', '�û�' + @delManName
												+ 'ɾ���˺�ͬ['+ @contractID +']��')

GO


drop PROCEDURE addContractAttachment
/*
	name:		11.addContractAttachment
	function:	��Ӻ�ͬ����
				ע�⣺���洢������ɾ��������ӡ�
	input: 
				@contractID varchar(12),	--��ͬ���
				--������Ϣ�������ж�������
				@attachmentInfo xml,	--�������·�ʽ���:
									N'<root>
									  <attachment attachmentType="1" aFileName="90b2bd1c-8789-4223-9f05-2c38f6f000a7.png" notes="���Ǻ�ͬ��1ҳ"/>
									  <attachment attachmentType="2" aFileName="bc1a3c47-00c1-4c7c-93de-f75149db7a9d.png" notes="����Э���1ҳ"/>
									</root>'				
				@modiManID varchar(10) output,		--ά���ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output				--�����ɹ���ʶ
										0:�ɹ���1��ָ���ĺ�ͬ�����ڣ�2��Ҫ���µĺ�ͬ��������������3:�ú�ͬ�Ѿ���ɣ��������޸ģ�9��δ֪����
	author:		¬έ
	CreateDate:	2012-3-31
	UpdateDate: ����UI��Ƶĵ������������ĳɳ������͡�
				modi by lw 2012-5-9 ����֪ͨ�¼�
*/
create PROCEDURE addContractAttachment
	@contractID varchar(12),	--��ͬ���
	@attachmentInfo xml,	--������Ϣ�������ж�����

	@modiManID varchar(10) output,		--ά���ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@updateTime smalldatetime output,	--����ʱ��
	@Ret		int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ�����������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @contractStatus int
	select @thisLockMan = isnull(lockManID,''), @contractStatus = contractStatus
	from contractInfo
	where contractID = @contractID
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--��鵥��״̬:
	if (@contractStatus = 9)
	begin
		set @Ret = 3
		return
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	begin tran
		delete contractAttachment where contractID = @contractID

		if (cast(@attachmentInfo as nvarchar(max))<>N'<root/>')
		begin
			--�ǼǸ�����
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

		--�ǼǸ�����Ϣ�������¼���
		update contractInfo
		set event2Manager = 'Y', event2ManagerType = 2, event2ManagerText='���µĸ����������Ĳ�����Ƿ���ɱ����ڹ�����', event2TraderTime = @updateTime,
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

	--�Ǽǹ�����־��
	declare @attachmentName varchar(100)
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '��Ӻ�ͬ����', '�û�' + @modiManName 
												+ '����˺�ͬ['+ @contractID +']�ĸ�����')
GO
--���ԣ�
declare	@Ret		int
declare @updateTime smalldatetime
exec dbo.addContractAttachment '20120039','<root></root>','00011275',@updateTime output,@Ret output
select @Ret


drop PROCEDURE delATypeContractAttachment
/*
	name:		delATypeContractAttachment
	function:	12.ɾ��ָ�������ĺ�ͬ����
	input: 
				@contractID varchar(12),	--��ͬ���
				@attachmentType smallint,	--�������ͣ��ɵ�5�Ŵ����ֵ䶨��

				@delManID varchar(10) output,--ɾ���ˣ�����ͬ������������ʱ�򷵻������˵�ID
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ���ĺ�ͬ�����ڣ�2��Ҫɾ���ĺ�ͬ��������������3���ú�ͬ�Ѿ���ɣ�����ɾ��������9��δ֪����
	author:		¬έ
	CreateDate:	2012-4-24
	UpdateDate: 

*/
create PROCEDURE delATypeContractAttachment
	@contractID varchar(12),	--��ͬ���
	@attachmentType smallint,	--�������ͣ��ɵ�5�Ŵ����ֵ䶨��

	@delManID varchar(10) output,--ɾ����
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--�ж�ָ���ĺ�ͬ�Ƿ����
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
	--��鵥��״̬:
	if (@contractStatus = 9)
	begin
		set @Ret = 3
		return
	end
	
	delete contractAttachment where contractID = @contractID and attachmentType = @attachmentType
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--��ȡ����������Ϣ��
	declare @attachmentName varchar(100)
	select @attachmentName = objDesc
	from codeDictionary cd 
	where objCode = @attachmentType and classCode=5

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ����ͬ����', '�û�' + @delManName
												+ 'ɾ���˺�ͬ['+ @contractID +']�ĸ���['+ @attachmentName +']��һ���ļ���')
GO

drop PROCEDURE addATypeContractAttachment
/*
	name:		13.addATypeContractAttachment
	function:	��Ӻ�ָͬ�����ĸ���
	input: 
				@contractID varchar(12),	--��ͬ���
				@attachmentType smallint,	--�������ͣ��ɵ�5�Ŵ����ֵ䶨��
				--������Ϣ�������ж�������
				@attachmentInfo xml,	--�������·�ʽ���:
									N'<root>
									  <attachment attachmentType="1" aFileName="90b2bd1c-8789-4223-9f05-2c38f6f000a7.png" notes="���Ǻ�ͬ��1ҳ"/>
									  <attachment attachmentType="1" aFileName="bc1a3c47-00c1-4c7c-93de-f75149db7a9d.png" notes="����Э���1ҳ"/>
									</root>'				
				@modiManID varchar(10) output,		--ά���ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output				--�����ɹ���ʶ
										0:�ɹ���1��ָ���ĺ�ͬ�����ڣ�2��Ҫ���µĺ�ͬ��������������3:�õ����Ѿ���ɣ��������޸ģ�9��δ֪����
	author:		¬έ
	CreateDate:	2012-4-24
	UpdateDate: modi by lw 2012-5-9 ����֪ͨ�¼�
*/
create PROCEDURE addATypeContractAttachment
	@contractID varchar(12),	--��ͬ���
	@attachmentType smallint,	--�������ͣ��ɵ�5�Ŵ����ֵ䶨��
	@attachmentInfo xml,	--������Ϣ�������ж�����

	@modiManID varchar(10) output,		--ά���ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@updateTime smalldatetime output,	--����ʱ��
	@Ret		int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ�����������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @contractStatus int
	select @thisLockMan = isnull(lockManID,''), @contractStatus = contractStatus
	from contractInfo
	where contractID = @contractID
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--��鵥��״̬:
	if (@contractStatus = 9)
	begin
		set @Ret = 3
		return
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	begin tran
		--�ǼǸ�����
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
		
		--�ǼǸ�����Ϣ�������¼���
		update contractInfo
		set event2Manager = 'Y', event2ManagerType = 2, event2ManagerText='���µĸ����������Ĳ�����Ƿ���ɱ����ڹ�����', event2TraderTime = @updateTime,
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

	--�Ǽǹ�����־��
	declare @attachmentName varchar(100)
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '��Ӻ�ͬ����', '�û�' + @modiManName 
												+ '����˺�ͬ['+ @contractID +']�ĸ�����')
GO

drop PROCEDURE addEvent2ContractInfo
/*
	name:		14.addEvent2ContractInfo
	function:	��ָ����ͬ����¼�
				ע�⣺���洢���̲���д������־��
	input: 
				@contractID varchar(12),	--��ͬ���
				@event2Who smallint,		--�¼����Ͷ���:1->���豸��������Ա���¼���2->����ó��˾���¼���3->��������λ���¼�
				@eventType smallint,		--�¼����ͣ�
												--��������Ա���¼����1->֪ͨ������Ҫ�����2->���µĸ�������Ҫ���Ĳ�����Ƿ��Ƿ���ɱ����ڣ�3->�����̱����Ҫ����
												--����ó��˾���¼����1->֪ͨ������Ҫ�����2->���ڳ��ڣ���Ҫ�ϴ���ɵĹ�������
												--��������λ���¼����1->֪ͨ������Ҫ�����3->�����̱����Ҫ����
				@eventText nvarchar(100),	--�¼�����

				
				@modiManID varchar(10) output,		--ά���ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output				--�����ɹ���ʶ
										0:�ɹ���1��ָ���ĺ�ͬ�����ڣ�2��Ҫ���µĺ�ͬ��������������3:�õ����Ѿ���ɣ��������޸ģ�9��δ֪����
	author:		¬έ
	CreateDate:	2012-5-9
	UpdateDate: 
*/
create PROCEDURE addEvent2ContractInfo
	@contractID varchar(12),	--��ͬ���
	@event2Who smallint,		--�¼����Ͷ���:1->���豸��������Ա���¼���2->����ó��˾���¼���3->��������λ���¼�
	@eventType smallint,		--�¼����ͣ�
									--��������Ա���¼����1->֪ͨ������Ҫ�����2->���µĸ�������Ҫ���Ĳ�����Ƿ��Ƿ���ɱ����ڣ�3->�����̱����Ҫ����
									--����ó��˾���¼����1->֪ͨ������Ҫ�����2->���ڳ��ڣ���Ҫ�ϴ���ɵĹ�������
									--��������λ���¼����1->֪ͨ������Ҫ�����3->�����̱����Ҫ����
	@eventText nvarchar(100),	--�¼�����

	@modiManID varchar(10) output,		--ά���ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ�����������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @contractStatus int
	select @thisLockMan = isnull(lockManID,''), @contractStatus = contractStatus
	from contractInfo
	where contractID = @contractID
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--��鵥��״̬:
	if (@contractStatus = 9)
	begin
		set @Ret = 3
		return
	end
	
	--ȡά���˵�������
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
	function:	ɾ��ָ����ͬ���¼�
				ע�⣺���洢���̲���д������־��
	input: 
				@contractID varchar(12),	--��ͬ���
				@event2Who smallint,		--�¼����Ͷ���:1->���豸��������Ա���¼���2->����ó��˾���¼���3->��������λ���¼�
				
				@modiManID varchar(10) output,		--ά���ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output				--�����ɹ���ʶ
										0:�ɹ���1��ָ���ĺ�ͬ�����ڣ�2��Ҫ���µĺ�ͬ��������������3:�õ����Ѿ���ɣ��������޸ģ�9��δ֪����
	author:		¬έ
	CreateDate:	2012-5-9
	UpdateDate: 
*/
create PROCEDURE clearContractInfoEvent
	@contractID varchar(12),	--��ͬ���
	@event2Who smallint,		--�¼����Ͷ���:1->���豸��������Ա���¼���2->����ó��˾���¼���3->��������λ���¼�

	@modiManID varchar(10) output,		--ά���ˣ������ǰ��ͬ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ�����������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from contractInfo where contractID = @contractID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @contractStatus int
	select @thisLockMan = isnull(lockManID,''), @contractStatus = contractStatus
	from contractInfo
	where contractID = @contractID
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--��鵥��״̬:
	if (@contractStatus = 9)
	begin
		set @Ret = 3
		return
	end
	
	--ȡά���˵�������
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
--���ԣ�
select lockManID, * from contractInfo where contractID='20130258'

drop PROCEDURE calcContract
/*
	name:		calcContract
	function:	20.����ȫ�����ߺ�ͬ��״̬����������ʾ���ű�
				ע�⣺�ô洢����Ϊ��̨������򣬸ô洢���̻�������е��û��༭������ռʽ�����������ߺ�ͬ
	input: 
	output: 
	author:		¬έ
	CreateDate:	2012-3-30
	UpdateDate: modi by lw 2012-5-9 ����֪ͨ�¼�

*/
create PROCEDURE calcContract
	WITH ENCRYPTION 
AS
	declare @Ret int
	set @Ret = 9
	begin tran
		--����ȫ�����ߺ�ͬ��
		update contractInfo
		set lockManID='0000000000'
		where contractStatus = 1
		if @@ERROR <> 0 
		begin
			rollback tran
			return
		end  
	
		--�����ͬ״̬��
		update contractInfo
		set curLeftDays = curLeftDays - 1
		where contractStatus = 1
		if @@ERROR <> 0 
		begin
			rollback tran
			return
		end  
		
		--�����ִͬ�������еĽڵ�״̬��add by lw 2012-4-19
		update contractFlow
		set curLeftDays = curLeftDays - 1
		where contractID in (select contractID from contractInfo where contractStatus=1)

		--�������Ѷ��ţ�
		declare @contractID varchar(12)			--��ͬ���
		declare @curNode int, @curNodeName nvarchar(30), @curLeftDays int
		declare @traderOprMan nvarchar(30)		--��ó��˾�����ˣ�������ƣ�������ʷ���� add by lw 2012-3-27
		declare @traderOprManMobile varchar(30)	--��ó��˾��������ϵ�绰���ֻ���������ƣ�������ʷ���� add by lw 2012-3-27
		declare @manager nvarchar(30)			--������
		declare @managerMobile varchar(30)		--��������ϵ�ֻ�
		
		declare tar cursor for
		select contractID, c.curNode, c.curNodeName, c.curLeftDays, c.traderOprMan, c.traderOprManMobile, t.manager, t.managerMobile
		from contractInfo c left join traderInfo t on c.traderID = t.traderID
		where contractStatus = 1 and curLeftDays <= 3
		OPEN tar
		FETCH NEXT FROM tar INTO @contractID, @curNode, @curNodeName, @curLeftDays, @traderOprMan, @traderOprManMobile, @manager, @managerMobile
		WHILE @@FETCH_STATUS = 0
		begin
			declare @msg nvarchar(100)
			if (@traderOprManMobile is not null and @traderOprManMobile<>'')	--���ɸ������˵Ķ���
			begin
				if (@curLeftDays > 0)
					set @msg = @traderOprMan + '���ã���������Ҵ���ó��ͬ['+@contractID
								+']��['+@curNodeName+']ʱ���Ҫ�����ˣ���ʣ��['+str(@curLeftDays,2,0)+']�죬�뼰ʱ����\n�人��ѧ�豸����'
				else
					set @msg = @traderOprMan + '���ã���������Ҵ���ó��ͬ['+@contractID
								+']��['+@curNodeName+']ʱ���Ѿ�������['+str(@curLeftDays*-1,2,0)+']�죬�뼰ʱ����\n�人��ѧ�豸����'
				insert contractSMS(contractID, mobile, msg)
				values(@contractID, @traderOprManMobile,@msg)
				if @@ERROR <> 0 
				begin
					rollback tran
					return
				end  
			end
			if (@managerMobile is not null and @managerMobile<>'' and @managerMobile<>@traderOprManMobile)	--���ɸ������˵Ķ���
			begin
				if (@curLeftDays > 0)
					set @msg = @traderOprMan + '���ã���������Ҵ���ó��ͬ['+@contractID
								+']��['+@curNodeName+']ʱ���Ҫ�����ˣ���ʣ��['+str(@curLeftDays,2,0)+']�죬�뼰ʱ����\n�人��ѧ�豸����'
				else
					set @msg = @traderOprMan + '���ã���������Ҵ���ó��ͬ['+@contractID
								+']��['+@curNodeName+']ʱ���Ѿ�������['+str(@curLeftDays*-1,2,0)+']�죬�뼰ʱ����\n�人��ѧ�豸����'
				insert contractSMS(contractID, mobile, msg)
				values(@contractID, @managerMobile,@msg)
				if @@ERROR <> 0 
				begin
					rollback tran
					return
				end  
			end
			
			--�����¼���
			update contractInfo
			set event2Trader = 'Y', event2TraderType = 2, event2TraderText = '��������Ҵ���ó��ͬ['+@contractID
								+']��['+@curNodeName+']ʱ���Ѿ�������['+str(@curLeftDays*-1,2,0)+']�죬�뾡�촦����������Ѿ���ɣ��뾡���ϴ�������',
				event2TraderTime = getdate()
			where contractID = @contractID
			if @@ERROR <> 0 
			begin
				rollback tran
				return
			end  
			--��ʱ��¼��
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
		
		--�ͷ�ȫ�����ߺ�ͬ�ı༭����
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
	
	--Ӧ����һ��ȫ������ı�һ�����ֹ��ȫ�������ʱ�����˱༭��ͬ����һ���������Ƿ�������񣡣�
	
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values('0000000000', 'ϵͳ', GETDATE(), '�����ͬ״̬', 'ϵͳ����˺�ͬ��״̬���㡣')
GO
--���ԣ�
exec dbo.calcContract
select * from contractInfo
select * from contractFlow

select * from contractSMS




select * from contractFlow where contractID='20120037'




select contractStatus, ci.curLeftDays, ci.contractID, curNode, curNodeName,dbo.getEqpInfoOfContract(ci.contractID) eqpInfo,totalAmount, currency, cd.objDesc currencyName,dbo.getClgInfoOfContract(ci.contractID) clgInfo,supplierID, supplierName, supplierOprMan, supplierOprManMobile, supplierOprManTel, convert(varchar(10),supplierSignedTime,120) supplierSignedTime,traderID, abbTraderName, traderName, traderOprMan, traderOprManMobile, traderOprManTel, convert(varchar(10),traderSignedTime,120) traderSignedTime,case f1.nStatus when 0 then '' when 1 then cast(f1.curLeftDays as varchar(10)) when -1 then '��' when 9 then '��' end nodeSignContract,case f2.nStatus when 0 then '' when 1 then cast(f2.curLeftDays as varchar(10)) when -1 then '��' when 9 then '��' end nodePay,case f3.nStatus when 0 then '' when 1 then cast(f3.curLeftDays as varchar(10)) when -1 then '��' when 9 then '��' end nodeTaxFree,case f4.nStatus when 0 then '' when 1 then cast(f4.curLeftDays as varchar(10)) when -1 then '��' when 9 then '��' end nodeDeclaration,case f5.nStatus when 0 then '' when 1 then cast(f5.curLeftDays as varchar(10)) when -1 then '��' when 9 then '��' end nodeCommit,case f6.nStatus when 0 then '' when 1 then cast(f6.curLeftDays as varchar(10)) when -1 then '��' when 9 then '��' end nodeAccept,case f7.nStatus when 0 then '' when 1 then cast(f7.curLeftDays as varchar(10)) when -1 then '��' when 9 then '��' end nodeAccount,ci.contractID timeoutRecord, dbo.getEventOfContract(ci.contractID,'00200977') haveEvent,dbo.getDiscussStatusOfContract(ci.contractID,'00200977') haveMsg,paymentMode, cd2.objDesc paymentModeDesc, goodsArrivalTime,convert(varchar(10),acceptedTime,120) acceptedTime, convert(varchar(10),completedTime,120) completedTime, notes,convert(varchar(10),ci.startTime,120) startTime
from contractInfo ci left join codeDictionary cd on ci.currency = cd.objCode and cd.classCode=3 left join codeDictionary cd2 on ci.paymentMode = cd2.objCode and cd2.classCode=4 left join contractFlow f1 on ci.contractID = f1.contractID and f1.nodeName ='ǩ��Э��' left join contractFlow f2 on ci.contractID = f2.contractID and f2.nodeName ='��֤����' left join contractFlow f3 on ci.contractID = f3.contractID and f3.nodeName ='�������' left join contractFlow f4 on ci.contractID = f4.contractID and f4.nodeName ='����' left join contractFlow f5 on ci.contractID = f5.contractID and f5.nodeName ='�ͽ�����' left join contractFlow f6 on ci.contractID = f6.contractID and f6.nodeName ='����' left join contractFlow f7 on ci.contractID = f7.contractID and f7.nodeName ='�������'
--where contractStatus in (0,1)
order by currencyName 



--��������ת����
select cast(UNICODE('��') as varbinary(4))
select cast(UNICODE('��') as varbinary(4))
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



--�����޸ĺ����¶�������:
delete contractFlow
declare @contractID varchar(12)	--��������ͬ��ţ�ʹ�õ� 1 �ź��뷢��������
declare @paymentMode smallint		--���ʽ, �ɵ�4�Ŵ����ֵ䶨��
declare tar cursor for
select contractID,paymentMode
from contractInfo
OPEN tar
FETCH NEXT FROM tar INTO @contractID, @paymentMode
WHILE @@FETCH_STATUS = 0
begin
	if (@paymentMode>10)	--��ǰ����
	begin
		insert contractFlow(contractID, nodeNum, nodeName,startTimeType,nodeDays)
		select @contractID, nodeNum, nodeName,startTimeType,nodeDays
		from flowTempletNode
		where templetID = '201204010001'
	end
	else					--���󸶿�
	begin
		insert contractFlow(contractID, nodeNum, nodeName,startTimeType,nodeDays)
		select @contractID, nodeNum, nodeName,startTimeType,nodeDays
		from flowTempletNode
		where templetID = '201204010002'	--����Ӧ�ö���һ����ͬ������
	end
	if @@ERROR <> 0 
	begin
		break
	end
	FETCH NEXT FROM tar INTO @contractID, @paymentMode
end
CLOSE tar
DEALLOCATE tar


--��ʷ��������2013-10-15
use fTradeDB2
select * from flowTempletNode
select * from contractFlow where contractID='20120001'
update contractFlow
set	startTimeType='startTime',	--����ʱ������:'startTime'�����̿�ʼʱ�䣬
								--'lastNodeCompleted'->��һ�ڵ�������ڣ�
								--'goodsArrivalTime'->����ʱ��
	nodeDays=7,			--�ڵ�����ʱ�䣨�죩
	curLeftDays=0,		--�ڵ�ʣ��ʱ��(��)�������ݿ�������ÿ����� add by lw 2012-4-19
	startTime='',		--�ڵ㿪ʼʱ��
	endTime='',			--�ڵ����ʱ��
	nStatus=9			--�ڵ�״̬��0->δ������1->���-1->������һ�ڵ㣬9->���
select * from contractFlow
where contractID='20133104' and nodeNum='1'

select acceptedTime, startTime, completedTime, * from contractInfo
	--acceptedTime smalldatetime null,	--����ʱ��(ǩԼʱ��)�������Ҫ�ͻ������б����Ĵ��ݺ�ͬ��ʱ�䣬ʱ��д��ԭʼ��ͬ�ϣ��ͻ�ȷ�ϲ�����ʽ�Ǽǣ�
	--startTime smalldatetime null,		--��ͬ����ʱ�� add by lw 2012-5-8 �ͻ����ǰ4��Ҫ��ص�ʱ�䶼��������ʱ��Ϊ��ʼʱ�������
	--completedTime smalldatetime null,	--�鵵ʱ��



