use hustOA
/*
	ǿ�ų����İ칫ϵͳ-�豸����
	author:		¬έ
	CreateDate:	2012-11-20
	UpdateDate: 
*/
--1.equipmentList���豸����
--�����豸Ҫ�����ֶΣ����������ṹ
--��ѯ�����༭���г�������豸
select * from equipmentList where eCode='20131436'
select * from equipmentAnnex where eCode='20131436'
select e.eCode, e.eName, e.lockManID, u.cName lockMan, u.telNum, u.mobileNum,
	case e.lock4LongTime when '0' then '' when '1' then '�豸��鵥' 
	when '2' then '�豸������' when '3' then '�豸���ϵ�' end invoiceType, e.lInvoiceNum
from equipmentList e left join userInfo u on e.lockManID = u.jobNumber 
where isnull(e.lockManID,'')<>'' or e.lock4LongTime <> 0

update equipmentList
set unit = g.unit
from eqpAcceptInfo e left join GBT14885 g on e.aTypeCode = g.aTypeCode

update equipmentList
set obtainMode = 1,purchaseMode=2
select eCode,'����' as status 
use hustOA

--�����豸��
update equipmentList
set obtainMode = 7
where notes like '%����%'
		or factory like '%�人��ѧ%'
		or eModel like '%����%'
		or eFormat like '%����%'
--�����豸��
update equipmentList
set obtainMode = 4
where fCode = '6'
alter table equipmentList add	barCode varchar(14) null		--һά���룺add by lw 2012-11-18


alter TABLE equipmentList add currency smallint null		--��ϵͳ�����ֶΣ�����,�ɵ�3�Ŵ����ֵ䶨��
alter TABLE equipmentList add cPrice numeric(12, 2) null	--��ϵͳ�����ֶΣ���ҼƼ�
alter TABLE equipmentList add cTotalAmount numeric(12, 2) null--��ϵͳ�����ֶΣ�����ܼ�, >0������+�����۸��޸����ͣ�Լ��С����
alter TABLE equipmentList add isShare smallint default(0)	--��ϵͳ�����ֶΣ��Ƿ���0->������1->����
alter TABLE equipmentList alter column aTypeCode varchar(7) null,		--��ϵͳ�����ã������ţ��ƣ������ţ��ƣ�=f�������ţ�������ʹ��ӳ���

