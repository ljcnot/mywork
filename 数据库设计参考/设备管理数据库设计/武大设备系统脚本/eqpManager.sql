use epdc211
/*
	����豸������Ϣϵͳ-�豸����
	author:		¬έ
	CreateDate:	2010-11-24
	UpdateDate: 
*/
--1.equipmentList���豸����
--�����豸Ҫ�����ֶΣ����������ṹ
--��ѯ�����༭���г�������豸
select e.eCode, e.eName, e.lockManID, u.cName lockMan, u.telNum, u.mobileNum, e.lock4LongTime,
	case e.lock4LongTime when 0 then '' 
	when 2 then '�豸������' when 3 then '�豸���ϵ�' 
	else '�豸��鵥' 
	end invoiceType, e.lInvoiceNum
from equipmentList e left join userInfo u on e.lockManID = u.jobNumber 
where isnull(e.lockManID,'')<>'' or e.lock4LongTime <> 0

update equipmentList
set unit = g.unit
from eqpAcceptInfo e left join GBT14885 g on e.aTypeCode = g.aTypeCode

update equipmentList
set obtainMode = 1,purchaseMode=2
select eCode,'����' as status 
use epdc211

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

select * from equipmentList

alter table equipmentList add lock4LongTime smallint	--����������add by lw 2012-7-28����Ϊ�豸���ʱ��Ҫ�����������Ըĳ����Σ�modi by lw 2013-5-27
ALTER TABLE [dbo].[equipmentList] ADD  DEFAULT (0) FOR [lock4LongTime]
update equipmentList
set lock4LongTime=0
where lock4LongTime is null

alter table equipmentList add bakLInvoiceNum varchar(30) null	--���ݵĳ�������������Ʊ�ݺţ���Ϊ�豸����ǵ���������������Ҫ���� add by lw 2013-5-27

