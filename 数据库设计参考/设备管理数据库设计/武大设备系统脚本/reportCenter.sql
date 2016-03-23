use epdc211
/*
	武大设备管理信息系统-采购计划类表与存储过程
	author:		卢苇
	本数据库从长治城区公安分局警用地理信息系统-报表中心设计移植
	author:		卢苇
	CreateDate:	2010-03-26
	UpdateDate: 2011-2-9将人员的身份证号修改为工号！
*/


--教育部报表中心管理表：
select * from reportCenter
delete reportCenter
drop table reportCenter
CREATE TABLE [dbo].[reportCenter](
	reportNum varchar(12) not null,	--主键：报表编号
	reportType int not null,		--主键：报表类型:引用第900、901号代码字典
											--教育部报表：
											--901->教学科研仪器设备表
											--902->教学科研仪器设备增减变动情况表
											--903->贵重仪器设备表
	theTitle nvarchar(100) null,		--报表标题
	theYear varchar(4) null,			--统计年度
	totalStartDate smalldatetime null,	--统计开始日期
	totalEndDate smalldatetime null,	--统计结束日期

	makeUnit nvarchar(50) null,			--制表单位
	makeDate smalldatetime null,		--制表日期
	makerID varchar(10) null,			--制表人工号
	maker nvarchar(30) null,			--制表人
 CONSTRAINT [PK_reportCenter] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[reportType] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

select * from useUnit where uCode='12217'

select * from eDepartCode
--教育部报表单位代码转换表：
drop TABLE [dbo].[eDepartCode]
CREATE TABLE [dbo].[eDepartCode](
	rowNum int IDENTITY(1,1) NOT NULL,	--序号:为了保证用户可以编辑编码而增加的行号
	clgCode char(3) not null,			--院部代码
	clgName nvarchar(30) not null,		--院部名称	
	uCode varchar(8) not null,			--使用单位代码
	uName nvarchar(30) null,			--使用单位名称
	isUsed char(1) default('N'),		--是否使用：如果为不使用，则不参与教育部报表的计算
	
	--以下为对应的教育部报表使用的代码和名称：
	eUCode varchar(8) null,				--映射的使用单位代码
	eUName nvarchar(30) null,			--映射的使用单位名称
	switchUName xml null,				--按使用方向做代码的特殊映射：这是武大特殊的要求！就是一些单位“教学”和“科研”类的资产分别放在不同的单位名称中
	remark nvarchar(25) null,			--备注

	--创建人：
	createManID varchar(10) null,		--创建人工号
	createManName varchar(30) null,		--创建人姓名
	createTime smalldatetime null,		--创建时间
	
	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName varchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
PRIMARY KEY NONCLUSTERED 
(
	[clgCode] ASC,
	[uCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

select * from e
update eDepartCode
set eUCode = e.eUCode, eUName = e.eUName, switchUName = e.switchUName, remark = e.remark
from eDepartCode d left join e on d.uCode = e.uCode

update eDepartCode
set isUsed = 'Y'
where eUCode is not null

select * from eDepartCode
insert eDepartCode(clgCode, clgName, uCode, uName, isUsed, eUName, switchUName, remark, 
				createManID, createManName, createTime)
select clgCode, clgName, uCode, uName, isUsed, eUName, switchUName, remark, 
				createManID, createManName, createTime
from WHGXYepdc211.dbo.eDepartCode

--901：基表一 教学科研仪器设备表（本表只统计使用方向为：教学或科研，隶属教学或科研性质的使用单位的设备）：
--本表中的仪器设备是指教学、科研单位中，单价在人民币800元（含）以上，使用方向为教学或科研的仪器设备。
--《高等学校固定资产分类及编码》中的01类（房屋及构筑物）、02类（土地及植物）、11类（图书）、13类（家具）、15类（被服装具）、16类（牲畜）不属于
--上报范围。计算机软件作为仪器设备的附件上报，不作为单台件上报。
--毕处：2012-10-3教育部日期格式只取“年-月”，院部名称不需要
--
--经费来源：
select * from fundSrc
select * from equipmentList where fCode='1'
drop TABLE [dbo].[rptBase1]
CREATE TABLE [dbo].[rptBase1](
	reportNum varchar(12) not null,			--外键：报表编号
	reportType int not null default(1),		--外键：报表类型:由引用第900号代码字典
											--教育部报表：
											--901->教学科研仪器设备表


	universityCode char(5) not null,		--学校代码：数据格式为字符型，长度为5。
												--按教育部规定的高等学校5位数字码填报，具体代码可访问中国教育统计网站：http://www.stats.edu.cn/。
	universityName nvarchar(60) not null,	--学校名称:上报报表不需要该字段！


	eCode char(8) not null,					--仪器编号(设备编号)：数据格式为字符型，长度为8。学校内部使用的仪器设备编号，在本校内具有唯一性。
	eTypeCode char(8) not null,				--3.分类号（教育部分类编号）：数据格式为字符型，长度为8。指对仪器设备进行统一分类的编码，
												--按教育部高教司颁发的《高等学校固定资产分类及编码》填写，不得自行增加，
												--若无对应编码，填上一级编码，编码末位填“00”补齐8位。
	eName nvarchar(30) not null,			--仪器名称（教育部分类名称/设备名称）：数据格式为字符型，长度为30。用汉字表示，不能为空，与《高等学校固定资产分类及编码》中的分类号所对应的名称一致，
												--若无对应名称,则填写仪器设备标牌的汉字名称或规范的中文翻译名称。
	eModel nvarchar(20) not null,			--型号：数据格式为字符型，长度为20。按仪器设备标牌或说明书标示填写，型号不清的仪器设备，经学校管理部门核实后，填“*”，超出字段长度应截取主要部分填写。
	eFormat nvarchar(30) not null,			--规格：规格：数据格式为字符型，长度为30。指仪器设备的规格和主要技术指标。规格不清的仪器设备，经学校管理部门核实后，填“*”，超出字段长度应截取主要部分填写。
	fCode char(1) not null,					--仪器来源：数据格式为字符型，长度为1。按代码填写：1．购置；2．捐赠：指自然人、法人或者其他组织自愿无偿向学校捐赠的仪器设备；
																							-- 3．自制：主要部分是自行设计、加工、制造的仪器设备；
																							-- 4．校外调入：除前三项外的其他来源。
	cCode char(3) not null,					--国别码：数据格式为字符型，长度为3。指仪器设备的生产国家代码，以产品标牌标示的产地为准，按《世界各国和地区名称代码》（GB/T 2659-2000）填写，国别码不清的填“000”。
	totalAmount numeric(12,2) null,			--单价（设备总价）：数据格式为数值型，长度为12。指仪器设备包括附件在内的总价格。以元为单位，保留两位小数。
	acceptDate char(6) null,				--购置日期（验收日期）：数据格式为字符型，长度为6。指仪器设备到校验收日期。前四位表示年，后两位表示月。
	curEqpStatus char(1) not null,			--现状码：数据格式为字符型，长度为1
											--1：在用，指正在使用的仪器设备；
											--2：多余，指具有使用价值而未使用的仪器设备；
											--3：待修，指待修或正在修理的仪器设备；
											--4：待报废：指已经失去使用价值，而未履行正式报废手续的仪器设备；
											--8：降档，指金学校批准允许降档次使用、管理的仪器设备；
											--9：其他，现状不详的仪器设备。
	aCode char(1) not null,					--使用方向：数据格式为字符型，长度为1。指仪器设备的使用性质，按代码填写：1．教学为主；2．科研为主。若某台仪器设备教学与科研使用机时各占一半，填代码“2”。
	
	eUCode varchar(10) not null,			--单位编号（为单位映射表中的新单位代码）：数据格式为字符型，长度为10。
											--指学校自编的仪器设备所在单位编号，校内具有唯一性。
	eUName nvarchar(50) not null,			--单位名称（为单位映射表中的新单位名称）：数据格式为字符型，长度为50。
											--指仪器设备所在单位名称。
 CONSTRAINT [PK_rptBase1] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[eCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
ALTER TABLE [dbo].[rptBase1]  WITH CHECK ADD  CONSTRAINT [FK_rptBase1_reportCenter] FOREIGN KEY([reportNum], [reportType])
REFERENCES [dbo].[reportCenter] ([reportNum], [reportType])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[rptBase1] CHECK CONSTRAINT [FK_rptBase1_reportCenter]


--基表一的检查报告：
drop TABLE [dbo].[rptBase1CheckDetail]
CREATE TABLE [dbo].[rptBase1CheckDetail](
	checkManID varchar(10) not null,		--检查人工号
	checkManName varchar(30) not null,		--检查人姓名
	checkTime smalldatetime default(getdate()),--检查时间
	errorType nvarchar(10) not null,		--问题分类
	errorDesc nvarchar(50) null,			--问题描述
	
	reportNum varchar(12) not null,			--报表编号
	reportType int not null default(901),	--报表类型:由引用第900号代码字典
											--教育部报表：--901->教学科研仪器设备表

	universityCode char(5) not null,		--学校代码：数据格式为字符型，长度为5。
											--按教育部规定的高等学校5位数字码填报，具体代码可访问中国教育统计网站：http://www.stats.edu.cn/。
	universityName nvarchar(60) not null,	--学校名称:上报报表不需要该字段！


	eCode char(8) not null,					--仪器编号(设备编号)：数据格式为字符型，长度为8。学校内部使用的仪器设备编号，在本校内具有唯一性。
	eTypeCode char(8) not null,				--3.分类号（教育部分类编号）：数据格式为字符型，长度为8。指对仪器设备进行统一分类的编码，
												--按教育部高教司颁发的《高等学校固定资产分类及编码》填写，不得自行增加，
												--若无对应编码，填上一级编码，编码末位填“00”补齐8位。
	eName nvarchar(30) not null,			--仪器名称（教育部分类名称/设备名称）：数据格式为字符型，长度为30。用汉字表示，不能为空，与《高等学校固定资产分类及编码》中的分类号所对应的名称一致，
												--若无对应名称,则填写仪器设备标牌的汉字名称或规范的中文翻译名称。
	eModel nvarchar(20) not null,			--型号：数据格式为字符型，长度为20。按仪器设备标牌或说明书标示填写，型号不清的仪器设备，经学校管理部门核实后，填“*”，超出字段长度应截取主要部分填写。
	eFormat nvarchar(30) not null,			--规格：规格：数据格式为字符型，长度为30。指仪器设备的规格和主要技术指标。规格不清的仪器设备，经学校管理部门核实后，填“*”，超出字段长度应截取主要部分填写。
	fCode char(1) not null,					--仪器来源：数据格式为字符型，长度为1。按代码填写：1．购置；2．捐赠：指自然人、法人或者其他组织自愿无偿向学校捐赠的仪器设备；
																							-- 3．自制：主要部分是自行设计、加工、制造的仪器设备；
																							-- 4．校外调入：除前三项外的其他来源。
	cCode char(3) not null,					--国别码：数据格式为字符型，长度为3。指仪器设备的生产国家代码，以产品标牌标示的产地为准，按《世界各国和地区名称代码》（GB/T 2659-2000）填写，国别码不清的填“000”。
	totalAmount numeric(12,2) null,			--单价（设备总价）：数据格式为数值型，长度为12。指仪器设备包括附件在内的总价格。以元为单位，保留两位小数。
	acceptDate char(6) null,				--购置日期（验收日期）：数据格式为字符型，长度为6。指仪器设备到校验收日期。前四位表示年，后两位表示月。
	curEqpStatus char(1) not null,			--现状码：数据格式为字符型，长度为1
											--1：在用，指正在使用的仪器设备；
											--2：多余，指具有使用价值而未使用的仪器设备；
											--3：待修，指待修或正在修理的仪器设备；
											--4：待报废：指已经失去使用价值，而未履行正式报废手续的仪器设备；
											--8：降档，指金学校批准允许降档次使用、管理的仪器设备；
											--9：其他，现状不详的仪器设备。
	aCode char(1) not null,					--使用方向：数据格式为字符型，长度为1。指仪器设备的使用性质，按代码填写：1．教学为主；2．科研为主。若某台仪器设备教学与科研使用机时各占一半，填代码“2”。
	
	eUCode varchar(10) not null,			--单位编号（为单位映射表中的新单位代码）：数据格式为字符型，长度为10。
											--指学校自编的仪器设备所在单位编号，校内具有唯一性。
	eUName nvarchar(50) not null,			--单位名称（为单位映射表中的新单位名称）：数据格式为字符型，长度为50。
											--指仪器设备所在单位名称。
 CONSTRAINT [PK_rptBase1CheckDetail] PRIMARY KEY CLUSTERED 
(
	[checkManID] ASC,
	[reportNum] Asc,
	[errorType] ASC,
	[eCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--902：基表二 教学科研仪器设备增减变动情况表（本表只统计使用方向为：教学或科研，隶属教学或科研性质的使用单位的设备）：
--本表中的仪器设备是指教学、科研单位中，单价在人民币800元（含）以上，使用方向为教学或科研的仪器设备。
--《高等学校固定资产分类及编码》中的01类（房屋及构筑物）、02类（土地及植物）、11类（图书）、13类（家具）、15类（被服装具）、16类（牲畜）不属于
--上报范围:计算机软件作为仪器设备的附件上报，不作为单台件上报。金额以万元为单位，保留两位小数。
drop TABLE [dbo].[rptBase2]
CREATE TABLE [dbo].[rptBase2](
	reportNum varchar(12) not null,			--外键：报表编号
	reportType int not null default(1),		--外键：报表类型:由引用第900号代码字典
											--教育部报表：
											--901->教学科研仪器设备表

	universityCode char(5) not null,		--学校代码
	universityName nvarchar(60) not null,	--学校名称
	
	--上学年末实有数：
	eSumNumLastYear int not null,				--台件合计
	eSumAmountLastYear numeric(18,2) not null,	--金额合计
	bESumNumLastYear int not null,				--10万元（含）以上设备台件合计
	bESumAmountLastYear numeric(18,2) not null,	--10万元（含）以上设备金额合计
	
	--本学年增加数：
	eIncNumCurYear int not null,				--台件合计
	eIncAmountCurYear numeric(18,2) not null,	--金额合计
	bEIncNumCurYear int not null,				--10万元（含）以上设备台件合计
	bEIncAmountCurYear numeric(18,2) not null,	--10万元（含）以上设备金额合计
--要考虑从行政单位到教学科研单位的调拨问题！

	--本学年减少数：
	eDecNumCurYear int not null,				--台件合计
	eDecAmountCurYear numeric(18,2) not null,	--金额合计
	bEDecNumCurYear int not null,				--10万元（含）以上设备台件合计
	bEDecAmountCurYear numeric(18,2) not null,	--10万元（含）以上设备金额合计

	--本学年末实有数：
	eSumNumCurYear int not null,				--台件合计
	eSumAmountCurYear numeric(18,2) not null,	--金额合计
	bESumNumCurYear int not null,				--10万元（含）以上设备台件合计
	bESumAmountCurYear numeric(18,2) not null,	--10万元（含）以上设备金额合计
 CONSTRAINT [PK_rptBase2] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
ALTER TABLE [dbo].[rptBase2]  WITH CHECK ADD  CONSTRAINT [FK_rptBase2_reportCenter] FOREIGN KEY([reportNum], [reportType])
REFERENCES [dbo].[reportCenter] ([reportNum], [reportType])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[rptBase2] CHECK CONSTRAINT [FK_rptBase2_reportCenter]

--add by lw 2013-4-3
--基表二 按使用单位分组的教学科研仪器设备增减变动情况表（本表只统计使用方向为：教学或科研，隶属教学或科研性质的使用单位的设备）：
--本表中的仪器设备是指教学、科研单位中，单价在人民币800元（含）以上，使用方向为教学或科研的仪器设备。
--《高等学校固定资产分类及编码》中的01类（房屋及构筑物）、02类（土地及植物）、11类（图书）、13类（家具）、15类（被服装具）、16类（牲畜）不属于
--上报范围:计算机软件作为仪器设备的附件上报，不作为单台件上报。金额以万元为单位，保留两位小数。
drop TABLE [dbo].[rptBase2Exp]
CREATE TABLE [dbo].[rptBase2Exp](
	reportNum varchar(12) not null,			--外键：报表编号
	reportType int not null default(1),		--外键：报表类型:由引用第900号代码字典
											--教育部报表：
											--901->教学科研仪器设备表

	universityCode char(5) not null,		--学校代码
	universityName nvarchar(60) not null,	--学校名称
	eUCode varchar(8) not null,					--映射的使用单位代码
	eUName nvarchar(30) not null,				--映射的使用单位名称
	
	--上学年末实有数：
	eSumNumLastYear int not null,				--台件合计
	eSumAmountLastYear numeric(18,2) not null,	--金额合计
	bESumNumLastYear int not null,				--10万元（含）以上设备台件合计
	bESumAmountLastYear numeric(18,2) not null,	--10万元（含）以上设备金额合计
	
	--本学年增加数：
	eIncNumCurYear int not null,				--台件合计
	eIncAmountCurYear numeric(18,2) not null,	--金额合计
	bEIncNumCurYear int not null,				--10万元（含）以上设备台件合计
	bEIncAmountCurYear numeric(18,2) not null,	--10万元（含）以上设备金额合计
--要考虑从行政单位到教学科研单位的调拨问题！

	--本学年减少数：
	eDecNumCurYear int not null,				--台件合计
	eDecAmountCurYear numeric(18,2) not null,	--金额合计
	bEDecNumCurYear int not null,				--10万元（含）以上设备台件合计
	bEDecAmountCurYear numeric(18,2) not null,	--10万元（含）以上设备金额合计

	--本学年末实有数：
	eSumNumCurYear int not null,				--台件合计
	eSumAmountCurYear numeric(18,2) not null,	--金额合计
	bESumNumCurYear int not null,				--10万元（含）以上设备台件合计
	bESumAmountCurYear numeric(18,2) not null,	--10万元（含）以上设备金额合计
 CONSTRAINT [PK_rptBase2Exp] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[eUCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--903：基表三 贵重仪器设备表（本表只统计使用方向为：教学或科研，隶属教学或科研性质的使用单位的设备）：
--贵重仪器设备是指《高等学校固定资产分类及编码》的03类（仪器仪表）中单价在人民币40万元（含）以上、使用方向为教学或科研的仪器设备。
--计算机软件作为仪器设备的附件上报，不作为单台件上报。
--数据来源应该是基表一中03类的40万元以上的设备
drop TABLE [dbo].[rptBase3]
CREATE TABLE [dbo].[rptBase3](
	reportNum varchar(12) not null,			--外键：报表编号
	reportType int not null default(1),		--外键：报表类型:由引用第900号代码字典
											--教育部报表：
											--901->教学科研仪器设备表


	universityCode char(5) not null,		--学校代码
	universityName nvarchar(60) not null,	--学校名称:非上报字段

	eCode char(8) not null,					--仪器编号(设备编号)：数据格式为字符型，长度为8。学校内部使用的仪器设备编号，在本校内具有唯一性。
	eTypeCode char(8) not null,				--3.分类号（教育部分类编号）：数据格式为字符型，长度为8。指对仪器设备进行统一分类的编码，
												--按教育部高教司颁发的《高等学校固定资产分类及编码》填写，不得自行增加，
												--若无对应编码，填上一级编码，编码末位填“00”补齐8位。
	eName nvarchar(30) not null,			--仪器名称（教育部分类名称/设备名称）：数据格式为字符型，长度为30。用汉字表示，不能为空，与《高等学校固定资产分类及编码》中的分类号所对应的名称一致，
												--若无对应名称,则填写仪器设备标牌的汉字名称或规范的中文翻译名称。
	totalAmount numeric(12,2) null,			--单价（设备总价）：数据格式为数值型，长度为12。指仪器设备包括附件在内的总价格。以元为单位，保留两位小数。
	eModel nvarchar(20) not null,			--型号：数据格式为字符型，长度为20。按仪器设备标牌或说明书标示填写，型号不清的仪器设备，经学校管理部门核实后，填“*”，超出字段长度应截取主要部分填写。
	eFormat nvarchar(200) not null,			--规格：规格：数据格式为字符型，长度为30。指仪器设备的规格和主要技术指标。规格不清的仪器设备，经学校管理部门核实后，填“*”，超出字段长度应截取主要部分填写。

	--以下字段非本系统提供，应由大型设备共享系统和实验室管理系统提供！
	useHour4Education int default(0),		--使用机时（教学）：数据格式为数值型，长度为4。
											--用于教学工作的使用机时数。根据仪器设备使用记录按教学方面统计机时数，若无使用机时，填“0”，不能空项。
											--使用机时：必要的开机准备时间+测试时间+必须的后处理时间。
	useHour4Research int default(0),		--使用机时（科研）：数据格式为数值型，长度为4。
											--用于科研工作的使用机时数。根据仪器设备使用记录按科研方面统计机时数，若无使用机时，填“0”，不能空项。
	useHour4Service int default(0),			--使用机时（社会服务）：数据格式为数值型，长度为4。
											--用于社会服务的使用机时数。根据仪器设备使用记录按社会服务方面统计机时数，若无使用机时，填“0”，不能空项。
	useHour4Open int default(0),			--使用机时（其中开放使用机时）：数据格式为数值型，长度为4。
											--仪器对用户开放使用（用户自行上机测试、观察样品）的机时数。
	samplesNum int default(0),				--测样数：数据格式为数值型，长度为6。
											--本学年在本仪器设备上测试、分析的样品数量，按照原始记录统计填报。
											--同一样品在一台仪器上测试，统计测样数为1，与测试方法和次数无关。
	trainStudents int default(0),			--培训人员数（学生）：数据格式为数值型，长度为4。
											--本学年在本仪器上培训的能够独立操作的学生数，不包括各种形式的参观人数。按照原始记录统计填报。
	trainTeachers int default(0),			--培训人员数（教师）：数据格式为数值型，长度为4。
											--本学年在本仪器上培训的能够独立操作的教师数，不包括各种形式的参观人数。按照原始记录统计填报。
	trainOthers int default(0),				--培训人员数（其他）：数据格式为数值型，长度为4。
											--本学年在本仪器上培训的能够独立操作的其他人员数，不包括各种形式的参观人数。按照原始记录统计填报。
	experimentItems int default(0),			--教学实验项目数：数据格式为数值型，长度为3。
											--本学年利用本仪器设备开设的列入教学计划的实验项目数。
	researchItems int default(0),			--科研项目数：数据格式为数值型，长度为3。
											--本学年利用本仪器设备完成的各种科研项目或合作项目数。
	serviceItems int default(0),			--社会服务项目数：数据格式为数值型，长度为4。
											--本学年利用本仪器设备完成的为校外承担的社会服务项目数。
	awardsFromCountry int default(0),		--获奖情况（国家级）：数据格式为数值型，长度为2。利用本仪器设备在本学年获得的国家级奖励情况。
	awardsFromProvince int default(0),		--获奖情况（省部级）：数据格式为数值型，长度为2。利用本仪器设备本学年获得的省部级奖励情况。
	patentsFromTeacher int default(0),		--发明专利（教师）：数据格式为数值型，长度为2。
											--利用本仪器设备在本学年获得的已授权发明专利数，不含实用新型和外观设计。
	patentsFromStudent int default(0),		--发明专利（学生）：数据格式为数值型，长度为2。
											--利用本仪器设备在本学年获得的已授权发明专利数，不含实用新型和外观设计。
	thesisNum1 int default(0),				--论文情况（三大检索）：数据格式为数值型，长度为3。
											--利用本仪器设备在本学年发表论文情况。三大检索指：SCI、EI 、ISTP。
	thesisNum2 int default(0),				--论文情况（核心刊物）：数据格式为数值型，长度为3。
											--利用本仪器设备在本学年核心期刊发表论文情况。

	keeper nvarchar(30) null,				--负责人姓名(保管人):数据格式为字符型，长度为8。指本仪器设备或机组的负责人姓名，没有负责人的填“无”


	--以下字段是留待扩展的：
	fCode char(1) not null,					--仪器来源：数据格式为字符型，长度为1。按代码填写：1．购置；2．捐赠：指自然人、法人或者其他组织自愿无偿向学校捐赠的仪器设备；
																							-- 3．自制：主要部分是自行设计、加工、制造的仪器设备；
																							-- 4．校外调入：除前三项外的其他来源。
	cCode char(3) not null,					--国别码：数据格式为字符型，长度为3。指仪器设备的生产国家代码，以产品标牌标示的产地为准，按《世界各国和地区名称代码》（GB/T 2659-2000）填写，国别码不清的填“000”。
	acceptDate char(6) null,				--购置日期（验收日期）：数据格式为字符型，长度为6。指仪器设备到校验收日期。前四位表示年，后两位表示月。

	curEqpStatus char(1) not null,			--现状码：数据格式为字符型，长度为1
											--1：在用，指正在使用的仪器设备；
											--2：多余，指具有使用价值而未使用的仪器设备；
											--3：待修，指待修或正在修理的仪器设备；
											--4：待报废：指已经失去使用价值，而未履行正式报废手续的仪器设备；
											--8：降档，指金学校批准允许降档次使用、管理的仪器设备；
											--9：其他，现状不详的仪器设备。
	aCode char(1) not null,					--使用方向：数据格式为字符型，长度为1。指仪器设备的使用性质，按代码填写：1．教学为主；2．科研为主。若某台仪器设备教学与科研使用机时各占一半，填代码“2”。
	
	eUCode varchar(10) not null,			--单位编号（为单位映射表中的新单位代码）：数据格式为字符型，长度为10。
											--指学校自编的仪器设备所在单位编号，校内具有唯一性。
	eUName nvarchar(50) not null,			--单位名称（为单位映射表中的新单位名称）：数据格式为字符型，长度为50。
											--指仪器设备所在单位名称。
 CONSTRAINT [PK_rptBase3] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[eCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
ALTER TABLE [dbo].[rptBase3]  WITH CHECK ADD  CONSTRAINT [FK_rptBase3_reportCenter] FOREIGN KEY([reportNum], [reportType])
REFERENCES [dbo].[reportCenter] ([reportNum], [reportType])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[rptBase3] CHECK CONSTRAINT [FK_rptBase3_reportCenter]

drop proc addReport
/*
	name:		addReport
	function:	1.添加指定类型的报表：自动根据统计起止时间生成数据
	input: 
				@reportType int,		--报表类型:引用第900、901号代码字典
											--教育部报表：
											--901->教学科研仪器设备表
											--902->教学科研仪器设备增减变动情况表
											--903->贵重仪器设备表
				@theTitle nvarchar(100),		--报表标题
				@theYear varchar(4),			--统计年度
				@totalStartDate varchar(10),	--统计开始日期:"yyyy-MM-dd"格式
				@totalEndDate varchar(10),		--统计结束日期:"yyyy-MM-dd"格式

				@makeUnit nvarchar(50),			--制表单位
				@makerID varchar(10),			--制表人工号
	output: 
				@Ret		int output,			--操作成功标识：0:成功，9:未知错误
				@reportNum varchar(12) output	--报表编号:""创建报表时出错！
	author:		卢苇
	CreateDate:	2010-3-26
	UpdateDate: 简化参数 by lw 2012-10-2
*/
create PROCEDURE addReport
	@reportType int,		--报表类型:引用第900、901号代码字典
								--教育部报表：
								--901->教学科研仪器设备表
								--902->教学科研仪器设备增减变动情况表
								--903->贵重仪器设备表
	@theTitle nvarchar(100),		--报表标题
	@theYear varchar(4),			--统计年度
	@totalStartDate varchar(10),	--统计开始日期:"yyyy-MM-dd"格式
	@totalEndDate varchar(10),		--统计结束日期:"yyyy-MM-dd"格式

	@makeUnit nvarchar(50),			--制表单位
	@makerID varchar(10),			--制表人工号
	@Ret int output,				--操作成功标识：0:成功，9:未知错误
	@reportNum varchar(12) output	--报表编号：""创建报表时出错！
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber @reportType, 1, @curNumber output
	set @reportNum = @curNumber
	--获取制表人姓名：
	declare @maker nvarchar(30)
	set @maker = isnull((select userCName from activeUsers where userID = @makerID),'')
	--制表日期：
	declare @makeDate smalldatetime		--制表日期
	set @makeDate = GETDATE()

	begin tran
		--添加主表条目：
		insert reportCenter(reportNum, reportType, theTitle, theYear, totalStartDate, totalEndDate,
								makeUnit, makeDate, makerID, maker) 
		values (@reportNum, @reportType, @theTitle, @theYear, @totalStartDate, @totalEndDate,
								@makeUnit, getdate(), @makerID, @maker)
		--根据报表类型，构造报表：
		--教育部报表
		if @reportType = 901	--教学科研仪器设备表
			EXEC dbo.makeRptBase1 @reportNum, @totalStartDate, @totalEndDate, @Ret output
		else if @reportType = 902	--教学科研仪器设备增减变动情况表
			EXEC dbo.makeRptBase2 @reportNum, @totalStartDate, @totalEndDate, @Ret output
		else if @reportType = 903	--贵重仪器设备表
			EXEC dbo.makeRptBase3 @reportNum, @totalStartDate, @totalEndDate, @Ret output
		if (@@ERROR <> 0 or @Ret <> 0)
		begin
			rollback tran
			return
		end
	commit tran
	set @Ret = 0
	declare @reportName nvarchar(60)
	set @reportName = (case @reportType when 901 then '教学科研仪器设备表' 
										when 902 then '教学科研仪器设备增减变动情况表'
										when 903 then '贵重仪器设备表' end)
	--写工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@makerID, @maker, @makeDate, '生成教育部报表', '系统根据用户' + @maker + 
					'的要求生成了教育部报表-'+ +'[' + @reportNum + ']。')
GO
--测试：
declare @Ret int, @reportNum as varchar(12)
exec dbo.addReport 903, '基表三', '2012', '2011-09-01', '2012-08-31', 
'武汉大学', '00000008', @Ret output, @reportNum output
select @Ret, @reportNum

select * from rptBase2 where reportNum='201210110002'
select COUNT(*),SUM(totalAmount) from rptBase1 where reportNum='201210110005'

select * from [rptBase1] where reportNum='201210110005' and eUCode='6080100'

select * from equipmentList
where eCode='00J00947'

use epdc211
select * from reportCenter
select count(*), SUM(totalAmount) from [rptBase1] where reportNum='201210080012'
select * from [rptBase1] where reportNum='201210110004' and eCode not in (select eCode from [rptBase1] where reportNum='201210080007')
select * from equipmentList where eCode='11000045'
select * from [rptBase3] where reportNum='201210140002' and eCode='11000045'
select * from [rptBase2]
select count(*),SUM(totalAmount) from rptBase1 where reportNum='201210090003'

select * from [rptBase1] where reportNum='201210080013' and left(eucode,1)='L'

select * from [rptBase3] where reportNum='201210150001' and eCode not in (select left(eCode,8) from r3 uu)
select CHAR(39)+uu.eCode, CHAR(39)+e.eCode, CHAR(39)+uu.eTypeCode, CHAR(39)+e.eTypeCode, uu.eName, e.eName, e.totalAmount, c.clgName, u.uName  
from r3 uu left join equipmentList e on uu.eCode = e.eCode left join college c on e.clgCode=c.clgCode left join useUnit u on e.uCode=u.uCode
where uu.eCode not in (select eCode from [rptBase3] where reportNum='201210150001')

select * from r3 where eCode is null
delete r3 where eCode is null


select r.eCode, uu.eCode, r.eName, uu.eName, * from [rptBase3] r inner join uu on r.reportNum='201210120005' and r.eCode=uu.eCode

select eCode, count(*) from uu group by eCode having count(*) > 1

select * from uu where eCode is null
select distinct rtrim(eCode) from [rptBase3] where reportNum='201210140001'
select distinct RTRIM(eCode) from uu
select * from uu where ecode ='03030900'

select eCode, LEN(eCode) from uu where LEN(eCode)<>8
select * from equipmentList where eName like '%沉积%'

delete uu where eCode is null
select * from [rptBase3] where reportNum='201210120005' and ecode ='11000045'

drop table uu

DROP PROCEDURE makeRptBase1
/*
	name:		makeRptBase1
	function:	2.根据统计日期生成“教学科研仪器设备表”
	input: 
				@totalStartDate varchar(10),	--统计开始日期:"yyyy-MM-dd"格式
				@totalEndDate varchar(10),		--统计结束日期:"yyyy-MM-dd"格式
	output: 
				@Ret		int output			--操作成功标识
							0:成功，9:未知错误
	author:		卢苇
	CreateDate:	2011-1-26
	UpdateDate: 
*/
create PROCEDURE makeRptBase1
	@reportNum varchar(12),			--报表编号
	@totalStartDate varchar(10),	--统计开始日期:"yyyy-MM-dd"格式
	@totalEndDate varchar(10),		--统计结束日期:"yyyy-MM-dd"格式
	@Ret		int output			--操作成功标识：0:成功，9:未知错误
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--获取学校代码和学校名称：
	declare @universityCode char(5), @universityName nvarchar(60)		--学校代码、学校名称
	set @universityCode = (select objDesc from codeDictionary where classCode = 1 and objCode = 1)
	set @universityName = (select objDesc from codeDictionary where classCode = 1 and objCode = 2)
--	select @universityCode, @universityName

	insert rptBase1(reportNum, reportType, universityCode, universityName,
					eCode, eTypeCode, 
					eName, eModel, eFormat,
					fCode, cCode, 
					totalAmount, acceptDate, curEqpStatus,
					aCode, 
					eUCode, eUName)
	select @reportNum, 901, @universityCode, @universityName,	
					e.eCode, e.eTypeCode, 
					case isnull(e.eTypeName,'') when '' then e.eName else e.eTypeName end, e.eModel, e.eFormat,
					case e.obtainMode when 4 then '2' when 7 then '3' when 3 then '3' when 1 then '1' else '4' end, 
					isnull(e.cCode,'000'), 
					e.totalAmount, 
					cast(year(e.acceptDate) as CHAR(4)) + right('0'+cast(MONTH(e.acceptDate) as varchar(2)),2), 
					case e.curEqpStatus when '6' then dbo.getEqpStatusBeforeScrap(e.eCode)
										when '5' then '9' when '7' then '9'
										  else e.curEqpStatus end, --注意：目前只处理了报废的情况！
					case rtrim(cast(e.aCode as varchar(2))) when '1' then '1' when '2' then '2' else '1' end, 
					u.eUCode, isnull(u.eUName,'')
	from equipmentList e left join college clg on e.clgCode = clg.clgCode
		left join eDepartCode u on e.uCode = u.uCode
	where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
		and e.uCode in (select uCode from eDepartCode where isUsed='Y')	--约束到教学、科研类的使用单位
		and e.totalAmount >= 800	--单价800元（含）以上的设备
		and convert(varchar(10),acceptDate,120) <= @totalEndDate
		and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) > @totalEndDate)
	if @@ERROR <> 0 
	begin
		return
	end    

	--根据使用方向将临时编码的两个单位的编码修改一下：这是武大的特殊要求！
	--将特殊单位的使用方向为“教学”转换为“备注”字段的第2个映射码：
	update rptBase1 
	set eUCode = cast(e.switchUName.query('data(root/code[1])') as varchar(8)), 
		eUName = cast(e.switchUName.query('data(root/name[1])') as nvarchar(50))
	from rptBase1 r left join eDepartCode e on r.eUCode = e.eUCode
	where reportNum=@reportNum and left(r.eUCode,1)='L' and aCode = '1'
	if @@ERROR <> 0 
	begin
		return
	end    
	--将特殊单位的使用方向为“科研”转换为“备注”字段的第1个映射码：
	update rptBase1 
	set eUCode = cast(e.switchUName.query('data(root/code[2])') as varchar(8)), 
		eUName = cast(e.switchUName.query('data(root/name[2])') as nvarchar(50))
	from rptBase1 r left join eDepartCode e on r.eUCode = e.eUCode
	where reportNum=@reportNum and left(r.eUCode,1)='L' and aCode = '2'
	if @@ERROR <> 0 
	begin
		return
	end    
	
	set @Ret = 0
go

DROP PROCEDURE makeRptBase2
/*
	name:		makeRptBase2
	function:	2.根据统计日期生成“教学科研仪器设备增减变动情况表”
	input: 
				@totalStartDate varchar(10),	--统计开始日期:"yyyy-MM-dd"格式
				@totalEndDate varchar(10),		--统计结束日期:"yyyy-MM-dd"格式
	output: 
				@Ret		int output			--操作成功标识
							0:成功，9:未知错误
	author:		卢苇
	CreateDate:	2011-1-26
	UpdateDate: 
*/
create PROCEDURE makeRptBase2
	@reportNum varchar(12),			--报表编号
	@totalStartDate varchar(10),	--统计开始日期:"yyyy-MM-dd"格式
	@totalEndDate varchar(10),		--统计结束日期:"yyyy-MM-dd"格式
	@Ret		int output			--操作成功标识：0:成功，9:未知错误
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--获取学校代码和学校名称：
	declare @universityCode char(5), @universityName nvarchar(60)		--学校代码、学校名称
	set @universityCode = (select objDesc from codeDictionary where classCode = 1 and objCode = 1)
	set @universityName = (select objDesc from codeDictionary where classCode = 1 and objCode = 2)

	--计算上学年末实有数：
	declare @eSumNumLastYear int		--台件合计
	declare @eSumAmountLastYear money	--金额合计
	declare @bESumNumLastYear int		--10万元（含）以上设备台件合计
	declare @bESumAmountLastYear money	--10万元（含）以上设备金额合计

	select @eSumNumLastYear = isnull(count(*),0), @eSumAmountLastYear = isnull(sum(totalAmount),0)
	from equipmentList e left join college clg on e.clgCode = clg.clgCode
		left join eDepartCode u on e.uCode = u.uCode
	where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
		and e.uCode in (select uCode from eDepartCode where isUsed='Y')	--约束到教学、科研类的使用单位
		and e.totalAmount >= 800	--单价800元（含）以上的设备
		and convert(varchar(10),acceptDate,120) < @totalStartDate
		and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) >= @totalStartDate)

	select @bESumNumLastYear = isnull(count(*),0), @bESumAmountLastYear = isnull(sum(totalAmount),0)
	from equipmentList e left join college clg on e.clgCode = clg.clgCode
		left join eDepartCode u on e.uCode = u.uCode
	where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
		and e.uCode in (select uCode from eDepartCode where isUsed='Y')	--约束到教学、科研类的使用单位
		and e.totalAmount >= 100000	--总价10万元以上
		and convert(varchar(10),acceptDate,120) < @totalStartDate
		and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) >= @totalStartDate)

	--计算本学年增加数：
	declare @eIncNumCurYear int			--台件合计
	declare @eIncAmountCurYear money	--金额合计
	declare @bEIncNumCurYear int		--10万元（含）以上设备台件合计
	declare @bEIncAmountCurYear money	--10万元（含）以上设备金额合计

	select @eIncNumCurYear = isnull(count(*),0), @eIncAmountCurYear = isnull(sum(totalAmount),0)
	from equipmentList e left join college clg on e.clgCode = clg.clgCode
		left join eDepartCode u on e.uCode = u.uCode
	where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
		and e.uCode in (select uCode from eDepartCode where isUsed='Y')	--约束到教学、科研类的使用单位
		and e.totalAmount >= 800	--单价800元（含）以上的设备
		and convert(varchar(10),acceptDate,120) >= @totalStartDate and acceptDate <= @totalEndDate
		
	select @bEIncNumCurYear = isnull(count(*),0), @bEIncAmountCurYear = isnull(sum(totalAmount),0)
	from equipmentList e left join college clg on e.clgCode = clg.clgCode
		left join eDepartCode u on e.uCode = u.uCode
	where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
		and e.uCode in (select uCode from eDepartCode where isUsed='Y')	--约束到教学、科研类的使用单位
		and e.totalAmount >= 100000	--总价10万元以上
		and convert(varchar(10),acceptDate,120) >= @totalStartDate and acceptDate <= @totalEndDate

	--本学年减少数：这个数字使用倒推！
/*	
	declare @eDecNumCurYear int			--台件合计
	declare @eDecAmountCurYear money	--金额合计
	declare @bEDecNumCurYear int		--10万元（含）以上设备台件合计
	declare @bEDecAmountCurYear money	--10万元（含）以上设备金额合计

	select @eDecNumCurYear = isnull(count(*),0), @eDecAmountCurYear = isnull(sum(totalAmount),0)
	from equipmentList e left join college clg on e.clgCode = clg.clgCode
		left join eDepartCode u on e.uCode = u.uCode
	where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
		and e.uCode in (select uCode from eDepartCode where isUsed='Y')	--约束到教学、科研类的使用单位
		and e.totalAmount >= 800	--单价800元（含）以上的设备
		and (e.curEqpStatus in ('5','6','7') 
		and convert(varchar(10),scrapDate,120) >= @totalStartDate and scrapDate <= @totalEndDate) --这里只考虑了报废情况

	select @bEDecNumCurYear = isnull(count(*),0), @bEDecAmountCurYear = isnull(sum(totalAmount),0)
	from equipmentList e left join college clg on e.clgCode = clg.clgCode
		left join eDepartCode u on e.uCode = u.uCode
	where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
		and e.uCode in (select uCode from eDepartCode where isUsed='Y')	--约束到教学、科研类的使用单位
		and e.totalAmount >= 100000	--总价10万元以上
		and (e.curEqpStatus in ('5','6','7') 
		and convert(varchar(10),scrapDate,120) >= @totalStartDate and scrapDate <= @totalEndDate) --这里只考虑了报废情况
*/

	--计算本学年末实有数：
	declare @eSumNumCurYear int		--台件合计
	declare @eSumAmountCurYear money	--金额合计
	declare @bESumNumCurYear int		--10万元（含）以上设备台件合计
	declare @bESumAmountCurYear money	--10万元（含）以上设备金额合计

	select @eSumNumCurYear = count(*), @eSumAmountCurYear = sum(totalAmount)
	from equipmentList e left join college clg on e.clgCode = clg.clgCode
		left join eDepartCode u on e.uCode = u.uCode
	where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
		and e.uCode in (select uCode from eDepartCode where isUsed='Y')	--约束到教学、科研类的使用单位
		and e.totalAmount >= 800	--单价800元（含）以上的设备
		and convert(varchar(10),acceptDate,120) <= @totalEndDate
		and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) > @totalEndDate)

	select @bESumNumCurYear = count(*), @bESumAmountCurYear = sum(totalAmount)
	from equipmentList e left join college clg on e.clgCode = clg.clgCode
		left join eDepartCode u on e.uCode = u.uCode
	where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
		and e.uCode in (select uCode from eDepartCode where isUsed='Y')	--约束到教学、科研类的使用单位
		and e.totalAmount >= 100000	--总价10万元以上
		and convert(varchar(10),acceptDate,120) <= @totalEndDate
		and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) > @totalEndDate)
	

	--计算本学年减少数：
	declare @eDecNumCurYear int			--台件合计
	declare @eDecAmountCurYear money	--金额合计
	declare @bEDecNumCurYear int		--10万元（含）以上设备台件合计
	declare @bEDecAmountCurYear money	--10万元（含）以上设备金额合计
	set @eDecNumCurYear = @eSumNumLastYear + @eIncNumCurYear - @eSumNumCurYear
	set @eDecAmountCurYear =  @eSumAmountLastYear + @eIncAmountCurYear - @eSumAmountCurYear
	set @bEDecNumCurYear = @bESumNumLastYear + @bEIncNumCurYear - @bESumNumCurYear
	set @bEDecAmountCurYear = @bESumAmountLastYear + @bEIncAmountCurYear - @bESumAmountCurYear

	--保存报表：
	insert rptBase2(reportNum, reportType, universityCode, universityName,
					eSumNumLastYear, eSumAmountLastYear, bESumNumLastYear, bESumAmountLastYear,
					eIncNumCurYear, eIncAmountCurYear, bEIncNumCurYear, bEIncAmountCurYear,
					eDecNumCurYear, eDecAmountCurYear, bEDecNumCurYear, bEDecAmountCurYear,
					eSumNumCurYear, eSumAmountCurYear, bESumNumCurYear, bESumAmountCurYear)
	values(@reportNum, 902, @universityCode, @universityName,
					@eSumNumLastYear, @eSumAmountLastYear, @bESumNumLastYear, @bESumAmountLastYear,
					@eIncNumCurYear, @eIncAmountCurYear, @bEIncNumCurYear, @bEIncAmountCurYear,
					@eDecNumCurYear, @eDecAmountCurYear, @bEDecNumCurYear, @bEDecAmountCurYear,
					@eSumNumCurYear, @eSumAmountCurYear, @bESumNumCurYear, @bESumAmountCurYear)
	if @@ERROR <> 0 
	begin
		return
	end    

	set @Ret = 0
go

DROP PROCEDURE makeRptBase2Exp
/*
	name:		makeRptBase2Exp
	function:	2.1.根据统计日期生成“教学科研仪器设备增减变动情况表(各院部分组统计)”
	input: 
				@totalStartDate varchar(10),	--统计开始日期:"yyyy-MM-dd"格式
				@totalEndDate varchar(10),		--统计结束日期:"yyyy-MM-dd"格式
				@eUCode varchar(8),				--映射的使用单位代码
				@eUName nvarchar(30),			--映射的使用单位名称
				@aCode varchar(30),					--使用使用方向约束：''->不约束，'2'->约束到科研类，'1,3,4,5,6,7,8'->约束到教学类
				@realEUCode varchar(8),			--当有开关单位代码时使用的映射的使用单位代码
				@realEUName nvarchar(30),		--当有开关单位代码时使用的映射的使用单位名称
	output: 
				@Ret		int output			--操作成功标识
							0:成功，9:未知错误
	author:		卢苇
	CreateDate:	2013-4-3
	UpdateDate: 
*/
create PROCEDURE makeRptBase2Exp
	@reportNum varchar(12),			--报表编号
	@totalStartDate varchar(10),	--统计开始日期:"yyyy-MM-dd"格式
	@totalEndDate varchar(10),		--统计结束日期:"yyyy-MM-dd"格式
	@eUCode varchar(8),				--映射的使用单位代码
	@eUName nvarchar(30),			--映射的使用单位名称
	@aCode varchar(30),					--使用使用方向约束：''->不约束，'2'->约束到科研类，'1,3,4,5,6,7,8'->约束到教学类
	@realEUCode varchar(8),			--当有开关单位代码时使用的映射的使用单位代码
	@realEUName nvarchar(30),		--当有开关单位代码时使用的映射的使用单位名称
	@Ret		int output			--操作成功标识：0:成功，9:未知错误
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--获取学校代码和学校名称：
	declare @universityCode char(5), @universityName nvarchar(60)		--学校代码、学校名称
	set @universityCode = (select objDesc from codeDictionary where classCode = 1 and objCode = 1)
	set @universityName = (select objDesc from codeDictionary where classCode = 1 and objCode = 2)

	--计算上学年末实有数：
	declare @eSumNumLastYear int		--台件合计
	declare @eSumAmountLastYear money	--金额合计
	declare @bESumNumLastYear int		--10万元（含）以上设备台件合计
	declare @bESumAmountLastYear money	--10万元（含）以上设备金额合计

	--计算本学年增加数：
	declare @eIncNumCurYear int			--台件合计
	declare @eIncAmountCurYear money	--金额合计
	declare @bEIncNumCurYear int		--10万元（含）以上设备台件合计
	declare @bEIncAmountCurYear money	--10万元（含）以上设备金额合计

	--计算本学年末实有数：
	declare @eSumNumCurYear int		--台件合计
	declare @eSumAmountCurYear money	--金额合计
	declare @bESumNumCurYear int		--10万元（含）以上设备台件合计
	declare @bESumAmountCurYear money	--10万元（含）以上设备金额合计
	if (@aCode='')	--不使用使用方向约束
	begin
		select @eSumNumLastYear = isnull(count(*),0), @eSumAmountLastYear = isnull(sum(totalAmount),0)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where eUCode=@eUCode)	--约束到教学、科研类的使用单位
			and e.totalAmount >= 800	--单价800元（含）以上的设备
			and convert(varchar(10),acceptDate,120) < @totalStartDate
			and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) >= @totalStartDate)

		select @bESumNumLastYear = isnull(count(*),0), @bESumAmountLastYear = isnull(sum(totalAmount),0)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where eUCode=@eUCode)	--约束到教学、科研类的使用单位
			and e.totalAmount >= 100000	--总价10万元以上
			and convert(varchar(10),acceptDate,120) < @totalStartDate
			and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) >= @totalStartDate)

		--计算本学年增加数：
		select @eIncNumCurYear = isnull(count(*),0), @eIncAmountCurYear = isnull(sum(totalAmount),0)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where eUCode=@eUCode)	--约束到教学、科研类的使用单位
			and e.totalAmount >= 800	--单价800元（含）以上的设备
			and convert(varchar(10),acceptDate,120) >= @totalStartDate and acceptDate <= @totalEndDate
			
		select @bEIncNumCurYear = isnull(count(*),0), @bEIncAmountCurYear = isnull(sum(totalAmount),0)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where eUCode=@eUCode)	--约束到教学、科研类的使用单位
			and e.totalAmount >= 100000	--总价10万元以上
			and convert(varchar(10),acceptDate,120) >= @totalStartDate and acceptDate <= @totalEndDate

		--本学年减少数：这个数字使用倒推！
	/*	
		declare @eDecNumCurYear int			--台件合计
		declare @eDecAmountCurYear money	--金额合计
		declare @bEDecNumCurYear int		--10万元（含）以上设备台件合计
		declare @bEDecAmountCurYear money	--10万元（含）以上设备金额合计

		select @eDecNumCurYear = isnull(count(*),0), @eDecAmountCurYear = isnull(sum(totalAmount),0)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where isUsed='Y')	--约束到教学、科研类的使用单位
			and e.totalAmount >= 800	--单价800元（含）以上的设备
			and (e.curEqpStatus in ('5','6','7') 
			and convert(varchar(10),scrapDate,120) >= @totalStartDate and scrapDate <= @totalEndDate) --这里只考虑了报废情况

		select @bEDecNumCurYear = isnull(count(*),0), @bEDecAmountCurYear = isnull(sum(totalAmount),0)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where isUsed='Y')	--约束到教学、科研类的使用单位
			and e.totalAmount >= 100000	--总价10万元以上
			and (e.curEqpStatus in ('5','6','7') 
			and convert(varchar(10),scrapDate,120) >= @totalStartDate and scrapDate <= @totalEndDate) --这里只考虑了报废情况
	*/

		--计算本学年末实有数：
		select @eSumNumCurYear = count(*), @eSumAmountCurYear = sum(totalAmount)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where eUCode=@eUCode)	--约束到教学、科研类的使用单位
			and e.totalAmount >= 800	--单价800元（含）以上的设备
			and convert(varchar(10),acceptDate,120) <= @totalEndDate
			and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) > @totalEndDate)

		select @bESumNumCurYear = count(*), @bESumAmountCurYear = sum(totalAmount)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where eUCode=@eUCode)	--约束到教学、科研类的使用单位
			and e.totalAmount >= 100000	--总价10万元以上
			and convert(varchar(10),acceptDate,120) <= @totalEndDate
			and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) > @totalEndDate)
	end	
	else	--使用使用方向约束
	begin
		select @eSumNumLastYear = isnull(count(*),0), @eSumAmountLastYear = isnull(sum(totalAmount),0)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where eUCode=@eUCode)	--约束到教学、科研类的使用单位
			and e.aCode in (--约束到特定的使用方向
				SELECT cast(T.x.query('data(.)') as CHAR(1)) FROM 
				(SELECT CONVERT(XML,'<x>'+REPLACE(@aCode,',','</x><x>')+'</x>',1) Col1) A
				OUTER APPLY A.Col1.nodes('/x') AS T(x)
				)
			and e.totalAmount >= 800	--单价800元（含）以上的设备
			and convert(varchar(10),acceptDate,120) < @totalStartDate
			and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) >= @totalStartDate)

		select @bESumNumLastYear = isnull(count(*),0), @bESumAmountLastYear = isnull(sum(totalAmount),0)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where eUCode=@eUCode)	--约束到教学、科研类的使用单位
			and e.aCode in (--约束到特定的使用方向
				SELECT cast(T.x.query('data(.)') as CHAR(1)) FROM 
				(SELECT CONVERT(XML,'<x>'+REPLACE(@aCode,',','</x><x>')+'</x>',1) Col1) A
				OUTER APPLY A.Col1.nodes('/x') AS T(x)
				)
			and e.totalAmount >= 100000	--总价10万元以上
			and convert(varchar(10),acceptDate,120) < @totalStartDate
			and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) >= @totalStartDate)

		--计算本学年增加数：
		select @eIncNumCurYear = isnull(count(*),0), @eIncAmountCurYear = isnull(sum(totalAmount),0)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where eUCode=@eUCode)	--约束到教学、科研类的使用单位
			and e.aCode in (--约束到特定的使用方向
				SELECT cast(T.x.query('data(.)') as CHAR(1)) FROM 
				(SELECT CONVERT(XML,'<x>'+REPLACE(@aCode,',','</x><x>')+'</x>',1) Col1) A
				OUTER APPLY A.Col1.nodes('/x') AS T(x)
				)
			and e.totalAmount >= 800	--单价800元（含）以上的设备
			and convert(varchar(10),acceptDate,120) >= @totalStartDate and acceptDate <= @totalEndDate
			
		select @bEIncNumCurYear = isnull(count(*),0), @bEIncAmountCurYear = isnull(sum(totalAmount),0)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where eUCode=@eUCode)	--约束到教学、科研类的使用单位
			and e.aCode in (--约束到特定的使用方向
				SELECT cast(T.x.query('data(.)') as CHAR(1)) FROM 
				(SELECT CONVERT(XML,'<x>'+REPLACE(@aCode,',','</x><x>')+'</x>',1) Col1) A
				OUTER APPLY A.Col1.nodes('/x') AS T(x)
				)
			and e.totalAmount >= 100000	--总价10万元以上
			and convert(varchar(10),acceptDate,120) >= @totalStartDate and acceptDate <= @totalEndDate

		--本学年减少数：这个数字使用倒推！

		--计算本学年末实有数：
		select @eSumNumCurYear = count(*), @eSumAmountCurYear = sum(totalAmount)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where eUCode=@eUCode)	--约束到教学、科研类的使用单位
			and e.aCode in (--约束到特定的使用方向
				SELECT cast(T.x.query('data(.)') as CHAR(1)) FROM 
				(SELECT CONVERT(XML,'<x>'+REPLACE(@aCode,',','</x><x>')+'</x>',1) Col1) A
				OUTER APPLY A.Col1.nodes('/x') AS T(x)
				)
			and e.totalAmount >= 800	--单价800元（含）以上的设备
			and convert(varchar(10),acceptDate,120) <= @totalEndDate
			and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) > @totalEndDate)

		select @bESumNumCurYear = count(*), @bESumAmountCurYear = sum(totalAmount)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where eUCode=@eUCode)	--约束到教学、科研类的使用单位
			and e.aCode in (--约束到特定的使用方向
				SELECT cast(T.x.query('data(.)') as CHAR(1)) FROM 
				(SELECT CONVERT(XML,'<x>'+REPLACE(@aCode,',','</x><x>')+'</x>',1) Col1) A
				OUTER APPLY A.Col1.nodes('/x') AS T(x)
				)
			and e.totalAmount >= 100000	--总价10万元以上
			and convert(varchar(10),acceptDate,120) <= @totalEndDate
			and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) > @totalEndDate)
		set @eUCode = @realEUCode; set @eUName = @realEUName;
	end	

	--计算本学年减少数：
	declare @eDecNumCurYear int			--台件合计
	declare @eDecAmountCurYear money	--金额合计
	declare @bEDecNumCurYear int		--10万元（含）以上设备台件合计
	declare @bEDecAmountCurYear money	--10万元（含）以上设备金额合计
	set @eDecNumCurYear = @eSumNumLastYear + @eIncNumCurYear - @eSumNumCurYear
	set @eDecAmountCurYear =  @eSumAmountLastYear + @eIncAmountCurYear - @eSumAmountCurYear
	set @bEDecNumCurYear = @bESumNumLastYear + @bEIncNumCurYear - @bESumNumCurYear
	set @bEDecAmountCurYear = @bESumAmountLastYear + @bEIncAmountCurYear - @bESumAmountCurYear

	--保存报表：
	insert rptBase2Exp(reportNum, reportType, universityCode, universityName,
					eUCode, eUName,
					eSumNumLastYear, eSumAmountLastYear, bESumNumLastYear, bESumAmountLastYear,
					eIncNumCurYear, eIncAmountCurYear, bEIncNumCurYear, bEIncAmountCurYear,
					eDecNumCurYear, eDecAmountCurYear, bEDecNumCurYear, bEDecAmountCurYear,
					eSumNumCurYear, eSumAmountCurYear, bESumNumCurYear, bESumAmountCurYear)
	values(@reportNum, 902, @universityCode, @universityName,
					@eUCode, @eUName,
					isnull(@eSumNumLastYear,0), isnull(@eSumAmountLastYear,0), isnull(@bESumNumLastYear,0), isnull(@bESumAmountLastYear,0),
					isnull(@eIncNumCurYear,0), isnull(@eIncAmountCurYear,0), isnull(@bEIncNumCurYear,0), isnull(@bEIncAmountCurYear,0),
					isnull(@eDecNumCurYear,0), isnull(@eDecAmountCurYear,0), isnull(@bEDecNumCurYear,0), isnull(@bEDecAmountCurYear,0),
					isnull(@eSumNumCurYear,0), isnull(@eSumAmountCurYear,0), isnull(@bESumNumCurYear,0), isnull(@bESumAmountCurYear,0))
	if @@ERROR <> 0 
	begin
		return
	end    

	set @Ret = 0
