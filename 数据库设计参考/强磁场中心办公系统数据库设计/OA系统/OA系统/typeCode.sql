use hustOA
/*
	����豸������Ϣϵͳ-�������
	author:		¬έ
	CreateDate:	2012-10-5
	UpdateDate: modi by lw 1011-10-16���豸��������ֲ��4�����������ࡢ���ࡢ�������������ӷ���������ʽ�ֶ�
				modi by lw 2012-10-5����������������������������������ƣ������޶��ı���������֯���������һ�Զ�Ĺ�ϵ�������µ�������
				
*/
select '=trim("'+aTypeCode+'"',aTypeName,unit, case level when -2 then '��ϸ��' else '' end from GBT14885 where abs(Level) = 2
select  '=trim("'+aTypeCode+'"',aTypeName,unit, Level from GBT14885 where classCode=''
--�������̶��ʲ���������GB/T 14885-1994����
DROP TABLE GBT14885
CREATE TABLE [dbo].[GBT14885](
	RwID int NOT NULL,						--���
	kind varchar(2) not null,				--������
	kindName nvarchar(20) not null,			--��������
	category varchar(2) not null,			--������
	classCode varchar(1) null,				--������
	subClassCode varchar(1) null,			--С����
	itemCode varchar(2) null,				--ϸ����
	
	aTypeCode varchar(7) NOT NULL,			--��׼����
	aTypeName nvarchar(60) NOT NULL,		--��׼����
	unit nvarchar(10) NULL,					--������λ
	QTYUnit varchar(60) NULL DEFAULT (''),	--������λ
	PrntCode varchar(60) NULL DEFAULT (''),	--���νṹ����
	[Level] int NULL DEFAULT ((-1)),		--���Σ���Ϊ������ʱ���ʾ��ϸ����
	ShrtNm varchar(25) NULL DEFAULT (''),
	[Desc] varchar(255) NULL DEFAULT(''),	--����

	inputCode varchar(5) null,				--������
	isOff char(1) null default('0') ,		--ͣ�ñ�ʶ:��0���������ã���1������ͣ��
	offDate smalldatetime null,				--ͣ������

	CreateDate smalldatetime NULL,			--����ʱ��
	ModifyDate smalldatetime NULL,			--�޸�ʱ��
	Creater nvarchar(30) NULL DEFAULT(''),	--������
	RwVrsn int NULL DEFAULT ((0)),			--�汾
PRIMARY KEY NONCLUSTERED 
(
	[RwID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

--������Դ��	
insert GBT14885
SELECT Rwid, g.kind, g.kindName, g.classCode, g.subClassCode, g.itemCode, 
	A.StdCode, a.StdName, a.JLDW, a.QTYUnit, a.PrntCode, a.Level, a.ShrtNm, a.Description, UPPER(dbo.getChinaPYCode(a.StdName)), '0', null, 
	GETDATE(), a.ModifyDate, 'lw', a.RwVrsn
FROM [WHDX_AID].[dbo].[JC_AssetCatalog] a left join  e.dbo.GBT14885 g on a.StdCode = g.aTypeCode
order by StdCode


select category, * from [GBT14885]
update GBT14885
set category = left(aTypeCode,2),
	classCode = substring(aTypeCode,3,1),
	subClassCode = substring(aTypeCode,4,1),
	itemCode = substring(aTypeCode,5,1)

select * from GBT14885 where classCode is null

		


--��û���¼��������������������typeCodes��
select * from subclassTypeCodes where eSubClass not in (select eSubClass from typeCodes)
insert typeCodes(eKind, eClass, eSubClass, eTypeCode, eTypeName, aTypeCode, aTypeName,
	typeUnit, inputCode, cInputCode, cssName, isOff, offDate)
select eKind, eClass, eSubClass, eTypeCode, eTypeName, aTypeCode, aTypeName,
	typeUnit, inputCode, cInputCode, cssName, isOff, offDate 
from subclassTypeCodes where eSubClass not in (select eSubClass from typeCodes)

select * from classTypeCodes where eClass not in (select eClass from typeCodes)
select * from kindTypeCodes where eKind not in (select eKind from typeCodes)

insert classTypeCodes(eKind, eClass, eTypeCode, eTypeName, aTypeCode, aTypeName,
	typeUnit, inputCode, cInputCode, cssName, isOff, offDate)
select eKind, '1100', eTypeCode, eTypeName, aTypeCode, aTypeName,
	typeUnit, inputCode, cInputCode, cssName, isOff, offDate 
from kindTypeCodes 
where eKind not in (select eKind from typeCodes)

insert subclassTypeCodes(eKind, eClass, eSubClass, eTypeCode, eTypeName, aTypeCode, aTypeName,
	typeUnit, inputCode, cInputCode, cssName, isOff, offDate)
select eKind, '1100', '110000', eTypeCode, eTypeName, aTypeCode, aTypeName,
	typeUnit, inputCode, cInputCode, cssName, isOff, offDate 
from kindTypeCodes 
where eKind not in (select eKind from typeCodes)

insert typeCodes(eKind, eClass, eSubClass, eTypeCode, eTypeName, aTypeCode, aTypeName,
	typeUnit, inputCode, cInputCode, cssName, isOff, offDate)
select eKind, '1100', '110000', eTypeCode, eTypeName, aTypeCode, aTypeName,
	typeUnit, inputCode, cInputCode, cssName, isOff, offDate 
from kindTypeCodes 
where eKind not in (select eKind from typeCodes)

select * from classTypeCodes where substring(eTypeCode,3,6) = '000000' 
select * from subClassTypeCodes where substring(eTypeCode,5,4) = '0000' 
select * from typeCodes where substring(eTypeCode,7,2) = '00' 

--1.�豸�����������������Ͳ�������������׼
--1.1.�豸�������������
--ע�⣺����������������������������һ�Զ�Ĺ�ϵ��
drop TABLE kindTypeCodes
CREATE TABLE kindTypeCodes(
	rowNum int IDENTITY(1,1) NOT NULL,	--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	eKind char(2) not null,			--��������������������
	eTypeCode char(8) not null,		--�����ţ��̣�
	eTypeName nvarchar(30) not null,--��������������
	--��Ϊ��Ӧ�Ĳ�������������ж������������Ӧ������Ҫ���࣡
	aTypeCode varchar(7) not null,	--��Ӧ�ķ����ţ���������--ע�⣺�����ݿ�����8λ��Ӧ��ʹ�����ݵ��뵼�����̣���
									--����GB/T 14885-2010�涨�������ӳ���7λmodi by lw 2012-2-23
	aTypeName nvarchar(30) not null,--��Ӧ�Ĳ�������������
	include xml null,				--��Ӧ�ĸ�����������ࣺadd by lw 2012-10-8

	inputCode varchar(5) null,		--������
	remark nvarchar(50) null,		--���������౸ע���������й�����˵���������뵽���ֶ�modi by lw 2012-2-23

	--Ϊ�˱�֤�������ʷ������ȷ�ԣ��������ú�ͣ�ù��ܶ����ӵ��ֶΣ�
	isOff char(1) default('0') null,	--ͣ�ñ�ʶ:��0���������ã���1������ͣ��
	offDate smalldatetime null,			--ͣ������

	cssName varchar(30) null,			--css��ʽ���ƣ�Ϊ��֧�ִ�ͼ����ʾ�����ӵ��ֶ�

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_kindTypeCodes] PRIMARY KEY CLUSTERED 
(
	[eKind] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

insert kindTypeCodes(eKind, eTypeCode, eTypeName, aTypeCode, aTypeName, include, inputCode, remark,cssName)
select eKind, eTypeCode, eTypeName, aTypeCode, aTypeName, include, inputCode, remark,cssName
from k

declare @x xml
set @x = (select aTypeCode, aTypeName from kindTypeCodes where eKind='16' for XML raw)
set @x = '<root>'+CAST(@x as varchar(4000))+'</root>'
select @x
update kindTypeCodes
set include = @x
where eKind = '16'

select include, * from kindTypeCodes
--1.2.�豸�������Ĵ����
drop TABLE classTypeCodes
CREATE TABLE classTypeCodes(
	rowNum int IDENTITY(1,1) NOT NULL,	--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	eKind char(2) not null,			--�������������������
	eClass char(4) not null,		--�������������������
	eTypeCode char(8) not null,		--�����ţ��̣�
	eTypeName nvarchar(30) not null,--��������������
	--��Ϊ��Ӧ�Ĳ�������������ж������������Ӧ������Ҫ���࣡
	aTypeCode varchar(7) not null,	--��Ӧ�Ĳ�����������--ע�⣺�����ݿ�����8λ��Ӧ��ʹ�����ݵ��뵼�����̣���
									--����GB/T 14885-2010�涨�������ӳ���7λmodi by lw 2012-2-23
	aTypeName nvarchar(30) not null,--��Ӧ�Ĳ�������������
	include xml null,				--��Ӧ�ĸ�����������ࣺadd by lw 2012-10-8

	inputCode varchar(5) null,		--������
	remark nvarchar(50) null,		--���������౸ע���������й�����˵���������뵽���ֶ�modi by lw 2012-2-23

	--Ϊ�˱�֤�������ʷ������ȷ�ԣ��������ú�ͣ�ù��ܶ����ӵ��ֶΣ�
	isOff char(1) default('0') null,	--ͣ�ñ�ʶ:��0���������ã���1������ͣ��
	offDate smalldatetime null,			--ͣ������

	cssName varchar(30) null,			--css��ʽ���ƣ�Ϊ��֧�ִ�ͼ����ʾ�����ӵ��ֶ�

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_classTypeCodes] PRIMARY KEY CLUSTERED 
(
	[eKind] ASC,
	[eClass] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--��������Ӽ���
ALTER TABLE [dbo].[classTypeCodes] WITH CHECK ADD CONSTRAINT [FK_classTypeCodes_kindTypeCodes] FOREIGN KEY([eKind])
REFERENCES [dbo].[kindTypeCodes] ([eKind])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[classTypeCodes] CHECK CONSTRAINT [FK_classTypeCodes_kindTypeCodes]
GO

select * from c where eKind is null or eClass is null
update c
set eKind=LEFT(eTypeCode,2)

delete classTypeCodes
insert classTypeCodes(eKind, eClass, eTypeCode,eTypeName,aTypeCode,aTypeName,inputCode,remark,cssName)
select eKind, eClass, eTypeCode,eTypeName,aTypeCode,aTypeName,inputCode,remark,cssName from c


SELECT eClass, count(*) 
FROM classTypeCodes
group by eClass
having count(*) > 1


update classTypeCodes
set include = '<root>' + '<row aTypeCode="'+aTypeCode+'" aTypeName="'+aTypeName+'" /></root>'

insert classTypeCodes(eKind, eClass, eTypeCode, eTypeName, aTypeCode, aTypeName, include, inputCode, remark,cssName)
select eKind, eClass, eTypeCode, eTypeName, aTypeCode, aTypeName, include, inputCode, remark,cssName
from c

declare @x xml
set @x = (select aTypeCode, aTypeName from classTypeCodes where eClass='0320' for XML raw)
set @x = '<root>'+CAST(@x as varchar(4000))+'</root>'
select @x
update classTypeCodes
set include = @x
where eClass = '0320'

select include, * from classTypeCodes
where eClass in ('0319','0320')

delete classTypeCodes where rowNum in (353,354,355,356,357,358,359,360,362,363,364,365,366,367,368)
update classTypeCodes
set aTypeCode='75',aTypeName='���Ӻ�ͨ�Ų�������'
where eClass ='0320'


update classTypeCodes
set aTypeCode='77',aTypeName='������׼���߼����ߡ�����'
--include = '<root>' + '<row aTypeCode="'+aTypeCode+'" aTypeName="'+aTypeName+'" /></root>'
where eClass = '0322'

--1.3.�豸�������������
drop TABLE subClassTypeCodes
CREATE TABLE subClassTypeCodes(
	rowNum int IDENTITY(1,1) NOT NULL,	--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	eKind char(2) not null,			--�������������������
	eClass char(4) not null,		--������������������
	eSubClass char(6) not null,		--��������������������
	eTypeCode char(8) not null,		--�����ţ��̣�
	eTypeName nvarchar(30) not null,--��������������
	aTypeCode varchar(7) not null,	--��Ӧ�Ĳ�����������--ע�⣺�����ݿ�����8λ��Ӧ��ʹ�����ݵ��뵼�����̣���
									--����GB/T 14885-2010�涨�������ӳ���7λmodi by lw 2012-2-23
	aTypeName nvarchar(30) not null,--��������������
	inputCode varchar(5) null,		--������
	remark nvarchar(50) null,		--���������౸ע���������й�����˵���������뵽���ֶ�modi by lw 2012-2-23

	--Ϊ�˱�֤�������ʷ������ȷ�ԣ��������ú�ͣ�ù��ܶ����ӵ��ֶΣ�
	isOff char(1) default('0') null,	--ͣ�ñ�ʶ:��0���������ã���1������ͣ��
	offDate smalldatetime null,			--ͣ������

	cssName varchar(30) null,			--css��ʽ���ƣ�Ϊ��֧�ִ�ͼ����ʾ�����ӵ��ֶ�

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
CONSTRAINT [PK_subClassTypeCodes] PRIMARY KEY CLUSTERED 
(
	[eKind] ASC,
	[eClass] ASC,
	[eSubClass] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--��������Ӽ���
ALTER TABLE [dbo].[subClassTypeCodes] WITH CHECK ADD CONSTRAINT [FK_subClassTypeCodes_classTypeCodes] FOREIGN KEY([eKind],[eClass])
REFERENCES [dbo].[classTypeCodes] ([eKind],[eClass])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[subClassTypeCodes] CHECK CONSTRAINT [FK_subClassTypeCodes_classTypeCodes]
GO


SELECT eSubClass, count(*) 
FROM subClassTypeCodes
group by eSubClass
having count(*) > 1

insert subClassTypeCodes(eKind, eClass, eSubClass,eTypeCode,eTypeName,aTypeCode,aTypeName,inputCode,remark,cssName)
select eKind, eClass, eSubClass, eTypeCode,eTypeName,aTypeCode,aTypeName,inputCode,remark,cssName from s

select * from subClassTypeCodes
--1.4.�豸��������
--ע�⣺��ΪҪ������ļ�飬���Ա�����ֻ����ϸ�ķ�����룬���������������������Ʋ�һ����
drop TABLE typeCodes
CREATE TABLE typeCodes(
	rowNum int IDENTITY(1,1) NOT NULL,	--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	eKind char(2) not null,			--�������������������
	eClass char(4) not null,		--������������������
	eSubClass char(6) not null,		--�������������������
	eTypeCode char(8) not null,		--�����������ţ��̣�
	eTypeName nvarchar(30) not null,--��������������
	aTypeCode varchar(7) not null,	--��Ӧ�Ĳ�����������--ע�⣺�����ݿ�����8λ��Ӧ��ʹ�����ݵ��뵼�����̣���
									--����GB/T 14885-2010�涨�������ӳ���7λmodi by lw 2012-2-23
	aTypeName nvarchar(30) not null,--��Ӧ�Ĳ�������������
	inputCode varchar(5) null,		--������
	remark nvarchar(50) null,		--���������౸ע���������й�����˵���������뵽���ֶ�modi by lw 2012-2-23
	
	cssName varchar(30) null,		--css��ʽ���ƣ�Ϊ��֧�ִ�ͼ����ʾ�����ӵ��ֶ�, add by lw 2011-10-16

	--Ϊ�˱�֤�������ʷ������ȷ�ԣ��������ú�ͣ�ù��ܶ����ӵ��ֶΣ�
	isOff char(1) default('0') null,	--ͣ�ñ�ʶ:��0���������ã���1������ͣ��
	offDate smalldatetime null,			--ͣ������

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_typeCodes] PRIMARY KEY CLUSTERED 
(
	[eTypeCode] ASC,
	[eTypeName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
--������
CREATE NONCLUSTERED INDEX [IX_typeCodes] ON [dbo].[typeCodes] 
(
	[aTypeCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_typeCodes_1] ON [dbo].[typeCodes] 
(
	[eTypeCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_typeCodes_2] ON [dbo].[typeCodes] 
(
	[inputCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_typeCodes_3] ON [dbo].[typeCodes] 
(
	[eKind] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_typeCodes_4] ON [dbo].[typeCodes] 
(
	[eClass] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_typeCodes_5] ON [dbo].[typeCodes] 
(
	[eSubClass] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_typeCodes_6] ON [dbo].[typeCodes] 
(
	[eKind] ASC,
	[eClass] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_typeCodes_7] ON [dbo].[typeCodes] 
(
	[eKind] ASC,
	[eClass] ASC,
	[eSubClass] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--��������Ӽ���
ALTER TABLE [dbo].[typeCodes] WITH CHECK ADD CONSTRAINT [FK_typeCodes_subClassTypeCodes] FOREIGN KEY([eKind],[eClass],[eSubClass])
REFERENCES [dbo].[subClassTypeCodes] ([eKind],[eClass],[eSubClass])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[typeCodes] CHECK CONSTRAINT [FK_typeCodes_subClassTypeCodes]
GO


insert subClassTypeCodes(eKind, eClass, eSubClass,eTypeCode,eTypeName,aTypeCode,aTypeName,inputCode,remark,cssName)
select eKind, eClass, eSubClass, eTypeCode,eTypeName,aTypeCode,aTypeName,inputCode,remark,cssName from s




drop PROCEDURE checkTypeCode
/*
	name:		checkTypeCode
	function:	0.���ָ���ķ�������Ƿ��Ѿ�����
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2012-5-31
				@eTypeCode char(8),			--�����ţ��̣�
				@eTypeName nvarchar(30),	--��������������
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�����ڣ�>1�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2012-5-31�����޸�״̬�µļ��
*/
create PROCEDURE checkTypeCode
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2012-5-31
	@eTypeCode char(8),			--�����ţ��̣�
	@eTypeName nvarchar(30),	--��������������
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���÷������Ƿ�����������
	declare @count int
	set @count = (select count(*) from typeCodes where eTypeCode = @eTypeCode and eTypeName = @eTypeName and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE addTypeCode
/*
	name:		addTypeCode
	function:	1.����豸�������
				ע�⣺���洢���̲������༭��
	input: 
				@eTypeCode char(8),			--�����ţ��̣�
				@eTypeName nvarchar(30),	--��������������
				@aTypeCode varchar(7),		--�����ţ���������
				@aTypeName nvarchar(30),	--��������������
				@inputCode varchar(5),		--������
				@remark nvarchar(50),		--���������౸ע���������й�����˵���������뵽���ֶ�modi by lw 2012-2-23

				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1���÷����Ѿ��Ǽǹ���
							2�������������ࡢ���������
							9��δ֪����
				@rowNum		int output,		--���
				@createTime smalldatetime output
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 2011-1-26 by lw ���ݱ༭Ҫ������rowNum���ز���
				modi by lw 2012-2-23�����¹���GB/T 14885-2010�ӳ������������ų��ȣ�
				���ӽ������������Ƶı�ע�Ͳ���������ı�ע
				modi by lw 2012-10-5��������������������ƣ��޸Ľӿ�
				modi by lw 2013-5-31���ӷ���������ࡢ���ࡢ�����飬�޶��������
*/
create PROCEDURE addTypeCode
	@eTypeCode char(8),			--�����ţ��̣�
	@eTypeName nvarchar(30),	--��������������
	@aTypeCode varchar(7),		--�����ţ���������
	@aTypeName nvarchar(30),	--��������������
	@inputCode varchar(5),		--������
	@remark nvarchar(50),		--���������౸ע���������й�����˵���������뵽���ֶ�modi by lw 2012-2-23

	@createManID varchar(10),	--�����˹���

	@Ret		int output,
	@rowNum		int output,		--���
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���÷������Ƿ�����������
	declare @count int
	set @count = (select count(*) from typeCodes where eTypeCode = @eTypeCode and eTypeName = @eTypeName)
	if @count > 0
	begin
		set @Ret = 1
		return
	end
	--����Ƿ��ǺϷ���𣺼������½����ࡢ���������
	set @count = (select count(*) from subClassTypeCodes where eSubClass = LEFT(@eTypeCode,6))
	if @count > 0
	begin
		set @Ret = 2
		return
	end

	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	insert typeCodes(eKind, eClass,eSubClass,eTypeCode, eTypeName, aTypeCode, aTypeName, 
						inputCode, remark,
						lockManID, modiManID, modiManName, modiTime) 
	values (left(@eTypeCode,2),left(@eTypeCode,4),left(@eTypeCode,6),@eTypeCode, @eTypeName, @aTypeCode, @aTypeName,
						@inputCode, @remark,
			'', @createManID, @createManName, @createTime)
	set @rowNum =(select rowNum from typeCodes where eTypeCode = @eTypeCode and eTypeName = @eTypeName)
	
	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '��ӷ������', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ������˷������[' + @eTypeName +'('+ @eTypeCode +')' + ']��')
GO

drop PROCEDURE queryTypeCodeLocMan
/*
	name:		queryTypeCodeLocMan
	function:	2.��ѯָ����������Ƿ��������ڱ༭
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ���ķ�����벻����
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE queryTypeCodeLocMan
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from typeCodes where rowNum = @rowNum),'')
	set @Ret = 0
GO


drop PROCEDURE lockTypeCode4Edit
/*
	name:		lockTypeCode4Edit
	function:	3.�����������༭������༭��ͻ
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@lockManID varchar(10) output,	--�����ˣ������ǰ����������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����ķ�����벻���ڣ�2:Ҫ�����ķ���������ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE lockTypeCode4Edit
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@lockManID varchar(10) output,	--�����ˣ������ǰ����������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����ķ�������Ƿ����
	declare @count as int
	set @count=(select count(*) from typeCodes where rowNum = @rowNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from typeCodes where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update typeCodes
	set lockManID = @lockManID 
	where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�����������༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���������к�Ϊ��[' + str(@rowNum,6) + ']�ķ������Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockTypeCodeEditor
/*
	name:		unlockTypeCodeEditor
	function:	4.�ͷŷ������༭��
				ע�⣺�����̲���鵥���Ƿ���ڣ�
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@lockManID varchar(10) output,	--�����ˣ������ǰ����������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE unlockTypeCodeEditor
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@lockManID varchar(10) output,	--�����ˣ������ǰ����������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from typeCodes where rowNum = @rowNum),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update typeCodes set lockManID = '' where rowNum = @rowNum
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
	values(@lockManID, @lockManName, getdate(), '�ͷŷ������༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ����к�Ϊ��[' + str(@rowNum,6) + ']�ķ������ı༭����')
GO


drop PROCEDURE updateTypeCode
/*
	name:		updateTypeCode
	function:	5.���·������
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@eTypeCode char(8),			--�����ţ��̣�
				@eTypeName nvarchar(30),	--��������������
				@aTypeCode varchar(7),		--�����ţ���������
				@aTypeName nvarchar(30),	--��������������
				@inputCode varchar(5),		--������
				@remark nvarchar(50),		--���������౸ע���������й�����˵���������뵽���ֶ�modi by lw 2012-2-23

				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ����������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1��Ҫ���µķ��������������������
							2�����ظ��ķ�����룬
							3�������������ࡢ���������
							9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2012-2-23�����¹���GB/T 14885-2010�ӳ������������ų��ȣ�
				���ӽ������������Ƶı�ע�Ͳ���������ı�ע
				modi by lw 2012-10-5��������������������ƣ��޸Ľӿ�
				modi by lw 2013-5-31���ӷ���������ࡢ���ࡢ�����飬�޶��������
*/
create PROCEDURE updateTypeCode
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30

	@eTypeCode char(8),			--�����ţ��̣�
	@eTypeName nvarchar(30),	--��������������
	@aTypeCode varchar(7),		--�����ţ���������
	@aTypeName nvarchar(30),	--��������������
	@inputCode varchar(5),		--������
	@remark nvarchar(50),		--���������౸ע���������й�����˵���������뵽���ֶ�modi by lw 2012-2-23

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ����������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from typeCodes where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--����Ƿ�����������
	declare @count int
	set @count = (select count(*) from typeCodes where eTypeCode = @eTypeCode and eTypeName = @eTypeName and rowNum <> @rowNum)
	if @count > 0
	begin
		set @Ret = 2
		return
	end

	--����Ƿ��ǺϷ���𣺼������½����ࡢ���������
	set @count = (select count(*) from subClassTypeCodes where eSubClass = LEFT(@eTypeCode,6))
	if @count > 0
	begin
		set @Ret = 3
		return
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update typeCodes
	set eKind = left(@eTypeCode,2), eClass = left(@eTypeCode,4),eSubClass = left(@eTypeCode,6),
		eTypeCode = @eTypeCode, eTypeName = @eTypeName,
		aTypeCode = @aTypeCode, aTypeName = @aTypeName,
		inputCode = @inputCode, remark = @remark,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where rowNum = @rowNum
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '���·������', '�û�' + @modiManName 
												+ '�������к�Ϊ��[' + str(@rowNum,6) + ']�ķ�����롣')
GO

drop PROCEDURE delTypeCode
/*
	name:		delTypeCode
	function:	6.ɾ��ָ���ķ������
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ����������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���ķ�����벻���ڣ�2��Ҫɾ���ķ��������������������9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE delTypeCode
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ����������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���ķ�������Ƿ����
	declare @count as int
	set @count=(select count(*) from typeCodes where rowNum = @rowNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from typeCodes where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete typeCodes where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ���������', '�û�' + @delManName
												+ 'ɾ�����к�Ϊ��[' + str(@rowNum,6) + ']�ķ�����롣')
GO

drop PROCEDURE setTypeCodeOff
/*
	name:		setTypeCodeOff
	function:	7.ͣ��ָ���ķ������
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@stopManID varchar(10) output,	--ͣ���ˣ������ǰ����������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���ķ�����벻���ڣ�2��Ҫͣ�õķ��������������������9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setTypeCodeOff
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@stopManID varchar(10) output,	--ͣ���ˣ������ǰ����������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���ķ�������Ƿ����
	declare @count as int
	set @count=(select count(*) from typeCodes where rowNum = @rowNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from typeCodes where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	declare @stopTime smalldatetime
	set @stopTime = getdate()
	update typeCodes
	set isOff = '1', offDate = @stopTime
	where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, @stopTime, 'ͣ�÷������', '�û�' + @stopManName
												+ 'ͣ�����к�Ϊ��[' + str(@rowNum,6) + ']�ķ�����롣')
GO

drop PROCEDURE setTypeCodeActive
/*
	name:		setTypeCodeActive
	function:	8.����ָ���ķ������
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@activeManID varchar(10) output,	--�����ˣ������ǰ����������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���ķ�����벻���ڣ�2��Ҫ���õķ��������������������3���÷�����뱾���Ǽ���״̬��9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setTypeCodeActive
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@activeManID varchar(10) output,	--�����ˣ������ǰ����������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���ķ�������Ƿ����
	declare @count as int
	set @count=(select count(*) from typeCodes where rowNum = @rowNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from typeCodes where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @activeManID)
	begin
		set @activeManID = @thisLockMan
		set @Ret = 2
		return
	end

	--���״̬��
	declare @status char(1)
	set @status = isnull((select isOff from typeCodes where rowNum = @rowNum),'')
	if (@status = '0')
	begin
		set @Ret = 3
		return
	end
	
	declare @activeTime smalldatetime
	set @activeTime = getdate()
	update typeCodes
	set isOff = '0', offDate = null
	where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @activeManName nvarchar(30)
	set @activeManName = isnull((select userCName from activeUsers where userID = @activeManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@activeManID, @activeManName, @activeTime, '�������÷������', '�û�' + @activeManName
												+ '�����������к�Ϊ��[' + str(@rowNum,6) + ']�ķ�����롣')
GO




--��������ݵ����ã�
--���ࣺ
--���ƴ�������룺
select inputCode, upper(dbo.getChinaPYCode(eTypeName)) a, * from k
where inputCode <> upper(dbo.getChinaPYCode(eTypeName))

update k
set inputCode=upper(dbo.getChinaPYCode(eTypeName))

select * from k

truncate table kindTypeCodes
insert kindTypeCodes(eKind, eTypeCode, eTypeName, aTypeCode, aTypeName, inputCode, remark,cssName)
select eKind, eTypeCode, eTypeName, aTypeCode, aTypeName, inputCode, '',cssName
from k
order by rowNum

select * from kindTypeCodes

--���ࣺ
select * from c
where isnull(cssName,'')='' or isnull(aTypeCode,'') = '' or isnull(aTypeName,'') = ''  
	or isnull(inputCode,'')=''

--���ƴ�������룺
select inputCode, upper(dbo.getChinaPYCode(eTypeName)) a, * from c
where inputCode <> upper(dbo.getChinaPYCode(eTypeName))
update c
set inputCode=upper(dbo.getChinaPYCode(eTypeName))
--�������ƣ�
update c
set eTypeName = rtrim(etypenameupdate)
where isnull(rtrim(etypenameupdate),'') <> ''

truncate table classTypeCodes
insert classTypeCodes(eKind, eClass,eTypeCode, eTypeName, aTypeCode, aTypeName, inputCode, remark,cssName)
select eKind, eClass, eTypeCode, eTypeName, aTypeCode, aTypeName, inputCode, '',cssName
from c
order by rowNum

select * from classTypeCodes

--���ࣺ
select eTypecode, count(*) from s
where isnull(cssName,'')='' or isnull(aTypeCode,'') = '' or isnull(aTypeName,'') = ''  
	or isnull(inputCode,'')=''
update s
set aTypeCode ='281307'
where eTypeCode ='14040300'

--���ƴ�������룺
select inputCode, upper(dbo.getChinaPYCode(eTypeName)) a, * from s
where inputCode <> upper(dbo.getChinaPYCode(eTypeName))

--�������ƣ�
update s
set eTypeName = rtrim(etypenameupdate)
where isnull(rtrim(etypenameupdate),'') <> ''

truncate table subClassTypeCodes

insert subClassTypeCodes(eKind, eClass, eSubClass, eTypeCode, eTypeName, aTypeCode, aTypeName, inputCode, remark,cssName)
select eKind, eClass, eSubClass, eTypeCode, eTypeName, aTypeCode, aTypeName, inputCode, '',cssName
from s
order by rowNum

select * from subClassTypeCodes

--С�ࣺ
use hustOA
select * from i
where eTyprCodeUpdate is not null or nameChange is not null

--���ƴ�������룺
select inputCode, upper(dbo.getChinaPYCode(eTypeName)) a, * from i
where inputCode <> upper(dbo.getChinaPYCode(eTypeName))

--��ʽ����
update i
set eTypeCode = RTRIM(eTypeCode), eTyprCodeUpdate = RTRIM(eTyprCodeUpdate), 
eTypeName = RTRIM(eTypeName), nameChange= RTRIM(nameChange),
aTypeCode = RTRIM(aTypeCode),aTypeName = RTRIM(aTypeName)

--���½���һ����׼�⣺
drop table n
CREATE TABLE [dbo].[n](
	[opr] [nvarchar](255) NULL,
	[eTypeCode] [nvarchar](255) NULL,
	[eTyprCodeUpdate] [nvarchar](255) NULL,
	[eTypeName] [nvarchar](255) NULL,
	[nameChange] [nvarchar](255) NULL,
	[aTypeCode] [nvarchar](255) NULL,
	[aTypeName] [nvarchar](255) NULL,
	[inputCode] [nvarchar](255) NULL,
	[eKind] [nvarchar](255) NULL,
	[eClass] [nvarchar](255) NULL,
	[eSubClass] [nvarchar](255) NULL,
	[cssName] [nvarchar](255) NULL,
	[F19] [nvarchar](255) NULL
) ON [PRIMARY]

GO
insert n
select * from i

--�������ƣ�
update i
set eTypeName = rtrim(nameChange)
where isnull(rtrim(nameChange),'') <> ''

--�������룺
update i
set eTypeCode = eTyprCodeUpdate
where isnull(rtrim(eTyprCodeUpdate),'')<>''

delete i where ltrim(rtrim(opr))='-'
select * from i

--����Ƿ��������ݣ�
select * from i where isnull(aTypeCode,'') = ''
--update n
--set aTypeCode='432399'
--where isnull(aTypeCode,'') = ''
select * from n where left(eTypeCode,4) = '1602'

--�γ���ʽ��С��⣺
truncate table typeCodes
insert typeCodes(eKind, eClass, eSubClass, eTypeCode, eTypeName, aTypeCode, aTypeName, inputCode, remark,cssName)
select distinct eKind, eClass, eSubClass, eTypeCode, eTypeName, aTypeCode, aTypeName, inputCode, '',cssName
from i
order by eTypeCode

--�����������ܵ������Ƿ񶼶�Ӧ������������ϸ���ϣ���56��
select g.Level,'=trim("'+t.eTypeCode+'")', t.eTypeName, '=trim("'+g.aTypeCode+'")', g.aTypeName, g.Level
from typeCodes t left join GBT14885 g on t.aTypeCode = g.aTypeCode
where g.Level > 0

select * from GBT14885 where left(aTypeCode,3)='479'
select * from GBT14885 where aTypeName like '%����%'

--ƴ���������Զ�������Ҫ���������ֵĴ���
select * from chinacharpy where chinachar like '%��%'
update chinacharpy
set chinachar = '��û��ġĢģĤĥĦħĨĩĪīĬĭĮįİ�������������������������;;;'
where pycode = 'mo'

select * from GBT14885
select *, e.rowNum,e.eTypeCode, e.eTypeName, 
a.aTypeCode, a.aTypeName,a.unit,
e.inputCode,e.remark,
case e.isOff when '0' then '��' else '' end isOff,
case e.isOff when '0' then '' else convert(char(10), e.offDate, 120) end offDate,
e.modiManID,e.modiManName,e.modiTime,e.lockManID
from typeCodes e left join GBT14885 a on e.aTypeCode = a.aTypeCode



--ͨ���´�����޶��豸���еķ�����룺

select * from i
where ltrim(rtrim(opr))='-'

select eTypeCode,eTypeName,aTypeCode,* from equipmentList
where eTypeCode+eTypeName in (select eTypeCode+eTypeName from i where ltrim(rtrim(opr))='-')


select '=trim("'+e.eTypeCode+'")','=trim("'+i.eTyprCodeUpdate+'")', e.eTypeName,i.nameChange,'=trim("'+e.aTypeCode+'")',
	'=trim("'+e.eCode +'")', '=trim("'+acceptApplyID+'")' 
from equipmentList e inner join i 
on e.eTypeCode = i.eTypeCode and e.eTypeName = i.eTypeName and (isnull(i.nameChange,'')<>'' or ISNULL(i.eTyprCodeUpdate,'')<>'')

--����7058�����������ƻ��������
update equipmentList
set eTypeCode = case rtrim(isnull(i.eTyprCodeUpdate,'')) when '' then i.eTypeCode else i.eTyprCodeUpdate end,
	eTypeName = case rtrim(isnull(i.nameChange,'')) when '' then i.eTypeName else i.nameChange end
from equipmentList e inner join i 
on e.eTypeCode = i.eTypeCode and e.eTypeName = i.eTypeName and (isnull(i.nameChange,'')<>'' or ISNULL(i.eTyprCodeUpdate,'')<>'')
--��Ӧ������1077�����յ����ݣ�
update eqpAcceptInfo
set eTypeCode = case rtrim(isnull(i.eTyprCodeUpdate,'')) when '' then i.eTypeCode else i.eTyprCodeUpdate end,
	eTypeName = case rtrim(isnull(i.nameChange,'')) when '' then i.eTypeName else i.nameChange end
from eqpAcceptInfo e inner join i 
on e.eTypeCode = i.eTypeCode and e.eTypeName = i.eTypeName and (isnull(i.nameChange,'')<>'' or ISNULL(i.eTyprCodeUpdate,'')<>'')

--���ݱ�׼�������������������ɲ��������룺���޸���5079������
update equipmentList
set aTypeCode = t.aTypeCode
--select t.aTypeCode, e.aTypeCode, e.* 
from equipmentList e inner join typeCodes t on e.eTypeCode=t.eTypeCode and e.eTypeName = t.eTypeName
where t.aTypeCode<>e.aTypeCode

--��Ӧ������1396�����յ����ݣ�
update eqpAcceptInfo
set aTypeCode = t.aTypeCode
--select t.aTypeCode, e.aTypeCode, e.* 
from eqpAcceptInfo e inner join typeCodes t on e.eTypeCode=t.eTypeCode and e.eTypeName = t.eTypeName
where t.aTypeCode<>e.aTypeCode

--����Ƿ��пյĻ�����ϸ������������豸������5826��������Ҫ�˹�������
select '=trim("'+eTypeCode+'")', e.eTypeName, '=trim("'+e.aTypeCode+'")', '=trim("'+acceptApplyID+'")', 
	'=trim("'+eCode+'")', eName, eModel,eFormat,factory,business,clgName, uName
from equipmentList e left join college clg on e.clgCode=clg.clgCode left join useUnit u on e.uCode = u.uCode
where eTypeCode + eTypeName not in (select eTypeCode + eTypeName from typeCodes)
--and acceptDate > '2011-10-01'

--����Ƿ��пյĻ�����ϸ��������������յ�������2722��������Ҫ�˹����������鲻������
select '=trim("'+eTypeCode+'")', e.eTypeName, '=trim("'+e.aTypeCode+'")', '=trim("'+acceptApplyID+'")', 
	eName, eModel,eFormat,factory,business,clg.clgName, u.uName,startECode,endECode
from eqpAcceptInfo e left join college clg on e.clgCode=clg.clgCode left join useUnit u on e.uCode = u.uCode
where eTypeCode + eTypeName not in (select eTypeCode + eTypeName from typeCodes) and acceptApplyStatus = 2
--and acceptDate > '2011-10-01'
------------------------------
--�޶���һ�����ԵĴ���
update eqpAcceptInfo
set eTypeName='�������Ļ���4000-40000ת/�֣�'
--select * from eqpAcceptInfo
where eTypeName = '�������Ļ�(4000-4000'

update equipmentList
set eTypeName='�������Ļ���4000-40000ת/�֣�'
where eTypeName = '�������Ļ�(4000-4000'

update eqpAcceptInfo
set eTypeName='�ƶ�ͨ���豸���ƶ�̨��'
--select * from eqpAcceptInfo
where eTypeName = '�ƶ�ͨѶ�豸���ƶ�̨'

update equipmentList
set eTypeName='�ƶ�ͨ���豸���ƶ�̨��'
--select * from eqpAcceptInfo
where eTypeName = '�ƶ�ͨѶ�豸���ƶ�̨'

select * from typeCodes where eTypeName like '�ƶ�ͨ���豸%'
-----------------------------------------------------

--���ݡ��豸������벻����Ҫ����豸�嵥(20111230�����޸ı����)���ļ��޶���4176�����ݣ�
select '=trim("'+eTypeCode+'")', e.eTypeName, '=trim("'+e.aTypeCode+'")', '=trim("'+acceptApplyID+'")', 
	'=trim("'+eCode+'")', eName, eModel,eFormat,factory,business,clgName, uName
from equipmentList e left join college clg on e.clgCode=clg.clgCode left join useUnit u on e.uCode = u.uCode
where eTypeCode + eTypeName not in (select eTypeCode + eTypeName from typeCodes)
	and eCode in (select ecode from u)

create function getETypeName
(@eTypeCode varchar(8))
returns nvarchar(30)
as
begin
	return (select top 1 eTypeName from typeCodes where eTypeCode = @eTypeCode)
end

create table #t (eCode varchar(8), eTypeCode varchar(8),eTypeName nvarchar(30), acceptApplyID varchar(20))
insert #t(eCode, eTypeCode, eTypeName, acceptApplyID)
select eCode, eTypeCode, dbo.getETypeName(eTypeCode),acceptApplyID from u
select * from #t

update equipmentList
set eTypeCode = t.eTypeCode, eTypeName = t.eTypeName
--select e.eTypeCode,t.eTypeCode, e.eTypeName , t.eTypeName
from equipmentList e inner join #t t on e.eCode = t.eCode
where e.eTypeCode + e.eTypeName not in (select eTypeCode + eTypeName from typeCodes)
	and e.eCode in (select ecode from u) and t.eTypeName is not null

update eqpAcceptInfo
set eTypeCode = t.eTypeCode, eTypeName = t.eTypeName
--select e.eTypeCode,t.eTypeCode, e.eTypeName , t.eTypeName
from eqpAcceptInfo e inner join #t t on e.acceptApplyID = t.acceptApplyID
where e.eTypeCode + e.eTypeName not in (select eTypeCode + eTypeName from typeCodes)
	and e.acceptApplyID in (select acceptApplyID from u) and t.eTypeName is not null

drop table #t




--�������������⣺
--û��ʹ�õ�λ���豸������68������
select '=trim("'+eCode+'")', '=trim("'+acceptApplyID+'")', eName, eModel, eFormat, f.fName, a.aName, clg.clgName, u.uName 
from equipmentList e left join college clg on e.clgCode=clg.clgCode left join useUnit u on e.uCode = u.uCode and e.clgCode = u.clgCode
	left join fundSrc f on e.fCode = f.fCode left join appDir a on e.aCode = a.aCode
where isnull(u.uCode,'') not in (select uCode from useUnit)
--and acceptDate > '2011-10-01'

--û���豸���Ƶĵ�λ������2������
select '=trim("'+eCode+'")', '=trim("'+acceptApplyID+'")', eName, eModel, eFormat, f.fName, a.aName, clg.clgName, u.uName 
from equipmentList e left join college clg on e.clgCode=clg.clgCode left join useUnit u on e.uCode = u.uCode and e.clgCode = u.clgCode
	left join fundSrc f on e.fCode = f.fCode left join appDir a on e.aCode = a.aCode
where isnull(rtrim(eName),'') = ''
--and acceptDate > '2011-10-01'

--�غ��豸��δ����
select eCode, eName, count(*) 
from equipmentList 
group by eCode, eName
having count(*) > 1
--û�н����豸������756������
select acceptDate, '=trim("'+eCode+'")', '=trim("'+acceptApplyID+'")', eName, eModel, eFormat, f.fName, a.aName, clg.clgName, u.uName 
from equipmentList e left join college clg on e.clgCode=clg.clgCode left join useUnit u on e.uCode = u.uCode
	left join fundSrc f on e.fCode = f.fCode left join appDir a on e.aCode = a.aCode
where (ISNULL(price,0)=0 or isnull(totalAmount,0)=0)
--and acceptDate > '2011-10-01'

--û�о�����Դ��ʹ�÷�����豸������1������
select '=trim("'+eCode+'")', '=trim("'+acceptApplyID+'")', eName, eModel, eFormat, f.fName, a.aName, clg.clgName, u.uName 
from equipmentList e left join college clg on e.clgCode=clg.clgCode left join useUnit u on e.uCode = u.uCode
	left join fundSrc f on e.fCode = f.fCode left join appDir a on e.aCode = a.aCode
where (isnull(e.fCode,'') not in (select fCode from fundSrc) or isnull(e.aCode,'') not in (select aCode from appDir))
--and acceptDate > '2011-10-01'

--û�л�ƿ�Ŀ�����յ�������64������
select accountCode, '=trim("'+acceptApplyID+'")', eName, eModel, eFormat, f.fName, a.aName, clg.clgName, u.uName 
from eqpAcceptInfo e left join college clg on e.clgCode=clg.clgCode left join useUnit u on e.uCode = u.uCode
	left join fundSrc f on e.fCode = f.fCode left join appDir a on e.aCode = a.aCode
where isnull(e.accountCode,'') not in (select accountCode  from accountTitle) and acceptApplyStatus = 2

--���������������յ�����8070�ţ�22689̨���豸
select *
from eqpAcceptInfo
where acceptDate > '2011-10-01' and acceptApplyStatus = 2

select *
from equipmentList
where acceptDate > '2011-10-01'


select * from typeCodes
select * from kindTypeCodes