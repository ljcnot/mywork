/*
	设备分类代码修订专用
	本次修订：
	1.原教育部与财政部编码中名称、代码错误问题；
	2.增加原武大没有对应的分类码；
	3.设计新的财政部编码对应关系；
	4.使用新的数据库结构将财政部分类码表从设备分类码表中分离
	author:		卢苇
	CreateDate:	2012-3-5
	UpdateDate: 
*/
use typeCodes
truncate table classTypeCodes
truncate table kindTypeCodes
truncate table subClassTypeCodes
truncate table typeCodes
--导入数据
--更新样式表和更新索引编码：
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
--断开门类、大类、中类、小类之间的级联：
ALTER TABLE [dbo].[classTypeCodes] drop CONSTRAINT [FK_classTypeCodes_kindTypeCodes] 
ALTER TABLE [dbo].[subClassTypeCodes] drop CONSTRAINT [FK_subClassTypeCodes_classTypeCodes]
ALTER TABLE [dbo].[typeCodes] drop CONSTRAINT [FK_typeCodes_subClassTypeCodes]

--更新门类：直接使用新码表覆盖旧码表：
select * from typeCodes.dbo.kindTypeCodes
select * from kindTypeCodes

truncate table kindTypeCodes
insert kindTypeCodes(eKind, eTypeCode, eTypeName, aTypeCode, aTypeName, typeUnit, inputCode, cInputCode, isOff, offDate, cssName, eTypeNotes, aTypeNotes)
select eKind, eTypeCode, eTypeName, aTypeCode, aTypeName, typeUnit, inputCode, cInputCode, isOff, offDate, cssName, eTypeNotes, aTypeNotes
from typeCodes.dbo.kindTypeCodes

--更新大类：直接使用新码表覆盖旧码表：
delete typeCodes.dbo.classTypeCodes where eTypeCode is null
select * from typeCodes.dbo.classTypeCodes where opr is not null
select * from typeCodes.dbo.classTypeCodes
select * from classTypeCodes

--名称修订：
select * from typeCodes.dbo.classTypeCodes where isnull(ltrim(rtrim(eTypeNameUpdate)),'') <> ''
update typeCodes.dbo.classTypeCodes
set eTypeName = eTypeNameUpdate
where isnull(ltrim(rtrim(eTypeNameUpdate)),'') <> ''

truncate table classTypeCodes
insert classTypeCodes(eKind, eClass, eTypeCode, eTypeName, aTypeCode, aTypeName, typeUnit, inputCode, cInputCode, isOff, offDate, cssName, eTypeNotes, aTypeNotes)
select eKind, eClass, eTypeCode, eTypeName, aTypeCode, aTypeName, typeUnit, inputCode, cInputCode, isOff, offDate, cssName, eTypeNotes, aTypeNotes
from typeCodes.dbo.classTypeCodes

--更新中类：直接使用新码表覆盖旧码表：
delete typeCodes.dbo.subClassTypeCodes where eTypeCode is null
select * from typeCodes.dbo.subClassTypeCodes where opr is not null
select * from typeCodes.dbo.subClassTypeCodes
select * from subClassTypeCodes

--名称修订：
select * from typeCodes.dbo.subClassTypeCodes where isnull(ltrim(rtrim(eTypeNameUpdate)),'') <> ''
update typeCodes.dbo.subClassTypeCodes 
set eTypeName = eTypeNameUpdate
where isnull(ltrim(rtrim(eTypeNameUpdate)),'') <> ''

truncate table subClassTypeCodes
insert subClassTypeCodes(eKind, eClass, eSubClass, eTypeCode, eTypeName, aTypeCode, aTypeName, typeUnit, inputCode, cInputCode, isOff, offDate, cssName, eTypeNotes, aTypeNotes)
select eKind, eClass, eSubClass, eTypeCode, eTypeName, aTypeCode, aTypeName, typeUnit, inputCode, cInputCode, isOff, offDate, cssName, eTypeNotes, aTypeNotes
from typeCodes.dbo.subClassTypeCodes

--更新小类：
--1.武大设备系统中编码分类错误的更正（方堃提交的文件），
--2.根据opr将减少的代码涉及到的设备库、验收单库中的条目更正，执行新增和删除操作，