go

delete rptBase2Exp
--生成明细表：
declare @eUCode varchar(8)	--映射的使用单位代码
declare @eUName nvarchar(30)--映射的使用单位名称
declare @Ret	int --操作成功标识：0:成功，9:未知错误
declare tar cursor for
select distinct eUCode,eUName from eDepartCode where isUsed='Y'	--约束到教学、科研类的使用单位
OPEN tar
FETCH NEXT FROM tar INTO @eUCode,@eUName
WHILE @@FETCH_STATUS = 0
begin
	print '正在处理：' + @eUcode + '-' + @eUName
	if left(@eUCode,1)='L'
	begin
		declare @switchUName xml	--按使用方向做代码的特殊映射：这是武大特殊的要求！就是一些单位“教学”和“科研”类的资产分别放在不同的单位名称中
		set @switchUName=(select top 1 switchUName from eDepartCode where eUCode = @eUCode)

		declare @realEUCode varchar(8)	--映射的使用单位代码:aCode = '1'
		declare @realEUName nvarchar(30)--映射的使用单位名称
		declare @realEUCode2 varchar(8)	--映射的使用单位代码:aCode = '2'
		declare @realEUName2 nvarchar(30)--映射的使用单位名称
		select @realEUCode = cast(@switchUName.query('data(root/code[1])') as varchar(8)), 
			   @realEUName = cast(@switchUName.query('data(root/name[1])') as nvarchar(50)),
			   @realEUCode2 = cast(@switchUName.query('data(root/code[2])') as varchar(8)), 
			   @realEUName2 = cast(@switchUName.query('data(root/name[2])') as nvarchar(50))
		--处理策略：将非科研类的资产全部放入教学类资产！
		exec dbo.makeRptBase2Exp '201304010001','2011-09-01','2012-08-31',@eUCode,@eUName,'1,3,4,5,6,7,8',@realEUCode,@realEUName,@Ret output
		if (@Ret<>0)
			break;	
		exec dbo.makeRptBase2Exp '201304010001','2011-09-01','2012-08-31',@eUCode,@eUName,'2',@realEUCode2,@realEUName2,@Ret output
	end
	else
		exec dbo.makeRptBase2Exp '201304010001','2011-09-01','2012-08-31',@eUCode,@eUName,'','','',@Ret output

	if (@Ret<>0)
		break;	
	FETCH NEXT FROM tar INTO @eUCode,@eUName