drop table equipmentList
CREATE TABLE equipmentList(
	eCode char(8) not null,			--�������豸���,ʹ������ĺ��뷢��������
											--2λ��ݴ���+6λ��ˮ�ţ�����Ԥ������
											--ʹ���ֹ�������룬�Զ��������Ƿ��غ�
	acceptApplyID char(12) null,	--��Ӧ�����յ���
	eName nvarchar(30) not null,	--�豸����:��Ҫ�û�ȷ���Ƿ������ֵ��������������
	eModel nvarchar(20) not null,	--�豸�ͺ�
	eFormat nvarchar(30) not null,	--�豸��񣺸��ݽ�����Ҫ���ӳ��ֶγ���Ϊ20λ modi by lw 2011-1-26
	unit nvarchar(10) null,			--������λ��add by lw 2012-10-5�õ�λ��GBT14885���л�ȡ
	cCode char(3) not null,			--���Ҵ��룺��Ҫ�û�ȷ���Ƿ������ֵ��������������
	factory	nvarchar(20) null,		--��������
	makeDate smalldatetime null,	--�������ڣ��ڽ���������
	serialNumber nvarchar(20) null,	--�������
	business nvarchar(20) null,		--���۵�λ
	buyDate smalldatetime null,		--�������ڣ��������ֵ
	annexName nvarchar(20) null,	--��������	add by lw 2010-12-4�����յ�һ�»�
	annexCode nvarchar(20) null,	--����������
	annexAmount	numeric(12, 2) null,--���������Ǹ������ۣ��޸����ͣ�Լ��С���� modi by lw 2012-10-9

	eTypeCode char(8) not null,		--�����ţ��̣����4λ������ͬʱΪ��0��
	eTypeName nvarchar(30) not null,--��������������:Ϊ�˽����Զ��������Ҫ���ӵ��ֶΣ�add by lw 2010-11-30
	aTypeCode varchar(7) not null,	--�����ţ��ƣ������ţ��ƣ�=f�������ţ�������ʹ��ӳ���
									--����GB/T 14885-2010�涨�������ӳ���7λmodi by lw 2012-2-23

	fCode char(2) not null,			--������Դ����
	aCode char(2) null,				--ʹ�÷�����룺���������п�ֵ����Ҫ�û�ȷ���Ƿ������ֵ������������
	price numeric(12, 2) null,		--���ۣ�>0 �޸����ͣ�Լ��С���� modi by lw 2012-10-9
	totalAmount numeric(12, 2) null,--�ܼ�, >0������+�����۸��޸����ͣ�Լ��С���� modi by lw 2012-10-9
	clgCode char(3) not null,		--ѧԺ����
	uCode varchar(8) null,			--ʹ�õ�λ���룺���������п�ֵ����Ҫ�û�ȷ���Ƿ������ֵ������������.modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
	keeperID varchar(10) null,		--�����˹��ţ��豸����Ա��,add by lw 2011-10-12�ƻ������豸��������Ϣ���������Ա�Ǽ��ˣ�������Ϣֻ���ɹ���Ա��д
	keeper nvarchar(30) null,		--������
	eqpLocate nvarchar(100) null,	--�豸���ڵ�ַ:�豸���ڵ�add by lw 2012-5-22�����豸���칦��

	notes nvarchar(50) null,		--��ע
	acceptDate smalldatetime null,	--��������
	oprManID varchar(10) null,		--�����˹��� add by lw 2012-8-9
	oprMan nvarchar(30) null,		--������
	acceptManID varchar(10) null,	--�����˹���,add by lw 2011-2-19
	acceptMan nvarchar(30) null,	--������
	
	barCode varchar(30) null,		--һά���룺add by lw 2012-11-18
	--�ƻ���ֹ��
	--scrapFlag int default(0),		--�Ƿ񱨷�:0->��1->�ǣ��������뱨���ֶΣ�
									--���ֶθĳ���״�룺0-���ã�1-���ޣ�2-�����ϣ�3-�����뱨�� 4-�ѱ��ϣ�
									--ǰ2��״̬Ժϵ�豸����Ա����ֱ���޸ģ�״̬2�����뱨�ϵ����ã�״̬4�ɸ������ã�״̬3Ԥ����չ
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

	lock4LongTime smallint default(0),	--����������add by lw 2012-7-28����Ϊ�豸���ʱ��Ҫ�����������Ըĳ����Σ�modi by lw 2013-5-27
										--��Ҫ��Ϊ���ȹ��������豸����ֹ�������ڼ����豸����Ӹ����������򱨷�
											--'0'->δ����
											--'1'->�������,�޸ĳɵ�����"10"
											--'2'->��������
											--'3'->��������
											--'4'->���յ���������Ӹ������յ���������
													--��Ϊ��Ӹ�������ȡ����˲��޸����ɵ����յ�������Ҫ����
											--'5'->�豸��Ϣ������������ add by lw 2012-19-13
	lInvoiceNum varchar(30) null,		--��������������Ʊ�ݺ�
	bakLInvoiceNum varchar(30) null,	--���ݵĳ�������������Ʊ�ݺţ���Ϊ�豸����ǵ���������������Ҫ���� add by lw 2013-5-27
	
	obtainMode int null,				--ȡ�÷�ʽ���ɵ�11�Ŵ����ֵ䶨�壬add by lw 2012-10-1
	purchaseMode int null,				--�ɹ���֯��ʽ���ɵ�18�Ŵ����ֵ䶨�壬add by lw 2012-10-1
	
	ZCBH varchar(20) null,			--�ʲ����:���ʲ�����ϵͳ���ӵı�š�������ʡ��ϵͳ���ӵı�ţ�add by lw 2012-12-25

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
--2.equipmentAnnex���豸����������Ҫ�û�ȷ���豸�����Ƿ�������豸�ֿ����ã�����
drop table equipmentAnnex
CREATE TABLE equipmentAnnex(
	rowNum int IDENTITY(1,1) NOT NULL,	--���
	acceptApplyID char(12) null,		--��Ӧ�����յ���	--��Ϊ�������Զ������գ��������������ֶΣ�add by lw 2011-4-5
	eCode char(8) not null,				--������豸���
	annexName nvarchar(20) null,		--��������
	annexFormat nvarchar(20) null,		--�ͺŹ��

	--��Ϊ�������Զ������գ��������������ֶΣ�add by lw 2011-4-5
	cCode char(3) not null,				--���Ҵ��룺add by lw 2011-10-26
	fCode char(2) not null,				--������Դ���룺���������豸�ľ�����Դ��ͬ��������豸�ľ�����Դͳ�ƣ�����Ը����ľ�����Դ��
	factory	nvarchar(20) null,			--��������
	makeDate smalldatetime null,		--��������
	business nvarchar(20) null,			--���۵�λ
	buyDate smalldatetime null,			--��������
	-----------------------------------------------
	
	quantity int null,					--��������������ֶ�û�д��ڵı�Ҫ��
	price numeric(12, 2) null,			--���ۣ���������ֶ�Ҳû�д��ڵı�Ҫ �޸����ͣ�Լ��С���� modi by lw 2012-10-9
	totalAmount numeric(12, 2) null,	--�ܼۣ��޸����ͣ�Լ��С���� modi by lw 2012-10-9

	oprManID varchar(10) null,			--�����˹��� add by lw 2012-8-12
	oprMan nvarchar(30) null,			--������
	acceptMan nvarchar(30) null,		--������
	acceptManID varchar(10) null,		--�����˹���:add by lw 2011-10-26
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

--�������ݣ�
insert equipmentAnnex(acceptApplyID, eCode, annexName, annexFormat,
	cCode, fCode, factory, makeDate, business, buyDate,
	quantity, price, totalAmount,
	oprMan, acceptMan, acceptManID)
select acceptApplyID, eCode, annexName, annexFormat,
	isnull(cCode,''), fCode, factory, makeDate, business, buyDate,
	quantity, price, totalAmount,
	oprMan, acceptMan, acceptManID
from equipmentAnnex2

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
	eFormat nvarchar(20) not null,	--�豸���
	
	--��������Ϣ��
	clgCode char(3) not null,		--ѧԺ����
	clgName nvarchar(30) null,		--ѧԺ����
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
	invoiceType char(1) not null,		--��Ӧ����״̬��Ʊ�����ͣ�'1':���յ��ţ�'5':�豸��鵥��
	invoiceNum varchar(30) not null,	--��Ӧ����״̬��Ʊ�ݺţ����������յ��Ż��豸��鵥�ŵ�
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


drop PROCEDURE addAnnex
/*
	name:		addAnnex
	function:	0.��Ӹ�����������Ӧ�����յ�
				ע�⣺���洢�����Զ�������յ���˹��̣��������豸�嵥������������
					  ���洢����û�����������豸�ܼ۵Ľ���飬����UI�м�飡
	input: 
				@applyDate smalldatetime,	--��������
				@eCode char(8),				--�豸���
				@annexName nvarchar(20),	--��������
				@annexFormat nvarchar(20),	--�ͺŹ��
				@cCode char(3),				--���Ҵ���
				@fCode char(2),				--������Դ����
				@factory nvarchar(20),		--��������
				@makeDate smalldatetime,	--�������ڣ��ڽ���������
				@business nvarchar(20),		--���۵�λ
				@buyDate smalldatetime,		--��������
				@sumNumber int,				--����
				@annexAmount numeric(12,2),	--���������ۣ�
				@oprManID varchar(10),		--�����˹���,add by lw 2012-8-10

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
				@acceptID char(12) output	--���ɵ����յ��ţ�ʹ�õ� 1 �ź��뷢��������
	author:		¬έ
	CreateDate:	2011-10-26
	UpdateDate: modi by lw 2012-8-12�������˸ĳɹ��ţ����ӳ���������飬���Ӵ������ֶ�
				modi by lw 2012-10-27�����������۵��ֶ�����
*/
create PROCEDURE addAnnex
	@applyDate smalldatetime,	--��������
	@eCode char(8),				--�豸���
	@annexName nvarchar(20),	--��������
	@annexFormat nvarchar(20),	--�ͺŹ��
	@cCode char(3),				--���Ҵ���
	@fCode char(2),				--������Դ����
	@factory nvarchar(20),		--��������
	@makeDate smalldatetime,	--�������ڣ��ڽ���������
	@business nvarchar(20),		--���۵�λ
	@buyDate smalldatetime,		--��������
	@sumNumber int,				--����
	@annexAmount numeric(12,2),	--���������ۣ�
	@oprManID varchar(10),		--�����˹���,add by lw 2012-8-10
	@createManID varchar(10) output,	--�����˹��ţ�������Ӹ����ˣ������ˣ�
	@Ret		int output,
	@createTime smalldatetime output,
	@acceptID char(12) output	--���յ��ţ�ʹ�õ� 1 �ź��뷢��������
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
													or lock4LongTime <> 0))
	if (@count>0)
	begin
		set @Ret = 4
		return
	end
	
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 1, 1, @curNumber output
	set @acceptID = @curNumber

	--ȡ�����˵�������
	declare @oprMan nvarchar(30)
	set @oprMan = isnull((select cName from userInfo where jobNumber = @oprManID),'')

	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	--�����
	declare @sumAmount numeric(12,2)			--�ϼƽ��
	set @sumAmount = @annexAmount * @sumNumber
	
	--ȡ���豸��Ӧ�����յ��еû�ƿ�Ŀ��
	declare @accountCode varchar(9)	--��ƿ�Ŀ����
	set @accountCode = isnull((select accountCode from eqpAcceptInfo 
								where acceptApplyID in(select acceptApplyID from equipmentList where eCode = @eCode)
								), '');
	
	set @createTime = getdate()
	begin tran
		--��Ӹ�����
		insert equipmentAnnex(acceptApplyID, eCode, annexName, annexFormat, fCode,
						cCode, factory, makeDate, business, buyDate, 
						quantity, price, totalAmount,
						oprManID, oprMan, acceptMan, acceptManID)
		values(@acceptID, @eCode, @annexName, @annexFormat, @fCode,
						@cCode, @factory, @makeDate, @business, @buyDate, 
						@sumNumber, @annexAmount, @sumAmount,
						@oprManID, @oprMan, @createManName, @createManID)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--������յ���
		insert eqpAcceptInfo(acceptApplyType, acceptApplyID, acceptApplyStatus, applyDate, acceptDate,
								eTypeCode, eTypeName, aTypeCode, eName,
								eModel, eFormat, cCode, factory, makeDate, serialNumber, buyDate, business, fCode, aCode, 
								clgCode, clgName, uCode, uName, 
								keeperID, keeper, annexName, annexAmount, price, totalAmount, sumNumber, sumAmount,
								oprManID, oprMan, notes, acceptMan, acceptManID,
								startECode, endECode, accountCode,
								lockManID, modiManID, modiManName, modiTime,
								createManID, createManName, createTime) 
 		select 1, @acceptID, 2, @applyDate, @createTime,
								eTypeCode, eTypeName, aTypeCode, @annexName,
								@annexFormat, '*', @cCode, @factory, @makeDate, '', @buyDate, @business, @fCode, aCode, 
								e.clgCode, c.clgName, e.uCode, u.uName, 
								keeperID, keeper, '', 0, @annexAmount, @annexAmount, @sumNumber, @sumAmount,
								@oprManID, @oprMan, '�����豸['+ e.eName +'('+ @eCode +')]�ĸ�����', @createManName, @createManID,
								@eCode, @eCode, @accountCode,
								@createManID, @createManID, @createManName, @createTime,
								@createManID, @createManName, @createTime
		from equipmentList e left join college c on e.clgCode = c.clgCode
				left join useUnit u on e.uCode = u.uCode and e.clgCode = u.clgCode
		where e.eCode = @eCode

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
			totalAmount = isnull(totalAmount,0) + @sumAmount
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
			@createTime, '��Ӹ�����' + @annexName,
			'��Ӹ���',@acceptID
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
	values(@createManID, @createManName, @createTime, '��Ӹ������յ�', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ����豸['+ @eCode +']����˸���['+ @annexName +']������������Ӧ�����յ�[' + @acceptID + ']��')
GO

drop PROCEDURE updateAnnexApply
/*
	name:		updateAnnexApply
	function:	1.�޸��豸�������յ���������Ӧ���豸����
				ע�⣺�ô洢�����Զ�������յ���˹��̣��������豸�嵥������������
					  ���洢����û�����������豸�ܼ۵Ľ���飬����UI�м�飡
	input: 
				@acceptID char(12),			--���յ���
				@applyDate smalldatetime,	--��������
				@eCode char(8),				--�豸���
				@annexName nvarchar(20),	--��������
				@annexFormat nvarchar(20),	--�ͺŹ��
				@cCode char(3),				--���Ҵ���
				@fCode char(2),				--������Դ����
				@factory nvarchar(20),		--��������
				@makeDate smalldatetime,	--�������ڣ��ڽ���������
				@business nvarchar(20),		--���۵�λ
				@buyDate smalldatetime,		--��������
				@sumNumber int,				--����
				@annexAmount numeric(12,2),	--���������ۣ�
				@oprManID varchar(10),		--�����˹���,add by lw 2012-8-10

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
							4:ָ�����������뵥�����ڣ�
							5:Ҫ���µ����յ�Ϣ��������������
							6:�õ����Ѿ�ͨ����ˣ��������޸ģ�
							7:�ø������յ������豸�б༭����������
							9:δ֪����
				@modiTime smalldatetime output	--�޸�ʱ��
	author:		¬έ
	CreateDate:	2011-11-3
	UpdateDate: modi by lw 2012-8-12�������˸ĳɹ��ţ����ӳ����������
				modi by lw 2012-10-27�����������۵��ֶ�����
*/
create PROCEDURE updateAnnexApply
	@acceptID char(12),			--���յ���
	@applyDate smalldatetime,	--��������
	@eCode char(8),				--�豸���
	@annexName nvarchar(20),	--��������
	@annexFormat nvarchar(20),	--�ͺŹ��
	@cCode char(3),				--���Ҵ���
	@fCode char(2),				--������Դ����
	@factory nvarchar(20),		--��������
	@makeDate smalldatetime,	--�������ڣ��ڽ���������
	@business nvarchar(20),		--���۵�λ
	@buyDate smalldatetime,		--��������
	@sumNumber int,				--����
	@annexAmount numeric(12,2),	--���������ۣ�
	@oprManID varchar(10),		--�����˹���,add by lw 2012-8-10
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
													or lock4LongTime <> 0))
	if (@count>0)
	begin
		set @Ret = 7
		return
	end
	
	--�ж�ָ�����������뵥�Ƿ����
	set @count=(select count(*) from eqpAcceptInfo where acceptApplyID = @acceptID)	
	if (@count = 0)	--������
	begin
		set @Ret = 4
		return
	end

	declare @acceptApplyStatus int
	select @thisLockMan = isnull(lockManID,''), @acceptApplyStatus = acceptApplyStatus
	from eqpAcceptInfo 
	where acceptApplyID = @acceptID
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 5
		return
	end
	
	--��鵥��״̬:
	if (@acceptApplyStatus <> 0)
	begin
		set @Ret = 6
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
	set @sumAmount = @annexAmount * @sumNumber
	
	--ȡ���豸��Ӧ�����յ��еû�ƿ�Ŀ��
	declare @accountCode varchar(9)	--��ƿ�Ŀ����
	set @accountCode = isnull((select accountCode from eqpAcceptInfo 
								where acceptApplyID in(select acceptApplyID from equipmentList where eCode = @eCode)
								), '');
	
	set @modiTime = getdate()
	begin tran
		--��Ӹ�����
		insert equipmentAnnex(acceptApplyID, eCode, annexName, annexFormat, fCode,
						cCode, factory, makeDate, business, buyDate, 
						quantity, price, totalAmount,
						oprManID, oprMan, acceptMan, acceptManID)
		values(@acceptID, @eCode, @annexName, @annexFormat, @fCode,
						@cCode, @factory, @makeDate, @business, @buyDate, 
						@sumNumber, @annexAmount, @sumAmount,
						@oprManID, @oprMan, @modiManName, @modiManID)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--������յ���
		update eqpAcceptInfo
		set acceptApplyType = 1,
			acceptApplyStatus = 2, 
			applyDate = @applyDate,
			acceptDate = @modiTime,
			eTypeCode = e.eTypeCode, eTypeName = e.eTypeName, aTypeCode = e.aTypeCode, 
			eName = @annexName, eModel = @annexFormat,  eFormat = '*', 
			cCode = @cCode, 
			factory = @factory, makeDate = @makeDate, 
			serialNumber = '', 
			buyDate = @buyDate, business = @business, 
			fCode = @fCode, aCode = e.aCode, 
			clgCode = e.clgCode, clgName = c.clgName, 
			uCode = e.uCode, uName = u.uName, 
			keeperID = e.keeperID, keeper = e.keeper, 
			annexName = '', annexAmount = 0, price = @annexAmount, totalAmount = @annexAmount, sumNumber = @sumNumber, sumAmount = @sumAmount,
			oprManID = @oprManID, oprMan = @oprMan, notes = '�����豸['+ e.eName +'('+ @eCode +')]�ĸ�����', 
			acceptMan = @modiManName, acceptManID = @modiManID,
			startECode = @eCode, endECode = @eCode, accountCode = @accountCode,
			lockManID = @modiManID, modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
		from (select * from equipmentList where eCode = @eCode) e left join college c on e.clgCode = c.clgCode
				left join useUnit u on e.uCode = u.uCode and e.clgCode = u.clgCode
		where eqpAcceptInfo.acceptApplyID = @acceptID
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
			totalAmount = isnull(totalAmount,0) + @sumAmount
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
			'��Ӹ���',@acceptID
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
	values(@modiManID, @modiManName, @modiTime, '�޸ĸ������յ�', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ����豸['+ @eCode +']����˸���['+ @annexName +']������������Ӧ�����յ�[' + @acceptID + ']��')
GO


select * from eqpCodeList where isUsed='Y' order by eCode
select top 100 eCode from eqpCodeList where isUsed='N'


drop PROCEDURE setEqpStatus
/*
	name:		setEqpStatus
	function:	2.�����豸״̬
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
													or lock4LongTime <> 0))
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

--3.�����豸��ű������豸��ŵ�������뷢����ʹ�õı�
drop TABLE eqpCodeList
CREATE TABLE eqpCodeList(
	eCode char(8) not null,			--�豸���
	isUsed char(1) default('N')		--�Ƿ��Ѿ�ʹ��
 CONSTRAINT [PK_eqpCodeList] PRIMARY KEY CLUSTERED 
(
	[eCode] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_eqpCodeList] ON [dbo].[eqpCodeList]
(
	[isUsed] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

select * from eqpCodeList
drop PROCEDURE makeEqpCodes
/*
	name:		makeEqpCodes
	function:	1.���ɿ����豸��ű�
	input: 
				@year char(4),				--���
				@startNum varchar(6),		--��ʼ���
				@length smallint,			--����
				@makeManID varchar(10),		--�����豸��ŵ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1����ǰ�����û���ʹ�����յ���2��û���㹻�ĺ������ɣ�9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-24
	UpdateDate: 
*/
create PROCEDURE makeEqpCodes
	@year char(4),				--���
	@startNum varchar(6),		--��ʼ���
	@length smallint,			--����
	@makeManID varchar(10),		--�����豸��ŵ��˵Ĺ���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ͷŲ������˳����û����������յ���
	update eqpAcceptInfo
	set lockManID = ''
	where lockManID not in (select userID from activeUsers)
	
	--������յ��Ƿ������ڱ༭
	declare @count int
	set @count = (select count(*) from eqpAcceptInfo where isnull(lockManID,'') <> '')
	if (@count > 0)
	begin
		set @Ret = 1
		return
	end
	declare @oldLength int
	set @oldLength = @length
	declare @shortYear varchar(2)
	set @shortYear = right(@year,2)
	--Ϊ�ӿ��㷨��������ռ�ú����
	declare @usedCodes table(eCode char(8))
	insert @usedCodes(eCode)
	select eCode from equipmentList where left(eCode,2) = @shortYear
	
	begin tran
		--��պ����
		truncate table eqpCodeList
		--����ȫ�����յ�
		update eqpAcceptInfo
		set lockManID = @makeManID

		--���ɺ���
		if (@startNum is null)
			set @startNum = '1'
		declare @intStartNum int
		set @intStartNum = cast(@startNum as int)
		declare @curCode as varchar(8)
		WHILE @length > 0
		begin
			set @curCode = @shortYear + right('00000' + ltrim(convert(varchar(6),@intStartNum)), 6) 
--print @curCode
			--���ú����Ƿ�ʹ�ù���
			set @count = (select count(*) from @usedCodes where eCode = @curCode)
			if (@count = 0)
			begin
				set @length = @length - 1
				insert eqpCodeList(eCode) values(@curCode)
			end
			set @intStartNum = @intStartNum + 1
			if (@intStartNum > 999999)	--�������
			begin
				set @Ret = 2
				update eqpAcceptInfo set lockManID = ''
				commit tran
				return
			end
		end
		update eqpAcceptInfo set lockManID = ''
	commit tran
	set @Ret = 0
	
	--ȡ�����˵�������
	declare @makeManName nvarchar(30)
	set @makeManName = isnull((select userCName from activeUsers where userID = @makeManID),'')
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@makeManID, @makeManName, getdate(), '�����豸���', 'ϵͳ�����û�' + @makeManName
												+ '��Ҫ�󴴽���['+ @year+'��]���豸���['+ cast(@oldLength as varchar(6)) +']����')
	
