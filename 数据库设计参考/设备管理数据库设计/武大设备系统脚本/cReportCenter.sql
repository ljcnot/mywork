use epdc211
--财政部固定资产分类代码表（GB/T 14885-1994）：
DROP TABLE GBT14885
CREATE TABLE [dbo].[GBT14885](
	RwID int NOT NULL,						--序号
	kind varchar(2) not null,				--门类码
	kindName nvarchar(20) not null,			--门类名称
	classCode varchar(1) null,				--大类码
	subClassCode varchar(1) null,			--中类码
	itemCode varchar(2) null,				--小类码
	
	aTypeCode varchar(7) NOT NULL,			--标准代码
	aTypeName nvarchar(60) NOT NULL,		--标准名称
	unit nvarchar(10) NULL,					--计量单位
	QTYUnit varchar(60) NULL DEFAULT (''),	--数量单位
	PrntCode varchar(60) NULL DEFAULT (''),	--树状结构码
	[Level] int NULL DEFAULT ((-1)),		--结构层次：当为叶子节点的时候为负数，abs(Level)为层次代码
	ShrtNm varchar(25) NULL DEFAULT (''),
	[Desc] varchar(255) NULL DEFAULT(''),	--描述

	inputCode varchar(5) null,				--输入码
	isOff char(1) null default('0') ,		--停用标识:“0”代表在用，“1”代表停用
	offDate smalldatetime null,				--停用日期

	CreateDate smalldatetime NULL,			--创建时间
	ModifyDate smalldatetime NULL,			--修改时间
	Creater nvarchar(30) NULL DEFAULT(''),--创建人
	RwVrsn int NULL DEFAULT ((0)),			--版本
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
--财政部报表单位代码转换表：
drop TABLE [dbo].[collegeCode]
CREATE TABLE [dbo].[collegeCode](
	rowNum int IDENTITY(1,1) NOT NULL,	--序号:为了保证用户可以编辑编码而增加的行号
	clgCode char(3) not null,			--主键：院部代码
	clgName nvarchar(30) not null,		--院部名称	
	dCode varchar(7) null,				--财政部报表系统院部代码
	dName nvarchar(30) null,			--财政部报表系统院部名称
	
	remark nvarchar(50) null,			--备注

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

--财政部报表中心管理表：
drop table CZreportCenter
CREATE TABLE [dbo].[CZreportCenter](
	reportNum varchar(12) not null,		--主键：报表编号,由第800号号码发生器产生
	theTitle nvarchar(100) null,		--报表标题
	theYear varchar(4) null,			--统计年度
	totalEndDate smalldatetime null,	--统计资产验收结束日期
	--资产（设备）分类汇总信息：
	LandValue numeric(19,2) not null,		--1.土地合计金额
	BuildingValue numeric(19,2) not null,	--2.房屋构筑物合计金额
	generalEqpValue numeric(19,2) not null,	--3.通用设备合计金额
	specialEqpValue numeric(19,2) not null,	--4.专用设备合计金额
	EqpCarValue numeric(19,2) not null,		--5.交通运输设备合计金额
	EqpElectricalValue numeric(19,2) not null,--6.电气设备合计金额
	EqpCommunicateValue numeric(19,2) not null,--7.电子产品及通信设备合计金额
	EqpInstrumentValue numeric(19,2) not null,--8.仪器仪表及量具合计金额
	EqpSportValue numeric(19,2) not null,	--9.文艺体育设备合计金额
	EqpCulturalValue numeric(19,2) not null,--10.图书文物及陈列品合计金额
	EqpFurnitureValue numeric(19,2) not null,--11.家具用具及其他类合计金额
	intangibleValue numeric(19,2) not null,	--12.无形资产合计金额
	
	makeUnit nvarchar(50) null,			--制表单位
	makeDate smalldatetime null,		--制表日期

	makerID varchar(10) null,			--制表人工号
	maker varchar(30) null,				--制表人
 CONSTRAINT [PK_CZreportCenter] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--1.土地：Land
drop TABLE [dbo].[Land]
CREATE TABLE [dbo].[Land](
	reportNum varchar(12) not null,		--主键/外键：报表编号
	QingCXTZCBH	varchar(12) not null,	--主键：资产编号
	BillDate smalldatetime not null,	--单据日期
	CatalogID varchar(7) not null,		--资产分类代码
	StdName nvarchar(30) not null,		--资产名称
	JiLDWCZB nvarchar(10) not null,		--计量单位
	TuDMJ numeric(19,2) not null,		--土地面积
	TuDZZMMJ numeric(19,2) not null,	--土地证载明面积
	QuanSZM	nvarchar(30) null,			--权属证明
	QuanSZH	nvarchar(30) null,			--权属证号
	ChanQXSName	nvarchar(10) null,		--产权形式:有产权，无产权
	DiH	nvarchar(150) null,				--地号
	QuanSXZName	nvarchar(10) null,		--权属性质:国有，集体
	FaZSJ smalldatetime null,			--发证时间
	KuaiJPZH varchar(12) null,			--会计凭证号
	ZuoLWZ nvarchar(150) not null,		--坐落位置
	JiaZXSName nvarchar(10) not null,	--价值类型:原值，暂估值，重置值，无价值
	OrgnValue numeric(19,2)	not null,	--价值:价值类型不是"无价值"时必填,与"财政性拨款"、"事业收入"与"其他资金"合计相等
	JunJ numeric(19,2) null,			--均价:均价＝价值/建筑面积
	CaiZXJFLY numeric(19,2) null,		--财政性拨款
	ShiYSR numeric(19,2) null,			--事业收入
	QiZYSWSR numeric(19,2) null,		--事业收入：预算外收入
	QiTJFLY numeric(19,2) null,			--其他资金
	QiZCZXJYZJ numeric(19,2) null,		--其他资金：财政性结余资金
	BuildDate smalldatetime not null,	--取得日期
	SrcName	nvarchar(10) not null,		--取得方式:购置，调拨，捐赠，划拨，其他，置换
	--自用面积，出借面积，出租面积，对外投资面积，担保面积，其他面积之和必等于土地面积
	ZiYMJ numeric(19,2) null,			--自用面积
	ZiYJZ numeric(19,2) null,			--自用价值:自用价值＝均价*自用面积
	ChuJMJ numeric(19,2) null,			--出借面积
	ChuJJZ numeric(19,2) null,			--出借价值:出借价值＝均价*出借面积
	ChuZMJ numeric(19,2) null,			--出租面积
	ChuZJZ numeric(19,2) null,			--出租价值:出租价值＝均价*出租面积
	DuiWTZMJ numeric(19,2) null,		--对外投资面积
	DuiWTZJZ numeric(19,2) null,		--对外投资价值:对外投资价值＝均价*对外投资面积
	DuiBMJ numeric(19,2) null,			--担保面积
	DanBJZ numeric(19,2) null,			--担保价值:担保价值＝均价*担保面积
	QiTMJ numeric(19,2) null,			--其他面积
	QiTJZ numeric(19,2) null,			--其他价值:其他价值＝均价*其他面积

	CGZZXS3	nvarchar(10) not null,		--采购组织形式:政府集中机构采购，部门集中采购，分散采购，其他
	UsedStateBDName	nvarchar(10) not null, --使用状况:在用，未使用，不需用，其他
	ChuJDW nvarchar(60) null,			--出借单位:有出借面积时，出借单位必填
	ChuZDW nvarchar(60) null,			--出租单位:有出租面积时，出租单位必填
	BMID varchar(12) not null,			--使用\管理部门
	Remark nvarchar(250) null,			--备注:当"取得方式""使用状况""使用方向"为"其他"时，备注必填
	Operator nvarchar(30) not null,		--制单人
 CONSTRAINT [PK_Land] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[QingCXTZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[Land]  WITH CHECK ADD  CONSTRAINT [FK_Land_CZreportCenter] FOREIGN KEY([reportNum])
REFERENCES [dbo].[CZreportCenter] ([reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Land] CHECK CONSTRAINT [FK_Land_CZreportCenter]

--2.房屋构筑物：Building
drop TABLE [dbo].[Building]
CREATE TABLE [dbo].[Building](
	reportNum varchar(12) not null,		--主键/外键：报表编号
	QingCXTZCBH	varchar(12) not null,	--主键：资产编号
	BillDate smalldatetime not null,	--单据日期
	CatalogID varchar(7) not null,		--资产分类代码
	StdName nvarchar(30) not null,		--资产名称
	JiLDWCZB nvarchar(10) not null,		--计量单位
	JianZMJ numeric(19,2) not null,		--建筑面积
	BuildDate smalldatetime not null,	--取得日期
	GuoZWJL int null,					--构筑物计量:资产为构筑物时必填
	JianZJGName	nvarchar(10) not null,	--建筑结构:钢结构，钢混结构，砖混结构，砖木结构，其他

	BanGSMJ numeric(19,2) null,			--办公室面积
	HuiYSMJ numeric(19,2) null,			--会议室面积
	CheKMJ numeric(19,2) null,			--车库面积
	ShiTMJ numeric(19,2) null,			--食堂面积
	PeiDSMJ numeric(19,2) null,			--配电室面积
	JiFMJ numeric(19,2) null,			--机房面积
	ShiYMJ numeric(19,2) null,			--使用面积:使用面积小于建筑面积
	DiaXMJ numeric(19,2) null,			--地下面积

	KuaiJPZH varchar(12) null,			--会计凭证号
	ChanQXSName	nvarchar(10) null,		--产权形式:有产权，无产权
	QuanSZM	nvarchar(30) null,			--权属证明:当有产权时，权属证明必填
	QuanSZH	nvarchar(30) null,			--权属证号:当有产权时，权属证号必填
	FaZSJ smalldatetime null,			--发证时间:当有产权时，必证日期必填
	JiaZXSName nvarchar(10) not null,	--价值类型:原值，暂估值，重置值，无价值
	OrgnValue numeric(19,2)	not null,	--价值:价值类型不是"无价值"时必填,与"财政性拨款"、"事业收入"与"其他资金"合计相等
	JunJ numeric(19,2) null,			--均价:均价＝价值/建筑面积

	CaiZXJFLY numeric(19,2) null,		--财政性拨款
	ShiYSR numeric(19,2) null,			--事业收入
	QiZYSWSR numeric(19,2) null,		--事业收入：预算外收入
	QiTJFLY numeric(19,2) null,			--其他资金
	QiZCZXJYZJ numeric(19,2) null,		--其他资金：财政性结余资金
	SrcName	nvarchar(10) not null,		--取得方式:购置，调拨，捐赠，划拨，其他，置换，自建

	JunGRQ smalldatetime not null,		--竣工日期

	--自用面积，出借面积，出租面积，对外投资面积，担保面积，其他面积之和必等于土地面积
	ZiYMJ numeric(19,2) null,			--自用面积
	ZiYJZ numeric(19,2) null,			--自用价值:自用价值＝均价*自用面积
	ChuJMJ numeric(19,2) null,			--出借面积
	ChuJJZ numeric(19,2) null,			--出借价值:出借价值＝均价*出借面积
	ChuZMJ numeric(19,2) null,			--出租面积
	ChuZJZ numeric(19,2) null,			--出租价值:出租价值＝均价*出租面积
	DuiWTZMJ numeric(19,2) null,		--对外投资面积
	DuiWTZJZ numeric(19,2) null,		--对外投资价值:对外投资价值＝均价*对外投资面积
	DuiBMJ numeric(19,2) null,			--担保面积
	DanBJZ numeric(19,2) null,			--担保价值:担保价值＝均价*担保面积
	QiTMJ numeric(19,2) null,			--其他面积
	QiTJZ numeric(19,2) null,			--其他价值:其他价值＝均价*其他面积

	CGZZXS3	nvarchar(10) not null,		--采购组织形式:政府集中机构采购，部门集中采购，分散采购，其他
	UsedStateBDName	nvarchar(10) not null, --使用状况:在用，未使用，不需用，危房不能用，其他
	ChuJDW nvarchar(60) null,			--出借单位:有出借面积时，出借单位必填
	ChuZDW nvarchar(60) null,			--出租单位:有出租面积时，出租单位必填

	DPRCTStateName nvarchar(10) not null,	--折旧状态:不提折旧，提折旧，已完成折旧
	DPRCTWayName nvarchar(10) null,		--折旧方法:折旧状态为“提折旧”时必填,参考"折旧状态"填写
	ExptMonth int null,					--使用年限/月份:折旧状态为“提折旧”时必填,以月份为计量单位
	UsedMonth int null,					--已提折旧月数:非必填，以月份为计量单位
	RMValueRate numeric(19,2) null,		--残值率
	DeValue numeric(19,2) null,			--减值准备

	ZuoLWZ nvarchar(150) not null,		--坐落位置
	TouRBDWSYSJ	smalldatetime null,		--投入本单位使用时间:
	BMID varchar(12) not null,			--使用\管理部门
	Remark nvarchar(250) null,			--备注:当"取得方式""使用状况""使用方向"为"其他"时，备注必填
	Operator nvarchar(30) not null,		--制单人
 CONSTRAINT [PK_Building] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[QingCXTZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[Building]  WITH CHECK ADD  CONSTRAINT [FK_Building_CZreportCenter] FOREIGN KEY([reportNum])
REFERENCES [dbo].[CZreportCenter] ([reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Building] CHECK CONSTRAINT [FK_Building_CZreportCenter]

--3.通用设备：generalEqp
select * from generalEqp
drop TABLE [dbo].[generalEqp]
CREATE TABLE [dbo].[generalEqp](
	reportNum varchar(12) not null,		--主键/外键：报表编号
	QingCXTZCBH	varchar(12) not null,	--主键：资产编号
	BillDate smalldatetime not null,	--单据日期
	CatalogID varchar(7) not null,		--资产分类代码
	StdName nvarchar(30) not null,		--资产名称
	JiLDWCZB nvarchar(10) not null,		--计量单位
	PinP nvarchar(30) null,				--品牌
	Spec nvarchar(60) null,				--规格型号
	JiaZXSName nvarchar(10) not null,	--价值类型:原值，暂估值，重置值，无价值
	OrgnValue numeric(19,2)	not null,	--价值:价值类型不是"无价值"时必填,与"财政性拨款"、"事业收入"与"其他资金"合计相等

	CaiZXJFLY numeric(19,2) null,		--财政性拨款
	ShiYSR numeric(19,2) null,			--事业收入
	QiZYSWSR numeric(19,2) null,		--事业收入：预算外收入
	QiTJFLY numeric(19,2) null,			--其他资金
	QiZCZXJYZJ numeric(19,2) null,		--其他资金：财政性结余资金

	KuaiJPZH varchar(12) null,			--会计凭证号
	SrcName	nvarchar(10) not null,		--取得方式:购置,调拨,捐赠,划拨,置换,其他
	BuildDate smalldatetime not null,	--取得日期
	BaoXJZRQ smalldatetime null,		--保修截止日期

	CGZZXS3	nvarchar(10) not null,		--采购组织形式:政府集中机构采购，部门集中采购，分散采购，其他
	UsedStateBDName	nvarchar(10) not null, --使用状况:在用，未使用，不需用，毁坏不能用，其他
	UsedwayBDName nvarchar(10) not null,	--使用方向:自用,出租，出借，对外投资，担保，其他
	ChuZCJDFDW nvarchar(60) null,		--出租/出借对方单位

	DPRCTStateName nvarchar(10) not null,	--折旧状态:不提折旧，提折旧，已完成折旧
	DPRCTWayName nvarchar(10) null,		--折旧方法:折旧状态为“提折旧”时必填,参考"折旧状态"填写
	ExptMonth int null,					--使用年限/月份:折旧状态为“提折旧”时必填,以月份为计量单位
	UsedMonth int null,					--已提折旧月数:非必填，以月份为计量单位
	RMValueRate numeric(19,2) null,		--残值率
	DeValue numeric(19,2) null,			--减值准备

	PlaceID nvarchar(150) not null,		--存放地点
	BMID varchar(12) not null,			--使用\管理部门
	ShiYRName nvarchar(30) null,		--使用人名称
	Remark nvarchar(250) null,			--备注:当"取得方式""使用状况""使用方向"为"其他"时，备注必填
	Operator nvarchar(30) not null,		--制单人
	GuanLRID nvarchar(30) null,			--管理人

 CONSTRAINT [PK_generalEqp] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[QingCXTZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[generalEqp]  WITH CHECK ADD  CONSTRAINT [FK_generalEqp_CZreportCenter] FOREIGN KEY([reportNum])
REFERENCES [dbo].[CZreportCenter] ([reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[generalEqp] CHECK CONSTRAINT [FK_generalEqp_CZreportCenter]

--4.专用设备：specialEqp
--与3.通用设备：generalEqp表结构完全一致！
drop TABLE [dbo].[specialEqp]
CREATE TABLE [dbo].[specialEqp](
	reportNum varchar(12) not null,		--主键/外键：报表编号
	QingCXTZCBH	varchar(12) not null,	--主键：资产编号
	BillDate smalldatetime not null,	--单据日期
	CatalogID varchar(7) not null,		--资产分类代码
	StdName nvarchar(30) not null,		--资产名称
	JiLDWCZB nvarchar(10) not null,		--计量单位
	PinP nvarchar(30) null,				--品牌
	Spec nvarchar(60) null,				--规格型号
	JiaZXSName nvarchar(10) not null,	--价值类型:原值，暂估值，重置值，无价值
	OrgnValue numeric(19,2)	not null,	--价值:价值类型不是"无价值"时必填,与"财政性拨款"、"事业收入"与"其他资金"合计相等

	CaiZXJFLY numeric(19,2) null,		--财政性拨款
	ShiYSR numeric(19,2) null,			--事业收入
	QiZYSWSR numeric(19,2) null,		--事业收入：预算外收入
	QiTJFLY numeric(19,2) null,			--其他资金
	QiZCZXJYZJ numeric(19,2) null,		--其他资金：财政性结余资金

	KuaiJPZH varchar(12) null,			--会计凭证号
	SrcName	nvarchar(10) not null,		--取得方式:购置,调拨,捐赠,划拨,置换,其他
	BuildDate smalldatetime not null,	--取得日期
	BaoXJZRQ smalldatetime null,		--保修截止日期

	CGZZXS3	nvarchar(10) not null,		--采购组织形式:政府集中机构采购，部门集中采购，分散采购，其他
	UsedStateBDName	nvarchar(10) not null, --使用状况:在用，未使用，不需用，毁坏不能用，其他
	UsedwayBDName nvarchar(10) not null,	--使用方向:自用,出租，出借，对外投资，担保，其他
	ChuZCJDFDW nvarchar(60) null,		--出租/出借对方单位

	DPRCTStateName nvarchar(10) not null,	--折旧状态:不提折旧，提折旧，已完成折旧
	DPRCTWayName nvarchar(10) null,		--折旧方法:折旧状态为“提折旧”时必填,参考"折旧状态"填写
	ExptMonth int null,					--使用年限/月份:折旧状态为“提折旧”时必填,以月份为计量单位
	UsedMonth int null,					--已提折旧月数:非必填，以月份为计量单位
	RMValueRate numeric(19,2) null,		--残值率
	DeValue numeric(19,2) null,			--减值准备

	PlaceID nvarchar(150) not null,		--存放地点
	BMID varchar(12) not null,			--使用\管理部门
	ShiYRName nvarchar(30) null,		--使用人名称
	Remark nvarchar(250) null,			--备注:当"取得方式""使用状况""使用方向"为"其他"时，备注必填
	Operator nvarchar(30) not null,		--制单人
	GuanLRID nvarchar(30) null,			--管理人

 CONSTRAINT [PK_specialEqp] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[QingCXTZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[specialEqp]  WITH CHECK ADD  CONSTRAINT [FK_specialEqp_CZreportCenter] FOREIGN KEY([reportNum])
REFERENCES [dbo].[CZreportCenter] ([reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[specialEqp] CHECK CONSTRAINT [FK_specialEqp_CZreportCenter]

--5.交通运输设备：EqpCar
drop TABLE [dbo].[EqpCar]
CREATE TABLE [dbo].[EqpCar](
	reportNum varchar(12) not null,		--主键/外键：报表编号
	QingCXTZCBH	varchar(12) not null,	--主键：资产编号
	BillDate smalldatetime not null,	--单据日期
	CatalogID varchar(7) not null,		--资产分类代码
	StdName nvarchar(30) not null,		--资产名称
	JiLDWCZB nvarchar(10) not null,		--计量单位

	CheLCDName nvarchar(10) null,		--车辆产地:进口,国产(含组装)
	Spec nvarchar(60) null,				--规格型号
	CheJH nvarchar(36) null,			--车架号:当车牌号存在时,车架号不能为空
	ChePH nvarchar(10) null,			--车牌号
	ChangPXH nvarchar(20) null,			--厂牌型号:当车牌号存在时,厂牌型号不能为空
	FaDJH nvarchar(20) null,			--发动机号:当车牌号存在时,发动机号不能为空
	PaiQL varchar(4) null,				--排气量:当车牌号存在时,排气量不能为空

	BianZQKName nvarchar(10) not null,	--编制情况:财政在编,非财政在编
	JiaZXSName nvarchar(10) not null,	--价值类型:原值，暂估值，重置值，无价值
	OrgnValue numeric(19,2)	not null,	--价值:价值类型不是"无价值"时必填,与"财政性拨款"、"事业收入"与"其他资金"合计相等

	CaiZXJFLY numeric(19,2) null,		--财政性拨款
	ShiYSR numeric(19,2) null,			--事业收入
	QiZYSWSR numeric(19,2) null,		--事业收入：预算外收入
	QiTJFLY numeric(19,2) null,			--其他资金
	QiZCZXJYZJ numeric(19,2) null,		--其他资金：财政性结余资金

	YongTFLName nvarchar(10) null,		--用途分类:领导用车,公务用车,专业用车,生活用车,接待用车,其他用车
	KuaiJPZH varchar(12) null,			--会计凭证号
	BuildDate smalldatetime not null,	--取得日期
	SrcName	nvarchar(10) not null,		--取得方式:购置,调拨,捐赠,划拨,置换,其他
	BaoXJZRQ smalldatetime null,		--保修截止日期
	UseDate smalldatetime null,			--使用日期
	UsedwayBDName nvarchar(10) not null,--使用方向:自用,出租，出借，对外投资，担保，其他

	ChuZCJDFDW nvarchar(60) null,		--出租/出借对方单位
	BMID varchar(12) not null,			--使用\管理部门
	ShiYRName nvarchar(30) null,		--使用人名称

	CGZZXS3	nvarchar(10) not null,		--采购组织形式:政府集中机构采购，部门集中采购，分散采购，其他
	UsedStateBDName	nvarchar(10) not null, --使用状况:在用，未使用，不需用，毁坏不能用，其他

	DPRCTStateName nvarchar(10) not null,	--折旧状态:不提折旧，提折旧，已完成折旧
	DPRCTWayName nvarchar(10) null,		--折旧方法:折旧状态为“提折旧”时必填,参考"折旧状态"填写
	ExptMonth int null,					--使用年限/月份:折旧状态为“提折旧”时必填,以月份为计量单位
	UsedMonth int null,					--已提折旧月数:非必填，以月份为计量单位
	RMValueRate numeric(19,2) null,		--残值率
	DeValue numeric(19,2) null,			--减值准备

	Remark nvarchar(250) null,			--备注:当"取得方式""使用状况""使用方向"为"其他"时，备注必填
	Operator nvarchar(30) not null,		--制单人
	GuanLRID nvarchar(30) null,			--管理人
 CONSTRAINT [PK_EqpCar] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[QingCXTZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[EqpCar]  WITH CHECK ADD  CONSTRAINT [FK_EqpCar_CZreportCenter] FOREIGN KEY([reportNum])
REFERENCES [dbo].[CZreportCenter] ([reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EqpCar] CHECK CONSTRAINT [FK_EqpCar_CZreportCenter]

--6.电气设备：EqpElectrical
--与3.通用设备：generalEqp表结构完全一致！
drop TABLE [dbo].[EqpElectrical]
CREATE TABLE [dbo].[EqpElectrical](
	reportNum varchar(12) not null,		--主键/外键：报表编号
	QingCXTZCBH	varchar(12) not null,	--主键：资产编号
	BillDate smalldatetime not null,	--单据日期
	CatalogID varchar(7) not null,		--资产分类代码
	StdName nvarchar(30) not null,		--资产名称
	JiLDWCZB nvarchar(10) not null,		--计量单位
	PinP nvarchar(30) null,				--品牌
	Spec nvarchar(60) null,				--规格型号
	JiaZXSName nvarchar(10) not null,	--价值类型:原值，暂估值，重置值，无价值
	OrgnValue numeric(19,2)	not null,	--价值:价值类型不是"无价值"时必填,与"财政性拨款"、"事业收入"与"其他资金"合计相等

	CaiZXJFLY numeric(19,2) null,		--财政性拨款
	ShiYSR numeric(19,2) null,			--事业收入
	QiZYSWSR numeric(19,2) null,		--事业收入：预算外收入
	QiTJFLY numeric(19,2) null,			--其他资金
	QiZCZXJYZJ numeric(19,2) null,		--其他资金：财政性结余资金

	KuaiJPZH varchar(12) null,			--会计凭证号
	SrcName	nvarchar(10) not null,		--取得方式:购置,调拨,捐赠,划拨,置换,其他
	BuildDate smalldatetime not null,	--取得日期
	BaoXJZRQ smalldatetime null,		--保修截止日期

	CGZZXS3	nvarchar(10) not null,		--采购组织形式:政府集中机构采购，部门集中采购，分散采购，其他
	UsedStateBDName	nvarchar(10) not null, --使用状况:在用，未使用，不需用，毁坏不能用，其他
	UsedwayBDName nvarchar(10) not null,	--使用方向:自用,出租，出借，对外投资，担保，其他
	ChuZCJDFDW nvarchar(60) null,		--出租/出借对方单位

	DPRCTStateName nvarchar(10) not null,	--折旧状态:不提折旧，提折旧，已完成折旧
	DPRCTWayName nvarchar(10) null,		--折旧方法:折旧状态为“提折旧”时必填,参考"折旧状态"填写
	ExptMonth int null,					--使用年限/月份:折旧状态为“提折旧”时必填,以月份为计量单位
	UsedMonth int null,					--已提折旧月数:非必填，以月份为计量单位
	RMValueRate numeric(19,2) null,		--残值率
	DeValue numeric(19,2) null,			--减值准备

	PlaceID nvarchar(150) not null,		--存放地点
	BMID varchar(12) not null,			--使用\管理部门
	ShiYRName nvarchar(30) null,		--使用人名称
	Remark nvarchar(250) null,			--备注:当"取得方式""使用状况""使用方向"为"其他"时，备注必填
	Operator nvarchar(30) not null,		--制单人
	GuanLRID nvarchar(30) null,			--管理人

 CONSTRAINT [PK_EqpElectrical] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[QingCXTZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[EqpElectrical]  WITH CHECK ADD  CONSTRAINT [FK_EqpElectrical_CZreportCenter] FOREIGN KEY([reportNum])
REFERENCES [dbo].[CZreportCenter] ([reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EqpElectrical] CHECK CONSTRAINT [FK_EqpElectrical_CZreportCenter]

--7.电子产品及通信设备：EqpCommunicate
--与3.通用设备：generalEqp表结构完全一致！
drop TABLE [dbo].[EqpCommunicate]
CREATE TABLE [dbo].[EqpCommunicate](
	reportNum varchar(12) not null,		--主键/外键：报表编号
	QingCXTZCBH	varchar(12) not null,	--主键：资产编号
	BillDate smalldatetime not null,	--单据日期
	CatalogID varchar(7) not null,		--资产分类代码
	StdName nvarchar(30) not null,		--资产名称
	JiLDWCZB nvarchar(10) not null,		--计量单位
	PinP nvarchar(30) null,				--品牌
	Spec nvarchar(60) null,				--规格型号
	JiaZXSName nvarchar(10) not null,	--价值类型:原值，暂估值，重置值，无价值
	OrgnValue numeric(19,2)	not null,	--价值:价值类型不是"无价值"时必填,与"财政性拨款"、"事业收入"与"其他资金"合计相等

	CaiZXJFLY numeric(19,2) null,		--财政性拨款
	ShiYSR numeric(19,2) null,			--事业收入
	QiZYSWSR numeric(19,2) null,		--事业收入：预算外收入
	QiTJFLY numeric(19,2) null,			--其他资金
	QiZCZXJYZJ numeric(19,2) null,		--其他资金：财政性结余资金

	KuaiJPZH varchar(12) null,			--会计凭证号
	SrcName	nvarchar(10) not null,		--取得方式:购置,调拨,捐赠,划拨,置换,其他
	BuildDate smalldatetime not null,	--取得日期
	BaoXJZRQ smalldatetime null,		--保修截止日期

	CGZZXS3	nvarchar(10) not null,		--采购组织形式:政府集中机构采购，部门集中采购，分散采购，其他
	UsedStateBDName	nvarchar(10) not null, --使用状况:在用，未使用，不需用，毁坏不能用，其他
	UsedwayBDName nvarchar(10) not null,	--使用方向:自用,出租，出借，对外投资，担保，其他
	ChuZCJDFDW nvarchar(60) null,		--出租/出借对方单位

	DPRCTStateName nvarchar(10) not null,	--折旧状态:不提折旧，提折旧，已完成折旧
	DPRCTWayName nvarchar(10) null,		--折旧方法:折旧状态为“提折旧”时必填,参考"折旧状态"填写
	ExptMonth int null,					--使用年限/月份:折旧状态为“提折旧”时必填,以月份为计量单位
	UsedMonth int null,					--已提折旧月数:非必填，以月份为计量单位
	RMValueRate numeric(19,2) null,		--残值率
	DeValue numeric(19,2) null,			--减值准备

	PlaceID nvarchar(150) not null,		--存放地点
	BMID varchar(12) not null,			--使用\管理部门
	ShiYRName nvarchar(30) null,		--使用人名称
	Remark nvarchar(250) null,			--备注:当"取得方式""使用状况""使用方向"为"其他"时，备注必填
	Operator nvarchar(30) not null,		--制单人
	GuanLRID nvarchar(30) null,			--管理人

 CONSTRAINT [PK_EqpCommunicate] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[QingCXTZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[EqpCommunicate]  WITH CHECK ADD  CONSTRAINT [FK_EqpCommunicate_CZreportCenter] FOREIGN KEY([reportNum])
REFERENCES [dbo].[CZreportCenter] ([reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EqpCommunicate] CHECK CONSTRAINT [FK_EqpCommunicate_CZreportCenter]

--8.仪器仪表及量具：EqpInstrument
--与3.通用设备：generalEqp表结构完全一致！
drop TABLE [dbo].[EqpInstrument]
CREATE TABLE [dbo].[EqpInstrument](
	reportNum varchar(12) not null,		--主键/外键：报表编号
	QingCXTZCBH	varchar(12) not null,	--主键：资产编号
	BillDate smalldatetime not null,	--单据日期
	CatalogID varchar(7) not null,		--资产分类代码
	StdName nvarchar(30) not null,		--资产名称
	JiLDWCZB nvarchar(10) not null,		--计量单位
	PinP nvarchar(30) null,				--品牌
	Spec nvarchar(60) null,				--规格型号
	JiaZXSName nvarchar(10) not null,	--价值类型:原值，暂估值，重置值，无价值
	OrgnValue numeric(19,2)	not null,	--价值:价值类型不是"无价值"时必填,与"财政性拨款"、"事业收入"与"其他资金"合计相等

	CaiZXJFLY numeric(19,2) null,		--财政性拨款
	ShiYSR numeric(19,2) null,			--事业收入
	QiZYSWSR numeric(19,2) null,		--事业收入：预算外收入
	QiTJFLY numeric(19,2) null,			--其他资金
	QiZCZXJYZJ numeric(19,2) null,		--其他资金：财政性结余资金

	KuaiJPZH varchar(12) null,			--会计凭证号
	SrcName	nvarchar(10) not null,		--取得方式:购置,调拨,捐赠,划拨,置换,其他
	BuildDate smalldatetime not null,	--取得日期
	BaoXJZRQ smalldatetime null,		--保修截止日期

	CGZZXS3	nvarchar(10) not null,		--采购组织形式:政府集中机构采购，部门集中采购，分散采购，其他
	UsedStateBDName	nvarchar(10) not null, --使用状况:在用，未使用，不需用，毁坏不能用，其他
	UsedwayBDName nvarchar(10) not null,	--使用方向:自用,出租，出借，对外投资，担保，其他
	ChuZCJDFDW nvarchar(60) null,		--出租/出借对方单位

	DPRCTStateName nvarchar(10) not null,	--折旧状态:不提折旧，提折旧，已完成折旧
	DPRCTWayName nvarchar(10) null,		--折旧方法:折旧状态为“提折旧”时必填,参考"折旧状态"填写
	ExptMonth int null,					--使用年限/月份:折旧状态为“提折旧”时必填,以月份为计量单位
	UsedMonth int null,					--已提折旧月数:非必填，以月份为计量单位
	RMValueRate numeric(19,2) null,		--残值率
	DeValue numeric(19,2) null,			--减值准备

	PlaceID nvarchar(150) not null,		--存放地点
	BMID varchar(12) not null,			--使用\管理部门
	ShiYRName nvarchar(30) null,		--使用人名称
	Remark nvarchar(250) null,			--备注:当"取得方式""使用状况""使用方向"为"其他"时，备注必填
	Operator nvarchar(30) not null,		--制单人
	GuanLRID nvarchar(30) null,			--管理人

 CONSTRAINT [PK_EqpInstrument] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[QingCXTZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[EqpInstrument]  WITH CHECK ADD  CONSTRAINT [FK_EqpInstrument_CZreportCenter] FOREIGN KEY([reportNum])
REFERENCES [dbo].[CZreportCenter] ([reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EqpInstrument] CHECK CONSTRAINT [FK_EqpInstrument_CZreportCenter]

--9.文艺体育设备：EqpSport
--与3.通用设备：generalEqp表结构基本一致，多一个“数量”字段，字段排列顺序不同！
drop TABLE [dbo].[EqpSport]
CREATE TABLE [dbo].[EqpSport](
	reportNum varchar(12) not null,		--主键/外键：报表编号
	QingCXTZCBH	varchar(12) not null,	--主键：资产编号
	BillDate smalldatetime not null,	--单据日期
	CatalogID varchar(7) not null,		--资产分类代码
	StdName nvarchar(30) not null,		--资产名称
	JiLDWCZB nvarchar(10) not null,		--计量单位
	QTY	int not null,					--数量:正整数，不可拆分的资产数量必须是1
	PinP nvarchar(30) null,				--品牌
	Spec nvarchar(60) null,				--规格型号
	KuaiJPZH varchar(12) null,			--会计凭证号
	JiaZXSName nvarchar(10) not null,	--价值类型:原值，暂估值，重置值，无价值
	OrgnValue numeric(19,2)	not null,	--价值:价值类型不是"无价值"时必填,与"财政性拨款"、"事业收入"与"其他资金"合计相等

	CaiZXJFLY numeric(19,2) null,		--财政性拨款
	ShiYSR numeric(19,2) null,			--事业收入
	QiZYSWSR numeric(19,2) null,		--事业收入：预算外收入
	QiTJFLY numeric(19,2) null,			--其他资金
	QiZCZXJYZJ numeric(19,2) null,		--其他资金：财政性结余资金

	SrcName	nvarchar(10) not null,		--取得方式:购置,调拨,捐赠,划拨,置换,其他
	DPRCTStateName nvarchar(10) not null,	--折旧状态:不提折旧，提折旧，已完成折旧
	DPRCTWayName nvarchar(10) null,		--折旧方法:折旧状态为“提折旧”时必填,参考"折旧状态"填写
	ExptMonth int null,					--使用年限/月份:折旧状态为“提折旧”时必填,以月份为计量单位
	UsedMonth int null,					--已提折旧月数:非必填，以月份为计量单位
	RMValueRate numeric(19,2) null,		--残值率
	DeValue numeric(19,2) null,			--减值准备

	BuildDate smalldatetime not null,	--取得日期
	BaoXJZRQ smalldatetime null,		--保修截止日期

	UsedwayBDName nvarchar(10) not null,	--使用方向:自用,出租，出借，对外投资，担保，其他
	ChuZCJDFDW nvarchar(60) null,		--出租/出借对方单位
	CGZZXS3	nvarchar(10) not null,		--采购组织形式:政府集中机构采购，部门集中采购，分散采购，其他
	UsedStateBDName	nvarchar(10) not null, --使用状况:在用，未使用，不需用，毁坏不能用，其他

	PlaceID nvarchar(150) not null,		--存放地点
	BMID varchar(12) not null,			--使用\管理部门
	ShiYRName nvarchar(30) null,		--使用人名称
	Remark nvarchar(250) null,			--备注:当"取得方式""使用状况""使用方向"为"其他"时，备注必填
	Operator nvarchar(30) not null,		--制单人
	GuanLRID nvarchar(30) null,			--管理人

 CONSTRAINT [PK_EqpSport] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[QingCXTZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[EqpSport]  WITH CHECK ADD  CONSTRAINT [FK_EqpSport_CZreportCenter] FOREIGN KEY([reportNum])
REFERENCES [dbo].[CZreportCenter] ([reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EqpSport] CHECK CONSTRAINT [FK_EqpSport_CZreportCenter]

--10.图书文物及陈列品：EqpCultural
drop TABLE [dbo].[EqpCultural]
CREATE TABLE [dbo].[EqpCultural](
	reportNum varchar(12) not null,		--主键/外键：报表编号
	QingCXTZCBH	varchar(12) not null,	--主键：资产编号
	BillDate smalldatetime not null,	--单据日期
	CatalogID varchar(7) not null,		--资产分类代码
	StdName nvarchar(30) not null,		--资产名称
	JiLDWCZB nvarchar(10) not null,		--计量单位
	QTY	int not null,					--数量:正整数，不可拆分的资产数量必须是1

	WenWDJName nvarchar(30) null,		--文物等级名称
	PlaceID nvarchar(150) not null,		--存放地点
	ZuoLWZ nvarchar(150) not null,		--坐落位置
	JiaZXSName nvarchar(10) not null,	--价值类型:原值，暂估值，重置值，无价值
	OrgnValue numeric(19,2)	not null,	--价值:价值类型不是"无价值"时必填,与"财政性拨款"、"事业收入"与"其他资金"合计相等

	CaiZXJFLY numeric(19,2) null,		--财政性拨款
	ShiYSR numeric(19,2) null,			--事业收入
	QiZYSWSR numeric(19,2) null,		--事业收入：预算外收入
	QiTJFLY numeric(19,2) null,			--其他资金
	QiZCZXJYZJ numeric(19,2) null,		--其他资金：财政性结余资金

	KuaiJPZH varchar(12) null,			--会计凭证号
	CGZZXS3	nvarchar(10) not null,		--采购组织形式:政府集中机构采购，部门集中采购，分散采购，其他
	UsedStateBDName	nvarchar(10) not null, --使用状况:在用，未使用，不需用，毁坏不能用，其他
	UsedwayBDName nvarchar(10) not null,	--使用方向:自用,出租，出借，对外投资，担保，其他
	BuildDate smalldatetime not null,	--取得日期
	SrcName	nvarchar(10) not null,		--取得方式:购置,调拨,捐赠,划拨,置换,其他

	ChanQXSName	nvarchar(10) null,		--产权形式:有产权，无产权
	BMID varchar(12) not null,			--使用\管理部门
	GuanLDW nvarchar(60) null,			--管理单位(机构)
	ShiYRName nvarchar(30) null,		--使用人名称
	Remark nvarchar(250) null,			--备注:当"取得方式""使用状况""使用方向"为"其他"时，备注必填
	Operator nvarchar(30) not null,		--制单人
	GuanLRID nvarchar(30) null,			--管理人

 CONSTRAINT [PK_EqpCultural] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[QingCXTZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[EqpCultural]  WITH CHECK ADD  CONSTRAINT [FK_EqpCultural_CZreportCenter] FOREIGN KEY([reportNum])
REFERENCES [dbo].[CZreportCenter] ([reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EqpCultural] CHECK CONSTRAINT [FK_EqpCultural_CZreportCenter]

--11.家具用具及其他类：EqpFurniture
--与3.通用设备：generalEqp表结构基本一致，多一个“数量”字段，字段排列顺序不同！
--与9.文艺体育设备：EqpSport完全一致！
drop TABLE [dbo].[EqpFurniture]
CREATE TABLE [dbo].[EqpFurniture](
	reportNum varchar(12) not null,		--主键/外键：报表编号
	QingCXTZCBH	varchar(12) not null,	--主键：资产编号
	BillDate smalldatetime not null,	--单据日期
	CatalogID varchar(7) not null,		--资产分类代码
	StdName nvarchar(30) not null,		--资产名称
	JiLDWCZB nvarchar(10) not null,		--计量单位
	QTY	int not null,					--数量:正整数，不可拆分的资产数量必须是1
	PinP nvarchar(30) null,				--品牌
	Spec nvarchar(60) null,				--规格型号
	KuaiJPZH varchar(12) null,			--会计凭证号
	JiaZXSName nvarchar(10) not null,	--价值类型:原值，暂估值，重置值，无价值
	OrgnValue numeric(19,2)	not null,	--价值:价值类型不是"无价值"时必填,与"财政性拨款"、"事业收入"与"其他资金"合计相等

	CaiZXJFLY numeric(19,2) null,		--财政性拨款
	ShiYSR numeric(19,2) null,			--事业收入
	QiZYSWSR numeric(19,2) null,		--事业收入：预算外收入
	QiTJFLY numeric(19,2) null,			--其他资金
	QiZCZXJYZJ numeric(19,2) null,		--其他资金：财政性结余资金

	SrcName	nvarchar(10) not null,		--取得方式:购置,调拨,捐赠,划拨,置换,其他
	DPRCTStateName nvarchar(10) not null,	--折旧状态:不提折旧，提折旧，已完成折旧
	DPRCTWayName nvarchar(10) null,		--折旧方法:折旧状态为“提折旧”时必填,参考"折旧状态"填写
	ExptMonth int null,					--使用年限/月份:折旧状态为“提折旧”时必填,以月份为计量单位
	UsedMonth int null,					--已提折旧月数:非必填，以月份为计量单位
	RMValueRate numeric(19,2) null,		--残值率
	DeValue numeric(19,2) null,			--减值准备

	BuildDate smalldatetime not null,	--取得日期
	BaoXJZRQ smalldatetime null,		--保修截止日期

	UsedwayBDName nvarchar(10) not null,	--使用方向:自用,出租，出借，对外投资，担保，其他
	ChuZCJDFDW nvarchar(60) null,		--出租/出借对方单位
	CGZZXS3	nvarchar(10) not null,		--采购组织形式:政府集中机构采购，部门集中采购，分散采购，其他
	UsedStateBDName	nvarchar(10) not null, --使用状况:在用，未使用，不需用，毁坏不能用，其他

	PlaceID nvarchar(150) not null,		--存放地点
	BMID varchar(12) not null,			--使用\管理部门
	ShiYRName nvarchar(30) null,		--使用人名称
	Remark nvarchar(250) null,			--备注:当"取得方式""使用状况""使用方向"为"其他"时，备注必填
	Operator nvarchar(30) not null,		--制单人
	GuanLRID nvarchar(30) null,			--管理人

 CONSTRAINT [PK_EqpFurniture] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[QingCXTZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[EqpFurniture]  WITH CHECK ADD  CONSTRAINT [FK_EqpFurniture_CZreportCenter] FOREIGN KEY([reportNum])
REFERENCES [dbo].[CZreportCenter] ([reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EqpFurniture] CHECK CONSTRAINT [FK_EqpFurniture_CZreportCenter]


--12.无形资产：intangible
drop table [dbo].[intangible]
CREATE TABLE [dbo].[intangible](
	reportNum varchar(12) not null,		--主键/外键：报表编号
	QingCXTZCBH	varchar(12) not null,	--主键：资产编号
	BillDate smalldatetime not null,	--单据日期
	CatalogID varchar(7) not null,		--资产分类代码
	StdName nvarchar(30) not null,		--资产名称

	SrcName	nvarchar(10) not null,		--取得方式:购置,调拨,捐赠,划拨,置换,其他
	BuildDate smalldatetime not null,	--取得日期
	QTY	int not null,					--数量:正整数，不可拆分的资产数量必须是1
	KuaiJPZH varchar(12) not null,		--会计凭证号:必填
	JiaZXSName nvarchar(10) not null,	--价值类型:原值，暂估值，重置值，无价值
	OrgnValue numeric(19,2)	not null,	--价值:价值类型不是无价时，价值必填，只需输入数值
	PingGJZ numeric(19,2) not null,		--评估价值:评估价值必填，只需输入数值

	UsedStateBDName	nvarchar(10) not null, --使用状况:在用，未使用，其他
	UsedwayBDName nvarchar(10) not null,--使用方向:自用,出租,出借,闲置,对外投资,经营,其他

	ShiYNX int null,					--使用年限
	ZhuCDJJG nvarchar(100) null,		--注册登记机关
	ZhuCDJSJ smalldatetime null,		--注册登记时间
	ZhuanLH nvarchar(100) null,			--专利号
	PiZWH nvarchar(50) null,			--批准文号
	
	GuanLDW nvarchar(60) null,			--管理单位(机构)
	Remark nvarchar(250) null,			--备注:当"取得方式""使用状况""使用方向"为"其他"时，备注必填
	Operator nvarchar(30) not null,		--制单人

 CONSTRAINT [PK_intangible] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[QingCXTZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[intangible]  WITH CHECK ADD  CONSTRAINT [FK_intangible_CZreportCenter] FOREIGN KEY([reportNum])
REFERENCES [dbo].[CZreportCenter] ([reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[intangible] CHECK CONSTRAINT [FK_intangible_CZreportCenter]


DROP PROCEDURE makeCReport
/*
	name:		makeCReport
	function:	1.根据统计日期生成财政部统计报表
	input: 
				@theTitle nvarchar(100),		--报表标题
				@theYear varchar(4),			--统计年度
				@totalEndDate varchar(10),		--统计结束日期:"yyyy-MM-dd"格式

				@makeUnit nvarchar(50),			--制表单位
				@makeDate smalldatetime,		--制表日期

				@makerID varchar(10),			--制表人工号
	output: 
				@Ret		int output,			--操作成功标识：0:成功，9:未知错误
				@reportNum varchar(12) output	--报表编号
	author:		卢苇
	CreateDate:	2012-10-1
	UpdateDate: 
*/
create PROCEDURE makeCReport
	@theTitle nvarchar(100),		--报表标题
	@theYear varchar(4),			--统计年度
	@totalEndDate varchar(10),		--统计结束日期:"yyyy-MM-dd"格式

	@makeUnit nvarchar(50),			--制表单位
	@makerID varchar(10),			--制表人工号
	@Ret		int output,			--操作成功标识：0:成功，9:未知错误
	@reportNum varchar(12) output	--报表编号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器生成报表编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 800, 1, @curNumber output
	set @reportNum = @curNumber

	--获取制表人姓名：
	declare @maker nvarchar(30)
	set @maker = isnull((select userCName from activeUsers where userID = @makerID),'')
	--制表日期：
	declare @makeDate smalldatetime		--制表日期
	set @makeDate = GETDATE()
	
	
	--生成索引表：
	begin tran
		insert CZreportCenter(reportNum, theTitle, theYear, totalEndDate,
				--资产（设备）分类汇总信息：
				LandValue,		--1.土地合计金额
				BuildingValue,	--2.房屋构筑物合计金额
				generalEqpValue,--3.通用设备合计金额
				specialEqpValue,--4.专用设备合计金额
				EqpCarValue,	--5.交通运输设备合计金额
				EqpElectricalValue,--6.电气设备合计金额
				EqpCommunicateValue,--7.电子产品及通信设备合计金额
				EqpInstrumentValue,--8.仪器仪表及量具合计金额
				EqpSportValue,	--9.文艺体育设备合计金额
				EqpCulturalValue,--10.图书文物及陈列品合计金额
				EqpFurnitureValue,--11.家具用具及其他类合计金额
				intangibleValue,--11.无形资产合计金额
				
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

		--1.生成“01.土地”报表：
		set @LandValue = 0
		set @BuildingValue = 0
		--2.生成“02.房屋及构筑物”报表：
		--3.生成“03.通用设备”报表：
		insert generalEqp(reportNum, BillDate, QingCXTZCBH, CatalogID, StdName, JiLDWCZB, PinP, Spec,
							JiaZXSName, OrgnValue,
							CaiZXJFLY, ShiYSR, QiZYSWSR, QiTJFLY, QiZCZXJYZJ,
							KuaiJPZH, SrcName, BuildDate, BaoXJZRQ,
							CGZZXS3, UsedStateBDName, UsedwayBDName, ChuZCJDFDW, 
							DPRCTStateName, DPRCTWayName, ExptMonth, UsedMonth, RMValueRate, DeValue,
							PlaceID, BMID, ShiYRName, Remark, Operator, GuanLRID)
		select @reportNum, acceptDate, e.eCode, e.aTypeCode, eName, g.unit, factory,
				case eModel when '*' then eFormat when '' then eFormat else eModel end as '规格型号(Spec)',
				'原值' as '价值类型(JiaZXSID)', totalAmount as '价值(OrgnValue)', 
				totalAmount as '财政性拨款(CaiZXJFLY)',	
				0 as '事业收入(ShiYSR)',0 as '事业收入：预算外收入(QiZYSWSR)', 0 as '其他资金(QiTJFLY)',
				0 as '其他资金：财政性结余资金(QiZCZXJYZJ)', 
				'' as '会计凭证号(KuaiJPZH)',
				case fCode when '6 ' then '捐赠' else case maker.status when '自制' then '其他' else '新购' end end as '取得方式(SrcID)',
				buyDate as '取得日期(BuildDate)', '' as '保修截止日期(BaoXJZRQ)', 
				'部门集中采购' as '采购组织形式(CGZZXSID)',
				case curEqpStatus when 4 then '毁坏不能用' else '在用' end as '使用状况(UsedStateBDID)',
				'自用' as '使用方向(UsedwayBDID)','' as '出租/出借对方单位(ChuZCJDFDW)',
				'不提折旧' as '折旧状态(DPRCTState)', '' as '折旧方法(DPRCTWayID)', null as '使用年限/月份(ExptMonth)', null as '已提折旧月数(UsedMonth)',
				null as '残值率(RMValueRate)', null as '减值准备(DeValue)', 
				'' as '存放地点(PlaceID)', t.dCode as '使用/管理部门(BMID)', '' as '使用人(ShiYRID)', 
				case maker.status when '自制' then '自制' else '' end as '备注(Remark)', 
				@maker as '制单人(Operator)', '' as '管理人(GuanLRID)'
		from equipmentList e left join GBT14885 g on e.aTypeCode = g.aTypeCode
			left join collegeCode t on e.clgCode = t.clgCode
			left join (select eCode,'自制' as status from equipmentList
						where notes like '%自制%'
								or factory like '%武汉大学%'
								or eModel like '%自制%'
								or eFormat like '%自制%'
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
		--4.生成“04.专用设备”报表：
		insert specialEqp(reportNum, BillDate, QingCXTZCBH, CatalogID, StdName, JiLDWCZB, PinP, Spec,
							JiaZXSName, OrgnValue,
							CaiZXJFLY, ShiYSR, QiZYSWSR, QiTJFLY, QiZCZXJYZJ,
							KuaiJPZH, SrcName, BuildDate, BaoXJZRQ,
							CGZZXS3, UsedStateBDName, UsedwayBDName, ChuZCJDFDW, 
							DPRCTStateName, DPRCTWayName, ExptMonth, UsedMonth, RMValueRate, DeValue,
							PlaceID, BMID, ShiYRName, Remark, Operator, GuanLRID)
		select @reportNum, acceptDate, e.eCode, e.aTypeCode, eName, g.unit, factory,
				case eModel when '*' then eFormat when '' then eFormat else eModel end as '规格型号(Spec)',
				'原值' as '价值类型(JiaZXSID)', totalAmount as '价值(OrgnValue)', 
				totalAmount as '财政性拨款(CaiZXJFLY)',	
				0 as '事业收入(ShiYSR)',0 as '事业收入：预算外收入(QiZYSWSR)', 0 as '其他资金(QiTJFLY)',
				0 as '其他资金：财政性结余资金(QiZCZXJYZJ)', 
				'' as '会计凭证号(KuaiJPZH)',
				case fCode when '6 ' then '捐赠' else case maker.status when '自制' then '其他' else '新购' end end as '取得方式(SrcID)',
				buyDate as '取得日期(BuildDate)', '' as '保修截止日期(BaoXJZRQ)', 
				'部门集中采购' as '采购组织形式(CGZZXSID)',
				case curEqpStatus when 4 then '毁坏不能用' else '在用' end as '使用状况(UsedStateBDID)',
				'自用' as '使用方向(UsedwayBDID)','' as '出租/出借对方单位(ChuZCJDFDW)',
				'不提折旧' as '折旧状态(DPRCTState)', '' as '折旧方法(DPRCTWayID)', null as '使用年限/月份(ExptMonth)', null as '已提折旧月数(UsedMonth)',
				null as '残值率(RMValueRate)', null as '减值准备(DeValue)', 
				'' as '存放地点(PlaceID)', t.dCode as '使用/管理部门(BMID)', '' as '使用人(ShiYRID)', 
				case maker.status when '自制' then '自制' else '' end as '备注(Remark)', 
				@maker as '制单人(Operator)', '' as '管理人(GuanLRID)'
		from equipmentList e left join GBT14885 g on e.aTypeCode = g.aTypeCode
			left join collegeCode t on e.clgCode = t.clgCode
			left join (select eCode,'自制' as status from equipmentList
						where notes like '%自制%'
								or factory like '%武汉大学%'
								or eModel like '%自制%'
								or eFormat like '%自制%'
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
		--5.生成“05.交通运输设备”报表：
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
				'财政在编', '原值' as '价值类型(JiaZXSID)', totalAmount as '价值(OrgnValue)', 
				totalAmount as '财政性拨款(CaiZXJFLY)',	
				0 as '事业收入(ShiYSR)',0 as '事业收入：预算外收入(QiZYSWSR)', 0 as '其他资金(QiTJFLY)',
				0 as '其他资金：财政性结余资金(QiZCZXJYZJ)', 
				cd2.objDesc, '' as '会计凭证号(KuaiJPZH)',
				buyDate as '取得日期(BuildDate)', 
				case fCode when '6 ' then '捐赠' else case maker.status when '自制' then '其他' else '新购' end end as '取得方式(SrcID)',
				'' as '保修截止日期(BaoXJZRQ)', '' as '使用日期',
				'自用' as '使用方向(UsedwayBDID)', '' as '出租/出借对方单位(ChuZCJDFDW)',
				t.dCode as '使用/管理部门(BMID)', '' as '使用人(ShiYRID)', 
				'部门集中采购' as '采购组织形式(CGZZXSID)',
				case curEqpStatus when 4 then '毁坏不能用' else '在用' end as '使用状况(UsedStateBDID)',
				'不提折旧' as '折旧状态(DPRCTState)', '' as '折旧方法(DPRCTWayID)', null as '使用年限/月份(ExptMonth)', null as '已提折旧月数(UsedMonth)',
				null as '残值率(RMValueRate)', null as '减值准备(DeValue)', 
				case maker.status when '自制' then '自制' else '' end as '备注(Remark)', 
				@maker as '制单人(Operator)', '' as '管理人(GuanLRID)'
		from equipmentList e left join eqpCarExtInfo ext on e.eCode = ext.eCode 
			left join codeDictionary cd1 on ext.origin = cd1.objCode and cd1.classCode = 20
			left join codeDictionary cd2 on ext.useDirection = cd2.objCode and cd1.classCode = 21
			left join GBT14885 g on e.aTypeCode = g.aTypeCode
			left join collegeCode t on e.clgCode = t.clgCode
			left join (select eCode,'自制' as status from equipmentList
						where notes like '%自制%'
								or factory like '%武汉大学%'
								or eModel like '%自制%'
								or eFormat like '%自制%'
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
		--6.生成“06.电气设备”报表：
		insert EqpElectrical(reportNum, BillDate, QingCXTZCBH, CatalogID, StdName, JiLDWCZB, PinP, Spec,
							JiaZXSName, OrgnValue,
							CaiZXJFLY, ShiYSR, QiZYSWSR, QiTJFLY, QiZCZXJYZJ,
							KuaiJPZH, SrcName, BuildDate, BaoXJZRQ,
							CGZZXS3, UsedStateBDName, UsedwayBDName, ChuZCJDFDW, 
							DPRCTStateName, DPRCTWayName, ExptMonth, UsedMonth, RMValueRate, DeValue,
							PlaceID, BMID, ShiYRName, Remark, Operator, GuanLRID)
		select @reportNum, acceptDate, e.eCode, e.aTypeCode, eName, g.unit, factory,
				case eModel when '*' then eFormat when '' then eFormat else eModel end as '规格型号(Spec)',
				'原值' as '价值类型(JiaZXSID)', totalAmount as '价值(OrgnValue)', 
				totalAmount as '财政性拨款(CaiZXJFLY)',	
				0 as '事业收入(ShiYSR)',0 as '事业收入：预算外收入(QiZYSWSR)', 0 as '其他资金(QiTJFLY)',
				0 as '其他资金：财政性结余资金(QiZCZXJYZJ)', 
				'' as '会计凭证号(KuaiJPZH)',
				case fCode when '6 ' then '捐赠' else case maker.status when '自制' then '其他' else '新购' end end as '取得方式(SrcID)',
				buyDate as '取得日期(BuildDate)', '' as '保修截止日期(BaoXJZRQ)', 
				'部门集中采购' as '采购组织形式(CGZZXSID)',
				case curEqpStatus when 4 then '毁坏不能用' else '在用' end as '使用状况(UsedStateBDID)',
				'自用' as '使用方向(UsedwayBDID)','' as '出租/出借对方单位(ChuZCJDFDW)',
				'不提折旧' as '折旧状态(DPRCTState)', '' as '折旧方法(DPRCTWayID)', null as '使用年限/月份(ExptMonth)', null as '已提折旧月数(UsedMonth)',
				null as '残值率(RMValueRate)', null as '减值准备(DeValue)', 
				'' as '存放地点(PlaceID)', t.dCode as '使用/管理部门(BMID)', '' as '使用人(ShiYRID)', 
				case maker.status when '自制' then '自制' else '' end as '备注(Remark)', 
				@maker as '制单人(Operator)', '' as '管理人(GuanLRID)'
		from equipmentList e left join GBT14885 g on e.aTypeCode = g.aTypeCode
			left join collegeCode t on e.clgCode = t.clgCode
			left join (select eCode,'自制' as status from equipmentList
						where notes like '%自制%'
								or factory like '%武汉大学%'
								or eModel like '%自制%'
								or eFormat like '%自制%'
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
		--7.生成“07.电子产品及通信设备”报表：
		insert EqpCommunicate(reportNum, BillDate, QingCXTZCBH, CatalogID, StdName, JiLDWCZB, PinP, Spec,
							JiaZXSName, OrgnValue,
							CaiZXJFLY, ShiYSR, QiZYSWSR, QiTJFLY, QiZCZXJYZJ,
							KuaiJPZH, SrcName, BuildDate, BaoXJZRQ,
							CGZZXS3, UsedStateBDName, UsedwayBDName, ChuZCJDFDW, 
							DPRCTStateName, DPRCTWayName, ExptMonth, UsedMonth, RMValueRate, DeValue,
							PlaceID, BMID, ShiYRName, Remark, Operator, GuanLRID)
		select @reportNum, acceptDate, e.eCode, e.aTypeCode, eName, g.unit, factory,
				case eModel when '*' then eFormat when '' then eFormat else eModel end as '规格型号(Spec)',
				'原值' as '价值类型(JiaZXSID)', totalAmount as '价值(OrgnValue)', 
				totalAmount as '财政性拨款(CaiZXJFLY)',	
				0 as '事业收入(ShiYSR)',0 as '事业收入：预算外收入(QiZYSWSR)', 0 as '其他资金(QiTJFLY)',
				0 as '其他资金：财政性结余资金(QiZCZXJYZJ)', 
				'' as '会计凭证号(KuaiJPZH)',
				case fCode when '6 ' then '捐赠' else case maker.status when '自制' then '其他' else '新购' end end as '取得方式(SrcID)',
				buyDate as '取得日期(BuildDate)', '' as '保修截止日期(BaoXJZRQ)', 
				'部门集中采购' as '采购组织形式(CGZZXSID)',
				case curEqpStatus when 4 then '毁坏不能用' else '在用' end as '使用状况(UsedStateBDID)',
				'自用' as '使用方向(UsedwayBDID)','' as '出租/出借对方单位(ChuZCJDFDW)',
				'不提折旧' as '折旧状态(DPRCTState)', '' as '折旧方法(DPRCTWayID)', null as '使用年限/月份(ExptMonth)', null as '已提折旧月数(UsedMonth)',
				null as '残值率(RMValueRate)', null as '减值准备(DeValue)', 
				'' as '存放地点(PlaceID)', t.dCode as '使用/管理部门(BMID)', '' as '使用人(ShiYRID)', 
				case maker.status when '自制' then '自制' else '' end as '备注(Remark)', 
				@maker as '制单人(Operator)', '' as '管理人(GuanLRID)'
		from equipmentList e left join GBT14885 g on e.aTypeCode = g.aTypeCode
			left join collegeCode t on e.clgCode = t.clgCode
			left join (select eCode,'自制' as status from equipmentList
						where notes like '%自制%'
								or factory like '%武汉大学%'
								or eModel like '%自制%'
								or eFormat like '%自制%'
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
		--8.生成“08.仪器仪表、计量标准器具及量具、衡器”报表：
		insert EqpInstrument(reportNum, BillDate, QingCXTZCBH, CatalogID, StdName, JiLDWCZB, PinP, Spec,
							JiaZXSName, OrgnValue,
							CaiZXJFLY, ShiYSR, QiZYSWSR, QiTJFLY, QiZCZXJYZJ,
							KuaiJPZH, SrcName, BuildDate, BaoXJZRQ,
							CGZZXS3, UsedStateBDName, UsedwayBDName, ChuZCJDFDW, 
							DPRCTStateName, DPRCTWayName, ExptMonth, UsedMonth, RMValueRate, DeValue,
							PlaceID, BMID, ShiYRName, Remark, Operator, GuanLRID)
		select @reportNum, acceptDate, e.eCode, e.aTypeCode, eName, g.unit, factory,
				case eModel when '*' then eFormat when '' then eFormat else eModel end as '规格型号(Spec)',
				'原值' as '价值类型(JiaZXSID)', totalAmount as '价值(OrgnValue)', 
				totalAmount as '财政性拨款(CaiZXJFLY)',	
				0 as '事业收入(ShiYSR)',0 as '事业收入：预算外收入(QiZYSWSR)', 0 as '其他资金(QiTJFLY)',
				0 as '其他资金：财政性结余资金(QiZCZXJYZJ)', 
				'' as '会计凭证号(KuaiJPZH)',
				case fCode when '6 ' then '捐赠' else case maker.status when '自制' then '其他' else '新购' end end as '取得方式(SrcID)',
				buyDate as '取得日期(BuildDate)', '' as '保修截止日期(BaoXJZRQ)', 
				'部门集中采购' as '采购组织形式(CGZZXSID)',
				case curEqpStatus when 4 then '毁坏不能用' else '在用' end as '使用状况(UsedStateBDID)',
				'自用' as '使用方向(UsedwayBDID)','' as '出租/出借对方单位(ChuZCJDFDW)',
				'不提折旧' as '折旧状态(DPRCTState)', '' as '折旧方法(DPRCTWayID)', null as '使用年限/月份(ExptMonth)', null as '已提折旧月数(UsedMonth)',
				null as '残值率(RMValueRate)', null as '减值准备(DeValue)', 
				'' as '存放地点(PlaceID)', t.dCode as '使用/管理部门(BMID)', '' as '使用人(ShiYRID)', 
				case maker.status when '自制' then '自制' else '' end as '备注(Remark)', 
				@maker as '制单人(Operator)', '' as '管理人(GuanLRID)'
		from equipmentList e left join GBT14885 g on e.aTypeCode = g.aTypeCode
			left join collegeCode t on e.clgCode = t.clgCode
			left join (select eCode,'自制' as status from equipmentList
						where notes like '%自制%'
								or factory like '%武汉大学%'
								or eModel like '%自制%'
								or eFormat like '%自制%'
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
		--9.生成“09.文艺体育设备”报表：
		insert EqpSport(reportNum, BillDate, QingCXTZCBH, CatalogID, StdName, JiLDWCZB, PinP, Spec, QTY,
							JiaZXSName, OrgnValue,
							CaiZXJFLY, ShiYSR, QiZYSWSR, QiTJFLY, QiZCZXJYZJ,
							KuaiJPZH, SrcName, BuildDate, BaoXJZRQ,
							CGZZXS3, UsedStateBDName, UsedwayBDName, ChuZCJDFDW, 
							DPRCTStateName, DPRCTWayName, ExptMonth, UsedMonth, RMValueRate, DeValue,
							PlaceID, BMID, ShiYRName, Remark, Operator, GuanLRID)
		select @reportNum, acceptDate, e.eCode, e.aTypeCode, eName, g.unit, factory,
				case eModel when '*' then eFormat when '' then eFormat else eModel end as '规格型号(Spec)', 1,
				'原值' as '价值类型(JiaZXSID)', totalAmount as '价值(OrgnValue)', 
				totalAmount as '财政性拨款(CaiZXJFLY)',	
				0 as '事业收入(ShiYSR)',0 as '事业收入：预算外收入(QiZYSWSR)', 0 as '其他资金(QiTJFLY)',
				0 as '其他资金：财政性结余资金(QiZCZXJYZJ)', 
				'' as '会计凭证号(KuaiJPZH)',
				case fCode when '6 ' then '捐赠' else case maker.status when '自制' then '其他' else '新购' end end as '取得方式(SrcID)',
				buyDate as '取得日期(BuildDate)', '' as '保修截止日期(BaoXJZRQ)', 
				'部门集中采购' as '采购组织形式(CGZZXSID)',
				case curEqpStatus when 4 then '毁坏不能用' else '在用' end as '使用状况(UsedStateBDID)',
				'自用' as '使用方向(UsedwayBDID)','' as '出租/出借对方单位(ChuZCJDFDW)',
				'不提折旧' as '折旧状态(DPRCTState)', '' as '折旧方法(DPRCTWayID)', null as '使用年限/月份(ExptMonth)', null as '已提折旧月数(UsedMonth)',
				null as '残值率(RMValueRate)', null as '减值准备(DeValue)', 
				'' as '存放地点(PlaceID)', t.dCode as '使用/管理部门(BMID)', '' as '使用人(ShiYRID)', 
				case maker.status when '自制' then '自制' else '' end as '备注(Remark)', 
				@maker as '制单人(Operator)', '' as '管理人(GuanLRID)'
		from equipmentList e left join GBT14885 g on e.aTypeCode = g.aTypeCode
			left join collegeCode t on e.clgCode = t.clgCode
			left join (select eCode,'自制' as status from equipmentList
						where notes like '%自制%'
								or factory like '%武汉大学%'
								or eModel like '%自制%'
								or eFormat like '%自制%'
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
		--10.生成“10.图书、文物及陈列品”报表：
		insert EqpCultural(reportNum, BillDate, QingCXTZCBH, CatalogID, StdName, JiLDWCZB, QTY,
							WenWDJName, PlaceID, ZuoLWZ, JiaZXSName, OrgnValue,
							CaiZXJFLY, ShiYSR, QiZYSWSR, QiTJFLY, QiZCZXJYZJ,
							KuaiJPZH, CGZZXS3, UsedStateBDName, UsedwayBDName, BuildDate, SrcName,
							ChanQXSName, BMID, GuanLDW, ShiYRName, Remark, Operator, GuanLRID)
		select @reportNum, acceptDate, e.eCode, e.aTypeCode, eName, g.unit, 1,
				'', '', '',  '原值' as '价值类型(JiaZXSID)', totalAmount as '价值(OrgnValue)', 
				totalAmount as '财政性拨款(CaiZXJFLY)',	
				0 as '事业收入(ShiYSR)',0 as '事业收入：预算外收入(QiZYSWSR)', 0 as '其他资金(QiTJFLY)',
				0 as '其他资金：财政性结余资金(QiZCZXJYZJ)', 
				'' as '会计凭证号(KuaiJPZH)',
				'部门集中采购' as '采购组织形式(CGZZXSID)',
				case curEqpStatus when 4 then '毁坏不能用' else '在用' end as '使用状况(UsedStateBDID)',
				'自用' as '使用方向(UsedwayBDID)',
				buyDate as '取得日期(BuildDate)', 
				case fCode when '6 ' then '捐赠' else case maker.status when '自制' then '其他' else '新购' end end as '取得方式(SrcID)',
				'有产权' as 产权形式,
				t.dCode as '使用/管理部门(BMID)', '' as '管理单位(机构)',
				'' as '使用人(ShiYRID)', 
				case maker.status when '自制' then '自制' else '' end as '备注(Remark)', 
				@maker as '制单人(Operator)', '' as '管理人(GuanLRID)'
		from equipmentList e left join GBT14885 g on e.aTypeCode = g.aTypeCode
			left join collegeCode t on e.clgCode = t.clgCode
			left join (select eCode,'自制' as status from equipmentList
						where notes like '%自制%'
								or factory like '%武汉大学%'
								or eModel like '%自制%'
								or eFormat like '%自制%'
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
		--11.生成“11.家具用具及其他类”报表：
		insert EqpFurniture(reportNum, BillDate, QingCXTZCBH, CatalogID, StdName, JiLDWCZB, PinP, Spec, QTY,
							JiaZXSName, OrgnValue,
							CaiZXJFLY, ShiYSR, QiZYSWSR, QiTJFLY, QiZCZXJYZJ,
							KuaiJPZH, SrcName, BuildDate, BaoXJZRQ,
							CGZZXS3, UsedStateBDName, UsedwayBDName, ChuZCJDFDW, 
							DPRCTStateName, DPRCTWayName, ExptMonth, UsedMonth, RMValueRate, DeValue,
							PlaceID, BMID, ShiYRName, Remark, Operator, GuanLRID)
		select @reportNum, acceptDate, e.eCode, e.aTypeCode, eName, g.unit, factory,
				case eModel when '*' then eFormat when '' then eFormat else eModel end as '规格型号(Spec)', 1,
				'原值' as '价值类型(JiaZXSID)', totalAmount as '价值(OrgnValue)', 
				totalAmount as '财政性拨款(CaiZXJFLY)',	
				0 as '事业收入(ShiYSR)',0 as '事业收入：预算外收入(QiZYSWSR)', 0 as '其他资金(QiTJFLY)',
				0 as '其他资金：财政性结余资金(QiZCZXJYZJ)', 
				'' as '会计凭证号(KuaiJPZH)',
				case fCode when '6 ' then '捐赠' else case maker.status when '自制' then '其他' else '新购' end end as '取得方式(SrcID)',
				buyDate as '取得日期(BuildDate)', '' as '保修截止日期(BaoXJZRQ)', 
				'部门集中采购' as '采购组织形式(CGZZXSID)',
				case curEqpStatus when 4 then '毁坏不能用' else '在用' end as '使用状况(UsedStateBDID)',
				'自用' as '使用方向(UsedwayBDID)','' as '出租/出借对方单位(ChuZCJDFDW)',
				'不提折旧' as '折旧状态(DPRCTState)', '' as '折旧方法(DPRCTWayID)', null as '使用年限/月份(ExptMonth)', null as '已提折旧月数(UsedMonth)',
				null as '残值率(RMValueRate)', null as '减值准备(DeValue)', 
				'' as '存放地点(PlaceID)', t.dCode as '使用/管理部门(BMID)', '' as '使用人(ShiYRID)', 
				case maker.status when '自制' then '自制' else '' end as '备注(Remark)', 
				@maker as '制单人(Operator)', '' as '管理人(GuanLRID)'
		from equipmentList e left join GBT14885 g on e.aTypeCode = g.aTypeCode
			left join collegeCode t on e.clgCode = t.clgCode
			left join (select eCode,'自制' as status from equipmentList
						where notes like '%自制%'
								or factory like '%武汉大学%'
								or eModel like '%自制%'
								or eFormat like '%自制%'
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
		--12.生成“12.无形资产”报表：
		set @intangibleValue = 0
		
		--写汇总信息：
		update CZreportCenter
				--资产（设备）分类汇总信息：
		set LandValue = @LandValue,					--1.土地合计金额
			BuildingValue = @BuildingValue,			--2.房屋构筑物合计金额
			generalEqpValue = @generalEqpValue,		--3.通用设备合计金额
			specialEqpValue = @specialEqpValue,		--4.专用设备合计金额
			EqpCarValue = @EqpCarValue,				--5.交通运输设备合计金额
			EqpElectricalValue = @EqpElectricalValue,--6.电气设备合计金额
			EqpCommunicateValue = @EqpCommunicateValue,--7.电子产品及通信设备合计金额
			EqpInstrumentValue = @EqpInstrumentValue,--8.仪器仪表及量具合计金额
			EqpSportValue = @EqpSportValue,			--9.文艺体育设备合计金额
			EqpCulturalValue = @EqpCulturalValue,	--10.图书文物及陈列品合计金额
			EqpFurnitureValue = @EqpFurnitureValue,	--11.家具用具及其他类合计金额
			intangibleValue = @intangibleValue		--12.无形资产合计金额
		where reportNum = @reportNum
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    
	commit tran	
	set @Ret = 0
	--写工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@makerID, @maker, @makeDate, '生成财政部报表', '系统根据用户' + @maker + 
					'的要求生成了财政部报表[' + @reportNum + ']。')

go

--测试：
declare @Ret int , @reportNum varchar(12)
exec dbo.makeCReport '2011年财政部报表','2011','2011-12-31','武汉大学设备处','00200977',@Ret output, @reportNum output
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
	function:	2.删除指定的财政部报表
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
create PROCEDURE delCZReport
	@reportNum varchar(12),			--报表编号
	@delManID varchar(10) output,	--删除人
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的报表是否存在
	declare @count as int
	set @count=(select count(*) from CZreportCenter where reportNum = @reportNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end


	delete CZreportCenter where reportNum = @reportNum
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除财政部报表', '用户' + @delManName
												+ '删除了财政部报表['+ @reportNum +']。')

GO


drop PROCEDURE importCollege
/*
	name:		importCollege
	function:	3.注入现系统中的单位列表到财政部单位映射表中
	input: 
				@modiManID varchar(10) output,	--维护人
	output: 
				@Ret		int output			--操作成功标识
							0:成功，9：未知错误
	author:		卢苇
	CreateDate:	2012-10-8
	UpdateDate: 

*/
create PROCEDURE importCollege
	@modiManID varchar(10) output,	--维护人
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--取维护人的姓名：
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

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, getdate(), '更新单位映射表', '用户' + @modiManName
												+ '更新了财政部单位映射表。')

GO
--测试：
declare @ret int
exec dbo.importCollege '00000000000', @ret output
select @ret

select * from collegeCode

drop PROCEDURE queryCollegeCodeLocMan
/*
	name:		queryCollegeCodeLocMan
	function:	4.查询指定财政部单位映射表中单位是否有人正在编辑
	input: 
				@clgCode char(3),				--主键：院部代码
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的单位不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2012-10-11
	UpdateDate: 
*/
create PROCEDURE queryCollegeCodeLocMan
	@clgCode char(3),				--主键：院部代码
	@Ret int output,				--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from collegeCode where clgCode = @clgCode),'')
	set @Ret = 0
GO


drop PROCEDURE lockCollegeCode4Edit
/*
	name:		lockCollegeCode4Edit
	function:	5.锁定财政部单位映射表中单位编辑，避免编辑冲突
	input: 
				@clgCode char(3),				--主键：院部代码
				@lockManID varchar(10) output,	--锁定人，如果当前单位映射表行正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的单位不存在，2:要锁定的单位正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-10-11
	UpdateDate: 
*/
create PROCEDURE lockCollegeCode4Edit
	@clgCode char(3),				--主键：院部代码
	@lockManID varchar(10) output,	--锁定人，如果当前单位映射表行正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的单位是否存在
	declare @count as int
	set @count=(select count(*) from collegeCode where clgCode = @clgCode)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
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

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定映射单位编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了财政部单位映射表中单位['+ @clgCode +']为独占式编辑。')
GO

drop PROCEDURE unlockCollegeCodeEditor
/*
	name:		unlockCollegeCodeEditor
	function:	6.释放财政部单位映射表中单位编辑锁
				注意：本过程不检查单位是否存在！
	input: 
				@clgCode char(3),				--主键：院部代码
				@lockManID varchar(10) output,	--锁定人，如果当前财政部单位映射表中单位正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2012-10-11
	UpdateDate: 
*/
create PROCEDURE unlockCollegeCodeEditor
	@clgCode char(3),				--主键：院部代码
	@lockManID varchar(10) output,	--锁定人，如果当前财政部单位映射表中单位正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
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

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '释放单位映射编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了财政部单位映射表中单位['+ @clgCode+']的编辑锁。')
GO

drop PROCEDURE updateCollegeMap
/*
	name:		updateCollegeMap
	function:	7.更新单位映射
	input: 
				@clgCode char(3),			--主键：院部代码
				@dCode varchar(7),			--财政部报表系统院部代码
				@dName nvarchar(30),		--财政部报表系统院部名称
				@remark nvarchar(50),		--备注

				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前财政部单位映射表中单位正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：指定的单位不存在，
							2：要更新的单位正被别人锁定，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-10-10
	UpdateDate: 
*/
create PROCEDURE updateCollegeMap
	@clgCode char(3),			--主键：院部代码
	@dCode varchar(7),			--财政部报表系统院部代码
	@dName nvarchar(30),		--财政部报表系统院部名称
	@remark nvarchar(50),		--备注
	
	--维护人:
	@modiManID varchar(10) output,		--维护人，如果当前财政部单位映射表中单位正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,	--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的财政部单位映射表中单位是否存在
	declare @count as int
	set @count=(select count(*) from collegeCode where clgCode = @clgCode)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from collegeCode
	where clgCode = @clgCode
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

	set @updateTime = getdate()
	update collegeCode
	set dCode = @dCode, dName = @dName, remark = @remark,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where clgCode = @clgCode
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新单位映射', '用户' + @modiManName 
												+ '更新了财政部单位映射表中单位['+ @clgCode +']的映射。')
GO

drop PROCEDURE delCollegeCode
/*
	name:		delCollegeCode
	function:	8.删除指定的单位
	input: 
				@clgCode char(3),				--主键：院部代码
				@delManID varchar(10) output,	--删除人，如果当前财政部单位映射表中单位正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的单位不存在，2：要删除的单位正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2012-10-11
	UpdateDate: 

*/
create PROCEDURE delCollegeCode
	@clgCode char(3),			--主键：院部代码
	@delManID varchar(10) output,	--删除人，如果当前财政部单位映射表中单位正在被人占用编辑则返回该人的工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的单位是否存在
	declare @count as int
	set @count=(select count(*) from collegeCode where clgCode = @clgCode)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from collegeCode
	where clgCode = @clgCode
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete collegeCode where clgCode = @clgCode
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除映射单位', '用户' + @delManName
												+ '删除了财政部单位映射表中单位['+ @clgCode+']。')

GO


drop PROCEDURE clearCollegeMap
/*
	name:		clearCollegeMap
	function:	9.清除指定单位的财政部映射单位
	input: 
				@clgCode char(3),				--主键：院部代码
				@delManID varchar(10) output,	--删除人，如果当前财政部单位映射表中单位正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的单位不存在，2：要清除映射的单位正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2012-10-11
	UpdateDate: 

*/
create PROCEDURE clearCollegeMap
	@clgCode char(3),			--主键：院部代码
	@delManID varchar(10) output,	--删除人，如果当前财政部单位映射表中单位正在被人占用编辑则返回该人的工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的单位是否存在
	declare @count as int
	set @count=(select count(*) from collegeCode where clgCode = @clgCode)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from collegeCode
	where clgCode = @clgCode
	--检查编辑锁：
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

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '清除单位映射', '用户' + @delManName
												+ '清除了财政部单位映射表中单位['+ @clgCode+']的映射。')

GO

select * from collegeCode


--使用broker内部激活机制执行makeCReport存储过程：
USE master;
GO
ALTER DATABASE epdc2
      SET ENABLE_BROKER;
GO
USE epdc2;
GO

--创建消息类型:
CREATE MESSAGE TYPE [RequestMessage] VALIDATION = WELL_FORMED_XML;
CREATE MESSAGE TYPE [ReplyMessage] VALIDATION = WELL_FORMED_XML;
GO


--创建约定:
CREATE CONTRACT [SampleContract]
      ([RequestMessage]
       SENT BY INITIATOR,
       [ReplyMessage]
       SENT BY TARGET
      );
GO



--创建目标队列和服务:
CREATE QUEUE TargetQueueIntAct;

CREATE SERVICE
       [TargetService]
       ON QUEUE TargetQueueIntAct
          ([SampleContract]);
GO



--创建发起方队列和服务:
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

--创建内部激活存储过程:
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
		--						'<Msg>系统已经接收到您的请求，正在调度执行存储过程</Msg>'+
		--					'</ReplyMsg>';
		--exec dbo.talk @ReplyMsg
              
		declare @x xml
		set @x = @RecvReqMsg;
        --获取命令类型：
		declare @type varchar(30)
		set @type = (select cast(@x.query('data(/RequestMsg/oprType)') as varchar(30)))
		if (@type='Exec makeCReport')
		begin
			declare @Ret int,@reportNum varchar(12)			--操作成功标识：0:成功，9:未知错误/报表编号
			declare @theTitle nvarchar(100)		--报表标题
			declare @theYear varchar(4)			--统计年度
			declare @totalEndDate varchar(10)	--统计结束日期:"yyyy-MM-dd"格式
			declare @makeUnit nvarchar(50)		--制表单位
			declare @makerID varchar(10)		--制表人工号
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
									'<Msg>系统完成了您的创建报表请求。</Msg>'+
								'</ReplyMsg>';
			else
				set @ReplyMsg = N'<ReplyMsg>'+
									'<status>Completed</status>'+
									'<result>Error:执行出错！</result>'+
									'<Msg>系统在执行您的创建报表请求时出错！</Msg>'+
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


--更改目标队列以指定内部激活:
ALTER QUEUE TargetQueueIntAct
    WITH ACTIVATION
    ( STATUS = ON,
      PROCEDURE_NAME = TargetActivProc,
      MAX_QUEUE_READERS = 10,
      EXECUTE AS SELF
    );
GO


--启动会话并发送请求消息:
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
							'<theTitle>测试报表</theTitle>'+
							'<theYear>2011</theYear>'+
							'<totalEndDate>2011-12-31</totalEndDate>'+
							'<makeUnit>武汉大学</makeUnit>'+
							'<makerID>00000015</makerID>'+
						'</para>'+
						'<Msg>请求执行储存过程makeCReport！</Msg>'+
					'</RequestMsg>';

SEND ON CONVERSATION @InitDlgHandle
     MESSAGE TYPE [RequestMessage] (@RequestMsg);

-- Diplay sent request.
--SELECT @RequestMsg AS SentRequestMsg;

COMMIT TRANSACTION;
GO

--检查结果：
select * from CZreportCenter
delete CZreportCenter

--接收答复并结束会话：
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

--删除会话对象：
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