end
CLOSE tar
DEALLOCATE tar

select * from rptBase2Exp
--对比结果：
select * from rptBase2
select reportNum, reportType, universityCode, universityName,
					sum(eSumNumLastYear), sum(eSumAmountLastYear), sum(bESumNumLastYear), sum(bESumAmountLastYear),
					sum(eIncNumCurYear), sum(eIncAmountCurYear), sum(bEIncNumCurYear), sum(bEIncAmountCurYear),
					sum(eDecNumCurYear), sum(eDecAmountCurYear), sum(bEDecNumCurYear), sum(bEDecAmountCurYear),
					sum(eSumNumCurYear), sum(eSumAmountCurYear), sum(bESumNumCurYear), sum(bESumAmountCurYear)
from rptBase2Exp
group by reportNum, reportType, universityCode, universityName


select * from appDir

SELECT * FROM eDepartCode WHERE isUsed = 'Y'
select * from rptBase1 where eUCode = '6020100'
select * from eDepartCode where isused ='Y'
select * from rptBase2


select * from codeDictionary where classCode = 1
DROP PROCEDURE makeRptBase3
/*
	name:		makeRptBase3
	function:	3.根据统计日期生成“贵重仪器设备表”
	input: 
				@totalStartDate varchar(10),	--统计开始日期:"yyyy-MM-dd"格式
				@totalEndDate varchar(10),		--统计结束日期:"yyyy-MM-dd"格式
	output: 
				@Ret		int output			--操作成功标识
							0:成功，9:未知错误
	author:		卢苇
	CreateDate:	2011-1-28
	UpdateDate: 
*/
create PROCEDURE makeRptBase3
	@reportNum varchar(12),			--报表编号
	@totalStartDate varchar(10),	--统计开始日期:"yyyy-MM-dd"格式
	@totalEndDate varchar(10),		--统计结束日期:"yyyy-MM-dd"格式
	@Ret		int output			--操作成功标识：0:成功，9:未知错误
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--获取学校代码和学校名称：
	declare @universityCode char(5), @universityName nvarchar(60)		--学校代码、学校名称
	set @universityCode = (select objDesc from codeDictionary where classCode = 1 and objCode = 1)
	set @universityName = (select objDesc from codeDictionary where classCode = 1 and objCode = 2)