GO

--���ԣ�
select * from eqpAcceptInfo where isnull(lockManID,'') <> ''
update eqpAcceptInfo 
set lockManID = ''
where isnull(lockManID,'') <> ''

truncate table eqpCodeList
declare @ret int
exec dbo.makeEqpCodes '2015', null, 1000, '0000000000', @ret output
select @ret
select * from eqpCodeList
select * from workNote order by actionTime desc

delete worknote

drop PROCEDURE checkEqpCodes
/*
	name:		checkEqpCodes
	function:	2.��������Ƿ����
	input: 
				@startNum varchar(8),		--��ʼ���
				@length smallint,			--����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:���ã�-1������ʹ�ã�9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-24
	UpdateDate: 
*/
create PROCEDURE checkEqpCodes
	@startNum varchar(8),		--��ʼ���
	@length smallint,			--����
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--���ɽ�������
	declare @intEndNum int
	set @intEndNum = cast(right(@startNum,6) as int) + @length - 1
	declare @endCode as varchar(8)
	set @endCode = left(@startNum,2) + right('00000' + ltrim(convert(varchar(6),@intEndNum)), 6)
	
	--���ú�����еĿ��ú����Ƿ��㹻��
	declare @count int
	set @count = (select count(*) from eqpCodeList where eCode >= @startNum and eCode <= @endCode and isUsed = 'N')
	if (@count = @length)
		set @Ret = 0
	else
		set @Ret = -1