--3.将新修订的名称eTypeNameUpdate附加到原表中，将涉及到的设备库、验收单库中的条目更正，在修订分类名称。
delete typeCodes.dbo.typeCodes where eTypeCode is null
select * from typeCodes.dbo.typeCodes
select * from typeCodes

--删除项：
delete typeCodes.dbo.typeCodes where opr = '-'

--修订代码和名称：这里还要加入设备列表和验收单的修订！！
select * from typeCodes.dbo.typeCodes where isnull(ltrim(rtrim(eTyprCodeUpdate)),'') <> ''
update typeCodes.dbo.typeCodes
set eTypeCode = eTyprCodeUpdate
where isnull(ltrim(rtrim(eTyprCodeUpdate)),'') <> ''

select * from typeCodes.dbo.typeCodes where isnull(ltrim(rtrim(nameChange)),'') <> ''
update typeCodes.dbo.typeCodes
set eTypeName = nameChange
where isnull(ltrim(rtrim(nameChange)),'') <> ''

--更新码表：
truncate table typeCodes
insert typeCodes(eKind, eClass, eSubClass, eTypeCode, eTypeName, aTypeCode, aTypeName, typeUnit, inputCode, cInputCode, isOff, offDate, cssName, eTypeNotes, aTypeNotes)
select eKind, eClass, eSubClass, eTypeCode, eTypeName, aTypeCode, aTypeName, typeUnit, inputCode, cInputCode, isOff, offDate, cssName, substring(eTypeNotes,0,50), substring(aTypeNotes,0,50)
from typeCodes.dbo.typeCodes

--排除错误：这些检查出来的错误已经修订了分类编码文件！
select * from typeCodes.dbo.typeCodes where isnull(aTypeCode,'') = ''
UPDATE typeCodes.dbo.typeCodes
set aTypeCode = '711199', aTypeName='其他数字电子计算机', typeUnit='部', inputCode='DZJSJ',cInputCode='QTSZJ',isOff = 0
where eTypeCode = '05010401' and eTypeName ='电子计算机'

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
WHERE eTypeCode = '05020701' and eTypeName = '近红外摄相机'

select eTypeCode, eTypeName from typeCodes.dbo.typeCodes
group by eTypeCode, eTypeName
having count(*) > 1
select * from typeCodes.dbo.typeCodes where eTypeCode='12020212'
delete typeCodes.dbo.typeCodes where eTypeCode='12020212' and nameChange='电感式表面粗糙度齿廊仪'
select * from typeCodes.dbo.typeCodes where eTypeCode='07050104'
update typeCodes.dbo.typeCodes 
set eTypeName = '微波治疗机'
where eTypeCode='07050104' and aTypeName='其他医用电子仪器'

select * from typeCodes.dbo.typeCodes
where eTypeCode is null or eTypeName is null

--重建级联关系：
--外键：增加级联
ALTER TABLE [dbo].[classTypeCodes] WITH CHECK ADD CONSTRAINT [FK_classTypeCodes_kindTypeCodes] FOREIGN KEY([eKind])
REFERENCES [dbo].[kindTypeCodes] ([eKind])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[classTypeCodes] CHECK CONSTRAINT [FK_classTypeCodes_kindTypeCodes]
GO


--外键：增加级联
ALTER TABLE [dbo].[subClassTypeCodes] WITH CHECK ADD CONSTRAINT [FK_subClassTypeCodes_classTypeCodes] FOREIGN KEY([eKind],[eClass])
REFERENCES [dbo].[classTypeCodes] ([eKind],[eClass])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[subClassTypeCodes] CHECK CONSTRAINT [FK_subClassTypeCodes_classTypeCodes]
GO

--外键：增加级联
ALTER TABLE [dbo].[typeCodes] WITH CHECK ADD CONSTRAINT [FK_typeCodes_subClassTypeCodes] FOREIGN KEY([eSubClass])
REFERENCES [dbo].[subClassTypeCodes] ([eSubClass])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[typeCodes] CHECK CONSTRAINT [FK_typeCodes_subClassTypeCodes]
GO