--	select @universityCode, @universityName

	insert rptBase3(reportNum, reportType, universityCode, universityName,
					eCode, eTypeCode, 
					eName, totalAmount, eModel, eFormat, keeper,
					fCode, cCode, 
					acceptDate, curEqpStatus,
					aCode, 
					eUCode, eUName)
	select @reportNum, 903, @universityCode, @universityName,	
					e.eCode, e.eTypeCode, 
					case isnull(e.eTypeName,'') when '' then e.eName else e.eTypeName end, 
					e.totalAmount, e.eModel, e.eFormat, e.keeper,
					case e.obtainMode when 4 then '2' when 7 then '3' when 3 then '3' when 1 then '1' else '4' end, 
					isnull(e.cCode,'000'), 
					cast(year(e.acceptDate) as CHAR(4)) + right('0'+cast(MONTH(e.acceptDate) as varchar(2)),2), 
					case e.curEqpStatus when '6' then dbo.getEqpStatusBeforeScrap(e.eCode)
										when '5' then '9' when '7' then '9'
										  else e.curEqpStatus end, --注意：目前只处理了报废的情况！
					case rtrim(cast(e.aCode as varchar(2))) when '1' then '1' when '2' then '2' else '1' end, 
					u.eUCode, isnull(u.eUName,'')
	from equipmentList e left join college clg on e.clgCode = clg.clgCode
		left join eDepartCode u on e.uCode = u.uCode
	where left(e.eTypeCode,2) = '03'
		and e.uCode in (select uCode from eDepartCode where isUsed='Y')	--约束到教学、科研类的使用单位
		and e.totalAmount >= 400000	--单价40万元（含）以上的设备
		and convert(varchar(10),acceptDate,120) <= @totalEndDate
		and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) > @totalEndDate)
	if @@ERROR <> 0 
	begin
		return
	end    

	--根据使用方向将临时编码的两个单位的编码修改一下：这是武大的特殊要求！
	--将特殊单位的使用方向为“教学”转换为“备注”字段的第2个映射码：
	update rptBase3 
	set eUCode = cast(e.switchUName.query('data(root/code[1])') as varchar(8)), 
		eUName = cast(e.switchUName.query('data(root/name[1])') as nvarchar(50))
	from rptBase3 r left join eDepartCode e on r.eUCode = e.eUCode
	where reportNum=@reportNum and left(r.eUCode,1)='L' and aCode = '1'
	if @@ERROR <> 0 
	begin
		return
	end    
	--将特殊单位的使用方向为“科研”转换为“备注”字段的第1个映射码：
	update rptBase3
	set eUCode = cast(e.switchUName.query('data(root/code[2])') as varchar(8)), 
		eUName = cast(e.switchUName.query('data(root/name[2])') as nvarchar(50))
	from rptBase3 r left join eDepartCode e on r.eUCode = e.eUCode
	where reportNum=@reportNum and left(r.eUCode,1)='L' and aCode = '2'
	if @@ERROR <> 0 
	begin
		return
	end    
	set @Ret = 0