GO
--���ԣ�
select * from eqpCodeList
declare @ret int
exec dbo.checkEqpCodes '12000189', 10, @ret output
select @ret



drop PROCEDURE autoGetCodes
/*
	name:		autoGetCodes
	function:	3.�Զ���ȡ���ʵĺ����
	input: 
				@length smallint,			--����
	output: 
				@Ret		int output,		--�����ɹ���ʶ
							0:���ã�1��û�к��ʵĺ���Σ�9��δ֪����
				@startNum varchar(8) output,--��ʼ���
				@endNum varchar(8) output	--�������
	author:		¬έ
	CreateDate:	2010-11-24
	UpdateDate: 2011-1-23 modi by lw ������������
*/
create PROCEDURE autoGetCodes
	@length smallint,			--����
	@Ret	int output,			--�����ɹ���ʶ
	@startNum varchar(8) output,--��ʼ���
	@endNum varchar(8) output	--�������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @startNum = ''
	
	declare @eCode char(8), @execRet int
	declare tar cursor for
	select eCode from eqpCodeList where isUsed = 'N'	
	OPEN tar
	FETCH NEXT FROM tar INTO @eCode
	WHILE @@FETCH_STATUS = 0
	begin
		exec dbo.checkEqpCodes @eCode, @length, @execRet output
		if (@execRet = 0)
		begin
			set @startNum = @eCode
			break
		end
		FETCH NEXT FROM tar INTO @eCode
	end
	CLOSE tar
	DEALLOCATE tar
	
	if (@startNum <> '')
	begin
		--���ɽ�������
		declare @intEndNum int
		set @intEndNum = cast(right(@startNum,6) as int) + @length - 1
		set @endNum = left(@startNum,2) + right('00000' + ltrim(convert(varchar(6),@intEndNum)), 6)
		
		set @Ret = 0
	end
	else
		set @Ret = 1
