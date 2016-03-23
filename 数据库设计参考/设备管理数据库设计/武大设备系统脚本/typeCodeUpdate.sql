/*
	�豸��������޶�ר��
	�����޶���
	1.ԭ����������������������ơ�����������⣻
	2.����ԭ���û�ж�Ӧ�ķ����룻
	3.����µĲ����������Ӧ��ϵ��
	4.ʹ���µ����ݿ�ṹ�����������������豸��������з���
	author:		¬έ
	CreateDate:	2012-3-5
	UpdateDate: 
*/
use typeCodes
truncate table classTypeCodes
truncate table kindTypeCodes
truncate table subClassTypeCodes
truncate table typeCodes
--��������
--������ʽ��͸����������룺
select * from kindTypeCodes
update kindTypeCodes
set cssName = 'c' + eTypeCode,
	eKind = left(eTypeCode,2)
	
select * from classTypeCodes
update classTypeCodes
set cssName = 'c' + eTypeCode,
	eKind = left(eTypeCode,2),
	eClass = left(eTypeCode,4)

select * from subClassTypeCodes
update subClassTypeCodes
set cssName = 'c' + eTypeCode,
	eKind = left(eTypeCode,2),
	eClass = left(eTypeCode,4),
	eSubClass= left(eTypeCode,6)

select * from typeCodes
update typeCodes
set cssName = 'c' + eTypeCode,
	eKind = left(eTypeCode,2),
	eClass = left(eTypeCode,4),
	eSubClass= left(eTypeCode,6)

select * from typeCodes where eTypeCode='03030715'
use epdc2
--�Ͽ����ࡢ���ࡢ���ࡢС��֮��ļ�����
ALTER TABLE [dbo].[classTypeCodes] drop CONSTRAINT [FK_classTypeCodes_kindTypeCodes] 
ALTER TABLE [dbo].[subClassTypeCodes] drop CONSTRAINT [FK_subClassTypeCodes_classTypeCodes]
ALTER TABLE [dbo].[typeCodes] drop CONSTRAINT [FK_typeCodes_subClassTypeCodes]

--�������ֱࣺ��ʹ��������Ǿ����
select * from typeCodes.dbo.kindTypeCodes
select * from kindTypeCodes

truncate table kindTypeCodes
insert kindTypeCodes(eKind, eTypeCode, eTypeName, aTypeCode, aTypeName, typeUnit, inputCode, cInputCode, isOff, offDate, cssName, eTypeNotes, aTypeNotes)
select eKind, eTypeCode, eTypeName, aTypeCode, aTypeName, typeUnit, inputCode, cInputCode, isOff, offDate, cssName, eTypeNotes, aTypeNotes
from typeCodes.dbo.kindTypeCodes

--���´��ֱࣺ��ʹ��������Ǿ����
delete typeCodes.dbo.classTypeCodes where eTypeCode is null
select * from typeCodes.dbo.classTypeCodes where opr is not null
select * from typeCodes.dbo.classTypeCodes
select * from classTypeCodes

--�����޶���
select * from typeCodes.dbo.classTypeCodes where isnull(ltrim(rtrim(eTypeNameUpdate)),'') <> ''
update typeCodes.dbo.classTypeCodes
set eTypeName = eTypeNameUpdate
where isnull(ltrim(rtrim(eTypeNameUpdate)),'') <> ''

truncate table classTypeCodes
insert classTypeCodes(eKind, eClass, eTypeCode, eTypeName, aTypeCode, aTypeName, typeUnit, inputCode, cInputCode, isOff, offDate, cssName, eTypeNotes, aTypeNotes)
select eKind, eClass, eTypeCode, eTypeName, aTypeCode, aTypeName, typeUnit, inputCode, cInputCode, isOff, offDate, cssName, eTypeNotes, aTypeNotes
from typeCodes.dbo.classTypeCodes

--�������ֱࣺ��ʹ��������Ǿ����
delete typeCodes.dbo.subClassTypeCodes where eTypeCode is null
select * from typeCodes.dbo.subClassTypeCodes where opr is not null
select * from typeCodes.dbo.subClassTypeCodes
select * from subClassTypeCodes

--�����޶���
select * from typeCodes.dbo.subClassTypeCodes where isnull(ltrim(rtrim(eTypeNameUpdate)),'') <> ''
update typeCodes.dbo.subClassTypeCodes 
set eTypeName = eTypeNameUpdate
where isnull(ltrim(rtrim(eTypeNameUpdate)),'') <> ''

truncate table subClassTypeCodes
insert subClassTypeCodes(eKind, eClass, eSubClass, eTypeCode, eTypeName, aTypeCode, aTypeName, typeUnit, inputCode, cInputCode, isOff, offDate, cssName, eTypeNotes, aTypeNotes)
select eKind, eClass, eSubClass, eTypeCode, eTypeName, aTypeCode, aTypeName, typeUnit, inputCode, cInputCode, isOff, offDate, cssName, eTypeNotes, aTypeNotes
from typeCodes.dbo.subClassTypeCodes

