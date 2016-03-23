use hustOA
/*
	武大设备管理信息系统-分类编码
	author:		卢苇
	CreateDate:	2012-10-5
	UpdateDate: modi by lw 1011-10-16将设备分类代码表分拆成4个表，建立门类、大类、中类索引表，增加分类代码的样式字段
				modi by lw 2012-10-5将财政部分类编码与教育部分类编码分离设计，根据修订的编码重新组织门类表（存在一对多的关系），重新导入数据
				
*/
select '=trim("'+aTypeCode+'"',aTypeName,unit, case level when -2 then '明细项' else '' end from GBT14885 where abs(Level) = 2
select  '=trim("'+aTypeCode+'"',aTypeName,unit, Level from GBT14885 where classCode=''
--财政部固定资产分类代码表（GB/T 14885-1994）：
DROP TABLE GBT14885
CREATE TABLE [dbo].[GBT14885](
	RwID int NOT NULL,						--序号
	kind varchar(2) not null,				--门类码
	kindName nvarchar(20) not null,			--门类名称
	category varchar(2) not null,			--大类码
	classCode varchar(1) null,				--中类码
	subClassCode varchar(1) null,			--小类码
	itemCode varchar(2) null,				--细类码
	
	aTypeCode varchar(7) NOT NULL,			--标准代码
	aTypeName nvarchar(60) NOT NULL,		--标准名称
	unit nvarchar(10) NULL,					--计量单位
	QTYUnit varchar(60) NULL DEFAULT (''),	--数量单位
	PrntCode varchar(60) NULL DEFAULT (''),	--树形结构代码
	[Level] int NULL DEFAULT ((-1)),		--级次：当为负数的时候表示明细分类
	ShrtNm varchar(25) NULL DEFAULT (''),
	[Desc] varchar(255) NULL DEFAULT(''),	--描述

	inputCode varchar(5) null,				--输入码
	isOff char(1) null default('0') ,		--停用标识:“0”代表在用，“1”代表停用
	offDate smalldatetime null,				--停用日期

	CreateDate smalldatetime NULL,			--创建时间
	ModifyDate smalldatetime NULL,			--修改时间
	Creater nvarchar(30) NULL DEFAULT(''),	--创建人
	RwVrsn int NULL DEFAULT ((0)),			--版本
PRIMARY KEY NONCLUSTERED 
(
	[RwID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

--数据来源：	
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

		


--将没有下级分类码的中类数据送入typeCodes表：
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

--1.设备分类代码表：含教育部和财政部两类分类标准
--1.1.设备分类代码的门类表：
--注意：教育部门类码与财政部分类码存在一对多的关系！
drop TABLE kindTypeCodes
CREATE TABLE kindTypeCodes(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	eKind char(2) not null,			--主键：教育部分类门类
	eTypeCode char(8) not null,		--分类编号（教）
	eTypeName nvarchar(30) not null,--教育部分类名称
	--因为对应的财政部分类可能有多个，所以这里应该是主要分类！
	aTypeCode varchar(7) not null,	--对应的分类编号（财政部）--注意：现数据库中是8位，应该使用数据导入导出缩短！！
									--根据GB/T 14885-2010规定将编码延长到7位modi by lw 2012-2-23
	aTypeName nvarchar(30) not null,--对应的财政部分类名称
	include xml null,				--对应的更多财政部分类：add by lw 2012-10-8

	inputCode varchar(5) null,		--输入码
	remark nvarchar(50) null,		--教育部分类备注。将名称中过长的说明文字移入到本字段modi by lw 2012-2-23

	--为了保证编码的历史数据正确性，增加启用和停用功能而增加的字段：
	isOff char(1) default('0') null,	--停用标识:“0”代表在用，“1”代表停用
	offDate smalldatetime null,			--停用日期

	cssName varchar(30) null,			--css样式名称：为了支持带图标显示而增加的字段

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
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
--1.2.设备分类代码的大类表：
drop TABLE classTypeCodes
CREATE TABLE classTypeCodes(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	eKind char(2) not null,			--外键：教育部分类门类
	eClass char(4) not null,		--主键：教育部分类大类
	eTypeCode char(8) not null,		--分类编号（教）
	eTypeName nvarchar(30) not null,--教育部分类名称
	--因为对应的财政部分类可能有多个，所以这里应该是主要分类！
	aTypeCode varchar(7) not null,	--对应的财政部分类编号--注意：现数据库中是8位，应该使用数据导入导出缩短！！
									--根据GB/T 14885-2010规定将编码延长到7位modi by lw 2012-2-23
	aTypeName nvarchar(30) not null,--对应的财政部分类名称
	include xml null,				--对应的更多财政部分类：add by lw 2012-10-8

	inputCode varchar(5) null,		--输入码
	remark nvarchar(50) null,		--教育部分类备注。将名称中过长的说明文字移入到本字段modi by lw 2012-2-23

	--为了保证编码的历史数据正确性，增加启用和停用功能而增加的字段：
	isOff char(1) default('0') null,	--停用标识:“0”代表在用，“1”代表停用
	offDate smalldatetime null,			--停用日期

	cssName varchar(30) null,			--css样式名称：为了支持带图标显示而增加的字段

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_classTypeCodes] PRIMARY KEY CLUSTERED 
(
	[eKind] ASC,
	[eClass] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--外键：增加级联
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
set aTypeCode='75',aTypeName='电子和通信测量仪器'
where eClass ='0320'


update classTypeCodes
set aTypeCode='77',aTypeName='计量标准器具及量具、衡器'
--include = '<root>' + '<row aTypeCode="'+aTypeCode+'" aTypeName="'+aTypeName+'" /></root>'
where eClass = '0322'

--1.3.设备分类代码的中类表：
drop TABLE subClassTypeCodes
CREATE TABLE subClassTypeCodes(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	eKind char(2) not null,			--外键：教育部分类门类
	eClass char(4) not null,		--外键：教育部分类大类
	eSubClass char(6) not null,		--主键：教育部分类中类
	eTypeCode char(8) not null,		--分类编号（教）
	eTypeName nvarchar(30) not null,--教育部分类名称
	aTypeCode varchar(7) not null,	--对应的财政部分类编号--注意：现数据库中是8位，应该使用数据导入导出缩短！！
									--根据GB/T 14885-2010规定将编码延长到7位modi by lw 2012-2-23
	aTypeName nvarchar(30) not null,--财政部分类名称
	inputCode varchar(5) null,		--输入码
	remark nvarchar(50) null,		--教育部分类备注。将名称中过长的说明文字移入到本字段modi by lw 2012-2-23

	--为了保证编码的历史数据正确性，增加启用和停用功能而增加的字段：
	isOff char(1) default('0') null,	--停用标识:“0”代表在用，“1”代表停用
	offDate smalldatetime null,			--停用日期

	cssName varchar(30) null,			--css样式名称：为了支持带图标显示而增加的字段

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
CONSTRAINT [PK_subClassTypeCodes] PRIMARY KEY CLUSTERED 
(
	[eKind] ASC,
	[eClass] ASC,
	[eSubClass] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--外键：增加级联
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
--1.4.设备分类代码表：
--注意：因为要做特殊的检查，所以本表中只有明细的分类编码，这种设计与财政部的码表设计不一样！
drop TABLE typeCodes
CREATE TABLE typeCodes(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	eKind char(2) not null,			--外键：教育部分类门类
	eClass char(4) not null,		--外键：教育部分类大类
	eSubClass char(6) not null,		--外键：教育部分类中类
	eTypeCode char(8) not null,		--主键：分类编号（教）
	eTypeName nvarchar(30) not null,--教育部分类名称
	aTypeCode varchar(7) not null,	--对应的财政部分类编号--注意：现数据库中是8位，应该使用数据导入导出缩短！！
									--根据GB/T 14885-2010规定将编码延长到7位modi by lw 2012-2-23
	aTypeName nvarchar(30) not null,--对应的财政部分类名称
	inputCode varchar(5) null,		--输入码
	remark nvarchar(50) null,		--教育部分类备注。将名称中过长的说明文字移入到本字段modi by lw 2012-2-23
	
	cssName varchar(30) null,		--css样式名称：为了支持带图标显示而增加的字段, add by lw 2011-10-16

	--为了保证编码的历史数据正确性，增加启用和停用功能而增加的字段：
	isOff char(1) default('0') null,	--停用标识:“0”代表在用，“1”代表停用
	offDate smalldatetime null,			--停用日期

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_typeCodes] PRIMARY KEY CLUSTERED 
(
	[eTypeCode] ASC,
	[eTypeName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
--索引：
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

--外键：增加级联
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
	function:	0.检查指定的分类编码是否已经存在
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2012-5-31
				@eTypeCode char(8),			--分类编号（教）
				@eTypeName nvarchar(30),	--教育部分类名称
	output: 
				@Ret		int output		--操作成功标识
							0:不存在，>1：存在，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2012-5-31增加修改状态下的检查
*/
create PROCEDURE checkTypeCode
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2012-5-31
	@eTypeCode char(8),			--分类编号（教）
	@eTypeName nvarchar(30),	--教育部分类名称
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查该分类编号是否重码重名：
	declare @count int
	set @count = (select count(*) from typeCodes where eTypeCode = @eTypeCode and eTypeName = @eTypeName and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE addTypeCode
/*
	name:		addTypeCode
	function:	1.添加设备分类代码
				注意：本存储过程不锁定编辑！
	input: 
				@eTypeCode char(8),			--分类编号（教）
				@eTypeName nvarchar(30),	--教育部分类名称
				@aTypeCode varchar(7),		--分类编号（财政部）
				@aTypeName nvarchar(30),	--财政部分类名称
				@inputCode varchar(5),		--输入码
				@remark nvarchar(50),		--教育部分类备注。将名称中过长的说明文字移入到本字段modi by lw 2012-2-23

				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1：该分类已经登记过，
							2：不能新增门类、大类或中类
							9：未知错误
				@rowNum		int output,		--序号
				@createTime smalldatetime output
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 2011-1-26 by lw 根据编辑要求增加rowNum返回参数
				modi by lw 2012-2-23根据新国标GB/T 14885-2010延长财政部分类编号长度，
				增加教育部分类名称的备注和财政部分类的备注
				modi by lw 2012-10-5将财政部分类编码分离设计，修改接口
				modi by lw 2013-5-31增加分类代码门类、大类、中类检查，修订保存错误
*/
create PROCEDURE addTypeCode
	@eTypeCode char(8),			--分类编号（教）
	@eTypeName nvarchar(30),	--教育部分类名称
	@aTypeCode varchar(7),		--分类编号（财政部）
	@aTypeName nvarchar(30),	--财政部分类名称
	@inputCode varchar(5),		--输入码
	@remark nvarchar(50),		--教育部分类备注。将名称中过长的说明文字移入到本字段modi by lw 2012-2-23

	@createManID varchar(10),	--创建人工号

	@Ret		int output,
	@rowNum		int output,		--序号
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查该分类编号是否重码重名：
	declare @count int
	set @count = (select count(*) from typeCodes where eTypeCode = @eTypeCode and eTypeName = @eTypeName)
	if @count > 0
	begin
		set @Ret = 1
		return
	end
	--检查是否是合法类别：即不能新建门类、大类和中类
	set @count = (select count(*) from subClassTypeCodes where eSubClass = LEFT(@eTypeCode,6))
	if @count > 0
	begin
		set @Ret = 2
		return
	end

	--取维护人的姓名：
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
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加分类编码', '系统根据用户' + @createManName + 
					'的要求添加了分类编码[' + @eTypeName +'('+ @eTypeCode +')' + ']。')
GO

drop PROCEDURE queryTypeCodeLocMan
/*
	name:		queryTypeCodeLocMan
	function:	2.查询指定分类编码是否有人正在编辑
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的分类编码不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE queryTypeCodeLocMan
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from typeCodes where rowNum = @rowNum),'')
	set @Ret = 0
GO


drop PROCEDURE lockTypeCode4Edit
/*
	name:		lockTypeCode4Edit
	function:	3.锁定分类编码编辑，避免编辑冲突
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@lockManID varchar(10) output,	--锁定人，如果当前分类编码正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的分类编码不存在，2:要锁定的分类编码正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE lockTypeCode4Edit
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@lockManID varchar(10) output,	--锁定人，如果当前分类编码正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的分类编码是否存在
	declare @count as int
	set @count=(select count(*) from typeCodes where rowNum = @rowNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
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

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定分类编码编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了行号为：[' + str(@rowNum,6) + ']的分类编码为独占式编辑。')
GO

drop PROCEDURE unlockTypeCodeEditor
/*
	name:		unlockTypeCodeEditor
	function:	4.释放分类编码编辑锁
				注意：本过程不检查单据是否存在！
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@lockManID varchar(10) output,	--锁定人，如果当前分类编码正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE unlockTypeCodeEditor
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@lockManID varchar(10) output,	--锁定人，如果当前分类编码正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
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

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '释放分类编码编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了行号为：[' + str(@rowNum,6) + ']的分类编码的编辑锁。')
GO


drop PROCEDURE updateTypeCode
/*
	name:		updateTypeCode
	function:	5.更新分类编码
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@eTypeCode char(8),			--分类编号（教）
				@eTypeName nvarchar(30),	--教育部分类名称
				@aTypeCode varchar(7),		--分类编号（财政部）
				@aTypeName nvarchar(30),	--财政部分类名称
				@inputCode varchar(5),		--输入码
				@remark nvarchar(50),		--教育部分类备注。将名称中过长的说明文字移入到本字段modi by lw 2012-2-23

				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前分类编码正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，
							1：要更新的分类编码正被别人锁定，
							2：有重复的分类编码，
							3：不能新增门类、大类或中类
							9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2012-2-23根据新国标GB/T 14885-2010延长财政部分类编号长度，
				增加教育部分类名称的备注和财政部分类的备注
				modi by lw 2012-10-5将财政部分类编码分离设计，修改接口
				modi by lw 2013-5-31增加分类代码门类、大类、中类检查，修订保存错误
*/
create PROCEDURE updateTypeCode
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30

	@eTypeCode char(8),			--分类编号（教）
	@eTypeName nvarchar(30),	--教育部分类名称
	@aTypeCode varchar(7),		--分类编号（财政部）
	@aTypeName nvarchar(30),	--财政部分类名称
	@inputCode varchar(5),		--输入码
	@remark nvarchar(50),		--教育部分类备注。将名称中过长的说明文字移入到本字段modi by lw 2012-2-23

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前分类编码正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from typeCodes where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--检查是否重码重名：
	declare @count int
	set @count = (select count(*) from typeCodes where eTypeCode = @eTypeCode and eTypeName = @eTypeName and rowNum <> @rowNum)
	if @count > 0
	begin
		set @Ret = 2
		return
	end

	--检查是否是合法类别：即不能新建门类、大类和中类
	set @count = (select count(*) from subClassTypeCodes where eSubClass = LEFT(@eTypeCode,6))
	if @count > 0
	begin
		set @Ret = 3
		return
	end
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update typeCodes
	set eKind = left(@eTypeCode,2), eClass = left(@eTypeCode,4),eSubClass = left(@eTypeCode,6),
		eTypeCode = @eTypeCode, eTypeName = @eTypeName,
		aTypeCode = @aTypeCode, aTypeName = @aTypeName,
		inputCode = @inputCode, remark = @remark,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where rowNum = @rowNum
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新分类编码', '用户' + @modiManName 
												+ '更新了行号为：[' + str(@rowNum,6) + ']的分类编码。')
GO

drop PROCEDURE delTypeCode
/*
	name:		delTypeCode
	function:	6.删除指定的分类编码
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@delManID varchar(10) output,	--删除人，如果当前分类编码正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的分类编码不存在，2：要删除的分类编码正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE delTypeCode
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@delManID varchar(10) output,	--删除人，如果当前分类编码正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的分类编码是否存在
	declare @count as int
	set @count=(select count(*) from typeCodes where rowNum = @rowNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
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

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除分类编码', '用户' + @delManName
												+ '删除了行号为：[' + str(@rowNum,6) + ']的分类编码。')
GO

drop PROCEDURE setTypeCodeOff
/*
	name:		setTypeCodeOff
	function:	7.停用指定的分类编码
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@stopManID varchar(10) output,	--停用人，如果当前分类编码正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的分类编码不存在，2：要停用的分类编码正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setTypeCodeOff
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@stopManID varchar(10) output,	--停用人，如果当前分类编码正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的分类编码是否存在
	declare @count as int
	set @count=(select count(*) from typeCodes where rowNum = @rowNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
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

	--取维护人的姓名：
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, @stopTime, '停用分类编码', '用户' + @stopManName
												+ '停用了行号为：[' + str(@rowNum,6) + ']的分类编码。')
GO

drop PROCEDURE setTypeCodeActive
/*
	name:		setTypeCodeActive
	function:	8.启用指定的分类编码
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@activeManID varchar(10) output,	--启用人，如果当前分类编码正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的分类编码不存在，2：要启用的分类编码正被别人锁定，3：该分类编码本就是激活状态，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setTypeCodeActive
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@activeManID varchar(10) output,	--启用人，如果当前分类编码正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的分类编码是否存在
	declare @count as int
	set @count=(select count(*) from typeCodes where rowNum = @rowNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from typeCodes where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @activeManID)
	begin
		set @activeManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查状态：
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

	--取维护人的姓名：
	declare @activeManName nvarchar(30)
	set @activeManName = isnull((select userCName from activeUsers where userID = @activeManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@activeManID, @activeManName, @activeTime, '重新启用分类编码', '用户' + @activeManName
												+ '重新启用了行号为：[' + str(@rowNum,6) + ']的分类编码。')
GO




--新码表数据的启用：
--门类：
--检查拼音输入码：
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

--大类：
select * from c
where isnull(cssName,'')='' or isnull(aTypeCode,'') = '' or isnull(aTypeName,'') = ''  
	or isnull(inputCode,'')=''

--检查拼音输入码：
select inputCode, upper(dbo.getChinaPYCode(eTypeName)) a, * from c
where inputCode <> upper(dbo.getChinaPYCode(eTypeName))
update c
set inputCode=upper(dbo.getChinaPYCode(eTypeName))
--更正名称：
update c
set eTypeName = rtrim(etypenameupdate)
where isnull(rtrim(etypenameupdate),'') <> ''

truncate table classTypeCodes
insert classTypeCodes(eKind, eClass,eTypeCode, eTypeName, aTypeCode, aTypeName, inputCode, remark,cssName)
select eKind, eClass, eTypeCode, eTypeName, aTypeCode, aTypeName, inputCode, '',cssName
from c
order by rowNum

select * from classTypeCodes

--中类：
select eTypecode, count(*) from s
where isnull(cssName,'')='' or isnull(aTypeCode,'') = '' or isnull(aTypeName,'') = ''  
	or isnull(inputCode,'')=''
update s
set aTypeCode ='281307'
where eTypeCode ='14040300'

--检查拼音输入码：
select inputCode, upper(dbo.getChinaPYCode(eTypeName)) a, * from s
where inputCode <> upper(dbo.getChinaPYCode(eTypeName))

--更正名称：
update s
set eTypeName = rtrim(etypenameupdate)
where isnull(rtrim(etypenameupdate),'') <> ''

truncate table subClassTypeCodes

insert subClassTypeCodes(eKind, eClass, eSubClass, eTypeCode, eTypeName, aTypeCode, aTypeName, inputCode, remark,cssName)
select eKind, eClass, eSubClass, eTypeCode, eTypeName, aTypeCode, aTypeName, inputCode, '',cssName
from s
order by rowNum

select * from subClassTypeCodes

--小类：
use hustOA
select * from i
where eTyprCodeUpdate is not null or nameChange is not null

--检查拼音输入码：
select inputCode, upper(dbo.getChinaPYCode(eTypeName)) a, * from i
where inputCode <> upper(dbo.getChinaPYCode(eTypeName))

--格式化：
update i
set eTypeCode = RTRIM(eTypeCode), eTyprCodeUpdate = RTRIM(eTyprCodeUpdate), 
eTypeName = RTRIM(eTypeName), nameChange= RTRIM(nameChange),
aTypeCode = RTRIM(aTypeCode),aTypeName = RTRIM(aTypeName)

--重新建立一个标准库：
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

--更正名称：
update i
set eTypeName = rtrim(nameChange)
where isnull(rtrim(nameChange),'') <> ''

--更正代码：
update i
set eTypeCode = eTyprCodeUpdate
where isnull(rtrim(eTyprCodeUpdate),'')<>''

delete i where ltrim(rtrim(opr))='-'
select * from i

--检查是否有脏数据：
select * from i where isnull(aTypeCode,'') = ''
--update n
--set aTypeCode='432399'
--where isnull(aTypeCode,'') = ''
select * from n where left(eTypeCode,4) = '1602'

--形成正式的小类库：
truncate table typeCodes
insert typeCodes(eKind, eClass, eSubClass, eTypeCode, eTypeName, aTypeCode, aTypeName, inputCode, remark,cssName)
select distinct eKind, eClass, eSubClass, eTypeCode, eTypeName, aTypeCode, aTypeName, inputCode, '',cssName
from i
order by eTypeCode

--检查分类代码表总的数据是否都对应到财政部的明细项上：共56条
select g.Level,'=trim("'+t.eTypeCode+'")', t.eTypeName, '=trim("'+g.aTypeCode+'")', g.aTypeName, g.Level
from typeCodes t left join GBT14885 g on t.aTypeCode = g.aTypeCode
where g.Level > 0

select * from GBT14885 where left(aTypeCode,3)='479'
select * from GBT14885 where aTypeName like '%房屋%'

--拼音输入码自动生成器要增加重音字的处理：
select * from chinacharpy where chinachar like '%万%'
update chinacharpy
set chinachar = '脉没摸摹蘑模膜磨摩魔抹末莫墨默沫漠寞陌谟茉蓦馍嫫殁镆秣瘼耱貊貘麽;;;'
where pycode = 'mo'

select * from GBT14885
select *, e.rowNum,e.eTypeCode, e.eTypeName, 
a.aTypeCode, a.aTypeName,a.unit,
e.inputCode,e.remark,
case e.isOff when '0' then '√' else '' end isOff,
case e.isOff when '0' then '' else convert(char(10), e.offDate, 120) end offDate,
e.modiManID,e.modiManName,e.modiTime,e.lockManID
from typeCodes e left join GBT14885 a on e.aTypeCode = a.aTypeCode



--通过新代码表修订设备库中的分类代码：

select * from i
where ltrim(rtrim(opr))='-'

select eTypeCode,eTypeName,aTypeCode,* from equipmentList
where eTypeCode+eTypeName in (select eTypeCode+eTypeName from i where ltrim(rtrim(opr))='-')


select '=trim("'+e.eTypeCode+'")','=trim("'+i.eTyprCodeUpdate+'")', e.eTypeName,i.nameChange,'=trim("'+e.aTypeCode+'")',
	'=trim("'+e.eCode +'")', '=trim("'+acceptApplyID+'")' 
from equipmentList e inner join i 
on e.eTypeCode = i.eTypeCode and e.eTypeName = i.eTypeName and (isnull(i.nameChange,'')<>'' or ISNULL(i.eTyprCodeUpdate,'')<>'')

--发现7058行数据有名称或代码问题
update equipmentList
set eTypeCode = case rtrim(isnull(i.eTyprCodeUpdate,'')) when '' then i.eTypeCode else i.eTyprCodeUpdate end,
	eTypeName = case rtrim(isnull(i.nameChange,'')) when '' then i.eTypeName else i.nameChange end
from equipmentList e inner join i 
on e.eTypeCode = i.eTypeCode and e.eTypeName = i.eTypeName and (isnull(i.nameChange,'')<>'' or ISNULL(i.eTyprCodeUpdate,'')<>'')
--相应订正了1077条验收单数据：
update eqpAcceptInfo
set eTypeCode = case rtrim(isnull(i.eTyprCodeUpdate,'')) when '' then i.eTypeCode else i.eTyprCodeUpdate end,
	eTypeName = case rtrim(isnull(i.nameChange,'')) when '' then i.eTypeName else i.nameChange end
from eqpAcceptInfo e inner join i 
on e.eTypeCode = i.eTypeCode and e.eTypeName = i.eTypeName and (isnull(i.nameChange,'')<>'' or ISNULL(i.eTyprCodeUpdate,'')<>'')

--根据标准分类代码和名称重新生成财政部代码：共修改了5079条数据
update equipmentList
set aTypeCode = t.aTypeCode
--select t.aTypeCode, e.aTypeCode, e.* 
from equipmentList e inner join typeCodes t on e.eTypeCode=t.eTypeCode and e.eTypeName = t.eTypeName
where t.aTypeCode<>e.aTypeCode

--相应订正了1396条验收单数据：
update eqpAcceptInfo
set aTypeCode = t.aTypeCode
--select t.aTypeCode, e.aTypeCode, e.* 
from eqpAcceptInfo e inner join typeCodes t on e.eTypeCode=t.eTypeCode and e.eTypeName = t.eTypeName
where t.aTypeCode<>e.aTypeCode

--检查是否有空的或不是明细分类分类代码的设备：发现5826条，这需要人工更正！
select '=trim("'+eTypeCode+'")', e.eTypeName, '=trim("'+e.aTypeCode+'")', '=trim("'+acceptApplyID+'")', 
	'=trim("'+eCode+'")', eName, eModel,eFormat,factory,business,clgName, uName
from equipmentList e left join college clg on e.clgCode=clg.clgCode left join useUnit u on e.uCode = u.uCode
where eTypeCode + eTypeName not in (select eTypeCode + eTypeName from typeCodes)
--and acceptDate > '2011-10-01'

--检查是否有空的或不是明细分类分类代码的验收单：发现2722条，这需要人工更正！建议不做更正
select '=trim("'+eTypeCode+'")', e.eTypeName, '=trim("'+e.aTypeCode+'")', '=trim("'+acceptApplyID+'")', 
	eName, eModel,eFormat,factory,business,clg.clgName, u.uName,startECode,endECode
from eqpAcceptInfo e left join college clg on e.clgCode=clg.clgCode left join useUnit u on e.uCode = u.uCode
where eTypeCode + eTypeName not in (select eTypeCode + eTypeName from typeCodes) and acceptApplyStatus = 2
--and acceptDate > '2011-10-01'
------------------------------
--修订了一个明显的错误：
update eqpAcceptInfo
set eTypeName='高速离心机（4000-40000转/分）'
--select * from eqpAcceptInfo
where eTypeName = '高速离心机(4000-4000'

update equipmentList
set eTypeName='高速离心机（4000-40000转/分）'
where eTypeName = '高速离心机(4000-4000'

update eqpAcceptInfo
set eTypeName='移动通信设备（移动台）'
--select * from eqpAcceptInfo
where eTypeName = '移动通讯设备（移动台'

update equipmentList
set eTypeName='移动通信设备（移动台）'
--select * from eqpAcceptInfo
where eTypeName = '移动通讯设备（移动台'

select * from typeCodes where eTypeName like '移动通信设备%'
-----------------------------------------------------

--根据《设备分类编码不符合要求的设备清单(20111230方堃修改编码后)》文件修订了4176行数据：
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




--其他的数据问题：
--没有使用单位的设备：发现68条数据
select '=trim("'+eCode+'")', '=trim("'+acceptApplyID+'")', eName, eModel, eFormat, f.fName, a.aName, clg.clgName, u.uName 
from equipmentList e left join college clg on e.clgCode=clg.clgCode left join useUnit u on e.uCode = u.uCode and e.clgCode = u.clgCode
	left join fundSrc f on e.fCode = f.fCode left join appDir a on e.aCode = a.aCode
where isnull(u.uCode,'') not in (select uCode from useUnit)
--and acceptDate > '2011-10-01'

--没有设备名称的单位：发现2条数据
select '=trim("'+eCode+'")', '=trim("'+acceptApplyID+'")', eName, eModel, eFormat, f.fName, a.aName, clg.clgName, u.uName 
from equipmentList e left join college clg on e.clgCode=clg.clgCode left join useUnit u on e.uCode = u.uCode and e.clgCode = u.clgCode
	left join fundSrc f on e.fCode = f.fCode left join appDir a on e.aCode = a.aCode
where isnull(rtrim(eName),'') = ''
--and acceptDate > '2011-10-01'

--重号设备：未发现
select eCode, eName, count(*) 
from equipmentList 
group by eCode, eName
having count(*) > 1
--没有金额的设备：发现756条数据
select acceptDate, '=trim("'+eCode+'")', '=trim("'+acceptApplyID+'")', eName, eModel, eFormat, f.fName, a.aName, clg.clgName, u.uName 
from equipmentList e left join college clg on e.clgCode=clg.clgCode left join useUnit u on e.uCode = u.uCode
	left join fundSrc f on e.fCode = f.fCode left join appDir a on e.aCode = a.aCode
where (ISNULL(price,0)=0 or isnull(totalAmount,0)=0)
--and acceptDate > '2011-10-01'

--没有经费来源或使用方向的设备：发现1条数据
select '=trim("'+eCode+'")', '=trim("'+acceptApplyID+'")', eName, eModel, eFormat, f.fName, a.aName, clg.clgName, u.uName 
from equipmentList e left join college clg on e.clgCode=clg.clgCode left join useUnit u on e.uCode = u.uCode
	left join fundSrc f on e.fCode = f.fCode left join appDir a on e.aCode = a.aCode
where (isnull(e.fCode,'') not in (select fCode from fundSrc) or isnull(e.aCode,'') not in (select aCode from appDir))
--and acceptDate > '2011-10-01'

--没有会计科目的验收单：发现64条数据
select accountCode, '=trim("'+acceptApplyID+'")', eName, eModel, eFormat, f.fName, a.aName, clg.clgName, u.uName 
from eqpAcceptInfo e left join college clg on e.clgCode=clg.clgCode left join useUnit u on e.uCode = u.uCode
	left join fundSrc f on e.fCode = f.fCode left join appDir a on e.aCode = a.aCode
where isnull(e.accountCode,'') not in (select accountCode  from accountTitle) and acceptApplyStatus = 2

--上线以来的总验收单数：8070张，22689台套设备
select *
from eqpAcceptInfo
where acceptDate > '2011-10-01' and acceptApplyStatus = 2

select *
from equipmentList
where acceptDate > '2011-10-01'


select * from typeCodes
select * from kindTypeCodes