GO
--���ԣ�
select * from eqpCodeList
declare @ret int, @startNum varchar(8), @endNum varchar(8)
exec dbo.autoGetCodes 20, @ret output, @startNum output, @endNum output
select @ret, @startNum, @endNum


drop PROCEDURE checkECodesEnable
/*
	name:		checkECodesEnable
	function:	4.����ָ���ĺ��뿪ʼ�Ƿ���ָ�����ȵ������Ŀ��ú����
	input: 
				@startNum varchar(8),		--��ʼ���
				@length smallint,			--����
	output: 
				@Ret		int output,		--�����ɹ���ʶ
							0:���ã�1��û�к��ʵĺ���Σ�9��δ֪����
				@endNum varchar(8) output	--�������
	author:		¬έ
	CreateDate:	2011-1-23
	UpdateDate: 
*/
create PROCEDURE checkECodesEnable
	@startNum varchar(8),		--��ʼ���
	@length smallint,			--����
	@Ret	int output,			--�����ɹ���ʶ
	@endNum varchar(8) output	--�������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	declare @execRet int
	exec dbo.checkEqpCodes @startNum, @length, @execRet output
	if (@execRet = 0)
	begin
		--���ɽ�������
		declare @intEndNum int
		set @intEndNum = cast(right(@startNum,6) as int) + @length - 1
		set @endNum = left(@startNum,2) + right('00000' + ltrim(convert(varchar(6),@intEndNum)), 6)
		
		set @Ret = 0
	end
	else
		set @Ret = 1