go


drop PROCEDURE delReport
/*
	name:		delReport
	function:	4.删除指定的教育部报表
	input: 
				@reportNum varchar(12),			--报表编号
				@delManID varchar(10) output,	--删除人
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的报表不存在，9：未知错误
	author:		卢苇
	CreateDate:	2012-10-2
	UpdateDate: 

*/
create PROCEDURE delReport
	@reportNum varchar(12),			--报表编号
	@delManID varchar(10) output,	--删除人
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的报表是否存在
	declare @count as int
	set @count=(select count(*) from reportCenter where reportNum = @reportNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end


	delete reportCenter where reportNum = @reportNum
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除教育部报表', '用户' + @delManName
												+ '删除了教育部报表['+ @reportNum +']。')

GO

--教育部报表数据格式检查的存储过程：
drop PROCEDURE checkReportDataModel
/*
	name:		checkReportDataModel
	function:	5.1检查指定的教育部报表数据的格式——型号
	input: 
				@reportNum varchar(12),			--报表编号
				@checkManID varchar(10),		--检查人
	output: 
				@Ret		int output			--操作成功标识
							0:成功，-1：指定的报表不存在，>0 :存在型号错误的行数
	author:		卢苇
	CreateDate:	2012-10-12
	UpdateDate: 

*/
create PROCEDURE checkReportDataModel
	@reportNum varchar(12),			--报表编号
	@checkManID varchar(10),		--检查人
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = -1

	--判断指定的报表是否存在
	declare @count as int
	set @count=(select count(*) from reportCenter where reportNum = @reportNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = -1
		return
	end


	set @Ret = (select count(*) from rptBase1 where reportNum = @reportNum and isnull(eModel,'')='')

	--写检查报告：
	--取检查人的姓名：
	declare @checkManName nvarchar(30)
	set @checkManName = isnull((select userCName from activeUsers where userID = @checkManID),'')

	insert rptBase1CheckDetail(checkManID, checkManName, errorType, errorDesc, 
		reportNum, reportType, universityCode, universityName, 
		eCode, eTypeCode, eName, eModel, eFormat, 
		fCode, cCode, totalAmount, acceptDate, curEqpStatus, aCode,
		eUCode, eUName)
	select @checkManID, @checkManName, '仪器型号错误', '仪器型号不能为空，型号不清的仪器设备，经学校管理部门核实后，填“*”', 
		reportNum, reportType, universityCode, universityName, 
		eCode, eTypeCode, eName, eModel, eFormat, 
		fCode, cCode, totalAmount, acceptDate, curEqpStatus, aCode,
		eUCode, eUName
	from rptBase1
	where reportNum = @reportNum and isnull(eModel,'')=''
	
GO

select count(*), SUM(totalAmount) from equipmentList
------------------------------制作上报文件格式：--------------------------
use epdc211
select * from reportCenter

select COUNT(*),SUM(totalAmount) from rptBase1 where reportNum='201210110005'
--检查数据是否符合格式要求：
	--1.检查型号：
select * from rptBase1 where isnull(eModel,'')=''
update rptBase1
set eModel='*'
where isnull(eModel,'')=''

update equipmentList
set eModel='*'
where isnull(eModel,'')=''
	--2.检查规格：
select * from rptBase1 where isnull(eFormat,'')=''
update rptBase1
set eFormat='*'
where isnull(eFormat,'')=''

update equipmentList
set eFormat='*'
where isnull(eFormat,'')=''

	--3.检查国别：
select * from rptBase1 where ISNULL(cCode,'') not in (select cCode from country)
select * from equipmentList where eCode='12006806'
select * from country where cName like '中国'
update rptBase1
set cCode='156'
where ISNULL(cCode,'') not in (select cCode from country)

update equipmentList
set cCode='156'
where ISNULL(cCode,'') not in (select cCode from country)

	--4.检查分类代码错：
	--发现一个错误的分类：
select * from equipmentList where eCode='11013208'
select * from equipmentList where eCode='11T13208'

update rptBase1
set eTypeCode='04400109'
where eCode in ('11013208','11T13208')

update equipmentList
set eTypeCode='04400109'
where eCode in ('11013208','11T13208')

select * from rptBase1 where eCode='00012388'
select * from collegeCode where dCode='7006000'
	
select top 10 * from rptBase1

--更正一个分类
update equipmentList
set eTypeCode='03250213', eTypeName='多道生理记录仪', aTypeCode='767200'
where eCode = '11000005'

update rptBase1
set eTypeCode='03250213'
where eCode = '11000005'

update rptBase3
set eTypeCode='03250213'
where eCode = '11000005'

select * from typeCodes where eTypeCode='03250213'


--导入手工录入考核数据：
select * from r3
update rptBase3
set useHour4Education = F8,		--使用机时（教学）：数据格式为数值型，长度为4。
											--用于教学工作的使用机时数。根据仪器设备使用记录按教学方面统计机时数，若无使用机时，填“0”，不能空项。
											--使用机时：必要的开机准备时间+测试时间+必须的后处理时间。
	useHour4Research = F9,		--使用机时（科研）：数据格式为数值型，长度为4。
											--用于科研工作的使用机时数。根据仪器设备使用记录按科研方面统计机时数，若无使用机时，填“0”，不能空项。
	useHour4Service =F10,			--使用机时（社会服务）：数据格式为数值型，长度为4。
											--用于社会服务的使用机时数。根据仪器设备使用记录按社会服务方面统计机时数，若无使用机时，填“0”，不能空项。
	useHour4Open =F11,			--使用机时（其中开放使用机时）：数据格式为数值型，长度为4。
											--仪器对用户开放使用（用户自行上机测试、观察样品）的机时数。
	samplesNum =F12,				--测样数：数据格式为数值型，长度为6。
											--本学年在本仪器设备上测试、分析的样品数量，按照原始记录统计填报。
											--同一样品在一台仪器上测试，统计测样数为1，与测试方法和次数无关。
	trainStudents =F13,			--培训人员数（学生）：数据格式为数值型，长度为4。
											--本学年在本仪器上培训的能够独立操作的学生数，不包括各种形式的参观人数。按照原始记录统计填报。
	trainTeachers =F14,			--培训人员数（教师）：数据格式为数值型，长度为4。
											--本学年在本仪器上培训的能够独立操作的教师数，不包括各种形式的参观人数。按照原始记录统计填报。
	trainOthers =F15,				--培训人员数（其他）：数据格式为数值型，长度为4。
											--本学年在本仪器上培训的能够独立操作的其他人员数，不包括各种形式的参观人数。按照原始记录统计填报。
	experimentItems =F16,			--教学实验项目数：数据格式为数值型，长度为3。
											--本学年利用本仪器设备开设的列入教学计划的实验项目数。
	researchItems =F17,			--科研项目数：数据格式为数值型，长度为3。
											--本学年利用本仪器设备完成的各种科研项目或合作项目数。
	serviceItems =F18,			--社会服务项目数：数据格式为数值型，长度为4。
											--本学年利用本仪器设备完成的为校外承担的社会服务项目数。
	awardsFromCountry =F19,		--获奖情况（国家级）：数据格式为数值型，长度为2。利用本仪器设备在本学年获得的国家级奖励情况。
	awardsFromProvince =F20,		--获奖情况（省部级）：数据格式为数值型，长度为2。利用本仪器设备本学年获得的省部级奖励情况。
	patentsFromTeacher =F21,		--发明专利（教师）：数据格式为数值型，长度为2。
											--利用本仪器设备在本学年获得的已授权发明专利数，不含实用新型和外观设计。
	patentsFromStudent =F22,		--发明专利（学生）：数据格式为数值型，长度为2。
											--利用本仪器设备在本学年获得的已授权发明专利数，不含实用新型和外观设计。
	thesisNum1 =F23,				--论文情况（三大检索）：数据格式为数值型，长度为3。
											--利用本仪器设备在本学年发表论文情况。三大检索指：SCI、EI 、ISTP。
	thesisNum2 =F24,				--论文情况（核心刊物）：数据格式为数值型，长度为3。
											--利用本仪器设备在本学年核心期刊发表论文情况。

	keeper =F25				--负责人姓名(保管人):数据格式为字符型，长度为8。指本仪器设备或机组的负责人姓名，没有负责人的填“无”
from rptBase3 b left join r3 on b.eCode=r3.eCode

--特殊处理两台设备：
select * from rptBase3 where eCode in( 'Q0198002','10000043')

update rptBase3
set useHour4Education = 24*360		--使用机时（教学）：数据格式为数值型，长度为4。
											--用于教学工作的使用机时数。根据仪器设备使用记录按教学方面统计机时数，若无使用机时，填“0”，不能空项。
											--使用机时：必要的开机准备时间+测试时间+必须的后处理时间。
where eCode = 'Q0198002'

update rptBase3
set	useHour4Research = 24*360		--使用机时（科研）：数据格式为数值型，长度为4。
where eCode = '10000043'

--将Null处理为0
select * from rptBase3 where useHour4Education is null
update rptBase3
set useHour4Education = isnull(useHour4Education,0),		--使用机时（教学）：数据格式为数值型，长度为4。
											--用于教学工作的使用机时数。根据仪器设备使用记录按教学方面统计机时数，若无使用机时，填“0”，不能空项。
											--使用机时：必要的开机准备时间+测试时间+必须的后处理时间。
	useHour4Research = isnull(useHour4Research,0),		--使用机时（科研）：数据格式为数值型，长度为4。
											--用于科研工作的使用机时数。根据仪器设备使用记录按科研方面统计机时数，若无使用机时，填“0”，不能空项。
	useHour4Service =isnull(useHour4Service,0),			--使用机时（社会服务）：数据格式为数值型，长度为4。
											--用于社会服务的使用机时数。根据仪器设备使用记录按社会服务方面统计机时数，若无使用机时，填“0”，不能空项。
	useHour4Open =isnull(useHour4Open,0),			--使用机时（其中开放使用机时）：数据格式为数值型，长度为4。
											--仪器对用户开放使用（用户自行上机测试、观察样品）的机时数。
	samplesNum =isnull(samplesNum,0),				--测样数：数据格式为数值型，长度为6。
											--本学年在本仪器设备上测试、分析的样品数量，按照原始记录统计填报。
											--同一样品在一台仪器上测试，统计测样数为1，与测试方法和次数无关。
	trainStudents =isnull(trainStudents,0) ,			--培训人员数（学生）：数据格式为数值型，长度为4。
											--本学年在本仪器上培训的能够独立操作的学生数，不包括各种形式的参观人数。按照原始记录统计填报。
	trainTeachers =isnull(trainTeachers,0),			--培训人员数（教师）：数据格式为数值型，长度为4。
											--本学年在本仪器上培训的能够独立操作的教师数，不包括各种形式的参观人数。按照原始记录统计填报。
	trainOthers =isnull(trainOthers,0),				--培训人员数（其他）：数据格式为数值型，长度为4。
											--本学年在本仪器上培训的能够独立操作的其他人员数，不包括各种形式的参观人数。按照原始记录统计填报。
	experimentItems =isnull(experimentItems,0),			--教学实验项目数：数据格式为数值型，长度为3。
											--本学年利用本仪器设备开设的列入教学计划的实验项目数。
	researchItems =isnull(researchItems,0),			--科研项目数：数据格式为数值型，长度为3。
											--本学年利用本仪器设备完成的各种科研项目或合作项目数。
	serviceItems =isnull(serviceItems,0),			--社会服务项目数：数据格式为数值型，长度为4。
											--本学年利用本仪器设备完成的为校外承担的社会服务项目数。
	awardsFromCountry =isnull(awardsFromCountry,0),		--获奖情况（国家级）：数据格式为数值型，长度为2。利用本仪器设备在本学年获得的国家级奖励情况。
	awardsFromProvince =isnull(awardsFromProvince,0),		--获奖情况（省部级）：数据格式为数值型，长度为2。利用本仪器设备本学年获得的省部级奖励情况。
	patentsFromTeacher =isnull(patentsFromTeacher,0),		--发明专利（教师）：数据格式为数值型，长度为2。
											--利用本仪器设备在本学年获得的已授权发明专利数，不含实用新型和外观设计。
	patentsFromStudent =isnull(patentsFromStudent,0),		--发明专利（学生）：数据格式为数值型，长度为2。
											--利用本仪器设备在本学年获得的已授权发明专利数，不含实用新型和外观设计。
	thesisNum1 =isnull(thesisNum1,0),				--论文情况（三大检索）：数据格式为数值型，长度为3。
											--利用本仪器设备在本学年发表论文情况。三大检索指：SCI、EI 、ISTP。
	thesisNum2 =isnull(thesisNum2,0)				--论文情况（核心刊物）：数据格式为数值型，长度为3。
											--利用本仪器设备在本学年核心期刊发表论文情况。

from rptBase3 

--11000004及11000005的考核数据为方堃授权随意编制:
select * from rptBase3 where eCode in ('11000004','11000005')
update rptBase3 set eName ='多导生理记录仪' where eCode in ('11000004','11000005')

update rptBase3
set useHour4Education = 100,		--使用机时（教学）：数据格式为数值型，长度为4。
											--用于教学工作的使用机时数。根据仪器设备使用记录按教学方面统计机时数，若无使用机时，填“0”，不能空项。
											--使用机时：必要的开机准备时间+测试时间+必须的后处理时间。
	useHour4Research = 2150,		--使用机时（科研）：数据格式为数值型，长度为4。
											--用于科研工作的使用机时数。根据仪器设备使用记录按科研方面统计机时数，若无使用机时，填“0”，不能空项。
	useHour4Service =0,			--使用机时（社会服务）：数据格式为数值型，长度为4。
											--用于社会服务的使用机时数。根据仪器设备使用记录按社会服务方面统计机时数，若无使用机时，填“0”，不能空项。
	useHour4Open =0,			--使用机时（其中开放使用机时）：数据格式为数值型，长度为4。
											--仪器对用户开放使用（用户自行上机测试、观察样品）的机时数。
	samplesNum =256,				--测样数：数据格式为数值型，长度为6。
											--本学年在本仪器设备上测试、分析的样品数量，按照原始记录统计填报。
											--同一样品在一台仪器上测试，统计测样数为1，与测试方法和次数无关。
	trainStudents =78,			--培训人员数（学生）：数据格式为数值型，长度为4。
											--本学年在本仪器上培训的能够独立操作的学生数，不包括各种形式的参观人数。按照原始记录统计填报。
	trainTeachers =65,			--培训人员数（教师）：数据格式为数值型，长度为4。
											--本学年在本仪器上培训的能够独立操作的教师数，不包括各种形式的参观人数。按照原始记录统计填报。
	trainOthers =0,				--培训人员数（其他）：数据格式为数值型，长度为4。
											--本学年在本仪器上培训的能够独立操作的其他人员数，不包括各种形式的参观人数。按照原始记录统计填报。
	experimentItems =17,			--教学实验项目数：数据格式为数值型，长度为3。
											--本学年利用本仪器设备开设的列入教学计划的实验项目数。
	researchItems =6,			--科研项目数：数据格式为数值型，长度为3。
											--本学年利用本仪器设备完成的各种科研项目或合作项目数。
	serviceItems =121,			--社会服务项目数：数据格式为数值型，长度为4。
											--本学年利用本仪器设备完成的为校外承担的社会服务项目数。
	awardsFromCountry =0,		--获奖情况（国家级）：数据格式为数值型，长度为2。利用本仪器设备在本学年获得的国家级奖励情况。
	awardsFromProvince =0,		--获奖情况（省部级）：数据格式为数值型，长度为2。利用本仪器设备本学年获得的省部级奖励情况。
	patentsFromTeacher =0,		--发明专利（教师）：数据格式为数值型，长度为2。
											--利用本仪器设备在本学年获得的已授权发明专利数，不含实用新型和外观设计。
	patentsFromStudent =0,		--发明专利（学生）：数据格式为数值型，长度为2。
											--利用本仪器设备在本学年获得的已授权发明专利数，不含实用新型和外观设计。
	thesisNum1 =7,				--论文情况（三大检索）：数据格式为数值型，长度为3。
											--利用本仪器设备在本学年发表论文情况。三大检索指：SCI、EI 、ISTP。
	thesisNum2 =3				--论文情况（核心刊物）：数据格式为数值型，长度为3。
											--利用本仪器设备在本学年核心期刊发表论文情况。

from rptBase3 
where eCode='11000004'

update rptBase3
set useHour4Education = 200,		--使用机时（教学）：数据格式为数值型，长度为4。
											--用于教学工作的使用机时数。根据仪器设备使用记录按教学方面统计机时数，若无使用机时，填“0”，不能空项。
											--使用机时：必要的开机准备时间+测试时间+必须的后处理时间。
	useHour4Research = 1780,		--使用机时（科研）：数据格式为数值型，长度为4。
											--用于科研工作的使用机时数。根据仪器设备使用记录按科研方面统计机时数，若无使用机时，填“0”，不能空项。
	useHour4Service =0,			--使用机时（社会服务）：数据格式为数值型，长度为4。
											--用于社会服务的使用机时数。根据仪器设备使用记录按社会服务方面统计机时数，若无使用机时，填“0”，不能空项。
	useHour4Open =0,			--使用机时（其中开放使用机时）：数据格式为数值型，长度为4。
											--仪器对用户开放使用（用户自行上机测试、观察样品）的机时数。
	samplesNum =418,				--测样数：数据格式为数值型，长度为6。
											--本学年在本仪器设备上测试、分析的样品数量，按照原始记录统计填报。
											--同一样品在一台仪器上测试，统计测样数为1，与测试方法和次数无关。
	trainStudents =76,			--培训人员数（学生）：数据格式为数值型，长度为4。
											--本学年在本仪器上培训的能够独立操作的学生数，不包括各种形式的参观人数。按照原始记录统计填报。
	trainTeachers =88,			--培训人员数（教师）：数据格式为数值型，长度为4。
											--本学年在本仪器上培训的能够独立操作的教师数，不包括各种形式的参观人数。按照原始记录统计填报。
	trainOthers =0,				--培训人员数（其他）：数据格式为数值型，长度为4。
											--本学年在本仪器上培训的能够独立操作的其他人员数，不包括各种形式的参观人数。按照原始记录统计填报。
	experimentItems =21,			--教学实验项目数：数据格式为数值型，长度为3。
											--本学年利用本仪器设备开设的列入教学计划的实验项目数。
	researchItems =8,			--科研项目数：数据格式为数值型，长度为3。
											--本学年利用本仪器设备完成的各种科研项目或合作项目数。
	serviceItems =128,			--社会服务项目数：数据格式为数值型，长度为4。
											--本学年利用本仪器设备完成的为校外承担的社会服务项目数。
	awardsFromCountry =0,		--获奖情况（国家级）：数据格式为数值型，长度为2。利用本仪器设备在本学年获得的国家级奖励情况。
	awardsFromProvince =0,		--获奖情况（省部级）：数据格式为数值型，长度为2。利用本仪器设备本学年获得的省部级奖励情况。
	patentsFromTeacher =0,		--发明专利（教师）：数据格式为数值型，长度为2。
											--利用本仪器设备在本学年获得的已授权发明专利数，不含实用新型和外观设计。
	patentsFromStudent =0,		--发明专利（学生）：数据格式为数值型，长度为2。
											--利用本仪器设备在本学年获得的已授权发明专利数，不含实用新型和外观设计。
	thesisNum1 =5,				--论文情况（三大检索）：数据格式为数值型，长度为3。
											--利用本仪器设备在本学年发表论文情况。三大检索指：SCI、EI 、ISTP。
	thesisNum2 =4				--论文情况（核心刊物）：数据格式为数值型，长度为3。
											--利用本仪器设备在本学年核心期刊发表论文情况。

from rptBase3 
where eCode='11000005'

--新增设备的保管人：
update rptBase3
set keeper='王晓红'
where reportNum='201210150001'
and eCode='11000005'

update rptBase3
set keeper='王晓红'
where reportNum='201210150001'
and eCode='11000004'

update rptBase3
set keeper='徐年俊'
where reportNum='201210150001'
and eCode='Q0198002'

update rptBase3
set keeper='黄建忠'
where reportNum='201210150001'
and eCode='10000043'

update rptBase3
set keeper='李莉'
where reportNum='201210150001'
and eCode='12000162'

--方堃要求设备名称使用系统中的设备名称：
update rptBase1
set eName = e.eName
from rptBase1 r inner join equipmentList e on r.eCode= e.eCode

update rptBase3
set eName = e.eName
from rptBase3 r inner join equipmentList e on r.eCode= e.eCode

--基表一的上报格式：
select universityCode+cast(eCode as char(8))+cast(eTypeCode as char(8)) 
	+ cast(eName as CHAR(30))+cast(eModel as CHAR(20))+cast(eFormat as CHAR(30))
	+cast(fCode as CHAR(1)) +cast(cCode as CHAR(3)) +right(SPACE(12)+cast(totalAmount as varchar(12)),12)
	+acceptDate+isnull(curEqpStatus,' ') + ISNULL(aCode,' ')+cast(eUCode as CHAR(10))+cast(eUName as CHAR(50))
from rptBase1
where reportNum='201210150001'
order by eCode desc


--基表二的上报格式：
select universityCode
		+right(SPACE(8)+cast(eSumNumLastYear as varchar(8)),8)
		+right(SPACE(11)+str(eSumAmountLastYear/10000,11,2),11)
		+right(SPACE(6)+cast(bESumNumLastYear as varchar(6)),6)
		+right(SPACE(9)+str(bESumAmountLastYear/10000,9,2),9)
		+right(SPACE(6)+cast(eIncNumCurYear as varchar(6)),6)
		+right(SPACE(9)+str(eIncAmountCurYear/10000,9,2),9)
		+right(SPACE(6)+cast(eDecNumCurYear as varchar(6)),6)
		+right(SPACE(9)+str(eDecAmountCurYear/10000,9,2),9)
		+right(SPACE(8)+cast(eSumNumCurYear as varchar(8)),8)
		+right(SPACE(11)+str(eSumAmountCurYear/10000,11,2),11)
		+right(SPACE(6)+cast(bESumNumCurYear as varchar(6)),6)
		+right(SPACE(9)+str(bESumAmountCurYear/10000,9,2),9)
from rptBase2
where reportNum='201210150001'

select * from rptBase2

--基表三的上报格式：
select universityCode+cast(eCode as char(8))+cast(eTypeCode as char(8))+cast(eName as char(30))
	+right(space(12)+cast(totalAmount as varchar(12)),12)
	+cast(eModel as CHAR(20))+cast(eFormat as CHAR(200))
	--以下字段非本系统提供，应由大型设备共享系统和实验室管理系统提供！
	+right(space(4)+cast(useHour4Education as varchar(4)),4)
	+right(space(4)+cast(useHour4Research as varchar(4)),4) 
	+right(space(4)+cast(useHour4Service as varchar(4)),4) 
	+right(space(4)+cast(useHour4Open as varchar(4)),4) 
	+right(space(6)+cast(samplesNum as varchar(6)),6) 
	+right(space(4)+cast(trainStudents as varchar(4)),4) 
	+right(space(4)+cast(trainTeachers as varchar(4)),4) 
	+right(space(4)+cast(trainOthers as varchar(4)),4) 
	+right(space(3)+cast(experimentItems as varchar(3)),3) 
	+right(space(3)+cast(researchItems as varchar(3)),3) 
	+right(space(4)+cast(serviceItems as varchar(4)),4) 
	+right(space(2)+cast(awardsFromCountry as varchar(2)),2) 
	+right(space(2)+cast(awardsFromProvince as varchar(2)),2) 
	+right(space(2)+cast(patentsFromTeacher as varchar(2)),2) 
	+right(space(2)+cast(patentsFromStudent as varchar(2)),2) 
	+right(space(3)+cast(thesisNum1 as varchar(3)),3) 
	+right(space(3)+cast(thesisNum2 as varchar(3)),3) 
	+right(space(8)+cast(keeper as varchar(8)),8) 
from rptBase3
where reportNum='201210150001'

--新增的设备的保管人：



--------------------------------------------单位代码映射表编辑类存储过程-------------------
drop PROCEDURE importDepart
/*
	name:		importDepart
	function:	5.注入现系统中的单位列表到映射表中
	input: 
				@modiManID varchar(10) output,	--维护人
	output: 
				@Ret		int output			--操作成功标识
							0:成功，9：未知错误
	author:		卢苇
	CreateDate:	2012-10-8
	UpdateDate: 

*/
create PROCEDURE importDepart
	@modiManID varchar(10) output,	--维护人
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	insert eDepartCode(clgCode,clgName,uCode,uName)
	select clg.clgCode, clg.clgName, u.uCode, u.uName 
	from college clg left join useUnit u on clg.clgCode = u.clgCode
	where uCode not in (select uCode from eDepartCode)
	if @@ERROR <> 0 
	begin
		return
	end    

	set @Ret = 0

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, getdate(), '更新教育部单位映射表', '用户' + @modiManName
												+ '更新了教育部单位映射表。')

