use epdc211
--�������̶��ʲ���������GB/T 14885-1994����
DROP TABLE GBT14885
CREATE TABLE [dbo].[GBT14885](
	RwID int NOT NULL,						--���
	kind varchar(2) not null,				--������
	kindName nvarchar(20) not null,			--��������
	classCode varchar(1) null,				--������
	subClassCode varchar(1) null,			--������
	itemCode varchar(2) null,				--С����
	
	aTypeCode varchar(7) NOT NULL,			--��׼����
	aTypeName nvarchar(60) NOT NULL,		--��׼����
	unit nvarchar(10) NULL,					--������λ
	QTYUnit varchar(60) NULL DEFAULT (''),	--������λ
	PrntCode varchar(60) NULL DEFAULT (''),	--��״�ṹ��
	[Level] int NULL DEFAULT ((-1)),		--�ṹ��Σ���ΪҶ�ӽڵ��ʱ��Ϊ������abs(Level)Ϊ��δ���
	ShrtNm varchar(25) NULL DEFAULT (''),
	[Desc] varchar(255) NULL DEFAULT(''),	--����

	inputCode varchar(5) null,				--������
	isOff char(1) null default('0') ,		--ͣ�ñ�ʶ:��0���������ã���1������ͣ��
	offDate smalldatetime null,				--ͣ������

	CreateDate smalldatetime NULL,			--����ʱ��
	ModifyDate smalldatetime NULL,			--�޸�ʱ��
	Creater nvarchar(30) NULL DEFAULT(''),--������
	RwVrsn int NULL DEFAULT ((0)),			--�汾
PRIMARY KEY NONCLUSTERED 
(
	[RwID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

	
insert GBT14885
SELECT Rwid, g.kind, g.kindName, g.classCode, g.subClassCode, g.itemCode, 
	A.StdCode, a.StdName, a.JLDW, a.QTYUnit, a.PrntCode, a.Level, a.ShrtNm, a.Description, UPPER(dbo.getChinaPYCode(a.StdName)), '0', null, 
	GETDATE(), a.ModifyDate, 'lw', a.RwVrsn
FROM [WHDX_AID].[dbo].[JC_AssetCatalog] a left join  e.dbo.GBT14885 g on a.StdCode = g.aTypeCode
order by StdCode


select * from GBT14885 where classCode is null
select clgCode,clgName,dCode,dName from collegeCode
select * from collegeCode
--����������λ����ת����
drop TABLE [dbo].[collegeCode]
CREATE TABLE [dbo].[collegeCode](
	rowNum int IDENTITY(1,1) NOT NULL,	--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к�
	clgCode char(3) not null,			--������Ժ������
	clgName nvarchar(30) not null,		--Ժ������	
	dCode varchar(7) null,				--����������ϵͳԺ������
	dName nvarchar(30) null,			--����������ϵͳԺ������
	
	remark nvarchar(50) null,			--��ע

	--�����ˣ�
	createManID varchar(10) null,		--�����˹���
	createManName varchar(30) null,		--����������
	createTime smalldatetime null,		--����ʱ��
	
	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName varchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
PRIMARY KEY NONCLUSTERED 
(
	[clgCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

insert collegeCode(clgCode, clgName, dCode,dName)
select rtrim(clgCode), rtrim(clgName), rtrim(dCode), rtrim(dName) from c

select clgCode, clgName, dCode,dName from WHGXYepdc211.dbo.collegeCode

insert collegeCode(clgCode,clgName, dCode,dName)
select clgCode,clgName, dCode,dName
from c

--�������������Ĺ����
drop table CZreportCenter
CREATE TABLE [dbo].[CZreportCenter](
	reportNum varchar(12) not null,		--������������,�ɵ�800�ź��뷢��������
	theTitle nvarchar(100) null,		--�������
	theYear varchar(4) null,			--ͳ�����
	totalEndDate smalldatetime null,	--ͳ���ʲ����ս�������
	--�ʲ����豸�����������Ϣ��
	LandValue numeric(19,2) not null,		--1.���غϼƽ��
	BuildingValue numeric(19,2) not null,	--2.���ݹ�����ϼƽ��
	generalEqpValue numeric(19,2) not null,	--3.ͨ���豸�ϼƽ��
	specialEqpValue numeric(19,2) not null,	--4.ר���豸�ϼƽ��
	EqpCarValue numeric(19,2) not null,		--5.��ͨ�����豸�ϼƽ��
	EqpElectricalValue numeric(19,2) not null,--6.�����豸�ϼƽ��
	EqpCommunicateValue numeric(19,2) not null,--7.���Ӳ�Ʒ��ͨ���豸�ϼƽ��
	EqpInstrumentValue numeric(19,2) not null,--8.�����Ǳ����ߺϼƽ��
	EqpSportValue numeric(19,2) not null,	--9.���������豸�ϼƽ��
	EqpCulturalValue numeric(19,2) not null,--10.ͼ�����Ｐ����Ʒ�ϼƽ��
	EqpFurnitureValue numeric(19,2) not null,--11.�Ҿ��þ߼�������ϼƽ��
	intangibleValue numeric(19,2) not null,	--12.�����ʲ��ϼƽ��
	
	makeUnit nvarchar(50) null,			--�Ʊ�λ
	makeDate smalldatetime null,		--�Ʊ�����

	makerID varchar(10) null,			--�Ʊ��˹���
	maker varchar(30) null,				--�Ʊ���
 CONSTRAINT [PK_CZreportCenter] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--1.���أ�Land
drop TABLE [dbo].[Land]
CREATE TABLE [dbo].[Land](
	reportNum varchar(12) not null,		--����/�����������
	QingCXTZCBH	varchar(12) not null,	--�������ʲ����
	BillDate smalldatetime not null,	--��������
	CatalogID varchar(7) not null,		--�ʲ��������
	StdName nvarchar(30) not null,		--�ʲ�����
	JiLDWCZB nvarchar(10) not null,		--������λ
	TuDMJ numeric(19,2) not null,		--�������
	TuDZZMMJ numeric(19,2) not null,	--����֤�������
	QuanSZM	nvarchar(30) null,			--Ȩ��֤��
	QuanSZH	nvarchar(30) null,			--Ȩ��֤��
	ChanQXSName	nvarchar(10) null,		--��Ȩ��ʽ:�в�Ȩ���޲�Ȩ
	DiH	nvarchar(150) null,				--�غ�
	QuanSXZName	nvarchar(10) null,		--Ȩ������:���У�����
	FaZSJ smalldatetime null,			--��֤ʱ��
	KuaiJPZH varchar(12) null,			--���ƾ֤��
	ZuoLWZ nvarchar(150) not null,		--����λ��
	JiaZXSName nvarchar(10) not null,	--��ֵ����:ԭֵ���ݹ�ֵ������ֵ���޼�ֵ
	OrgnValue numeric(19,2)	not null,	--��ֵ:��ֵ���Ͳ���"�޼�ֵ"ʱ����,��"�����Բ���"��"��ҵ����"��"�����ʽ�"�ϼ����
	JunJ numeric(19,2) null,			--����:���ۣ���ֵ/�������
	CaiZXJFLY numeric(19,2) null,		--�����Բ���
	ShiYSR numeric(19,2) null,			--��ҵ����
	QiZYSWSR numeric(19,2) null,		--��ҵ���룺Ԥ��������
	QiTJFLY numeric(19,2) null,			--�����ʽ�
	QiZCZXJYZJ numeric(19,2) null,		--�����ʽ𣺲����Խ����ʽ�
	BuildDate smalldatetime not null,	--ȡ������
	SrcName	nvarchar(10) not null,		--ȡ�÷�ʽ:���ã��������������������������û�
	--�������������������������������Ͷ�����������������������֮�ͱص����������
	ZiYMJ numeric(19,2) null,			--�������
	ZiYJZ numeric(19,2) null,			--���ü�ֵ:���ü�ֵ������*�������
	ChuJMJ numeric(19,2) null,			--�������
	ChuJJZ numeric(19,2) null,			--�����ֵ:�����ֵ������*�������
	ChuZMJ numeric(19,2) null,			--�������
	ChuZJZ numeric(19,2) null,			--�����ֵ:�����ֵ������*�������
	DuiWTZMJ numeric(19,2) null,		--����Ͷ�����
	DuiWTZJZ numeric(19,2) null,		--����Ͷ�ʼ�ֵ:����Ͷ�ʼ�ֵ������*����Ͷ�����
	DuiBMJ numeric(19,2) null,			--�������
	DanBJZ numeric(19,2) null,			--������ֵ:������ֵ������*�������
	QiTMJ numeric(19,2) null,			--�������
	QiTJZ numeric(19,2) null,			--������ֵ:������ֵ������*�������

	CGZZXS3	nvarchar(10) not null,		--�ɹ���֯��ʽ:�������л����ɹ������ż��вɹ�����ɢ�ɹ�������
	UsedStateBDName	nvarchar(10) not null, --ʹ��״��:���ã�δʹ�ã������ã�����
	ChuJDW nvarchar(60) null,			--���赥λ:�г������ʱ�����赥λ����
	ChuZDW nvarchar(60) null,			--���ⵥλ:�г������ʱ�����ⵥλ����
	BMID varchar(12) not null,			--ʹ��\������
	Remark nvarchar(250) null,			--��ע:��"ȡ�÷�ʽ""ʹ��״��""ʹ�÷���"Ϊ"����"ʱ����ע����
	Operator nvarchar(30) not null,		--�Ƶ���
 CONSTRAINT [PK_Land] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[QingCXTZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[Land]  WITH CHECK ADD  CONSTRAINT [FK_Land_CZreportCenter] FOREIGN KEY([reportNum])
REFERENCES [dbo].[CZreportCenter] ([reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Land] CHECK CONSTRAINT [FK_Land_CZreportCenter]

--2.���ݹ����Building
drop TABLE [dbo].[Building]
CREATE TABLE [dbo].[Building](
	reportNum varchar(12) not null,		--����/�����������
	QingCXTZCBH	varchar(12) not null,	--�������ʲ����
	BillDate smalldatetime not null,	--��������
	CatalogID varchar(7) not null,		--�ʲ��������
	StdName nvarchar(30) not null,		--�ʲ�����
	JiLDWCZB nvarchar(10) not null,		--������λ
	JianZMJ numeric(19,2) not null,		--�������
	BuildDate smalldatetime not null,	--ȡ������
	GuoZWJL int null,					--���������:�ʲ�Ϊ������ʱ����
	JianZJGName	nvarchar(10) not null,	--�����ṹ:�ֽṹ���ֻ�ṹ��ש��ṹ��שľ�ṹ������

	BanGSMJ numeric(19,2) null,			--�칫�����
	HuiYSMJ numeric(19,2) null,			--���������
	CheKMJ numeric(19,2) null,			--�������
	ShiTMJ numeric(19,2) null,			--ʳ�����
	PeiDSMJ numeric(19,2) null,			--��������
	JiFMJ numeric(19,2) null,			--�������
	ShiYMJ numeric(19,2) null,			--ʹ�����:ʹ�����С�ڽ������
	DiaXMJ numeric(19,2) null,			--�������

	KuaiJPZH varchar(12) null,			--���ƾ֤��
	ChanQXSName	nvarchar(10) null,		--��Ȩ��ʽ:�в�Ȩ���޲�Ȩ
	QuanSZM	nvarchar(30) null,			--Ȩ��֤��:���в�Ȩʱ��Ȩ��֤������
	QuanSZH	nvarchar(30) null,			--Ȩ��֤��:���в�Ȩʱ��Ȩ��֤�ű���
	FaZSJ smalldatetime null,			--��֤ʱ��:���в�Ȩʱ����֤���ڱ���
	JiaZXSName nvarchar(10) not null,	--��ֵ����:ԭֵ���ݹ�ֵ������ֵ���޼�ֵ
	OrgnValue numeric(19,2)	not null,	--��ֵ:��ֵ���Ͳ���"�޼�ֵ"ʱ����,��"�����Բ���"��"��ҵ����"��"�����ʽ�"�ϼ����
	JunJ numeric(19,2) null,			--����:���ۣ���ֵ/�������

	CaiZXJFLY numeric(19,2) null,		--�����Բ���
	ShiYSR numeric(19,2) null,			--��ҵ����
	QiZYSWSR numeric(19,2) null,		--��ҵ���룺Ԥ��������
	QiTJFLY numeric(19,2) null,			--�����ʽ�
	QiZCZXJYZJ numeric(19,2) null,		--�����ʽ𣺲����Խ����ʽ�
	SrcName	nvarchar(10) not null,		--ȡ�÷�ʽ:���ã��������������������������û����Խ�

	JunGRQ smalldatetime not null,		--��������

	--�������������������������������Ͷ�����������������������֮�ͱص����������
	ZiYMJ numeric(19,2) null,			--�������
	ZiYJZ numeric(19,2) null,			--���ü�ֵ:���ü�ֵ������*�������
	ChuJMJ numeric(19,2) null,			--�������
	ChuJJZ numeric(19,2) null,			--�����ֵ:�����ֵ������*�������
	ChuZMJ numeric(19,2) null,			--�������
	ChuZJZ numeric(19,2) null,			--�����ֵ:�����ֵ������*�������
	DuiWTZMJ numeric(19,2) null,		--����Ͷ�����
	DuiWTZJZ numeric(19,2) null,		--����Ͷ�ʼ�ֵ:����Ͷ�ʼ�ֵ������*����Ͷ�����
	DuiBMJ numeric(19,2) null,			--�������
	DanBJZ numeric(19,2) null,			--������ֵ:������ֵ������*�������
	QiTMJ numeric(19,2) null,			--�������
	QiTJZ numeric(19,2) null,			--������ֵ:������ֵ������*�������

	CGZZXS3	nvarchar(10) not null,		--�ɹ���֯��ʽ:�������л����ɹ������ż��вɹ�����ɢ�ɹ�������
	UsedStateBDName	nvarchar(10) not null, --ʹ��״��:���ã�δʹ�ã������ã�Σ�������ã�����
	ChuJDW nvarchar(60) null,			--���赥λ:�г������ʱ�����赥λ����
	ChuZDW nvarchar(60) null,			--���ⵥλ:�г������ʱ�����ⵥλ����

	DPRCTStateName nvarchar(10) not null,	--�۾�״̬:�����۾ɣ����۾ɣ�������۾�
	DPRCTWayName nvarchar(10) null,		--�۾ɷ���:�۾�״̬Ϊ�����۾ɡ�ʱ����,�ο�"�۾�״̬"��д
	ExptMonth int null,					--ʹ������/�·�:�۾�״̬Ϊ�����۾ɡ�ʱ����,���·�Ϊ������λ
	UsedMonth int null,					--�����۾�����:�Ǳ�����·�Ϊ������λ
	RMValueRate numeric(19,2) null,		--��ֵ��
	DeValue numeric(19,2) null,			--��ֵ׼��

	ZuoLWZ nvarchar(150) not null,		--����λ��
	TouRBDWSYSJ	smalldatetime null,		--Ͷ�뱾��λʹ��ʱ��:
	BMID varchar(12) not null,			--ʹ��\������
	Remark nvarchar(250) null,			--��ע:��"ȡ�÷�ʽ""ʹ��״��""ʹ�÷���"Ϊ"����"ʱ����ע����
	Operator nvarchar(30) not null,		--�Ƶ���
 CONSTRAINT [PK_Building] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[QingCXTZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[Building]  WITH CHECK ADD  CONSTRAINT [FK_Building_CZreportCenter] FOREIGN KEY([reportNum])
REFERENCES [dbo].[CZreportCenter] ([reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Building] CHECK CONSTRAINT [FK_Building_CZreportCenter]

--3.ͨ���豸��generalEqp
select * from generalEqp
drop TABLE [dbo].[generalEqp]
CREATE TABLE [dbo].[generalEqp](
	reportNum varchar(12) not null,		--����/�����������
	QingCXTZCBH	varchar(12) not null,	--�������ʲ����
	BillDate smalldatetime not null,	--��������
	CatalogID varchar(7) not null,		--�ʲ��������
	StdName nvarchar(30) not null,		--�ʲ�����
	JiLDWCZB nvarchar(10) not null,		--������λ
	PinP nvarchar(30) null,				--Ʒ��
	Spec nvarchar(60) null,				--����ͺ�
	JiaZXSName nvarchar(10) not null,	--��ֵ����:ԭֵ���ݹ�ֵ������ֵ���޼�ֵ
	OrgnValue numeric(19,2)	not null,	--��ֵ:��ֵ���Ͳ���"�޼�ֵ"ʱ����,��"�����Բ���"��"��ҵ����"��"�����ʽ�"�ϼ����

	CaiZXJFLY numeric(19,2) null,		--�����Բ���
	ShiYSR numeric(19,2) null,			--��ҵ����
	QiZYSWSR numeric(19,2) null,		--��ҵ���룺Ԥ��������
	QiTJFLY numeric(19,2) null,			--�����ʽ�
	QiZCZXJYZJ numeric(19,2) null,		--�����ʽ𣺲����Խ����ʽ�

	KuaiJPZH varchar(12) null,			--���ƾ֤��
	SrcName	nvarchar(10) not null,		--ȡ�÷�ʽ:����,����,����,����,�û�,����
	BuildDate smalldatetime not null,	--ȡ������
	BaoXJZRQ smalldatetime null,		--���޽�ֹ����

	CGZZXS3	nvarchar(10) not null,		--�ɹ���֯��ʽ:�������л����ɹ������ż��вɹ�����ɢ�ɹ�������
	UsedStateBDName	nvarchar(10) not null, --ʹ��״��:���ã�δʹ�ã������ã��ٻ������ã�����
	UsedwayBDName nvarchar(10) not null,	--ʹ�÷���:����,���⣬���裬����Ͷ�ʣ�����������
	ChuZCJDFDW nvarchar(60) null,		--����/����Է���λ

	DPRCTStateName nvarchar(10) not null,	--�۾�״̬:�����۾ɣ����۾ɣ�������۾�
	DPRCTWayName nvarchar(10) null,		--�۾ɷ���:�۾�״̬Ϊ�����۾ɡ�ʱ����,�ο�"�۾�״̬"��д
	ExptMonth int null,					--ʹ������/�·�:�۾�״̬Ϊ�����۾ɡ�ʱ����,���·�Ϊ������λ
	UsedMonth int null,					--�����۾�����:�Ǳ�����·�Ϊ������λ
	RMValueRate numeric(19,2) null,		--��ֵ��
	DeValue numeric(19,2) null,			--��ֵ׼��

	PlaceID nvarchar(150) not null,		--��ŵص�
	BMID varchar(12) not null,			--ʹ��\������
	ShiYRName nvarchar(30) null,		--ʹ��������
	Remark nvarchar(250) null,			--��ע:��"ȡ�÷�ʽ""ʹ��״��""ʹ�÷���"Ϊ"����"ʱ����ע����
	Operator nvarchar(30) not null,		--�Ƶ���
	GuanLRID nvarchar(30) null,			--������

 CONSTRAINT [PK_generalEqp] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[QingCXTZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[generalEqp]  WITH CHECK ADD  CONSTRAINT [FK_generalEqp_CZreportCenter] FOREIGN KEY([reportNum])
REFERENCES [dbo].[CZreportCenter] ([reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[generalEqp] CHECK CONSTRAINT [FK_generalEqp_CZreportCenter]

--4.ר���豸��specialEqp
--��3.ͨ���豸��generalEqp��ṹ��ȫһ�£�
drop TABLE [dbo].[specialEqp]
CREATE TABLE [dbo].[specialEqp](
	reportNum varchar(12) not null,		--����/�����������
	QingCXTZCBH	varchar(12) not null,	--�������ʲ����
	BillDate smalldatetime not null,	--��������
	CatalogID varchar(7) not null,		--�ʲ��������
	StdName nvarchar(30) not null,		--�ʲ�����
	JiLDWCZB nvarchar(10) not null,		--������λ
	PinP nvarchar(30) null,				--Ʒ��
	Spec nvarchar(60) null,				--����ͺ�
	JiaZXSName nvarchar(10) not null,	--��ֵ����:ԭֵ���ݹ�ֵ������ֵ���޼�ֵ
	OrgnValue numeric(19,2)	not null,	--��ֵ:��ֵ���Ͳ���"�޼�ֵ"ʱ����,��"�����Բ���"��"��ҵ����"��"�����ʽ�"�ϼ����

	CaiZXJFLY numeric(19,2) null,		--�����Բ���
	ShiYSR numeric(19,2) null,			--��ҵ����
	QiZYSWSR numeric(19,2) null,		--��ҵ���룺Ԥ��������
	QiTJFLY numeric(19,2) null,			--�����ʽ�
	QiZCZXJYZJ numeric(19,2) null,		--�����ʽ𣺲����Խ����ʽ�

	KuaiJPZH varchar(12) null,			--���ƾ֤��
	SrcName	nvarchar(10) not null,		--ȡ�÷�ʽ:����,����,����,����,�û�,����
	BuildDate smalldatetime not null,	--ȡ������
	BaoXJZRQ smalldatetime null,		--���޽�ֹ����

	CGZZXS3	nvarchar(10) not null,		--�ɹ���֯��ʽ:�������л����ɹ������ż��вɹ�����ɢ�ɹ�������
	UsedStateBDName	nvarchar(10) not null, --ʹ��״��:���ã�δʹ�ã������ã��ٻ������ã�����
	UsedwayBDName nvarchar(10) not null,	--ʹ�÷���:����,���⣬���裬����Ͷ�ʣ�����������
	ChuZCJDFDW nvarchar(60) null,		--����/����Է���λ

	DPRCTStateName nvarchar(10) not null,	--�۾�״̬:�����۾ɣ����۾ɣ�������۾�
	DPRCTWayName nvarchar(10) null,		--�۾ɷ���:�۾�״̬Ϊ�����۾ɡ�ʱ����,�ο�"�۾�״̬"��д
	ExptMonth int null,					--ʹ������/�·�:�۾�״̬Ϊ�����۾ɡ�ʱ����,���·�Ϊ������λ
	UsedMonth int null,					--�����۾�����:�Ǳ�����·�Ϊ������λ
	RMValueRate numeric(19,2) null,		--��ֵ��
	DeValue numeric(19,2) null,			--��ֵ׼��

	PlaceID nvarchar(150) not null,		--��ŵص�
	BMID varchar(12) not null,			--ʹ��\������
	ShiYRName nvarchar(30) null,		--ʹ��������
	Remark nvarchar(250) null,			--��ע:��"ȡ�÷�ʽ""ʹ��״��""ʹ�÷���"Ϊ"����"ʱ����ע����
	Operator nvarchar(30) not null,		--�Ƶ���
	GuanLRID nvarchar(30) null,			--������

 CONSTRAINT [PK_specialEqp] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[QingCXTZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[specialEqp]  WITH CHECK ADD  CONSTRAINT [FK_specialEqp_CZreportCenter] FOREIGN KEY([reportNum])
REFERENCES [dbo].[CZreportCenter] ([reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[specialEqp] CHECK CONSTRAINT [FK_specialEqp_CZreportCenter]

--5.��ͨ�����豸��EqpCar
drop TABLE [dbo].[EqpCar]
CREATE TABLE [dbo].[EqpCar](
	reportNum varchar(12) not null,		--����/�����������
	QingCXTZCBH	varchar(12) not null,	--�������ʲ����
	BillDate smalldatetime not null,	--��������
	CatalogID varchar(7) not null,		--�ʲ��������
	StdName nvarchar(30) not null,		--�ʲ�����
	JiLDWCZB nvarchar(10) not null,		--������λ

	CheLCDName nvarchar(10) null,		--��������:����,����(����װ)
	Spec nvarchar(60) null,				--����ͺ�
	CheJH nvarchar(36) null,			--���ܺ�:�����ƺŴ���ʱ,���ܺŲ���Ϊ��
	ChePH nvarchar(10) null,			--���ƺ�
	ChangPXH nvarchar(20) null,			--�����ͺ�:�����ƺŴ���ʱ,�����ͺŲ���Ϊ��
	FaDJH nvarchar(20) null,			--��������:�����ƺŴ���ʱ,�������Ų���Ϊ��
	PaiQL varchar(4) null,				--������:�����ƺŴ���ʱ,����������Ϊ��

	BianZQKName nvarchar(10) not null,	--�������:�����ڱ�,�ǲ����ڱ�
	JiaZXSName nvarchar(10) not null,	--��ֵ����:ԭֵ���ݹ�ֵ������ֵ���޼�ֵ
	OrgnValue numeric(19,2)	not null,	--��ֵ:��ֵ���Ͳ���"�޼�ֵ"ʱ����,��"�����Բ���"��"��ҵ����"��"�����ʽ�"�ϼ����

	CaiZXJFLY numeric(19,2) null,		--�����Բ���
	ShiYSR numeric(19,2) null,			--��ҵ����
	QiZYSWSR numeric(19,2) null,		--��ҵ���룺Ԥ��������
	QiTJFLY numeric(19,2) null,			--�����ʽ�
	QiZCZXJYZJ numeric(19,2) null,		--�����ʽ𣺲����Խ����ʽ�

	YongTFLName nvarchar(10) null,		--��;����:�쵼�ó�,�����ó�,רҵ�ó�,�����ó�,�Ӵ��ó�,�����ó�
	KuaiJPZH varchar(12) null,			--���ƾ֤��
	BuildDate smalldatetime not null,	--ȡ������
	SrcName	nvarchar(10) not null,		--ȡ�÷�ʽ:����,����,����,����,�û�,����
	BaoXJZRQ smalldatetime null,		--���޽�ֹ����
	UseDate smalldatetime null,			--ʹ������
	UsedwayBDName nvarchar(10) not null,--ʹ�÷���:����,���⣬���裬����Ͷ�ʣ�����������

	ChuZCJDFDW nvarchar(60) null,		--����/����Է���λ
	BMID varchar(12) not null,			--ʹ��\������
	ShiYRName nvarchar(30) null,		--ʹ��������

	CGZZXS3	nvarchar(10) not null,		--�ɹ���֯��ʽ:�������л����ɹ������ż��вɹ�����ɢ�ɹ�������
	UsedStateBDName	nvarchar(10) not null, --ʹ��״��:���ã�δʹ�ã������ã��ٻ������ã�����

	DPRCTStateName nvarchar(10) not null,	--�۾�״̬:�����۾ɣ����۾ɣ�������۾�
	DPRCTWayName nvarchar(10) null,		--�۾ɷ���:�۾�״̬Ϊ�����۾ɡ�ʱ����,�ο�"�۾�״̬"��д
	ExptMonth int null,					--ʹ������/�·�:�۾�״̬Ϊ�����۾ɡ�ʱ����,���·�Ϊ������λ
	UsedMonth int null,					--�����۾�����:�Ǳ�����·�Ϊ������λ
	RMValueRate numeric(19,2) null,		--��ֵ��
	DeValue numeric(19,2) null,			--��ֵ׼��

	Remark nvarchar(250) null,			--��ע:��"ȡ�÷�ʽ""ʹ��״��""ʹ�÷���"Ϊ"����"ʱ����ע����
	Operator nvarchar(30) not null,		--�Ƶ���
	GuanLRID nvarchar(30) null,			--������
 CONSTRAINT [PK_EqpCar] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[QingCXTZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[EqpCar]  WITH CHECK ADD  CONSTRAINT [FK_EqpCar_CZreportCenter] FOREIGN KEY([reportNum])
REFERENCES [dbo].[CZreportCenter] ([reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EqpCar] CHECK CONSTRAINT [FK_EqpCar_CZreportCenter]

--6.�����豸��EqpElectrical
--��3.ͨ���豸��generalEqp��ṹ��ȫһ�£�
drop TABLE [dbo].[EqpElectrical]
CREATE TABLE [dbo].[EqpElectrical](
	reportNum varchar(12) not null,		--����/�����������
	QingCXTZCBH	varchar(12) not null,	--�������ʲ����
	BillDate smalldatetime not null,	--��������
	CatalogID varchar(7) not null,		--�ʲ��������
	StdName nvarchar(30) not null,		--�ʲ�����
	JiLDWCZB nvarchar(10) not null,		--������λ
	PinP nvarchar(30) null,				--Ʒ��
	Spec nvarchar(60) null,				--����ͺ�
	JiaZXSName nvarchar(10) not null,	--��ֵ����:ԭֵ���ݹ�ֵ������ֵ���޼�ֵ
	OrgnValue numeric(19,2)	not null,	--��ֵ:��ֵ���Ͳ���"�޼�ֵ"ʱ����,��"�����Բ���"��"��ҵ����"��"�����ʽ�"�ϼ����

	CaiZXJFLY numeric(19,2) null,		--�����Բ���
	ShiYSR numeric(19,2) null,			--��ҵ����
	QiZYSWSR numeric(19,2) null,		--��ҵ���룺Ԥ��������
	QiTJFLY numeric(19,2) null,			--�����ʽ�
	QiZCZXJYZJ numeric(19,2) null,		--�����ʽ𣺲����Խ����ʽ�

	KuaiJPZH varchar(12) null,			--���ƾ֤��
	SrcName	nvarchar(10) not null,		--ȡ�÷�ʽ:����,����,����,����,�û�,����
	BuildDate smalldatetime not null,	--ȡ������
	BaoXJZRQ smalldatetime null,		--���޽�ֹ����

	CGZZXS3	nvarchar(10) not null,		--�ɹ���֯��ʽ:�������л����ɹ������ż��вɹ�����ɢ�ɹ�������
	UsedStateBDName	nvarchar(10) not null, --ʹ��״��:���ã�δʹ�ã������ã��ٻ������ã�����
	UsedwayBDName nvarchar(10) not null,	--ʹ�÷���:����,���⣬���裬����Ͷ�ʣ�����������
	ChuZCJDFDW nvarchar(60) null,		--����/����Է���λ

	DPRCTStateName nvarchar(10) not null,	--�۾�״̬:�����۾ɣ����۾ɣ�������۾�
	DPRCTWayName nvarchar(10) null,		--�۾ɷ���:�۾�״̬Ϊ�����۾ɡ�ʱ����,�ο�"�۾�״̬"��д
	ExptMonth int null,					--ʹ������/�·�:�۾�״̬Ϊ�����۾ɡ�ʱ����,���·�Ϊ������λ
	UsedMonth int null,					--�����۾�����:�Ǳ�����·�Ϊ������λ
	RMValueRate numeric(19,2) null,		--��ֵ��
	DeValue numeric(19,2) null,			--��ֵ׼��

	PlaceID nvarchar(150) not null,		--��ŵص�
	BMID varchar(12) not null,			--ʹ��\������
	ShiYRName nvarchar(30) null,		--ʹ��������
	Remark nvarchar(250) null,			--��ע:��"ȡ�÷�ʽ""ʹ��״��""ʹ�÷���"Ϊ"����"ʱ����ע����
	Operator nvarchar(30) not null,		--�Ƶ���
	GuanLRID nvarchar(30) null,			--������

 CONSTRAINT [PK_EqpElectrical] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[QingCXTZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[EqpElectrical]  WITH CHECK ADD  CONSTRAINT [FK_EqpElectrical_CZreportCenter] FOREIGN KEY([reportNum])
REFERENCES [dbo].[CZreportCenter] ([reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EqpElectrical] CHECK CONSTRAINT [FK_EqpElectrical_CZreportCenter]

--7.���Ӳ�Ʒ��ͨ���豸��EqpCommunicate
--��3.ͨ���豸��generalEqp��ṹ��ȫһ�£�
drop TABLE [dbo].[EqpCommunicate]
CREATE TABLE [dbo].[EqpCommunicate](
	reportNum varchar(12) not null,		--����/�����������
	QingCXTZCBH	varchar(12) not null,	--�������ʲ����
	BillDate smalldatetime not null,	--��������
	CatalogID varchar(7) not null,		--�ʲ��������
	StdName nvarchar(30) not null,		--�ʲ�����
	JiLDWCZB nvarchar(10) not null,		--������λ
	PinP nvarchar(30) null,				--Ʒ��
	Spec nvarchar(60) null,				--����ͺ�
	JiaZXSName nvarchar(10) not null,	--��ֵ����:ԭֵ���ݹ�ֵ������ֵ���޼�ֵ
	OrgnValue numeric(19,2)	not null,	--��ֵ:��ֵ���Ͳ���"�޼�ֵ"ʱ����,��"�����Բ���"��"��ҵ����"��"�����ʽ�"�ϼ����

	CaiZXJFLY numeric(19,2) null,		--�����Բ���
	ShiYSR numeric(19,2) null,			--��ҵ����
	QiZYSWSR numeric(19,2) null,		--��ҵ���룺Ԥ��������
	QiTJFLY numeric(19,2) null,			--�����ʽ�
	QiZCZXJYZJ numeric(19,2) null,		--�����ʽ𣺲����Խ����ʽ�

	KuaiJPZH varchar(12) null,			--���ƾ֤��
	SrcName	nvarchar(10) not null,		--ȡ�÷�ʽ:����,����,����,����,�û�,����
	BuildDate smalldatetime not null,	--ȡ������
	BaoXJZRQ smalldatetime null,		--���޽�ֹ����

	CGZZXS3	nvarchar(10) not null,		--�ɹ���֯��ʽ:�������л����ɹ������ż��вɹ�����ɢ�ɹ�������
	UsedStateBDName	nvarchar(10) not null, --ʹ��״��:���ã�δʹ�ã������ã��ٻ������ã�����
	UsedwayBDName nvarchar(10) not null,	--ʹ�÷���:����,���⣬���裬����Ͷ�ʣ�����������
	ChuZCJDFDW nvarchar(60) null,		--����/����Է���λ

	DPRCTStateName nvarchar(10) not null,	--�۾�״̬:�����۾ɣ����۾ɣ�������۾�
	DPRCTWayName nvarchar(10) null,		--�۾ɷ���:�۾�״̬Ϊ�����۾ɡ�ʱ����,�ο�"�۾�״̬"��д
	ExptMonth int null,					--ʹ������/�·�:�۾�״̬Ϊ�����۾ɡ�ʱ����,���·�Ϊ������λ
	UsedMonth int null,					--�����۾�����:�Ǳ�����·�Ϊ������λ
	RMValueRate numeric(19,2) null,		--��ֵ��
	DeValue numeric(19,2) null,			--��ֵ׼��

	PlaceID nvarchar(150) not null,		--��ŵص�
	BMID varchar(12) not null,			--ʹ��\������
	ShiYRName nvarchar(30) null,		--ʹ��������
	Remark nvarchar(250) null,			--��ע:��"ȡ�÷�ʽ""ʹ��״��""ʹ�÷���"Ϊ"����"ʱ����ע����
	Operator nvarchar(30) not null,		--�Ƶ���
	GuanLRID nvarchar(30) null,			--������

 CONSTRAINT [PK_EqpCommunicate] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[QingCXTZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[EqpCommunicate]  WITH CHECK ADD  CONSTRAINT [FK_EqpCommunicate_CZreportCenter] FOREIGN KEY([reportNum])
REFERENCES [dbo].[CZreportCenter] ([reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EqpCommunicate] CHECK CONSTRAINT [FK_EqpCommunicate_CZreportCenter]

--8.�����Ǳ����ߣ�EqpInstrument
--��3.ͨ���豸��generalEqp��ṹ��ȫһ�£�
drop TABLE [dbo].[EqpInstrument]
CREATE TABLE [dbo].[EqpInstrument](
	reportNum varchar(12) not null,		--����/�����������
	QingCXTZCBH	varchar(12) not null,	--�������ʲ����
	BillDate smalldatetime not null,	--��������
	CatalogID varchar(7) not null,		--�ʲ��������
	StdName nvarchar(30) not null,		--�ʲ�����
	JiLDWCZB nvarchar(10) not null,		--������λ
	PinP nvarchar(30) null,				--Ʒ��
	Spec nvarchar(60) null,				--����ͺ�
	JiaZXSName nvarchar(10) not null,	--��ֵ����:ԭֵ���ݹ�ֵ������ֵ���޼�ֵ
	OrgnValue numeric(19,2)	not null,	--��ֵ:��ֵ���Ͳ���"�޼�ֵ"ʱ����,��"�����Բ���"��"��ҵ����"��"�����ʽ�"�ϼ����

	CaiZXJFLY numeric(19,2) null,		--�����Բ���
	ShiYSR numeric(19,2) null,			--��ҵ����
	QiZYSWSR numeric(19,2) null,		--��ҵ���룺Ԥ��������
	QiTJFLY numeric(19,2) null,			--�����ʽ�
	QiZCZXJYZJ numeric(19,2) null,		--�����ʽ𣺲����Խ����ʽ�

	KuaiJPZH varchar(12) null,			--���ƾ֤��
	SrcName	nvarchar(10) not null,		--ȡ�÷�ʽ:����,����,����,����,�û�,����
	BuildDate smalldatetime not null,	--ȡ������
	BaoXJZRQ smalldatetime null,		--���޽�ֹ����

	CGZZXS3	nvarchar(10) not null,		--�ɹ���֯��ʽ:�������л����ɹ������ż��вɹ�����ɢ�ɹ�������
	UsedStateBDName	nvarchar(10) not null, --ʹ��״��:���ã�δʹ�ã������ã��ٻ������ã�����
	UsedwayBDName nvarchar(10) not null,	--ʹ�÷���:����,���⣬���裬����Ͷ�ʣ�����������
	ChuZCJDFDW nvarchar(60) null,		--����/����Է���λ

	DPRCTStateName nvarchar(10) not null,	--�۾�״̬:�����۾ɣ����۾ɣ�������۾�
	DPRCTWayName nvarchar(10) null,		--�۾ɷ���:�۾�״̬Ϊ�����۾ɡ�ʱ����,�ο�"�۾�״̬"��д
	ExptMonth int null,					--ʹ������/�·�:�۾�״̬Ϊ�����۾ɡ�ʱ����,���·�Ϊ������λ
	UsedMonth int null,					--�����۾�����:�Ǳ�����·�Ϊ������λ
	RMValueRate numeric(19,2) null,		--��ֵ��
	DeValue numeric(19,2) null,			--��ֵ׼��

	PlaceID nvarchar(150) not null,		--��ŵص�
	BMID varchar(12) not null,			--ʹ��\������
	ShiYRName nvarchar(30) null,		--ʹ��������
	Remark nvarchar(250) null,			--��ע:��"ȡ�÷�ʽ""ʹ��״��""ʹ�÷���"Ϊ"����"ʱ����ע����
	Operator nvarchar(30) not null,		--�Ƶ���
	GuanLRID nvarchar(30) null,			--������

 CONSTRAINT [PK_EqpInstrument] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[QingCXTZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[EqpInstrument]  WITH CHECK ADD  CONSTRAINT [FK_EqpInstrument_CZreportCenter] FOREIGN KEY([reportNum])
REFERENCES [dbo].[CZreportCenter] ([reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EqpInstrument] CHECK CONSTRAINT [FK_EqpInstrument_CZreportCenter]

--9.���������豸��EqpSport
--��3.ͨ���豸��generalEqp��ṹ����һ�£���һ�����������ֶΣ��ֶ�����˳��ͬ��
drop TABLE [dbo].[EqpSport]
CREATE TABLE [dbo].[EqpSport](
	reportNum varchar(12) not null,		--����/�����������
	QingCXTZCBH	varchar(12) not null,	--�������ʲ����
	BillDate smalldatetime not null,	--��������
	CatalogID varchar(7) not null,		--�ʲ��������
	StdName nvarchar(30) not null,		--�ʲ�����
	JiLDWCZB nvarchar(10) not null,		--������λ
	QTY	int not null,					--����:�����������ɲ�ֵ��ʲ�����������1
	PinP nvarchar(30) null,				--Ʒ��
	Spec nvarchar(60) null,				--����ͺ�
	KuaiJPZH varchar(12) null,			--���ƾ֤��
	JiaZXSName nvarchar(10) not null,	--��ֵ����:ԭֵ���ݹ�ֵ������ֵ���޼�ֵ
	OrgnValue numeric(19,2)	not null,	--��ֵ:��ֵ���Ͳ���"�޼�ֵ"ʱ����,��"�����Բ���"��"��ҵ����"��"�����ʽ�"�ϼ����

	CaiZXJFLY numeric(19,2) null,		--�����Բ���
	ShiYSR numeric(19,2) null,			--��ҵ����
	QiZYSWSR numeric(19,2) null,		--��ҵ���룺Ԥ��������
	QiTJFLY numeric(19,2) null,			--�����ʽ�
	QiZCZXJYZJ numeric(19,2) null,		--�����ʽ𣺲����Խ����ʽ�

	SrcName	nvarchar(10) not null,		--ȡ�÷�ʽ:����,����,����,����,�û�,����
	DPRCTStateName nvarchar(10) not null,	--�۾�״̬:�����۾ɣ����۾ɣ�������۾�
	DPRCTWayName nvarchar(10) null,		--�۾ɷ���:�۾�״̬Ϊ�����۾ɡ�ʱ����,�ο�"�۾�״̬"��д
	ExptMonth int null,					--ʹ������/�·�:�۾�״̬Ϊ�����۾ɡ�ʱ����,���·�Ϊ������λ
	UsedMonth int null,					--�����۾�����:�Ǳ�����·�Ϊ������λ
	RMValueRate numeric(19,2) null,		--��ֵ��
	DeValue numeric(19,2) null,			--��ֵ׼��

	BuildDate smalldatetime not null,	--ȡ������
	BaoXJZRQ smalldatetime null,		--���޽�ֹ����

	UsedwayBDName nvarchar(10) not null,	--ʹ�÷���:����,���⣬���裬����Ͷ�ʣ�����������
	ChuZCJDFDW nvarchar(60) null,		--����/����Է���λ
	CGZZXS3	nvarchar(10) not null,		--�ɹ���֯��ʽ:�������л����ɹ������ż��вɹ�����ɢ�ɹ�������
	UsedStateBDName	nvarchar(10) not null, --ʹ��״��:���ã�δʹ�ã������ã��ٻ������ã�����

	PlaceID nvarchar(150) not null,		--��ŵص�
	BMID varchar(12) not null,			--ʹ��\������
	ShiYRName nvarchar(30) null,		--ʹ��������
	Remark nvarchar(250) null,			--��ע:��"ȡ�÷�ʽ""ʹ��״��""ʹ�÷���"Ϊ"����"ʱ����ע����
	Operator nvarchar(30) not null,		--�Ƶ���
	GuanLRID nvarchar(30) null,			--������

 CONSTRAINT [PK_EqpSport] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[QingCXTZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[EqpSport]  WITH CHECK ADD  CONSTRAINT [FK_EqpSport_CZreportCenter] FOREIGN KEY([reportNum])
REFERENCES [dbo].[CZreportCenter] ([reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EqpSport] CHECK CONSTRAINT [FK_EqpSport_CZreportCenter]

--10.ͼ�����Ｐ����Ʒ��EqpCultural
drop TABLE [dbo].[EqpCultural]
CREATE TABLE [dbo].[EqpCultural](
	reportNum varchar(12) not null,		--����/�����������
	QingCXTZCBH	varchar(12) not null,	--�������ʲ����
	BillDate smalldatetime not null,	--��������
	CatalogID varchar(7) not null,		--�ʲ��������
	StdName nvarchar(30) not null,		--�ʲ�����
	JiLDWCZB nvarchar(10) not null,		--������λ
	QTY	int not null,					--����:�����������ɲ�ֵ��ʲ�����������1

	WenWDJName nvarchar(30) null,		--����ȼ�����
	PlaceID nvarchar(150) not null,		--��ŵص�
	ZuoLWZ nvarchar(150) not null,		--����λ��
	JiaZXSName nvarchar(10) not null,	--��ֵ����:ԭֵ���ݹ�ֵ������ֵ���޼�ֵ
	OrgnValue numeric(19,2)	not null,	--��ֵ:��ֵ���Ͳ���"�޼�ֵ"ʱ����,��"�����Բ���"��"��ҵ����"��"�����ʽ�"�ϼ����

	CaiZXJFLY numeric(19,2) null,		--�����Բ���
	ShiYSR numeric(19,2) null,			--��ҵ����
	QiZYSWSR numeric(19,2) null,		--��ҵ���룺Ԥ��������
	QiTJFLY numeric(19,2) null,			--�����ʽ�
	QiZCZXJYZJ numeric(19,2) null,		--�����ʽ𣺲����Խ����ʽ�

	KuaiJPZH varchar(12) null,			--���ƾ֤��
	CGZZXS3	nvarchar(10) not null,		--�ɹ���֯��ʽ:�������л����ɹ������ż��вɹ�����ɢ�ɹ�������
	UsedStateBDName	nvarchar(10) not null, --ʹ��״��:���ã�δʹ�ã������ã��ٻ������ã�����
	UsedwayBDName nvarchar(10) not null,	--ʹ�÷���:����,���⣬���裬����Ͷ�ʣ�����������
	BuildDate smalldatetime not null,	--ȡ������
	SrcName	nvarchar(10) not null,		--ȡ�÷�ʽ:����,����,����,����,�û�,����

	ChanQXSName	nvarchar(10) null,		--��Ȩ��ʽ:�в�Ȩ���޲�Ȩ
	BMID varchar(12) not null,			--ʹ��\������
	GuanLDW nvarchar(60) null,			--����λ(����)
	ShiYRName nvarchar(30) null,		--ʹ��������
	Remark nvarchar(250) null,			--��ע:��"ȡ�÷�ʽ""ʹ��״��""ʹ�÷���"Ϊ"����"ʱ����ע����
	Operator nvarchar(30) not null,		--�Ƶ���
	GuanLRID nvarchar(30) null,			--������

 CONSTRAINT [PK_EqpCultural] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[QingCXTZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[EqpCultural]  WITH CHECK ADD  CONSTRAINT [FK_EqpCultural_CZreportCenter] FOREIGN KEY([reportNum])
REFERENCES [dbo].[CZreportCenter] ([reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EqpCultural] CHECK CONSTRAINT [FK_EqpCultural_CZreportCenter]

--11.�Ҿ��þ߼������ࣺEqpFurniture
--��3.ͨ���豸��generalEqp��ṹ����һ�£���һ�����������ֶΣ��ֶ�����˳��ͬ��
--��9.���������豸��EqpSport��ȫһ�£�
drop TABLE [dbo].[EqpFurniture]
CREATE TABLE [dbo].[EqpFurniture](
	reportNum varchar(12) not null,		--����/�����������
	QingCXTZCBH	varchar(12) not null,	--�������ʲ����
	BillDate smalldatetime not null,	--��������
	CatalogID varchar(7) not null,		--�ʲ��������
	StdName nvarchar(30) not null,		--�ʲ�����
	JiLDWCZB nvarchar(10) not null,		--������λ
	QTY	int not null,					--����:�����������ɲ�ֵ��ʲ�����������1
	PinP nvarchar(30) null,				--Ʒ��
	Spec nvarchar(60) null,				--����ͺ�
	KuaiJPZH varchar(12) null,			--���ƾ֤��
	JiaZXSName nvarchar(10) not null,	--��ֵ����:ԭֵ���ݹ�ֵ������ֵ���޼�ֵ
	OrgnValue numeric(19,2)	not null,	--��ֵ:��ֵ���Ͳ���"�޼�ֵ"ʱ����,��"�����Բ���"��"��ҵ����"��"�����ʽ�"�ϼ����

	CaiZXJFLY numeric(19,2) null,		--�����Բ���
	ShiYSR numeric(19,2) null,			--��ҵ����
	QiZYSWSR numeric(19,2) null,		--��ҵ���룺Ԥ��������
	QiTJFLY numeric(19,2) null,			--�����ʽ�
	QiZCZXJYZJ numeric(19,2) null,		--�����ʽ𣺲����Խ����ʽ�

	SrcName	nvarchar(10) not null,		--ȡ�÷�ʽ:����,����,����,����,�û�,����
	DPRCTStateName nvarchar(10) not null,	--�۾�״̬:�����۾ɣ����۾ɣ�������۾�
	DPRCTWayName nvarchar(10) null,		--�۾ɷ���:�۾�״̬Ϊ�����۾ɡ�ʱ����,�ο�"�۾�״̬"��д
	ExptMonth int null,					--ʹ������/�·�:�۾�״̬Ϊ�����۾ɡ�ʱ����,���·�Ϊ������λ
	UsedMonth int null,					--�����۾�����:�Ǳ�����·�Ϊ������λ
	RMValueRate numeric(19,2) null,		--��ֵ��
	DeValue numeric(19,2) null,			--��ֵ׼��

	BuildDate smalldatetime not null,	--ȡ������
	BaoXJZRQ smalldatetime null,		--���޽�ֹ����

	UsedwayBDName nvarchar(10) not null,	--ʹ�÷���:����,���⣬���裬����Ͷ�ʣ�����������
	ChuZCJDFDW nvarchar(60) null,		--����/����Է���λ
	CGZZXS3	nvarchar(10) not null,		--�ɹ���֯��ʽ:�������л����ɹ������ż��вɹ�����ɢ�ɹ�������
	UsedStateBDName	nvarchar(10) not null, --ʹ��״��:���ã�δʹ�ã������ã��ٻ������ã�����

	PlaceID nvarchar(150) not null,		--��ŵص�
	BMID varchar(12) not null,			--ʹ��\������
	ShiYRName nvarchar(30) null,		--ʹ��������
	Remark nvarchar(250) null,			--��ע:��"ȡ�÷�ʽ""ʹ��״��""ʹ�÷���"Ϊ"����"ʱ����ע����
	Operator nvarchar(30) not null,		--�Ƶ���
	GuanLRID nvarchar(30) null,			--������

 CONSTRAINT [PK_EqpFurniture] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[QingCXTZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[EqpFurniture]  WITH CHECK ADD  CONSTRAINT [FK_EqpFurniture_CZreportCenter] FOREIGN KEY([reportNum])
REFERENCES [dbo].[CZreportCenter] ([reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EqpFurniture] CHECK CONSTRAINT [FK_EqpFurniture_CZreportCenter]


--12.�����ʲ���intangible
drop table [dbo].[intangible]
CREATE TABLE [dbo].[intangible](
	reportNum varchar(12) not null,		--����/�����������
	QingCXTZCBH	varchar(12) not null,	--�������ʲ����
	BillDate smalldatetime not null,	--��������
	CatalogID varchar(7) not null,		--�ʲ��������
	StdName nvarchar(30) not null,		--�ʲ�����

	SrcName	nvarchar(10) not null,		--ȡ�÷�ʽ:����,����,����,����,�û�,����
	BuildDate smalldatetime not null,	--ȡ������
	QTY	int not null,					--����:�����������ɲ�ֵ��ʲ�����������1
	KuaiJPZH varchar(12) not null,		--���ƾ֤��:����
	JiaZXSName nvarchar(10) not null,	--��ֵ����:ԭֵ���ݹ�ֵ������ֵ���޼�ֵ
	OrgnValue numeric(19,2)	not null,	--��ֵ:��ֵ���Ͳ����޼�ʱ����ֵ���ֻ��������ֵ
	PingGJZ numeric(19,2) not null,		--������ֵ:������ֵ���ֻ��������ֵ

	UsedStateBDName	nvarchar(10) not null, --ʹ��״��:���ã�δʹ�ã�����
	UsedwayBDName nvarchar(10) not null,--ʹ�÷���:����,����,����,����,����Ͷ��,��Ӫ,����

	ShiYNX int null,					--ʹ������
	ZhuCDJJG nvarchar(100) null,		--ע��Ǽǻ���
	ZhuCDJSJ smalldatetime null,		--ע��Ǽ�ʱ��
	ZhuanLH nvarchar(100) null,			--ר����
	PiZWH nvarchar(50) null,			--��׼�ĺ�
	
	GuanLDW nvarchar(60) null,			--����λ(����)
	Remark nvarchar(250) null,			--��ע:��"ȡ�÷�ʽ""ʹ��״��""ʹ�÷���"Ϊ"����"ʱ����ע����
	Operator nvarchar(30) not null,		--�Ƶ���

 CONSTRAINT [PK_intangible] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[QingCXTZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[intangible]  WITH CHECK ADD  CONSTRAINT [FK_intangible_CZreportCenter] FOREIGN KEY([reportNum])
REFERENCES [dbo].[CZreportCenter] ([reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[intangible] CHECK CONSTRAINT [FK_intangible_CZreportCenter]


DROP PROCEDURE makeCReport
/*
	name:		makeCReport
	function:	1.����ͳ���������ɲ�����ͳ�Ʊ���
	input: 
				@theTitle nvarchar(100),		--�������
				@theYear varchar(4),			--ͳ�����
				@totalEndDate varchar(10),		--ͳ�ƽ�������:"yyyy-MM-dd"��ʽ

				@makeUnit nvarchar(50),			--�Ʊ�λ
				@makeDate smalldatetime,		--�Ʊ�����

				@makerID varchar(10),			--�Ʊ��˹���
	output: 
				@Ret		int output,			--�����ɹ���ʶ��0:�ɹ���9:δ֪����
				@reportNum varchar(12) output	--������
	author:		¬έ
	CreateDate:	2012-10-1
	UpdateDate: 
*/
create PROCEDURE makeCReport
	@theTitle nvarchar(100),		--�������
	@theYear varchar(4),			--ͳ�����
	@totalEndDate varchar(10),		--ͳ�ƽ�������:"yyyy-MM-dd"��ʽ

	@makeUnit nvarchar(50),			--�Ʊ�λ
	@makerID varchar(10),			--�Ʊ��˹���
	@Ret		int output,			--�����ɹ���ʶ��0:�ɹ���9:δ֪����
	@reportNum varchar(12) output	--������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢�������ɱ����ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 800, 1, @curNumber output
	set @reportNum = @curNumber

	--��ȡ�Ʊ���������
	declare @maker nvarchar(30)
	set @maker = isnull((select userCName from activeUsers where userID = @makerID),'')
	--�Ʊ����ڣ�
	declare @makeDate smalldatetime		--�Ʊ�����
	set @makeDate = GETDATE()
	
	
	--����������
	begin tran
		insert CZreportCenter(reportNum, theTitle, theYear, totalEndDate,
				--�ʲ����豸�����������Ϣ��
				LandValue,		--1.���غϼƽ��
				BuildingValue,	--2.���ݹ�����ϼƽ��
				generalEqpValue,--3.ͨ���豸�ϼƽ��
				specialEqpValue,--4.ר���豸�ϼƽ��
				EqpCarValue,	--5.��ͨ�����豸�ϼƽ��
				EqpElectricalValue,--6.�����豸�ϼƽ��
				EqpCommunicateValue,--7.���Ӳ�Ʒ��ͨ���豸�ϼƽ��
				EqpInstrumentValue,--8.�����Ǳ����ߺϼƽ��
				EqpSportValue,	--9.���������豸�ϼƽ��
				EqpCulturalValue,--10.ͼ�����Ｐ����Ʒ�ϼƽ��
				EqpFurnitureValue,--11.�Ҿ��þ߼�������ϼƽ��
				intangibleValue,--11.�����ʲ��ϼƽ��
				
				makeUnit, makeDate,
				makerID, maker)
		values(@reportNum,@theTitle, @theYear, @totalEndDate, 0,0,0,0,0,0,0,0,0,0,0,0,@makeUnit,@makeDate,@makerID,@maker)
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    

		declare @LandValue numeric(19,2), @BuildingValue  numeric(19,2),
				@generalEqpValue numeric(19,2), @specialEqpValue  numeric(19,2),
				@EqpCarValue numeric(19,2), @EqpElectricalValue numeric(19,2),
				@EqpCommunicateValue  numeric(19,2), @EqpInstrumentValue  numeric(19,2),
				@EqpSportValue numeric(19,2), @EqpCulturalValue numeric(19,2), 
				@EqpFurnitureValue numeric(19,2),@intangibleValue numeric(19,2)

		--1.���ɡ�01.���ء�����
		set @LandValue = 0
		set @BuildingValue = 0
		--2.���ɡ�02.���ݼ����������
		--3.���ɡ�03.ͨ���豸������
		insert generalEqp(reportNum, BillDate, QingCXTZCBH, CatalogID, StdName, JiLDWCZB, PinP, Spec,
							JiaZXSName, OrgnValue,
							CaiZXJFLY, ShiYSR, QiZYSWSR, QiTJFLY, QiZCZXJYZJ,
							KuaiJPZH, SrcName, BuildDate, BaoXJZRQ,
							CGZZXS3, UsedStateBDName, UsedwayBDName, ChuZCJDFDW, 
							DPRCTStateName, DPRCTWayName, ExptMonth, UsedMonth, RMValueRate, DeValue,
							PlaceID, BMID, ShiYRName, Remark, Operator, GuanLRID)
		select @reportNum, acceptDate, e.eCode, e.aTypeCode, eName, g.unit, factory,
				case eModel when '*' then eFormat when '' then eFormat else eModel end as '����ͺ�(Spec)',
				'ԭֵ' as '��ֵ����(JiaZXSID)', totalAmount as '��ֵ(OrgnValue)', 
				totalAmount as '�����Բ���(CaiZXJFLY)',	
				0 as '��ҵ����(ShiYSR)',0 as '��ҵ���룺Ԥ��������(QiZYSWSR)', 0 as '�����ʽ�(QiTJFLY)',
				0 as '�����ʽ𣺲����Խ����ʽ�(QiZCZXJYZJ)', 
				'' as '���ƾ֤��(KuaiJPZH)',
				case fCode when '6 ' then '����' else case maker.status when '����' then '����' else '�¹�' end end as 'ȡ�÷�ʽ(SrcID)',
				buyDate as 'ȡ������(BuildDate)', '' as '���޽�ֹ����(BaoXJZRQ)', 
				'���ż��вɹ�' as '�ɹ���֯��ʽ(CGZZXSID)',
				case curEqpStatus when 4 then '�ٻ�������' else '����' end as 'ʹ��״��(UsedStateBDID)',
				'����' as 'ʹ�÷���(UsedwayBDID)','' as '����/����Է���λ(ChuZCJDFDW)',
				'�����۾�' as '�۾�״̬(DPRCTState)', '' as '�۾ɷ���(DPRCTWayID)', null as 'ʹ������/�·�(ExptMonth)', null as '�����۾�����(UsedMonth)',
				null as '��ֵ��(RMValueRate)', null as '��ֵ׼��(DeValue)', 
				'' as '��ŵص�(PlaceID)', t.dCode as 'ʹ��/������(BMID)', '' as 'ʹ����(ShiYRID)', 
				case maker.status when '����' then '����' else '' end as '��ע(Remark)', 
				@maker as '�Ƶ���(Operator)', '' as '������(GuanLRID)'
		from equipmentList e left join GBT14885 g on e.aTypeCode = g.aTypeCode
			left join collegeCode t on e.clgCode = t.clgCode
			left join (select eCode,'����' as status from equipmentList
						where notes like '%����%'
								or factory like '%�人��ѧ%'
								or eModel like '%����%'
								or eFormat like '%����%'
						) as maker on e.eCode = maker.eCode
		where convert(varchar(10),acceptDate,120) <= @totalEndDate
		and e.eCode not in (select eCode from equipmentList where convert(varchar(10),scrapDate,120) < @totalEndDate)
		and e.aTypeCode in (select aTypeCode from GBT14885 where kind in ('03'))
		order by acceptDate
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    

		set @generalEqpValue = isnull((select SUM(OrgnValue) from generalEqp),0)
		--4.���ɡ�04.ר���豸������
		insert specialEqp(reportNum, BillDate, QingCXTZCBH, CatalogID, StdName, JiLDWCZB, PinP, Spec,
							JiaZXSName, OrgnValue,
							CaiZXJFLY, ShiYSR, QiZYSWSR, QiTJFLY, QiZCZXJYZJ,
							KuaiJPZH, SrcName, BuildDate, BaoXJZRQ,
							CGZZXS3, UsedStateBDName, UsedwayBDName, ChuZCJDFDW, 
							DPRCTStateName, DPRCTWayName, ExptMonth, UsedMonth, RMValueRate, DeValue,
							PlaceID, BMID, ShiYRName, Remark, Operator, GuanLRID)
		select @reportNum, acceptDate, e.eCode, e.aTypeCode, eName, g.unit, factory,
				case eModel when '*' then eFormat when '' then eFormat else eModel end as '����ͺ�(Spec)',
				'ԭֵ' as '��ֵ����(JiaZXSID)', totalAmount as '��ֵ(OrgnValue)', 
				totalAmount as '�����Բ���(CaiZXJFLY)',	
				0 as '��ҵ����(ShiYSR)',0 as '��ҵ���룺Ԥ��������(QiZYSWSR)', 0 as '�����ʽ�(QiTJFLY)',
				0 as '�����ʽ𣺲����Խ����ʽ�(QiZCZXJYZJ)', 
				'' as '���ƾ֤��(KuaiJPZH)',
				case fCode when '6 ' then '����' else case maker.status when '����' then '����' else '�¹�' end end as 'ȡ�÷�ʽ(SrcID)',
				buyDate as 'ȡ������(BuildDate)', '' as '���޽�ֹ����(BaoXJZRQ)', 
				'���ż��вɹ�' as '�ɹ���֯��ʽ(CGZZXSID)',
				case curEqpStatus when 4 then '�ٻ�������' else '����' end as 'ʹ��״��(UsedStateBDID)',
				'����' as 'ʹ�÷���(UsedwayBDID)','' as '����/����Է���λ(ChuZCJDFDW)',
				'�����۾�' as '�۾�״̬(DPRCTState)', '' as '�۾ɷ���(DPRCTWayID)', null as 'ʹ������/�·�(ExptMonth)', null as '�����۾�����(UsedMonth)',
				null as '��ֵ��(RMValueRate)', null as '��ֵ׼��(DeValue)', 
				'' as '��ŵص�(PlaceID)', t.dCode as 'ʹ��/������(BMID)', '' as 'ʹ����(ShiYRID)', 
				case maker.status when '����' then '����' else '' end as '��ע(Remark)', 
				@maker as '�Ƶ���(Operator)', '' as '������(GuanLRID)'
		from equipmentList e left join GBT14885 g on e.aTypeCode = g.aTypeCode
			left join collegeCode t on e.clgCode = t.clgCode
			left join (select eCode,'����' as status from equipmentList
						where notes like '%����%'
								or factory like '%�人��ѧ%'
								or eModel like '%����%'
								or eFormat like '%����%'
						) as maker on e.eCode = maker.eCode
		where convert(varchar(10),acceptDate,120) <= @totalEndDate
		and e.eCode not in (select eCode from equipmentList where convert(varchar(10),scrapDate,120) < @totalEndDate)
		and e.aTypeCode in (select aTypeCode from GBT14885 where kind in ('04'))
		order by acceptDate
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    

		set @specialEqpValue = isnull((select SUM(OrgnValue) from specialEqp),0)
		--5.���ɡ�05.��ͨ�����豸������
		insert EqpCar(reportNum, BillDate, QingCXTZCBH, CatalogID, StdName, JiLDWCZB,
						CheLCDName, Spec, CheJH, ChePH, ChangPXH, FaDJH, PaiQL,
						BianZQKName, JiaZXSName, OrgnValue,
						CaiZXJFLY, ShiYSR, QiZYSWSR, QiTJFLY, QiZCZXJYZJ,
						YongTFLName, KuaiJPZH, BuildDate, SrcName, BaoXJZRQ, UseDate, UsedwayBDName,
						ChuZCJDFDW, BMID, ShiYRName, CGZZXS3, UsedStateBDName,
						DPRCTStateName, DPRCTWayName, ExptMonth, UsedMonth, RMValueRate, DeValue,
						Remark, Operator, GuanLRID)
		select @reportNum, acceptDate, e.eCode, e.aTypeCode, eName, g.unit, 
				cd1.objDesc, ext.carModle, ext.chassisNumber, ext.licensePlate, ext.brandModel, ext.engineNumber, ext.powerNumber,
				'�����ڱ�', 'ԭֵ' as '��ֵ����(JiaZXSID)', totalAmount as '��ֵ(OrgnValue)', 
				totalAmount as '�����Բ���(CaiZXJFLY)',	
				0 as '��ҵ����(ShiYSR)',0 as '��ҵ���룺Ԥ��������(QiZYSWSR)', 0 as '�����ʽ�(QiTJFLY)',
				0 as '�����ʽ𣺲����Խ����ʽ�(QiZCZXJYZJ)', 
				cd2.objDesc, '' as '���ƾ֤��(KuaiJPZH)',
				buyDate as 'ȡ������(BuildDate)', 
				case fCode when '6 ' then '����' else case maker.status when '����' then '����' else '�¹�' end end as 'ȡ�÷�ʽ(SrcID)',
				'' as '���޽�ֹ����(BaoXJZRQ)', '' as 'ʹ������',
				'����' as 'ʹ�÷���(UsedwayBDID)', '' as '����/����Է���λ(ChuZCJDFDW)',
				t.dCode as 'ʹ��/������(BMID)', '' as 'ʹ����(ShiYRID)', 
				'���ż��вɹ�' as '�ɹ���֯��ʽ(CGZZXSID)',
				case curEqpStatus when 4 then '�ٻ�������' else '����' end as 'ʹ��״��(UsedStateBDID)',
				'�����۾�' as '�۾�״̬(DPRCTState)', '' as '�۾ɷ���(DPRCTWayID)', null as 'ʹ������/�·�(ExptMonth)', null as '�����۾�����(UsedMonth)',
				null as '��ֵ��(RMValueRate)', null as '��ֵ׼��(DeValue)', 
				case maker.status when '����' then '����' else '' end as '��ע(Remark)', 
				@maker as '�Ƶ���(Operator)', '' as '������(GuanLRID)'
		from equipmentList e left join eqpCarExtInfo ext on e.eCode = ext.eCode 
			left join codeDictionary cd1 on ext.origin = cd1.objCode and cd1.classCode = 20
			left join codeDictionary cd2 on ext.useDirection = cd2.objCode and cd1.classCode = 21
			left join GBT14885 g on e.aTypeCode = g.aTypeCode
			left join collegeCode t on e.clgCode = t.clgCode
			left join (select eCode,'����' as status from equipmentList
						where notes like '%����%'
								or factory like '%�人��ѧ%'
								or eModel like '%����%'
								or eFormat like '%����%'
						) as maker on e.eCode = maker.eCode
		where convert(varchar(10),acceptDate,120) <= @totalEndDate
		and e.eCode not in (select eCode from equipmentList where convert(varchar(10),scrapDate,120) < @totalEndDate)
		and e.aTypeCode in (select aTypeCode from GBT14885 where kind in ('05'))
		order by acceptDate
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    

		set @EqpCarValue = isnull((select SUM(OrgnValue) from EqpCar),0)
		--6.���ɡ�06.�����豸������
		insert EqpElectrical(reportNum, BillDate, QingCXTZCBH, CatalogID, StdName, JiLDWCZB, PinP, Spec,
							JiaZXSName, OrgnValue,
							CaiZXJFLY, ShiYSR, QiZYSWSR, QiTJFLY, QiZCZXJYZJ,
							KuaiJPZH, SrcName, BuildDate, BaoXJZRQ,
							CGZZXS3, UsedStateBDName, UsedwayBDName, ChuZCJDFDW, 
							DPRCTStateName, DPRCTWayName, ExptMonth, UsedMonth, RMValueRate, DeValue,
							PlaceID, BMID, ShiYRName, Remark, Operator, GuanLRID)
		select @reportNum, acceptDate, e.eCode, e.aTypeCode, eName, g.unit, factory,
				case eModel when '*' then eFormat when '' then eFormat else eModel end as '����ͺ�(Spec)',
				'ԭֵ' as '��ֵ����(JiaZXSID)', totalAmount as '��ֵ(OrgnValue)', 
				totalAmount as '�����Բ���(CaiZXJFLY)',	
				0 as '��ҵ����(ShiYSR)',0 as '��ҵ���룺Ԥ��������(QiZYSWSR)', 0 as '�����ʽ�(QiTJFLY)',
				0 as '�����ʽ𣺲����Խ����ʽ�(QiZCZXJYZJ)', 
				'' as '���ƾ֤��(KuaiJPZH)',
				case fCode when '6 ' then '����' else case maker.status when '����' then '����' else '�¹�' end end as 'ȡ�÷�ʽ(SrcID)',
				buyDate as 'ȡ������(BuildDate)', '' as '���޽�ֹ����(BaoXJZRQ)', 
				'���ż��вɹ�' as '�ɹ���֯��ʽ(CGZZXSID)',
				case curEqpStatus when 4 then '�ٻ�������' else '����' end as 'ʹ��״��(UsedStateBDID)',
				'����' as 'ʹ�÷���(UsedwayBDID)','' as '����/����Է���λ(ChuZCJDFDW)',
				'�����۾�' as '�۾�״̬(DPRCTState)', '' as '�۾ɷ���(DPRCTWayID)', null as 'ʹ������/�·�(ExptMonth)', null as '�����۾�����(UsedMonth)',
				null as '��ֵ��(RMValueRate)', null as '��ֵ׼��(DeValue)', 
				'' as '��ŵص�(PlaceID)', t.dCode as 'ʹ��/������(BMID)', '' as 'ʹ����(ShiYRID)', 
				case maker.status when '����' then '����' else '' end as '��ע(Remark)', 
				@maker as '�Ƶ���(Operator)', '' as '������(GuanLRID)'
		from equipmentList e left join GBT14885 g on e.aTypeCode = g.aTypeCode
			left join collegeCode t on e.clgCode = t.clgCode
			left join (select eCode,'����' as status from equipmentList
						where notes like '%����%'
								or factory like '%�人��ѧ%'
								or eModel like '%����%'
								or eFormat like '%����%'
						) as maker on e.eCode = maker.eCode
		where convert(varchar(10),acceptDate,120) <= @totalEndDate
		and e.eCode not in (select eCode from equipmentList where convert(varchar(10),scrapDate,120) < @totalEndDate)
		and e.aTypeCode in (select aTypeCode from GBT14885 where kind in ('06'))
		order by acceptDate
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    

		set @EqpElectricalValue = isnull((select SUM(OrgnValue) from EqpElectrical),0)
		--7.���ɡ�07.���Ӳ�Ʒ��ͨ���豸������
		insert EqpCommunicate(reportNum, BillDate, QingCXTZCBH, CatalogID, StdName, JiLDWCZB, PinP, Spec,
							JiaZXSName, OrgnValue,
							CaiZXJFLY, ShiYSR, QiZYSWSR, QiTJFLY, QiZCZXJYZJ,
							KuaiJPZH, SrcName, BuildDate, BaoXJZRQ,
							CGZZXS3, UsedStateBDName, UsedwayBDName, ChuZCJDFDW, 
							DPRCTStateName, DPRCTWayName, ExptMonth, UsedMonth, RMValueRate, DeValue,
							PlaceID, BMID, ShiYRName, Remark, Operator, GuanLRID)
		select @reportNum, acceptDate, e.eCode, e.aTypeCode, eName, g.unit, factory,
				case eModel when '*' then eFormat when '' then eFormat else eModel end as '����ͺ�(Spec)',
				'ԭֵ' as '��ֵ����(JiaZXSID)', totalAmount as '��ֵ(OrgnValue)', 
				totalAmount as '�����Բ���(CaiZXJFLY)',	
				0 as '��ҵ����(ShiYSR)',0 as '��ҵ���룺Ԥ��������(QiZYSWSR)', 0 as '�����ʽ�(QiTJFLY)',
				0 as '�����ʽ𣺲����Խ����ʽ�(QiZCZXJYZJ)', 
				'' as '���ƾ֤��(KuaiJPZH)',
				case fCode when '6 ' then '����' else case maker.status when '����' then '����' else '�¹�' end end as 'ȡ�÷�ʽ(SrcID)',
				buyDate as 'ȡ������(BuildDate)', '' as '���޽�ֹ����(BaoXJZRQ)', 
				'���ż��вɹ�' as '�ɹ���֯��ʽ(CGZZXSID)',
				case curEqpStatus when 4 then '�ٻ�������' else '����' end as 'ʹ��״��(UsedStateBDID)',
				'����' as 'ʹ�÷���(UsedwayBDID)','' as '����/����Է���λ(ChuZCJDFDW)',
				'�����۾�' as '�۾�״̬(DPRCTState)', '' as '�۾ɷ���(DPRCTWayID)', null as 'ʹ������/�·�(ExptMonth)', null as '�����۾�����(UsedMonth)',
				null as '��ֵ��(RMValueRate)', null as '��ֵ׼��(DeValue)', 
				'' as '��ŵص�(PlaceID)', t.dCode as 'ʹ��/������(BMID)', '' as 'ʹ����(ShiYRID)', 
				case maker.status when '����' then '����' else '' end as '��ע(Remark)', 
				@maker as '�Ƶ���(Operator)', '' as '������(GuanLRID)'
		from equipmentList e left join GBT14885 g on e.aTypeCode = g.aTypeCode
			left join collegeCode t on e.clgCode = t.clgCode
			left join (select eCode,'����' as status from equipmentList
						where notes like '%����%'
								or factory like '%�人��ѧ%'
								or eModel like '%����%'
								or eFormat like '%����%'
						) as maker on e.eCode = maker.eCode
		where convert(varchar(10),acceptDate,120) <= @totalEndDate
		and e.eCode not in (select eCode from equipmentList where convert(varchar(10),scrapDate,120) < @totalEndDate)
		and e.aTypeCode in (select aTypeCode from GBT14885 where kind in ('07'))
		order by acceptDate
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    

		set @EqpCommunicateValue = isnull((select SUM(OrgnValue) from EqpCommunicate),0)
		--8.���ɡ�08.�����Ǳ�������׼���߼����ߡ�����������
		insert EqpInstrument(reportNum, BillDate, QingCXTZCBH, CatalogID, StdName, JiLDWCZB, PinP, Spec,
							JiaZXSName, OrgnValue,
							CaiZXJFLY, ShiYSR, QiZYSWSR, QiTJFLY, QiZCZXJYZJ,
							KuaiJPZH, SrcName, BuildDate, BaoXJZRQ,
							CGZZXS3, UsedStateBDName, UsedwayBDName, ChuZCJDFDW, 
							DPRCTStateName, DPRCTWayName, ExptMonth, UsedMonth, RMValueRate, DeValue,
							PlaceID, BMID, ShiYRName, Remark, Operator, GuanLRID)
		select @reportNum, acceptDate, e.eCode, e.aTypeCode, eName, g.unit, factory,
				case eModel when '*' then eFormat when '' then eFormat else eModel end as '����ͺ�(Spec)',
				'ԭֵ' as '��ֵ����(JiaZXSID)', totalAmount as '��ֵ(OrgnValue)', 
				totalAmount as '�����Բ���(CaiZXJFLY)',	
				0 as '��ҵ����(ShiYSR)',0 as '��ҵ���룺Ԥ��������(QiZYSWSR)', 0 as '�����ʽ�(QiTJFLY)',
				0 as '�����ʽ𣺲����Խ����ʽ�(QiZCZXJYZJ)', 
				'' as '���ƾ֤��(KuaiJPZH)',
				case fCode when '6 ' then '����' else case maker.status when '����' then '����' else '�¹�' end end as 'ȡ�÷�ʽ(SrcID)',
				buyDate as 'ȡ������(BuildDate)', '' as '���޽�ֹ����(BaoXJZRQ)', 
				'���ż��вɹ�' as '�ɹ���֯��ʽ(CGZZXSID)',
				case curEqpStatus when 4 then '�ٻ�������' else '����' end as 'ʹ��״��(UsedStateBDID)',
				'����' as 'ʹ�÷���(UsedwayBDID)','' as '����/����Է���λ(ChuZCJDFDW)',
				'�����۾�' as '�۾�״̬(DPRCTState)', '' as '�۾ɷ���(DPRCTWayID)', null as 'ʹ������/�·�(ExptMonth)', null as '�����۾�����(UsedMonth)',
				null as '��ֵ��(RMValueRate)', null as '��ֵ׼��(DeValue)', 
				'' as '��ŵص�(PlaceID)', t.dCode as 'ʹ��/������(BMID)', '' as 'ʹ����(ShiYRID)', 
				case maker.status when '����' then '����' else '' end as '��ע(Remark)', 
				@maker as '�Ƶ���(Operator)', '' as '������(GuanLRID)'
		from equipmentList e left join GBT14885 g on e.aTypeCode = g.aTypeCode
			left join collegeCode t on e.clgCode = t.clgCode
			left join (select eCode,'����' as status from equipmentList
						where notes like '%����%'
								or factory like '%�人��ѧ%'
								or eModel like '%����%'
								or eFormat like '%����%'
						) as maker on e.eCode = maker.eCode
		where convert(varchar(10),acceptDate,120) <= @totalEndDate
		and e.eCode not in (select eCode from equipmentList where convert(varchar(10),scrapDate,120) < @totalEndDate)
		and e.aTypeCode in (select aTypeCode from GBT14885 where kind in ('08'))
		order by acceptDate
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    

		set @EqpInstrumentValue = isnull((select SUM(OrgnValue) from EqpInstrument),0)
		--9.���ɡ�09.���������豸������
		insert EqpSport(reportNum, BillDate, QingCXTZCBH, CatalogID, StdName, JiLDWCZB, PinP, Spec, QTY,
							JiaZXSName, OrgnValue,
							CaiZXJFLY, ShiYSR, QiZYSWSR, QiTJFLY, QiZCZXJYZJ,
							KuaiJPZH, SrcName, BuildDate, BaoXJZRQ,
							CGZZXS3, UsedStateBDName, UsedwayBDName, ChuZCJDFDW, 
							DPRCTStateName, DPRCTWayName, ExptMonth, UsedMonth, RMValueRate, DeValue,
							PlaceID, BMID, ShiYRName, Remark, Operator, GuanLRID)
		select @reportNum, acceptDate, e.eCode, e.aTypeCode, eName, g.unit, factory,
				case eModel when '*' then eFormat when '' then eFormat else eModel end as '����ͺ�(Spec)', 1,
				'ԭֵ' as '��ֵ����(JiaZXSID)', totalAmount as '��ֵ(OrgnValue)', 
				totalAmount as '�����Բ���(CaiZXJFLY)',	
				0 as '��ҵ����(ShiYSR)',0 as '��ҵ���룺Ԥ��������(QiZYSWSR)', 0 as '�����ʽ�(QiTJFLY)',
				0 as '�����ʽ𣺲����Խ����ʽ�(QiZCZXJYZJ)', 
				'' as '���ƾ֤��(KuaiJPZH)',
				case fCode when '6 ' then '����' else case maker.status when '����' then '����' else '�¹�' end end as 'ȡ�÷�ʽ(SrcID)',
				buyDate as 'ȡ������(BuildDate)', '' as '���޽�ֹ����(BaoXJZRQ)', 
				'���ż��вɹ�' as '�ɹ���֯��ʽ(CGZZXSID)',
				case curEqpStatus when 4 then '�ٻ�������' else '����' end as 'ʹ��״��(UsedStateBDID)',
				'����' as 'ʹ�÷���(UsedwayBDID)','' as '����/����Է���λ(ChuZCJDFDW)',
				'�����۾�' as '�۾�״̬(DPRCTState)', '' as '�۾ɷ���(DPRCTWayID)', null as 'ʹ������/�·�(ExptMonth)', null as '�����۾�����(UsedMonth)',
				null as '��ֵ��(RMValueRate)', null as '��ֵ׼��(DeValue)', 
				'' as '��ŵص�(PlaceID)', t.dCode as 'ʹ��/������(BMID)', '' as 'ʹ����(ShiYRID)', 
				case maker.status when '����' then '����' else '' end as '��ע(Remark)', 
				@maker as '�Ƶ���(Operator)', '' as '������(GuanLRID)'
		from equipmentList e left join GBT14885 g on e.aTypeCode = g.aTypeCode
			left join collegeCode t on e.clgCode = t.clgCode
			left join (select eCode,'����' as status from equipmentList
						where notes like '%����%'
								or factory like '%�人��ѧ%'
								or eModel like '%����%'
								or eFormat like '%����%'
						) as maker on e.eCode = maker.eCode
		where convert(varchar(10),acceptDate,120) <= @totalEndDate
		and e.eCode not in (select eCode from equipmentList where convert(varchar(10),scrapDate,120) < @totalEndDate)
		and e.aTypeCode in (select aTypeCode from GBT14885 where kind in ('09'))
		order by acceptDate
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    

		set @EqpSportValue = isnull((select SUM(OrgnValue) from EqpSport),0)
		--10.���ɡ�10.ͼ�顢���Ｐ����Ʒ������
		insert EqpCultural(reportNum, BillDate, QingCXTZCBH, CatalogID, StdName, JiLDWCZB, QTY,
							WenWDJName, PlaceID, ZuoLWZ, JiaZXSName, OrgnValue,
							CaiZXJFLY, ShiYSR, QiZYSWSR, QiTJFLY, QiZCZXJYZJ,
							KuaiJPZH, CGZZXS3, UsedStateBDName, UsedwayBDName, BuildDate, SrcName,
							ChanQXSName, BMID, GuanLDW, ShiYRName, Remark, Operator, GuanLRID)
		select @reportNum, acceptDate, e.eCode, e.aTypeCode, eName, g.unit, 1,
				'', '', '',  'ԭֵ' as '��ֵ����(JiaZXSID)', totalAmount as '��ֵ(OrgnValue)', 
				totalAmount as '�����Բ���(CaiZXJFLY)',	
				0 as '��ҵ����(ShiYSR)',0 as '��ҵ���룺Ԥ��������(QiZYSWSR)', 0 as '�����ʽ�(QiTJFLY)',
				0 as '�����ʽ𣺲����Խ����ʽ�(QiZCZXJYZJ)', 
				'' as '���ƾ֤��(KuaiJPZH)',
				'���ż��вɹ�' as '�ɹ���֯��ʽ(CGZZXSID)',
				case curEqpStatus when 4 then '�ٻ�������' else '����' end as 'ʹ��״��(UsedStateBDID)',
				'����' as 'ʹ�÷���(UsedwayBDID)',
				buyDate as 'ȡ������(BuildDate)', 
				case fCode when '6 ' then '����' else case maker.status when '����' then '����' else '�¹�' end end as 'ȡ�÷�ʽ(SrcID)',
				'�в�Ȩ' as ��Ȩ��ʽ,
				t.dCode as 'ʹ��/������(BMID)', '' as '����λ(����)',
				'' as 'ʹ����(ShiYRID)', 
				case maker.status when '����' then '����' else '' end as '��ע(Remark)', 
				@maker as '�Ƶ���(Operator)', '' as '������(GuanLRID)'
		from equipmentList e left join GBT14885 g on e.aTypeCode = g.aTypeCode
			left join collegeCode t on e.clgCode = t.clgCode
			left join (select eCode,'����' as status from equipmentList
						where notes like '%����%'
								or factory like '%�人��ѧ%'
								or eModel like '%����%'
								or eFormat like '%����%'
						) as maker on e.eCode = maker.eCode
		where convert(varchar(10),acceptDate,120) <= @totalEndDate
		and e.eCode not in (select eCode from equipmentList where convert(varchar(10),scrapDate,120) < @totalEndDate)
		and e.aTypeCode in (select aTypeCode from GBT14885 where kind in ('10'))
		order by acceptDate
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    

		set @EqpCulturalValue = isnull((select SUM(OrgnValue) from EqpCultural),0)
		--11.���ɡ�11.�Ҿ��þ߼������ࡱ����
		insert EqpFurniture(reportNum, BillDate, QingCXTZCBH, CatalogID, StdName, JiLDWCZB, PinP, Spec, QTY,
							JiaZXSName, OrgnValue,
							CaiZXJFLY, ShiYSR, QiZYSWSR, QiTJFLY, QiZCZXJYZJ,
							KuaiJPZH, SrcName, BuildDate, BaoXJZRQ,
							CGZZXS3, UsedStateBDName, UsedwayBDName, ChuZCJDFDW, 
							DPRCTStateName, DPRCTWayName, ExptMonth, UsedMonth, RMValueRate, DeValue,
							PlaceID, BMID, ShiYRName, Remark, Operator, GuanLRID)
		select @reportNum, acceptDate, e.eCode, e.aTypeCode, eName, g.unit, factory,
				case eModel when '*' then eFormat when '' then eFormat else eModel end as '����ͺ�(Spec)', 1,
				'ԭֵ' as '��ֵ����(JiaZXSID)', totalAmount as '��ֵ(OrgnValue)', 
				totalAmount as '�����Բ���(CaiZXJFLY)',	
				0 as '��ҵ����(ShiYSR)',0 as '��ҵ���룺Ԥ��������(QiZYSWSR)', 0 as '�����ʽ�(QiTJFLY)',
				0 as '�����ʽ𣺲����Խ����ʽ�(QiZCZXJYZJ)', 
				'' as '���ƾ֤��(KuaiJPZH)',
				case fCode when '6 ' then '����' else case maker.status when '����' then '����' else '�¹�' end end as 'ȡ�÷�ʽ(SrcID)',
				buyDate as 'ȡ������(BuildDate)', '' as '���޽�ֹ����(BaoXJZRQ)', 
				'���ż��вɹ�' as '�ɹ���֯��ʽ(CGZZXSID)',
				case curEqpStatus when 4 then '�ٻ�������' else '����' end as 'ʹ��״��(UsedStateBDID)',
				'����' as 'ʹ�÷���(UsedwayBDID)','' as '����/����Է���λ(ChuZCJDFDW)',
				'�����۾�' as '�۾�״̬(DPRCTState)', '' as '�۾ɷ���(DPRCTWayID)', null as 'ʹ������/�·�(ExptMonth)', null as '�����۾�����(UsedMonth)',
				null as '��ֵ��(RMValueRate)', null as '��ֵ׼��(DeValue)', 
				'' as '��ŵص�(PlaceID)', t.dCode as 'ʹ��/������(BMID)', '' as 'ʹ����(ShiYRID)', 
				case maker.status when '����' then '����' else '' end as '��ע(Remark)', 
				@maker as '�Ƶ���(Operator)', '' as '������(GuanLRID)'
		from equipmentList e left join GBT14885 g on e.aTypeCode = g.aTypeCode
			left join collegeCode t on e.clgCode = t.clgCode
			left join (select eCode,'����' as status from equipmentList
						where notes like '%����%'
								or factory like '%�人��ѧ%'
								or eModel like '%����%'
								or eFormat like '%����%'
						) as maker on e.eCode = maker.eCode
		where convert(varchar(10),acceptDate,120) <= @totalEndDate
		and e.eCode not in (select eCode from equipmentList where convert(varchar(10),scrapDate,120) < @totalEndDate)
		and e.aTypeCode in (select aTypeCode from GBT14885 where kind in ('11'))
		order by acceptDate
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    

		set @EqpFurnitureValue = isnull((select SUM(OrgnValue) from EqpFurniture),0)
		--12.���ɡ�12.�����ʲ�������
		set @intangibleValue = 0
		
		--д������Ϣ��
		update CZreportCenter
				--�ʲ����豸�����������Ϣ��
		set LandValue = @LandValue,					--1.���غϼƽ��
			BuildingValue = @BuildingValue,			--2.���ݹ�����ϼƽ��
			generalEqpValue = @generalEqpValue,		--3.ͨ���豸�ϼƽ��
			specialEqpValue = @specialEqpValue,		--4.ר���豸�ϼƽ��
			EqpCarValue = @EqpCarValue,				--5.��ͨ�����豸�ϼƽ��
			EqpElectricalValue = @EqpElectricalValue,--6.�����豸�ϼƽ��
			EqpCommunicateValue = @EqpCommunicateValue,--7.���Ӳ�Ʒ��ͨ���豸�ϼƽ��
			EqpInstrumentValue = @EqpInstrumentValue,--8.�����Ǳ����ߺϼƽ��
			EqpSportValue = @EqpSportValue,			--9.���������豸�ϼƽ��
			EqpCulturalValue = @EqpCulturalValue,	--10.ͼ�����Ｐ����Ʒ�ϼƽ��
			EqpFurnitureValue = @EqpFurnitureValue,	--11.�Ҿ��þ߼�������ϼƽ��
			intangibleValue = @intangibleValue		--12.�����ʲ��ϼƽ��
		where reportNum = @reportNum
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    
	commit tran	
	set @Ret = 0
	--д������־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@makerID, @maker, @makeDate, '���ɲ���������', 'ϵͳ�����û�' + @maker + 
					'��Ҫ�������˲���������[' + @reportNum + ']��')

go

--���ԣ�
declare @Ret int , @reportNum varchar(12)
exec dbo.makeCReport '2011�����������','2011','2011-12-31','�人��ѧ�豸��','00200977',@Ret output, @reportNum output
SELECT @Ret, @reportNum


select * from equipmentList
select * from collegeCode

select * from CZreportCenter
select * from generalEqp
select * from EqpFurniture
select * from CZreportCenter
select * from EqpCar

drop PROCEDURE delCZReport
/*
	name:		delCZReport
	function:	2.ɾ��ָ���Ĳ���������
	input: 
				@reportNum varchar(12),			--������
				@delManID varchar(10) output,	--ɾ����
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���ı������ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2012-10-2
	UpdateDate: 

*/
create PROCEDURE delCZReport
	@reportNum varchar(12),			--������
	@delManID varchar(10) output,	--ɾ����
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���ı����Ƿ����
	declare @count as int
	set @count=(select count(*) from CZreportCenter where reportNum = @reportNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end


	delete CZreportCenter where reportNum = @reportNum
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ������������', '�û�' + @delManName
												+ 'ɾ���˲���������['+ @reportNum +']��')

GO


drop PROCEDURE importCollege
/*
	name:		importCollege
	function:	3.ע����ϵͳ�еĵ�λ�б���������λӳ�����
	input: 
				@modiManID varchar(10) output,	--ά����
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-10-8
	UpdateDate: 

*/
create PROCEDURE importCollege
	@modiManID varchar(10) output,	--ά����
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	insert collegeCode(clgCode, clgName, createManID, createManName, createTime)
	select clgCode, clgName, @modiManID, @modiManName, GETDATE()
	from college clg
	where clgCode not in (select clgCode from collegeCode)
	if @@ERROR <> 0 
	begin
		return
	end    

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, getdate(), '���µ�λӳ���', '�û�' + @modiManName
												+ '�����˲�������λӳ���')

GO
--���ԣ�
declare @ret int
exec dbo.importCollege '00000000000', @ret output
select @ret

select * from collegeCode

drop PROCEDURE queryCollegeCodeLocMan
/*
	name:		queryCollegeCodeLocMan
	function:	4.��ѯָ����������λӳ����е�λ�Ƿ��������ڱ༭
	input: 
				@clgCode char(3),				--������Ժ������
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ���ĵ�λ������
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2012-10-11
	UpdateDate: 
*/
create PROCEDURE queryCollegeCodeLocMan
	@clgCode char(3),				--������Ժ������
	@Ret int output,				--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from collegeCode where clgCode = @clgCode),'')
	set @Ret = 0
GO


drop PROCEDURE lockCollegeCode4Edit
/*
	name:		lockCollegeCode4Edit
	function:	5.������������λӳ����е�λ�༭������༭��ͻ
	input: 
				@clgCode char(3),				--������Ժ������
				@lockManID varchar(10) output,	--�����ˣ������ǰ��λӳ��������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����ĵ�λ�����ڣ�2:Ҫ�����ĵ�λ���ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-10-11
	UpdateDate: 
*/
create PROCEDURE lockCollegeCode4Edit
	@clgCode char(3),				--������Ժ������
	@lockManID varchar(10) output,	--�����ˣ������ǰ��λӳ��������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����ĵ�λ�Ƿ����
	declare @count as int
	set @count=(select count(*) from collegeCode where clgCode = @clgCode)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from collegeCode where clgCode = @clgCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	update collegeCode
	set lockManID = @lockManID 
	where clgCode = @clgCode
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '����ӳ�䵥λ�༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˲�������λӳ����е�λ['+ @clgCode +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockCollegeCodeEditor
/*
	name:		unlockCollegeCodeEditor
	function:	6.�ͷŲ�������λӳ����е�λ�༭��
				ע�⣺�����̲���鵥λ�Ƿ���ڣ�
	input: 
				@clgCode char(3),				--������Ժ������
				@lockManID varchar(10) output,	--�����ˣ������ǰ��������λӳ����е�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-10-11
	UpdateDate: 
*/
create PROCEDURE unlockCollegeCodeEditor
	@clgCode char(3),				--������Ժ������
	@lockManID varchar(10) output,	--�����ˣ������ǰ��������λӳ����е�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from collegeCode where clgCode = @clgCode),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update collegeCode set lockManID = '' where clgCode = @clgCode
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
	values(@lockManID, @lockManName, getdate(), '�ͷŵ�λӳ��༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ��˲�������λӳ����е�λ['+ @clgCode+']�ı༭����')
GO

drop PROCEDURE updateCollegeMap
/*
	name:		updateCollegeMap
	function:	7.���µ�λӳ��
	input: 
				@clgCode char(3),			--������Ժ������
				@dCode varchar(7),			--����������ϵͳԺ������
				@dName nvarchar(30),		--����������ϵͳԺ������
				@remark nvarchar(50),		--��ע

				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ��������λӳ����е�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ���ĵ�λ�����ڣ�
							2��Ҫ���µĵ�λ��������������
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-10-10
	UpdateDate: 
*/
create PROCEDURE updateCollegeMap
	@clgCode char(3),			--������Ժ������
	@dCode varchar(7),			--����������ϵͳԺ������
	@dName nvarchar(30),		--����������ϵͳԺ������
	@remark nvarchar(50),		--��ע
	
	--ά����:
	@modiManID varchar(10) output,		--ά���ˣ������ǰ��������λӳ����е�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,	--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ���Ĳ�������λӳ����е�λ�Ƿ����
	declare @count as int
	set @count=(select count(*) from collegeCode where clgCode = @clgCode)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from collegeCode
	where clgCode = @clgCode
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update collegeCode
	set dCode = @dCode, dName = @dName, remark = @remark,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where clgCode = @clgCode
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '���µ�λӳ��', '�û�' + @modiManName 
												+ '�����˲�������λӳ����е�λ['+ @clgCode +']��ӳ�䡣')
GO

drop PROCEDURE delCollegeCode
/*
	name:		delCollegeCode
	function:	8.ɾ��ָ���ĵ�λ
	input: 
				@clgCode char(3),				--������Ժ������
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ��������λӳ����е�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���ĵ�λ�����ڣ�2��Ҫɾ���ĵ�λ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2012-10-11
	UpdateDate: 

*/
create PROCEDURE delCollegeCode
	@clgCode char(3),			--������Ժ������
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ��������λӳ����е�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���ĵ�λ�Ƿ����
	declare @count as int
	set @count=(select count(*) from collegeCode where clgCode = @clgCode)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from collegeCode
	where clgCode = @clgCode
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete collegeCode where clgCode = @clgCode
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ��ӳ�䵥λ', '�û�' + @delManName
												+ 'ɾ���˲�������λӳ����е�λ['+ @clgCode+']��')

GO


drop PROCEDURE clearCollegeMap
/*
	name:		clearCollegeMap
	function:	9.���ָ����λ�Ĳ�����ӳ�䵥λ
	input: 
				@clgCode char(3),				--������Ժ������
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ��������λӳ����е�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���ĵ�λ�����ڣ�2��Ҫ���ӳ��ĵ�λ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2012-10-11
	UpdateDate: 

*/
create PROCEDURE clearCollegeMap
	@clgCode char(3),			--������Ժ������
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ��������λӳ����е�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���ĵ�λ�Ƿ����
	declare @count as int
	set @count=(select count(*) from collegeCode where clgCode = @clgCode)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from collegeCode
	where clgCode = @clgCode
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	update collegeCode 
	set dCode='', dName='', remark=''
	where clgCode = @clgCode
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '�����λӳ��', '�û�' + @delManName
												+ '����˲�������λӳ����е�λ['+ @clgCode+']��ӳ�䡣')

GO

select * from collegeCode


--ʹ��broker�ڲ��������ִ��makeCReport�洢���̣�
USE master;
GO
ALTER DATABASE epdc2
      SET ENABLE_BROKER;
GO
USE epdc2;
GO

--������Ϣ����:
CREATE MESSAGE TYPE [RequestMessage] VALIDATION = WELL_FORMED_XML;
CREATE MESSAGE TYPE [ReplyMessage] VALIDATION = WELL_FORMED_XML;
GO


--����Լ��:
CREATE CONTRACT [SampleContract]
      ([RequestMessage]
       SENT BY INITIATOR,
       [ReplyMessage]
       SENT BY TARGET
      );
GO



--����Ŀ����кͷ���:
CREATE QUEUE TargetQueueIntAct;

CREATE SERVICE
       [TargetService]
       ON QUEUE TargetQueueIntAct
          ([SampleContract]);
GO



--�������𷽶��кͷ���:
CREATE QUEUE InitiatorQueueIntAct;

CREATE SERVICE
       [InitiatorService]
       ON QUEUE InitiatorQueueIntAct;
GO

alter procedure talk
	@msg nvarchar(300)
as
	DECLARE @conversationHandle uniqueidentifier
	Begin Transaction
		BEGIN DIALOG @conversationHandle
			 FROM SERVICE [InitiatorService]
			 TO SERVICE N'TargetService'
			 ON CONTRACT [SampleContract]
			 WITH ENCRYPTION = OFF;
		
		SEND ON CONVERSATION @conversationHandle
              MESSAGE TYPE [RequestMessage] (@msg);

	commit Transaction
go

alter procedure apply
	@msg nvarchar(300)
as
	DECLARE @conversationHandle uniqueidentifier
	Begin Transaction
		BEGIN DIALOG @conversationHandle
			 FROM SERVICE [TargetService]
			 TO SERVICE N'InitiatorService'
			 ON CONTRACT [SampleContract]
			 WITH ENCRYPTION = OFF;
		
		SEND ON CONVERSATION @conversationHandle
              MESSAGE TYPE [RequestMessage] (@msg);

	commit Transaction
go

select * from InitiatorQueueIntAct
select * from TargetQueueIntAct
exec dbo.talk '<a>Hello<a>'
exec dbo.apply '<a>apply<a>'

--�����ڲ�����洢����:
drop PROCEDURE TargetActivProc
alter PROCEDURE TargetActivProc
AS
  DECLARE @RecvReqDlgHandle UNIQUEIDENTIFIER;
  DECLARE @RecvReqMsg NVARCHAR(300);
  DECLARE @RecvReqMsgName sysname;

  WHILE (1=1)
  BEGIN

    BEGIN TRANSACTION;

    WAITFOR
    ( RECEIVE TOP(1)
        @RecvReqDlgHandle = conversation_handle,
        @RecvReqMsg = message_body,
        @RecvReqMsgName = message_type_name
      FROM TargetQueueIntAct
    ), TIMEOUT 5000;

    IF (@@ROWCOUNT = 0)
    BEGIN
      ROLLBACK TRANSACTION;
      BREAK;
    END

    IF @RecvReqMsgName = N'RequestMessage'
    BEGIN
		--declare @ReplyMsg nvarchar(300)
		--set @ReplyMsg = N'<ReplyMsg>'+
		--						'<status>Start</status>'+
		--						'<Msg>ϵͳ�Ѿ����յ������������ڵ���ִ�д洢����</Msg>'+
		--					'</ReplyMsg>';
		--exec dbo.talk @ReplyMsg
              
		declare @x xml
		set @x = @RecvReqMsg;
        --��ȡ�������ͣ�
		declare @type varchar(30)
		set @type = (select cast(@x.query('data(/RequestMsg/oprType)') as varchar(30)))
		if (@type='Exec makeCReport')
		begin
			declare @Ret int,@reportNum varchar(12)			--�����ɹ���ʶ��0:�ɹ���9:δ֪����/������
			declare @theTitle nvarchar(100)		--�������
			declare @theYear varchar(4)			--ͳ�����
			declare @totalEndDate varchar(10)	--ͳ�ƽ�������:"yyyy-MM-dd"��ʽ
			declare @makeUnit nvarchar(50)		--�Ʊ�λ
			declare @makerID varchar(10)		--�Ʊ��˹���
			set @theTitle = (select cast(@x.query('data(/RequestMsg/para/theTitle)') as nvarchar(100)))
			set @theYear = (select cast(@x.query('data(/RequestMsg/para/theYear)') as varchar(4)))
			set @totalEndDate = (select cast(@x.query('data(/RequestMsg/para/totalEndDate)') as varchar(10)))
			set @makeUnit = (select cast(@x.query('data(/RequestMsg/para/makeUnit)') as nvarchar(50)))
			set @makerID = (select cast(@x.query('data(/RequestMsg/para/makerID)') as varchar(10)))
			
			exec dbo.makeCReport @theTitle, @theYear, @totalEndDate, @makeUnit, @makerID, @Ret output, @reportNum output
			
			declare @ReplyMsg nvarchar(300)
			if (@Ret=0)
				set @ReplyMsg = N'<ReplyMsg>'+
									'<status>Completed</status>'+
									'<result>Success:'+@reportNum+'</result>'+
									'<Msg>ϵͳ��������Ĵ�����������</Msg>'+
								'</ReplyMsg>';
			else
				set @ReplyMsg = N'<ReplyMsg>'+
									'<status>Completed</status>'+
									'<result>Error:ִ�г���</result>'+
									'<Msg>ϵͳ��ִ�����Ĵ�����������ʱ����</Msg>'+
								'</ReplyMsg>';
	 
			SEND ON CONVERSATION @RecvReqDlgHandle
				  MESSAGE TYPE [ReplyMessage] (@ReplyMsg);
		end
    END
    ELSE IF @RecvReqMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
       END CONVERSATION @RecvReqDlgHandle;
    END
    ELSE IF @RecvReqMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN
       END CONVERSATION @RecvReqDlgHandle;
    END
      
    COMMIT TRANSACTION;
  END
GO


--����Ŀ�������ָ���ڲ�����:
ALTER QUEUE TargetQueueIntAct
    WITH ACTIVATION
    ( STATUS = ON,
      PROCEDURE_NAME = TargetActivProc,
      MAX_QUEUE_READERS = 10,
      EXECUTE AS SELF
    );
GO


--�����Ự������������Ϣ:
DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
DECLARE @RequestMsg NVARCHAR(300);

BEGIN TRANSACTION;

BEGIN DIALOG @InitDlgHandle
     FROM SERVICE [InitiatorService]
     TO SERVICE N'TargetService'
     ON CONTRACT [SampleContract]
     WITH ENCRYPTION = OFF;

set @RequestMsg =N'<RequestMsg>'+
						'<oprType>Exec makeCReport</oprType>'+
						'<para>'+
							'<theTitle>���Ա���</theTitle>'+
							'<theYear>2011</theYear>'+
							'<totalEndDate>2011-12-31</totalEndDate>'+
							'<makeUnit>�人��ѧ</makeUnit>'+
							'<makerID>00000015</makerID>'+
						'</para>'+
						'<Msg>����ִ�д������makeCReport��</Msg>'+
					'</RequestMsg>';

SEND ON CONVERSATION @InitDlgHandle
     MESSAGE TYPE [RequestMessage] (@RequestMsg);

-- Diplay sent request.
--SELECT @RequestMsg AS SentRequestMsg;

COMMIT TRANSACTION;
GO

--�������
select * from CZreportCenter
delete CZreportCenter

--���մ𸴲������Ự��
DECLARE @RecvReplyMsg NVARCHAR(300);
DECLARE @RecvReplyDlgHandle UNIQUEIDENTIFIER;

BEGIN TRANSACTION;

WAITFOR
( RECEIVE TOP(1)
    @RecvReplyDlgHandle = conversation_handle,
    @RecvReplyMsg = message_body
    FROM InitiatorQueueIntAct
), TIMEOUT 5000;

END CONVERSATION @RecvReplyDlgHandle;

-- Display recieved request.
SELECT @RecvReplyMsg AS ReceivedReplyMsg;

COMMIT TRANSACTION;
GO

--ɾ���Ự����
IF EXISTS (SELECT * FROM sys.objects
           WHERE name = N'TargetActivProc')
     DROP PROCEDURE TargetActivProc;

IF EXISTS (SELECT * FROM sys.services
           WHERE name = N'TargetService')
     DROP SERVICE [TargetService];

IF EXISTS (SELECT * FROM sys.service_queues
           WHERE name = N'TargetQueueIntAct')
     DROP QUEUE TargetQueueIntAct;

-- Drop the intitator queue and service if they already exist.
IF EXISTS (SELECT * FROM sys.services
           WHERE name = N'InitiatorService')
     DROP SERVICE [InitiatorService];

IF EXISTS (SELECT * FROM sys.service_queues
           WHERE name = N'InitiatorQueueIntAct')
     DROP QUEUE InitiatorQueueIntAct;

-- Drop contract and message type if they already exist.
IF EXISTS (SELECT * FROM sys.service_contracts
           WHERE name = N'SampleContract')
     DROP CONTRACT [SampleContract];

IF EXISTS (SELECT * FROM sys.service_message_types
           WHERE name = N'RequestMessage')
     DROP MESSAGE TYPE [RequestMessage];

IF EXISTS (SELECT * FROM sys.service_message_types
           WHERE name = N'ReplyMessage')
     DROP MESSAGE TYPE [ReplyMessage];