GO
--���ԣ�
select * from eqpCodeList
declare @ret int, @startNum varchar(8), @endNum varchar(8)
exec dbo.checkECodesEnable '10000674', 3, @ret output, @endNum output
select @ret, @endNum



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
	
	acceptApplyID char(12) null,	--��Ӧ�����յ���:�����������
	eName nvarchar(30) not null,	--�豸����
	eModel nvarchar(20) not null,	--�豸�ͺ�
	eFormat nvarchar(30) not null,	--�豸���
	unit nvarchar(10) null,			--������λ�������������
	cCode char(3) not null,			--���Ҵ���
	factory	nvarchar(20) null,		--��������
	makeDate smalldatetime null,	--��������
	serialNumber nvarchar(20) null,	--�������
	business nvarchar(20) null,		--���۵�λ
	buyDate smalldatetime null,		--��������
	annexName nvarchar(20) null,	--�������ƣ����������
	annexCode nvarchar(20) null,	--����������:�����������
	annexAmount	numeric(12, 2) null,--���������Ǹ������ۣ����������

	eTypeCode char(8) not null,		--�����ţ��̣����4λ������ͬʱΪ��0��
	eTypeName nvarchar(30) not null,--��������������
	aTypeCode varchar(7) not null,	--�����ţ��ƣ������ţ��ƣ�=f�������ţ�������ʹ��ӳ���
									--����GB/T 14885-2010�涨�������ӳ���7λmodi by lw 2012-2-23

	fCode char(2) not null,			--������Դ����
	aCode char(2) null,				--ʹ�÷������
	price numeric(12, 2) null,		--���ۣ������������
	totalAmount numeric(12, 2) null,--�ܼۣ������������
	clgCode char(3) not null,		--ѧԺ���룺�����������
	uCode varchar(8) null,			--ʹ�õ�λ���룺�����������
	keeperID varchar(10) null,		--�����˹��ţ��豸����Ա���������������
	keeper nvarchar(30) null,		--�����ˣ������������
	eqpLocate nvarchar(100) null,	--�豸���ڵ�ַ

	notes nvarchar(50) null,		--��ע
	acceptDate smalldatetime null,	--�������ڣ������������
	oprManID varchar(10) null,		--�����˹��ţ������������
	oprMan nvarchar(30) null,		--�����ˣ������������
	acceptManID varchar(10) null,	--�����˹��ţ������������
	acceptMan nvarchar(30) null,	--�����ˣ������������
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

	obtainMode int null,				--ȡ�÷�ʽ
	purchaseMode int null,				--�ɹ���֯��ʽ
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
				@eFormat nvarchar(20),		--�豸���
				@cCode char(3),				--���Ҵ���
				@factory nvarchar(20),		--��������
				@makeDate varchar(10),		--��������:���á�yyyy-MM-dd����ʽ
				@serialNumber nvarchar(20),	--�������
				@business nvarchar(20),		--���۵�λ
				@buyDate varchar(10),		--��������:���á�yyyy-MM-dd����ʽ

				@eTypeCode char(8),			--�����ţ��̣�
				@eTypeName nvarchar(30),	--��������������:Ϊ�˽����Զ��������Ҫ���ӵ��ֶΣ�add by lw 2010-11-30

				@fCode char(2),				--������Դ����
				@aCode char(2),				--ʹ�÷������

				@eqpLocate nvarchar(100),	--�豸���ڵ�ַ

				@notes nvarchar(50),		--��ע
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1:���豸�����ڣ�2:���豸�������˱༭��������δ��ɵĳ�����
							3:û���޸��κ���Ϣ��9:δ֪����
				@changeApplyID varchar(12)	--�������������뵥�ţ�ʹ�õ� 5 �ź��뷢��������
	author:		¬έ
	CreateDate:	2012-10-13
	UpdateDate: 