GO
--测试：
declare @ret int
exec dbo.importDepart '00000000000', @ret output
select @ret

truncate table eDepartCode
select * from eDepartCode

drop PROCEDURE queryEDepartCodeLocMan
/*
	name:		queryEDepartCodeLocMan
	function:	4.查询指定教育部单位映射表中单位是否有人正在编辑
	input: 
				@uCode varchar(8),				--使用单位代码
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的单位不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2012-10-12
	UpdateDate: 
*/
create PROCEDURE queryEDepartCodeLocMan
	@uCode varchar(8),				--使用单位代码
	@Ret int output,				--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from eDepartCode where uCode = @uCode),'')
	set @Ret = 0
GO


drop PROCEDURE lockEDepartCode4Edit
/*
	name:		lockEDepartCode4Edit
	function:	5.锁定教育部单位映射表中单位编辑，避免编辑冲突
	input: 
				@uCode varchar(8),				--使用单位代码
				@lockManID varchar(10) output,	--锁定人，如果当前单位映射表行正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的单位不存在，2:要锁定的单位正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-10-12
	UpdateDate: 
*/
create PROCEDURE lockEDepartCode4Edit
	@uCode varchar(8),				--使用单位代码
	@lockManID varchar(10) output,	--锁定人，如果当前单位映射表行正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的单位是否存在
	declare @count as int
	set @count=(select count(*) from eDepartCode where uCode = @uCode)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eDepartCode where uCode = @uCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	update eDepartCode
	set lockManID = @lockManID 
	where uCode = @uCode
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定映射单位编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了教育部单位映射表中单位['+ @uCode +']为独占式编辑。')
GO