select * from equipmentList where lock4LongTime='0'
--ע�⣺��ϵͳ�и�������������¼�룡
select * from equipmentList
drop table equipmentList
CREATE TABLE equipmentList(
	eCode char(8) not null,			--�������豸���,��ϵͳʹ�õ�6�ź��뷢����������4λ��ݴ���+4λ��ˮ�ţ�
	acceptApplyID char(12) null,	--��ϵͳ�����ã���Ӧ�����յ���
	eName nvarchar(30) not null,	--�豸���ƣ��������ƣ�:
	eModel nvarchar(20) not null,	--�豸�ͺ�
	eFormat nvarchar(30) not null,	--�豸���
	unit nvarchar(10) null,			--������λ���õ�λ��GBT14885���л�ȡ
	cCode char(3) not null,			--���Ҵ��룺
	factory	nvarchar(20) null,		--��������
	makeDate smalldatetime null,	--�������ڣ��������ֵ���ڽ���������
	serialNumber nvarchar(20) null,	--�������
	business nvarchar(20) null,		--���۵�λ
	buyDate smalldatetime null,		--�������ڣ��������ֵ���ڽ���������
	annexName nvarchar(20) null,	--��������
	annexCode nvarchar(20) null,	--����������
	annexAmount	numeric(12, 2) null,--���������Ǹ������ۣ��޸����ͣ�Լ��С����

	eTypeCode char(8) not null,		--�����ţ��̣�������ֻ��������
	eTypeName nvarchar(30) not null,--��������������
	aTypeCode varchar(7) null,		--��ϵͳ�����ã������ţ��ƣ������ţ��ƣ�=f�������ţ�������ʹ��ӳ���
									--����GB/T 14885-2010�涨�������ӳ���7λ

	fCode char(2) not null,			--������Դ����
	aCode char(2) null,				--��ϵͳ�����ã�ʹ�÷�����룺���������п�ֵ����Ҫ�û�ȷ���Ƿ������ֵ������������
	price numeric(12, 2) null,		--���ۣ�>0 �޸����ͣ�Լ��С����
	totalAmount numeric(12, 2) null,--�ܼ�, >0������+�����۸��޸����ͣ�Լ��С����
	
	currency smallint null,			--��ϵͳ�����ֶΣ�����,�ɵ�3�Ŵ����ֵ䶨��
	cPrice numeric(12, 2) null,		--��ϵͳ�����ֶΣ���ҼƼ�
	cTotalAmount numeric(12, 2) null,--��ϵͳ�����ֶΣ�����ܼ�, >0������+�����۸��޸����ͣ�Լ��С����
	
	clgCode char(3) not null,		--ѧԺ����:��ϵͳ��ʹ�ù̶�ֵ
	uCode varchar(8) not null,		--ʹ�õ�λ����
	keeperID varchar(10) null,		--�����˹��ţ��豸����Ա��,add by lw 2011-10-12�ƻ������豸��������Ϣ���������Ա�Ǽ��ˣ�������Ϣֻ���ɹ���Ա��д
	keeper nvarchar(30) null,		--������
	eqpLocate nvarchar(100) null,	--�豸���ڵ�ַ:�豸���ڵ�add by lw 2012-5-22�����豸���칦��
	
	isShare smallint default(0),	--��ϵͳ�����ֶΣ��Ƿ���0->������1->����

	notes nvarchar(50) null,		--��ע
	acceptDate smalldatetime null,	--��ϵͳ�����ã���������
	oprManID varchar(10) null,		--�����˹���
	oprMan nvarchar(30) null,		--������
	acceptManID varchar(10) null,	--��ϵͳ�����ã������˹���
	acceptMan nvarchar(30) null,	--��ϵͳ�����ã�������
	
	barCode varchar(30) null,		--��ϵͳ�����ã�һά����
	curEqpStatus char(1) not null,	--���ݱ���Ĺ涨���¶����豸����״���뺬�壺���ֶ��ɵ�2�Ŵ����ֵ䶨�� modi by lw 2011-1-26
									--1�����ã�ָ����ʹ�õ������豸��
									--2�����ָ࣬����ʹ�ü�ֵ��δʹ�õ������豸��
									--3�����ޣ�ָ���޻���������������豸��
									--4�������ϣ�ָ�Ѿ�ʧȥʹ�ü�ֵ����δ������ʽ���������������豸��
									--5����ʧ��
									--6�����ϣ�
									--7��������
									--8��������ָ��ѧУ��׼��������ʹ�á�����������豸��
									--9����������״����������豸��
	scrapDate smalldatetime null,	--�������ڣ�ԭ[ISDORE] [bit] NOT NULL,���Ѿ�ȷ�ϱ��ϣ��ָ�Ϊʹ�ñ�������
	--add by lw 2011-05-16,��Ϊɸѡ�е���������Ƚ��鷳���������Ӹ��ֶ�
	--ע�⣺��Ӧ�޸��˱��ϵĴ洢���̣��ڴ���ԭʼ���ݵ�ʱ����Ҫ����
	scrapNum char(12) null,		--��Ӧ���豸���ϵ���

	lock4LongTime char(1) default('0'),	--����������add by lw 2012-7-28
										--��Ҫ��Ϊ���ȹ��������豸����ֹ�������ڼ����豸����Ӹ����������򱨷�
											--'0'->δ����
											--'1'->�������
											--'2'->��������
											--'3'->��������
											--'4'->���յ���������Ӹ������յ���������
													--��Ϊ��Ӹ�������ȡ����˲��޸����ɵ����յ�������Ҫ����
											--'5'->�豸��Ϣ������������ add by lw 2012-19-13
	lInvoiceNum varchar(30) null,		--��������������Ʊ�ݺ�
	
	obtainMode int null,				--��ϵͳ�����ã�ȡ�÷�ʽ���ɵ�11�Ŵ����ֵ䶨�壬add by lw 2012-10-1
	purchaseMode int null,				--��ϵͳ�����ã��ɹ���֯��ʽ���ɵ�18�Ŵ����ֵ䶨�壬add by lw 2012-10-1

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_equipmentList] PRIMARY KEY CLUSTERED 
(
	[eCode] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--Ժ��������
CREATE NONCLUSTERED INDEX [IX_equipmentList] ON [dbo].[equipmentList] 
(
	[clgCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--Ժ����ʹ�õ�λ������
CREATE NONCLUSTERED INDEX [IX_equipmentList0] ON [dbo].[equipmentList] 
(
	[clgCode] ASC,
	[uCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--�������������������
CREATE NONCLUSTERED INDEX [IX_equipmentList1] ON [dbo].[equipmentList] 
(
	[eTypeCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--�������������������
CREATE NONCLUSTERED INDEX [IX_equipmentList2] ON [dbo].[equipmentList] 
(
	[aTypeCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--������Դ������
CREATE NONCLUSTERED INDEX [IX_equipmentList3] ON [dbo].[equipmentList] 
(
	[fCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--ʹ�÷���������
CREATE NONCLUSTERED INDEX [IX_equipmentList4] ON [dbo].[equipmentList] 
(
	[aCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--���۵�λ������
CREATE NONCLUSTERED INDEX [IX_equipmentList5] ON [dbo].[equipmentList] 
(
	[business] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
--��������������
CREATE NONCLUSTERED INDEX [IX_equipmentList6] ON [dbo].[equipmentList] 
(
	[factory] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

select * from equipmentAnnex order by buyDate desc
--2.equipmentAnnex���豸���������豸�����������豸�ֿ�����
drop table equipmentAnnex
CREATE TABLE equipmentAnnex(
	rowNum int IDENTITY(1,1) NOT NULL,	--���
	acceptApplyID char(12) null,		--��ϵͳ�����ã���Ӧ�����յ���	--��Ϊ�������Զ������գ��������������ֶΣ�add by lw 2011-4-5
	eCode char(8) not null,				--������豸���
	annexName nvarchar(20) not null,	--��������
	annexModel nvarchar(20) null,		--��ϵͳ�����ֶΣ��ͺ�
	annexFormat nvarchar(30) null,		--���

	unit nvarchar(10) null,				--��ϵͳ�����ֶΣ�������λ���õ�λ��GBT14885���л�ȡ
	serialNumber nvarchar(2100) null,	--��ϵͳ�����ֶΣ��������

	
	--��Ϊ�������Զ������գ��������������ֶΣ�add by lw 2011-4-5
	cCode char(3) not null,				--���Ҵ��룺add by lw 2011-10-26
	fCode char(2) not null,				--������Դ���룺���������豸�ľ�����Դ��ͬ��������豸�ľ�����Դͳ�ƣ�����Ը����ľ�����Դ��
	factory	nvarchar(20) null,			--��������
	makeDate smalldatetime null,		--��������
	business nvarchar(20) null,			--���۵�λ
	buyDate smalldatetime null,			--��������
	-----------------------------------------------
	
	quantity int null,					--����
	price numeric(12, 2) null,			--����
	totalAmount numeric(12, 2) null,	--�ܼ�
	currency smallint null,				--��ϵͳ�����ֶΣ�����,�ɵ�3�Ŵ����ֵ䶨��
	cPrice numeric(12, 2) null,			--��ϵͳ�����ֶΣ���ҼƼ�
	cTotalAmount numeric(12, 2) null,	--����ܼ�

	oprManID varchar(10) null,			--�����˹��� add by lw 2012-8-12
	oprMan nvarchar(30) null,			--������
	acceptMan nvarchar(30) null,		--��ϵͳ�����ã�������
	acceptManID varchar(10) null,		--��ϵͳ�����ã������˹���:add by lw 2011-10-26
/*	�����ֶ����ϣ���Ϊ�����༭��ʱ��ʹ�õ������豸���� del by lw 2012-10-5
	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
*/	
 CONSTRAINT [PK_equipmentAnnex] PRIMARY KEY CLUSTERED 
(
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--�����
ALTER TABLE [dbo].[equipmentAnnex] WITH CHECK ADD CONSTRAINT [FK_equipmentAnnex_equipmentList] FOREIGN KEY([eCode])
REFERENCES [dbo].[equipmentList] ([eCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[equipmentAnnex] CHECK CONSTRAINT [FK_equipmentAnnex_equipmentList]
GO

CREATE NONCLUSTERED INDEX [IX_equipmentList] ON [dbo].[equipmentAnnex]
(
	[business] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


select * from equipmentAnnex

--3.eqpLifeCycle���豸�������ڱ���
--�豸���������ڣ�
--������ˣ��豸�������ڵĿ�ʼ
--ȡ��������ˣ��豸�������ڵ���ֹ
--�豸ά�ޣ��豸�������ڣ��䶯�������漰��ֵ�䶯
--�豸�������豸�������ڣ��䶯��������ϵ�䶯
--���Ӹ������豸�������ڣ��䶯���漰��ֵ�䶯
--�豸���ϣ��豸����������ֹ
select * from eqpLifeCycle

alter table eqpLifeCycle alter column changeType nvarchar(10) null		--�䶯���� modi by lw 2012-10-18
drop table eqpLifeCycle
CREATE TABLE eqpLifeCycle(
	eCode char(8) not null,			--����/������豸���,ʹ������ĺ��뷢��������
											--2λ��ݴ���+6λ��ˮ�ţ�����Ԥ������
											--ʹ���ֹ�������룬�Զ��������Ƿ��غ�
	rowNum int IDENTITY(1,1) NOT NULL,	--����:���
	
	--������ƣ�
	eName nvarchar(30) not null,	--�豸����
	eModel nvarchar(20) not null,	--�豸�ͺ�
	eFormat nvarchar(30) not null,	--�豸���
	
	--��������Ϣ��
	clgCode char(3) not null,		--��ϵͳ�����ã�ѧԺ����
	clgName nvarchar(30) null,		--��ϵͳ�����ã�ѧԺ����
	uCode varchar(8) null,			--ʹ�õ�λ����,modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
	uName nvarchar(30) null,		--ʹ�õ�λ����
	keeper nvarchar(30) null,		--������
	keeperID varchar(10) null,		--�����˹���:add by lw 2012-5-22Ϊ�豸����һ�»�����
	eqpLocate nvarchar(100) null,	--�豸���ڵ�ַ:add by lw 2012-5-22Ϊ�豸����һ�»�����
	
	--��ֵ��	
	annexAmount	numeric(12, 2) null,--������� �޸����ͣ�Լ��С���� modi by lw 2012-10-9
	price numeric(12, 2)  null,		--���ۣ�>0 �޸����ͣ�Լ��С���� modi by lw 2012-10-9
	totalAmount numeric(12, 2) null,--�ܼ�, >0������+�����۸��޸����ͣ�Լ��С���� modi by lw 2012-10-9

	--�䶯���
	changeDate smalldatetime default(getdate()), --�䶯����
	changeDesc nvarchar(200) not null,	--�䶯����
	--add by lw 2011-10-15��
	changeType nvarchar(10) null,		--�䶯���� modi by lw 2012-10-18
	changeInvoiceID varchar(30) null,	--�䶯ƾ֤��
	
 CONSTRAINT [PK_eqpLifeCycle] PRIMARY KEY CLUSTERED 
(
	[eCode] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[eqpLifeCycle] WITH CHECK ADD CONSTRAINT [FK_eqpLifeCycle_equipmentList] FOREIGN KEY([eCode])
REFERENCES [dbo].[equipmentList] ([eCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[eqpLifeCycle] CHECK CONSTRAINT [FK_eqpLifeCycle_equipmentList]
GO

--4.�豸��״����Ϊ�����Ϣ����Դ���ܲ�ֹ�豸���һ�����ܣ�Ҳ���������չ��ܵȣ�
			  --����Ҫ����ͬ�豸�����״�������ƣ������豸����������������е�ʱ��ɾ������������ᱻɾ����
use hustOA
alter TABLE eqpStatusInfo alter column invoiceType char(1) null		--��Ӧ����״̬��Ʊ�����ͣ�'1':���յ��ţ�'5':�豸��鵥��
alter TABLE eqpStatusInfo alter column invoiceNum varchar(30) null		--��Ӧ����״̬��Ʊ�ݺţ����������յ��Ż��豸��鵥�ŵ�
select * from eqpStatusInfo
drop TABLE eqpStatusInfo
CREATE TABLE eqpStatusInfo(
	eCode char(8) not null,				--����/������豸���
	eName nvarchar(30) not null,		--�豸���ƣ��������
	sNumber int not null,				--��������״���κ�
	checkDate smalldatetime null,		--ȷ������
	keeperID varchar(10) null,			--�����˹���
	keeper nvarchar(30) null,			--������
	eqpLocate nvarchar(100) null,		--�豸���ڵ�ַ
	checkStatus char(1) not null,		--�豸״̬��
										--0��״̬���� --����״̬�Զ����Ϊ����
										--1��������
										--3�����ޣ�
										--4�������ϣ�
										--5���������
										--6���������--����״̬Ӧ���޷�ȷ����
										--9��������
	statusNotes nvarchar(100) null,		--�豸��״˵��
	invoiceType char(1) null,		--��Ӧ����״̬��Ʊ�����ͣ�'1':���յ��ţ�'5':�豸��鵥��
	invoiceNum varchar(30) null,		--��Ӧ����״̬��Ʊ�ݺţ����������յ��Ż��豸��鵥�ŵ�
 CONSTRAINT [PK_eqpStatusInfo] PRIMARY KEY CLUSTERED 
(
	[eCode] ASC,
	[sNumber] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[eqpStatusInfo] WITH CHECK ADD CONSTRAINT [FK_eqpStatusInfo_equipmentList] FOREIGN KEY([eCode])
REFERENCES [dbo].[equipmentList] ([eCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[eqpStatusInfo] CHECK CONSTRAINT [FK_eqpStatusInfo_equipmentList]
GO

--������
--ȷ������������
CREATE NONCLUSTERED INDEX [IX_eqpStatusInfo_1] ON [dbo].[eqpStatusInfo]
(
	[checkDate] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


select * from eqpStatusPhoto
--4.1�豸��״��Ƭ�������豸��״���һ������
--ͼƬ�ļ�����eqpCheckPhoto/201111,��Ŀ¼Ϊ�ϴ������ڵ�����
drop TABLE eqpStatusPhoto
CREATE TABLE eqpStatusPhoto(
	eCode char(8) not null,				--���/����:�豸���
	eName nvarchar(30) not null,		--�豸����:�������
	sNumber int not null,				--���/����:��״���κ�
	rowNum bigint IDENTITY(1,1) NOT NULL,--����:���
	photoDate smalldatetime not null,	--��������
	aFilename varchar(128) not NULL,	--������ͼƬ�ļ���Ӧ��36λȫ��Ψһ�����ļ���
	notes nvarchar(100) null,			--˵��
 CONSTRAINT [PK_eqpStatusPhoto] PRIMARY KEY CLUSTERED 
(
	[eCode] ASC,
	[sNumber] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[eqpStatusPhoto]  WITH CHECK ADD  CONSTRAINT [FK_eqpStatusPhoto_eqpStatusInfo] FOREIGN KEY([eCode],[sNumber])
REFERENCES [dbo].[eqpStatusInfo] ([eCode],[sNumber])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[eqpStatusPhoto] CHECK CONSTRAINT [FK_eqpStatusPhoto_eqpStatusInfo]
GO
--������
--ͼƬ��������
CREATE NONCLUSTERED INDEX [IX_eqpStatusPhoto] ON [dbo].[eqpStatusPhoto]
(
	[aFilename] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


drop PROCEDURE queryEqpLocMan
/*
	name:		queryEqpLocMan
	function:	1.��ѯָ���豸�Ƿ��������ڱ༭
	input: 
				@eCode char(8),				--�豸���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ�����豸������
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2012-5-22
	UpdateDate: 
*/
create PROCEDURE queryEqpLocMan
	@eCode char(8),				--�豸���
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from equipmentList where eCode= @eCode),'')
	set @Ret = 0
GO


drop PROCEDURE lockEqp4Edit
/*
	name:		lockEqp4Edit
	function:	2.�����豸�༭������༭��ͻ
	input: 
				@eCode char(8),					--�豸���
				@lockManID varchar(10) output,	--�����ˣ������ǰ�豸���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�������豸�����ڣ�2:Ҫ�������豸���ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-5-22
	UpdateDate: 
*/
create PROCEDURE lockEqp4Edit
	@eCode char(8),					--�豸���
	@lockManID varchar(10) output,	--�����ˣ������ǰ�豸���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�������豸�Ƿ����
	declare @count as int
	set @count=(select count(*) from equipmentList where eCode= @eCode)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from equipmentList where eCode= @eCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update equipmentList
	set lockManID = @lockManID 
	where eCode= @eCode
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�����豸�༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���������豸['+ @eCode +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockEqpEditor
/*
	name:		unlockEqpEditor
	function:	3.�ͷ��豸�༭��
				ע�⣺�����̲�����豸�Ƿ���ڣ�
	input: 
				@eCode char(8),					--�豸���
				@lockManID varchar(10) output,	--�����ˣ������ǰ�豸���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-5-22
	UpdateDate: 
*/
create PROCEDURE unlockEqpEditor
	@eCode char(8),					--�豸���
	@lockManID varchar(10) output,	--�����ˣ������ǰ�豸���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from equipmentList where eCode= @eCode),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update equipmentList set lockManID = '' where eCode= @eCode
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
	values(@lockManID, @lockManName, getdate(), '�ͷ��豸�༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ����豸['+ @eCode +']�ı༭����')
GO

delete equipmentList where isnull(uCode,'')=''
delete shareEqpStatus where eCode not in (select ecode from equipmentList)
drop PROCEDURE addEqpInfo
/*
	name:		addEqpInfo
	function:	4.����豸��Ϣ
				�����̸����豸����ϵͳ������յ����޸Ķ���
				ע�⣺�ô洢�����Զ���������
	input: 
				@eTypeCode char(8),			--�����ţ��̣�
				@eTypeName nvarchar(30),	--��������������:Ϊ�˽����Զ��������Ҫ���ӵ��ֶΣ�add by lw 2010-11-30
				@eName nvarchar(30),		--�豸����
				@eModel nvarchar(20),		--�豸�ͺ�
				@eFormat nvarchar(30),		--�豸���
				@cCode char(3),				--���Ҵ���
				@factory nvarchar(20),		--��������
				@makeDate smalldatetime,	--�������ڣ��ڽ���������
				@serialNumber nvarchar(2100),--�������:���á�1|2|3|..."��ʽ���,�֧��20�ַ�*100������
				@buyDate smalldatetime,		--��������
				@business nvarchar(20),		--���۵�λ
				@fCode char(2),				--������Դ����
				@uCode varchar(8),			--ʹ�õ�λ����
				@keeperID varchar(10),		--�����˹���,add by lw 2012-8-10
				@price numeric(12,2),		--���ۣ�>0
				@sumNumber int,				--����

				@currency smallint,			--��ϵͳ�����ֶΣ�����,�ɵ�3�Ŵ����ֵ䶨��
				@cPrice numeric(12, 2),		--��ϵͳ�����ֶΣ���ҼƼ�
				
				@oprManID varchar(10),		--�����˹���,add by lw 2012-8-10
				@notes nvarchar(50),		--��ע
				@photoXml xml,				--�豸��Ƭ��add by lw 2012-10-25
				@eqpLocate nvarchar(100),	--�豸���ڵ�ַ:�豸���ڵ�add by lw 2012-12-19
				@isShare smallint,			--��ϵͳ�����ֶΣ��Ƿ���0->������1->����

				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output	--���ʱ��
	author:		¬έ
	CreateDate:	2012-12-20
	UpdateDate: 
*/
create PROCEDURE addEqpInfo
	@eTypeCode char(8),			--�����ţ��̣�
	@eTypeName nvarchar(30),	--��������������:Ϊ�˽����Զ��������Ҫ���ӵ��ֶΣ�add by lw 2010-11-30
	@eName nvarchar(30),		--�豸����
	@eModel nvarchar(20),		--�豸�ͺ�
	@eFormat nvarchar(30),		--�豸���
	@cCode char(3),				--���Ҵ���
	@factory nvarchar(20),		--��������
	@makeDate smalldatetime,	--�������ڣ��ڽ���������
	@serialNumber nvarchar(2100),--�������:���á�1|2|3|..."��ʽ���,�֧��20�ַ�*100������
	@buyDate smalldatetime,		--��������
	@business nvarchar(20),		--���۵�λ
	@fCode char(2),				--������Դ����
	@uCode varchar(8),			--ʹ�õ�λ����
	@keeperID varchar(10),		--�����˹���,add by lw 2012-8-10
	@price numeric(12,2),		--���ۣ�>0
	@sumNumber int,				--����

	@currency smallint,			--��ϵͳ�����ֶΣ�����,�ɵ�3�Ŵ����ֵ䶨��
	@cPrice numeric(12, 2),		--��ϵͳ�����ֶΣ���ҼƼ�
	
	@oprManID varchar(10),		--�����˹���,add by lw 2012-8-10
	@notes nvarchar(50),		--��ע
	@photoXml xml,				--�豸��Ƭ��add by lw 2012-10-25
	@eqpLocate nvarchar(100),	--�豸���ڵ�ַ:�豸���ڵ�add by lw 2012-12-19
	@isShare smallint,			--��ϵͳ�����ֶΣ��Ƿ���0->������1->����

	@createManID varchar(10),	--�����˹���

	@Ret		int output,
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	declare @clgCode char(3),@clgName nvarchar(30)	--ѧԺ����
	set @clgCode = '001'	--������ʱ�趨�Ĵ��룬��Ҫ����ѧУ����Ĵ����д��
	set @clgName = '����ǿ�ų���ѧ����'

	--ȡ������λ��
	declare @unit nvarchar(10)
	set @unit = '̨/��'
	
	--��ȡ�������ƣ�
	declare @uName nvarchar(30)	--ѧԺ����/ʹ�õ�λ����
	set @uName = (select uName from useUnit where uCode = @uCode)

	--ȡ�����ˡ������ˡ������˵�������
	declare @keeper nvarchar(30),@oprMan nvarchar(30),@createManName nvarchar(30)
	set @keeper = isnull((select cName from userInfo where jobNumber = @keeperID),'')
	set @oprMan = isnull((select cName from userInfo where jobNumber = @oprManID),'')
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	--���������ţ�
	declare @xmlSerialNumber xml
	set @xmlSerialNumber = '<s>'+REPLACE(@serialNumber,'|','</s><s>')+'</s>'

	set @createTime = getdate()
	--�����豸�嵥��
	begin tran
		declare @rowID int --�кţ�����ȡ�豸������ź͸�����ŵ����к�
		set @rowID = 1
		declare @length int
		set @length = @sumNumber
		
		declare @eCode char(8)
		--��������豸�嵥��
		while (@sumNumber>0)
		begin
			--ʹ�ú��뷢���������豸���룺
			declare @curNumber varchar(50)
			exec dbo.getClassNumber 6, 1, @curNumber output
			set @eCode = @curNumber

			declare @curSerialNumber nvarchar(20)	--��ǰ�豸�ĳ������
			set @curSerialNumber = (select cast(@xmlSerialNumber.query('(/s)[sql:variable("@rowID")]/text()') as nvarchar(20)))
			--�����豸�嵥��
			insert equipmentList(eCode, eName, eModel, eFormat, unit, cCode, factory, business,
				eTypeCode, eTypeName, 
				fCode, makeDate, buyDate, price, totalAmount, currency, cPrice, cTotalAmount,
				clgCode, uCode, keeperID, keeper, eqpLocate, notes,
				acceptDate, oprManID, oprMan, curEqpStatus,
				serialNumber, isShare,
				--����ά�����:
				modiManID, modiManName, modiTime)
			values(@eCode, @eName, @eModel, @eFormat, @unit, @cCode, @factory, @business,
				@eTypeCode,@eTypeName,
				@fCode, @makeDate, @buyDate, @price, @price, @currency, @cPrice, @cPrice,
				@clgCode, @uCode, @keeperID, @keeper, @eqpLocate, @notes,
				@buyDate, @oprManID, @oprMan, '1',
				@curSerialNumber, @isShare,
				--����ά�����:
				@createManID, @createManName, @createTime)
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
			
			--�Ǽ��豸���������ڣ�
			insert eqpLifeCycle(eCode,eName, eModel, eFormat,
				clgCode, clgName, uCode, uName, keeper,
				price, totalAmount,
				changeDate, changeDesc,changeType,changeInvoiceID) 
			values(@eCode, @eName, @eModel, @eFormat, 
				@clgCode, @clgName, @uCode, @uName, @keeper,
				@price, @price,
				@createTime, '�Ǽ��豸['+@eCode+']','�Ǽ�',null)
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end
			
			--�����豸��״�⣺add by lw 2012-10-27
			--ֻ������Ϊ1�����յ����������豸��Ƭ������Ҫ��UI��������
			if (@length = 1)
			begin
				insert eqpStatusInfo(eCode, eName, sNumber, checkDate, keeperID, keeper, 
							eqpLocate, checkStatus,		--�豸״̬��
											--0��״̬���� --����״̬�Զ����Ϊ����
											--1��������
											--3�����ޣ�
											--4�������ϣ�
											--5���������
											--6���������--����״̬Ӧ���޷�ȷ����
											--9��������
							statusNotes, invoiceType, invoiceNum)
				values(@eCode, @eName, 1, @createTime, @keeperID, @keeper, @eqpLocate, 1,
						'�豸���״̬', '1', null)

				insert eqpStatusPhoto(eCode, eName, sNumber, photoDate, aFilename, notes)
				select @eCode, @eName, 1, cast(T.photo.query('data(./@photoDate)') as varchar(10)), 
					cast(T.photo.query('data(./@aFileName)') as varchar(128)), 
					cast(T.photo.query('data(./@notes)') as nvarchar(100))
				from @photoXml.nodes('/root/photo') as T(photo)
			end
			set @rowID = @rowID + 1
			set @sumNumber = @sumNumber -1
		end
	commit tran	
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '�Ǽ��豸', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��Ǽ���' + str(@sumNumber) + '̨/���豸��')
GO

drop PROCEDURE delEqpInfo
/*
	name:		delEqpInfo
	function:	5.ɾ��ָ�����豸
	input: 
				@eCode char(8)					--�豸���
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ�����豸�����ڣ�2��Ҫɾ�����豸��������������9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-20
	UpdateDate: 

*/
create PROCEDURE delEqpInfo
	@eCode char(8),					--�豸���
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�����豸�Ƿ���ڣ�
	declare @count int
	set @count = (select COUNT(*) from equipmentList where eCode = @eCode)
	if (@count=0)
	begin
		set @Ret = 1
		return
	end

	--����豸�ĳ��������ͱ༭����
	declare @locker varchar(10), @lock4LongTime char(1)
	select @locker=isnull(lockManID,''), @lock4LongTime=lock4LongTime from equipmentList where eCode =@eCode
	if ((@locker<>'' and @locker<>@delManID) or @lock4LongTime<>'0')
	begin
		set @Ret = 2
		return
	end

	delete equipmentList where eCode = @eCode
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ���豸', '�û�' + @delManName
												+ 'ɾ�����豸['+ @eCode +']��')

GO


drop PROCEDURE addAnnex
/*
	name:		addAnnex
	function:	6.��Ӹ���
				�����豸����ϵͳ�е���Ӹ����޸Ķ���.
				ע�⣺���洢����ʹ�����豸����
	input: 
				@eCode char(8),				--���豸���
				@annexName nvarchar(20),	--��������
				@annexModel nvarchar(20),	--��ϵͳ�����ֶΣ��ͺ�
				@annexFormat nvarchar(30),	--���

				@serialNumber nvarchar(2100),--�������:���á�1|2|3|..."��ʽ���,�֧��20�ַ�*100������
				
				@cCode char(3),				--���Ҵ��룺add by lw 2011-10-26
				@fCode char(2),				--������Դ���룺���������豸�ľ�����Դ��ͬ��������豸�ľ�����Դͳ�ƣ�����Ը����ľ�����Դ��
				@factory	nvarchar(20),	--��������
				@makeDate smalldatetime,	--��������
				@business nvarchar(20),		--���۵�λ
				@buyDate smalldatetime,		--��������
				-----------------------------------------------
				
				@quantity int,				--����
				@price numeric(12, 2),		--����
				@currency smallint,			--��ϵͳ�����ֶΣ�����,�ɵ�3�Ŵ����ֵ䶨��
				@cPrice numeric(12, 2),		--��ϵͳ�����ֶΣ���ҼƼ�

				@oprManID varchar(10),		--�����˹��� add by lw 2012-8-12

				@createManID varchar(10) output,	--�����˹��ţ�������Ӹ����ˣ������ˣ���������豸�����������༭���������˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:Ҫ��Ӹ��������豸�����ڣ�
							2:Ҫ��Ӹ��������豸������������༭��
							3:Ҫ��Ӹ��������豸��״̬���ԣ�ֻ�������豸״̬������Ӹ�����
									--1�����ã�ָ����ʹ�õ������豸��
									--3�����ޣ�ָ���޻���������������豸��
									--8��������ָ��ѧУ��׼��������ʹ�á�����������豸��
							4:���豸�б༭����������
							9:δ֪����
				@createTime smalldatetime output	--���ʱ��
	author:		¬έ
	CreateDate:	2012-12-20
	UpdateDate: 
*/
create PROCEDURE addAnnex
	@eCode char(8),				--���豸���
	@annexName nvarchar(20),	--��������
	@annexModel nvarchar(20),	--��ϵͳ�����ֶΣ��ͺ�
	@annexFormat nvarchar(30),	--���

	@serialNumber nvarchar(2100),--�������:���á�1|2|3|..."��ʽ���,�֧��20�ַ�*100������
	
	@cCode char(3),				--���Ҵ��룺add by lw 2011-10-26
	@fCode char(2),				--������Դ���룺���������豸�ľ�����Դ��ͬ��������豸�ľ�����Դͳ�ƣ�����Ը����ľ�����Դ��
	@factory	nvarchar(20),	--��������
	@makeDate smalldatetime,	--��������
	@business nvarchar(20),		--���۵�λ
	@buyDate smalldatetime,		--��������
	-----------------------------------------------
	
	@quantity int,				--����
	@price numeric(12, 2),		--����
	@currency smallint,			--��ϵͳ�����ֶΣ�����,�ɵ�3�Ŵ����ֵ䶨��
	@cPrice numeric(12, 2),		--��ϵͳ�����ֶΣ���ҼƼ�

	@oprManID varchar(10),		--�����˹��� add by lw 2012-8-12

	@createManID varchar(10) output,	--�����˹��ţ�������Ӹ����ˣ������ˣ�
	@Ret		int output,
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ȡ������λ��
	declare @unit nvarchar(10)
	set @unit = '̨/��'

	--���ָ�����豸�Ƿ����
	declare @count as int
	set @count=(select count(*) from equipmentList where eCode = @eCode)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @curEqpStatus char(1)
	select @thisLockMan = isnull(lockManID,''), @curEqpStatus = curEqpStatus
	from equipmentList where eCode = @eCode
	--����豸�༭����
	if (@thisLockMan <> '' and @thisLockMan <> @createManID)
	begin
		set @createManID = @thisLockMan
		set @Ret = 2
		return
	end
	--����豸״̬:
	if (@curEqpStatus not in ('1','3','8'))
	begin
		set @Ret = 3
		return
	end
	
	--����豸�Ƿ��б༭������������
	set @count = (select COUNT(*) from equipmentList
					where eCode = @eCode and ((isnull(lockManID,'') <> '' and isnull(lockManID,'') <> @createManID) 
													or lock4LongTime <> '0'))
	if (@count>0)
	begin
		set @Ret = 4
		return
	end
	
	--ȡ������/ά���˵�������
	declare @oprMan nvarchar(30),@createManName nvarchar(30)
	set @oprMan = isnull((select cName from userInfo where jobNumber = @oprManID),'')
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	--�����
	declare @sumAmount numeric(12,2)			--�ϼƽ��
	set @sumAmount = @price * @quantity

	set @createTime = getdate()
	begin tran
		insert equipmentAnnex(eCode, annexName, annexModel, annexFormat, unit, 
						fCode, cCode, factory, makeDate, business, buyDate, 
						quantity, price, totalAmount, currency, cPrice, cTotalAmount,
						oprManID, oprMan)
		values(@eCode, @annexName, @annexModel, @annexFormat, @unit, 
						@fCode, @cCode, @factory, @makeDate, @business, @buyDate, 
						@quantity, @price, @sumAmount, @currency, @cPrice, @quantity*@cPrice,
						@oprManID, @oprMan)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--�����豸��
		declare @curAnnexName nvarchar(20)
		set @curAnnexName = isnull((select annexName from equipmentList where eCode = @eCode),'')
		if @curAnnexName = ''
			set @curAnnexName = @annexName
		update equipmentList
		set annexName = @curAnnexName,
			annexAmount	= isnull(annexAmount,0) + @sumAmount,
			totalAmount = isnull(totalAmount,0) + @sumAmount,
			cTotalAmount = ISNULL(cTotalAmount,0) + @quantity*@cPrice
		where eCode = @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--�Ǽ��豸���������ڣ�
		insert eqpLifeCycle(eCode,eName, eModel, eFormat,
			clgCode, clgName, uCode, uName, keeper,
			annexAmount, price, totalAmount,
			changeDate, changeDesc,changeType,changeInvoiceID) 
		select eCode, eName, eModel, eFormat, 
			e.clgCode, c.clgName, e.uCode, u.uName, keeper,
			annexAmount, price, totalAmount,
			@createTime, '��Ӹ�����' + @annexName, '��Ӹ���',null
		from equipmentList e left join college c on e.clgCode = c.clgCode
				left join useUnit u on e.uCode = u.uCode and e.clgCode = u.clgCode
		where e.eCode = @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
	commit tran
	
	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '��Ӹ���', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ����豸['+ @eCode +']����˸���'+str(@quantity)+'̨/��['+ @annexName +']��')
GO
--����:
use hustOA
declare @Ret		int
declare @createTime smalldatetime 
exec dbo.addAnnex 'A5000725','ceshi','*','*','123456','156','1 ','IBM','2012-12-01','lan','2012-12-12',
			5,7500,'502',200,'0000000000','0000000000', @Ret  output, @createTime output
select @Ret

drop PROCEDURE updateAnnex
/*
	name:		updateAnnex
	function:	7.�޸��豸����
				�����豸����ϵͳ�е��޸ĸ����޸Ķ���.
				ע�⣺���洢����ʹ�����豸����
	input: 
				@eCode char(8),				--���豸���
				@rowNum int,				--�����к�
				@annexName nvarchar(20),	--��������
				@annexModel nvarchar(20),	--��ϵͳ�����ֶΣ��ͺ�
				@annexFormat nvarchar(30),	--���

				--@serialNumber nvarchar(2100),--�������:���á�1|2|3|..."��ʽ���,�֧��20�ַ�*100������
				
				@cCode char(3),				--���Ҵ��룺add by lw 2011-10-26
				@fCode char(2),				--������Դ���룺���������豸�ľ�����Դ��ͬ��������豸�ľ�����Դͳ�ƣ�����Ը����ľ�����Դ��
				@factory	nvarchar(20),	--��������
				@makeDate smalldatetime,	--��������
				@business nvarchar(20),		--���۵�λ
				@buyDate smalldatetime,		--��������
				-----------------------------------------------
				
				@quantity int,				--����
				@price numeric(12, 2),		--����
				@currency smallint,			--��ϵͳ�����ֶΣ�����,�ɵ�3�Ŵ����ֵ䶨��
				@cPrice numeric(12, 2),		--��ϵͳ�����ֶΣ���ҼƼ�

				@oprManID varchar(10),		--�����˹��� add by lw 2012-8-12

				@modiManID varchar(10) output,	--�޸��˹��ţ�������Ӹ����ˣ������ˣ�
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:Ҫ��Ӹ��������豸�����ڣ�
							2:Ҫ��Ӹ��������豸������������༭��
							3:Ҫ��Ӹ��������豸��״̬���ԣ�ֻ�������豸״̬������Ӹ�����
									--1�����ã�ָ����ʹ�õ������豸��
									--3�����ޣ�ָ���޻���������������豸��
									--8��������ָ��ѧУ��׼��������ʹ�á�����������豸��
							4:ָ���ĸ��������ڣ�
							5:Ҫ��Ӹ��������豸�г����������������޸�
							9:δ֪����
				@modiTime smalldatetime output	--�޸�ʱ��
	author:		¬έ
	CreateDate:	2012-12-20
	UpdateDate: 
*/
create PROCEDURE updateAnnex
	@eCode char(8),				--���豸���
	@rowNum int,				--�����к�
	@annexName nvarchar(20),	--��������
	@annexModel nvarchar(20),	--��ϵͳ�����ֶΣ��ͺ�
	@annexFormat nvarchar(30),	--���

	--@serialNumber nvarchar(2100),--�������:���á�1|2|3|..."��ʽ���,�֧��20�ַ�*100������
	
	@cCode char(3),				--���Ҵ��룺add by lw 2011-10-26
	@fCode char(2),				--������Դ���룺���������豸�ľ�����Դ��ͬ��������豸�ľ�����Դͳ�ƣ�����Ը����ľ�����Դ��
	@factory	nvarchar(20),	--��������
	@makeDate smalldatetime,	--��������
	@business nvarchar(20),		--���۵�λ
	@buyDate smalldatetime,		--��������
	-----------------------------------------------
	
	@quantity int,				--����
	@price numeric(12, 2),		--����
	@currency smallint,			--��ϵͳ�����ֶΣ�����,�ɵ�3�Ŵ����ֵ䶨��
	@cPrice numeric(12, 2),		--��ϵͳ�����ֶΣ���ҼƼ�

	@oprManID varchar(10),		--�����˹��� add by lw 2012-8-12

	@modiManID varchar(10) output,	--�޸��˹��ţ�������Ӹ����ˣ������ˣ�
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���ָ�����豸�Ƿ����
	declare @count as int
	set @count=(select count(*) from equipmentList where eCode = @eCode)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @curEqpStatus char(1)
	select @thisLockMan = isnull(lockManID,''), @curEqpStatus = curEqpStatus
	from equipmentList where eCode = @eCode
	--����豸�༭����
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--����豸״̬:
	if (@curEqpStatus not in ('1','3','8'))
	begin
		set @Ret = 3
		return
	end
	--����豸�Ƿ��б༭������������
	set @count = (select COUNT(*) from equipmentList
					where eCode = @eCode and ((isnull(lockManID,'') <> '' and isnull(lockManID,'') <> @modiManID) 
													or lock4LongTime <> '0'))
	if (@count>0)
	begin
		set @Ret = 5
		return
	end
	
	--�ж�ָ���ĸ����Ƿ����
	set @count=(select count(*) from equipmentAnnex where eCode = @eCode and rowNum = @rowNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 4
		return
	end

	--ȡ�����˵�������
	declare @oprMan nvarchar(30)
	set @oprMan = isnull((select cName from userInfo where jobNumber = @oprManID),'')

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--�����
	declare @sumAmount numeric(12,2)			--�ϼƽ��
	set @sumAmount = @price * @quantity
	
	--��ȡԭ������
	declare @oldSumAmount numeric(12,2), @oldCTotalAmount numeric(12,2)			--�ϼƽ��/��ҽ��
	select @oldSumAmount = totalAmount, @oldCTotalAmount = cTotalAmount 
	from equipmentAnnex 
	where eCode = @eCode and rowNum = @rowNum
	
	set @modiTime = getdate()
	begin tran
		--�޸ĸ�����
		update equipmentAnnex
		set annexName = @annexName, annexModel = @annexModel, annexFormat = @annexFormat,
			--serialNumber = @serialNumber, 
			cCode = @cCode, fCode = @fCode, 
			factory = @factory, makeDate = @makeDate, business = @business, buyDate = @buyDate,
			quantity = @quantity, price = @price, totalAmount = @sumAmount, currency = @currency, cPrice = @cPrice, cTotalAmount = @quantity * @cPrice,
			oprManID = @oprManID
		where eCode = @eCode and rowNum = @rowNum
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--�����豸��
		declare @curAnnexName nvarchar(20)
		set @curAnnexName = isnull((select annexName from equipmentList where eCode = @eCode),'')
		if @curAnnexName = ''
			set @curAnnexName = @annexName
		update equipmentList
		set annexName = @curAnnexName,
			annexAmount	= isnull(annexAmount,0) - @oldSumAmount + @sumAmount,
			totalAmount = isnull(totalAmount,0) - @oldSumAmount + @sumAmount,
			cTotalAmount = isnull(cTotalAmount,0) - @oldCTotalAmount + @quantity * @cPrice
		where eCode = @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--�Ǽ��豸���������ڣ�
		insert eqpLifeCycle(eCode,eName, eModel, eFormat,
			clgCode, clgName, uCode, uName, keeper,
			annexAmount, price, totalAmount,
			changeDate, changeDesc,changeType,changeInvoiceID) 
		select eCode, eName, eModel, eFormat, 
			e.clgCode, c.clgName, e.uCode, u.uName, keeper,
			annexAmount, price, totalAmount,
			@modiTime, '��Ӹ�����' + @annexName,
			'��Ӹ���',null
		from equipmentList e left join college c on e.clgCode = c.clgCode
				left join useUnit u on e.uCode = u.uCode and e.clgCode = u.clgCode
		where e.eCode = @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
	commit tran
	
	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '�޸ĸ���', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸����豸['+ @eCode +']�ĸ���['+ @annexName +']��')
GO

drop PROCEDURE delAnnex
/*
	name:		delAnnex
	function:	7.1.ɾ���豸����
				ע�⣺���洢����ʹ�����豸����������洢�������豸ϵͳû�еģ�
	input: 
				@eCode char(8),				--���豸���
				@rowNum int,				--�����к�
				@delManID varchar(10) output,	--ɾ���˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:���豸�����ڣ�
							2:���豸������������༭��
							3:���豸��״̬���ԣ�ֻ�������豸״̬����ɾ��������
									--1�����ã�ָ����ʹ�õ������豸��
									--3�����ޣ�ָ���޻���������������豸��
									--8��������ָ��ѧУ��׼��������ʹ�á�����������豸��
							4:ָ���ĸ��������ڣ�
							5:���豸�г����������������޸�
							9:δ֪����
	author:		¬έ
	CreateDate:	2013-07-08
	UpdateDate: 
*/
create PROCEDURE delAnnex
	@eCode char(8),				--���豸���
	@rowNum int,				--�����к�
	@delManID varchar(10) output,	--ɾ���˹���
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���ָ�����豸�Ƿ����
	declare @count as int
	set @count=(select count(*) from equipmentList where eCode = @eCode)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @curEqpStatus char(1)
	select @thisLockMan = isnull(lockManID,''), @curEqpStatus = curEqpStatus
	from equipmentList where eCode = @eCode
	--����豸�༭����
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	--����豸״̬:
	if (@curEqpStatus not in ('1','3','8'))
	begin
		set @Ret = 3
		return
	end
	--����豸�Ƿ��б༭������������
	set @count = (select COUNT(*) from equipmentList
					where eCode = @eCode and ((isnull(lockManID,'') <> '' and isnull(lockManID,'') <> @delManID) 
													or lock4LongTime <> '0'))
	if (@count>0)
	begin
		set @Ret = 5
		return
	end
	
	--�ж�ָ���ĸ����Ƿ����
	set @count=(select count(*) from equipmentAnnex where eCode = @eCode and rowNum = @rowNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 4
		return
	end

	--ȡɾ���˵�������
	declare @delMan nvarchar(30)
	set @delMan = isnull((select cName from userInfo where jobNumber = @delManID),'')

	--��ȡԭ�������ƺͽ�
	declare @annexName nvarchar(20)	--��������
	declare @oldSumAmount numeric(12,2), @oldCTotalAmount numeric(12,2)			--�ϼƽ��/��ҽ��
	select @annexName = annexName, @oldSumAmount = totalAmount, @oldCTotalAmount = cTotalAmount 
	from equipmentAnnex 
	where eCode = @eCode and rowNum = @rowNum

	declare	@modiTime smalldatetime
	set @modiTime = getdate()
	begin tran
		--ɾ��������
		delete equipmentAnnex where eCode = @eCode and rowNum = @rowNum
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--�����豸��
		declare @curAnnexName nvarchar(20)
		set @curAnnexName = isnull((select annexName from equipmentList where eCode = @eCode),'')
		if @curAnnexName = @annexName
			set @curAnnexName = ''
		update equipmentList
		set annexName = @curAnnexName,
			annexAmount	= isnull(annexAmount,0) - @oldSumAmount,
			totalAmount = isnull(totalAmount,0) - @oldSumAmount,
			cTotalAmount = isnull(cTotalAmount,0) - @oldCTotalAmount
		where eCode = @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--�Ǽ��豸���������ڣ�
		insert eqpLifeCycle(eCode,eName, eModel, eFormat,
			clgCode, clgName, uCode, uName, keeper,
			annexAmount, price, totalAmount,
			changeDate, changeDesc,changeType,changeInvoiceID) 
		select eCode, eName, eModel, eFormat, 
			e.clgCode, c.clgName, e.uCode, u.uName, keeper,
			annexAmount, price, totalAmount,
			@modiTime, 'ɾ��������' + @annexName,
			'ɾ������',null
		from equipmentList e left join college c on e.clgCode = c.clgCode
				left join useUnit u on e.uCode = u.uCode and e.clgCode = u.clgCode
		where e.eCode = @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
	commit tran
	
	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delMan, @modiTime, 'ɾ������', 'ϵͳ�����û�' + @delMan + 
					'��Ҫ��ɾ�����豸['+ @eCode +']�ĸ���['+ @annexName +']��')
GO

select * from eqpCodeList where isUsed='Y' order by eCode
select top 100 eCode from eqpCodeList where isUsed='N'


drop PROCEDURE setEqpStatus
/*
	name:		setEqpStatus
	function:	8.�����豸״̬
				ע�⣺�ô洢���̼��༭��������һ����Ҫ������Ҳ���ͷű༭��
	input: 
				@eCode char(8),				--�豸���
				@curEqpStatus char(1),		--�豸״̬��

				@modiManID varchar(10) output,	--�޸��˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:���豸�����ڣ�
							2:���豸������������༭��
							3:���豸�б༭����������
							9:δ֪����
	author:		¬έ
	CreateDate:	2012-10-13
	UpdateDate: 
*/
create PROCEDURE setEqpStatus
	@eCode char(8),					--�豸���
	@curEqpStatus char(1),			--�豸״̬��
	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���ָ�����豸�Ƿ����
	declare @count as int
	set @count=(select count(*) from equipmentList where eCode = @eCode)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from equipmentList where eCode = @eCode
	--����豸�༭����
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--����豸�Ƿ��б༭������������
	set @count = (select COUNT(*) from equipmentList
					where eCode = @eCode and ((isnull(lockManID,'') <> '' and isnull(lockManID,'') <> @modiManID) 
													or lock4LongTime <> '0'))
	if (@count>0)
	begin
		set @Ret = 3
		return
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--ȡ״̬���Ӧ�����ƣ�
	declare @statusName nvarchar(10)
	set @statusName = (select objDesc from codeDictionary where classCode=2 and objCode=@curEqpStatus)

	declare @modiTime smalldatetime
	set @modiTime = getdate()
	begin tran
		update equipmentList
		set curEqpStatus = @curEqpStatus,
			--ά�����:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @modiTime
		where eCode = @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--�Ǽ��豸���������ڣ�
		insert eqpLifeCycle(eCode,eName, eModel, eFormat,
			clgCode, clgName, uCode, uName, keeper,
			annexAmount, price, totalAmount,
			changeDate, changeDesc,changeType,changeInvoiceID) 
		select eCode, eName, eModel, eFormat, 
			e.clgCode, c.clgName, e.uCode, u.uName, keeper,
			annexAmount, price, totalAmount,
			@modiTime, @modiManName +'���豸״̬��ΪΪ��' + @statusName,
			'�޸�״̬',''
		from equipmentList e left join college c on e.clgCode = c.clgCode
				left join useUnit u on e.uCode = u.uCode and e.clgCode = u.clgCode
		where e.eCode = @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
	commit tran
	
	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '�޸��豸״̬', '�û�' + @modiManName + 
					'���豸['+ @eCode +']��״̬�޸�Ϊ['+ @statusName +']��')
GO
--���ԣ�
select * from equipmentList
declare @Ret int
exec dbo.setEqpStatus '00000104', '3', '00000001', @Ret output
select @Ret
select * from eqpLifeCycle where eCode='00000104'
select * from userInfo


drop PROCEDURE shareEqp
/*
	name:		shareEqp
	function:	9.�����豸
				ע�⣺�ô洢���̼��༭��������һ����Ҫ������Ҳ���ͷű༭��
	input: 
				@eCode char(8),					--�豸���
				@isShare smallint,				--�Ƿ���0->������1->����

				@modiManID varchar(10) output,	--�޸��˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:���豸�����ڣ�
							2:���豸������������༭��
							3:���豸�б༭����������
							9:δ֪����
	author:		¬έ
	CreateDate:	2012-12-20
	UpdateDate: modi by lw 2013-1-22���ô洢�����빲���豸״̬�����
*/
create PROCEDURE shareEqp
	@eCode char(8),					--�豸���
	@isShare smallint,				--�Ƿ���0->������1->����
	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���ָ�����豸�Ƿ����
	declare @count as int
	set @count=(select count(*) from equipmentList where eCode = @eCode)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from equipmentList where eCode = @eCode
	--����豸�༭����
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--����豸�Ƿ��б༭������������
	set @count = (select COUNT(*) from equipmentList
					where eCode = @eCode and ((isnull(lockManID,'') <> '' and isnull(lockManID,'') <> @modiManID) 
													or lock4LongTime <> '0'))
	if (@count>0)
	begin
		set @Ret = 3
		return
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	declare @modiTime smalldatetime
	set @modiTime = getdate()
	begin tran
		update equipmentList
		set isShare = @isShare,
			--ά�����:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @modiTime
		where eCode = @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--�Ǽǹ����豸״̬��
		set @count = isnull((select count(*) from shareEqpStatus where eCode = @eCode),0)
		if (@count = 0 and @isShare=1)
		begin
			insert shareEqpStatus(eCode, isShare, modiManID, modiManName, modiTime)
			values(@eCode, @isShare, @modiManID, @modiManName, @modiTime)
		end
		else if (@count >0 and @isShare=1)
		begin
			update shareEqpStatus
			set isShare = 1, setoffDate=null
			where eCode = @eCode
		end
		else if (@count >0 and @isShare=0)
		begin
			update shareEqpStatus
			set isShare = 0, setoffDate=@modiTime
			where eCode = @eCode
		end
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
	
				
		--�Ǽ��豸���������ڣ�
		declare @changeDesc nvarchar(200),	@changeType nvarchar(10)--�䶯����/�䶯����
		if (@isShare = 1)
		begin
			set @changeDesc = @modiManName +'���豸��Ϊ����'
			set @changeType = '����'
		end
		else
		begin
			set @changeDesc = @modiManName +'���豸��Ϊ������'
			set @changeType = '������'
		end
		insert eqpLifeCycle(eCode,eName, eModel, eFormat,
			clgCode, clgName, uCode, uName, keeper,
			annexAmount, price, totalAmount,
			changeDate, changeDesc,changeType,changeInvoiceID) 
		select eCode, eName, eModel, eFormat, 
			e.clgCode, c.clgName, e.uCode, u.uName, keeper,
			annexAmount, price, totalAmount,
			@modiTime, @changeDesc,@changeType,''
		from equipmentList e left join college c on e.clgCode = c.clgCode
				left join useUnit u on e.uCode = u.uCode and e.clgCode = u.clgCode
		where e.eCode = @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
	commit tran
	
	set @Ret = 0
	--�Ǽǹ�����־��
	if (@isShare = 1)
		insert workNote(userID, userName, actionTime, actions, actionObject)
		values(@modiManID, @modiManName, @modiTime, '�����豸', '�û�' + @modiManName + 
						'���豸['+ @eCode +']����Ϊ����')
	else
		insert workNote(userID, userName, actionTime, actions, actionObject)
		values(@modiManID, @modiManName, @modiTime, '��ռ�豸', '�û�' + @modiManName + 
						'���豸['+ @eCode +']����Ϊ������')
GO


--5.�豸��������Ϣ��
--5.1������������Ϣ��
--5.2���;����豸��������Ϣ��
--5.3����Դ�豸��������Ϣ��

select changeApplyID, eCode, changeDesc, applyManID, applyManName, CONVERT(varchar(10),e.applyTime,120) applyTime, 
	isAgree, checkManID,checkManName, convert(varchar(10),e.checkTime,120) checkTime,
	acceptApplyID, eName, eModel, eFormat, unit, cCode, factory, convert(varchar(10),e.makeDate,120) makeDate,
	serialNumber, business, convert(varchar(10),buyDate,120) buyDate,
	annexName, annexCode, annexAmount,
	eTypeCode, eTypeName, aTypeCode,
	fCode, aCode, price, totalAmount, clgCode, uCode, keeperID, keeper, eqpLocate, notes,
	convert(varchar(10),e.acceptDate,120) acceptDate, oprManID, oprMan, acceptManID, acceptMan, 
	curEqpStatus, convert(varchar(10),e.scrapDate,120) scrapDate, scrapNum,
	obtainMode, purchaseMode
from changeEqpInfoApply e

select changeApplyID, eCode, changeDesc, applyManID, applyManName, CONVERT(varchar(10),e.applyTime,120) applyTime, isAgree, checkManID,checkManName, convert(varchar(10),e.checkTime,120) checkTime
from changeEqpInfoApply e
where eCode='12015242'
--6.�豸��Ϣ���������
drop TABLE changeEqpInfoApply
CREATE TABLE changeEqpInfoApply(
	changeApplyID varchar(12) not null,	--�������������뵥�ţ�ʹ�õ� 5 �ź��뷢��������
	eCode char(8) not null,				--�豸���

	changeDesc nvarchar(50) null,		--������Ҫ�������������Ϊ�գ�ϵͳ�Զ�ɨ���޸ĵ��ֶΣ�������������
	applyManID varchar(10) null,		--�����˹���
	applyManName nvarchar(30) null,		--����������
	applyTime smalldatetime default(getdate()),		--����ʱ��

	isAgree smallint not null default(0),	--�Ƿ�ͬ������0->����״̬��1->ͬ������->2��ͬ����
	checkManID varchar(10) null,		--����˹���
	checkManName nvarchar(30) null,		--���������
	checkTime smalldatetime null,		--���ʱ��
	
	acceptApplyID char(12) null,	--��ϵͳ�����ã���Ӧ�����յ���:�����������
	eName nvarchar(30) not null,	--�豸����
	eModel nvarchar(20) null,		--�豸�ͺ�
	eFormat nvarchar(30) null,		--�豸���
	unit nvarchar(10) null,			--������λ�������������
	cCode char(3) not null,			--���Ҵ���
	factory	nvarchar(20) null,		--��������
	makeDate smalldatetime null,	--��������
	serialNumber nvarchar(20) null,	--�������
	business nvarchar(20) null,		--���۵�λ
	buyDate smalldatetime null,		--��������
	annexName nvarchar(20) null,	--�����ñ�ϵͳ���������ƣ����������
	annexCode nvarchar(20) null,	--�����ñ�ϵͳ������������:�����������
	annexAmount	numeric(12, 2) null,--�����ñ�ϵͳ�����������Ǹ������ۣ����������

	eTypeCode char(8) not null,		--�����ţ��̣����4λ������ͬʱΪ��0��
	eTypeName nvarchar(30) not null,--��������������
	aTypeCode varchar(7) null,		--�����ñ�ϵͳ�������ţ��ƣ������ţ��ƣ�=f�������ţ�������ʹ��ӳ���
									--����GB/T 14885-2010�涨�������ӳ���7λmodi by lw 2012-2-23

	fCode char(2) not null,			--������Դ����
	aCode char(2) null,				--�����ñ�ϵͳ��ʹ�÷������
	price numeric(12, 2) null,		--���ۣ������������
	totalAmount numeric(12, 2) null,--�ܼۣ������������

	currency smallint null,			--��ϵͳ�����ֶΣ�����,�ɵ�3�Ŵ����ֵ䶨�壻�����������
	cPrice numeric(12, 2) null,		--��ϵͳ�����ֶΣ���ҼƼ�
	cTotalAmount numeric(12, 2) null,--��ϵͳ�����ֶΣ�����ܼ�, >0������+�����۸��޸����ͣ�Լ��С���㣻�����������
	
	clgCode char(3) not null,		--ѧԺ����:��ϵͳ��ʹ�ù̶�ֵ�������������
	uCode varchar(8) not null,		--ʹ�õ�λ���룻�����������
	keeperID varchar(10) null,		--�����˹��ţ��豸����Ա��,add by lw 2011-10-12�ƻ������豸��������Ϣ���������Ա�Ǽ��ˣ�������Ϣֻ���ɹ���Ա��д�������������
	keeper nvarchar(30) null,		--�����ˣ������������
	eqpLocate nvarchar(100) null,	--�豸���ڵ�ַ
	isShare smallint null,			--��ϵͳ�����ֶΣ��Ƿ���0->������1->�������������

	notes nvarchar(50) null,		--��ע
	acceptDate smalldatetime null,	--��ϵͳ�����ã��������ڣ������������
	oprManID varchar(10) null,		--�����˹��ţ������������
	oprMan nvarchar(30) null,		--�����ˣ������������
	acceptManID varchar(10) null,	--�����ñ�ϵͳ�������˹��ţ������������
	acceptMan nvarchar(30) null,	--�����ñ�ϵͳ�������ˣ������������
	curEqpStatus char(1) not null,	--���ݱ���Ĺ涨���¶����豸����״���뺬�壺���ֶ��ɵ�2�Ŵ����ֵ䶨�� modi by lw 2011-1-26
									--1�����ã�ָ����ʹ�õ������豸��
									--2�����ָ࣬����ʹ�ü�ֵ��δʹ�õ������豸��
									--3�����ޣ�ָ���޻���������������豸��
									--4�������ϣ�ָ�Ѿ�ʧȥʹ�ü�ֵ����δ������ʽ���������������豸��
									--5����ʧ��
									--6�����ϣ�
									--7��������
									--8��������ָ��ѧУ��׼��������ʹ�á�����������豸��
									--9����������״����������豸��
	scrapDate smalldatetime null,	--�������ڣ������������
	--add by lw 2011-05-16,��Ϊɸѡ�е���������Ƚ��鷳���������Ӹ��ֶ�
	--ע�⣺��Ӧ�޸��˱��ϵĴ洢���̣��ڴ���ԭʼ���ݵ�ʱ����Ҫ����
	scrapNum char(12) null,		--��Ӧ���豸���ϵ��ţ������������

	obtainMode int null,			--ȡ�÷�ʽ
	purchaseMode int null,			--�ɹ���֯��ʽ
	barCode varchar(30) null,		--��ϵͳ�����ã�һά����
 CONSTRAINT [PK_changeEqpInfoApply] PRIMARY KEY CLUSTERED 
(
	[changeApplyID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--������
CREATE NONCLUSTERED INDEX [IX_changeEqpInfoApply] ON [dbo].[changeEqpInfoApply] 
(
	[eCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[changeEqpInfoApply] WITH CHECK ADD CONSTRAINT [FK_changeEqpInfoApply_equipmentList] FOREIGN KEY([eCode])
REFERENCES [dbo].[equipmentList] ([eCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[changeEqpInfoApply] CHECK CONSTRAINT [FK_changeEqpInfoApply_equipmentList]
GO


select * from equipmentList where isnull(lockManID,'') <> '' or lock4LongTime<>0
drop PROCEDURE addChangeEqpInfoApply
/*
	name:		addChangeEqpInfoApply
	function:	10.����豸��Ϣ�������뵥
	input: 
				@eCode char(8),				--�豸���
				@changeDesc nvarchar(50),	--������Ҫ�������������Ϊ�գ�ϵͳ�Զ�ɨ���޸ĵ��ֶΣ�������������
				@applyManID varchar(10),	--�����˹���
				
				@eName nvarchar(30),		--�豸����
				@eModel nvarchar(20),		--�豸�ͺ�
				@eFormat nvarchar(30),		--�豸���
				@cCode char(3),				--���Ҵ���
				@factory nvarchar(20),		--��������
				@makeDate varchar(10),		--��������:���á�yyyy-MM-dd����ʽ
				@serialNumber nvarchar(20),	--�������
				@business nvarchar(20),		--���۵�λ
				@buyDate varchar(10),		--��������:���á�yyyy-MM-dd����ʽ

				@eTypeCode char(8),			--�����ţ��̣�
				@eTypeName nvarchar(30),	--��������������:Ϊ�˽����Զ��������Ҫ���ӵ��ֶΣ�add by lw 2010-11-30

				@fCode char(2),				--������Դ����
				--@aCode char(2),				--ʹ�÷������

				@eqpLocate nvarchar(100),	--�豸���ڵ�ַ

				@notes nvarchar(50),		--��ע
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1:���豸�����ڣ�2:���豸��û�н��������񣨳���������༭����
							3:û���޸��κ���Ϣ��9:δ֪����
				@changeApplyID varchar(12)	--�������������뵥�ţ�ʹ�õ� 5 �ź��뷢��������
	author:		¬έ
	CreateDate:	2012-12-20
	UpdateDate: 
*/
create PROCEDURE addChangeEqpInfoApply
	@eCode char(8),				--�豸���
	@changeDesc nvarchar(50),	--������Ҫ�������������Ϊ�գ�ϵͳ�Զ�ɨ���޸ĵ��ֶΣ�������������
	@applyManID varchar(10),	--�����˹���
	
	@eName nvarchar(30),		--�豸����
	@eModel nvarchar(20),		--�豸�ͺ�
	@eFormat nvarchar(30),		--�豸���
	@cCode char(3),				--���Ҵ���
	@factory nvarchar(20),		--��������
	@makeDate varchar(10),		--��������:���á�yyyy-MM-dd����ʽ
	@serialNumber nvarchar(20),	--�������
	@business nvarchar(20),		--���۵�λ
	@buyDate varchar(10),		--��������:���á�yyyy-MM-dd����ʽ

	@eTypeCode char(8),			--�����ţ��̣�
	@eTypeName nvarchar(30),	--��������������:Ϊ�˽����Զ��������Ҫ���ӵ��ֶΣ�add by lw 2010-11-30

	@fCode char(2),				--������Դ����
	--@aCode char(2),				--ʹ�÷������

	@eqpLocate nvarchar(100),	--�豸���ڵ�ַ

	@notes nvarchar(50),		--��ע

	@Ret		int output,
	@changeApplyID varchar(12) output	--�������������뵥�ţ�ʹ�õ� 5 �ź��뷢��������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�����豸�Ƿ���ڣ�
	declare @count int
	set @count = (select COUNT(*) from equipmentList where eCode = @eCode)
	if (@count=0)
	begin
		set @Ret = 1
		return
	end

	--����豸�ĳ��������ͱ༭����
	declare @locker varchar(10), @lock4LongTime char(1)
	select @locker=isnull(lockManID,''), @lock4LongTime=lock4LongTime from equipmentList where eCode =@eCode
	if ((@locker<>'' and @locker<>@applyManID) or @lock4LongTime<>'0')
	begin
		set @Ret = 2
		return
	end

	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 5, 1, @curNumber output
	set @changeApplyID = @curNumber

	--�����˵�������
	declare @applyManName nvarchar(30)	--����������
	set @applyManName = isnull((select userCName from activeUsers where userID = @applyManID),'')

	--ȡ������λ��
	declare @unit nvarchar(10)
	set @unit = '̨��'
	
	--�������������
	declare @desc nvarchar(50)
	set @desc = ''
	set @desc = @desc + (select case eName when @eName then '' else '���豸����' end from equipmentList where eCode=@eCode)
	set @desc = @desc + (select case eModel when @eModel then '' else '���ͺ�' end from equipmentList where eCode=@eCode)
	set @desc = @desc + (select case eFormat when @eFormat then '' else '�����' end from equipmentList where eCode=@eCode)
	set @desc = @desc + (select case cCode when @cCode then '' else '������' end from equipmentList where eCode=@eCode)
	set @desc = @desc + (select case factory when @factory then '' else '����������' end from equipmentList where eCode=@eCode)
	set @desc = @desc + (select case makeDate when @makeDate then '' else '����������' end from equipmentList where eCode=@eCode)
	set @desc = @desc + (select case serialNumber when @serialNumber then '' else '���������' end from equipmentList where eCode=@eCode)
	set @desc = @desc + (select case business when @business then '' else '�����۵�λ' end from equipmentList where eCode=@eCode)
	set @desc = @desc + (select case buyDate when @buyDate then '' else '����������' end from equipmentList where eCode=@eCode)
	set @desc = @desc + (select case eTypeCode + eTypeName when @eTypeCode+@eTypeName then '' else '���������' end 
							from equipmentList where eCode=@eCode)
	set @desc = @desc + (select case fCode when @fCode then '' else '��������Դ' end from equipmentList where eCode=@eCode)
	--set @desc = @desc + (select case aCode when @aCode then '' else '��ʹ�÷���' end from equipmentList where eCode=@eCode)
	set @desc = @desc + (select case eqpLocate when @eqpLocate then '' else '����ŵص�' end from equipmentList where eCode=@eCode)
	set @desc = @desc + (select case notes when @notes then '' else '����ע' end from equipmentList where eCode=@eCode)
	if (@desc='')
	begin
		set @Ret = 3
		return
	end
	if (isnull(@changeDesc,'')='')
	begin
		set @changeDesc = N'�����޸�'+RIGHT(@desc, LEN(@desc)-1)
	end

	declare @createTime smalldatetime
	set @createTime = getdate()
	begin tran
		insert changeEqpInfoApply(changeApplyID, eCode, changeDesc, applyManID, applyManName, applyTime,
			acceptApplyID, eName, eModel, eFormat, unit, cCode, factory, makeDate, serialNumber, 
			business, buyDate, annexName, annexCode, annexAmount, eTypeCode, eTypeName, 
			fCode, price, totalAmount, clgCode, uCode, keeperID, keeper, eqpLocate, notes,
			acceptDate, oprManID, oprMan, acceptManID, acceptMan, curEqpStatus, scrapDate, scrapNum, 
			obtainMode, purchaseMode)
		select @changeApplyID, eCode, @changeDesc, @applyManID, @applyManName, @createTime,
			acceptApplyID, @eName, @eModel, @eFormat, @unit, @cCode, @factory, @makeDate, @serialNumber, 
			@business, @buyDate, annexName, annexCode, annexAmount, @eTypeCode, @eTypeName, 
			@fCode, price, totalAmount, clgCode, uCode, keeperID, keeper, @eqpLocate, @notes,
			acceptDate, oprManID, oprMan, acceptManID, acceptMan, curEqpStatus, scrapDate, scrapNum, 
			obtainMode, purchaseMode
		from equipmentList
		where eCode = @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		
		--����豸����������
		update equipmentList
		set lock4LongTime = '5', lInvoiceNum=@changeApplyID
		where eCode =@eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
	commit tran
	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@applyManID, @applyManName, @createTime, '��������', '�û�' + @applyManName + 
					'�������豸['+@eCode+']��Ϣ�������뵥[' + @changeApplyID + ']��')
GO
--����:
select top 10 * from equipmentList
select * from activeUsers
declare @Ret		int
declare @changeApplyID varchar(12)
exec dbo.addChangeEqpInfoApply '00000001','','00200977','������ʾ��','*','19"','156','�����й�','2008-12-10','234234','��ɽ�����˵���',
	'2008-10-10','05010502','��ɫ�ն�','1','�人','��������', @Ret output, @changeApplyID output
select @Ret, @changeApplyID


select * from changeEqpInfoApply
select top 10 * from workNote order by actionTime desc
select * from equipmentList where eCode ='00000174'
use hustOA
declare @Ret int
exec dbo.delChangeEqpInfoApply '201210140005','00200977', @Ret output


select changeApplyID, eCode, changeDesc, applyManID, applyManName, 
	CONVERT(varchar(10),e.applyTime,120) applyTime, isAgree, checkManID,checkManName, 
	convert(varchar(10),e.checkTime,120) checkTime,acceptApplyID, eName, eModel, eFormat, 
	unit, cCode, factory, convert(varchar(10),e.makeDate,120) makeDate,serialNumber, business, 
	convert(varchar(10),buyDate,120) buyDate,annexName, annexCode, annexAmount,eTypeCode, eTypeName, 
	aTypeCode,fCode, aCode, price, totalAmount, clgCode, uCode, keeperID, keeper, eqpLocate, notes,
	convert(varchar(10),e.acceptDate,120) acceptDate, oprManID, oprMan, acceptManID, acceptMan, curEqpStatus, 
	convert(varchar(10),e.scrapDate,120) scrapDate, scrapNum,obtainMode, purchaseMode 
	from changeEqpInfoApply e where e.changeApplyID ='201210140001'

drop PROCEDURE delChangeEqpInfoApply
/*
	name:		delChangeEqpInfoApply
	function:	11.ɾ��ָ�����豸��Ϣ��������
	input: 
				@changeApplyID varchar(12),		--�������뵥��
				@delManID varchar(10),			--ɾ����
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ�����豸��Ϣ�����������ڣ�2�������������Ч������ɾ����9��δ֪����
	author:		¬έ
	CreateDate:	2012-10-13
	UpdateDate: 

*/
create PROCEDURE delChangeEqpInfoApply
	@changeApplyID varchar(12),		--�������뵥��
	@delManID varchar(10) output,	--ɾ����
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ�������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from changeEqpInfoApply where changeApplyID = @changeApplyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--��ȡ�豸��ţ�
	declare @eCode char(8)
	set @eCode = (select eCode from changeEqpInfoApply where changeApplyID = @changeApplyID)
	
	declare @isAgree smallint
	select @isAgree = isAgree
	from changeEqpInfoApply 
	where changeApplyID = @changeApplyID
	--��鵥��״̬:
	if (@isAgree <> 0)
	begin
		set @Ret = 2
		return
	end

	begin tran
		--�ͷų���������
		update equipmentList
		set lock4LongTime = '0', lInvoiceNum=''
		where eCode =@eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end

		delete changeEqpInfoApply where changeApplyID = @changeApplyID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
	commit tran	
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ���������뵥', '�û�' + @delManName
												+ 'ɾ�����豸['+@eCode+']��Ϣ������['+ @changeApplyID +']��')

GO


drop PROCEDURE activeChangeEqpInfoApply
/*
	name:		activeChangeEqpInfoApply
	function:	12.��Ч������ָ�����豸��Ϣ��������
	input: 
				@changeApplyID varchar(12),		--�������뵥��
				@isActive char(1),				--�Ƿ���Ч��"Y":��Ч��"N"������
				@activeManID varchar(10),		--�����
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ�����豸��Ϣ�����������ڣ�2�������������Ч��9��δ֪����
	author:		¬έ
	CreateDate:	2012-10-13
	UpdateDate: 

*/
create PROCEDURE activeChangeEqpInfoApply
	@changeApplyID varchar(12),		--�������뵥��
	@isActive char(1),				--�Ƿ���Ч��"Y":��Ч��"N"������
	@activeManID varchar(10),		--�����
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ�������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from changeEqpInfoApply where changeApplyID = @changeApplyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @isAgree smallint
	select @isAgree = isAgree
	from changeEqpInfoApply 
	where changeApplyID = @changeApplyID
	--��鵥��״̬:
	if (@isAgree <> 0)
	begin
		set @Ret = 2
		return
	end

	--��ȡ�豸��ţ�
	declare @eCode char(8)
	set @eCode = (select eCode from changeEqpInfoApply where changeApplyID = @changeApplyID)

	--ȡά���˵�������
	declare @activeManName nvarchar(30)
	set @activeManName = isnull((select userCName from activeUsers where userID = @activeManID),'')
	
	declare @modiTime smalldatetime
	set @modiTime = GETDATE()
	begin tran
		if (@isActive = 'Y')
		begin
			--�����豸�⣬���ͷų���������
			update equipmentList
			set eName = c.eName, eModel = c.eModel, eFormat = c.eFormat,
				cCode = c.cCode, factory = c.factory, makeDate = c.makeDate,
				serialNumber = c.serialNumber, business = c.business, buyDate = c.buyDate,
				eTypeCode = c.eTypeCode, eTypeName = c.eTypeName, aTypeCode = c.aTypeCode,
				fCode = c.fCode, aCode = c.aCode,
				eqpLocate = c.eqpLocate, notes = c.notes,
				lock4LongTime = '0', lInvoiceNum='',	--�ͷų�������
				--ά�����:
				modiManID = @activeManID, modiManName = @activeManName,	modiTime = @modiTime
			from equipmentList e inner join changeEqpInfoApply c on e.eCode=c.eCode
			where c.changeApplyID = @changeApplyID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end
			--�Ǽ��豸���������ڣ�
			insert eqpLifeCycle(eCode,eName, eModel, eFormat,
				clgCode, clgName, uCode, uName, keeper,
				annexAmount, price, totalAmount,
				changeDate, changeDesc,changeType,changeInvoiceID) 
			select e.eCode, e.eName, e.eModel, e.eFormat, 
				e.clgCode, c.clgName, e.uCode, u.uName, e.keeper,
				e.annexAmount, e.price, e.totalAmount,
				@modiTime, @activeManName +'��' + a.applyManName 
					+ '"' +a.changeDesc + '"�ĸ���������Ч��',
				'�޸��豸��Ϣ',@changeApplyID
			from equipmentList e left join changeEqpInfoApply a on e.eCode = a.eCode and a.changeApplyID = @changeApplyID
					left join college c on e.clgCode = c.clgCode
					left join useUnit u on e.uCode = u.uCode and e.clgCode = u.clgCode
			where e.eCode = @eCode
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    

			--�޸ĵ���״̬��
			update changeEqpInfoApply 
			set isAgree = 1, checkManID = @activeManID, checkManName = @activeManName,
				checkTime = @modiTime
			where changeApplyID = @changeApplyID
		end
		else
		begin
			--�޸ĵ���״̬��
			update changeEqpInfoApply 
			set isAgree = 2
			where changeApplyID = @changeApplyID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end

			--�ͷų���������
			update equipmentList
			set lock4LongTime = '0', lInvoiceNum=''
			where eCode =@eCode
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end
		end
	commit tran

	set @Ret = 0
	
	--�Ǽǹ�����־��
	if (@isActive = 'Y')
		insert workNote(userID, userName, actionTime, actions, actionObject)
		values(@activeManID, @activeManName, @modiTime, '��Ч�������뵥', '�û�' + @activeManName
													+ '��Ч���豸��Ϣ������['+ @changeApplyID +']��')
	else
		insert workNote(userID, userName, actionTime, actions, actionObject)
		values(@activeManID, @activeManName, @modiTime, '���ϸ������뵥', '�û�' + @activeManName
													+ '�������豸��Ϣ������['+ @changeApplyID +']��')

GO
--���ԣ�
select * from activeUsers
declare @Ret		int
exec dbo.activeChangeEqpInfoApply '201210190003', 'Y', '00200977', @Ret output
select @Ret

select * from changeEqpInfoApply
select * from workNote order by actionTime desc

--�豸��״��
select e.eTypeCode, e.eTypeName, e.aTypeCode,
	e.eCode, e.eName, e.eModel, e.eFormat,
	e.annexAmount,
	e.fCode, f.fName, e.aCode, a.aName, e.makeDate, e.buyDate, e.price, e.totalAmount, 
	e.clgCode, clg.clgName, e.uCode, u.uName, e.keeper, e.acceptDate, 
	curEqpStatus char(1) not null,	--���ݱ���Ĺ涨���¶����豸����״���뺬�壺���ֶ��ɵ�2�Ŵ����ֵ䶨�� modi by lw 2011-1-26
									--1�����ã�ָ����ʹ�õ������豸��
									--2�����ָ࣬����ʹ�ü�ֵ��δʹ�õ������豸��
									--3�����ޣ�ָ���޻���������������豸��
									--4�������ϣ�ָ�Ѿ�ʧȥʹ�ü�ֵ����δ������ʽ���������������豸��
									--5����ʧ��
									--6�����ϣ�
									--7��������
									--8��������ָ��ѧУ��׼��������ʹ�á�����������豸��
									--9����������״����������豸��
	case curEqpStatus when '1' then '����' when '2' then '����' when '3' then '����' when '4' then '������'
	when '5' then '��ʧ' when '6' then '����' when '7' then '����' when '8' then '����' when '9' then '����' else 'δ֪' end eqpStatus,
	case curEqpStatus when '6' then convert(char(10), e.scrapDate, 120) else '' end scrapDate
from equipmentList e 
left join fundSrc f on e.fCode = f.fCode
left join appDir a on e.aCode = a.aCode
left join college clg on e.clgCode = clg.clgCode
left join useUnit u on e.uCode = u.uCode

--�䶯����, �䶯����, ����Ժ������, ����Ժ��, ����ʹ�õ�λ����, ����ʹ�õ�λ, ������, �������, ����, �ܼ�
select 	changeDate,changeDesc,
	clgCode, clgName, uCode, uName, keeper,
	annexAmount, price, totalAmount
from eqpLifeCycle
order by rowNum

--�������ݣ�
insert eqpLifeCycle(eCode,
	eName, eModel, eFormat,
	clgCode, clgName, uCode, uName, keeper,
	annexAmount, price, totalAmount,
	changeDesc) 
select '01010102',
	eName, eModel, eFormat,
	e.clgCode, clg.clgName, e.uCode, u.uName, keeper,
	annexAmount, price, totalAmount,
	'�����豸�������ڱ�'
from equipmentList e left join college clg on e.clgCode = clg.clgCode
left join useUnit u on e.uCode = u.uName
where eCode = '01010102'

select * from eqpLifeCycle

drop PROCEDURE changeEqpKeeping
/*
	name:		changeEqpKeeping
	function:	14.�����豸����
	input: 
				@eCode char(8),					--�豸���
				@keeperID varchar(10),			--�±����˹���
				@eqpLocate nvarchar(100),		--���豸���ڵ�ַ

				--ά����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ�豸������ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 

				@updateTime smalldatetime output,--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1�����豸�����ڣ�2�����豸�������������༭��9��δ֪����
	author:		¬έ
	CreateDate:	2012-5-22
	UpdateDate: 
*/
create PROCEDURE changeEqpKeeping
	@eCode char(8),					--�豸���
	@keeperID varchar(10),			--�±����˹���
	@eqpLocate nvarchar(100),		--���豸���ڵ�ַ

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ�豸������ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ�����豸�Ƿ����
	declare @count as int
	set @count=(select count(*) from equipmentList where eCode= @eCode)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from equipmentList where eCode= @eCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--��ȡ������������
	declare @keeper nvarchar(30)
	set @keeper = isnull((select cName from userInfo where jobNumber = @keeperID),'')
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	set @updateTime = getdate()
	update equipmentList
	set keeperID = @keeperID, keeper = @keeper, eqpLocate = @eqpLocate,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where eCode= @eCode
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '�����豸����', '�û�' + @modiManName 
												+ '�������豸['+ @eCode +']�ı�����Ϊ��'+ @keeper +'��')
GO




select ROW_NUMBER() OVER(order by eCode asc) AS RowID, eCode,eName, totalAmount,oldKeeper,newKeeperID,newKeeper,'' 
from equipmentAllocationDetail d left join equipmentAllocation e on d.alcNum=e.alcNum  
where d.alcNum in('762') 
order by d.alcNum



--������ѯ��䣺
select a.rowNum,a.annexName, annexModel, annexFormat, a.cCode, c.cName, a.fCode, f.fName,
a.factory, convert(varchar(10),a.makeDate,120) as makeDate, a.business, convert(varchar(10),a.buyDate,120) as buyDate,
a.price, a.quantity, a.totalAmount, a.currency,cd.objDesc currencyName, a.cTotalAmount, a.oprMan
from equipmentAnnex a left join country c on a.cCode = c.cCode 
left join fundSrc f on a.fCode = f.fCode 
left join codeDictionary cd on a.currency = cd.objCode and cd.classCode = 3 
order by a.rowNum


--��ȡ�豸�������ң�
USE hustOA
select distinct top 10 tab.factory
from 
((select distinct factory from equipmentList)
union 
(select distinct factory from equipmentAnnex)) as tab
where tab.factory like '%IBM%' 
order by tab.factory


select * from equipmentList
where eCode='20130073'

update equipmentList
set notes = '���Իس�'+CHAR(9)+'����'
where eCode='20130073'

select '���Իس�'+CHAR(9)+'����'