--����С�ࣺ
--1.����豸ϵͳ�б���������ĸ����������ύ���ļ�����
--2.����opr�����ٵĴ����漰�����豸�⡢���յ����е���Ŀ������ִ��������ɾ��������

--3.�����޶�������eTypeNameUpdate���ӵ�ԭ���У����漰�����豸�⡢���յ����е���Ŀ���������޶��������ơ�
delete typeCodes.dbo.typeCodes where eTypeCode is null
select * from typeCodes.dbo.typeCodes
select * from typeCodes

--ɾ���
delete typeCodes.dbo.typeCodes where opr = '-'

--�޶���������ƣ����ﻹҪ�����豸�б�����յ����޶�����
select * from typeCodes.dbo.typeCodes where isnull(ltrim(rtrim(eTyprCodeUpdate)),'') <> ''
update typeCodes.dbo.typeCodes
set eTypeCode = eTyprCodeUpdate
where isnull(ltrim(rtrim(eTyprCodeUpdate)),'') <> ''

select * from typeCodes.dbo.typeCodes where isnull(ltrim(rtrim(nameChange)),'') <> ''
update typeCodes.dbo.typeCodes
set eTypeName = nameChange
where isnull(ltrim(rtrim(nameChange)),'') <> ''

--�������
truncate table typeCodes
insert typeCodes(eKind, eClass, eSubClass, eTypeCode, eTypeName, aTypeCode, aTypeName, typeUnit, inputCode, cInputCode, isOff, offDate, cssName, eTypeNotes, aTypeNotes)
select eKind, eClass, eSubClass, eTypeCode, eTypeName, aTypeCode, aTypeName, typeUnit, inputCode, cInputCode, isOff, offDate, cssName, substring(eTypeNotes,0,50), substring(aTypeNotes,0,50)
from typeCodes.dbo.typeCodes

--�ų�������Щ�������Ĵ����Ѿ��޶��˷�������ļ���
select * from typeCodes.dbo.typeCodes where isnull(aTypeCode,'') = ''
UPDATE typeCodes.dbo.typeCodes
set aTypeCode = '711199', aTypeName='�������ֵ��Ӽ����', typeUnit='��', inputCode='DZJSJ',cInputCode='QTSZJ',isOff = 0
where eTypeCode = '05010401' and eTypeName ='���Ӽ����'

select * from typeCodes.dbo.typeCodes where eTypeCode='03010103'
truncate table typeCodes.dbo.typeCodes
select * from typeCodes.dbo.typeCodes
where LEN(eTypeCode) <> 8 or LEN(aTypeCode)<>6

update typeCodes.dbo.typeCodes
set aTypeCode = '219000'
where aTypeCode='21900'

select max(len(typeUnit)), max(len(aTypeName)), MAX(len(inputCode)), MAX(len(cInputCode))
from typeCodes.dbo.typeCodes

select * from typeCodes.dbo.typeCodes
where len(inputCode) > 5

update typeCodes.dbo.typeCodes
set inputCode = 'JHWSJ'
WHERE eTypeCode = '05020701' and eTypeName = '�����������'

select eTypeCode, eTypeName from typeCodes.dbo.typeCodes
group by eTypeCode, eTypeName
having count(*) > 1
select * from typeCodes.dbo.typeCodes where eTypeCode='12020212'
delete typeCodes.dbo.typeCodes where eTypeCode='12020212' and nameChange='���ʽ����ֲڶȳ�����'
select * from typeCodes.dbo.typeCodes where eTypeCode='07050104'
update typeCodes.dbo.typeCodes 
set eTypeName = '΢�����ƻ�'
where eTypeCode='07050104' and aTypeName='����ҽ�õ�������'

select * from typeCodes.dbo.typeCodes
where eTypeCode is null or eTypeName is null

--�ؽ�������ϵ��
--��������Ӽ���
ALTER TABLE [dbo].[classTypeCodes] WITH CHECK ADD CONSTRAINT [FK_classTypeCodes_kindTypeCodes] FOREIGN KEY([eKind])
REFERENCES [dbo].[kindTypeCodes] ([eKind])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[classTypeCodes] CHECK CONSTRAINT [FK_classTypeCodes_kindTypeCodes]
GO


--��������Ӽ���
ALTER TABLE [dbo].[subClassTypeCodes] WITH CHECK ADD CONSTRAINT [FK_subClassTypeCodes_classTypeCodes] FOREIGN KEY([eKind],[eClass])
REFERENCES [dbo].[classTypeCodes] ([eKind],[eClass])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[subClassTypeCodes] CHECK CONSTRAINT [FK_subClassTypeCodes_classTypeCodes]
GO

--��������Ӽ���
ALTER TABLE [dbo].[typeCodes] WITH CHECK ADD CONSTRAINT [FK_typeCodes_subClassTypeCodes] FOREIGN KEY([eSubClass])
REFERENCES [dbo].[subClassTypeCodes] ([eSubClass])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[typeCodes] CHECK CONSTRAINT [FK_typeCodes_subClassTypeCodes]
GO