*/
create PROCEDURE addChangeEqpInfoApply
	@eCode char(8),				--�豸���
	@changeDesc nvarchar(50),	--������Ҫ�������������Ϊ�գ�ϵͳ�Զ�ɨ���޸ĵ��ֶΣ�������������
	@applyManID varchar(10),	--�����˹���
	
	@eName nvarchar(30),		--�豸����
	@eModel nvarchar(20),		--�豸�ͺ�
	@eFormat nvarchar(20),		--�豸���
	@cCode char(3),				--���Ҵ���
	@factory nvarchar(20),		--��������
	@makeDate varchar(10),		--��������:���á�yyyy-MM-dd����ʽ
	@serialNumber nvarchar(20),	--�������
	@business nvarchar(20),		--���۵�λ
	@buyDate varchar(10),		--��������:���á�yyyy-MM-dd����ʽ

	@eTypeCode char(8),			--�����ţ��̣�
	@eTypeName nvarchar(30),	--��������������:Ϊ�˽����Զ��������Ҫ���ӵ��ֶΣ�add by lw 2010-11-30

	@fCode char(2),				--������Դ����
	@aCode char(2),				--ʹ�÷������

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
	if ((@locker<>'' and @locker<>@applyManID) or @lock4LongTime<>0)
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

	--ȡ���������룺
	declare @aTypeCode varchar(7)		--�����ţ��ƣ�
	set @aTypeCode = (select aTypeCode from typeCodes where eTypeCode=@eTypeCode and eTypeName=@eTypeName)

	--ȡ������λ��
	declare @unit nvarchar(10)
	set @unit = ISNULL((select unit from GBT14885 where aTypeCode = @aTypeCode),'')
	
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
	set @desc = @desc + (select case aCode when @aCode then '' else '��ʹ�÷���' end from equipmentList where eCode=@eCode)
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
			business, buyDate, annexName, annexCode, annexAmount, eTypeCode, eTypeName, aTypeCode,
			fCode, aCode, price, totalAmount, clgCode, uCode, keeperID, keeper, eqpLocate, notes,
			acceptDate, oprManID, oprMan, acceptManID, acceptMan, curEqpStatus, scrapDate, scrapNum, 
			obtainMode, purchaseMode)
		select @changeApplyID, eCode, @changeDesc, @applyManID, @applyManName, @createTime,
			acceptApplyID, @eName, @eModel, @eFormat, @unit, @cCode, @factory, @makeDate, @serialNumber, 
			@business, @buyDate, annexName, annexCode, annexAmount, @eTypeCode, @eTypeName, @aTypeCode,
			@fCode, @aCode, price, totalAmount, clgCode, uCode, keeperID, keeper, @eqpLocate, @notes,
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
		set lock4LongTime = 5, lInvoiceNum=@changeApplyID
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
					'�������豸��Ϣ�������뵥[' + @changeApplyID + ']��')