drop PROCEDURE unlockEDepartCodeEditor
/*
	name:		unlockEDepartCodeEditor
	function:	6.释放教育部单位映射表中单位编辑锁
				注意：本过程不检查单位是否存在！
	input: 
				@uCode varchar(8),				--使用单位代码
				@lockManID varchar(10) output,	--锁定人，如果当前教育部单位映射表中单位正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2012-10-12
	UpdateDate: 
*/
create PROCEDURE unlockEDepartCodeEditor
	@uCode varchar(8),				--使用单位代码
	@lockManID varchar(10) output,	--锁定人，如果当前教育部单位映射表中单位正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eDepartCode where uCode = @uCode),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update eDepartCode set lockManID = '' where uCode = @uCode
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
	values(@lockManID, @lockManName, getdate(), '释放单位映射编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了教育部单位映射表中单位['+ @uCode +']的编辑锁。')
GO

drop PROCEDURE updateEDepartCodeMap
/*
	name:		updateEDepartCodeMap
	function:	7.更新单位映射
	input: 
				@uCode varchar(8),		--使用单位代码
				@isUsed char(1),		--是否使用：如果为不使用，则不参与教育部报表的计算
				@eUCode varchar(8),		--映射的使用单位代码
				@eUName nvarchar(30),	--映射的使用单位名称
				@switchUName xml,		--按使用方向做代码的特殊映射：这是武大特殊的要求！就是一些单位“教学”和“科研”类的资产分别放在不同的单位名称中
				@remark nvarchar(25),	--备注

				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前教育部单位映射表中单位正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：指定的单位不存在，
							2：要更新的单位正被别人锁定，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-10-10
	UpdateDate: modi by lw 2013-4-6自动计算特殊映射的编码
*/
create PROCEDURE updateEDepartCodeMap
	@uCode varchar(8),		--使用单位代码
	@isUsed char(1),		--是否使用：如果为不使用，则不参与教育部报表的计算
	@eUCode varchar(8),		--映射的使用单位代码
	@eUName nvarchar(30),	--映射的使用单位名称
	@switchUName xml,		--按使用方向做代码的特殊映射：这是武大特殊的要求！就是一些单位“教学”和“科研”类的资产分别放在不同的单位名称中
	@remark nvarchar(25),	--备注
	
	--维护人:
	@modiManID varchar(10) output,		--维护人，如果当前教育部单位映射表中单位正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,	--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的教育部单位映射表中单位是否存在
	declare @count as int
	set @count=(select count(*) from eDepartCode where uCode = @uCode)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from eDepartCode
	where uCode = @uCode
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--特殊映射，生成eUCode和eUName：
	if (cast(@switchUName as varchar(max))<>'')
	begin
		declare @clgName nvarchar(30)
		set @clgName =(select clgName from eDepartCode where uCode = @uCode)
		set @eUCode = null
		select top 1 @eUCode = eUCode, @eUName = eUName from eDepartCode where eUName = @clgName and isnull(eUCode,'') <> ''
		if (@eUCode is null)
		begin
			select top 1 @eUCode=eUCode from eDepartCode where left(eUCode,1) ='L' order by eUCode desc
			if (@eUCode is null)
				set @eUCode = 'L000001'
			else
				set @eUCode = 'L' + right('00000'+ltrim(str(cast(right(@eUCode,6) as int) +1)),7)
			set @eUName = @clgName
		end
	end

	set @updateTime = getdate()
	update eDepartCode
	set isUsed = @isUsed, eUCode = @eUCode, eUName = @eUName, switchUName = @switchUName, remark = @remark,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where uCode = @uCode
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新单位映射', '用户' + @modiManName 
												+ '更新了教育部单位映射表中单位['+ @uCode +']的映射。')
GO
--测试：
declare	@modiManID varchar(10)	--维护人，如果当前教育部单位映射表中单位正在被人占用编辑则返回该人的工号
declare	@updateTime smalldatetime--更新时间
declare	@Ret		int	--操作成功标识
set @modiManID = '0000000000'
exec updateEDepartCodeMap '00000', 'Y','1234567','测试映射单位',
N'<root>
  <code>6080100</code>
  <name>药学实验教学中心</name>
  <code>6080200</code>
  <name>药物研究室</name>
</root>','测试',
@modiManID output, @updateTime output, @Ret output
select @Ret

select * from eDepartCode

update eDepartCode
set isUsed='N', eUCode=null,eUName=null,switchUName=N''
where uCode='00000'

drop PROCEDURE delEDepartCode
/*
	name:		delEDepartCode
	function:	8.删除指定的单位
	input: 
				@uCode varchar(8),				--使用单位代码
				@delManID varchar(10) output,	--删除人，如果当前教育部单位映射表中单位正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的单位不存在，2：要删除的单位正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2012-10-12
	UpdateDate: 

*/
create PROCEDURE delEDepartCode
	@uCode varchar(8),				--使用单位代码
	@delManID varchar(10) output,	--删除人，如果当前教育部单位映射表中单位正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的单位是否存在
	declare @count as int
	set @count=(select count(*) from eDepartCode where uCode = @uCode)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from eDepartCode
	where uCode = @uCode
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete eDepartCode where uCode = @uCode
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除映射单位', '用户' + @delManName
												+ '删除了教育部单位映射表中单位['+ @uCode +']。')

GO

drop PROCEDURE clearEDepartCode
/*
	name:		clearEDepartCode
	function:	9.清除指定单位的教育部映射单位
	input: 
				@uCode varchar(8),				--使用单位代码
				@delManID varchar(10) output,	--删除人，如果当前教育部单位映射表中单位正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的单位不存在，2：要清除映射的单位正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2012-10-12
	UpdateDate: 

*/
create PROCEDURE clearEDepartCode
	@uCode varchar(8),				--使用单位代码
	@delManID varchar(10) output,	--删除人，如果当前教育部单位映射表中单位正在被人占用编辑则返回该人的工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的单位是否存在
	declare @count as int
	set @count=(select count(*) from eDepartCode where uCode = @uCode)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from eDepartCode
	where uCode = @uCode
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	update eDepartCode 
	set isUsed = 'N', eUCode = '', eUName = '', switchUName = N'', remark = ''
	where uCode = @uCode
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '清除单位映射', '用户' + @delManName
												+ '清除了教育部单位映射表中单位['+ @uCode+']的映射。')

GO


--使用导入方式手工制作教育部单位映射表：

select e.clgCode, e.clgName, e.uCode, e.uName, c.eUCode, c.eUName, c.switchUName, c.remark 
from eDepartCode e left join c on e.clgCode=c.clgCode and e.uCode=c.uCode

update eDepartCode
set eUCode = c.eUCode, eUName=c.eUName, switchUName= convert(xml, c.switchUName,0), remark=c.remark
from eDepartCode e inner join c on e.clgCode=c.clgCode and e.uCode=c.uCode

update eDepartCode
set isUsed='Y'
where eUCode is not null

update eDepartCode
set eUName=''
where eUCode is not null and eUName is null

select * from eDepartCode
where eUCode is not null

select c.*, e.*
from eDepartCode e right join c on e.clgCode=c.clgCode and e.uCode=c.uCode
where e.clgCode is null or rtrim(e.clgCode)=''

select * from c where clgCode not in (select clgCode from college)
select * from c where uCode not in (select uCode from useUnit)
select clgCode, uCode, count(*)
from c
group by clgCode,uCode

select * from useUnit where uCode = '03301'

select * from college where clgCode='033'
select * from useUnit where clgCode='033'
select * from college where clgCode='123'
select * from useUnit where clgCode='123'
select * from useUnit where uCode='12302'

select * from c where uCode='03301'
update c
set clgCode='033'
where uCode='03301'


--生成报表：
declare @Ret int, @reportNum as varchar(12)
exec dbo.addReport 903, '基表三', '2012', '2011-09-01', '2012-08-31', 
'武汉大学', '00200977', @Ret output, @reportNum output
select @Ret, @reportNum

select * from userInfo where cName like '毕%'
select * from rptBase2 where reportNum='201210150001'

select eCode,* from l where eCode not in (select eCode from rptBase3 where reportNum='201210120005')
select eCode, * from rptBase3 where reportNum='201210120005'  and eCode not in (select eCode from l)

use epdc211
select * from rptBase2 where reportNum='201210150001'
select COUNT(*),SUM(totalAmount) from rptBase1 where reportNum='201210150001'

select * from [rptBase3] where reportNum='201210150001'

select * from equipmentList
where eCode='00J00947'


select * from reportCenter
select count(*), SUM(totalAmount) from [rptBase1] where reportNum='201210080012'
select * from [rptBase1] where reportNum='201210110004' and eCode not in (select eCode from [rptBase1] where reportNum='201210080007')
select * from equipmentList where eCode='11018354'
select * from [rptBase2] where reportNum='201210080004' 

select * from [rptBase2]
select count(*),SUM(totalAmount) from rptBase1 where reportNum='201210090003'

select * from [rptBase1] where reportNum='201210080013' and left(eucode,1)='L'



--基表三的录入数据：

select * from r3





--年度设备统计
use epdc211
--年度采购设备清单：
declare	@totalStartDate varchar(10)	--统计开始日期:"yyyy-MM-dd"格式
declare	@totalEndDate varchar(10)	--统计结束日期:"yyyy-MM-dd"格式
set @totalStartDate='2014-01-01'
set @totalEndDate='2014-12-31'
select e.eCode, convert(varchar(10),e.acceptDate,120), 
--状态：(报废前状态)
case (case e.curEqpStatus 
		when '6' then dbo.getEqpStatusBeforeScrap(e.eCode)
		when '5' then '9' 
		when '7' then '9'
		else e.curEqpStatus 
	  end)
when '1' then '在用'
when '2' then '多余'
when '3' then '待修'
when '4' then '待报废'
when '9' then '其他'
when '8' then '降档'
else '不明'
end, 
--现状
case e.curEqpStatus 
when '1' then '在用'
when '2' then '多余'
when '3' then '待修'
when '4' then '待报废'
when '5' then '丢失'
when '6' then '报废'
when '7' then '调出'
when '8' then '降档'
when '9' then '其他'
else '不明'
end, 
e.eName, e.eModel, e.eFormat,
isnull(e.cCode,'000'), c.cName, 
isnull(factory,'不明'),	isnull(business,'不明'),
annexAmount, 
dbo.getEqpAnnexAmount(e.eCode,@totalEndDate), --按统计日期修订后的附件金额
e.eTypeCode,  case isnull(e.eTypeName,'') when '' then e.eName else e.eTypeName end, 
e.aTypeCode, g.aTypeName,
f.fName, a.aName,
price, e.totalAmount, 
e.price + dbo.getEqpAnnexAmount(e.eCode,@totalEndDate), --按统计日期修订后的总金额
e.clgCode, clg.clgName,
isnull(e.uCode,''), isnull(u.uName,''),
keeper
from equipmentList e left join college clg on e.clgCode = clg.clgCode
	left join useUnit u on e.uCode = u.uCode
	left join country c on e.cCode = c.cCode
	left join GBT14885 g on e.aTypeCode = g.aTypeCode
	left join fundSrc f on e.fCode = f.fCode
	left join appDir a on e.aCode = a.aCode
where convert(varchar(10),acceptDate,120) > @totalStartDate and convert(varchar(10),acceptDate,120) <= @totalEndDate
order by e.acceptDate


--年度在库设备清单：
declare	@totalStartDate varchar(10)	--统计开始日期:"yyyy-MM-dd"格式
declare	@totalEndDate varchar(10)	--统计结束日期:"yyyy-MM-dd"格式
set @totalStartDate='2014-01-01'
set @totalEndDate='2014-12-31'
select e.eCode, convert(varchar(10),e.acceptDate,120), 
--状态：(报废前状态)
case (case e.curEqpStatus 
		when '6' then dbo.getEqpStatusBeforeScrap(e.eCode)
		when '5' then '9' 
		when '7' then '9'
		else e.curEqpStatus 
	  end)
when '1' then '在用'
when '2' then '多余'
when '3' then '待修'
when '4' then '待报废'
when '9' then '其他'
when '8' then '降档'
else '不明'
end, 
--现状
case e.curEqpStatus 
when '1' then '在用'
when '2' then '多余'
when '3' then '待修'
when '4' then '待报废'
when '5' then '丢失'
when '6' then '报废'
when '7' then '调出'
when '8' then '降档'
when '9' then '其他'
else '不明'
end, 
e.eName, e.eModel, e.eFormat,
isnull(e.cCode,'000'), c.cName, 
isnull(factory,'不明'),	isnull(business,'不明'),
annexAmount, 
dbo.getEqpAnnexAmount(e.eCode,@totalEndDate), --按统计日期修订后的附件金额
e.eTypeCode,  case isnull(e.eTypeName,'') when '' then e.eName else e.eTypeName end, 
e.aTypeCode, g.aTypeName,
f.fName, a.aName,
e.price, e.totalAmount, 
e.price + dbo.getEqpAnnexAmount(e.eCode,@totalEndDate), --按统计日期修订后的总金额
e.clgCode, clg.clgName,
isnull(u.uCode,''), isnull(u.uName,''),
keeper
from equipmentList e left join college clg on e.clgCode = clg.clgCode
	left join useUnit u on e.uCode = u.uCode
	left join country c on e.cCode = c.cCode
	left join GBT14885 g on e.aTypeCode = g.aTypeCode
	left join fundSrc f on e.fCode = f.fCode
	left join appDir a on e.aCode = a.aCode
where convert(varchar(10),acceptDate,120) <= @totalEndDate 
and (e.curEqpStatus <> '6' or (e.curEqpStatus = '6' and convert(varchar(10),scrapDate,120) > @totalEndDate))
order by e.acceptDate



--报废设备一览表：
declare	@totalStartDate varchar(10)	--统计开始日期:"yyyy-MM-dd"格式
declare	@totalEndDate varchar(10)	--统计结束日期:"yyyy-MM-dd"格式
set @totalStartDate='2014-01-01'
set @totalEndDate='2014-12-31'
select convert(varchar(10),scrapDate,120),e.eCode, convert(varchar(10),e.acceptDate,120), 
e.eName, e.eModel, e.eFormat,
isnull(e.cCode,'000'), c.cName, 
isnull(factory,'不明'),	isnull(business,'不明'),
annexAmount, 
e.eTypeCode,  case isnull(e.eTypeName,'') when '' then e.eName else e.eTypeName end, 
e.aTypeCode, g.aTypeName,
f.fName, a.aName,
price, e.totalAmount, 
e.clgCode, clg.clgName,
isnull(u.uCode,''), isnull(u.uName,''),
keeper
from equipmentList e left join college clg on e.clgCode = clg.clgCode
	left join useUnit u on e.uCode = u.uCode
	left join country c on e.cCode = c.cCode
	left join GBT14885 g on e.aTypeCode = g.aTypeCode
	left join fundSrc f on e.fCode = f.fCode
	left join appDir a on e.aCode = a.aCode
where convert(varchar(10),scrapDate,120) > @totalStartDate and convert(varchar(10),scrapDate,120) <= @totalEndDate
order by e.scrapDate


--获取指定日期前的附件金额：
drop FUNCTION getEqpAnnexAmount
/*
	name:		getEqpAnnexAmount
	function:	1.获取设备在指定日期前的附件金额
	input: 
				@eCode char(8),	--设备编号
				@totalEndDate varchar(10) --统计截止日期
	output: 
				return char(1)	--设备报废前的状态
	author:		卢苇
	CreateDate:	2015-5-30
	UpdateDate: 
*/
create FUNCTION getEqpAnnexAmount
(  
	@eCode char(8),	--设备编号
	@totalEndDate varchar(10) --统计截止日期
)  
RETURNS numeric(12, 2)
WITH ENCRYPTION
AS      
begin
	--采用设备中的 附件金额-超出截止日期的附件增加金额 计算，这样保证了脏数据（验收时如果附件同时验收，原来的系统没有附件清单的入库）能正确显示！
	DECLARE @total numeric(12, 2), @overTotal numeric(12, 2)--附件金额全值/超出截止日期的附件增加金额
	select @total = isnull(annexAmount,0)
	from equipmentList
	where eCode =@eCode
	select @overTotal = isnull(sum(an.totalAmount),0) 
	from equipmentAnnex an left join eqpAcceptInfo a on an.acceptApplyID = a.acceptApplyID
	where an.eCode =@eCode and convert(varchar(10),a.acceptDate,120) > @totalEndDate
	return @total - @overTotal
end
--测试：
select dbo.getEqpAnnexAmount('15007011','2015-12-31')


select sum(an.totalAmount)
from equipmentAnnex an left join eqpAcceptInfo a on an.acceptApplyID = a.acceptApplyID
where an.eCode ='V0780003' and convert(varchar(10),a.acceptDate,120) > '2014-12-31'