GO
--����:
select top 10 * from equipmentList
select * from activeUsers
declare @Ret		int
declare @changeApplyID varchar(12)
exec dbo.addChangeEqpInfoApply '00000174','','00200977','������ʾ��','*','19"','156','�����й�','2008-12-10','234234','��ɽ�����˵���',
	'2008-10-10','05010502','��ɫ�ն�','1','3','�人','��������', @Ret output, @changeApplyID output
select @Ret, @changeApplyID

select * from changeEqpInfoApply
select top 10 * from workNote order by actionTime desc
select * from equipmentList where eCode ='00000174'
use epdc211
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
							0:�ɹ���1��ָ�����豸��Ϣ�����������ڣ�2�������������Ч������ɾ����
							5���ø���������豸������飬
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-10-13
	UpdateDate: modi by lw 2013-5-27���ӳ�����������
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

	--���õ����漰���豸�Ƿ��б༭������������
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from changeEqpInfoApply where changeApplyID = @changeApplyID)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> 0 and not(lock4LongTime = 5 and lInvoiceNum=@changeApplyID))))
	if (@count>0)
	begin
		set @Ret = 5
		return
	end

	begin tran
		--�ͷų���������
		update equipmentList
		set lock4LongTime = 0, lInvoiceNum=''
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
							0:�ɹ���1��ָ�����豸��Ϣ�����������ڣ�2�������������Ч��
							5���ø���������豸������飬
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-10-13
	UpdateDate: modi by lw 2013-5-27���ӳ�����������
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

	--���õ����漰���豸�Ƿ��б༭������������
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from changeEqpInfoApply where changeApplyID = @changeApplyID)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> 0 and not(lock4LongTime = 5 and lInvoiceNum=@changeApplyID))))
	if (@count>0)
	begin
		set @Ret = 5
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
				lock4LongTime = 0, lInvoiceNum='',	--�ͷų�������
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
			set lock4LongTime = 0, lInvoiceNum=''
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



drop PROCEDURE queryEqpLocMan
/*
	name:		queryEqpLocMan
	function:	11.��ѯָ���豸�Ƿ��������ڱ༭
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
	function:	12.�����豸�༭������༭��ͻ
	input: 
				@eCode char(8),					--�豸���
				@lockManID varchar(10) output,	--�����ˣ������ǰ�豸���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�������豸�����ڣ�2:Ҫ�������豸���ڱ����˱༭��
							5���������༭���豸�г���������
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-5-22
	UpdateDate: modi by lw 2013-5-27���ӳ�����������
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

	--�����豸�Ƿ��б༭������������
	set @count = (select COUNT(*) from equipmentList
					where eCode = @eCode and lock4LongTime <> 0)
	if (@count>0)
	begin
		set @Ret = 5
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
	function:	13.�ͷ��豸�༭��
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
							0:�ɹ���1�����豸�����ڣ�2�����豸�������������༭��
							5�����豸�г���������
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-5-22
	UpdateDate: modi by lw 2013-5-27���ӳ�����������
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
	
	--�����豸�Ƿ��б༭������������
	set @count = (select COUNT(*) from equipmentList
					where eCode = @eCode and lock4LongTime <> 0)
	if (@count>0)
	begin
		set @Ret = 5
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


select * from equipmentAnnex



